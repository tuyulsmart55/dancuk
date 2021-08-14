#!/usr/bin/env bash

DEFAULT_FAN=65
DEFAULT_MEM=1500
DEFAULT_GPU=150
DEFAULT_POW=200
echo "Setting up ${GPU_COUNT} GPU(s)..."


GPU_COUNT="$(nvidia-smi -L | wc -l)"
GPU_INDEX=0
while [ $GPU_INDEX -lt $GPU_COUNT ]; do
    FAN=""
    MEM=""
    GPU=""
    POW=""
    FAN_CTRL="-a [gpu:${GPU_INDEX}]/GPUFanControlState=1"
    POW_MIZER="-a [gpu:${GPU_INDEX}]/GPUPowerMizerMode=1"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--fan)
                FAN="-a [fan:${GPU_INDEX}]/GPUTargetFanSpeed=$2"
            ;;
            -m|--mem)
                MEM="-a [gpu:${GPU_INDEX}]/GPUMemoryTransferRateOffset[3]=$2"
            ;;
            -g|--gpu)
                GPU="-a [gpu:${GPU_INDEX}]/GPUGraphicsClockOffset[3]=$2"
            ;;
            -p|--pow)
                POW="nvidia-smi -i $GPU_INDEX -pl $2"
            *)
                FAN="-a [fan:${GPU_INDEX}]/GPUTargetFanSpeed=${DEFAULT_FAN}"
                MEM="-a [gpu:${GPU_INDEX}]/GPUMemoryTransferRateOffset[3]=${DEFAULT_MEM}"
                GPU="-a [gpu:${GPU_INDEX}]/GPUGraphicsClockOffset[3]=${DEFAULT_GPU}"
                POW="nvidia-smi -i $GPU_INDEX -pl ${DEFAULT_POW}"
            ;;
        esac
        shift
    done

    DISPLAY=:0 nvidia-settings $FAN_CTRL $FAN $POW_MIZER $MEM $GPU
    sleep 1
    $(echo $POW)
    let GPU_INDEX=GPU_INDEX+1
    sleep 2
done


echo "Complete."
exit 0
