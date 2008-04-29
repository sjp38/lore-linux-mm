Date: Tue, 29 Apr 2008 10:43:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Message-ID: <20080429094327.GB4503@csn.ul.ie>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080428164235.GA29229@csn.ul.ie> <200804282044.34783.bzolnier@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200804282044.34783.bzolnier@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (28/04/08 20:44), Bartlomiej Zolnierkiewicz didst pronounce:
> 
> Hi,
> 
> On Monday 28 April 2008, Mel Gorman wrote:
> > An old T21 is failing to boot and the relevant message appears to be
> > 
> > [    1.929536] Probing IDE interface ide0...
> > [   36.939317] ide0: Wait for ready failed before probe !
> > [   37.502676] ide0: DISABLED, NO IRQ
> > [   37.506356] ide0: failed to initialize IDE interface
> > 
> > The owner of ide-mm-ide-add-struct-ide_io_ports-take-2.patch with the
> > "DISABLED, NO IRQ" message is cc'd. I've attached the config, full boot log
> > and lspci -v for the machine in question. I'll start reverting some of the
> > these patches to see if ide-mm-ide-add-struct-ide_io_ports-take-2.patch
> > is really the culprit.
> 
> Please try reverting ide-fix-hwif-s-initialization.patch first - it has
> already been dropped from IDE tree because people were reporting problems
> similar to the one encountered by you.
> 

Thanks.

I reverted this patch and ide-mm-ide-make-ide_hwifs-static.patch (for compile
breakage reasons). It's better but still fails to find the IDE device.
What is better is that it finds ide0 at;

ide0 at 0x1f0-0x1f7,0x3f6 on irq 14

but does not identify any of the disks nor does it find ide1. For
comparison, a "good" dmesg looks like

[    1.793244] Probing IDE interface ide0...
[    2.235292] hda: IBM-DJSA-220, ATA DISK drive
[    2.915457] Probing IDE interface ide1...
[    3.787516] hdc: CRN-8241U, ATAPI CD/DVD-ROM drive
[    4.475650] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.478096] ide1 at 0x170-0x177,0x376 on irq 15
[    4.484547] hda: max request size: 128KiB
[    4.522696] hda: 39070080 sectors (20003 MB) w/1874KiB Cache, CHS=41344/15/63
[    4.530706] hda: cache flushes not supported
[    4.538724]  hda: hda1 hda2 hda3 hda4
[    4.569606] hdc: ATAPI 24X CD-ROM drive, 128kB Cache
[    4.587678] Uniform CD-ROM driver Revision: 3.20
[    4.595690] Driver 'sd' needs updating - please use bus_type methods


Here is the bootlog with the two patches reverted.

root            (hd0,0)
 Filesystem type is ext2fs, partition type 0x83
kernel          /boot/vmlinuz-2.6.25-mm1 root=/dev/hda1 mminit_loglevel=4 logle
vel=9 console=tty0 console=ttyS0,9600 ro earlyprintk=serial,ttyS0,9600 kernelco
re=384MB movablecore=384MB profile=sleep,2 resume=/dev/hda2
   [Linux-bzImage, setup=0x2c00, size=0x1d9390]
savedefault
boot
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Linux version 2.6.25-mm1 (mel@arnold) (gcc version 4.2.3 (Debian 4.2.3-3)) #1 SMP Tue Apr 29 10:04:35 IST 2008
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
[    0.000000]  BIOS-e820: 000000001fff0000 - 000000001fffec00 (ACPI data)
[    0.000000]  BIOS-e820: 000000001fffec00 - 0000000020000000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] console [earlyser0] enabled
[    0.000000] CPU and/or kernel does not support PAT.
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 511MB LOWMEM available.
[    0.000000] Entering add_active_range(0, 0, 131056) 0 entries of 256 used
[    0.000000] sizeof(struct page) = 56
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   131056
[    0.000000]   HighMem    131056 ->   131056
[    0.000000] Movable zone start PFN for each node
[    0.000000]   Node 0: 98304
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   131056
[    0.000000] On node 0 totalpages: 131056
[    0.000000] Node 0 memmap at 0xc1000000 size 7340032 first pfn 0xc1000000
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4040 pages, LIFO batch:0
[    0.000000]   Normal zone: 1288 pages used for memmap
[    0.000000]   Normal zone: 92920 pages, LIFO batch:31
[    0.000000]   HighMem zone: 0 pages used for memmap
[    0.000000]   Movable zone: 447 pages used for memmap
[    0.000000]   Movable zone: 32305 pages, LIFO batch:7
[    0.000000] DMI 2.3 present.
[    0.000000] ACPI: RSDP 000F7160, 0014 (r0 PTLTD )
[    0.000000] ACPI: RSDT 1FFF4D07, 002C (r1 PTLTD    RSDT    6040000  LTP        0)
[    0.000000] ACPI: FACP 1FFFEB65, 0074 (r1 IBM    TP-T21    6040000             0)
[    0.000000] ACPI: DSDT 1FFF4D33, 9E32 (r1 IBM    TP-T21    6040000 MSFT  100000C)
[    0.000000] ACPI: FACS 1FFFF000, 0040
[    0.000000] ACPI: BOOT 1FFFEBD9, 0027 (r1 PTLTD  $SBFTBL$  6040000  LTP        1)
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] Allocating PCI resources starting at 30000000 (gap: 20000000:dff80000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] SMP: Allowing 0 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 323296 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129265
[    0.000000] Kernel command line: root=/dev/hda1 mminit_loglevel=4 loglevel=9 console=tty0 console=ttyS0,9600 ro earlyprintk=serial,ttyS0,9600 kernelcore=384MB movablecore=384MB profile=sleep,2 resume=/dev/hda2
[    0.000000] kernel sleep profiling requires CONFIG_SCHEDSTATS
[    0.000000] Local APIC disabled by BIOS -- you can enable it with "lapic"
[    0.000000] mapped APIC to ffffb000 (01757000)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 2048 (order: 11, 8192 bytes)
[    0.000000] Detected 796.562 MHz processor.
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] console [tty0] enabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Linux version 2.6.25-mm1 (mel@arnold) (gcc version 4.2.3 (Debian 4.2.3-3)) #1 SMP Tue Apr 29 10:04:35 IST 2008
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
[    0.000000]  BIOS-e820: 000000001fff0000 - 000000001fffec00 (ACPI data)
[    0.000000]  BIOS-e820: 000000001fffec00 - 0000000020000000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] console [earlyser0] enabled
[    0.000000] CPU and/or kernel does not support PAT.
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 511MB LOWMEM available.
[    0.000000] Entering add_active_range(0, 0, 131056) 0 entries of 256 used
[    0.000000] sizeof(struct page) = 56
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   131056
[    0.000000]   HighMem    131056 ->   131056
[    0.000000] Movable zone start PFN for each node
[    0.000000]   Node 0: 98304
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   131056
[    0.000000] On node 0 totalpages: 131056
[    0.000000] Node 0 memmap at 0xc1000000 size 7340032 first pfn 0xc1000000
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4040 pages, LIFO batch:0
[    0.000000]   Normal zone: 1288 pages used for memmap
[    0.000000]   Normal zone: 92920 pages, LIFO batch:31
[    0.000000]   HighMem zone: 0 pages used for memmap
[    0.000000]   Movable zone: 447 pages used for memmap
[    0.000000]   Movable zone: 32305 pages, LIFO batch:7
[    0.000000] DMI 2.3 present.
[    0.000000] ACPI: RSDP 000F7160, 0014 (r0 PTLTD )
[    0.000000] ACPI: RSDT 1FFF4D07, 002C (r1 PTLTD    RSDT    6040000  LTP        0)
[    0.000000] ACPI: FACP 1FFFEB65, 0074 (r1 IBM    TP-T21    6040000             0)
[    0.000000] ACPI: DSDT 1FFF4D33, 9E32 (r1 IBM    TP-T21    6040000 MSFT  100000C)
[    0.000000] ACPI: FACS 1FFFF000, 0040
[    0.000000] ACPI: BOOT 1FFFEBD9, 0027 (r1 PTLTD  $SBFTBL$  6040000  LTP        1)
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] Allocating PCI resources starting at 30000000 (gap: 20000000:dff80000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] SMP: Allowing 0 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 323296 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129265
[    0.000000] Kernel command line: root=/dev/hda1 mminit_loglevel=4 loglevel=9 console=tty0 console=ttyS0,9600 ro earlyprintk=serial,ttyS0,9600 kernelcore=384MB movablecore=384MB profile=sleep,2 resume=/dev/hda2
[    0.000000] kernel sleep profiling requires CONFIG_SCHEDSTATS
[    0.000000] Local APIC disabled by BIOS -- you can enable it with "lapic"
[    0.000000] mapped APIC to ffffb000 (01757000)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 2048 (order: 11, 8192 bytes)
[    0.000000] Detected 796.562 MHz processor.
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] console [tty0] enabled
[    0.004000] console handover: boot [earlyser0] -> real [ttyS0]
[    0.004000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.004000] ... MAX_LOCKDEP_SUBCLASSES:    8
[    0.004000] ... MAX_LOCK_DEPTH:          48
[    0.004000] ... MAX_LOCKDEP_KEYS:        2048
[    0.004000] ... CLASSHASH_SIZE:           1024
[    0.004000] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.004000] ... MAX_LOCKDEP_CHAINS:      16384
[    0.004000] ... CHAINHASH_SIZE:          8192
[    0.004000]  memory used by lock dependency info: 1024 kB
[    0.004000]  per task-struct memory footprint: 2688 bytes
[    0.004000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.004000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.004000] Memory: 509568k/524224k available (2376k kernel code, 14120k reserved, 1147k data, 512k init, 0k highmem)
[    0.004000] virtual kernel memory layout:
[    0.004000]     fixmap  : 0xfff81000 - 0xfffff000   ( 504 kB)
[    0.004000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.004000]     vmalloc : 0xe0800000 - 0xff7fe000   ( 495 MB)
[    0.004000]     lowmem  : 0xc0000000 - 0xdfff0000   ( 511 MB)
[    0.004000]       .init : 0xc0477000 - 0xc04f7000   ( 512 kB)
[    0.004000]       .data : 0xc0352015 - 0xc0470cc0   (1147 kB)
[    0.004000]       .text : 0xc0100000 - 0xc0352015   (2376 kB)
[    0.004000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.004000] CPA: page pool initialized 1 of 1 pages preallocated
[    0.084013] Calibrating delay using timer specific routine.. 1596.32 BogoMIPS (lpj=3192642)
[    0.092250] Mount-cache hash table entries: 512
[    0.097073] Initializing cgroup subsys ns
[    0.100020] Initializing cgroup subsys cpuacct
[    0.104081] CPU: L1 I cache: 16K, L1 D cache: 16K
[    0.112015] CPU: L2 cache: 256K
[    0.116031] Compat vDSO mapped to ffffe000.
[    0.120029] Checking 'hlt' instruction... OK.
[    0.144640] SMP alternatives: switching to UP code
[    0.162465] Freeing SMP alternatives: 9k freed
[    0.164020] ACPI: Core revision 20080321
[    0.197234] ACPI: setting ELCR to 0200 (from 0800)
[    0.204353] weird, boot CPU (#0) not listedby the BIOS.
[    0.208024] SMP motherboard not detected.
[    0.212024] Local APIC not detected. Using dummy APIC emulation.
[    0.216021] SMP disabled
[    0.220447] Brought up 1 CPUs
[    0.224026] Total of 1 processors activated (1596.32 BogoMIPS).
[    0.228067] CPU0 attaching sched-domain:
[    0.232026]  domain 0: span 1
[    0.240023]   groups: 1
[    0.249546] net_namespace: 272 bytes
[    0.253271] NET: Registered protocol family 16
[    0.261411] ACPI: bus type pci registered
[    0.265049] PCI: PCI BIOS revision 2.10 entry at 0xfd94f, last bus=7
[    0.268050] PCI: Using configuration type 1
[    0.272026] Setting up standard PCI resources
[    0.295676] ACPI: EC: Look up EC in DSDT
[    0.599927] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.725099] ACPI: Interpreter enabled
[    0.728056] ACPI: (supports S0 S1 S3 S4 S5)
[    0.751411] ACPI: Using PIC for interrupt routing
[    1.007938] ACPI: EC: GPE = 0x9, I/O: command/status = 0x66, data = 0x62
[    1.008079] ACPI: EC: driver started in interrupt mode
[    1.012479] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    1.021024] pci 0000:00:07.3: quirk: region 1000-103f claimed by PIIX4 ACPI
[    1.024079] pci 0000:00:07.3: quirk: region 1040-104f claimed by PIIX4 SMB
[    1.028085] pci 0000:00:07.3: PIIX4 devres C PIO at 15e8-15ef
[    1.032077] pci 0000:00:07.3: PIIX4 devres I PIO at 03f0-03f7
[    1.036078] pci 0000:00:07.3: PIIX4 devres J PIO at 002e-002f
[    1.040592] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    1.044351] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
[    1.071626] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
[    1.099026] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
[    1.124701] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
[    1.152698] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
[    1.181188] ACPI: Power Resource [PSER] (on)
[    1.184265] ACPI: Power Resource [PSIO] (on)
[    1.188530] Linux Plug and Play Support v0.97 (c) Adam Belay
[    1.192286] pnp: PnP ACPI init
[    1.196195] ACPI: bus type pnp registered
[    1.260101] Clocksource tsc unstable (delta = 1120015514 ns)
[    1.322294] pnp: PnP ACPI: found 15 devices
[    1.324095] ACPI: ACPI bus type pnp unregistered
[    1.332769] SCSI subsystem initialized
[    1.336847] PCI: Using ACPI for IRQ routing
[    1.341103] system 00:00: iomem range 0x0-0x9ffff could not be reserved
[    1.344099] system 00:00: iomem range 0xc0000-0xc3fff could not be reserved
[    1.348097] system 00:00: iomem range 0xc4000-0xc7fff could not be reserved
[    1.352096] system 00:00: iomem range 0xc8000-0xcbfff could not be reserved
[    1.356096] system 00:00: iomem range 0x0-0x0 could not be reserved
[    1.360097] system 00:00: iomem range 0x0-0x0 could not be reserved
[    1.364097] system 00:00: iomem range 0x0-0x0 could not be reserved
[    1.368097] system 00:00: iomem range 0x0-0x0 could not be reserved
[    1.372098] system 00:00: iomem range 0x0-0x0 could not be reserved
[    1.376098] system 00:00: iomem range 0xe0000-0xe3fff could not be reserved
[    1.380098] system 00:00: iomem range 0xe4000-0xe7fff could not be reserved
[    1.384098] system 00:00: iomem range 0xe8000-0xebfff could not be reserved
[    1.388099] system 00:00: iomem range 0xec000-0xeffff could not be reserved
[    1.392099] system 00:00: iomem range 0xf0000-0xfffff could not be reserved
[    1.396100] system 00:00: iomem range 0x100000-0x1fffffff could not be reserved
[    1.400100] system 00:00: iomem range 0xfff80000-0xffffffff could not be reserved
[    1.404144] system 00:02: ioport range 0x1000-0x103f has been reserved
[    1.408100] system 00:02: ioport range 0x1040-0x104f has been reserved
[    1.412100] system 00:02: ioport range 0xfe00-0xfe0f has been reserved
[    1.416171] system 00:09: ioport range 0x15e0-0x15ef has been reserved
[    1.454269] PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.0
[    1.456101] PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.0
[    1.460102] PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.0
[    1.464102] PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.0
[    1.468102] PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.1
[    1.472102] PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.1
[    1.476103] PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.1
[    1.480103] PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.1
[    1.484107] PCI: Bridge: 0000:00:01.0
[    1.488101]   IO window: disabled.
[    1.492113]   MEM window: 0xf0000000-0xf7ffffff
[    1.496107]   PREFETCH window: disabled.
[    1.500114] PCI: Bus 2, cardbus bridge: 0000:00:02.0
[    1.504103]   IO window: 0x00000100-0x000001ff
[    1.508109]   IO window: 0x00000100-0x000001ff
[    1.512110]   PREFETCH window: 0x04000000-0x07ffffff
[    1.516110]   MEM window: 0x04000000-0x07ffffff
[    1.520110] PCI: Bus 6, cardbus bridge: 0000:00:02.1
[    1.524104]   IO window: 0x00000100-0x000001ff
[    1.528111]   IO window: 0x00000100-0x000001ff
[    1.532111]   PREFETCH window: 0x04000000-0x07ffffff
[    1.536111]   MEM window: 0x04000000-0x07ffffff
[    1.540443] pci 0000:00:02.0: device not available because of BAR 7 [100:1ff] collisions
[    1.544270] pci 0000:00:02.1: device not available because of BAR 7 [100:1ff] collisions
[    1.548229] NET: Registered protocol family 2
[    1.552823] IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
[    1.560115] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
[    1.564618] TCP bind hash table entries: 16384 (order: 7, 589824 bytes)
[    1.573264] TCP: Hash tables configured (established 16384 bind 16384)
[    1.576197] TCP reno registered
[    1.581710] Simple Boot Flag at 0x35 set to 0x1
[    1.602470] Total HugeTLB memory allocated, 0
[    1.605016] msgmni has been set to 995 for ipc namespace c044ab00
[    1.608757] io scheduler noop registered
[    1.612113] io scheduler anticipatory registered (default)
[    1.616153] io scheduler bfq registered
[    1.620131] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.624180] pci 0000:00:03.0: Firmware left e100 interrupts enabled; disabling
[    1.628191] pci 0000:01:00.0: Boot video device
[    1.841275] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
[    1.844739] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.848909] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a NS16550A
[    1.856395] 00:0c: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.865386] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.868163] PCI: setting IRQ 11 as level-triggered
[    1.872128] ACPI: PCI Interrupt 0000:00:03.1[A] -> Link [LNKC] -> GSI 11 (level, low) -> IRQ 11
[    1.894085] loop: module loaded
[    1.896167] tun: Universal TUN/TAP device driver, 1.6
[    1.900128] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    1.904727] Uniform Multi-Platform E-IDE driver
[    1.909631] Probing IDE interface ide0...
[    2.484577] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    2.492368] Driver 'sd' needs updating - please use bus_type methods
[    2.497122] PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    2.517369] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.520182] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.525629] mice: PS/2 mouse device common for all mice
[    2.529017] Software Watchdog Timer: 0.07 initialized. soft_noboot=0 soft_margin=60 sec (nowayout= 0)
[    2.532195] oprofile: using timer interrupt.
[    2.542308] TCP cubic registered
[    2.544169] Initializing XFRM netlink socket
[    2.548228] NET: Registered protocol family 15
[    2.552191] Using IPI No-Shortcut mode
[    2.557589] registered taskstats version 1
[    2.563524] input: AT Translated Set 2 keyboard as /class/input/input0
[    2.664484] VFS: Cannot open root device "hda1" or unknown-block(0,0)
[    2.668178] Please append a correct "root=" boot option; here are the available partitions:
[    2.672181] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[    2.676180] Pid: 1, comm: swapper Not tainted 2.6.25-mm1 #1
[    2.680178]  [<c01244d7>] panic+0x47/0x110
[    2.688179]  [<c0477c3d>] mount_block_root+0x10d/0x260
[    2.696180]  [<c018a537>] ? sys_mknod+0x27/0x30
[    2.708180]  [<c0477dea>] mount_root+0x5a/0x60
[    2.716181]  [<c0477e9d>] prepare_namespace+0xad/0x160
[    2.724181]  [<c017f410>] ? sys_access+0x20/0x30
[    2.732182]  [<c0477997>] kernel_init+0x1e7/0x2a0
[    2.740186]  [<c04777b0>] ? kernel_init+0x0/0x2a0
[    2.748183]  [<c04777b0>] ? kernel_init+0x0/0x2a0
[    2.756183]  [<c0103c3f>] kernel_thread_helper+0x7/0x18
[    2.764183]  =======================
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
