Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 8FA1D6B0070
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 00:00:18 -0400 (EDT)
Date: Sun, 8 Jul 2012 12:00:09 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: WARNING: __GFP_FS allocations with IRQs disabled
 (kmemcheck_alloc_shadow)
Message-ID: <20120708040009.GA8363@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Vegard,

This warning code is triggered for the attached config:

__lockdep_trace_alloc():
        /*
         * Oi! Can't be having __GFP_FS allocations with IRQs disabled.
         */
        if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
                return;

Where the irq is possibly disabled at the beginning of __slab_alloc():

        local_irq_save(flags);

Thanks,
Fengguang
---

[    1.657564] kmemcheck: Limiting number of CPUs to 1.
[    1.660022] kmemcheck: Initialized
[    1.682729] ------------[ cut here ]------------
[    1.687281] WARNING: at /c/kernel-tests/net/kernel/lockdep.c:2739 lockdep_trace_alloc+0x14e/0x1c0()
[    1.690000] Hardware name: Bochs
[    1.690000] Pid: 1, comm: swapper/0 Not tainted 3.5.0-rc5+ #11
[    1.690000] Call Trace:
[    1.690000]  [<ffffffff81055521>] warn_slowpath_common+0xd1/0x110
[    1.690000]  [<ffffffff81043685>] ? kmemcheck_fault+0x105/0x130
[    1.690000]  [<ffffffff81055685>] warn_slowpath_null+0x25/0x30
[    1.690000]  [<ffffffff810c852e>] lockdep_trace_alloc+0x14e/0x1c0
[    1.690000]  [<ffffffff8112e9ec>] __alloc_pages_nodemask+0xbc/0xcb0
[    1.690000]  [<ffffffff8112eb89>] ? __alloc_pages_nodemask+0x259/0xcb0
[    1.690000]  [<ffffffff813a2dfd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    1.690000]  [<ffffffff813a2dfd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    1.690000]  [<ffffffff818a8ef0>] ? error_exit+0x30/0xb0
[    1.690000]  [<ffffffff8117e9b1>] kmemcheck_alloc_shadow+0x31/0x160
[    1.690000]  [<ffffffff8117b1ec>] new_slab+0x1fc/0x460
[    1.690000]  [<ffffffff81898065>] __slab_alloc.isra.49.constprop.54+0x585/0x791
[    1.690000]  [<ffffffff813918ff>] ? idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff818a8ef0>] ? error_exit+0x30/0xb0
[    1.690000]  [<ffffffff813918ff>] ? idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff8117b63b>] kmem_cache_alloc+0xab/0x1b0
[    1.690000]  [<ffffffff813918ff>] idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff81392413>] ida_pre_get+0x23/0xf0
[    1.690000]  [<ffffffff810786e5>] create_worker+0x65/0x220
[    1.690000]  [<ffffffff8236202f>] init_workqueues+0x296/0x4fc
[    1.690000]  [<ffffffff82361d99>] ? usermodehelper_init+0x52/0x52
[    1.690000]  [<ffffffff823452ee>] do_one_initcall+0xb6/0x1d4
[    1.690000]  [<ffffffff823454e6>] kernel_init+0xda/0x309
[    1.690000]  [<ffffffff818aa4f4>] kernel_thread_helper+0x4/0x10
[    1.690000]  [<ffffffff818a8a34>] ? retint_restore_args+0x13/0x13
[    1.690000]  [<ffffffff8234540c>] ? do_one_initcall+0x1d4/0x1d4
[    1.690000]  [<ffffffff818aa4f0>] ? gs_change+0x13/0x13
[    1.690000] ---[ end trace 4eaa2a86a8e2da22 ]---
[    1.776302] Brought up 1 CPUs


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg-kvm-waimea-2166-2012-07-08-11-02-20

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.5.0-rc5+ (wfg@bee) (gcc version 4.7.0 (Debian 4.7.1-1) ) #11 SMP PREEMPT Sun Jul 8 09:22:34 CST 2012
[    0.000000] Command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-07-08-09-23-00-net-net-next.master-95162d6-8206728-x86_64-randconfig-net8-1-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-net8/820672812f8284143f933da8ccc60e296230d25d/vmlinuz-3.5.0-rc5+
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xfffd max_arch_pfn = 0x400000000
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
[    0.000000] x86 PAT enabled: cpu 0, old 0x70106, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x0fffcfff]
[    0.000000]  [mem 0x00000000-0x0fffcfff] page 4k
[    0.000000] kernel direct mapping tables up to 0xfffcfff @ [mem 0x0e854000-0x0e8d5fff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128240(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: cpu 0, msr 0:2343001, boot clock
[    0.000000] Zone ranges:
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffcfff]
[    0.000000] On node 0 totalpages: 65420
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 60477 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
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
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x10000000-0xfffbbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 23 pages/cpu @ffff88000dc00000 s73088 r0 d21120 u1048576
[    0.000000] kvm-clock: cpu 0, msr 0:dc11001, primary cpu clock
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64390
[    0.000000] Kernel command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-07-08-09-23-00-net-net-next.master-95162d6-8206728-x86_64-randconfig-net8-1-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-net8/820672812f8284143f933da8ccc60e296230d25d/vmlinuz-3.5.0-rc5+
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 191120k/262132k available (8883k kernel code, 452k absent, 70560k reserved, 10750k data, 708k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Additional per-CPU info printed with stalls.
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
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
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
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
[    0.000000] allocated 1048576 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Detected 3299.986 MHz processor.
[    0.010000] Calibrating delay loop (skipped) preset value.. 6599.97 BogoMIPS (lpj=32999860)
[    0.012904] pid_max: default: 32768 minimum: 301
[    0.042078] Security Framework initialized
[    0.060847] AppArmor: AppArmor initialized
[    0.072469] Mount-cache hash table entries: 256
[    0.102771] kobject: 'fs' (ffff88000d014080): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    0.241522] Initializing cgroup subsys debug
[    0.244583] Initializing cgroup subsys memory
[    0.256305] Initializing cgroup subsys devices
[    0.259724] Initializing cgroup subsys freezer
[    0.265922] kobject: 'cgroup' (ffff88000d014180): kobject_add_internal: parent: 'fs', set: '<NULL>'
[    0.280392] Disabled fast string operations
[    0.287032] ACPI: Core revision 20120320
[    1.457533] Getting VERSION: 50014
[    1.460141] Getting VERSION: 50014
[    1.463371] Getting ID: 0
[    1.466049] Getting ID: ff000000
[    1.470223] Getting LVT0: 8700
[    1.473242] Getting LVT1: 8400
[    1.476341] enabled ExtINT on CPU#0
[    1.481857] ENABLING IO-APIC IRQs
[    1.485073] init IO_APIC IRQs
[    1.487954]  apic 2 pin 0 not connected
[    1.490286] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    1.500686] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    1.508492] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    1.510843] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    1.520711] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    1.530724] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    1.540661] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    1.548193] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    1.550694] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    1.560682] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    1.570660] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    1.578146] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    1.580557] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    1.590458] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    1.595956] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    1.600373]  apic 2 pin 16 not connected
[    1.602975]  apic 2 pin 17 not connected
[    1.605528]  apic 2 pin 18 not connected
[    1.610094]  apic 2 pin 19 not connected
[    1.612717]  apic 2 pin 20 not connected
[    1.615360]  apic 2 pin 21 not connected
[    1.617887]  apic 2 pin 22 not connected
[    1.620091]  apic 2 pin 23 not connected
[    1.623140] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    1.627097] CPU0: Intel Common KVM processor stepping 01
[    1.633529] Using local APIC timer interrupts.
[    1.633529] calibrating APIC timer ...
[    1.650000] ... lapic delta = 6246739
[    1.650000] ... PM-Timer delta = 357773
[    1.650000] ... PM-Timer result ok
[    1.650000] ..... delta 6246739
[    1.650000] ..... mult: 268295397
[    1.650000] ..... calibration result: 9994782
[    1.650000] ..... CPU clock speed is 3298.4405 MHz.
[    1.650000] ..... host bus clock speed is 999.4782 MHz.
[    1.650185] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    1.657564] kmemcheck: Limiting number of CPUs to 1.
[    1.660022] kmemcheck: Initialized
[    1.682729] ------------[ cut here ]------------
[    1.687281] WARNING: at /c/kernel-tests/net/kernel/lockdep.c:2739 lockdep_trace_alloc+0x14e/0x1c0()
[    1.690000] Hardware name: Bochs
[    1.690000] Pid: 1, comm: swapper/0 Not tainted 3.5.0-rc5+ #11
[    1.690000] Call Trace:
[    1.690000]  [<ffffffff81055521>] warn_slowpath_common+0xd1/0x110
[    1.690000]  [<ffffffff81043685>] ? kmemcheck_fault+0x105/0x130
[    1.690000]  [<ffffffff81055685>] warn_slowpath_null+0x25/0x30
[    1.690000]  [<ffffffff810c852e>] lockdep_trace_alloc+0x14e/0x1c0
[    1.690000]  [<ffffffff8112e9ec>] __alloc_pages_nodemask+0xbc/0xcb0
[    1.690000]  [<ffffffff8112eb89>] ? __alloc_pages_nodemask+0x259/0xcb0
[    1.690000]  [<ffffffff813a2dfd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    1.690000]  [<ffffffff813a2dfd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    1.690000]  [<ffffffff818a8ef0>] ? error_exit+0x30/0xb0
[    1.690000]  [<ffffffff8117e9b1>] kmemcheck_alloc_shadow+0x31/0x160
[    1.690000]  [<ffffffff8117b1ec>] new_slab+0x1fc/0x460
[    1.690000]  [<ffffffff81898065>] __slab_alloc.isra.49.constprop.54+0x585/0x791
[    1.690000]  [<ffffffff813918ff>] ? idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff818a8ef0>] ? error_exit+0x30/0xb0
[    1.690000]  [<ffffffff813918ff>] ? idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff8117b63b>] kmem_cache_alloc+0xab/0x1b0
[    1.690000]  [<ffffffff813918ff>] idr_pre_get+0x5f/0xd0
[    1.690000]  [<ffffffff81392413>] ida_pre_get+0x23/0xf0
[    1.690000]  [<ffffffff810786e5>] create_worker+0x65/0x220
[    1.690000]  [<ffffffff8236202f>] init_workqueues+0x296/0x4fc
[    1.690000]  [<ffffffff82361d99>] ? usermodehelper_init+0x52/0x52
[    1.690000]  [<ffffffff823452ee>] do_one_initcall+0xb6/0x1d4
[    1.690000]  [<ffffffff823454e6>] kernel_init+0xda/0x309
[    1.690000]  [<ffffffff818aa4f4>] kernel_thread_helper+0x4/0x10
[    1.690000]  [<ffffffff818a8a34>] ? retint_restore_args+0x13/0x13
[    1.690000]  [<ffffffff8234540c>] ? do_one_initcall+0x1d4/0x1d4
[    1.690000]  [<ffffffff818aa4f0>] ? gs_change+0x13/0x13
[    1.690000] ---[ end trace 4eaa2a86a8e2da22 ]---
[    1.776302] Brought up 1 CPUs
[    1.779064] ----------------
[    1.780046] | NMI testsuite:
[    1.790013] --------------------
[    1.793430]   remote IPI:  ok  |
[    1.797783]    local IPI:  ok  |
[    1.840027] --------------------
[    1.842868] Good, all   2 testcases passed! |
[    1.846773] ---------------------------------
[    1.850011] Total of 1 processors activated (6599.97 BogoMIPS).
[    1.861550] CPU0 attaching NULL sched-domain.
[    1.911746] devtmpfs: initialized
[    1.914679] kobject: 'devices' (ffff88000d07a7c8): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    1.920566] kobject: 'devices' (ffff88000d07a7c8): kobject_uevent_env
[    1.925646] kobject: 'devices' (ffff88000d07a7c8): kobject_uevent_env: attempted to send uevent without kset!
[    1.930275] kobject: 'dev' (ffff88000d014340): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    1.940887] kobject: 'block' (ffff88000d014400): kobject_add_internal: parent: 'dev', set: '<NULL>'
[    1.950773] kobject: 'char' (ffff88000d014440): kobject_add_internal: parent: 'dev', set: '<NULL>'
[    1.958168] kobject: 'bus' (ffff88000d07a888): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    1.960558] kobject: 'bus' (ffff88000d07a888): kobject_uevent_env
[    1.970040] kobject: 'bus' (ffff88000d07a888): kobject_uevent_env: attempted to send uevent without kset!
[    1.977598] kobject: 'system' (ffff88000d07a948): kobject_add_internal: parent: 'devices', set: '<NULL>'
[    1.980518] kobject: 'system' (ffff88000d07a948): kobject_uevent_env
[    1.990110] kobject: 'system' (ffff88000d07a948): kobject_uevent_env: attempted to send uevent without kset!
[    1.998724] kobject: 'class' (ffff88000d07aa08): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    2.000522] kobject: 'class' (ffff88000d07aa08): kobject_uevent_env
[    2.010052] kobject: 'class' (ffff88000d07aa08): kobject_uevent_env: attempted to send uevent without kset!
[    2.017156] kobject: 'firmware' (ffff88000d014480): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    2.021296] kobject: 'platform' (ffffffff821c0ef0): kobject_add_internal: parent: 'devices', set: 'devices'
[    2.034414] kobject: 'platform' (ffffffff821c0ef0): kobject_uevent_env
[    2.040106] kobject: 'platform' (ffffffff821c0ef0): kobject_uevent_env: filter function caused the event to drop!
[    2.051158] kobject: 'platform' (ffff88000d065048): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.058197] kobject: 'platform' (ffff88000d065048): kobject_uevent_env
[    2.062622] kobject: 'platform' (ffff88000d065048): fill_kobj_path: path = '/bus/platform'
[    2.071283] kobject: 'devices' (ffff88000d07aac8): kobject_add_internal: parent: 'platform', set: '<NULL>'
[    2.078551] kobject: 'devices' (ffff88000d07aac8): kobject_uevent_env
[    2.080106] kobject: 'devices' (ffff88000d07aac8): kobject_uevent_env: filter function caused the event to drop!
[    2.090554] kobject: 'drivers' (ffff88000d07ab88): kobject_add_internal: parent: 'platform', set: '<NULL>'
[    2.098600] kobject: 'drivers' (ffff88000d07ab88): kobject_uevent_env
[    2.100110] kobject: 'drivers' (ffff88000d07ab88): kobject_uevent_env: filter function caused the event to drop!
[    2.111926] kobject: 'cpu' (ffff88000d065448): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.120978] kobject: 'cpu' (ffff88000d065448): kobject_uevent_env
[    2.130136] kobject: 'cpu' (ffff88000d065448): fill_kobj_path: path = '/bus/cpu'
[    2.135419] kobject: 'devices' (ffff88000d07ac48): kobject_add_internal: parent: 'cpu', set: '<NULL>'
[    2.140395] kobject: 'devices' (ffff88000d07ac48): kobject_uevent_env
[    2.144160] kobject: 'devices' (ffff88000d07ac48): kobject_uevent_env: filter function caused the event to drop!
[    2.150433] kobject: 'drivers' (ffff88000d07ad08): kobject_add_internal: parent: 'cpu', set: '<NULL>'
[    2.157471] kobject: 'drivers' (ffff88000d07ad08): kobject_uevent_env
[    2.160099] kobject: 'drivers' (ffff88000d07ad08): kobject_uevent_env: filter function caused the event to drop!
[    2.172728] kobject: 'cpu' (ffff88000d065810): kobject_add_internal: parent: 'system', set: 'devices'
[    2.187470] kobject: 'cpu' (ffff88000d065810): kobject_uevent_env
[    2.190079] kobject: 'cpu' (ffff88000d065810): kobject_uevent_env: filter function caused the event to drop!
[    2.201085] kobject: 'memory' (ffff88000d065c48): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.208327] kobject: 'memory' (ffff88000d065c48): kobject_uevent_env
[    2.212496] kobject: 'memory' (ffff88000d065c48): fill_kobj_path: path = '/bus/memory'
[    2.221230] kobject: 'devices' (ffff88000d07adc8): kobject_add_internal: parent: 'memory', set: '<NULL>'
[    2.231357] kobject: 'devices' (ffff88000d07adc8): kobject_uevent_env
[    2.236491] kobject: 'devices' (ffff88000d07adc8): kobject_uevent_env: filter function caused the event to drop!
[    2.240480] kobject: 'drivers' (ffff88000d07ae88): kobject_add_internal: parent: 'memory', set: '<NULL>'
[    2.250697] kobject: 'drivers' (ffff88000d07ae88): kobject_uevent_env
[    2.255323] kobject: 'drivers' (ffff88000d07ae88): kobject_uevent_env: filter function caused the event to drop!
[    2.262849] kobject: 'memory' (ffff88000d066010): kobject_add_internal: parent: 'system', set: 'devices'
[    2.274641] kobject: 'memory' (ffff88000d066010): kobject_uevent_env
[    2.280078] kobject: 'memory' (ffff88000d066010): kobject_uevent_env: filter function caused the event to drop!
[    2.292606] kobject: 'memory0' (ffff88000d01e0d0): kobject_add_internal: parent: 'memory', set: 'devices'
[    2.306648] kobject: 'memory0' (ffff88000d01e0d0): kobject_uevent_env
[    2.312976] kobject: 'memory0' (ffff88000d01e0d0): fill_kobj_path: path = '/devices/system/memory/memory0'
[    2.325211] kobject: 'memory1' (ffff88000d01e8d0): kobject_add_internal: parent: 'memory', set: 'devices'
[    2.340378] kobject: 'memory1' (ffff88000d01e8d0): kobject_uevent_env
[    2.348284] kobject: 'memory1' (ffff88000d01e8d0): fill_kobj_path: path = '/devices/system/memory/memory1'
[    2.441196] kobject: 'kernel' (ffff88000d0144c0): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    2.454618] kobject: 'power' (ffff88000d014500): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    2.465505] kobject: 'debug' (ffff88000d014540): kobject_add_internal: parent: 'kernel', set: '<NULL>'
[    2.470731] kobject: 'security' (ffff88000d014580): kobject_add_internal: parent: 'kernel', set: '<NULL>'
[    2.478264] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    2.524180] NET: Registered protocol family 16
[    2.536560] kobject: 'bdi' (ffff88000d066448): kobject_add_internal: parent: 'class', set: 'class'
[    2.540463] kobject: 'bdi' (ffff88000d066448): kobject_uevent_env
[    2.551656] kobject: 'bdi' (ffff88000d066448): fill_kobj_path: path = '/class/bdi'
[    2.570000] kobject: 'pci_bus' (ffff88000d066848): kobject_add_internal: parent: 'class', set: 'class'
[    2.570587] kobject: 'pci_bus' (ffff88000d066848): kobject_uevent_env
[    2.582929] kobject: 'pci_bus' (ffff88000d066848): fill_kobj_path: path = '/class/pci_bus'
[    2.591833] kobject: 'pci' (ffff88000d066c48): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.601437] kobject: 'pci' (ffff88000d066c48): kobject_uevent_env
[    2.611060] kobject: 'pci' (ffff88000d066c48): fill_kobj_path: path = '/bus/pci'
[    2.618510] kobject: 'devices' (ffff88000d1e2108): kobject_add_internal: parent: 'pci', set: '<NULL>'
[    2.620584] kobject: 'devices' (ffff88000d1e2108): kobject_uevent_env
[    2.630199] kobject: 'devices' (ffff88000d1e2108): kobject_uevent_env: filter function caused the event to drop!
[    2.638294] kobject: 'drivers' (ffff88000d1e21c8): kobject_add_internal: parent: 'pci', set: '<NULL>'
[    2.640799] kobject: 'drivers' (ffff88000d1e21c8): kobject_uevent_env
[    2.650127] kobject: 'drivers' (ffff88000d1e21c8): kobject_uevent_env: filter function caused the event to drop!
[    2.662349] kobject: 'rapidio' (ffffffff821709f0): kobject_add_internal: parent: 'devices', set: 'devices'
[    2.675177] kobject: 'rapidio' (ffffffff821709f0): kobject_uevent_env
[    2.680098] kobject: 'rapidio' (ffffffff821709f0): kobject_uevent_env: filter function caused the event to drop!
[    2.688942] kobject: 'rapidio' (ffff88000d067048): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.690707] kobject: 'rapidio' (ffff88000d067048): kobject_uevent_env
[    2.702914] kobject: 'rapidio' (ffff88000d067048): fill_kobj_path: path = '/bus/rapidio'
[    2.711397] kobject: 'devices' (ffff88000d1e2288): kobject_add_internal: parent: 'rapidio', set: '<NULL>'
[    2.720708] kobject: 'devices' (ffff88000d1e2288): kobject_uevent_env
[    2.725371] kobject: 'devices' (ffff88000d1e2288): kobject_uevent_env: filter function caused the event to drop!
[    2.730560] kobject: 'drivers' (ffff88000d1e2348): kobject_add_internal: parent: 'rapidio', set: '<NULL>'
[    2.740832] kobject: 'drivers' (ffff88000d1e2348): kobject_uevent_env
[    2.746184] kobject: 'drivers' (ffff88000d1e2348): kobject_uevent_env: filter function caused the event to drop!
[    2.752600] kobject: 'lcd' (ffff88000d067448): kobject_add_internal: parent: 'class', set: 'class'
[    2.760696] kobject: 'lcd' (ffff88000d067448): kobject_uevent_env
[    2.771763] kobject: 'lcd' (ffff88000d067448): fill_kobj_path: path = '/class/lcd'
[    2.779705] kobject: 'tty' (ffff88000d067848): kobject_add_internal: parent: 'class', set: 'class'
[    2.780600] kobject: 'tty' (ffff88000d067848): kobject_uevent_env
[    2.792816] kobject: 'tty' (ffff88000d067848): fill_kobj_path: path = '/class/tty'
[    2.801066] kobject: 'vtconsole' (ffff88000d067c48): kobject_add_internal: parent: 'class', set: 'class'
[    2.807018] kobject: 'vtconsole' (ffff88000d067c48): kobject_uevent_env
[    2.812648] kobject: 'vtconsole' (ffff88000d067c48): fill_kobj_path: path = '/class/vtconsole'
[    2.823379] kobject: 'virtual' (ffff88000d0145c0): kobject_add_internal: parent: 'devices', set: '<NULL>'
[    2.832315] kobject: 'vtconsole' (ffff88000d050720): kobject_add_internal: parent: 'virtual', set: '(null)'
[    2.840953] kobject: 'vtcon0' (ffff88000d208010): kobject_add_internal: parent: 'vtconsole', set: 'devices'
[    2.856557] kobject: 'vtcon0' (ffff88000d208010): kobject_uevent_env
[    2.863584] kobject: 'vtcon0' (ffff88000d208010): fill_kobj_path: path = '/devices/virtual/vtconsole/vtcon0'
[    2.882285] kobject: 'spi' (ffff88000d208448): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.889563] kobject: 'spi' (ffff88000d208448): kobject_uevent_env
[    2.892667] kobject: 'spi' (ffff88000d208448): fill_kobj_path: path = '/bus/spi'
[    2.901292] kobject: 'devices' (ffff88000d1e2408): kobject_add_internal: parent: 'spi', set: '<NULL>'
[    2.910565] kobject: 'devices' (ffff88000d1e2408): kobject_uevent_env
[    2.916018] kobject: 'devices' (ffff88000d1e2408): kobject_uevent_env: filter function caused the event to drop!
[    2.920476] kobject: 'drivers' (ffff88000d1e24c8): kobject_add_internal: parent: 'spi', set: '<NULL>'
[    2.930784] kobject: 'drivers' (ffff88000d1e24c8): kobject_uevent_env
[    2.936232] kobject: 'drivers' (ffff88000d1e24c8): kobject_uevent_env: filter function caused the event to drop!
[    2.942627] kobject: 'spi_master' (ffff88000d208848): kobject_add_internal: parent: 'class', set: 'class'
[    2.950775] kobject: 'spi_master' (ffff88000d208848): kobject_uevent_env
[    2.962939] kobject: 'spi_master' (ffff88000d208848): fill_kobj_path: path = '/class/spi_master'
[    2.971741] kobject: 'hsi' (ffff88000d208c48): kobject_add_internal: parent: 'bus', set: 'bus'
[    2.980601] kobject: 'hsi' (ffff88000d208c48): kobject_uevent_env
[    2.987979] kobject: 'hsi' (ffff88000d208c48): fill_kobj_path: path = '/bus/hsi'
[    2.991311] kobject: 'devices' (ffff88000d1e2588): kobject_add_internal: parent: 'hsi', set: '<NULL>'
[    3.000561] kobject: 'devices' (ffff88000d1e2588): kobject_uevent_env
[    3.005487] kobject: 'devices' (ffff88000d1e2588): kobject_uevent_env: filter function caused the event to drop!
[    3.010456] kobject: 'drivers' (ffff88000d1e2648): kobject_add_internal: parent: 'hsi', set: '<NULL>'
[    3.021588] kobject: 'drivers' (ffff88000d1e2648): kobject_uevent_env
[    3.030084] kobject: 'drivers' (ffff88000d1e2648): kobject_uevent_env: filter function caused the event to drop!
[    3.041354] ACPI: bus type pci registered
[    3.045317] kobject: 'dma' (ffff88000d209048): kobject_add_internal: parent: 'class', set: 'class'
[    3.050638] kobject: 'dma' (ffff88000d209048): kobject_uevent_env
[    3.060307] kobject: 'dma' (ffff88000d209048): fill_kobj_path: path = '/class/dma'
[    3.072418] kobject: 'dmi' (ffff88000d209448): kobject_add_internal: parent: 'class', set: 'class'
[    3.079198] kobject: 'dmi' (ffff88000d209448): kobject_uevent_env
[    3.082632] kobject: 'dmi' (ffff88000d209448): fill_kobj_path: path = '/class/dmi'
[    3.092622] kobject: 'dmi' (ffff88000d050780): kobject_add_internal: parent: 'virtual', set: '(null)'
[    3.100772] kobject: 'id' (ffff88000d209810): kobject_add_internal: parent: 'dmi', set: 'devices'
[    3.121786] kobject: 'id' (ffff88000d209810): kobject_uevent_env
[    3.128577] kobject: 'id' (ffff88000d209810): fill_kobj_path: path = '/devices/virtual/dmi/id'
[    3.132211] PCI: Using configuration type 1 for base access
[    3.135628] kobject: 'cpu0' (ffff88000dc0b4d8): kobject_add_internal: parent: 'cpu', set: 'devices'
[    3.144823] kobject: 'cpu0' (ffff88000dc0b4d8): kobject_uevent_env
[    3.152897] kobject: 'cpu0' (ffff88000dc0b4d8): fill_kobj_path: path = '/devices/system/cpu/cpu0'
[    3.172355] kobject: 'cpu1' (ffff88000dd0b4d8): kobject_add_internal: parent: 'cpu', set: 'devices'
[    3.186899] kobject: 'cpu1' (ffff88000dd0b4d8): kobject_uevent_env
[    3.193009] kobject: 'cpu1' (ffff88000dd0b4d8): fill_kobj_path: path = '/devices/system/cpu/cpu1'
[    3.211022] kobject: 'module' (ffff88000d1e2708): kobject_add_internal: parent: '<NULL>', set: '<NULL>'
[    3.218820] kobject: 'module' (ffff88000d1e2708): kobject_uevent_env
[    3.220111] kobject: 'module' (ffff88000d1e2708): kobject_uevent_env: attempted to send uevent without kset!
[    3.230685] kobject: 'xz_dec' (ffff88000d0507e0): kobject_add_internal: parent: 'module', set: 'module'
[    3.240466] kobject: 'xz_dec' (ffff88000d0507e0): kobject_uevent_env
[    3.248066] kobject: 'xz_dec' (ffff88000d0507e0): fill_kobj_path: path = '/module/xz_dec'
[    3.251409] kobject: 'xz_dec_test' (ffff88000d050840): kobject_add_internal: parent: 'module', set: 'module'
[    3.261052] kobject: 'xz_dec_test' (ffff88000d050840): kobject_uevent_env
[    3.272915] kobject: 'xz_dec_test' (ffff88000d050840): fill_kobj_path: path = '/module/xz_dec_test'
[    3.280718] kobject: 'intel_mid_dma' (ffff88000d0508a0): kobject_add_internal: parent: 'module', set: 'module'
[    3.288889] kobject: 'intel_mid_dma' (ffff88000d0508a0): kobject_uevent_env
[    3.292688] kobject: 'intel_mid_dma' (ffff88000d0508a0): fill_kobj_path: path = '/module/intel_mid_dma'
[    3.301345] kobject: 'tpm' (ffff88000d050900): kobject_add_internal: parent: 'module', set: 'module'
[    3.310846] kobject: 'tpm' (ffff88000d050900): kobject_uevent_env
[    3.320200] kobject: 'tpm' (ffff88000d050900): fill_kobj_path: path = '/module/tpm'
[    3.327105] kobject: 'tpm_tis' (ffff88000d050960): kobject_add_internal: parent: 'module', set: 'module'
[    3.330928] kobject: 'tpm_tis' (ffff88000d050960): kobject_uevent_env
[    3.342185] kobject: 'tpm_tis' (ffff88000d050960): fill_kobj_path: path = '/module/tpm_tis'
[    3.350000] kobject: 'phantom' (ffff88000d0509c0): kobject_add_internal: parent: 'module', set: 'module'
[    3.350875] kobject: 'phantom' (ffff88000d0509c0): kobject_uevent_env
[    3.362791] kobject: 'phantom' (ffff88000d0509c0): fill_kobj_path: path = '/module/phantom'
[    3.371300] kobject: 'hpilo' (ffff88000d050a20): kobject_add_internal: parent: 'module', set: 'module'
[    3.381044] kobject: 'hpilo' (ffff88000d050a20): kobject_uevent_env
[    3.388710] kobject: 'hpilo' (ffff88000d050a20): fill_kobj_path: path = '/module/hpilo'
[    3.391439] kobject: 'ti_dac7512' (ffff88000d050a80): kobject_add_internal: parent: 'module', set: 'module'
[    3.400986] kobject: 'ti_dac7512' (ffff88000d050a80): kobject_uevent_env
[    3.412931] kobject: 'ti_dac7512' (ffff88000d050a80): fill_kobj_path: path = '/module/ti_dac7512'
[    3.421577] kobject: 'timberdale' (ffff88000d050ae0): kobject_add_internal: parent: 'module', set: 'module'
[    3.430805] kobject: 'timberdale' (ffff88000d050ae0): kobject_uevent_env
[    3.438531] kobject: 'timberdale' (ffff88000d050ae0): fill_kobj_path: path = '/module/timberdale'
[    3.441530] kobject: 'cp210x' (ffff88000d050b40): kobject_add_internal: parent: 'module', set: 'module'
[    3.451839] kobject: 'cp210x' (ffff88000d050b40): kobject_uevent_env
[    3.462831] kobject: 'cp210x' (ffff88000d050b40): fill_kobj_path: path = '/module/cp210x'
[    3.470846] kobject: 'cypress_m8' (ffff88000d050ba0): kobject_add_internal: parent: 'module', set: 'module'
[    3.478533] kobject: 'cypress_m8' (ffff88000d050ba0): kobject_uevent_env
[    3.482228] kobject: 'cypress_m8' (ffff88000d050ba0): fill_kobj_path: path = '/module/cypress_m8'
[    3.491159] kobject: 'usb_wwan' (ffff88000d050c00): kobject_add_internal: parent: 'module', set: 'module'
[    3.497637] kobject: 'usb_wwan' (ffff88000d050c00): kobject_uevent_env
[    3.502838] kobject: 'usb_wwan' (ffff88000d050c00): fill_kobj_path: path = '/module/usb_wwan'
[    3.511664] kobject: 'ti_usb_3410_5052' (ffff88000d050c60): kobject_add_internal: parent: 'module', set: 'module'
[    3.521193] kobject: 'ti_usb_3410_5052' (ffff88000d050c60): kobject_uevent_env
[    3.530972] kobject: 'ti_usb_3410_5052' (ffff88000d050c60): fill_kobj_path: path = '/module/ti_usb_3410_5052'
[    3.540310] kobject: 'ldusb' (ffff88000d050cc0): kobject_add_internal: parent: 'module', set: 'module'
[    3.548772] kobject: 'ldusb' (ffff88000d050cc0): kobject_uevent_env
[    3.552619] kobject: 'ldusb' (ffff88000d050cc0): fill_kobj_path: path = '/module/ldusb'
[    3.561399] kobject: 'cxacru' (ffff88000d050d20): kobject_add_internal: parent: 'module', set: 'module'
[    3.571117] kobject: 'cxacru' (ffff88000d050d20): kobject_uevent_env
[    3.578475] kobject: 'cxacru' (ffff88000d050d20): fill_kobj_path: path = '/module/cxacru'
[    3.581522] kobject: 'usbatm' (ffff88000d050d80): kobject_add_internal: parent: 'module', set: 'module'
[    3.590999] kobject: 'usbatm' (ffff88000d050d80): kobject_uevent_env
[    3.602333] kobject: 'usbatm' (ffff88000d050d80): fill_kobj_path: path = '/module/usbatm'
[    3.610000] kobject: 'xusbatm' (ffff88000d050de0): kobject_add_internal: parent: 'module', set: 'module'
[    3.610872] kobject: 'xusbatm' (ffff88000d050de0): kobject_uevent_env
[    3.622754] kobject: 'xusbatm' (ffff88000d050de0): fill_kobj_path: path = '/module/xusbatm'
[    3.631572] kobject: 'input_polldev' (ffff88000d050e40): kobject_add_internal: parent: 'module', set: 'module'
[    3.641311] kobject: 'input_polldev' (ffff88000d050e40): kobject_uevent_env
[    3.650738] kobject: 'input_polldev' (ffff88000d050e40): fill_kobj_path: path = '/module/input_polldev'
[    3.659540] kobject: 'rtc_ds1553' (ffff88000d050ea0): kobject_add_internal: parent: 'module', set: 'module'
[    3.661203] kobject: 'rtc_ds1553' (ffff88000d050ea0): kobject_uevent_env
[    3.672957] kobject: 'rtc_ds1553' (ffff88000d050ea0): fill_kobj_path: path = '/module/rtc_ds1553'
[    3.681632] kobject: 'rtc_ds1742' (ffff88000d050f00): kobject_add_internal: parent: 'module', set: 'module'
[    3.691002] kobject: 'rtc_ds1742' (ffff88000d050f00): kobject_uevent_env
[    3.701644] kobject: 'rtc_ds1742' (ffff88000d050f00): fill_kobj_path: path = '/module/rtc_ds1742'
[    3.710000] kobject: 'rtc_pcf2123' (ffff88000d050f60): kobject_add_internal: parent: 'module', set: 'module'
[    3.711133] kobject: 'rtc_pcf2123' (ffff88000d050f60): kobject_uevent_env
[    3.723036] kobject: 'rtc_pcf2123' (ffff88000d050f60): fill_kobj_path: path = '/module/rtc_pcf2123'
[    3.733126] kobject: 'mem2mem_testdev' (ffff88000d205000): kobject_add_internal: parent: 'module', set: 'module'
[    3.741173] kobject: 'mem2mem_testdev' (ffff88000d205000): kobject_uevent_env
[    3.752473] kobject: 'mem2mem_testdev' (ffff88000d205000): fill_kobj_path: path = '/module/mem2mem_testdev'
[    3.761722] kobject: 'radio_usb_si470x' (ffff88000d205060): kobject_add_internal: parent: 'module', set: 'module'
[    3.771207] kobject: 'radio_usb_si470x' (ffff88000d205060): kobject_uevent_env
[    3.782339] kobject: 'radio_usb_si470x' (ffff88000d205060): fill_kobj_path: path = '/module/radio_usb_si470x'
[    3.791139] kobject: 'iTCO_wdt' (ffff88000d2050c0): kobject_add_internal: parent: 'module', set: 'module'
[    3.799801] kobject: 'iTCO_wdt' (ffff88000d2050c0): kobject_uevent_env
[    3.802794] kobject: 'iTCO_wdt' (ffff88000d2050c0): fill_kobj_path: path = '/module/iTCO_wdt'
[    3.811529] kobject: 'hpwdt' (ffff88000d205120): kobject_add_internal: parent: 'module', set: 'module'
[    3.820898] kobject: 'hpwdt' (ffff88000d205120): kobject_uevent_env
[    3.827834] kobject: 'hpwdt' (ffff88000d205120): fill_kobj_path: path = '/module/hpwdt'
[    3.831524] kobject: 'sbc8360' (ffff88000d205180): kobject_add_internal: parent: 'module', set: 'module'
[    3.840909] kobject: 'sbc8360' (ffff88000d205180): kobject_uevent_env
[    3.846465] kobject: 'sbc8360' (ffff88000d205180): fill_kobj_path: path = '/module/sbc8360'
[    3.851271] kobject: 'hci_vhci' (ffff88000d2051e0): kobject_add_internal: parent: 'module', set: 'module'
[    3.861085] kobject: 'hci_vhci' (ffff88000d2051e0): kobject_uevent_env
[    3.870868] kobject: 'hci_vhci' (ffff88000d2051e0): fill_kobj_path: path = '/module/hci_vhci'
[    3.878888] kobject: 'bcm203x' (ffff88000d205240): kobject_add_internal: parent: 'module', set: 'module'
[    3.881011] kobject: 'bcm203x' (ffff88000d205240): kobject_uevent_env
[    3.892866] kobject: 'bcm203x' (ffff88000d205240): fill_kobj_path: path = '/module/bcm203x'
[    3.901640] kobject: 'btusb' (ffff88000d2052a0): kobject_add_internal: parent: 'module', set: 'module'
[    3.910632] kobject: 'btusb' (ffff88000d2052a0): kobject_uevent_env
[    3.917830] kobject: 'btusb' (ffff88000d2052a0): fill_kobj_path: path = '/module/btusb'
[    3.921693] kobject: 'btmrvl' (ffff88000d205300): kobject_add_internal: parent: 'module', set: 'module'
[    3.931028] kobject: 'btmrvl' (ffff88000d205300): kobject_uevent_env
[    3.942055] kobject: 'btmrvl' (ffff88000d205300): fill_kobj_path: path = '/module/btmrvl'
[    3.950323] kobject: 'efivars' (ffff88000d205360): kobject_add_internal: parent: 'module', set: 'module'
[    3.959099] kobject: 'efivars' (ffff88000d205360): kobject_uevent_env
[    3.962953] kobject: 'efivars' (ffff88000d205360): fill_kobj_path: path = '/module/efivars'
[    3.971736] kobject: 'hid_hyperv' (ffff88000d2053c0): kobject_add_internal: parent: 'module', set: 'module'
[    3.981161] kobject: 'hid_hyperv' (ffff88000d2053c0): kobject_uevent_env
[    3.992663] kobject: 'hid_hyperv' (ffff88000d2053c0): fill_kobj_path: path = '/module/hid_hyperv'
[    4.001419] kobject: 'hv_vmbus' (ffff88000d205420): kobject_add_internal: parent: 'module', set: 'module'
[    4.010458] kobject: 'hv_vmbus' (ffff88000d205420): kobject_uevent_env
[    4.018266] kobject: 'hv_vmbus' (ffff88000d205420): fill_kobj_path: path = '/module/hv_vmbus'
[    4.021811] kobject: 'bridge' (ffff88000d205480): kobject_add_internal: parent: 'module', set: 'module'
[    4.031089] kobject: 'bridge' (ffff88000d205480): kobject_uevent_env
[    4.042762] kobject: 'bridge' (ffff88000d205480): fill_kobj_path: path = '/module/bridge'
[    4.051255] kobject: 'bluetooth' (ffff88000d2054e0): kobject_add_internal: parent: 'module', set: 'module'
[    4.059900] kobject: 'bluetooth' (ffff88000d2054e0): kobject_uevent_env
[    4.063141] kobject: 'bluetooth' (ffff88000d2054e0): fill_kobj_path: path = '/module/bluetooth'
[    4.072006] kobject: 'rfcomm' (ffff88000d205540): kobject_add_internal: parent: 'module', set: 'module'
[    4.081260] kobject: 'rfcomm' (ffff88000d205540): kobject_uevent_env
[    4.092752] kobject: 'rfcomm' (ffff88000d205540): fill_kobj_path: path = '/module/rfcomm'
[    4.101737] kobject: 'bnep' (ffff88000d2055a0): kobject_add_internal: parent: 'module', set: 'module'
[    4.111042] kobject: 'bnep' (ffff88000d2055a0): kobject_uevent_env
[    4.118051] kobject: 'bnep' (ffff88000d2055a0): fill_kobj_path: path = '/module/bnep'
[    4.121741] kobject: '8021q' (ffff88000d205600): kobject_add_internal: parent: 'module', set: 'module'
[    4.131978] kobject: '8021q' (ffff88000d205600): kobject_uevent_env
[    4.142862] kobject: '8021q' (ffff88000d205600): fill_kobj_path: path = '/module/8021q'
[    4.151546] kobject: 'kernel' (ffff88000d205660): kobject_add_internal: parent: 'module', set: 'module'
[    4.160361] kobject: 'kernel' (ffff88000d205660): kobject_uevent_env
[    4.167658] kobject: 'kernel' (ffff88000d205660): fill_kobj_path: path = '/module/kernel'
[    4.173570] kobject: 'kernel' (ffff88000d205660): kobject_uevent_env
[    4.182574] kobject: 'kernel' (ffff88000d205660): fill_kobj_path: path = '/module/kernel'
[    4.193326] kobject: 'kernel' (ffff88000d205660): kobject_uevent_env
[    4.199457] kobject: 'kernel' (ffff88000d205660): fill_kobj_path: path = '/module/kernel'
[    4.201808] kobject: 'printk' (ffff88000d2056c0): kobject_add_internal: parent: 'module', set: 'module'
[    4.212248] kobject: 'printk' (ffff88000d2056c0): kobject_uevent_env
[    4.222782] kobject: 'printk' (ffff88000d2056c0): fill_kobj_path: path = '/module/printk'
[    4.233523] kobject: 'printk' (ffff88000d2056c0): kobject_uevent_env
[    4.241133] kobject: 'printk' (ffff88000d2056c0): fill_kobj_path: path = '/module/printk'
[    4.252083] kobject: 'printk' (ffff88000d2056c0): kobject_uevent_env
[    4.259710] kobject: 'printk' (ffff88000d2056c0): fill_kobj_path: path = '/module/printk'
[    4.271077] kobject: 'printk' (ffff88000d2056c0): kobject_uevent_env
[    4.278705] kobject: 'printk' (ffff88000d2056c0): fill_kobj_path: path = '/module/printk'
[    4.281799] kobject: 'lockdep' (ffff88000d205720): kobject_add_internal: parent: 'module', set: 'module'
[    4.291790] kobject: 'lockdep' (ffff88000d205720): kobject_uevent_env
[    4.302921] kobject: 'lockdep' (ffff88000d205720): fill_kobj_path: path = '/module/lockdep'
[    4.312090] kobject: 'spurious' (ffff88000d205780): kobject_add_internal: parent: 'module', set: 'module'
[    4.321674] kobject: 'spurious' (ffff88000d205780): kobject_uevent_env
[    4.329445] kobject: 'spurious' (ffff88000d205780): fill_kobj_path: path = '/module/spurious'
[    4.333817] kobject: 'spurious' (ffff88000d205780): kobject_uevent_env
[    4.342951] kobject: 'spurious' (ffff88000d205780): fill_kobj_path: path = '/module/spurious'
[    4.351957] kobject: 'rcutree' (ffff88000d2057e0): kobject_add_internal: parent: 'module', set: 'module'
[    4.361992] kobject: 'rcutree' (ffff88000d2057e0): kobject_uevent_env
[    4.373028] kobject: 'rcutree' (ffff88000d2057e0): fill_kobj_path: path = '/module/rcutree'
[    4.383822] kobject: 'rcutree' (ffff88000d2057e0): kobject_uevent_env
[    4.391465] kobject: 'rcutree' (ffff88000d2057e0): fill_kobj_path: path = '/module/rcutree'
[    4.400000] kobject: 'fscache' (ffff88000d205840): kobject_add_internal: parent: 'module', set: 'module'
[    4.410499] kobject: 'fscache' (ffff88000d205840): kobject_uevent_env
[    4.418447] kobject: 'fscache' (ffff88000d205840): fill_kobj_path: path = '/module/fscache'
[    4.423508] kobject: 'fscache' (ffff88000d205840): kobject_uevent_env
[    4.433052] kobject: 'fscache' (ffff88000d205840): fill_kobj_path: path = '/module/fscache'
[    4.444553] kobject: 'fscache' (ffff88000d205840): kobject_uevent_env
[    4.452970] kobject: 'fscache' (ffff88000d205840): fill_kobj_path: path = '/module/fscache'
[    4.462103] kobject: 'cachefiles' (ffff88000d2058a0): kobject_add_internal: parent: 'module', set: 'module'
[    4.473056] kobject: 'cachefiles' (ffff88000d2058a0): kobject_uevent_env
[    4.481378] kobject: 'cachefiles' (ffff88000d2058a0): fill_kobj_path: path = '/module/cachefiles'
[    4.490000] kobject: 'pstore' (ffff88000d205900): kobject_add_internal: parent: 'module', set: 'module'
[    4.491983] kobject: 'pstore' (ffff88000d205900): kobject_uevent_env
[    4.502811] kobject: 'pstore' (ffff88000d205900): fill_kobj_path: path = '/module/pstore'
[    4.511957] kobject: 'apparmor' (ffff88000d205960): kobject_add_internal: parent: 'module', set: 'module'
[    4.521638] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.531826] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.541439] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.546996] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.553363] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.561785] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.573563] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.581133] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.595267] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.603237] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.616439] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.622937] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.641126] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.648788] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.663844] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.671892] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.690383] kobject: 'apparmor' (ffff88000d205960): kobject_uevent_env
[    4.697173] kobject: 'apparmor' (ffff88000d205960): fill_kobj_path: path = '/module/apparmor'
[    4.702018] kobject: 'block' (ffff88000d205a20): kobject_add_internal: parent: 'module', set: 'module'
[    4.711744] kobject: 'block' (ffff88000d205a20): kobject_uevent_env
[    4.722397] kobject: 'block' (ffff88000d205a20): fill_kobj_path: path = '/module/block'
[    4.730626] kobject: 'gpio_bt8xx' (ffff88000d205a80): kobject_add_internal: parent: 'module', set: 'module'
[    4.739214] kobject: 'gpio_bt8xx' (ffff88000d205a80): kobject_uevent_env
[    4.742894] kobject: 'gpio_bt8xx' (ffff88000d205a80): fill_kobj_path: path = '/module/gpio_bt8xx'
[    4.752177] kobject: 'gpio_cs5535' (ffff88000d205ae0): kobject_add_internal: parent: 'module', set: 'module'
[    4.762026] kobject: 'gpio_cs5535' (ffff88000d205ae0): kobject_uevent_env
[    4.773068] kobject: 'gpio_cs5535' (ffff88000d205ae0): fill_kobj_path: path = '/module/gpio_cs5535'
[    4.782173] kobject: 'gpio_ich' (ffff88000d205b40): kobject_add_internal: parent: 'module', set: 'module'
[    4.793305] kobject: 'gpio_ich' (ffff88000d205b40): kobject_uevent_env
[    4.802379] kobject: 'gpio_ich' (ffff88000d205b40): fill_kobj_path: path = '/module/gpio_ich'
[    4.811479] kobject: 'pcie_aspm' (ffff88000d205ba0): kobject_add_internal: parent: 'module', set: 'module'
[    4.820769] kobject: 'pcie_aspm' (ffff88000d205ba0): kobject_uevent_env
[    4.828267] kobject: 'pcie_aspm' (ffff88000d205ba0): fill_kobj_path: path = '/module/pcie_aspm'
[    4.831751] kobject: 'acpi' (ffff88000d205c00): kobject_add_internal: parent: 'module', set: 'module'
[    4.841900] kobject: 'acpi' (ffff88000d205c00): kobject_uevent_env
[    4.851830] kobject: 'acpi' (ffff88000d205c00): fill_kobj_path: path = '/module/acpi'
[    4.861329] kobject: 'acpi' (ffff88000d205c00): kobject_uevent_env
[    4.868407] kobject: 'acpi' (ffff88000d205c00): fill_kobj_path: path = '/module/acpi'
[    4.874366] kobject: 'acpi' (ffff88000d205c00): kobject_uevent_env
[    4.882703] kobject: 'acpi' (ffff88000d205c00): fill_kobj_path: path = '/module/acpi'
[    4.893698] kobject: 'acpi' (ffff88000d205c00): kobject_uevent_env
[    4.900948] kobject: 'acpi' (ffff88000d205c00): fill_kobj_path: path = '/module/acpi'
[    4.911506] kobject: 'acpi' (ffff88000d205c00): kobject_uevent_env
[    4.919586] kobject: 'acpi' (ffff88000d205c00): fill_kobj_path: path = '/module/acpi'
[    4.922010] kobject: 'pci_slot' (ffff88000d205c60): kobject_add_internal: parent: 'module', set: 'module'
[    4.932096] kobject: 'pci_slot' (ffff88000d205c60): kobject_uevent_env
[    4.943270] kobject: 'pci_slot' (ffff88000d205c60): fill_kobj_path: path = '/module/pci_slot'
[    4.952108] kobject: 'battery' (ffff88000d205cc0): kobject_add_internal: parent: 'module', set: 'module'
[    4.962101] kobject: 'battery' (ffff88000d205cc0): kobject_uevent_env
[    4.971409] kobject: 'battery' (ffff88000d205cc0): fill_kobj_path: path = '/module/battery'
[    4.980227] kobject: 'sbs' (ffff88000d205d20): kobject_add_internal: parent: 'module', set: 'module'
[    4.988942] kobject: 'sbs' (ffff88000d205d20): kobject_uevent_env
[    4.992697] kobject: 'sbs' (ffff88000d205d20): fill_kobj_path: path = '/module/sbs'

--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.5.0-rc5+"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.5.0-rc5 Kernel Configuration
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
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set
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
CONFIG_GENERIC_IRQ_CHIP=y
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
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_CGROUP_MEM_RES_CTLR=y
# CONFIG_CGROUP_MEM_RES_CTLR_SWAP is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
# CONFIG_NET_NS is not set
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
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
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_PROFILING=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
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
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_CLOCK=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
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
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
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
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

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
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_CAN_PM_TRACE=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_EINJ is not set
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_DEBUG=y
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
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
# CONFIG_PCMCIA is not set
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
# CONFIG_HOTPLUG_PCI is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
# CONFIG_RAPIDIO_TSI57X is not set
# CONFIG_RAPIDIO_CPS_XX is not set
# CONFIG_RAPIDIO_TSI568 is not set
# CONFIG_RAPIDIO_CPS_GEN2 is not set
CONFIG_RAPIDIO_TSI500=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_NET_KEY=y
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_NETFILTER_XTABLES=y
CONFIG_BRIDGE_NF_EBTABLES=y
# CONFIG_BRIDGE_EBT_BROUTE is not set
# CONFIG_BRIDGE_EBT_T_FILTER is not set
# CONFIG_BRIDGE_EBT_T_NAT is not set
# CONFIG_BRIDGE_EBT_802_3 is not set
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
# CONFIG_BRIDGE_EBT_IP is not set
# CONFIG_BRIDGE_EBT_LIMIT is not set
# CONFIG_BRIDGE_EBT_MARK is not set
# CONFIG_BRIDGE_EBT_PKTTYPE is not set
CONFIG_BRIDGE_EBT_STP=y
# CONFIG_BRIDGE_EBT_VLAN is not set
# CONFIG_BRIDGE_EBT_DNAT is not set
CONFIG_BRIDGE_EBT_MARK_T=y
# CONFIG_BRIDGE_EBT_REDIRECT is not set
# CONFIG_BRIDGE_EBT_SNAT is not set
# CONFIG_BRIDGE_EBT_LOG is not set
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
CONFIG_ATM=y
CONFIG_ATM_LANE=y
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_BRIDGE=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_DECNET=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
# CONFIG_IPDDP is not set
CONFIG_PHONET=y
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
CONFIG_NETROM=y
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
# CONFIG_6PACK is not set
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
# CONFIG_BAYCOM_PAR is not set
# CONFIG_YAM is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
# CONFIG_CAN_DEV is not set
CONFIG_CAN_DEBUG_DEVICES=y
# CONFIG_IRDA is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
# CONFIG_BT_BNEP_PROTO_FILTER is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIBCM203X=y
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
# CONFIG_BT_ATH3K is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_INPUT=y
CONFIG_NET_9P=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
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
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_SPI=y
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
# CONFIG_MTD_CHAR is not set
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=y
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
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
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_GPIO_ADDR is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SST25L is not set
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
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_UBI is not set
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS, INET or CONNECTOR not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=8
CONFIG_BLK_DEV_RAM_SIZE=102400
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_CS5535_MFGPT is not set
CONFIG_HP_ILO=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y

#
# EEPROM support
#
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set

#
# Altera FPGA firmware download module
#
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
# CONFIG_IDE_GD is not set
CONFIG_BLK_DEV_DELKIN=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
CONFIG_BLK_DEV_IDEACPI=y
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
CONFIG_BLK_DEV_OFFBOARD=y
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=y
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
CONFIG_BLK_DEV_CS5530=y
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
CONFIG_BLK_DEV_SC1200=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
# CONFIG_SCSI is not set
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
# CONFIG_ISDN_CAPI is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_DUMMYLL=y
CONFIG_GIGASET_BASE=y
# CONFIG_GIGASET_M105 is not set
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
# CONFIG_MISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_GAMEPORT is not set

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
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

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
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX3107 is not set
CONFIG_SERIAL_MFD_HSU=y
CONFIG_SERIAL_MFD_HSU_CONSOLE=y
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_PRINTER is not set
# CONFIG_PPDEV is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_NVRAM is not set
CONFIG_R3964=y
CONFIG_APPLICOM=y
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
CONFIG_DEVPORT=y
# CONFIG_I2C is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_TOPCLIFF_PCH=y
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_TLE62X0=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#

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
CONFIG_GPIOLIB=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
CONFIG_GPIO_VX855=y

#
# I2C GPIO expanders:
#
CONFIG_GPIO_TPS65912=y

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_BT8XX=y
# CONFIG_GPIO_LANGWELL is not set
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_TIMBERDALE is not set
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MCP23S08=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_74X164=y

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
# CONFIG_W1_MASTER_DS2490 is not set
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_CHARGER_ISP1704=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_GPIO=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
CONFIG_ALIM7101_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
# CONFIG_SBC_FITPC2_WATCHDOG is not set
CONFIG_EUROTECH_WDT=y
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_HP_WATCHDOG=y
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
CONFIG_W83697UG_WDT=y
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_ABX500_CORE is not set
CONFIG_EZX_PCAP=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_TIMBERDALE=y
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_VX855=y
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2_COMMON=y
CONFIG_DVB_CORE=y
CONFIG_VIDEO_MEDIA=y

#
# Multimedia drivers
#
# CONFIG_RC_CORE is not set
CONFIG_VIDEO_V4L2=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
# CONFIG_VIDEO_CAPTURE_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_MEM2MEM_TESTDEV=y
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=y
CONFIG_USB_SI470X=y
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
CONFIG_USB_KEENE=y

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_RADIO_WL128X is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_CAPTURE_DRIVERS is not set

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
# CONFIG_DRM is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
CONFIG_LCD_TDO24M=y
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
# CONFIG_BACKLIGHT_CLASS_DEVICE is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_HRTIMER=y
# CONFIG_SND_SEQ_HRTIMER_DEFAULT is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
# CONFIG_SND_DRIVERS is not set
# CONFIG_SND_PCI is not set
CONFIG_SND_SPI=y
# CONFIG_SND_USB is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_I2C_AND_SPI=y
CONFIG_SND_SOC_ALL_CODECS=y
CONFIG_SND_SOC_AD1836=y
CONFIG_SND_SOC_AD193X=y
CONFIG_SND_SOC_AD73311=y
CONFIG_SND_SOC_ADAV80X=y
CONFIG_SND_SOC_ADS117X=y
CONFIG_SND_SOC_AK4104=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CX20442=y
CONFIG_SND_SOC_JZ4740_CODEC=y
CONFIG_SND_SOC_L3=y
CONFIG_SND_SOC_DFBMCS320=y
CONFIG_SND_SOC_PCM3008=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_TLV320AIC26=y
CONFIG_SND_SOC_UDA134X=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8727=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8770=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8983=y
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_WM8988=y
CONFIG_SND_SOC_WM8995=y
# CONFIG_SND_SIMPLE_CARD is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_HYPERV_MOUSE=y

#
# USB HID support
#
# CONFIG_USB_HID is not set
# CONFIG_HID_PID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_DEBUG=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=y
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_CHIPIDEA is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_EZUSB=y
# CONFIG_USB_SERIAL_GENERIC is not set
# CONFIG_USB_SERIAL_AIRCABLE is not set
CONFIG_USB_SERIAL_ARK3116=y
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_CH341 is not set
CONFIG_USB_SERIAL_WHITEHEAT=y
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
# CONFIG_USB_SERIAL_EMPEG is not set
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_FUNSOFT=y
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MOTOROLA=y
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=y
# CONFIG_USB_SERIAL_OTI6858 is not set
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
# CONFIG_USB_SERIAL_SPCP8X5 is not set
# CONFIG_USB_SERIAL_HP4X is not set
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=y
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
CONFIG_USB_SERIAL_TI=y
# CONFIG_USB_SERIAL_CYBERJACK is not set
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
# CONFIG_USB_SERIAL_OPTION is not set
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
CONFIG_USB_SERIAL_ZIO=y
# CONFIG_USB_SERIAL_SSU100 is not set
CONFIG_USB_SERIAL_QT2=y
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y

#
# USB Physical Layer drivers
#
CONFIG_USB_ATM=y
# CONFIG_USB_SPEEDTOUCH is not set
CONFIG_USB_CXACRU=y
# CONFIG_USB_UEAGLEATM is not set
CONFIG_USB_XUSBATM=y
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_CLEVO_MAIL=y
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_INTEL_SS4200=y
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_TRIGGERS is not set

#
# LED Triggers
#
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_DS3234 is not set
CONFIG_RTC_DRV_PCF2123=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_TIMB_DMA=y
CONFIG_PCH_DMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set

#
# Virtio drivers
#
# CONFIG_VIRTIO_BALLOON is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
# CONFIG_HYPERV_UTILS is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
CONFIG_VIRT_DRIVERS=y
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
# CONFIG_IIO_BUFFER is not set
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Analog to digital converters
#

#
# Amplifiers
#
CONFIG_AD8366=y
# CONFIG_VME_BUS is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_SMI=y
# CONFIG_GOOGLE_MEMCONSOLE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
# CONFIG_EXT3_FS_XATTR is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT23 is not set
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
# CONFIG_EXT4_FS_SECURITY is not set
CONFIG_EXT4_DEBUG=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
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
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_HFSPLUS_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
# CONFIG_JFFS2_ZLIB is not set
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
CONFIG_JFFS2_RUBIN=y
CONFIG_JFFS2_CMODE_NONE=y
# CONFIG_JFFS2_CMODE_PRIORITY is not set
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZO=y
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_MAGIC_SYSRQ is not set
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_STATS is not set
CONFIG_DEBUG_PREEMPT=y
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_KOBJECT=y
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_VERBOSE=y
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_LKDTM=y
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
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
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DMA_API_DEBUG=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_KMEMCHECK=y
# CONFIG_KMEMCHECK_DISABLED_BY_DEFAULT is not set
# CONFIG_KMEMCHECK_ENABLED_BY_DEFAULT is not set
CONFIG_KMEMCHECK_ONESHOT_BY_DEFAULT=y
CONFIG_KMEMCHECK_QUEUE_SIZE=64
CONFIG_KMEMCHECK_SHADOW_COPY_SHIFT=5
CONFIG_KMEMCHECK_PARTIAL_OK=y
CONFIG_KMEMCHECK_BITOPS_OK=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_DEBUG_NMI_SELFTEST=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
CONFIG_SECURITY_YAMA=y
CONFIG_INTEGRITY=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_AUDIT=y
CONFIG_DEFAULT_SECURITY_APPARMOR=y
# CONFIG_DEFAULT_SECURITY_YAMA is not set
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="apparmor"
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y

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
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_DES is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

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
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
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
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_CRC8=y
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
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
CONFIG_DDR=y

--KsGdsel6WgEHnImy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
