Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD586B0191
	for <linux-mm@kvack.org>; Sat, 10 Sep 2011 14:43:21 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so550564bkb.14
        for <linux-mm@kvack.org>; Sat, 10 Sep 2011 11:43:12 -0700 (PDT)
Message-ID: <4E6BAFBA.8080100@gmail.com>
Date: Sat, 10 Sep 2011 20:43:06 +0200
From: Anders <aeriksson2@gmail.com>
MIME-Version: 1.0
Subject: Re: 3.0.3 oops. memory related?
References: <4E63C846.10606@gmail.com>	 <20110905094956.186d3830.kamezawa.hiroyu@jp.fujitsu.com>	 <4E665D51.7050809@gmail.com>	 <20110907083818.827b0fa1.kamezawa.hiroyu@jp.fujitsu.com>	 <20110907091339.91160fb5.kamezawa.hiroyu@jp.fujitsu.com> <1315675617.3537.49.camel@frodo>
In-Reply-To: <1315675617.3537.49.camel@frodo>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <srostedt@redhat.com>, rostedt@goodmis.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>

Full dmesg and config attached.

-A


On 09/10/11 19:26, Steven Rostedt wrote:
> Note, it's best to email me at my other email rostedt@goodmis.org. As I
> do not check this email much while traveling.
> 
> On Wed, 2011-09-07 at 09:13 +0900, KAMEZAWA Hiroyuki wrote:
>> On Wed, 7 Sep 2011 08:38:18 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> 
>> > On Tue, 06 Sep 2011 19:50:09 +0200
>> > Anders <aeriksson2@gmail.com> wrote:
>> > 
>> > > On 09/05/11 02:49, KAMEZAWA Hiroyuki wrote:
>> > > > On Sun, 04 Sep 2011 20:49:42 +0200
>> > > > Anders <aeriksson2@gmail.com> wrote:
>> > > >
>> > > > > I've got kdump setup to collect oopes. I found this in the log. Not sure
>> > > > > what it's related to.
>> > > > > 
>> > > >
>> > > > > <4>[47900.533010]  [<ffffffff810ab79f>] ?
>> > > > > mem_cgroup_count_vm_event+0x15/0x67
>> > > > > <4>[47900.533010]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
>> > > > > <4>[47900.533010]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
>> > > > > <4>[47900.533010]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
>> > > > > <4>[47900.533010]  [<ffffffff81022b80>] ? check_preempt_curr+0x36/0x62
>> > > > > <4>[47900.533010]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
>> > > > > <4>[47900.533010]  [<ffffffff810bfd2c>] ?
>> > > > > poll_select_copy_remaining+0xce/0xed
>> > > > > <4>[47900.533010]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30
>> > > >
>> > > > I'll check memcg but...not sure what parts in above log are garbage.
>> > > > At quick glance, mem_cgroup_count_vm_event() does enough NULL check
>> > > > but faulted address was..
>> > > >
>> > > > > <0>[47900.533010] CR2: ffffc5217e257cf0
>> > > >
>> > > > This seems not NULL referencing.
>> > > >
>> > > > #define VMALLOC_START    _AC(0xffffc90000000000, UL)
>> > > > #define VMALLOC_END      _AC(0xffffe8ffffffffff, UL)
>> > > >
>> > > > This is not vmalloc area...hmm. could you show your disassemble of
>> > > > mem_cgroup_count_vm_event() ? and .config ?
>> > > >
>> > > How do I disassembe it?
>> > > 
>> > 
>> > # make mm/memcontrol.o
>> > # objdump -d memcontrol.o > file
>> > 
>> > please cut out mem_cgroup_count_vm_event() from dumpped file.
>> > 
>> 
>> Sorry, I made mistake ..the log says
>> 
>> <1>[47900.533010] RIP  [<ffffffff81097d18>] handle_pte_fault+0x24/0x70a
>> <4>[47900.533010]  RSP <ffff880024c27db8>
>> <0>[47900.533010] CR2: ffffc5217e257cf0
>> 
>> <4>[47900.533010] RSP: 0000:ffff880024c27db8  EFLAGS: 00010296
>> <4>[47900.533010] RAX: 0000000000000cf0 RBX: ffff88006c3b2a68 RCX:
>> ffffc5217e257cf0
>> <4>[47900.533010] RDX: 000000000059effe RSI: ffff88006c3b2a68 RDI:
>> ffff88006d6d2ac0
>> <4>[47900.533010] RBP: ffffc5217e257cf0 R08: ffff880024d3b010 R09:
>> 0000000000000028
>> Hm. CR2==RBP...then accessing RBP caused the fault. But it seems this
>> RBP was accessed in this function before reaching EIP.
>> 
> 
> Since I don't have the full context. What was the IP address of the
> actually fault. Too much is removed and out of context for me to really
> understand what happened.
> 
>> your .config says
>> CONFIG_HAVE_FUNCTION_TRACER=y
>> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
>> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
>> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
>> CONFIG_HAVE_DYNAMIC_FTRACE=y
>> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
>> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
>> CONFIG_HAVE_C_RECORDMCOUNT=y
> 
> Ignore all the "_HAVE_" configs. It is set if the architecture supports
> the features, not if the features are actually enabled. But looking at
> your objdump, at least CONFIG_FUNCTION_TRACER is. Is dynamic tracing
> enabled?
> 
>> 
>> In my binary,
>> 
>> ffffffff8113b820 <handle_pte_fault>:
>> ffffffff8113b820:       55                      push   %rbp
>> ffffffff8113b821:       48 89 e5                mov    %rsp,%rbp
>> ffffffff8113b824:       48 81 ec c0 00 00 00    sub    $0xc0,%rsp
>> ffffffff8113b82b:       48 89 5d d8             mov    %rbx,-0x28(%rbp)
>> ffffffff8113b82f:       4c 89 65 e0             mov    %r12,-0x20(%rbp)
>> ffffffff8113b833:       4c 89 6d e8             mov    %r13,-0x18(%rbp)
>> ffffffff8113b837:       4c 89 75 f0             mov    %r14,-0x10(%rbp)
>> ffffffff8113b83b:       4c 89 7d f8             mov    %r15,-0x8(%rbp)
>> ffffffff8113b83f:       e8 fc d4 47 00          callq  ffffffff815b8d40 <mcount>
>> ffffffff8113b844:       4c 89 45 b8             mov    %r8,-0x48(%rbp)
>> ffffffff8113b848:       4c 8b 29                mov    (%rcx),%r13
>> 
>> handle_pte_fault + 0x24 is just after mcount. And caused fault by accessing 
>> %rbp...returning from a funciton ?
> 
> I'm confused? Is the handle_pte_fault what crashed? Or is it the call
> path to the page fault handler to handle the crash.
> 
> 
>> Hmm...problem with tracing ? I'm sorry if I misunderstand something.
>> Anyway, CCing ftrace guys for getting information.
> 
> The mcount above should be converted to a nop at boot up. Can you please
> send me your .config file and the dmesg too.
> 
> Thanks!
> 
> -- Steve
> 
> 


<6>[    0.000000] Initializing cgroup subsys cpuset
<6>[    0.000000] Initializing cgroup subsys cpu
<5>[    0.000000] Linux version 3.0.3-dirty (root@tv) (gcc version 4.4.5
(Gentoo 4.4.5 p1.2, pie-0.4.5) ) #37 SMP PREEMPT Mon Aug 22 08:54:35
CEST 2011
<6>[    0.000000] Command line: root=/dev/sda3 hpet=disable crashkernel=128M
<6>[    0.000000] KERNEL supported cpus:
<6>[    0.000000]   AMD AuthenticAMD
<6>[    0.000000] BIOS-provided physical RAM map:
<6>[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
<6>[    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
<6>[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
<6>[    0.000000]  BIOS-e820: 0000000000100000 - 0000000077ee0000 (usable)
<6>[    0.000000]  BIOS-e820: 0000000077ee0000 - 0000000077ee3000 (ACPI NVS)
<6>[    0.000000]  BIOS-e820: 0000000077ee3000 - 0000000077ef0000 (ACPI
data)
<6>[    0.000000]  BIOS-e820: 0000000077ef0000 - 0000000077f00000 (reserved)
<6>[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
<6>[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
<6>[    0.000000] NX (Execute Disable) protection: active
<6>[    0.000000] DMI 2.4 present.
<7>[    0.000000] DMI: System manufacturer System Product Name/M2A-VM
HDMI, BIOS ASUS M2A-VM HDMI ACPI BIOS Revision 2201 10/22/2008
<7>[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
(usable) ==> (reserved)
<7>[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000
(usable)
<6>[    0.000000] No AGP bridge found
<6>[    0.000000] last_pfn = 0x77ee0 max_arch_pfn = 0x400000000
<7>[    0.000000] MTRR default type: uncachable
<7>[    0.000000] MTRR fixed ranges enabled:
<7>[    0.000000]   00000-9FFFF write-back
<7>[    0.000000]   A0000-BFFFF uncachable
<7>[    0.000000]   C0000-C7FFF write-protect
<7>[    0.000000]   C8000-FFFFF uncachable
<7>[    0.000000] MTRR variable ranges enabled:
<7>[    0.000000]   0 base 0000000000 mask FFC0000000 write-back
<7>[    0.000000]   1 base 0040000000 mask FFE0000000 write-back
<7>[    0.000000]   2 base 0060000000 mask FFF0000000 write-back
<7>[    0.000000]   3 base 0070000000 mask FFF8000000 write-back
<7>[    0.000000]   4 base 0077F00000 mask FFFFF00000 uncachable
<7>[    0.000000]   5 disabled
<7>[    0.000000]   6 disabled
<7>[    0.000000]   7 disabled
<6>[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
<6>[    0.000000] found SMP MP-table at [ffff8800000f6560] f6560
<7>[    0.000000] initial memory mapped : 0 - 20000000
<7>[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000
size 20480
<6>[    0.000000] init_memory_mapping: 0000000000000000-0000000077ee0000
<7>[    0.000000]  0000000000 - 0077e00000 page 2M
<7>[    0.000000]  0077e00000 - 0077ee0000 page 4k
<7>[    0.000000] kernel direct mapping tables up to 77ee0000 @
77edc000-77ee0000
<6>[    0.000000] Reserving 128MB of memory at 768MB for crashkernel
(System RAM: 1918MB)
<4>[    0.000000] ACPI: RSDP 00000000000f8210 00024 (v02 ATI   )
<4>[    0.000000] ACPI: XSDT 0000000077ee3100 00044 (v01 ATI    ASUSACPI
42302E31 AWRD 00000000)
<4>[    0.000000] ACPI: FACP 0000000077ee8500 000F4 (v03 ATI    ASUSACPI
42302E31 AWRD 00000000)
<4>[    0.000000] ACPI: DSDT 0000000077ee3280 05210 (v01 ATI    ASUSACPI
00001000 MSFT 03000000)
<4>[    0.000000] ACPI: FACS 0000000077ee0000 00040
<4>[    0.000000] ACPI: SSDT 0000000077ee8740 002CC (v01 PTLTD  POWERNOW
00000001  LTP 00000001)
<4>[    0.000000] ACPI: MCFG 0000000077ee8b00 0003C (v01 ATI    ASUSACPI
42302E31 AWRD 00000000)
<4>[    0.000000] ACPI: APIC 0000000077ee8640 00084 (v01 ATI    ASUSACPI
42302E31 AWRD 00000000)
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<7>[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD ->
[ffff880075800000-ffff8800773fffff] on node 0
<4>[    0.000000] Zone PFN ranges:
<4>[    0.000000]   DMA      0x00000010 -> 0x00001000
<4>[    0.000000]   DMA32    0x00001000 -> 0x00100000
<4>[    0.000000]   Normal   empty
<4>[    0.000000] Movable zone start PFN for each node
<4>[    0.000000] early_node_map[2] active PFN ranges
<4>[    0.000000]     0: 0x00000010 -> 0x0000009f
<4>[    0.000000]     0: 0x00000100 -> 0x00077ee0
<7>[    0.000000] On node 0 totalpages: 491119
<7>[    0.000000]   DMA zone: 56 pages used for memmap
<7>[    0.000000]   DMA zone: 5 pages reserved
<7>[    0.000000]   DMA zone: 3922 pages, LIFO batch:0
<7>[    0.000000]   DMA32 zone: 6661 pages used for memmap
<7>[    0.000000]   DMA32 zone: 480475 pages, LIFO batch:31
<6>[    0.000000] Detected use of extended apic ids on hypertransport bus
<6>[    0.000000] ACPI: PM-Timer IO Port: 0x4008
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
<6>[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
<6>[    0.000000] IOAPIC[0]: apic_id 4, version 33, address 0xfec00000,
GSI 0-23
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
<7>[    0.000000] ACPI: IRQ0 used by override.
<7>[    0.000000] ACPI: IRQ2 used by override.
<7>[    0.000000] ACPI: IRQ9 used by override.
<6>[    0.000000] Using ACPI (MADT) for SMP configuration information
<6>[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
<7>[    0.000000] nr_irqs_gsi: 40
<6>[    0.000000] PM: Registered nosave memory: 000000000009f000 -
00000000000a0000
<6>[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
00000000000f0000
<6>[    0.000000] PM: Registered nosave memory: 00000000000f0000 -
0000000000100000
<6>[    0.000000] Allocating PCI resources starting at 77f00000 (gap:
77f00000:68100000)
<6>[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4
nr_node_ids:1
<6>[    0.000000] PERCPU: Embedded 24 pages/cpu @ffff880077c00000 s68800
r8192 d21312 u524288
<7>[    0.000000] pcpu-alloc: s68800 r8192 d21312 u524288 alloc=1*2097152
<7>[    0.000000] pcpu-alloc: [0] 0 1 2 3
<4>[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
 Total pages: 484397
<5>[    0.000000] Kernel command line: root=/dev/sda3 hpet=disable
crashkernel=128M
<6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
<6>[    0.000000] Dentry cache hash table entries: 262144 (order: 9,
2097152 bytes)
<6>[    0.000000] Inode-cache hash table entries: 131072 (order: 8,
1048576 bytes)
<6>[    0.000000] Checking aperture...
<6>[    0.000000] No AGP bridge found
<6>[    0.000000] Node 0: aperture @ 1266000000 size 32 MB
<6>[    0.000000] Aperture beyond 4GB. Ignoring.
<6>[    0.000000] Memory: 1792880k/1964928k available (4899k kernel
code, 452k absent, 171596k reserved, 2346k data, 464k init)
<6>[    0.000000] Preemptible hierarchical RCU implementation.
<6>[    0.000000]       CONFIG_RCU_FANOUT set to non-default value of 32
<6>[    0.000000] NR_IRQS:384
<6>[    0.000000] Console: colour VGA+ 80x25
<6>[    0.000000] console [tty0] enabled
<6>[    0.000000] allocated 15728640 bytes of page_cgroup
<6>[    0.000000] please try 'cgroup_disable=memory' option if you don't
want memory cgroups
<4>[    0.000000] Fast TSC calibration using PIT
<4>[    0.000000] Detected 2799.481 MHz processor.
<6>[    0.000000] Marking TSC unstable due to TSCs unsynchronized
<6>[    0.002040] Calibrating delay loop (skipped), value calculated
using timer frequency.. 5598.96 BogoMIPS (lpj=2799481)
<6>[    0.002112] pid_max: default: 32768 minimum: 301
<6>[    0.002206] Mount-cache hash table entries: 256
<6>[    0.002395] Initializing cgroup subsys cpuacct
<6>[    0.002436] Initializing cgroup subsys memory
<6>[    0.002482] Initializing cgroup subsys devices
<6>[    0.002517] Initializing cgroup subsys freezer
<6>[    0.002551] Initializing cgroup subsys blkio
<7>[    0.003024] tseg: 0077f00000
<6>[    0.003025] CPU: Physical Processor ID: 0
<6>[    0.003060] CPU: Processor Core ID: 0
<6>[    0.003094] mce: CPU supports 5 MCE banks
<6>[    0.003136] using AMD E400 aware idle routine
<6>[    0.003204] ACPI: Core revision 20110413
<6>[    0.006300] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
<6>[    0.016351] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 5600+
stepping 03
<6>[    0.016998] Performance Events: AMD PMU driver.
<6>[    0.016998] ... version:                0
<6>[    0.016998] ... bit width:              48
<6>[    0.016998] ... generic registers:      4
<6>[    0.016998] ... value mask:             0000ffffffffffff
<6>[    0.016998] ... max period:             00007fffffffffff
<6>[    0.016998] ... fixed-purpose events:   0
<6>[    0.016998] ... event mask:             000000000000000f
<6>[    0.028010] Booting Node   0, Processors  #1
<7>[    0.028070] smpboot cpu 1: start_ip = 9a000
<6>[    0.099031] Brought up 2 CPUs
<6>[    0.099066] Total of 2 processors activated (11197.75 BogoMIPS).
<6>[    0.099459] PM: Registering ACPI NVS region at 77ee0000 (12288 bytes)
<6>[    0.099459] NET: Registered protocol family 16
<7>[    0.100026] node 0 link 0: io port [c000, ffff]
<6>[    0.100026] TOM: 0000000080000000 aka 2048M
<7>[    0.100045] node 0 link 0: mmio [a0000, bffff]
<7>[    0.100048] node 0 link 0: mmio [f0000000, f7ffffff]
<7>[    0.100050] node 0 link 0: mmio [80000000, dfffffff]
<7>[    0.100053] node 0 link 0: mmio [f0000000, fe02ffff]
<7>[    0.100055] node 0 link 0: mmio [e0000000, e03fffff]
<7>[    0.100058] bus: [00, 03] on node 0 link 0
<7>[    0.100060] bus: 00 index 0 [io  0x0000-0xffff]
<7>[    0.100062] bus: 00 index 1 [mem 0x000a0000-0x000bffff]
<7>[    0.100065] bus: 00 index 2 [mem 0xe0400000-0xfcffffffff]
<7>[    0.100066] bus: 00 index 3 [mem 0x80000000-0xe03fffff]
<6>[    0.100074] ACPI: bus type pci registered
<6>[    0.100118] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
<6>[    0.100118] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved
in E820
<6>[    0.116070] PCI: Using configuration type 1 for base access
<6>[    0.121125] bio: create slab <bio-0> at 0
<7>[    0.122564] ACPI: EC: Look up EC in DSDT
<6>[    0.126031] ACPI: Interpreter enabled
<6>[    0.126069] ACPI: (supports S0 S1 S3 S4 S5)
<6>[    0.126262] ACPI: Using IOAPIC for interrupt routing
<6>[    0.130344] ACPI: No dock devices found.
<6>[    0.130344] HEST: Table not found.
<6>[    0.130344] PCI: Using host bridge windows from ACPI; if
necessary, use "pci=nocrs" and report a bug
<6>[    0.131064] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
<6>[    0.131135] pci_root PNP0A03:00: host bridge window [io
0x0000-0x0cf7]
<6>[    0.131135] pci_root PNP0A03:00: host bridge window [io
0x0d00-0xffff]
<6>[    0.131145] pci_root PNP0A03:00: host bridge window [mem
0x000a0000-0x000bffff]
<6>[    0.131184] pci_root PNP0A03:00: host bridge window [mem
0x000c0000-0x000dffff]
<6>[    0.131224] pci_root PNP0A03:00: host bridge window [mem
0x80000000-0xfebfffff]
<7>[    0.131272] pci 0000:00:00.0: [1002:7910] type 0 class 0x000600
<7>[    0.131297] pci 0000:00:01.0: [1002:7912] type 1 class 0x000604
<7>[    0.131328] pci 0000:00:07.0: [1002:7917] type 1 class 0x000604
<7>[    0.131349] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
<7>[    0.131352] pci 0000:00:07.0: PME# disabled
<7>[    0.131381] pci 0000:00:12.0: [1002:4380] type 0 class 0x000101
<7>[    0.131399] pci 0000:00:12.0: reg 10: [io  0xff00-0xff07]
<7>[    0.131409] pci 0000:00:12.0: reg 14: [io  0xfe00-0xfe03]
<7>[    0.131419] pci 0000:00:12.0: reg 18: [io  0xfd00-0xfd07]
<7>[    0.131429] pci 0000:00:12.0: reg 1c: [io  0xfc00-0xfc03]
<7>[    0.131439] pci 0000:00:12.0: reg 20: [io  0xfb00-0xfb0f]
<7>[    0.131449] pci 0000:00:12.0: reg 24: [mem 0xfe02f000-0xfe02f3ff]
<6>[    0.131470] pci 0000:00:12.0: set SATA to AHCI mode
<7>[    0.131531] pci 0000:00:13.0: [1002:4387] type 0 class 0x000c03
<7>[    0.131545] pci 0000:00:13.0: reg 10: [mem 0xfe02e000-0xfe02efff]
<7>[    0.131610] pci 0000:00:13.1: [1002:4388] type 0 class 0x000c03
<7>[    0.131623] pci 0000:00:13.1: reg 10: [mem 0xfe02d000-0xfe02dfff]
<7>[    0.131688] pci 0000:00:13.2: [1002:4389] type 0 class 0x000c03
<7>[    0.131701] pci 0000:00:13.2: reg 10: [mem 0xfe02c000-0xfe02cfff]
<7>[    0.131766] pci 0000:00:13.3: [1002:438a] type 0 class 0x000c03
<7>[    0.131780] pci 0000:00:13.3: reg 10: [mem 0xfe02b000-0xfe02bfff]
<7>[    0.132029] pci 0000:00:13.4: [1002:438b] type 0 class 0x000c03
<7>[    0.132043] pci 0000:00:13.4: reg 10: [mem 0xfe02a000-0xfe02afff]
<7>[    0.132114] pci 0000:00:13.5: [1002:4386] type 0 class 0x000c03
<7>[    0.132134] pci 0000:00:13.5: reg 10: [mem 0xfe029000-0xfe0290ff]
<7>[    0.132205] pci 0000:00:13.5: supports D1 D2
<7>[    0.132207] pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
<7>[    0.132211] pci 0000:00:13.5: PME# disabled
<7>[    0.132233] pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
<7>[    0.132256] pci 0000:00:14.0: reg 10: [io  0x0b00-0x0b0f]
<7>[    0.132332] pci 0000:00:14.1: [1002:438c] type 0 class 0x000101
<7>[    0.132346] pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
<7>[    0.132356] pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
<7>[    0.132366] pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
<7>[    0.132376] pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
<7>[    0.132386] pci 0000:00:14.1: reg 20: [io  0xf900-0xf90f]
<7>[    0.132423] pci 0000:00:14.2: [1002:4383] type 0 class 0x000403
<7>[    0.132445] pci 0000:00:14.2: reg 10: [mem 0xfe020000-0xfe023fff
64bit]
<7>[    0.132504] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
<7>[    0.132508] pci 0000:00:14.2: PME# disabled
<7>[    0.132523] pci 0000:00:14.3: [1002:438d] type 0 class 0x000601
<7>[    0.132596] pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
<7>[    0.132642] pci 0000:00:18.0: [1022:1100] type 0 class 0x000600
<7>[    0.132657] pci 0000:00:18.1: [1022:1101] type 0 class 0x000600
<7>[    0.132670] pci 0000:00:18.2: [1022:1102] type 0 class 0x000600
<7>[    0.132683] pci 0000:00:18.3: [1022:1103] type 0 class 0x000600
<7>[    0.132723] pci 0000:01:05.0: [1002:791e] type 0 class 0x000300
<7>[    0.132731] pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff
64bit pref]
<7>[    0.132737] pci 0000:01:05.0: reg 18: [mem 0xfdbe0000-0xfdbeffff
64bit]
<7>[    0.132742] pci 0000:01:05.0: reg 20: [io  0xde00-0xdeff]
<7>[    0.132746] pci 0000:01:05.0: reg 24: [mem 0xfda00000-0xfdafffff]
<7>[    0.132756] pci 0000:01:05.0: supports D1 D2
<7>[    0.132766] pci 0000:01:05.2: [1002:7919] type 0 class 0x000403
<7>[    0.132774] pci 0000:01:05.2: reg 10: [mem 0xfdbfc000-0xfdbfffff
64bit]
<6>[    0.132805] pci 0000:00:01.0: PCI bridge to [bus 01-01]
<7>[    0.132842] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
<7>[    0.132844] pci 0000:00:01.0:   bridge window [mem
0xfda00000-0xfdbfffff]
<7>[    0.132848] pci 0000:00:01.0:   bridge window [mem
0xf0000000-0xf7ffffff 64bit pref]
<7>[    0.132886] pci 0000:02:00.0: [10ec:8168] type 0 class 0x000200
<7>[    0.132900] pci 0000:02:00.0: reg 10: [io  0xee00-0xeeff]
<7>[    0.132924] pci 0000:02:00.0: reg 18: [mem 0xfdfff000-0xfdffffff
64bit]
<7>[    0.132951] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
<7>[    0.133003] pci 0000:02:00.0: supports D1 D2
<7>[    0.133005] pci 0000:02:00.0: PME# supported from D1 D2 D3hot D3cold
<7>[    0.133010] pci 0000:02:00.0: PME# disabled
<6>[    0.133024] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe
device.  You can enable it with 'pcie_aspm=force'
<6>[    0.133071] pci 0000:00:07.0: PCI bridge to [bus 02-02]
<7>[    0.133107] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
<7>[    0.133110] pci 0000:00:07.0:   bridge window [mem
0xfdf00000-0xfdffffff]
<7>[    0.133113] pci 0000:00:07.0:   bridge window [mem
0xfdc00000-0xfdcfffff 64bit pref]
<7>[    0.133150] pci 0000:03:06.0: [1131:7133] type 0 class 0x000480
<7>[    0.133172] pci 0000:03:06.0: reg 10: [mem 0xfdeff000-0xfdeff7ff]
<7>[    0.133261] pci 0000:03:06.0: supports D1 D2
<7>[    0.133284] pci 0000:03:07.0: [1106:3044] type 0 class 0x000c00
<7>[    0.133307] pci 0000:03:07.0: reg 10: [mem 0xfdefe000-0xfdefe7ff]
<7>[    0.133321] pci 0000:03:07.0: reg 14: [io  0xcf00-0xcf7f]
<7>[    0.133401] pci 0000:03:07.0: supports D2
<7>[    0.133404] pci 0000:03:07.0: PME# supported from D2 D3hot D3cold
<7>[    0.133409] pci 0000:03:07.0: PME# disabled
<6>[    0.133454] pci 0000:00:14.4: PCI bridge to [bus 03-03]
(subtractive decode)
<7>[    0.133492] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
<7>[    0.133497] pci 0000:00:14.4:   bridge window [mem
0xfde00000-0xfdefffff]
<7>[    0.133501] pci 0000:00:14.4:   bridge window [mem
0xfdd00000-0xfddfffff pref]
<7>[    0.133504] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
<7>[    0.133506] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
<7>[    0.133509] pci 0000:00:14.4:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
<7>[    0.133511] pci 0000:00:14.4:   bridge window [mem
0x000c0000-0x000dffff] (subtractive decode)
<7>[    0.133514] pci 0000:00:14.4:   bridge window [mem
0x80000000-0xfebfffff] (subtractive decode)
<7>[    0.133525] pci_bus 0000:00: on NUMA node 0
<7>[    0.133527] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
<7>[    0.133679] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
<7>[    0.133745] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE7._PRT]
<7>[    0.133771] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
<6>[    0.133799]  pci0000:00: Requesting ACPI _OSC control (0x1d)
<6>[    0.133835]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND),
returned control mask: 0x1d
<6>[    0.133874] ACPI _OSC control for PCIe not granted, disabling ASPM
<6>[    0.146434] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.147231] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.147618] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.148021] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.148409] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.148794] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.149168] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 10 *11)
<6>[    0.149491] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 10 11)
*0, disabled.
<6>[    0.150009] vgaarb: device added:
PCI:0000:01:05.0,decodes=io+mem,owns=io+mem,locks=none
<6>[    0.150049] vgaarb: loaded
<6>[    0.150082] vgaarb: bridge control possible 0000:01:05.0
<5>[    0.150195] SCSI subsystem initialized
<7>[    0.150195] libata version 3.00 loaded.
<6>[    0.150195] usbcore: registered new interface driver usbfs
<6>[    0.150195] usbcore: registered new interface driver hub
<6>[    0.150195] usbcore: registered new device driver usb
<6>[    0.150998] Advanced Linux Sound Architecture Driver Version 1.0.24.
<6>[    0.151034] PCI: Using ACPI for IRQ routing
<7>[    0.159960] PCI: pci_cache_line_size set to 64 bytes
<7>[    0.160051] reserve RAM buffer: 000000000009f000 - 000000000009ffff
<7>[    0.160054] reserve RAM buffer: 0000000077ee0000 - 0000000077ffffff
<6>[    0.160072] Bluetooth: Core ver 2.16
<6>[    0.160072] NET: Registered protocol family 31
<6>[    0.160072] Bluetooth: HCI device and connection manager initialized
<6>[    0.160072] Bluetooth: HCI socket layer initialized
<6>[    0.160102] Bluetooth: L2CAP socket layer initialized
<6>[    0.160141] Bluetooth: SCO socket layer initialized
<6>[    0.160141] pnp: PnP ACPI init
<6>[    0.160141] ACPI: bus type pnp registered
<7>[    0.160141] pnp 00:00: [bus 00-ff]
<7>[    0.160141] pnp 00:00: [io  0x0cf8-0x0cff]
<7>[    0.160141] pnp 00:00: [io  0x0000-0x0cf7 window]
<7>[    0.160143] pnp 00:00: [io  0x0d00-0xffff window]
<7>[    0.160145] pnp 00:00: [mem 0x000a0000-0x000bffff window]
<7>[    0.160148] pnp 00:00: [mem 0x000c0000-0x000dffff window]
<7>[    0.160150] pnp 00:00: [mem 0x80000000-0xfebfffff window]
<7>[    0.160189] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
<7>[    0.160189] pnp 00:01: [io  0x4100-0x411f]
<7>[    0.160189] pnp 00:01: [io  0x0228-0x022f]
<7>[    0.160189] pnp 00:01: [io  0x040b]
<7>[    0.160189] pnp 00:01: [io  0x04d6]
<7>[    0.160189] pnp 00:01: [io  0x0c00-0x0c01]
<7>[    0.160189] pnp 00:01: [io  0x0c14]
<7>[    0.160189] pnp 00:01: [io  0x0c50-0x0c52]
<7>[    0.160189] pnp 00:01: [io  0x0c6c-0x0c6d]
<7>[    0.160189] pnp 00:01: [io  0x0c6f]
<7>[    0.160189] pnp 00:01: [io  0x0cd0-0x0cd1]
<7>[    0.160189] pnp 00:01: [io  0x0cd2-0x0cd3]
<7>[    0.160189] pnp 00:01: [io  0x0cd4-0x0cdf]
<7>[    0.160189] pnp 00:01: [io  0x4000-0x40fe]
<7>[    0.160189] pnp 00:01: [io  0x4210-0x4217]
<7>[    0.160189] pnp 00:01: [io  0x0b10-0x0b1f]
<7>[    0.160189] pnp 00:01: [mem 0x00000000-0x00000fff window]
<7>[    0.160189] pnp 00:01: [mem 0xfee00400-0xfee00fff window]
<4>[    0.160189] pnp 00:01: disabling [mem 0x00000000-0x00000fff
window] because it overlaps 0000:02:00.0 BAR 6 [mem
0x00000000-0x0001ffff pref]
<6>[    0.161009] system 00:01: [io  0x4100-0x411f] has been reserved
<6>[    0.161036] system 00:01: [io  0x0228-0x022f] has been reserved
<6>[    0.161073] system 00:01: [io  0x040b] has been reserved
<6>[    0.161108] system 00:01: [io  0x04d6] has been reserved
<6>[    0.163986] system 00:01: [io  0x0c00-0x0c01] has been reserved
<6>[    0.163986] system 00:01: [io  0x0c14] has been reserved
<6>[    0.164020] system 00:01: [io  0x0c50-0x0c52] has been reserved
<6>[    0.164056] system 00:01: [io  0x0c6c-0x0c6d] has been reserved
<6>[    0.164091] system 00:01: [io  0x0c6f] has been reserved
<6>[    0.164127] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
<6>[    0.164162] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
<6>[    0.164198] system 00:01: [io  0x0cd4-0x0cdf] has been reserved
<6>[    0.164234] system 00:01: [io  0x4000-0x40fe] has been reserved
<6>[    0.164269] system 00:01: [io  0x4210-0x4217] has been reserved
<6>[    0.164305] system 00:01: [io  0x0b10-0x0b1f] has been reserved
<6>[    0.164342] system 00:01: [mem 0xfee00400-0xfee00fff window] has
been reserved
<7>[    0.164381] system 00:01: Plug and Play ACPI device, IDs PNP0c02
(active)
<7>[    0.164466] pnp 00:02: [dma 4]
<7>[    0.164468] pnp 00:02: [io  0x0000-0x000f]
<7>[    0.164470] pnp 00:02: [io  0x0080-0x0090]
<7>[    0.164472] pnp 00:02: [io  0x0094-0x009f]
<7>[    0.164474] pnp 00:02: [io  0x00c0-0x00df]
<7>[    0.164499] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
<7>[    0.164499] pnp 00:03: [io  0x0070-0x0073]
<7>[    0.164499] pnp 00:03: [irq 8]
<7>[    0.164499] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
<7>[    0.164499] pnp 00:04: [io  0x0061]
<7>[    0.164499] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
<7>[    0.164499] pnp 00:05: [io  0x00f0-0x00ff]
<7>[    0.164499] pnp 00:05: [irq 13]
<7>[    0.164499] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
<7>[    0.164499] pnp 00:06: [io  0x0010-0x001f]
<7>[    0.164499] pnp 00:06: [io  0x0022-0x003f]
<7>[    0.164499] pnp 00:06: [io  0x0044-0x005f]
<7>[    0.164499] pnp 00:06: [io  0x0062-0x0063]
<7>[    0.164499] pnp 00:06: [io  0x0065-0x006f]
<7>[    0.164499] pnp 00:06: [io  0x0074-0x007f]
<7>[    0.164499] pnp 00:06: [io  0x0091-0x0093]
<7>[    0.164499] pnp 00:06: [io  0x00a2-0x00bf]
<7>[    0.164499] pnp 00:06: [io  0x00e0-0x00ef]
<7>[    0.164499] pnp 00:06: [io  0x04d0-0x04d1]
<7>[    0.164499] pnp 00:06: [io  0x0220-0x0225]
<6>[    0.164499] system 00:06: [io  0x04d0-0x04d1] has been reserved
<6>[    0.164499] system 00:06: [io  0x0220-0x0225] has been reserved
<7>[    0.164499] system 00:06: Plug and Play ACPI device, IDs PNP0c02
(active)
<7>[    0.165081] pnp 00:07: [io  0x03f0-0x03f5]
<7>[    0.165083] pnp 00:07: [io  0x03f7]
<7>[    0.165091] pnp 00:07: [irq 6]
<7>[    0.165093] pnp 00:07: [dma 2]
<7>[    0.165136] pnp 00:07: Plug and Play ACPI device, IDs PNP0700 (active)
<7>[    0.165160] pnp 00:08: [io  0x03f8-0x03ff]
<7>[    0.165168] pnp 00:08: [irq 4]
<7>[    0.165224] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
<7>[    0.165242] pnp 00:09: [io  0x0378-0x037f]
<7>[    0.165250] pnp 00:09: [irq 7]
<7>[    0.165298] pnp 00:09: Plug and Play ACPI device, IDs PNP0400 (active)
<7>[    0.165298] pnp 00:0a: [mem 0xe0000000-0xefffffff]
<6>[    0.165298] system 00:0a: [mem 0xe0000000-0xefffffff] has been
reserved
<7>[    0.165298] system 00:0a: Plug and Play ACPI device, IDs PNP0c02
(active)
<7>[    0.166066] pnp 00:0b: [mem 0x000cd600-0x000cffff]
<7>[    0.166068] pnp 00:0b: [mem 0x000f0000-0x000f7fff]
<7>[    0.166070] pnp 00:0b: [mem 0x000f8000-0x000fbfff]
<7>[    0.166072] pnp 00:0b: [mem 0x000fc000-0x000fffff]
<7>[    0.166074] pnp 00:0b: [mem 0x77ef0000-0x77feffff]
<7>[    0.166076] pnp 00:0b: [mem 0xfed00000-0xfed000ff]
<7>[    0.166078] pnp 00:0b: [mem 0x77ee0000-0x77efffff]
<7>[    0.166080] pnp 00:0b: [mem 0xffff0000-0xffffffff]
<7>[    0.166082] pnp 00:0b: [mem 0x00000000-0x0009ffff]
<7>[    0.166085] pnp 00:0b: [mem 0x00100000-0x77edffff]
<7>[    0.166087] pnp 00:0b: [mem 0x77ff0000-0x7ffeffff]
<7>[    0.166091] pnp 00:0b: [mem 0xfec00000-0xfec00fff]
<7>[    0.166094] pnp 00:0b: [mem 0xfee00000-0xfee00fff]
<7>[    0.166096] pnp 00:0b: [mem 0xfff80000-0xfffeffff]
<6>[    0.166151] system 00:0b: [mem 0x000cd600-0x000cffff] has been
reserved
<6>[    0.166151] system 00:0b: [mem 0x000f0000-0x000f7fff] could not be
reserved
<6>[    0.166151] system 00:0b: [mem 0x000f8000-0x000fbfff] could not be
reserved
<6>[    0.166151] system 00:0b: [mem 0x000fc000-0x000fffff] could not be
reserved
<6>[    0.166151] system 00:0b: [mem 0x77ef0000-0x77feffff] could not be
reserved
<6>[    0.166180] system 00:0b: [mem 0xfed00000-0xfed000ff] has been
reserved
<6>[    0.166215] system 00:0b: [mem 0x77ee0000-0x77efffff] could not be
reserved
<6>[    0.166252] system 00:0b: [mem 0xffff0000-0xffffffff] has been
reserved
<6>[    0.166288] system 00:0b: [mem 0x00000000-0x0009ffff] could not be
reserved
<6>[    0.166324] system 00:0b: [mem 0x00100000-0x77edffff] could not be
reserved
<6>[    0.166360] system 00:0b: [mem 0x77ff0000-0x7ffeffff] could not be
reserved
<6>[    0.166397] system 00:0b: [mem 0xfec00000-0xfec00fff] could not be
reserved
<6>[    0.166432] system 00:0b: [mem 0xfee00000-0xfee00fff] could not be
reserved
<6>[    0.166469] system 00:0b: [mem 0xfff80000-0xfffeffff] has been
reserved
<7>[    0.166505] system 00:0b: Plug and Play ACPI device, IDs PNP0c01
(active)
<6>[    0.166511] pnp: PnP ACPI: found 12 devices
<6>[    0.166546] ACPI: ACPI bus type pnp unregistered
<6>[    0.174447] Switching to clocksource acpi_pm
<7>[    0.174510] PCI: max bus depth: 1 pci_try_num: 2
<6>[    0.174527] pci 0000:00:01.0: PCI bridge to [bus 01-01]
<6>[    0.174563] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
<6>[    0.174600] pci 0000:00:01.0:   bridge window [mem
0xfda00000-0xfdbfffff]
<6>[    0.174636] pci 0000:00:01.0:   bridge window [mem
0xf0000000-0xf7ffffff 64bit pref]
<6>[    0.174679] pci 0000:02:00.0: BAR 6: assigned [mem
0xfdc00000-0xfdc1ffff pref]
<6>[    0.174718] pci 0000:00:07.0: PCI bridge to [bus 02-02]
<6>[    0.174754] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
<6>[    0.174790] pci 0000:00:07.0:   bridge window [mem
0xfdf00000-0xfdffffff]
<6>[    0.174827] pci 0000:00:07.0:   bridge window [mem
0xfdc00000-0xfdcfffff 64bit pref]
<6>[    0.174867] pci 0000:00:14.4: PCI bridge to [bus 03-03]
<6>[    0.174903] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
<6>[    0.174942] pci 0000:00:14.4:   bridge window [mem
0xfde00000-0xfdefffff]
<6>[    0.174490] Switched to NOHz mode on CPU #0
<6>[    0.174942] Switched to NOHz mode on CPU #1
<6>[    0.174942] pci 0000:00:14.4:   bridge window [mem
0xfdd00000-0xfddfffff pref]
<7>[    0.174942] pci 0000:00:07.0: setting latency timer to 64
<7>[    0.174942] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
<7>[    0.174942] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
<7>[    0.174942] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    0.174942] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000dffff]
<7>[    0.174942] pci_bus 0000:00: resource 8 [mem 0x80000000-0xfebfffff]
<7>[    0.174942] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
<7>[    0.174942] pci_bus 0000:01: resource 1 [mem 0xfda00000-0xfdbfffff]
<7>[    0.174942] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff
64bit pref]
<7>[    0.174942] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
<7>[    0.174942] pci_bus 0000:02: resource 1 [mem 0xfdf00000-0xfdffffff]
<7>[    0.174942] pci_bus 0000:02: resource 2 [mem 0xfdc00000-0xfdcfffff
64bit pref]
<7>[    0.174942] pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
<7>[    0.174942] pci_bus 0000:03: resource 1 [mem 0xfde00000-0xfdefffff]
<7>[    0.174942] pci_bus 0000:03: resource 2 [mem 0xfdd00000-0xfddfffff
pref]
<7>[    0.174942] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
<7>[    0.174942] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
<7>[    0.174942] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    0.174942] pci_bus 0000:03: resource 7 [mem 0x000c0000-0x000dffff]
<7>[    0.174942] pci_bus 0000:03: resource 8 [mem 0x80000000-0xfebfffff]
<6>[    0.174942] NET: Registered protocol family 2
<6>[    0.174942] IP route cache hash table entries: 65536 (order: 7,
524288 bytes)
<6>[    0.175307] TCP established hash table entries: 262144 (order: 10,
4194304 bytes)
<6>[    0.177149] TCP bind hash table entries: 65536 (order: 8, 1048576
bytes)
<6>[    0.177692] TCP: Hash tables configured (established 262144 bind
65536)
<6>[    0.177729] TCP reno registered
<6>[    0.177764] UDP hash table entries: 1024 (order: 3, 32768 bytes)
<6>[    0.177817] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
<6>[    0.177994] NET: Registered protocol family 1
<6>[    0.178159] RPC: Registered named UNIX socket transport module.
<6>[    0.178196] RPC: Registered udp transport module.
<6>[    0.178230] RPC: Registered tcp transport module.
<6>[    0.178265] RPC: Registered tcp NFSv4.1 backchannel transport module.
<7>[    0.374046] pci 0000:01:05.0: Boot video device
<7>[    0.374058] PCI: CLS 32 bytes, default 64
<6>[    0.375168] audit: initializing netlink socket (disabled)
<5>[    0.375211] type=2000 audit(1314715273.374:1): initialized
<6>[    0.381961] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
<6>[    0.382273] msgmni has been set to 3501
<6>[    0.382681] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
<6>[    0.382722] io scheduler noop registered
<6>[    0.382775] io scheduler cfq registered (default)
<7>[    0.382940] pcieport 0000:00:07.0: setting latency timer to 64
<7>[    0.382964] pcieport 0000:00:07.0: irq 40 for MSI/MSI-X
<6>[    0.383633] input: Power Button as
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
<6>[    0.383676] ACPI: Power Button [PWRB]
<6>[    0.383806] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
<6>[    0.383846] ACPI: Power Button [PWRF]
<6>[    0.384029] ACPI: Fan [FAN] (on)
<7>[    0.384162] ACPI: acpi_idle registered with cpuidle
<4>[    0.385511] ACPI Warning: For \_TZ_.THRM._PSL: Return Package has
no elements (empty) (20110413/nspredef-456)
<3>[    0.385613] ACPI: [Package] has zero elements (ffff88007424c2c0)
<4>[    0.385648] ACPI: Invalid passive threshold
<6>[    0.385835] thermal LNXTHERM:00: registered as thermal_zone0
<6>[    0.385871] ACPI: Thermal Zone [THRM] (40 C)
<6>[    0.385951] ERST: Table is not found!
<6>[    0.386101] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
<6>[    0.406795] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
<6>[    0.477797] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
<6>[    0.489338] [drm] Initialized drm 1.1.0 20060810
<6>[    0.489425] [drm] radeon defaulting to kernel modesetting.
<6>[    0.489461] [drm] radeon kernel modesetting enabled.
<6>[    0.489546] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
-> IRQ 18
<6>[    0.489760] [drm] initializing kernel modesetting (RS690
0x1002:0x791E 0x1043:0x826D).
<6>[    0.489814] [drm] register mmio base: 0xFDBE0000
<6>[    0.489849] [drm] register mmio size: 65536
<6>[    0.491426] ATOM BIOS: ATI
<6>[    0.491476] radeon 0000:01:05.0: VRAM: 128M 0x0000000078000000 -
0x000000007FFFFFFF (128M used)
<6>[    0.491516] radeon 0000:01:05.0: GTT: 512M 0x0000000080000000 -
0x000000009FFFFFFF
<6>[    0.491556] [drm] Supports vblank timestamp caching Rev 1
(10.10.2010).
<6>[    0.491591] [drm] Driver supports precise vblank timestamp query.
<6>[    0.491650] [drm] radeon: irq initialized.
<6>[    0.492002] [drm] Detected VRAM RAM=128M, BAR=128M
<6>[    0.492072] [drm] RAM width 128bits DDR
<6>[    0.492180] [TTM] Zone  kernel: Available graphics memory: 896440 kiB.
<6>[    0.492220] [TTM] Initializing pool allocator.
<6>[    0.492281] [drm] radeon: 128M of VRAM memory ready
<6>[    0.492316] [drm] radeon: 512M of GTT memory ready.
<6>[    0.492352] [drm] GART: num cpu pages 131072, num gpu pages 131072
<6>[    0.496128] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
<6>[    0.502015] radeon 0000:01:05.0: WB enabled
<6>[    0.502150] [drm] Loading RS690/RS740 Microcode
<6>[    0.502334] [drm] radeon: ring at 0x0000000080001000
<6>[    0.502385] [drm] ring test succeeded in 1 usecs
<6>[    0.502517] [drm] radeon: ib pool ready.
<6>[    0.502557] [drm] ib test succeeded in 0 usecs
<7>[    0.502600] failed to evaluate ATIF got AE_BAD_PARAMETER
<6>[    0.503287] [drm] Radeon Display Connectors
<6>[    0.503321] [drm] Connector 0:
<6>[    0.503355] [drm]   VGA
<6>[    0.503389] [drm]   DDC: 0x7e50 0x7e40 0x7e54 0x7e44 0x7e58 0x7e48
0x7e5c 0x7e4c
<6>[    0.503427] [drm]   Encoders:
<6>[    0.503460] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
<6>[    0.503494] [drm] Connector 1:
<6>[    0.503527] [drm]   S-video
<6>[    0.503560] [drm]   Encoders:
<6>[    0.503593] [drm]     TV1: INTERNAL_KLDSCP_DAC1
<6>[    0.503627] [drm] Connector 2:
<6>[    0.503660] [drm]   HDMI-A
<6>[    0.503693] [drm]   HPD2
<6>[    0.503727] [drm]   DDC: 0x7e40 0x7e60 0x7e44 0x7e64 0x7e48 0x7e68
0x7e4c 0x7e6c
<6>[    0.503765] [drm]   Encoders:
<6>[    0.503798] [drm]     DFP2: INTERNAL_DDI
<6>[    0.503831] [drm] Connector 3:
<6>[    0.503864] [drm]   DVI-D
<6>[    0.503898] [drm]   DDC: 0x7e40 0x7e50 0x7e44 0x7e54 0x7e48 0x7e58
0x7e4c 0x7e5c
<6>[    0.503936] [drm]   Encoders:
<6>[    0.503969] [drm]     DFP3: INTERNAL_LVTM1
<6>[    0.555329] [drm] Radeon display connector VGA-1: Found valid EDID
<6>[    0.656303] [drm] Radeon display connector HDMI-A-1: Found valid EDID
<6>[    0.665918] [drm] Radeon display connector DVI-D-1: No monitor
connected or invalid EDID
<6>[    0.922033] [drm] fb mappable at 0xF0040000
<6>[    0.922098] [drm] vram apper at 0xF0000000
<6>[    0.922132] [drm] size 8294400
<6>[    0.922165] [drm] fb depth is 24
<6>[    0.922199] [drm]    pitch is 7680
<6>[    0.922314] fbcon: radeondrmfb (fb0) is primary device
<6>[    0.969682] Console: switching to colour frame buffer device 240x67
<6>[    0.987701] fb0: radeondrmfb frame buffer device
<6>[    0.987768] drm: registered panic notifier
<6>[    0.987832] [drm] Initialized radeon 2.10.0 20080528 for
0000:01:05.0 on minor 0
<6>[    0.990428] brd: module loaded
<6>[    0.991651] loop: module loaded
<6>[    0.991754] Uniform Multi-Platform E-IDE driver
<6>[    0.991958] ide-gd driver 1.18
<7>[    0.992276] ahci 0000:00:12.0: version 3.0
<6>[    0.992301] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
IRQ 22
<4>[    0.992421] ahci 0000:00:12.0: ASUS M2A-VM: enabling 64bit DMA
<6>[    0.992622] ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3
Gbps 0xf impl SATA mode
<6>[    0.992745] ahci 0000:00:12.0: flags: 64bit ncq sntf ilck pm led
clo pmp pio slum part ccc
<6>[    0.994219] scsi0 : ahci
<6>[    0.994507] scsi1 : ahci
<6>[    0.994713] scsi2 : ahci
<6>[    0.994917] scsi3 : ahci
<6>[    0.995150] ata1: SATA max UDMA/133 abar m1024@0xfe02f000 port
0xfe02f100 irq 22
<6>[    0.995262] ata2: SATA max UDMA/133 abar m1024@0xfe02f000 port
0xfe02f180 irq 22
<6>[    0.995376] ata3: SATA max UDMA/133 abar m1024@0xfe02f000 port
0xfe02f200 irq 22
<6>[    0.995484] ata4: SATA max UDMA/133 abar m1024@0xfe02f000 port
0xfe02f280 irq 22
<6>[    0.995870] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
<6>[    0.995983] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)
-> IRQ 19
<7>[    0.996168] r8169 0000:02:00.0: setting latency timer to 64
<7>[    0.996220] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
<6>[    0.996462] r8169 0000:02:00.0: eth0: RTL8168b/8111b at
0xffffc9000000c000, 00:1b:fc:89:fa:a2, XID 18000000 IRQ 41
<6>[    0.996674] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
<6>[    0.996798] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
low) -> IRQ 19
<6>[    0.996918] ehci_hcd 0000:00:13.5: EHCI Host Controller
<6>[    0.997018] ehci_hcd 0000:00:13.5: new USB bus registered,
assigned bus number 1
<6>[    0.997166] ehci_hcd 0000:00:13.5: applying AMD SB600/SB700 USB
freeze workaround
<6>[    0.997287] ehci_hcd 0000:00:13.5: debug port 1
<6>[    0.997391] ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
<6>[    1.003023] ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00
<6>[    1.003309] hub 1-0:1.0: USB hub found
<6>[    1.003369] hub 1-0:1.0: 10 ports detected
<6>[    1.003556] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
<6>[    1.003664] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[    1.003773] ohci_hcd 0000:00:13.0: OHCI Host Controller
<6>[    1.003851] ohci_hcd 0000:00:13.0: new USB bus registered,
assigned bus number 2
<6>[    1.003984] ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
<6>[    1.059207] hub 2-0:1.0: USB hub found
<6>[    1.059270] hub 2-0:1.0: 2 ports detected
<6>[    1.059383] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[    1.059495] ohci_hcd 0000:00:13.1: OHCI Host Controller
<6>[    1.059572] ohci_hcd 0000:00:13.1: new USB bus registered,
assigned bus number 3
<6>[    1.063334] ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
<6>[    1.122203] hub 3-0:1.0: USB hub found
<6>[    1.126014] hub 3-0:1.0: 2 ports detected
<6>[    1.129803] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[    1.133602] ohci_hcd 0000:00:13.2: OHCI Host Controller
<6>[    1.137454] ohci_hcd 0000:00:13.2: new USB bus registered,
assigned bus number 4
<6>[    1.141325] ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
<6>[    1.200209] hub 4-0:1.0: USB hub found
<6>[    1.204130] hub 4-0:1.0: 2 ports detected
<6>[    1.208051] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[    1.211942] ohci_hcd 0000:00:13.3: OHCI Host Controller
<6>[    1.215738] ohci_hcd 0000:00:13.3: new USB bus registered,
assigned bus number 5
<6>[    1.219665] ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
<6>[    1.278204] hub 5-0:1.0: USB hub found
<6>[    1.281926] hub 5-0:1.0: 2 ports detected
<6>[    1.285776] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[    1.289667] ohci_hcd 0000:00:13.4: OHCI Host Controller
<6>[    1.293557] ohci_hcd 0000:00:13.4: new USB bus registered,
assigned bus number 6
<6>[    1.297488] ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe02a000
<6>[    1.356204] hub 6-0:1.0: USB hub found
<6>[    1.360008] hub 6-0:1.0: 2 ports detected
<6>[    1.364044] i8042: PNP: No PS/2 controller found. Probing ports
directly.
<6>[    1.368155] serio: i8042 KBD port at 0x60,0x64 irq 1
<6>[    1.371918] serio: i8042 AUX port at 0x60,0x64 irq 12
<6>[    1.375887] mousedev: PS/2 mouse device common for all mice
<4>[    1.379900] k8temp 0000:00:18.3: Temperature readouts might be
wrong - check erratum #141
<6>[    1.383843] md: linear personality registered for level -1
<6>[    1.387764] device-mapper: uevent: version 1.0.3
<6>[    1.391719] device-mapper: ioctl: 4.20.0-ioctl (2011-02-02)
initialised: dm-devel@redhat.com
<6>[    1.395598] Bluetooth: Generic Bluetooth USB driver ver 0.6
<6>[    1.399477] usbcore: registered new interface driver btusb
<6>[    1.403338] cpuidle: using governor ladder
<6>[    1.407202] cpuidle: using governor menu
<6>[    1.411541] ALSA device list:
<6>[    1.415399]   No soundcards found.
<6>[    1.419309] TCP cubic registered
<6>[    1.423213] NET: Registered protocol family 17
<6>[    1.427219] Bluetooth: RFCOMM TTY layer initialized
<6>[    1.431161] Bluetooth: RFCOMM socket layer initialized
<6>[    1.435071] Bluetooth: RFCOMM ver 1.11
<6>[    1.439010] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
<6>[    1.442858] Bluetooth: BNEP filters: protocol multicast
<6>[    1.446537] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
<3>[    1.455024] ata1: softreset failed (device not ready)
<4>[    1.458787] ata1: applying SB600 PMP SRST workaround and retrying
<3>[    1.462558] ata2: softreset failed (device not ready)
<4>[    1.466280] ata2: applying SB600 PMP SRST workaround and retrying
<3>[    1.470116] ata4: softreset failed (device not ready)
<4>[    1.473969] ata4: applying SB600 PMP SRST workaround and retrying
<3>[    1.477827] ata3: softreset failed (device not ready)
<4>[    1.481498] ata3: applying SB600 PMP SRST workaround and retrying
<6>[    1.590016] usb 3-2: new full speed USB device number 2 using ohci_hcd
<6>[    1.638030] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[    1.641985] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[    1.645837] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[    1.649605] ata4.00: ATAPI: TSSTcorp CDDVDW SH-S203P, SB00, max
UDMA/100
<6>[    1.653490] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.657345] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[    1.661405] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-11, max UDMA7
<6>[    1.665163] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth
31/32), AA
<6>[    1.669064] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.672995] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.676868] ata4.00: configured for UDMA/100
<6>[    1.681301] ata2.00: ATA-8: WDC WD15EADS-00P8B0, 01.00A01, max
UDMA/133
<6>[    1.685190] ata2.00: 2930277168 sectors, multi 1: LBA48 NCQ (depth
31/32), AA
<6>[    1.689087] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.693080] ata3.00: ATA-8: WDC WD3200BEVT-00ZCT0, 11.01A11, max
UDMA/133
<6>[    1.696913] ata3.00: 625142448 sectors, multi 1: LBA48 NCQ (depth
31/32), AA
<6>[    1.700766] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.704770] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.708679] ata1.00: configured for UDMA/133
<6>[    1.712541] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.716355] ata2.00: configured for UDMA/133
<6>[    1.720486] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[    1.724468] ata3.00: configured for UDMA/133
<5>[    1.724541] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG
HD501LJ  CR10 PQ: 0 ANSI: 5
<5>[    1.732364] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks:
(500 GB/465 GiB)
<5>[    1.732528] scsi 1:0:0:0: Direct-Access     ATA      WDC
WD15EADS-00P 01.0 PQ: 0 ANSI: 5
<5>[    1.732704] sd 1:0:0:0: [sdb] 2930277168 512-byte logical blocks:
(1.50 TB/1.36 TiB)
<5>[    1.732735] sd 1:0:0:0: [sdb] Write Protect is off
<7>[    1.732737] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
<5>[    1.732751] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
<6>[    1.743039]  sdb: sdb1 sdb2 sdb3 sdb4
<5>[    1.756499] scsi 2:0:0:0: Direct-Access     ATA      WDC
WD3200BEVT-0 11.0 PQ: 0 ANSI: 5
<5>[    1.756650] sd 1:0:0:0: [sdb] Attached SCSI disk
<5>[    1.764759] sd 0:0:0:0: [sda] Write Protect is off
<7>[    1.768964] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
<5>[    1.769022] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
<5>[    1.773535] sd 2:0:0:0: [sdc] 625142448 512-byte logical blocks:
(320 GB/298 GiB)
<5>[    1.777802] sd 2:0:0:0: [sdc] Write Protect is off
<7>[    1.781947] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
<5>[    1.781962] sd 2:0:0:0: [sdc] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
<5>[    1.782539] scsi 3:0:0:0: CD-ROM            TSSTcorp CDDVDW
SH-S203P  SB00 PQ: 0 ANSI: 5
<4>[    1.784894] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw
xa/form2 cdda tray
<6>[    1.784896] cdrom: Uniform CD-ROM driver Revision: 3.20
<7>[    1.785015] sr 3:0:0:0: Attached scsi CD-ROM sr0
<6>[    1.854600]  sda: sda1 sda2 sda3 sda4
<5>[    1.859331] sd 0:0:0:0: [sda] Attached SCSI disk
<6>[    1.871721]  sdc: sdc1 sdc2 sdc3 sdc4 < sdc5 sdc6 sdc7 sdc8 >
<5>[    1.876761] sd 2:0:0:0: [sdc] Attached SCSI disk
<3>[    1.881382] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
<6>[    1.885730] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core
Processor 5600+ (2 cpu cores) (version 2.20.00)
<6>[    1.890196] powernow-k8: fid 0x14 (2800 MHz), vid 0x8
<6>[    1.894612] powernow-k8: fid 0x12 (2600 MHz), vid 0xa
<6>[    1.898841] powernow-k8: fid 0x10 (2400 MHz), vid 0xc
<6>[    1.903236] powernow-k8: fid 0xe (2200 MHz), vid 0xe
<6>[    1.907640] powernow-k8: fid 0xc (2000 MHz), vid 0x10
<6>[    1.912020] powernow-k8: fid 0xa (1800 MHz), vid 0x10
<6>[    1.912032] usb 5-1: new low speed USB device number 2 using ohci_hcd
<6>[    1.920483] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
<6>[    1.925047] md: Skipping autodetection of RAID arrays.
(raid=autodetect will force)
<6>[    1.949435] EXT3-fs (sda3): recovery required on readonly filesystem
<6>[    1.953853] EXT3-fs (sda3): write access will be enabled during
recovery
<6>[    1.964129] EXT3-fs: barriers not enabled
<6>[    5.672996] kjournald starting.  Commit interval 5 seconds
<6>[    5.673113] EXT3-fs (sda3): recovery complete
<6>[    5.673438] EXT3-fs (sda3): mounted filesystem with writeback data
mode
<6>[    5.673472] VFS: Mounted root (ext3 filesystem) readonly on device
8:3.
<6>[    5.699651] Freeing unused kernel memory: 464k freed
<6>[    8.759054] udev[825]: starting version 164
<6>[    9.070985] input: PC Speaker as /devices/platform/pcspkr/input/input2
<6>[    9.105129] piix4_smbus 0000:00:14.0: SMBus Host Controller at
0xb00, revision 0
<6>[    9.167694] IT8716 SuperIO detected.
<6>[    9.168467] parport_pc 00:09: reported by Plug and Play ACPI
<6>[    9.168507] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
<6>[    9.225252] input: iMON Panel, Knob and Mouse(15c2:ffdc) as
/devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/input/input3
<6>[    9.240031] imon 5-1:1.0: 0xffdc iMON VFD, MCE IR (id 0x9e)
<6>[    9.241180] IR NEC protocol handler initialized
<6>[    9.310898] rtc_cmos 00:03: RTC can wake from S4
<6>[    9.311570] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
<6>[    9.311618] rtc0: alarms up to one month, 242 bytes nvram
<6>[    9.315102] atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev
0x00)
<6>[    9.315135] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[    9.315175] atiixp 0000:00:14.1: not 100% native mode: will probe
irqs later
<6>[    9.315188]     ide0: BM-DMA at 0xf900-0xf907
<7>[    9.315202] Probing IDE interface ide0...
<6>[    9.332497] IR RC5(x) protocol handler initialized
<6>[    9.355023] Registered IR keymap rc-imon-mce
<6>[    9.355272] input: iMON Remote (15c2:ffdc) as
/devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0/input4
<6>[    9.355374] rc0: iMON Remote (15c2:ffdc) as
/devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0
<6>[    9.358350] IR RC6 protocol handler initialized
<6>[    9.368121] imon 5-1:1.0: iMON device (15c2:ffdc, intf0) on
usb<5:2> initialized
<6>[    9.368164] usbcore: registered new interface driver imon
<6>[    9.400638] IR JVC protocol handler initialized
<6>[    9.453308] IR Sony protocol handler initialized
<5>[    9.466867] sd 0:0:0:0: Attached scsi generic sg0 type 0
<5>[    9.467050] sd 1:0:0:0: Attached scsi generic sg1 type 0
<5>[    9.467196] sd 2:0:0:0: Attached scsi generic sg2 type 0
<5>[    9.467339] sr 3:0:0:0: Attached scsi generic sg3 type 5
<6>[    9.475677] lirc_dev: IR Remote Control driver registered, major 252
<6>[    9.476314] IR LIRC bridge handler initialized
<6>[    9.686948] Linux video capture interface: v2.00
<6>[    9.754565] saa7130/34: v4l2 driver version 0.2.16 loaded
<6>[    9.754705] saa7134 0000:03:06.0: PCI INT A -> GSI 21 (level, low)
-> IRQ 21
<6>[    9.754720] saa7133[0]: found at 0000:03:06.0, rev: 209, irq: 21,
latency: 64, mmio: 0xfdeff000
<6>[    9.754735] saa7133[0]: subsystem: 11bd:002f, board: Pinnacle PCTV
310i [card=101,autodetected]
<6>[    9.754779] saa7133[0]: board init: gpio is 600c000
<6>[    9.829192] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
<6>[    9.829365] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<4>[    9.857170] saa7133[0]: i2c eeprom read error (err=-5)
<4>[    9.864782] i2c-core: driver [tuner] using legacy suspend method
<4>[    9.864788] i2c-core: driver [tuner] using legacy resume method
<6>[   10.015040] tuner 5-004b: Tuner -1 found with type(s) Radio TV.
<6>[   10.050047] tda829x 5-004b: setting tuner address to 61
<6>[   10.134620] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
low) -> IRQ 19
<7>[   10.134711] HDA Intel 0000:01:05.2: irq 42 for MSI/MSI-X
<6>[   10.427263] tda829x 5-004b: ANDERS: setting switch_addr. was 0x00,
new 0x4b
<6>[   10.427267] tda829x 5-004b: ANDERS: new 0x61
<6>[   10.433019] tda829x 5-004b: type set to tda8290+75a
<4>[   13.141011] hda-intel: azx_get_response timeout, switching to
polling mode: last cmd=0x000f0000
<6>[   13.440092] saa7133[0]: registered device video0 [v4l2]
<6>[   13.440134] saa7133[0]: registered device vbi0
<6>[   13.440173] saa7133[0]: registered device radio0
<6>[   13.461328] dvb_init() allocating 1 frontend
<6>[   13.486029] DVB: registering new adapter (saa7133[0])
<4>[   13.486034] DVB: registering adapter 0 frontend 0 (Philips
TDA10046H DVB-T)...
<6>[   13.576022] tda1004x: setting up plls for 48MHz sampling clock
<4>[   14.142014] hda-intel: No response from codec, disabling MSI: last
cmd=0x000f0000
<4>[   15.143013] hda-intel: Codec #0 probe error; disabling it...
<3>[   15.763019] tda1004x: timeout waiting for DSP ready
<6>[   15.773018] tda1004x: found firmware revision 0 -- invalid
<6>[   15.773020] tda1004x: trying to boot from eeprom
<3>[   17.254013] hda_intel: azx_get_response timeout, switching to
single_cmd mode: last cmd=0x00070503
<3>[   17.255760] hda-codec: No codec parser is available
<3>[   18.082025] tda1004x: timeout waiting for DSP ready
<6>[   18.092020] tda1004x: found firmware revision 0 -- invalid
<6>[   18.092026] tda1004x: waiting for firmware upload...
<3>[   18.118452] tda1004x: no firmware upload (timeout or file not found?)
<4>[   18.118460] tda1004x: firmware upload failed
<6>[   18.234369] saa7134 ALSA driver for DMA sound loaded
<6>[   18.234422] saa7133[0]/alsa: saa7133[0] at 0xfdeff000 irq 21
registered as card -1
<6>[  123.401657] EXT3-fs (sda3): using internal journal
<6>[  123.497638] EXT3-fs: barriers not enabled
<6>[  123.499920] kjournald starting.  Commit interval 5 seconds
<6>[  123.500171] EXT3-fs (sda1): using internal journal
<6>[  123.500177] EXT3-fs (sda1): mounted filesystem with writeback data
mode
<6>[  123.522276] EXT3-fs: barriers not enabled
<6>[  123.535056] kjournald starting.  Commit interval 5 seconds
<6>[  123.535316] EXT3-fs (dm-1): using internal journal
<6>[  123.535321] EXT3-fs (dm-1): mounted filesystem with writeback data
mode
<6>[  123.615085] EXT3-fs: barriers not enabled
<6>[  123.623655] kjournald starting.  Commit interval 5 seconds
<6>[  123.623915] EXT3-fs (dm-2): using internal journal
<6>[  123.623921] EXT3-fs (dm-2): mounted filesystem with writeback data
mode
<6>[  123.642807] EXT3-fs: barriers not enabled
<6>[  123.655732] kjournald starting.  Commit interval 5 seconds
<6>[  123.656015] EXT3-fs (dm-3): using internal journal
<6>[  123.656019] EXT3-fs (dm-3): mounted filesystem with writeback data
mode
<6>[  123.687999] EXT4-fs (dm-4): mounted filesystem with ordered data
mode. Opts: (null)
<6>[  124.282363] EXT4-fs (dm-7): mounted filesystem with ordered data
mode. Opts: (null)
<6>[  124.322028] EXT3-fs: barriers not enabled
<6>[  124.322244] kjournald starting.  Commit interval 5 seconds
<6>[  124.322526] EXT3-fs (dm-5): using internal journal
<6>[  124.322537] EXT3-fs (dm-5): mounted filesystem with writeback data
mode
<6>[  124.329990] EXT4-fs (dm-6): mounted filesystem with ordered data
mode. Opts: (null)
<6>[  124.407283] EXT4-fs (dm-0): mounted filesystem without journal.
Opts: (null)
<6>[  127.129515] Adding 10490440k swap on /dev/sda2.  Priority:-1
extents:1 across:10490440k
<6>[  127.678487] r8169 0000:02:00.0: eth0: link down
<6>[  127.678503] r8169 0000:02:00.0: eth0: link down
<6>[  129.365902] r8169 0000:02:00.0: eth0: link up
<6>[  171.282065] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  171.386069] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  173.234070] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  173.338065] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  173.954065] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[  174.058084] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[  174.674063] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  174.778100] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  175.530065] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  175.634074] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  179.386066] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  179.498071] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  180.290066] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  180.394068] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  184.250069] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[  184.354078] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[  185.258067] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  185.362074] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  186.890071] intf0 decoded packet: 80 0f 84 06 00 00 9e ae
<6>[  189.274083] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  189.378074] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  191.234071] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[  191.338078] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[  192.770070] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[  192.874080] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[  196.986072] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[  197.098072] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[  198.338069] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  198.442083] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[  199.970068] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  200.082078] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[  201.218071] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  201.322071] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[  206.738077] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[  206.842078] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[  206.946084] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[  207.050080] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[  207.338076] intf0 decoded packet: 80 0f 04 10 00 00 9e ae
<6>[  207.442082] intf0 decoded packet: 80 0f 04 10 00 00 9e ae
<6>[  223.279082] intf0 decoded packet: 80 0f 84 13 00 00 9e ae
<6>[  223.391043] intf0 decoded packet: 80 0f 84 13 00 00 9e ae
<6>[  223.494983] intf0 decoded packet: 80 0f 84 13 00 00 9e ae
<6>[  224.774341] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  224.878280] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  224.990227] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  225.094182] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  225.198122] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  225.302618] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[  225.637910] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[  225.741873] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[ 1646.807231] intf0 decoded packet: 80 0f 04 23 00 00 9e ae
<6>[ 1646.911189] intf0 decoded packet: 80 0f 04 23 00 00 9e ae
<6>[ 1650.893187] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1651.005148] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1651.572846] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1651.684821] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1653.036118] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1653.140084] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1653.252013] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1653.355952] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1655.522876] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1655.626821] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1655.738777] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1656.242515] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1656.346466] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1656.450422] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1657.521872] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1657.625831] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1661.375946] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1661.479901] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1662.423419] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1662.527378] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1664.998140] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1665.102098] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1667.261005] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1667.364961] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1668.796234] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1668.900203] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1670.411430] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1670.515385] intf0 decoded packet: 80 0f 04 20 00 00 9e ae
<6>[ 1673.226028] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1673.329973] intf0 decoded packet: 80 0f 84 20 00 00 9e ae
<6>[ 1674.785238] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1674.889209] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1675.552856] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1675.656816] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1676.056607] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1676.168558] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1676.272505] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1676.552351] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1676.656335] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[ 1677.335965] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1677.439931] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[ 1679.702780] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[ 1679.806733] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[ 1688.362459] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[ 1688.466417] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[ 1690.625320] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[ 1690.737270] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[ 1692.304479] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[ 1692.416429] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44908.797194] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44908.799268] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44908.799277] ata1.00: configured for UDMA/133
<6>[44908.799286] ata1: EH complete
<6>[44909.041914] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44909.046048] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44909.046056] ata2.00: configured for UDMA/133
<6>[44909.046062] ata2: EH complete
<6>[44911.273472] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44911.274490] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44911.274502] ata3.00: configured for UDMA/133
<6>[44911.274516] ata3: EH complete
<6>[44912.015955] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[44912.023998] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[44912.038195] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[44912.046140] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<6>[44912.646998] PM: Syncing filesystems ... done.
<4>[44912.787379] Freezing user space processes ...
<3>[44912.787703] imon:send_packet: task interrupted
<3>[44912.792021] imon:send_packet: task interrupted
<3>[44912.797020] imon:send_packet: task interrupted
<4>[44912.809020] (elapsed 0.02 seconds) done.
<4>[44912.809022] Freezing remaining freezable tasks ... (elapsed 0.01
seconds) done.
<4>[44912.820034] Suspending console(s) (use no_console_suspend to debug)
<5>[44912.820501] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
<5>[44912.820566] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
<5>[44912.820608] sd 0:0:0:0: [sda] Synchronizing SCSI cache
<5>[44912.820708] sd 2:0:0:0: [sdc] Stopping disk
<5>[44912.820714] sd 1:0:0:0: [sdb] Stopping disk
<6>[44912.820748] parport_pc 00:09: disabled
<6>[44912.820812] serial 00:08: disabled
<6>[44912.820836] serial 00:08: wake-up capability disabled by ACPI
<7>[44912.820939] ACPI handle has no context!
<5>[44912.821021] sd 0:0:0:0: [sda] Stopping disk
<6>[44912.821396] r8169 0000:02:00.0: eth0: link down
<6>[44912.822136] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
<6>[44912.822171] ehci_hcd 0000:00:13.5: PCI INT D disabled
<6>[44912.822181] ohci_hcd 0000:00:13.4: PCI INT C disabled
<6>[44912.822213] ohci_hcd 0000:00:13.2: PCI INT C disabled
<6>[44912.822244] ohci_hcd 0000:00:13.0: PCI INT A disabled
<6>[44912.831071] ohci_hcd 0000:00:13.3: PCI INT B disabled
<6>[44912.833076] ohci_hcd 0000:00:13.1: PCI INT B disabled
<6>[44912.839702] radeon 0000:01:05.0: PCI INT A disabled
<6>[44912.922023] HDA Intel 0000:01:05.2: PCI INT B disabled
<7>[44912.922033] ACPI handle has no context!
<6>[44912.923085] HDA Intel 0000:00:14.2: PCI INT A disabled
<6>[44913.524829] ahci 0000:00:12.0: PCI INT A disabled
<6>[44913.524856] PM: suspend of devices complete after 704.537 msecs
<7>[44913.525052] r8169 0000:02:00.0: PME# enabled
<6>[44913.525058] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
<6>[44913.547136] PM: late suspend of devices complete after 22.276 msecs
<6>[44913.547325] ACPI: Preparing to enter system sleep state S3
<6>[44913.547404] PM: Saving platform NVS memory
<4>[44913.547435] Disabling non-boot CPUs ...
<6>[44913.548829] CPU 1 is now offline
<6>[44913.549333] ACPI: Low-level resume complete
<6>[44913.549333] PM: Restoring platform NVS memory
<6>[44913.549333] Enabling non-boot CPUs ...
<6>[44913.551570] Booting Node 0 Processor 1 APIC 0x1
<7>[44913.551572] smpboot cpu 1: start_ip = 9a000
<6>[44913.622285] CPU1 is up
<6>[44913.622511] ACPI: Waking up from system sleep state S3
<7>[44913.622634] pci 0000:00:00.0: restoring config space at offset 0x3
(was 0x0, writing 0x4000)
<7>[44913.622658] pcieport 0000:00:07.0: restoring config space at
offset 0x1 (was 0x100007, writing 0x100407)
<7>[44913.622692] ahci 0000:00:12.0: restoring config space at offset
0x2 (was 0x1018f00, writing 0x1060100)
<6>[44913.622709] ahci 0000:00:12.0: set SATA to AHCI mode
<7>[44913.622731] ohci_hcd 0000:00:13.0: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[44913.622757] ohci_hcd 0000:00:13.1: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[44913.622782] ohci_hcd 0000:00:13.2: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[44913.622807] ohci_hcd 0000:00:13.3: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[44913.622833] ohci_hcd 0000:00:13.4: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[44913.622864] ehci_hcd 0000:00:13.5: restoring config space at
offset 0x1 (was 0x2b00000, writing 0x2b00013)
<7>[44913.622949] HDA Intel 0000:00:14.2: restoring config space at
offset 0x1 (was 0x4100006, writing 0x4100002)
<6>[44913.623024] Switched to NOHz mode on CPU #1
<7>[44913.623051] HDA Intel 0000:01:05.2: restoring config space at
offset 0xf (was 0x200, writing 0x20a)
<7>[44913.623057] HDA Intel 0000:01:05.2: restoring config space at
offset 0x4 (was 0x4, writing 0xfdbfc004)
<7>[44913.623060] HDA Intel 0000:01:05.2: restoring config space at
offset 0x3 (was 0x0, writing 0x4008)
<7>[44913.623063] HDA Intel 0000:01:05.2: restoring config space at
offset 0x1 (was 0x100000, writing 0x100002)
<7>[44913.623086] r8169 0000:02:00.0: restoring config space at offset
0xf (was 0x100, writing 0x10a)
<7>[44913.623100] r8169 0000:02:00.0: restoring config space at offset
0x6 (was 0x4, writing 0xfdfff004)
<7>[44913.623106] r8169 0000:02:00.0: restoring config space at offset
0x4 (was 0x1, writing 0xee01)
<7>[44913.623110] r8169 0000:02:00.0: restoring config space at offset
0x3 (was 0x0, writing 0x8)
<7>[44913.623116] r8169 0000:02:00.0: restoring config space at offset
0x1 (was 0x100000, writing 0x100407)
<7>[44913.623175] saa7134 0000:03:06.0: restoring config space at offset
0x4 (was 0x0, writing 0xfdeff000)
<7>[44913.623181] saa7134 0000:03:06.0: restoring config space at offset
0x3 (was 0xff00, writing 0x4000)
<7>[44913.623187] saa7134 0000:03:06.0: restoring config space at offset
0x1 (was 0x2900000, writing 0x2900006)
<7>[44913.623209] pci 0000:03:07.0: restoring config space at offset 0xf
(was 0x200001ff, writing 0x2000010b)
<7>[44913.623229] pci 0000:03:07.0: restoring config space at offset 0x5
(was 0x1, writing 0xcf01)
<7>[44913.623234] pci 0000:03:07.0: restoring config space at offset 0x4
(was 0xfdeff000, writing 0xfdefe000)
<7>[44913.623240] pci 0000:03:07.0: restoring config space at offset 0x3
(was 0x4000, writing 0x4008)
<7>[44913.623247] pci 0000:03:07.0: restoring config space at offset 0x1
(was 0x2100006, writing 0x2100007)
<6>[44913.623388] PM: early resume of devices complete after 0.779 msecs
<6>[44913.623562] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
-> IRQ 18
<6>[44913.623566] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
low) -> IRQ 19
<6>[44913.623650] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
IRQ 22
<6>[44913.623725] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[44913.623743] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[44913.623763] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[44913.623782] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[44913.623801] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[44913.623820] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
low) -> IRQ 19
<6>[44913.623867] saa7133[0]: board init: gpio is 600e000
<6>[44913.623886] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
<7>[44913.623892] r8169 0000:02:00.0: PME# disabled
<5>[44913.623969] sd 0:0:0:0: [sda] Starting disk
<5>[44913.624027] sd 1:0:0:0: [sdb] Starting disk
<5>[44913.624056] sd 2:0:0:0: [sdc] Starting disk
<6>[44913.625048] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[44913.625057] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[44913.625462] serial 00:08: activated
<6>[44913.625754] parport_pc 00:09: activated
<6>[44913.630075] r8169 0000:02:00.0: eth0: link down
<6>[44913.711038] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
<6>[44913.717102] radeon 0000:01:05.0: WB enabled
<6>[44913.717116] [drm] radeon: ring at 0x0000000080001000
<6>[44913.717135] [drm] ring test succeeded in 1 usecs
<6>[44913.717146] [drm] ib test succeeded in 0 usecs
<3>[44914.083015] ata4: softreset failed (device not ready)
<4>[44914.083018] ata4: applying SB600 PMP SRST workaround and retrying
<6>[44914.238031] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[44914.239504] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44914.282056] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44914.282060] ata4.00: configured for UDMA/100
<6>[44915.292241] r8169 0000:02:00.0: eth0: link up
<3>[44916.786023] ata3: softreset failed (device not ready)
<4>[44916.786026] ata3: applying SB600 PMP SRST workaround and retrying
<6>[44916.941033] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[44916.976557] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44916.977518] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44916.977521] ata3.00: configured for UDMA/133
<3>[44921.376025] ata1: softreset failed (device not ready)
<4>[44921.376028] ata1: applying SB600 PMP SRST workaround and retrying
<6>[44921.531034] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[44921.539418] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44921.541434] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44921.541436] ata1.00: configured for UDMA/133
<3>[44922.192024] ata2: softreset failed (device not ready)
<4>[44922.192027] ata2: applying SB600 PMP SRST workaround and retrying
<6>[44922.347035] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[44924.057237] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44924.060607] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44924.060609] ata2.00: configured for UDMA/133
<6>[44925.055047] PM: resume of devices complete after 11431.580 msecs
<4>[44925.055223] Restarting tasks ... done.
<6>[44925.277179] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44925.279217] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44925.279220] ata1.00: configured for UDMA/133
<6>[44925.279224] ata1: EH complete
<6>[44925.595642] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44925.599039] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44925.599046] ata2.00: configured for UDMA/133
<6>[44925.599054] ata2: EH complete
<6>[44926.007757] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44926.008768] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[44926.008774] ata3.00: configured for UDMA/133
<6>[44926.008782] ata3: EH complete
<6>[44926.196640] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[44926.203707] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[44926.216609] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[44926.222988] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<6>[44949.232271] intf0 decoded packet: 28 90 00 80 00 00 9e ae
<6>[44949.336215] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44949.440168] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44953.254261] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[44954.509631] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44954.621566] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44956.220775] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44956.324734] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44956.428670] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44956.540613] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44957.028372] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44957.132327] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44959.771000] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[44959.874944] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[44961.730026] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44961.841978] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44961.945917] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44962.049858] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44963.329223] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[44963.433185] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[44964.736516] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44964.840459] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44966.383704] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44966.487658] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44967.095338] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44967.207293] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44972.156808] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44972.260756] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[44976.650556] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44976.754535] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[44978.737521] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44978.841476] intf0 decoded packet: 80 0f 04 1f 00 00 9e ae
<6>[44979.864952] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[44979.976910] intf0 decoded packet: 80 0f 84 22 00 00 9e ae
<6>[44999.894936] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45000.006883] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45525.384161] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[45525.496118] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[45526.487608] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45526.591567] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45722.013843] intf0 decoded packet: 80 0f 84 23 00 00 9e ae
<6>[45722.125785] intf0 decoded packet: 80 0f 84 23 00 00 9e ae
<6>[45722.229718] intf0 decoded packet: 80 0f 84 23 00 00 9e ae
<6>[45726.595543] intf0 decoded packet: 80 0f 04 23 00 00 9e ae
<6>[45726.707487] intf0 decoded packet: 80 0f 04 23 00 00 9e ae
<6>[45729.186250] intf0 decoded packet: 80 0f 84 23 00 00 9e ae
<6>[45729.298215] intf0 decoded packet: 80 0f 84 23 00 00 9e ae
<6>[45733.656011] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45733.759985] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45734.935371] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[45735.047343] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[45738.109785] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45738.221759] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45740.884398] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[45740.996365] intf0 decoded packet: 80 0f 84 1f 00 00 9e ae
<6>[45742.403638] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45742.507582] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45744.362657] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[45744.466617] intf0 decoded packet: 80 0f 84 21 00 00 9e ae
<6>[45745.186246] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45745.290207] intf0 decoded packet: 80 0f 04 21 00 00 9e ae
<6>[45750.759460] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[45750.863411] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[45751.151268] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[45751.255221] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[45751.734971] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[45751.838943] intf0 decoded packet: 80 0f 04 1e 00 00 9e ae
<6>[45752.118781] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[45752.230736] intf0 decoded packet: 80 0f 84 1e 00 00 9e ae
<6>[45753.805934] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45753.909889] intf0 decoded packet: 80 0f 04 22 00 00 9e ae
<6>[45757.340173] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.444127] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.548074] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.652036] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.763967] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.868135] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45757.971861] intf0 decoded packet: 80 0f 84 10 00 00 9e ae
<6>[45758.251717] intf0 decoded packet: 80 0f 04 10 00 00 9e ae
<6>[45758.363667] intf0 decoded packet: 80 0f 04 10 00 00 9e ae
<6>[45760.410644] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[45760.514593] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[45760.802438] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[45760.906395] intf0 decoded packet: 80 0f 04 11 00 00 9e ae
<6>[45761.194243] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[45761.298199] intf0 decoded packet: 80 0f 84 11 00 00 9e ae
<6>[47553.505767] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47553.507839] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47553.507848] ata1.00: configured for UDMA/133
<6>[47553.507855] ata1: EH complete
<6>[47554.205223] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47554.209713] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47554.209722] ata2.00: configured for UDMA/133
<6>[47554.209729] ata2: EH complete
<6>[47554.274815] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47554.275826] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47554.275832] ata3.00: configured for UDMA/133
<6>[47554.275840] ata3: EH complete
<6>[47554.589304] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[47554.596494] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[47554.609745] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[47554.616577] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<6>[47555.094017] PM: Syncing filesystems ... done.
<4>[47555.232423] Freezing user space processes ...
<3>[47555.232672] imon:send_packet: task interrupted
<3>[47555.237012] imon:send_packet: task interrupted
<4>[47555.243047] (elapsed 0.01 seconds) done.
<4>[47555.243050] Freezing remaining freezable tasks ... (elapsed 0.01
seconds) done.
<4>[47555.254037] Suspending console(s) (use no_console_suspend to debug)
<5>[47555.285166] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
<5>[47555.285229] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
<5>[47555.285276] sd 0:0:0:0: [sda] Synchronizing SCSI cache
<5>[47555.285364] sd 1:0:0:0: [sdb] Stopping disk
<5>[47555.285368] sd 2:0:0:0: [sdc] Stopping disk
<6>[47555.285477] parport_pc 00:09: disabled
<6>[47555.285536] serial 00:08: disabled
<6>[47555.285557] serial 00:08: wake-up capability disabled by ACPI
<7>[47555.285664] ACPI handle has no context!
<5>[47555.285675] sd 0:0:0:0: [sda] Stopping disk
<6>[47555.285959] HDA Intel 0000:01:05.2: PCI INT B disabled
<7>[47555.285968] ACPI handle has no context!
<6>[47555.286132] r8169 0000:02:00.0: eth0: link down
<6>[47555.287319] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
<6>[47555.287351] ehci_hcd 0000:00:13.5: PCI INT D disabled
<6>[47555.287360] ohci_hcd 0000:00:13.4: PCI INT C disabled
<6>[47555.287391] ohci_hcd 0000:00:13.2: PCI INT C disabled
<6>[47555.287421] ohci_hcd 0000:00:13.0: PCI INT A disabled
<6>[47555.297044] ohci_hcd 0000:00:13.3: PCI INT B disabled
<6>[47555.299044] ohci_hcd 0000:00:13.1: PCI INT B disabled
<6>[47555.319442] radeon 0000:01:05.0: PCI INT A disabled
<6>[47555.388074] HDA Intel 0000:00:14.2: PCI INT A disabled
<6>[47555.978395] ahci 0000:00:12.0: PCI INT A disabled
<6>[47555.978421] PM: suspend of devices complete after 724.110 msecs
<7>[47555.978640] r8169 0000:02:00.0: PME# enabled
<6>[47555.978652] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
<6>[47556.000162] PM: late suspend of devices complete after 21.736 msecs
<6>[47556.000362] ACPI: Preparing to enter system sleep state S3
<6>[47556.000443] PM: Saving platform NVS memory
<4>[47556.000489] Disabling non-boot CPUs ...
<6>[47556.001906] CPU 1 is now offline
<6>[47556.002207] ACPI: Low-level resume complete
<6>[47556.002207] PM: Restoring platform NVS memory
<6>[47556.002207] Enabling non-boot CPUs ...
<6>[47556.004453] Booting Node 0 Processor 1 APIC 0x1
<7>[47556.004455] smpboot cpu 1: start_ip = 9a000
<6>[47556.075260] CPU1 is up
<6>[47556.075488] ACPI: Waking up from system sleep state S3
<7>[47556.075610] pci 0000:00:00.0: restoring config space at offset 0x3
(was 0x0, writing 0x4000)
<7>[47556.075634] pcieport 0000:00:07.0: restoring config space at
offset 0x1 (was 0x100007, writing 0x100407)
<7>[47556.075668] ahci 0000:00:12.0: restoring config space at offset
0x2 (was 0x1018f00, writing 0x1060100)
<6>[47556.075685] ahci 0000:00:12.0: set SATA to AHCI mode
<7>[47556.075707] ohci_hcd 0000:00:13.0: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47556.075733] ohci_hcd 0000:00:13.1: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47556.075758] ohci_hcd 0000:00:13.2: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47556.075783] ohci_hcd 0000:00:13.3: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47556.075808] ohci_hcd 0000:00:13.4: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47556.075840] ehci_hcd 0000:00:13.5: restoring config space at
offset 0x1 (was 0x2b00000, writing 0x2b00013)
<7>[47556.075925] HDA Intel 0000:00:14.2: restoring config space at
offset 0x1 (was 0x4100006, writing 0x4100002)
<6>[47556.076024] Switched to NOHz mode on CPU #1
<7>[47556.076028] HDA Intel 0000:01:05.2: restoring config space at
offset 0xf (was 0x200, writing 0x20a)
<7>[47556.076035] HDA Intel 0000:01:05.2: restoring config space at
offset 0x4 (was 0x4, writing 0xfdbfc004)
<7>[47556.076038] HDA Intel 0000:01:05.2: restoring config space at
offset 0x3 (was 0x0, writing 0x4008)
<7>[47556.076041] HDA Intel 0000:01:05.2: restoring config space at
offset 0x1 (was 0x100000, writing 0x100002)
<7>[47556.076064] r8169 0000:02:00.0: restoring config space at offset
0xf (was 0x100, writing 0x10a)
<7>[47556.076078] r8169 0000:02:00.0: restoring config space at offset
0x6 (was 0x4, writing 0xfdfff004)
<7>[47556.076084] r8169 0000:02:00.0: restoring config space at offset
0x4 (was 0x1, writing 0xee01)
<7>[47556.076088] r8169 0000:02:00.0: restoring config space at offset
0x3 (was 0x0, writing 0x8)
<7>[47556.076094] r8169 0000:02:00.0: restoring config space at offset
0x1 (was 0x100000, writing 0x100407)
<7>[47556.076152] saa7134 0000:03:06.0: restoring config space at offset
0x4 (was 0x0, writing 0xfdeff000)
<7>[47556.076158] saa7134 0000:03:06.0: restoring config space at offset
0x3 (was 0xff00, writing 0x4000)
<7>[47556.076165] saa7134 0000:03:06.0: restoring config space at offset
0x1 (was 0x2900000, writing 0x2900006)
<7>[47556.076186] pci 0000:03:07.0: restoring config space at offset 0xf
(was 0x200001ff, writing 0x2000010b)
<7>[47556.076206] pci 0000:03:07.0: restoring config space at offset 0x5
(was 0x1, writing 0xcf01)
<7>[47556.076211] pci 0000:03:07.0: restoring config space at offset 0x4
(was 0xfdeff000, writing 0xfdefe000)
<7>[47556.076217] pci 0000:03:07.0: restoring config space at offset 0x3
(was 0x4000, writing 0x4008)
<7>[47556.076224] pci 0000:03:07.0: restoring config space at offset 0x1
(was 0x2100006, writing 0x2100007)
<6>[47556.076366] PM: early resume of devices complete after 0.781 msecs
<6>[47556.076490] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
IRQ 22
<6>[47556.076554] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47556.076577] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[47556.076631] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[47556.076652] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[47556.076660] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[47556.076710] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
-> IRQ 18
<6>[47556.076713] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
low) -> IRQ 19
<6>[47556.076757] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
low) -> IRQ 19
<6>[47556.076836] saa7133[0]: board init: gpio is 600c000
<6>[47556.076843] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
<7>[47556.076848] r8169 0000:02:00.0: PME# disabled
<5>[47556.077031] sd 0:0:0:0: [sda] Starting disk
<5>[47556.077069] sd 1:0:0:0: [sdb] Starting disk
<5>[47556.077098] sd 2:0:0:0: [sdc] Starting disk
<6>[47556.078033] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47556.078045] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47556.078422] serial 00:08: activated
<6>[47556.078718] parport_pc 00:09: activated
<6>[47556.083077] r8169 0000:02:00.0: eth0: link down
<6>[47556.164028] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
<6>[47556.170055] radeon 0000:01:05.0: WB enabled
<6>[47556.170068] [drm] radeon: ring at 0x0000000080001000
<6>[47556.170087] [drm] ring test succeeded in 1 usecs
<6>[47556.170098] [drm] ib test succeeded in 0 usecs
<6>[47556.211006] intf0 decoded packet: 01 00 00 00 ff ff 9e ee
<3>[47556.536014] ata4: softreset failed (device not ready)
<4>[47556.536017] ata4: applying SB600 PMP SRST workaround and retrying
<6>[47556.691026] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[47556.710679] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47556.753244] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47556.753247] ata4.00: configured for UDMA/100
<6>[47557.808115] r8169 0000:02:00.0: eth0: link up
<3>[47559.189025] ata3: softreset failed (device not ready)
<4>[47559.189028] ata3: applying SB600 PMP SRST workaround and retrying
<6>[47559.344027] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47559.372966] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47559.373921] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47559.373923] ata3.00: configured for UDMA/133
<3>[47563.727019] ata1: softreset failed (device not ready)
<4>[47563.727022] ata1: applying SB600 PMP SRST workaround and retrying
<6>[47563.882023] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47563.902605] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47563.904621] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47563.904623] ata1.00: configured for UDMA/133
<3>[47564.645016] ata2: softreset failed (device not ready)
<4>[47564.645018] ata2: applying SB600 PMP SRST workaround and retrying
<6>[47564.800023] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47566.511349] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47566.514713] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47566.514715] ata2.00: configured for UDMA/133
<6>[47567.509047] PM: resume of devices complete after 11432.604 msecs
<4>[47567.509217] Restarting tasks ... done.
<6>[47567.733097] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47567.735138] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47567.735141] ata1.00: configured for UDMA/133
<6>[47567.735145] ata1: EH complete
<6>[47568.049754] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47568.053137] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47568.053144] ata2.00: configured for UDMA/133
<6>[47568.053151] ata2: EH complete
<6>[47568.504124] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47568.505302] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47568.505305] ata3.00: configured for UDMA/133
<6>[47568.505309] ata3: EH complete
<6>[47568.601168] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[47568.605308] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[47568.610641] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[47568.619053] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<6>[47709.024059] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.026136] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.026145] ata1.00: configured for UDMA/133
<6>[47709.026153] ata1: EH complete
<6>[47709.703486] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.707075] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.707082] ata2.00: configured for UDMA/133
<6>[47709.707090] ata2: EH complete
<6>[47709.770233] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.771263] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47709.771275] ata3.00: configured for UDMA/133
<6>[47709.771287] ata3: EH complete
<6>[47709.974492] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[47709.981636] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[47709.994922] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[47710.001968] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<6>[47710.411658] PM: Syncing filesystems ... done.
<4>[47710.550415] Freezing user space processes ...
<3>[47710.550576] imon:send_packet: task interrupted
<3>[47710.555013] imon:send_packet: task interrupted
<3>[47710.560011] imon:send_packet: task interrupted
<4>[47710.572019] (elapsed 0.02 seconds) done.
<4>[47710.572021] Freezing remaining freezable tasks ... (elapsed 0.01
seconds) done.
<4>[47710.583035] Suspending console(s) (use no_console_suspend to debug)
<5>[47710.614121] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
<5>[47710.614174] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
<5>[47710.614179] sd 0:0:0:0: [sda] Synchronizing SCSI cache
<5>[47710.614306] sd 2:0:0:0: [sdc] Stopping disk
<5>[47710.614321] sd 1:0:0:0: [sdb] Stopping disk
<6>[47710.614513] parport_pc 00:09: disabled
<5>[47710.614577] sd 0:0:0:0: [sda] Stopping disk
<6>[47710.614583] serial 00:08: disabled
<6>[47710.614604] serial 00:08: wake-up capability disabled by ACPI
<7>[47710.614696] ACPI handle has no context!
<6>[47710.614910] HDA Intel 0000:01:05.2: PCI INT B disabled
<7>[47710.614920] ACPI handle has no context!
<6>[47710.615089] r8169 0000:02:00.0: eth0: link down
<6>[47710.619613] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
<6>[47710.619645] ehci_hcd 0000:00:13.5: PCI INT D disabled
<6>[47710.619653] ohci_hcd 0000:00:13.4: PCI INT C disabled
<6>[47710.619665] ohci_hcd 0000:00:13.2: PCI INT C disabled
<6>[47710.619679] ohci_hcd 0000:00:13.0: PCI INT A disabled
<6>[47710.625049] ohci_hcd 0000:00:13.3: PCI INT B disabled
<6>[47710.627049] ohci_hcd 0000:00:13.1: PCI INT B disabled
<6>[47710.638797] radeon 0000:01:05.0: PCI INT A disabled
<6>[47710.720134] HDA Intel 0000:00:14.2: PCI INT A disabled
<6>[47711.308904] ahci 0000:00:12.0: PCI INT A disabled
<6>[47711.308923] PM: suspend of devices complete after 725.617 msecs
<7>[47711.309164] r8169 0000:02:00.0: PME# enabled
<6>[47711.309174] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
<6>[47711.331161] PM: late suspend of devices complete after 22.233 msecs
<6>[47711.331348] ACPI: Preparing to enter system sleep state S3
<6>[47711.331427] PM: Saving platform NVS memory
<4>[47711.331460] Disabling non-boot CPUs ...
<6>[47711.332845] CPU 1 is now offline
<6>[47711.333240] ACPI: Low-level resume complete
<6>[47711.333240] PM: Restoring platform NVS memory
<6>[47711.333240] Enabling non-boot CPUs ...
<6>[47711.335472] Booting Node 0 Processor 1 APIC 0x1
<7>[47711.335474] smpboot cpu 1: start_ip = 9a000
<6>[47711.406291] CPU1 is up
<6>[47711.406521] ACPI: Waking up from system sleep state S3
<7>[47711.406624] pci 0000:00:00.0: restoring config space at offset 0x3
(was 0x0, writing 0x4000)
<7>[47711.406648] pcieport 0000:00:07.0: restoring config space at
offset 0x1 (was 0x100007, writing 0x100407)
<7>[47711.406682] ahci 0000:00:12.0: restoring config space at offset
0x2 (was 0x1018f00, writing 0x1060100)
<6>[47711.406700] ahci 0000:00:12.0: set SATA to AHCI mode
<7>[47711.406722] ohci_hcd 0000:00:13.0: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47711.406748] ohci_hcd 0000:00:13.1: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47711.406774] ohci_hcd 0000:00:13.2: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47711.406799] ohci_hcd 0000:00:13.3: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47711.406825] ohci_hcd 0000:00:13.4: restoring config space at
offset 0x1 (was 0x2a00007, writing 0x2a00003)
<7>[47711.406857] ehci_hcd 0000:00:13.5: restoring config space at
offset 0x1 (was 0x2b00000, writing 0x2b00013)
<7>[47711.406943] HDA Intel 0000:00:14.2: restoring config space at
offset 0x1 (was 0x4100006, writing 0x4100002)
<6>[47711.407025] Switched to NOHz mode on CPU #1
<7>[47711.407050] HDA Intel 0000:01:05.2: restoring config space at
offset 0xf (was 0x200, writing 0x20a)
<7>[47711.407056] HDA Intel 0000:01:05.2: restoring config space at
offset 0x4 (was 0x4, writing 0xfdbfc004)
<7>[47711.407059] HDA Intel 0000:01:05.2: restoring config space at
offset 0x3 (was 0x0, writing 0x4008)
<7>[47711.407062] HDA Intel 0000:01:05.2: restoring config space at
offset 0x1 (was 0x100000, writing 0x100002)
<7>[47711.407085] r8169 0000:02:00.0: restoring config space at offset
0xf (was 0x100, writing 0x10a)
<7>[47711.407100] r8169 0000:02:00.0: restoring config space at offset
0x6 (was 0x4, writing 0xfdfff004)
<7>[47711.407106] r8169 0000:02:00.0: restoring config space at offset
0x4 (was 0x1, writing 0xee01)
<7>[47711.407110] r8169 0000:02:00.0: restoring config space at offset
0x3 (was 0x0, writing 0x8)
<7>[47711.407116] r8169 0000:02:00.0: restoring config space at offset
0x1 (was 0x100000, writing 0x100407)
<7>[47711.407175] saa7134 0000:03:06.0: restoring config space at offset
0x4 (was 0x0, writing 0xfdeff000)
<7>[47711.407181] saa7134 0000:03:06.0: restoring config space at offset
0x3 (was 0xff00, writing 0x4000)
<7>[47711.407188] saa7134 0000:03:06.0: restoring config space at offset
0x1 (was 0x2900000, writing 0x2900006)
<7>[47711.407209] pci 0000:03:07.0: restoring config space at offset 0xf
(was 0x200001ff, writing 0x2000010b)
<7>[47711.407229] pci 0000:03:07.0: restoring config space at offset 0x5
(was 0x1, writing 0xcf01)
<7>[47711.407235] pci 0000:03:07.0: restoring config space at offset 0x4
(was 0xfdeff000, writing 0xfdefe000)
<7>[47711.407241] pci 0000:03:07.0: restoring config space at offset 0x3
(was 0x4000, writing 0x4008)
<7>[47711.407248] pci 0000:03:07.0: restoring config space at offset 0x1
(was 0x2100006, writing 0x2100007)
<6>[47711.407389] PM: early resume of devices complete after 0.791 msecs
<6>[47711.407514] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
IRQ 22
<6>[47711.407577] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47711.407602] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[47711.407658] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[47711.407679] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
<6>[47711.407689] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
<6>[47711.407706] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
low) -> IRQ 19
<6>[47711.407726] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47711.407730] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
<6>[47711.407750] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
-> IRQ 18
<6>[47711.407760] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
low) -> IRQ 19
<6>[47711.407772] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
<7>[47711.407778] r8169 0000:02:00.0: PME# disabled
<6>[47711.407799] saa7133[0]: board init: gpio is 600c000
<5>[47711.407873] sd 0:0:0:0: [sda] Starting disk
<5>[47711.407902] sd 1:0:0:0: [sdb] Starting disk
<5>[47711.407916] sd 2:0:0:0: [sdc] Starting disk
<6>[47711.409445] serial 00:08: activated
<6>[47711.409741] parport_pc 00:09: activated
<6>[47711.413044] r8169 0000:02:00.0: eth0: link down
<6>[47711.495029] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
<6>[47711.501116] radeon 0000:01:05.0: WB enabled
<6>[47711.501129] [drm] radeon: ring at 0x0000000080001000
<6>[47711.501149] [drm] ring test succeeded in 1 usecs
<6>[47711.501160] [drm] ib test succeeded in 0 usecs
<3>[47711.867017] ata4: softreset failed (device not ready)
<4>[47711.867020] ata4: applying SB600 PMP SRST workaround and retrying
<6>[47712.022025] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[47712.043857] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47712.086418] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47712.086421] ata4.00: configured for UDMA/100
<6>[47713.306814] r8169 0000:02:00.0: eth0: link up
<3>[47714.570017] ata3: softreset failed (device not ready)
<4>[47714.570020] ata3: applying SB600 PMP SRST workaround and retrying
<6>[47714.725024] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47714.757149] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47714.758102] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47714.758104] ata3.00: configured for UDMA/133
<3>[47719.109016] ata1: softreset failed (device not ready)
<4>[47719.109018] ata1: applying SB600 PMP SRST workaround and retrying
<6>[47719.264030] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47719.284628] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47719.286668] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47719.286671] ata1.00: configured for UDMA/133
<3>[47719.976015] ata2: softreset failed (device not ready)
<4>[47719.976018] ata2: applying SB600 PMP SRST workaround and retrying
<6>[47720.131023] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
<6>[47721.832690] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47721.836072] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47721.836074] ata2.00: configured for UDMA/133
<6>[47722.830047] PM: resume of devices complete after 11422.582 msecs
<4>[47722.830225] Restarting tasks ... done.
<6>[47723.223665] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.225686] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.225689] ata1.00: configured for UDMA/133
<6>[47723.225691] ata1: EH complete
<6>[47723.515018] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.518391] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.518394] ata2.00: configured for UDMA/133
<6>[47723.518397] ata2: EH complete
<6>[47723.932934] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.933943] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
<6>[47723.933952] ata3.00: configured for UDMA/133
<6>[47723.933962] ata3: EH complete
<6>[47724.120123] EXT4-fs (dm-4): re-mounted. Opts: commit=0
<6>[47724.127271] EXT4-fs (dm-7): re-mounted. Opts: commit=0
<6>[47724.140235] EXT4-fs (dm-6): re-mounted. Opts: commit=0
<6>[47724.147066] EXT4-fs (dm-0): re-mounted. Opts: commit=0
<1>[47900.532079] BUG: unable to handle kernel paging request at
ffffc5217e257cf0
<1>[47900.532282] IP: [<ffffffff81097d18>] handle_pte_fault+0x24/0x70a
<4>[47900.532448] PGD 0
<0>[47900.532505] Oops: 0000 [#1] PREEMPT SMP
<4>[47900.532618] CPU 1
<4>[47900.532668] Modules linked in: saa7134_alsa tda1004x saa7134_dvb
videobuf_dvb dvb_core ir_kbd_i2c tda827x snd_hda_codec_realtek tda8290
tuner saa7134 videobuf_dma_sg snd_hda_intel videobuf_core v4l2_common
videodev snd_hda_codec ir_lirc_codec lirc_dev sg ir_sony_decoder
ir_jvc_decoder v4l2_compat_ioctl32 tveeprom ir_rc6_decoder rc_imon_mce
ir_rc5_decoder atiixp rtc_cmos ir_nec_decoder imon rc_core parport_pc
parport i2c_piix4 pcspkr snd_hwdep asus_atk0110
<4>[47900.533010]
<4>[47900.533010] Pid: 23858, comm: mencoder Not tainted 3.0.3-dirty #37
System manufacturer System Product Name/M2A-VM HDMI
<4>[47900.533010] RIP: 0010:[<ffffffff81097d18>]  [<ffffffff81097d18>]
handle_pte_fault+0x24/0x70a
<4>[47900.533010] RSP: 0000:ffff880024c27db8  EFLAGS: 00010296
<4>[47900.533010] RAX: 0000000000000cf0 RBX: ffff88006c3b2a68 RCX:
ffffc5217e257cf0
<4>[47900.533010] RDX: 000000000059effe RSI: ffff88006c3b2a68 RDI:
ffff88006d6d2ac0
<4>[47900.533010] RBP: ffffc5217e257cf0 R08: ffff880024d3b010 R09:
0000000000000028
<4>[47900.533010] R10: ffffffff81049bb3 R11: ffff880077c10a80 R12:
ffff88006d6d2ac0
<4>[47900.533010] R13: ffff880025ee4050 R14: ffff88006c3b2a68 R15:
000000000059effe
<4>[47900.533010] FS:  00007fe0ee868700(0000) GS:ffff880077c80000(0000)
knlGS:0000000000000000
<4>[47900.533010] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<4>[47900.533010] CR2: ffffc5217e257cf0 CR3: 000000006eb49000 CR4:
00000000000006e0
<4>[47900.533010] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
<4>[47900.533010] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
<4>[47900.533010] Process mencoder (pid: 23858, threadinfo
ffff880024c26000, task ffff880025ee4050)
<0>[47900.533010] Stack:
<4>[47900.533010]  0000000000004000 0000000000000000 0000000000000000
0000000000004000
<4>[47900.533010]  0000000000000028 0000000000000000 ffff880024d3b010
ffffffff810ab79f
<4>[47900.533010]  0000000000000000 000000000059effe 000000000059effe
ffffffff810987e5
<0>[47900.533010] Call Trace:
<4>[47900.533010]  [<ffffffff810ab79f>] ?
mem_cgroup_count_vm_event+0x15/0x67
<4>[47900.533010]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
<4>[47900.533010]  [<ffffffff81049bb3>] ? sched_clock_local+0x13/0x76
<4>[47900.533010]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
<4>[47900.533010]  [<ffffffff81022b80>] ? check_preempt_curr+0x36/0x62
<4>[47900.533010]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
<4>[47900.533010]  [<ffffffff810bfd2c>] ?
poll_select_copy_remaining+0xce/0xed
<4>[47900.533010]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30
<0>[47900.533010] Code: 41 5d 41 5e 41 5f c3 41 57 49 89 d7 41 56 41 55
41 54 49 89 fc 55 48 89 cd 53 48 89 f3 48 83 ec 68 4c 89 44 24 30 44 89
4c 24 20 <4c> 8b 31 44 89 f0 25 ff 0f 00 00 a9 01 01 00 00 0f 85 22 06 00
<1>[47900.533010] RIP  [<ffffffff81097d18>] handle_pte_fault+0x24/0x70a
<4>[47900.533010]  RSP <ffff880024c27db8>
<0>[47900.533010] CR2: ffffc5217e257cf0


I'm _fairly_ certain that this config is the riight one.

#
# Automatically generated make config: don't edit
# Linux/x86_64 3.0.3 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi
-fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9
-fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
# CONFIG_TASKSTATS is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_FORCED_THREADING=y
# CONFIG_SPARSE_IRQ is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=32
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_BOOST is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_PERF_COUNTERS is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

#
# GCOV-based kernel profiling
#
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_DEV_THROTTLING is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=m
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
# CONFIG_INLINE_SPIN_UNLOCK is not set
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
# CONFIG_KVM_CLOCK is not set
# CONFIG_KVM_GUEST is not set
# CONFIG_PARAVIRT is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
CONFIG_MK8=y
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_CMPXCHG_LOCAL=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_IOMMU_API=y
CONFIG_NR_CPUS=4
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_I8K=m
CONFIG_MICROCODE=m
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_EFI=y
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x100000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION="/dev/sda2"
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=m
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=m
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K8=y
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_DMAR=y
CONFIG_DMAR_DEFAULT_ON=y
CONFIG_DMAR_FLOPPY_WA=y
# CONFIG_INTR_REMAP is not set
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
# CONFIG_NETFILTER_XTABLES is not set
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
# CONFIG_IP_NF_QUEUE is not set
# CONFIG_IP_NF_IPTABLES is not set
# CONFIG_IP_NF_ARPTABLES is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
CONFIG_ATM=m
# CONFIG_ATM_CLIP is not set
# CONFIG_ATM_LANE is not set
# CONFIG_ATM_BR2684 is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_HAVE_BPF_JIT=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=y
CONFIG_BT_L2CAP=y
CONFIG_BT_SCO=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
# CONFIG_BT_HCIUART is not set
# CONFIG_BT_HCIBCM203X is not set
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_BT_MRVL is not set
# CONFIG_BT_ATH3K is not set
# CONFIG_AF_RXRPC is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
# CONFIG_RFKILL_INPUT is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=m
# CONFIG_MTD is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=8192
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_MISC_DEVICES=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=m
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=m
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085 is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=m
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_SENSORS_LIS3_I2C=y
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
CONFIG_BLK_DEV_IDEACPI=y
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=m
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=m
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=m
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MULTICORE_RAID456=y
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
# CONFIG_DM_RAID is not set
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_ZERO=m
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
CONFIG_MACVLAN=m
# CONFIG_MACVTAP is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
CONFIG_VETH=m
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_MII=y
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=m
# CONFIG_E1000E is not set
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_R8169=y
CONFIG_SIS190=m
CONFIG_SKGE=m
CONFIG_SKY2=m
CONFIG_VIA_VELOCITY=m
CONFIG_TIGON3=m
CONFIG_BNX2=m
# CONFIG_CNIC is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
# CONFIG_STMMAC_ETH is not set
# CONFIG_PCH_GBE is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_CDCETHER=m
# CONFIG_USB_NET_CDC_EEM is not set
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_DM9601 is not set
# CONFIG_USB_NET_SMSC75XX is not set
# CONFIG_USB_NET_SMSC95XX is not set
# CONFIG_USB_NET_GL620A is not set
CONFIG_USB_NET_NET1080=m
# CONFIG_USB_NET_PLUSB is not set
# CONFIG_USB_NET_MCS7830 is not set
# CONFIG_USB_NET_RNDIS_HOST is not set
# CONFIG_USB_NET_CDC_SUBSET is not set
CONFIG_USB_NET_ZAURUS=m
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_HSO is not set
# CONFIG_USB_NET_INT51X1 is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
# CONFIG_WAN is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_VIRTIO_NET is not set
CONFIG_VMXNET3=m
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=m

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_LKKBD=m
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=m
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=m
CONFIG_KEYBOARD_XTKBD=m
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_UINPUT is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PARKBD=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
# CONFIG_PPDEV is not set
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=m
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_MWAVE=m
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_RAMOOPS is not set
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=m
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=m
CONFIG_I2C_SIS630=m
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=m
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set
# CONFIG_I2C_EG20T is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
CONFIG_I2C_TAOS_EVM=m
CONFIG_I2C_TINY_USB=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set

#
# PPS support
#
# CONFIG_PPS is not set

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable Device Drivers -> PPS to see the PTP clock options.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ20Z75 is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_THMC50=m
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set
CONFIG_MFD_SUPPORT=y
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2_COMMON=m
CONFIG_DVB_CORE=m
CONFIG_VIDEO_MEDIA=m

#
# Multimedia drivers
#
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_RC_CORE=m
CONFIG_LIRC=m
CONFIG_RC_MAP=m
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_RC5_SZ_DECODER=m
CONFIG_IR_LIRC_CODEC=m
# CONFIG_IR_ENE is not set
CONFIG_IR_IMON=m
# CONFIG_IR_MCEUSB is not set
# CONFIG_IR_ITE_CIR is not set
# CONFIG_IR_FINTEK is not set
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_REDRAT3 is not set
# CONFIG_IR_STREAMZAP is not set
# CONFIG_IR_WINBOND_CIR is not set
# CONFIG_RC_LOOPBACK is not set
CONFIG_MEDIA_ATTACH=y
CONFIG_MEDIA_TUNER=m
# CONFIG_MEDIA_TUNER_CUSTOMISE is not set
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_VIDEO_BTCX=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEO_CAPTURE_DRIVERS=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_HELPER_CHIPS_AUTO=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_TDA9840=m
CONFIG_VIDEO_TEA6415C=m
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_BT819=m
CONFIG_VIDEO_BT856=m
CONFIG_VIDEO_BT866=m
CONFIG_VIDEO_KS0127=m
CONFIG_VIDEO_SAA7110=m
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_VPX3220=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# MPEG video encoders
#
CONFIG_VIDEO_CX2341X=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m
CONFIG_VIDEO_SAA7185=m
CONFIG_VIDEO_ADV7170=m
CONFIG_VIDEO_ADV7175=m

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7670=m
CONFIG_VIDEO_MT9V011=m

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Miscelaneous helper chips
#
CONFIG_VIDEO_M52790=m
# CONFIG_VIDEO_VIVI is not set
CONFIG_VIDEO_BT848=m
CONFIG_VIDEO_BT848_DVB=y
CONFIG_VIDEO_BWQCAM=m
CONFIG_VIDEO_CQCAM=m
CONFIG_VIDEO_W9966=m
CONFIG_VIDEO_CPIA2=m
CONFIG_VIDEO_ZORAN=m
CONFIG_VIDEO_ZORAN_DC30=m
CONFIG_VIDEO_ZORAN_ZR36060=m
CONFIG_VIDEO_ZORAN_BUZ=m
CONFIG_VIDEO_ZORAN_DC10=m
CONFIG_VIDEO_ZORAN_LML33=m
CONFIG_VIDEO_ZORAN_LML33R10=m
CONFIG_VIDEO_ZORAN_AVS6EYES=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_MXB=m
CONFIG_VIDEO_HEXIUM_ORION=m
CONFIG_VIDEO_HEXIUM_GEMINI=m
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX23885=m
# CONFIG_MEDIA_ALTERA_CI is not set
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_IVTV=m
CONFIG_VIDEO_FB_IVTV=m
CONFIG_VIDEO_CX18=m
# CONFIG_VIDEO_CX18_ALSA is not set
CONFIG_VIDEO_SAA7164=m
CONFIG_VIDEO_CAFE_CCIC=m
# CONFIG_VIDEO_SR030PC30 is not set
# CONFIG_VIDEO_NOON010PC30 is not set
CONFIG_SOC_CAMERA=m
# CONFIG_SOC_CAMERA_IMX074 is not set
CONFIG_SOC_CAMERA_MT9M001=m
# CONFIG_SOC_CAMERA_MT9M111 is not set
# CONFIG_SOC_CAMERA_MT9T031 is not set
# CONFIG_SOC_CAMERA_MT9T112 is not set
CONFIG_SOC_CAMERA_MT9V022=m
# CONFIG_SOC_CAMERA_RJ54N1 is not set
# CONFIG_SOC_CAMERA_TW9910 is not set
CONFIG_SOC_CAMERA_PLATFORM=m
# CONFIG_SOC_CAMERA_OV2640 is not set
# CONFIG_SOC_CAMERA_OV6650 is not set
# CONFIG_SOC_CAMERA_OV772X is not set
# CONFIG_SOC_CAMERA_OV9640 is not set
# CONFIG_SOC_CAMERA_OV9740 is not set
CONFIG_V4L_USB_DRIVERS=y
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
# CONFIG_USB_M5602 is not set
# CONFIG_USB_STV06XX is not set
# CONFIG_USB_GL860 is not set
# CONFIG_USB_GSPCA_BENQ is not set
# CONFIG_USB_GSPCA_CONEX is not set
# CONFIG_USB_GSPCA_CPIA1 is not set
# CONFIG_USB_GSPCA_ETOMS is not set
# CONFIG_USB_GSPCA_FINEPIX is not set
# CONFIG_USB_GSPCA_JEILINJ is not set
# CONFIG_USB_GSPCA_KINECT is not set
# CONFIG_USB_GSPCA_KONICA is not set
# CONFIG_USB_GSPCA_MARS is not set
# CONFIG_USB_GSPCA_MR97310A is not set
# CONFIG_USB_GSPCA_NW80X is not set
# CONFIG_USB_GSPCA_OV519 is not set
# CONFIG_USB_GSPCA_OV534 is not set
# CONFIG_USB_GSPCA_OV534_9 is not set
# CONFIG_USB_GSPCA_PAC207 is not set
# CONFIG_USB_GSPCA_PAC7302 is not set
# CONFIG_USB_GSPCA_PAC7311 is not set
# CONFIG_USB_GSPCA_SN9C2028 is not set
# CONFIG_USB_GSPCA_SN9C20X is not set
# CONFIG_USB_GSPCA_SONIXB is not set
# CONFIG_USB_GSPCA_SONIXJ is not set
# CONFIG_USB_GSPCA_SPCA500 is not set
# CONFIG_USB_GSPCA_SPCA501 is not set
# CONFIG_USB_GSPCA_SPCA505 is not set
# CONFIG_USB_GSPCA_SPCA506 is not set
# CONFIG_USB_GSPCA_SPCA508 is not set
# CONFIG_USB_GSPCA_SPCA561 is not set
# CONFIG_USB_GSPCA_SPCA1528 is not set
# CONFIG_USB_GSPCA_SQ905 is not set
# CONFIG_USB_GSPCA_SQ905C is not set
# CONFIG_USB_GSPCA_SQ930X is not set
# CONFIG_USB_GSPCA_STK014 is not set
# CONFIG_USB_GSPCA_STV0680 is not set
# CONFIG_USB_GSPCA_SUNPLUS is not set
# CONFIG_USB_GSPCA_T613 is not set
# CONFIG_USB_GSPCA_TV8532 is not set
# CONFIG_USB_GSPCA_VC032X is not set
# CONFIG_USB_GSPCA_VICAM is not set
# CONFIG_USB_GSPCA_XIRLINK_CIT is not set
# CONFIG_USB_GSPCA_ZC3XX is not set
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
CONFIG_VIDEO_PVRUSB2_DEBUGIFC=y
# CONFIG_VIDEO_HDPVR is not set
CONFIG_VIDEO_EM28XX=m
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
# CONFIG_VIDEO_TLG2300 is not set
# CONFIG_VIDEO_CX231XX is not set
CONFIG_VIDEO_USBVISION=m
CONFIG_USB_ET61X251=m
CONFIG_USB_SN9C102=m
CONFIG_USB_PWC=m
CONFIG_USB_PWC_DEBUG=y
CONFIG_USB_PWC_INPUT_EVDEV=y
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_RADIO_ADAPTERS=y
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_I2C_SI4713 is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_SI470X is not set
# CONFIG_USB_MR800 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_RADIO_WL128X is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set
CONFIG_DVB_CAPTURE_DRIVERS=y

#
# Supported SAA7146 based PCI Adapters
#
# CONFIG_TTPCI_EEPROM is not set
# CONFIG_DVB_AV7110 is not set
# CONFIG_DVB_BUDGET_CORE is not set

#
# Supported USB Adapters
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
# CONFIG_DVB_USB_A800 is not set
# CONFIG_DVB_USB_DIBUSB_MB is not set
# CONFIG_DVB_USB_DIBUSB_MC is not set
# CONFIG_DVB_USB_DIB0700 is not set
# CONFIG_DVB_USB_UMT_010 is not set
# CONFIG_DVB_USB_CXUSB is not set
# CONFIG_DVB_USB_M920X is not set
# CONFIG_DVB_USB_GL861 is not set
# CONFIG_DVB_USB_AU6610 is not set
# CONFIG_DVB_USB_DIGITV is not set
# CONFIG_DVB_USB_VP7045 is not set
# CONFIG_DVB_USB_VP702X is not set
# CONFIG_DVB_USB_GP8PSK is not set
# CONFIG_DVB_USB_NOVA_T_USB2 is not set
# CONFIG_DVB_USB_TTUSB2 is not set
# CONFIG_DVB_USB_DTT200U is not set
# CONFIG_DVB_USB_OPERA1 is not set
# CONFIG_DVB_USB_AF9005 is not set
# CONFIG_DVB_USB_DW2102 is not set
# CONFIG_DVB_USB_CINERGY_T2 is not set
CONFIG_DVB_USB_ANYSEE=m
# CONFIG_DVB_USB_DTV5100 is not set
# CONFIG_DVB_USB_AF9015 is not set
# CONFIG_DVB_USB_CE6230 is not set
# CONFIG_DVB_USB_FRIIO is not set
# CONFIG_DVB_USB_EC168 is not set
# CONFIG_DVB_USB_AZ6027 is not set
# CONFIG_DVB_USB_LME2510 is not set
# CONFIG_DVB_USB_TECHNISAT_USB2 is not set
# CONFIG_DVB_TTUSB_BUDGET is not set
# CONFIG_DVB_TTUSB_DEC is not set
# CONFIG_SMS_SIANO_MDTV is not set

#
# Supported FlexCopII (B2C2) Adapters
#
# CONFIG_DVB_B2C2_FLEXCOP is not set

#
# Supported BT878 Adapters
#
CONFIG_DVB_BT8XX=m

#
# Supported Pluto2 Adapters
#
# CONFIG_DVB_PLUTO2 is not set

#
# Supported SDMC DM1105 Adapters
#
# CONFIG_DVB_DM1105 is not set

#
# Supported Earthsoft PT1 Adapters
#
# CONFIG_DVB_PT1 is not set

#
# Supported Mantis Adapters
#
# CONFIG_MANTIS_CORE is not set

#
# Supported nGene Adapters
#
# CONFIG_DVB_NGENE is not set

#
# Supported DVB Frontends
#
# CONFIG_DVB_FE_CUSTOMISE is not set

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB6100=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_DS3000=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_TDA10023=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_TTM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_WMT_GE_ROPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_EFI is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_PROGEAR is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=y

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_HRTIMER is not set
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_SUPPORT_OLD_API=y
# CONFIG_SND_VERBOSE_PROCFS is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_DRIVERS=y
# CONFIG_SND_PCSP is not set
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_ALOOP is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=y
# CONFIG_SND_HDA_CODEC_ANALOG is not set
# CONFIG_SND_HDA_CODEC_SIGMATEL is not set
# CONFIG_SND_HDA_CODEC_VIA is not set
# CONFIG_SND_HDA_CODEC_HDMI is not set
# CONFIG_SND_HDA_CODEC_CIRRUS is not set
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
# CONFIG_SND_HDA_CODEC_CA0110 is not set
# CONFIG_SND_HDA_CODEC_CMEDIA is not set
# CONFIG_SND_HDA_CODEC_SI3054 is not set
# CONFIG_SND_HDA_GENERIC is not set
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
# CONFIG_SND_USB_6FIRE is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=m
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CYPRESS=m
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=m
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=m
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LOGITECH=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWII_FF is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_QUANTA is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_ROCCAT_ARVO is not set
# CONFIG_HID_ROCCAT_KONE is not set
# CONFIG_HID_ROCCAT_KONEPLUS is not set
# CONFIG_HID_ROCCAT_KOVAPLUS is not set
# CONFIG_HID_ROCCAT_PYRA is not set
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEVICEFS is not set
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
# CONFIG_USB_SERIAL_CP210X is not set
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_FUNSOFT=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KEYSPAN_MPR=y
CONFIG_USB_SERIAL_KEYSPAN_USA28=y
CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XA=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XB=y
CONFIG_USB_SERIAL_KEYSPAN_USA19=y
CONFIG_USB_SERIAL_KEYSPAN_USA18X=y
CONFIG_USB_SERIAL_KEYSPAN_USA19W=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QW=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QI=y
CONFIG_USB_SERIAL_KEYSPAN_USA49W=y
CONFIG_USB_SERIAL_KEYSPAN_USA49WLC=y
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_MOS7720=m
# CONFIG_USB_SERIAL_MOS7715_PARPORT is not set
CONFIG_USB_SERIAL_MOS7840=m
CONFIG_USB_SERIAL_MOTOROLA=m
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_HP4X=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
# CONFIG_USB_SERIAL_SIEMENS_MPI is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
# CONFIG_USB_SERIAL_SYMBOL is not set
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
# CONFIG_USB_SERIAL_ZIO is not set
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_ALIX2 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_TRIGGERS is not set

#
# LED Triggers
#
# CONFIG_NFC_DEVICES is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=m
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=m
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_INTEL_OAKTRAIL is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_EFI_VARS is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_SIGMA is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD=y
CONFIG_JBD2=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=m
# CONFIG_CUSE is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=y
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_VERBOSE=y
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
# CONFIG_EARLY_PRINTK is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_INTEL_TXT is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
# CONFIG_CRYPTO_GF128MUL is not set
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=m
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
# CONFIG_KVM_INTEL is not set
CONFIG_KVM_AMD=m
# CONFIG_VHOST_NET is not set
CONFIG_VIRTIO=m
CONFIG_VIRTIO_RING=m
CONFIG_VIRTIO_PCI=m
CONFIG_VIRTIO_BALLOON=m
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_NLATTR=y
# CONFIG_AVERAGE is not set


Checking in /boot, if found a config-3.0.3-dirty.old too: the diff
between the two is:
# diff -u  /boot/config-3.0.3-dirty*
--- /boot/config-3.0.3-dirty    2011-08-22 08:56:25.000000000 +0200
+++ /boot/config-3.0.3-dirty.old        2011-08-22 08:45:38.000000000 +0200
@@ -561,28 +561,7 @@
 # CONFIG_IPV6 is not set
 # CONFIG_NETWORK_SECMARK is not set
 # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
-CONFIG_NETFILTER=y
-# CONFIG_NETFILTER_DEBUG is not set
-CONFIG_NETFILTER_ADVANCED=y
-
-#
-# Core Netfilter Configuration
-#
-CONFIG_NETFILTER_NETLINK=m
-CONFIG_NETFILTER_NETLINK_QUEUE=m
-# CONFIG_NETFILTER_NETLINK_LOG is not set
-# CONFIG_NF_CONNTRACK is not set
-# CONFIG_NETFILTER_XTABLES is not set
-# CONFIG_IP_SET is not set
-# CONFIG_IP_VS is not set
-
-#
-# IP: Netfilter Configuration
-#
-# CONFIG_NF_DEFRAG_IPV4 is not set
-# CONFIG_IP_NF_QUEUE is not set
-# CONFIG_IP_NF_IPTABLES is not set
-# CONFIG_IP_NF_ARPTABLES is not set
+# CONFIG_NETFILTER is not set
 # CONFIG_IP_DCCP is not set
 # CONFIG_IP_SCTP is not set
 # CONFIG_RDS is not set


The dirtyness comes from this patch which I've carried since 2.6.25 or so.
# cat /TV_CARD.diff
diff --git a/drivers/media/common/tuners/tda8290.c
b/drivers/media/common/tuners/tda8290.c
index 064d14c..498cc7b 100644
--- a/drivers/media/common/tuners/tda8290.c
+++ b/drivers/media/common/tuners/tda8290.c
@@ -635,7 +635,11 @@ static int tda829x_find_tuner(struct dvb_frontend *fe)

                dvb_attach(tda827x_attach, fe, priv->tda827x_addr,
                           priv->i2c_props.adap, &priv->cfg);
+               tuner_info("ANDERS: setting switch_addr. was 0x%02x, new
0x%02x\n",priv->cfg.switch_addr,priv->i2c_props.addr);
                priv->cfg.switch_addr = priv->i2c_props.addr;
+               priv->cfg.switch_addr = 0xc2 / 2;
+               tuner_info("ANDERS: new 0x%02x\n",priv->cfg.switch_addr);
+
        }
        if (fe->ops.tuner_ops.init)
                fe->ops.tuner_ops.init(fe);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
