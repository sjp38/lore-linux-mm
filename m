Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F277C6B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 13:45:22 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l3so6012876wrf.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 10:45:22 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id b38si11725984wrb.450.2017.12.22.10.45.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 10:45:21 -0800 (PST)
Received: from mail-it0-f72.google.com ([209.85.214.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <seth.forshee@canonical.com>)
	id 1eSSJs-00064i-CZ
	for linux-mm@kvack.org; Fri, 22 Dec 2017 18:45:20 +0000
Received: by mail-it0-f72.google.com with SMTP id r6so11410682itr.1
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 10:45:20 -0800 (PST)
Date: Fri, 22 Dec 2017 12:45:15 -0600
From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20171222184515.GT11858@ubuntu-hedt>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
 <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
 <20171201142327.GA16952@ubuntu-xps13>
 <20171218145320.GO16951@dhcp22.suse.cz>
 <20171222144925.GR4831@dhcp22.suse.cz>
 <20171222161240.GA25425@ubuntu-xps13>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Content-Disposition: inline
In-Reply-To: <20171222161240.GA25425@ubuntu-xps13>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 22, 2017 at 10:12:40AM -0600, Seth Forshee wrote:
> On Fri, Dec 22, 2017 at 03:49:25PM +0100, Michal Hocko wrote:
> > On Mon 18-12-17 15:53:20, Michal Hocko wrote:
> > > On Fri 01-12-17 08:23:27, Seth Forshee wrote:
> > > > On Mon, Sep 25, 2017 at 02:58:25PM +0200, Michal Hocko wrote:
> > > > > On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> > > [...]
> > > > > > It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
> > > > > > and the problem still occurs there. It's pointing to the call to
> > > > > > __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
> > > > > > get to via wp_page_copy -> cow_user_page -> copy_user_highpage.
> > > > > 
> > > > > Hmm, this is interesting. That would mean that we have successfully
> > > > > mapped the destination page but its memory is still not accessible.
> > > > > 
> > > > > Right now I do not see how the patch you have bisected to could make any
> > > > > difference because it only postponed the onlining to be independent but
> > > > > your config simply onlines automatically so there shouldn't be any
> > > > > semantic change. Maybe there is some sort of off-by-one or something.
> > > > > 
> > > > > I will try to investigate some more. Do you think it would be possible
> > > > > to configure kdump on your system and provide me with the vmcore in some
> > > > > way?
> > > > 
> > > > Sorry, I got busy with other stuff and this kind of fell off my radar.
> > > > It came to my attention again recently though.
> > > 
> > > Apology on my side. This has completely fall of my radar.
> > > 
> > > > I was looking through the hotplug rework changes, and I noticed that
> > > > 32-bit x86 previously was using ZONE_HIGHMEM as a default but after the
> > > > rework it doesn't look like it's possible for memory to be associated
> > > > with ZONE_HIGHMEM when onlining. So I made the change below against 4.14
> > > > and am now no longer seeing the oopses.
> > > 
> > > Thanks a lot for debugging! Do I read the above correctly that the
> > > current code simply returns ZONE_NORMAL and maps an unrelated pfn into
> > > this zone and that leads to later blowups? Could you attach the fresh
> > > boot dmesg output please?
> > > 
> > > > I'm sure this isn't the correct fix, but I think it does confirm that
> > > > the problem is that the memory should be associated with ZONE_HIGHMEM
> > > > but is not.
> > > 
> > > 
> > > Yes, the fix is not quite right. HIGHMEM is not a _kernel_ memory
> > > zone. The kernel cannot access that memory directly. It is essentially a
> > > movable zone from the hotplug API POV. We simply do not have any way to
> > > tell into which zone we want to online this memory range in.
> > > Unfortunately both zones _can_ be present. It would require an explicit
> > > configuration (movable_node and a NUMA hoptlugable nodes running in 32b
> > > or and movable memory configured explicitly on the kernel command line).
> > > 
> > > The below patch is not really complete but I would rather start simple.
> > > Maybe we do not even have to care as most 32b users will never use both
> > > zones at the same time. I've placed a warning to learn about those.
> > > 
> > > Does this pass your testing?
> > 
> > Any chances to test this?
> 
> Yes, I should get to testing it soon. I'm working through a backlog of
> things I need to get done and this just hasn't quite made it to the top.

I started by testing vanilla 4.15-rc4 with a vm that has several memory
slots already populated at boot. With that I no longer get an oops,
however while /sys/devices/system/memory/*/online is 1 it looks like the
memory isn't being used. With your patch the behavior is the same. I'm
attaching dmesg from both kernels.

Thanks,
Seth

> 
> > > ---
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 262bfd26baf9..18fec18bdb60 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -855,12 +855,29 @@ static struct zone *default_kernel_zone_for_pfn(int nid, unsigned long start_pfn
> > >  	return &pgdat->node_zones[ZONE_NORMAL];
> > >  }
> > >  
> > > +static struct zone *default_movable_zone_for_pfn(int nid)
> > > +{
> > > +	/*
> > > +	 * Please note that 32b HIGHMEM systems might have 2 movable zones
> > > +	 * actually so we have to check for both. This is rather ugly hack
> > > +	 * to enforce using Highmem on those systems but we do not have a
> > > +	 * good user API to tell into which movable zone we should online.
> > > +	 * WARN if we have a movable zone which is not highmem.
> > > +	 */
> > > +#ifdef CONFIG_HIGHMEM
> > > +	WARN_ON_ONCE(!zone_movable_is_highmem());
> > > +	return &NODE_DATA(nid)->node_zones[ZONE_HIGHMEM];
> > > +#else
> > > +	return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > > +#endif
> > > +}
> > > +
> > >  static inline struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
> > >  		unsigned long nr_pages)
> > >  {
> > >  	struct zone *kernel_zone = default_kernel_zone_for_pfn(nid, start_pfn,
> > >  			nr_pages);
> > > -	struct zone *movable_zone = &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > > +	struct zone *movable_zone = default_movable_zone_for_pfn(nid);
> > >  	bool in_kernel = zone_intersects(kernel_zone, start_pfn, nr_pages);
> > >  	bool in_movable = zone_intersects(movable_zone, start_pfn, nr_pages);
> > >  
> > > @@ -886,7 +903,7 @@ struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
> > >  		return default_kernel_zone_for_pfn(nid, start_pfn, nr_pages);
> > >  
> > >  	if (online_type == MMOP_ONLINE_MOVABLE)
> > > -		return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > > +		return default_movable_zone_for_pfn(nid);
> > >  
> > >  	return default_zone_for_pfn(nid, start_pfn, nr_pages);
> > >  }
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-4.15-rc4.txt"

[    0.000000] Linux version 4.15.0-041500rc4-generic (kernel@gloin) (gcc version 7.2.0 (Ubuntu 7.2.0-8ubuntu3)) #201712172330 SMP Mon Dec 18 04:44:01 UTC 2017
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001ffddfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001ffde000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x1ffde max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: PAT not supported by CPU.
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] found SMP MP-table at [mem 0x000f6a90-0x000f6a9f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x073fffff]
[    0.000000] Base memory trampoline at [(ptrval)] 9b000 size 16384
[    0.000000] BRK [0x06eee000, 0x06eeefff] PGTABLE
[    0.000000] BRK [0x06eef000, 0x06eeffff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1bf44000-0x1ed17fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F68B0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000001FFE1B1E 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000001FFE197A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000001FFE0040 00193A (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000001FFE0000 000040
[    0.000000] ACPI: APIC 0x000000001FFE1A6E 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000001FFE1AE6 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 511MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 1ffde000
[    0.000000]   low ram: 0 - 1ffde000
[    0.000000] kvm-clock: cpu 0, msr 0:1ffdc001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 3886829473 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x000000001ffddfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001ffddfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001ffddfff]
[    0.000000] On node 0 totalpages: 130940
[    0.000000]   DMA zone: 40 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 1240 pages used for memmap
[    0.000000]   Normal zone: 126942 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_node_ids:1
[    0.000000] percpu: Embedded 23 pages/cpu @(ptrval) s65420 r0 d28788 u94208
[    0.000000] pcpu-alloc: s65420 r0 d28788 u94208 alloc=23*4096
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1fac5640
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 129660
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-041500rc4-generic root=UUID=e8de8903-ce33-4ba7-89bd-03a419bda665 ro console=ttyAMA0 console=ttyS0
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 455832K/523760K available (8735K kernel code, 893K rwdata, 3400K rodata, 1040K init, 848K bss, 67928K reserved, 0K cma-reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
                   fixmap  : 0xfff0b000 - 0xfffff000   ( 976 kB)
                   pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
                   vmalloc : 0xe07de000 - 0xffbfe000   ( 500 MB)
                   lowmem  : 0xc0000000 - 0xdffde000   ( 511 MB)
                     .init : 0xc6cd3000 - 0xc6dd7000   (1040 kB)
                     .data : 0xc6887c88 - 0xc6cbf480   (4317 kB)
                     .text : 0xc6000000 - 0xc6887c88   (8735 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] ftrace: allocating 37617 entries in 74 pages
[    0.004000] Hierarchical RCU implementation.
[    0.004000] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=1.
[    0.004000] 	Tasks RCU enabled.
[    0.004000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
[    0.004000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.004000] CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
[    0.004000] Console: colour dummy device 80x25
[    0.004000] console [ttyS0] enabled
[    0.004000] allocated 524288 bytes of page_ext
[    0.004000] ACPI: Core revision 20170831
[    0.004000] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.004000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.004000] hpet clockevent registered
[    0.004003] APIC: Switch to symmetric I/O mode setup
[    0.004444] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.005330] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.005688] tsc: Detected 2993.068 MHz processor
[    0.005952] Calibrating delay loop (skipped) preset value.. 5986.13 BogoMIPS (lpj=11972272)
[    0.005952] pid_max: default: 32768 minimum: 301
[    0.005952] Security Framework initialized
[    0.005952] Yama: becoming mindful.
[    0.005952] AppArmor: AppArmor initialized
[    0.005952] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.005952] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.008166] CPU: Physical Processor ID: 0
[    0.008416] mce: CPU supports 10 MCE banks
[    0.008676] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.008983] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.014630] Freeing SMP alternatives memory: 32K
[    0.016000] smpboot: CPU0: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
[    0.016000] Performance Events: PMU not available due to virtualization, using software events only.
[    0.016000] Hierarchical SRCU implementation.
[    0.016000] NMI watchdog: Perf event create on CPU 0 failed with -2
[    0.016000] NMI watchdog: Perf NMI watchdog permanently disabled
[    0.016000] smp: Bringing up secondary CPUs ...
[    0.016000] smp: Brought up 1 node, 1 CPU
[    0.016000] smpboot: Max logical packages: 1
[    0.016000] smpboot: Total of 1 processors activated (5986.13 BogoMIPS)
[    0.016000] devtmpfs: initialized
[    0.016133] evm: security.selinux
[    0.016394] evm: security.SMACK64
[    0.016603] evm: security.SMACK64EXEC
[    0.016815] evm: security.SMACK64TRANSMUTE
[    0.017052] evm: security.SMACK64MMAP
[    0.017264] evm: security.apparmor
[    0.017462] evm: security.ima
[    0.017636] evm: security.capability
[    0.017932] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.018497] futex hash table entries: 256 (order: 2, 16384 bytes)
[    0.018870] pinctrl core: initialized pinctrl subsystem
[    0.019249] RTC time: 18:39:18, date: 12/22/17
[    0.019559] NET: Registered protocol family 16
[    0.020031] audit: initializing netlink subsys (disabled)
[    0.020447] EISA bus registered
[    0.020649] cpuidle: using governor ladder
[    0.020885] cpuidle: using governor menu
[    0.021163] ACPI: bus type PCI registered
[    0.021399] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.021987] PCI: PCI BIOS area is rw and x. Use pci=nobios if you want it NX.
[    0.022399] PCI: PCI BIOS revision 2.10 entry at 0xfd501, last bus=0
[    0.022762] PCI: Using configuration type 1 for base access
[    0.023812] audit: type=2000 audit(1513967958.480:1): state=initialized audit_enabled=0 res=1
[    0.024046] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.024566] ACPI: Added _OSI(Module Device)
[    0.024840] ACPI: Added _OSI(Processor Device)
[    0.025096] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.025365] ACPI: Added _OSI(Processor Aggregator Device)
[    0.026639] ACPI: Interpreter enabled
[    0.026873] ACPI: (supports S0 S3 S4 S5)
[    0.027100] ACPI: Using IOAPIC for interrupt routing
[    0.027394] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.028103] ACPI: Enabled 3 GPEs in block 00 to 0F
[    0.030217] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.030584] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.030979] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.031359] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.032198] acpiphp: Slot [3] registered
[    0.032442] acpiphp: Slot [4] registered
[    0.032683] acpiphp: Slot [5] registered
[    0.032922] acpiphp: Slot [6] registered
[    0.033160] acpiphp: Slot [7] registered
[    0.033400] acpiphp: Slot [8] registered
[    0.033639] acpiphp: Slot [9] registered
[    0.033879] acpiphp: Slot [10] registered
[    0.034124] acpiphp: Slot [11] registered
[    0.034368] acpiphp: Slot [12] registered
[    0.034611] acpiphp: Slot [13] registered
[    0.034854] acpiphp: Slot [14] registered
[    0.035098] acpiphp: Slot [15] registered
[    0.035341] acpiphp: Slot [16] registered
[    0.035584] acpiphp: Slot [17] registered
[    0.036012] acpiphp: Slot [18] registered
[    0.036263] acpiphp: Slot [19] registered
[    0.036683] acpiphp: Slot [20] registered
[    0.036946] acpiphp: Slot [21] registered
[    0.037188] acpiphp: Slot [22] registered
[    0.037429] acpiphp: Slot [23] registered
[    0.037670] acpiphp: Slot [24] registered
[    0.037911] acpiphp: Slot [25] registered
[    0.038152] acpiphp: Slot [26] registered
[    0.038394] acpiphp: Slot [27] registered
[    0.038635] acpiphp: Slot [28] registered
[    0.038876] acpiphp: Slot [29] registered
[    0.039124] acpiphp: Slot [30] registered
[    0.039367] acpiphp: Slot [31] registered
[    0.039605] PCI host bridge to bus 0000:00
[    0.039842] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.040002] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.040390] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.040836] pci_bus 0000:00: root bus resource [mem 0x20000000-0xfebfffff window]
[    0.041288] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.041642] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.041841] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.042095] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.044709] pci 0000:00:01.1: reg 0x20: [io  0xc080-0xc08f]
[    0.045794] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.046326] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.047506] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.048002] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.048472] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.048658] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.049089] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.049638] pci 0000:00:02.0: [1b36:0100] type 00 class 0x030000
[    0.052003] pci 0000:00:02.0: reg 0x10: [mem 0xf4000000-0xf7ffffff]
[    0.054637] pci 0000:00:02.0: reg 0x14: [mem 0xf8000000-0xfbffffff]
[    0.057775] pci 0000:00:02.0: reg 0x18: [mem 0xfc050000-0xfc051fff]
[    0.061652] pci 0000:00:02.0: reg 0x1c: [io  0xc040-0xc05f]
[    0.069537] pci 0000:00:02.0: reg 0x30: [mem 0xfc040000-0xfc04ffff pref]
[    0.069688] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.072003] pci 0000:00:03.0: reg 0x10: [io  0xc060-0xc07f]
[    0.073800] pci 0000:00:03.0: reg 0x14: [mem 0xfc052000-0xfc052fff]
[    0.081186] pci 0000:00:03.0: reg 0x20: [mem 0xfebf8000-0xfebfbfff 64bit pref]
[    0.082353] pci 0000:00:03.0: reg 0x30: [mem 0xfc000000-0xfc03ffff pref]
[    0.082632] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.084827] pci 0000:00:04.0: reg 0x10: [io  0xc000-0xc03f]
[    0.086377] pci 0000:00:04.0: reg 0x14: [mem 0xfc053000-0xfc053fff]
[    0.091220] pci 0000:00:04.0: reg 0x20: [mem 0xfebfc000-0xfebfffff 64bit pref]
[    0.093849] pci_bus 0000:00: on NUMA node 0
[    0.094119] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.094584] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.096060] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.096484] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.096876] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.105104] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.105472] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.105986] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.106341] vgaarb: loaded
[    0.106624] SCSI subsystem initialized
[    0.106866] libata version 3.00 loaded.
[    0.106876] ACPI: bus type USB registered
[    0.107121] usbcore: registered new interface driver usbfs
[    0.107440] usbcore: registered new interface driver hub
[    0.107766] usbcore: registered new device driver usb
[    0.108038] EDAC MC: Ver: 3.0.0
[    0.108360] PCI: Using ACPI for IRQ routing
[    0.108626] PCI: pci_cache_line_size set to 64 bytes
[    0.108689] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.108690] e820: reserve RAM buffer [mem 0x1ffde000-0x1fffffff]
[    0.108750] NetLabel: Initializing
[    0.108956] NetLabel:  domain hash size = 128
[    0.109348] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.109707] NetLabel:  unlabeled traffic allowed by default
[    0.110132] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.110548] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.110831] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.113043] clocksource: Switched to clocksource kvm-clock
[    0.119947] VFS: Disk quotas dquot_6.6.0
[    0.120228] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.120706] AppArmor: AppArmor Filesystem Enabled
[    0.121025] pnp: PnP ACPI init
[    0.121239] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.121260] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.121274] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.121280] pnp 00:03: [dma 2]
[    0.121287] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.121319] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.121344] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.121510] pnp: PnP ACPI: found 6 devices
[    0.121767] PnPBIOS: Disabled
[    0.157088] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.157648] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.157649] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.157650] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.157651] pci_bus 0000:00: resource 7 [mem 0x20000000-0xfebfffff window]
[    0.157685] NET: Registered protocol family 2
[    0.158095] TCP established hash table entries: 4096 (order: 2, 16384 bytes)
[    0.158543] TCP bind hash table entries: 4096 (order: 3, 32768 bytes)
[    0.158947] TCP: Hash tables configured (established 4096 bind 4096)
[    0.159347] UDP hash table entries: 256 (order: 1, 8192 bytes)
[    0.159709] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
[    0.160136] NET: Registered protocol family 1
[    0.160416] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.160764] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.161132] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.161519] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.162009] PCI: CLS 0 bytes, default 64
[    0.162035] Unpacking initramfs...
[    0.746635] Freeing initrd memory: 46928K
[    0.747071] Scanning for low memory corruption every 60 seconds
[    0.747751] Initialise system trusted keyrings
[    0.748056] Key type blacklist registered
[    0.748331] workingset: timestamp_bits=14 max_order=17 bucket_order=3
[    0.749421] zbud: loaded
[    0.749752] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.750202] fuse init (API version 7.26)
[    0.751032] Key type asymmetric registered
[    0.751306] Asymmetric key parser 'x509' registered
[    0.751613] bounce: pool size: 64 pages
[    0.751859] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
[    0.752338] io scheduler noop registered
[    0.752586] io scheduler deadline registered
[    0.752876] io scheduler cfq registered (default)
[    0.753247] vesafb: mode is 640x480x32, linelength=2560, pages=0
[    0.753619] vesafb: scrolling: redraw
[    0.753845] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    0.754195] vesafb: framebuffer at 0xf4000000, mapped to 0xafd94fcf, using 1216k, total 1216k
[    0.755675] Console: switching to colour frame buffer device 80x30
[    0.756731] fb0: VESA VGA frame buffer device
[    0.757012] intel_idle: does not run on family 6 model 6
[    0.757051] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.757513] ACPI: Power Button [PWRF]
[    0.757820] isapnp: Scanning for PnP cards...
[    1.070402] isapnp: No Plug & Play device found
[    1.083687] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.097439] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    1.098301] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    1.120455] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.121496] Linux agpgart interface v0.103
[    1.122528] loop: module loaded
[    1.122825] ata_piix 0000:00:01.1: version 2.13
[    1.123399] scsi host0: ata_piix
[    1.123653] scsi host1: ata_piix
[    1.123887] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc080 irq 14
[    1.124283] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc088 irq 15
[    1.125003] libphy: Fixed MDIO Bus: probed
[    1.125251] tun: Universal TUN/TAP device driver, 1.6
[    1.125564] PPP generic driver version 2.4.2
[    1.125839] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.126220] ehci-pci: EHCI PCI platform driver
[    1.126483] ehci-platform: EHCI generic platform driver
[    1.126790] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.127191] ohci-pci: OHCI PCI platform driver
[    1.127453] ohci-platform: OHCI generic platform driver
[    1.127757] uhci_hcd: USB Universal Host Controller Interface driver
[    1.128164] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.129028] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.129320] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.129788] mousedev: PS/2 mouse device common for all mice
[    1.130245] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    1.130892] rtc_cmos 00:00: RTC can wake from S4
[    1.131277] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    1.131690] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram, hpet irqs
[    1.132161] i2c /dev entries driver
[    1.132407] device-mapper: uevent: version 1.0.3
[    1.132707] device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
[    1.133206] platform eisa.0: Probing EISA bus 0
[    1.133471] platform eisa.0: EISA: Cannot allocate resource for mainboard
[    1.133860] platform eisa.0: Cannot allocate resource for EISA slot 1
[    1.134231] platform eisa.0: Cannot allocate resource for EISA slot 2
[    1.134600] platform eisa.0: Cannot allocate resource for EISA slot 3
[    1.134977] platform eisa.0: Cannot allocate resource for EISA slot 4
[    1.135348] platform eisa.0: Cannot allocate resource for EISA slot 5
[    1.135719] platform eisa.0: Cannot allocate resource for EISA slot 6
[    1.136099] platform eisa.0: Cannot allocate resource for EISA slot 7
[    1.136472] platform eisa.0: Cannot allocate resource for EISA slot 8
[    1.136842] platform eisa.0: EISA: Detected 0 cards
[    1.137126] cpufreq_nforce2: No nForce2 chipset
[    1.137392] ledtrig-cpu: registered to indicate activity on CPUs
[    1.137861] NET: Registered protocol family 10
[    1.140428] Segment Routing with IPv6
[    1.140686] NET: Registered protocol family 17
[    1.140966] Key type dns_resolver registered
[    1.141314] Using IPI No-Shortcut mode
[    1.141550] sched_clock: Marking stable (1140004764, 0)->(1299958250, -159953486)
[    1.142043] registered taskstats version 1
[    1.142291] Loading compiled-in X.509 certificates
[    1.145589] Loaded X.509 cert 'Build time autogenerated kernel key: 09bb3ba9dbb9e00f8aef7277c4602a1ee9405c5d'
[    1.146209] zswap: loaded using pool lzo/zbud
[    1.148361] Key type big_key registered
[    1.148606] Key type trusted registered
[    1.149715] Key type encrypted registered
[    1.149968] AppArmor: AppArmor sha1 policy hashing enabled
[    1.150349] ima: No TPM chip found, activating TPM-bypass! (rc=-19)
[    1.150754] evm: HMAC attrs: 0x1
[    1.151063]   Magic number: 13:732:696
[    1.151344] rtc_cmos 00:00: setting system clock to 2017-12-22 18:39:19 UTC (1513967959)
[    1.151844] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    1.152211] EDD information not available.
[    1.288500] ata2.01: NODEV after polling detection
[    1.288799] ata2.00: ATAPI: QEMU DVD-ROM, 2.5+, max UDMA/100
[    1.290140] ata2.00: configured for MWDMA2
[    1.291284] scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     2.5+ PQ: 0 ANSI: 5
[    1.304567] sr 1:0:0:0: [sr0] scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[    1.305620] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.306889] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.306955] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    1.309727] Freeing unused kernel memory: 1040K
[    1.310503] Write protecting the kernel text: 8736k
[    1.311384] Write protecting the kernel read-only data: 3424k
[    1.312310] NX-protecting the kernel data: 5600k
[    1.313178] ------------[ cut here ]------------
[    1.313907] x86/mm: Found insecure W+X mapping at address 4f556ded/0xc00a0000
[    1.314933] WARNING: CPU: 0 PID: 1 at /home/kernel/COD/linux/arch/x86/mm/dump_pagetables.c:237 note_page+0x670/0x860
[    1.315538] Modules linked in:
[    1.315720] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.15.0-041500rc4-generic #201712172330
[    1.316206] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    1.316717] EIP: note_page+0x670/0x860
[    1.316935] EFLAGS: 00010292 CPU: 0
[    1.317138] EAX: 00000041 EBX: df4fbf48 ECX: 000001ab EDX: 00000000
[    1.317499] ESI: 80000000 EDI: 00000000 EBP: df4fbf14 ESP: df4fbee8
[    1.317860]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    1.318325] CR0: 80050033 CR2: 01d5d060 CR3: 06de2000 CR4: 000006f0
[    1.318688] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    1.319056] DR6: fffe0ff0 DR7: 00000400
[    1.319281] Call Trace:
[    1.319429]  ptdump_walk_pgd_level_core+0x1fc/0x2e0
[    1.319713]  ptdump_walk_pgd_level_checkwx+0x16/0x20
[    1.320001]  mark_rodata_ro+0xf5/0x117
[    1.320222]  ? rest_init+0xa0/0xa0
[    1.320422]  kernel_init+0x2e/0xee
[    1.320623]  ret_from_fork+0x19/0x24
[    1.320832] Code: c6 e9 0c fb ff ff f7 c6 00 10 00 00 74 8c 68 44 a6 ac c6 e9 16 fe ff ff 52 52 68 e4 a6 ac c6 c6 05 a6 40 c9 c6 01 e8 70 72 00 00 <0f> ff 8b 53 0c 83 c4 0c e9 38 fa ff ff 50 6a 08 52 6a 08 68 f4
[    1.321915] ---[ end trace 0db94fa0ca4ef8ba ]---
[    1.322245] x86/mm: Checked W+X mappings: FAILED, 96 W+X pages found.
[    1.391416] Floppy drive(s): fd0 is 2.88M AMI BIOS
[    1.408525] FDC 0 is a S82078B
[    1.417328]  vda: vda1
[    1.424360] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input4
[    1.424973] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input3
[    1.464747] virtio_net virtio0 ens3: renamed from eth0
[    1.494921] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    1.495290] [drm] Device Version 0.0
[    1.495502] [drm] Compression level 0 log level 0
[    1.495772] [drm] 12286 io pages at offset 0x1000000
[    1.496086] [drm] 16777216 byte draw area at offset 0x0
[    1.496410] [drm] RAM header offset: 0x3ffe000
[    1.496687] [TTM] Zone  kernel: Available graphics memory: 251916 kiB
[    1.497065] [TTM] Initializing pool allocator
[    1.497321] [TTM] Initializing DMA pool allocator
[    1.497599] [drm] qxl: 16M of VRAM memory size
[    1.497878] [drm] qxl: 63M of IO pages memory ready (VRAM domain)
[    1.498369] [drm] qxl: 64M of Surface memory size
[    1.500820] [drm] main mem slot 1 [f4000000,3ffe000]
[    1.501143] [drm] surface mem slot 2 [f8000000,4000000]
[    1.501612] [drm] fb mappable at 0xF4000000, size 3145728
[    1.501935] [drm] fb: depth 24, pitch 4096, width 1024, height 768
[    1.502296] checking generic (f4000000 130000) vs hw (f4000000 1000000)
[    1.502297] fb: switching to qxldrmfb from VESA VGA
[    1.502594] Console: switching to colour dummy device 80x25
[    1.503244] fbcon: qxldrmfb (fb0) is primary device
[    1.504917] Console: switching to colour frame buffer device 128x48
[    1.508479] qxl 0000:00:02.0: fb0: qxldrmfb frame buffer device
[    1.509224] [drm] Initialized qxl 0.1.0 20120117 for 0000:00:02.0 on minor 0
[    1.628008] raid6: mmxx1    gen()  6651 MB/s
[    1.696012] raid6: mmxx2    gen()  6905 MB/s
[    1.764010] raid6: sse1x1   gen()  5701 MB/s
[    1.832005] raid6: sse1x2   gen()  6837 MB/s
[    1.900008] raid6: sse2x1   gen() 11432 MB/s
[    1.968013] raid6: sse2x1   xor()  8253 MB/s
[    2.036006] raid6: sse2x2   gen() 13663 MB/s
[    2.104027] raid6: sse2x2   xor()  9079 MB/s
[    2.104318] raid6: using algorithm sse2x2 gen() 13663 MB/s
[    2.104649] raid6: .... xor() 9079 MB/s, rmw enabled
[    2.104938] raid6: using intx1 recovery algorithm
[    2.105274] tsc: Refined TSC clocksource calibration: 2993.001 MHz
[    2.105636] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2b2471837ec, max_idle_ns: 440795222822 ns
[    2.109716] xor: measuring software checksum speed
[    2.148035]    pIII_sse  : 20406.000 MB/sec
[    2.188006]    prefetch64-sse: 22836.000 MB/sec
[    2.188303] xor: using function: prefetch64-sse (22836.000 MB/sec)
[    2.191606] async_tx: api initialized (async)
[    2.253465] Btrfs loaded, crc32c=crc32c-generic
[    2.360127] print_req_error: I/O error, dev fd0, sector 0
[    2.361082] floppy: error 10 while reading block 0
[    2.390703] EXT4-fs (vda1): mounted filesystem with ordered data mode. Opts: (null)
[    2.520212] ip_tables: (C) 2000-2006 Netfilter Core Team
[    2.525933] systemd[1]: systemd 235 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN default-hierarchy=hybrid)
[    2.527248] systemd[1]: Detected virtualization kvm.
[    2.527587] systemd[1]: Detected architecture x86.
[    2.529778] systemd[1]: Set hostname to <mem-hotplug>.
[    2.614697] systemd[1]: Created slice System Slice.
[    2.615864] systemd[1]: Mounting Kernel Debug File System...
[    2.616585] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[    2.617480] systemd[1]: Listening on udev Control Socket.
[    2.618247] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    2.619619] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[    2.660281] EXT4-fs (vda1): re-mounted. Opts: errors=remount-ro
[    2.697275] Loading iSCSI transport class v2.0-870.
[    2.738416] Adding 581564k swap on /swapfile.  Priority:-2 extents:3 across:597948k FS
[    2.745390] iscsi: registered transport (tcp)
[    2.761676] systemd-journald[338]: Received request to flush runtime journal from PID 1
[    2.832630] iscsi: registered transport (iser)
[    2.991268] audit: type=1400 audit(1513967961.336:2): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default" pid=432 comm="apparmor_parser"
[    2.991270] audit: type=1400 audit(1513967961.336:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-cgns" pid=432 comm="apparmor_parser"
[    2.991271] audit: type=1400 audit(1513967961.336:4): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-with-mounting" pid=432 comm="apparmor_parser"
[    2.991272] audit: type=1400 audit(1513967961.336:5): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-with-nesting" pid=432 comm="apparmor_parser"
[    2.996078] audit: type=1400 audit(1513967961.344:6): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/sbin/dhclient" pid=433 comm="apparmor_parser"
[    2.996080] audit: type=1400 audit(1513967961.344:7): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=433 comm="apparmor_parser"
[    2.996081] audit: type=1400 audit(1513967961.344:8): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-helper" pid=433 comm="apparmor_parser"
[    2.996082] audit: type=1400 audit(1513967961.344:9): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/connman/scripts/dhclient-script" pid=433 comm="apparmor_parser"
[    2.997305] audit: type=1400 audit(1513967961.344:10): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/bin/lxc-start" pid=434 comm="apparmor_parser"
[    3.079661] new mount options do not match the existing superblock, will be ignored
[    3.267547] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[    3.290966] parport_pc 00:04: reported by Plug and Play ACPI
[    3.291042] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    3.750234] ppdev: user-space parallel port driver

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-4.15-rc4+patch.txt"

[    0.000000] Linux version 4.15.0-rc4+ (sforshee@ubuntu-hedt) (gcc version 7.2.1 20171205 (Ubuntu 7.2.0-17ubuntu1)) #2 SMP Fri Dec 22 11:38:26 CST 2017
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001ffddfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001ffde000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x1ffde max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: PAT not supported by CPU.
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
[    0.000000] found SMP MP-table at [mem 0x000f6a90-0x000f6a9f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x053fffff]
[    0.000000] Base memory trampoline at [(ptrval)] 9b000 size 16384
[    0.000000] BRK [0x04ed7000, 0x04ed7fff] PGTABLE
[    0.000000] BRK [0x04ed8000, 0x04ed8fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1bf33000-0x1ed09fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F68B0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000001FFE1B1E 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000001FFE197A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000001FFE0040 00193A (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000001FFE0000 000040
[    0.000000] ACPI: APIC 0x000000001FFE1A6E 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000001FFE1AE6 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 511MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 1ffde000
[    0.000000]   low ram: 0 - 1ffde000
[    0.000000] kvm-clock: cpu 0, msr 0:1ffdc001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 10022658731 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x000000001ffddfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001ffddfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001ffddfff]
[    0.000000] On node 0 totalpages: 130940
[    0.000000]   DMA zone: 40 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 1240 pages used for memmap
[    0.000000]   Normal zone: 126942 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_node_ids:1
[    0.000000] percpu: Embedded 23 pages/cpu @(ptrval) s65420 r0 d28788 u94208
[    0.000000] pcpu-alloc: s65420 r0 d28788 u94208 alloc=23*4096
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1fac5640
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 129660
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-rc4+ root=UUID=e8de8903-ce33-4ba7-89bd-03a419bda665 ro console=ttyAMA0 console=ttyS0
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 455912K/523760K available (8732K kernel code, 893K rwdata, 3372K rodata, 1044K init, 848K bss, 67848K reserved, 0K cma-reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
                   fixmap  : 0xfff0b000 - 0xfffff000   ( 976 kB)
                   pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
                   vmalloc : 0xe07de000 - 0xffbfe000   ( 500 MB)
                   lowmem  : 0xc0000000 - 0xdffde000   ( 511 MB)
                     .init : 0xc4ccb000 - 0xc4dd0000   (1044 kB)
                     .data : 0xc4887008 - 0xc4cb7480   (4289 kB)
                     .text : 0xc4000000 - 0xc4887008   (8732 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] ftrace: allocating 37534 entries in 74 pages
[    0.004000] Hierarchical RCU implementation.
[    0.004000] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=1.
[    0.004000] 	Tasks RCU enabled.
[    0.004000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
[    0.004000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.004000] CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
[    0.004000] Console: colour dummy device 80x25
[    0.004000] console [ttyS0] enabled
[    0.004000] allocated 524288 bytes of page_ext
[    0.004000] ACPI: Core revision 20170831
[    0.004000] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.004000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.004000] hpet clockevent registered
[    0.004005] APIC: Switch to symmetric I/O mode setup
[    0.004394] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.005378] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.005833] tsc: Detected 2993.068 MHz processor
[    0.006169] Calibrating delay loop (skipped) preset value.. 5986.13 BogoMIPS (lpj=11972272)
[    0.006169] pid_max: default: 32768 minimum: 301
[    0.006169] Security Framework initialized
[    0.006169] Yama: becoming mindful.
[    0.006169] AppArmor: AppArmor initialized
[    0.008028] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.008510] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.009180] CPU: Physical Processor ID: 0
[    0.009492] mce: CPU supports 10 MCE banks
[    0.009816] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.010204] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.016325] Freeing SMP alternatives memory: 32K
[    0.020000] smpboot: CPU0: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
[    0.020000] Performance Events: PMU not available due to virtualization, using software events only.
[    0.020000] Hierarchical SRCU implementation.
[    0.020000] NMI watchdog: Perf event create on CPU 0 failed with -2
[    0.020000] NMI watchdog: Perf NMI watchdog permanently disabled
[    0.020000] smp: Bringing up secondary CPUs ...
[    0.020000] smp: Brought up 1 node, 1 CPU
[    0.020002] smpboot: Max logical packages: 1
[    0.020344] smpboot: Total of 1 processors activated (5986.13 BogoMIPS)
[    0.020980] devtmpfs: initialized
[    0.021387] evm: security.selinux
[    0.021663] evm: security.SMACK64
[    0.021944] evm: security.SMACK64EXEC
[    0.022247] evm: security.SMACK64TRANSMUTE
[    0.022591] evm: security.SMACK64MMAP
[    0.022886] evm: security.apparmor
[    0.023160] evm: security.ima
[    0.023405] evm: security.capability
[    0.023793] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.024003] futex hash table entries: 256 (order: 2, 16384 bytes)
[    0.024531] pinctrl core: initialized pinctrl subsystem
[    0.025020] RTC time: 18:35:29, date: 12/22/17
[    0.025439] NET: Registered protocol family 16
[    0.025887] audit: initializing netlink subsys (disabled)
[    0.026422] EISA bus registered
[    0.026665] cpuidle: using governor ladder
[    0.026969] cpuidle: using governor menu
[    0.027312] ACPI: bus type PCI registered
[    0.028002] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.028704] PCI: PCI BIOS area is rw and x. Use pci=nobios if you want it NX.
[    0.029230] PCI: PCI BIOS revision 2.10 entry at 0xfd501, last bus=0
[    0.029694] PCI: Using configuration type 1 for base access
[    0.030909] audit: type=2000 audit(1513967729.679:1): state=initialized audit_enabled=0 res=1
[    0.031587] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.032109] ACPI: Added _OSI(Module Device)
[    0.032429] ACPI: Added _OSI(Processor Device)
[    0.032756] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.033108] ACPI: Added _OSI(Processor Aggregator Device)
[    0.034537] ACPI: Interpreter enabled
[    0.034835] ACPI: (supports S0 S3 S4 S5)
[    0.035125] ACPI: Using IOAPIC for interrupt routing
[    0.035496] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.036103] ACPI: Enabled 3 GPEs in block 00 to 0F
[    0.038448] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.038925] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.039434] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.040013] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.041136] acpiphp: Slot [3] registered
[    0.041451] acpiphp: Slot [4] registered
[    0.041760] acpiphp: Slot [5] registered
[    0.042071] acpiphp: Slot [6] registered
[    0.042394] acpiphp: Slot [7] registered
[    0.042702] acpiphp: Slot [8] registered
[    0.043009] acpiphp: Slot [9] registered
[    0.043316] acpiphp: Slot [10] registered
[    0.044015] acpiphp: Slot [11] registered
[    0.044410] acpiphp: Slot [12] registered
[    0.044716] acpiphp: Slot [13] registered
[    0.045025] acpiphp: Slot [14] registered
[    0.045338] acpiphp: Slot [15] registered
[    0.045647] acpiphp: Slot [16] registered
[    0.045958] acpiphp: Slot [17] registered
[    0.046268] acpiphp: Slot [18] registered
[    0.046593] acpiphp: Slot [19] registered
[    0.046907] acpiphp: Slot [20] registered
[    0.047219] acpiphp: Slot [21] registered
[    0.047530] acpiphp: Slot [22] registered
[    0.047841] acpiphp: Slot [23] registered
[    0.048013] acpiphp: Slot [24] registered
[    0.048324] acpiphp: Slot [25] registered
[    0.048634] acpiphp: Slot [26] registered
[    0.048943] acpiphp: Slot [27] registered
[    0.049253] acpiphp: Slot [28] registered
[    0.049562] acpiphp: Slot [29] registered
[    0.049879] acpiphp: Slot [30] registered
[    0.050188] acpiphp: Slot [31] registered
[    0.050512] PCI host bridge to bus 0000:00
[    0.050821] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.051331] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.052002] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.052553] pci_bus 0000:00: root bus resource [mem 0x20000000-0xfebfffff window]
[    0.053105] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.053531] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.053744] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.054019] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.056472] pci 0000:00:01.1: reg 0x20: [io  0xc080-0xc08f]
[    0.057533] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.058077] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.058574] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.059101] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.059681] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.059880] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.060007] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.060658] pci 0000:00:02.0: [1b36:0100] type 00 class 0x030000
[    0.064003] pci 0000:00:02.0: reg 0x10: [mem 0xf4000000-0xf7ffffff]
[    0.068003] pci 0000:00:02.0: reg 0x14: [mem 0xf8000000-0xfbffffff]
[    0.070419] pci 0000:00:02.0: reg 0x18: [mem 0xfc050000-0xfc051fff]
[    0.073325] pci 0000:00:02.0: reg 0x1c: [io  0xc040-0xc05f]
[    0.082303] pci 0000:00:02.0: reg 0x30: [mem 0xfc040000-0xfc04ffff pref]
[    0.082474] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.084003] pci 0000:00:03.0: reg 0x10: [io  0xc060-0xc07f]
[    0.085369] pci 0000:00:03.0: reg 0x14: [mem 0xfc052000-0xfc052fff]
[    0.090491] pci 0000:00:03.0: reg 0x20: [mem 0xfebf8000-0xfebfbfff 64bit pref]
[    0.092003] pci 0000:00:03.0: reg 0x30: [mem 0xfc000000-0xfc03ffff pref]
[    0.092299] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.093679] pci 0000:00:04.0: reg 0x10: [io  0xc000-0xc03f]
[    0.095047] pci 0000:00:04.0: reg 0x14: [mem 0xfc053000-0xfc053fff]
[    0.099646] pci 0000:00:04.0: reg 0x20: [mem 0xfebfc000-0xfebfffff 64bit pref]
[    0.102499] pci_bus 0000:00: on NUMA node 0
[    0.102756] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.104063] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.104537] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.105005] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.105449] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.106887] WARNING: CPU: 0 PID: 1 at mm/memory_hotplug.c:867 default_movable_zone_for_pfn.isra.33.part.34+0x8/0x10
[    0.107661] Modules linked in:
[    0.107899] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.15.0-rc4+ #2
[    0.108000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    0.108000] EIP: default_movable_zone_for_pfn.isra.33.part.34+0x8/0x10
[    0.108000] EFLAGS: 00210297 CPU: 0
[    0.108000] EAX: c4c85480 EBX: 00001000 ECX: 00100000 EDX: 00000001
[    0.108000] ESI: 00000001 EDI: 00000000 EBP: df4fbcf0 ESP: df4fbcf0
[    0.108000]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    0.108000] CR0: 80050033 CR2: 00000000 CR3: 04ddb000 CR4: 000006f0
[    0.108000] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    0.108000] DR6: fffe0ff0 DR7: 00000400
[    0.108000] Call Trace:
[    0.108000]  zone_for_pfn_range+0x13b/0x150
[    0.108000]  online_pages+0x31/0x200
[    0.108000]  ? sysfs_create_file_ns+0x24/0x40
[    0.108000]  ? kobject_add_internal+0x18b/0x270
[    0.108000]  memory_subsys_online+0x16c/0x1b0
[    0.108000]  device_online+0x3b/0x80
[    0.108000]  online_memory_block+0x10/0x20
[    0.108000]  walk_memory_range+0x5c/0xa0
[    0.108000]  add_memory_resource+0x18c/0x1b0
[    0.108000]  ? online_pages_range+0xd0/0xd0
[    0.108000]  add_memory+0xbd/0x130
[    0.108000]  acpi_memory_device_add+0x103/0x2c0
[    0.108000]  acpi_bus_attach+0x132/0x1b0
[    0.108000]  acpi_bus_attach+0x76/0x1b0
[    0.108000]  acpi_bus_attach+0x76/0x1b0
[    0.108000]  acpi_bus_attach+0x76/0x1b0
[    0.108000]  acpi_bus_scan+0x41/0x90
[    0.108000]  ? acpi_sleep_proc_init+0x25/0x25
[    0.108000]  acpi_scan_init+0xf3/0x211
[    0.108000]  ? acpi_sleep_proc_init+0x25/0x25
[    0.108000]  acpi_init+0x2c0/0x314
[    0.108000]  do_one_initcall+0x46/0x170
[    0.108000]  ? parse_args+0x140/0x390
[    0.108000]  ? set_debug_rodata+0x14/0x14
[    0.108000]  kernel_init_freeable+0x146/0x1c2
[    0.108000]  ? rest_init+0xa0/0xa0
[    0.108000]  kernel_init+0xd/0xee
[    0.108000]  ret_from_fork+0x19/0x24
[    0.108000] Code: 00 00 00 3e 8d 74 26 00 55 01 c2 89 e5 e8 71 95 fa ff 31 c0 5d c3 8d b6 00 00 00 00 8d bc 27 00 00 00 00 3e 8d 74 26 00 55 89 e5 <0f> ff 5d c3 8d 74 26 00 3e 8d 74 26 00 55 89 e5 56 53 89 c3 83
[    0.108000] ---[ end trace e0d67f4d82fe1b11 ]---
[    0.117764] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.118222] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.119005] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.119435] vgaarb: loaded
[    0.119772] SCSI subsystem initialized
[    0.120025] libata version 3.00 loaded.
[    0.120037] ACPI: bus type USB registered
[    0.120352] usbcore: registered new interface driver usbfs
[    0.120786] usbcore: registered new interface driver hub
[    0.121189] usbcore: registered new device driver usb
[    0.121602] EDAC MC: Ver: 3.0.0
[    0.121959] PCI: Using ACPI for IRQ routing
[    0.122277] PCI: pci_cache_line_size set to 64 bytes
[    0.122332] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.122333] e820: reserve RAM buffer [mem 0x1ffde000-0x1fffffff]
[    0.122394] NetLabel: Initializing
[    0.122673] NetLabel:  domain hash size = 128
[    0.122993] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.123421] NetLabel:  unlabeled traffic allowed by default
[    0.124009] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.124540] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.124899] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.127414] clocksource: Switched to clocksource kvm-clock
[    0.131961] VFS: Disk quotas dquot_6.6.0
[    0.132287] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.132856] AppArmor: AppArmor Filesystem Enabled
[    0.133232] pnp: PnP ACPI init
[    0.133505] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.133528] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.133543] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.133549] pnp 00:03: [dma 2]
[    0.133557] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.133593] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.133622] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.133800] pnp: PnP ACPI: found 6 devices
[    0.134116] PnPBIOS: Disabled
[    0.169507] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.170204] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.170205] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.170206] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.170207] pci_bus 0000:00: resource 7 [mem 0x20000000-0xfebfffff window]
[    0.170242] NET: Registered protocol family 2
[    0.170681] TCP established hash table entries: 4096 (order: 2, 16384 bytes)
[    0.171235] TCP bind hash table entries: 4096 (order: 3, 32768 bytes)
[    0.171730] TCP: Hash tables configured (established 4096 bind 4096)
[    0.172228] UDP hash table entries: 256 (order: 1, 8192 bytes)
[    0.172690] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
[    0.173189] NET: Registered protocol family 1
[    0.173530] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.173975] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.174402] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.174878] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.175627] PCI: CLS 0 bytes, default 64
[    0.175656] Unpacking initramfs...
[    0.761271] Freeing initrd memory: 46940K
[    0.761741] Scanning for low memory corruption every 60 seconds
[    0.762534] Initialise system trusted keyrings
[    0.762884] Key type blacklist registered
[    0.763231] workingset: timestamp_bits=14 max_order=17 bucket_order=3
[    0.764424] zbud: loaded
[    0.764793] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.765324] fuse init (API version 7.26)
[    0.766186] Key type asymmetric registered
[    0.766501] Asymmetric key parser 'x509' registered
[    0.766872] bounce: pool size: 64 pages
[    0.767179] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
[    0.767739] io scheduler noop registered
[    0.768046] io scheduler deadline registered
[    0.768397] io scheduler cfq registered (default)
[    0.768831] vesafb: mode is 640x480x32, linelength=2560, pages=0
[    0.769281] vesafb: scrolling: redraw
[    0.769558] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    0.769982] vesafb: framebuffer at 0xf4000000, mapped to 0xa517b8b7, using 1216k, total 1216k
[    0.771599] Console: switching to colour frame buffer device 80x30
[    0.772736] fb0: VESA VGA frame buffer device
[    0.773076] intel_idle: does not run on family 6 model 6
[    0.773116] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.773677] ACPI: Power Button [PWRF]
[    0.774049] isapnp: Scanning for PnP cards...
[    1.086593] isapnp: No Plug & Play device found
[    1.100223] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.114313] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    1.115242] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    1.137767] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.138939] Linux agpgart interface v0.103
[    1.140127] loop: module loaded
[    1.140481] ata_piix 0000:00:01.1: version 2.13
[    1.141030] scsi host0: ata_piix
[    1.141483] scsi host1: ata_piix
[    1.141751] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc080 irq 14
[    1.142239] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc088 irq 15
[    1.142912] libphy: Fixed MDIO Bus: probed
[    1.143234] tun: Universal TUN/TAP device driver, 1.6
[    1.143629] PPP generic driver version 2.4.2
[    1.143982] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.144474] ehci-pci: EHCI PCI platform driver
[    1.144812] ehci-platform: EHCI generic platform driver
[    1.145202] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.145658] ohci-pci: OHCI PCI platform driver
[    1.146000] ohci-platform: OHCI generic platform driver
[    1.146393] uhci_hcd: USB Universal Host Controller Interface driver
[    1.146894] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.147914] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.148421] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.148856] mousedev: PS/2 mouse device common for all mice
[    1.149412] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    1.150195] rtc_cmos 00:00: RTC can wake from S4
[    1.150663] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    1.151186] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram, hpet irqs
[    1.151758] i2c /dev entries driver
[    1.152123] device-mapper: uevent: version 1.0.3
[    1.152702] device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
[    1.153341] platform eisa.0: Probing EISA bus 0
[    1.153677] platform eisa.0: EISA: Cannot allocate resource for mainboard
[    1.154174] platform eisa.0: Cannot allocate resource for EISA slot 1
[    1.154644] platform eisa.0: Cannot allocate resource for EISA slot 2
[    1.155114] platform eisa.0: Cannot allocate resource for EISA slot 3
[    1.155601] platform eisa.0: Cannot allocate resource for EISA slot 4
[    1.156085] platform eisa.0: Cannot allocate resource for EISA slot 5
[    1.156559] platform eisa.0: Cannot allocate resource for EISA slot 6
[    1.157033] platform eisa.0: Cannot allocate resource for EISA slot 7
[    1.157504] platform eisa.0: Cannot allocate resource for EISA slot 8
[    1.157977] platform eisa.0: EISA: Detected 0 cards
[    1.158338] cpufreq_nforce2: No nForce2 chipset
[    1.158677] ledtrig-cpu: registered to indicate activity on CPUs
[    1.159259] NET: Registered protocol family 10
[    1.161900] Segment Routing with IPv6
[    1.162209] NET: Registered protocol family 17
[    1.162564] Key type dns_resolver registered
[    1.162992] Using IPI No-Shortcut mode
[    1.163304] sched_clock: Marking stable (1160005056, 0)->(1345755251, -185750195)
[    1.163922] registered taskstats version 1
[    1.164251] Loading compiled-in X.509 certificates
[    1.167964] Loaded X.509 cert 'Build time autogenerated kernel key: b4ef9de84e162704be7a4a85a145a1bab5d86143'
[    1.168733] zswap: loaded using pool lzo/zbud
[    1.171090] Key type big_key registered
[    1.171404] Key type trusted registered
[    1.172727] Key type encrypted registered
[    1.173026] AppArmor: AppArmor sha1 policy hashing enabled
[    1.173407] ima: No TPM chip found, activating TPM-bypass! (rc=-19)
[    1.173902] evm: HMAC attrs: 0x1
[    1.174297]   Magic number: 13:629:595
[    1.174678] rtc_cmos 00:00: setting system clock to 2017-12-22 18:35:30 UTC (1513967730)
[    1.175395] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    1.175893] EDD information not available.
[    1.308524] ata2.01: NODEV after polling detection
[    1.308747] ata2.00: ATAPI: QEMU DVD-ROM, 2.5+, max UDMA/100
[    1.309799] ata2.00: configured for MWDMA2
[    1.310709] scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     2.5+ PQ: 0 ANSI: 5
[    1.324618] sr 1:0:0:0: [sr0] scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[    1.325785] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.327076] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.327173] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    1.330039] Freeing unused kernel memory: 1044K
[    1.330895] Write protecting the kernel text: 8736k
[    1.331858] Write protecting the kernel read-only data: 3392k
[    1.332849] NX-protecting the kernel data: 5600k
[    1.333767] ------------[ cut here ]------------
[    1.334560] x86/mm: Found insecure W+X mapping at address 6a1cd187/0xc00a0000
[    1.335718] WARNING: CPU: 0 PID: 1 at arch/x86/mm/dump_pagetables.c:237 note_page+0x670/0x860
[    1.336365] Modules linked in:
[    1.336594] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W        4.15.0-rc4+ #2
[    1.337150] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    1.337793] EIP: note_page+0x670/0x860
[    1.338070] EFLAGS: 00010292 CPU: 0
[    1.338329] EAX: 00000041 EBX: df4fbf48 ECX: 000001d6 EDX: 00000000
[    1.338783] ESI: 80000000 EDI: 00000000 EBP: df4fbf14 ESP: df4fbee8
[    1.339265]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    1.339666] CR0: 80050033 CR2: b7d39128 CR3: 04ddb000 CR4: 000006f0
[    1.340128] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    1.340591] DR6: fffe0ff0 DR7: 00000400
[    1.340874] Call Trace:
[    1.341060]  ptdump_walk_pgd_level_core+0x1fc/0x2e0
[    1.341424]  ptdump_walk_pgd_level_checkwx+0x16/0x20
[    1.341794]  mark_rodata_ro+0xf5/0x117
[    1.342075]  ? rest_init+0xa0/0xa0
[    1.342329]  kernel_init+0x2e/0xee
[    1.342586]  ret_from_fork+0x19/0x24
[    1.342854] Code: c4 e9 0c fb ff ff f7 c6 00 10 00 00 74 8c 68 fa 81 ac c4 e9 16 fe ff ff 52 52 68 98 82 ac c4 c6 05 a6 c0 c8 c4 01 e8 70 72 00 00 <0f> ff 8b 53 0c 83 c4 0c e9 38 fa ff ff 50 6a 08 52 6a 08 68 aa
[    1.344297] ---[ end trace e0d67f4d82fe1b13 ]---
[    1.344721] x86/mm: Checked W+X mappings: FAILED, 96 W+X pages found.
[    1.417737] Floppy drive(s): fd0 is 2.88M AMI BIOS
[    1.436209] FDC 0 is a S82078B
[    1.442157]  vda: vda1
[    1.452860] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input4
[    1.453623] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input3
[    1.486502] virtio_net virtio0 ens3: renamed from eth0
[    1.523163] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    1.523623] [drm] Device Version 0.0
[    1.523896] [drm] Compression level 0 log level 0
[    1.524254] [drm] 12286 io pages at offset 0x1000000
[    1.524623] [drm] 16777216 byte draw area at offset 0x0
[    1.525013] [drm] RAM header offset: 0x3ffe000
[    1.525364] [TTM] Zone  kernel: Available graphics memory: 251964 kiB
[    1.525840] [TTM] Initializing pool allocator
[    1.526164] [TTM] Initializing DMA pool allocator
[    1.526520] [drm] qxl: 16M of VRAM memory size
[    1.526849] [drm] qxl: 63M of IO pages memory ready (VRAM domain)
[    1.527309] [drm] qxl: 64M of Surface memory size
[    1.528751] [drm] main mem slot 1 [f4000000,3ffe000]
[    1.529134] [drm] surface mem slot 2 [f8000000,4000000]
[    1.529687] [drm] fb mappable at 0xF4000000, size 3145728
[    1.530091] [drm] fb: depth 24, pitch 4096, width 1024, height 768
[    1.530544] checking generic (f4000000 130000) vs hw (f4000000 1000000)
[    1.530545] fb: switching to qxldrmfb from VESA VGA
[    1.530912] Console: switching to colour dummy device 80x25
[    1.531681] fbcon: qxldrmfb (fb0) is primary device
[    1.533763] Console: switching to colour frame buffer device 128x48
[    1.538808] qxl 0000:00:02.0: fb0: qxldrmfb frame buffer device
[    1.553527] [drm] Initialized qxl 0.1.0 20120117 for 0000:00:02.0 on minor 0
[    1.684006] raid6: mmxx1    gen()  6370 MB/s
[    1.752016] raid6: mmxx2    gen()  6546 MB/s
[    1.820018] raid6: sse1x1   gen()  5447 MB/s
[    1.888009] raid6: sse1x2   gen()  6651 MB/s
[    1.956007] raid6: sse2x1   gen() 11137 MB/s
[    2.024004] raid6: sse2x1   xor()  8240 MB/s
[    2.092006] raid6: sse2x2   gen() 13450 MB/s
[    2.160008] raid6: sse2x2   xor()  8759 MB/s
[    2.160331] raid6: using algorithm sse2x2 gen() 13450 MB/s
[    2.160732] raid6: .... xor() 8759 MB/s, rmw enabled
[    2.161099] raid6: using intx1 recovery algorithm
[    2.161499] tsc: Refined TSC clocksource calibration: 2993.007 MHz
[    2.161959] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2b24776bc64, max_idle_ns: 440795348589 ns
[    2.166148] xor: measuring software checksum speed
[    2.204005]    pIII_sse  : 19572.000 MB/sec
[    2.244005]    prefetch64-sse: 21508.000 MB/sec
[    2.244393] xor: using function: prefetch64-sse (21508.000 MB/sec)
[    2.247852] async_tx: api initialized (async)
[    2.311665] Btrfs loaded, crc32c=crc32c-generic
[    2.420115] print_req_error: I/O error, dev fd0, sector 0
[    2.421215] floppy: error 10 while reading block 0
[    2.450489] EXT4-fs (vda1): mounted filesystem with ordered data mode. Opts: (null)
[    2.577843] ip_tables: (C) 2000-2006 Netfilter Core Team
[    2.583528] systemd[1]: systemd 235 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN default-hierarchy=hybrid)
[    2.585139] systemd[1]: Detected virtualization kvm.
[    2.585545] systemd[1]: Detected architecture x86.
[    2.587722] systemd[1]: Set hostname to <mem-hotplug>.
[    2.670054] systemd[1]: Reached target User and Group Name Lookups.
[    2.671222] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[    2.672930] systemd[1]: Created slice System Slice.
[    2.673769] systemd[1]: Listening on LVM2 poll daemon socket.
[    2.674690] systemd[1]: Listening on udev Control Socket.
[    2.675616] systemd[1]: Listening on LVM2 metadata daemon socket.
[    2.732979] EXT4-fs (vda1): re-mounted. Opts: errors=remount-ro
[    2.755589] Loading iSCSI transport class v2.0-870.
[    2.809274] Adding 581564k swap on /swapfile.  Priority:-2 extents:3 across:597948k FS
[    2.817360] iscsi: registered transport (tcp)
[    2.840163] systemd-journald[339]: Received request to flush runtime journal from PID 1
[    2.901450] iscsi: registered transport (iser)
[    3.066742] audit: type=1400 audit(1513967732.388:2): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default" pid=437 comm="apparmor_parser"
[    3.066743] audit: type=1400 audit(1513967732.388:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-cgns" pid=437 comm="apparmor_parser"
[    3.066745] audit: type=1400 audit(1513967732.388:4): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-with-mounting" pid=437 comm="apparmor_parser"
[    3.066746] audit: type=1400 audit(1513967732.388:5): apparmor="STATUS" operation="profile_load" profile="unconfined" name="lxc-container-default-with-nesting" pid=437 comm="apparmor_parser"
[    3.071724] audit: type=1400 audit(1513967732.392:6): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/sbin/dhclient" pid=438 comm="apparmor_parser"
[    3.071725] audit: type=1400 audit(1513967732.392:7): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=438 comm="apparmor_parser"
[    3.071726] audit: type=1400 audit(1513967732.392:8): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-helper" pid=438 comm="apparmor_parser"
[    3.071727] audit: type=1400 audit(1513967732.392:9): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/connman/scripts/dhclient-script" pid=438 comm="apparmor_parser"
[    3.072986] audit: type=1400 audit(1513967732.396:10): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/bin/lxc-start" pid=439 comm="apparmor_parser"
[    3.121727] new mount options do not match the existing superblock, will be ignored
[    3.354736] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[    3.421529] parport_pc 00:04: reported by Plug and Play ACPI
[    3.421602] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    3.802813] ppdev: user-space parallel port driver

--PEIAKu/WMn1b1Hv9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
