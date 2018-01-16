Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90D7B6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 20:15:35 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id n19so8139825ota.19
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 17:15:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v43si344134otv.355.2018.01.15.17.15.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 17:15:32 -0800 (PST)
Message-Id: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 16 Jan 2018 10:15:24 +0900
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp> <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
In-Reply-To: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

Linus Torvalds wrote:
> On Sun, Jan 14, 2018 at 3:54 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > This memory corruption bug occurs even on CONFIG_SMP=n CONFIG_PREEMPT_NONE=y
> > kernel. This bug highly depends on timing and thus too difficult to bisect.
> > This bug seems to exist at least since Linux 4.8 (judging from the traces, though
> > the cause might be different). None of debugging configuration gives me a clue.
> > So far only CONFIG_HIGHMEM=y CONFIG_DEBUG_PAGEALLOC=y kernel (with RAM enough to
> > use HighMem: zone) seems to hit this bug, but it might be just by chance caused
> > by timings. Thus, there is no evidence that 64bit kernels are not affected by
> > this bug. But I can't narrow down any more. Thus, I call for developers who can
> > narrow down / identify where the memory corruption bug is.
> 
> Hmm.
> 
> I guess I'm still hung up on the "it does not look like a valid
> 'struct page *'" thing.
> 
> Can you reproduce this with CONFIG_FLATMEM=y instead of CONFIG_SPARSEMEM?
> 
> Because if you can, I think we can easily add a few more pfn and
> 'struct page' validation debug statements. With SPARSEMEM, it gets
> pretty complicated because the whole struct page setup is much more
> complex.

I can't reproduce this with CONFIG_FLATMEM=y . But I'm not sure whether
we are hitting a bug in CONFIG_SPARSEMEM=y code, for the bug is highly
timing dependent.

----------
# diff .config.old .config
372a373
> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
462d462
< CONFIG_NEED_NODE_MEMMAP_SIZE=y
468,471c468,471
< # CONFIG_FLATMEM_MANUAL is not set
< CONFIG_SPARSEMEM_MANUAL=y
< CONFIG_SPARSEMEM=y
< CONFIG_HAVE_MEMORY_PRESENT=y
---
> CONFIG_FLATMEM_MANUAL=y
> # CONFIG_SPARSEMEM_MANUAL is not set
> CONFIG_FLATMEM=y
> CONFIG_FLAT_NODE_MEM_MAP=y
478d477
< # CONFIG_MEMORY_HOTPLUG is not set
486a486,487
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> # CONFIG_MEMORY_FAILURE is not set
----------

----------
[    0.000000] Linux version 4.15.0-rc8 (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #381 Tue Jan 16 09:38:22 JST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fffc000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Red Hat KVM, BIOS 0.5.1 01/01/2011
[    0.000000] e820: last_pfn = 0x7fffc max_arch_pfn = 0x100000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC
[    0.000000] found SMP MP-table at [mem 0x000f7300-0x000f730f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F7160 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000007FFFFA9B 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000007FFFF177 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000007FFFE040 001137 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000007FFFE000 000040
[    0.000000] ACPI: SSDT 0x000000007FFFF1EB 000838 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000007FFFFA23 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] 1159MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x000000007fffbfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007fffbfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007fffbfff]
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0 already used, trying 1
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] e820: [mem 0x80000000-0xfffbffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 521966
[    0.000000] Kernel command line: ro console=ttyS0,115200n8 root=/dev/vda init=/init
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0007fffc)
[    0.000000] Initializing Movable for node 0 (00000000:00000000)
[    0.000000] Memory: 2064192K/2096744K available (3353K kernel code, 256K rwdata, 924K rodata, 376K init, 5308K bss, 32552K reserved, 0K cma-reserved, 1187832K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa4000 - 0xfffff000   ( 364 kB)
[    0.000000]   cpu_entry : 0xffc00000 - 0xffc28000   ( 160 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc147e000 - 0xc14dc000   ( 376 kB)
[    0.000000]       .data : 0xc13466c8 - 0xc14713e0   (1195 kB)
[    0.000000]       .text : 0xc1000000 - 0xc13466c8   (3353 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] ACPI: Core revision 20170831
[    0.000000] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.001000] APIC: Switch to symmetric I/O mode setup
[    0.002000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.002000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.007000] tsc: Fast TSC calibration using PIT
[    0.008000] tsc: Detected 1995.399 MHz processor
[    0.008000] Calibrating delay loop (skipped), value calculated using timer frequency.. 3990.79 BogoMIPS (lpj=1995399)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.009788] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.010000] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.017000] mce: CPU supports 10 MCE banks
[    0.017478] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017644] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.017792] CPU: Intel Common 32-bit KVM processor (family: 0xf, model: 0x6, stepping: 0x1)
[    0.018000] Spectre V2 mitigation: Vulnerable: Minimal generic ASM retpoline
[    0.024000] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.027000] APIC calibration not consistent with PM-Timer: 205ms instead of 100ms
[    0.027000] APIC delta adjusted to PM-Timer: 6250051 (12854429)
[    0.029058] devtmpfs: initialized
[    0.032000] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.032000] futex hash table entries: 256 (order: -1, 3072 bytes)
[    0.035992] cpuidle: using governor menu
[    0.037000] ACPI: bus type PCI registered
[    0.039000] PCI: PCI BIOS revision 2.10 entry at 0xfd54b, last bus=0
[    0.039000] PCI: Using configuration type 1 for base access
[    0.048000] HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
[    0.050000] ACPI: Added _OSI(Module Device)
[    0.050000] ACPI: Added _OSI(Processor Device)
[    0.050000] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.050000] ACPI: Added _OSI(Processor Aggregator Device)
[    0.071000] ACPI: Interpreter enabled
[    0.071000] ACPI: (supports S0 S5)
[    0.071000] ACPI: Using IOAPIC for interrupt routing
[    0.071409] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.073000] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.100000] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.100000] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.100314] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.100785] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.102000] PCI host bridge to bus 0000:00
[    0.102156] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.102378] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.102602] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.102784] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebfffff window]
[    0.103000] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.108493] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.108716] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.108905] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.109000] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.110000] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.110000] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.129000] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.130000] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.130000] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.131000] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.131000] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.135000] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.135000] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.135000] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.135000] vgaarb: loaded
[    0.136000] SCSI subsystem initialized
[    0.136735] PCI: Using ACPI for IRQ routing
[    0.137652] clocksource: Switched to clocksource refined-jiffies
[    0.138999] ACPI: Failed to create genetlink family for ACPI event
[    0.138999] pnp: PnP ACPI init
[    0.142999] pnp: PnP ACPI: found 5 devices
[    0.167133] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.167414] clocksource: Switched to clocksource acpi_pm
[    0.167995] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.167995] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.167995] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.170867] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.179490] Scanning for low memory corruption every 60 seconds
[    0.185037] workingset: timestamp_bits=14 max_order=19 bucket_order=5
[    0.209598] zbud: loaded
[    0.214606] SGI XFS with ACLs, security attributes, no debug enabled
[    0.226422] bounce: pool size: 64 pages
[    0.226745] io scheduler noop registered (default)
[    0.239185] atomic64_test: passed for i586+ platform with CX8 and with SSE
[    0.245995] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.246746] ACPI: Power Button [PWRF]
[    0.259029] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    0.259249] virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy driver
[    0.263351] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.286776] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    0.293723] Non-volatile memory driver v1.3
[    0.330628] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    0.335343] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.335644] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.338091] Using IPI Shortcut mode
[    0.338091] sched_clock: Marking stable (337091080, 0)->(767486575, -430395495)
[    0.341662] page_owner is disabled
[    0.373592] XFS (vda): Mounting V5 Filesystem
[    0.440300] XFS (vda): Ending clean mount
[    0.463216] VFS: Mounted root (xfs filesystem) readonly on device 254:0.
[    0.465860] devtmpfs: mounted
[    0.466592] debug: unmapping init [mem 0xc147e000-0xc14dbfff]
[    0.468584] Write protecting the kernel text: 3356k
[    0.469119] Write protecting the kernel read-only data: 936k
Starting a.out
[    1.184517] tsc: Refined TSC clocksource calibration: 1995.468 MHz
[    1.184906] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x3986e9f5ad2, max_idle_ns: 881590531620 ns
[    2.259952] clocksource: Switched to clocksource tsc
----------





I dont know why but selecting CONFIG_FLATMEM=y seems to avoid a different bug
where bootup of qemu randomly fails at

----------
[    0.000000] Linux version 4.15.0-rc8 (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #380 Tue Jan 16 09:25:52 JST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fffc000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Red Hat KVM, BIOS 0.5.1 01/01/2011
[    0.000000] e820: last_pfn = 0x7fffc max_arch_pfn = 0x100000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC
[    0.000000] found SMP MP-table at [mem 0x000f7300-0x000f730f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F7160 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000007FFFFA9B 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000007FFFF177 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000007FFFE040 001137 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000007FFFE000 000040
[    0.000000] ACPI: SSDT 0x000000007FFFF1EB 000838 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000007FFFFA23 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] 1159MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: No reference (HPET/PMTIMER) available
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x000000007fffbfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007fffbfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007fffbfff]
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0 already used, trying 1
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] e820: [mem 0x80000000-0xfffbffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 521966
[    0.000000] Kernel command line: ro console=ttyS0,115200n8 root=/dev/vda init=/init
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0007fffc)
[    0.000000] Initializing Movable for node 0 (00000000:00000000)
[    0.000000] Memory: 2064188K/2096744K available (3357K kernel code, 252K rwdata, 924K rodata, 380K init, 5308K bss, 32556K reserved, 0K cma-reserved, 1187832K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa4000 - 0xfffff000   ( 364 kB)
[    0.000000]   cpu_entry : 0xffc00000 - 0xffc28000   ( 160 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc147e000 - 0xc14dd000   ( 380 kB)
[    0.000000]       .data : 0xc13476a8 - 0xc14713e0   (1191 kB)
[    0.000000]       .text : 0xc1000000 - 0xc13476a8   (3357 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] ACPI: Core revision 20170831
[    0.000000] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.000000] APIC: Switch to symmetric I/O mode setup
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.000000] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[    0.000000] ...trying to set up timer (IRQ0) through the 8259A ...
[    0.000000] ..... (found apic 0 pin 2) ...
[    0.000000] ....... failed.
[    0.000000] ...trying to set up timer as Virtual Wire IRQ...
[    0.000000] ..... failed.
[    0.000000] ...trying to set up timer as ExtINT IRQ...
[    0.000000] ..... failed :(.
[    0.000000] Kernel panic - not syncing: IO-APIC + timer doesn't work!  Boot with apic=debug and send a report.  Then try booting with the 'noapic' option.
[    0.000000]
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.15.0-rc8 #380
[    0.000000] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x16/0x24
[    0.000000]  panic+0x87/0x1a2
[    0.000000]  ? vprintk_func+0x23/0x60
[    0.000000]  setup_IO_APIC+0x4dd/0x6f8
[    0.000000]  ? clear_IO_APIC+0x29/0x50
[    0.000000]  ? lapic_get_maxlvt+0x2e/0x40
[    0.000000]  ? end_local_APIC_setup+0x9d/0x130
[    0.000000]  apic_bsp_setup+0x70/0x75
[    0.000000]  apic_intr_mode_init+0x10c/0x10e
[    0.000000]  ? hpet_time_init+0x1e/0x20
[    0.000000]  x86_late_time_init+0xf/0x16
[    0.000000]  start_kernel+0x2ef/0x360
[    0.000000]  ? set_init_arg+0x52/0x52
[    0.000000]  i386_start_kernel+0x13d/0x140
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] Rebooting in 1 seconds..
----------

or hangs at

----------
[    0.000000] Linux version 4.15.0-rc8 (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #380 Tue Jan 16 09:25:52 JST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fffc000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Red Hat KVM, BIOS 0.5.1 01/01/2011
[    0.000000] e820: last_pfn = 0x7fffc max_arch_pfn = 0x100000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC
[    0.000000] found SMP MP-table at [mem 0x000f7300-0x000f730f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F7160 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000007FFFFA9B 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000007FFFF177 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000007FFFE040 001137 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000007FFFE000 000040
[    0.000000] ACPI: SSDT 0x000000007FFFF1EB 000838 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000007FFFFA23 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] 1159MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: No reference (HPET/PMTIMER) available
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x000000007fffbfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007fffbfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007fffbfff]
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0 already used, trying 1
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] e820: [mem 0x80000000-0xfffbffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 521966
[    0.000000] Kernel command line: ro console=ttyS0,115200n8 root=/dev/vda init=/init
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0007fffc)
[    0.000000] Initializing Movable for node 0 (00000000:00000000)
[    0.000000] Memory: 2064188K/2096744K available (3357K kernel code, 252K rwdata, 924K rodata, 380K init, 5308K bss, 32556K reserved, 0K cma-reserved, 1187832K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa4000 - 0xfffff000   ( 364 kB)
[    0.000000]   cpu_entry : 0xffc00000 - 0xffc28000   ( 160 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc147e000 - 0xc14dd000   ( 380 kB)
[    0.000000]       .data : 0xc13476a8 - 0xc14713e0   (1191 kB)
[    0.000000]       .text : 0xc1000000 - 0xc13476a8   (3357 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] ACPI: Core revision 20170831
[    0.000000] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.001000] APIC: Switch to symmetric I/O mode setup
[    0.001000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.001000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.003000] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[    0.003000] ...trying to set up timer (IRQ0) through the 8259A ...
[    0.003000] ..... (found apic 0 pin 2) ...
[    0.005000] ....... failed.
[    0.005000] ...trying to set up timer as Virtual Wire IRQ...
[   13.120000] random: crng init done
----------

which has been bothering me when testing using qemu. Note that the 13.120000 part is
incorrect. There is no delay between "...trying to set up timer as Virtual Wire IRQ..."
line and "random: crng init done" line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
