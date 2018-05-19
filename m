Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82A506B06D3
	for <linux-mm@kvack.org>; Sat, 19 May 2018 10:46:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7-v6so6443771pfi.8
        for <linux-mm@kvack.org>; Sat, 19 May 2018 07:46:42 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f15-v6si9890941pln.359.2018.05.19.07.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 07:46:39 -0700 (PDT)
Date: Sat, 19 May 2018 17:46:32 +0300
From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180519144632.GE23723@intel.com>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com>
 <20180517164947.GV12670@dhcp22.suse.cz>
 <20180517170816.GW12670@dhcp22.suse.cz>
 <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
 <20180518040104.GA17433@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180518040104.GA17433@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 18, 2018 at 01:01:04PM +0900, Joonsoo Kim wrote:
> On Thu, May 17, 2018 at 10:53:32AM -0700, Laura Abbott wrote:
> > On 05/17/2018 10:08 AM, Michal Hocko wrote:
> > >On Thu 17-05-18 18:49:47, Michal Hocko wrote:
> > >>On Thu 17-05-18 16:58:32, Ville Syrjala wrote:
> > >>>On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> > >>>>On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> > >>>>>On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > >>>>>>From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > >>>>>>
> > >>>>>>This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > >>>>>>
> > >>>>>>Make x86 with HIGHMEM=y and CMA=y boot again.
> > >>>>>
> > >>>>>Is there any bug report with some more details? It is much more
> > >>>>>preferable to fix the issue rather than to revert the whole thing
> > >>>>>right away.
> > >>>>
> > >>>>The machine I have in front of me right now didn't give me anything.
> > >>>>Black screen, and netconsole was silent. No serial port on this
> > >>>>machine unfortunately.
> > >>>
> > >>>Booted on another machine with serial:
> > >>
> > >>Could you provide your .config please?
> > >>
> > >>[...]
> > >>>[    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
> > >>[...]
> > >>>[    0.000000] BUG: Bad page state in process swapper  pfn:377fe
> > >>>[    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
> > >>
> > >>OK, so this looks the be the source of the problem. -128 would be a
> > >>buddy page but I do not see anything that would set the counter to -127
> > >>and the real map count updates shouldn't really happen that early.
> > >>
> > >>Maybe CONFIG_DEBUG_VM and CONFIG_DEBUG_HIGHMEM will tell us more.
> > >
> > >Looking closer, I _think_ that the bug is in set_highmem_pages_init->is_highmem
> > >and zone_movable_is_highmem might force CMA pages in the zone movable to
> > >be initialized as highmem. And that sounds supicious to me. Joonsoo?
> > >
> > 
> > For a point of reference, arm with this configuration doesn't hit this bug
> > because highmem pages are freed via the memblock interface only instead
> > of iterating through each zone. It looks like the x86 highmem code
> > assumes only a single highmem zone and/or it's disjoint?
> 
> Good point! Reason of the crash is that the span of MOVABLE_ZONE is
> extended to whole node span for future CMA initialization, and,
> normal memory is wrongly freed here.
> 
> Here goes the fix. Ville, Could you test below patch?
> I re-generated the issue on my side and this patch fixed it.

This gets me past the initial hurdles. But when I tried it on a machine
with an actual 32 bit OS it oopsed again later in the boot.

[    0.000000] Linux version 4.17.0-rc5-mgm+ () (gcc version 6.4.0 (Gentoo 6.4.0-r1 p1.3)) #57 PREEMPT Sat May 19 17:25:27 EEST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000ce000-0x00000000000cffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007f6effff] usable
[    0.000000] BIOS-e820: [mem 0x000000007f6f0000-0x000000007f6f7fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007f6f8000-0x000000007f6fffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007f700000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffb00000-0x00000000ffbfffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] SMBIOS 2.3 present.
[    0.000000] DMI: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[    0.000000] e820: last_pfn = 0x7f6f0 max_arch_pfn = 0x100000
[    0.000000] x86/PAT: PAT not supported by CPU.
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] log_buf_len: 2097152 bytes
[    0.000000] early log buf free: 259584(99%)
[    0.000000] RAMDISK: [mem 0x37e58000-0x37feffff]
[    0.000000] Allocated new RAMDISK: [mem 0x37466000-0x375fd7ff]
[    0.000000] Move RAMDISK from [mem 0x37e58000-0x37fef7ff] to [mem 0x37466000-0x375fd7ff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F5970 000014 (v00 FUJ   )
[    0.000000] ACPI: RSDT 0x000000007F6F1D5C 000034 (v01 FUJ    FJNB16C  01260000 FUJ  00001000)
[    0.000000] ACPI: FACP 0x000000007F6F78E0 000074 (v01 FUJ    FJNB16C  01260000 FUJ  00001000)
[    0.000000] ACPI: DSDT 0x000000007F6F1D90 005B50 (v01 FUJ    FJNB16C  01260000 MSFT 0100000E)
[    0.000000] ACPI: FACS 0x000000007F6F8FC0 000040
[    0.000000] ACPI: SSDT 0x000000007F6F7954 000288 (v01 FUJ    FJNB16C  01260000 INTL 20030228)
[    0.000000] ACPI: SSDT 0x000000007F6F7D68 000270 (v01 FUJ    FJNB16C  01260000 MSFT 0100000E)
[    0.000000] ACPI: BOOT 0x000000007F6F7FD8 000028 (v01 FUJ    FJNB16C  01260000 FUJ  00001000)
[    0.000000] 1150MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] cma: Reserved 4 MiB at 0x37000000
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x000000007f6effff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007f6effff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007f6effff]
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] Reserving Intel graphics memory at [mem 0x7f700000-0x7fefffff]
[    0.000000] ACPI: PM-Timer IO Port: 0xfc08
[    0.000000] Local APIC disabled by BIOS -- reenabling.
[    0.000000] Found and enabled local APIC!
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000cdfff]
[    0.000000] PM: Registered nosave memory: [mem 0x000ce000-0x000cffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000d0000-0x000dbfff]
[    0.000000] PM: Registered nosave memory: [mem 0x000dc000-0x000fffff]
[    0.000000] e820: [mem 0x80000000-0xfec0ffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 520094
[    0.000000] Kernel command line: root=/dev/sda3 resume=/dev/sda2 lapic modprobe.blacklist=i915 drm.debug=0xe log_buf_len=2M console=ttyS0,115200
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] microcode: microcode updated early to revision 0x7, date = 2004-11-09
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0007f6f0)
[    0.000000] Memory: 2039028K/2087480K available (5733K kernel code, 627K rwdata, 2064K rodata, 640K init, 14252K bss, 44356K reserved, 4096K cma-reserved, 1178568K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff8f000 - 0xfffff000   ( 448 kB)
[    0.000000]   cpu_entry : 0xffc00000 - 0xffc28000   ( 160 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc184f000 - 0xc18ef000   ( 640 kB)
[    0.000000]       .data : 0xc1599460 - 0xc183ee40   (2710 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1599460   (5733 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] ftrace: allocating 22084 entries in 44 pages
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] kmemleak: Kernel memory leak detector disabled
[    0.000000] NR_IRQS: 2304, nr_irqs: 24, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      131072
[    0.000000] ... CHAINHASH_SIZE:          65536
[    0.000000]  memory used by lock dependency info: 5935 kB
[    0.000000]  per task-struct memory footprint: 1344 bytes
[    0.000000] kmemleak: Early log buffer exceeded (785), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE
[    0.000000] ACPI: Core revision 20180313
[    0.000000] ACPI: setting ELCR to 0200 (from 0800)
[    0.003333] APIC: ACPI MADT or MP tables are not detected
[    0.006666] APIC: Switch to virtual wire mode setup with no configuration
[    0.009999] Enabling APIC mode:  Flat.  Using 0 I/O APICs
[    0.013333] tsc: Fast TSC calibration using PIT
[    0.016666] tsc: Detected 1599.815 MHz processor
[    0.019999] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x170f7614032, max_idle_ns: 440795204679 ns
[    0.023355] Calibrating delay loop (skipped), value calculated using timer frequency.. 3200.94 BogoMIPS (lpj=5332716)
[    0.026674] pid_max: default: 32768 minimum: 301
[    0.030120] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.033348] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.037411] mce: CPU supports 5 MCE banks
[    0.040032] CPU0: Thermal monitoring enabled (TM2)
[    0.043354] Last level iTLB entries: 4KB 128, 2MB 0, 4MB 2
[    0.046674] Last level dTLB entries: 4KB 128, 2MB 0, 4MB 8, 1GB 0
[    0.050006] CPU: Intel(R) Pentium(R) M processor 1600MHz (family: 0x6, model: 0x9, stepping: 0x5)
[    0.053342] Spectre V2 : Vulnerable: Minimal generic ASM retpoline
[    0.056673] Spectre V2 : Spectre v2 mitigation: Filling RSB on context switch
[    0.064166] Performance Events: p6 PMU driver.
[    0.066686] ... version:                0
[    0.070017] ... bit width:              32
[    0.073346] ... generic registers:      2
[    0.076674] ... value mask:             00000000ffffffff
[    0.080007] ... max period:             000000007fffffff
[    0.083340] ... fixed-purpose events:   0
[    0.086673] ... event mask:             0000000000000003
[    0.090172] Hierarchical SRCU implementation.
[    0.094612] WARNING: CPU: 0 PID: 1 at ../kernel/kthread.c:505 kthread_park+0x70/0x80
[    0.096666] Modules linked in:
[    0.096666] CPU: 0 PID: 1 Comm: swapper Not tainted 4.17.0-rc5-mgm+ #57
[    0.096666] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[    0.096666] EIP: kthread_park+0x70/0x80
[    0.096666] EFLAGS: 00210202 CPU: 0
[    0.096666] EAX: f58fab80 EBX: f58b4680 ECX: 00000000 EDX: 00000005
[    0.096666] ESI: c183b5c8 EDI: 00000000 EBP: f58d5f58 ESP: f58d5f54
[    0.096666]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    0.096666] CR0: 80050033 CR2: ffd8f000 CR3: 018f2000 CR4: 000006d0
[    0.096666] Call Trace:
[    0.096666]  smpboot_update_cpumask_percpu_thread+0x55/0x70
[    0.096666]  softlockup_update_smpboot_threads+0x2f/0x50
[    0.096666]  lockup_detector_reconfigure+0x1a/0x80
[    0.096666]  lockup_detector_init+0x62/0x6e
[    0.096666]  kernel_init_freeable+0xe6/0x31b
[    0.096666]  ? rest_init+0x1f0/0x1f0
[    0.096666]  kernel_init+0x10/0x110
[    0.096666]  ? schedule_tail_wrapper+0x9/0xc
[    0.096666]  ret_from_fork+0x2e/0x38
[    0.096666] Code: 8d 76 00 5b 31 c0 5d c3 8d 76 00 0f 0b f6 c2 04 8b 98 38 03 00 00 74 c2 0f 0b 5b b8 da ff ff ff 5d c3 89 f6 8d bc 27 00 00 00 00 <0f> 0b b8 f0 ff ff ff eb c9 8d b4 26 00 00 00 00 3e 8d 74 26 00 
[    0.096666] irq event stamp: 810
[    0.096666] hardirqs last  enabled at (809): [<c1595ab7>] _raw_spin_unlock_irq+0x27/0x50
[    0.096666] hardirqs last disabled at (810): [<c1596f27>] common_exception+0x61/0x82
[    0.096666] softirqs last  enabled at (286): [<c1598749>] __do_softirq+0x389/0x425
[    0.096666] softirqs last disabled at (279): [<c101db7c>] call_on_stack+0x4c/0x60
[    0.096666] WARNING: CPU: 0 PID: 1 at ../kernel/kthread.c:505 kthread_park+0x70/0x80
[    0.096666] random: get_random_bytes called from print_oops_end_marker+0x57/0x70 with crng_init=0
[    0.096666] ---[ end trace 37f4adc02e5109c7 ]---
[    0.099999] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
[    0.100411] devtmpfs: initialized
[    0.103996] Built 1 zonelists, mobility grouping on.  Total pages: 510781
[    0.106943] PM: Registering ACPI NVS region [mem 0x7f6f8000-0x7f6fffff] (32768 bytes)
[    0.113811] kworker/u2:0 (15) used greatest stack depth: 6708 bytes left
[    0.116909] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.120040] futex hash table entries: 256 (order: 1, 11264 bytes)
[    0.126944] RTC time: 14:32:23, date: 05/19/18
[    0.130504] NET: Registered protocol family 16
[    0.136973] audit: initializing netlink subsys (disabled)
[    0.140948] cpuidle: using governor ladder
[    0.143370] audit: type=2000 audit(1526740342.139:1): state=initialized audit_enabled=0 res=1
[    0.146993] cpuidle: using governor menu
[    0.150336] Simple Boot Flag at 0x7f set to 0x1
[    0.153453] ACPI: bus type PCI registered
[    0.156767] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.166545] PCI: PCI BIOS revision 2.10 entry at 0xfd9b2, last bus=3
[    0.166689] PCI: Using configuration type 1 for base access
[    0.177531] kworker/u2:1 (50) used greatest stack depth: 6428 bytes left
[    0.200361] HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
[    0.204690] ACPI: Added _OSI(Module Device)
[    0.206788] ACPI: Added _OSI(Processor Device)
[    0.210189] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.213366] ACPI: Added _OSI(Processor Aggregator Device)
[    0.216692] ACPI: Added _OSI(Linux-Dell-Video)
[    0.236095] ACPI: 3 ACPI AML tables successfully acquired and loaded
[    0.253568] ACPI: Interpreter enabled
[    0.256768] ACPI: (supports S0 S3 S4 S5)
[    0.260020] ACPI: Using PIC for interrupt routing
[    0.263464] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.267543] ACPI: Enabled 5 GPEs in block 00 to 1F
[    0.299274] acpi LNXIOBAY:00: ACPI dock station (docks/bays count: 1)
[    0.312078] acpi PNP0C15:00: ACPI dock station (docks/bays count: 2)
[    0.318281] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.320131] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.326797] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.330075] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.336967] PCI host bridge to bus 0000:00
[    0.340080] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.343361] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
[    0.346701] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.358256] pci 0000:00:1f.0: quirk: [io  0xfc00-0xfc7f] claimed by ICH4 ACPI/GPIO/TCO
[    0.360189] pci 0000:00:1f.0: quirk: [io  0xfc80-0xfcbf] claimed by ICH4 GPIO
[    0.363884] pci 0000:00:1f.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.366796] pci 0000:00:1f.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.370028] pci 0000:00:1f.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.373360] pci 0000:00:1f.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.382127] pci 0000:00:1e.0: PCI bridge to [bus 01-03] (subtractive decode)
[    0.384025] pci 0000:00:1e.0: bridge has subordinate 03 but max busn 06
[    0.393971] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11)
[    0.397013] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 10 *11)
[    0.400280] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11)
[    0.403652] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11)
[    0.406944] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 *11)
[    0.413586] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 *11)
[    0.420136] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 9 10 11) *0, disabled.
[    0.423589] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 10 *11)
[    0.430878] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.433333] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.433434] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.436693] vgaarb: loaded
[    0.440528] SCSI subsystem initialized
[    0.443978] PCI: Using ACPI for IRQ routing
[    0.454474] clocksource: Switched to clocksource tsc-early
[    0.506079] pnp: PnP ACPI init
[    0.510137] system 00:00: [io  0x04d0-0x04d1] has been reserved
[    0.516193] system 00:00: [io  0xf800-0xf87f] has been reserved
[    0.522136] system 00:00: [io  0xf880-0xf8ff] has been reserved
[    0.528084] system 00:00: [io  0xfd00-0xfd6f] has been reserved
[    0.534027] system 00:00: [io  0xfe00-0xfe01] has been reserved
[    0.539965] system 00:00: [io  0xfc00-0xfc7f] has been reserved
[    0.545900] system 00:00: [io  0xfc80-0xfcbf] has been reserved
[    0.551821] system 00:00: [mem 0x000ccc00-0x000cffff] could not be reserved
[    0.558827] system 00:00: [mem 0xffb00000-0xffbfffff] has been reserved
[    0.565440] system 00:00: [mem 0xfec10000-0xfec1ffff] has been reserved
[    0.578887] pnp: PnP ACPI: found 7 devices
[    0.635088] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.644046] pci 0000:00:1e.0: BAR 9: assigned [mem 0x80000000-0x8fffffff pref]
[    0.651268] pci 0000:00:1f.1: BAR 5: assigned [mem 0x90000000-0x900003ff]
[    0.658079] pci 0000:01:0a.0: BAR 0: assigned [mem 0x94000000-0x94000fff]
[    0.664867] pci 0000:01:0a.0: BAR 9: assigned [mem 0x80000000-0x83ffffff pref]
[    0.672087] pci 0000:01:0a.0: BAR 10: assigned [mem 0x98000000-0x9bffffff]
[    0.678960] pci 0000:01:0a.1: BAR 0: assigned [mem 0x9c000000-0x9c000fff]
[    0.685747] pci 0000:01:0a.1: BAR 9: assigned [mem 0x84000000-0x87ffffff pref]
[    0.692966] pci 0000:01:0a.1: BAR 10: assigned [mem 0xa0000000-0xa3ffffff]
[    0.699837] pci 0000:01:0a.0: BAR 7: assigned [io  0x3400-0x34ff]
[    0.705927] pci 0000:01:0a.0: BAR 8: assigned [io  0x3800-0x38ff]
[    0.712018] pci 0000:01:0a.1: BAR 7: assigned [io  0x3c00-0x3cff]
[    0.718110] pci 0000:01:0a.1: BAR 8: assigned [io  0x1000-0x10ff]
[    0.724208] pci 0000:01:0a.0: CardBus bridge to [bus 02]
[    0.729517] pci 0000:01:0a.0:   bridge window [io  0x3400-0x34ff]
[    0.735609] pci 0000:01:0a.0:   bridge window [io  0x3800-0x38ff]
[    0.741700] pci 0000:01:0a.0:   bridge window [mem 0x80000000-0x83ffffff pref]
[    0.748919] pci 0000:01:0a.0:   bridge window [mem 0x98000000-0x9bffffff]
[    0.755705] pci 0000:01:0a.1: CardBus bridge to [bus 03]
[    0.761013] pci 0000:01:0a.1:   bridge window [io  0x3c00-0x3cff]
[    0.767103] pci 0000:01:0a.1:   bridge window [io  0x1000-0x10ff]
[    0.773195] pci 0000:01:0a.1:   bridge window [mem 0x84000000-0x87ffffff pref]
[    0.780414] pci 0000:01:0a.1:   bridge window [mem 0xa0000000-0xa3ffffff]
[    0.787200] pci 0000:00:1e.0: PCI bridge to [bus 01-03]
[    0.792424] pci 0000:00:1e.0:   bridge window [io  0x3000-0x3fff]
[    0.798518] pci 0000:00:1e.0:   bridge window [mem 0xd0200000-0xd02fffff]
[    0.805304] pci 0000:00:1e.0:   bridge window [mem 0x80000000-0x8fffffff pref]
[    0.813017] NET: Registered protocol family 2
[    0.817943] tcp_listen_portaddr_hash hash table entries: 512 (order: 2, 20480 bytes)
[    0.825772] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.832888] TCP bind hash table entries: 8192 (order: 6, 294912 bytes)
[    0.840507] TCP: Hash tables configured (established 8192 bind 8192)
[    0.846996] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    0.853062] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    0.859688] NET: Registered protocol family 1
[    0.864101] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.872882] PCI Interrupt Link [LNKA] enabled at IRQ 11
[    0.878545] PCI Interrupt Link [LNKD] enabled at IRQ 11
[    0.884180] PCI Interrupt Link [LNKC] enabled at IRQ 11
[    0.889816] PCI Interrupt Link [LNKH] enabled at IRQ 11
[    0.895590] Unpacking initramfs...
[    0.905875] Freeing initrd memory: 1632K
[    0.959992] DMA-API: preallocated 65536 debug entries
[    0.965077] DMA-API: debugging enabled by kernel config
[    0.971831] Scanning for low memory corruption every 60 seconds
[    0.980868] Initialise system trusted keyrings
[    0.986717] workingset: timestamp_bits=30 max_order=19 bucket_order=0
[    1.012709] pstore: using deflate compression
[    1.019013] Key type asymmetric registered
[    1.023308] Asymmetric key parser 'x509' registered
[    1.028290] bounce: pool size: 64 pages
[    1.032306] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.039796] io scheduler noop registered
[    1.043738] io scheduler deadline registered
[    1.048047] io scheduler cfq registered (default)
[    1.053568] ACPI: AC Adapter [AC] (on-line)
[    1.058317] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    1.066914] ACPI: Power Button [PWRB]
[    1.070872] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input1
[    1.079891] ACPI: Lid Switch [LID]
[    1.083628] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    1.091221] ACPI: Power Button [PWRF]
[    1.095148] tsc: Marking TSC unstable due to TSC halts in idle
[    1.104099] ACPI: Battery Slot [CMB1] (battery present)
[    1.109509] isapnp: Scanning for PnP cards...
[    1.114142] clocksource: Switched to clocksource acpi_pm
[    1.123837] ACPI: Battery Slot [CMB2] (battery absent)
[    1.482272] isapnp: No Plug & Play device found
[    1.487182] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.514395] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.522211] serial 00:05: skipping CIR port at 0x2e8 / 0x0, IRQ 3
[    1.530173] ata_piix 0000:00:1f.1: enabling device (0005 -> 0007)
[    1.538301] BUG: unable to handle kernel NULL pointer dereference at 00000000
[    1.540010] *pde = 00000000 
[    1.540010] Oops: 0002 [#1] PREEMPT
[    1.540010] Modules linked in:
[    1.540010] CPU: 0 PID: 1 Comm: swapper Tainted: G        W         4.17.0-rc5-mgm+ #57
[    1.540010] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[    1.540010] EIP: dma_direct_alloc+0x22f/0x260
[    1.540010] EFLAGS: 00210246 CPU: 0
[    1.540010] EAX: 00000000 EBX: 00000000 ECX: 00000200 EDX: 00000000
[    1.540010] ESI: 014000c4 EDI: 00000000 EBP: f58d5cdc ESP: f58d5cb8
[    1.540010]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    1.540010] CR0: 80050033 CR2: 00000000 CR3: 018f2000 CR4: 000006d0
[    1.540010] Call Trace:
[    1.540010]  ? dma_direct_mapping_error+0x10/0x10
[    1.540010]  dmam_alloc_coherent+0xe8/0x160
[    1.540010]  ata_bmdma_port_start+0x42/0x70
[    1.540010]  piix_port_start+0x1a/0x20
[    1.540010]  ata_host_start.part.9+0xcb/0x1c0
[    1.540010]  ata_host_start+0x18/0x20
[    1.540010]  ata_pci_sff_activate_host+0x30/0x2b0
[    1.540010]  ? pci_write_config_byte+0x50/0x60
[    1.540010]  ? ata_bmdma_port_intr+0xe0/0xe0
[    1.540010]  piix_init_one+0x2e1/0x5e0
[    1.540010]  ? _raw_spin_unlock_irqrestore+0x5d/0x80
[    1.540010]  pci_device_probe+0x9a/0x130
[    1.540010]  ? devices_kset_move_last+0x67/0xe0
[    1.540010]  ? sysfs_create_link+0x25/0x50
[    1.540010]  driver_probe_device+0x319/0x4e0
[    1.540010]  ? _raw_spin_unlock+0x2c/0x50
[    1.540010]  ? pci_match_device+0xd2/0x100
[    1.540010]  __driver_attach+0xd9/0x100
[    1.540010]  ? klist_next+0x6b/0xe0
[    1.540010]  ? driver_probe_device+0x4e0/0x4e0
[    1.540010]  bus_for_each_dev+0x4b/0x90
[    1.540010]  driver_attach+0x1e/0x20
[    1.540010]  ? driver_probe_device+0x4e0/0x4e0
[    1.540010]  bus_add_driver+0x18f/0x280
[    1.540010]  driver_register+0x5d/0xf0
[    1.540010]  ? ata_sff_init+0x35/0x35
[    1.540010]  __pci_register_driver+0x50/0x60
[    1.540010]  piix_init+0x19/0x29
[    1.540010]  do_one_initcall+0x62/0x330
[    1.540010]  ? parse_args+0x1cd/0x410
[    1.540010]  kernel_init_freeable+0x214/0x31b
[    1.540010]  ? rest_init+0x1f0/0x1f0
[    1.540010]  kernel_init+0x10/0x110
[    1.540010]  ? schedule_tail_wrapper+0x9/0xc
[    1.540010]  ret_from_fork+0x2e/0x38
[    1.540010] Code: 0f 84 02 ff ff ff eb d4 8d 74 26 00 f6 c2 01 75 21 f7 c7 02 00 00 00 75 24 f7 c7 04 00 00 00 75 29 89 d9 31 c0 c1 e9 02 83 e3 03 <f3> ab e9 c4 fe ff ff c6 02 00 8d 7a 01 8b 5d e0 eb d4 66 c7 07 
[    1.540010] EIP: dma_direct_alloc+0x22f/0x260 SS:ESP: 0068:f58d5cb8
[    1.540010] CR2: 0000000000000000
[    1.540010] ---[ end trace 37f4adc02e5109c8 ]---
[    1.540010] BUG: sleeping function called from invalid context at ../include/linux/cgroup-defs.h:696
[    1.540010] in_atomic(): 0, irqs_disabled(): 1, pid: 1, name: swapper
[    1.540010] INFO: lockdep is turned off.
[    1.540010] irq event stamp: 366166
[    1.540010] hardirqs last  enabled at (366165): [<c1595a6d>] _raw_spin_unlock_irqrestore+0x5d/0x80
[    1.540010] hardirqs last disabled at (366166): [<c1596f27>] common_exception+0x61/0x82
[    1.540010] softirqs last  enabled at (363740): [<c1598749>] __do_softirq+0x389/0x425
[    1.540010] softirqs last disabled at (363703): [<c101db7c>] call_on_stack+0x4c/0x60
[    1.540010] CPU: 0 PID: 1 Comm: swapper Tainted: G      D W         4.17.0-rc5-mgm+ #57
[    1.540010] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[    1.540010] Call Trace:
[    1.540010]  dump_stack+0x16/0x26
[    1.540010]  ___might_sleep+0x1f3/0x260
[    1.540010]  ? vprintk_emit+0x21c/0x420
[    1.540010]  __might_sleep+0x36/0x90
[    1.540010]  exit_signals+0x1f/0xf0
[    1.540010]  do_exit+0x79/0xb80
[    1.540010]  ? kernel_init_freeable+0x214/0x31b
[    1.540010]  ? rest_init+0x1f0/0x1f0
[    1.540010]  ? kernel_init+0x10/0x110
[    1.540010]  rewind_stack_do_exit+0x10/0x12
[    1.891523] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
[    1.891523] 
[    1.894765] Kernel Offset: disabled
[    1.894765] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
[    1.894765]  ]---
[    2.153352] random: fast init done


(gdb) list *(dma_direct_alloc+0x22f)
0x573fbf is in dma_direct_alloc (../lib/dma-direct.c:104).
94	
95		if (!page)
96			return NULL;
97		ret = page_address(page);
98		if (force_dma_unencrypted()) {
99			set_memory_decrypted((unsigned long)ret, 1 << page_order);
100			*dma_handle = __phys_to_dma(dev, page_to_phys(page));
101		} else {
102			*dma_handle = phys_to_dma(dev, page_to_phys(page));
103		}
104		memset(ret, 0, size);
105		return ret;
106	}

-- 
Ville Syrjala
Intel
