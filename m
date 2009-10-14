Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A9DF06B004D
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 09:10:18 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Wed, 14 Oct 2009 15:10:08 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910132238.40867.elendil@planet.nl> <20091014103002.GA5027@csn.ul.ie>
In-Reply-To: <20091014103002.GA5027@csn.ul.ie>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_z2c1KJnOi9pY+mk"
Message-Id: <200910141510.11059.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_z2c1KJnOi9pY+mk
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 14 October 2009, Mel Gorman wrote:
> I think this is very significant. Either that change needs to be backed
> out or more likely, __GFP_NOWARN needs to be specified and warnings
> *only* printed when the RX buffers are really low. My expectation would
> be that some GFP_ATOMIC allocations fail during refill but the fact they
> fail wakes kswapd to reclaim order-2 pages while the RX buffers in the
> pool are consumed.

Sorry I did not actually mention this, but the SKB failures I get with .32 
have loads of the "Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 
free buffers remaining." errors. That's why I don't think your patch will 
help anything.

zgrep "Only 0 free buffers remaining" /var/log/kern.log* | wc -l
84

OK, they are all GPF_ATOMIC and not GPF_KERNEL, but they also almost all 
have "0 free buffers"! Next to the 84 warnings for 0 remaining I only have 
one with "3 free buffers" and one with "1 free buffers".

And that does not even count the rate limitting:
Oct 12 20:15:07 aragorn kernel: __ratelimit: 45 callbacks suppressed
Oct 12 20:25:19 aragorn kernel: __ratelimit: 27 callbacks suppressed
Oct 12 20:25:20 aragorn kernel: __ratelimit: 2 callbacks suppressed

Attached the kernel log for one test I did with .32.

> > In both cases I no longer get SKB errors, but instead (?) I get
> > firmware errors:
> > iwlagn 0000:10:00.0: Microcode SW error detected.  Restarting
> > 0x2000000.
>
> I am no wireless expert, but that looks like an separate problem to me.
> I don't see how an allocation failure could trigger errors in the
> microcode.

Yes, it is a separate problem, but it is still significant that reverting 
that patch triggers them in the extreme swap situation.

> > With your patch on .32-rc4 I still get the SKB errors, so it does not
> > seem to help. The only change there may have been is that the desktop
> > was frozen longer than without the patch, but that is an impression,
> > not a hard fact.
>
> Actually, that's fairly interesting and I think justifies pushing the
> patch. Direct reclaim can stall processes in a user-visible manner which
> kswapd is meant to avoid in the majority of cases but is tricky to
> quantify without instrumenting the kernel to measure direct reclaim
> frequency and latency (I have WIP tracepoints for this but it's still a
> WIP). If you notice shorter stalls with the patch applied, it means that
> kswapd really did need to be informed of the problems.

No, I thought I saw _longer_ stalls with your patch applied...

> There still has not been a mm-change identified that makes fragmentation
> significantly worse.

My bisection shows a very clear point, even if not an individual commit, in 
the 'akpm' merge where SKB errors suddenly become *much* more frequent and 
easy to trigger.
I'm sorry to say this, but the fact that nothing has been identified yet is 
IMO the result of a lack of effort, not because there is no such change.

> The majority of the wireless reports have been in 
> this driver and I think we have the problem commit there. The only other
> is a firmware loading problem in e100 after resume that fails to make an
> atomic order-5 fail.

Not exactly true. Bartlomiej's report was about ipw2200, so there are at 
least 3 different drivers involved, two wireless and one wired. Besides 
that one report is related to heavy swap, one to resume and one to driver 
reload.
So it's much more likely that there is some common regression (in mm) that 
affected all three than that there are three unrelated regressions.
And although both of the others did extremely high allocations, they both 
started appearing in the same timeframe. And Bart's very first report 
linked it to mm changes.

> It's possible that something has changed in resume 
> in the 2.6.31 window there - maybe something like drivers now reload
> during resume where they didn't previously or less memory being pushed
> to swap during resume.

IMO you're sticking your head in the sand here. 
I'm not saying that mm is the only issue here, but I'm convinced that there 
_is_ an mm change that has contributed in a major way to these issues, 
even if we've not yet been able to identify it.

> -			    net_ratelimit())
> +			    net_ratelimit()) {
>  				IWL_CRIT(priv, "Failed to allocate SKB buffer with %s. Only %u free
> buffers remaining.\n", priority == GFP_ATOMIC ?  "GFP_ATOMIC" :
> "GFP_KERNEL",

Haven't you broken the test 'priority == GFP_ATOMIC' here by setting 
priority to GFP_ATOMIC|__GFP_NOWARN?

Cheers,
FJP


--Boundary-00=_z2c1KJnOi9pY+mk
Content-Type: text/x-log;
  charset="iso-8859-15";
  name="kern.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="kern.log"

Oct 12 17:13:07 aragorn kernel: Linux version 2.6.32-rc4 (root@aragorn) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #29 SMP Mon Oct 12 13:12:50 CEST 2009
Oct 12 17:13:07 aragorn kernel: Command line: root=/dev/mapper/main-root ro vga=791 quiet
Oct 12 17:13:07 aragorn kernel: KERNEL supported cpus:
Oct 12 17:13:07 aragorn kernel:   Intel GenuineIntel
Oct 12 17:13:07 aragorn kernel:   AMD AuthenticAMD
Oct 12 17:13:07 aragorn kernel:   Centaur CentaurHauls
Oct 12 17:13:07 aragorn kernel: BIOS-provided physical RAM map:
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 0000000000100000 - 000000007e7b0000 (usable)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 000000007e7b0000 - 000000007e7c5400 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 000000007e7c5400 - 000000007e7e7fb8 (ACPI NVS)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 000000007e7e7fb8 - 000000007f000000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000fed20000 - 00000000fed9a000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000feda0000 - 00000000fedc0000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000ffb00000 - 00000000ffc00000 (reserved)
Oct 12 17:13:07 aragorn kernel:  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
Oct 12 17:13:07 aragorn kernel: DMI 2.4 present.
Oct 12 17:13:07 aragorn kernel: last_pfn = 0x7e7b0 max_arch_pfn = 0x400000000
Oct 12 17:13:07 aragorn kernel: MTRR default type: uncachable
Oct 12 17:13:07 aragorn kernel: MTRR fixed ranges enabled:
Oct 12 17:13:07 aragorn kernel:   00000-9FFFF write-back
Oct 12 17:13:07 aragorn kernel:   A0000-BFFFF uncachable
Oct 12 17:13:07 aragorn kernel:   C0000-D3FFF write-protect
Oct 12 17:13:07 aragorn kernel:   D4000-EFFFF uncachable
Oct 12 17:13:07 aragorn kernel:   F0000-FFFFF write-protect
Oct 12 17:13:07 aragorn kernel: MTRR variable ranges enabled:
Oct 12 17:13:07 aragorn kernel:   0 base 000000000 mask F80000000 write-back
Oct 12 17:13:07 aragorn kernel:   1 base 07F000000 mask FFF000000 uncachable
Oct 12 17:13:07 aragorn kernel:   2 base 07E800000 mask FFF800000 uncachable
Oct 12 17:13:07 aragorn kernel:   3 base 0FEDA0000 mask FFFFE0000 uncachable
Oct 12 17:13:07 aragorn kernel:   4 disabled
Oct 12 17:13:07 aragorn kernel:   5 disabled
Oct 12 17:13:07 aragorn kernel:   6 disabled
Oct 12 17:13:07 aragorn kernel:   7 disabled
Oct 12 17:13:07 aragorn kernel: x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Oct 12 17:13:07 aragorn kernel: initial memory mapped : 0 - 20000000
Oct 12 17:13:07 aragorn kernel: init_memory_mapping: 0000000000000000-000000007e7b0000
Oct 12 17:13:07 aragorn kernel:  0000000000 - 007e600000 page 2M
Oct 12 17:13:07 aragorn kernel:  007e600000 - 007e7b0000 page 4k
Oct 12 17:13:07 aragorn kernel: kernel direct mapping tables up to 7e7b0000 @ 8000-c000
Oct 12 17:13:07 aragorn kernel: RAMDISK: 37a79000 - 37fef2f8
Oct 12 17:13:07 aragorn kernel: ACPI: RSDP 00000000000f7960 00024 (v02 HP    )
Oct 12 17:13:07 aragorn kernel: ACPI: XSDT 000000007e7c81c8 0007C (v01 HPQOEM SLIC-MPC 00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: FACP 000000007e7c8084 000F4 (v04 HP     30C9     00000003 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: DSDT 000000007e7c8538 13484 (v01 HP       nc2500 00010000 MSFT 03000001)
Oct 12 17:13:07 aragorn kernel: ACPI: FACS 000000007e7e7d80 00040
Oct 12 17:13:07 aragorn kernel: ACPI: SLIC 000000007e7c8244 00176 (v01 HPQOEM SLIC-MPC 00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: HPET 000000007e7c83bc 00038 (v01 HP     30C9     00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: APIC 000000007e7c83f4 00068 (v01 HP     30C9     00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: MCFG 000000007e7c845c 0003C (v01 HP     30C9     00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: TCPA 000000007e7c8498 00032 (v02 HP     30C9     00000001 HP   00000001)
Oct 12 17:13:07 aragorn kernel: ACPI: ASF! 000000007e7c84cc 00069 (v16 HP     CHIMAYU  00000001 HP   00000000)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7db9bc 002BE (v01 HP       HPQPAT 00000001 MSFT 03000001)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dc640 0025F (v01 HP      Cpu0Tst 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dc89f 000A6 (v01 HP      Cpu1Tst 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dc945 004D7 (v01 HP        CpuPm 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: Local APIC address 0xfee00000
Oct 12 17:13:07 aragorn kernel: (7 early reservations) ==> bootmem [0000000000 - 007e7b0000]
Oct 12 17:13:07 aragorn kernel:   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
Oct 12 17:13:07 aragorn kernel:   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
Oct 12 17:13:07 aragorn kernel:   #2 [0001000000 - 00015bdb30]    TEXT DATA BSS ==> [0001000000 - 00015bdb30]
Oct 12 17:13:07 aragorn kernel:   #3 [0037a79000 - 0037fef2f8]          RAMDISK ==> [0037a79000 - 0037fef2f8]
Oct 12 17:13:07 aragorn kernel:   #4 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
Oct 12 17:13:07 aragorn kernel:   #5 [00015be000 - 00015be18c]              BRK ==> [00015be000 - 00015be18c]
Oct 12 17:13:07 aragorn kernel:   #6 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
Oct 12 17:13:07 aragorn kernel:  [ffffea0000000000-ffffea0001ffffff] PMD -> [ffff880001a00000-ffff8800039fffff] on node 0
Oct 12 17:13:07 aragorn kernel: Zone PFN ranges:
Oct 12 17:13:07 aragorn kernel:   DMA      0x00000000 -> 0x00001000
Oct 12 17:13:07 aragorn kernel:   DMA32    0x00001000 -> 0x00100000
Oct 12 17:13:07 aragorn kernel:   Normal   0x00100000 -> 0x00100000
Oct 12 17:13:07 aragorn kernel: Movable zone start PFN for each node
Oct 12 17:13:07 aragorn kernel: early_node_map[2] active PFN ranges
Oct 12 17:13:07 aragorn kernel:     0: 0x00000000 -> 0x0000009f
Oct 12 17:13:07 aragorn kernel:     0: 0x00000100 -> 0x0007e7b0
Oct 12 17:13:07 aragorn kernel: On node 0 totalpages: 517967
Oct 12 17:13:07 aragorn kernel:   DMA zone: 64 pages used for memmap
Oct 12 17:13:07 aragorn kernel:   DMA zone: 101 pages reserved
Oct 12 17:13:07 aragorn kernel:   DMA zone: 3834 pages, LIFO batch:0
Oct 12 17:13:07 aragorn kernel:   DMA32 zone: 8031 pages used for memmap
Oct 12 17:13:07 aragorn kernel:   DMA32 zone: 505937 pages, LIFO batch:31
Oct 12 17:13:07 aragorn kernel: ACPI: PM-Timer IO Port: 0x1008
Oct 12 17:13:07 aragorn kernel: ACPI: Local APIC address 0xfee00000
Oct 12 17:13:07 aragorn kernel: ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Oct 12 17:13:07 aragorn kernel: ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Oct 12 17:13:07 aragorn kernel: ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
Oct 12 17:13:07 aragorn kernel: ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
Oct 12 17:13:07 aragorn kernel: ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
Oct 12 17:13:07 aragorn kernel: IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
Oct 12 17:13:07 aragorn kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
Oct 12 17:13:07 aragorn kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Oct 12 17:13:07 aragorn kernel: ACPI: IRQ0 used by override.
Oct 12 17:13:07 aragorn kernel: ACPI: IRQ2 used by override.
Oct 12 17:13:07 aragorn kernel: ACPI: IRQ9 used by override.
Oct 12 17:13:07 aragorn kernel: Using ACPI (MADT) for SMP configuration information
Oct 12 17:13:07 aragorn kernel: ACPI: HPET id: 0x8086a201 base: 0xfed00000
Oct 12 17:13:07 aragorn kernel: SMP: Allowing 2 CPUs, 0 hotplug CPUs
Oct 12 17:13:07 aragorn kernel: nr_irqs_gsi: 24
Oct 12 17:13:07 aragorn kernel: PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
Oct 12 17:13:07 aragorn kernel: PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
Oct 12 17:13:07 aragorn kernel: PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
Oct 12 17:13:07 aragorn kernel: Allocating PCI resources starting at 7f000000 (gap: 7f000000:7fc00000)
Oct 12 17:13:07 aragorn kernel: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
Oct 12 17:13:07 aragorn kernel: PERCPU: Embedded 27 pages/cpu @ffff880001600000 s81752 r8192 d20648 u1048576
Oct 12 17:13:07 aragorn kernel: pcpu-alloc: s81752 r8192 d20648 u1048576 alloc=1*2097152
Oct 12 17:13:07 aragorn kernel: pcpu-alloc: [0] 0 1 
Oct 12 17:13:07 aragorn kernel: Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 509771
Oct 12 17:13:07 aragorn kernel: Kernel command line: root=/dev/mapper/main-root ro vga=791 quiet
Oct 12 17:13:07 aragorn kernel: PID hash table entries: 4096 (order: 3, 32768 bytes)
Oct 12 17:13:07 aragorn kernel: Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Oct 12 17:13:07 aragorn kernel: Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Oct 12 17:13:07 aragorn kernel: Initializing CPU#0
Oct 12 17:13:07 aragorn kernel: Checking aperture...
Oct 12 17:13:07 aragorn kernel: No AGP bridge found
Oct 12 17:13:07 aragorn kernel: Memory: 2023496k/2072256k available (2758k kernel code, 388k absent, 47724k reserved, 1927k data, 508k init)
Oct 12 17:13:07 aragorn kernel: SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Oct 12 17:13:07 aragorn kernel: Hierarchical RCU implementation.
Oct 12 17:13:07 aragorn kernel: NR_IRQS:512
Oct 12 17:13:07 aragorn kernel: Extended CMOS year: 2000
Oct 12 17:13:07 aragorn kernel: Console: colour dummy device 80x25
Oct 12 17:13:07 aragorn kernel: console [tty0] enabled
Oct 12 17:13:07 aragorn kernel: hpet clockevent registered
Oct 12 17:13:07 aragorn kernel: HPET: 3 timers in total, 0 timers will be used for per-cpu timer
Oct 12 17:13:07 aragorn kernel: Fast TSC calibration using PIT
Oct 12 17:13:07 aragorn kernel: Detected 1330.067 MHz processor.
Oct 12 17:13:07 aragorn kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 2660.13 BogoMIPS (lpj=5320268)
Oct 12 17:13:07 aragorn kernel: Security Framework initialized
Oct 12 17:13:07 aragorn kernel: SELinux:  Disabled at boot.
Oct 12 17:13:07 aragorn kernel: Mount-cache hash table entries: 256
Oct 12 17:13:07 aragorn kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Oct 12 17:13:07 aragorn kernel: CPU: L2 cache: 2048K
Oct 12 17:13:07 aragorn kernel: CPU: Physical Processor ID: 0
Oct 12 17:13:07 aragorn kernel: CPU: Processor Core ID: 0
Oct 12 17:13:07 aragorn kernel: mce: CPU supports 6 MCE banks
Oct 12 17:13:07 aragorn kernel: CPU0: Thermal monitoring handled by SMI
Oct 12 17:13:07 aragorn kernel: using mwait in idle threads.
Oct 12 17:13:07 aragorn kernel: Performance Events: Core2 events, Intel PMU driver.
Oct 12 17:13:07 aragorn kernel: ... version:                2
Oct 12 17:13:07 aragorn kernel: ... bit width:              40
Oct 12 17:13:07 aragorn kernel: ... generic registers:      2
Oct 12 17:13:07 aragorn kernel: ... value mask:             000000ffffffffff
Oct 12 17:13:07 aragorn kernel: ... max period:             000000007fffffff
Oct 12 17:13:07 aragorn kernel: ... fixed-purpose events:   3
Oct 12 17:13:07 aragorn kernel: ... event mask:             0000000700000003
Oct 12 17:13:07 aragorn kernel: ACPI: Core revision 20090903
Oct 12 17:13:07 aragorn kernel: ftrace: converting mcount calls to 0f 1f 44 00 00
Oct 12 17:13:07 aragorn kernel: ftrace: allocating 13965 entries in 55 pages
Oct 12 17:13:07 aragorn kernel: Setting APIC routing to flat
Oct 12 17:13:07 aragorn kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Oct 12 17:13:07 aragorn kernel: CPU0: Intel(R) Core(TM)2 Duo CPU     U7700  @ 1.33GHz stepping 0d
Oct 12 17:13:07 aragorn kernel: Booting processor 1 APIC 0x1 ip 0x6000
Oct 12 17:13:07 aragorn kernel: Initializing CPU#1
Oct 12 17:13:07 aragorn kernel: Calibrating delay using timer specific routine.. 2659.98 BogoMIPS (lpj=5319962)
Oct 12 17:13:07 aragorn kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Oct 12 17:13:07 aragorn kernel: CPU: L2 cache: 2048K
Oct 12 17:13:07 aragorn kernel: CPU: Physical Processor ID: 0
Oct 12 17:13:07 aragorn kernel: CPU: Processor Core ID: 1
Oct 12 17:13:07 aragorn kernel: mce: CPU supports 6 MCE banks
Oct 12 17:13:07 aragorn kernel: CPU1: Thermal monitoring enabled (TM2)
Oct 12 17:13:07 aragorn kernel: CPU1: Intel(R) Core(TM)2 Duo CPU     U7700  @ 1.33GHz stepping 0d
Oct 12 17:13:07 aragorn kernel: checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Oct 12 17:13:07 aragorn kernel: Brought up 2 CPUs
Oct 12 17:13:07 aragorn kernel: Total of 2 processors activated (5320.11 BogoMIPS).
Oct 12 17:13:07 aragorn kernel: CPU0 attaching sched-domain:
Oct 12 17:13:07 aragorn kernel:  domain 0: span 0-1 level MC
Oct 12 17:13:07 aragorn kernel:   groups: 0 1
Oct 12 17:13:07 aragorn kernel: CPU1 attaching sched-domain:
Oct 12 17:13:07 aragorn kernel:  domain 0: span 0-1 level MC
Oct 12 17:13:07 aragorn kernel:   groups: 1 0
Oct 12 17:13:07 aragorn kernel: NET: Registered protocol family 16
Oct 12 17:13:07 aragorn kernel: ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
Oct 12 17:13:07 aragorn kernel: ACPI: bus type pci registered
Oct 12 17:13:07 aragorn kernel: PCI: MCFG configuration 0: base f8000000 segment 0 buses 0 - 63
Oct 12 17:13:07 aragorn kernel: PCI: Not using MMCONFIG.
Oct 12 17:13:07 aragorn kernel: PCI: Using configuration type 1 for base access
Oct 12 17:13:07 aragorn kernel: bio: create slab <bio-0> at 0
Oct 12 17:13:07 aragorn kernel: ACPI: EC: Look up EC in DSDT
Oct 12 17:13:07 aragorn kernel: ACPI: Interpreter enabled
Oct 12 17:13:07 aragorn kernel: ACPI: (supports S0 S3 S4 S5)
Oct 12 17:13:07 aragorn kernel: ACPI: Using IOAPIC for interrupt routing
Oct 12 17:13:07 aragorn kernel: PCI: MCFG configuration 0: base f8000000 segment 0 buses 0 - 63
Oct 12 17:13:07 aragorn kernel: PCI: MCFG area at f8000000 reserved in ACPI motherboard resources
Oct 12 17:13:07 aragorn kernel: PCI: Using MMCONFIG at f8000000 - fbffffff
Oct 12 17:13:07 aragorn kernel: ACPI: EC: GPE = 0x16, I/O: command/status = 0x66, data = 0x62
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C29F] (on)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C1C7] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3AD] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3B0] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3C3] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3C4] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3C5] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3C6] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: Power Resource [C3C7] (off)
Oct 12 17:13:07 aragorn kernel: ACPI: No dock devices found.
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Root Bridge [C003] (0000:00)
Oct 12 17:13:07 aragorn kernel: pci 0000:00:02.0: reg 10 64bit mmio: [0xe0400000-0xe04fffff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:02.0: reg 18 64bit mmio pref: [0xd0000000-0xdfffffff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:02.0: reg 20 io port: [0x2000-0x2007]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:02.1: reg 10 64bit mmio: [0xe0500000-0xe05fffff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.0: reg 10 64bit mmio: [0xe0600000-0xe060000f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.2: reg 10 io port: [0x2008-0x200f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.2: reg 14 io port: [0x2010-0x2013]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.2: reg 18 io port: [0x2018-0x201f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.2: reg 1c io port: [0x2020-0x2023]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.2: reg 20 io port: [0x2030-0x203f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.3: reg 10 io port: [0x2040-0x2047]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:03.3: reg 14 32bit mmio: [0xe0601000-0xe0601fff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:19.0: reg 10 32bit mmio: [0xe0620000-0xe063ffff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:19.0: reg 14 32bit mmio: [0xe0640000-0xe0640fff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:19.0: reg 18 io port: [0x2060-0x207f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:19.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1a.0: reg 20 io port: [0x2080-0x209f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1a.1: reg 20 io port: [0x20a0-0x20bf]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1a.7: reg 10 32bit mmio: [0xe0641000-0xe06413ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1a.7: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1b.0: reg 10 64bit mmio: [0xe0644000-0xe0647fff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1b.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.0: reg 20 io port: [0x20c0-0x20df]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.1: reg 20 io port: [0x20e0-0x20ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.2: reg 20 io port: [0x2100-0x211f]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.7: reg 10 32bit mmio: [0xe0648000-0xe06483ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1d.7: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.0: quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.0: quirk: region 1100-113f claimed by ICH6 GPIO
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0500 (mask 007f)
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 02e8 (mask 0007)
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1f.1: reg 20 io port: [0x2120-0x212f]
Oct 12 17:13:07 aragorn kernel: pci 0000:10:00.0: reg 10 64bit mmio: [0xe0000000-0xe0001fff]
Oct 12 17:13:07 aragorn kernel: pci 0000:10:00.0: PME# supported from D0 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:10:00.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: bridge 32bit mmio: [0xe0000000-0xe00fffff]
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: reg 10 32bit mmio: [0xe0100000-0xe0100fff]
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: supports D1 D2
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: PME# supported from D0 D1 D2 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.1: reg 10 32bit mmio: [0xe0101000-0xe01017ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.1: supports D1 D2
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.1: PME# supported from D0 D1 D2 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.1: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.2: reg 10 32bit mmio: [0xe0102000-0xe01020ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.2: supports D1 D2
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.2: PME# supported from D0 D1 D2 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.2: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.3: reg 10 32bit mmio: [0xe0103000-0xe01030ff]
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.3: supports D1 D2
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.3: PME# supported from D0 D1 D2 D3hot D3cold
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.3: PME# disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0: transparent bridge
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0: bridge 32bit mmio: [0xe0100000-0xe03fffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:00: on NUMA node 0
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Routing Table [\_SB_.C003._PRT]
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Routing Table [\_SB_.C003.C0B2._PRT]
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Routing Table [\_SB_.C003.C11F._PRT]
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Routing Table [\_SB_.C003.C133._PRT]
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C12F] (IRQs *10 11)
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C130] (IRQs *10 11)
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C131] (IRQs 10 *11)
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C132] (IRQs 10 11) *5
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C142] (IRQs *10 11)
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C143] (IRQs 10 11) *0, disabled.
Oct 12 17:13:07 aragorn kernel: ACPI: PCI Interrupt Link [C144] (IRQs 10 *11)
Oct 12 17:13:07 aragorn kernel: ACPI Exception: AE_NOT_FOUND, Evaluating _PRS (20090903/pci_link-184)
Oct 12 17:13:07 aragorn kernel: vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
Oct 12 17:13:07 aragorn kernel: vgaarb: loaded
Oct 12 17:13:07 aragorn kernel: usbcore: registered new interface driver usbfs
Oct 12 17:13:07 aragorn kernel: usbcore: registered new interface driver hub
Oct 12 17:13:07 aragorn kernel: usbcore: registered new device driver usb
Oct 12 17:13:07 aragorn kernel: PCI: Using ACPI for IRQ routing
Oct 12 17:13:07 aragorn kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
Oct 12 17:13:07 aragorn kernel: hpet0: 3 comparators, 64-bit 14.318180 MHz counter
Oct 12 17:13:07 aragorn kernel: Switching to clocksource tsc
Oct 12 17:13:07 aragorn kernel: pnp: PnP ACPI init
Oct 12 17:13:07 aragorn kernel: ACPI: bus type pnp registered
Oct 12 17:13:07 aragorn kernel: pnp: PnP ACPI: found 14 devices
Oct 12 17:13:07 aragorn kernel: ACPI: ACPI bus type pnp unregistered
Oct 12 17:13:07 aragorn kernel: system 00:00: iomem range 0x0-0x9ffff could not be reserved
Oct 12 17:13:07 aragorn kernel: (The fact that a range could not be reserved is generally harmless.)
Oct 12 17:13:07 aragorn kernel: system 00:00: iomem range 0xe0000-0xfffff could not be reserved
Oct 12 17:13:07 aragorn kernel: system 00:00: iomem range 0x100000-0x7e7fffff could not be reserved
Oct 12 17:13:07 aragorn kernel: system 00:0a: ioport range 0x500-0x55f has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0a: ioport range 0x800-0x80f has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0a: iomem range 0xffb00000-0xffbfffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0a: iomem range 0xfff00000-0xffffffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x4d0-0x4d1 has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x2f8-0x2ff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x3f8-0x3ff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x1000-0x107f has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x1100-0x113f has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: ioport range 0x1200-0x121f has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: iomem range 0xf8000000-0xfbffffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: iomem range 0xfec00000-0xfec000ff could not be reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: iomem range 0xfed20000-0xfed3ffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: iomem range 0xfed45000-0xfed8ffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0c: iomem range 0xfed90000-0xfed99fff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0d: iomem range 0xcee00-0xcffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0d: iomem range 0xd2000-0xd3fff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0d: iomem range 0xfeda0000-0xfedbffff has been reserved
Oct 12 17:13:07 aragorn kernel: system 00:0d: iomem range 0xfee00000-0xfee00fff has been reserved
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0: PCI bridge, secondary bus 0000:08
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0:   IO window: disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0:   MEM window: disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0:   PREFETCH window: disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: PCI bridge, secondary bus 0000:10
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1:   IO window: disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1:   MEM window: 0xe0000000-0xe00fffff
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1:   PREFETCH window: disabled
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: CardBus bridge, secondary bus 0000:03
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0:   IO window: 0x003000-0x0030ff
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0:   IO window: 0x003400-0x0034ff
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0:   PREFETCH window: 0x80000000-0x83ffffff
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0:   MEM window: 0x84000000-0x87ffffff
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0: PCI bridge, secondary bus 0000:02
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0:   IO window: 0x3000-0x3fff
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0:   MEM window: 0xe0100000-0xe03fffff
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0:   PREFETCH window: 0x80000000-0x83ffffff
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1c.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pci 0000:00:1e.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pci 0000:02:06.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:10: resource 1 mem: [0xe0000000-0xe00fffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: resource 0 io:  [0x3000-0x3fff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: resource 1 mem: [0xe0100000-0xe03fffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: resource 2 pref mem [0x80000000-0x83ffffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: resource 3 io:  [0x00-0xffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: resource 4 mem: [0x000000-0xffffffffffffffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:03: resource 0 io:  [0x3000-0x30ff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:03: resource 1 io:  [0x3400-0x34ff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:03: resource 2 pref mem [0x80000000-0x83ffffff]
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:03: resource 3 mem: [0x84000000-0x87ffffff]
Oct 12 17:13:07 aragorn kernel: NET: Registered protocol family 2
Oct 12 17:13:07 aragorn kernel: IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
Oct 12 17:13:07 aragorn kernel: TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
Oct 12 17:13:07 aragorn kernel: TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
Oct 12 17:13:07 aragorn kernel: TCP: Hash tables configured (established 262144 bind 65536)
Oct 12 17:13:07 aragorn kernel: TCP reno registered
Oct 12 17:13:07 aragorn kernel: NET: Registered protocol family 1
Oct 12 17:13:07 aragorn kernel: Trying to unpack rootfs image as initramfs...
Oct 12 17:13:07 aragorn kernel: Freeing initrd memory: 5592k freed
Oct 12 17:13:07 aragorn kernel: audit: initializing netlink socket (disabled)
Oct 12 17:13:07 aragorn kernel: type=2000 audit(1255360345.659:1): initialized
Oct 12 17:13:07 aragorn kernel: VFS: Disk quotas dquot_6.5.2
Oct 12 17:13:07 aragorn kernel: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Oct 12 17:13:07 aragorn kernel: msgmni has been set to 3964
Oct 12 17:13:07 aragorn kernel: alg: No test for stdrng (krng)
Oct 12 17:13:07 aragorn kernel: io scheduler noop registered
Oct 12 17:13:07 aragorn kernel: io scheduler anticipatory registered
Oct 12 17:13:07 aragorn kernel: io scheduler deadline registered
Oct 12 17:13:07 aragorn kernel: io scheduler cfq registered (default)
Oct 12 17:13:07 aragorn kernel: pci 0000:00:02.0: Boot video device
Oct 12 17:13:07 aragorn kernel: pcieport-driver 0000:00:1c.0: irq 24 for MSI/MSI-X
Oct 12 17:13:07 aragorn kernel: pcieport-driver 0000:00:1c.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pcieport-driver 0000:00:1c.1: irq 25 for MSI/MSI-X
Oct 12 17:13:07 aragorn kernel: pcieport-driver 0000:00:1c.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: vesafb: framebuffer at 0xd0000000, mapped to 0xffffc90004100000, using 3072k, total 7616k
Oct 12 17:13:07 aragorn kernel: vesafb: mode is 1024x768x16, linelength=2048, pages=3
Oct 12 17:13:07 aragorn kernel: vesafb: scrolling: redraw
Oct 12 17:13:07 aragorn kernel: vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Oct 12 17:13:07 aragorn kernel: Console: switching to colour frame buffer device 128x48
Oct 12 17:13:07 aragorn kernel: fb0: VESA VGA frame buffer device
Oct 12 17:13:07 aragorn kernel: Linux agpgart interface v0.103
Oct 12 17:13:07 aragorn kernel: Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
Oct 12 17:13:07 aragorn kernel: serial 0000:00:03.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
Oct 12 17:13:07 aragorn kernel: 0000:00:03.3: ttyS0 at I/O 0x2040 (irq = 17) is a 16550A
Oct 12 17:13:07 aragorn kernel: brd: module loaded
Oct 12 17:13:07 aragorn kernel: PNP: PS/2 Controller [PNP0303:C29C,PNP0f13:C29D] at 0x60,0x64 irq 1,12
Oct 12 17:13:07 aragorn kernel: i8042.c: Detected active multiplexing controller, rev 1.1.
Oct 12 17:13:07 aragorn kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
Oct 12 17:13:07 aragorn kernel: serio: i8042 AUX0 port at 0x60,0x64 irq 12
Oct 12 17:13:07 aragorn kernel: serio: i8042 AUX1 port at 0x60,0x64 irq 12
Oct 12 17:13:07 aragorn kernel: serio: i8042 AUX2 port at 0x60,0x64 irq 12
Oct 12 17:13:07 aragorn kernel: serio: i8042 AUX3 port at 0x60,0x64 irq 12
Oct 12 17:13:07 aragorn kernel: mice: PS/2 mouse device common for all mice
Oct 12 17:13:07 aragorn kernel: Driver 'rtc_cmos' needs updating - please use bus_type methods
Oct 12 17:13:07 aragorn kernel: rtc_cmos 00:06: RTC can wake from S4
Oct 12 17:13:07 aragorn kernel: rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
Oct 12 17:13:07 aragorn kernel: rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
Oct 12 17:13:07 aragorn kernel: cpuidle: using governor ladder
Oct 12 17:13:07 aragorn kernel: cpuidle: using governor menu
Oct 12 17:13:07 aragorn kernel: TCP cubic registered
Oct 12 17:13:07 aragorn kernel: NET: Registered protocol family 17
Oct 12 17:13:07 aragorn kernel: registered taskstats version 1
Oct 12 17:13:07 aragorn kernel: rtc_cmos 00:06: setting system clock to 2009-10-12 15:12:26 UTC (1255360346)
Oct 12 17:13:07 aragorn kernel: Freeing unused kernel memory: 508k freed
Oct 12 17:13:07 aragorn kernel: input: AT Translated Set 2 keyboard as /class/input/input0
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:00: registered as cooling_device0
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3B1] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:01: registered as cooling_device1
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3B2] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:02: registered as cooling_device2
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3C8] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:03: registered as cooling_device3
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3C9] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:04: registered as cooling_device4
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3CA] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:05: registered as cooling_device5
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3CB] (off)
Oct 12 17:13:07 aragorn kernel: fan PNP0C0B:06: registered as cooling_device6
Oct 12 17:13:07 aragorn kernel: ACPI: Fan [C3CC] (off)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:01: registered as thermal_zone0
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ6] (25 C)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:02: registered as thermal_zone1
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ0] (55 C)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:03: registered as thermal_zone2
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ1] (57 C)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:04: registered as thermal_zone3
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ3] (45 C)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:05: registered as thermal_zone4
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ4] (33 C)
Oct 12 17:13:07 aragorn kernel: thermal LNXTHERM:06: registered as thermal_zone5
Oct 12 17:13:07 aragorn kernel: ACPI: Thermal Zone [TZ5] (49 C)
Oct 12 17:13:07 aragorn kernel: e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
Oct 12 17:13:07 aragorn kernel: e1000e: Copyright (c) 1999-2008 Intel Corporation.
Oct 12 17:13:07 aragorn kernel: e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
Oct 12 17:13:07 aragorn kernel: e1000e 0000:00:19.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
Oct 12 17:13:07 aragorn kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Oct 12 17:13:07 aragorn kernel: SCSI subsystem initialized
Oct 12 17:13:07 aragorn kernel: libata version 3.00 loaded.
Oct 12 17:13:07 aragorn kernel: ricoh-mmc: Ricoh MMC Controller disabling driver
Oct 12 17:13:07 aragorn kernel: ricoh-mmc: Copyright(c) Philip Langdale
Oct 12 17:13:07 aragorn kernel: ricoh-mmc: Ricoh MMC controller found at 0000:02:06.3 [1180:0843] (rev 11)
Oct 12 17:13:07 aragorn kernel: ricoh-mmc: Controller is now disabled.
Oct 12 17:13:07 aragorn kernel: ohci1394 0000:02:06.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
Oct 12 17:13:07 aragorn kernel: sdhci: Secure Digital Host Controller Interface driver
Oct 12 17:13:07 aragorn kernel: sdhci: Copyright(c) Pierre Ossman
Oct 12 17:13:07 aragorn kernel: ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[19]  MMIO=[e0101000-e01017ff]  Max Packet=[2048]  IR/IT contexts=[4/4]
Oct 12 17:13:07 aragorn kernel: sdhci-pci 0000:02:06.2: SDHCI controller found [1180:0822] (rev 21)
Oct 12 17:13:07 aragorn kernel: sdhci-pci 0000:02:06.2: PCI INT C -> GSI 20 (level, low) -> IRQ 20
Oct 12 17:13:07 aragorn kernel: Registered led device: mmc0::
Oct 12 17:13:07 aragorn kernel: mmc0: SDHCI controller on PCI [0000:02:06.2] using PIO
Oct 12 17:13:07 aragorn kernel: 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:1e:68:5e:3b:04
Oct 12 17:13:07 aragorn kernel: 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
Oct 12 17:13:07 aragorn kernel: 0000:00:19.0: eth0: MAC: 6, PHY: 6, PBA No: ffffff-0ff
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: EHCI Host Controller
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: debug port 1
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: irq 18, io mem 0xe0641000
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
Oct 12 17:13:07 aragorn kernel: usb usb1: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 1-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 1-0:1.0: 4 ports detected
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 20 (level, low) -> IRQ 20
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: EHCI Host Controller
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: debug port 1
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: irq 20, io mem 0xe0648000
Oct 12 17:13:07 aragorn kernel: ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
Oct 12 17:13:07 aragorn kernel: usb usb2: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 2-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 2-0:1.0: 6 ports detected
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:03.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:03.2: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:03.2: PCI INT C disabled
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:1f.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:1f.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: pata_acpi 0000:00:1f.1: PCI INT A disabled
Oct 12 17:13:07 aragorn kernel: ata_piix 0000:00:1f.1: version 2.13
Oct 12 17:13:07 aragorn kernel: ata_piix 0000:00:1f.1: quirky BIOS, skipping spindown on poweroff and hibernation
Oct 12 17:13:07 aragorn kernel: ata_piix 0000:00:1f.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Oct 12 17:13:07 aragorn kernel: ata_piix 0000:00:1f.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd: USB Universal Host Controller Interface driver
Oct 12 17:13:07 aragorn kernel: Uniform Multi-Platform E-IDE driver
Oct 12 17:13:07 aragorn kernel: scsi0 : ata_piix
Oct 12 17:13:07 aragorn kernel: scsi1 : ata_piix
Oct 12 17:13:07 aragorn kernel: ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x2120 irq 14
Oct 12 17:13:07 aragorn kernel: ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x2128 irq 15
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.0: UHCI Host Controller
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.0: irq 16, io base 0x00002080
Oct 12 17:13:07 aragorn kernel: usb usb3: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 3-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 3-0:1.0: 2 ports detected
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.1: UHCI Host Controller
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1a.1: irq 17, io base 0x000020a0
Oct 12 17:13:07 aragorn kernel: usb usb4: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 4-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 4-0:1.0: 2 ports detected
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.0: UHCI Host Controller
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.0: irq 20, io base 0x000020c0
Oct 12 17:13:07 aragorn kernel: usb usb5: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 5-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 5-0:1.0: 2 ports detected
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 22 (level, low) -> IRQ 22
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.1: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.1: UHCI Host Controller
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.1: irq 22, io base 0x000020e0
Oct 12 17:13:07 aragorn kernel: usb usb6: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 6-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 6-0:1.0: 2 ports detected
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.2: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.2: UHCI Host Controller
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
Oct 12 17:13:07 aragorn kernel: uhci_hcd 0000:00:1d.2: irq 18, io base 0x00002100
Oct 12 17:13:07 aragorn kernel: usb usb7: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 7-0:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 7-0:1.0: 2 ports detected
Oct 12 17:13:07 aragorn kernel: ata2: port disabled. ignoring.
Oct 12 17:13:07 aragorn kernel: ata1.00: ATA-7: SAMSUNG HS122JC, GQ100-04, max UDMA/100
Oct 12 17:13:07 aragorn kernel: ata1.00: 234441648 sectors, multi 16: LBA 
Oct 12 17:13:07 aragorn kernel: ata1.01: ATAPI: MATSHITADVD-RAM UJ-852S, 1.02, max MWDMA2
Oct 12 17:13:07 aragorn kernel: ata1.00: configured for UDMA/100
Oct 12 17:13:07 aragorn kernel: ata1.01: configured for MWDMA2
Oct 12 17:13:07 aragorn kernel: scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HS122JC  GQ10 PQ: 0 ANSI: 5
Oct 12 17:13:07 aragorn kernel: scsi 0:0:1:0: CD-ROM            MATSHITA DVD-RAM UJ-852S  1.02 PQ: 0 ANSI: 5
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: [sda] Write Protect is off
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Oct 12 17:13:07 aragorn kernel:  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: [sda] Attached SCSI disk
Oct 12 17:13:07 aragorn kernel: sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
Oct 12 17:13:07 aragorn kernel: Uniform CD-ROM driver Revision: 3.20
Oct 12 17:13:07 aragorn kernel: sr 0:0:1:0: Attached scsi CD-ROM sr0
Oct 12 17:13:07 aragorn kernel: sd 0:0:0:0: Attached scsi generic sg0 type 0
Oct 12 17:13:07 aragorn kernel: sr 0:0:1:0: Attached scsi generic sg1 type 5
Oct 12 17:13:07 aragorn kernel: usb 1-2: new high speed USB device using ehci_hcd and address 3
Oct 12 17:13:07 aragorn kernel: usb 1-2: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: hub 1-2:1.0: USB hub found
Oct 12 17:13:07 aragorn kernel: hub 1-2:1.0: 4 ports detected
Oct 12 17:13:07 aragorn kernel: usb 3-1: new full speed USB device using uhci_hcd and address 2
Oct 12 17:13:07 aragorn kernel: device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
Oct 12 17:13:07 aragorn kernel: usb 3-1: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: ieee1394: Host added: ID:BUS[0-00:1023]  GUID[001b249929192210]
Oct 12 17:13:07 aragorn kernel: usb 5-2: new full speed USB device using uhci_hcd and address 2
Oct 12 17:13:07 aragorn kernel: usb 5-2: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: usb 1-2.2: new full speed USB device using ehci_hcd and address 4
Oct 12 17:13:07 aragorn kernel: usb 1-2.2: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: usb 1-2.3: new low speed USB device using ehci_hcd and address 5
Oct 12 17:13:07 aragorn kernel: usb 1-2.3: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: usbcore: registered new interface driver hiddev
Oct 12 17:13:07 aragorn kernel: input: Logitech USB Receiver as /class/input/input1
Oct 12 17:13:07 aragorn kernel: generic-usb 0003:046D:C50D.0001: input: USB HID v1.10 Mouse [Logitech USB Receiver] on usb-0000:00:1a.7-2.3/input0
Oct 12 17:13:07 aragorn kernel: usbcore: registered new interface driver usbhid
Oct 12 17:13:07 aragorn kernel: usbhid: v2.6:USB HID core driver
Oct 12 17:13:07 aragorn kernel: usb 1-2.4: new low speed USB device using ehci_hcd and address 6
Oct 12 17:13:07 aragorn kernel: usb 1-2.4: configuration #1 chosen from 1 choice
Oct 12 17:13:07 aragorn kernel: input: USB Compliant Keyboard as /class/input/input2
Oct 12 17:13:07 aragorn kernel: generic-usb 0003:05A4:9841.0002: input: USB HID v1.10 Keyboard [USB Compliant Keyboard] on usb-0000:00:1a.7-2.4/input0
Oct 12 17:13:07 aragorn kernel: input: USB Compliant Keyboard as /class/input/input3
Oct 12 17:13:07 aragorn kernel: generic-usb 0003:05A4:9841.0003: input: USB HID v1.10 Device [USB Compliant Keyboard] on usb-0000:00:1a.7-2.4/input1
Oct 12 17:13:07 aragorn kernel: PM: Starting manual resume from disk
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: udevd version 125 started
Oct 12 17:13:07 aragorn kernel: input: Sleep Button as /class/input/input4
Oct 12 17:13:07 aragorn kernel: ACPI: Sleep Button [C2BF]
Oct 12 17:13:07 aragorn kernel: input: Lid Switch as /class/input/input5
Oct 12 17:13:07 aragorn kernel: ACPI: Lid Switch [C155]
Oct 12 17:13:07 aragorn kernel: input: Power Button as /class/input/input6
Oct 12 17:13:07 aragorn kernel: ACPI: Power Button [PWRF]
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dbd42 0027F (v01 HP      Cpu0Ist 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dc046 005FA (v01 HP      Cpu0Cst 00003001 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: AC Adapter [C23B] (on-line)
Oct 12 17:13:07 aragorn kernel: ACPI: WMI: Mapper loaded
Oct 12 17:13:07 aragorn kernel: Monitor-Mwait will be used to enter C-1 state
Oct 12 17:13:07 aragorn kernel: Monitor-Mwait will be used to enter C-2 state
Oct 12 17:13:07 aragorn kernel: Marking TSC unstable due to TSC halts in idle
Oct 12 17:13:07 aragorn kernel: processor LNXCPU:00: registered as cooling_device7
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dbc7a 000C8 (v01 HP      Cpu1Ist 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: ACPI: SSDT 000000007e7dbfc1 00085 (v01 HP      Cpu1Cst 00003000 INTL 20060317)
Oct 12 17:13:07 aragorn kernel: Switching to clocksource hpet
Oct 12 17:13:07 aragorn kernel: agpgart-intel 0000:00:00.0: Intel 965GM Chipset
Oct 12 17:13:07 aragorn kernel: agpgart-intel 0000:00:00.0: detected 7676K stolen memory
Oct 12 17:13:07 aragorn kernel: agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
Oct 12 17:13:07 aragorn kernel: processor LNXCPU:01: registered as cooling_device8
Oct 12 17:13:07 aragorn kernel: ACPI: Battery Slot [C23D] (battery present)
Oct 12 17:13:07 aragorn kernel: lis3lv02d: hardware type NC2510 found
Oct 12 17:13:07 aragorn kernel: lis3lv02d: 2-byte sensor found
Oct 12 17:13:07 aragorn kernel: input: ST LIS3LV02DL Accelerometer as /class/input/input7
Oct 12 17:13:07 aragorn kernel: Registered led device: hp::hddprotect
Oct 12 17:13:07 aragorn kernel: input: PC Speaker as /class/input/input8
Oct 12 17:13:07 aragorn kernel: cfg80211: Using static regulatory domain info
Oct 12 17:13:07 aragorn kernel: cfg80211: Regulatory domain: EU
Oct 12 17:13:07 aragorn kernel: ^I(start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
Oct 12 17:13:07 aragorn kernel: ^I(2402000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
Oct 12 17:13:07 aragorn kernel: ^I(5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
Oct 12 17:13:07 aragorn kernel: ^I(5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
Oct 12 17:13:07 aragorn kernel: ^I(5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
Oct 12 17:13:07 aragorn kernel: ^I(5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
Oct 12 17:13:07 aragorn kernel: ^I(5490000 KHz - 5710000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
Oct 12 17:13:07 aragorn kernel: cfg80211: Calling CRDA for country: EU
Oct 12 17:13:07 aragorn kernel: cfg80211: Calling CRDA for country: EU
Oct 12 17:13:07 aragorn kernel: input: PS/2 Generic Mouse as /class/input/input9
Oct 12 17:13:07 aragorn kernel: usblp0: USB Bidirectional printer dev 4 if 0 alt 1 proto 2 vid 0x03F0 pid 0x3102
Oct 12 17:13:07 aragorn kernel: usbcore: registered new interface driver usblp
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: CardBus bridge found [103c:30c9]
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: ISA IRQ mask 0x0cb8, PCI irq 18
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: Socket status: 30000006
Oct 12 17:13:07 aragorn kernel: pci_bus 0000:02: Raising subordinate bus# of parent bus (#02) from #03 to #06
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge I/O window: 0x3000 - 0x3fff
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge Memory window: 0xe0100000 - 0xe03fffff
Oct 12 17:13:07 aragorn kernel: yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge Memory window: 0x80000000 - 0x83ffffff
Oct 12 17:13:07 aragorn kernel: Synaptics Touchpad, model: 1, fw: 6.3, id: 0x1a0b1, caps: 0xa04711/0xa00000
Oct 12 17:13:07 aragorn kernel: input: SynPS/2 Synaptics TouchPad as /class/input/input10
Oct 12 17:13:07 aragorn kernel: iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27kd
Oct 12 17:13:07 aragorn kernel: iwlagn: Copyright(c) 2003-2009 Intel Corporation
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: Detected Intel Wireless WiFi Link 4965AGN REV=0x4
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: Tunable channels: 11 802.11bg, 13 802.11a channels
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: irq 27 for MSI/MSI-X
Oct 12 17:13:07 aragorn kernel: phy0: Selected rate control algorithm 'iwl-agn-rs'
Oct 12 17:13:07 aragorn kernel: HDA Intel 0000:00:1b.0: power state changed by ACPI to D0
Oct 12 17:13:07 aragorn kernel: HDA Intel 0000:00:1b.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Oct 12 17:13:07 aragorn kernel: HDA Intel 0000:00:1b.0: setting latency timer to 64
Oct 12 17:13:07 aragorn kernel: input: HDA Digital PCBeep as /class/input/input11
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-1, internal journal
Oct 12 17:13:07 aragorn kernel: loop: module loaded
Oct 12 17:13:07 aragorn kernel: input: HP WMI hotkeys as /class/input/input12
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-5, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-2, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-3, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-4, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-6, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-9, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-12, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-8, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: kjournald starting.  Commit interval 5 seconds
Oct 12 17:13:07 aragorn kernel: EXT3 FS on dm-10, internal journal
Oct 12 17:13:07 aragorn kernel: EXT3-fs: mounted filesystem with ordered data mode.
Oct 12 17:13:07 aragorn kernel: Adding 2097144k swap on /dev/mapper/main-swap.  Priority:-1 extents:1 across:2097144k 
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: firmware: requesting iwlwifi-4965-2.ucode
Oct 12 17:13:07 aragorn kernel: iwlagn 0000:10:00.0: loaded firmware version 228.57.2.23
Oct 12 17:13:07 aragorn kernel: Registered led device: iwl-phy0::radio
Oct 12 17:13:07 aragorn kernel: Registered led device: iwl-phy0::assoc
Oct 12 17:13:07 aragorn kernel: Registered led device: iwl-phy0::RX
Oct 12 17:13:07 aragorn kernel: Registered led device: iwl-phy0::TX
Oct 12 17:13:07 aragorn kernel: wlan0: deauthenticating from 00:14:c1:38:e5:15 by local choice (reason=3)
Oct 12 17:13:07 aragorn kernel: wlan0: direct probe to AP 00:14:c1:38:e5:15 (try 1)
Oct 12 17:13:07 aragorn kernel: wlan0: direct probe responded
Oct 12 17:13:07 aragorn kernel: wlan0: authenticate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 17:13:07 aragorn kernel: wlan0: authenticated
Oct 12 17:13:07 aragorn kernel: wlan0: associate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 17:13:07 aragorn kernel: wlan0: RX AssocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=1)
Oct 12 17:13:07 aragorn kernel: wlan0: associated
Oct 12 17:13:07 aragorn kernel: RPC: Registered udp transport module.
Oct 12 17:13:07 aragorn kernel: RPC: Registered tcp transport module.
Oct 12 17:13:07 aragorn kernel: RPC: Registered tcp NFSv4.1 backchannel transport module.
Oct 12 17:13:07 aragorn kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
Oct 12 17:13:07 aragorn kernel: NET: Registered protocol family 10
Oct 12 17:13:07 aragorn kernel: lo: Disabled Privacy Extensions
Oct 12 17:13:09 aragorn kernel: lp: driver loaded but no devices found
Oct 12 17:13:09 aragorn kernel: ppdev: user-space parallel port driver
Oct 12 17:13:15 aragorn kernel: wlan0: no IPv6 routers present
Oct 12 17:13:20 aragorn kernel: [drm] Initialized drm 1.1.0 20060810
Oct 12 17:13:20 aragorn kernel: pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Oct 12 17:13:20 aragorn kernel: pci 0000:00:02.0: setting latency timer to 64
Oct 12 17:13:20 aragorn kernel: pci 0000:00:02.0: irq 28 for MSI/MSI-X
Oct 12 17:13:20 aragorn kernel: acpi device:00: registered as cooling_device9
Oct 12 17:13:20 aragorn kernel: input: Video Bus as /class/input/input13
Oct 12 17:13:20 aragorn kernel: ACPI: Video Device [C09A] (multi-head: yes  rom: no  post: no)
Oct 12 17:13:20 aragorn kernel: [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
Oct 12 17:16:11 aragorn kernel: sr0: CDROM not ready.  Make sure there is a disc in the drive.
Oct 12 17:16:11 aragorn kernel: sr0: CDROM not ready.  Make sure there is a disc in the drive.
Oct 12 17:55:15 aragorn kernel: sr0: CDROM not ready.  Make sure there is a disc in the drive.
Oct 12 17:55:15 aragorn kernel: sr0: CDROM not ready.  Make sure there is a disc in the drive.
Oct 12 18:10:35 aragorn kernel: e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
Oct 12 18:10:35 aragorn kernel: e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
Oct 12 18:10:35 aragorn kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Oct 12 18:10:37 aragorn kernel: e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
Oct 12 18:10:37 aragorn kernel: 0000:00:19.0: eth0: 10/100 speed: disabling TSO
Oct 12 18:10:37 aragorn kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Oct 12 18:10:39 aragorn kernel: wlan0: deauthenticating from 00:14:c1:38:e5:15 by local choice (reason=3)
Oct 12 18:10:48 aragorn kernel: eth0: no IPv6 routers present
Oct 12 20:13:29 aragorn kernel: Registered led device: iwl-phy0::radio
Oct 12 20:13:29 aragorn kernel: Registered led device: iwl-phy0::assoc
Oct 12 20:13:29 aragorn kernel: Registered led device: iwl-phy0::RX
Oct 12 20:13:29 aragorn kernel: Registered led device: iwl-phy0::TX
Oct 12 20:13:29 aragorn kernel: ADDRCONF(NETDEV_UP): wlan0: link is not ready
Oct 12 20:13:29 aragorn kernel: wlan0: direct probe to AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:29 aragorn kernel: wlan0: direct probe responded
Oct 12 20:13:29 aragorn kernel: wlan0: authenticate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:29 aragorn kernel: wlan0: authenticated
Oct 12 20:13:29 aragorn kernel: wlan0: associate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:29 aragorn kernel: wlan0: RX ReassocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=0)
Oct 12 20:13:29 aragorn kernel: wlan0: invalid aid value 0; bits 15:14 not set
Oct 12 20:13:29 aragorn kernel: wlan0: associated
Oct 12 20:13:29 aragorn kernel: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
Oct 12 20:13:30 aragorn kernel: wlan0: deauthenticating from 00:14:c1:38:e5:15 by local choice (reason=3)
Oct 12 20:13:31 aragorn kernel: wlan0: deauthenticating from 00:14:c1:38:e5:15 by local choice (reason=3)
Oct 12 20:13:31 aragorn kernel: wlan0: direct probe to AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:31 aragorn kernel: wlan0: direct probe responded
Oct 12 20:13:31 aragorn kernel: wlan0: authenticate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:31 aragorn kernel: wlan0: authenticated
Oct 12 20:13:31 aragorn kernel: wlan0: associate with AP 00:14:c1:38:e5:15 (try 1)
Oct 12 20:13:31 aragorn kernel: wlan0: RX ReassocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=1)
Oct 12 20:13:31 aragorn kernel: wlan0: associated
Oct 12 20:13:40 aragorn kernel: wlan0: no IPv6 routers present
Oct 12 20:15:06 aragorn kernel: swapper: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 0, comm: swapper Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7243>] iwl_rx_handle+0x3ad/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8125732b>] ? ip_rcv+0x2b8/0x2ef
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0362b95>] ? __iwl_read32+0xaa/0xb9 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02b1fc9>] ? acpi_idle_enter_simple+0xfe/0x12c [processor]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa02b1fbf>] ? acpi_idle_enter_simple+0xf4/0x12c [processor]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81220131>] ? cpuidle_idle_call+0x98/0xf3
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100aed0>] ? cpu_idle+0x5a/0x92
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812aa175>] ? start_secondary+0x17a/0x17f
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 187
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 159
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102886 isolated_anon:32
Oct 12 20:15:07 aragorn kernel:  active_file:10730 inactive_file:10749 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:35291 unstable:0 buffer:50
Oct 12 20:15:07 aragorn kernel:  free:3047 slab_reclaimable:3967 slab_unreclaimable:11608
Oct 12 20:15:07 aragorn kernel:  mapped:21571 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4260kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407564kB active_file:42904kB inactive_file:42868kB unevictable:1600kB isolated(anon):128kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:141164kB mapped:86256kB shmem:76kB slab_reclaimable:15864kB slab_unreclaimable:46424kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 549*4kB 196*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4340kB
Oct 12 20:15:07 aragorn kernel: 59407 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 37518 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 205147, delete 167629, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1361488kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93830 pages shared
Oct 12 20:15:07 aragorn kernel: 433823 pages non-shared
Oct 12 20:15:07 aragorn kernel: iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
Oct 12 20:15:07 aragorn kernel: swapper: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 0, comm: swapper Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7243>] iwl_rx_handle+0x3ad/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0362b95>] ? __iwl_read32+0xaa/0xb9 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02b1fc9>] ? acpi_idle_enter_simple+0xfe/0x12c [processor]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa02b1fbf>] ? acpi_idle_enter_simple+0xf4/0x12c [processor]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81220131>] ? cpuidle_idle_call+0x98/0xf3
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100aed0>] ? cpu_idle+0x5a/0x92
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8129e042>] ? rest_init+0x66/0x68
Oct 12 20:15:07 aragorn kernel:  [<ffffffff814a9c48>] ? start_kernel+0x34d/0x358
Oct 12 20:15:07 aragorn kernel:  [<ffffffff814a929a>] ? x86_64_start_reservations+0xaa/0xae
Oct 12 20:15:07 aragorn kernel:  [<ffffffff814a937f>] ? x86_64_start_kernel+0xe1/0xe8
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 187
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 167
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102888 isolated_anon:32
Oct 12 20:15:07 aragorn kernel:  active_file:10737 inactive_file:10749 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:35575 unstable:0 buffer:50
Oct 12 20:15:07 aragorn kernel:  free:2981 slab_reclaimable:3935 slab_unreclaimable:11684
Oct 12 20:15:07 aragorn kernel:  mapped:21563 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:3996kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407572kB active_file:42932kB inactive_file:42868kB unevictable:1600kB isolated(anon):128kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:142300kB mapped:86224kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:46728kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 609*4kB 135*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4028kB
Oct 12 20:15:07 aragorn kernel: 59639 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 37774 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 205403, delete 167629, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1360464kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93766 pages shared
Oct 12 20:15:07 aragorn kernel: 433957 pages non-shared
Oct 12 20:15:07 aragorn kernel: iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 3 free buffers remaining.
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8125732b>] ? ip_rcv+0x2b8/0x2ef
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0362b95>] ? __iwl_read32+0xaa/0xb9 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 200
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102838 isolated_anon:65
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36939 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11957
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407376kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):256kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147756kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47820kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:131 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60755 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39168 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206820, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354820kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7243>] iwl_rx_handle+0x3ad/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8125732b>] ? ip_rcv+0x2b8/0x2ef
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0362b95>] ? __iwl_read32+0xaa/0xb9 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:165 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: kcryptd: page allocation failure. order:2, mode:0x4020
Oct 12 20:15:07 aragorn kernel: Pid: 1523, comm: kcryptd Not tainted 2.6.32-rc4 #29
Oct 12 20:15:07 aragorn kernel: Call Trace:
Oct 12 20:15:07 aragorn kernel:  <IRQ>  [<ffffffff810a9d87>] __alloc_pages_nodemask+0x5b9/0x632
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810a9e17>] __get_free_pages+0x17/0x46
Oct 12 20:15:07 aragorn kernel:  [<ffffffff810cecff>] __kmalloc_track_caller+0x4e/0x146
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] ? iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122d96d>] __alloc_skb+0x6b/0x161
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b583>] iwl_rx_allocate+0x94/0x30a [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa036b814>] iwl_rx_replenish_now+0x1b/0x28 [iwlcore]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b7218>] iwl_rx_handle+0x382/0x3c6 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa03b778d>] iwl_irq_tasklet_legacy+0x531/0x7a9 [iwlagn]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8122c0e6>] ? skb_dequeue+0x60/0x6c
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81048abf>] tasklet_action+0x76/0xc1
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a31a>] __do_softirq+0xdd/0x197
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100ccdc>] call_softirq+0x1c/0x28
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100e81c>] do_softirq+0x38/0x70
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8104a164>] irq_exit+0x3b/0x7a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff812af5d5>] do_IRQ+0xad/0xc4
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100c553>] ret_from_intr+0x0/0xa
Oct 12 20:15:07 aragorn kernel:  <EOI>  [<ffffffffa02419f4>] ? enc128+0x67f/0x80b [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa024273a>] ? aes_encrypt+0x12/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa022f2cc>] ? crypto_cbc_encrypt+0x131/0x193 [cbc]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0242728>] ? aes_encrypt+0x0/0x14 [aes_x86_64]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81152601>] ? async_encrypt+0x3d/0x3f
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201bbd>] ? crypt_convert+0x1fe/0x290 [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0202077>] ? kcryptd_crypt+0x428/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058e77>] ? worker_thread+0x195/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffffa0201c4f>] ? kcryptd_crypt+0x0/0x44e [dm_crypt]
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105cb19>] ? autoremove_wake_function+0x0/0x3d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff81058ce2>] ? worker_thread+0x0/0x22d
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c79b>] ? kthread+0x82/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbda>] ? child_rip+0xa/0x20
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8105c719>] ? kthread+0x0/0x8a
Oct 12 20:15:07 aragorn kernel:  [<ffffffff8100cbd0>] ? child_rip+0x0/0x20
Oct 12 20:15:07 aragorn kernel: Mem-Info:
Oct 12 20:15:07 aragorn kernel: DMA per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:    0, btch:   1 usd:   0
Oct 12 20:15:07 aragorn kernel: DMA32 per-cpu:
Oct 12 20:15:07 aragorn kernel: CPU    0: hi:  186, btch:  31 usd: 161
Oct 12 20:15:07 aragorn kernel: CPU    1: hi:  186, btch:  31 usd: 190
Oct 12 20:15:07 aragorn kernel: active_anon:306195 inactive_anon:102848 isolated_anon:66
Oct 12 20:15:07 aragorn kernel:  active_file:10600 inactive_file:10613 isolated_file:0
Oct 12 20:15:07 aragorn kernel:  unevictable:400 dirty:0 writeback:36970 unstable:0 buffer:51
Oct 12 20:15:07 aragorn kernel:  free:3171 slab_reclaimable:3935 slab_unreclaimable:11978
Oct 12 20:15:07 aragorn kernel:  mapped:21315 shmem:19 pagetables:4243 bounce:0
Oct 12 20:15:07 aragorn kernel: DMA free:7928kB min:40kB low:48kB high:60kB active_anon:3880kB inactive_anon:3980kB active_file:16kB inactive_file:128kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15336kB mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 1976 1976 1976
Oct 12 20:15:07 aragorn kernel: DMA32 free:4756kB min:5664kB low:7080kB high:8496kB active_anon:1220900kB inactive_anon:407412kB active_file:42384kB inactive_file:42324kB unevictable:1600kB isolated(anon):264kB isolated(file):0kB present:2023748kB mlocked:1600kB dirty:0kB writeback:147880kB mapped:85232kB shmem:76kB slab_reclaimable:15736kB slab_unreclaimable:47904kB kernel_stack:1440kB pagetables:16956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Oct 12 20:15:07 aragorn kernel: lowmem_reserve[]: 0 0 0 0
Oct 12 20:15:07 aragorn kernel: DMA: 6*4kB 6*8kB 5*16kB 5*32kB 5*64kB 3*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 1*4096kB = 7928kB
Oct 12 20:15:07 aragorn kernel: DMA32: 923*4kB 17*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 4756kB
Oct 12 20:15:07 aragorn kernel: 60786 total pagecache pages
Oct 12 20:15:07 aragorn kernel: 39195 pages in swap cache
Oct 12 20:15:07 aragorn kernel: Swap cache stats: add 206846, delete 167651, find 11222/12777
Oct 12 20:15:07 aragorn kernel: Free swap  = 1354716kB
Oct 12 20:15:07 aragorn kernel: Total swap = 2097144kB
Oct 12 20:15:07 aragorn kernel: 518064 pages RAM
Oct 12 20:15:07 aragorn kernel: 10503 pages reserved
Oct 12 20:15:07 aragorn kernel: 93541 pages shared
Oct 12 20:15:07 aragorn kernel: 433976 pages non-shared
Oct 12 20:15:07 aragorn kernel: __ratelimit: 45 callbacks suppressed

--Boundary-00=_z2c1KJnOi9pY+mk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
