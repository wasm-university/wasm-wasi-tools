FROM gitpod/workspace-dotnet

RUN sudo apt-get update && \
    sudo apt-get install gettext libncurses5 libxkbcommon0 libtinfo5 -y

USER gitpod

RUN brew install httpie && \
    brew install bat && \
    brew install exa && \
    brew install hey && \
    brew install pv

# ------------------------------------
# Install TinyGo
# ------------------------------------
ARG TINYGO_VERSION="0.25.0"
RUN wget https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_amd64.deb
RUN sudo dpkg -i tinygo_${TINYGO_VERSION}_amd64.deb
RUN rm tinygo_${TINYGO_VERSION}_amd64.deb

# ------------------------------------
# Install Rust support
# ------------------------------------
RUN rustup toolchain uninstall stable-x86_64-unknown-linux-gnu && \
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y && \
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh && \
    rustup target add wasm32-wasi

# ------------------------------------
# Install Grain support
# ------------------------------------
ARG GRAIN_VERSION="0.5.3"

RUN sudo curl -L --output /usr/local/bin/grain \
https://github.com/grain-lang/grain/releases/download/grain-v${GRAIN_VERSION}/grain-linux-x64 \
&& sudo chmod +x /usr/local/bin/grain

# ------------------------------------
# Install Wagi (Deislab)
# ------------------------------------
ARG WAGI_VERSION="0.8.1"
RUN mkdir tmp-wagi && \
    cd tmp-wagi && \
    wget https://github.com/deislabs/wagi/releases/download/v${WAGI_VERSION}/wagi-v${WAGI_VERSION}-linux-amd64.tar.gz && \
    tar -zxf wagi-v${WAGI_VERSION}-linux-amd64.tar.gz && \
    sudo cp wagi /usr/local/bin/wagi && \
    cd .. && \
    rm -rf tmp-wagi

# ------------------------------------
# Install Spin (Fermyon)
# ------------------------------------
# curl https://spin.fermyon.dev/downloads/install.sh | bash -s -- -v v0.5.0
ARG SPIN_VERSION="0.5.0"
RUN wget https://github.com/fermyon/spin/releases/download/v${SPIN_VERSION}/spin-v${SPIN_VERSION}-linux-amd64.tar.gz && \
    tar xfv spin-v${SPIN_VERSION}-linux-amd64.tar.gz && \
    sudo cp spin /usr/local/bin/spin && \
    rm spin; rm readme.md; rm LICENSE; rm spin-v${SPIN_VERSION}-linux-amd64.tar.gz

RUN spin templates install --git https://github.com/fermyon/spin
RUN spin templates install --git https://github.com/fermyon/spin-dotnet-sdk --branch main --update

# ------------------------------------
# Install Dot.NEt Core Preview
# ------------------------------------
# See :
# - https://dotnet.microsoft.com/en-us/download/dotnet/7.0
# - https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-7.0.100-preview.7-linux-x64-binaries

RUN wget https://download.visualstudio.microsoft.com/download/pr/aabf15d3-f201-4a6c-9a7e-def050d054af/0a8eba2d8abcf1c28605744f3a48252f/dotnet-sdk-7.0.100-preview.7.22377.5-linux-x64.tar.gz

RUN mkdir -p $HOME/dotnet && tar zxf dotnet-sdk-7.0.100-preview.7.22377.5-linux-x64.tar.gz -C $HOME/dotnet
RUN rm dotnet-sdk-7.0.100-preview.7.22377.5-linux-x64.tar.gz

RUN export DOTNET_ROOT=$HOME/dotnet && \
    export PATH=$PATH:$HOME/dotnet && \
    dotnet workload install wasm-tools

# ------------------------------------
# Install Wasi Runtimes
# ------------------------------------
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -v 0.10.0 && \
    curl https://get.wasmer.io -sSfL | sh && \
    curl https://wasmtime.dev/install.sh -sSf | bash

# ------------------------------------
# Install Subo
# ------------------------------------

RUN brew tap suborbital/subo && \
    brew install subo

# ------------------------------------
# Install Sat (Suborbital)
# ------------------------------------
RUN git clone --depth=1 https://github.com/suborbital/sat.git && \
    cd sat && \
    go build -o .bin/sat -tags netgo,wasmtime . && \
    sudo cp .bin/sat /usr/local/bin/sat && \
    cd .. && \
    rm -rf sat
