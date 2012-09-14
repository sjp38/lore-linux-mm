Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BCCCA6B0258
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 09:35:51 -0400 (EDT)
Date: Fri, 14 Sep 2012 21:35:42 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: huge_pte_alloc: inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W}
 usage.
Message-ID: <20120914133542.GA21830@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got this one shot warning:

[  192.575049] 3.6.0-rc4+ #5699 Not tainted
[  192.575734] ---------------------------------
[  192.576077] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[  192.576077] trinity-child0/7738 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  192.576077]  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81075db9>] huge_pte_alloc+0x2c3/0x32b
[  192.576077] {IN-RECLAIM_FS-W} state was registered at:
[  192.576077]   [<ffffffff810d5bdc>] __lock_acquire+0x35f/0xd04
[  192.576077]   [<ffffffff810d69de>] lock_acquire+0x9b/0x10d
[  192.576077]   [<ffffffff826fb7df>] __mutex_lock_common+0x47/0x35f
[  192.576077]   [<ffffffff826fbbca>] mutex_lock_nested+0x2f/0x36
[  192.576077]   [<ffffffff811589e2>] page_referenced+0x15a/0x1fb
[  192.576077]   [<ffffffff8113ef50>] shrink_page_list+0x1a6/0x71c
[  192.576077]   [<ffffffff8113f82e>] shrink_inactive_list+0x1c9/0x31a
[  192.576077]   [<ffffffff8113ff69>] shrink_lruvec+0x33f/0x472
[  192.576077]   [<ffffffff8114022c>] do_try_to_free_pages+0x190/0x39a
[  192.576077]   [<ffffffff811405cc>] try_to_free_pages+0xbc/0x123
[  192.576077]   [<ffffffff811377d8>] __alloc_pages_nodemask+0x433/0x6f9
[  192.576077]   [<ffffffff8116a120>] kmem_getpages+0x6b/0x138
[  192.576077]   [<ffffffff8116c1b4>] fallback_alloc+0x138/0x202
[  192.576077]   [<ffffffff8116c067>] ____cache_alloc_node+0x12b/0x140
[  192.576077]   [<ffffffff8116c433>] kmem_cache_alloc+0x93/0x151
[  192.576077]   [<ffffffff81187696>] alloc_inode+0x30/0x78
[  192.576077]   [<ffffffff811888b7>] iget_locked+0x69/0x10d
[  192.576077]   [<ffffffff811ce3d2>] sysfs_get_inode+0x1a/0x140
[  192.576077]   [<ffffffff811d00c5>] sysfs_lookup+0x87/0xb2
[  192.576077]   [<ffffffff8117bb84>] lookup_real+0x2c/0x47
[  192.576077]   [<ffffffff8117c04a>] __lookup_hash+0x33/0x3a
[  192.576077]   [<ffffffff8117ce4c>] walk_component+0x77/0x1a4
[  192.576077]   [<ffffffff8117cfaf>] lookup_last+0x36/0x38
[  192.576077]   [<ffffffff8117dae9>] path_lookupat+0x90/0x29d
[  192.576077]   [<ffffffff8117dd1e>] do_path_lookup+0x28/0x92
[  192.576077]   [<ffffffff8117fd71>] user_path_at_empty+0x57/0x95
[  192.576077]   [<ffffffff8117fdc0>] user_path_at+0x11/0x13
[  192.576077]   [<ffffffff81176d41>] vfs_fstatat+0x35/0x66
[  192.576077]   [<ffffffff81176d90>] vfs_lstat+0x1e/0x20
[  192.576077]   [<ffffffff811770e9>] sys_newlstat+0x1a/0x35
[  192.576077]   [<ffffffff82704d10>] tracesys+0xdd/0xe2
[  192.576077] irq event stamp: 14521
[  192.576077] hardirqs last  enabled at (14521): [<ffffffff826fbab4>] __mutex_lock_common+0x31c/0x35f
[  192.576077] hardirqs last disabled at (14520): [<ffffffff826fb836>] __mutex_lock_common+0x9e/0x35f
[  192.576077] softirqs last  enabled at (14516): [<ffffffff8231b6f5>] lock_sock_nested+0x75/0x80
[  192.576077] softirqs last disabled at (14514): [<ffffffff826fd953>] _raw_spin_lock_bh+0x18/0x6f
[  192.576077] 
[  192.576077] other info that might help us debug this:
[  192.576077]  Possible unsafe locking scenario:
[  192.576077] 
[  192.576077]        CPU0
[  192.576077]        ----
[  192.576077]   lock(&mapping->i_mmap_mutex);
[  192.576077]   <Interrupt>
[  192.576077]     lock(&mapping->i_mmap_mutex);
[  192.576077] 
[  192.576077]  *** DEADLOCK ***
[  192.576077] 
[  192.576077] 3 locks held by trinity-child0/7738:
[  192.576077]  #0:  (sk_lock-AF_ATMPVC){+.+.+.}, at: [<ffffffff824e88cc>] pvc_getsockopt+0x31/0x60
[  192.576077]  #1:  (&mm->mmap_sem){++++++}, at: [<ffffffff827013a9>] do_page_fault+0x170/0x3a9
[  192.576077]  #2:  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81075db9>] huge_pte_alloc+0x2c3/0x32b
[  192.576077] 
[  192.576077] stack backtrace:
[  192.576077] Pid: 7738, comm: trinity-child0 Not tainted 3.6.0-rc4+ #5699
[  192.576077] Call Trace:
[  192.576077]  [<ffffffff826d28ff>] print_usage_bug+0x1f7/0x208
[  192.576077]  [<ffffffff81054745>] ? save_stack_trace+0x2c/0x49
[  192.576077]  [<ffffffff810d5047>] ? print_shortest_lock_dependencies+0x185/0x185
[  192.576077]  [<ffffffff810d5786>] mark_lock+0x11b/0x212
[  192.576077]  [<ffffffff810d6d20>] mark_held_locks+0x71/0x99
[  192.576077]  [<ffffffff810d73a5>] lockdep_trace_alloc+0xb9/0xc3
[  192.576077]  [<ffffffff81137443>] __alloc_pages_nodemask+0x9e/0x6f9
[  192.576077]  [<ffffffff810d5698>] ? mark_lock+0x2d/0x212
[  192.576077]  [<ffffffff810d3388>] ? ftrace_raw_event_lock+0xb9/0xc8
[  192.576077]  [<ffffffff810d6d20>] ? mark_held_locks+0x71/0x99
[  192.576077]  [<ffffffff826fbab4>] ? __mutex_lock_common+0x31c/0x35f
[  192.576077]  [<ffffffff81075db9>] ? huge_pte_alloc+0x2c3/0x32b
[  192.576077]  [<ffffffff81164eae>] alloc_pages_current+0xc3/0xe0
[  192.576077]  [<ffffffff81075db9>] ? huge_pte_alloc+0x2c3/0x32b
[  192.576077]  [<ffffffff81133cda>] __get_free_pages+0x16/0x43
[  192.576077]  [<ffffffff81133d1d>] get_zeroed_page+0x16/0x18
[  192.576077]  [<ffffffff811500d1>] __pmd_alloc+0x20/0xa3
[  192.576077]  [<ffffffff8107596b>] pmd_alloc+0x4c/0x57
[  192.576077]  [<ffffffff81075d47>] huge_pte_alloc+0x251/0x32b
[  192.576077]  [<ffffffff81163544>] hugetlb_fault+0xcf/0x575
[  192.576077]  [<ffffffff827013a9>] ? do_page_fault+0x170/0x3a9
[  192.576077]  [<ffffffff82701334>] ? do_page_fault+0xfb/0x3a9
[  192.576077]  [<ffffffff811501c8>] handle_mm_fault+0x44/0xcc
[  192.576077]  [<ffffffff82701598>] do_page_fault+0x35f/0x3a9
[  192.576077]  [<ffffffff8104f55b>] ? native_sched_clock+0x33/0x35
[  192.576077]  [<ffffffff81116de4>] ? irq_trace+0x14/0x21
[  192.576077]  [<ffffffff811174fc>] ? time_hardirqs_off+0x26/0x2a
[  192.576077]  [<ffffffff810b9dba>] ? local_clock+0x3b/0x52
[  192.576077]  [<ffffffff810d31bd>] ? trace_hardirqs_off+0xd/0xf
[  192.576077]  [<ffffffff810d3131>] ? trace_hardirqs_off_caller+0x1f/0x9e
[  192.576077]  [<ffffffff81116de4>] ? irq_trace+0x14/0x21
[  192.576077]  [<ffffffff811174fc>] ? time_hardirqs_off+0x26/0x2a
[  192.576077]  [<ffffffff826fe826>] ? error_sti+0x5/0x6
[  192.576077]  [<ffffffff810d3151>] ? trace_hardirqs_off_caller+0x3f/0x9e
[  192.576077]  [<ffffffff8167c61d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  192.576077]  [<ffffffff82700ed4>] do_async_page_fault+0x31/0x5e
[  192.576077]  [<ffffffff826fe605>] async_page_fault+0x25/0x30
[  192.576077]  [<ffffffff810b9d98>] ? local_clock+0x19/0x52
[  192.576077]  [<ffffffff8167b5fc>] ? __get_user_4+0x1c/0x30
[  192.576077]  [<ffffffff824eba1b>] ? vcc_getsockopt+0x33/0x194
[  192.576077]  [<ffffffff824e88cc>] ? pvc_getsockopt+0x31/0x60
[  192.576077]  [<ffffffff81111772>] ? trace_nowake_buffer_unlock_commit+0xc/0xe
[  192.576077]  [<ffffffff824e88e2>] pvc_getsockopt+0x47/0x60
[  192.576077]  [<ffffffff82319319>] sys_getsockopt+0x7a/0x98
[  192.576077]  [<ffffffff82704d10>] tracesys+0xdd/0xe2

Thanks,
Fengguang

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-waimea-3443-2012-09-13-19-28-32-3.6.0-rc4+-5699"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc4+ (kbuild@bee) (gcc version 4.7.1 (Debian 4.7.1-6) ) #5699 SMP Thu Sep 13 19:15:55 CST 2012
[    0.000000] Command line: trinity=2m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=asoc/for-next log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-09-13-19-17-18-asoc:for-next:17bea57-17bea57-x86_64-allyesdebian-9-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/17bea57/vmlinuz-3.6.0-rc4+
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x1fffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x1fffdfff]
[    0.000000]  [mem 0x00000000-0x1fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0x1fffdfff @ [mem 0x1fefc000-0x1fffdfff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127900(97%)
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 00040
[    0.000000] ACPI: SSDT 000000001ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000001ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1f6f7000-0x1f6fbfff]
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e600000-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130945
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3901 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 124990 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000093000 - 0000000000094000
[    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 478 pages/cpu @ffff88001f200000 s1925848 r8192 d23848 u2097152
[    0.000000] pcpu-alloc: s1925848 r8192 d23848 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1f20e200
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 128891
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: trinity=2m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=asoc/for-next log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-09-13-19-17-18-asoc:for-next:17bea57-17bea57-x86_64-allyesdebian-9-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/17bea57/vmlinuz-3.6.0-rc4+
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 445544k/524280k available (23593k kernel code, 500k absent, 78236k reserved, 16104k data, 3612k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] NR_IRQS:33024 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 3300.109 MHz processor
[    0.004004] Calibrating delay loop (skipped), value calculated using timer frequency.. 6600.21 BogoMIPS (lpj=13200436)
[    0.008583] pid_max: default: 32768 minimum: 301
[    0.009767] Security Framework initialized
[    0.010718] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.012389] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.013655] Mount-cache hash table entries: 256
[    0.016967] Initializing cgroup subsys cpuacct
[    0.017743] Initializing cgroup subsys devices
[    0.018528] Initializing cgroup subsys freezer
[    0.019333] Initializing cgroup subsys net_cls
[    0.020019] Initializing cgroup subsys blkio
[    0.021030] mce: CPU supports 10 MCE banks
[    0.021794] numa_add_cpu cpu 0 node 0: mask now 0
[    0.022624] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.022624] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.022624] tlb_flushall_shift is 0x6
[    0.025312] ACPI: Core revision 20120711
[    0.030073] ftrace: allocating 90314 entries in 353 pages
[    0.048259] Getting VERSION: 50014
[    0.048914] Getting VERSION: 50014
[    0.049560] Getting ID: 0
[    0.052013] Getting ID: ff000000
[    0.052667] Getting LVT0: 8700
[    0.053269] Getting LVT1: 8400
[    0.053911] enabled ExtINT on CPU#0
[    0.055172] ENABLING IO-APIC IRQs
[    0.056013] init IO_APIC IRQs
[    0.056592]  apic 2 pin 0 not connected
[    0.057321] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.058702] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.060035] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.062158] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.064025] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.065372] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.068022] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.069428] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.070753] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.072022] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.073417] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.074783] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.076023] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.077433] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.078826] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.080020]  apic 2 pin 16 not connected
[    0.080742]  apic 2 pin 17 not connected
[    0.081437]  apic 2 pin 18 not connected
[    0.084010]  apic 2 pin 19 not connected
[    0.084704]  apic 2 pin 20 not connected
[    0.085440]  apic 2 pin 21 not connected
[    0.086152]  apic 2 pin 22 not connected
[    0.086876]  apic 2 pin 23 not connected
[    0.088146] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.089298] smpboot: CPU0: Intel Common KVM processor stepping 01
[    0.090663] Using local APIC timer interrupts.
[    0.090663] calibrating APIC timer ...
[    0.096006] ... lapic delta = 6265912
[    0.096006] ... PM-Timer delta = 358886
[    0.096006] ... PM-Timer result ok
[    0.096006] ..... delta 6265912
[    0.096006] ..... mult: 269102052
[    0.096006] ..... calibration result: 4010183
[    0.096006] ..... CPU clock speed is 3309.0209 MHz.
[    0.096006] ..... host bus clock speed is 1002.2183 MHz.
[    0.096067] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.099523] Testing tracer nop: PASSED
[    0.101831] SMP alternatives: lockdep: fixing up alternatives
[    0.103227] smpboot: Booting Node   0, Processors  #1 OK
[    0.008000] masked ExtINT on CPU#1
[    0.008000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.200012] TSC synchronization [CPU#0 -> CPU#1]:
[    0.200012] Measured 2597 cycles TSC warp between CPUs, turning off TSC clock.
[    0.200012] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.204224] Brought up 2 CPUs
[    0.204224] KVM setup async PF for cpu 1
[    0.204224] kvm-stealtime: cpu 1, msr 1f40e200
[    0.208018] smpboot: Total of 2 processors activated (13215.01 BogoMIPS)
[    0.209507] CPU0 attaching sched-domain:
[    0.210240]  domain 0: span 0-1 level CPU
[    0.212479]   groups: 0 1
[    0.213257] CPU1 attaching sched-domain:
[    0.213968]  domain 0: span 0-1 level CPU
[    0.214828]   groups: 1 0
[    0.216361] devtmpfs: initialized
[    0.225993] xor: automatically using best checksumming function:
[    0.264033]    generic_sse:   205.000 MB/sec
[    0.264806] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.266553] dummy: 
[    0.267631] NET: Registered protocol family 16
[    0.271606] ACPI: bus type pci registered
[    0.272180] dca service started, version 1.12.1
[    0.273063] PCI: Using configuration type 1 for base access
[    0.324171] bio: create slab <bio-0> at 0
[    0.392037] raid6: sse2x1    9405 MB/s
[    0.460035] raid6: sse2x2   11644 MB/s
[    0.528041] raid6: sse2x4   13607 MB/s
[    0.528735] raid6: using algorithm sse2x4 (13607 MB/s)
[    0.529584] raid6: using intx1 recovery algorithm
[    0.530613] ACPI: Added _OSI(Module Device)
[    0.531377] ACPI: Added _OSI(Processor Device)
[    0.532040] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.532818] ACPI: Added _OSI(Processor Aggregator Device)
[    0.535625] ACPI: EC: Look up EC in DSDT
[    0.542339] ACPI: Interpreter enabled
[    0.543033] ACPI: (supports S0 S3 S4 S5)
[    0.544038] ACPI: Using IOAPIC for interrupt routing
[    0.555784] ACPI: No dock devices found.
[    0.556040] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.557648] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.558701] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.560040] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.561305] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.562736] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.564048] PCI: root bus 00: using default resources
[    0.564915] pci_root PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.566924] PCI host bridge to bus 0000:00
[    0.568047] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
[    0.569362] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.570261] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.571242] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.572105] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.573497] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.575021] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.577451] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    0.579200] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.580474] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.581724] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.583009] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.585769] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.588140] pci 0000:00:02.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    0.592861] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    0.594446] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.595733] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    0.596592] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    0.600858] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.602301] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.603491] pci 0000:00:04.0: reg 10: [mem 0xfebf0000-0xfebf3fff]
[    0.606222] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.608077] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    0.609497] pci 0000:00:05.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    0.613683] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.615002] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    0.616327] pci 0000:00:06.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    0.620620] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.621940] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.623384] pci 0000:00:07.0: reg 14: [mem 0xfebf7000-0xfebf7fff]
[    0.627251] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.628393] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    0.629813] pci 0000:00:08.0: reg 14: [mem 0xfebf8000-0xfebf8fff]
[    0.634477] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.635802] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    0.636593] pci 0000:00:09.0: reg 14: [mem 0xfebf9000-0xfebf9fff]
[    0.641409] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.642729] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    0.644079] pci 0000:00:0a.0: reg 14: [mem 0xfebfa000-0xfebfafff]
[    0.648329] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.649479] pci 0000:00:0b.0: reg 10: [mem 0xfebfb000-0xfebfb00f]
[    0.652615] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.655307]  pci0000:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.656067]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.674595] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.676160] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.677675] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.679188] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.680680] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.682581] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.684084] vgaarb: loaded
[    0.684620] vgaarb: bridge control possible 0000:00:02.0
[    0.685773] tps65010: version 2 May 2005
[    0.716155] tps65010: no chip?
[    0.717823] SCSI subsystem initialized
[    0.718513] ACPI: bus type scsi registered
[    0.719627] libata version 3.00 loaded.
[    0.720432] pps_core: LinuxPPS API ver. 1 registered
[    0.721344] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.724083] wmi: Mapper loaded
[    0.724960] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    0.726026] PCI: Using ACPI for IRQ routing
[    0.726851] PCI: pci_cache_line_size set to 64 bytes
[    0.728219] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.729213] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    0.731152] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    0.732182] NET: Registered protocol family 23
[    0.733117] Bluetooth: Core ver 2.16
[    0.733941] NET: Registered protocol family 31
[    0.735113] Bluetooth: HCI device and connection manager initialized
[    0.736064] Bluetooth: HCI socket layer initialized
[    0.736930] Bluetooth: L2CAP socket layer initialized
[    0.737896] Bluetooth: SCO socket layer initialized
[    0.738867] NET: Registered protocol family 8
[    0.740051] NET: Registered protocol family 20
[    0.741578] cfg80211: Calling CRDA to update world regulatory domain
[    0.745295] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.746502] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.747959] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.752267] Switching to clocksource hpet
[    0.993084] FS-Cache: Loaded
[    0.994083] CacheFiles: Loaded
[    0.994761] pnp: PnP ACPI init
[    0.995425] ACPI: bus type pnp registered
[    0.996285] pnp 00:00: [bus 00-ff]
[    0.996916] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.997647] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.998467] pnp 00:00: [io  0x0d00-0xffff window]
[    0.999284] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.000235] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    1.001305] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    1.002403] pnp 00:01: [io  0x0070-0x0071]
[    1.003165] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    1.004548] pnp 00:01: [irq 8]
[    1.005145] pnp 00:01: [io  0x0072-0x0077]
[    1.005931] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.007090] pnp 00:02: [io  0x0060]
[    1.013205] pnp 00:02: [io  0x0064]
[    1.013860] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    1.015201] pnp 00:02: [irq 1]
[    1.015856] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.017049] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    1.018428] pnp 00:03: [irq 12]
[    1.019123] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.020298] pnp 00:04: [io  0x03f2-0x03f5]
[    1.021025] pnp 00:04: [io  0x03f7]
[    1.021663] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    1.023007] pnp 00:04: [irq 6]
[    1.023591] pnp 00:04: [dma 2]
[    1.024317] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.025480] pnp 00:05: [io  0x0378-0x037f]
[    1.026229] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    1.027559] pnp 00:05: [irq 7]
[    1.028291] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.029427] pnp 00:06: [io  0x03f8-0x03ff]
[    1.030163] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    1.031495] pnp 00:06: [irq 4]
[    1.032220] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.033615] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    1.034564] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.035914] pnp: PnP ACPI: found 8 devices
[    1.036707] ACPI: ACPI bus type pnp unregistered
[    1.062363] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    1.063294] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    1.064919] NET: Registered protocol family 2
[    1.067108] TCP established hash table entries: 16384 (order: 6, 262144 bytes)
[    1.068952] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
[    1.071458] TCP: Hash tables configured (established 16384 bind 16384)
[    1.072676] TCP: reno registered
[    1.073330] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    1.074365] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    1.076068] NET: Registered protocol family 1
[    1.077843] RPC: Registered named UNIX socket transport module.
[    1.078808] RPC: Registered udp transport module.
[    1.079604] RPC: Registered tcp transport module.
[    1.080479] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.081530] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.082506] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.083462] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.084531] pci 0000:00:02.0: Boot video device
[    1.085426] PCI: CLS 0 bytes, default 64
[    1.113299] DMA-API: preallocated 32768 debug entries
[    1.114165] DMA-API: debugging enabled by kernel config
[    1.116787] kvm: no hardware support
[    1.117500] has_svm: not amd
[    1.118077] kvm: no hardware support
[    1.119067] Machine check injector initialized
[    1.121448] microcode: CPU0 sig=0xf61, pf=0x1, revision=0x1
[    1.122432] microcode: CPU1 sig=0xf61, pf=0x1, revision=0x1
[    1.123921] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.126102] cryptomgr_test (28) used greatest stack depth: 6536 bytes left
[    1.131212] Initializing RT-Tester: OK
[    1.132103] audit: initializing netlink socket (disabled)
[    1.133182] type=2000 audit(1347535504.132:1): initialized
[    1.185215] Kprobe smoke test started
[    1.264337] Kprobe smoke test passed successfully
[    1.268172] Testing tracer function: PASSED
[    1.590474] Testing dynamic ftrace: PASSED
[    2.060927] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 3 1 10) (2 2 4 1 223) PASSED
[    2.642076] Testing dynamic ftrace ops #2: (1 0 1 4 0) (1 1 2 200 0) (2 1 3 1 5) (2 2 4 212 216) PASSED
[    3.252237] Testing tracer irqsoff: PASSED
[    3.760762] Testing tracer wakeup: [    4.512495] ftrace-test (41) used greatest stack depth: 6400 bytes left
PASSED
[    4.560322] Testing tracer wakeup_rt: PASSED
[    5.344316] Testing tracer function_graph: PASSED
[    5.858712] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    5.862146] VFS: Disk quotas dquot_6.5.2
[    5.862978] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    5.865898] DLM installed
[    5.868864] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    5.873559] FS-Cache: Netfs 'nfs' registered for caching
[    5.875496] NFS: Registering the id_resolver key type
[    5.876490] Key type id_resolver registered
[    5.877239] Key type id_legacy registered
[    5.877941] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    5.881571] Key type cifs.spnego registered
[    5.882413] NTFS driver 2.1.30 [Flags: R/W].
[    5.883628] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    5.884606] jffs2: version 2.2. (NAND) (SUMMARY)  
[    5.886845] ROMFS MTD (C) 2007 Red Hat, Inc.
[    5.887737] QNX4 filesystem 0.2.3 registered.
[    5.888953] fuse init (API version 7.20)
[    5.890891] JFS: nTxBlock = 3480, nTxLock = 27846
[    5.895330] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[    5.899481] 9p: Installing v9fs 9p2000 file system support
[    5.900535] FS-Cache: Netfs '9p' registered for caching
[    5.901810] NILFS version 2 loaded
[    5.902470] BeFS version: 0.9.3
[    5.903223] OCFS2 1.5.0
[    5.904517] ocfs2: Registered cluster interface o2cb
[    5.905701] ocfs2: Registered cluster interface user
[    5.906617] OCFS2 DLMFS 1.5.0
[    5.907554] OCFS2 User DLM kernel interface loaded
[    5.908494] OCFS2 Node Manager 1.5.0
[    5.909650] OCFS2 DLM 1.5.0
[    5.911739] Btrfs loaded
[    5.914008] GFS2 installed
[    5.915027] ceph: loaded (mds proto 32)
[    5.915729] msgmni has been set to 870
[    5.934159] async_tx: api initialized (async)
[    5.935107] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    5.936730] io scheduler noop registered
[    5.937438] io scheduler deadline registered
[    5.938407] io scheduler cfq registered (default)
[    5.939221] start plist test
[    5.941070] end plist test
[    5.942586] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    5.943605] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    5.945085] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    5.946220] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
[    5.947512] cpcihp_generic: not configured, disabling.
[    5.948512] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    5.949567] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    5.950925] acpiphp: Slot [3] registered
[    5.951727] acpiphp: Slot [4] registered
[    5.952592] acpiphp: Slot [5] registered
[    5.953401] acpiphp: Slot [6] registered
[    5.954195] acpiphp: Slot [7] registered
[    5.955053] acpiphp: Slot [8] registered
[    5.955862] acpiphp: Slot [9] registered
[    5.957082] acpiphp: Slot [10] registered
[    5.957896] acpiphp: Slot [11] registered
[    5.958677] acpiphp: Slot [12] registered
[    5.959475] acpiphp: Slot [13] registered
[    5.960347] acpiphp: Slot [14] registered
[    5.961141] acpiphp: Slot [15] registered
[    5.961932] acpiphp: Slot [16] registered
[    5.962722] acpiphp: Slot [17] registered
[    5.963517] acpiphp: Slot [18] registered
[    5.964392] acpiphp: Slot [19] registered
[    5.965192] acpiphp: Slot [20] registered
[    5.965993] acpiphp: Slot [21] registered
[    5.966791] acpiphp: Slot [22] registered
[    5.967585] acpiphp: Slot [23] registered
[    5.968426] acpiphp: Slot [24] registered
[    5.969236] acpiphp: Slot [25] registered
[    5.970042] acpiphp: Slot [26] registered
[    5.970811] acpiphp: Slot [27] registered
[    5.971613] acpiphp: Slot [28] registered
[    5.972481] acpiphp: Slot [29] registered
[    5.973292] acpiphp: Slot [30] registered
[    5.974168] acpiphp: Slot [31] registered
[    5.977464] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    5.979298] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    5.980883] vmlfb: initializing
[    5.981620] Could not find Carillo Ranch MCH device.
[    5.982643] no IO addresses supplied
[    5.983544] hgafb: HGA card not detected.
[    5.984557] hgafb: probe of hgafb.0 failed with error -22
[    5.986690] kworker/u:0 (115) used greatest stack depth: 5352 bytes left
[    5.987860] uvesafb: failed to execute /sbin/v86d
[    5.988993] uvesafb: make sure that the v86d helper is installed and executable
[    5.990360] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    5.991442] uvesafb: vbe_init() failed with -22
[    5.992386] uvesafb: probe of uvesafb.0 failed with error -22
[    5.993985] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    5.995352] ACPI: Power Button [PWRF]
[    6.005688] GHES: HEST is not enabled!
[    6.006405] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    6.008127] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    6.009089] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[    6.016084] virtio-pci 0000:00:05.0: setting latency timer to 64
[    6.017919] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[    6.018867] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[    6.020342] virtio-pci 0000:00:06.0: setting latency timer to 64
[    6.021887] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    6.022858] virtio-pci 0000:00:07.0: setting latency timer to 64
[    6.024523] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    6.025504] virtio-pci 0000:00:08.0: setting latency timer to 64
[    6.026881] virtio-pci 0000:00:09.0: setting latency timer to 64
[    6.028290] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    6.029561] XENFS: not registering filesystem on non-xen platform
[    6.031126] HDLC line discipline maxframe=4096
[    6.031977] N_HDLC line discipline registered.
[    6.032815] r3964: Philips r3964 Driver $Revision: 1.10 $
[    6.033706] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    6.058360] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    6.085108] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    6.086894] Cyclades driver 2.6
[    6.087727] MOXA Intellio family driver version 6.0k
[    6.121026] MOXA Smartio/Industio family driver version 2.0.5
[    6.122097] Initializing Nozomi driver 2.1d
[    6.122911] RocketPort device driver module, version 2.09, 12-June-2003
[    6.123979] No rocketport ports found; unloading driver
[    6.124990] SyncLink GT
[    6.125559] SyncLink GT, tty major#247
[    6.126315] SyncLink GT no devices found
[    6.127037] SyncLink MultiPort driver $Revision: 4.38 $
[    6.159561] SyncLink MultiPort driver $Revision: 4.38 $, tty major#246
[    6.160689] SyncLink serial driver $Revision: 4.38 $
[    6.193401] SyncLink serial driver $Revision: 4.38 $, tty major#245
[    6.195482] lp: driver loaded but no devices found
[    6.196366] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    6.197518] ac.o: No PCI boards found.
[    6.198296] ac.o: For an ISA board you must supply memory and irq parameters.
[    6.200257] Non-volatile memory driver v1.3
[    6.201680] ppdev: user-space parallel port driver
[    6.202688] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    6.203950] smapi::smapi_init, ERROR invalid usSmapiID
[    6.205414] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[    6.207701] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[    6.208978] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    6.210077] Linux agpgart interface v0.103
[    6.212824] SyncLink PC Card driver $Revision: 4.34 $, tty major#243
[    6.213984] ipmi message handler version 39.2
[    6.214906] ipmi device interface
[    6.215646] IPMI System Interface driver.
[    6.216717] ipmi_si: Adding default-specified kcs state machine
[    6.217826] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    6.219439] ipmi_si: Interface detection failed
[    6.220463] ipmi_si: Adding default-specified smic state machine
[    6.221597] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    6.223391] ipmi_si: Interface detection failed
[    6.232234] ipmi_si: Adding default-specified bt state machine
[    6.233428] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    6.235141] ipmi_si: Interface detection failed
[    6.236184] ipmi_si: Unable to find any System Interface(s)
[    6.237141] IPMI Watchdog: driver initialized
[    6.237894] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    6.239319] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    6.241091] Hangcheck: Using getrawmonotonic().
[    6.242213] [drm] Initialized drm 1.1.0 20060810
[    6.243458] [drm] radeon defaulting to kernel modesetting.
[    6.244477] [drm] radeon kernel modesetting enabled.
[    6.245885] parport_pc 00:05: reported by Plug and Play ACPI
[    6.247411] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    6.345136] lp0: using parport0 (interrupt-driven).
[    6.349127] Floppy drive(s): fd0 is 1.44M
[    6.357549] brd: module loaded
[    6.361794] loop: module loaded
[    6.362547] Compaq SMART2 Driver (v 2.6.0)
[    6.363785] HP CISS Driver (v 3.6.26)
[    6.365769] FDC 0 is a S82078B
[    6.366555] MM: desc_per_page = 128
[    6.369409] nbd: registered device at major 43
[    6.378374] virtio-pci 0000:00:05.0: irq 40 for MSI/MSI-X
[    6.379440] virtio-pci 0000:00:05.0: irq 41 for MSI/MSI-X
[    6.399370]  vda: unknown partition table
[    6.400748] virtio-pci 0000:00:06.0: irq 42 for MSI/MSI-X
[    6.401672] virtio-pci 0000:00:06.0: irq 43 for MSI/MSI-X
[    6.415627]  vdb: unknown partition table
[    6.417019] virtio-pci 0000:00:07.0: irq 44 for MSI/MSI-X
[    6.417952] virtio-pci 0000:00:07.0: irq 45 for MSI/MSI-X
[    6.435370]  vdc: unknown partition table
[    6.437369] virtio-pci 0000:00:08.0: irq 46 for MSI/MSI-X
[    6.438817] virtio-pci 0000:00:08.0: irq 47 for MSI/MSI-X
[    6.452232]  vdd: unknown partition table
[    6.454176] virtio-pci 0000:00:09.0: irq 48 for MSI/MSI-X
[    6.455592] virtio-pci 0000:00:09.0: irq 49 for MSI/MSI-X
[    6.470021]  vde: unknown partition table
[    6.471924] virtio-pci 0000:00:0a.0: irq 50 for MSI/MSI-X
[    6.473455] virtio-pci 0000:00:0a.0: irq 51 for MSI/MSI-X
[    6.488124]  vdf: unknown partition table
[    6.494342] drbd: initialized. Version: 8.3.13 (api:88/proto:86-96)
[    6.495915] drbd: built-in
[    6.496853] drbd: registered as block device major 147
[    6.498210] drbd: minor_table @ 0xffff88001687eef0
[    6.499643] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    6.501339] lkdtm: No crash points registered, enable through debugfs
[    6.502503] Phantom Linux Driver, version n0.9.8, init OK
[    6.503602] i2c-core: driver [isl29003] using legacy suspend method
[    6.504696] i2c-core: driver [isl29003] using legacy resume method
[    6.505722] i2c-core: driver [tsl2550] using legacy suspend method
[    6.506718] i2c-core: driver [tsl2550] using legacy resume method
[    6.507861] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[    6.509486] c2port c2port0: C2 port uc added
[    6.510244] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[    6.512075] Uniform Multi-Platform E-IDE driver
[    6.513023] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    6.514241] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    6.515361] pci 0000:00:01.1: setting latency timer to 64
[    6.516386]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    6.517223]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    6.518096] Probing IDE interface ide0...
[    7.084502] Probing IDE interface ide1...
[    7.820590] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    8.492570] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    8.494338] hdc: MWDMA2 mode selected
[    8.495687] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    8.497262] ide1 at 0x170-0x177,0x376 on irq 15
[    8.499937] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    8.502508] ide-gd driver 1.18
[    8.503528] ide-cd driver 5.00
[    8.505160] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[    8.507127] cdrom: Uniform CD-ROM driver Revision: 3.20
[    8.512534] Loading iSCSI transport class v2.0-870.
[    8.514278] rdac: device handler registered
[    8.515307] hp_sw: device handler registered
[    8.516186] emc: device handler registered
[    8.516967] alua: device handler registered
[    8.518931] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[    8.520558] iscsi: registered transport (tcp)
[    8.521585] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[    8.522528] Detecting Adaptec I2O RAID controllers...
[    8.523585] Adaptec aacraid driver 1.2-0[29800]-ms
[    8.524810] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    8.526407] scsi: <fdomain> Detection failed (no card)
[    8.527433] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.03-k.
[    8.529072] iscsi: registered transport (qla4xxx)
[    8.529920] QLogic iSCSI HBA Driver
[    8.530595] Brocade BFA FC/FCOE SCSI driver - version: 3.0.23.0
[    8.531927] DC390: clustering now enabled by default. If you get problems load
[    8.533313]        with "disable_clustering=1" and report to maintainers
[    8.534558] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    8.536161] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    8.537296] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
[    8.538397] mpt2sas version 13.100.00.00 loaded
[    8.539576] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    8.540836] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    8.541972] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[    8.543333] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[    8.544829] ppa: Version 2.07 (for Linux 2.4.x)
[    8.547976] imm: Version 2.05 (for Linux 2.4.0)
[    8.549348] ipr: IBM Power RAID SCSI Device Driver version: 2.5.3 (March 10, 2012)
[    8.550736] RocketRAID 3xxx/4xxx Controller driver v1.6 (091225)
[    8.551785] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    8.553121] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
[    8.554476] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
[    8.555561] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[    8.556746] iscsi: registered transport (cxgb3i)
[    8.557569] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2012)
[    8.558776] iscsi: registered transport (bnx2i)
[    8.560200] iscsi: registered transport (be2iscsi)
[    8.566784] VMware PVSCSI driver - version 1.0.2.0-k
[    8.567691] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    8.568914] osst :I: Tape driver with OnStream support version 0.99.4
[    8.568914] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    8.571293] SCSI Media Changer driver v0.25 
[    8.572227] osd: LOADED open-osd 0.2.1
[    8.580102] scsi_debug: host protection
[    8.580825] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[    8.583648] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[    8.588217] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
[    8.588617] SSFDC read-only Flash Translation layer
[    8.588621] mtdoops: mtd device (mtddev=name/number) must be supplied
[    8.588747] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    8.588917] NetSc520 flash device: 0x100000 at 0x200000
[    8.588920] Failed to ioremap_nocache
[    8.588926] Failed to ioremap_nocache
[    8.589060] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[    8.597511] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    8.600157] sd 0:0:0:0: [sda] Write Protect is off
[    8.601438] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    8.608137] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[    8.615081] No recognised DiskOnChip devices found
[    8.615885] slram: not enough parameters.
[    8.616643] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[    8.617931] pmc551: not detected
[    8.621114] kworker/u:0 (136) used greatest stack depth: 5320 bytes left
[    8.623717] ftl_cs: FTL header not found.
[    8.631924] DiskOnChip Millennium Plus 32MB is not supported, ignoring.
[    8.640194]  sda: unknown partition table
[    8.655049] No valid DiskOnChip devices found
[    8.656223] sd 0:0:0:0: [sda] Attached SCSI disk
[    8.657665] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.659788] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.661379] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.662988] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.664565] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.666109] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.667715] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), page size: 512, OOB size: 16
[    8.669667] flash size: 128 MiB
[    8.670350] page size: 512 bytes
[    8.670942] OOB area size: 16 bytes
[    8.671590] sector size: 16 KiB
[    8.672242] pages number: 262144
[    8.672839] pages per sector: 32
[    8.673449] bus width: 8
[    8.673962] bits in sector size: 14
[    8.674806] bits in page size: 9
[    8.675720] bits in OOB size: 4
[    8.676736] flash size with OOB: 135168 KiB
[    8.677874] page address bytes: 4
[    8.678798] sector address bytes: 3
[    8.679717] options: 0x42
[    8.682381] Scanning device for bad blocks
[    8.726393] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    8.727607] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    8.729900] ftl_cs: FTL header not found.
[    8.764094] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[    8.765183] OneNAND Manufacturer: Samsung (0xec)
[    8.765957] OneNAND 16MB 1.8V 16-bit (0x04)
[    8.766714] OneNAND version = 0x001e
[    8.767368] Lock scheme is Continuous Lock
[    8.768212] Scanning device for bad blocks
[    8.770508] Creating 1 MTD partitions on "OneNAND simulator":
[    8.771476] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[    8.775664] ftl_cs: FTL header not found.
[    8.893905] parport_pc 00:05: master is unqueued, this is deprecated
[    8.897503] parport0: AVR Butterfly
[    8.898590] parport0: cannot grant exclusive access for device spi-lm70llp
[    8.900408] spi-lm70llp: spi_lm70llp probe fail, status -12
[    8.901930] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[    8.905540] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[    8.910415] tun: Universal TUN/TAP device driver, 1.6
[    8.911325] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    8.913104] arcnet loaded.
[    8.913957] arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
[    8.915661] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[    8.917134] arcnet: raw mode (`r') encapsulation support loaded.
[    8.918165] arcnet: cap mode (`c') encapsulation support loaded.
[    8.919186] arcnet: COM90xx chipset support
[    9.220631] S3: No ARCnet cards found.
[    9.221385] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[    9.222637] E-mail me if you actually test this driver, please!
[    9.223585]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[    9.225021] arcnet: RIM I (entirely mem-mapped) support
[    9.225880] E-mail me if you actually test the RIM I driver, please!
[    9.226891] Given: node 00h, shmem 0h, irq 0
[    9.227633] No autoprobe for RIM I; you must specify the shmem and irq!
[    9.228736] arcnet: COM20020 PCI support
[    9.229605] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    9.231282] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    9.232790] vcan: Virtual CAN interface driver
[    9.233560] CAN device driver interface
[    9.234251] sja1000 CAN netdevice driver
[    9.235459] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 29, 2012)
[    9.237159] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.72.51-0 (2012/06/18)
[    9.239592] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[    9.240810] vxge: Copyright(c) 2002-2010 Exar Corp.
[    9.241644] vxge: Driver version: 2.5.3.22640-k
[    9.242505] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    9.243599] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    9.244692] e1000 0000:00:03.0: setting latency timer to 64
[    9.581509] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[    9.582672] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
[    9.583844] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[    9.584853] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[    9.585918] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.1-k
[    9.587093] igb: Copyright (c) 2007-2012 Intel Corporation.
[    9.588147] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.1-k
[    9.589479] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    9.590602] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
[    9.591896] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[    9.592961] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.6.0-k
[    9.594559] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[    9.595612] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[    9.596790] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    9.597919] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    9.599081] sky2: driver version 1.30
[    9.600346] myri10ge: Version 1.5.3-1.534
[    9.601191] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[    9.602555] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.0.29
[    9.603988] QLogic/NetXen Network Driver v4.0.80
[    9.605081] Solarflare NET driver v3.1
[    9.606343] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[    9.607329] tehuti: Options: hw_csum 
[    9.608343] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    9.609241] AX.25: 6pack driver, Revision: 0.3.0
[    9.610058] YAM driver version 0.8 by F1OAT/F6FBB
[    9.612445] AX.25: bpqether driver version 004
[    9.613228] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.613228] baycom_ser_fdx: version 0.10
[    9.616468] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    9.617488] hdlcdrv: version 0.8
[    9.618140] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.618140] baycom_ser_hdx: version 0.10
[    9.621223] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.621223] baycom_par: version 0.9
[    9.626051] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[    9.626977] plip0: Parallel port at 0x378, using IRQ 7.
[    9.627902] PPP generic driver version 2.4.2
[    9.628926] PPP BSD Compression module registered
[    9.629737] PPP Deflate Compression module registered
[    9.630699] PPP MPPE Compression module registered
[    9.631537] NET: Registered protocol family 24
[    9.632405] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
[    9.634033] CSLIP: code copyright 1989 Regents of the University of California.
[    9.635286] SLIP linefill/keepalive option.
[    9.636136] hdlc: HDLC support module revision 1.22
[    9.637223] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[    9.638269] cycx_drv: Cyclom 2X Support Module v0.6 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[    9.639899] cyclomx: CYCLOM 2X(tm) Sync Card Driver v0.11 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[    9.641912] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmprq
[    9.643254] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[    9.649863] libipw: 802.11 data/management/control stack, git-1.1.13
[    9.650958] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[    9.652361] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin <proski@gnu.org>, et al)
[    9.654065] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[    9.656144] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[    9.657246] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <disdos@traum404.de>)
[    9.658814] airo(): Probing for PCI adapters
[    9.659649] airo(): Finished probing for PCI adapters
[    9.661069] Broadcom 43xx driver loaded [ Features: PMLS ]
[    9.662064] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[    9.663358] libertas_sdio: Libertas SDIO driver
[    9.664246] libertas_sdio: Copyright Pierre Ossman
[    9.665106] libertas_spi: Libertas SPI driver
[    9.666354] Intel(R) Wireless WiFi driver for Linux, in-tree:
[    9.667339] Copyright(c) 2003-2012 Intel Corporation
[    9.668306] iwldvm: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:
[    9.669538] iwldvm: Copyright(c) 2003-2012 Intel Corporation
[    9.670615] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[    9.672186] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[    9.673695] mac80211_hwsim: Initializing radio 0
[    9.675333] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    9.677043] ieee80211 phy0: hwaddr 020000000000 registered
[    9.678090] mac80211_hwsim: Initializing radio 1
[    9.679355] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[    9.681057] ieee80211 phy1: hwaddr 020000000100 registered
[    9.682487] mac80211_hwsim: initializing netlink
[    9.683488] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[    9.684806] Madge ATM Ambassador driver version 1.2.4
[    9.685738] Madge ATM Horizon [Ultra] driver version 1.2.1
[    9.687107] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[    9.688502] idt77252_init: at ffffffff838f7e99
[    9.689343] Solos PCI Driver Version 0.07
[    9.690193] adummy: version 1.0
[    9.691592] I2O subsystem v1.325
[    9.692272] i2o: max drivers = 8
[    9.693319] I2O Configuration OSM v1.323
[    9.694376] I2O Bus Adapter OSM v1.317
[    9.695104] I2O Block Device OSM v1.325
[    9.696650] I2O SCSI Peripheral OSM v1.316
[    9.697488] I2O ProcFS OSM v1.316
[    9.698283] Fusion MPT base driver 3.04.20
[    9.699041] Copyright (c) 1999-2008 LSI Corporation
[    9.699889] Fusion MPT SPI Host driver 3.04.20
[    9.700878] Fusion MPT FC Host driver 3.04.20
[    9.701727] Fusion MPT SAS Host driver 3.04.20
[    9.702893] Fusion MPT misc device (ioctl) driver 3.04.20
[    9.704170] mptctl: Registered with Fusion MPT base driver
[    9.705082] mptctl: /dev/mptctl @ (major,minor=10,220)
[    9.705918] Fusion MPT LAN driver 3.04.20
[    9.707663] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[    9.709770] aoe: AoE v47 initialised.
[    9.711558] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    9.714020] serio: i8042 KBD port at 0x60,0x64 irq 1
[    9.714920] serio: i8042 AUX port at 0x60,0x64 irq 12
[    9.716214] parport0: cannot grant exclusive access for device parkbd
[    9.781134] mousedev: PS/2 mouse device common for all mice
[    9.783900] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    9.788909] parport0: cannot grant exclusive access for device walkera0701
[    9.791041] mk712: device not present
[    9.792267] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    9.793669] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    9.795711] rtc_cmos 00:01: RTC can wake from S4
[    9.797569] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    9.799419] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[    9.802244] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    9.803476] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    9.804638] i2c /dev entries driver
[    9.806071] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[    9.920983] i2c-parport: adapter type unspecified
[    9.921820] i2c-parport-light: adapter type unspecified
[    9.922766] pps_ldisc: PPS line discipline registered
[    9.923610] Driver for 1-wire Dallas network protocol.
[    9.924806] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[    9.926488] i2c-core: driver [max17040] using legacy suspend method
[    9.927496] i2c-core: driver [max17040] using legacy resume method
[   10.236571] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[   11.152256] i2c i2c-0: detect fail: address match, 0x2c
[   11.168155] i2c i2c-0: detect fail: address match, 0x2d
[   11.184178] i2c i2c-0: detect fail: address match, 0x2e
[   11.200245] i2c i2c-0: detect fail: address match, 0x2f
[   11.464248] applesmc: supported laptop not found!
[   11.465496] applesmc: driver init failed (ret=-19)!
[   19.320327] pc87360: PC8736x not detected, module not inserted
[   19.824458] acquirewdt: WDT driver for Acquire single board computer initialising
[   19.826071] acquirewdt: I/O address 0x0043 already in use
[   19.827055] acquirewdt: probe of acquirewdt failed with error -5
[   19.828135] advantechwdt: WDT driver for Advantech single board computer initialising
[   19.830103] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   19.831224] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   19.832195] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   19.833264] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[   19.834524] ib700wdt: WDT driver for IB700 single board computer initialising
[   19.835972] ib700wdt: START method I/O 443 is not available
[   19.836970] ib700wdt: probe of ib700wdt failed with error -5
[   19.838376] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   19.840569] wafer5823wdt: I/O address 0x0443 already in use
[   19.841649] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   19.843050] i6300esb: cannot register miscdev on minor=130 (err=-16)
[   19.844244] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[   19.845504] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   19.846575] iTCO_vendor_support: vendor-support=0
[   19.847499] it87_wdt: no device
[   19.848277] sc1200wdt: build 20020303
[   19.848983] sc1200wdt: io parameter must be specified
[   19.849898] pc87413_wdt: Version 1.1 at io 0x2E
[   19.850776] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   19.851825] sbc60xxwdt: I/O address 0x0443 already in use
[   19.852794] sbc8360: failed to register misc device
[   19.853976] cpu5wdt: misc_register failed
[   19.854846] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   19.857441] smsc37b787_wdt: Unable to register miscdev on minor 130
[   19.858578] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[   19.860203] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[   19.861638] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[   19.862822] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   19.863863] w83697hf_wdt: watchdog not found at address 0x2e
[   19.864855] w83697hf_wdt: No W83697HF/HG could be found
[   19.865817] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[   19.867400] w83697ug_wdt: No W83697UG/UF could be found
[   19.868358] w83877f_wdt: I/O address 0x0443 already in use
[   19.869604] w83977f_wdt: driver v1.00
[   19.870513] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[   19.871624] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   19.872715] machzwd: no ZF-Logic found
[   19.873587] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   19.874928] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[   19.876360] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[   19.878094] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   19.880160] md: linear personality registered for level -1
[   19.881117] md: raid0 personality registered for level 0
[   19.882064] md: raid1 personality registered for level 1
[   19.882986] md: raid10 personality registered for level 10
[   19.883917] md: raid6 personality registered for level 6
[   19.884859] md: raid5 personality registered for level 5
[   19.886070] md: raid4 personality registered for level 4
[   19.887030] md: multipath personality registered for level -4
[   19.888323] md: faulty personality registered for level -5
[   19.889780] device-mapper: uevent: version 1.0.3
[   19.891212] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised: dm-devel@redhat.com
[   19.897891] device-mapper: multipath: version 1.5.0 loaded
[   19.899452] device-mapper: multipath round-robin: version 1.0.0 loaded
[   19.901266] device-mapper: multipath queue-length: version 0.1.0 loaded
[   19.902993] device-mapper: multipath service-time: version 0.2.0 loaded
[   19.905732] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   19.906781] Bluetooth: Virtual HCI driver ver 1.3
[   19.907784] Bluetooth: HCI UART driver ver 2.2
[   19.908623] Bluetooth: HCI H4 protocol initialized
[   19.909668] Bluetooth: HCI BCSP protocol initialized
[   19.910513] Bluetooth: HCILL protocol initialized
[   19.911466] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   19.912966] CAPI 2.0 started up with major 68 (middleware)
[   19.913916] Modular ISDN core version 1.1.29
[   19.914902] NET: Registered protocol family 34
[   19.915684] DSP module 2.0
[   19.916294] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffies.
[   19.918835] mISDN: Layer-1-over-IP driver Rev. 2.00
[   19.919899] 0 virtual devices registered
[   19.921039] b1pci: revision 1.1.2.2
[   19.927854] b1: revision 1.1.2.2
[   19.928568] b1dma: revision 1.1.2.3
[   19.929373] b1pci: revision 1.1.2.2
[   19.930281] t1pci: revision 1.1.2.2
[   19.931086] c4: revision 1.1.2.2
[   19.931766] mISDN: HFC-multi driver 2.03
[   19.932612] AVM Fritz PCI driver Rev. 2.3
[   19.933614] Sedlbauer Speedfax+ Driver Rev. 2.0
[   19.934892] Infineon ISDN Driver Rev. 1.0
[   19.936203] Winbond W6692 PCI driver Rev. 2.0
[   19.937242] mISDNipac module version 2.0
[   19.938050] mISDN: ISAR driver Rev. 2.1
[   19.938737] gigaset: Driver for Gigaset 307x
[   19.939496] gigaset: Kernel CAPI interface
[   19.940439] EDAC MC: Ver: 3.0.0
[   19.946367] AMD64 EDAC driver v3.4.0
[   19.947208] cpuidle: using governor ladder
[   19.947927] cpuidle: using governor menu
[   19.948792] sdhci: Secure Digital Host Controller Interface driver
[   19.950159] sdhci: Copyright(c) Pierre Ossman
[   19.951470] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   19.952895] wbsd: Copyright(c) Pierre Ossman
[   19.953978] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Technologies, Inc.
[   19.955583] sdhci-pltfm: SDHCI platform and OF driver helper
[   19.957365] leds_ss4200: no LED devices found
[   19.959863] user_mad: couldn't register device number
[   19.960802] user_verbs: couldn't register device number
[   19.961852] ucm: couldn't register device number
[   19.963921] ib_qib: Unable to register ipathfs
[   19.968679] iscsi: registered transport (iser)
[   19.969739] EFI Variables Facility v0.08 2004-May-17
[   19.970921] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   19.972315] No iBFT detected.
[   19.973273] Linux telephony interface: v1.00
[   19.974071] ixj driver initialized.
[   19.975482] msi_laptop: driver 0.5 successfully loaded
[   19.976645] compal_laptop: Motherboard not recognized (You could try the module's force-parameter)
[   19.978294] dell_wmi: No known WMI GUID found
[   19.979055] acer_wmi: Acer Laptop ACPI-WMI Extras
[   19.979861] acer_wmi: No or unsupported WMI interface, unable to load
[   19.980960] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   19.981881] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Bochs, please report, aborting!
[   19.983544] hdaps: supported laptop not found!
[   19.984386] hdaps: driver init failed (ret=-19)!
[   19.985771] fujitsu_laptop: driver 0.6.0 successfully loaded
[   19.987345] msi_wmi: This machine doesn't have MSI-hotkeys through WMI
[   19.988861] topstar_laptop: ACPI extras driver loaded
[   19.990706] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMAC hardware
[   20.000600] no UART detected at 0x1
[   20.001841] MTVAP port 0x378 is busy
[   20.002968] snd_mtpav: probe of snd_mtpav failed with error -16
[   20.004678] snd_mts64: probe of snd_mts64.0 failed with error -5
[   20.005962] snd_portman2x4: probe of snd_portman2x4.0 failed with error -5
[   20.007366] Error: Driver 'pcspkr' is already registered, aborting...
[   20.010482] ASIHPI driver 4.10.01
[   20.013400] snd_hda_intel 0000:00:04.0: irq 52 for MSI/MSI-X
[   20.019424] snd_hda_intel 0000:00:04.0: setting latency timer to 64
[   20.044297] oprofile: using NMI interrupt.
[   20.045375] pktgen: Packet Generator for packet performance testing. Version: 2.74
[   20.047386] drop_monitor: Initializing network drop monitor service
[   20.048736] NET: Registered protocol family 26
[   20.049831] GACT probability on
[   20.050801] Mirror/redirect action on
[   20.051830] Simple TC action Loaded
[   20.053071] netem: version 1.3
[   20.053684] u32 classifier
[   20.054240]     Performance counters on
[   20.054925]     input device check on
[   20.055609]     Actions configured
[   20.056358] Netfilter messages via NETLINK v0.30.
[   20.057405] nf_conntrack version 0.5.0 (3480 buckets, 13920 max)
[   20.058961] ctnetlink v0.93: registering with nfnetlink.
[   20.060130] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
[   20.061249] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   20.062486] xt_time: kernel timezone is -0000
[   20.063273] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   20.064420] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[   20.066340] IPVS: Creating netns size=3080 id=0
[   20.067686] IPVS: ipvs loaded.
[   20.068565] IPVS: [rr] scheduler registered.
[   20.069412] IPVS: [wrr] scheduler registered.
[   20.070177] IPVS: [lc] scheduler registered.
[   20.070908] IPVS: [wlc] scheduler registered.
[   20.071712] IPVS: [lblc] scheduler registered.
[   20.072547] IPVS: [lblcr] scheduler registered.
[   20.073441] IPVS: [dh] scheduler registered.
[   20.074204] IPVS: [sh] scheduler registered.
[   20.074960] IPVS: [sed] scheduler registered.
[   20.075729] IPVS: [nq] scheduler registered.
[   20.076584] IPv4 over IPv4 tunneling driver
[   20.078121] ip_tables: (C) 2000-2006 Netfilter Core Team
[   20.079251] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   20.080407] arp_tables: (C) 2002 David S. Miller
[   20.081407] TCP: bic registered
[   20.082331] TCP: cubic registered
[   20.083340] TCP: westwood registered
[   20.084356] TCP: highspeed registered
[   20.085038] TCP: hybla registered
[   20.085763] TCP: htcp registered
[   20.086377] TCP: vegas registered
[   20.086982] TCP: veno registered
[   20.087601] TCP: scalable registered
[   20.088318] TCP: lp registered
[   20.088899] TCP: yeah registered
[   20.089618] TCP: illinois registered
[   20.090277] Initializing XFRM netlink socket
[   20.091706] NET: Registered protocol family 10
[   20.095669] mip6: Mobile IPv6
[   20.096400] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   20.097703] sit: IPv6 over IPv4 tunneling driver
[   20.100636] NET: Registered protocol family 17
[   20.101508] NET: Registered protocol family 15
[   20.102533] Bridge firewalling registered
[   20.103302] Ebtables v2.0 registered
[   20.104339] NET: Registered protocol family 4
[   20.105325] NET: Registered protocol family 5
[   20.107802] NET: Registered protocol family 6
[   20.112311] NET: Registered protocol family 11
[   20.113338] NET: Registered protocol family 3
[   20.114572] can: controller area network core (rev 20120528 abi 9)
[   20.116550] NET: Registered protocol family 29
[   20.117416] can: raw protocol (rev 20120528)
[   20.118198] can: broadcast manager protocol (rev 20120528 t)
[   20.119942] IrCOMM protocol (Dag Brattli)
[   20.124580] RPC: Registered rdma transport module.
[   20.125843] NET: Registered protocol family 33
[   20.126630] Key type rxrpc registered
[   20.127304] Key type rxrpc_s registered
[   20.130214] RxRPC: Registered security type 2 'rxkad'
[   20.131647] lec:lane_module_init: lec.c: initialized
[   20.132960] mpoa:atm_mpoa_init: mpc.c: initialized
[   20.133924] l2tp_core: L2TP core driver, V2.0
[   20.134727] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   20.135555] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   20.136634] l2tp_netlink: L2TP netlink interface
[   20.137699] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   20.138740] l2tp_debugfs: L2TP debugfs support
[   20.139523] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   20.140706] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[   20.142655] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   20.143740] NET: Registered protocol family 12
[   20.144816] NET: Registered protocol family 35
[   20.145963] 8021q: 802.1Q VLAN Support v1.8
[   20.148394] DCCP: Activated CCID 2 (TCP-like)
[   20.149585] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   20.162751] DCCP watch registered (port=0)
[   20.164935] sctp: Hash tables configured (established 1638 bind 1638)
[   20.177230] sctp_probe: probe registered (port=0)
[   20.178699] NET: Registered protocol family 21
[   20.179842] Registered RDS/iwarp transport
[   20.180900] Registered RDS/infiniband transport
[   20.182068] Registered RDS/tcp transport
[   20.183086] lib80211: common routines for IEEE802.11 drivers
[   20.184737] lib80211_crypt: registered algorithm 'NULL'
[   20.186139] lib80211_crypt: registered algorithm 'WEP'
[   20.187458] lib80211_crypt: registered algorithm 'CCMP'
[   20.188893] lib80211_crypt: registered algorithm 'TKIP'
[   20.190292] tipc: Activated (version 2.0.0)
[   20.193050] NET: Registered protocol family 30
[   20.194300] tipc: Started in single node mode
[   20.195499] 9pnet: Installing 9P2000 support
[   20.197157] NET: Registered protocol family 36
[   20.198440] Key type dns_resolver registered
[   20.199666] Key type ceph registered
[   20.200817] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[   20.205257] 
[   20.205257] printing PIC contents
[   20.206732] ... PIC  IMR: ffff
[   20.207658] ... PIC  IRR: 9153
[   20.208682] ... PIC  ISR: 0000
[   20.209476] ... PIC ELCR: 0c00
[   20.210087] printing local APIC contents on CPU#0/0:
[   20.212658] ... APIC ID:      00000000 (0)
[   20.212658] ... APIC VERSION: 00050014
[   20.212658] ... APIC TASKPRI: 00000000 (00)
[   20.212658] ... APIC PROCPRI: 00000000
[   20.212658] ... APIC LDR: 01000000
[   20.212658] ... APIC DFR: ffffffff
[   20.212658] ... APIC SPIV: 000001ff
[   20.212658] ... APIC ISR field:
[   20.212658] 0000000000000000000000000000000000000000000000000000000000000000
[   20.212658] ... APIC TMR field:
[   20.212658] 0000000000000000000000000000000000000000000000000000000000000000
[   20.212658] ... APIC IRR field:
[   20.212658] 0000000000000000000000000000000000000000000000000000000000008000
[   20.212658] ... APIC ESR: 00000000
[   20.212658] ... APIC ICR: 000008fb
[   20.212658] ... APIC ICR2: 02000000
[   20.212658] ... APIC LVTT: 000000ef
[   20.212658] ... APIC LVTPC: 00010000
[   20.212658] ... APIC LVT0: 00010700
[   20.212658] ... APIC LVT1: 00000400
[   20.212658] ... APIC LVTERR: 000000fe
[   20.212658] ... APIC TMICT: 00032ecd
[   20.212658] ... APIC TMCCT: 00000000
[   20.212658] ... APIC TDCR: 00000003
[   20.212658] 
[   20.236210] number of MP IRQ sources: 15.
[   20.236916] number of IO-APIC #2 registers: 24.
[   20.237779] testing the IO APIC.......................
[   20.238670] IO APIC #2......
[   20.239253] .... register #00: 00000000
[   20.239925] .......    : physical APIC id: 00
[   20.240762] .......    : Delivery Type: 0
[   20.241562] .......    : LTS          : 0
[   20.242300] .... register #01: 00170011
[   20.242980] .......     : max redirection entries: 17
[   20.243845] .......     : PRQ implemented: 0
[   20.244726] .......     : IO APIC version: 11
[   20.245580] .... register #02: 00000000
[   20.246295] .......     : arbitration: 00
[   20.247028] .... IRQ redirection table:
[   20.247700]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[   20.248784]  00 00  1    0    0   0   0    0    0    00
[   20.249818]  01 03  0    0    0   0   0    1    1    31
[   20.250791]  02 03  0    0    0   0   0    1    1    30
[   20.251761]  03 03  0    0    0   0   0    1    1    33
[   20.252819]  04 03  1    0    0   0   0    1    1    34
[   20.253810]  05 03  1    1    0   0   0    1    1    35
[   20.254759]  06 03  0    0    0   0   0    1    1    36
[   20.255720]  07 03  0    0    0   0   0    1    1    37
[   20.256761]  08 03  0    0    0   0   0    1    1    38
[   20.257759]  09 03  0    1    0   0   0    1    1    39
[   20.258730]  0a 03  1    1    0   0   0    1    1    3A
[   20.259717]  0b 03  1    1    0   0   0    1    1    3B
[   20.260801]  0c 03  0    0    0   0   0    1    1    3C
[   20.261787]  0d 03  0    0    0   0   0    1    1    3D
[   20.262764]  0e 03  0    0    0   0   0    1    1    3E
[   20.263740]  0f 03  0    0    0   0   0    1    1    3F
[   20.264779]  10 00  1    0    0   0   0    0    0    00
[   20.265826]  11 00  1    0    0   0   0    0    0    00
[   20.266785]  12 00  1    0    0   0   0    0    0    00
[   20.267749]  13 00  1    0    0   0   0    0    0    00
[   20.268809]  14 00  1    0    0   0   0    0    0    00
[   20.269909]  15 00  1    0    0   0   0    0    0    00
[   20.270886]  16 00  1    0    0   0   0    0    0    00
[   20.271850]  17 00  1    0    0   0   0    0    0    00
[   20.272909] IRQ to pin mappings:
[   20.273603] IRQ0 -> 0:2
[   20.274297] IRQ1 -> 0:1
[   20.274970] IRQ3 -> 0:3
[   20.275653] IRQ4 -> 0:4
[   20.276426] IRQ5 -> 0:5
[   20.277174] IRQ6 -> 0:6
[   20.277853] IRQ7 -> 0:7
[   20.278552] IRQ8 -> 0:8
[   20.279249] IRQ9 -> 0:9
[   20.279909] IRQ10 -> 0:10
[   20.280719] IRQ11 -> 0:11
[   20.281454] IRQ12 -> 0:12
[   20.282168] IRQ13 -> 0:13
[   20.282853] IRQ14 -> 0:14
[   20.283560] IRQ15 -> 0:15
[   20.284355] .................................... done.
[   20.286336] PM: Hibernation image not present or could not be loaded.
[   20.287518] registered taskstats version 1
[   20.288409] Running tests on trace events:
[   20.289155] Testing event 9p_client_req: OK
[   20.304892] Testing event 9p_client_res: OK
[   20.324793] Testing event 9p_protocol_dump: OK
[   20.341124] Testing event drv_return_void: OK
[   20.357158] Testing event drv_return_int: OK
[   20.372989] Testing event drv_return_bool: OK
[   20.389046] Testing event drv_return_u64: OK
[   20.404789] Testing event drv_start: OK
[   20.420779] Testing event drv_get_et_strings: OK
[   20.436776] Testing event drv_get_et_sset_count: OK
[   20.452782] Testing event drv_get_et_stats: OK
[   20.470701] Testing event drv_suspend: OK
[   20.489170] Testing event drv_resume: OK
[   20.504834] Testing event drv_set_wakeup: OK
[   20.520765] Testing event drv_stop: OK
[   20.536731] Testing event drv_add_interface: OK
[   20.553147] Testing event drv_change_interface: OK
[   20.568718] Testing event drv_remove_interface: OK
[   20.584891] Testing event drv_config: OK
[   20.600905] Testing event drv_bss_info_changed: OK
[   20.616720] Testing event drv_prepare_multicast: OK
[   20.632896] Testing event drv_configure_filter: OK
[   20.649152] Testing event drv_set_tim: OK
[   20.665306] Testing event drv_set_key: OK
[   20.681079] Testing event drv_update_tkip_key: OK
[   20.697108] Testing event drv_hw_scan: OK
[   20.713132] Testing event drv_cancel_hw_scan: OK
[   20.729114] Testing event drv_sched_scan_start: OK
[   20.745104] Testing event drv_sched_scan_stop: OK
[   20.761216] Testing event drv_sw_scan_start: OK
[   20.777191] Testing event drv_sw_scan_complete: OK
[   20.792807] Testing event drv_get_stats: OK
[   20.809167] Testing event drv_get_tkip_seq: OK
[   20.825174] Testing event drv_set_frag_threshold: OK
[   20.840824] Testing event drv_set_rts_threshold: OK
[   20.860987] Testing event drv_set_coverage_class: OK
[   20.877179] Testing event drv_sta_notify: OK
[   20.893185] Testing event drv_sta_state: OK
[   20.908823] Testing event drv_sta_rc_update: OK
[   20.925561] Testing event drv_sta_add: OK
[   20.941452] Testing event drv_sta_remove: OK
[   20.961123] Testing event drv_conf_tx: OK
[   20.977433] Testing event drv_get_tsf: OK
[   20.992841] Testing event drv_set_tsf: OK
[   21.009692] Testing event drv_reset_tsf: OK
[   21.025080] Testing event drv_tx_last_beacon: OK
[   21.041132] Testing event drv_ampdu_action: OK
[   21.057233] Testing event drv_get_survey: OK
[   21.073128] Testing event drv_flush: OK
[   21.089118] Testing event drv_channel_switch: OK
[   21.105205] Testing event drv_set_antenna: OK
[   21.121513] Testing event drv_get_antenna: OK
[   21.137814] Testing event drv_remain_on_channel: OK
[   21.153109] Testing event drv_cancel_remain_on_channel: OK
[   21.169172] Testing event drv_offchannel_tx: OK
[   21.185106] Testing event drv_set_ringparam: OK
[   21.201159] Testing event drv_get_ringparam: OK
[   21.217134] Testing event drv_tx_frames_pending: OK
[   21.233101] Testing event drv_offchannel_tx_cancel_wait: OK
[   21.249108] Testing event drv_set_bitrate_mask: OK
[   21.264860] Testing event drv_set_rekey_data: OK
[   21.281124] Testing event drv_rssi_callback: OK
[   21.296895] Testing event drv_release_buffered_frames: OK
[   21.312888] Testing event drv_allow_buffered_frames: OK
[   21.328928] Testing event drv_get_rssi: OK
[   21.344803] Testing event drv_mgd_prepare_tx: OK
[   21.360879] Testing event api_start_tx_ba_session: OK
[   21.377196] Testing event api_start_tx_ba_cb: OK
[   21.393106] Testing event api_stop_tx_ba_session: OK
[   21.409165] Testing event api_stop_tx_ba_cb: OK
[   21.425160] Testing event api_restart_hw: OK
[   21.441435] Testing event api_beacon_loss: OK
[   21.457202] Testing event api_connection_loss: OK
[   21.473281] Testing event api_cqm_rssi_notify: OK
[   21.489459] Testing event api_scan_completed: OK
[   21.504832] Testing event api_sched_scan_results: OK
[   21.521183] Testing event api_sched_scan_stopped: OK
[   21.537167] Testing event api_sta_block_awake: OK
[   21.553164] Testing event api_chswitch_done: OK
[   21.569112] Testing event api_ready_on_channel: OK
[   21.585186] Testing event api_remain_on_channel_expired: OK
[   21.600825] Testing event api_gtk_rekey_notify: OK
[   21.617132] Testing event api_enable_rssi_reports: OK
[   21.633153] Testing event api_eosp: OK
[   21.649032] Testing event wake_queue: OK
[   21.665165] Testing event stop_queue: OK
[   21.681028] Testing event rpc_call_status: OK
[   21.697112] Testing event rpc_bind_status: OK
[   21.713107] Testing event rpc_connect_status: OK
[   21.729149] Testing event rpc_task_begin: OK
[   21.744890] Testing event rpc_task_run_action: OK
[   21.761152] Testing event rpc_task_complete: OK
[   21.777206] Testing event rpc_task_sleep: OK
[   21.793258] Testing event rpc_task_wakeup: OK
[   21.809165] Testing event kfree_skb: OK
[   21.833893] Testing event consume_skb: OK
[   21.849150] Testing event skb_copy_datagram_iovec: OK
[   21.865205] Testing event net_dev_xmit: OK
[   21.881113] Testing event net_dev_queue: OK
[   21.896808] Testing event netif_receive_skb: OK
[   21.913084] Testing event netif_rx: OK
[   21.929230] Testing event napi_poll: OK
[   21.945124] Testing event sock_rcvqueue_full: OK
[   21.961134] Testing event sock_exceed_buf_limit: OK
[   21.978212] Testing event udp_fail_queue_rcv_skb: OK
[   21.993091] Testing event hda_send_cmd: OK
[   22.009076] Testing event hda_get_response: OK
[   22.025055] Testing event hda_bus_reset: OK
[   22.041061] Testing event hda_power_down: OK
[   22.056987] Testing event hda_power_up: OK
[   22.073156] Testing event hda_unsol_event: OK
[   22.089088] Testing event mc_event: OK
[   22.105130] Testing event scsi_dispatch_cmd_start: OK
[   22.121076] Testing event scsi_dispatch_cmd_error: OK
[   22.137149] Testing event scsi_dispatch_cmd_done: OK
[   22.153097] Testing event scsi_dispatch_cmd_timeout: OK
[   22.169072] Testing event scsi_eh_wakeup: OK
[   22.185155] Testing event regmap_reg_write: OK
[   22.201119] Testing event regmap_reg_read: OK
[   22.217196] Testing event regmap_reg_read_cache: OK
[   22.233093] Testing event regmap_hw_read_start: OK
[   22.249107] Testing event regmap_hw_read_done: OK
[   22.264863] Testing event regmap_hw_write_start: OK
[   22.281135] Testing event regmap_hw_write_done: OK
[   22.297223] Testing event regcache_sync: OK
[   22.313165] Testing event regmap_cache_only: OK
[   22.329165] Testing event regmap_cache_bypass: OK
[   22.345102] Testing event i915_gem_object_create: OK
[   22.361115] Testing event i915_gem_object_bind: OK
[   22.377189] Testing event i915_gem_object_unbind: OK
[   22.393191] Testing event i915_gem_object_change_domain: OK
[   22.409177] Testing event i915_gem_object_pwrite: OK
[   22.424916] Testing event i915_gem_object_pread: OK
[   22.440841] Testing event i915_gem_object_fault: OK
[   22.457461] Testing event i915_gem_object_clflush: OK
[   22.473197] Testing event i915_gem_object_destroy: OK
[   22.489106] Testing event i915_gem_evict: OK
[   22.505148] Testing event i915_gem_evict_everything: OK
[   22.521139] Testing event i915_gem_ring_dispatch: OK
[   22.536995] Testing event i915_gem_ring_flush: OK
[   22.553036] Testing event i915_gem_request_add: OK
[   22.569116] Testing event i915_gem_request_complete: OK
[   22.585123] Testing event i915_gem_request_retire: OK
[   22.602359] Testing event i915_gem_request_wait_begin: OK
[   22.621096] Testing event i915_gem_request_wait_end: OK
[   22.637122] Testing event i915_ring_wait_begin: OK
[   22.653035] Testing event i915_ring_wait_end: OK
[   22.669078] Testing event i915_flip_request: OK
[   22.685139] Testing event i915_flip_complete: OK
[   22.701074] Testing event i915_reg_rw: OK
[   22.717192] Testing event radeon_bo_create: OK
[   22.733141] Testing event radeon_fence_emit: OK
[   22.748972] Testing event radeon_fence_retire: OK
[   22.764964] Testing event radeon_fence_wait_begin: OK
[   22.780959] Testing event radeon_fence_wait_end: OK
[   22.797201] Testing event drm_vblank_event: OK
[   22.813102] Testing event drm_vblank_event_queued: OK
[   22.829522] Testing event drm_vblank_event_delivered: OK
[   22.845079] Testing event mix_pool_bytes: OK
[   22.861201] Testing event mix_pool_bytes_nolock: OK
[   22.877103] Testing event credit_entropy_bits: OK
[   22.893231] Testing event get_random_bytes: OK
[   22.909115] Testing event extract_entropy: OK
[   22.925080] Testing event extract_entropy_user: OK
[   22.941095] Testing event regulator_enable: OK
[   22.956916] Testing event regulator_enable_delay: OK
[   22.972796] Testing event regulator_enable_complete: OK
[   22.988756] Testing event regulator_disable: OK
[   23.004769] Testing event regulator_disable_complete: OK
[   23.020900] Testing event regulator_set_voltage: OK
[   23.036827] Testing event regulator_set_voltage_complete: OK
[   23.052653] Testing event gpio_direction: OK
[   23.069114] Testing event gpio_value: OK
[   23.085144] Testing event block_rq_abort: OK
[   23.101117] Testing event block_rq_requeue: OK
[   23.117127] Testing event block_rq_complete: OK
[   23.133068] Testing event block_rq_insert: OK
[   23.149109] Testing event block_rq_issue: OK
[   23.165129] Testing event block_bio_bounce: OK
[   23.181126] Testing event block_bio_complete: OK
[   23.197158] Testing event block_bio_backmerge: OK
[   23.213118] Testing event block_bio_frontmerge: OK
[   23.228835] Testing event block_bio_queue: OK
[   23.244820] Testing event block_getrq: OK
[   23.261189] Testing event block_sleeprq: OK
[   23.277428] Testing event block_plug: OK
[   23.293133] Testing event block_unplug: OK
[   23.309119] Testing event block_split: OK
[   23.324813] Testing event block_bio_remap: OK
[   23.341132] Testing event block_rq_remap: OK
[   23.356917] Testing event gfs2_glock_state_change: OK
[   23.372941] Testing event gfs2_glock_put: OK
[   23.389183] Testing event gfs2_demote_rq: OK
[   23.405123] Testing event gfs2_promote: OK
[   23.421195] Testing event gfs2_glock_queue: OK
[   23.437253] Testing event gfs2_glock_lock_time: OK
[   23.453139] Testing event gfs2_pin: OK
[   23.469072] Testing event gfs2_log_flush: OK
[   23.485205] Testing event gfs2_log_blocks: OK
[   23.501216] Testing event gfs2_ail_flush: OK
[   23.517108] Testing event gfs2_bmap: OK
[   23.533094] Testing event gfs2_block_alloc: OK
[   23.549125] Testing event gfs2_rs: OK
[   23.565160] Testing event btrfs_transaction_commit: OK
[   23.581089] Testing event btrfs_inode_new: OK
[   23.597209] Testing event btrfs_inode_request: OK
[   23.613142] Testing event btrfs_inode_evict: OK
[   23.628881] Testing event btrfs_get_extent: OK
[   23.644766] Testing event btrfs_ordered_extent_add: OK
[   23.660844] Testing event btrfs_ordered_extent_remove: OK
[   23.677197] Testing event btrfs_ordered_extent_start: OK
[   23.693530] Testing event btrfs_ordered_extent_put: OK
[   23.709157] Testing event __extent_writepage: OK
[   23.725096] Testing event btrfs_writepage_end_io_hook: OK
[   23.741122] Testing event btrfs_sync_file: OK
[   23.757477] Testing event btrfs_sync_fs: OK
[   23.773247] Testing event btrfs_delayed_tree_ref: OK
[   23.789497] Testing event btrfs_delayed_data_ref: OK
[   23.805586] Testing event btrfs_delayed_ref_head: OK
[   23.820858] Testing event btrfs_chunk_alloc: OK
[   23.837144] Testing event btrfs_chunk_free: OK
[   23.852697] Testing event btrfs_cow_block: OK
[   23.869057] Testing event btrfs_space_reservation: OK
[   23.885037] Testing event btrfs_reserved_extent_alloc: OK
[   23.901100] Testing event btrfs_reserved_extent_free: OK
[   23.917126] Testing event find_free_extent: OK
[   23.933116] Testing event btrfs_reserve_extent: OK
[   23.949133] Testing event btrfs_reserve_extent_cluster: OK
[   23.964906] Testing event btrfs_find_cluster: OK
[   23.981110] Testing event btrfs_failed_cluster_setup: OK
[   23.997116] Testing event btrfs_setup_cluster: OK
[   24.013052] Testing event alloc_extent_state: OK
[   24.029259] Testing event free_extent_state: OK
[   24.044924] Testing event ocfs2_adjust_rightmost_branch: OK
[   24.061541] Testing event ocfs2_rotate_tree_right: OK
[   24.077531] Testing event ocfs2_append_rec_to_path: OK
[   24.097234] Testing event ocfs2_insert_extent_start: OK
[   24.117810] Testing event ocfs2_add_clusters_in_btree: OK
[   24.133333] Testing event ocfs2_num_free_extents: OK
[   24.150089] Testing event ocfs2_complete_edge_insert: OK
[   24.165176] Testing event ocfs2_grow_tree: OK
[   24.180795] Testing event ocfs2_rotate_subtree: OK
[   24.196955] Testing event ocfs2_insert_extent: OK
[   24.216943] Testing event ocfs2_split_extent: OK
[   24.233056] Testing event ocfs2_remove_extent: OK
[   24.249366] Testing event ocfs2_commit_truncate: OK
[   24.264928] Testing event ocfs2_validate_extent_block: OK
[   24.281155] Testing event ocfs2_rotate_leaf: OK
[   24.296788] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   24.313062] Testing event ocfs2_mark_extent_written: OK
[   24.328836] Testing event ocfs2_truncate_log_append: OK
[   24.344977] Testing event ocfs2_replay_truncate_records: OK
[   24.360757] Testing event ocfs2_flush_truncate_log: OK
[   24.376985] Testing event ocfs2_begin_truncate_log_recovery: OK
[   24.392903] Testing event ocfs2_truncate_log_recovery_num: OK
[   24.408934] Testing event ocfs2_complete_truncate_log_recovery: OK
[   24.424866] Testing event ocfs2_free_cached_blocks: OK
[   24.440996] Testing event ocfs2_cache_cluster_dealloc: OK
[   24.456942] Testing event ocfs2_run_deallocs: OK
[   24.472969] Testing event ocfs2_cache_block_dealloc: OK
[   24.488938] Testing event ocfs2_trim_extent: OK
[   24.505031] Testing event ocfs2_trim_group: OK
[   24.520937] Testing event ocfs2_trim_fs: OK
[   24.537049] Testing event ocfs2_la_set_sizes: OK
[   24.552934] Testing event ocfs2_alloc_should_use_local: OK
[   24.569076] Testing event ocfs2_load_local_alloc: OK
[   24.585080] Testing event ocfs2_begin_local_alloc_recovery: OK
[   24.601178] Testing event ocfs2_reserve_local_alloc_bits: OK
[   24.617116] Testing event ocfs2_local_alloc_count_bits: OK
[   24.633769] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   24.649407] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   24.665194] Testing event ocfs2_sync_local_to_main: OK
[   24.681145] Testing event ocfs2_sync_local_to_main_free: OK
[   24.697157] Testing event ocfs2_local_alloc_new_window: OK
[   24.713106] Testing event ocfs2_local_alloc_new_window_result: OK
[   24.743821] Testing event ocfs2_update_last_group_and_inode: OK
[   24.761167] Testing event ocfs2_group_extend: OK
[   24.776787] Testing event ocfs2_group_add: OK
[   24.792816] Testing event ocfs2_validate_group_descriptor: OK
[   24.809195] Testing event ocfs2_block_group_alloc_contig: OK
[   24.825077] Testing event ocfs2_block_group_alloc_discontig: OK
[   24.841120] Testing event ocfs2_block_group_alloc: OK
[   24.857084] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   24.873713] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   24.892898] Testing event ocfs2_reserve_new_inode_new_group: OK
[   24.909520] Testing event ocfs2_block_group_set_bits: OK
[   24.925055] Testing event ocfs2_relink_block_group: OK
[   24.940886] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   24.956886] Testing event ocfs2_cluster_group_search_max_block: OK
[   24.973126] Testing event ocfs2_block_group_search_max_block: OK
[   24.989119] Testing event ocfs2_search_chain_begin: OK
[   25.005107] Testing event ocfs2_search_chain_succ: OK
[   25.021130] Testing event ocfs2_search_chain_end: OK
[   25.036877] Testing event ocfs2_claim_suballoc_bits: OK
[   25.052725] Testing event ocfs2_claim_new_inode_at_loc: OK
[   25.068855] Testing event ocfs2_block_group_clear_bits: OK
[   25.084875] Testing event ocfs2_free_suballoc_bits: OK
[   25.100978] Testing event ocfs2_free_clusters: OK
[   25.116794] Testing event ocfs2_get_suballoc_slot_bit: OK
[   25.132903] Testing event ocfs2_test_suballoc_bit: OK
[   25.148746] Testing event ocfs2_test_inode_bit: OK
[   25.164945] Testing event ocfs2_validate_refcount_block: OK
[   25.181148] Testing event ocfs2_purge_refcount_trees: OK
[   25.196947] Testing event ocfs2_create_refcount_tree: OK
[   25.212873] Testing event ocfs2_create_refcount_tree_blkno: OK
[   25.229157] Testing event ocfs2_change_refcount_rec: OK
[   25.245146] Testing event ocfs2_expand_inline_ref_root: OK
[   25.261149] Testing event ocfs2_divide_leaf_refcount_block: OK
[   25.276882] Testing event ocfs2_new_leaf_refcount_block: OK
[   25.292826] Testing event ocfs2_insert_refcount_rec: OK
[   25.309159] Testing event ocfs2_split_refcount_rec: OK
[   25.324841] Testing event ocfs2_split_refcount_rec_insert: OK
[   25.340851] Testing event ocfs2_increase_refcount_begin: OK
[   25.356848] Testing event ocfs2_increase_refcount_change: OK
[   25.372847] Testing event ocfs2_increase_refcount_insert: OK
[   25.388841] Testing event ocfs2_increase_refcount_split: OK
[   25.404858] Testing event ocfs2_remove_refcount_extent: OK
[   25.421109] Testing event ocfs2_restore_refcount_block: OK
[   25.437108] Testing event ocfs2_decrease_refcount_rec: OK
[   25.452825] Testing event ocfs2_decrease_refcount: OK
[   25.469325] Testing event ocfs2_mark_extent_refcounted: OK
[   25.485124] Testing event ocfs2_calc_refcount_meta_credits: OK
[   25.501088] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   25.516867] Testing event ocfs2_add_refcount_flag: OK
[   25.533118] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   25.549116] Testing event ocfs2_lock_refcount_allocators: OK
[   25.565094] Testing event ocfs2_duplicate_clusters_by_page: OK
[   25.581124] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   25.597098] Testing event ocfs2_clear_ext_refcount: OK
[   25.613111] Testing event ocfs2_replace_clusters: OK
[   25.629106] Testing event ocfs2_make_clusters_writable: OK
[   25.645064] Testing event ocfs2_refcount_cow_hunk: OK
[   25.661115] Testing event ocfs2_symlink_get_block: OK
[   25.677110] Testing event ocfs2_get_block: OK
[   25.692973] Testing event ocfs2_get_block_end: OK
[   25.709077] Testing event ocfs2_readpage: OK
[   25.725083] Testing event ocfs2_writepage: OK
[   25.741132] Testing event ocfs2_bmap: OK
[   25.756903] Testing event ocfs2_try_to_write_inline_data: OK
[   25.772814] Testing event ocfs2_write_begin_nolock: OK
[   25.789136] Testing event ocfs2_write_end_inline: OK
[   25.805091] Testing event ocfs2_fault: OK
[   25.821117] Testing event ocfs2_file_open: OK
[   25.836853] Testing event ocfs2_file_release: OK
[   25.852802] Testing event ocfs2_sync_file: OK
[   25.869062] Testing event ocfs2_file_aio_write: OK
[   25.884834] Testing event ocfs2_file_splice_write: OK
[   25.900821] Testing event ocfs2_file_splice_read: OK
[   25.917166] Testing event ocfs2_file_aio_read: OK
[   25.932889] Testing event ocfs2_truncate_file: OK
[   25.949025] Testing event ocfs2_truncate_file_error: OK
[   25.964842] Testing event ocfs2_extend_allocation: OK
[   25.981100] Testing event ocfs2_extend_allocation_end: OK
[   25.996853] Testing event ocfs2_write_zero_page: OK
[   26.012842] Testing event ocfs2_zero_extend_range: OK
[   26.029122] Testing event ocfs2_zero_extend: OK
[   26.045048] Testing event ocfs2_setattr: OK
[   26.061145] Testing event ocfs2_write_remove_suid: OK
[   26.077119] Testing event ocfs2_zero_partial_clusters: OK
[   26.093093] Testing event ocfs2_zero_partial_clusters_range1: OK
[   26.108810] Testing event ocfs2_zero_partial_clusters_range2: OK
[   26.125087] Testing event ocfs2_remove_inode_range: OK
[   26.140785] Testing event ocfs2_prepare_inode_for_write: OK
[   26.156881] Testing event generic_file_aio_read_ret: OK
[   26.172874] Testing event ocfs2_iget_begin: OK
[   26.188853] Testing event ocfs2_iget5_locked: OK
[   26.204834] Testing event ocfs2_iget_end: OK
[   26.221193] Testing event ocfs2_find_actor: OK
[   26.236938] Testing event ocfs2_populate_inode: OK
[   26.252718] Testing event ocfs2_read_locked_inode: OK
[   26.268768] Testing event ocfs2_check_orphan_recovery_state: OK
[   26.285557] Testing event ocfs2_validate_inode_block: OK
[   26.300915] Testing event ocfs2_inode_is_valid_to_delete: OK
[   26.316816] Testing event ocfs2_query_inode_wipe_begin: OK
[   26.333107] Testing event ocfs2_query_inode_wipe_succ: OK
[   26.349099] Testing event ocfs2_query_inode_wipe_end: OK
[   26.365118] Testing event ocfs2_cleanup_delete_inode: OK
[   26.380848] Testing event ocfs2_delete_inode: OK
[   26.396921] Testing event ocfs2_clear_inode: OK
[   26.413107] Testing event ocfs2_drop_inode: OK
[   26.429104] Testing event ocfs2_inode_revalidate: OK
[   26.445074] Testing event ocfs2_mark_inode_dirty: OK
[   26.461086] Testing event ocfs2_read_virt_blocks: OK
[   26.477105] Testing event ocfs2_refresh_slot_info: OK
[   26.493130] Testing event ocfs2_map_slot_buffers: OK
[   26.509109] Testing event ocfs2_map_slot_buffers_block: OK
[   26.524859] Testing event ocfs2_find_slot: OK
[   26.541093] Testing event ocfs2_do_node_down: OK
[   26.557099] Testing event ocfs2_remount: OK
[   26.573100] Testing event ocfs2_fill_super: OK
[   26.589127] Testing event ocfs2_parse_options: OK
[   26.605128] Testing event ocfs2_put_super: OK
[   26.620905] Testing event ocfs2_statfs: OK
[   26.637110] Testing event ocfs2_dismount_volume: OK
[   26.652733] Testing event ocfs2_initialize_super: OK
[   26.668864] Testing event ocfs2_validate_xattr_block: OK
[   26.684867] Testing event ocfs2_xattr_extend_allocation: OK
[   26.700931] Testing event ocfs2_init_xattr_set_ctxt: OK
[   26.716859] Testing event ocfs2_xattr_bucket_find: OK
[   26.732847] Testing event ocfs2_xattr_index_block_find: OK
[   26.748816] Testing event ocfs2_xattr_index_block_find_rec: OK
[   26.764838] Testing event ocfs2_iterate_xattr_buckets: OK
[   26.780849] Testing event ocfs2_iterate_xattr_bucket: OK
[   26.797447] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   26.812971] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   26.828784] Testing event ocfs2_xattr_create_index_block_begin: OK
[   26.844786] Testing event ocfs2_xattr_create_index_block: OK
[   26.860795] Testing event ocfs2_defrag_xattr_bucket: OK
[   26.877168] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   26.892749] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   26.908784] Testing event ocfs2_divide_xattr_bucket_move: OK
[   26.924864] Testing event ocfs2_cp_xattr_bucket: OK
[   26.940842] Testing event ocfs2_mv_xattr_buckets: OK
[   26.956915] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   26.972881] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   26.988737] Testing event ocfs2_add_new_xattr_cluster: OK
[   27.004789] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   27.020740] Testing event ocfs2_extend_xattr_bucket: OK
[   27.036914] Testing event ocfs2_add_new_xattr_bucket: OK
[   27.052733] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   27.068885] Testing event ocfs2_rm_xattr_cluster: OK
[   27.084799] Testing event ocfs2_reflink_xattr_header: OK
[   27.100882] Testing event ocfs2_create_empty_xattr_block: OK
[   27.116765] Testing event ocfs2_xattr_set_entry_bucket: OK
[   27.132825] Testing event ocfs2_xattr_set_entry_index_block: OK
[   27.148727] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   27.164742] Testing event ocfs2_reflink_xattr_buckets: OK
[   27.180864] Testing event ocfs2_reflink_xattr_rec: OK
[   27.196842] Testing event ocfs2_resv_insert: OK
[   27.212874] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   27.228899] Testing event ocfs2_resmap_find_free_bits_end: OK
[   27.244764] Testing event ocfs2_resv_find_window_begin: OK
[   27.260935] Testing event ocfs2_resv_find_window_prev: OK
[   27.276850] Testing event ocfs2_resv_find_window_next: OK
[   27.292812] Testing event ocfs2_cannibalize_resv_begin: OK
[   27.308800] Testing event ocfs2_cannibalize_resv_end: OK
[   27.324819] Testing event ocfs2_resmap_resv_bits: OK
[   27.340788] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   27.356786] Testing event ocfs2_resmap_claimed_bits_end: OK
[   27.372787] Testing event ocfs2_recover_local_quota_file: OK
[   27.388881] Testing event ocfs2_finish_quota_recovery: OK
[   27.404813] Testing event olq_set_dquot: OK
[   27.420910] Testing event ocfs2_validate_quota_block: OK
[   27.437226] Testing event ocfs2_sync_dquot: OK
[   27.453083] Testing event ocfs2_sync_dquot_helper: OK
[   27.469157] Testing event ocfs2_write_dquot: OK
[   27.485154] Testing event ocfs2_release_dquot: OK
[   27.500966] Testing event ocfs2_acquire_dquot: OK
[   27.517175] Testing event ocfs2_mark_dquot_dirty: OK
[   27.533182] Testing event ocfs2_search_dirblock: OK
[   27.549177] Testing event ocfs2_validate_dir_block: OK
[   27.564893] Testing event ocfs2_find_entry_el: OK
[   27.580970] Testing event ocfs2_dx_dir_search: OK
[   27.597293] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   27.613047] Testing event ocfs2_delete_entry_dx: OK
[   27.637070] Testing event ocfs2_readdir: OK
[   27.653167] Testing event ocfs2_find_files_on_disk: OK
[   27.669107] Testing event ocfs2_check_dir_for_entry: OK
[   27.685123] Testing event ocfs2_dx_dir_attach_index: OK
[   27.701122] Testing event ocfs2_dx_dir_format_cluster: OK
[   27.717103] Testing event ocfs2_dx_dir_index_root_block: OK
[   27.732937] Testing event ocfs2_extend_dir: OK
[   27.749059] Testing event ocfs2_dx_dir_rebalance: OK
[   27.764846] Testing event ocfs2_dx_dir_rebalance_split: OK
[   27.780863] Testing event ocfs2_prepare_dir_for_insert: OK
[   27.797150] Testing event ocfs2_lookup: OK
[   27.813059] Testing event ocfs2_mkdir: OK
[   27.828740] Testing event ocfs2_create: OK
[   27.844907] Testing event ocfs2_unlink: OK
[   27.861172] Testing event ocfs2_symlink_create: OK
[   27.876892] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   27.892840] Testing event ocfs2_lookup_ret: OK
[   27.908796] Testing event ocfs2_mknod: OK
[   27.924782] Testing event ocfs2_link: OK
[   27.940848] Testing event ocfs2_unlink_noent: OK
[   27.956882] Testing event ocfs2_double_lock: OK
[   27.972819] Testing event ocfs2_double_lock_end: OK
[   27.988821] Testing event ocfs2_rename: OK
[   28.004778] Testing event ocfs2_rename_target_exists: OK
[   28.021229] Testing event ocfs2_rename_disagree: OK
[   28.037141] Testing event ocfs2_rename_over_existing: OK
[   28.052695] Testing event ocfs2_create_symlink_data: OK
[   28.069098] Testing event ocfs2_symlink_begin: OK
[   28.085106] Testing event ocfs2_blkno_stringify: OK
[   28.101110] Testing event ocfs2_orphan_add_begin: OK
[   28.117091] Testing event ocfs2_orphan_add_end: OK
[   28.132831] Testing event ocfs2_orphan_del: OK
[   28.149146] Testing event ocfs2_dentry_revalidate: OK
[   28.164865] Testing event ocfs2_dentry_revalidate_negative: OK
[   28.181886] Testing event ocfs2_dentry_revalidate_delete: OK
[   28.197277] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   28.212847] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   28.229106] Testing event ocfs2_dentry_revalidate_ret: OK
[   28.244752] Testing event ocfs2_find_local_alias: OK
[   28.260781] Testing event ocfs2_dentry_attach_lock: OK
[   28.276911] Testing event ocfs2_dentry_attach_lock_found: OK
[   28.293133] Testing event ocfs2_get_dentry_begin: OK
[   28.309098] Testing event ocfs2_get_dentry_test_bit: OK
[   28.325160] Testing event ocfs2_get_dentry_stale: OK
[   28.340736] Testing event ocfs2_get_dentry_generation: OK
[   28.356795] Testing event ocfs2_get_dentry_end: OK
[   28.372910] Testing event ocfs2_get_parent: OK
[   28.389127] Testing event ocfs2_get_parent_end: OK
[   28.405061] Testing event ocfs2_encode_fh_begin: OK
[   28.420956] Testing event ocfs2_encode_fh_self: OK
[   28.436829] Testing event ocfs2_encode_fh_parent: OK
[   28.452850] Testing event ocfs2_encode_fh_type: OK
[   28.468791] Testing event ocfs2_commit_cache_begin: OK
[   28.484789] Testing event ocfs2_commit_cache_end: OK
[   28.500783] Testing event ocfs2_extend_trans: OK
[   28.516819] Testing event ocfs2_extend_trans_restart: OK
[   28.532863] Testing event ocfs2_journal_access: OK
[   28.549047] Testing event ocfs2_journal_dirty: OK
[   28.564909] Testing event ocfs2_journal_init: OK
[   28.580973] Testing event ocfs2_journal_init_maxlen: OK
[   28.597160] Testing event ocfs2_journal_shutdown: OK
[   28.613095] Testing event ocfs2_journal_shutdown_wait: OK
[   28.629131] Testing event ocfs2_complete_recovery: OK
[   28.644870] Testing event ocfs2_complete_recovery_end: OK
[   28.660887] Testing event ocfs2_complete_recovery_slot: OK
[   28.677149] Testing event ocfs2_recovery_thread_node: OK
[   28.693089] Testing event ocfs2_recovery_thread_end: OK
[   28.709143] Testing event ocfs2_recovery_thread: OK
[   28.725144] Testing event ocfs2_replay_journal_recovered: OK
[   28.741194] Testing event ocfs2_replay_journal_lock_err: OK
[   28.757152] Testing event ocfs2_replay_journal_skip: OK
[   28.773084] Testing event ocfs2_recover_node: OK
[   28.789121] Testing event ocfs2_recover_node_skip: OK
[   28.805261] Testing event ocfs2_mark_dead_nodes: OK
[   28.821083] Testing event ocfs2_queue_orphan_scan_begin: OK
[   28.837207] Testing event ocfs2_queue_orphan_scan_end: OK
[   28.853069] Testing event ocfs2_orphan_filldir: OK
[   28.869155] Testing event ocfs2_recover_orphans: OK
[   28.885377] Testing event ocfs2_recover_orphans_iput: OK
[   28.901221] Testing event ocfs2_wait_on_mount: OK
[   28.917021] Testing event ocfs2_read_blocks_sync: OK
[   28.933111] Testing event ocfs2_read_blocks_sync_jbd: OK
[   28.949069] Testing event ocfs2_read_blocks_from_disk: OK
[   28.965142] Testing event ocfs2_read_blocks_bh: OK
[   28.981154] Testing event ocfs2_read_blocks_end: OK
[   28.997412] Testing event ocfs2_write_block: OK
[   29.012956] Testing event ocfs2_read_blocks_begin: OK
[   29.029112] Testing event ocfs2_purge_copied_metadata_tree: OK
[   29.045157] Testing event ocfs2_metadata_cache_purge: OK
[   29.061237] Testing event ocfs2_buffer_cached_begin: OK
[   29.077781] Testing event ocfs2_buffer_cached_end: OK
[   29.093275] Testing event ocfs2_append_cache_array: OK
[   29.109123] Testing event ocfs2_insert_cache_tree: OK
[   29.125146] Testing event ocfs2_expand_cache: OK
[   29.141268] Testing event ocfs2_set_buffer_uptodate: OK
[   29.157224] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   29.173124] Testing event ocfs2_remove_metadata_array: OK
[   29.189086] Testing event ocfs2_remove_metadata_tree: OK
[   29.204843] Testing event ocfs2_remove_block_from_cache: OK
[   29.221123] Testing event xfs_attr_list_sf: OK
[   29.237152] Testing event xfs_attr_list_sf_all: OK
[   29.252981] Testing event xfs_attr_list_leaf: OK
[   29.268866] Testing event xfs_attr_list_leaf_end: OK
[   29.284893] Testing event xfs_attr_list_full: OK
[   29.301146] Testing event xfs_attr_list_add: OK
[   29.317094] Testing event xfs_attr_list_wrong_blk: OK
[   29.333085] Testing event xfs_attr_list_notfound: OK
[   29.349096] Testing event xfs_perag_get: OK
[   29.365108] Testing event xfs_perag_get_tag: OK
[   29.381112] Testing event xfs_perag_put: OK
[   29.397483] Testing event xfs_perag_set_reclaim: OK
[   29.413839] Testing event xfs_perag_clear_reclaim: OK
[   29.428821] Testing event xfs_attr_list_node_descend: OK
[   29.449137] Testing event xfs_iext_insert: OK
[   29.464878] Testing event xfs_iext_remove: OK
[   29.481112] Testing event xfs_bmap_pre_update: OK
[   29.501224] Testing event xfs_bmap_post_update: OK
[   29.516984] Testing event xfs_extlist: OK
[   29.533137] Testing event xfs_buf_init: OK
[   29.549053] Testing event xfs_buf_free: OK
[   29.565179] Testing event xfs_buf_hold: OK
[   29.581278] Testing event xfs_buf_rele: OK
[   29.597383] Testing event xfs_buf_iodone: OK
[   29.613109] Testing event xfs_buf_iorequest: OK
[   29.628874] Testing event xfs_buf_bawrite: OK
[   29.645217] Testing event xfs_buf_lock: OK
[   29.661025] Testing event xfs_buf_lock_done: OK
[   29.677215] Testing event xfs_buf_trylock: OK
[   29.693166] Testing event xfs_buf_unlock: OK
[   29.709063] Testing event xfs_buf_iowait: OK
[   29.724880] Testing event xfs_buf_iowait_done: OK
[   29.740815] Testing event xfs_buf_delwri_queue: OK
[   29.757097] Testing event xfs_buf_delwri_queued: OK
[   29.773200] Testing event xfs_buf_delwri_split: OK
[   29.789100] Testing event xfs_buf_get_uncached: OK
[   29.805473] Testing event xfs_bdstrat_shut: OK
[   29.821269] Testing event xfs_buf_item_relse: OK
[   29.837173] Testing event xfs_buf_item_iodone: OK
[   29.853166] Testing event xfs_buf_item_iodone_async: OK
[   29.869162] Testing event xfs_buf_error_relse: OK
[   29.885178] Testing event xfs_trans_read_buf_io: OK
[   29.901085] Testing event xfs_trans_read_buf_shut: OK
[   29.917146] Testing event xfs_btree_corrupt: OK
[   29.933124] Testing event xfs_da_btree_corrupt: OK
[   29.949118] Testing event xfs_reset_dqcounts: OK
[   29.965162] Testing event xfs_inode_item_push: OK
[   29.981070] Testing event xfs_buf_find: OK
[   29.997709] Testing event xfs_buf_get: OK
[   30.013661] Testing event xfs_buf_read: OK
[   30.033229] Testing event xfs_buf_ioerror: OK
[   30.048956] Testing event xfs_buf_item_size: OK
[   30.065129] Testing event xfs_buf_item_size_stale: OK
[   30.081200] Testing event xfs_buf_item_format: OK
[   30.097211] Testing event xfs_buf_item_format_stale: OK
[   30.113162] Testing event xfs_buf_item_pin: OK
[   30.129184] Testing event xfs_buf_item_unpin: OK
[   30.145284] Testing event xfs_buf_item_unpin_stale: OK
[   30.161332] Testing event xfs_buf_item_unlock: OK
[   30.177108] Testing event xfs_buf_item_unlock_stale: OK
[   30.193048] Testing event xfs_buf_item_committed: OK
[   30.209223] Testing event xfs_buf_item_push: OK
[   30.225061] Testing event xfs_trans_get_buf: OK
[   30.241096] Testing event xfs_trans_get_buf_recur: OK
[   30.258385] Testing event xfs_trans_getsb: OK
[   30.277253] Testing event xfs_trans_getsb_recur: OK
[   30.293147] Testing event xfs_trans_read_buf: OK
[   30.308819] Testing event xfs_trans_read_buf_recur: OK
[   30.329513] Testing event xfs_trans_log_buf: OK
[   30.345066] Testing event xfs_trans_brelse: OK
[   30.361135] Testing event xfs_trans_bjoin: OK
[   30.377140] Testing event xfs_trans_bhold: OK
[   30.393163] Testing event xfs_trans_bhold_release: OK
[   30.409129] Testing event xfs_trans_binval: OK
[   30.424978] Testing event xfs_ilock: OK
[   30.441075] Testing event xfs_ilock_nowait: OK
[   30.457119] Testing event xfs_ilock_demote: OK
[   30.473208] Testing event xfs_iunlock: OK
[   30.489037] Testing event xfs_iget_skip: OK
[   30.505161] Testing event xfs_iget_reclaim: OK
[   30.521191] Testing event xfs_iget_reclaim_fail: OK
[   30.547045] Testing event xfs_iget_hit: OK
[   30.565201] Testing event xfs_iget_miss: OK
[   30.581109] Testing event xfs_getattr: OK
[   30.597142] Testing event xfs_setattr: OK
[   30.617188] Testing event xfs_readlink: OK
[   30.633625] Testing event xfs_alloc_file_space: OK
[   30.649256] Testing event xfs_free_file_space: OK
[   30.665111] Testing event xfs_readdir: OK
[   30.681498] Testing event xfs_get_acl: OK
[   30.697646] Testing event xfs_vm_bmap: OK
[   30.717198] Testing event xfs_file_ioctl: OK
[   30.733100] Testing event xfs_file_compat_ioctl: OK
[   30.749122] Testing event xfs_ioctl_setattr: OK
[   30.765121] Testing event xfs_dir_fsync: OK
[   30.781152] Testing event xfs_file_fsync: OK
[   30.797900] Testing event xfs_destroy_inode: OK
[   30.813202] Testing event xfs_evict_inode: OK
[   30.833142] Testing event xfs_update_time: OK
[   30.849118] Testing event xfs_dquot_dqalloc: OK
[   30.865209] Testing event xfs_dquot_dqdetach: OK
[   30.882265] Testing event xfs_ihold: OK
[   30.897195] Testing event xfs_irele: OK
[   30.913671] Testing event xfs_inode_pin: OK
[   30.929150] Testing event xfs_inode_unpin: OK
[   30.946027] Testing event xfs_inode_unpin_nowait: OK
[   30.961899] Testing event xfs_remove: OK
[   30.977188] Testing event xfs_link: OK
[   30.993111] Testing event xfs_lookup: OK
[   31.009534] Testing event xfs_create: OK
[   31.025146] Testing event xfs_symlink: OK
[   31.045179] Testing event xfs_rename: OK
[   31.063996] Testing event xfs_dqadjust: OK
[   31.080772] Testing event xfs_dqreclaim_want: OK
[   31.097136] Testing event xfs_dqreclaim_dirty: OK
[   31.113111] Testing event xfs_dqreclaim_busy: OK
[   31.129154] Testing event xfs_dqreclaim_done: OK
[   31.144996] Testing event xfs_dqattach_found: OK
[   31.161197] Testing event xfs_dqattach_get: OK
[   31.177539] Testing event xfs_dqalloc: OK
[   31.197060] Testing event xfs_dqtobp_read: OK
[   31.213143] Testing event xfs_dqread: OK
[   31.229103] Testing event xfs_dqread_fail: OK
[   31.245489] Testing event xfs_dqget_hit: OK
[   31.261080] Testing event xfs_dqget_miss: OK
[   31.280978] Testing event xfs_dqget_freeing: OK
[   31.296772] Testing event xfs_dqget_dup: OK
[   31.317137] Testing event xfs_dqput: OK
[   31.333232] Testing event xfs_dqput_wait: OK
[   31.349455] Testing event xfs_dqput_free: OK
[   31.365221] Testing event xfs_dqrele: OK
[   31.380800] Testing event xfs_dqflush: OK
[   31.397518] Testing event xfs_dqflush_force: OK
[   31.414347] Testing event xfs_dqflush_done: OK
[   31.433143] Testing event xfs_log_done_nonperm: OK
[   31.455635] Testing event xfs_log_done_perm: OK
[   31.473140] Testing event xfs_log_umount_write: OK
[   31.489934] Testing event xfs_log_grant_sleep: OK
[   31.509080] Testing event xfs_log_grant_wake: OK
[   31.537066] Testing event xfs_log_grant_wake_up: OK
[   31.552889] Testing event xfs_log_reserve: OK
[   31.569095] Testing event xfs_log_reserve_exit: OK
[   31.585635] Testing event xfs_log_regrant: OK
[   31.601169] Testing event xfs_log_regrant_exit: OK
[   31.617065] Testing event xfs_log_regrant_reserve_enter: OK
[   31.632759] Testing event xfs_log_regrant_reserve_exit: OK
[   31.649468] Testing event xfs_log_regrant_reserve_sub: OK
[   31.665077] Testing event xfs_log_ungrant_enter: OK
[   31.681505] Testing event xfs_log_ungrant_exit: OK
[   31.699759] Testing event xfs_log_ungrant_sub: OK
[   31.717985] Testing event xfs_log_force: OK
[   31.733937] Testing event xfs_ail_push: OK
[   31.749141] Testing event xfs_ail_pinned: OK
[   31.765185] Testing event xfs_ail_locked: OK
[   31.781407] Testing event xfs_ail_flushing: OK
[   31.797133] Testing event xfs_file_read: OK
[   31.813067] Testing event xfs_file_buffered_write: OK
[   31.829093] Testing event xfs_file_direct_write: OK
[   31.845123] Testing event xfs_file_splice_read: OK
[   31.861156] Testing event xfs_file_splice_write: OK
[   31.877195] Testing event xfs_writepage: OK
[   31.893235] Testing event xfs_releasepage: OK
[   31.909193] Testing event xfs_invalidatepage: OK
[   31.925225] Testing event xfs_map_blocks_found: OK
[   31.941568] Testing event xfs_map_blocks_alloc: OK
[   31.957599] Testing event xfs_get_blocks_found: OK
[   31.973192] Testing event xfs_get_blocks_alloc: OK
[   31.989159] Testing event xfs_delalloc_enospc: OK
[   32.005095] Testing event xfs_unwritten_convert: OK
[   32.021153] Testing event xfs_get_blocks_notfound: OK
[   32.037062] Testing event xfs_setfilesize: OK
[   32.053220] Testing event xfs_itruncate_extents_start: OK
[   32.069222] Testing event xfs_itruncate_extents_end: OK
[   32.085073] Testing event xfs_pagecache_inval: OK
[   32.101035] Testing event xfs_bunmap: OK
[   32.117254] Testing event xfs_extent_busy: OK
[   32.133181] Testing event xfs_extent_busy_enomem: OK
[   32.149090] Testing event xfs_extent_busy_force: OK
[   32.165266] Testing event xfs_extent_busy_reuse: OK
[   32.184871] Testing event xfs_extent_busy_clear: OK
[   32.200888] Testing event xfs_extent_busy_trim: OK
[   32.218451] Testing event xfs_trans_commit_lsn: OK
[   32.236838] Testing event xfs_agf: OK
[   32.253135] Testing event xfs_free_extent: OK
[   32.269120] Testing event xfs_alloc_exact_done: OK
[   32.285165] Testing event xfs_alloc_exact_notfound: OK
[   32.301159] Testing event xfs_alloc_exact_error: OK
[   32.316961] Testing event xfs_alloc_near_nominleft: OK
[   32.332986] Testing event xfs_alloc_near_first: OK
[   32.350202] Testing event xfs_alloc_near_greater: OK
[   32.364774] Testing event xfs_alloc_near_lesser: OK
[   32.380821] Testing event xfs_alloc_near_error: OK
[   32.397737] Testing event xfs_alloc_near_noentry: OK
[   32.413098] Testing event xfs_alloc_near_busy: OK
[   32.429622] Testing event xfs_alloc_size_neither: OK
[   32.445235] Testing event xfs_alloc_size_noentry: OK
[   32.461138] Testing event xfs_alloc_size_nominleft: OK
[   32.477151] Testing event xfs_alloc_size_done: OK
[   32.494055] Testing event xfs_alloc_size_error: OK
[   32.512839] Testing event xfs_alloc_size_busy: OK
[   32.529127] Testing event xfs_alloc_small_freelist: OK
[   32.545422] Testing event xfs_alloc_small_notenough: OK
[   32.560822] Testing event xfs_alloc_small_done: OK
[   32.577129] Testing event xfs_alloc_small_error: OK
[   32.593505] Testing event xfs_alloc_vextent_badargs: OK
[   32.609535] Testing event xfs_alloc_vextent_nofix: OK
[   32.629249] Testing event xfs_alloc_vextent_noagbp: OK
[   32.645681] Testing event xfs_alloc_vextent_loopfailed: OK
[   32.669209] Testing event xfs_alloc_vextent_allfailed: OK
[   32.685207] Testing event xfs_dir2_sf_addname: OK
[   32.702318] Testing event xfs_dir2_sf_create: OK
[   32.720907] Testing event xfs_dir2_sf_lookup: OK
[   32.737244] Testing event xfs_dir2_sf_replace: OK
[   32.752860] Testing event xfs_dir2_sf_removename: OK
[   32.769222] Testing event xfs_dir2_sf_toino4: OK
[   32.786223] Testing event xfs_dir2_sf_toino8: OK
[   32.801138] Testing event xfs_dir2_sf_to_block: OK
[   32.817177] Testing event xfs_dir2_block_addname: OK
[   32.833049] Testing event xfs_dir2_block_lookup: OK
[   32.848908] Testing event xfs_dir2_block_replace: OK
[   32.865549] Testing event xfs_dir2_block_removename: OK
[   32.881144] Testing event xfs_dir2_block_to_sf: OK
[   32.899921] Testing event xfs_dir2_block_to_leaf: OK
[   32.917909] Testing event xfs_dir2_leaf_addname: OK
[   32.933228] Testing event xfs_dir2_leaf_lookup: OK
[   32.949098] Testing event xfs_dir2_leaf_replace: OK
[   32.965540] Testing event xfs_dir2_leaf_removename: OK
[   32.981106] Testing event xfs_dir2_leaf_to_block: OK
[   32.997106] Testing event xfs_dir2_leaf_to_node: OK
[   33.013475] Testing event xfs_dir2_node_addname: OK
[   33.029066] Testing event xfs_dir2_node_lookup: OK
[   33.045093] Testing event xfs_dir2_node_replace: OK
[   33.061592] Testing event xfs_dir2_node_removename: OK
[   33.077701] Testing event xfs_dir2_node_to_leaf: OK
[   33.093035] Testing event xfs_attr_sf_add: OK
[   33.112260] Testing event xfs_attr_sf_addname: OK
[   33.129138] Testing event xfs_attr_sf_create: OK
[   33.145071] Testing event xfs_attr_sf_lookup: OK
[   33.160942] Testing event xfs_attr_sf_remove: OK
[   33.176790] Testing event xfs_attr_sf_removename: OK
[   33.193038] Testing event xfs_attr_sf_to_leaf: OK
[   33.209111] Testing event xfs_attr_leaf_add: OK
[   33.227418] Testing event xfs_attr_leaf_add_old: OK
[   33.245143] Testing event xfs_attr_leaf_add_new: OK
[   33.261140] Testing event xfs_attr_leaf_addname: OK
[   33.277248] Testing event xfs_attr_leaf_create: OK
[   33.293115] Testing event xfs_attr_leaf_lookup: OK
[   33.309127] Testing event xfs_attr_leaf_replace: OK
[   33.325065] Testing event xfs_attr_leaf_removename: OK
[   33.342088] Testing event xfs_attr_leaf_split: OK
[   33.369653] Testing event xfs_attr_leaf_split_before: OK
[   33.389247] Testing event xfs_attr_leaf_split_after: OK
[   33.405119] Testing event xfs_attr_leaf_clearflag: OK
[   33.422981] Testing event xfs_attr_leaf_setflag: OK
[   33.446172] Testing event xfs_attr_leaf_flipflags: OK
[   33.461189] Testing event xfs_attr_leaf_to_sf: OK
[   33.477151] Testing event xfs_attr_leaf_to_node: OK
[   33.493187] Testing event xfs_attr_leaf_rebalance: OK
[   33.509559] Testing event xfs_attr_leaf_unbalance: OK
[   33.529068] Testing event xfs_attr_node_addname: OK
[   33.546456] Testing event xfs_attr_node_lookup: OK
[   33.575997] Testing event xfs_attr_node_replace: OK
[   33.595869] Testing event xfs_attr_node_removename: OK
[   33.614157] Testing event xfs_da_split: OK
[   33.639911] Testing event xfs_da_join: OK
[   33.657109] Testing event xfs_da_link_before: OK
[   33.682137] Testing event xfs_da_link_after: OK
[   33.697091] Testing event xfs_da_unlink_back: OK
[   33.712990] Testing event xfs_da_unlink_forward: OK
[   33.728985] Testing event xfs_da_root_split: OK
[   33.745098] Testing event xfs_da_root_join: OK
[   33.761193] Testing event xfs_da_node_add: OK
[   33.776783] Testing event xfs_da_node_create: OK
[   33.793295] Testing event xfs_da_node_split: OK
[   33.808862] Testing event xfs_da_node_remove: OK
[   33.825228] Testing event xfs_da_node_rebalance: OK
[   33.841442] Testing event xfs_da_node_unbalance: OK
[   33.857281] Testing event xfs_da_swap_lastblock: OK
[   33.872976] Testing event xfs_da_grow_inode: OK
[   33.888999] Testing event xfs_da_shrink_inode: OK
[   33.905123] Testing event xfs_dir2_leafn_add: OK
[   33.920990] Testing event xfs_dir2_leafn_remove: OK
[   33.937386] Testing event xfs_dir2_grow_inode: OK
[   33.952994] Testing event xfs_dir2_shrink_inode: OK
[   33.973000] Testing event xfs_dir2_leafn_moveents: OK
[   33.993205] Testing event xfs_swap_extent_before: OK
[   34.013043] Testing event xfs_swap_extent_after: OK
[   34.031261] Testing event xfs_log_recover_item_add: OK
[   34.049176] Testing event xfs_log_recover_item_add_cont: OK
[   34.065194] Testing event xfs_log_recover_item_reorder_head: OK
[   34.082740] Testing event xfs_log_recover_item_reorder_tail: OK
[   34.103593] Testing event xfs_log_recover_item_recover: OK
[   34.122718] Testing event xfs_log_recover_buf_not_cancel: OK
[   34.142143] Testing event xfs_log_recover_buf_cancel: OK
[   34.161506] Testing event xfs_log_recover_buf_cancel_add: OK
[   34.177120] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   34.193164] Testing event xfs_log_recover_buf_recover: OK
[   34.213201] Testing event xfs_log_recover_buf_inode_buf: OK
[   34.229056] Testing event xfs_log_recover_buf_reg_buf: OK
[   34.245512] Testing event xfs_log_recover_buf_dquot_buf: OK
[   34.265075] Testing event xfs_log_recover_inode_recover: OK
[   34.281084] Testing event xfs_log_recover_inode_cancel: OK
[   34.297243] Testing event xfs_log_recover_inode_skip: OK
[   34.313115] Testing event xfs_discard_extent: OK
[   34.329131] Testing event xfs_discard_toosmall: OK
[   34.345186] Testing event xfs_discard_exclude: OK
[   34.361144] Testing event xfs_discard_busy: OK
[   34.377178] Testing event jbd2_checkpoint: OK
[   34.393294] Testing event jbd2_start_commit: OK
[   34.409139] Testing event jbd2_commit_locking: OK
[   34.425163] Testing event jbd2_commit_flushing: OK
[   34.441346] Testing event jbd2_commit_logging: OK
[   34.458581] Testing event jbd2_drop_transaction: OK
[   34.477178] Testing event jbd2_end_commit: OK
[   34.493095] Testing event jbd2_submit_inode_data: OK
[   34.509051] Testing event jbd2_run_stats: OK
[   34.525144] Testing event jbd2_checkpoint_stats: OK
[   34.541260] Testing event jbd2_update_log_tail: OK
[   34.557067] Testing event jbd2_write_superblock: OK
[   34.573045] Testing event jbd_checkpoint: OK
[   34.589073] Testing event jbd_start_commit: OK
[   34.605894] Testing event jbd_commit_locking: OK
[   34.625127] Testing event jbd_commit_flushing: OK
[   34.640869] Testing event jbd_commit_logging: OK
[   34.658135] Testing event jbd_drop_transaction: OK
[   34.676925] Testing event jbd_end_commit: OK
[   34.693203] Testing event jbd_do_submit_data: OK
[   34.708926] Testing event jbd_cleanup_journal_tail: OK
[   34.733050] Testing event journal_write_superblock: OK
[   34.749296] Testing event ext4_free_inode: OK
[   34.765275] Testing event ext4_request_inode: OK
[   34.780711] Testing event ext4_allocate_inode: OK
[   34.797316] Testing event ext4_evict_inode: OK
[   34.813125] Testing event ext4_drop_inode: OK
[   34.829595] Testing event ext4_mark_inode_dirty: OK
[   34.845109] Testing event ext4_begin_ordered_truncate: OK
[   34.861126] Testing event ext4_write_begin: OK
[   34.877935] Testing event ext4_da_write_begin: OK
[   34.893084] Testing event ext4_ordered_write_end: OK
[   34.913058] Testing event ext4_writeback_write_end: OK
[   34.929112] Testing event ext4_journalled_write_end: OK
[   34.945089] Testing event ext4_da_write_end: OK
[   34.961112] Testing event ext4_da_writepages: OK
[   34.976775] Testing event ext4_da_write_pages: OK
[   34.992854] Testing event ext4_da_writepages_result: OK
[   35.009126] Testing event ext4_writepage: OK
[   35.025105] Testing event ext4_readpage: OK
[   35.041137] Testing event ext4_releasepage: OK
[   35.056678] Testing event ext4_invalidatepage: OK
[   35.073124] Testing event ext4_discard_blocks: OK
[   35.088930] Testing event ext4_mb_new_inode_pa: OK
[   35.105119] Testing event ext4_mb_new_group_pa: OK
[   35.121140] Testing event ext4_mb_release_inode_pa: OK
[   35.137125] Testing event ext4_mb_release_group_pa: OK
[   35.153113] Testing event ext4_discard_preallocations: OK
[   35.169147] Testing event ext4_mb_discard_preallocations: OK
[   35.185156] Testing event ext4_request_blocks: OK
[   35.201139] Testing event ext4_allocate_blocks: OK
[   35.217095] Testing event ext4_free_blocks: OK
[   35.233097] Testing event ext4_sync_file_enter: OK
[   35.249116] Testing event ext4_sync_file_exit: OK
[   35.265128] Testing event ext4_sync_fs: OK
[   35.281089] Testing event ext4_alloc_da_blocks: OK
[   35.296854] Testing event ext4_mballoc_alloc: OK
[   35.312855] Testing event ext4_mballoc_prealloc: OK
[   35.329120] Testing event ext4_mballoc_discard: OK
[   35.345133] Testing event ext4_mballoc_free: OK
[   35.361546] Testing event ext4_forget: OK
[   35.376827] Testing event ext4_da_update_reserve_space: OK
[   35.393043] Testing event ext4_da_reserve_space: OK
[   35.408805] Testing event ext4_da_release_space: OK
[   35.425161] Testing event ext4_mb_bitmap_load: OK
[   35.441144] Testing event ext4_mb_buddy_bitmap_load: OK
[   35.457253] Testing event ext4_read_block_bitmap_load: OK
[   35.472988] Testing event ext4_load_inode_bitmap: OK
[   35.488852] Testing event ext4_direct_IO_enter: OK
[   35.504777] Testing event ext4_direct_IO_exit: OK
[   35.520788] Testing event ext4_fallocate_enter: OK
[   35.537128] Testing event ext4_fallocate_exit: OK
[   35.553092] Testing event ext4_unlink_enter: OK
[   35.569090] Testing event ext4_unlink_exit: OK
[   35.585024] Testing event ext4_truncate_enter: OK
[   35.601045] Testing event ext4_truncate_exit: OK
[   35.617159] Testing event ext4_ext_convert_to_initialized_enter: OK
[   35.633147] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   35.649071] Testing event ext4_ext_map_blocks_enter: OK
[   35.665170] Testing event ext4_ind_map_blocks_enter: OK
[   35.680879] Testing event ext4_ext_map_blocks_exit: OK
[   35.697108] Testing event ext4_ind_map_blocks_exit: OK
[   35.712801] Testing event ext4_ext_load_extent: OK
[   35.729193] Testing event ext4_load_inode: OK
[   35.744835] Testing event ext4_journal_start: OK
[   35.760847] Testing event ext4_trim_extent: OK
[   35.777163] Testing event ext4_trim_all_free: OK
[   35.792830] Testing event ext4_ext_handle_uninitialized_extents: OK
[   35.809241] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   35.825121] Testing event ext4_ext_put_in_cache: OK
[   35.841051] Testing event ext4_ext_in_cache: OK
[   35.857072] Testing event ext4_find_delalloc_range: OK
[   35.872878] Testing event ext4_get_reserved_cluster_alloc: OK
[   35.890140] Testing event ext4_ext_show_extent: OK
[   35.905106] Testing event ext4_remove_blocks: OK
[   35.921234] Testing event ext4_ext_rm_leaf: OK
[   35.937165] Testing event ext4_ext_rm_idx: OK
[   35.953137] Testing event ext4_ext_remove_space: OK
[   35.969133] Testing event ext4_ext_remove_space_done: OK
[   35.985112] Testing event ext3_free_inode: OK
[   36.001079] Testing event ext3_request_inode: OK
[   36.017111] Testing event ext3_allocate_inode: OK
[   36.032865] Testing event ext3_evict_inode: OK
[   36.048925] Testing event ext3_drop_inode: OK
[   36.065155] Testing event ext3_mark_inode_dirty: OK
[   36.081038] Testing event ext3_write_begin: OK
[   36.096802] Testing event ext3_ordered_write_end: OK
[   36.113180] Testing event ext3_writeback_write_end: OK
[   36.129116] Testing event ext3_journalled_write_end: OK
[   36.144887] Testing event ext3_ordered_writepage: OK
[   36.161159] Testing event ext3_writeback_writepage: OK
[   36.177167] Testing event ext3_journalled_writepage: OK
[   36.193063] Testing event ext3_readpage: OK
[   36.208822] Testing event ext3_releasepage: OK
[   36.225142] Testing event ext3_invalidatepage: OK
[   36.241316] Testing event ext3_discard_blocks: OK
[   36.256706] Testing event ext3_request_blocks: OK
[   36.272769] Testing event ext3_allocate_blocks: OK
[   36.289112] Testing event ext3_free_blocks: OK
[   36.304800] Testing event ext3_sync_file_enter: OK
[   36.320706] Testing event ext3_sync_file_exit: OK
[   36.336795] Testing event ext3_sync_fs: OK
[   36.352790] Testing event ext3_rsv_window_add: OK
[   36.368963] Testing event ext3_discard_reservation: OK
[   36.385160] Testing event ext3_alloc_new_reservation: OK
[   36.401127] Testing event ext3_reserved: OK
[   36.417121] Testing event ext3_forget: OK
[   36.433112] Testing event ext3_read_block_bitmap: OK
[   36.448806] Testing event ext3_direct_IO_enter: OK
[   36.465164] Testing event ext3_direct_IO_exit: OK
[   36.481471] Testing event ext3_unlink_enter: OK
[   36.497275] Testing event ext3_unlink_exit: OK
[   36.512810] Testing event ext3_truncate_enter: OK
[   36.529118] Testing event ext3_truncate_exit: OK
[   36.551156] Testing event ext3_get_blocks_enter: OK
[   36.568778] Testing event ext3_get_blocks_exit: OK
[   36.584789] Testing event ext3_load_inode: OK
[   36.600946] Testing event writeback_nothread: OK
[   36.616895] Testing event writeback_queue: OK
[   36.632755] Testing event writeback_exec: OK
[   36.648908] Testing event writeback_start: OK
[   36.664907] Testing event writeback_written: OK
[   36.681066] Testing event writeback_wait: OK
[   36.697146] Testing event writeback_pages_written: OK
[   36.713094] Testing event writeback_nowork: OK
[   36.733165] Testing event writeback_wake_background: OK
[   36.749209] Testing event writeback_wake_thread: OK
[   36.764880] Testing event writeback_wake_forker_thread: OK
[   36.781118] Testing event writeback_bdi_register: OK
[   36.797180] Testing event writeback_bdi_unregister: OK
[   36.813085] Testing event writeback_thread_start: OK
[   36.829111] Testing event writeback_thread_stop: OK
[   36.844846] Testing event wbc_writepage: OK
[   36.860905] Testing event writeback_queue_io: OK
[   36.877315] Testing event global_dirty_state: OK
[   36.893076] Testing event bdi_dirty_ratelimit: OK
[   36.909189] Testing event balance_dirty_pages: OK
[   36.925099] Testing event writeback_sb_inodes_requeue: OK
[   36.941033] Testing event writeback_congestion_wait: OK
[   36.957716] Testing event writeback_wait_iff_congested: OK
[   36.973120] Testing event writeback_single_inode: OK
[   36.989140] Testing event mm_compaction_isolate_migratepages: OK
[   37.004728] Testing event mm_compaction_isolate_freepages: OK
[   37.021080] Testing event mm_compaction_migratepages: OK
[   37.036917] Testing event kmalloc: OK
[   37.052844] Testing event kmem_cache_alloc: OK
[   37.068800] Testing event kmalloc_node: OK
[   37.084846] Testing event kmem_cache_alloc_node: OK
[   37.100874] Testing event kfree: OK
[   37.116664] Testing event kmem_cache_free: OK
[   37.132660] Testing event mm_page_free: OK
[   37.148801] Testing event mm_page_free_batched: OK
[   37.164864] Testing event mm_page_alloc: OK
[   37.180774] Testing event mm_page_alloc_zone_locked: OK
[   37.196904] Testing event mm_page_pcpu_drain: OK
[   37.213128] Testing event mm_page_alloc_extfrag: OK
[   37.229078] Testing event mm_vmscan_kswapd_sleep: OK
[   37.245071] Testing event mm_vmscan_kswapd_wake: OK
[   37.261136] Testing event mm_vmscan_wakeup_kswapd: OK
[   37.277037] Testing event mm_vmscan_direct_reclaim_begin: OK
[   37.293090] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   37.309031] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   37.325117] Testing event mm_vmscan_direct_reclaim_end: OK
[   37.341114] Testing event mm_vmscan_memcg_reclaim_end: OK
[   37.356884] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   37.373158] Testing event mm_shrink_slab_start: OK
[   37.388755] Testing event mm_shrink_slab_end: OK
[   37.405163] Testing event mm_vmscan_lru_isolate: OK
[   37.421167] Testing event mm_vmscan_memcg_isolate: OK
[   37.436945] Testing event mm_vmscan_writepage: OK
[   37.453104] Testing event mm_vmscan_lru_shrink_inactive: OK
[   37.469142] Testing event oom_score_adj_update: OK
[   37.485338] Testing event rpm_suspend: OK
[   37.501141] Testing event rpm_resume: OK
[   37.517126] Testing event rpm_idle: OK
[   37.533193] Testing event rpm_return_int: OK
[   37.549197] Testing event cpu_idle: OK
[   37.565074] Testing event cpu_frequency: OK
[   37.581174] Testing event machine_suspend: OK
[   37.597168] Testing event wakeup_source_activate: OK
[   37.613061] Testing event wakeup_source_deactivate: OK
[   37.628858] Testing event power_start: OK
[   37.645110] Testing event power_frequency: OK
[   37.661158] Testing event power_end: OK
[   37.677074] Testing event clock_enable: OK
[   37.692723] Testing event clock_disable: OK
[   37.709173] Testing event clock_set_rate: OK
[   37.725132] Testing event power_domain_target: OK
[   37.740834] Testing event ftrace_test_filter: OK
[   37.756838] Testing event module_load: OK
[   37.772784] Testing event module_free: OK
[   37.788768] Testing event module_get: OK
[   37.804744] Testing event module_put: OK
[   37.820702] Testing event module_request: OK
[   37.837064] Testing event lock_acquire: OK
[   37.852989] Testing event lock_release: OK
[   37.869129] Testing event lock_contended: OK
[   37.885136] Testing event lock_acquired: OK
[   37.901083] Testing event sched_kthread_stop: OK
[   37.917491] Testing event sched_kthread_stop_ret: OK
[   37.933131] Testing event sched_wakeup: OK
[   37.949032] Testing event sched_wakeup_new: OK
[   37.965076] Testing event sched_switch: OK
[   37.981116] Testing event sched_migrate_task: OK
[   37.997206] Testing event sched_process_free: OK
[   38.012910] Testing event sched_process_exit: OK
[   38.028846] Testing event sched_wait_task: OK
[   38.045102] Testing event sched_process_wait: OK
[   38.061194] Testing event sched_process_fork: OK
[   38.076881] Testing event sched_process_exec: OK
[   38.093095] Testing event sched_stat_wait: OK
[   38.108802] Testing event sched_stat_sleep: OK
[   38.124794] Testing event sched_stat_iowait: OK
[   38.140907] Testing event sched_stat_blocked: OK
[   38.156675] Testing event sched_stat_runtime: OK
[   38.172765] Testing event sched_pi_setprio: OK
[   38.188667] Testing event rcu_utilization: OK
[   38.204774] Testing event rcu_grace_period: OK
[   38.221097] Testing event rcu_grace_period_init: OK
[   38.237098] Testing event rcu_preempt_task: OK
[   38.253094] Testing event rcu_unlock_preempted_task: OK
[   38.269102] Testing event rcu_quiescent_state_report: OK
[   38.284740] Testing event rcu_fqs: OK
[   38.301109] Testing event rcu_dyntick: OK
[   38.317117] Testing event rcu_prep_idle: OK
[   38.333120] Testing event rcu_callback: OK
[   38.349134] Testing event rcu_kfree_callback: OK
[   38.365089] Testing event rcu_batch_start: OK
[   38.381114] Testing event rcu_invoke_callback: OK
[   38.397044] Testing event rcu_invoke_kfree_callback: OK
[   38.412821] Testing event rcu_batch_end: OK
[   38.428976] Testing event rcu_torture_read: OK
[   38.445127] Testing event rcu_barrier: OK
[   38.460842] Testing event workqueue_queue_work: OK
[   38.476787] Testing event workqueue_activate_work: OK
[   38.492809] Testing event workqueue_execute_start: OK
[   38.508771] Testing event workqueue_execute_end: OK
[   38.525167] Testing event signal_generate: OK
[   38.541054] Testing event signal_deliver: OK
[   38.557100] Testing event timer_init: OK
[   38.573144] Testing event timer_start: OK
[   38.589089] Testing event timer_expire_entry: OK
[   38.604929] Testing event timer_expire_exit: OK
[   38.621080] Testing event timer_cancel: OK
[   38.637093] Testing event hrtimer_init: OK
[   38.653142] Testing event hrtimer_start: OK
[   38.669098] Testing event hrtimer_expire_entry: OK
[   38.685187] Testing event hrtimer_expire_exit: OK
[   38.701067] Testing event hrtimer_cancel: OK
[   38.717121] Testing event itimer_state: OK
[   38.733111] Testing event itimer_expire: OK
[   38.749140] Testing event irq_handler_entry: OK
[   38.765139] Testing event irq_handler_exit: OK
[   38.781163] Testing event softirq_entry: OK
[   38.796851] Testing event softirq_exit: OK
[   38.812954] Testing event softirq_raise: OK
[   38.829117] Testing event console: OK
[   38.845184] Testing event task_newtask: OK
[   38.861122] Testing event task_rename: OK
[   38.877120] Testing event mce_record: OK
[   38.893069] Testing event sys_enter: OK
[   38.909207] Testing event sys_exit: OK
[   38.925186] Testing event emulate_vsyscall: OK
[   38.940784] Testing event xen_mc_batch: OK
[   38.956757] Testing event xen_mc_issue: OK
[   38.973147] Testing event xen_mc_entry: OK
[   38.988798] Testing event xen_mc_entry_alloc: OK
[   39.004679] Testing event xen_mc_callback: OK
[   39.020788] Testing event xen_mc_flush_reason: OK
[   39.036753] Testing event xen_mc_flush: OK
[   39.053108] Testing event xen_mc_extend_args: OK
[   39.068822] Testing event xen_mmu_set_pte: OK
[   39.084788] Testing event xen_mmu_set_pte_atomic: OK
[   39.100793] Testing event xen_mmu_set_domain_pte: OK
[   39.116785] Testing event xen_mmu_set_pte_at: OK
[   39.132837] Testing event xen_mmu_pte_clear: OK
[   39.149070] Testing event xen_mmu_set_pmd: OK
[   39.164916] Testing event xen_mmu_pmd_clear: OK
[   39.180757] Testing event xen_mmu_set_pud: OK
[   39.196792] Testing event xen_mmu_set_pgd: OK
[   39.212883] Testing event xen_mmu_pud_clear: OK
[   39.228764] Testing event xen_mmu_pgd_clear: OK
[   39.244653] Testing event xen_mmu_ptep_modify_prot_start: OK
[   39.260746] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   39.276657] Testing event xen_mmu_alloc_ptpage: OK
[   39.292664] Testing event xen_mmu_release_ptpage: OK
[   39.308848] Testing event xen_mmu_pgd_pin: OK
[   39.324975] Testing event xen_mmu_pgd_unpin: OK
[   39.341149] Testing event xen_mmu_flush_tlb: OK
[   39.357052] Testing event xen_mmu_flush_tlb_single: OK
[   39.373138] Testing event xen_mmu_flush_tlb_others: OK
[   39.389046] Testing event xen_mmu_write_cr3: OK
[   39.405171] Testing event xen_cpu_write_ldt_entry: OK
[   39.420866] Testing event xen_cpu_write_idt_entry: OK
[   39.442306] Testing event xen_cpu_load_idt: OK
[   39.456803] Testing event xen_cpu_write_gdt_entry: OK
[   39.473115] Testing event xen_cpu_set_ldt: OK
[   39.489132] Testing event kvm_mmu_pagetable_walk: OK
[   39.505087] Testing event kvm_mmu_paging_element: OK
[   39.521055] Testing event kvm_mmu_set_accessed_bit: OK
[   39.536975] Testing event kvm_mmu_set_dirty_bit: OK
[   39.552848] Testing event kvm_mmu_walker_error: OK
[   39.569115] Testing event kvm_mmu_get_page: OK
[   39.585043] Testing event kvm_mmu_sync_page: OK
[   39.601117] Testing event kvm_mmu_unsync_page: OK
[   39.617104] Testing event kvm_mmu_prepare_zap_page: OK
[   39.633068] Testing event kvm_mmu_delay_free_pages: OK
[   39.648945] Testing event mark_mmio_spte: OK
[   39.665066] Testing event handle_mmio_page_fault: OK
[   39.680960] Testing event fast_page_fault: OK
[   39.696879] Testing event kvm_entry: OK
[   39.713085] Testing event kvm_hypercall: OK
[   39.729078] Testing event kvm_hv_hypercall: OK
[   39.745075] Testing event kvm_pio: OK
[   39.761050] Testing event kvm_cpuid: OK
[   39.777047] Testing event kvm_apic: OK
[   39.793081] Testing event kvm_exit: OK
[   39.808814] Testing event kvm_inj_virq: OK
[   39.824809] Testing event kvm_inj_exception: OK
[   39.840906] Testing event kvm_page_fault: OK
[   39.856972] Testing event kvm_msr: OK
[   39.872784] Testing event kvm_cr: OK
[   39.889112] Testing event kvm_pic_set_irq: OK
[   39.904775] Testing event kvm_apic_ipi: OK
[   39.920855] Testing event kvm_apic_accept_irq: OK
[   39.936782] Testing event kvm_eoi: OK
[   39.952735] Testing event kvm_pv_eoi: OK
[   39.970248] Testing event kvm_nested_vmrun: OK
[   39.985301] Testing event kvm_nested_intercepts: OK
[   40.001297] Testing event kvm_nested_vmexit: OK
[   40.016904] Testing event kvm_nested_vmexit_inject: OK
[   40.032748] Testing event kvm_nested_intr_vmexit: OK
[   40.048735] Testing event kvm_invlpga: OK
[   40.065402] Testing event kvm_skinit: OK
[   40.081172] Testing event kvm_emulate_insn: OK
[   40.097072] Testing event vcpu_match_mmio: OK
[   40.112899] Testing event kvm_userspace_exit: OK
[   40.128938] Testing event kvm_set_irq: OK
[   40.145162] Testing event kvm_ioapic_set_irq: OK
[   40.161986] Testing event kvm_msi_set_irq: OK
[   40.177234] Testing event kvm_ack_irq: OK
[   40.193050] Testing event kvm_mmio: OK
[   40.209191] Testing event kvm_fpu: OK
[   40.225202] Testing event kvm_age_page: OK
[   40.241196] Testing event kvm_try_async_get_page: OK
[   40.256888] Testing event kvm_async_pf_doublefault: OK
[   40.272827] Testing event kvm_async_pf_not_present: OK
[   40.288757] Testing event kvm_async_pf_ready: OK
[   40.305430] Testing event kvm_async_pf_completed: OK
[   40.321105] Running tests on trace event systems:
[   40.322355] Testing event system 9p: OK
[   40.341428] Testing event system mac80211: OK
[   40.373595] Testing event system sunrpc: OK
[   40.389865] Testing event system skb: OK
[   40.405428] Testing event system net: OK
[   40.421514] Testing event system napi: OK
[   40.437246] Testing event system sock: OK
[   40.453133] Testing event system udp: OK
[   40.469157] Testing event system hda: OK
[   40.485349] Testing event system ras: OK
[   40.501035] Testing event system scsi: OK
[   40.517899] Testing event system regmap: OK
[   40.538625] Testing event system i915: OK
[   40.559355] Testing event system radeon: OK
[   40.577287] Testing event system drm: OK
[   40.593128] Testing event system random: OK
[   40.609735] Testing event system regulator: OK
[   40.625589] Testing event system gpio: OK
[   40.641332] Testing event system block: OK
[   40.662768] Testing event system gfs2: OK
[   40.682129] Testing event system btrfs: OK
[   40.703164] Testing event system ocfs2: OK
[   40.783425] Testing event system xfs: OK
[   40.869029] Testing event system jbd2: OK
[   40.886688] Testing event system jbd: OK
[   40.905610] Testing event system ext4: OK
[   40.934840] Testing event system ext3: OK
[   40.955702] Testing event system writeback: OK
[   40.979123] Testing event system compaction: OK
[   40.997000] Testing event system kmem: OK
[   41.013691] Testing event system vmscan: OK
[   41.034831] Testing event system oom: OK
[   41.053265] Testing event system rpm: OK
[   41.070388] Testing event system power: OK
[   41.090045] Testing event system test: OK
[   41.105109] Testing event system module: OK
[   41.121423] Testing event system lock: OK
[   41.137536] Testing event system sched: OK
[   41.158809] Testing event system rcu: OK
[   41.178763] Testing event system workqueue: OK
[   41.197526] Testing event system signal: OK
[   41.213788] Testing event system timer: OK
[   41.234069] Testing event system irq: OK
[   41.249438] Testing event system printk: OK
[   41.265240] Testing event system task: OK
[   41.281276] Testing event system mce: OK
[   41.297199] Testing event system raw_syscalls: OK
[   41.313347] Testing event system vsyscall: OK
[   41.329040] Testing event system syscalls: OK
[   41.345713] Testing event system xen: OK
[   41.367376] Testing event system kvmmmu: OK
[   41.386285] Testing event system kvm: OK
[   41.409445] Running tests on all trace events:
[   41.410644] Testing all events: OK
[   42.107683] Running tests again, along with the function tracer
[   42.109117] Running tests on trace events:
[   42.110045] Testing event 9p_client_req: OK
[   42.129902] Testing event 9p_client_res: OK
[   42.149651] Testing event 9p_protocol_dump: OK
[   42.165423] Testing event drv_return_void: OK
[   42.181370] Testing event drv_return_int: OK
[   42.198180] Testing event drv_return_bool: OK
[   42.217807] Testing event drv_return_u64: OK
[   42.237880] Testing event drv_start: OK
[   42.257694] Testing event drv_get_et_strings: OK
[   42.273772] Testing event drv_get_et_sset_count: OK
[   42.294187] Testing event drv_get_et_stats: OK
[   42.313895] Testing event drv_suspend: OK
[   42.333661] Testing event drv_resume: OK
[   42.349982] Testing event drv_set_wakeup: OK
[   42.370303] Testing event drv_stop: OK
[   42.390227] Testing event drv_add_interface: OK
[   42.410097] Testing event drv_change_interface: OK
[   42.430200] Testing event drv_remove_interface: OK
[   42.450206] Testing event drv_config: OK
[   42.470170] Testing event drv_bss_info_changed: OK
[   42.490318] Testing event drv_prepare_multicast: OK
[   42.510227] Testing event drv_configure_filter: OK
[   42.531042] Testing event drv_set_tim: OK
[   42.551343] Testing event drv_set_key: OK
[   42.570268] Testing event drv_update_tkip_key: OK
[   42.590215] Testing event drv_hw_scan: OK
[   42.610218] Testing event drv_cancel_hw_scan: OK
[   42.630428] Testing event drv_sched_scan_start: OK
[   42.650268] Testing event drv_sched_scan_stop: OK
[   42.670382] Testing event drv_sw_scan_start: OK
[   42.691989] Testing event drv_sw_scan_complete: OK
[   42.711676] Testing event drv_get_stats: OK
[   42.731748] Testing event drv_get_tkip_seq: OK
[   42.750331] Testing event drv_set_frag_threshold: OK
[   42.770340] Testing event drv_set_rts_threshold: OK
[   42.790831] Testing event drv_set_coverage_class: OK
[   42.809999] Testing event drv_sta_notify: OK
[   42.826748] Testing event drv_sta_state: OK
[   42.846330] Testing event drv_sta_rc_update: OK
[   42.870081] Testing event drv_sta_add: OK
[   42.892417] Testing event drv_sta_remove: OK
[   42.910025] Testing event drv_conf_tx: OK
[   42.933249] Testing event drv_get_tsf: OK
[   42.958286] Testing event drv_set_tsf: OK
[   42.979220] Testing event drv_reset_tsf: OK
[   42.998307] Testing event drv_tx_last_beacon: OK
[   43.018220] Testing event drv_ampdu_action: OK
[   43.038396] Testing event drv_get_survey: OK
[   43.058395] Testing event drv_flush: OK
[   43.078306] Testing event drv_channel_switch: OK
[   43.098365] Testing event drv_set_antenna: OK
[   43.118291] Testing event drv_get_antenna: OK
[   43.138405] Testing event drv_remain_on_channel: OK
[   43.158347] Testing event drv_cancel_remain_on_channel: OK
[   43.177699] Testing event drv_offchannel_tx: OK
[   43.193612] Testing event drv_set_ringparam: OK
[   43.209624] Testing event drv_get_ringparam: OK
[   43.225668] Testing event drv_tx_frames_pending: OK
[   43.242143] Testing event drv_offchannel_tx_cancel_wait: OK
[   43.262038] Testing event drv_set_bitrate_mask: OK
[   43.282276] Testing event drv_set_rekey_data: OK
[   43.301567] Testing event drv_rssi_callback: OK
[   43.318038] Testing event drv_release_buffered_frames: OK
[   43.338122] Testing event drv_allow_buffered_frames: OK
[   43.358364] Testing event drv_get_rssi: OK
[   43.378353] Testing event drv_mgd_prepare_tx: OK
[   43.397853] Testing event api_start_tx_ba_session: OK
[   43.414292] Testing event api_start_tx_ba_cb: OK
[   43.439714] Testing event api_stop_tx_ba_session: OK
[   43.457547] Testing event api_stop_tx_ba_cb: OK
[   43.473580] Testing event api_restart_hw: OK
[   43.489960] Testing event api_beacon_loss: OK
[   43.506280] Testing event api_connection_loss: OK
[   43.526266] Testing event api_cqm_rssi_notify: OK
[   43.546597] Testing event api_scan_completed: OK
[   43.566272] Testing event api_sched_scan_results: OK
[   43.586371] Testing event api_sched_scan_stopped: OK
[   43.605752] Testing event api_sta_block_awake: OK
[   43.629517] Testing event api_chswitch_done: OK
[   43.650230] Testing event api_ready_on_channel: OK
[   43.670281] Testing event api_remain_on_channel_expired: OK
[   43.690200] Testing event api_gtk_rekey_notify: OK
[   43.709452] Testing event api_enable_rssi_reports: OK
[   43.727846] Testing event api_eosp: OK
[   43.747596] Testing event wake_queue: OK
[   43.766034] Testing event stop_queue: OK
[   43.781506] Testing event rpc_call_status: OK
[   43.799645] Testing event rpc_bind_status: OK
[   43.819118] Testing event rpc_connect_status: OK
[   43.838117] Testing event rpc_task_begin: OK
[   43.858376] Testing event rpc_task_run_action: OK
[   43.878358] Testing event rpc_task_complete: OK
[   43.898766] Testing event rpc_task_sleep: OK
[   43.919400] Testing event rpc_task_wakeup: OK
[   43.945933] Testing event kfree_skb: OK
[   43.966365] Testing event consume_skb: OK
[   43.986171] Testing event skb_copy_datagram_iovec: OK
[   44.005907] Testing event net_dev_xmit: OK
[   44.021913] Testing event net_dev_queue: OK
[   44.041625] Testing event netif_receive_skb: OK
[   44.057584] Testing event netif_rx: OK
[   44.074329] Testing event napi_poll: OK
[   44.094282] Testing event sock_rcvqueue_full: OK
[   44.113962] Testing event sock_exceed_buf_limit: OK
[   44.134278] Testing event udp_fail_queue_rcv_skb: OK
[   44.154306] Testing event hda_send_cmd: OK
[   44.174365] Testing event hda_get_response: OK
[   44.195053] Testing event hda_bus_reset: OK
[   44.214161] Testing event hda_power_down: OK
[   44.234049] Testing event hda_power_up: OK
[   44.254478] Testing event hda_unsol_event: OK
[   44.274196] Testing event mc_event: OK
[   44.293679] Testing event scsi_dispatch_cmd_start: OK
[   44.318229] Testing event scsi_dispatch_cmd_error: OK
[   44.339261] Testing event scsi_dispatch_cmd_done: OK
[   44.358216] Testing event scsi_dispatch_cmd_timeout: OK
[   44.378178] Testing event scsi_eh_wakeup: OK
[   44.397822] Testing event regmap_reg_write: OK
[   44.413574] Testing event regmap_reg_read: OK
[   44.429615] Testing event regmap_reg_read_cache: OK
[   44.446458] Testing event regmap_hw_read_start: OK
[   44.466131] Testing event regmap_hw_read_done: OK
[   44.486186] Testing event regmap_hw_write_start: OK
[   44.506091] Testing event regmap_hw_write_done: OK
[   44.526172] Testing event regcache_sync: OK
[   44.546307] Testing event regmap_cache_only: OK
[   44.566265] Testing event regmap_cache_bypass: OK
[   44.586220] Testing event i915_gem_object_create: OK
[   44.606430] Testing event i915_gem_object_bind: OK
[   44.626352] Testing event i915_gem_object_unbind: OK
[   44.646156] Testing event i915_gem_object_change_domain: OK
[   44.665585] Testing event i915_gem_object_pwrite: OK
[   44.681844] Testing event i915_gem_object_pread: OK
[   44.698239] Testing event i915_gem_object_fault: OK
[   44.717539] Testing event i915_gem_object_clflush: OK
[   44.737470] Testing event i915_gem_object_destroy: OK
[   44.753534] Testing event i915_gem_evict: OK
[   44.769684] Testing event i915_gem_evict_everything: OK
[   44.786227] Testing event i915_gem_ring_dispatch: OK
[   44.806333] Testing event i915_gem_ring_flush: OK
[   44.826335] Testing event i915_gem_request_add: OK
[   44.845826] Testing event i915_gem_request_complete: OK
[   44.866127] Testing event i915_gem_request_retire: OK
[   44.886000] Testing event i915_gem_request_wait_begin: OK
[   44.906518] Testing event i915_gem_request_wait_end: OK
[   44.927061] Testing event i915_ring_wait_begin: OK
[   44.946312] Testing event i915_ring_wait_end: OK
[   44.967836] Testing event i915_flip_request: OK
[   44.985910] Testing event i915_flip_complete: OK
[   45.001612] Testing event i915_reg_rw: OK
[   45.018435] Testing event radeon_bo_create: OK
[   45.037716] Testing event radeon_fence_emit: OK
[   45.057935] Testing event radeon_fence_retire: OK
[   45.077661] Testing event radeon_fence_wait_begin: OK
[   45.094376] Testing event radeon_fence_wait_end: OK
[   45.114182] Testing event drm_vblank_event: OK
[   45.134313] Testing event drm_vblank_event_queued: OK
[   45.154312] Testing event drm_vblank_event_delivered: OK
[   45.173945] Testing event mix_pool_bytes: OK
[   45.189888] Testing event mix_pool_bytes_nolock: OK
[   45.205730] Testing event credit_entropy_bits: OK
[   45.221558] Testing event get_random_bytes: OK
[   45.237870] Testing event extract_entropy: OK
[   45.257808] Testing event extract_entropy_user: OK
[   45.278375] Testing event regulator_enable: OK
[   45.298500] Testing event regulator_enable_delay: OK
[   45.317622] Testing event regulator_enable_complete: OK
[   45.333585] Testing event regulator_disable: OK
[   45.350292] Testing event regulator_disable_complete: OK
[   45.370038] Testing event regulator_set_voltage: OK
[   45.389660] Testing event regulator_set_voltage_complete: OK
[   45.409696] Testing event gpio_direction: OK
[   45.425632] Testing event gpio_value: OK
[   45.442318] Testing event block_rq_abort: OK
[   45.461508] Testing event block_rq_requeue: OK
[   45.477671] Testing event block_rq_complete: OK
[   45.494305] Testing event block_rq_insert: OK
[   45.513540] Testing event block_rq_issue: OK
[   45.529713] Testing event block_bio_bounce: OK
[   45.550376] Testing event block_bio_complete: OK
[   45.569458] Testing event block_bio_backmerge: OK
[   45.585446] Testing event block_bio_frontmerge: OK
[   45.601429] Testing event block_bio_queue: OK
[   45.617502] Testing event block_getrq: OK
[   45.633317] Testing event block_sleeprq: OK
[   45.649330] Testing event block_plug: OK
[   45.666099] Testing event block_unplug: OK
[   45.685393] Testing event block_split: OK
[   45.701353] Testing event block_bio_remap: OK
[   45.717430] Testing event block_rq_remap: OK
[   45.734289] Testing event gfs2_glock_state_change: OK
[   45.754286] Testing event gfs2_glock_put: OK
[   45.774379] Testing event gfs2_demote_rq: OK
[   45.794387] Testing event gfs2_promote: OK
[   45.813642] Testing event gfs2_glock_queue: OK
[   45.830131] Testing event gfs2_glock_lock_time: OK
[   45.850220] Testing event gfs2_pin: OK
[   45.865369] Testing event gfs2_log_flush: OK
[   45.881519] Testing event gfs2_log_blocks: OK
[   45.897378] Testing event gfs2_ail_flush: OK
[   45.913436] Testing event gfs2_bmap: OK
[   45.930261] Testing event gfs2_block_alloc: OK
[   45.949371] Testing event gfs2_rs: OK
[   45.966290] Testing event btrfs_transaction_commit: OK
[   45.986287] Testing event btrfs_inode_new: OK
[   46.006724] Testing event btrfs_inode_request: OK
[   46.026963] Testing event btrfs_inode_evict: OK
[   46.046172] Testing event btrfs_get_extent: OK
[   46.066279] Testing event btrfs_ordered_extent_add: OK
[   46.086181] Testing event btrfs_ordered_extent_remove: OK
[   46.105576] Testing event btrfs_ordered_extent_start: OK
[   46.121603] Testing event btrfs_ordered_extent_put: OK
[   46.137615] Testing event __extent_writepage: OK
[   46.153486] Testing event btrfs_writepage_end_io_hook: OK
[   46.170262] Testing event btrfs_sync_file: OK
[   46.189869] Testing event btrfs_sync_fs: OK
[   46.205694] Testing event btrfs_delayed_tree_ref: OK
[   46.221589] Testing event btrfs_delayed_data_ref: OK
[   46.237526] Testing event btrfs_delayed_ref_head: OK
[   46.253441] Testing event btrfs_chunk_alloc: OK
[   46.269707] Testing event btrfs_chunk_free: OK
[   46.285671] Testing event btrfs_cow_block: OK
[   46.301655] Testing event btrfs_space_reservation: OK
[   46.317515] Testing event btrfs_reserved_extent_alloc: OK
[   46.334821] Testing event btrfs_reserved_extent_free: OK
[   46.354307] Testing event find_free_extent: OK
[   46.373510] Testing event btrfs_reserve_extent: OK
[   46.389556] Testing event btrfs_reserve_extent_cluster: OK
[   46.405610] Testing event btrfs_find_cluster: OK
[   46.421487] Testing event btrfs_failed_cluster_setup: OK
[   46.437418] Testing event btrfs_setup_cluster: OK
[   46.454213] Testing event alloc_extent_state: OK
[   46.473620] Testing event free_extent_state: OK
[   46.489469] Testing event ocfs2_adjust_rightmost_branch: OK
[   46.506312] Testing event ocfs2_rotate_tree_right: OK
[   46.526262] Testing event ocfs2_append_rec_to_path: OK
[   46.546357] Testing event ocfs2_insert_extent_start: OK
[   46.566308] Testing event ocfs2_add_clusters_in_btree: OK
[   46.585930] Testing event ocfs2_num_free_extents: OK
[   46.601616] Testing event ocfs2_complete_edge_insert: OK
[   46.622311] Testing event ocfs2_grow_tree: OK
[   46.641536] Testing event ocfs2_rotate_subtree: OK
[   46.657844] Testing event ocfs2_insert_extent: OK
[   46.673801] Testing event ocfs2_split_extent: OK
[   46.689498] Testing event ocfs2_remove_extent: OK
[   46.705478] Testing event ocfs2_commit_truncate: OK
[   46.721710] Testing event ocfs2_validate_extent_block: OK
[   46.737575] Testing event ocfs2_rotate_leaf: OK
[   46.759447] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   46.777547] Testing event ocfs2_mark_extent_written: OK
[   46.793477] Testing event ocfs2_truncate_log_append: OK
[   46.810044] Testing event ocfs2_replay_truncate_records: OK
[   46.830285] Testing event ocfs2_flush_truncate_log: OK
[   46.849418] Testing event ocfs2_begin_truncate_log_recovery: OK
[   46.865824] Testing event ocfs2_truncate_log_recovery_num: OK
[   46.885457] Testing event ocfs2_complete_truncate_log_recovery: OK
[   46.901521] Testing event ocfs2_free_cached_blocks: OK
[   46.917482] Testing event ocfs2_cache_cluster_dealloc: OK
[   46.933454] Testing event ocfs2_run_deallocs: OK
[   46.949335] Testing event ocfs2_cache_block_dealloc: OK
[   46.966306] Testing event ocfs2_trim_extent: OK
[   46.985451] Testing event ocfs2_trim_group: OK
[   47.001476] Testing event ocfs2_trim_fs: OK
[   47.017458] Testing event ocfs2_la_set_sizes: OK
[   47.033530] Testing event ocfs2_alloc_should_use_local: OK
[   47.049471] Testing event ocfs2_load_local_alloc: OK
[   47.065448] Testing event ocfs2_begin_local_alloc_recovery: OK
[   47.081495] Testing event ocfs2_reserve_local_alloc_bits: OK
[   47.097437] Testing event ocfs2_local_alloc_count_bits: OK
[   47.113388] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   47.129514] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   47.146220] Testing event ocfs2_sync_local_to_main: OK
[   47.166332] Testing event ocfs2_sync_local_to_main_free: OK
[   47.185432] Testing event ocfs2_local_alloc_new_window: OK
[   47.201473] Testing event ocfs2_local_alloc_new_window_result: OK
[   47.217495] Testing event ocfs2_update_last_group_and_inode: OK
[   47.233445] Testing event ocfs2_group_extend: OK
[   47.249410] Testing event ocfs2_group_add: OK
[   47.265378] Testing event ocfs2_validate_group_descriptor: OK
[   47.281738] Testing event ocfs2_block_group_alloc_contig: OK
[   47.297781] Testing event ocfs2_block_group_alloc_discontig: OK
[   47.317594] Testing event ocfs2_block_group_alloc: OK
[   47.333523] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   47.349628] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   47.365487] Testing event ocfs2_reserve_new_inode_new_group: OK
[   47.381613] Testing event ocfs2_block_group_set_bits: OK
[   47.397636] Testing event ocfs2_relink_block_group: OK
[   47.413535] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   47.429937] Testing event ocfs2_cluster_group_search_max_block: OK
[   47.446050] Testing event ocfs2_block_group_search_max_block: OK
[   47.465528] Testing event ocfs2_search_chain_begin: OK
[   47.481818] Testing event ocfs2_search_chain_succ: OK
[   47.497483] Testing event ocfs2_search_chain_end: OK
[   47.513709] Testing event ocfs2_claim_suballoc_bits: OK
[   47.529549] Testing event ocfs2_claim_new_inode_at_loc: OK
[   47.545734] Testing event ocfs2_block_group_clear_bits: OK
[   47.561421] Testing event ocfs2_free_suballoc_bits: OK
[   47.577575] Testing event ocfs2_free_clusters: OK
[   47.593585] Testing event ocfs2_get_suballoc_slot_bit: OK
[   47.609622] Testing event ocfs2_test_suballoc_bit: OK
[   47.625642] Testing event ocfs2_test_inode_bit: OK
[   47.641716] Testing event ocfs2_validate_refcount_block: OK
[   47.657569] Testing event ocfs2_purge_refcount_trees: OK
[   47.673414] Testing event ocfs2_create_refcount_tree: OK
[   47.689449] Testing event ocfs2_create_refcount_tree_blkno: OK
[   47.705463] Testing event ocfs2_change_refcount_rec: OK
[   47.721437] Testing event ocfs2_expand_inline_ref_root: OK
[   47.737387] Testing event ocfs2_divide_leaf_refcount_block: OK
[   47.753533] Testing event ocfs2_new_leaf_refcount_block: OK
[   47.769408] Testing event ocfs2_insert_refcount_rec: OK
[   47.786316] Testing event ocfs2_split_refcount_rec: OK
[   47.805598] Testing event ocfs2_split_refcount_rec_insert: OK
[   47.821412] Testing event ocfs2_increase_refcount_begin: OK
[   47.837416] Testing event ocfs2_increase_refcount_change: OK
[   47.853515] Testing event ocfs2_increase_refcount_insert: OK
[   47.869392] Testing event ocfs2_increase_refcount_split: OK
[   47.885398] Testing event ocfs2_remove_refcount_extent: OK
[   47.901461] Testing event ocfs2_restore_refcount_block: OK
[   47.917379] Testing event ocfs2_decrease_refcount_rec: OK
[   47.933371] Testing event ocfs2_decrease_refcount: OK
[   47.949396] Testing event ocfs2_mark_extent_refcounted: OK
[   47.965370] Testing event ocfs2_calc_refcount_meta_credits: OK
[   47.981391] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   47.997374] Testing event ocfs2_add_refcount_flag: OK
[   48.013383] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   48.029413] Testing event ocfs2_lock_refcount_allocators: OK
[   48.045277] Testing event ocfs2_duplicate_clusters_by_page: OK
[   48.062328] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   48.081586] Testing event ocfs2_clear_ext_refcount: OK
[   48.097392] Testing event ocfs2_replace_clusters: OK
[   48.113485] Testing event ocfs2_make_clusters_writable: OK
[   48.129507] Testing event ocfs2_refcount_cow_hunk: OK
[   48.145550] Testing event ocfs2_symlink_get_block: OK
[   48.161513] Testing event ocfs2_get_block: OK
[   48.177538] Testing event ocfs2_get_block_end: OK
[   48.193512] Testing event ocfs2_readpage: OK
[   48.209505] Testing event ocfs2_writepage: OK
[   48.225517] Testing event ocfs2_bmap: OK
[   48.241552] Testing event ocfs2_try_to_write_inline_data: OK
[   48.258240] Testing event ocfs2_write_begin_nolock: OK
[   48.278301] Testing event ocfs2_write_end_inline: OK
[   48.297635] Testing event ocfs2_fault: OK
[   48.314052] Testing event ocfs2_file_open: OK
[   48.329352] Testing event ocfs2_file_release: OK
[   48.345690] Testing event ocfs2_sync_file: OK
[   48.361591] Testing event ocfs2_file_aio_write: OK
[   48.377643] Testing event ocfs2_file_splice_write: OK
[   48.394130] Testing event ocfs2_file_splice_read: OK
[   48.409686] Testing event ocfs2_file_aio_read: OK
[   48.429718] Testing event ocfs2_truncate_file: OK
[   48.449598] Testing event ocfs2_truncate_file_error: OK
[   48.469432] Testing event ocfs2_extend_allocation: OK
[   48.489496] Testing event ocfs2_extend_allocation_end: OK
[   48.505427] Testing event ocfs2_write_zero_page: OK
[   48.521483] Testing event ocfs2_zero_extend_range: OK
[   48.537460] Testing event ocfs2_zero_extend: OK
[   48.553541] Testing event ocfs2_setattr: OK
[   48.569501] Testing event ocfs2_write_remove_suid: OK
[   48.585586] Testing event ocfs2_zero_partial_clusters: OK
[   48.601549] Testing event ocfs2_zero_partial_clusters_range1: OK
[   48.617395] Testing event ocfs2_zero_partial_clusters_range2: OK
[   48.633431] Testing event ocfs2_remove_inode_range: OK
[   48.649717] Testing event ocfs2_prepare_inode_for_write: OK
[   48.665500] Testing event generic_file_aio_read_ret: OK
[   48.682305] Testing event ocfs2_iget_begin: OK
[   48.702311] Testing event ocfs2_iget5_locked: OK
[   48.721863] Testing event ocfs2_iget_end: OK
[   48.737592] Testing event ocfs2_find_actor: OK
[   48.753805] Testing event ocfs2_populate_inode: OK
[   48.769575] Testing event ocfs2_read_locked_inode: OK
[   48.785541] Testing event ocfs2_check_orphan_recovery_state: OK
[   48.801815] Testing event ocfs2_validate_inode_block: OK
[   48.818053] Testing event ocfs2_inode_is_valid_to_delete: OK
[   48.839317] Testing event ocfs2_query_inode_wipe_begin: OK
[   48.858324] Testing event ocfs2_query_inode_wipe_succ: OK
[   48.877898] Testing event ocfs2_query_inode_wipe_end: OK
[   48.898138] Testing event ocfs2_cleanup_delete_inode: OK
[   48.918187] Testing event ocfs2_delete_inode: OK
[   48.937626] Testing event ocfs2_clear_inode: OK
[   48.954315] Testing event ocfs2_drop_inode: OK
[   48.973625] Testing event ocfs2_inode_revalidate: OK
[   48.989733] Testing event ocfs2_mark_inode_dirty: OK
[   49.006553] Testing event ocfs2_read_virt_blocks: OK
[   49.025561] Testing event ocfs2_refresh_slot_info: OK
[   49.042632] Testing event ocfs2_map_slot_buffers: OK
[   49.061751] Testing event ocfs2_map_slot_buffers_block: OK
[   49.077847] Testing event ocfs2_find_slot: OK
[   49.093816] Testing event ocfs2_do_node_down: OK
[   49.109764] Testing event ocfs2_remount: OK
[   49.125544] Testing event ocfs2_fill_super: OK
[   49.142569] Testing event ocfs2_parse_options: OK
[   49.161490] Testing event ocfs2_put_super: OK
[   49.177444] Testing event ocfs2_statfs: OK
[   49.194195] Testing event ocfs2_dismount_volume: OK
[   49.213943] Testing event ocfs2_initialize_super: OK
[   49.233790] Testing event ocfs2_validate_xattr_block: OK
[   49.253584] Testing event ocfs2_xattr_extend_allocation: OK
[   49.269659] Testing event ocfs2_init_xattr_set_ctxt: OK
[   49.285542] Testing event ocfs2_xattr_bucket_find: OK
[   49.301501] Testing event ocfs2_xattr_index_block_find: OK
[   49.317554] Testing event ocfs2_xattr_index_block_find_rec: OK
[   49.334318] Testing event ocfs2_iterate_xattr_buckets: OK
[   49.354363] Testing event ocfs2_iterate_xattr_bucket: OK
[   49.374208] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   49.394231] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   49.414394] Testing event ocfs2_xattr_create_index_block_begin: OK
[   49.433618] Testing event ocfs2_xattr_create_index_block: OK
[   49.449570] Testing event ocfs2_defrag_xattr_bucket: OK
[   49.465815] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   49.485405] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   49.502373] Testing event ocfs2_divide_xattr_bucket_move: OK
[   49.522316] Testing event ocfs2_cp_xattr_bucket: OK
[   49.541587] Testing event ocfs2_mv_xattr_buckets: OK
[   49.558319] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   49.577795] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   49.597825] Testing event ocfs2_add_new_xattr_cluster: OK
[   49.617767] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   49.638297] Testing event ocfs2_extend_xattr_bucket: OK
[   49.657728] Testing event ocfs2_add_new_xattr_bucket: OK
[   49.673712] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   49.689551] Testing event ocfs2_rm_xattr_cluster: OK
[   49.710416] Testing event ocfs2_reflink_xattr_header: OK
[   49.730213] Testing event ocfs2_create_empty_xattr_block: OK
[   49.750332] Testing event ocfs2_xattr_set_entry_bucket: OK
[   49.770338] Testing event ocfs2_xattr_set_entry_index_block: OK
[   49.789585] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   49.809764] Testing event ocfs2_reflink_xattr_buckets: OK
[   49.830454] Testing event ocfs2_reflink_xattr_rec: OK
[   49.855149] Testing event ocfs2_resv_insert: OK
[   49.874193] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   49.893846] Testing event ocfs2_resmap_find_free_bits_end: OK
[   49.914093] Testing event ocfs2_resv_find_window_begin: OK
[   49.935141] Testing event ocfs2_resv_find_window_prev: OK
[   49.953799] Testing event ocfs2_resv_find_window_next: OK
[   49.973519] Testing event ocfs2_cannibalize_resv_begin: OK
[   49.994031] Testing event ocfs2_cannibalize_resv_end: OK
[   50.013688] Testing event ocfs2_resmap_resv_bits: OK
[   50.030386] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   50.049532] Testing event ocfs2_resmap_claimed_bits_end: OK
[   50.066394] Testing event ocfs2_recover_local_quota_file: OK
[   50.086284] Testing event ocfs2_finish_quota_recovery: OK
[   50.105992] Testing event olq_set_dquot: OK
[   50.126387] Testing event ocfs2_validate_quota_block: OK
[   50.145531] Testing event ocfs2_sync_dquot: OK
[   50.162407] Testing event ocfs2_sync_dquot_helper: OK
[   50.181440] Testing event ocfs2_write_dquot: OK
[   50.197588] Testing event ocfs2_release_dquot: OK
[   50.213473] Testing event ocfs2_acquire_dquot: OK
[   50.234394] Testing event ocfs2_mark_dquot_dirty: OK
[   50.254458] Testing event ocfs2_search_dirblock: OK
[   50.273747] Testing event ocfs2_validate_dir_block: OK
[   50.289770] Testing event ocfs2_find_entry_el: OK
[   50.305600] Testing event ocfs2_dx_dir_search: OK
[   50.321558] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   50.337572] Testing event ocfs2_delete_entry_dx: OK
[   50.354560] Testing event ocfs2_readdir: OK
[   50.373576] Testing event ocfs2_find_files_on_disk: OK
[   50.393685] Testing event ocfs2_check_dir_for_entry: OK
[   50.410399] Testing event ocfs2_dx_dir_attach_index: OK
[   50.430127] Testing event ocfs2_dx_dir_format_cluster: OK
[   50.449613] Testing event ocfs2_dx_dir_index_root_block: OK
[   50.465492] Testing event ocfs2_extend_dir: OK
[   50.482414] Testing event ocfs2_dx_dir_rebalance: OK
[   50.501796] Testing event ocfs2_dx_dir_rebalance_split: OK
[   50.521867] Testing event ocfs2_prepare_dir_for_insert: OK
[   50.541589] Testing event ocfs2_lookup: OK
[   50.558308] Testing event ocfs2_mkdir: OK
[   50.578285] Testing event ocfs2_create: OK
[   50.598130] Testing event ocfs2_unlink: OK
[   50.618335] Testing event ocfs2_symlink_create: OK
[   50.637582] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   50.654360] Testing event ocfs2_lookup_ret: OK
[   50.674348] Testing event ocfs2_mknod: OK
[   50.694165] Testing event ocfs2_link: OK
[   50.714040] Testing event ocfs2_unlink_noent: OK
[   50.734324] Testing event ocfs2_double_lock: OK
[   50.754369] Testing event ocfs2_double_lock_end: OK
[   50.773405] Testing event ocfs2_rename: OK
[   50.789674] Testing event ocfs2_rename_target_exists: OK
[   50.805694] Testing event ocfs2_rename_disagree: OK
[   50.821661] Testing event ocfs2_rename_over_existing: OK
[   50.837493] Testing event ocfs2_create_symlink_data: OK
[   50.854350] Testing event ocfs2_symlink_begin: OK
[   50.874377] Testing event ocfs2_blkno_stringify: OK
[   50.893930] Testing event ocfs2_orphan_add_begin: OK
[   50.914392] Testing event ocfs2_orphan_add_end: OK
[   50.933573] Testing event ocfs2_orphan_del: OK
[   50.954309] Testing event ocfs2_dentry_revalidate: OK
[   50.973574] Testing event ocfs2_dentry_revalidate_negative: OK
[   50.989659] Testing event ocfs2_dentry_revalidate_delete: OK
[   51.005690] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   51.021576] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   51.038653] Testing event ocfs2_dentry_revalidate_ret: OK
[   51.058356] Testing event ocfs2_find_local_alias: OK
[   51.077675] Testing event ocfs2_dentry_attach_lock: OK
[   51.098908] Testing event ocfs2_dentry_attach_lock_found: OK
[   51.117786] Testing event ocfs2_get_dentry_begin: OK
[   51.134282] Testing event ocfs2_get_dentry_test_bit: OK
[   51.154038] Testing event ocfs2_get_dentry_stale: OK
[   51.173804] Testing event ocfs2_get_dentry_generation: OK
[   51.189890] Testing event ocfs2_get_dentry_end: OK
[   51.206197] Testing event ocfs2_get_parent: OK
[   51.225438] Testing event ocfs2_get_parent_end: OK
[   51.241724] Testing event ocfs2_encode_fh_begin: OK
[   51.257780] Testing event ocfs2_encode_fh_self: OK
[   51.273533] Testing event ocfs2_encode_fh_parent: OK
[   51.293495] Testing event ocfs2_encode_fh_type: OK
[   51.310280] Testing event ocfs2_commit_cache_begin: OK
[   51.330414] Testing event ocfs2_commit_cache_end: OK
[   51.349578] Testing event ocfs2_extend_trans: OK
[   51.370271] Testing event ocfs2_extend_trans_restart: OK
[   51.389545] Testing event ocfs2_journal_access: OK
[   51.405630] Testing event ocfs2_journal_dirty: OK
[   51.421538] Testing event ocfs2_journal_init: OK
[   51.438228] Testing event ocfs2_journal_init_maxlen: OK
[   51.457526] Testing event ocfs2_journal_shutdown: OK
[   51.474438] Testing event ocfs2_journal_shutdown_wait: OK
[   51.494473] Testing event ocfs2_complete_recovery: OK
[   51.514378] Testing event ocfs2_complete_recovery_end: OK
[   51.533655] Testing event ocfs2_complete_recovery_slot: OK
[   51.549684] Testing event ocfs2_recovery_thread_node: OK
[   51.565620] Testing event ocfs2_recovery_thread_end: OK
[   51.582307] Testing event ocfs2_recovery_thread: OK
[   51.602398] Testing event ocfs2_replay_journal_recovered: OK
[   51.621602] Testing event ocfs2_replay_journal_lock_err: OK
[   51.637663] Testing event ocfs2_replay_journal_skip: OK
[   51.658794] Testing event ocfs2_recover_node: OK
[   51.677547] Testing event ocfs2_recover_node_skip: OK
[   51.694181] Testing event ocfs2_mark_dead_nodes: OK
[   51.713678] Testing event ocfs2_queue_orphan_scan_begin: OK
[   51.729789] Testing event ocfs2_queue_orphan_scan_end: OK
[   51.749479] Testing event ocfs2_orphan_filldir: OK
[   51.765660] Testing event ocfs2_recover_orphans: OK
[   51.786475] Testing event ocfs2_recover_orphans_iput: OK
[   51.805671] Testing event ocfs2_wait_on_mount: OK
[   51.822460] Testing event ocfs2_read_blocks_sync: OK
[   51.842416] Testing event ocfs2_read_blocks_sync_jbd: OK
[   51.861529] Testing event ocfs2_read_blocks_from_disk: OK
[   51.878320] Testing event ocfs2_read_blocks_bh: OK
[   51.898239] Testing event ocfs2_read_blocks_end: OK
[   51.918360] Testing event ocfs2_write_block: OK
[   51.938315] Testing event ocfs2_read_blocks_begin: OK
[   51.958002] Testing event ocfs2_purge_copied_metadata_tree: OK
[   51.978139] Testing event ocfs2_metadata_cache_purge: OK
[   51.998362] Testing event ocfs2_buffer_cached_begin: OK
[   52.017739] Testing event ocfs2_buffer_cached_end: OK
[   52.033682] Testing event ocfs2_append_cache_array: OK
[   52.049731] Testing event ocfs2_insert_cache_tree: OK
[   52.065865] Testing event ocfs2_expand_cache: OK
[   52.081738] Testing event ocfs2_set_buffer_uptodate: OK
[   52.098309] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   52.117582] Testing event ocfs2_remove_metadata_array: OK
[   52.138268] Testing event ocfs2_remove_metadata_tree: OK
[   52.158246] Testing event ocfs2_remove_block_from_cache: OK
[   52.177995] Testing event xfs_attr_list_sf: OK
[   52.198269] Testing event xfs_attr_list_sf_all: OK
[   52.218275] Testing event xfs_attr_list_leaf: OK
[   52.238288] Testing event xfs_attr_list_leaf_end: OK
[   52.257556] Testing event xfs_attr_list_full: OK
[   52.277851] Testing event xfs_attr_list_add: OK
[   52.294433] Testing event xfs_attr_list_wrong_blk: OK
[   52.314241] Testing event xfs_attr_list_notfound: OK
[   52.333685] Testing event xfs_perag_get: OK
[   52.349463] Testing event xfs_perag_get_tag: OK
[   52.365443] Testing event xfs_perag_put: OK
[   52.381388] Testing event xfs_perag_set_reclaim: OK
[   52.397468] Testing event xfs_perag_clear_reclaim: OK
[   52.413872] Testing event xfs_attr_list_node_descend: OK
[   52.429524] Testing event xfs_iext_insert: OK
[   52.446034] Testing event xfs_iext_remove: OK
[   52.461416] Testing event xfs_bmap_pre_update: OK
[   52.477574] Testing event xfs_bmap_post_update: OK
[   52.493592] Testing event xfs_extlist: OK
[   52.509580] Testing event xfs_buf_init: OK
[   52.525546] Testing event xfs_buf_free: OK
[   52.541610] Testing event xfs_buf_hold: OK
[   52.557516] Testing event xfs_buf_rele: OK
[   52.573438] Testing event xfs_buf_iodone: OK
[   52.589581] Testing event xfs_buf_iorequest: OK
[   52.605402] Testing event xfs_buf_bawrite: OK
[   52.621539] Testing event xfs_buf_lock: OK
[   52.637561] Testing event xfs_buf_lock_done: OK
[   52.653495] Testing event xfs_buf_trylock: OK
[   52.669367] Testing event xfs_buf_unlock: OK
[   52.685798] Testing event xfs_buf_iowait: OK
[   52.701520] Testing event xfs_buf_iowait_done: OK
[   52.717544] Testing event xfs_buf_delwri_queue: OK
[   52.734362] Testing event xfs_buf_delwri_queued: OK
[   52.753491] Testing event xfs_buf_delwri_split: OK
[   52.770378] Testing event xfs_buf_get_uncached: OK
[   52.789669] Testing event xfs_bdstrat_shut: OK
[   52.805655] Testing event xfs_buf_item_relse: OK
[   52.822569] Testing event xfs_buf_item_iodone: OK
[   52.841649] Testing event xfs_buf_item_iodone_async: OK
[   52.858091] Testing event xfs_buf_error_relse: OK
[   52.878533] Testing event xfs_trans_read_buf_io: OK
[   52.898473] Testing event xfs_trans_read_buf_shut: OK
[   52.919131] Testing event xfs_btree_corrupt: OK
[   52.937910] Testing event xfs_da_btree_corrupt: OK
[   52.958297] Testing event xfs_reset_dqcounts: OK
[   52.978430] Testing event xfs_inode_item_push: OK
[   52.998334] Testing event xfs_buf_find: OK
[   53.017646] Testing event xfs_buf_get: OK
[   53.034337] Testing event xfs_buf_read: OK
[   53.054316] Testing event xfs_buf_ioerror: OK
[   53.074400] Testing event xfs_buf_item_size: OK
[   53.094303] Testing event xfs_buf_item_size_stale: OK
[   53.114235] Testing event xfs_buf_item_format: OK
[   53.142744] Testing event xfs_buf_item_format_stale: OK
[   53.162439] Testing event xfs_buf_item_pin: OK
[   53.182539] Testing event xfs_buf_item_unpin: OK
[   53.202210] Testing event xfs_buf_item_unpin_stale: OK
[   53.222377] Testing event xfs_buf_item_unlock: OK
[   53.241500] Testing event xfs_buf_item_unlock_stale: OK
[   53.257620] Testing event xfs_buf_item_committed: OK
[   53.273491] Testing event xfs_buf_item_push: OK
[   53.290352] Testing event xfs_trans_get_buf: OK
[   53.309617] Testing event xfs_trans_get_buf_recur: OK
[   53.325417] Testing event xfs_trans_getsb: OK
[   53.342348] Testing event xfs_trans_getsb_recur: OK
[   53.362397] Testing event xfs_trans_read_buf: OK
[   53.382324] Testing event xfs_trans_read_buf_recur: OK
[   53.401510] Testing event xfs_trans_log_buf: OK
[   53.418302] Testing event xfs_trans_brelse: OK
[   53.438243] Testing event xfs_trans_bjoin: OK
[   53.457692] Testing event xfs_trans_bhold: OK
[   53.473441] Testing event xfs_trans_bhold_release: OK
[   53.494364] Testing event xfs_trans_binval: OK
[   53.513531] Testing event xfs_ilock: OK
[   53.530259] Testing event xfs_ilock_nowait: OK
[   53.550312] Testing event xfs_ilock_demote: OK
[   53.570346] Testing event xfs_iunlock: OK
[   53.590405] Testing event xfs_iget_skip: OK
[   53.609794] Testing event xfs_iget_reclaim: OK
[   53.625743] Testing event xfs_iget_reclaim_fail: OK
[   53.642308] Testing event xfs_iget_hit: OK
[   53.662418] Testing event xfs_iget_miss: OK
[   53.682383] Testing event xfs_getattr: OK
[   53.702344] Testing event xfs_setattr: OK
[   53.721471] Testing event xfs_readlink: OK
[   53.737462] Testing event xfs_alloc_file_space: OK
[   53.753519] Testing event xfs_free_file_space: OK
[   53.769339] Testing event xfs_readdir: OK
[   53.785356] Testing event xfs_get_acl: OK
[   53.801589] Testing event xfs_vm_bmap: OK
[   53.818744] Testing event xfs_file_ioctl: OK
[   53.838303] Testing event xfs_file_compat_ioctl: OK
[   53.857902] Testing event xfs_ioctl_setattr: OK
[   53.873393] Testing event xfs_dir_fsync: OK
[   53.889690] Testing event xfs_file_fsync: OK
[   53.905808] Testing event xfs_destroy_inode: OK
[   53.923549] Testing event xfs_evict_inode: OK
[   53.942443] Testing event xfs_update_time: OK
[   53.962398] Testing event xfs_dquot_dqalloc: OK
[   53.981862] Testing event xfs_dquot_dqdetach: OK
[   53.998387] Testing event xfs_ihold: OK
[   54.018383] Testing event xfs_irele: OK
[   54.038453] Testing event xfs_inode_pin: OK
[   54.057557] Testing event xfs_inode_unpin: OK
[   54.073542] Testing event xfs_inode_unpin_nowait: OK
[   54.089657] Testing event xfs_remove: OK
[   54.105442] Testing event xfs_link: OK
[   54.122360] Testing event xfs_lookup: OK
[   54.141501] Testing event xfs_create: OK
[   54.158440] Testing event xfs_symlink: OK
[   54.177797] Testing event xfs_rename: OK
[   54.198499] Testing event xfs_dqadjust: OK
[   54.218194] Testing event xfs_dqreclaim_want: OK
[   54.238425] Testing event xfs_dqreclaim_dirty: OK
[   54.258273] Testing event xfs_dqreclaim_busy: OK
[   54.277927] Testing event xfs_dqreclaim_done: OK
[   54.298506] Testing event xfs_dqattach_found: OK
[   54.318375] Testing event xfs_dqattach_get: OK
[   54.337598] Testing event xfs_dqalloc: OK
[   54.358386] Testing event xfs_dqtobp_read: OK
[   54.378430] Testing event xfs_dqread: OK
[   54.397848] Testing event xfs_dqread_fail: OK
[   54.414370] Testing event xfs_dqget_hit: OK
[   54.433640] Testing event xfs_dqget_miss: OK
[   54.450425] Testing event xfs_dqget_freeing: OK
[   54.470120] Testing event xfs_dqget_dup: OK
[   54.486341] Testing event xfs_dqput: OK
[   54.506475] Testing event xfs_dqput_wait: OK
[   54.526399] Testing event xfs_dqput_free: OK
[   54.545534] Testing event xfs_dqrele: OK
[   54.561434] Testing event xfs_dqflush: OK
[   54.578357] Testing event xfs_dqflush_force: OK
[   54.598585] Testing event xfs_dqflush_done: OK
[   54.618372] Testing event xfs_log_done_nonperm: OK
[   54.638432] Testing event xfs_log_done_perm: OK
[   54.658354] Testing event xfs_log_umount_write: OK
[   54.678458] Testing event xfs_log_grant_sleep: OK
[   54.698039] Testing event xfs_log_grant_wake: OK
[   54.718419] Testing event xfs_log_grant_wake_up: OK
[   54.738221] Testing event xfs_log_reserve: OK
[   54.758445] Testing event xfs_log_reserve_exit: OK
[   54.777847] Testing event xfs_log_regrant: OK
[   54.798301] Testing event xfs_log_regrant_exit: OK
[   54.817842] Testing event xfs_log_regrant_reserve_enter: OK
[   54.833495] Testing event xfs_log_regrant_reserve_exit: OK
[   54.849893] Testing event xfs_log_regrant_reserve_sub: OK
[   54.865604] Testing event xfs_log_ungrant_enter: OK
[   54.886995] Testing event xfs_log_ungrant_exit: OK
[   54.906944] Testing event xfs_log_ungrant_sub: OK
[   54.926509] Testing event xfs_log_force: OK
[   54.946399] Testing event xfs_ail_push: OK
[   54.966375] Testing event xfs_ail_pinned: OK
[   54.986476] Testing event xfs_ail_locked: OK
[   55.006463] Testing event xfs_ail_flushing: OK
[   55.026493] Testing event xfs_file_read: OK
[   55.046541] Testing event xfs_file_buffered_write: OK
[   55.066482] Testing event xfs_file_direct_write: OK
[   55.086448] Testing event xfs_file_splice_read: OK
[   55.106492] Testing event xfs_file_splice_write: OK
[   55.126516] Testing event xfs_writepage: OK
[   55.146369] Testing event xfs_releasepage: OK
[   55.166422] Testing event xfs_invalidatepage: OK
[   55.186393] Testing event xfs_map_blocks_found: OK
[   55.206427] Testing event xfs_map_blocks_alloc: OK
[   55.226479] Testing event xfs_get_blocks_found: OK
[   55.245839] Testing event xfs_get_blocks_alloc: OK
[   55.265801] Testing event xfs_delalloc_enospc: OK
[   55.285533] Testing event xfs_unwritten_convert: OK
[   55.302407] Testing event xfs_get_blocks_notfound: OK
[   55.321613] Testing event xfs_setfilesize: OK
[   55.341657] Testing event xfs_itruncate_extents_start: OK
[   55.362316] Testing event xfs_itruncate_extents_end: OK
[   55.382448] Testing event xfs_pagecache_inval: OK
[   55.402358] Testing event xfs_bunmap: OK
[   55.422373] Testing event xfs_extent_busy: OK
[   55.442654] Testing event xfs_extent_busy_enomem: OK
[   55.462378] Testing event xfs_extent_busy_force: OK
[   55.482659] Testing event xfs_extent_busy_reuse: OK
[   55.502060] Testing event xfs_extent_busy_clear: OK
[   55.522409] Testing event xfs_extent_busy_trim: OK
[   55.541559] Testing event xfs_trans_commit_lsn: OK
[   55.558482] Testing event xfs_agf: OK
[   55.578392] Testing event xfs_free_extent: OK
[   55.597961] Testing event xfs_alloc_exact_done: OK
[   55.618508] Testing event xfs_alloc_exact_notfound: OK
[   55.637573] Testing event xfs_alloc_exact_error: OK
[   55.653971] Testing event xfs_alloc_near_nominleft: OK
[   55.673913] Testing event xfs_alloc_near_first: OK
[   55.690448] Testing event xfs_alloc_near_greater: OK
[   55.709893] Testing event xfs_alloc_near_lesser: OK
[   55.730451] Testing event xfs_alloc_near_error: OK
[   55.750569] Testing event xfs_alloc_near_noentry: OK
[   55.770399] Testing event xfs_alloc_near_busy: OK
[   55.790494] Testing event xfs_alloc_size_neither: OK
[   55.809557] Testing event xfs_alloc_size_noentry: OK
[   55.826335] Testing event xfs_alloc_size_nominleft: OK
[   55.845628] Testing event xfs_alloc_size_done: OK
[   55.862115] Testing event xfs_alloc_size_error: OK
[   55.882490] Testing event xfs_alloc_size_busy: OK
[   55.902471] Testing event xfs_alloc_small_freelist: OK
[   55.922368] Testing event xfs_alloc_small_notenough: OK
[   55.941661] Testing event xfs_alloc_small_done: OK
[   55.957744] Testing event xfs_alloc_small_error: OK
[   55.978425] Testing event xfs_alloc_vextent_badargs: OK
[   55.997793] Testing event xfs_alloc_vextent_nofix: OK
[   56.014370] Testing event xfs_alloc_vextent_noagbp: OK
[   56.033561] Testing event xfs_alloc_vextent_loopfailed: OK
[   56.050368] Testing event xfs_alloc_vextent_allfailed: OK
[   56.070280] Testing event xfs_dir2_sf_addname: OK
[   56.090388] Testing event xfs_dir2_sf_create: OK
[   56.110228] Testing event xfs_dir2_sf_lookup: OK
[   56.129668] Testing event xfs_dir2_sf_replace: OK
[   56.146190] Testing event xfs_dir2_sf_removename: OK
[   56.166504] Testing event xfs_dir2_sf_toino4: OK
[   56.186538] Testing event xfs_dir2_sf_toino8: OK
[   56.206385] Testing event xfs_dir2_sf_to_block: OK
[   56.225583] Testing event xfs_dir2_block_addname: OK
[   56.246280] Testing event xfs_dir2_block_lookup: OK
[   56.266455] Testing event xfs_dir2_block_replace: OK
[   56.286371] Testing event xfs_dir2_block_removename: OK
[   56.305655] Testing event xfs_dir2_block_to_sf: OK
[   56.322365] Testing event xfs_dir2_block_to_leaf: OK
[   56.342432] Testing event xfs_dir2_leaf_addname: OK
[   56.362527] Testing event xfs_dir2_leaf_lookup: OK
[   56.382178] Testing event xfs_dir2_leaf_replace: OK
[   56.402315] Testing event xfs_dir2_leaf_removename: OK
[   56.421574] Testing event xfs_dir2_leaf_to_block: OK
[   56.437552] Testing event xfs_dir2_leaf_to_node: OK
[   56.454398] Testing event xfs_dir2_node_addname: OK
[   56.474240] Testing event xfs_dir2_node_lookup: OK
[   56.494162] Testing event xfs_dir2_node_replace: OK
[   56.514233] Testing event xfs_dir2_node_removename: OK
[   56.534326] Testing event xfs_dir2_node_to_leaf: OK
[   56.561760] Testing event xfs_attr_sf_add: OK
[   56.581815] Testing event xfs_attr_sf_addname: OK
[   56.602293] Testing event xfs_attr_sf_create: OK
[   56.621637] Testing event xfs_attr_sf_lookup: OK
[   56.637653] Testing event xfs_attr_sf_remove: OK
[   56.654307] Testing event xfs_attr_sf_removename: OK
[   56.674313] Testing event xfs_attr_sf_to_leaf: OK
[   56.694410] Testing event xfs_attr_leaf_add: OK
[   56.714292] Testing event xfs_attr_leaf_add_old: OK
[   56.734430] Testing event xfs_attr_leaf_add_new: OK
[   56.754053] Testing event xfs_attr_leaf_addname: OK
[   56.774269] Testing event xfs_attr_leaf_create: OK
[   56.794532] Testing event xfs_attr_leaf_lookup: OK
[   56.813935] Testing event xfs_attr_leaf_replace: OK
[   56.830298] Testing event xfs_attr_leaf_removename: OK
[   56.850414] Testing event xfs_attr_leaf_split: OK
[   56.870204] Testing event xfs_attr_leaf_split_before: OK
[   56.889632] Testing event xfs_attr_leaf_split_after: OK
[   56.909626] Testing event xfs_attr_leaf_clearflag: OK
[   56.930452] Testing event xfs_attr_leaf_setflag: OK
[   56.950424] Testing event xfs_attr_leaf_flipflags: OK
[   56.969642] Testing event xfs_attr_leaf_to_sf: OK
[   56.990325] Testing event xfs_attr_leaf_to_node: OK
[   57.010305] Testing event xfs_attr_leaf_rebalance: OK
[   57.030322] Testing event xfs_attr_leaf_unbalance: OK
[   57.049716] Testing event xfs_attr_node_addname: OK
[   57.070238] Testing event xfs_attr_node_lookup: OK
[   57.090394] Testing event xfs_attr_node_replace: OK
[   57.110434] Testing event xfs_attr_node_removename: OK
[   57.130356] Testing event xfs_da_split: OK
[   57.150369] Testing event xfs_da_join: OK
[   57.169564] Testing event xfs_da_link_before: OK
[   57.186353] Testing event xfs_da_link_after: OK
[   57.206371] Testing event xfs_da_unlink_back: OK
[   57.226301] Testing event xfs_da_unlink_forward: OK
[   57.246344] Testing event xfs_da_root_split: OK
[   57.266387] Testing event xfs_da_root_join: OK
[   57.286470] Testing event xfs_da_node_add: OK
[   57.306496] Testing event xfs_da_node_create: OK
[   57.325663] Testing event xfs_da_node_split: OK
[   57.342262] Testing event xfs_da_node_remove: OK
[   57.362427] Testing event xfs_da_node_rebalance: OK
[   57.382374] Testing event xfs_da_node_unbalance: OK
[   57.402272] Testing event xfs_da_swap_lastblock: OK
[   57.422291] Testing event xfs_da_grow_inode: OK
[   57.442256] Testing event xfs_da_shrink_inode: OK
[   57.461533] Testing event xfs_dir2_leafn_add: OK
[   57.481521] Testing event xfs_dir2_leafn_remove: OK
[   57.498323] Testing event xfs_dir2_grow_inode: OK
[   57.517653] Testing event xfs_dir2_shrink_inode: OK
[   57.538320] Testing event xfs_dir2_leafn_moveents: OK
[   57.557774] Testing event xfs_swap_extent_before: OK
[   57.577588] Testing event xfs_swap_extent_after: OK
[   57.593558] Testing event xfs_log_recover_item_add: OK
[   57.610234] Testing event xfs_log_recover_item_add_cont: OK
[   57.629640] Testing event xfs_log_recover_item_reorder_head: OK
[   57.645517] Testing event xfs_log_recover_item_reorder_tail: OK
[   57.662286] Testing event xfs_log_recover_item_recover: OK
[   57.681620] Testing event xfs_log_recover_buf_not_cancel: OK
[   57.697626] Testing event xfs_log_recover_buf_cancel: OK
[   57.713439] Testing event xfs_log_recover_buf_cancel_add: OK
[   57.729446] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   57.745507] Testing event xfs_log_recover_buf_recover: OK
[   57.761407] Testing event xfs_log_recover_buf_inode_buf: OK
[   57.777610] Testing event xfs_log_recover_buf_reg_buf: OK
[   57.793409] Testing event xfs_log_recover_buf_dquot_buf: OK
[   57.809413] Testing event xfs_log_recover_inode_recover: OK
[   57.825400] Testing event xfs_log_recover_inode_cancel: OK
[   57.841470] Testing event xfs_log_recover_inode_skip: OK
[   57.858470] Testing event xfs_discard_extent: OK
[   57.877529] Testing event xfs_discard_toosmall: OK
[   57.894357] Testing event xfs_discard_exclude: OK
[   57.913384] Testing event xfs_discard_busy: OK
[   57.930464] Testing event jbd2_checkpoint: OK
[   57.950367] Testing event jbd2_start_commit: OK
[   57.969495] Testing event jbd2_commit_locking: OK
[   57.986367] Testing event jbd2_commit_flushing: OK
[   58.005595] Testing event jbd2_commit_logging: OK
[   58.026275] Testing event jbd2_drop_transaction: OK
[   58.045647] Testing event jbd2_end_commit: OK
[   58.066441] Testing event jbd2_submit_inode_data: OK
[   58.086359] Testing event jbd2_run_stats: OK
[   58.106439] Testing event jbd2_checkpoint_stats: OK
[   58.125690] Testing event jbd2_update_log_tail: OK
[   58.145671] Testing event jbd2_write_superblock: OK
[   58.165568] Testing event jbd_checkpoint: OK
[   58.182355] Testing event jbd_start_commit: OK
[   58.202390] Testing event jbd_commit_locking: OK
[   58.222433] Testing event jbd_commit_flushing: OK
[   58.241555] Testing event jbd_commit_logging: OK
[   58.258405] Testing event jbd_drop_transaction: OK
[   58.277823] Testing event jbd_end_commit: OK
[   58.294285] Testing event jbd_do_submit_data: OK
[   58.313829] Testing event jbd_cleanup_journal_tail: OK
[   58.333981] Testing event journal_write_superblock: OK
[   58.354313] Testing event ext4_free_inode: OK
[   58.374401] Testing event ext4_request_inode: OK
[   58.394416] Testing event ext4_allocate_inode: OK
[   58.414399] Testing event ext4_evict_inode: OK
[   58.434560] Testing event ext4_drop_inode: OK
[   58.454435] Testing event ext4_mark_inode_dirty: OK
[   58.474277] Testing event ext4_begin_ordered_truncate: OK
[   58.494442] Testing event ext4_write_begin: OK
[   58.514303] Testing event ext4_da_write_begin: OK
[   58.534361] Testing event ext4_ordered_write_end: OK
[   58.554363] Testing event ext4_writeback_write_end: OK
[   58.574300] Testing event ext4_journalled_write_end: OK
[   58.593800] Testing event ext4_da_write_end: OK
[   58.610419] Testing event ext4_da_writepages: OK
[   58.630295] Testing event ext4_da_write_pages: OK
[   58.650227] Testing event ext4_da_writepages_result: OK
[   58.669741] Testing event ext4_writepage: OK
[   58.687182] Testing event ext4_readpage: OK
[   58.705494] Testing event ext4_releasepage: OK
[   58.722546] Testing event ext4_invalidatepage: OK
[   58.741567] Testing event ext4_discard_blocks: OK
[   58.757540] Testing event ext4_mb_new_inode_pa: OK
[   58.774364] Testing event ext4_mb_new_group_pa: OK
[   58.793619] Testing event ext4_mb_release_inode_pa: OK
[   58.809677] Testing event ext4_mb_release_group_pa: OK
[   58.826312] Testing event ext4_discard_preallocations: OK
[   58.846392] Testing event ext4_mb_discard_preallocations: OK
[   58.866490] Testing event ext4_request_blocks: OK
[   58.886432] Testing event ext4_allocate_blocks: OK
[   58.906393] Testing event ext4_free_blocks: OK
[   58.926442] Testing event ext4_sync_file_enter: OK
[   58.946481] Testing event ext4_sync_file_exit: OK
[   58.965972] Testing event ext4_sync_fs: OK
[   58.982164] Testing event ext4_alloc_da_blocks: OK
[   59.002041] Testing event ext4_mballoc_alloc: OK
[   59.021468] Testing event ext4_mballoc_prealloc: OK
[   59.037571] Testing event ext4_mballoc_discard: OK
[   59.054272] Testing event ext4_mballoc_free: OK
[   59.074390] Testing event ext4_forget: OK
[   59.094341] Testing event ext4_da_update_reserve_space: OK
[   59.113554] Testing event ext4_da_reserve_space: OK
[   59.133714] Testing event ext4_da_release_space: OK
[   59.153550] Testing event ext4_mb_bitmap_load: OK
[   59.173487] Testing event ext4_mb_buddy_bitmap_load: OK
[   59.190275] Testing event ext4_read_block_bitmap_load: OK
[   59.209614] Testing event ext4_load_inode_bitmap: OK
[   59.225561] Testing event ext4_direct_IO_enter: OK
[   59.241559] Testing event ext4_direct_IO_exit: OK
[   59.257667] Testing event ext4_fallocate_enter: OK
[   59.273721] Testing event ext4_fallocate_exit: OK
[   59.293397] Testing event ext4_unlink_enter: OK
[   59.309423] Testing event ext4_unlink_exit: OK
[   59.325572] Testing event ext4_truncate_enter: OK
[   59.342322] Testing event ext4_truncate_exit: OK
[   59.362342] Testing event ext4_ext_convert_to_initialized_enter: OK
[   59.381782] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   59.402318] Testing event ext4_ext_map_blocks_enter: OK
[   59.421533] Testing event ext4_ind_map_blocks_enter: OK
[   59.438321] Testing event ext4_ext_map_blocks_exit: OK
[   59.457498] Testing event ext4_ind_map_blocks_exit: OK
[   59.474335] Testing event ext4_ext_load_extent: OK
[   59.494410] Testing event ext4_load_inode: OK
[   59.514376] Testing event ext4_journal_start: OK
[   59.533796] Testing event ext4_trim_extent: OK
[   59.553671] Testing event ext4_trim_all_free: OK
[   59.569684] Testing event ext4_ext_handle_uninitialized_extents: OK
[   59.585505] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   59.601475] Testing event ext4_ext_put_in_cache: OK
[   59.617578] Testing event ext4_ext_in_cache: OK
[   59.633847] Testing event ext4_find_delalloc_range: OK
[   59.649517] Testing event ext4_get_reserved_cluster_alloc: OK
[   59.665847] Testing event ext4_ext_show_extent: OK
[   59.681549] Testing event ext4_remove_blocks: OK
[   59.697849] Testing event ext4_ext_rm_leaf: OK
[   59.713542] Testing event ext4_ext_rm_idx: OK
[   59.729544] Testing event ext4_ext_remove_space: OK
[   59.745826] Testing event ext4_ext_remove_space_done: OK
[   59.761524] Testing event ext3_free_inode: OK
[   59.777874] Testing event ext3_request_inode: OK
[   59.793591] Testing event ext3_allocate_inode: OK
[   59.809860] Testing event ext3_evict_inode: OK
[   59.825691] Testing event ext3_drop_inode: OK
[   59.842004] Testing event ext3_mark_inode_dirty: OK
[   59.861621] Testing event ext3_write_begin: OK
[   59.877505] Testing event ext3_ordered_write_end: OK
[   59.899120] Testing event ext3_writeback_write_end: OK
[   59.917893] Testing event ext3_journalled_write_end: OK
[   59.937684] Testing event ext3_ordered_writepage: OK
[   59.953664] Testing event ext3_writeback_writepage: OK
[   59.973545] Testing event ext3_journalled_writepage: OK
[   59.994266] Testing event ext3_readpage: OK
[   60.013970] Testing event ext3_releasepage: OK
[   60.029593] Testing event ext3_invalidatepage: OK
[   60.045486] Testing event ext3_discard_blocks: OK
[   60.061767] Testing event ext3_request_blocks: OK
[   60.077715] Testing event ext3_allocate_blocks: OK
[   60.094473] Testing event ext3_free_blocks: OK
[   60.114426] Testing event ext3_sync_file_enter: OK
[   60.134546] Testing event ext3_sync_file_exit: OK
[   60.154449] Testing event ext3_sync_fs: OK
[   60.174435] Testing event ext3_rsv_window_add: OK
[   60.194466] Testing event ext3_discard_reservation: OK
[   60.214406] Testing event ext3_alloc_new_reservation: OK
[   60.233884] Testing event ext3_reserved: OK
[   60.250435] Testing event ext3_forget: OK
[   60.269547] Testing event ext3_read_block_bitmap: OK
[   60.285508] Testing event ext3_direct_IO_enter: OK
[   60.302511] Testing event ext3_direct_IO_exit: OK
[   60.321856] Testing event ext3_unlink_enter: OK
[   60.337668] Testing event ext3_unlink_exit: OK
[   60.353926] Testing event ext3_truncate_enter: OK
[   60.369540] Testing event ext3_truncate_exit: OK
[   60.385772] Testing event ext3_get_blocks_enter: OK
[   60.402591] Testing event ext3_get_blocks_exit: OK
[   60.421569] Testing event ext3_load_inode: OK
[   60.438445] Testing event writeback_nothread: OK
[   60.458490] Testing event writeback_queue: OK
[   60.477946] Testing event writeback_exec: OK
[   60.493566] Testing event writeback_start: OK
[   60.510300] Testing event writeback_written: OK
[   60.530410] Testing event writeback_wait: OK
[   60.550325] Testing event writeback_pages_written: OK
[   60.570535] Testing event writeback_nowork: OK
[   60.590374] Testing event writeback_wake_background: OK
[   60.610385] Testing event writeback_wake_thread: OK
[   60.630375] Testing event writeback_wake_forker_thread: OK
[   60.650356] Testing event writeback_bdi_register: OK
[   60.669599] Testing event writeback_bdi_unregister: OK
[   60.686472] Testing event writeback_thread_start: OK
[   60.706377] Testing event writeback_thread_stop: OK
[   60.726412] Testing event wbc_writepage: OK
[   60.745724] Testing event writeback_queue_io: OK
[   60.761584] Testing event global_dirty_state: OK
[   60.777700] Testing event bdi_dirty_ratelimit: OK
[   60.793789] Testing event balance_dirty_pages: OK
[   60.809520] Testing event writeback_sb_inodes_requeue: OK
[   60.826424] Testing event writeback_congestion_wait: OK
[   60.846363] Testing event writeback_wait_iff_congested: OK
[   60.866271] Testing event writeback_single_inode: OK
[   60.886354] Testing event mm_compaction_isolate_migratepages: OK
[   60.906316] Testing event mm_compaction_isolate_freepages: OK
[   60.926331] Testing event mm_compaction_migratepages: OK
[   60.946346] Testing event kmalloc: OK
[   60.966366] Testing event kmem_cache_alloc: OK
[   60.986337] Testing event kmalloc_node: OK
[   61.007061] Testing event kmem_cache_alloc_node: OK
[   61.027299] Testing event kfree: OK
[   61.050374] Testing event kmem_cache_free: OK
[   61.070610] Testing event mm_page_free: OK
[   61.090376] Testing event mm_page_free_batched: OK
[   61.110412] Testing event mm_page_alloc: OK
[   61.130306] Testing event mm_page_alloc_zone_locked: OK
[   61.150366] Testing event mm_page_pcpu_drain: OK
[   61.170290] Testing event mm_page_alloc_extfrag: OK
[   61.190353] Testing event mm_vmscan_kswapd_sleep: OK
[   61.210417] Testing event mm_vmscan_kswapd_wake: OK
[   61.230453] Testing event mm_vmscan_wakeup_kswapd: OK
[   61.250399] Testing event mm_vmscan_direct_reclaim_begin: OK
[   61.270400] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   61.290502] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   61.310480] Testing event mm_vmscan_direct_reclaim_end: OK
[   61.330571] Testing event mm_vmscan_memcg_reclaim_end: OK
[   61.350430] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   61.370307] Testing event mm_shrink_slab_start: OK
[   61.390486] Testing event mm_shrink_slab_end: OK
[   61.410498] Testing event mm_vmscan_lru_isolate: OK
[   61.430532] Testing event mm_vmscan_memcg_isolate: OK
[   61.450512] Testing event mm_vmscan_writepage: OK
[   61.470346] Testing event mm_vmscan_lru_shrink_inactive: OK
[   61.490515] Testing event oom_score_adj_update: OK
[   61.510471] Testing event rpm_suspend: OK
[   61.530455] Testing event rpm_resume: OK
[   61.550428] Testing event rpm_idle: OK
[   61.570327] Testing event rpm_return_int: OK
[   61.590550] Testing event cpu_idle: OK
[   61.610506] Testing event cpu_frequency: OK
[   61.630492] Testing event machine_suspend: OK
[   61.650424] Testing event wakeup_source_activate: OK
[   61.670281] Testing event wakeup_source_deactivate: OK
[   61.690360] Testing event power_start: OK
[   61.710426] Testing event power_frequency: OK
[   61.730401] Testing event power_end: OK
[   61.750460] Testing event clock_enable: OK
[   61.770390] Testing event clock_disable: OK
[   61.790330] Testing event clock_set_rate: OK
[   61.810332] Testing event power_domain_target: OK
[   61.830292] Testing event ftrace_test_filter: OK
[   61.850313] Testing event module_load: OK
[   61.870345] Testing event module_free: OK
[   61.890382] Testing event module_get: OK
[   61.910432] Testing event module_put: OK
[   61.930393] Testing event module_request: OK
[   61.950357] Testing event lock_acquire: OK
[   61.970325] Testing event lock_release: OK
[   61.990442] Testing event lock_contended: OK
[   62.010388] Testing event lock_acquired: OK
[   62.030400] Testing event sched_kthread_stop: OK
[   62.050352] Testing event sched_kthread_stop_ret: OK
[   62.070331] Testing event sched_wakeup: OK
[   62.090320] Testing event sched_wakeup_new: OK
[   62.110300] Testing event sched_switch: OK
[   62.130371] Testing event sched_migrate_task: OK
[   62.150326] Testing event sched_process_free: OK
[   62.170289] Testing event sched_process_exit: OK
[   62.190319] Testing event sched_wait_task: OK
[   62.210355] Testing event sched_process_wait: OK
[   62.230393] Testing event sched_process_fork: OK
[   62.250304] Testing event sched_process_exec: OK
[   62.270247] Testing event sched_stat_wait: OK
[   62.290399] Testing event sched_stat_sleep: OK
[   62.310581] Testing event sched_stat_iowait: OK
[   62.330471] Testing event sched_stat_blocked: OK
[   62.350560] Testing event sched_stat_runtime: OK
[   62.369648] Testing event sched_pi_setprio: OK
[   62.386498] Testing event rcu_utilization: OK
[   62.406491] Testing event rcu_grace_period: OK
[   62.426946] Testing event rcu_grace_period_init: OK
[   62.446760] Testing event rcu_preempt_task: OK
[   62.466787] Testing event rcu_unlock_preempted_task: OK
[   62.485689] Testing event rcu_quiescent_state_report: OK
[   62.502373] Testing event rcu_fqs: OK
[   62.522514] Testing event rcu_dyntick: OK
[   62.542527] Testing event rcu_prep_idle: OK
[   62.562467] Testing event rcu_callback: OK
[   62.582442] Testing event rcu_kfree_callback: OK
[   62.602651] Testing event rcu_batch_start: OK
[   62.622483] Testing event rcu_invoke_callback: OK
[   62.642420] Testing event rcu_invoke_kfree_callback: OK
[   62.663143] Testing event rcu_batch_end: OK
[   62.682849] Testing event rcu_torture_read: OK
[   62.702616] Testing event rcu_barrier: OK
[   62.723531] Testing event workqueue_queue_work: OK
[   62.747961] Testing event workqueue_activate_work: OK
[   62.775341] Testing event workqueue_execute_start: OK
[   62.798967] Testing event workqueue_execute_end: OK
[   62.819234] Testing event signal_generate: OK
[   62.860828] Testing event signal_deliver: OK
[   62.909257] Testing event timer_init: OK
[   62.943061] Testing event timer_start: OK
[   62.963094] Testing event timer_expire_entry: OK
[   62.991705] Testing event timer_expire_exit: OK
[   63.011179] Testing event timer_cancel: OK
[   63.055099] Testing event hrtimer_init: OK
[   63.075053] Testing event hrtimer_start: OK
[   63.095091] Testing event hrtimer_expire_entry: OK
[   63.169207] Testing event hrtimer_expire_exit: OK
[   63.227213] Testing event hrtimer_cancel: OK
[   63.279118] Testing event itimer_state: OK
[   63.307171] Testing event itimer_expire: OK
[   63.327151] Testing event irq_handler_entry: OK
[   63.376380] Testing event irq_handler_exit: OK
[   63.398505] Testing event softirq_entry: OK
[   63.418541] Testing event softirq_exit: OK
[   63.438663] Testing event softirq_raise: OK
[   63.458517] Testing event console: OK
[   63.478563] Testing event task_newtask: OK
[   63.498519] Testing event task_rename: OK
[   63.519128] Testing event mce_record: OK
[   63.539184] Testing event sys_enter: OK
[   63.559135] Testing event sys_exit: OK
[   63.605187] Testing event emulate_vsyscall: OK
[   63.638933] Testing event xen_mc_batch: OK
[   63.659086] Testing event xen_mc_issue: OK
[   63.729173] Testing event xen_mc_entry: OK
[   63.762343] Testing event xen_mc_entry_alloc: OK
[   63.792837] Testing event xen_mc_callback: OK
[   63.810475] Testing event xen_mc_flush_reason: OK
[   63.830352] Testing event xen_mc_flush: OK
[   63.850548] Testing event xen_mc_extend_args: OK
[   63.870374] Testing event xen_mmu_set_pte: OK
[   63.890292] Testing event xen_mmu_set_pte_atomic: OK
[   63.910581] Testing event xen_mmu_set_domain_pte: OK
[   63.930605] Testing event xen_mmu_set_pte_at: OK
[   63.950359] Testing event xen_mmu_pte_clear: OK
[   63.970432] Testing event xen_mmu_set_pmd: OK
[   63.990453] Testing event xen_mmu_pmd_clear: OK
[   64.010418] Testing event xen_mmu_set_pud: OK
[   64.030305] Testing event xen_mmu_set_pgd: OK
[   64.050365] Testing event xen_mmu_pud_clear: OK
[   64.069845] Testing event xen_mmu_pgd_clear: OK
[   64.085577] Testing event xen_mmu_ptep_modify_prot_start: OK
[   64.102761] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   64.122454] Testing event xen_mmu_alloc_ptpage: OK
[   64.142431] Testing event xen_mmu_release_ptpage: OK
[   64.162473] Testing event xen_mmu_pgd_pin: OK
[   64.182442] Testing event xen_mmu_pgd_unpin: OK
[   64.202435] Testing event xen_mmu_flush_tlb: OK
[   64.222401] Testing event xen_mmu_flush_tlb_single: OK
[   64.242621] Testing event xen_mmu_flush_tlb_others: OK
[   64.262444] Testing event xen_mmu_write_cr3: OK
[   64.282339] Testing event xen_cpu_write_ldt_entry: OK
[   64.302433] Testing event xen_cpu_write_idt_entry: OK
[   64.322428] Testing event xen_cpu_load_idt: OK
[   64.342422] Testing event xen_cpu_write_gdt_entry: OK
[   64.362435] Testing event xen_cpu_set_ldt: OK
[   64.382300] Testing event kvm_mmu_pagetable_walk: OK
[   64.402427] Testing event kvm_mmu_paging_element: OK
[   64.422441] Testing event kvm_mmu_set_accessed_bit: OK
[   64.442421] Testing event kvm_mmu_set_dirty_bit: OK
[   64.462400] Testing event kvm_mmu_walker_error: OK
[   64.482292] Testing event kvm_mmu_get_page: OK
[   64.502551] Testing event kvm_mmu_sync_page: OK
[   64.522376] Testing event kvm_mmu_unsync_page: OK
[   64.542373] Testing event kvm_mmu_prepare_zap_page: OK
[   64.562385] Testing event kvm_mmu_delay_free_pages: OK
[   64.582595] Testing event mark_mmio_spte: OK
[   64.602987] Testing event handle_mmio_page_fault: OK
[   64.623309] Testing event fast_page_fault: OK
[   64.642415] Testing event kvm_entry: OK
[   64.662379] Testing event kvm_hypercall: OK
[   64.682451] Testing event kvm_hv_hypercall: OK
[   64.702433] Testing event kvm_pio: OK
[   64.722407] Testing event kvm_cpuid: OK
[   64.742386] Testing event kvm_apic: OK
[   64.762295] Testing event kvm_exit: OK
[   64.782399] Testing event kvm_inj_virq: OK
[   64.803159] Testing event kvm_inj_exception: OK
[   64.823105] Testing event kvm_page_fault: OK
[   64.841679] Testing event kvm_msr: OK
[   64.857969] Testing event kvm_cr: OK
[   64.878316] Testing event kvm_pic_set_irq: OK
[   64.899335] Testing event kvm_apic_ipi: OK
[   64.919127] Testing event kvm_apic_accept_irq: OK
[   64.939391] Testing event kvm_eoi: OK
[   64.958548] Testing event kvm_pv_eoi: OK
[   64.979382] Testing event kvm_nested_vmrun: OK
[   64.998521] Testing event kvm_nested_intercepts: OK
[   65.018531] Testing event kvm_nested_vmexit: OK
[   65.038435] Testing event kvm_nested_vmexit_inject: OK
[   65.058497] Testing event kvm_nested_intr_vmexit: OK
[   65.078416] Testing event kvm_invlpga: OK
[   65.098416] Testing event kvm_skinit: OK
[   65.118443] Testing event kvm_emulate_insn: OK
[   65.138438] Testing event vcpu_match_mmio: OK
[   65.158435] Testing event kvm_userspace_exit: OK
[   65.178473] Testing event kvm_set_irq: OK
[   65.198511] Testing event kvm_ioapic_set_irq: OK
[   65.218467] Testing event kvm_msi_set_irq: OK
[   65.238542] Testing event kvm_ack_irq: OK
[   65.258481] Testing event kvm_mmio: OK
[   65.278400] Testing event kvm_fpu: OK
[   65.298466] Testing event kvm_age_page: OK
[   65.318503] Testing event kvm_try_async_get_page: OK
[   65.338507] Testing event kvm_async_pf_doublefault: OK
[   65.358497] Testing event kvm_async_pf_not_present: OK
[   65.378507] Testing event kvm_async_pf_ready: OK
[   65.398452] Testing event kvm_async_pf_completed: OK
[   65.418485] Running tests on trace event systems:
[   65.419866] Testing event system 9p: OK
[   65.439261] Testing event system mac80211: OK
[   65.521658] Testing event system sunrpc: OK
[   65.545134] Testing event system skb: OK
[   65.567379] Testing event system net: OK
[   65.587670] Testing event system napi: OK
[   65.606600] Testing event system sock: OK
[   65.626913] Testing event system udp: OK
[   65.646576] Testing event system hda: OK
[   65.668522] Testing event system ras: OK
[   65.686549] Testing event system scsi: OK
[   65.708220] Testing event system regmap: OK
[   65.733879] Testing event system i915: OK
[   65.770672] Testing event system radeon: OK
[   65.791912] Testing event system drm: OK
[   65.811688] Testing event system random: OK
[   65.836419] Testing event system regulator: OK
[   65.861196] Testing event system gpio: OK
[   65.882888] Testing event system block: OK
[   65.916561] Testing event system gfs2: OK
[   65.946954] Testing event system btrfs: OK
[   65.989229] Testing event system ocfs2: OK
[   66.278141] Testing event system xfs: OK
[   66.546368] Testing event system jbd2: OK
[   66.574392] Testing event system jbd: OK
[   66.601615] Testing event system ext4: OK
[   66.678057] Testing event system ext3: OK
[   66.723644] Testing event system writeback: OK
[   66.758636] Testing event system compaction: OK
[   66.779211] Testing event system kmem: OK
[   66.806755] Testing event system vmscan: OK
[   66.835687] Testing event system oom: OK
[   66.854807] Testing event system rpm: OK
[   66.875898] Testing event system power: OK
[   66.906653] Testing event system test: OK
[   66.926604] Testing event system module: OK
[   66.947960] Testing event system lock: OK
[   66.973088] Testing event system sched: OK
[   67.019530] Testing event system rcu: OK
[   67.065875] Testing event system workqueue: OK
[   67.088506] Testing event system signal: OK
[   67.115771] Testing event system timer: OK
[   67.147632] Testing event system irq: OK
[   67.185170] Testing event system printk: OK
[   67.213595] Testing event system task: OK
[   67.237537] Testing event system mce: OK
[   67.270502] Testing event system raw_syscalls: OK
[   67.291680] Testing event system vsyscall: OK
[   67.333614] Testing event system syscalls: OK
[   67.365957] Testing event system xen: OK
[   67.426817] Testing event system kvmmmu: OK
[   67.471392] Testing event system kvm: OK
[   67.534577] Running tests on all trace events:
[   67.535993] Testing all events: OK
[   69.091473] Testing ftrace filter: OK
[   69.094848] Testing kprobe tracing: OK
[   69.102106] kAFS: Red Hat AFS client v0.1 registering.
[   69.103590] FS-Cache: Netfs 'afs' registered for caching
[   69.107671] console [netcon0] enabled
[   69.108794] netconsole: network logging started
[   69.110198] rtc_cmos 00:01: setting system clock to 2012-09-13 11:26:13 UTC (1347535573)
[   69.112603] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[   69.117336] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   69.118888] 8021q: adding VLAN 0 to HW filter on device bond0
[   69.122882] IP-Config: Failed to open ipddp0
[   69.136581] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   69.139304] 8021q: adding VLAN 0 to HW filter on device eth0
[   69.140941] IP-Config: Failed to open plip0
[   69.142130] ieee80211 phy0: mac80211_hwsim_start
[   69.143337] ieee80211 phy0: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:00:00)
[   69.145559] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0xe)
[   69.147190] ieee80211 phy0:   ERP_CTS_PROT: 0
[   69.148415] ieee80211 phy0:   ERP_PREAMBLE: 0
[   69.149563] ieee80211 phy0:   ERP_SLOT: 0
[   69.150685] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.153043] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.155250] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.157541] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.159710] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   69.161577] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   69.163265] ieee80211 phy0: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   69.165707] ieee80211 phy0: mac80211_hwsim_configure_filter
[   69.166663] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   69.166772] ieee80211 phy1: mac80211_hwsim_start
[   69.166779] ieee80211 phy1: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:01:00)
[   69.166781] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0xe)
[   69.166783] ieee80211 phy1:   ERP_CTS_PROT: 0
[   69.166785] ieee80211 phy1:   ERP_PREAMBLE: 0
[   69.166786] ieee80211 phy1:   ERP_SLOT: 0
[   69.166808] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.166811] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.166813] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.166815] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   69.166823] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   69.166828] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   69.166831] ieee80211 phy1: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   69.166850] ieee80211 phy1: mac80211_hwsim_configure_filter
[   69.166987] ieee80211 phy1: mac80211_hwsim_configure_filter
[   69.167107] ieee80211 phy1: mac80211_hwsim_configure_filter
[   69.167666] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
[   69.167706] ieee80211 phy1: mac80211_hwsim_configure_filter
[   69.167939] DHCP/BOOTP: Ignoring device hardwpan0, MTU 127 too small
[   69.167939] IP-Config: Failed to open irlan0
[   69.208116] ieee80211 phy0: mac80211_hwsim_configure_filter
[   71.136666] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   71.139113] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   72.180197] Sending DHCP requests .Unknown ARP type 0x0323 for device hwsim0
[   74.468190] ., OK
[   75.972764] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0.2.15
[   75.988794] ieee80211 phy0: mac80211_hwsim_configure_filter
[   75.990518] ieee80211 phy0: mac80211_hwsim_configure_filter
[   75.992622] ieee80211 phy0: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:00:00)
[   75.995443] ieee80211 phy0: mac80211_hwsim_stop
[   75.997645] ieee80211 phy1: mac80211_hwsim_configure_filter
[   75.997691] ieee80211 phy1: mac80211_hwsim_configure_filter
[   76.004294] ieee80211 phy1: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:01:00)
[   76.006617] ieee80211 phy1: mac80211_hwsim_stop
[   76.009344] IP-Config: Complete:
[   76.010316]      device=eth0, addr=10.0.2.15, mask=255.255.255.0, gw=10.0.2.2
[   76.012198]      host=kvm, domain=, nis-domain=(none)
[   76.013532]      bootserver=10.0.2.2, rootserver=10.239.97.14, rootpath=
[   76.015339] ALSA device list:
[   76.016344]   #0: Dummy 1
[   76.017186]   #1: Virtual MIDI Card 1
[   76.018237]   #2: HDA Intel at 0xfebf0000 irq 52
[   76.020538] md: Waiting for all devices to be available before autodetect
[   76.022240] md: If you don't use raid, use raid=noautodetect
[   76.025186] md: Autodetecting RAID arrays.
[   76.026345] md: Scanned 0 and added 0 devices.
[   76.027556] md: autorun ...
[   76.028554] md: ... autorun DONE.
[   79.835499] VFS: Mounted root (nfs filesystem) on device 0:14.
[   79.837380] debug: unmapping init [mem 0xffffffff836c6000-0xffffffff83a4cfff]
[   79.839529] Write protecting the kernel read-only data: 36864k
[   79.842229] debug: unmapping init [mem 0xffff88000270e000-0xffff8800027fffff]
[   79.844449] debug: unmapping init [mem 0xffff8800032bd000-0xffff8800033fffff]
[   80.154903] modprobe (2765) used greatest stack depth: 3112 bytes left
[   81.052375] S02mountkernfs. (2786) used greatest stack depth: 3024 bytes left
[   82.271600] cdrom_id (2947) used greatest stack depth: 2864 bytes left
[   82.472058] ide-cd: hdc: DMA read error
[   82.472137] hdc: DMA disabled
[   82.841577] scsi_id (2982) used greatest stack depth: 2672 bytes left
[   99.929857] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   99.933170] NFSD: starting 90-second grace period
Kernel tests: Boot OK!
[  101.860906] Adding 307196k swap on /dev/vda.  Priority:-1 extents:1 across:307196k 
[  106.467251] can: request_module (can-proto-6) failed.
[  106.755195] can: request_module (can-proto-6) failed.
[  111.045158] can: request_module (can-proto-6) failed.
[  155.450928] warning: process `trinity-child0' used the deprecated sysctl system call with 
[  158.607368] trinity-child1 (7572): Using mlock ulimits for SHM_HUGETLB is deprecated
[  192.573156] 
[  192.573552] =================================
[  192.574307] [ INFO: inconsistent lock state ]
[  192.575049] 3.6.0-rc4+ #5699 Not tainted
[  192.575734] ---------------------------------
[  192.576077] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[  192.576077] trinity-child0/7738 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  192.576077]  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81075db9>] huge_pte_alloc+0x2c3/0x32b
[  192.576077] {IN-RECLAIM_FS-W} state was registered at:
[  192.576077]   [<ffffffff810d5bdc>] __lock_acquire+0x35f/0xd04
[  192.576077]   [<ffffffff810d69de>] lock_acquire+0x9b/0x10d
[  192.576077]   [<ffffffff826fb7df>] __mutex_lock_common+0x47/0x35f
[  192.576077]   [<ffffffff826fbbca>] mutex_lock_nested+0x2f/0x36
[  192.576077]   [<ffffffff811589e2>] page_referenced+0x15a/0x1fb
[  192.576077]   [<ffffffff8113ef50>] shrink_page_list+0x1a6/0x71c
[  192.576077]   [<ffffffff8113f82e>] shrink_inactive_list+0x1c9/0x31a
[  192.576077]   [<ffffffff8113ff69>] shrink_lruvec+0x33f/0x472
[  192.576077]   [<ffffffff8114022c>] do_try_to_free_pages+0x190/0x39a
[  192.576077]   [<ffffffff811405cc>] try_to_free_pages+0xbc/0x123
[  192.576077]   [<ffffffff811377d8>] __alloc_pages_nodemask+0x433/0x6f9
[  192.576077]   [<ffffffff8116a120>] kmem_getpages+0x6b/0x138
[  192.576077]   [<ffffffff8116c1b4>] fallback_alloc+0x138/0x202
[  192.576077]   [<ffffffff8116c067>] ____cache_alloc_node+0x12b/0x140
[  192.576077]   [<ffffffff8116c433>] kmem_cache_alloc+0x93/0x151
[  192.576077]   [<ffffffff81187696>] alloc_inode+0x30/0x78
[  192.576077]   [<ffffffff811888b7>] iget_locked+0x69/0x10d
[  192.576077]   [<ffffffff811ce3d2>] sysfs_get_inode+0x1a/0x140
[  192.576077]   [<ffffffff811d00c5>] sysfs_lookup+0x87/0xb2
[  192.576077]   [<ffffffff8117bb84>] lookup_real+0x2c/0x47
[  192.576077]   [<ffffffff8117c04a>] __lookup_hash+0x33/0x3a
[  192.576077]   [<ffffffff8117ce4c>] walk_component+0x77/0x1a4
[  192.576077]   [<ffffffff8117cfaf>] lookup_last+0x36/0x38
[  192.576077]   [<ffffffff8117dae9>] path_lookupat+0x90/0x29d
[  192.576077]   [<ffffffff8117dd1e>] do_path_lookup+0x28/0x92
[  192.576077]   [<ffffffff8117fd71>] user_path_at_empty+0x57/0x95
[  192.576077]   [<ffffffff8117fdc0>] user_path_at+0x11/0x13
[  192.576077]   [<ffffffff81176d41>] vfs_fstatat+0x35/0x66
[  192.576077]   [<ffffffff81176d90>] vfs_lstat+0x1e/0x20
[  192.576077]   [<ffffffff811770e9>] sys_newlstat+0x1a/0x35
[  192.576077]   [<ffffffff82704d10>] tracesys+0xdd/0xe2
[  192.576077] irq event stamp: 14521
[  192.576077] hardirqs last  enabled at (14521): [<ffffffff826fbab4>] __mutex_lock_common+0x31c/0x35f
[  192.576077] hardirqs last disabled at (14520): [<ffffffff826fb836>] __mutex_lock_common+0x9e/0x35f
[  192.576077] softirqs last  enabled at (14516): [<ffffffff8231b6f5>] lock_sock_nested+0x75/0x80
[  192.576077] softirqs last disabled at (14514): [<ffffffff826fd953>] _raw_spin_lock_bh+0x18/0x6f
[  192.576077] 
[  192.576077] other info that might help us debug this:
[  192.576077]  Possible unsafe locking scenario:
[  192.576077] 
[  192.576077]        CPU0
[  192.576077]        ----
[  192.576077]   lock(&mapping->i_mmap_mutex);
[  192.576077]   <Interrupt>
[  192.576077]     lock(&mapping->i_mmap_mutex);
[  192.576077] 
[  192.576077]  *** DEADLOCK ***
[  192.576077] 
[  192.576077] 3 locks held by trinity-child0/7738:
[  192.576077]  #0:  (sk_lock-AF_ATMPVC){+.+.+.}, at: [<ffffffff824e88cc>] pvc_getsockopt+0x31/0x60
[  192.576077]  #1:  (&mm->mmap_sem){++++++}, at: [<ffffffff827013a9>] do_page_fault+0x170/0x3a9
[  192.576077]  #2:  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81075db9>] huge_pte_alloc+0x2c3/0x32b
[  192.576077] 
[  192.576077] stack backtrace:
[  192.576077] Pid: 7738, comm: trinity-child0 Not tainted 3.6.0-rc4+ #5699
[  192.576077] Call Trace:
[  192.576077]  [<ffffffff826d28ff>] print_usage_bug+0x1f7/0x208
[  192.576077]  [<ffffffff81054745>] ? save_stack_trace+0x2c/0x49
[  192.576077]  [<ffffffff810d5047>] ? print_shortest_lock_dependencies+0x185/0x185
[  192.576077]  [<ffffffff810d5786>] mark_lock+0x11b/0x212
[  192.576077]  [<ffffffff810d6d20>] mark_held_locks+0x71/0x99
[  192.576077]  [<ffffffff810d73a5>] lockdep_trace_alloc+0xb9/0xc3
[  192.576077]  [<ffffffff81137443>] __alloc_pages_nodemask+0x9e/0x6f9
[  192.576077]  [<ffffffff810d5698>] ? mark_lock+0x2d/0x212
[  192.576077]  [<ffffffff810d3388>] ? ftrace_raw_event_lock+0xb9/0xc8
[  192.576077]  [<ffffffff810d6d20>] ? mark_held_locks+0x71/0x99
[  192.576077]  [<ffffffff826fbab4>] ? __mutex_lock_common+0x31c/0x35f
[  192.576077]  [<ffffffff81075db9>] ? huge_pte_alloc+0x2c3/0x32b
[  192.576077]  [<ffffffff81164eae>] alloc_pages_current+0xc3/0xe0
[  192.576077]  [<ffffffff81075db9>] ? huge_pte_alloc+0x2c3/0x32b
[  192.576077]  [<ffffffff81133cda>] __get_free_pages+0x16/0x43
[  192.576077]  [<ffffffff81133d1d>] get_zeroed_page+0x16/0x18
[  192.576077]  [<ffffffff811500d1>] __pmd_alloc+0x20/0xa3
[  192.576077]  [<ffffffff8107596b>] pmd_alloc+0x4c/0x57
[  192.576077]  [<ffffffff81075d47>] huge_pte_alloc+0x251/0x32b
[  192.576077]  [<ffffffff81163544>] hugetlb_fault+0xcf/0x575
[  192.576077]  [<ffffffff827013a9>] ? do_page_fault+0x170/0x3a9
[  192.576077]  [<ffffffff82701334>] ? do_page_fault+0xfb/0x3a9
[  192.576077]  [<ffffffff811501c8>] handle_mm_fault+0x44/0xcc
[  192.576077]  [<ffffffff82701598>] do_page_fault+0x35f/0x3a9
[  192.576077]  [<ffffffff8104f55b>] ? native_sched_clock+0x33/0x35
[  192.576077]  [<ffffffff81116de4>] ? irq_trace+0x14/0x21
[  192.576077]  [<ffffffff811174fc>] ? time_hardirqs_off+0x26/0x2a
[  192.576077]  [<ffffffff810b9dba>] ? local_clock+0x3b/0x52
[  192.576077]  [<ffffffff810d31bd>] ? trace_hardirqs_off+0xd/0xf
[  192.576077]  [<ffffffff810d3131>] ? trace_hardirqs_off_caller+0x1f/0x9e
[  192.576077]  [<ffffffff81116de4>] ? irq_trace+0x14/0x21
[  192.576077]  [<ffffffff811174fc>] ? time_hardirqs_off+0x26/0x2a
[  192.576077]  [<ffffffff826fe826>] ? error_sti+0x5/0x6
[  192.576077]  [<ffffffff810d3151>] ? trace_hardirqs_off_caller+0x3f/0x9e
[  192.576077]  [<ffffffff8167c61d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  192.576077]  [<ffffffff82700ed4>] do_async_page_fault+0x31/0x5e
[  192.576077]  [<ffffffff826fe605>] async_page_fault+0x25/0x30
[  192.576077]  [<ffffffff810b9d98>] ? local_clock+0x19/0x52
[  192.576077]  [<ffffffff8167b5fc>] ? __get_user_4+0x1c/0x30
[  192.576077]  [<ffffffff824eba1b>] ? vcc_getsockopt+0x33/0x194
[  192.576077]  [<ffffffff824e88cc>] ? pvc_getsockopt+0x31/0x60
[  192.576077]  [<ffffffff81111772>] ? trace_nowake_buffer_unlock_commit+0xc/0xe
[  192.576077]  [<ffffffff824e88e2>] pvc_getsockopt+0x47/0x60
[  192.576077]  [<ffffffff82319319>] sys_getsockopt+0x7a/0x98
[  192.576077]  [<ffffffff82704d10>] tracesys+0xdd/0xe2

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.6.0-rc4+"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
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
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_IKCONFIG is not set
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
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=y
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
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
# CONFIG_MUTEX_SPIN_ON_OWNER is not set
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_KVM_CLOCK is not set
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
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
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_FAKE is not set
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_NET_IPVTI is not set
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
# CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_NFCT=y
# CONFIG_IP_VS_PE_SIP is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_NF_NAT is not set
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_SECURITY=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
# CONFIG_IP6_NF_MATCH_RPFILTER is not set
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_SECURITY=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_NET_DCCPPROBE=y
CONFIG_IP_SCTP=y
CONFIG_NET_SCTPPROBE=y
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_RDS=y
CONFIG_RDS_RDMA=y
CONFIG_RDS_TCP=y
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_ADVANCED=y
CONFIG_TIPC_PORTS=8191
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_IPDDP_DECAP=y
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_WAN_ROUTER=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_6LOWPAN is not set
# CONFIG_MAC802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_ACT_SKBEDIT=y
# CONFIG_NET_ACT_CSUM is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
CONFIG_NETROM=y
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
CONFIG_6PACK=y
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_MCP251X=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCMCIA is not set
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
# CONFIG_CAN_PEAK_PCI is not set
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
# CONFIG_CAN_SOFTING is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
CONFIG_ACTISYS_DONGLE=y
CONFIG_TEKRAM_DONGLE=y
CONFIG_TOIM3232_DONGLE=y
CONFIG_LITELINK_DONGLE=y
CONFIG_MA600_DONGLE=y
CONFIG_GIRBIL_DONGLE=y
CONFIG_MCP2120_DONGLE=y
CONFIG_OLD_BELKIN_DONGLE=y
CONFIG_ACT200L_DONGLE=y

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_BT=y
# CONFIG_BT_RFCOMM is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_CMTP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_RDMA=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=y
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
# CONFIG_MTD_SC520CDP is not set
CONFIG_MTD_NETSC520=y
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=y
CONFIG_MTD_PCMCIA=y
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
# CONFIG_MTD_GPIO_ADDR is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
CONFIG_M25PXX_USE_FAST_READ=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOC2000=y
CONFIG_MTD_DOC2001=y
CONFIG_MTD_DOC2001PLUS=y
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_DOCPROBE=y
CONFIG_MTD_DOCECC=y
# CONFIG_MTD_DOCPROBE_ADVANCED is not set
CONFIG_MTD_DOCPROBE_ADDRESS=0x0
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_RESERVE=2
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=m
CONFIG_PARIDE_BPCK=m
CONFIG_PARIDE_COMM=m
CONFIG_PARIDE_DSTR=m
CONFIG_PARIDE_FIT2=m
CONFIG_PARIDE_FIT3=m
CONFIG_PARIDE_EPAT=m
# CONFIG_PARIDE_EPATC8 is not set
CONFIG_PARIDE_EPIA=m
CONFIG_PARIDE_FRIQ=m
CONFIG_PARIDE_FRPW=m
CONFIG_PARIDE_KBIC=m
CONFIG_PARIDE_KTTI=m
CONFIG_PARIDE_ON20=m
CONFIG_PARIDE_ON26=m
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
CONFIG_BLK_CPQ_DA=y
CONFIG_BLK_CPQ_CISS_DA=y
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
CONFIG_BLK_DEV_DRBD=y
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
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
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_DELKIN=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
CONFIG_BLK_DEV_HPT366=y
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_CXGB3_ISCSI=y
# CONFIG_SCSI_CXGB4_ISCSI is not set
CONFIG_SCSI_BNX2_ISCSI=y
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=8
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
CONFIG_VMWARE_PVSCSI=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=y
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_PCMCIA_AHA152X is not set
CONFIG_PCMCIA_FDOMAIN=m
CONFIG_PCMCIA_QLOGIC=m
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
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
CONFIG_SATA_INIC162X=y
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
CONFIG_SATA_SVW=y
CONFIG_SATA_ULI=y
CONFIG_SATA_VIA=y
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=y
# CONFIG_PATA_ARASAN_CF is not set
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
CONFIG_PATA_EFAR=y
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
CONFIG_PATA_NETCELL=y
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=y
CONFIG_PATA_SC1200=y
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
CONFIG_PATA_SIL680=y
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=y
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_MIRROR=y
# CONFIG_DM_RAID is not set
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LAN=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NET=y
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
CONFIG_I2O_SCSI=y
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
CONFIG_MII=y
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y
# CONFIG_ARCNET_COM20020_CS is not set
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
CONFIG_ATM_TCP=y
CONFIG_ATM_LANAI=y
CONFIG_ATM_ENI=y
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=y
CONFIG_ATM_ZATM=y
# CONFIG_ATM_ZATM_DEBUG is not set
# CONFIG_ATM_NICSTAR is not set
CONFIG_ATM_IDT77252=y
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=y
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=y
# CONFIG_ATM_HORIZON_DEBUG is not set
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=y
# CONFIG_ATM_FORE200E_USE_TASKLET is not set
CONFIG_ATM_FORE200E_TX_RETRY=16
CONFIG_ATM_FORE200E_DEBUG=0
CONFIG_ATM_HE=y
CONFIG_ATM_HE_USE_SUNI=y
CONFIG_ATM_SOLOS=y

#
# CAIF transport drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DE600 is not set
# CONFIG_DE620 is not set
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
# CONFIG_IGB_PTP is not set
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
# CONFIG_IXGBE_PTP is not set
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_ZNET is not set
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_SEEQ8005 is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=y
# CONFIG_ROADRUNNER_LARGE_RINGS is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
# CONFIG_MICREL_KS8995MA is not set
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PCMCIA_ATMEL=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_RTL8180=y
CONFIG_ADM8211=y
CONFIG_MAC80211_HWSIM=y
CONFIG_MWL8K=y
CONFIG_ATH_COMMON=y
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=y
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=y
CONFIG_ATH9K_COMMON=y
CONFIG_ATH9K_BTCOEX_SUPPORT=y
CONFIG_ATH9K=y
CONFIG_ATH9K_PCI=y
# CONFIG_ATH9K_AHB is not set
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_RATE_CONTROL=y
# CONFIG_ATH6KL is not set
CONFIG_B43=y
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_PIO=y
# CONFIG_B43_PHY_N is not set
CONFIG_B43_PHY_LP=y
# CONFIG_B43_PHY_HT is not set
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
# CONFIG_B43_DEBUG is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
# CONFIG_BRCMFMAC is not set
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
CONFIG_HOSTAP_PLX=y
CONFIG_HOSTAP_PCI=y
CONFIG_HOSTAP_CS=y
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=y
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=y
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLWIFI=y
CONFIG_IWLDVM=y

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_IWLWIFI_P2P=y
# CONFIG_IWLWIFI_EXPERIMENTAL_MFP is not set
CONFIG_IWLEGACY=y
# CONFIG_IWL4965 is not set
CONFIG_IWL3945=y

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_CS=y
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_SPI=y
# CONFIG_LIBERTAS_DEBUG is not set
CONFIG_LIBERTAS_MESH=y
CONFIG_HERMES=y
# CONFIG_HERMES_PRISM is not set
CONFIG_HERMES_CACHE_FW_ON_INIT=y
CONFIG_PLX_HERMES=y
CONFIG_TMD_HERMES=y
CONFIG_NORTEL_HERMES=y
CONFIG_PCMCIA_HERMES=y
CONFIG_PCMCIA_SPECTRUM=y
CONFIG_P54_COMMON=y
CONFIG_P54_PCI=y
CONFIG_P54_SPI=y
# CONFIG_P54_SPI_DEFAULT_EEPROM is not set
CONFIG_P54_LEDS=y
CONFIG_RT2X00=y
CONFIG_RT2400PCI=y
CONFIG_RT2500PCI=y
CONFIG_RT61PCI=y
CONFIG_RT2800PCI=y
CONFIG_RT2800PCI_RT33XX=y
CONFIG_RT2800PCI_RT35XX=y
CONFIG_RT2800PCI_RT53XX=y
CONFIG_RT2800PCI_RT3290=y
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_WL_TI is not set
# CONFIG_MWIFIEX is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
# CONFIG_HDLC_X25 is not set
CONFIG_PCI200SYN=y
CONFIG_WANXL=y
# CONFIG_PC300TOO is not set
CONFIG_FARSYNC=y
CONFIG_DSCC4=m
CONFIG_DSCC4_PCISYNC=y
CONFIG_DSCC4_PCI_RST=y
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_WAN_ROUTER_DRIVERS=y
CONFIG_CYCLADES_SYNC=y
# CONFIG_CYCLOMX_X25 is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=y
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPI20=y

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=y
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=y
CONFIG_ISDN_DRV_AVMB1_AVM_CS=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=y
CONFIG_ISDN_DRV_AVMB1_C4=y
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=y
CONFIG_MISDN_HFCMULTI=y
CONFIG_MISDN_AVMFRITZ=y
CONFIG_MISDN_SPEEDFAX=y
CONFIG_MISDN_INFINEON=y
CONFIG_MISDN_W6692=y
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=y
CONFIG_MISDN_ISAR=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
CONFIG_NOZOMI=y
CONFIG_ISI=y
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX3107 is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MCP23S08 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_74X164 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_WM97XX is not set
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_XEN_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set

#
# Media drivers
#

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_STUB_POULSBO is not set
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=y
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PROGEAR is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LP855X is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=y
CONFIG_SND_DUMMY=y
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
CONFIG_SND_MTS64=y
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
CONFIG_SND_ATIIXP_MODEM=y
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
CONFIG_SND_CS4281=y
CONFIG_SND_CS46XX=y
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CS5530=y
CONFIG_SND_CS5535AUDIO=y
CONFIG_SND_CTXFI=y
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
CONFIG_SND_MONA=y
CONFIG_SND_MIA=y
CONFIG_SND_ECHO3G=y
CONFIG_SND_INDIGO=y
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
CONFIG_SND_INDIGOIOX=y
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
CONFIG_SND_ES1938=y
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_FM801=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
# CONFIG_SND_HDA_POWER_SAVE is not set
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=y
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
CONFIG_SND_KORG1212=y
# CONFIG_SND_LOLA is not set
CONFIG_SND_LX6464ES=y
CONFIG_SND_MAESTRO3=y
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y
CONFIG_SND_SPI=y
CONFIG_SND_FIREWIRE=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
# CONFIG_SND_ISIGHT is not set
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_CHIPIDEA is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_R8A66597=y
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_GADGET_DUALSPEED=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_FILE_STORAGE is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=y
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA9633 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_DELL_NETBOOKS=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM3556 is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=y
CONFIG_INFINIBAND_QIB=y
CONFIG_INFINIBAND_AMSO1100=y
# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=y
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_AMD64=y
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
CONFIG_EDAC_I5000=y
CONFIG_EDAC_I5100=y
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
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
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VFIO is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=y
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=y
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=m
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_ECHO is not set
# CONFIG_COMEDI is not set
# CONFIG_PANEL is not set
# CONFIG_R8187SE is not set
# CONFIG_RTLLIB is not set
# CONFIG_RTS_PSTOR is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_VT6655 is not set
# CONFIG_DX_SEP is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_SBE_2T3E3 is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_PHONE=y
CONFIG_PHONE_IXJ=y
CONFIG_PHONE_IXJ_PCMCIA=y
# CONFIG_USB_G_CCG is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_CSR_WIFI is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
# CONFIG_IDEAPAD_LAPTOP is not set
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_MXM_WMI is not set
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
# CONFIG_AMD_IOMMU_V2 is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=y
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

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
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="utf8"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_LOGFS=y
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
# CONFIG_EXOFS_DEBUG is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_OBJLAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_ROOT_NFS=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_SUNRPC_XPRT_RDMA=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CEPH_FS=y
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CIFS_ACL is not set
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=y
CONFIG_9P_FS=y
CONFIG_9P_FSCACHE=y
# CONFIG_9P_FS_POSIX_ACL is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_DEBUG_BLOCK_EXT_DEVT=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
# CONFIG_EVENT_TRACE_TEST_SYSCALLS is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DMA_API_DEBUG=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_TOMOYO=y
CONFIG_SECURITY_TOMOYO_MAX_ACCEPT_ENTRY=2048
CONFIG_SECURITY_TOMOYO_MAX_AUDIT_LOG=1024
# CONFIG_SECURITY_TOMOYO_OMIT_USERSPACE_LOADER is not set
CONFIG_SECURITY_TOMOYO_POLICY_LOADER="/sbin/tomoyo-init"
CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER="/sbin/init"
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_BTREE=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_LRU_CACHE=y
CONFIG_AVERAGE=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
