Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DC96A6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 08:38:08 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so26377818pdb.3
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:38:08 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id zz15si12719113pab.73.2015.08.21.05.38.06
        for <linux-mm@kvack.org>;
        Fri, 21 Aug 2015 05:38:08 -0700 (PDT)
Message-ID: <55D71BAB.30205@internode.on.net>
Date: Fri, 21 Aug 2015 22:08:03 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz> <55D6ECBD.60303@internode.on.net> <55D70D80.5060009@suse.cz>
In-Reply-To: <55D70D80.5060009@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>



Vlastimil Babka wrote on 21/08/15 21:07:
> On 08/21/2015 11:17 AM, Arthur Marsh wrote:
>>
>>
>> Vlastimil Babka wrote on 20/08/15 17:46:
>>> On 08/19/2015 05:44 PM, Arthur Marsh wrote:
>>>> Hi, I've found that the Linus' git head kernel has had some unwelcome
>>>> behaviour where chromium browser would exhaust all swap space in the
>>>> course of a few hours. The behaviour appeared before the release of
>>>> 4.2.0-rc7.
>>>
>>> Do you have any more details about the memory/swap usage? Is it really
>>> that chromium process(es) itself eats more memory and starts swapping,
>>> or that something else (a graphics driver?) eats kernel memory, and
>>> chromium as one of the biggest processes is driven to swap by that? Can
>>> you provide e.g. top output with good/bad kernels?
>>>
>>> Also what does /proc/meminfo and /proc/zoneinfo look like when it's
>>> swapping?
>>>
>>> To see which processes use swap, you can try [1] :
>>> for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{
>>> print ""}' $file; done | sort -k 2 -n -r | less
>>>
>>> Thanks
>>>
>>> [1] http://www.cyberciti.biz/faq/linux-which-process-is-using-swap/
>>>
>>>> This does not happen with kernel 4.2.0-rc6.
>>
>> Sorry for the delay in replying. I had to give an extended run under
>> kernel 4.2.0-rc6 to obtain comparative results. Both kernels' config
>> files are attached.
>>
>> The applications running are the same both times, mainly iceweasel
>> 38.1.0esr-3 and chromium 44.0.2403.107-1.
>>
>> With the rc7+ kernel but not the rc6 kernel, chromium eventually gets
>> into a state of consuming lots of swap.
>>
>> I was able to capture the output requested when running a 4.2.0-rc7+
>> kernel (Linus' git head as of around 05:00 UTC 19 August 2015) just
>> before swap was exhausted, forcing me to do a control-alt-delete
>> shutdown and waiting ages. The kernel config for the rc7+ is attached
>>
>> The comparison good kernel is from Debian:
>> Linux am64 4.2.0-rc6-amd64 #1 SMP Debian 4.2~rc6-1~exp1 (2015-08-12)
>> x86_64 GNU/Linux
>
> Hm I didn't how similar are the configs, was the debian one used as a
> base for the self-compiled one? Just to rule out config differences...
> during the bisection you did use the same for compiling a "good" rc6
> kernel and "bad" rc7 kernel, right?
>
> That, said, looking at the memory values:
>
> rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
> rc7: ...                                   = 4714MB
>
> That's 2GB unaccounted for. Which is bad, and yet not enough to explain
> a full 4GB swap. Another noticeable difference is rc7 using 1560MB ShMem
> vs 476MB. The rest must be due to more anonymous memory used by the
> processes. Iceweasel looks unchanged, so I'm guessing the chromiums...
> the top output probably doesn't give us the whole picture here. I'm
> still suspecting a graphics driver, which one do you use?
>
> The shmem could be inspected by listing ipcs -m and ipcs -mp and grep
> grep SYSV /proc/*/maps and figuring out what processes are behind the
> pids. Doing that for rc6 and rc7 could tell us which processes use the
> extra 1GB of shmem in rc7.

I could do another test with the output you requested using an rc6 
kernel built with the same config as rc7 but it would mean the best part 
of 24 hours letting it run again.

I had observed the differences in behaviour with rc6 and rc7 kernels I 
had built with the same config, but it was difficult to bisect when the 
problems took some hours to appear.

The graphics driver is radeon, an onboard radeon 3200HD (RS780), taken 
from the r6 kernel dmesg (I have to do a power off restart with the 
onboard video to get it initialised correctly):

dmesg|egrep -i '(video|vga|radeon|agp|drm|ttm)'

[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-4.2.0-rc6-amd64 
root=UUID=39706f53-7c27-4310-b22a-36c7b042d1a1 ro radeon.audio=1
[    0.000000] AGP: No AGP bridge found
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.2.0-rc6-amd64 
root=UUID=39706f53-7c27-4310-b22a-36c7b042d1a1 ro radeon.audio=1
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] AGP: Node 0: aperture [bus addr 0xe64000000-0xe65ffffff] 
(32MB)
[    0.000000] AGP: Your BIOS doesn't leave an aperture memory hole
[    0.000000] AGP: Please enable the IOMMU option in the BIOS setup
[    0.000000] AGP: This costs you 64MB of RAM
[    0.000000] AGP: Mapping aperture over RAM [mem 
0xb4000000-0xb7ffffff] (65536KB)
[    0.000000] Console: colour VGA+ 80x25
[    0.250485] vgaarb: setting as boot device: PCI:0000:01:05.0
[    0.250524] vgaarb: device added: 
PCI:0000:01:05.0,decodes=io+mem,owns=io+mem,locks=none
[    0.250562] vgaarb: loaded
[    0.250591] vgaarb: bridge control possible 0000:01:05.0
[    0.280443] pci 0000:01:05.0: Video device with shadowed ROM
[    0.554082] PCI-DMA: Disabling AGP.
[    0.554278] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.581841] Linux agpgart interface v0.103
[    8.192329] [drm] Initialized drm 1.1.0 20060810
[    9.820433] [drm] radeon kernel modesetting enabled.
[   10.061641] [drm] initializing kernel modesetting (RS780 
0x1002:0x9610 0x1043:0x82F1).
[   10.061723] [drm] register mmio base: 0xFEAF0000
[   10.061761] [drm] register mmio size: 65536
[   10.062752] radeon 0000:01:05.0: VRAM: 256M 0x00000000C0000000 - 
0x00000000CFFFFFFF (256M used)
[   10.062802] radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 
0x00000000BFFFFFFF
[   10.062848] [drm] Detected VRAM RAM=256M, BAR=256M
[   10.062886] [drm] RAM width 32bits DDR
[   10.063199] [TTM] Zone  kernel: Available graphics memory: 3961334 kiB
[   10.063242] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[   10.063282] [TTM] Initializing pool allocator
[   10.063330] [TTM] Initializing DMA pool allocator
[   10.063415] [drm] radeon: 256M of VRAM memory ready
[   10.063457] [drm] radeon: 512M of GTT memory ready.
[   10.063521] [drm] Loading RS780 Microcode
[   10.375216] radeon 0000:01:05.0: firmware: direct-loading firmware 
radeon/RS780_pfp.bin
[   10.382622] radeon 0000:01:05.0: firmware: direct-loading firmware 
radeon/RS780_me.bin
[   10.418020] radeon 0000:01:05.0: firmware: direct-loading firmware 
radeon/R600_rlc.bin
[   10.418123] [drm] radeon: power management initialized
[   10.563323] radeon 0000:01:05.0: firmware: direct-loading firmware 
radeon/RS780_uvd.bin
[   10.563473] [drm] GART: num cpu pages 131072, num gpu pages 131072
[   10.582735] [drm] PCIE GART of 512M enabled (table at 
0x00000000C0258000).
[   10.582866] radeon 0000:01:05.0: WB enabled
[   10.582914] radeon 0000:01:05.0: fence driver on ring 0 use gpu addr 
0x00000000a0000c00 and cpu addr 0xffff8800bac13c00
[   10.587596] radeon 0000:01:05.0: fence driver on ring 5 use gpu addr 
0x00000000c0056038 and cpu addr 0xffffc90001016038
[   10.587667] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   10.587706] [drm] Driver supports precise vblank timestamp query.
[   10.587746] radeon 0000:01:05.0: radeon: MSI limited to 32-bit
[   10.587806] [drm] radeon: irq initialized.
[   10.619604] [drm] ring test on 0 succeeded in 1 usecs
[   10.794153] [drm] ring test on 5 succeeded in 1 usecs
[   10.794217] [drm] UVD initialized successfully.
[   10.794840] [drm] ib test on ring 0 succeeded in 0 usecs
[   11.441315] [drm] ib test on ring 5 succeeded
[   11.442573] [drm] Radeon Display Connectors
[   11.442625] [drm] Connector 0:
[   11.442662] [drm]   VGA-1
[   11.442701] [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 
0x7e4c 0x7e4c
[   11.442742] [drm]   Encoders:
[   11.442779] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[   11.442816] [drm] Connector 1:
[   11.442852] [drm]   HDMI-A-1
[   11.443780] [drm]   HPD3
[   11.443817] [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 
0x7e5c 0x7e5c
[   11.443857] [drm]   Encoders:
[   11.443893] [drm]     DFP3: INTERNAL_KLDSCP_LVTMA
[   11.492369] [drm] fb mappable at 0xD0359000
[   11.492402] [drm] vram apper at 0xD0000000
[   11.492430] [drm] size 8294400
[   11.492458] [drm] fb depth is 24
[   11.492487] [drm]    pitch is 7680
[   11.492697] fbcon: radeondrmfb (fb0) is primary device
[   11.548492] radeon 0000:01:05.0: fb0: radeondrmfb frame buffer device
[   11.548581] radeon 0000:01:05.0: registered panic notifier
[   11.557161] [drm] Initialized radeon 2.43.0 20080528 for 0000:01:05.0 
on minor 0
[   12.615061] Linux video capture interface: v2.00

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
