Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 824EE6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:19:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x18-v6so10316450oie.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:19:43 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q10-v6si7315407oif.217.2018.07.30.02.19.40
        for <linux-mm@kvack.org>;
        Mon, 30 Jul 2018 02:19:41 -0700 (PDT)
Date: Mon, 30 Jul 2018 10:19:35 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Message-ID: <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Jan Beulich <JBeulich@suse.com>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 11:09:54AM +0200, Sedat Dilek wrote:
> On Mon, Jul 30, 2018 at 10:21 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Sun, Jul 29, 2018 at 08:12:00PM +0200, Sedat Dilek wrote:
> >> I was able to build a Linux v4.18-rc6 with tip.git#locking/core [1] on
> >> top of it here on Debian/buster AMD64.
> >>
> >> The patch of interest is [2]...
> >>
> >> df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
> >>
> >> ...and some more locking/atomics[/x86] may be interesting.
> >>
> >> I had also to apply an asm-goto fix to reduce the number of warnings
> >> when building with clang-7 (version
> >> 7.0.0-svn337957-1~exp1+0~20180725200907.1908~1.gbpcccb1b (trunk)).

> >> The kernel does ***not boot*** on bare metal.
> >
> > Ok. Does the prior commit boot?
> 
> I cannot say as I was not able to compile with clang since the commit
> 8bf705d13039 mentioned here in the subject.

> Kees pointed me to issue #7 "__builtin_constant_p() does not work in
> deep inline functions" which is the cause for not booting.
> The issue is known as #7.
> 
> My qemu-log.txt is attached for details if you want to look at.
> 
> [1] https://github.com/ClangBuiltLinux/linux/issues/7
> 
> >> More details see [4] and [5] for the clang-side.
> >
> > It's not clear to me how these relate to the patch in question. AFAICT,
> > those are build-time errors, but you say that the kernel doesn't boot
> > (which implies it built).
> >
> > Are [4,5] relevant to this commit, or to the (unrelated) issue [3]?
> >
> > My patch removes the switch, so this doesn't look like the same issue.
> 
> ClangBuiltLinux issue #3 "clang validates extended assembly
> constraints of dead code" is the problem on the clang-side.
> Matthias and Jan commented on the thread [1] if you want to read.
> You fixed the issue on the kernel-side, so that I could build a Linux
> v4.18-rc6 with clang-7 (trunk).
> This is a huge progress - really.
> 
> [1] https://groups.google.com/forum/#!topic/kasan-dev/oMgCP37n1vw
> 
> Is this a bit clearer, now?

Yes; I had misunderstood your mail as reporting a regression resulting
from my patch, rather than an improvement.

IIUC, commit df79ed2c0643 ("locking/atomics: Simplify cmpxchg()
instrumentation") happens to make the kernel compile with clang, when it
would not previously (since commit 8bf705d13039). 

Given that you seem to understand the remaining issue, I take it that
there is nothing that I need to do here.

Thanks,
Mark.

> $ cat run_qemu.sh 
> KPATH=$(pwd)
> 
> sudo qemu-system-x86_64 -enable-kvm -M pc -kernel $KPATH/bzImage -initrd $KPATH/initrd.img -m 512 -net none -serial stdio -append "root=/dev/ram0 console=ttyS0 hung_task_panic=1 earlyprintk=ttyS0,115200"
> 
> sdi@iniza:~/src/linux-kernel/archives$ ./run_qemu.sh 
> Probing EDD (edd=off to disable)... ok
> [    0.000000] Linux version 4.18.0-rc6-2-iniza-llvmlinux (sedat.dilek@gmail.com@iniza) (clang version 7.0.0-svn338192-1~exp1+0~20180728091252.1913~1.gbpcccb1b (trunk)) #1 SMP 2018-07-29
> [    0.000000] Command line: root=/dev/ram0 console=ttyS0 hung_task_panic=1 earlyprintk=ttyS0,115200
> [    0.000000] x86/fpu: x87 FPU will use FXSAVE
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001ffdffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000001ffe0000-0x000000001fffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] last_pfn = 0x1ffe0 max_arch_pfn = 0x400000000
> [    0.000000] x86/PAT: PAT not supported by CPU.
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC  
> Memory KASLR using RDTSC...
> [    0.000000] found SMP MP-table at [mem 0x000f5d60-0x000f5d6f] mapped at [(____ptrval____)]
> [    0.000000] RAMDISK: [mem 0x1e555000-0x1ffdffff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F5B90 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x000000001FFE157C 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x000000001FFE1458 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x000000001FFE0040 001418 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x000000001FFE0000 000040
> [    0.000000] ACPI: APIC 0x000000001FFE14CC 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x000000001FFE1544 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001ffdffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x1e550000-0x1e554fff]
> [    0.000000] kvm-clock: cpu 0, msr 0:1e547001, primary cpu clock
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: using sched offset of 614287916 cycles
> [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x000000001ffdffff]
> [    0.000000]   Normal   empty
> [    0.000000]   Device   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x000000001ffdffff]
> [    0.000000] Reserved but unavailable: 130 pages
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001ffdffff]
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
> [    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> [    0.000000] [mem 0x20000000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
> [    0.000000] random: get_random_bytes called from start_kernel+0x87/0x5f0 with crng_init=0
> [    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:1 nr_node_ids:1
> [    0.000000] percpu: Embedded 44 pages/cpu @(____ptrval____) s141528 r8192 d30504 u2097152
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 1e216180
> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 128872
> [    0.000000] Policy zone: DMA32
> [    0.000000] Kernel command line: root=/dev/ram0 console=ttyS0 hung_task_panic=1 earlyprintk=ttyS0,115200
> [    0.000000] Memory: 465940K/523768K available (10252K kernel code, 1053K rwdata, 2964K rodata, 1704K init, 648K bss, 57828K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
> [    0.000000] Kernel/User page tables isolation: enabled
> [    0.000000] ftrace: allocating 27902 entries in 109 pages
> [    0.004000] Hierarchical RCU implementation.
> [    0.004000]  RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=1.
> [    0.004000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
> [    0.004000] NR_IRQS: 33024, nr_irqs: 256, preallocated irqs: 16
> [    0.004000] Console: colour VGA+ 80x25
> [    0.004000] console [ttyS0] enabled
> [    0.004000] console [ttyS0] enabled
> [    0.004000] bootconsole [earlyser0] disabled
> [    0.004000] bootconsole [earlyser0] disabled
> [    0.004000] ACPI: Core revision 20180531
> [    0.004000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
> [    0.004011] APIC: Switch to symmetric I/O mode setup
> [    0.004642] x2apic enabled
> [    0.005068] Switched APIC routing to physical x2apic.
> [    0.006223] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.006688] tsc: Detected 2904.000 MHz processor
> [    0.007038] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x29dc05e54fc, max_idle_ns: 440795291716 ns
> [    0.007038] Calibrating delay loop (skipped) preset value.. 5808.00 BogoMIPS (lpj=11616000)
> [    0.008002] pid_max: default: 32768 minimum: 301
> [    0.008367] Security Framework initialized
> [    0.008714] Yama: becoming mindful.
> [    0.008994] AppArmor: AppArmor initialized
> [    0.009393] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.010388] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
> [    0.011050] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
> [    0.012003] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 bytes)
> [    0.012666] CPU: Physical Processor ID: 0
> [    0.012984] mce: CPU supports 10 MCE banks
> [    0.013320] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.013720] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.014173] Spectre V2 : Mitigation: Full generic retpoline
> [    0.014592] Speculative Store Bypass: Vulnerable
> [    0.021689] Freeing SMP alternatives memory: 28K
> [    0.028000] smpboot: CPU0: Intel QEMU Virtual CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
> [    0.028000] Performance Events: PMU not available due to virtualization, using software events only.
> [    0.028000] Hierarchical SRCU implementation.
> [    0.028000] NMI watchdog: Perf event create on CPU 0 failed with -2
> [    0.028000] NMI watchdog: Perf NMI watchdog permanently disabled
> [    0.028000] smp: Bringing up secondary CPUs ...
> [    0.028000] smp: Brought up 1 node, 1 CPU
> [    0.028003] smpboot: Max logical packages: 1
> [    0.028331] smpboot: Total of 1 processors activated (5808.00 BogoMIPS)
> [    0.028937] devtmpfs: initialized
> [    0.029233] x86/mm: Memory block size: 128MB
> [    0.029679] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
> [    0.030419] futex hash table entries: 256 (order: 2, 16384 bytes)
> [    0.030903] pinctrl core: initialized pinctrl subsystem
> [    0.031401] NET: Registered protocol family 16
> [    0.031784] audit: initializing netlink subsys (disabled)
> [    0.032064] cpuidle: using governor ladder
> [    0.032383] cpuidle: using governor menu
> [    0.032695] ACPI: bus type PCI registered
> [    0.033003] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> [    0.033561] PCI: Using configuration type 1 for base access
> [    0.033990] audit: type=2000 audit(1532896057.253:1): state=initialized audit_enabled=0 res=1
> [    0.035369] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
> [    0.036115] ACPI: Added _OSI(Module Device)
> [    0.036493] ACPI: Added _OSI(Processor Device)
> [    0.036887] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.037304] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.037789] ACPI: Added _OSI(Linux-Dell-Video)
> [    0.038607] ACPI: 1 ACPI AML tables successfully acquired and loaded
> [    0.040114] ACPI: Interpreter enabled
> [    0.040425] ACPI: (supports S0 S3 S4 S5)
> [    0.040779] ACPI: Using IOAPIC for interrupt routing
> [    0.041231] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.042161] ACPI: Enabled 2 GPEs in block 00 to 0F
> [    0.044126] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.044682] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
> [    0.045292] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.045890] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
> [    0.047061] acpiphp: Slot [3] registered
> [    0.047423] acpiphp: Slot [4] registered
> [    0.047793] acpiphp: Slot [5] registered
> [    0.048022] acpiphp: Slot [6] registered
> [    0.048395] acpiphp: Slot [7] registered
> [    0.048802] acpiphp: Slot [8] registered
> [    0.049173] acpiphp: Slot [9] registered
> [    0.049543] acpiphp: Slot [10] registered
> [    0.049927] acpiphp: Slot [11] registered
> [    0.050304] acpiphp: Slot [12] registered
> [    0.050680] acpiphp: Slot [13] registered
> [    0.051056] acpiphp: Slot [14] registered
> [    0.051432] acpiphp: Slot [15] registered
> [    0.051809] acpiphp: Slot [16] registered
> [    0.052021] acpiphp: Slot [17] registered
> [    0.052397] acpiphp: Slot [18] registered
> [    0.052773] acpiphp: Slot [19] registered
> [    0.053149] acpiphp: Slot [20] registered
> [    0.053530] acpiphp: Slot [21] registered
> [    0.053906] acpiphp: Slot [22] registered
> [    0.054280] acpiphp: Slot [23] registered
> [    0.054655] acpiphp: Slot [24] registered
> [    0.055030] acpiphp: Slot [25] registered
> [    0.055405] acpiphp: Slot [26] registered
> [    0.056022] acpiphp: Slot [27] registered
> [    0.056397] acpiphp: Slot [28] registered
> [    0.056773] acpiphp: Slot [29] registered
> [    0.057149] acpiphp: Slot [30] registered
> [    0.057524] acpiphp: Slot [31] registered
> [    0.057882] PCI host bridge to bus 0000:00
> [    0.058195] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> [    0.058709] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
> [    0.059222] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.059789] pci_bus 0000:00: root bus resource [mem 0x20000000-0xfebfffff window]
> [    0.060001] pci_bus 0000:00: root bus resource [mem 0x100000000-0x17fffffff window]
> [    0.060579] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.064018] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> [    0.064624] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.065215] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> [    0.065813] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.066755] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
> [    0.067596] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
> [    0.074067] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> [    0.074720] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> [    0.075328] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> [    0.076093] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> [    0.077044] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
> [    0.078314] pci 0000:00:02.0: vgaarb: setting as boot VGA device
> [    0.079203] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
> [    0.080005] pci 0000:00:02.0: vgaarb: bridge control possible
> [    0.080848] vgaarb: loaded
> [    0.081197] pps_core: LinuxPPS API ver. 1 registered
> [    0.081729] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.082708] PTP clock support registered
> [    0.083130] EDAC MC: Ver: 3.0.0
> [    0.083592] PCI: Using ACPI for IRQ routing
> [    0.084191] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
> [    0.084948] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> [    0.085473] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
> [    0.090089] clocksource: Switched to clocksource kvm-clock
> [    0.099366] VFS: Disk quotas dquot_6.6.0
> [    0.099817] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    0.100406] AppArmor: AppArmor Filesystem Enabled
> [    0.100770] pnp: PnP ACPI init
> [    0.101409] pnp: PnP ACPI: found 6 devices
> [    0.113805] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    0.114557] NET: Registered protocol family 2
> [    0.114962] tcp_listen_portaddr_hash hash table entries: 256 (order: 0, 4096 bytes)
> [    0.115694] TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.116237] TCP bind hash table entries: 4096 (order: 4, 65536 bytes)
> [    0.116726] TCP: Hash tables configured (established 4096 bind 4096)
> [    0.117204] UDP hash table entries: 256 (order: 1, 8192 bytes)
> [    0.117633] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
> [    0.118107] NET: Registered protocol family 1
> [    0.118511] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    0.119014] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    0.119652] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    0.120590] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
> [    0.121720] Unpacking initramfs...
> [    0.539655] Freeing initrd memory: 27180K
> [    0.540155] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x29dc05e54fc, max_idle_ns: 440795291716 ns
> [    0.541190] Initialise system trusted keyrings
> [    0.541547] workingset: timestamp_bits=40 max_order=17 bucket_order=0
> [    0.542721] zbud: loaded
> [    0.543099] pstore: using deflate compression
> [    0.684799] Key type asymmetric registered
> [    0.685185] Asymmetric key parser 'x509' registered
> [    0.685638] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
> [    0.686287] io scheduler noop registered
> [    0.686592] io scheduler deadline registered
> [    0.686933] io scheduler cfq registered (default)
> [    0.687296] io scheduler mq-deadline registered
> [    0.687695] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [    0.688303] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    0.711943] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    0.712751] Linux agpgart interface v0.103
> [    0.713091] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
> [    0.713560] AMD IOMMUv2 functionality not available on this system
> [    0.714144] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
> [    0.715315] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    0.715744] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    0.716241] mousedev: PS/2 mouse device common for all mice
> [    0.716864] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
> [    0.717808] rtc_cmos 00:00: RTC can wake from S4
> [    0.718941] rtc_cmos 00:00: registered as rtc0
> [    0.719531] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram, hpet irqs
> [    0.720742] ledtrig-cpu: registered to indicate activity on CPUs
> [    0.721732] NET: Registered protocol family 10
> [    0.724475] Segment Routing with IPv6
> [    0.724890] mip6: Mobile IPv6
> [    0.725166] NET: Registered protocol family 17
> [    0.725553] mpls_gso: MPLS GSO support
> [    0.725942] sched_clock: Marking stable (724018763, 0)->(964060525, -240041762)
> [    0.726626] registered taskstats version 1
> [    0.726986] Loading compiled-in X.509 certificates
> [    0.727475] zswap: loaded using pool lzo/zbud
> [    0.727971] AppArmor: AppArmor sha1 policy hashing enabled
> [    0.728756] rtc_cmos 00:00: setting system clock to 2018-07-29 20:27:37 UTC (1532896057)
> [    0.730756] Freeing unused kernel memory: 1704K
> [    0.736161] Write protecting the kernel read-only data: 16384k
> [    0.737499] Freeing unused kernel memory: 2024K
> [    0.739566] Freeing unused kernel memory: 1132K
> [    0.745418] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    0.746111] x86/mm: Checking user space page tables
> [    0.752098] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [    0.753666] usercopy: Kernel memory exposure attempt detected from SLUB object 'task_struct' (offset 1744, size 8)!
> [    0.754649] ------------[ cut here ]------------
> [    0.755067] kernel BUG at mm/usercopy.c:100!
> [    0.755684] invalid opcode: 0000 [#1] SMP PTI
> [    0.756148] CPU: 0 PID: 1 Comm: init Not tainted 4.18.0-rc6-2-iniza-llvmlinux #1
> [    0.756773] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1 04/01/2014
> [    0.757425] RIP: 0010:usercopy_abort+0x94/0xb0
> [    0.757913] Code: 77 01 b7 48 0f 44 d8 48 c7 c7 5f 77 01 b7 31 c0 4c 89 ce 4c 89 d1 4d 89 e0 4d 89 d9 41 56 41 57 53 e8 10 44 e5 ff 48 83 c4 18 <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 eb fe 66 66 2e 0f 1f 84 00 00 
> [    0.759980] RSP: 0018:ffffb747c00d3cb8 EFLAGS: 00010286
> [    0.760436] RAX: 0000000000000067 RBX: ffffffffb701774f RCX: 5ad13347f669db00
> [    0.761009] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000000246
> [    0.761546] RBP: ffffb747c00d3cd8 R08: 000000000000000a R09: 00000000ffff0a00
> [    0.762083] R10: 0000000000000152 R11: 0000000000000000 R12: ffffffffb701774e
> [    0.762620] R13: 00000000fffffff2 R14: 0000000000000008 R15: 00000000000006d0
> [    0.763199] FS:  00007f4e7c48d580(0000) GS:ffff99469e200000(0000) knlGS:0000000000000000
> [    0.763912] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.764522] CR2: 00007ffc3a4e4fff CR3: 0000000016cf6000 CR4: 00000000000006f0
> [    0.765522] Call Trace:
> [    0.765831]  __check_heap_object+0xf0/0x120
> [    0.766431]  __check_object_size+0xbe/0x1c0
> [    0.767057]  do_signal+0x4ac/0x600
> [    0.767470]  prepare_exit_to_usermode+0xd2/0x160
> [    0.767827]  syscall_return_slowpath+0x48/0x240
> [    0.768180]  ? __do_page_fault+0x2c6/0x510
> [    0.768498]  ? async_page_fault+0x8/0x30
> [    0.768801]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [    0.769192] RIP: 0033:0x7f4e7c3941c7
> [    0.769470] Code: c7 1c 0f 00 f7 d8 64 89 02 b8 ff ff ff ff eb bf 0f 1f 00 48 8d 05 21 78 0f 00 8b 00 85 c0 75 1b 45 31 d2 b8 3d 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 59 f3 c3 0f 1f 80 00 00 00 00 41 54 55 41 89 
> [    0.770911] RSP: 002b:00007ffc3a4e5088 EFLAGS: 00000246 ORIG_RAX: 000000000000003d
> [    0.771544] RAX: 000000000000003a RBX: 0000556de5d30260 RCX: 00007f4e7c3941c7
> [    0.772091] RDX: 0000000000000000 RSI: 00007ffc3a4e509c RDI: 00000000ffffffff
> [    0.772637] RBP: 0000556de5d30260 R08: 00007f4e7c48d580 R09: fefeff7168636a6c
> [    0.773198] R10: 0000000000000000 R11: 0000000000000246 R12: 0000556de5d316b0
> [    0.773806] R13: 00007ffc3a4e509c R14: 00000000ffffffff R15: 0000556de5d31325
> [    0.774345] Modules linked in:
> [    0.774604] ---[ end trace aebaaea85d265154 ]---
> [    0.774961] RIP: 0010:usercopy_abort+0x94/0xb0
> [    0.775308] Code: 77 01 b7 48 0f 44 d8 48 c7 c7 5f 77 01 b7 31 c0 4c 89 ce 4c 89 d1 4d 89 e0 4d 89 d9 41 56 41 57 53 e8 10 44 e5 ff 48 83 c4 18 <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 eb fe 66 66 2e 0f 1f 84 00 00 
> [    0.776745] RSP: 0018:ffffb747c00d3cb8 EFLAGS: 00010286
> [    0.777142] RAX: 0000000000000067 RBX: ffffffffb701774f RCX: 5ad13347f669db00
> [    0.777711] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000000246
> [    0.778252] RBP: ffffb747c00d3cd8 R08: 000000000000000a R09: 00000000ffff0a00
> [    0.778801] R10: 0000000000000152 R11: 0000000000000000 R12: ffffffffb701774e
> [    0.779404] R13: 00000000fffffff2 R14: 0000000000000008 R15: 00000000000006d0
> [    0.780183] FS:  00007f4e7c48d580(0000) GS:ffff99469e200000(0000) knlGS:0000000000000000
> [    0.780988] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.781501] CR2: 00007ffc3a4e4fff CR3: 0000000016cf6000 CR4: 00000000000006f0
> [    0.782797] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
> [    0.782797] 
> [    0.784181] Kernel Offset: 0x35200000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [    0.786094] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
> [    0.786094]  ]---
