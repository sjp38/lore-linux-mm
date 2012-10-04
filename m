Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 39E766B011D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 11:31:49 -0400 (EDT)
Message-ID: <506DABDD.7090105@googlemail.com>
Date: Thu, 04 Oct 2012 17:31:41 +0200
From: =?ISO-8859-1?Q?Holger_Hoffst=E4tte?=
 <holger.hoffstaette@googlemail.com>
MIME-Version: 1.0
Subject: Re: Repeatable ext4 oops with 3.6.0 (regression)
References: <pan.2012.10.02.11.19.55.793436@googlemail.com> <20121002133642.GD22777@quack.suse.cz> <pan.2012.10.02.14.31.57.530230@googlemail.com> <20121004130119.GH4641@quack.suse.cz>
In-Reply-To: <20121004130119.GH4641@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On 04.10.2012 15:01, Jan Kara wrote:
>   dmesg after boot doesn't help us. It is a dump of a kernel internal
> buffer of messages so it is cleared after reboot. I had hoped the machine

Yeah, I know and was wondering why you'd want that. Sorry,
misunderstanding. Maybe for memory layout for something..

Anyway I reproduced again and while the segfault is always the same
(in libgio, same address etc) one problem is that the oops does not show
up immediately but seems to be delayed (?) after the initial corruption
(pool[2970]: segfault ..) which is why the syslog file also shows other
random processes oopsing - often the running shell, cron, or nscd.
In the one below I caused "the real oops" by running 'du'.
Curiously, if the first corruption doesn't kill the system, I can then
subsequently run gthumb (at least for a moment).

So armed with multiple running shells I finally managed to save the dmesg
to NFS. It doesn't get any more complete than this and again shows the
ext4 stacktrace from before. So maybe it really is generic kmem corruption
and ext4 looking at symlinks/inodes is just the victim.

Holger


[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0 (root@hho) (gcc version 4.6.3 (Gentoo 4.6.3 p1.6, pie-0.5.2) ) #1 SMP Mon Oct 1 20:26:09 CEST 2012
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009efff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f000-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000d2000-0x00000000000d3fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bfecffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bfed0000-0x00000000bfedefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bfedf000-0x00000000bfefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bff00000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000f0000000-0x00000000f3ffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed003ff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed14000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed8ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] DMI present.
[    0.000000] DMI: LENOVO 20087JG/20087JG, BIOS 79ETC6WW (2.06 ) 11/20/2006
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0xbfed0 max_arch_pfn = 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-DBFFF uncachable
[    0.000000]   DC000-DFFFF write-back
[    0.000000]   E0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0BFF00000 mask FFFF00000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] found SMP MP-table at [mem 0x000f6820-0x000f682f] mapped at [c00f6820]
[    0.000000] initial memory mapped: [mem 0x00000000-0x00bfffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x377fdfff]
[    0.000000]  [mem 0x00000000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x373fffff] page 2M
[    0.000000]  [mem 0x37400000-0x377fdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0x377fdfff @ [mem 0x00bfa000-0x00bfffff]
[    0.000000] ACPI: RSDP 000f67e0 00024 (v02 LENOVO)
[    0.000000] ACPI: XSDT bfed1599 00084 (v01 LENOVO TP-79    00002060  LTP 00000000)
[    0.000000] ACPI: FACP bfed1700 000F4 (v03 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI BIOS Bug: Warning: 32/64X length mismatch in FADT/Gpe1Block: 0/32 (20120711/tbfadt-567)
[    0.000000] ACPI BIOS Bug: Warning: Optional FADT field Gpe1Block has zero address or length: 0x000000000000102C/0x0 (20120711/tbfadt-598)
[    0.000000] ACPI: DSDT bfed1b32 0D29A (v01 LENOVO TP-79    00002060 MSFT 0100000E)
[    0.000000] ACPI: FACS bfef4000 00040
[    0.000000] ACPI: SSDT bfed18b4 0027E (v01 LENOVO TP-79    00002060 MSFT 0100000E)
[    0.000000] ACPI: ECDT bfededcc 00052 (v01 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI: TCPA bfedee1e 00032 (v02 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI: APIC bfedee50 00068 (v01 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI: MCFG bfedeeb8 0003C (v01 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI: HPET bfedeef4 00038 (v01 LENOVO TP-79    00002060 LNVO 00000001)
[    0.000000] ACPI: BOOT bfedefd8 00028 (v01 LENOVO TP-79    00002060  LTP 00000001)
[    0.000000] ACPI: SSDT bfef2697 0025F (v01 LENOVO TP-79    00002060 INTL 20050513)
[    0.000000] ACPI: SSDT bfef28f6 000A6 (v01 LENOVO TP-79    00002060 INTL 20050513)
[    0.000000] ACPI: SSDT bfef299c 004F7 (v01 LENOVO TP-79    00002060 INTL 20050513)
[    0.000000] ACPI: SSDT bfef2e93 001D8 (v01 LENOVO TP-79    00002060 INTL 20050513)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 2182MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x377fdfff]
[    0.000000]   HighMem  [mem 0x377fe000-0xbfecffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xbfecffff]
[    0.000000] On node 0 totalpages: 786015
[    0.000000] free_area_init_node: node 0, pgdat c05e1700, node_mem_map f5ffd200
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3951 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 4366 pages used for memmap
[    0.000000]   HighMem zone: 554436 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0xc0000000-0xefffffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @f5fd3000 s26240 r0 d22912 u49152
[    0.000000] pcpu-alloc: s26240 r0 d22912 u49152 alloc=12*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 779873
[    0.000000] Kernel command line: root=/dev/sda1 vga=773
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:000bfed0)
[    0.000000] Memory: 3112740k/3144512k available (3751k kernel code, 31320k reserved, 1271k data, 388k init, 2235208k highmem)
[    0.000000] virtual kernel memory layout:
    fixmap  : 0xfff17000 - 0xfffff000   ( 928 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
      .init : 0xc05e8000 - 0xc0649000   ( 388 kB)
      .data : 0xc04a9c98 - 0xc05e7ac0   (1271 kB)
      .text : 0xc0100000 - 0xc04a9c98   (3751 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=2.
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=f5808000 soft=f580a000
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2161.247 MHz processor
[    0.003334] Calibrating delay loop (skipped), value calculated using timer frequency.. 4324.59 BogoMIPS (lpj=7204156)
[    0.003341] pid_max: default: 32768 minimum: 301
[    0.003364] Security Framework initialized
[    0.003379] Mount-cache hash table entries: 512
[    0.003602] Initializing cgroup subsys blkio
[    0.003629] CPU: Physical Processor ID: 0
[    0.003632] CPU: Processor Core ID: 0
[    0.003635] mce: CPU supports 6 MCE banks
[    0.003642] CPU0: Thermal monitoring enabled (TM2)
[    0.003646] process: using mwait in idle threads
[    0.003655] Last level iTLB entries: 4KB 128, 2MB 4, 4MB 4
Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32
tlb_flushall_shift is 0xffffffff
[    0.003713] ACPI: Core revision 20120711
[    0.013374] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.013827] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.048156] smpboot: CPU0: Intel(R) Core(TM)2 CPU         T7400  @ 2.16GHz stepping 06
[    0.049997] Performance Events: PEBS fmt0-, 4-deep LBR, Core2 events, Intel PMU driver.
[    0.049997] perf_event_intel: PEBS disabled due to CPU errata
[    0.049997] ... version:                2
[    0.049997] ... bit width:              40
[    0.049997] ... generic registers:      2
[    0.049997] ... value mask:             000000ffffffffff
[    0.049997] ... max period:             000000007fffffff
[    0.049997] ... fixed-purpose events:   3
[    0.049997] ... event mask:             0000000700000003
[    0.049997] CPU 1 irqstacks, hard=f5884000 soft=f5886000
[    0.049997] smpboot: Booting Node   0, Processors  #1 OK
[    0.006666] Initializing CPU#1
[    0.059978] TSC synchronization [CPU#0 -> CPU#1]:
[    0.059984] Measured 669201 cycles TSC warp between CPUs, turning off TSC clock.
[    0.059988] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.060022] Brought up 2 CPUs
[    0.060022] smpboot: Total of 2 processors activated (8648.19 BogoMIPS)
[    0.061862] devtmpfs: initialized
[    0.061862] PM: Registering ACPI NVS region [mem 0xbfedf000-0xbfefffff] (135168 bytes)
[    0.061862] NET: Registered protocol family 16
[    0.061862] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.061862] ACPI: bus type pci registered
[    0.061862] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf0000000-0xf3ffffff] (base 0xf0000000)
[    0.061862] PCI: MMCONFIG at [mem 0xf0000000-0xf3ffffff] reserved in E820
[    0.061862] PCI: Using MMCONFIG for extended config space
[    0.061862] PCI: Using configuration type 1 for base access
[    0.066703] bio: create slab <bio-0> at 0
[    0.066713] ACPI: Added _OSI(Module Device)
[    0.066713] ACPI: Added _OSI(Processor Device)
[    0.066713] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.066713] ACPI: Added _OSI(Processor Aggregator Device)
[    0.068472] ACPI: EC: EC description table is found, configuring boot EC
[    0.078183] ACPI: SSDT bfef1d36 00282 (v01  PmRef  Cpu0Ist 00000100 INTL 20050513)
[    0.078624] ACPI: Dynamic OEM Table Load:
[    0.078628] ACPI: SSDT   (null) 00282 (v01  PmRef  Cpu0Ist 00000100 INTL 20050513)
[    0.078772] ACPI: SSDT bfef203d 0065A (v01  PmRef  Cpu0Cst 00000100 INTL 20050513)
[    0.079233] ACPI: Dynamic OEM Table Load:
[    0.079238] ACPI: SSDT   (null) 0065A (v01  PmRef  Cpu0Cst 00000100 INTL 20050513)
[    0.090267] ACPI: SSDT bfef1c6e 000C8 (v01  PmRef  Cpu1Ist 00000100 INTL 20050513)
[    0.090700] ACPI: Dynamic OEM Table Load:
[    0.090704] ACPI: SSDT   (null) 000C8 (v01  PmRef  Cpu1Ist 00000100 INTL 20050513)
[    0.090801] ACPI: SSDT bfef1fb8 00085 (v01  PmRef  Cpu1Cst 00000100 INTL 20050513)
[    0.091225] ACPI: Dynamic OEM Table Load:
[    0.091229] ACPI: SSDT   (null) 00085 (v01  PmRef  Cpu1Cst 00000100 INTL 20050513)
[    0.100199] ACPI: Interpreter enabled
[    0.100207] ACPI: (supports S0 S3 S5)
[    0.100222] ACPI: Using IOAPIC for interrupt routing
[    0.103717] ACPI: Power Resource [PUBS] (on)
[    0.106864] ACPI: EC: GPE = 0x1c, I/O: command/status = 0x66, data = 0x62
[    0.110385] ACPI: ACPI Dock Station Driver: 3 docks/bays found
[    0.110393] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.110656] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.110685] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.110687] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.110690] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.110692] pci_root PNP0A08:00: host bridge window [mem 0x000d4000-0x000d7fff] (ignored)
[    0.110695] pci_root PNP0A08:00: host bridge window [mem 0x000d8000-0x000dbfff] (ignored)
[    0.110697] pci_root PNP0A08:00: host bridge window [mem 0xc0000000-0xfebfffff] (ignored)
[    0.110700] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed40fff] (ignored)
[    0.110702] PCI: root bus 00: using default resources
[    0.110705] pci_root PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.110742] PCI host bridge to bus 0000:00
[    0.110742] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
[    0.110742] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.110742] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.110742] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
[    0.110742] pci 0000:00:00.0: [8086:27a0] type 00 class 0x060000
[    0.110742] pci 0000:00:01.0: [8086:27a1] type 01 class 0x060400
[    0.110742] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.110742] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    0.110742] pci 0000:00:1b.0: reg 10: [mem 0xee400000-0xee403fff 64bit]
[    0.110742] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.110742] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    0.110742] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.110742] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    0.110742] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.110742] pci 0000:00:1c.2: [8086:27d4] type 01 class 0x060400
[    0.110757] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.110789] pci 0000:00:1c.3: [8086:27d6] type 01 class 0x060400
[    0.110898] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.110931] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    0.110987] pci 0000:00:1d.0: reg 20: [io  0x1800-0x181f]
[    0.111029] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    0.111085] pci 0000:00:1d.1: reg 20: [io  0x1820-0x183f]
[    0.111126] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    0.111182] pci 0000:00:1d.2: reg 20: [io  0x1840-0x185f]
[    0.111223] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    0.111279] pci 0000:00:1d.3: reg 20: [io  0x1860-0x187f]
[    0.111332] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    0.111356] pci 0000:00:1d.7: reg 10: [mem 0xee404000-0xee4043ff]
[    0.111463] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.111489] pci 0000:00:1e.0: [8086:2448] type 01 class 0x060401
[    0.111585] pci 0000:00:1f.0: [8086:27b9] type 00 class 0x060100
[    0.111698] pci 0000:00:1f.0: quirk: [io  0x1000-0x107f] claimed by ICH6 ACPI/GPIO/TCO
[    0.111707] pci 0000:00:1f.0: quirk: [io  0x1180-0x11bf] claimed by ICH6 GPIO
[    0.111714] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 1600 (mask 007f)
[    0.111720] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 15e0 (mask 000f)
[    0.111726] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 1680 (mask 001f)
[    0.111785] pci 0000:00:1f.1: [8086:27df] type 00 class 0x01018a
[    0.111801] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.111813] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.111825] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.111836] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.111848] pci 0000:00:1f.1: reg 20: [io  0x1880-0x188f]
[    0.111898] pci 0000:00:1f.2: [8086:27c5] type 00 class 0x010601
[    0.111922] pci 0000:00:1f.2: reg 10: [io  0x18c8-0x18cf]
[    0.111934] pci 0000:00:1f.2: reg 14: [io  0x18ac-0x18af]
[    0.111945] pci 0000:00:1f.2: reg 18: [io  0x18c0-0x18c7]
[    0.111957] pci 0000:00:1f.2: reg 1c: [io  0x18a8-0x18ab]
[    0.111969] pci 0000:00:1f.2: reg 20: [io  0x18b0-0x18bf]
[    0.111981] pci 0000:00:1f.2: reg 24: [mem 0xee404400-0xee4047ff]
[    0.112038] pci 0000:00:1f.2: PME# supported from D3hot
[    0.112060] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    0.113345] pci 0000:00:1f.3: reg 20: [io  0x18e0-0x18ff]
[    0.113424] pci_bus 0000:01: busn_res: [bus 01] is inserted under [bus 00-ff]
[    0.113457] pci 0000:01:00.0: [1002:7145] type 00 class 0x030000
[    0.113486] pci 0000:01:00.0: reg 10: [mem 0xd8000000-0xdfffffff pref]
[    0.113505] pci 0000:01:00.0: reg 14: [io  0x2000-0x20ff]
[    0.113524] pci 0000:01:00.0: reg 18: [mem 0xee100000-0xee10ffff]
[    0.113589] pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.113674] pci 0000:01:00.0: supports D1 D2
[    0.113697] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.113702] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.113705] pci 0000:00:01.0:   bridge window [mem 0xee100000-0xee1fffff]
[    0.113710] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.113768] pci_bus 0000:02: busn_res: [bus 02] is inserted under [bus 00-ff]
[    0.113806] pci 0000:02:00.0: [8086:109a] type 00 class 0x020000
[    0.113836] pci 0000:02:00.0: reg 10: [mem 0xee000000-0xee01ffff]
[    0.113877] pci 0000:02:00.0: reg 18: [io  0x3000-0x301f]
[    0.114061] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.114097] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.114104] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    0.114109] pci 0000:00:1c.0:   bridge window [mem 0xee000000-0xee0fffff]
[    0.114173] pci_bus 0000:03: busn_res: [bus 03] is inserted under [bus 00-ff]
[    0.114281] pci 0000:03:00.0: [8086:4227] type 00 class 0x028000
[    0.114337] pci 0000:03:00.0: reg 10: [mem 0xedf00000-0xedf00fff]
[    0.114755] pci 0000:03:00.0: PME# supported from D0 D3hot
[    0.114820] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.114827] pci 0000:00:1c.1:   bridge window [io  0x4000-0x5fff]
[    0.114832] pci 0000:00:1c.1:   bridge window [mem 0xec000000-0xedffffff]
[    0.114839] pci 0000:00:1c.1:   bridge window [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.114899] pci_bus 0000:04: busn_res: [bus 04-0b] is inserted under [bus 00-ff]
[    0.114902] pci 0000:00:1c.2: PCI bridge to [bus 04-0b]
[    0.114909] pci 0000:00:1c.2:   bridge window [io  0x6000-0x7fff]
[    0.114914] pci 0000:00:1c.2:   bridge window [mem 0xe8000000-0xe9ffffff]
[    0.114922] pci 0000:00:1c.2:   bridge window [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.114981] pci_bus 0000:0c: busn_res: [bus 0c-13] is inserted under [bus 00-ff]
[    0.114984] pci 0000:00:1c.3: PCI bridge to [bus 0c-13]
[    0.114991] pci 0000:00:1c.3:   bridge window [io  0x8000-0x9fff]
[    0.114996] pci 0000:00:1c.3:   bridge window [mem 0xea000000-0xebffffff]
[    0.115003] pci 0000:00:1c.3:   bridge window [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.115037] pci_bus 0000:15: busn_res: [bus 15-18] is inserted under [bus 00-ff]
[    0.115054] pci 0000:15:00.0: [104c:ac56] type 02 class 0x060700
[    0.115082] pci 0000:15:00.0: reg 10: [mem 0xe4300000-0xe4300fff]
[    0.115128] pci 0000:15:00.0: supports D1 D2
[    0.115130] pci 0000:15:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.115207] pci 0000:00:1e.0: PCI bridge to [bus 15-18] (subtractive decode)
[    0.115214] pci 0000:00:1e.0:   bridge window [io  0xa000-0xdfff]
[    0.115219] pci 0000:00:1e.0:   bridge window [mem 0xe4300000-0xe7ffffff]
[    0.115226] pci 0000:00:1e.0:   bridge window [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.115229] pci 0000:00:1e.0:   bridge window [io  0x0000-0xffff] (subtractive decode)
[    0.115231] pci 0000:00:1e.0:   bridge window [mem 0x00000000-0xffffffff] (subtractive decode)
[    0.115282] pci_bus 0000:16: busn_res: can not insert [bus 16-ff] under [bus 15-18] (conflicts with (null) [bus 15-18])
[    0.115287] pci_bus 0000:16: busn_res: [bus 16-ff] end is updated to 17
[    0.115289] pci_bus 0000:16: busn_res: [bus 16-17] is inserted under [bus 15-18]
[    0.115328] pci_bus 0000:00: on NUMA node 0
[    0.115331] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.115421] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
[    0.115451] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP0._PRT]
[    0.115484] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
[    0.115516] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
[    0.115551] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP3._PRT]
[    0.115587] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
[    0.115898]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x19)
[    0.120073] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120153] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120229] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120305] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120381] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120456] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120531] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120606] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 *11)
[    0.120647] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.120647] vgaarb: loaded
[    0.120647] vgaarb: bridge control possible 0000:01:00.0
[    0.120647] SCSI subsystem initialized
[    0.120647] ACPI: bus type scsi registered
[    0.120647] libata version 3.00 loaded.
[    0.120647] PCI: Using ACPI for IRQ routing
[    0.124231] PCI: pci_cache_line_size set to 64 bytes
[    0.124379] e820: reserve RAM buffer [mem 0x0009f000-0x0009ffff]
[    0.124382] e820: reserve RAM buffer [mem 0xbfed0000-0xbfffffff]
[    0.124397] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.130019] Switching to clocksource hpet
[    0.130071] pnp: PnP ACPI init
[    0.130083] ACPI: bus type pnp registered
[    0.130498] pnp 00:00: [mem 0x00000000-0x0009ffff]
[    0.130501] pnp 00:00: [mem 0x000c0000-0x000c3fff]
[    0.130503] pnp 00:00: [mem 0x000c4000-0x000c7fff]
[    0.130505] pnp 00:00: [mem 0x000c8000-0x000cbfff]
[    0.130507] pnp 00:00: [mem 0x000cc000-0x000cffff]
[    0.130508] pnp 00:00: [mem 0x000d0000-0x000d3fff]
[    0.130510] pnp 00:00: [mem 0x000d4000-0x000d3fff disabled]
[    0.130512] pnp 00:00: [mem 0x000d8000-0x000d7fff disabled]
[    0.130515] pnp 00:00: [mem 0x000dc000-0x000dffff]
[    0.130517] pnp 00:00: [mem 0x000e0000-0x000e3fff]
[    0.130519] pnp 00:00: [mem 0x000e4000-0x000e7fff]
[    0.130520] pnp 00:00: [mem 0x000e8000-0x000ebfff]
[    0.130522] pnp 00:00: [mem 0x000ec000-0x000effff]
[    0.130524] pnp 00:00: [mem 0x000f0000-0x000fffff]
[    0.130526] pnp 00:00: [mem 0x00100000-0xbfffffff]
[    0.130529] pnp 00:00: [mem 0xfec00000-0xfed3ffff]
[    0.130531] pnp 00:00: [mem 0xfed41000-0xffffffff]
[    0.130623] system 00:00: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.130629] system 00:00: [mem 0x000c0000-0x000c3fff] could not be reserved
[    0.130634] system 00:00: [mem 0x000c4000-0x000c7fff] could not be reserved
[    0.130638] system 00:00: [mem 0x000c8000-0x000cbfff] could not be reserved
[    0.130643] system 00:00: [mem 0x000cc000-0x000cffff] could not be reserved
[    0.130648] system 00:00: [mem 0x000d0000-0x000d3fff] could not be reserved
[    0.130652] system 00:00: [mem 0x000dc000-0x000dffff] could not be reserved
[    0.130657] system 00:00: [mem 0x000e0000-0x000e3fff] could not be reserved
[    0.130662] system 00:00: [mem 0x000e4000-0x000e7fff] could not be reserved
[    0.130666] system 00:00: [mem 0x000e8000-0x000ebfff] could not be reserved
[    0.130671] system 00:00: [mem 0x000ec000-0x000effff] could not be reserved
[    0.130675] system 00:00: [mem 0x000f0000-0x000fffff] could not be reserved
[    0.130680] system 00:00: [mem 0x00100000-0xbfffffff] could not be reserved
[    0.130685] system 00:00: [mem 0xfec00000-0xfed3ffff] could not be reserved
[    0.130690] system 00:00: [mem 0xfed41000-0xffffffff] could not be reserved
[    0.130695] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.130717] pnp 00:01: [bus 00-ff]
[    0.130720] pnp 00:01: [io  0x0cf8-0x0cff]
[    0.130722] pnp 00:01: [io  0x0000-0x0cf7 window]
[    0.130724] pnp 00:01: [io  0x0d00-0xffff window]
[    0.130726] pnp 00:01: [mem 0x000a0000-0x000bffff window]
[    0.130728] pnp 00:01: [mem 0x000c0000-0x000c3fff window]
[    0.130730] pnp 00:01: [mem 0x000c4000-0x000c7fff window]
[    0.130732] pnp 00:01: [mem 0x000c8000-0x000cbfff window]
[    0.130734] pnp 00:01: [mem 0x000cc000-0x000cffff window]
[    0.130736] pnp 00:01: [mem 0x000d0000-0x000d3fff window]
[    0.130738] pnp 00:01: [mem 0x000d4000-0x000d7fff window]
[    0.130740] pnp 00:01: [mem 0x000d8000-0x000dbfff window]
[    0.130742] pnp 00:01: [mem 0x000dc000-0x000dffff window]
[    0.130744] pnp 00:01: [mem 0x000e0000-0x000e3fff window]
[    0.130746] pnp 00:01: [mem 0x000e4000-0x000e7fff window]
[    0.130751] pnp 00:01: [mem 0x000e8000-0x000ebfff window]
[    0.130753] pnp 00:01: [mem 0x000ec000-0x000effff window]
[    0.130755] pnp 00:01: [mem 0xc0000000-0xfebfffff window]
[    0.130757] pnp 00:01: [mem 0xfed40000-0xfed40fff window]
[    0.130834] pnp 00:01: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.130852] pnp 00:02: [io  0x0010-0x001f]
[    0.130854] pnp 00:02: [io  0x0090-0x009f]
[    0.130856] pnp 00:02: [io  0x0024-0x0025]
[    0.130858] pnp 00:02: [io  0x0028-0x0029]
[    0.130860] pnp 00:02: [io  0x002c-0x002d]
[    0.130862] pnp 00:02: [io  0x0030-0x0031]
[    0.130864] pnp 00:02: [io  0x0034-0x0035]
[    0.130866] pnp 00:02: [io  0x0038-0x0039]
[    0.130868] pnp 00:02: [io  0x003c-0x003d]
[    0.130869] pnp 00:02: [io  0x00a4-0x00a5]
[    0.130871] pnp 00:02: [io  0x00a8-0x00a9]
[    0.130873] pnp 00:02: [io  0x00ac-0x00ad]
[    0.130875] pnp 00:02: [io  0x00b0-0x00b5]
[    0.130877] pnp 00:02: [io  0x00b8-0x00b9]
[    0.130879] pnp 00:02: [io  0x00bc-0x00bd]
[    0.130881] pnp 00:02: [io  0x0050-0x0053]
[    0.130883] pnp 00:02: [io  0x0072-0x0077]
[    0.130885] pnp 00:02: [io  0x164e-0x164f]
[    0.130887] pnp 00:02: [io  0x002e-0x002f]
[    0.130888] pnp 00:02: [io  0x1000-0x107f]
[    0.130890] pnp 00:02: [io  0x1180-0x11bf]
[    0.130892] pnp 00:02: [io  0x0800-0x080f]
[    0.130894] pnp 00:02: [io  0x15e0-0x15ef]
[    0.130896] pnp 00:02: [io  0x1600-0x165f]
[    0.130898] pnp 00:02: [mem 0xf0000000-0xf3ffffff]
[    0.130900] pnp 00:02: [mem 0xfed1c000-0xfed1ffff]
[    0.130902] pnp 00:02: [mem 0xfed14000-0xfed17fff]
[    0.130904] pnp 00:02: [mem 0xfed18000-0xfed18fff]
[    0.130906] pnp 00:02: [mem 0xfed19000-0xfed19fff]
[    0.131018] system 00:02: [io  0x164e-0x164f] has been reserved
[    0.131024] system 00:02: [io  0x1000-0x107f] has been reserved
[    0.131028] system 00:02: [io  0x1180-0x11bf] has been reserved
[    0.131032] system 00:02: [io  0x0800-0x080f] has been reserved
[    0.131037] system 00:02: [io  0x15e0-0x15ef] has been reserved
[    0.131041] system 00:02: [io  0x1600-0x165f] could not be reserved
[    0.131046] system 00:02: [mem 0xf0000000-0xf3ffffff] has been reserved
[    0.131050] system 00:02: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.131055] system 00:02: [mem 0xfed14000-0xfed17fff] has been reserved
[    0.131059] system 00:02: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.131064] system 00:02: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.131069] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.131105] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    0.131172] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.131183] pnp 00:04: [io  0x0000-0x000f]
[    0.131185] pnp 00:04: [io  0x0080-0x008f]
[    0.131187] pnp 00:04: [io  0x00c0-0x00df]
[    0.131189] pnp 00:04: [dma 4]
[    0.131249] pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.131259] pnp 00:05: [io  0x0061]
[    0.131318] pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.131328] pnp 00:06: [io  0x00f0]
[    0.131337] pnp 00:06: [irq 13]
[    0.131401] pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.131411] pnp 00:07: [io  0x0070-0x0071]
[    0.131416] pnp 00:07: [irq 8]
[    0.131477] pnp 00:07: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.131487] pnp 00:08: [io  0x0060]
[    0.131489] pnp 00:08: [io  0x0064]
[    0.131494] pnp 00:08: [irq 1]
[    0.131555] pnp 00:08: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.131568] pnp 00:09: [irq 12]
[    0.131631] pnp 00:09: Plug and Play ACPI device, IDs IBM3780 PNP0f13 (active)
[    0.131986] pnp 00:0a: Plug and Play ACPI device, IDs IBM0071 PNP0511 (disabled)
[    0.132014] pnp 00:0b: [mem 0xfed40000-0xfed40fff]
[    0.132080] pnp 00:0b: Plug and Play ACPI device, IDs ATM1200 PNP0c31 (active)
[    0.132570] pnp: PnP ACPI: found 12 devices
[    0.132574] ACPI: ACPI bus type pnp unregistered
[    0.172448] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 02] add_size 200000
[    0.172497] pci 0000:00:1c.0: res[9]=[mem 0x00100000-0x000fffff 64bit pref] get_res_add_size add_size 200000
[    0.172501] pci 0000:00:1c.0: BAR 9: assigned [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.172508] pci 0000:01:00.0: BAR 6: assigned [mem 0xee120000-0xee13ffff pref]
[    0.172513] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.172518] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.172523] pci 0000:00:01.0:   bridge window [mem 0xee100000-0xee1fffff]
[    0.172529] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.172536] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.172541] pci 0000:00:1c.0:   bridge window [io  0x3000-0x3fff]
[    0.172549] pci 0000:00:1c.0:   bridge window [mem 0xee000000-0xee0fffff]
[    0.172556] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.172566] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.172571] pci 0000:00:1c.1:   bridge window [io  0x4000-0x5fff]
[    0.172579] pci 0000:00:1c.1:   bridge window [mem 0xec000000-0xedffffff]
[    0.172586] pci 0000:00:1c.1:   bridge window [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.172595] pci 0000:00:1c.2: PCI bridge to [bus 04-0b]
[    0.172601] pci 0000:00:1c.2:   bridge window [io  0x6000-0x7fff]
[    0.172609] pci 0000:00:1c.2:   bridge window [mem 0xe8000000-0xe9ffffff]
[    0.172615] pci 0000:00:1c.2:   bridge window [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.172625] pci 0000:00:1c.3: PCI bridge to [bus 0c-13]
[    0.172630] pci 0000:00:1c.3:   bridge window [io  0x8000-0x9fff]
[    0.172638] pci 0000:00:1c.3:   bridge window [mem 0xea000000-0xebffffff]
[    0.172645] pci 0000:00:1c.3:   bridge window [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.172657] pci 0000:15:00.0: res[9]=[mem 0x04000000-0x03ffffff pref] get_res_add_size add_size 4000000
[    0.172660] pci 0000:15:00.0: res[10]=[mem 0x04000000-0x03ffffff] get_res_add_size add_size 4000000
[    0.172662] pci 0000:15:00.0: res[7]=[io  0x0100-0x00ff] get_res_add_size add_size 100
[    0.172664] pci 0000:15:00.0: res[8]=[io  0x0100-0x00ff] get_res_add_size add_size 100
[    0.172667] pci 0000:15:00.0: BAR 9: assigned [mem 0xe0000000-0xe3ffffff pref]
[    0.172672] pci 0000:15:00.0: BAR 10: assigned [mem 0xc4000000-0xc7ffffff]
[    0.172677] pci 0000:15:00.0: BAR 7: assigned [io  0xa000-0xa0ff]
[    0.172681] pci 0000:15:00.0: BAR 8: assigned [io  0xa400-0xa4ff]
[    0.172685] pci 0000:15:00.0: CardBus bridge to [bus 16-17]
[    0.172689] pci 0000:15:00.0:   bridge window [io  0xa000-0xa0ff]
[    0.172697] pci 0000:15:00.0:   bridge window [io  0xa400-0xa4ff]
[    0.172704] pci 0000:15:00.0:   bridge window [mem 0xe0000000-0xe3ffffff pref]
[    0.172712] pci 0000:15:00.0:   bridge window [mem 0xc4000000-0xc7ffffff]
[    0.172720] pci 0000:00:1e.0: PCI bridge to [bus 15-18]
[    0.172725] pci 0000:00:1e.0:   bridge window [io  0xa000-0xdfff]
[    0.172733] pci 0000:00:1e.0:   bridge window [mem 0xe4300000-0xe7ffffff]
[    0.172740] pci 0000:00:1e.0:   bridge window [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.172792] pci 0000:00:1e.0: enabling device (0005 -> 0007)
[    0.172801] pci 0000:00:1e.0: setting latency timer to 64
[    0.172813] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.172816] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff]
[    0.172818] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    0.172820] pci_bus 0000:01: resource 1 [mem 0xee100000-0xee1fffff]
[    0.172822] pci_bus 0000:01: resource 2 [mem 0xd8000000-0xdfffffff 64bit pref]
[    0.172825] pci_bus 0000:02: resource 0 [io  0x3000-0x3fff]
[    0.172827] pci_bus 0000:02: resource 1 [mem 0xee000000-0xee0fffff]
[    0.172829] pci_bus 0000:02: resource 2 [mem 0xc0000000-0xc01fffff 64bit pref]
[    0.172831] pci_bus 0000:03: resource 0 [io  0x4000-0x5fff]
[    0.172833] pci_bus 0000:03: resource 1 [mem 0xec000000-0xedffffff]
[    0.172835] pci_bus 0000:03: resource 2 [mem 0xe4000000-0xe40fffff 64bit pref]
[    0.172837] pci_bus 0000:04: resource 0 [io  0x6000-0x7fff]
[    0.172839] pci_bus 0000:04: resource 1 [mem 0xe8000000-0xe9ffffff]
[    0.172842] pci_bus 0000:04: resource 2 [mem 0xe4100000-0xe41fffff 64bit pref]
[    0.172844] pci_bus 0000:0c: resource 0 [io  0x8000-0x9fff]
[    0.172846] pci_bus 0000:0c: resource 1 [mem 0xea000000-0xebffffff]
[    0.172848] pci_bus 0000:0c: resource 2 [mem 0xe4200000-0xe42fffff 64bit pref]
[    0.172850] pci_bus 0000:15: resource 0 [io  0xa000-0xdfff]
[    0.172852] pci_bus 0000:15: resource 1 [mem 0xe4300000-0xe7ffffff]
[    0.172855] pci_bus 0000:15: resource 2 [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.172857] pci_bus 0000:15: resource 4 [io  0x0000-0xffff]
[    0.172859] pci_bus 0000:15: resource 5 [mem 0x00000000-0xffffffff]
[    0.172861] pci_bus 0000:16: resource 0 [io  0xa000-0xa0ff]
[    0.172863] pci_bus 0000:16: resource 1 [io  0xa400-0xa4ff]
[    0.172865] pci_bus 0000:16: resource 2 [mem 0xe0000000-0xe3ffffff pref]
[    0.172867] pci_bus 0000:16: resource 3 [mem 0xc4000000-0xc7ffffff]
[    0.172898] NET: Registered protocol family 2
[    0.173039] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.173463] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.173669] TCP: Hash tables configured (established 131072 bind 65536)
[    0.173694] TCP: reno registered
[    0.173700] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.173710] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.173760] NET: Registered protocol family 1
[    0.173794] pci 0000:00:1d.0: power state changed by ACPI to D0
[    0.173853] pci 0000:00:1d.2: power state changed by ACPI to D0
[    0.173954] pci 0000:01:00.0: Boot video device
[    0.174017] PCI: CLS mismatch (64 != 32), using 64 bytes
[    0.174086] Simple Boot Flag at 0x35 set to 0x1
[    0.188281] bounce pool size: 64 pages
[    0.188287] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    0.193419] ROMFS MTD (C) 2007 Red Hat, Inc.
[    0.193621] msgmni has been set to 1713
[    0.194108] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[    0.194114] io scheduler noop registered
[    0.194116] io scheduler deadline registered (default)
[    0.194125] io scheduler cfq registered
[    0.194259] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    0.194399] pcieport 0000:00:1c.0: irq 41 for MSI/MSI-X
[    0.194565] pcieport 0000:00:1c.1: irq 42 for MSI/MSI-X
[    0.194729] pcieport 0000:00:1c.2: irq 43 for MSI/MSI-X
[    0.194892] pcieport 0000:00:1c.3: irq 44 for MSI/MSI-X
[    0.195328] vesafb: mode is 1024x768x8, linelength=1024, pages=18
[    0.195332] vesafb: protected mode interface info at c000:b142
[    0.195336] vesafb: pmi: set display start = c00cb1ca, set palette = c00cb286
[    0.195339] vesafb: scrolling: redraw
[    0.195342] vesafb: Pseudocolor: size=8:8:8:8, shift=0:0:0:0
[    0.195442] vesafb: framebuffer at 0xd8000000, mapped to 0xf8080000, using 1536k, total 16384k
[    0.208590] Console: switching to colour frame buffer device 128x48
[    0.221685] fb0: VESA VGA frame buffer device
[    0.221806] intel_idle: does not run on family 6 model 15
[    0.221958] ACPI: Deprecated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    0.222326] ACPI: AC Adapter [AC] (on-line)
[    0.222579] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
[    0.222876] ACPI: Lid Switch [LID]
[    0.223010] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input1
[    0.223175] ACPI: Sleep Button [SLPB]
[    0.223319] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    0.223489] ACPI: Power Button [PWRF]
[    0.223699] ACPI: Requesting acpi_cpufreq
[    0.226603] Monitor-Mwait will be used to enter C-1 state
[    0.226607] Monitor-Mwait will be used to enter C-2 state
[    0.226611] Monitor-Mwait will be used to enter C-3 state
[    0.226622] ACPI: acpi_idle registered with cpuidle
[    0.232882] thermal LNXTHERM:00: registered as thermal_zone0
[    0.232989] ACPI: Thermal Zone [THM0] (56 C)
[    0.234059] thermal LNXTHERM:01: registered as thermal_zone1
[    0.234165] ACPI: Thermal Zone [THM1] (56 C)
[    0.247269] ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    0.247498] ACPI: Battery Slot [BAT0] (battery present)
[    0.272089] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.272999] Real Time Clock Driver v1.12b
[    0.273132] Non-volatile memory driver v1.3
[    0.273251] intel_rng: FWH not detected
[    0.275831] brd: module loaded
[    0.277273] loop: module loaded
[    0.277764] SCSI Media Changer driver v0.25 
[    0.283035] ahci 0000:00:1f.2: version 3.0
[    0.283094] ahci 0000:00:1f.2: irq 45 for MSI/MSI-X
[    0.283165] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 1.5 Gbps 0x1 impl SATA mode
[    0.288452] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part 
[    0.293720] ahci 0000:00:1f.2: setting latency timer to 64
[    0.294894] scsi0 : ahci
[    0.300226] scsi1 : ahci
[    0.305432] scsi2 : ahci
[    0.310536] scsi3 : ahci
[    0.315512] ata1: SATA max UDMA/133 abar m1024@0xee404400 port 0xee404500 irq 45
[    0.320626] ata2: DUMMY
[    0.325635] ata3: DUMMY
[    0.330607] ata4: DUMMY
[    0.335644] ata_piix 0000:00:1f.1: version 2.13
[    0.335684] ata_piix 0000:00:1f.1: setting latency timer to 64
[    0.336241] scsi4 : ata_piix
[    0.341362] scsi5 : ata_piix
[    0.346225] ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1880 irq 14
[    0.351035] ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1888 irq 15
[    0.355865] ata6: port disabled--ignoring
[    0.356143] yenta_cardbus 0000:15:00.0: CardBus bridge found [17aa:2012]
[    0.360939] yenta_cardbus 0000:15:00.0: Using INTVAL to route CSC interrupts to PCI
[    0.365740] yenta_cardbus 0000:15:00.0: Routing CardBus interrupts to PCI
[    0.370507] yenta_cardbus 0000:15:00.0: TI: mfunc 0x01d01002, devctl 0x64
[    0.513798] ata5.00: ATAPI: HL-DT-STCD-RW/DVD DRIVE GCC-4247N, 1.01, max UDMA/33
[    0.530333] ata5.00: configured for UDMA/33
[    0.656697] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    0.661800] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    0.661803] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    0.666607] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    0.671541] ata1.00: ATA-7: INTEL SSDSA2M160G2GC, 2CV102M3, max UDMA/133
[    0.676262] ata1.00: 312581808 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    0.681345] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    0.681348] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    0.686036] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    0.690839] ata1.00: configured for UDMA/133
[    0.695431] scsi 0:0:0:0: Direct-Access     ATA      INTEL SSDSA2M160 2CV1 PQ: 0 ANSI: 5
[    0.700210] sd 0:0:0:0: [sda] 312581808 512-byte logical blocks: (160 GB/149 GiB)
[    0.700301] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    0.709226] sd 0:0:0:0: [sda] Write Protect is off
[    0.713558] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.713576] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.718024] scsi 4:0:0:0: CD-ROM            HL-DT-ST RW/DVD GCC-4247N 1.01 PQ: 0 ANSI: 5
[    0.722800] scsi 4:0:0:0: Attached scsi generic sg1 type 5
[    0.722894]  sda: sda1
[    0.723110] sd 0:0:0:0: [sda] Attached SCSI disk
[    0.736120] ACPI: Invalid Power Resource to register!
[    0.860836] yenta_cardbus 0000:15:00.0: ISA IRQ mask 0x0cf8, PCI irq 16
[    0.865234] yenta_cardbus 0000:15:00.0: Socket status: 30000007
[    0.869510] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [io  0xa000-0xdfff]
[    0.873758] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa000-0xdfff:
[    0.736120] ACPI: Invalid Power Resource to register!
[    0.879615]  excluding
[    0.879661]  0xa000-0xa0ff 0xa400-0xa4ff
[    0.908708] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe4300000-0xe7ffffff]
[    0.913124] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe4300000-0xe7ffffff:
[    0.917612]  excluding 0xe4300000-0xe46cffff
[    0.922117] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe0000000-0xe3ffffff 64bit pref]
[    0.926871] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe0000000-0xe3ffffff:
[    0.931709]  excluding 0xe0000000-0xe3ffffff
[    0.936932] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    0.948519] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.953372] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.958448] mousedev: PS/2 mouse device common for all mice
[    0.963772] cpuidle: using governor ladder
[    0.968874] cpuidle: using governor menu
[    0.974082] TCP: cubic registered
[    0.978924] TCP: highspeed registered
[    0.984122] NET: Registered protocol family 10
[    0.989272] sit: IPv6 over IPv4 tunneling driver
[    0.994570] NET: Registered protocol family 17
[    0.999650] Key type dns_resolver registered
[    1.005007] Using IPI No-Shortcut mode
[    1.010203] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input3
[    1.015740] registered taskstats version 1
[    1.442587] psmouse serio1: trackpoint: IBM TrackPoint firmware: 0x0e, buttons: 3/3
[    1.466859] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input4
[    1.475673] EXT3-fs (sda1): error: couldn't mount because of unsupported optional features (240)
[    1.500232] EXT2-fs (sda1): error: couldn't mount because of unsupported optional features (244)
[    1.525524] EXT4-fs (sda1): INFO: recovery required on readonly filesystem
[    1.530794] EXT4-fs (sda1): write access will be enabled during recovery
[    1.537713] EXT4-fs (sda1): barriers disabled
[    1.579518] EXT4-fs (sda1): orphan cleanup on readonly fs
[    1.584686] EXT4-fs (sda1): ext4_orphan_cleanup: deleting unreferenced inode 3670036
[    1.584749] EXT4-fs (sda1): ext4_orphan_cleanup: deleting unreferenced inode 3670035
[    1.584774] EXT4-fs (sda1): ext4_orphan_cleanup: deleting unreferenced inode 3670026
[    1.584798] EXT4-fs (sda1): 3 orphan inodes deleted
[    1.589885] EXT4-fs (sda1): recovery complete
[    1.595839] EXT4-fs (sda1): mounted filesystem with writeback data mode. Opts: (null)
[    1.600968] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[    1.606120] Freeing unused kernel memory: 388k freed
[    1.611384] Write protecting the kernel text: 3752k
[    1.616410] Write protecting the kernel read-only data: 1044k
[    2.054492] systemd-udevd[1350]: starting version 193
[    2.107725] acpi device:06: registered as cooling_device2
[    2.107773] ACPI: Video Device [VID1] (multi-head: yes  rom: no  post: no)
[    2.107824] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/device:05/LNXVIDEO:01/input/input5
[    2.119218] thinkpad_acpi: ThinkPad ACPI Extras v0.24
[    2.119220] thinkpad_acpi: http://ibm-acpi.sf.net/
[    2.119221] thinkpad_acpi: ThinkPad BIOS 79ETC6WW (2.06 ), EC 79HT50WW-1.07
[    2.119223] thinkpad_acpi: Lenovo ThinkPad T60, model 20087JG
[    2.119224] thinkpad_acpi: WARNING: Outdated ThinkPad BIOS/EC firmware
[    2.119225] thinkpad_acpi: WARNING: This firmware may be missing critical bug fixes and/or important features
[    2.124227] thinkpad_acpi: detected a 8-level brightness capable ThinkPad
[    2.124529] thinkpad_acpi: radio switch found; radios are disabled
[    2.124544] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[    2.124545] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[    2.126466] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is blocked
[    2.127262] Registered led device: tpacpi::thinklight
[    2.127290] Registered led device: tpacpi::power
[    2.127310] Registered led device: tpacpi::standby
[    2.127329] Registered led device: tpacpi::thinkvantage
[    2.127935] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[    2.127936] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[    2.127956] e1000e 0000:02:00.0: Disabling ASPM L0s L1
[    2.128110] e1000e 0000:02:00.0: Interrupt Throttling Rate (ints/sec) set to dynamic mode
[    2.128194] e1000e 0000:02:00.0: irq 46 for MSI/MSI-X
[    2.129910] hda_intel: probe_mask set to 0x1 for device 17aa:2010
[    2.129962] snd_hda_intel 0000:00:1b.0: irq 47 for MSI/MSI-X
[    2.131102] thinkpad_acpi: Standard ACPI backlight interface available, not loading native one
[    2.131190] thinkpad_acpi: Console audio control enabled, mode: monitor (read only)
[    2.132139] ACPI: bus type usb registered
[    2.132222] usbcore: registered new interface driver usbfs
[    2.132237] usbcore: registered new interface driver hub
[    2.132288] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input6
[    2.132671] usbcore: registered new device driver usb
[    2.133647] uhci_hcd: USB Universal Host Controller Interface driver
[    2.142425] sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
[    2.142429] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.142548] sr 4:0:0:0: Attached scsi CD-ROM sr0
[    2.144619] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.144621] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    2.172245] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.172251] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.172259] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[    2.172291] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001800
[    2.172465] hub 1-0:1.0: USB hub found
[    2.172470] hub 1-0:1.0: 2 ports detected
[    2.172563] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.172567] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.172571] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
[    2.172614] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001820
[    2.172780] hub 2-0:1.0: USB hub found
[    2.172783] hub 2-0:1.0: 2 ports detected
[    2.172900] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.172903] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.172908] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
[    2.172947] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
[    2.173127] hub 3-0:1.0: USB hub found
[    2.173131] hub 3-0:1.0: 2 ports detected
[    2.173214] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    2.173218] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    2.173222] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
[    2.173258] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001860
[    2.173424] hub 4-0:1.0: USB hub found
[    2.173428] hub 4-0:1.0: 2 ports detected
[    2.173668] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[    2.173846] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.173849] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.173854] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
[    2.177773] ehci_hcd 0000:00:1d.7: debug port 1
[    2.177783] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    2.180364] ehci_hcd 0000:00:1d.7: irq 19, io mem 0xee404000
[    2.190174] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.190329] hub 5-0:1.0: USB hub found
[    2.190334] hub 5-0:1.0: 8 ports detected
[    2.233291] e1000e 0000:02:00.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:15:58:7f:84:03
[    2.233295] e1000e 0000:02:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    2.233390] e1000e 0000:02:00.0: eth0: MAC: 2, PHY: 2, PBA No: 005301-003
[    3.280986] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised: dm-devel@redhat.com
[    3.465289] EXT4-fs (sda1): re-mounted. Opts: nobarrier,discard
[    3.635520] Adding 1048572k swap on /swapfile.  Priority:-1 extents:2 across:1138684k SS
[    5.972817] e1000e 0000:02:00.0: irq 46 for MSI/MSI-X
[    6.073481] e1000e 0000:02:00.0: irq 46 for MSI/MSI-X
[    6.073952] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    8.951039] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
[    8.951126] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   24.258137] RPC: Registered named UNIX socket transport module.
[   24.258140] RPC: Registered udp transport module.
[   24.258141] RPC: Registered tcp transport module.
[   24.258142] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   41.888385] [drm] Initialized drm 1.1.0 20060810
[   41.900833] [drm] radeon defaulting to userspace modesetting.
[   41.901648] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   41.901650] [drm] No driver support for vblank timestamp query.
[   41.901652] [drm] Initialized radeon 1.33.0 20080528 for 0000:01:00.0 on minor 0
[   42.464397] [drm] Setting GART location based on new memory map
[   42.466063] [drm] Loading R500 Microcode
[   42.467650] [drm] Num pipes: 1
[   42.467666] [drm] writeback test succeeded in 2 usecs
[   43.730913] NFS: Registering the id_resolver key type
[   43.730930] Key type id_resolver registered
[   43.730931] Key type id_legacy registered
[   84.697223] pool[2970]: segfault at 138 ip b7083ee0 sp ad6fee2c error 4 in libgio-2.0.so.0.3200.4[b7060000+156000]
[  106.642962] BUG: unable to handle kernel paging request at 09000000
[  106.642967] IP: [<c01c0238>] __kmalloc+0x88/0x150
[  106.642974] *pde = 00000000 
[  106.642977] Oops: 0000 [#1] SMP 
[  106.642979] Modules linked in: nfsv4 auth_rpcgss radeon drm_kms_helper ttm drm i2c_algo_bit nfs lockd sunrpc dm_mod snd_hda_codec_analog coretemp kvm_intel kvm ehci_hcd i2c_i801 i2c_core sr_mod cdrom uhci_hcd usbcore snd_hda_intel usb_common snd_hda_codec e1000e snd_pcm snd_page_alloc snd_timer thinkpad_acpi snd video
[  106.643003] Pid: 2983, comm: du Not tainted 3.6.0 #1 LENOVO 20087JG/20087JG
[  106.643006] EIP: 0060:[<c01c0238>] EFLAGS: 00210206 CPU: 0
[  106.643008] EIP is at __kmalloc+0x88/0x150
[  106.643010] EAX: 00000000 EBX: 09000000 ECX: 0000ebcb EDX: 0000ebca
[  106.643011] ESI: f5802380 EDI: 09000000 EBP: f154fe10 ESP: f154fde4
[  106.643013]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  106.643014] CR0: 8005003b CR2: 09000000 CR3: 31541000 CR4: 000007d0
[  106.643016] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  106.643017] DR6: ffff0ff0 DR7: 00000400
[  106.643019] Process du (pid: 2983, ti=f154e000 task=f5329b90 task.ti=f154e000)
[  106.643020] Stack:
[  106.643020]  0000000b 09000000 0000ebca c024e3e0 0000ebcb 70636f6d c0236ed9 000080d0
[  106.643026]  f0de13e4 f154feac f0de13e4 f154fe30 c0236ed9 66b7f4d5 267b6df2 f594bc60
[  106.643030]  f0de13e4 f154feac f421e8c0 f154fe70 c0245c06 f0de13e4 f0de13e4 f421e8c0
[  106.643035] Call Trace:
[  106.643041]  [<c024e3e0>] ? ext4_follow_link+0x20/0x20
[  106.643045]  [<c0236ed9>] ? ext4_htree_store_dirent+0x29/0x110
[  106.643048]  [<c0236ed9>] ext4_htree_store_dirent+0x29/0x110
[  106.643051]  [<c0245c06>] htree_dirblock_to_tree+0x126/0x1b0
[  106.643054]  [<c0245cf8>] ext4_htree_fill_tree+0x68/0x1d0
[  106.643057]  [<c01bfd4d>] ? kmem_cache_alloc+0x9d/0xd0
[  106.643060]  [<c0236d6b>] ? ext4_readdir+0x71b/0x820
[  106.643063]  [<c0236bd3>] ext4_readdir+0x583/0x820
[  106.643066]  [<c01cb52f>] ? cp_new_stat64+0xef/0x110
[  106.643069]  [<c01d7120>] ? sys_ioctl+0x80/0x80
[  106.643073]  [<c02a182c>] ? security_file_permission+0x8c/0xa0
[  106.643075]  [<c01d7120>] ? sys_ioctl+0x80/0x80
[  106.643078]  [<c01d7435>] vfs_readdir+0xa5/0xd0
[  106.643080]  [<c01d75e0>] sys_getdents64+0x60/0xc0
[  106.643084]  [<c04a8bd0>] sysenter_do_call+0x12/0x26
[  106.643086] Code: 00 00 00 8b 06 64 03 05 74 46 64 c0 8b 50 04 8b 18 85 db 89 5d d8 0f 84 8c 00 00 00 8b 7d d8 8d 4a 01 8b 46 14 89 4d e4 89 55 dc <8b> 04 07 89 45 e0 89 c3 89 f8 8b 3e 64 0f c7 0f 0f 94 c0 84 c0
[  106.643119] EIP: [<c01c0238>] __kmalloc+0x88/0x150 SS:ESP 0068:f154fde4
[  106.643123] CR2: 0000000009000000
[  106.643125] ---[ end trace 402b4990fb7385f0 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
