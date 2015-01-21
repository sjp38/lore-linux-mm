Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9FDF6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:09:21 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id z6so3858672yhz.10
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:09:21 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ew2si3062690pdb.190.2015.01.21.01.30.01
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 01:30:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150121023003.GF30598@verge.net.au>
References: <20150121023003.GF30598@verge.net.au>
Subject: RE: Possible regression in next-20150120 due to "mm: account pmd page
 tables to the process"
Content-Transfer-Encoding: 7bit
Message-Id: <20150121092956.4CF89A8@black.fi.intel.com>
Date: Wed, 21 Jan 2015 11:29:56 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Horman <horms@verge.net.au>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>

Simon Horman wrote:
> Hi,
> 
> I have observed what appears to be a regression caused
> by b316feb3c37ff19cd ("mm: account pmd page tables to the process").
> 
> The problem that I am seeing is that when booting the kzm9g board, which is
> based on the Renesas r8a73a4 ARM SoC, using its defconfig the following the
> tail boot log below is output repeatedly and the boot does not appear to
> proceed any further.
> 
> I have observed this problem using next-20150120 and observed
> that it does not occur when the patch mentioned above is reverted.
> 
> I have also observed what appears to be the same problem when
> booting the following boards using their defconfigs. And perhaps
> more to the point the problem appears to affect booting all
> boards based on Renesas ARM SoCs for which there is working support
> to boot them by initialising them using C (as opposed to device tree).
> 
> * armadillo800eva, based on the r8a7740 SoC
> * mackerel, based on the sh7372

This should be fixed by this:

http://marc.info/?l=linux-next&m=142176280218627&w=2

Please, test.

> 
> 
> Bytes transferred = 2531949 (26a26d hex)
> ## Booting kernel from Legacy Image at 43000000 ...
>    Image Name:   'Linux-3.19.0-rc5-next-20150120'
>    Image Type:   ARM Linux Kernel Image (uncompressed)
>    Data Size:    2531885 Bytes = 2.4 MiB
>    Load Address: 41008000
>    Entry Point:  41008000
>    Verifying Checksum ... OK
>    Loading Kernel Image ... OK
> OK
> 
> Starting kernel ...
> 
> Booting Linux on physical CPU 0x0
> Linux version 3.19.0-rc5-next-20150120 (horms@ayumi.isobedori.kobe.vergenet.net) (gcc version 4.6.3 (GCC) ) #623 SMP Wed Jan 21 11:23:05 JST 2015
> CPU: ARMv7 Processor [412fc098] revision 8 (ARMv7), cr=10c5387d
> CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
> Machine model: KZM-A9-GT
> Ignoring memory range 0x40000000 - 0x41000000
> debug: ignoring loglevel setting.
> Memory policy: Data cache writealloc
> On node 0 totalpages: 126976
> free_area_init_node: node 0, pgdat c04fb180, node_mem_map dec19000
>   Normal zone: 992 pages used for memmap
>   Normal zone: 0 pages reserved
>   Normal zone: 126976 pages, LIFO batch:31
> PERCPU: Embedded 10 pages/cpu @debf1000 s11840 r8192 d20928 u40960
> pcpu-alloc: s11840 r8192 d20928 u40960 alloc=10*4096
> pcpu-alloc: [0] 0 [0] 1 
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 125984
> Kernel command line: console=tty0 console=ttySC4,115200 root=/dev/nfs ip=dhcp ignore_loglevel rw
> PID hash table entries: 2048 (order: 1, 8192 bytes)
> Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> Memory: 498064K/507904K available (3575K kernel code, 191K rwdata, 1080K rodata, 220K init, 191K bss, 9840K reserved, 0K cma-reserved, 0K highmem)
> Virtual kernel memory layout:
>     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
>     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
>     vmalloc : 0xdf800000 - 0xff000000   ( 504 MB)
>     lowmem  : 0xc0000000 - 0xdf000000   ( 496 MB)
>     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
>     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
>       .text : 0xc0008000 - 0xc0494fa4   (4660 kB)
>       .init : 0xc0495000 - 0xc04cc000   ( 220 kB)
>       .data : 0xc04cc000 - 0xc04fbe40   ( 192 kB)
>        .bss : 0xc04fbe40 - 0xc052be0c   ( 192 kB)
> Hierarchical RCU implementation.
>         Additional per-CPU info printed with stalls.
>         RCU restricting CPUs from NR_CPUS=4 to nr_cpu_ids=2.
> RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> NR_IRQS:16 nr_irqs:16 16
> intc: Registered controller 'sh73a0-intcs' with 77 IRQs
> intc: Registered controller 'sh73a0-pint0' with 32 IRQs
> intc: Registered controller 'sh73a0-pint1' with 8 IRQs
> sched_clock: 32 bits at 128 Hz, resolution 7812500ns, wraps every 16777216000000000ns
> Console: colour dummy device 80x30
> console [tty0] enabled
>  sh-tmu.0: ch0: used for clock events
>  sh-tmu.0: ch1: used as clock source
>  sh-cmt-48.1: ch0: used for clock events
>  sh-cmt-48.1: ch1: used as clock source
> Calibrating delay loop (skipped) preset value.. 797.61 BogoMIPS (lpj=3114583)
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
> CPU: Testing write buffer coherency: ok
> CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> Setting up static identity map for 0x41385080 - 0x413850d8
> CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> Brought up 2 CPUs
> SMP: Total of 2 processors activated (1594.22 BogoMIPS).
> CPU: All CPU(s) started in SVC mode.
> devtmpfs: initialized
> VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 2
> pinctrl core: initialized pinctrl subsystem
> NET: Registered protocol family 16
> DMA: preallocated 256 KiB pool for atomic coherent allocations
> sh-pfc pfc-sh73a0: sh73a0_pfc handling gpio 0 -> 309
> sh-pfc pfc-sh73a0: sh73a0_pfc support registered
> L2C: DT/platform modifies aux control register: 0x02060000 -> 0x02460000
> L2C-310 enabling early BRESP for Cortex-A9
> L2C-310 full line of zeros enabled for Cortex-A9
> L2C-310 dynamic clock gating enabled, standby mode enabled
> L2C-310 cache controller enabled, 8 ways, 512 kB
> L2C-310: CACHE_ID 0x410000c7, AUX_CTRL 0x46460001
> renesas_intc_irqpin renesas_intc_irqpin.0: driving 8 irqs
> renesas_intc_irqpin renesas_intc_irqpin.1: driving 8 irqs
> renesas_intc_irqpin renesas_intc_irqpin.2: driving 8 irqs
> renesas_intc_irqpin renesas_intc_irqpin.3: driving 8 irqs
> No ATAGs?
> hw-breakpoint: found 5 (+1 reserved) breakpoint and 1 watchpoint registers.
> hw-breakpoint: maximum watchpoint size is 4 bytes.
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> as3711 0-0040: IRQ not supported yet
> as3711 0-0040: No cache defaults, reading back from HW
> as3711 0-0040: AS3711 detected: 8b:1
> i2c-sh_mobile i2c-sh_mobile.0: I2C adapter 0, bus speed 100000 Hz
> i2c-sh_mobile i2c-sh_mobile.1: I2C adapter 1, bus speed 100000 Hz
> i2c-sh_mobile i2c-sh_mobile.2: I2C adapter 2, bus speed 100000 Hz
> pcf857x 3-0020: probed
> i2c-sh_mobile i2c-sh_mobile.3: I2C adapter 3, bus speed 100000 Hz
> i2c-sh_mobile i2c-sh_mobile.4: I2C adapter 4, bus speed 100000 Hz
> sh_cmt sh-cmt-48.1: kept as earlytimer
> sh_tmu sh-tmu.0: kept as earlytimer
> Advanced Linux Sound Architecture Driver Initialized.
> NET: Registered protocol family 23
> Switched to clocksource sh-tmu.0
> NET: Registered protocol family 2
> TCP established hash table entries: 4096 (order: 2, 16384 bytes)
> TCP bind hash table entries: 4096 (order: 3, 32768 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP: reno registered
> UDP hash table entries: 256 (order: 1, 8192 bytes)
> UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
> NET: Registered protocol family 1
> RPC: Registered named UNIX socket transport module.
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> CPU PMU: probing PMU on CPU 0
> hw perfevents: enabled with armv7_cortex_a9 PMU driver, 7 counters available
> futex hash table entries: 512 (order: 3, 32768 bytes)
> NFS: Registering the id_resolver key type
> Key type id_resolver registered
> Key type id_legacy registered
> nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> io scheduler noop registered (default)
> Console: switching to colour frame buffer device 100x30
> sh_mobile_lcdc_fb sh_mobile_lcdc_fb.0: registered sh_mobile_lcdc_fb.0/mainlcd as 800x480 16bpp.
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 1 at drivers/dma/dmaengine.c:863 dma_async_device_register+0x140/0x46c()
> this driver doesn't support generic slave capabilities reporting
> Modules linked in:
> CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc5-next-20150120 #623
> Hardware name: kzm9g
> Backtrace: 
> [<c0011ab8>] (dump_backtrace) from [<c0011c58>] (show_stack+0x18/0x1c)
>  r6:c0454711 r5:00000009 r4:00000000 r3:00200140
> [<c0011c40>] (show_stack) from [<c038076c>] (dump_stack+0x74/0x90)
> [<c03806f8>] (dump_stack) from [<c0024cc8>] (warn_slowpath_common+0x8c/0xb4)
>  r4:00000000 r3:c04dcd70
> [<c0024c3c>] (warn_slowpath_common) from [<c0024d94>] (warn_slowpath_fmt+0x38/0x40)
>  r8:00000014 r7:c04d4538 r6:c04d556c r5:00000000 r4:ddffcc10
> [<c0024d60>] (warn_slowpath_fmt) from [<c01da83c>] (dma_async_device_register+0x140/0x46c)
>  r3:00000000 r2:c0454756
> [<c01da6fc>] (dma_async_device_register) from [<c01dd6dc>] (sh_dmae_probe+0x550/0x620)
>  r10:00000014 r9:00000000 r8:00000014 r7:c04d4538 r6:c04d556c r5:00000000
>  r4:ddffcc10
> [<c01dd18c>] (sh_dmae_probe) from [<c020ab5c>] (platform_drv_probe+0x38/0x80)
>  r10:c04955e0 r9:c04c7d58 r8:c04d05d8 r7:c04e93f4 r6:c04e93f4 r5:c04d4538
>  r4:ffffffed
> [<c020ab24>] (platform_drv_probe) from [<c0209054>] (driver_probe_device+0xcc/0x20c)
>  r6:00000000 r5:00000000 r4:c04d4538 r3:c020ab24
> [<c0208f88>] (driver_probe_device) from [<c02091fc>] (__driver_attach+0x68/0x8c)
>  r7:00000000 r6:c04e93f4 r5:c04d456c r4:c04d4538
> [<c0209194>] (__driver_attach) from [<c0207940>] (bus_for_each_dev+0x5c/0x94)
>  r6:c0209194 r5:de44fe28 r4:c04e93f4 r3:c0209194
> [<c02078e4>] (bus_for_each_dev) from [<c0208b8c>] (driver_attach+0x20/0x28)
>  r7:00000000 r6:c04edd58 r5:de559800 r4:c04e93f4
> [<c0208b6c>] (driver_attach) from [<c0208808>] (bus_add_driver+0xb4/0x1c8)
> [<c0208754>] (bus_add_driver) from [<c02098d8>] (driver_register+0xa4/0xe8)
>  r7:c04d05d8 r6:00000000 r5:de6bf840 r4:c04e93f4
> [<c0209834>] (driver_register) from [<c020a514>] (__platform_driver_register+0x50/0x64)
>  r5:de6bf840 r4:c04e93e0
> [<c020a4c4>] (__platform_driver_register) from [<c020a550>] (__platform_driver_probe+0x28/0xac)
> [<c020a528>] (__platform_driver_probe) from [<c04a8600>] (sh_dmae_init+0x28/0x40)
>  r6:00000000 r5:de6bf840 r4:c04a85d8 r3:00000000
> [<c04a85d8>] (sh_dmae_init) from [<c00096d8>] (do_one_initcall+0x108/0x1b8)
> [<c00095d0>] (do_one_initcall) from [<c0495d78>] (kernel_init_freeable+0x10c/0x1d8)
>  r9:c04c7d58 r8:00000074 r7:c04fbe40 r6:c04bee50 r5:c04bee70 r4:00000006
> [<c0495c6c>] (kernel_init_freeable) from [<c037d790>] (kernel_init+0x10/0xec)
>  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c037d780
>  r4:00000000
> [<c037d780>] (kernel_init) from [<c000ede0>] (ret_from_fork+0x14/0x34)
>  r4:00000000 r3:de44e000
> ---[ end trace 04209299a07b5223 ]---
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 1 at drivers/dma/dmaengine.c:863 dma_async_device_register+0x140/0x46c()
> this driver doesn't support generic slave capabilities reporting
> Modules linked in:
> CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W       3.19.0-rc5-next-20150120 #623
> Hardware name: kzm9g
> Backtrace: 
> [<c0011ab8>] (dump_backtrace) from [<c0011c58>] (show_stack+0x18/0x1c)
>  r6:c0454711 r5:00000009 r4:00000000 r3:00200140
> [<c0011c40>] (show_stack) from [<c038076c>] (dump_stack+0x74/0x90)
> [<c03806f8>] (dump_stack) from [<c0024cc8>] (warn_slowpath_common+0x8c/0xb4)
>  r4:00000000 r3:c04dcd70
> [<c0024c3c>] (warn_slowpath_common) from [<c0024d94>] (warn_slowpath_fmt+0x38/0x40)
>  r8:00000006 r7:c04d46c8 r6:c04d55f8 r5:00000000 r4:de699410
> [<c0024d60>] (warn_slowpath_fmt) from [<c01da83c>] (dma_async_device_register+0x140/0x46c)
>  r3:00000000 r2:c0454756
> [<c01da6fc>] (dma_async_device_register) from [<c01dd6dc>] (sh_dmae_probe+0x550/0x620)
>  r10:00000006 r9:00000000 r8:00000006 r7:c04d46c8 r6:c04d55f8 r5:00000000
>  r4:de699410
> [<c01dd18c>] (sh_dmae_probe) from [<c020ab5c>] (platform_drv_probe+0x38/0x80)
>  r10:c04955e0 r9:c04c7d58 r8:c04d05d8 r7:c04e93f4 r6:c04e93f4 r5:c04d46c8
>  r4:ffffffed
> [<c020ab24>] (platform_drv_probe) from [<c0209054>] (driver_probe_device+0xcc/0x20c)
>  r6:00000000 r5:00000000 r4:c04d46c8 r3:c020ab24
> [<c0208f88>] (driver_probe_device) from [<c02091fc>] (__driver_attach+0x68/0x8c)
>  r7:00000000 r6:c04e93f4 r5:c04d46fc r4:c04d46c8
> [<c0209194>] (__driver_attach) from [<c0207940>] (bus_for_each_dev+0x5c/0x94)
>  r6:c0209194 r5:de44fe28 r4:c04e93f4 r3:c0209194
> [<c02078e4>] (bus_for_each_dev) from [<c0208b8c>] (driver_attach+0x20/0x28)
>  r7:00000000 r6:c04edd58 r5:de559800 r4:c04e93f4
> [<c0208b6c>] (driver_attach) from [<c0208808>] (bus_add_driver+0xb4/0x1c8)
> [<c0208754>] (bus_add_driver) from [<c02098d8>] (driver_register+0xa4/0xe8)
>  r7:c04d05d8 r6:00000000 r5:de6bf840 r4:c04e93f4
> [<c0209834>] (driver_register) from [<c020a514>] (__platform_driver_register+0x50/0x64)
>  r5:de6bf840 r4:c04e93e0
> [<c020a4c4>] (__platform_driver_register) from [<c020a550>] (__platform_driver_probe+0x28/0xac)
> [<c020a528>] (__platform_driver_probe) from [<c04a8600>] (sh_dmae_init+0x28/0x40)
>  r6:00000000 r5:de6bf840 r4:c04a85d8 r3:00000000
> [<c04a85d8>] (sh_dmae_init) from [<c00096d8>] (do_one_initcall+0x108/0x1b8)
> [<c00095d0>] (do_one_initcall) from [<c0495d78>] (kernel_init_freeable+0x10c/0x1d8)
>  r9:c04c7d58 r8:00000074 r7:c04fbe40 r6:c04bee50 r5:c04bee70 r4:00000006
> [<c0495c6c>] (kernel_init_freeable) from [<c037d790>] (kernel_init+0x10/0xec)
>  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c037d780
>  r4:00000000
> [<c037d780>] (kernel_init) from [<c000ede0>] (ret_from_fork+0x14/0x34)
>  r4:00000000 r3:de44e000
> ---[ end trace 04209299a07b5224 ]---
> SuperH (H)SCI(F) driver initialized
> sh-sci.0: ttySC0 at MMIO 0xe6c40000 (irq = 104, base_baud = 0) is a scifa
> sh-sci.1: ttySC1 at MMIO 0xe6c50000 (irq = 105, base_baud = 0) is a scifa
> sh-sci.2: ttySC2 at MMIO 0xe6c60000 (irq = 106, base_baud = 0) is a scifa
> sh-sci.3: ttySC3 at MMIO 0xe6c70000 (irq = 107, base_baud = 0) is a scifa
> sh-sci.4: ttySC4 at MMIO 0xe6c80000 (irq = 110, base_baud = 0) is a scifa
> console [ttySC4] enabled
> sh-sci.5: ttySC5 at MMIO 0xe6cb0000 (irq = 111, base_baud = 0) is a scifa
> sh-sci.6: ttySC6 at MMIO 0xe6cc0000 (irq = 188, base_baud = 0) is a scifa
> sh-sci.7: ttySC7 at MMIO 0xe6cd0000 (irq = 175, base_baud = 0) is a scifa
> sh-sci.8: ttySC8 at MMIO 0xe6c30000 (irq = 112, base_baud = 0) is a scifb
> libphy: smsc911x-mdio: probed
> smsc911x smsc911x.0 eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=smsc911x-0:01, irq=-1)
> smsc911x smsc911x.0 eth0: MAC Address: 00:01:9b:04:04:1f
> r8a66597_hcd r8a66597_hcd.0: USB Host Controller
> r8a66597_hcd r8a66597_hcd.0: new USB bus registered, assigned bus number 1
> r8a66597_hcd r8a66597_hcd.0: irq 2001, io base 0x10010000
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 2 ports detected
> usbcore: registered new interface driver usb-storage
> renesas_usbhs renesas_usbhs: gadget probed
> renesas_usbhs renesas_usbhs: probed
> input: st1232-touchscreen as /devices/platform/i2c-sh_mobile.1/i2c-1/1-0055/input/input0
> input: ADXL34x accelerometer as /devices/platform/i2c-sh_mobile.0/i2c-0/0-001d/input/input1
> rtc-rs5c372 0-0032: r2025sd found, am/pm, driver version 0.6
> rtc-rs5c372 0-0032: rtc core: registered rtc-rs5c372 as rtc0
> i2c /dev entries driver
> Driver 'mmcblk' needs updating - please use bus_type methods
> sh_mobile_sdhi sh_mobile_sdhi.0: mmc0 base at 0xee100000 clock rate 69 MHz
> sh_mobile_sdhi sh_mobile_sdhi.2: No vqmmc regulator found
> sh_mobile_sdhi sh_mobile_sdhi.2: mmc1 base at 0xee140000 clock rate 69 MHz
> sh_mmcif sh_mmcif.0: Platform OCR mask is ignored
> sh_mmcif sh_mmcif.0: Chip version 0x0003, clock rate 104MHz
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> asoc-simple-card asoc-simple-card.0: ASoC: CPU DAI fsia-dai not registered
> platform asoc-simple-card.0: Driver asoc-simple-card requests probe deferral
> TCP: cubic registered
> NET: Registered protocol family 17
> Key type dns_resolver registered
> Registering SWP/SWPB emulation handler
> asoc-simple-card asoc-simple-card.0: ak4642-hifi <-> fsia-dai mapping ok
> input: gpio-keys as /devices/platform/gpio-keys.0/input/input2
> rtc-rs5c372 0-0032: setting system clock to 2002-09-04 13:25:50 UTC (1031145950)
> smsc911x smsc911x.0 eth0: SMSC911x/921x identified at 0xdfa1a000, IRQ: 2003
> Sending DHCP requests .,
> mmc2: switch to bus width 2 failed
> mmc2: switch to bus width 1 failed
> mmc2: new high speed MMC card at address 0001
> mmcblk0: mmc2:0001 M4G1EM 3.72 GiB 
>  OK
>  mmcblk0: unknown partition table
> IP-Config: Got DHCP answer from 10.3.3.254, my address is 10.3.3.155
> IP-Config: Complete:
>      device=eth0, hwaddr=00:01:9b:04:04:1f, ipaddr=10.3.3.155, mask=255.255.255.0, gw=10.3.3.254
>      host=10.3.3.155, domain=isobedori.kobe.vergenet.net kanocho.kobe.vergenet.net vergenet., nis-domain=(none)
>      bootserver=10.3.3.135, rootserver=10.3.3.135, rootpath=/srv/nfs/kzm9g-armhf,rsize=1024,wsize=1024
>      nameserver0=10.3.3.254, nameserver1=10.4.3.254, nameserver2=8.8.8.8
> SDHI2 Vcc: disabling
> ALSA device list:
>   #0: FSI2A-AK4648
> VFS: Mounted root (nfs filesystem) on device 0:12.
> devtmpfs: mounted
> Freeing unused kernel memory: 220K (c0495000 - c04cc000)
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 520 at mm/mmap.c:2859 exit_mmap+0x1f4/0x208()
> Modules linked in:
> CPU: 1 PID: 520 Comm: modprobe Tainted: G        W       3.19.0-rc5-next-20150120 #623
> Hardware name: kzm9g
> Backtrace: 
> [<c0011ab8>] (dump_backtrace) from [<c0011c58>] (show_stack+0x18/0x1c)
>  r6:c04493f1 r5:00000009 r4:00000000 r3:00400004
> [<c0011c40>] (show_stack) from [<c038076c>] (dump_stack+0x74/0x90)
> [<c03806f8>] (dump_stack) from [<c0024cc8>] (warn_slowpath_common+0x8c/0xb4)
>  r4:00000000 r3:c04dcd70
> [<c0024c3c>] (warn_slowpath_common) from [<c0024d14>] (warn_slowpath_null+0x24/0x2c)
>  r8:c000eee4 r7:de6de23c r6:00000054 r5:de6de200 r4:00000000
> [<c0024cf0>] (warn_slowpath_null) from [<c00b5180>] (exit_mmap+0x1f4/0x208)
> [<c00b4f8c>] (exit_mmap) from [<c0022724>] (mmput+0x48/0x100)
>  r6:00000000 r5:00000000 r4:de6de200
> [<c00226dc>] (mmput) from [<c0026eac>] (do_exit+0x394/0x8b0)
>  r5:de6de200 r4:de5eb140
> [<c0026b18>] (do_exit) from [<c0027514>] (do_group_exit+0xa4/0xdc)
>  r7:000000f8
> [<c0027470>] (do_group_exit) from [<c0027564>] (__wake_up_parent+0x0/0x28)
>  r6:b6f02774 r5:b6f02774 r4:0006f42e r3:00000001
> [<c002754c>] (SyS_exit_group) from [<c000ed40>] (ret_fast_syscall+0x0/0x34)
> ---[ end trace 04209299a07b5226 ]---
> INIT: version 2.88 booting
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 522 at mm/mmap.c:2859 exit_mmap+0x1f4/0x208()
> Modules linked in:
> CPU: 0 PID: 522 Comm: init Tainted: G        W       3.19.0-rc5-next-20150120 #623
> Hardware name: kzm9g
> Backtrace: 
> [<c0011ab8>] (dump_backtrace) from [<c0011c58>] (show_stack+0x18/0x1c)
>  r6:c04493f1 r5:00000009 r4:00000000 r3:00400040
> [<c0011c40>] (show_stack) from [<c038076c>] (dump_stack+0x74/0x90)
> [<c03806f8>] (dump_stack) from [<c0024cc8>] (warn_slowpath_common+0x8c/0xb4)
>  r4:00000000 r3:c04dcd70
> [<c0024c3c>] (warn_slowpath_common) from [<c0024d14>] (warn_slowpath_null+0x24/0x2c)
>  r8:ddfd2f00 r7:de562e40 r6:00000057 r5:de6de3c0 r4:00000000
> [<c0024cf0>] (warn_slowpath_null) from [<c00b5180>] (exit_mmap+0x1f4/0x208)
> [<c00b4f8c>] (exit_mmap) from [<c0022724>] (mmput+0x48/0x100)
>  r6:de6de3c0 r5:00000000 r4:de6de3c0
> [<c00226dc>] (mmput) from [<c00cf640>] (flush_old_exec+0x4c8/0x5d8)
>  r5:de475500 r4:de6de3c0
> [<c00cf178>] (flush_old_exec) from [<c010b014>] (load_elf_binary+0x29c/0x100c)
>  r10:ddfd2e00 r9:00000080 r8:ddc41a00 r7:00000001 r6:de7cb9b4 r5:ddfd2f00
>  r4:de7cb980 r3:ddc2e000
> [<c010ad78>] (load_elf_binary) from [<c00ce770>] (search_binary_handler+0xa0/0x254)
>  r10:c051880c r9:00000001 r8:c051880c r7:c04e0090 r6:c04dfa98 r5:fffffff8
>  r4:ddfd2f00
> [<c00ce6d0>] (search_binary_handler) from [<c010a9b0>] (load_script+0x200/0x210)
>  r10:c051880c r9:00000001 r8:c051880c r7:c04e0074 r6:c04dfa98 r5:00000000
>  r4:ddfd2f00 r3:ddc2e000
> [<c010a7b0>] (load_script) from [<c00ce770>] (search_binary_handler+0xa0/0x254)
>  r5:fffffffe r4:ddfd2f00
> [<c00ce6d0>] (search_binary_handler) from [<c00cfe98>] (do_execveat_common+0x454/0x5b0)
>  r10:de54e710 r9:de562e7c r8:00000000 r7:00000000 r6:de630000 r5:0000020a
>  r4:ddfd2f00 r3:c04dbfd4
> [<c00cfa44>] (do_execveat_common) from [<c00d0028>] (do_execve+0x34/0x3c)
>  r10:00000000 r9:ddc2e000 r8:c000eee4 r7:0000000b r6:bef53908 r5:bef53a98
>  r4:00017688
> [<c00cfff4>] (do_execve) from [<c00d0278>] (SyS_execve+0x24/0x28)
> [<c00d0254>] (SyS_execve) from [<c000ed40>] (ret_fast_syscall+0x0/0x34)
>  r5:00017688 r4:bef53a98
> ---[ end trace 04209299a07b5227 ]---
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 522 at mm/mmap.c:2859 exit_mmap+0x1f4/0x208()
> Modules linked in:
> CPU: 0 PID: 522 Comm: rcS Tainted: G        W       3.19.0-rc5-next-20150120 #623
> Hardware name: kzm9g
> Backtrace: 
> [<c0011ab8>] (dump_backtrace) from [<c0011c58>] (show_stack+0x18/0x1c)
>  r6:c04493f1 r5:00000009 r4:00000000 r3:00400000
> [<c0011c40>] (show_stack) from [<c038076c>] (dump_stack+0x74/0x90)
> [<c03806f8>] (dump_stack) from [<c0024cc8>] (warn_slowpath_common+0x8c/0xb4)
>  r4:00000000 r3:c04dcd70
> [<c0024c3c>] (warn_slowpath_common) from [<c0024d14>] (warn_slowpath_null+0x24/0x2c)
>  r8:ddfd2d00 r7:de6de3c0 r6:00000051 r5:de562e40 r4:00000000
> [<c0024cf0>] (warn_slowpath_null) from [<c00b5180>] (exit_mmap+0x1f4/0x208)
> [<c00b4f8c>] (exit_mmap) from [<c0022724>] (mmput+0x48/0x100)
>  r6:de562e40 r5:00000000 r4:de562e40
> [<c00226dc>] (mmput) from [<c00cf640>] (flush_old_exec+0x4c8/0x5d8)
>  r5:de475500 r4:de562e40
> [<c00cf178>] (flush_old_exec) from [<c010b014>] (load_elf_binary+0x29c/0x100c)
>  r10:ddfd2b00 r9:00000080 r8:de7cf4c0 r7:00000001 r6:de7d4634 r5:ddfd2d00
>  r4:de7d4600 r3:ddc2e000
> [<c010ad78>] (load_elf_binary) from [<c00ce770>] (search_binary_handler+0xa0/0x254)
>  r10:c051880c r9:00000001 r8:c051880c r7:c04e0090 r6:c04dfa98 r5:fffffff8
>  r4:ddfd2d00
> [<c00ce6d0>] (search_binary_handler) from [<c010a9b0>] (load_script+0x200/0x210)
>  r10:c051880c r9:00000001 r8:c051880c r7:c04e0074 r6:c04dfa98 r5:00000000
>  r4:ddfd2d00 r3:ddc2e000
> [<c010a7b0>] (load_script) from [<c00ce770>] (search_binary_handler+0xa0/0x254)
>  r5:fffffffe r4:ddfd2d00
> [<c00ce6d0>] (search_binary_handler) from [<c00cfe98>] (do_execveat_common+0x454/0x5b0)
>  r10:de54e768 r9:de6de3fc r8:00000000 r7:00000000 r6:de638000 r5:0000020a
>  r4:ddfd2d00 r3:c04dbfd4
> [<c00cfa44>] (do_execveat_common) from [<c00d0028>] (do_execve+0x34/0x3c)
>  r10:00000000 r9:ddc2e000 r8:c000eee4 r7:0000000b r6:00021884 r5:00021874
>  r4:00021884
> [<c00cfff4>] (do_execve) from [<c00d0278>] (SyS_execve+0x24/0x28)
> [<c00d0254>] (SyS_execve) from [<c000ed40>] (ret_fast_syscall+0x0/0x34)
>  r5:00021844 r4:00021874
> ---[ end trace 04209299a07b5228 ]---
> ------------[ cut here ]------------
> ...
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
