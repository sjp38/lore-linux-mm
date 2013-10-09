Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id B47756B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 10:12:56 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so955835pbb.24
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 07:12:56 -0700 (PDT)
Date: Wed, 9 Oct 2013 22:12:17 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: 6e543d5780e fixed a boot hang
Message-ID: <20131009141217.GA24846@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

FYI, this commit seem to fix a boot hang problem here.

commit 6e543d5780e36ff5ee56c44d7e2e30db3457a7ed
Author: Lisa Du <cldu@marvell.com>
Date:   Wed Sep 11 14:22:36 2013 -0700

    mm: vmscan: fix do_try_to_free_pages() livelock


        [    1.394871] pci 0000:00:02.0: Boot video device
        [    1.395883] PCI: CLS 0 bytes, default 64

In parent commit, it will hang right here.

With this commit, it will continue to emit the below OOM messages
(which is not a surprise to me because the boot test runs in a small
memory KVM and the kconfig builds in lots of drivers).

        [    1.631892] swapper/0 invoked oom-killer: gfp_mask=0x2000d0, order=1, oom_score_adj=0
        [    1.633549] swapper/0 cpuset=/ mems_allowed=0
        [    1.634443] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.12.0-rc4-00019-g8b5ede6 #126
        [    1.635982] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
        [    1.637088]  0000000000000002 ffff88001dd41b28 ffffffff82c8d78f ffff88001ef7c040
        [    1.638955]  ffff88001dd41ba8 ffffffff82c8395f ffffffff83c54680 ffff88001dd41b60
        [    1.640830]  ffffffff810f3f06 0000000000001eb4 0000000000000246 ffff88001dd41b98
        [    1.642687] Call Trace:
        [    1.643313]  [<ffffffff82c8d78f>] dump_stack+0x54/0x74
        [    1.644331]  [<ffffffff82c8395f>] dump_header.isra.10+0x7a/0x1ba
        [    1.645443]  [<ffffffff810f3f06>] ? lock_release_holdtime.part.27+0x4c/0x50
        [    1.646685]  [<ffffffff810f795a>] ? lock_release+0x189/0x1d1
        [    1.647744]  [<ffffffff811530a8>] out_of_memory+0x39e/0x3ee
        [    1.648882]  [<ffffffff811579f5>] __alloc_pages_nodemask+0x668/0x7de
        [    1.650385]  [<ffffffff8118eb53>] kmem_getpages+0x75/0x16c
        [    1.651429]  [<ffffffff81190d20>] fallback_alloc+0x12c/0x1ea
        [    1.652528]  [<ffffffff810f38e8>] ? trace_hardirqs_off+0xd/0xf
        [    1.653627]  [<ffffffff81190be5>] ____cache_alloc_node+0x14a/0x159
        [    1.654783]  [<ffffffff817059fb>] ? dma_debug_init+0x1ef/0x29a
        [    1.655928]  [<ffffffff8119162c>] kmem_cache_alloc_trace+0x83/0x11a
        [    1.657108]  [<ffffffff817059fb>] dma_debug_init+0x1ef/0x29a
        [    1.658182]  [<ffffffff841ac38b>] pci_iommu_init+0x16/0x52
        [    1.659263]  [<ffffffff841ac375>] ? iommu_setup+0x27d/0x27d
        [    1.660342]  [<ffffffff810020d2>] do_one_initcall+0x93/0x137
        [    1.661415]  [<ffffffff810bd300>] ? param_set_charp+0x92/0xd8
        [    1.662503]  [<ffffffff810bd52e>] ? parse_args+0x189/0x247
        [    1.663555]  [<ffffffff8419fed1>] kernel_init_freeable+0x15e/0x1df
        [    1.664724]  [<ffffffff8419f729>] ? do_early_param+0x88/0x88
        [    1.665814]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb
        [    1.666824]  [<ffffffff82c77875>] kernel_init+0xe/0xdb
        [    1.667824]  [<ffffffff82cbc57c>] ret_from_fork+0x7c/0xb0
        [    1.668911]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb
        [    1.669925] Mem-Info:
        [    1.670508] Node 0 DMA per-cpu:

Thanks,
Fengguang

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-nfsroot-snb-22:20131008110042:x86_64-allyesdebian:3.12.0-rc4-00019-g8b5ede6:126"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.12.0-rc4-00019-g8b5ede6 (kbuild@inn) (gcc ve=
rsion 4.8.1 (Debian 4.8.1-8) ) #126 SMP Tue Oct 8 11:00:08 CST 2013
[    0.000000] Command line: hung_task_panic=3D1 rcutree.rcu_cpu_stall_time=
out=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug d=
ynamic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdi=
sk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nfsroot-=
snb-22::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,=
nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-queue/kvm/=
x86_64-allyesdebian/linus:master/.vmlinuz-8b5ede69d24db939f52b47effff2f6fe1=
e83e08b-20131008110028-9-snb branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86=
_64-allyesdebian/8b5ede69d24db939f52b47effff2f6fe1e83e08b/vmlinuz-3.12.0-rc=
4-00019-g8b5ede6
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x1fffe max_arch_pfn =3D 0x400000000
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
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at =
[ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x050be000, 0x050befff] PGTABLE
[    0.000000] BRK [0x050bf000, 0x050bffff] PGTABLE
[    0.000000] BRK [0x050c0000, 0x050c0fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1fc00000-0x1fdfffff]
[    0.000000]  [mem 0x1fc00000-0x1fdfffff] page 4k
[    0.000000] BRK [0x050c1000, 0x050c1fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1c000000-0x1fbfffff]
[    0.000000]  [mem 0x1c000000-0x1fbfffff] page 4k
[    0.000000] BRK [0x050c2000, 0x050c2fff] PGTABLE
[    0.000000] BRK [0x050c3000, 0x050c3fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1bffffff]
[    0.000000]  [mem 0x00100000-0x1bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x1fe00000-0x1fffdfff]
[    0.000000]  [mem 0x1fe00000-0x1fffdfff] page 4k
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127192(97%)
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe450 00034 (v01 BOCHS  BXPCRSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 00074 (v01 BOCHS  BXPCFACP 00000=
001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe490 011A9 (v01   BXPC   BXDSDT 00000=
001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 00040
[    0.000000] ACPI: SSDT 000000001ffff7a0 00796 (v01 BOCHS  BXPCSSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffff680 00080 (v01 BOCHS  BXPCAPIC 00000=
001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffff640 00038 (v01 BOCHS  BXPCHPET 00000=
001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1fff9000-0x1fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1fff1001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e40000=
0-ffff88001ebfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130972
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 126974 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 478 pages/cpu @ffff88001f000000 s1928536 r8=
192 d21160 u2097152
[    0.000000] pcpu-alloc: s1928536 r8192 d21160 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1fff1001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1f00e240
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128903
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3D=
debug dynamic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 promp=
t_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::n=
fsroot-snb-22::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=
=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-que=
ue/kvm/x86_64-allyesdebian/linus:master/.vmlinuz-8b5ede69d24db939f52b47efff=
f2f6fe1e83e08b-20131008110028-9-snb branch=3Dlinus/master BOOT_IMAGE=3D/ker=
nel/x86_64-allyesdebian/8b5ede69d24db939f52b47effff2f6fe1e83e08b/vmlinuz-3.=
12.0-rc4-00019-g8b5ede6
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 435476K/523888K available (29449K kernel code, 3864K=
 rwdata, 14028K rodata, 4400K init, 12908K bss, 88412K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:33024 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
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
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
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
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |
[    0.000000]                ww contexts mixing:  ok  |  ok  |
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]            spinlock nest unlocked:  ok  |
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:  ok  |  ok  |  ok  |
[    0.000000]                               try:  ok  |  ok  |  ok  |
[    0.000000]                             block:  ok  |  ok  |  ok  |
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2299.862 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 4599.72 Bogo=
MIPS (lpj=3D9199448)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.008445] Security Framework initialized
[    0.009342] AppArmor: AppArmor disabled by boot time parameter
[    0.010744] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.012228] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.013641] Mount-cache hash table entries: 256
[    0.017325] Initializing cgroup subsys devices
[    0.018307] Initializing cgroup subsys freezer
[    0.019274] Initializing cgroup subsys net_cls
[    0.020029] Initializing cgroup subsys blkio
[    0.021176] mce: CPU supports 10 MCE banks
[    0.022108] numa_add_cpu cpu 0 node 0: mask now 0
[    0.023085] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.023085] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.023085] tlb_flushall_shift: 6
[    0.024045] debug: unmapping init [mem 0xffffffff84414000-0xffffffff8442=
0fff]
[    0.029722] ACPI: Core revision 20130725
[    0.034764] ACPI: All ACPI Tables successfully acquired
[    0.036039] ftrace: allocating 115943 entries in 453 pages
[    0.068510] Getting VERSION: 50014
[    0.072015] Getting VERSION: 50014
[    0.072803] Getting ID: 0
[    0.073468] Getting ID: ff000000
[    0.074236] Getting LVT0: 8700
[    0.074967] Getting LVT1: 8400
[    0.076074] enabled ExtINT on CPU#0
[    0.080991] ENABLING IO-APIC IRQs
[    0.081764] init IO_APIC IRQs
[    0.082469]  apic 0 pin 0 not connected
[    0.084029] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.085689] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.087328] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.088029] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.089667] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.092029] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.093634] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.095237] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.096028] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.097653] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.100029] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.101654] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.104029] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.105658] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.107418] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.108025]  apic 0 pin 16 not connected
[    0.108860]  apic 0 pin 17 not connected
[    0.109759]  apic 0 pin 18 not connected
[    0.110592]  apic 0 pin 19 not connected
[    0.112006]  apic 0 pin 20 not connected
[    0.112842]  apic 0 pin 21 not connected
[    0.113701]  apic 0 pin 22 not connected
[    0.114631]  apic 0 pin 23 not connected
[    0.116157] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.117435] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.119688] Using local APIC timer interrupts.
[    0.119688] calibrating APIC timer ...
[    0.124000] ... lapic delta =3D 6250126
[    0.124000] ... PM-Timer delta =3D 357969
[    0.124000] ... PM-Timer result ok
[    0.124000] ..... delta 6250126
[    0.124000] ..... mult: 268440867
[    0.124000] ..... calibration result: 4000080
[    0.124000] ..... CPU clock speed is 2300.0230 MHz.
[    0.124000] ..... host bus clock speed is 1000.0080 MHz.
[    0.124087] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.129440] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.132439] SMP alternatives: lockdep: fixing up alternatives
[    0.133745] smpboot: Booting Node   0, Processors  #   1 OK
[    0.008000] kvm-clock: cpu 1, msr 0:1fff1041, secondary cpu clock
[    0.008000] masked ExtINT on CPU#1
[    0.008000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.152116] Brought up 2 CPUs
[    0.152108] KVM setup async PF for cpu 1
[    0.152113] kvm-stealtime: cpu 1, msr 1f20e240
[    0.156013] ----------------
[    0.156686] | NMI testsuite:
[    0.157371] --------------------
[    0.160004]   remote IPI:  ok  |
[    0.172517]    local IPI:  ok  |
[    0.196019] --------------------
[    0.197096] Good, all   2 testcases passed! |
[    0.197994] ---------------------------------
[    0.198883] smpboot: Total of 2 processors activated (9199.44 BogoMIPS)
[    0.200459] CPU0 attaching sched-domain:
[    0.201058]  domain 0: span 0-1 level CPU
[    0.202000]   groups: 0 (cpu_power =3D 1023) 1
[    0.203270] CPU1 attaching sched-domain:
[    0.204033]  domain 0: span 0-1 level CPU
[    0.204963]   groups: 1 0 (cpu_power =3D 1023)
[    0.208032] devtmpfs: initialized
[    0.228111] xor: measuring software checksum speed
[    0.268008]    prefetch64-sse:  9427.000 MB/sec
[    0.308005]    generic_sse:  7831.000 MB/sec
[    0.308889] xor: using function: prefetch64-sse (9427.000 MB/sec)
[    0.310025] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.312385] regulator-dummy: no parameters
[    0.314011] NET: Registered protocol family 16
[    0.318734] cpuidle: using governor ladder
[    0.319597] cpuidle: using governor menu
[    0.322558] ACPI: bus type PCI registered
[    0.323415] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.324359] dca service started, version 1.12.1
[    0.325434] PCI: Using configuration type 1 for base access
[    0.484667] bio: create slab <bio-0> at 0
[    0.552009] raid6: sse2x1    6136 MB/s
[    0.620012] raid6: sse2x2    7735 MB/s
[    0.688010] raid6: sse2x4    8975 MB/s
[    0.688833] raid6: using algorithm sse2x4 (8975 MB/s)
[    0.689820] raid6: using intx1 recovery algorithm
[    0.691078] ACPI: Added _OSI(Module Device)
[    0.691945] ACPI: Added _OSI(Processor Device)
[    0.692006] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.692946] ACPI: Added _OSI(Processor Aggregator Device)
[    0.697704] ACPI: EC: Look up EC in DSDT
[    0.708046] ACPI: Interpreter enabled
[    0.708861] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20130725/hwxface-571)
[    0.710814] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20130725/hwxface-571)
[    0.712643] ACPI: (supports S0 S3 S4 S5)
[    0.713471] ACPI: Using IOAPIC for interrupt routing
[    0.714556] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.718103] ACPI: No dock devices found.
[    0.744365] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.745551] acpi PNP0A03:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    0.747168] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.748665] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.754758] acpiphp: Slot [3] registered
[    0.755727] acpiphp: Slot [4] registered
[    0.756135] acpiphp: Slot [5] registered
[    0.757130] acpiphp: Slot [6] registered
[    0.758090] acpiphp: Slot [7] registered
[    0.759055] acpiphp: Slot [8] registered
[    0.760134] acpiphp: Slot [9] registered
[    0.761098] acpiphp: Slot [10] registered
[    0.762084] acpiphp: Slot [11] registered
[    0.763153] acpiphp: Slot [12] registered
[    0.764135] acpiphp: Slot [13] registered
[    0.765153] acpiphp: Slot [14] registered
[    0.766142] acpiphp: Slot [15] registered
[    0.767138] acpiphp: Slot [16] registered
[    0.768136] acpiphp: Slot [17] registered
[    0.769110] acpiphp: Slot [18] registered
[    0.770099] acpiphp: Slot [19] registered
[    0.771084] acpiphp: Slot [20] registered
[    0.772145] acpiphp: Slot [21] registered
[    0.773116] acpiphp: Slot [22] registered
[    0.774093] acpiphp: Slot [23] registered
[    0.775072] acpiphp: Slot [24] registered
[    0.776136] acpiphp: Slot [25] registered
[    0.777127] acpiphp: Slot [26] registered
[    0.778117] acpiphp: Slot [27] registered
[    0.779093] acpiphp: Slot [28] registered
[    0.780143] acpiphp: Slot [29] registered
[    0.781129] acpiphp: Slot [30] registered
[    0.782109] acpiphp: Slot [31] registered
[    0.782974] PCI host bridge to bus 0000:00
[    0.784010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.785064] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.786216] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.787378] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.788007] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.789300] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.792333] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.794649] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.799224] pci 0000:00:01.1: reg 0x20: [io  0xc1e0-0xc1ef]
[    0.802672] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.804470] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.805959] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.808475] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.812021] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.814813] pci 0000:00:02.0: reg 0x14: [mem 0xfebe0000-0xfebe0fff]
[    0.823098] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    0.824870] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.828007] pci 0000:00:03.0: reg 0x10: [io  0xc1c0-0xc1df]
[    0.830403] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    0.838018] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    0.840801] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.843388] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.845352] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.853340] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    0.855391] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.857425] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    0.860698] pci 0000:00:05.0: reg 0x14: [mem 0xfebe2000-0xfebe2fff]
[    0.869679] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.872007] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.874433] pci 0000:00:06.0: reg 0x14: [mem 0xfebe3000-0xfebe3fff]
[    0.880000] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.885418] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.887835] pci 0000:00:07.0: reg 0x14: [mem 0xfebe4000-0xfebe4fff]
[    0.896774] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.899310] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    0.901353] pci 0000:00:08.0: reg 0x14: [mem 0xfebe5000-0xfebe5fff]
[    0.910352] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.912700] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    0.915100] pci 0000:00:09.0: reg 0x14: [mem 0xfebe6000-0xfebe6fff]
[    0.924554] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.927089] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.929364] pci 0000:00:0a.0: reg 0x14: [mem 0xfebe7000-0xfebe7fff]
[    0.938313] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.940007] pci 0000:00:0b.0: reg 0x10: [mem 0xfebe8000-0xfebe800f]
[    0.948390] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.950277] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.952153] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.954017] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.955717] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.957979] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.959154] ACPI: \_SB_.PCI0: notify handler is installed
[    0.960168] Found 1 acpi root devices
[    0.962476] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.964015] vgaarb: loaded
[    0.964671] vgaarb: bridge control possible 0000:00:02.0
[    0.965969] tps65010: version 2 May 2005
[    1.000071] tps65010: no chip?
[    1.001607] SCSI subsystem initialized
[    1.002587] libata version 3.00 loaded.
[    1.002587] ACPI: bus type USB registered
[    1.004312] usbcore: registered new interface driver usbfs
[    1.005485] usbcore: registered new interface driver hub
[    1.006614] usbcore: registered new device driver usb
[    1.008415] pps_core: LinuxPPS API ver. 1 registered
[    1.009394] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.011166] PTP clock support registered
[    1.012258] EDAC MC: Ver: 3.0.0
[    1.013634] wmi: Mapper loaded
[    1.013634] Advanced Linux Sound Architecture Driver Initialized.
[    1.016598] PCI: Using ACPI for IRQ routing
[    1.017474] PCI: pci_cache_line_size set to 64 bytes
[    1.018725] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.020014] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    1.022569] NET: Registered protocol family 23
[    1.024162] Bluetooth: Core ver 2.16
[    1.025008] NET: Registered protocol family 31
[    1.025914] Bluetooth: HCI device and connection manager initialized
[    1.027116] Bluetooth: HCI socket layer initialized
[    1.028024] Bluetooth: L2CAP socket layer initialized
[    1.029094] Bluetooth: SCO socket layer initialized
[    1.030065] NET: Registered protocol family 8
[    1.030957] NET: Registered protocol family 20
[    1.032817] cfg80211: Calling CRDA to update world regulatory domain
[    1.034165] nfc: nfc_init: NFC Core ver 0.1
[    1.036115] NET: Registered protocol family 39
[    1.039242] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.039242] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    1.039242] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    1.044206] Switched to clocksource kvm-clock
[    1.317994] FS-Cache: Loaded
[    1.319075] CacheFiles: Loaded
[    1.319896] pnp: PnP ACPI init
[    1.320761] ACPI: bus type PNP registered
[    1.321700] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.323551] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.324880] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.326684] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.327962] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.329829] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.331148] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.332787] pnp 00:03: [dma 2]
[    1.333695] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.335019] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.336853] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.338168] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.340028] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.341974] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.343575] pnp: PnP ACPI: found 7 devices
[    1.344457] ACPI: bus type PNP unregistered
[    1.369685] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.370776] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.371836] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.373011] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.374588] NET: Registered protocol family 2
[    1.376853] TCP established hash table entries: 4096 (order: 4, 65536 by=
tes)
[    1.378300] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    1.379839] TCP: Hash tables configured (established 4096 bind 4096)
[    1.381122] TCP: reno registered
[    1.381890] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    1.383066] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    1.384920] NET: Registered protocol family 1
[    1.387190] RPC: Registered named UNIX socket transport module.
[    1.388341] RPC: Registered udp transport module.
[    1.389295] RPC: Registered tcp transport module.
[    1.390233] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.391417] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.392576] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.393690] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.394871] pci 0000:00:02.0: Boot video device
[    1.395883] PCI: CLS 0 bytes, default 64
[    1.631892] swapper/0 invoked oom-killer: gfp_mask=3D0x2000d0, order=3D1=
, oom_score_adj=3D0
[    1.633549] swapper/0 cpuset=3D/ mems_allowed=3D0
[    1.634443] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.12.0-rc4-00019-g=
8b5ede6 #126
[    1.635982] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.637088]  0000000000000002 ffff88001dd41b28 ffffffff82c8d78f ffff8800=
1ef7c040
[    1.638955]  ffff88001dd41ba8 ffffffff82c8395f ffffffff83c54680 ffff8800=
1dd41b60
[    1.640830]  ffffffff810f3f06 0000000000001eb4 0000000000000246 ffff8800=
1dd41b98
[    1.642687] Call Trace:
[    1.643313]  [<ffffffff82c8d78f>] dump_stack+0x54/0x74
[    1.644331]  [<ffffffff82c8395f>] dump_header.isra.10+0x7a/0x1ba
[    1.645443]  [<ffffffff810f3f06>] ? lock_release_holdtime.part.27+0x4c/0=
x50
[    1.646685]  [<ffffffff810f795a>] ? lock_release+0x189/0x1d1
[    1.647744]  [<ffffffff811530a8>] out_of_memory+0x39e/0x3ee
[    1.648882]  [<ffffffff811579f5>] __alloc_pages_nodemask+0x668/0x7de
[    1.650385]  [<ffffffff8118eb53>] kmem_getpages+0x75/0x16c
[    1.651429]  [<ffffffff81190d20>] fallback_alloc+0x12c/0x1ea
[    1.652528]  [<ffffffff810f38e8>] ? trace_hardirqs_off+0xd/0xf
[    1.653627]  [<ffffffff81190be5>] ____cache_alloc_node+0x14a/0x159
[    1.654783]  [<ffffffff817059fb>] ? dma_debug_init+0x1ef/0x29a
[    1.655928]  [<ffffffff8119162c>] kmem_cache_alloc_trace+0x83/0x11a
[    1.657108]  [<ffffffff817059fb>] dma_debug_init+0x1ef/0x29a
[    1.658182]  [<ffffffff841ac38b>] pci_iommu_init+0x16/0x52
[    1.659263]  [<ffffffff841ac375>] ? iommu_setup+0x27d/0x27d
[    1.660342]  [<ffffffff810020d2>] do_one_initcall+0x93/0x137
[    1.661415]  [<ffffffff810bd300>] ? param_set_charp+0x92/0xd8
[    1.662503]  [<ffffffff810bd52e>] ? parse_args+0x189/0x247
[    1.663555]  [<ffffffff8419fed1>] kernel_init_freeable+0x15e/0x1df
[    1.664724]  [<ffffffff8419f729>] ? do_early_param+0x88/0x88
[    1.665814]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb
[    1.666824]  [<ffffffff82c77875>] kernel_init+0xe/0xdb
[    1.667824]  [<ffffffff82cbc57c>] ret_from_fork+0x7c/0xb0
[    1.668911]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb
[    1.669925] Mem-Info:
[    1.670508] Node 0 DMA per-cpu:
[    1.671318] CPU    0: hi:    0, btch:   1 usd:   0
[    1.672288] CPU    1: hi:    0, btch:   1 usd:   0
[    1.673232] Node 0 DMA32 per-cpu:
[    1.674060] CPU    0: hi:  186, btch:  31 usd:  56
[    1.675008] CPU    1: hi:  186, btch:  31 usd:  25
[    1.675955] active_anon:0 inactive_anon:0 isolated_anon:0
[    1.675955]  active_file:0 inactive_file:0 isolated_file:0
[    1.675955]  unevictable:0 dirty:0 writeback:0 unstable:0
[    1.675955]  free:1 slab_reclaimable:22546 slab_unreclaimable:85387
[    1.675955]  mapped:0 shmem:0 pagetables:0 bounce:0
[    1.675955]  free_cma:0
[    1.681419] Node 0 DMA free:4kB min:0kB low:0kB high:0kB active_anon:0kB=
 inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolat=
ed(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB=
 dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unr=
eclaimable:15904kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB =
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    1.688220] lowmem_reserve[]: 0 0 0 0
[    1.689482] Node 0 DMA32 free:0kB min:0kB low:0kB high:0kB active_anon:0=
kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isol=
ated(anon):0kB isolated(file):0kB present:507896kB managed:419568kB mlocked=
:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:90184kB =
slab_unreclaimable:325644kB kernel_stack:256kB pagetables:0kB unstable:0kB =
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable=
? yes
[    1.696420] lowmem_reserve[]: 0 0 0 0
[    1.697661] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*2=
56kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 4kB
[    1.700927] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256=
kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 0kB
[    1.704057] 0 total pagecache pages
[    1.704817] 0 pages in swap cache
[    1.705548] Swap cache stats: add 0, delete 0, find 0/0
[    1.706552] Free swap  =3D 0kB
[    1.714382] Total swap =3D 0kB
[    1.716512] 131069 pages RAM
[    1.717205] 22200 pages reserved
[    1.717937] 0 pages shared
[    1.718585] 71319 pages non-shared
[    1.719361] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_s=
core_adj name
[    1.720990] Kernel panic - not syncing: Out of memory and no killable pr=
ocesses...
[    1.720990]=20
[    1.722898] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.12.0-rc4-00019-g=
8b5ede6 #126
[    1.724453] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.724954]  0000000000000002 ffff88001dd41b30 ffffffff82c8d78f ffffffff=
837a2587
[    1.724954]  ffff88001dd41ba8 ffffffff82c81e9a ffff880000000008 ffff8800=
1dd41bb8
[    1.724954]  ffff88001dd41b58 0000000000000246 0000000000001694 8c6318c6=
318c6320
[    1.724954] Call Trace:
[    1.724954]  [<ffffffff82c8d78f>] dump_stack+0x54/0x74
[    1.724954]  [<ffffffff82c81e9a>] panic+0xd0/0x1e3
[    1.724954]  [<ffffffff811530b6>] out_of_memory+0x3ac/0x3ee
[    1.724954]  [<ffffffff811579f5>] __alloc_pages_nodemask+0x668/0x7de
[    1.724954]  [<ffffffff8118eb53>] kmem_getpages+0x75/0x16c
[    1.724954]  [<ffffffff81190d20>] fallback_alloc+0x12c/0x1ea
[    1.724954]  [<ffffffff810f38e8>] ? trace_hardirqs_off+0xd/0xf
[    1.724954]  [<ffffffff81190be5>] ____cache_alloc_node+0x14a/0x159
[    1.724954]  [<ffffffff817059fb>] ? dma_debug_init+0x1ef/0x29a
[    1.724954]  [<ffffffff8119162c>] kmem_cache_alloc_trace+0x83/0x11a
[    1.724954]  [<ffffffff817059fb>] dma_debug_init+0x1ef/0x29a
[    1.724954]  [<ffffffff841ac38b>] pci_iommu_init+0x16/0x52
[    1.724954]  [<ffffffff841ac375>] ? iommu_setup+0x27d/0x27d
[    1.724954]  [<ffffffff810020d2>] do_one_initcall+0x93/0x137
[    1.724954]  [<ffffffff810bd300>] ? param_set_charp+0x92/0xd8
[    1.724954]  [<ffffffff810bd52e>] ? parse_args+0x189/0x247
[    1.724954]  [<ffffffff8419fed1>] kernel_init_freeable+0x15e/0x1df
[    1.724954]  [<ffffffff8419f729>] ? do_early_param+0x88/0x88
[    1.724954]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb
[    1.724954]  [<ffffffff82c77875>] kernel_init+0xe/0xdb
[    1.724954]  [<ffffffff82cbc57c>] ret_from_fork+0x7c/0xb0
[    1.724954]  [<ffffffff82c77867>] ? rest_init+0xdb/0xdb

BUG: kernel boot oops
Elapsed time: 5
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-allyesdebi=
an/8b5ede69d24db939f52b47effff2f6fe1e83e08b/vmlinuz-3.12.0-rc4-00019-g8b5ed=
e6 -append 'hung_task_panic=3D1 rcutree.rcu_cpu_stall_timeout=3D100 log_buf=
_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dynamic_printk sys=
rq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3D=
ttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nfsroot-snb-22::dhcp nfsr=
oot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock,rsize=3D52=
4288,wsize=3D524288 rw link=3D/kernel-tests/run-queue/kvm/x86_64-allyesdebi=
an/linus:master/.vmlinuz-8b5ede69d24db939f52b47effff2f6fe1e83e08b-201310081=
10028-9-snb branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_64-allyesdebian/=
8b5ede69d24db939f52b47effff2f6fe1e83e08b/vmlinuz-3.12.0-rc4-00019-g8b5ede6'=
  -m 512M -smp 2 -net nic,vlan=3D0,macaddr=3D00:00:00:00:00:00,model=3Dvirt=
io -net user,vlan=3D0,hostfwd=3Dtcp::6647-:22 -net nic,vlan=3D1,model=3De10=
00 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -drive=
 file=3D/fs/LABEL=3DKVM/disk0-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio -driv=
e file=3D/fs/LABEL=3DKVM/disk1-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio -dri=
ve file=3D/fs/LABEL=3DKVM/disk2-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio -dr=
ive file=3D/fs/LABEL=3DKVM/disk3-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio -d=
rive file=3D/fs/LABEL=3DKVM/disk4-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio -=
drive file=3D/fs/LABEL=3DKVM/disk5-nfsroot-snb-22,media=3Ddisk,if=3Dvirtio =
-pidfile /dev/shm/kboot/pid-nfsroot-snb-22 -serial file:/dev/shm/kboot/seri=
al-nfsroot-snb-22 -daemonize -display none -monitor null=20

--8t9RHnE3ZwKMSgU+
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-8b5ede69d24db939f52b47effff2f6fe1e83e08b-x86_64-allyesdebian-Kernel-panic---not-syncing:-Out-of-memory-and-no-killable-processes----58404.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDg3NGRiNGQ4MDAyZjg5ZTE0OTRiZTlkNWMzMmYyOThjZWM2MjEyNTEK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgOGI1ZWRlNi4uLiBwb3dlcnBjL2lycTogRG9u
J3Qgc3dpdGNoIHRvIGlycSBzdGFjayBmcm9tIHNvZnRpcnEgc3RhY2sKSEVBRCBpcyBub3cg
YXQgODc0ZGI0ZC4uLiBNZXJnZSBicmFuY2ggJ2ZpeGVzJyBvZiBnaXQ6Ly9naXQubGluYXJv
Lm9yZy9wZW9wbGUvcm1rL2xpbnV4LWFybQpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1
ZS9rdm0veDg2XzY0LWFsbHllc2RlYmlhbi9saW51czptYXN0ZXI6ODc0ZGI0ZDgwMDJmODll
MTQ5NGJlOWQ1YzMyZjI5OGNlYzYyMTI1MTpiaXNlY3QtbW0KCjIwMTMtMTAtMDgtMTQ6MTg6
MTAgODc0ZGI0ZDgwMDJmODllMTQ5NGJlOWQ1YzMyZjI5OGNlYzYyMTI1MSBjb21waWxpbmcK
MTU2MiByZWFsICA0OTkxIHVzZXIgIDQyNSBzeXMgIDM0Ni43OCUgY3B1IAl4ODZfNjQtYWxs
eWVzZGViaWFuCgoyMDEzLTEwLTA4LTE0OjQ1OjUzIGRldGVjdGluZyBib290IHN0YXRlIDMu
MTIuMC1yYzItMDAxMTMtZzg3NGRiNGQuIFRFU1QgRkFJTFVSRQpbICAgIDEuMjUzNjc0XSBw
Y2kgMDAwMDowMDowMi4wOiBCb290IHZpZGVvIGRldmljZQpbICAgIDEuMjU0ODc5XSBQQ0k6
IENMUyAwIGJ5dGVzLCBkZWZhdWx0IDY0ClsgICAgMS40MTgxMjBdIHN3YXBwZXIvMCBpbnZv
a2VkIG9vbS1raWxsZXI6IGdmcF9tYXNrPTB4MjAwMGQwLCBvcmRlcj0xLCBvb21fc2NvcmVf
YWRqPTAKWyAgICAxLjQxOTQ5M10gc3dhcHBlci8wIGNwdXNldD0vIG1lbXNfYWxsb3dlZD0w
ClsgICAgMS40MjAyODBdIENQVTogMSBQSUQ6IDEgQ29tbTogc3dhcHBlci8wIE5vdCB0YWlu
dGVkIDMuMTIuMC1yYzItMDAxMTMtZzg3NGRiNGQgIzQxNgpbICAgIDEuNDIxNjIyXSBIYXJk
d2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAgMS40
MjI1NzddICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMWVmN2JiMjggZmZmZmZmZmY4MmM2
MTk1MiBmZmZmODgwMDFlZjdjMDQwClsgICAgMS40MjQyMzVdICBmZmZmODgwMDFlZjdiYmE4
IGZmZmZmZmZmODJjNTdiMjIgZmZmZmZmZmY4M2M1NDY4MCBmZmZmODgwMDFlZjdiYjYwClsg
ICAgMS40MjU4NzldICBmZmZmZmZmZjgxMGYzZTZlIDAwMDAwMDAwMDAwMDE0M2EgMDAwMDAw
MDAwMDAwMDI0NiBmZmZmODgwMDFlZjdiYjk4ClsgICAgMS40Mjc1MTRdIENhbGwgVHJhY2U6
ClsgICAgMS40MjgwNTldICBbPGZmZmZmZmZmODJjNjE5NTI+XSBkdW1wX3N0YWNrKzB4NTQv
MHg3NApbICAgIDEuNDI4OTQ2XSAgWzxmZmZmZmZmZjgyYzU3YjIyPl0gZHVtcF9oZWFkZXIu
aXNyYS4xMCsweDdhLzB4MWJhClsgICAgMS40Mjk5MzZdICBbPGZmZmZmZmZmODEwZjNlNmU+
XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0LjI3KzB4NGMvMHg1MApbICAgIDEuNDMx
MDQwXSAgWzxmZmZmZmZmZjgxMGY3OGM1Pl0gPyBsb2NrX3JlbGVhc2UrMHgxODkvMHgxZDEK
WyAgICAxLjQzMTk4NV0gIFs8ZmZmZmZmZmY4MTE1MzA4NT5dIG91dF9vZl9tZW1vcnkrMHgz
OWUvMHgzZWUKWyAgICAxLjQzMjkyOF0gIFs8ZmZmZmZmZmY4MTE1NzlkMj5dIF9fYWxsb2Nf
cGFnZXNfbm9kZW1hc2srMHg2NjgvMHg3ZGUKWyAgICAxLjQzMzk1OV0gIFs8ZmZmZmZmZmY4
MTE4ZWE2Mz5dIGttZW1fZ2V0cGFnZXMrMHg3NS8weDE2YwpbICAgIDEuNDM0ODY3XSAgWzxm
ZmZmZmZmZjgxMTkwYzMwPl0gZmFsbGJhY2tfYWxsb2MrMHgxMmMvMHgxZWEKWyAgICAxLjQz
NTc5OF0gIFs8ZmZmZmZmZmY4MTBmMzg1MD5dID8gdHJhY2VfaGFyZGlycXNfb2ZmKzB4ZC8w
eGYKWyAgICAxLjQzNjc2NV0gIFs8ZmZmZmZmZmY4MTE5MGFmNT5dIF9fX19jYWNoZV9hbGxv
Y19ub2RlKzB4MTRhLzB4MTU5ClsgICAgMS40Mzc3NTRdICBbPGZmZmZmZmZmODE3MDVhMmY+
XSA/IGRtYV9kZWJ1Z19pbml0KzB4MWVmLzB4MjlhClsgICAgMS40Mzg3MDJdICBbPGZmZmZm
ZmZmODExOTE1M2M+XSBrbWVtX2NhY2hlX2FsbG9jX3RyYWNlKzB4ODMvMHgxMWEKWyAgICAx
LjQzOTcwNF0gIFs8ZmZmZmZmZmY4MTcwNWEyZj5dIGRtYV9kZWJ1Z19pbml0KzB4MWVmLzB4
MjlhClsgICAgMS40NDA2NjddICBbPGZmZmZmZmZmODQxOTczOGE+XSBwY2lfaW9tbXVfaW5p
dCsweDE2LzB4NTIKWyAgICAxLjQ0MTU4OV0gIFs8ZmZmZmZmZmY4NDE5NzM3ND5dID8gaW9t
bXVfc2V0dXArMHgyN2QvMHgyN2QKWyAgICAxLjQ0MjUzMl0gIFs8ZmZmZmZmZmY4MTAwMjBk
Mj5dIGRvX29uZV9pbml0Y2FsbCsweDkzLzB4MTM3ClsgICAgMS40NDM0ODhdICBbPGZmZmZm
ZmZmODEwYmQzMDA+XSA/IHBhcmFtZXFuKzB4MjgvMHgzYgpbICAgIDEuNDQ0MzcxXSAgWzxm
ZmZmZmZmZjgxMGJkNGMwPl0gPyBwYXJzZV9hcmdzKzB4MTg5LzB4MjQ3ClsgICAgMS40NDUy
NzVdICBbPGZmZmZmZmZmODQxOGFlZDE+XSBrZXJuZWxfaW5pdF9mcmVlYWJsZSsweDE1ZS8w
eDFkZgpbICAgIDEuNDQ2MjczXSAgWzxmZmZmZmZmZjg0MThhNzI5Pl0gPyBkb19lYXJseV9w
YXJhbSsweDg4LzB4ODgKWyAgICAxLjQ0NzE4Nl0gIFs8ZmZmZmZmZmY4MmM0YmEyNz5dID8g
cmVzdF9pbml0KzB4ZGIvMHhkYgpbICAgIDEuNDQ4MDg1XSAgWzxmZmZmZmZmZjgyYzRiYTM1
Pl0ga2VybmVsX2luaXQrMHhlLzB4ZGIKWyAgICAxLjQ0ODk2OF0gIFs8ZmZmZmZmZmY4MmM5
MDc3Yz5dIHJldF9mcm9tX2ZvcmsrMHg3Yy8weGIwClsgICAgMS40NDk4ODJdICBbPGZmZmZm
ZmZmODJjNGJhMjc+XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAxLjQ1MDc4NF0gTWVt
LUluZm86ClsgICAgMS40NTEyOTFdIE5vZGUgMCBETUEgcGVyLWNwdToKL2tlcm5lbC94ODZf
NjQtYWxseWVzZGViaWFuLzg3NGRiNGQ4MDAyZjg5ZTE0OTRiZTlkNWMzMmYyOThjZWM2MjEy
NTEvZG1lc2cteW9jdG8td2FpbWVhLTEzOjIwMTMxMDA4MjI0MzAxOng4Nl82NC1hbGx5ZXNk
ZWJpYW46My4xMi4wLXJjMi0wMDExMy1nODc0ZGI0ZDo0MTYKL2tlcm5lbC94ODZfNjQtYWxs
eWVzZGViaWFuLzg3NGRiNGQ4MDAyZjg5ZTE0OTRiZTlkNWMzMmYyOThjZWM2MjEyNTEvZG1l
c2cteW9jdG8td2FpbWVhLTk6MjAxMzEwMDgyMjQzMDM6eDg2XzY0LWFsbHllc2RlYmlhbjoz
LjEyLjAtcmMyLTAwMTEzLWc4NzRkYjRkOjQxNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJp
YW4vODc0ZGI0ZDgwMDJmODllMTQ5NGJlOWQ1YzMyZjI5OGNlYzYyMTI1MS9kbWVzZy1xdWFu
dGFsLWxrcC1zdDAxLTEwOjIwMTMxMDA4MTQ0NjExOng4Nl82NC1hbGx5ZXNkZWJpYW46My4x
Mi4wLXJjMi0wMDExMy1nODc0ZGI0ZDo0MTYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFu
Lzg3NGRiNGQ4MDAyZjg5ZTE0OTRiZTlkNWMzMmYyOThjZWM2MjEyNTEvZG1lc2ctcXVhbnRh
bC14cHMtNzoyMDEzMTAwODIyNDIzNzp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzIt
MDAxMTMtZzg3NGRiNGQ6NDE2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84NzRkYjRk
ODAwMmY4OWUxNDk0YmU5ZDVjMzJmMjk4Y2VjNjIxMjUxL2RtZXNnLW5mc3Jvb3Qtd2FpbWVh
LTEyOjIwMTMxMDA4MjI0MzE4Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjMi0wMDEx
My1nODc0ZGI0ZDo0MTYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzg3NGRiNGQ4MDAy
Zjg5ZTE0OTRiZTlkNWMzMmYyOThjZWM2MjEyNTEvZG1lc2ctbmZzcm9vdC13YWltZWEtOToy
MDEzMTAwODIyNDMxODp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzItMDAxMTMtZzg3
NGRiNGQ6NDE2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84NzRkYjRkODAwMmY4OWUx
NDk0YmU5ZDVjMzJmMjk4Y2VjNjIxMjUxL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtOToyMDEz
MTAwODE0NDYyMDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzItMDAxMTMtZzg3NGRi
NGQ6NDE2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84NzRkYjRkODAwMmY4OWUxNDk0
YmU5ZDVjMzJmMjk4Y2VjNjIxMjUxL2RtZXNnLXF1YW50YWwtbGtwLXR0MDItMTM6MjAxMzEw
MDgwNTE3MTI6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmMyLTAwMTEzLWc4NzRkYjRk
OjQxNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vODc0ZGI0ZDgwMDJmODllMTQ5NGJl
OWQ1YzMyZjI5OGNlYzYyMTI1MS9kbWVzZy15b2N0by1sa3Atc3QwMS01OjIwMTMxMDA4MTQ0
NjE3Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjMi0wMDExMy1nODc0ZGI0ZDo0MTYK
MDo5OjUgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCmJpc2VjdDogYmFkIGNvbW1pdCA4
NzRkYjRkODAwMmY4OWUxNDk0YmU5ZDVjMzJmMjk4Y2VjNjIxMjUxCmdpdCBjaGVja291dCB2
My4xMQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA4NzRkYjRkLi4uIE1lcmdlIGJyYW5j
aCAnZml4ZXMnIG9mIGdpdDovL2dpdC5saW5hcm8ub3JnL3Blb3BsZS9ybWsvbGludXgtYXJt
CkhFQUQgaXMgbm93IGF0IDZlNDY2NDUuLi4gTGludXggMy4xMQpscyAtYSAva2VybmVsLXRl
c3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWFsbHllc2RlYmlhbi9saW51czptYXN0ZXI6NmU0
NjY0NTI1YjFkYjI4ZjhjNGUxMTMwOTU3ZjcwYTk0YzE5MjEzZTpiaXNlY3QtbW0KCjIwMTMt
MTAtMDgtMTQ6NDY6MjkgNmU0NjY0NTI1YjFkYjI4ZjhjNGUxMTMwOTU3ZjcwYTk0YzE5MjEz
ZSBjb21waWxpbmcKMTEzOSByZWFsICA0ODgzIHVzZXIgIDQyNCBzeXMgIDQ2NS45OCUgY3B1
IAl4ODZfNjQtYWxseWVzZGViaWFuCgoyMDEzLTEwLTA4LTE1OjA1OjUxIGRldGVjdGluZyBi
b290IHN0YXRlIDMuMTEuMC4uLi4uLi4uLi4uLi4uLi4uLi4uCTExCTIwIFNVQ0NFU1MKCmJp
c2VjdDogZ29vZCBjb21taXQgdjMuMTEKZ2l0IGJpc2VjdCBzdGFydCA4NzRkYjRkODAwMmY4
OWUxNDk0YmU5ZDVjMzJmMjk4Y2VjNjIxMjUxIHYzLjExIC0tClByZXZpb3VzIEhFQUQgcG9z
aXRpb24gd2FzIDZlNDY2NDUuLi4gTGludXggMy4xMQpIRUFEIGlzIG5vdyBhdCAzYzBlZWUz
Li4uIExpbnV4IDIuNi4zNwpCaXNlY3Rpbmc6IDU2MDAgcmV2aXNpb25zIGxlZnQgdG8gdGVz
dCBhZnRlciB0aGlzIChyb3VnaGx5IDEyIHN0ZXBzKQpbNTdkNzMwOTI0ZDVjYzJjM2UyODBh
ZjE2YTkzMDY1ODdjM2E1MTFkYl0gTWVyZ2UgYnJhbmNoICd0aW1lcnMtdXJnZW50LWZvci1s
aW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0
L3RpcC90aXAKZ2l0IGJpc2VjdCBydW4gL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJv
b3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdApydW5uaW5nIC9jL2tlcm5l
bC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21tL29iai1i
aXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vbGludXM6bWFzdGVyOjU3ZDczMDkyNGQ1Y2MyYzNlMjgwYWYxNmE5MzA2NTg3YzNh
NTExZGI6YmlzZWN0LW1tCgoyMDEzLTEwLTA4LTE1OjE3OjI2IDU3ZDczMDkyNGQ1Y2MyYzNl
MjgwYWYxNmE5MzA2NTg3YzNhNTExZGIgY29tcGlsaW5nCjEwNTYgcmVhbCAgNDkxNSB1c2Vy
ICA0Mzggc3lzICA1MDYuOTklIGNwdSAJeDg2XzY0LWFsbHllc2RlYmlhbgoKMjAxMy0xMC0w
OC0xNTozNTo1MyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDQ2OTQtZzU3ZDczMDku
Li4uLi4uLi4uLi4uLi4uLi4uLgkxNwkxOAkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDI3OTEg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEyIHN0ZXBzKQpb
YzRjMTcyNTIyODNhMTNjMGQ2M2E4ZDlkZjgyOGRhMTA5YzExNjQxMV0gTWVyZ2UgdGFnICdu
dGItMy4xMicgb2YgZ2l0Oi8vZ2l0aHViLmNvbS9qb25tYXNvbi9udGIKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9v
YmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtYWxs
eWVzZGViaWFuL2xpbnVzOm1hc3RlcjpjNGMxNzI1MjI4M2ExM2MwZDYzYThkOWRmODI4ZGEx
MDljMTE2NDExOmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xNTo0NzoyNiBjNGMxNzI1MjI4M2Ex
M2MwZDYzYThkOWRmODI4ZGExMDljMTE2NDExIGNvbXBpbGluZwoxMzAxIHJlYWwgIDQ5NDAg
dXNlciAgNDQzIHN5cyAgNDEzLjUzJSBjcHUgCXg4Nl82NC1hbGx5ZXNkZWJpYW4KCjIwMTMt
MTAtMDgtMTY6MDk6NDQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTA3NTAzLWdjNGMx
NzI1Li4uLi4uLi4uLi4uLi4uLi4uLi4JMTMJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxMzk1
IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMSBzdGVwcykK
W2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmZdIGZpcm13YXJlL2Rt
aV9zY2FuOiBjb25zdGlmeSBzdHJpbmdzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWFsbHllc2RlYmlhbi9saW51czpt
YXN0ZXI6ZmZiYmI5NmRkNzU3MGI5YWFmZDQyNmNkNzdhN2VlMDNkMjI0Y2FiZjpiaXNlY3Qt
bW0KCjIwMTMtMTAtMDgtMTY6MjA6NDkgZmZiYmI5NmRkNzU3MGI5YWFmZDQyNmNkNzdhN2Vl
MDNkMjI0Y2FiZiBjb21waWxpbmcKMTA4NSByZWFsICA0OTI5IHVzZXIgIDQzMiBzeXMgIDQ5
My44NCUgY3B1IAl4ODZfNjQtYWxseWVzZGViaWFuCgoyMDEzLTEwLTA4LTE2OjQxOjA3IGRl
dGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wOTI3NS1nZmZiYmI5Ni4gVEVTVCBGQUlMVVJF
ClsgICAgMS40NjIzNDddIHBjaSAwMDAwOjAwOjAyLjA6IEJvb3QgdmlkZW8gZGV2aWNlClsg
ICAgMS40NjMyNzJdIFBDSTogQ0xTIDAgYnl0ZXMsIGRlZmF1bHQgNjQKWyAgICAxLjk0MDg5
Ml0gc3dhcHBlci8wIGludm9rZWQgb29tLWtpbGxlcjogZ2ZwX21hc2s9MHgyMDAwZDAsIG9y
ZGVyPTEsIG9vbV9zY29yZV9hZGo9MApbICAgIDEuOTQyMzkwXSBzd2FwcGVyLzAgY3B1c2V0
PS8gbWVtc19hbGxvd2VkPTAKWyAgICAxLjk0MzIwMV0gQ1BVOiAxIFBJRDogMSBDb21tOiBz
d2FwcGVyLzAgTm90IHRhaW50ZWQgMy4xMS4wLTA5Mjc1LWdmZmJiYjk2ICM0MjAKWyAgICAx
Ljk0NDYwNF0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEv
MjAxMQpbICAgIDEuOTQ1NTkwXSAgMDAwMDAwMDAwMDAwMDAwMiBmZmZmODgwMDFlZjc5YjE4
IGZmZmZmZmZmODJjNTVhY2YgZmZmZjg4MDAxZWY3NDA0MApbICAgIDEuOTQ3MjgxXSAgZmZm
Zjg4MDAxZWY3OWI5OCBmZmZmZmZmZjgyYzRkZTU2IGZmZmZmZmZmODNjNTQ1ODAgZmZmZjg4
MDAxZWY3OWI1MApbICAgIDEuOTQ4OTkzXSAgZmZmZmZmZmY4MTBlZTA3NyAwMDAwMDAwMDAw
MDA3YWIxIDAwMDAwMDAwMDAwMDAyNDYgZmZmZjg4MDAxZWY3OWI4OApbICAgIDEuOTUwNjg0
XSBDYWxsIFRyYWNlOgpbICAgIDEuOTUxMjUzXSAgWzxmZmZmZmZmZjgyYzU1YWNmPl0gZHVt
cF9zdGFjaysweDU0LzB4NzQKWyAgICAxLjk1MjE3N10gIFs8ZmZmZmZmZmY4MmM0ZGU1Nj5d
IGR1bXBfaGVhZGVyLmlzcmEuMTArMHg3YS8weDFiYQpbICAgIDEuOTUzMjA1XSAgWzxmZmZm
ZmZmZjgxMGVlMDc3Pl0gPyBsb2NrX3JlbGVhc2VfaG9sZHRpbWUucGFydC4yNysweDRjLzB4
NTAKWyAgICAxLjk1NDM3M10gIFs8ZmZmZmZmZmY4MTBmMWFjZT5dID8gbG9ja19yZWxlYXNl
KzB4MTg5LzB4MWQxClsgICAgMS45NTUzNTJdICBbPGZmZmZmZmZmODExNTJlMDI+XSBvdXRf
b2ZfbWVtb3J5KzB4MzllLzB4M2VlClsgICAgMS45NTYzMzZdICBbPGZmZmZmZmZmODExNTc3
NGY+XSBfX2FsbG9jX3BhZ2VzX25vZGVtYXNrKzB4NjY4LzB4N2RlClsgICAgMS45NTc0MjBd
ICBbPGZmZmZmZmZmODExOGUwNjY+XSBrbWVtX2dldHBhZ2VzKzB4NzUvMHgxNmMKWyAgICAx
Ljk1ODM2N10gIFs8ZmZmZmZmZmY4MTE5MDIzMz5dIGZhbGxiYWNrX2FsbG9jKzB4MTJjLzB4
MWVhClsgICAgMS45NTkzNDBdICBbPGZmZmZmZmZmODEwZWRhNTk+XSA/IHRyYWNlX2hhcmRp
cnFzX29mZisweGQvMHhmClsgICAgMS45NjAzNjhdICBbPGZmZmZmZmZmODExOTAwZjg+XSBf
X19fY2FjaGVfYWxsb2Nfbm9kZSsweDE0YS8weDE1OQpbICAgIDEuOTYxNDEwXSAgWzxmZmZm
ZmZmZjgxMTkwYTI0Pl0gX19rbWFsbG9jKzB4OTUvMHgxMmQKWyAgICAxLjk2MjMxN10gIFs8
ZmZmZmZmZmY4MTcwMTk5OD5dID8ga3phbGxvYy5jb25zdHByb3AuMTYrMHhlLzB4MTAKWyAg
ICAxLjk2MzMzN10gIFs8ZmZmZmZmZmY4MTcwMTk5OD5dIGt6YWxsb2MuY29uc3Rwcm9wLjE2
KzB4ZS8weDEwClsgICAgMS45NjQzNzVdICBbPGZmZmZmZmZmODE3MDMxMGI+XSBkbWFfZGVi
dWdfaW5pdCsweDFlMy8weDI4ZQpbICAgIDEuOTY1MzUyXSAgWzxmZmZmZmZmZjg0MTk3MzI5
Pl0gcGNpX2lvbW11X2luaXQrMHgxNi8weDUyClsgICAgMS45NjYzMDRdICBbPGZmZmZmZmZm
ODQxOTczMTM+XSA/IGlvbW11X3NldHVwKzB4MjdkLzB4MjdkClsgICAgMS45NjcyNjhdICBb
PGZmZmZmZmZmODEwMDIwZDI+XSBkb19vbmVfaW5pdGNhbGwrMHg5My8weDEzNwpbICAgIDEu
OTY4MjU0XSAgWzxmZmZmZmZmZjgxMGJkMzAwPl0gPyBwYXJhbWVxKzB4NC8weDI0ClsgICAg
MS45NjkxMzddICBbPGZmZmZmZmZmODEwYmQ0YTk+XSA/IHBhcnNlX2FyZ3MrMHgxODkvMHgy
NDcKWyAgICAxLjk3MDA5M10gIFs8ZmZmZmZmZmY4NDE4YWVkMT5dIGtlcm5lbF9pbml0X2Zy
ZWVhYmxlKzB4MTVlLzB4MWRmClsgICAgMS45NzExMzFdICBbPGZmZmZmZmZmODQxOGE3Mjk+
XSA/IGRvX2Vhcmx5X3BhcmFtKzB4ODgvMHg4OApbICAgIDEuOTcyMTE5XSAgWzxmZmZmZmZm
ZjgyYzQxZDA3Pl0gPyByZXN0X2luaXQrMHhkYi8weGRiClsgICAgMS45NzMwMzNdICBbPGZm
ZmZmZmZmODJjNDFkMTU+XSBrZXJuZWxfaW5pdCsweGUvMHhkYgpbICAgIDEuOTczOTMwXSAg
WzxmZmZmZmZmZjgyYzgzMTZjPl0gcmV0X2Zyb21fZm9yaysweDdjLzB4YjAKWyAgICAxLjk3
NDg5M10gIFs8ZmZmZmZmZmY4MmM0MWQwNz5dID8gcmVzdF9pbml0KzB4ZGIvMHhkYgpbICAg
IDEuOTc1ODAwXSBNZW0tSW5mbzoKWyAgICAxLjk3NjM3NV0gTm9kZSAwIERNQSBwZXItY3B1
Ogova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vZmZiYmI5NmRkNzU3MGI5YWFmZDQyNmNk
NzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy1uZnNyb290LWF0aGVucy0yMzoyMDEzMTAwODE2NDEx
OTp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5l
bC94ODZfNjQtYWxseWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAz
ZDIyNGNhYmYvZG1lc2ctbmZzcm9vdC1jYWlyby0xOToyMDEzMTAwODE2NDExNjp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94ODZfNjQt
YWxseWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmYv
ZG1lc2ctbmZzcm9vdC1jYWlyby03OjIwMTMxMDA4MTY0MTE2Ong4Nl82NC1hbGx5ZXNkZWJp
YW46My4xMS4wLTA5Mjc1LWdmZmJiYjk2OjQyMAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJp
YW4vZmZiYmI5NmRkNzU3MGI5YWFmZDQyNmNkNzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy1uZnNy
b290LXJvYW0tMTQ6MjAxMzEwMDgxNjQxMTU6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAt
MDkyNzUtZ2ZmYmJiOTY6NDIwCi9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9mZmJiYjk2
ZGQ3NTcwYjlhYWZkNDI2Y2Q3N2E3ZWUwM2QyMjRjYWJmL2RtZXNnLXF1YW50YWwtYXRoZW5z
LTQ0OjIwMTMxMDA4MTY0MTE2Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5Mjc1LWdm
ZmJiYjk2OjQyMAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vZmZiYmI5NmRkNzU3MGI5
YWFmZDQyNmNkNzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy1xdWFudGFsLWNhaXJvLTE2OjIwMTMx
MDA4MTY0MTE1Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5Mjc1LWdmZmJiYjk2OjQy
MAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vZmZiYmI5NmRkNzU3MGI5YWFmZDQyNmNk
NzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy1xdWFudGFsLWlubi0xNDoyMDEzMTAwODE2NDExNjp4
ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94
ODZfNjQtYWxseWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIy
NGNhYmYvZG1lc2ctcXVhbnRhbC1pbm4tMzY6MjAxMzEwMDgxNjQxMTg6eDg2XzY0LWFsbHll
c2RlYmlhbjozLjExLjAtMDkyNzUtZ2ZmYmJiOTY6NDIwCi9rZXJuZWwveDg2XzY0LWFsbHll
c2RlYmlhbi9mZmJiYjk2ZGQ3NTcwYjlhYWZkNDI2Y2Q3N2E3ZWUwM2QyMjRjYWJmL2RtZXNn
LXlvY3RvLWF0aGVucy0zNToyMDEzMTAwODE2NDExNTp4ODZfNjQtYWxseWVzZGViaWFuOjMu
MTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2Zm
YmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmYvZG1lc2cteW9jdG8tYXRo
ZW5zLTM3OjIwMTMxMDA4MTY0MTE1Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5Mjc1
LWdmZmJiYjk2OjQyMAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vZmZiYmI5NmRkNzU3
MGI5YWFmZDQyNmNkNzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy15b2N0by1jYWlyby0xNDoyMDEz
MTAwODE2NDExNjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0
MjAKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZj
ZDc3YTdlZTAzZDIyNGNhYmYvZG1lc2cteW9jdG8tY2Fpcm8tNDA6MjAxMzEwMDgxNjQxMTU6
eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyNzUtZ2ZmYmJiOTY6NDIwCi9rZXJuZWwv
eDg2XzY0LWFsbHllc2RlYmlhbi9mZmJiYjk2ZGQ3NTcwYjlhYWZkNDI2Y2Q3N2E3ZWUwM2Qy
MjRjYWJmL2RtZXNnLXlvY3RvLWlubi0zNToyMDEzMTAwODE2NDExNjp4ODZfNjQtYWxseWVz
ZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94ODZfNjQtYWxseWVz
ZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmYvZG1lc2ct
eW9jdG8tcm9hbS0yMToyMDEzMTAwODE2NDExNTp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEu
MC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2ZmYmJi
OTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmYvZG1lc2cteW9jdG8td2FpbWVh
LTE1OjIwMTMxMDA5MDAzODE0Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5Mjc1LWdm
ZmJiYjk2OjQyMAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vZmZiYmI5NmRkNzU3MGI5
YWFmZDQyNmNkNzdhN2VlMDNkMjI0Y2FiZi9kbWVzZy15b2N0by13YWltZWEtNjoyMDEzMTAw
OTAwMzgxMzp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAK
L2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3
YTdlZTAzZDIyNGNhYmYvZG1lc2cteW9jdG8td2FpbWVhLTc6MjAxMzEwMDkwMDM4MTM6eDg2
XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyNzUtZ2ZmYmJiOTY6NDIwCi9rZXJuZWwveDg2
XzY0LWFsbHllc2RlYmlhbi9mZmJiYjk2ZGQ3NTcwYjlhYWZkNDI2Y2Q3N2E3ZWUwM2QyMjRj
YWJmL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtNjoyMDEzMTAwODE2NDEyNTp4ODZfNjQtYWxs
eWVzZGViaWFuOjMuMTEuMC0wOTI3NS1nZmZiYmI5Njo0MjAKL2tlcm5lbC94ODZfNjQtYWxs
eWVzZGViaWFuL2ZmYmJiOTZkZDc1NzBiOWFhZmQ0MjZjZDc3YTdlZTAzZDIyNGNhYmYvZG1l
c2cteW9jdG8tbGtwLXR0MDItMTY6MjAxMzEwMDgwNzEyMjE6eDg2XzY0LWFsbHllc2RlYmlh
bjozLjExLjAtMDkyNzUtZ2ZmYmJiOTY6NDIwCi9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlh
bi9mZmJiYjk2ZGQ3NTcwYjlhYWZkNDI2Y2Q3N2E3ZWUwM2QyMjRjYWJmL2RtZXNnLXlvY3Rv
LXN0b2FrbGV5LTI6MjAxMzEwMDgxNjQxMjU6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAt
MDkyNzUtZ2ZmYmJiOTY6NDIwCjA6MjA6MjAgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMK
G1sxOzM1bVJFUEVBVCBDT1VOVDogMjAgICMgL2NjL3dmZy9tbS1iaXNlY3QvLnJlcGVhdBtb
MG0KCkJpc2VjdGluZzogNzA3IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSAxMCBzdGVwcykKW2EzNWM2MzIyZTUyYzU1MGI2MWEwNGE0NGRmMjdkMjIzOTRl
ZTBhMmNdIE1lcmdlIHRhZyAnZHJpdmVycy1mb3ItbGludXMnIG9mIGdpdDovL2dpdC5rZXJu
ZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9hcm0vYXJtLXNvYwpydW5uaW5nIC9j
L2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21t
L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1h
bGx5ZXNkZWJpYW4vbGludXM6bWFzdGVyOmEzNWM2MzIyZTUyYzU1MGI2MWEwNGE0NGRmMjdk
MjIzOTRlZTBhMmM6YmlzZWN0LW1tCgoyMDEzLTEwLTA4LTE2OjQxOjQwIGEzNWM2MzIyZTUy
YzU1MGI2MWEwNGE0NGRmMjdkMjIzOTRlZTBhMmMgY29tcGlsaW5nCjExMDMgcmVhbCAgNDg2
NyB1c2VyICA0MTcgc3lzICA0NzguOTglIGNwdSAJeDg2XzY0LWFsbHllc2RlYmlhbgoKMjAx
My0xMC0wOC0xNzowMDo0MiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDg1NjctZ2Ez
NWM2MzIuLi4uLi4uLi4uLi4uLi4uLi4uLgkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDM0NyBy
ZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKW2Vj
NWIxMDNlY2ZkZTkyOTAwNGI2OTFmMjkxODMyNTVhZWVhZGVjZDVdIE1lcmdlIGJyYW5jaCAn
Zm9yLWxpbnVzJyBvZiBnaXQ6Ly9naXQuaW5mcmFkZWFkLm9yZy91c2Vycy92a291bC9zbGF2
ZS1kbWEKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1
ZXVlL2t2bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3RlcjplYzViMTAzZWNmZGU5
MjkwMDRiNjkxZjI5MTgzMjU1YWVlYWRlY2Q1OmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xNzox
MToxNCBlYzViMTAzZWNmZGU5MjkwMDRiNjkxZjI5MTgzMjU1YWVlYWRlY2Q1IGNvbXBpbGlu
Zwo2OTggcmVhbCAgNDk3MiB1c2VyICA0Mzggc3lzICA3NzQuNzYlIGNwdSAJeDg2XzY0LWFs
bHllc2RlYmlhbgoKMjAxMy0xMC0wOC0xNzoyMzoxMCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAz
LjExLjAtMDg5MjctZ2VjNWIxMDMuLi4uLi4uLi4uLi4uLi4uLi4uLgk0CTIwIFNVQ0NFU1MK
CkJpc2VjdGluZzogMTczIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSA4IHN0ZXBzKQpbZTE0MDNiOGVkZjY2OWZmNDliYmRmNjAyY2M5N2ZlZmEyNzYwY2Ix
NV0gaW5jbHVkZS9saW51eC9zY2hlZC5oOiBkb24ndCB1c2UgdGFzay0+cGlkL3RnaWQgaW4g
c2FtZV90aHJlYWRfZ3JvdXAvaGFzX2dyb3VwX2xlYWRlcl9waWQKcnVubmluZyAvYy9rZXJu
ZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9vYmot
YmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtYWxseWVz
ZGViaWFuL2xpbnVzOm1hc3RlcjplMTQwM2I4ZWRmNjY5ZmY0OWJiZGY2MDJjYzk3ZmVmYTI3
NjBjYjE1OmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xNzozNDoxMiBlMTQwM2I4ZWRmNjY5ZmY0
OWJiZGY2MDJjYzk3ZmVmYTI3NjBjYjE1IGNvbXBpbGluZwo3NDYgcmVhbCAgNDkyNyB1c2Vy
ICA0Mjkgc3lzICA3MTcuMjIlIGNwdSAJeDg2XzY0LWFsbHllc2RlYmlhbgoKMjAxMy0xMC0w
OC0xNzo0Njo1OCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDkxMDEtZ2UxNDAzYjgu
Li4uLi4uLi4uLi4uLi4uLi4uLgkyCTE2CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogODYgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDcgc3RlcHMpCls3MjI1
NTIyYmI0MjlhMmY3ZGFlNjY2N2U1MzNlMmQ3MzViNDg4MmQwXSBtbTogbXVubG9jazogYmF0
Y2ggbm9uLVRIUCBwYWdlIGlzb2xhdGlvbiBhbmQgbXVubG9jaytwdXRiYWNrIHVzaW5nIHBh
Z2V2ZWMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1
ZXVlL2t2bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo3MjI1NTIyYmI0Mjlh
MmY3ZGFlNjY2N2U1MzNlMmQ3MzViNDg4MmQwOmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xNzo1
ODoyOCA3MjI1NTIyYmI0MjlhMmY3ZGFlNjY2N2U1MzNlMmQ3MzViNDg4MmQwIGNvbXBpbGlu
Zwo3MzEgcmVhbCAgNDkyNyB1c2VyICA0MjMgc3lzICA3MzIuMDAlIGNwdSAJeDg2XzY0LWFs
bHllc2RlYmlhbgoKMjAxMy0xMC0wOC0xODoxMDo1NyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAz
LjExLjAtMDkxODgtZzcyMjU1MjIuLi4uLi4uLi4uLi4uLi4uLi4uLgk3CTE3CTIwIFNVQ0NF
U1MKCkJpc2VjdGluZzogNDMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDYgc3RlcHMpCltmYTY4ODIwN2M5ZGI0OGI2NGFiNjUzOGFiYzNmY2RmMjYxMTBi
OWVjXSBzbXA6IHF1aXQgdW5jb25kaXRpb25hbGx5IGVuYWJsaW5nIGlycSBpbiBvbl9lYWNo
X2NwdV9tYXNrIGFuZCBvbl9lYWNoX2NwdV9jb25kCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3Rz
L2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdAps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWFsbHllc2RlYmlhbi9s
aW51czptYXN0ZXI6ZmE2ODgyMDdjOWRiNDhiNjRhYjY1MzhhYmMzZmNkZjI2MTEwYjllYzpi
aXNlY3QtbW0KCjIwMTMtMTAtMDgtMTg6MjI6MjggZmE2ODgyMDdjOWRiNDhiNjRhYjY1Mzhh
YmMzZmNkZjI2MTEwYjllYyBjb21waWxpbmcKNzI0IHJlYWwgIDQ5NjAgdXNlciAgNDM0IHN5
cyAgNzQ1LjAzJSBjcHUgCXg4Nl82NC1hbGx5ZXNkZWJpYW4KCjIwMTMtMTAtMDgtMTg6MzQ6
NDcgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTA5MjMxLWdmYTY4ODIwLiBURVNUIEZB
SUxVUkUKWyAgICAxLjgwMjAyNV0gcGNpIDAwMDA6MDA6MDIuMDogQm9vdCB2aWRlbyBkZXZp
Y2UKWyAgICAxLjgwMzUzMV0gUENJOiBDTFMgMCBieXRlcywgZGVmYXVsdCA2NApbICAgIDIu
MTEwOTgyXSBzd2FwcGVyLzAgaW52b2tlZCBvb20ta2lsbGVyOiBnZnBfbWFzaz0weDIwMDBk
MCwgb3JkZXI9MSwgb29tX3Njb3JlX2Fkaj0wClsgICAgMi4xMTM0OTJdIHN3YXBwZXIvMCBj
cHVzZXQ9LyBtZW1zX2FsbG93ZWQ9MApbICAgIDIuMTE0ODM0XSBDUFU6IDEgUElEOiAxIENv
bW06IHN3YXBwZXIvMCBOb3QgdGFpbnRlZCAzLjExLjAtMDkyMzEtZ2ZhNjg4MjAgIzQyNQpb
ICAgIDIuMTE3MDY0XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAw
MS8wMS8yMDExClsgICAgMi4xMTg2OTBdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMWVm
NzliMTggZmZmZmZmZmY4MmM1NWE4ZiBmZmZmODgwMDFlZjc0MDQwClsgICAgMi4xMjE0Nzld
ICBmZmZmODgwMDFlZjc5Yjk4IGZmZmZmZmZmODJjNGRlMTYgZmZmZmZmZmY4M2M1NDU4MCBm
ZmZmODgwMDFlZjc5YjUwClsgICAgMi4xMjQyNzhdICBmZmZmZmZmZjgxMGVlMDc3IDAwMDAw
MDAwMDAwMDFiZTEgMDAwMDAwMDAwMDAwMDI0NiBmZmZmODgwMDFlZjc5Yjg4ClsgICAgMi4x
MjY5NDNdIENhbGwgVHJhY2U6ClsgICAgMi4xMjc5MDJdICBbPGZmZmZmZmZmODJjNTVhOGY+
XSBkdW1wX3N0YWNrKzB4NTQvMHg3NApbICAgIDIuMTI5NDUwXSAgWzxmZmZmZmZmZjgyYzRk
ZTE2Pl0gZHVtcF9oZWFkZXIuaXNyYS4xMCsweDdhLzB4MWJhClsgICAgMi4xMzExMjBdICBb
PGZmZmZmZmZmODEwZWUwNzc+XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0LjI3KzB4
NGMvMHg1MApbICAgIDIuMTMzMDEyXSAgWzxmZmZmZmZmZjgxMGYxYWNlPl0gPyBsb2NrX3Jl
bGVhc2UrMHgxODkvMHgxZDEKWyAgICAyLjEzNDU4Nl0gIFs8ZmZmZmZmZmY4MTE1MmRlNT5d
IG91dF9vZl9tZW1vcnkrMHgzOWUvMHgzZWUKWyAgICAyLjEzNjIyM10gIFs8ZmZmZmZmZmY4
MTE1NzczMj5dIF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHg2NjgvMHg3ZGUKWyAgICAyLjEz
ODA4MV0gIFs8ZmZmZmZmZmY4MTE4ZTA0OT5dIGttZW1fZ2V0cGFnZXMrMHg3NS8weDE2Ywpb
ICAgIDIuMTM5NTg1XSAgWzxmZmZmZmZmZjgxMTkwMjE2Pl0gZmFsbGJhY2tfYWxsb2MrMHgx
MmMvMHgxZWEKWyAgICAyLjE0MTIzMV0gIFs8ZmZmZmZmZmY4MTBlZGE1OT5dID8gdHJhY2Vf
aGFyZGlycXNfb2ZmKzB4ZC8weGYKWyAgICAyLjE0Mjc5NF0gIFs8ZmZmZmZmZmY4MTE5MDBk
Yj5dIF9fX19jYWNoZV9hbGxvY19ub2RlKzB4MTRhLzB4MTU5ClsgICAgMi4xNDQ1MDZdICBb
PGZmZmZmZmZmODExOTBhMDc+XSBfX2ttYWxsb2MrMHg5NS8weDEyZApbICAgIDIuMTQ1OTg3
XSAgWzxmZmZmZmZmZjgxNzAxOTU4Pl0gPyBremFsbG9jLmNvbnN0cHJvcC4xNisweGUvMHgx
MApbICAgIDIuMTQ3NjMzXSAgWzxmZmZmZmZmZjgxNzAxOTU4Pl0ga3phbGxvYy5jb25zdHBy
b3AuMTYrMHhlLzB4MTAKWyAgICAyLjE0OTM3NF0gIFs8ZmZmZmZmZmY4MTcwMzBjYj5dIGRt
YV9kZWJ1Z19pbml0KzB4MWUzLzB4MjhlClsgICAgMi4xNTA5NjNdICBbPGZmZmZmZmZmODQx
OTczMjk+XSBwY2lfaW9tbXVfaW5pdCsweDE2LzB4NTIKWyAgICAyLjE1MjU1MF0gIFs8ZmZm
ZmZmZmY4NDE5NzMxMz5dID8gaW9tbXVfc2V0dXArMHgyN2QvMHgyN2QKWyAgICAyLjE1NDA3
OF0gIFs8ZmZmZmZmZmY4MTAwMjBkMj5dIGRvX29uZV9pbml0Y2FsbCsweDkzLzB4MTM3Clsg
ICAgMi4xNTU2NTRdICBbPGZmZmZmZmZmODEwYmQzMDA+XSA/IHBhcmFtZXErMHg0LzB4MjQK
WyAgICAyLjE1NzExOV0gIFs8ZmZmZmZmZmY4MTBiZDRhOT5dID8gcGFyc2VfYXJncysweDE4
OS8weDI0NwpbICAgIDIuMTU4Njk4XSAgWzxmZmZmZmZmZjg0MThhZWQxPl0ga2VybmVsX2lu
aXRfZnJlZWFibGUrMHgxNWUvMHgxZGYKWyAgICAyLjE2MDQzN10gIFs8ZmZmZmZmZmY4NDE4
YTcyOT5dID8gZG9fZWFybHlfcGFyYW0rMHg4OC8weDg4ClsgICAgMi4xNjE5ODddICBbPGZm
ZmZmZmZmODJjNDFjYzc+XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAyLjE2MzM5MV0g
IFs8ZmZmZmZmZmY4MmM0MWNkNT5dIGtlcm5lbF9pbml0KzB4ZS8weGRiClsgICAgMi4xNjQ4
NzVdICBbPGZmZmZmZmZmODJjODMxMmM+XSByZXRfZnJvbV9mb3JrKzB4N2MvMHhiMApbICAg
IDIuMTY2MzU4XSAgWzxmZmZmZmZmZjgyYzQxY2M3Pl0gPyByZXN0X2luaXQrMHhkYi8weGRi
ClsgICAgMi4xNjc5MThdIE1lbS1JbmZvOgpbICAgIDIuMTY4ODQ3XSBOb2RlIDAgRE1BIHBl
ci1jcHU6Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9mYTY4ODIwN2M5ZGI0OGI2NGFi
NjUzOGFiYzNmY2RmMjYxMTBiOWVjL2RtZXNnLW5mc3Jvb3QtaW5uLTk6MjAxMzEwMDgxODM1
MDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMzEtZ2ZhNjg4MjA6NDI1Ci9rZXJu
ZWwveDg2XzY0LWFsbHllc2RlYmlhbi9mYTY4ODIwN2M5ZGI0OGI2NGFiNjUzOGFiYzNmY2Rm
MjYxMTBiOWVjL2RtZXNnLW5mc3Jvb3QteGlhbi0zMDoyMDEzMTAwODE4MzUwMTp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTEuMC0wOTIzMS1nZmE2ODgyMDo0MjUKL2tlcm5lbC94ODZfNjQt
YWxseWVzZGViaWFuL2ZhNjg4MjA3YzlkYjQ4YjY0YWI2NTM4YWJjM2ZjZGYyNjExMGI5ZWMv
ZG1lc2ctbmZzcm9vdC1jYWlyby0xOToyMDEzMTAwODE4MzUxMjp4ODZfNjQtYWxseWVzZGVi
aWFuOjMuMTEuMC0wOTIzMS1nZmE2ODgyMDo0MjUKL2tlcm5lbC94ODZfNjQtYWxseWVzZGVi
aWFuL2ZhNjg4MjA3YzlkYjQ4YjY0YWI2NTM4YWJjM2ZjZGYyNjExMGI5ZWMvZG1lc2ctbmZz
cm9vdC13YWltZWEtMjoyMDEzMTAwOTAyMzIwNDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEu
MC0wOTIzMS1nZmE2ODgyMDo0MjUKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2ZhNjg4
MjA3YzlkYjQ4YjY0YWI2NTM4YWJjM2ZjZGYyNjExMGI5ZWMvZG1lc2ctbmZzcm9vdC14aWFu
LTY6MjAxMzEwMDgxODM1MTI6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMzEtZ2Zh
Njg4MjA6NDI1Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9mYTY4ODIwN2M5ZGI0OGI2
NGFiNjUzOGFiYzNmY2RmMjYxMTBiOWVjL2RtZXNnLW5mc3Jvb3QtY2Fpcm8tMjg6MjAxMzEw
MDgxODM1MTM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMzEtZ2ZhNjg4MjA6NDI1
Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9mYTY4ODIwN2M5ZGI0OGI2NGFiNjUzOGFi
YzNmY2RmMjYxMTBiOWVjL2RtZXNnLW5mc3Jvb3QtY2Fpcm8tMzE6MjAxMzEwMDgxODM1MTM6
eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMzEtZ2ZhNjg4MjA6NDI1Ci9rZXJuZWwv
eDg2XzY0LWFsbHllc2RlYmlhbi9mYTY4ODIwN2M5ZGI0OGI2NGFiNjUzOGFiYzNmY2RmMjYx
MTBiOWVjL2RtZXNnLXlvY3RvLXNuYi00OjIwMTMxMDA4MTgzNTEzOng4Nl82NC1hbGx5ZXNk
ZWJpYW46My4xMS4wLTA5MjMxLWdmYTY4ODIwOjQyNQova2VybmVsL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vZmE2ODgyMDdjOWRiNDhiNjRhYjY1MzhhYmMzZmNkZjI2MTEwYjllYy9kbWVzZy1u
ZnNyb290LXdhaW1lYS0xMDoyMDEzMTAwOTAyMzIxMTp4ODZfNjQtYWxseWVzZGViaWFuOjMu
MTEuMC0wOTIzMS1nZmE2ODgyMDo0MjUKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2Zh
Njg4MjA3YzlkYjQ4YjY0YWI2NTM4YWJjM2ZjZGYyNjExMGI5ZWMvZG1lc2ctcXVhbnRhbC1i
YXktMToyMDEzMTAwODE4MzUxNjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTIzMS1n
ZmE2ODgyMDo0MjUKMDoxMDo3IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rp
bmc6IDIxIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA1IHN0
ZXBzKQpbYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEwNzYxNF0gbW0vaHdw
b2lzb246IGFkZCAnIycgdG8gbWFkdmlzZV9od3BvaXNvbgpydW5uaW5nIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21tL29iai1iaXNl
Y3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1hbGx5ZXNkZWJp
YW4vbGludXM6bWFzdGVyOmIxOTRiOGNkYjgzZGFhZmQyNDA1ZmI5MDIxOTNiOGU5MDQxMDc2
MTQ6YmlzZWN0LW1tCgoyMDEzLTEwLTA4LTE4OjM1OjIwIGIxOTRiOGNkYjgzZGFhZmQyNDA1
ZmI5MDIxOTNiOGU5MDQxMDc2MTQgY29tcGlsaW5nCjczMSByZWFsICA0OTU0IHVzZXIgIDQy
MyBzeXMgIDczNS4xNSUgY3B1IAl4ODZfNjQtYWxseWVzZGViaWFuCgoyMDEzLTEwLTA4LTE4
OjQ3OjQ1IGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wOTIwOS1nYjE5NGI4Yy4uLiBU
RVNUIEZBSUxVUkUKWyAgICAxLjkxMzQyNF0gcGNpIDAwMDA6MDA6MDIuMDogQm9vdCB2aWRl
byBkZXZpY2UKWyAgICAxLjkxNDU4OV0gUENJOiBDTFMgMCBieXRlcywgZGVmYXVsdCA2NApb
ICAgIDIuMTkwNzc1XSBzd2FwcGVyLzAgaW52b2tlZCBvb20ta2lsbGVyOiBnZnBfbWFzaz0w
eDIwMDBkMCwgb3JkZXI9MSwgb29tX3Njb3JlX2Fkaj0wClsgICAgMi4xOTI4NTNdIHN3YXBw
ZXIvMCBjcHVzZXQ9LyBtZW1zX2FsbG93ZWQ9MApbICAgIDIuMTkzOTk5XSBDUFU6IDEgUElE
OiAxIENvbW06IHN3YXBwZXIvMCBOb3QgdGFpbnRlZCAzLjExLjAtMDkyMDktZ2IxOTRiOGMg
IzQyNgpbICAgIDIuMTk1ODc5XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBC
b2NocyAwMS8wMS8yMDExClsgICAgMi4xOTc0MzRdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4
ODAwMWVmNzliMTggZmZmZmZmZmY4MmM1NTlhZiBmZmZmODgwMDFlZjc0MDQwClsgICAgMi4x
OTk5NTFdICBmZmZmODgwMDFlZjc5Yjk4IGZmZmZmZmZmODJjNGRkMzYgZmZmZmZmZmY4M2M1
NDU4MCBmZmZmODgwMDFlZjc5YjUwClsgICAgMi4yMDI1MTJdICBmZmZmZmZmZjgxMGVlMDZl
IDAwMDAwMDAwMDAwMDI0YzEgMDAwMDAwMDAwMDAwMDI0NiBmZmZmODgwMDFlZjc5Yjg4Clsg
ICAgMi4yMDUxMjBdIENhbGwgVHJhY2U6ClsgICAgMi4yMDU5NzRdICBbPGZmZmZmZmZmODJj
NTU5YWY+XSBkdW1wX3N0YWNrKzB4NTQvMHg3NApbICAgIDIuMjA3NDIyXSAgWzxmZmZmZmZm
ZjgyYzRkZDM2Pl0gZHVtcF9oZWFkZXIuaXNyYS4xMCsweDdhLzB4MWJhClsgICAgMi4yMDg4
OTVdICBbPGZmZmZmZmZmODEwZWUwNmU+XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0
LjI3KzB4NGMvMHg1MApbICAgIDIuMjEwNDU5XSAgWzxmZmZmZmZmZjgxMGYxYWM1Pl0gPyBs
b2NrX3JlbGVhc2UrMHgxODkvMHgxZDEKWyAgICAyLjIxMTgyMl0gIFs8ZmZmZmZmZmY4MTE1
MmRkZD5dIG91dF9vZl9tZW1vcnkrMHgzOWUvMHgzZWUKWyAgICAyLjIxMzIxOF0gIFs8ZmZm
ZmZmZmY4MTE1NzcyYT5dIF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHg2NjgvMHg3ZGUKWyAg
ICAyLjIxNDY4MV0gIFs8ZmZmZmZmZmY4MTE4ZTAzMj5dIGttZW1fZ2V0cGFnZXMrMHg3NS8w
eDE2YwpbICAgIDIuMjE1OTg2XSAgWzxmZmZmZmZmZjgxMTkwMWZmPl0gZmFsbGJhY2tfYWxs
b2MrMHgxMmMvMHgxZWEKWyAgICAyLjIxNzUyNl0gIFs8ZmZmZmZmZmY4MTBlZGE1MD5dID8g
dHJhY2VfaGFyZGlycXNfb2ZmKzB4ZC8weGYKWyAgICAyLjIxOTAxMV0gIFs8ZmZmZmZmZmY4
MTE5MDBjND5dIF9fX19jYWNoZV9hbGxvY19ub2RlKzB4MTRhLzB4MTU5ClsgICAgMi4yMjA2
MDZdICBbPGZmZmZmZmZmODExOTA5ZjA+XSBfX2ttYWxsb2MrMHg5NS8weDEyZApbICAgIDIu
MjIxOTU5XSAgWzxmZmZmZmZmZjgxNzAxOTE4Pl0gPyBremFsbG9jLmNvbnN0cHJvcC4xNisw
eGUvMHgxMApbICAgIDIuMjIzNTAwXSAgWzxmZmZmZmZmZjgxNzAxOTE4Pl0ga3phbGxvYy5j
b25zdHByb3AuMTYrMHhlLzB4MTAKWyAgICAyLjIyNTA0OF0gIFs8ZmZmZmZmZmY4MTcwMzA4
Yj5dIGRtYV9kZWJ1Z19pbml0KzB4MWUzLzB4MjhlClsgICAgMi4yMjY0NTldICBbPGZmZmZm
ZmZmODQxOTczMjk+XSBwY2lfaW9tbXVfaW5pdCsweDE2LzB4NTIKWyAgICAyLjIyNzc2N10g
IFs8ZmZmZmZmZmY4NDE5NzMxMz5dID8gaW9tbXVfc2V0dXArMHgyN2QvMHgyN2QKWyAgICAy
LjIyOTE3MF0gIFs8ZmZmZmZmZmY4MTAwMjBkMj5dIGRvX29uZV9pbml0Y2FsbCsweDkzLzB4
MTM3ClsgICAgMi4yMzA1MzBdICBbPGZmZmZmZmZmODEwYmQzMDA+XSA/IHBhcmFtZXErMHhk
LzB4MjQKWyAgICAyLjIzMTc1OF0gIFs8ZmZmZmZmZmY4MTBiZDRhMD5dID8gcGFyc2VfYXJn
cysweDE4OS8weDI0NwpbICAgIDIuMjMzMDk1XSAgWzxmZmZmZmZmZjg0MThhZWQxPl0ga2Vy
bmVsX2luaXRfZnJlZWFibGUrMHgxNWUvMHgxZGYKWyAgICAyLjIzNDUxMl0gIFs8ZmZmZmZm
ZmY4NDE4YTcyOT5dID8gZG9fZWFybHlfcGFyYW0rMHg4OC8weDg4ClsgICAgMi4yMzU4NzRd
ICBbPGZmZmZmZmZmODJjNDFiZTc+XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAyLjIz
NzMxNV0gIFs8ZmZmZmZmZmY4MmM0MWJmNT5dIGtlcm5lbF9pbml0KzB4ZS8weGRiClsgICAg
Mi4yMzg2NjldICBbPGZmZmZmZmZmODJjODMwMmM+XSByZXRfZnJvbV9mb3JrKzB4N2MvMHhi
MApbICAgIDIuMjQwMTA1XSAgWzxmZmZmZmZmZjgyYzQxYmU3Pl0gPyByZXN0X2luaXQrMHhk
Yi8weGRiClsgICAgMi4yNDE0NzJdIE1lbS1JbmZvOgpbICAgIDIuMjQyMjg2XSBOb2RlIDAg
RE1BIHBlci1jcHU6Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9iMTk0YjhjZGI4M2Rh
YWZkMjQwNWZiOTAyMTkzYjhlOTA0MTA3NjE0L2RtZXNnLW5mc3Jvb3QtaW5uLTE5OjIwMTMx
MDA4MTg0ODAxOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQy
Ngova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkw
MjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy1uZnNyb290LWlubi0yMDoyMDEzMTAwODE4NDgwMDp4
ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTIwOS1nYjE5NGI4Yzo0MjYKL2tlcm5lbC94
ODZfNjQtYWxseWVzZGViaWFuL2IxOTRiOGNkYjgzZGFhZmQyNDA1ZmI5MDIxOTNiOGU5MDQx
MDc2MTQvZG1lc2ctbmZzcm9vdC1sa3AtdHQwMi0xMDoyMDEzMTAwODA5MTkwNTp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTEuMC0wOTIwOS1nYjE5NGI4Yzo0MjYKL2tlcm5lbC94ODZfNjQt
YWxseWVzZGViaWFuL2IxOTRiOGNkYjgzZGFhZmQyNDA1ZmI5MDIxOTNiOGU5MDQxMDc2MTQv
ZG1lc2ctbmZzcm9vdC1yb2FtLTMwOjIwMTMxMDA4MTg0ODA1Ong4Nl82NC1hbGx5ZXNkZWJp
YW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJp
YW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy1uZnNy
b290LXdhaW1lYS01OjIwMTMxMDA5MDI0NDUzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4w
LTA5MjA5LWdiMTk0YjhjOjQyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4
Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy1xdWFudGFsLWlubi0x
NToyMDEzMTAwODE4NDgwMjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTIwOS1nYjE5
NGI4Yzo0MjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2IxOTRiOGNkYjgzZGFhZmQy
NDA1ZmI5MDIxOTNiOGU5MDQxMDc2MTQvZG1lc2ctcXVhbnRhbC1pbm4tMjQ6MjAxMzEwMDgx
ODQ4MDA6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMDktZ2IxOTRiOGM6NDI2Ci9r
ZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9iMTk0YjhjZGI4M2RhYWZkMjQwNWZiOTAyMTkz
YjhlOTA0MTA3NjE0L2RtZXNnLXF1YW50YWwtaW5uLTI4OjIwMTMxMDA4MTg0NzU0Ong4Nl82
NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgova2VybmVsL3g4Nl82
NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEwNzYx
NC9kbWVzZy1xdWFudGFsLWlubi0yOToyMDEzMTAwODE4NDc1NDp4ODZfNjQtYWxseWVzZGVi
aWFuOjMuMTEuMC0wOTIwOS1nYjE5NGI4Yzo0MjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGVi
aWFuL2IxOTRiOGNkYjgzZGFhZmQyNDA1ZmI5MDIxOTNiOGU5MDQxMDc2MTQvZG1lc2ctcXVh
bnRhbC1pbm4tNDc6MjAxMzEwMDgxODQ3NTU6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAt
MDkyMDktZ2IxOTRiOGM6NDI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9iMTk0Yjhj
ZGI4M2RhYWZkMjQwNWZiOTAyMTkzYjhlOTA0MTA3NjE0L2RtZXNnLXF1YW50YWwtamFrZXRv
d24tNjoyMDEzMTAwODE4NDgwOTp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTIwOS1n
YjE5NGI4Yzo0MjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2IxOTRiOGNkYjgzZGFh
ZmQyNDA1ZmI5MDIxOTNiOGU5MDQxMDc2MTQvZG1lc2ctcXVhbnRhbC1zdG9ha2xleS00OjIw
MTMxMDA4MTg0ODAzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0Yjhj
OjQyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVm
YjkwMjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy15b2N0by1pbm4tMjM6MjAxMzEwMDgxODQ4MDA6
eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkyMDktZ2IxOTRiOGM6NDI2Ci9rZXJuZWwv
eDg2XzY0LWFsbHllc2RlYmlhbi9iMTk0YjhjZGI4M2RhYWZkMjQwNWZiOTAyMTkzYjhlOTA0
MTA3NjE0L2RtZXNnLXlvY3RvLWlubi0zOjIwMTMxMDA4MTg0ODAxOng4Nl82NC1hbGx5ZXNk
ZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy15
b2N0by1qYWtldG93bi0yMzoyMDEzMTAwODE4NDgxMDp4ODZfNjQtYWxseWVzZGViaWFuOjMu
MTEuMC0wOTIwOS1nYjE5NGI4Yzo0MjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2Ix
OTRiOGNkYjgzZGFhZmQyNDA1ZmI5MDIxOTNiOGU5MDQxMDc2MTQvZG1lc2cteW9jdG8tamFr
ZXRvd24tMjY6MjAxMzEwMDgxODQ4MDY6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDky
MDktZ2IxOTRiOGM6NDI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9iMTk0YjhjZGI4
M2RhYWZkMjQwNWZiOTAyMTkzYjhlOTA0MTA3NjE0L2RtZXNnLXlvY3RvLWpha2V0b3duLTI4
OjIwMTMxMDA4MTg0ODA3Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0
YjhjOjQyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0
MDVmYjkwMjE5M2I4ZTkwNDEwNzYxNC9kbWVzZy15b2N0by1sa3AtdHQwMi00OjIwMTMxMDA4
MDkxOTAzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgov
a2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5
M2I4ZTkwNDEwNzYxNC9kbWVzZy15b2N0by1sa3AtdHQwMi01OjIwMTMxMDA4MDkxOTEwOng4
Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgova2VybmVsL3g4
Nl82NC1hbGx5ZXNkZWJpYW4vYjE5NGI4Y2RiODNkYWFmZDI0MDVmYjkwMjE5M2I4ZTkwNDEw
NzYxNC9kbWVzZy15b2N0by1sa3AtdHQwMi04OjIwMTMxMDA4MDkxOTA0Ong4Nl82NC1hbGx5
ZXNkZWJpYW46My4xMS4wLTA5MjA5LWdiMTk0YjhjOjQyNgowOjIwOjE3IGFsbF9nb29kOmJh
ZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rpbmc6IDEwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3Qg
YWZ0ZXIgdGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbNGMzYmZmYzI3Mjc1NWM5ODcyOGMyYjU4
YjFhODE0OGNmOWU5ZmQxZl0gbW0vYmFja2luZy1kZXYuYzogY2hlY2sgdXNlciBidWZmZXIg
bGVuZ3RoIGJlZm9yZSBjb3B5aW5nIGRhdGEgdG8gdGhlIHJlbGF0ZWQgdXNlciBidWZmZXIK
cnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9o
b21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo0YzNiZmZjMjcyNzU1Yzk4NzI4
YzJiNThiMWE4MTQ4Y2Y5ZTlmZDFmOmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xODo0OToxOCA0
YzNiZmZjMjcyNzU1Yzk4NzI4YzJiNThiMWE4MTQ4Y2Y5ZTlmZDFmIGNvbXBpbGluZwo3NTQg
cmVhbCAgNDk0NSB1c2VyICA0MzUgc3lzICA3MTMuNjMlIGNwdSAJeDg2XzY0LWFsbHllc2Rl
YmlhbgoKMjAxMy0xMC0wOC0xOTowMjoxOCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAt
MDkxOTgtZzRjM2JmZmMuIFRFU1QgRkFJTFVSRQpbICAgIDEuNzQ1MzQ1XSBwY2kgMDAwMDow
MDowMi4wOiBCb290IHZpZGVvIGRldmljZQpbICAgIDEuNzQ3Mjc4XSBQQ0k6IENMUyAwIGJ5
dGVzLCBkZWZhdWx0IDY0ClsgICAgMi4wODg5ODFdIHN3YXBwZXIvMCBpbnZva2VkIG9vbS1r
aWxsZXI6IGdmcF9tYXNrPTB4MjAwMGQwLCBvcmRlcj0xLCBvb21fc2NvcmVfYWRqPTAKWyAg
ICAyLjA5MTM0Nl0gc3dhcHBlci8wIGNwdXNldD0vIG1lbXNfYWxsb3dlZD0wClsgICAgMi4w
OTI2MjddIENQVTogMSBQSUQ6IDEgQ29tbTogc3dhcHBlci8wIE5vdCB0YWludGVkIDMuMTEu
MC0wOTE5OC1nNGMzYmZmYyAjNDI3ClsgICAgMi4wOTQ3ODBdIEhhcmR3YXJlIG5hbWU6IEJv
Y2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgICAyLjA5NjMyNl0gIDAwMDAw
MDAwMDAwMDAwMDIgZmZmZjg4MDAxZWY3OWIxOCBmZmZmZmZmZjgyYzU1ODJkIGZmZmY4ODAw
MWVmNzQwNDAKWyAgICAyLjA5OTAwOV0gIGZmZmY4ODAwMWVmNzliOTggZmZmZmZmZmY4MmM0
ZGNiNiBmZmZmZmZmZjgzYzU0NTgwIGZmZmY4ODAwMWVmNzliNTAKWyAgICAyLjEwMTc2Ml0g
IGZmZmZmZmZmODEwZWUwNmUgMDAwMDAwMDAwMDAwMjgyMSAwMDAwMDAwMDAwMDAwMjQ2IGZm
ZmY4ODAwMWVmNzliODgKWyAgICAyLjEwNDQyN10gQ2FsbCBUcmFjZToKWyAgICAyLjEwNTM2
Ml0gIFs8ZmZmZmZmZmY4MmM1NTgyZD5dIGR1bXBfc3RhY2srMHg1NC8weDc0ClsgICAgMi4x
MDY3NDBdICBbPGZmZmZmZmZmODJjNGRjYjY+XSBkdW1wX2hlYWRlci5pc3JhLjEwKzB4N2Ev
MHgxYmEKWyAgICAyLjEwODM1N10gIFs8ZmZmZmZmZmY4MTBlZTA2ZT5dID8gbG9ja19yZWxl
YXNlX2hvbGR0aW1lLnBhcnQuMjcrMHg0Yy8weDUwClsgICAgMi4xMTAxOTddICBbPGZmZmZm
ZmZmODEwZjFhYzU+XSA/IGxvY2tfcmVsZWFzZSsweDE4OS8weDFkMQpbICAgIDIuMTExNzE5
XSAgWzxmZmZmZmZmZjgxMTUyZGRkPl0gb3V0X29mX21lbW9yeSsweDM5ZS8weDNlZQpbICAg
IDIuMTEzMzAyXSAgWzxmZmZmZmZmZjgxMTU3NzJhPl0gX19hbGxvY19wYWdlc19ub2RlbWFz
aysweDY2OC8weDdkZQpbICAgIDIuMTE0OTkwXSAgWzxmZmZmZmZmZjgxMThkZWRmPl0ga21l
bV9nZXRwYWdlcysweDc1LzB4MTZjClsgICAgMi4xMTY1MTRdICBbPGZmZmZmZmZmODExOTAw
YWM+XSBmYWxsYmFja19hbGxvYysweDEyYy8weDFlYQpbICAgIDIuMTE4MDQzXSAgWzxmZmZm
ZmZmZjgxMGVkYTUwPl0gPyB0cmFjZV9oYXJkaXJxc19vZmYrMHhkLzB4ZgpbICAgIDIuMTE5
NDUyXSAgWzxmZmZmZmZmZjgxMThmZjcxPl0gX19fX2NhY2hlX2FsbG9jX25vZGUrMHgxNGEv
MHgxNTkKWyAgICAyLjEyMTE2OF0gIFs8ZmZmZmZmZmY4MTE5MDg5ZD5dIF9fa21hbGxvYysw
eDk1LzB4MTJkClsgICAgMi4xMjI1MzldICBbPGZmZmZmZmZmODE3MDE4OTg+XSA/IGt6YWxs
b2MuY29uc3Rwcm9wLjE2KzB4ZS8weDEwClsgICAgMi4xMjQyMDRdICBbPGZmZmZmZmZmODE3
MDE4OTg+XSBremFsbG9jLmNvbnN0cHJvcC4xNisweGUvMHgxMApbICAgIDIuMTI1NzU1XSAg
WzxmZmZmZmZmZjgxNzAzMDBiPl0gZG1hX2RlYnVnX2luaXQrMHgxZTMvMHgyOGUKWyAgICAy
LjEyNzI1OV0gIFs8ZmZmZmZmZmY4NDE5NzMyOT5dIHBjaV9pb21tdV9pbml0KzB4MTYvMHg1
MgpbICAgIDIuMTI4ODE1XSAgWzxmZmZmZmZmZjg0MTk3MzEzPl0gPyBpb21tdV9zZXR1cCsw
eDI3ZC8weDI3ZApbICAgIDIuMTMwMzQ0XSAgWzxmZmZmZmZmZjgxMDAyMGQyPl0gZG9fb25l
X2luaXRjYWxsKzB4OTMvMHgxMzcKWyAgICAyLjEzMTg1OV0gIFs8ZmZmZmZmZmY4MTBiZDMw
MD5dID8gcGFyYW1lcSsweGQvMHgyNApbICAgIDIuMTMzMjQ1XSAgWzxmZmZmZmZmZjgxMGJk
NGEwPl0gPyBwYXJzZV9hcmdzKzB4MTg5LzB4MjQ3ClsgICAgMi4xMzQ3MTRdICBbPGZmZmZm
ZmZmODQxOGFlZDE+XSBrZXJuZWxfaW5pdF9mcmVlYWJsZSsweDE1ZS8weDFkZgpbICAgIDIu
MTM2MzMzXSAgWzxmZmZmZmZmZjg0MThhNzI5Pl0gPyBkb19lYXJseV9wYXJhbSsweDg4LzB4
ODgKWyAgICAyLjEzNzc3MF0gIFs8ZmZmZmZmZmY4MmM0MWI2Nz5dID8gcmVzdF9pbml0KzB4
ZGIvMHhkYgpbICAgIDIuMTM5MTY2XSAgWzxmZmZmZmZmZjgyYzQxYjc1Pl0ga2VybmVsX2lu
aXQrMHhlLzB4ZGIKWyAgICAyLjE0MDcxOF0gIFs8ZmZmZmZmZmY4MmM4MmVhYz5dIHJldF9m
cm9tX2ZvcmsrMHg3Yy8weGIwClsgICAgMi4xNDIxNzJdICBbPGZmZmZmZmZmODJjNDFiNjc+
XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAyLjE0MzYwNl0gTWVtLUluZm86ClsgICAg
Mi4xNDQ1MDRdIE5vZGUgMCBETUEgcGVyLWNwdToKL2tlcm5lbC94ODZfNjQtYWxseWVzZGVi
aWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ctbmZz
cm9vdC13YWltZWEtMToyMDEzMTAwOTAyNTkyNDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEu
MC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2Jm
ZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ctbmZzcm9vdC13YWlt
ZWEtNDoyMDEzMTAwOTAyNTkyMTp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5OC1n
NGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3NTVj
OTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ctcXVhbnRhbC14cHMtMjoyMDEzMTAw
OTAyNTg1MDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcK
L2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIx
YTgxNDhjZjllOWZkMWYvZG1lc2ctbmZzcm9vdC1pbm4tMToyMDEzMTAwODE5MDIzMTp4ODZf
NjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZf
NjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZk
MWYvZG1lc2ctbmZzcm9vdC13YWltZWEtNDoyMDEzMTAwOTAyNTkzMTp4ODZfNjQtYWxseWVz
ZGViaWFuOjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVz
ZGViaWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ct
bmZzcm9vdC13YWltZWEtOToyMDEzMTAwOTAyNTkyOTp4ODZfNjQtYWxseWVzZGViaWFuOjMu
MTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRj
M2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ctcXVhbnRhbC1j
YWlyby00MDoyMDEzMTAwODE5MDIzNjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5
OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3
NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2ctcXVhbnRhbC1pbm4tMjU6MjAx
MzEwMDgxOTAyMzM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTgtZzRjM2JmZmM6
NDI3Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi80YzNiZmZjMjcyNzU1Yzk4NzI4YzJi
NThiMWE4MTQ4Y2Y5ZTlmZDFmL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtMzoyMDEzMTAwODE5
MDIzNDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tl
cm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgx
NDhjZjllOWZkMWYvZG1lc2ctcXVhbnRhbC1sa3AtdHQwMi0yMToyMDEzMTAwODA5MzMzNjp4
ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94
ODZfNjQtYWxseWVzZGViaWFuLzRjM2JmZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjll
OWZkMWYvZG1lc2cteW9jdG8tYmVucy0xOjIwMTMxMDA4MTkwMjM2Ong4Nl82NC1hbGx5ZXNk
ZWJpYW46My4xMS4wLTA5MTk4LWc0YzNiZmZjOjQyNwova2VybmVsL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vNGMzYmZmYzI3Mjc1NWM5ODcyOGMyYjU4YjFhODE0OGNmOWU5ZmQxZi9kbWVzZy15
b2N0by1jYWlyby00ODoyMDEzMTAwODE5MDIzNjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEu
MC0wOTE5OC1nNGMzYmZmYzo0MjcKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzRjM2Jm
ZmMyNzI3NTVjOTg3MjhjMmI1OGIxYTgxNDhjZjllOWZkMWYvZG1lc2cteW9jdG8tbGtwLXR0
MDItMjE6MjAxMzEwMDgwOTMzMzY6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTgt
ZzRjM2JmZmM6NDI3Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi80YzNiZmZjMjcyNzU1
Yzk4NzI4YzJiNThiMWE4MTQ4Y2Y5ZTlmZDFmL2RtZXNnLW5mc3Jvb3Qtd2FpbWVhLTE6MjAx
MzEwMDkwMjU5MzM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTgtZzRjM2JmZmM6
NDI3Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi80YzNiZmZjMjcyNzU1Yzk4NzI4YzJi
NThiMWE4MTQ4Y2Y5ZTlmZDFmL2RtZXNnLXlvY3RvLXN0b2FrbGV5LTI6MjAxMzEwMDgxOTAy
NDA6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTgtZzRjM2JmZmM6NDI3Ci9rZXJu
ZWwveDg2XzY0LWFsbHllc2RlYmlhbi80YzNiZmZjMjcyNzU1Yzk4NzI4YzJiNThiMWE4MTQ4
Y2Y5ZTlmZDFmL2RtZXNnLXlvY3RvLWxrcC1zdDAxLTk6MjAxMzEwMDgxOTAyNDE6eDg2XzY0
LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTgtZzRjM2JmZmM6NDI3Ci9rZXJuZWwveDg2XzY0
LWFsbHllc2RlYmlhbi80YzNiZmZjMjcyNzU1Yzk4NzI4YzJiNThiMWE4MTQ4Y2Y5ZTlmZDFm
L2RtZXNnLXlvY3RvLWlubi0xNzoyMDEzMTAwODE5MDI0NDp4ODZfNjQtYWxseWVzZGViaWFu
OjMuMTEuMC0wOTE5OC1nNGMzYmZmYzo0MjcKMDoxNzoxNyBhbGxfZ29vZDpiYWQ6YWxsX2Jh
ZCBib290cwobWzE7MzVtUkVQRUFUIENPVU5UOiAyMCAgIyAvY2Mvd2ZnL21tLWJpc2VjdC8u
cmVwZWF0G1swbQoKQmlzZWN0aW5nOiA0IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIg
dGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbNmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMw
ZGIzNDU3YTdlZF0gbW06IHZtc2NhbjogZml4IGRvX3RyeV90b19mcmVlX3BhZ2VzKCkgbGl2
ZWxvY2sKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1
ZXVlL2t2bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo2ZTU0M2Q1NzgwZTM2
ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkOmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xOTow
Mjo1MyA2ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkIGNvbXBpbGlu
ZwoyMDcgcmVhbCAgMTEzMSB1c2VyICA5MCBzeXMgIDU4OC4wOCUgY3B1IAl4ODZfNjQtYWxs
eWVzZGViaWFuCgoyMDEzLTEwLTA4LTE5OjA4OjQyIGRldGVjdGluZyBib290IHN0YXRlIDMu
MTEuMC0wOTE5My1nNmU1NDNkNS4gVEVTVCBGQUlMVVJFClsgICAgNC40NjUzNDddIHBjaSAw
MDAwOjAwOjAyLjA6IEJvb3QgdmlkZW8gZGV2aWNlClsgICAgNC40NjY4NDFdIFBDSTogQ0xT
IDAgYnl0ZXMsIGRlZmF1bHQgNjQKWyAgICA1LjAxMDIwMl0gc3dhcHBlci8wIGludm9rZWQg
b29tLWtpbGxlcjogZ2ZwX21hc2s9MHgyMDAwZDAsIG9yZGVyPTEsIG9vbV9zY29yZV9hZGo9
MApbICAgIDUuMDEyNzUzXSBzd2FwcGVyLzAgY3B1c2V0PS8gbWVtc19hbGxvd2VkPTAKWyAg
ICA1LjAxNDEyMV0gQ1BVOiAxIFBJRDogMSBDb21tOiBzd2FwcGVyLzAgTm90IHRhaW50ZWQg
My4xMS4wLTA5MTkzLWc2ZTU0M2Q1ICM0MjgKWyAgICA1LjAxNjUwNF0gSGFyZHdhcmUgbmFt
ZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgIDUuMDE4MTg0XSAg
MDAwMDAwMDAwMDAwMDAwMiBmZmZmODgwMDFlZjc5YjE4IGZmZmZmZmZmODJjNTU4MmQgZmZm
Zjg4MDAxZWY3NDA0MApbICAgIDUuMDIxMTI0XSAgZmZmZjg4MDAxZWY3OWI5OCBmZmZmZmZm
ZjgyYzRkY2I2IGZmZmZmZmZmODNjNTQ1ODAgZmZmZjg4MDAxZWY3OWI1MApbICAgIDUuMDI0
MTUzXSAgZmZmZmZmZmY4MTBlZTA2ZSAwMDAwMDAwMDAwMDAxYTNhIDAwMDAwMDAwMDAwMDAy
NDYgZmZmZjg4MDAxZWY3OWI4OApbICAgIDUuMDI3MDEyXSBDYWxsIFRyYWNlOgpbICAgIDUu
MDI3OTgwXSAgWzxmZmZmZmZmZjgyYzU1ODJkPl0gZHVtcF9zdGFjaysweDU0LzB4NzQKWyAg
ICA1LjAyOTU0NF0gIFs8ZmZmZmZmZmY4MmM0ZGNiNj5dIGR1bXBfaGVhZGVyLmlzcmEuMTAr
MHg3YS8weDFiYQpbICAgIDUuMDMxMjY3XSAgWzxmZmZmZmZmZjgxMGVlMDZlPl0gPyBsb2Nr
X3JlbGVhc2VfaG9sZHRpbWUucGFydC4yNysweDRjLzB4NTAKWyAgICA1LjAzNDAxOV0gIFs8
ZmZmZmZmZmY4MTBmMWFjNT5dID8gbG9ja19yZWxlYXNlKzB4MTg5LzB4MWQxClsgICAgNS4w
MzU2NDRdICBbPGZmZmZmZmZmODExNTJkZGQ+XSBvdXRfb2ZfbWVtb3J5KzB4MzllLzB4M2Vl
ClsgICAgNS4wMzczMjVdICBbPGZmZmZmZmZmODExNTc3MmE+XSBfX2FsbG9jX3BhZ2VzX25v
ZGVtYXNrKzB4NjY4LzB4N2RlClsgICAgNS4wMzkxMTddICBbPGZmZmZmZmZmODExOGRlYzQ+
XSBrbWVtX2dldHBhZ2VzKzB4NzUvMHgxNmMKWyAgICA1LjA0MDc2MF0gIFs8ZmZmZmZmZmY4
MTE5MDA5MT5dIGZhbGxiYWNrX2FsbG9jKzB4MTJjLzB4MWVhClsgICAgNS4wNDI0OTFdICBb
PGZmZmZmZmZmODEwZWRhNTA+XSA/IHRyYWNlX2hhcmRpcnFzX29mZisweGQvMHhmClsgICAg
NS4wNDQyNThdICBbPGZmZmZmZmZmODExOGZmNTY+XSBfX19fY2FjaGVfYWxsb2Nfbm9kZSsw
eDE0YS8weDE1OQpbICAgIDUuMDQ2MDYzXSAgWzxmZmZmZmZmZjgxMTkwODgyPl0gX19rbWFs
bG9jKzB4OTUvMHgxMmQKWyAgICA1LjA0NzU3N10gIFs8ZmZmZmZmZmY4MTcwMTg5OD5dID8g
a3phbGxvYy5jb25zdHByb3AuMTYrMHhlLzB4MTAKWyAgICA1LjA0OTM2OV0gIFs8ZmZmZmZm
ZmY4MTcwMTg5OD5dIGt6YWxsb2MuY29uc3Rwcm9wLjE2KzB4ZS8weDEwClsgICAgNS4wNTEw
NTNdICBbPGZmZmZmZmZmODE3MDMwMGI+XSBkbWFfZGVidWdfaW5pdCsweDFlMy8weDI4ZQpb
ICAgIDUuMDUyNzY5XSAgWzxmZmZmZmZmZjg0MTk3MzI5Pl0gcGNpX2lvbW11X2luaXQrMHgx
Ni8weDUyClsgICAgNS4wNTQzNzBdICBbPGZmZmZmZmZmODQxOTczMTM+XSA/IGlvbW11X3Nl
dHVwKzB4MjdkLzB4MjdkClsgICAgNS4wNTU5ODZdICBbPGZmZmZmZmZmODEwMDIwZDI+XSBk
b19vbmVfaW5pdGNhbGwrMHg5My8weDEzNwpbICAgIDUuMDU3NjYyXSAgWzxmZmZmZmZmZjgx
MGJkMzAwPl0gPyBwYXJhbWVxKzB4ZC8weDI0ClsgICAgNS4wNTkxNTVdICBbPGZmZmZmZmZm
ODEwYmQ0YTA+XSA/IHBhcnNlX2FyZ3MrMHgxODkvMHgyNDcKWyAgICA1LjA2MDgyOV0gIFs8
ZmZmZmZmZmY4NDE4YWVkMT5dIGtlcm5lbF9pbml0X2ZyZWVhYmxlKzB4MTVlLzB4MWRmClsg
ICAgNS4wNjI2MTBdICBbPGZmZmZmZmZmODQxOGE3Mjk+XSA/IGRvX2Vhcmx5X3BhcmFtKzB4
ODgvMHg4OApbICAgIDUuMDY0Mjc0XSAgWzxmZmZmZmZmZjgyYzQxYjY3Pl0gPyByZXN0X2lu
aXQrMHhkYi8weGRiClsgICAgNS4wNjU4MTRdICBbPGZmZmZmZmZmODJjNDFiNzU+XSBrZXJu
ZWxfaW5pdCsweGUvMHhkYgpbICAgIDUuMDY3MzU2XSAgWzxmZmZmZmZmZjgyYzgyZWFjPl0g
cmV0X2Zyb21fZm9yaysweDdjLzB4YjAKWyAgICA1LjA2ODk5Ml0gIFs8ZmZmZmZmZmY4MmM0
MWI2Nz5dID8gcmVzdF9pbml0KzB4ZGIvMHhkYgpbICAgIDUuMDcwNTU2XSBNZW0tSW5mbzoK
WyAgICA1LjA3MTQ2N10gTm9kZSAwIERNQSBwZXItY3B1Ogova2VybmVsL3g4Nl82NC1hbGx5
ZXNkZWJpYW4vNmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9kbWVz
Zy1uZnNyb290LXdhaW1lYS05OjIwMTMxMDA5MDMwNTM5Ong4Nl82NC1hbGx5ZXNkZWJpYW46
My4xMS4wLTA5MTkzLWc2ZTU0M2Q1OjQyOAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4v
NmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9kbWVzZy1xdWFudGFs
LXdhaW1lYS0xMToyMDEzMTAwOTAzMDU0Mjp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0w
OTE5My1nNmU1NDNkNTo0MjgKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzZlNTQzZDU3
ODBlMzZmZjVlZTU2YzQ0ZDdlMmUzMGRiMzQ1N2E3ZWQvZG1lc2cteW9jdG8td2FpbWVhLTM6
MjAxMzEwMDkwMzA1NDI6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTMtZzZlNTQz
ZDU6NDI4Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi82ZTU0M2Q1NzgwZTM2ZmY1ZWU1
NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkL2RtZXNnLXF1YW50YWwtd2FpbWVhLTEzOjIwMTMxMDA5
MDMwNTQ1Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MTkzLWc2ZTU0M2Q1OjQyOAov
a2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vNmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2Uy
ZTMwZGIzNDU3YTdlZC9kbWVzZy15b2N0by1uaG00LTM6MjAxMzEwMDgxMTEzNTE6eDg2XzY0
LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTMtZzZlNTQzZDU6NDI4Ci9rZXJuZWwveDg2XzY0
LWFsbHllc2RlYmlhbi82ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2Vk
L2RtZXNnLXlvY3RvLXNuYi0zODoyMDEzMTAwODE5MDg1Mzp4ODZfNjQtYWxseWVzZGViaWFu
OjMuMTEuMC0wOTE5My1nNmU1NDNkNTo0MjgKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFu
LzZlNTQzZDU3ODBlMzZmZjVlZTU2YzQ0ZDdlMmUzMGRiMzQ1N2E3ZWQvZG1lc2ctbmZzcm9v
dC1yb2FtLTEyOjIwMTMxMDA4MTkwODU4Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5
MTkzLWc2ZTU0M2Q1OjQyOAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vNmU1NDNkNTc4
MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9kbWVzZy1uZnNyb290LXdhaW1lYS05
OjIwMTMxMDA5MDMwNTQ4Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5MTkzLWc2ZTU0
M2Q1OjQyOAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vNmU1NDNkNTc4MGUzNmZmNWVl
NTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9kbWVzZy1xdWFudGFsLXdhaW1lYS0xMToyMDEzMTAw
OTAzMDU1NDp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5My1nNmU1NDNkNTo0MjgK
L2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzZlNTQzZDU3ODBlMzZmZjVlZTU2YzQ0ZDdl
MmUzMGRiMzQ1N2E3ZWQvZG1lc2ctcXVhbnRhbC14cHMtMzoyMDEzMTAwOTAzMDUxNjp4ODZf
NjQtYWxseWVzZGViaWFuOjMuMTEuMC0wOTE5My1nNmU1NDNkNTo0MjgKL2tlcm5lbC94ODZf
NjQtYWxseWVzZGViaWFuLzZlNTQzZDU3ODBlMzZmZjVlZTU2YzQ0ZDdlMmUzMGRiMzQ1N2E3
ZWQvZG1lc2cteW9jdG8teHBzLTE6MjAxMzEwMDkwMzA1MTc6eDg2XzY0LWFsbHllc2RlYmlh
bjozLjExLjAtMDkxOTMtZzZlNTQzZDU6NDI4Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlh
bi82ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkL2RtZXNnLXF1YW50
YWwtYmVucy0zOjIwMTMxMDA4MTkwOTAyOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMS4wLTA5
MTkzLWc2ZTU0M2Q1OjQyOAova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vNmU1NDNkNTc4
MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9kbWVzZy1xdWFudGFsLWxrcC1zdDAx
LTE6MjAxMzEwMDgxOTA5MDE6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTMtZzZl
NTQzZDU6NDI4Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi82ZTU0M2Q1NzgwZTM2ZmY1
ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkL2RtZXNnLXF1YW50YWwtbGtwLXR0MDItMjQ6MjAx
MzEwMDgwOTQwMDI6eDg2XzY0LWFsbHllc2RlYmlhbjozLjExLjAtMDkxOTMtZzZlNTQzZDU6
NDI4CjA6MTQ6MTQgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bVJFUEVBVCBD
T1VOVDogMjAgICMgL2NjL3dmZy9tbS1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzog
MiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMSBzdGVwKQpb
NTZhZmU0NzdkZjNjYmJjZDY1NjY4MmQwMzU1ZWY3ZDllYjhiZGQ4MV0gbW06IG11bmxvY2s6
IGJ5cGFzcyBwZXItY3B1IHB2ZWMgZm9yIHB1dGJhY2tfbHJ1X3BhZ2UKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9v
YmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtYWxs
eWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo1NmFmZTQ3N2RmM2NiYmNkNjU2NjgyZDAzNTVlZjdk
OWViOGJkZDgxOmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xOTowOToyMCA1NmFmZTQ3N2RmM2Ni
YmNkNjU2NjgyZDAzNTVlZjdkOWViOGJkZDgxIGNvbXBpbGluZwo4OTcgcmVhbCAgNDkwMiB1
c2VyICA0MjYgc3lzICA1OTMuODklIGNwdSAJeDg2XzY0LWFsbHllc2RlYmlhbgoKMjAxMy0x
MC0wOC0xOToyNTozNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDkxOTAtZzU2YWZl
NDcuLi4uLi4uLi4uLi4uLi4uLi4uLgkzCTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMCByZXZp
c2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMSBzdGVwKQpbN2E4MDEw
Y2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOV0gbW06IG11bmxvY2s6IG1hbnVh
bCBwdGUgd2FsayBpbiBmYXN0IHBhdGggaW5zdGVhZCBvZiBmb2xsb3dfcGFnZV9tYXNrKCkK
cnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9o
b21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo3YTgwMTBjZDM2MjczZmY1ZjZm
ZWE1MjAxZWY5MjMyZjMwY2ViYmQ5OmJpc2VjdC1tbQoKMjAxMy0xMC0wOC0xOTozNjozNyA3
YTgwMTBjZDM2MjczZmY1ZjZmZWE1MjAxZWY5MjMyZjMwY2ViYmQ5IGNvbXBpbGluZwo5MTYg
cmVhbCAgNDMzNiB1c2VyICAzNjggc3lzICA1MTMuNDklIGNwdSAJeDg2XzY0LWFsbHllc2Rl
YmlhbgoKMjAxMy0xMC0wOC0xOTo1MjoyNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAt
MDkxOTItZzdhODAxMGMuLi4uLi4uLi4uLi4uLi4uLi4uLgkxNQkxOQkyMCBTVUNDRVNTCgo2
ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkIGlzIHRoZSBmaXJzdCBi
YWQgY29tbWl0CmNvbW1pdCA2ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdh
N2VkCkF1dGhvcjogTGlzYSBEdSA8Y2xkdUBtYXJ2ZWxsLmNvbT4KRGF0ZTogICBXZWQgU2Vw
IDExIDE0OjIyOjM2IDIwMTMgLTA3MDAKCiAgICBtbTogdm1zY2FuOiBmaXggZG9fdHJ5X3Rv
X2ZyZWVfcGFnZXMoKSBsaXZlbG9jawogICAgCiAgICBUaGlzIHBhdGNoIGlzIGJhc2VkIG9u
IEtPU0FLSSdzIHdvcmsgYW5kIEkgYWRkIGEgbGl0dGxlIG1vcmUgZGVzY3JpcHRpb24sCiAg
ICBwbGVhc2UgcmVmZXIgaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTIvNi8xNC83NC4KICAg
IAogICAgQ3VycmVudGx5LCBJIGZvdW5kIHN5c3RlbSBjYW4gZW50ZXIgYSBzdGF0ZSB0aGF0
IHRoZXJlIGFyZSBsb3RzIG9mIGZyZWUKICAgIHBhZ2VzIGluIGEgem9uZSBidXQgb25seSBv
cmRlci0wIGFuZCBvcmRlci0xIHBhZ2VzIHdoaWNoIG1lYW5zIHRoZSB6b25lIGlzCiAgICBo
ZWF2aWx5IGZyYWdtZW50ZWQsIHRoZW4gaGlnaCBvcmRlciBhbGxvY2F0aW9uIGNvdWxkIG1h
a2UgZGlyZWN0IHJlY2xhaW0KICAgIHBhdGgncyBsb25nIHN0YWxsKGV4LCA2MCBzZWNvbmRz
KSBlc3BlY2lhbGx5IGluIG5vIHN3YXAgYW5kIG5vIGNvbXBhY2l0b24KICAgIGVudmlyb21l
bnQuICBUaGlzIHByb2JsZW0gaGFwcGVuZWQgb24gdjMuNCwgYnV0IGl0IHNlZW1zIGlzc3Vl
IHN0aWxsIGxpdmVzCiAgICBpbiBjdXJyZW50IHRyZWUsIHRoZSByZWFzb24gaXMgZG9fdHJ5
X3RvX2ZyZWVfcGFnZXMgZW50ZXIgbGl2ZSBsb2NrOgogICAgCiAgICBrc3dhcGQgd2lsbCBn
byB0byBzbGVlcCBpZiB0aGUgem9uZXMgaGF2ZSBiZWVuIGZ1bGx5IHNjYW5uZWQgYW5kIGFy
ZSBzdGlsbAogICAgbm90IGJhbGFuY2VkLiAgQXMga3N3YXBkIHRoaW5rcyB0aGVyZSdzIGxp
dHRsZSBwb2ludCB0cnlpbmcgYWxsIG92ZXIgYWdhaW4KICAgIHRvIGF2b2lkIGluZmluaXRl
IGxvb3AuICBJbnN0ZWFkIGl0IGNoYW5nZXMgb3JkZXIgZnJvbSBoaWdoLW9yZGVyIHRvCiAg
ICAwLW9yZGVyIGJlY2F1c2Uga3N3YXBkIHRoaW5rIG9yZGVyLTAgaXMgdGhlIG1vc3QgaW1w
b3J0YW50LiAgTG9vayBhdAogICAgNzNjZTAyZTkgaW4gZGV0YWlsLiAgSWYgd2F0ZXJtYXJr
cyBhcmUgb2ssIGtzd2FwZCB3aWxsIGdvIGJhY2sgdG8gc2xlZXAKICAgIGFuZCBtYXkgbGVh
dmUgem9uZS0+YWxsX3VucmVjbGFpbWFibGUgPTNEIDAuICBJdCBhc3N1bWUgaGlnaC1vcmRl
ciB1c2VycwogICAgY2FuIHN0aWxsIHBlcmZvcm0gZGlyZWN0IHJlY2xhaW0gaWYgdGhleSB3
aXNoLgogICAgCiAgICBEaXJlY3QgcmVjbGFpbSBjb250aW51ZSB0byByZWNsYWltIGZvciBh
IGhpZ2ggb3JkZXIgd2hpY2ggaXMgbm90IGEKICAgIENPU1RMWV9PUkRFUiB3aXRob3V0IG9v
bS1raWxsZXIgdW50aWwga3N3YXBkIHR1cm4gb24KICAgIHpvbmUtPmFsbF91bnJlY2xhaW1i
bGU9IC4gIFRoaXMgaXMgYmVjYXVzZSB0byBhdm9pZCB0b28gZWFybHkgb29tLWtpbGwuCiAg
ICBTbyBpdCBtZWFucyBkaXJlY3RfcmVjbGFpbSBkZXBlbmRzIG9uIGtzd2FwZCB0byBicmVh
ayB0aGlzIGxvb3AuCiAgICAKICAgIEluIHdvcnN0IGNhc2UsIGRpcmVjdC1yZWNsYWltIG1h
eSBjb250aW51ZSB0byBwYWdlIHJlY2xhaW0gZm9yZXZlciB3aGVuCiAgICBrc3dhcGQgc2xl
ZXBzIGZvcmV2ZXIgdW50aWwgc29tZW9uZSBsaWtlIHdhdGNoZG9nIGRldGVjdCBhbmQgZmlu
YWxseSBraWxsCiAgICB0aGUgcHJvY2Vzcy4gIEFzIGRlc2NyaWJlZCBpbjoKICAgIGh0dHA6
Ly90aHJlYWQuZ21hbmUub3JnL2dtYW5lLmxpbnV4Lmtlcm5lbC5tbS8xMDM3MzcKICAgIAog
ICAgV2UgY2FuJ3QgdHVybiBvbiB6b25lLT5hbGxfdW5yZWNsYWltYWJsZSBmcm9tIGRpcmVj
dCByZWNsYWltIHBhdGggYmVjYXVzZQogICAgZGlyZWN0IHJlY2xhaW0gcGF0aCBkb24ndCB0
YWtlIGFueSBsb2NrIGFuZCB0aGlzIHdheSBpcyByYWN5LiAgVGh1cyB0aGlzCiAgICBwYXRj
aCByZW1vdmVzIHpvbmUtPmFsbF91bnJlY2xhaW1hYmxlIGZpZWxkIGNvbXBsZXRlbHkgYW5k
IHJlY2FsY3VsYXRlcwogICAgem9uZSByZWNsYWltYWJsZSBzdGF0ZSBldmVyeSB0aW1lLgog
ICAgCiAgICBOb3RlOiB3ZSBjYW4ndCB0YWtlIHRoZSBpZGVhIHRoYXQgZGlyZWN0LXJlY2xh
aW0gc2VlIHpvbmUtPnBhZ2VzX3NjYW5uZWQKICAgIGRpcmVjdGx5IGFuZCBrc3dhcGQgY29u
dGludWUgdG8gdXNlIHpvbmUtPmFsbF91bnJlY2xhaW1hYmxlLiAgQmVjYXVzZSwgaXQKICAg
IGlzIHJhY3kuICBjb21taXQgOTI5YmVhN2M3MSAodm1zY2FuOiBhbGxfdW5yZWNsYWltYWJs
ZSgpIHVzZQogICAgem9uZS0+YWxsX3VucmVjbGFpbWFibGUgYXMgYSBuYW1lKSBkZXNjcmli
ZXMgdGhlIGRldGFpbC4KICAgIAogICAgW2FrcG1AbGludXgtZm91bmRhdGlvbi5vcmc6IHVu
aW5saW5lIHpvbmVfcmVjbGFpbWFibGVfcGFnZXMoKSBhbmQgem9uZV9yZWNsYWltYWJsZSgp
XQogICAgQ2M6IEFhZGl0eWEgS3VtYXIgPGFhZGl0eWEua3VtYXIuMzBAZ21haWwuY29tPgog
ICAgQ2M6IFlpbmcgSGFuIDx5aW5naGFuQGdvb2dsZS5jb20+CiAgICBDYzogTmljayBQaWdn
aW4gPG5waWdnaW5AZ21haWwuY29tPgogICAgQWNrZWQtYnk6IFJpayB2YW4gUmllbCA8cmll
bEByZWRoYXQuY29tPgogICAgQ2M6IE1lbCBHb3JtYW4gPG1lbEBjc24udWwuaWU+CiAgICBD
YzogS0FNRVpBV0EgSGlyb3l1a2kgPGthbWV6YXdhLmhpcm95dUBqcC5mdWppdHN1LmNvbT4K
ICAgIENjOiBDaHJpc3RvcGggTGFtZXRlciA8Y2xAbGludXguY29tPgogICAgQ2M6IEJvYiBM
aXUgPGxsaXViYm9AZ21haWwuY29tPgogICAgQ2M6IE5laWwgWmhhbmcgPHpoYW5nd21AbWFy
dmVsbC5jb20+CiAgICBDYzogUnVzc2VsbCBLaW5nIC0gQVJNIExpbnV4IDxsaW51eEBhcm0u
bGludXgub3JnLnVrPgogICAgUmV2aWV3ZWQtYnk6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQHN1
c2UuY3o+CiAgICBBY2tlZC1ieTogTWluY2hhbiBLaW0gPG1pbmNoYW5Aa2VybmVsLm9yZz4K
ICAgIEFja2VkLWJ5OiBKb2hhbm5lcyBXZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4KICAg
IFNpZ25lZC1vZmYtYnk6IEtPU0FLSSBNb3RvaGlybyA8a29zYWtpLm1vdG9oaXJvQGpwLmZ1
aml0c3UuY29tPgogICAgU2lnbmVkLW9mZi1ieTogTGlzYSBEdSA8Y2xkdUBtYXJ2ZWxsLmNv
bT4KICAgIFNpZ25lZC1vZmYtYnk6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRh
dGlvbi5vcmc+CiAgICBTaWduZWQtb2ZmLWJ5OiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNA
bGludXgtZm91bmRhdGlvbi5vcmc+Cgo6MDQwMDAwIDA0MDAwMCA5ZDYwZDQ0ZmE0MTY4YmU0
ZWI3N2U4NjZkZDI3Y2Q2ZDZmMjU5ODc5IGFkOTA4NjQ0ODQwMWQ3NzkyZmUxYzAzMGVkNjBi
MzBiMzA2YmExNzYgTQlpbmNsdWRlCjowNDAwMDAgMDQwMDAwIDk1MTg2MmNhYjY4OWE2MmNk
OWI4ODBiZjE2OTI4MDEwNzBkNzM2ZjYgYjA1OWU5YmM3MTc5YTQwOWJhYzVlZTEwMTdlMzFl
MzQ5NGFiMmM2YyBNCW1tCmJpc2VjdCBydW4gc3VjY2VzcwpscyAtYSAva2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0veDg2XzY0LWFsbHllc2RlYmlhbi9saW51czptYXN0ZXI6N2E4MDEw
Y2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOTpiaXNlY3QtbW0KCjIwMTMtMTAt
MDgtMjA6MDM6NTkgN2E4MDEwY2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOSBy
ZXVzZSAva2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vN2E4MDEwY2QzNjI3M2ZmNWY2ZmVh
NTIwMWVmOTIzMmYzMGNlYmJkOS92bWxpbnV6LTMuMTEuMC0wOTE5Mi1nN2E4MDEwYwoKMjAx
My0xMC0wOC0yMDowMzo1OSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMQkyLi4uLi4uLi4u
Li4uLi4uCTEzCTM1CTUwCTU2Li4JNTcuCTU4Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLhtbMTszNW1hZGRfdG9fcnVuX3F1ZXVlIDIbWzBtCi4uLi4uLi4uLi4uLi4uLi4uLi4u
CTYwIFNVQ0NFU1MKCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQt
YWxseWVzZGViaWFuL2xpbnVzOm1hc3Rlcjo4YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYy
ZjZmZTFlODNlMDhiOmJpc2VjdC1tbQogVEVTVCBGQUlMVVJFClsgICAgMS4zNzIwODJdIHBj
aSAwMDAwOjAwOjAyLjA6IEJvb3QgdmlkZW8gZGV2aWNlClsgICAgMS4zNzMwMTZdIFBDSTog
Q0xTIDAgYnl0ZXMsIGRlZmF1bHQgNjQKWyAgICAxLjU3NjMzMV0gc3dhcHBlci8wIGludm9r
ZWQgb29tLWtpbGxlcjogZ2ZwX21hc2s9MHgyMDAwZDAsIG9yZGVyPTEsIG9vbV9zY29yZV9h
ZGo9MApbICAgIDEuNTc3ODA0XSBzd2FwcGVyLzAgY3B1c2V0PS8gbWVtc19hbGxvd2VkPTAK
WyAgICAxLjU3ODYxNF0gQ1BVOiAxIFBJRDogMSBDb21tOiBzd2FwcGVyLzAgTm90IHRhaW50
ZWQgMy4xMi4wLXJjNC0wMDAxOS1nOGI1ZWRlNiAjMTI2ClsgICAgMS41ODAwNDRdIEhhcmR3
YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgICAxLjU4
MTAzMl0gIDAwMDAwMDAwMDAwMDAwMDIgZmZmZjg4MDAxZGQ0MWIyOCBmZmZmZmZmZjgyYzhk
NzhmIGZmZmY4ODAwMWVmN2MwNDAKWyAgICAxLjU4MjczMV0gIGZmZmY4ODAwMWRkNDFiYTgg
ZmZmZmZmZmY4MmM4Mzk1ZiBmZmZmZmZmZjgzYzU0NjgwIGZmZmY4ODAwMWRkNDFiNjAKWyAg
ICAxLjU4NDQ1Nl0gIGZmZmZmZmZmODEwZjNmMDYgMDAwMDAwMDAwMDAwMTkwOCAwMDAwMDAw
MDAwMDAwMjQ2IGZmZmY4ODAwMWRkNDFiOTgKWyAgICAxLjU4NjE2Ml0gQ2FsbCBUcmFjZToK
WyAgICAxLjU4Njc0MF0gIFs8ZmZmZmZmZmY4MmM4ZDc4Zj5dIGR1bXBfc3RhY2srMHg1NC8w
eDc0ClsgICAgMS41ODc2NDZdICBbPGZmZmZmZmZmODJjODM5NWY+XSBkdW1wX2hlYWRlci5p
c3JhLjEwKzB4N2EvMHgxYmEKWyAgICAxLjU4ODY4OV0gIFs8ZmZmZmZmZmY4MTBmM2YwNj5d
ID8gbG9ja19yZWxlYXNlX2hvbGR0aW1lLnBhcnQuMjcrMHg0Yy8weDUwClsgICAgMS41ODk4
MjldICBbPGZmZmZmZmZmODEwZjc5NWE+XSA/IGxvY2tfcmVsZWFzZSsweDE4OS8weDFkMQpb
ICAgIDEuNTkwODA3XSAgWzxmZmZmZmZmZjgxMTUzMGE4Pl0gb3V0X29mX21lbW9yeSsweDM5
ZS8weDNlZQpbICAgIDEuNTkxNzc3XSAgWzxmZmZmZmZmZjgxMTU3OWY1Pl0gX19hbGxvY19w
YWdlc19ub2RlbWFzaysweDY2OC8weDdkZQpbICAgIDEuNTkyODczXSAgWzxmZmZmZmZmZjgx
MThlYjUzPl0ga21lbV9nZXRwYWdlcysweDc1LzB4MTZjClsgICAgMS41OTM4MDldICBbPGZm
ZmZmZmZmODExOTBkMjA+XSBmYWxsYmFja19hbGxvYysweDEyYy8weDFlYQpbICAgIDEuNTk0
Nzc4XSAgWzxmZmZmZmZmZjgxMGYzOGU4Pl0gPyB0cmFjZV9oYXJkaXJxc19vZmYrMHhkLzB4
ZgpbICAgIDEuNTk1NzgyXSAgWzxmZmZmZmZmZjgxMTkwYmU1Pl0gX19fX2NhY2hlX2FsbG9j
X25vZGUrMHgxNGEvMHgxNTkKWyAgICAxLjU5Njg0Ml0gIFs8ZmZmZmZmZmY4MTcwNTlmYj5d
ID8gZG1hX2RlYnVnX2luaXQrMHgxZWYvMHgyOWEKWyAgICAxLjU5NzgzMV0gIFs8ZmZmZmZm
ZmY4MTE5MTYyYz5dIGttZW1fY2FjaGVfYWxsb2NfdHJhY2UrMHg4My8weDExYQpbICAgIDEu
NTk4ODc4XSAgWzxmZmZmZmZmZjgxNzA1OWZiPl0gZG1hX2RlYnVnX2luaXQrMHgxZWYvMHgy
OWEKWyAgICAxLjU5OTgzN10gIFs8ZmZmZmZmZmY4NDFhYzM4Yj5dIHBjaV9pb21tdV9pbml0
KzB4MTYvMHg1MgpbICAgIDEuNjAwODE1XSAgWzxmZmZmZmZmZjg0MWFjMzc1Pl0gPyBpb21t
dV9zZXR1cCsweDI3ZC8weDI3ZApbICAgIDEuNjAxNzc4XSAgWzxmZmZmZmZmZjgxMDAyMGQy
Pl0gZG9fb25lX2luaXRjYWxsKzB4OTMvMHgxMzcKWyAgICAxLjYwMjc1MF0gIFs8ZmZmZmZm
ZmY4MTBiZDMwMD5dID8gcGFyYW1fc2V0X2NoYXJwKzB4OTIvMHhkOApbICAgIDEuNjAzNzI4
XSAgWzxmZmZmZmZmZjgxMGJkNTJlPl0gPyBwYXJzZV9hcmdzKzB4MTg5LzB4MjQ3ClsgICAg
MS42MDQ2OTldICBbPGZmZmZmZmZmODQxOWZlZDE+XSBrZXJuZWxfaW5pdF9mcmVlYWJsZSsw
eDE1ZS8weDFkZgpbICAgIDEuNjA1NzM4XSAgWzxmZmZmZmZmZjg0MTlmNzI5Pl0gPyBkb19l
YXJseV9wYXJhbSsweDg4LzB4ODgKWyAgICAxLjYwNjcwM10gIFs8ZmZmZmZmZmY4MmM3Nzg2
Nz5dID8gcmVzdF9pbml0KzB4ZGIvMHhkYgpbICAgIDEuNjA3NjE2XSAgWzxmZmZmZmZmZjgy
Yzc3ODc1Pl0ga2VybmVsX2luaXQrMHhlLzB4ZGIKWyAgICAxLjYwODU0MV0gIFs8ZmZmZmZm
ZmY4MmNiYzU3Yz5dIHJldF9mcm9tX2ZvcmsrMHg3Yy8weGIwClsgICAgMS42MDk0NzhdICBb
PGZmZmZmZmZmODJjNzc4Njc+XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAxLjYxMDM4
NV0gTWVtLUluZm86ClsgICAgMS42MTA5MThdIE5vZGUgMCBETUEgcGVyLWNwdToKL2tlcm5l
bC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZl
MWU4M2UwOGIvZG1lc2ctcXVhbnRhbC1jYWlyby0zMToyMDEzMTAwODE0MTYzOTp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2
XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNl
MDhiL2RtZXNnLW5mc3Jvb3QtbGtwLXR0MDItMjoyMDEzMTAwODA0NDczOTp4ODZfNjQtYWxs
eWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0
LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhi
L2RtZXNnLW5mc3Jvb3Qtc25iLTIyOjIwMTMxMDA4MTEwMDQyOng4Nl82NC1hbGx5ZXNkZWJp
YW46My4xMi4wLXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVz
ZGViaWFuLzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ct
bmZzcm9vdC1hdGhlbnMtMTQ6MjAxMzEwMDgxNDE2Mzk6eDg2XzY0LWFsbHllc2RlYmlhbjoz
LjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJp
YW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNy
b290LWxrcC10dDAyLTE0OjIwMTMxMDA4MDQ0NzQxOng4Nl82NC1hbGx5ZXNkZWJpYW46My4x
Mi4wLXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFu
LzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9v
dC1jYWlyby0xOToyMDEzMTAwODExMDA0Njp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1y
YzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84YjVl
ZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLW5mc3Jvb3Qtcm9h
bS0yMDoyMDEzMTAwODE0MTYzODp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzQtMDAw
MTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQy
NGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLW5mc3Jvb3Qtcm9hbS04OjIw
MTMxMDA4MTEwMDQzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAxOS1nOGI1
ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0ZGI5Mzlm
NTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9vdC1hdGhlbnMtNDoyMDEzMTAw
ODE0MTY0Mzp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6
MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3
ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLXF1YW50YWwtYXRoZW5zLTI6MjAxMzEwMDgxMTAw
NDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgov
a2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZm
MmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290LXJvYW0tMTU6MjAxMzEwMDgxMTAwNDc6eDg2
XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2VybmVs
L3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2ZmUx
ZTgzZTA4Yi9kbWVzZy15b2N0by1sa3AtdHQwMi0xODoyMDEzMTAwODAxMzE0Mzp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2
XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNl
MDhiL2RtZXNnLW5mc3Jvb3Qtcm9hbS0yNToyMDEzMTAwODExMDA1MDp4ODZfNjQtYWxseWVz
ZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFs
bHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2Rt
ZXNnLW5mc3Jvb3QtaW5uLTI4OjIwMTMxMDA4MTQxNjM5Ong4Nl82NC1hbGx5ZXNkZWJpYW46
My4xMi4wLXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGVi
aWFuLzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZz
cm9vdC1yb2FtLTIzOjIwMTMxMDA4MTQxNjM2Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4w
LXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhi
NWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9vdC14
aWFuLTExOjIwMTMxMDA4MTQxNjQyOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0w
MDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5
ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9vdC1hdGhlbnMt
MzA6MjAxMzEwMDgxMTAwNDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5
LWc4YjVlZGU2OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRk
YjkzOWY1MmI0N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy15b2N0by1zbmItMzE6MjAxMzEw
MDgxNDE2NDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2
OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0
N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290LXJvYW0tMjk6MjAxMzEwMDgxMTAw
NDY6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgow
OjE5OjE5IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpbZGV0YWNoZWQgSEVBRCA4ODBi
ZGM4XSBSZXZlcnQgIm1tOiB2bXNjYW46IGZpeCBkb190cnlfdG9fZnJlZV9wYWdlcygpIGxp
dmVsb2NrIgogOSBmaWxlcyBjaGFuZ2VkLCA0MiBpbnNlcnRpb25zKCspLCA0NCBkZWxldGlv
bnMoLSkKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vbGludXM6bWFzdGVyOjg4MGJkYzhlNTRhM2IxOTBhMGRhZGI2NmE1Zjg1ZTdjOTM1
ZWViMmI6YmlzZWN0LW1tCgoyMDEzLTEwLTA4LTIzOjAwOjAyIDg4MGJkYzhlNTRhM2IxOTBh
MGRhZGI2NmE1Zjg1ZTdjOTM1ZWViMmIgY29tcGlsaW5nCgoyMDEzLTEwLTA4LTIzOjI1OjQ1
IGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzQtMDAwMjAtZzg4MGJkYzguLi4uLi4u
Li4uLi4uLi4uLi4uLgkxMQk1Ngk2MCBTVUNDRVNTCgoKPT09PT09PT09IHVwc3RyZWFtID09
PT09PT09PQpGZXRjaGluZyBsaW51cwpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9r
dm0veDg2XzY0LWFsbHllc2RlYmlhbi9saW51czptYXN0ZXI6OGI1ZWRlNjlkMjRkYjkzOWY1
MmI0N2VmZmZmMmY2ZmUxZTgzZTA4YjpiaXNlY3QtbW0KIFRFU1QgRkFJTFVSRQpbICAgIDEu
MzcyMDgyXSBwY2kgMDAwMDowMDowMi4wOiBCb290IHZpZGVvIGRldmljZQpbICAgIDEuMzcz
MDE2XSBQQ0k6IENMUyAwIGJ5dGVzLCBkZWZhdWx0IDY0ClsgICAgMS41NzYzMzFdIHN3YXBw
ZXIvMCBpbnZva2VkIG9vbS1raWxsZXI6IGdmcF9tYXNrPTB4MjAwMGQwLCBvcmRlcj0xLCBv
b21fc2NvcmVfYWRqPTAKWyAgICAxLjU3NzgwNF0gc3dhcHBlci8wIGNwdXNldD0vIG1lbXNf
YWxsb3dlZD0wClsgICAgMS41Nzg2MTRdIENQVTogMSBQSUQ6IDEgQ29tbTogc3dhcHBlci8w
IE5vdCB0YWludGVkIDMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTYgIzEyNgpbICAgIDEuNTgw
MDQ0XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDEx
ClsgICAgMS41ODEwMzJdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMWRkNDFiMjggZmZm
ZmZmZmY4MmM4ZDc4ZiBmZmZmODgwMDFlZjdjMDQwClsgICAgMS41ODI3MzFdICBmZmZmODgw
MDFkZDQxYmE4IGZmZmZmZmZmODJjODM5NWYgZmZmZmZmZmY4M2M1NDY4MCBmZmZmODgwMDFk
ZDQxYjYwClsgICAgMS41ODQ0NTZdICBmZmZmZmZmZjgxMGYzZjA2IDAwMDAwMDAwMDAwMDE5
MDggMDAwMDAwMDAwMDAwMDI0NiBmZmZmODgwMDFkZDQxYjk4ClsgICAgMS41ODYxNjJdIENh
bGwgVHJhY2U6ClsgICAgMS41ODY3NDBdICBbPGZmZmZmZmZmODJjOGQ3OGY+XSBkdW1wX3N0
YWNrKzB4NTQvMHg3NApbICAgIDEuNTg3NjQ2XSAgWzxmZmZmZmZmZjgyYzgzOTVmPl0gZHVt
cF9oZWFkZXIuaXNyYS4xMCsweDdhLzB4MWJhClsgICAgMS41ODg2ODldICBbPGZmZmZmZmZm
ODEwZjNmMDY+XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0LjI3KzB4NGMvMHg1MApb
ICAgIDEuNTg5ODI5XSAgWzxmZmZmZmZmZjgxMGY3OTVhPl0gPyBsb2NrX3JlbGVhc2UrMHgx
ODkvMHgxZDEKWyAgICAxLjU5MDgwN10gIFs8ZmZmZmZmZmY4MTE1MzBhOD5dIG91dF9vZl9t
ZW1vcnkrMHgzOWUvMHgzZWUKWyAgICAxLjU5MTc3N10gIFs8ZmZmZmZmZmY4MTE1NzlmNT5d
IF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHg2NjgvMHg3ZGUKWyAgICAxLjU5Mjg3M10gIFs8
ZmZmZmZmZmY4MTE4ZWI1Mz5dIGttZW1fZ2V0cGFnZXMrMHg3NS8weDE2YwpbICAgIDEuNTkz
ODA5XSAgWzxmZmZmZmZmZjgxMTkwZDIwPl0gZmFsbGJhY2tfYWxsb2MrMHgxMmMvMHgxZWEK
WyAgICAxLjU5NDc3OF0gIFs8ZmZmZmZmZmY4MTBmMzhlOD5dID8gdHJhY2VfaGFyZGlycXNf
b2ZmKzB4ZC8weGYKWyAgICAxLjU5NTc4Ml0gIFs8ZmZmZmZmZmY4MTE5MGJlNT5dIF9fX19j
YWNoZV9hbGxvY19ub2RlKzB4MTRhLzB4MTU5ClsgICAgMS41OTY4NDJdICBbPGZmZmZmZmZm
ODE3MDU5ZmI+XSA/IGRtYV9kZWJ1Z19pbml0KzB4MWVmLzB4MjlhClsgICAgMS41OTc4MzFd
ICBbPGZmZmZmZmZmODExOTE2MmM+XSBrbWVtX2NhY2hlX2FsbG9jX3RyYWNlKzB4ODMvMHgx
MWEKWyAgICAxLjU5ODg3OF0gIFs8ZmZmZmZmZmY4MTcwNTlmYj5dIGRtYV9kZWJ1Z19pbml0
KzB4MWVmLzB4MjlhClsgICAgMS41OTk4MzddICBbPGZmZmZmZmZmODQxYWMzOGI+XSBwY2lf
aW9tbXVfaW5pdCsweDE2LzB4NTIKWyAgICAxLjYwMDgxNV0gIFs8ZmZmZmZmZmY4NDFhYzM3
NT5dID8gaW9tbXVfc2V0dXArMHgyN2QvMHgyN2QKWyAgICAxLjYwMTc3OF0gIFs8ZmZmZmZm
ZmY4MTAwMjBkMj5dIGRvX29uZV9pbml0Y2FsbCsweDkzLzB4MTM3ClsgICAgMS42MDI3NTBd
ICBbPGZmZmZmZmZmODEwYmQzMDA+XSA/IHBhcmFtX3NldF9jaGFycCsweDkyLzB4ZDgKWyAg
ICAxLjYwMzcyOF0gIFs8ZmZmZmZmZmY4MTBiZDUyZT5dID8gcGFyc2VfYXJncysweDE4OS8w
eDI0NwpbICAgIDEuNjA0Njk5XSAgWzxmZmZmZmZmZjg0MTlmZWQxPl0ga2VybmVsX2luaXRf
ZnJlZWFibGUrMHgxNWUvMHgxZGYKWyAgICAxLjYwNTczOF0gIFs8ZmZmZmZmZmY4NDE5Zjcy
OT5dID8gZG9fZWFybHlfcGFyYW0rMHg4OC8weDg4ClsgICAgMS42MDY3MDNdICBbPGZmZmZm
ZmZmODJjNzc4Njc+XSA/IHJlc3RfaW5pdCsweGRiLzB4ZGIKWyAgICAxLjYwNzYxNl0gIFs8
ZmZmZmZmZmY4MmM3Nzg3NT5dIGtlcm5lbF9pbml0KzB4ZS8weGRiClsgICAgMS42MDg1NDFd
ICBbPGZmZmZmZmZmODJjYmM1N2M+XSByZXRfZnJvbV9mb3JrKzB4N2MvMHhiMApbICAgIDEu
NjA5NDc4XSAgWzxmZmZmZmZmZjgyYzc3ODY3Pl0gPyByZXN0X2luaXQrMHhkYi8weGRiClsg
ICAgMS42MTAzODVdIE1lbS1JbmZvOgpbICAgIDEuNjEwOTE4XSBOb2RlIDAgRE1BIHBlci1j
cHU6Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3
ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLXF1YW50YWwtY2Fpcm8tMzE6MjAxMzEwMDgxNDE2
Mzk6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgov
a2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZm
MmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290LWxrcC10dDAyLTI6MjAxMzEwMDgwNDQ3Mzk6
eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2Vy
bmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2
ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290LXNuYi0yMjoyMDEzMTAwODExMDA0Mjp4ODZfNjQt
YWxseWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2
XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNl
MDhiL2RtZXNnLW5mc3Jvb3QtYXRoZW5zLTE0OjIwMTMxMDA4MTQxNjM5Ong4Nl82NC1hbGx5
ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQt
YWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIv
ZG1lc2ctbmZzcm9vdC1sa3AtdHQwMi0xNDoyMDEzMTAwODA0NDc0MTp4ODZfNjQtYWxseWVz
ZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFs
bHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2Rt
ZXNnLW5mc3Jvb3QtY2Fpcm8tMTk6MjAxMzEwMDgxMTAwNDY6eDg2XzY0LWFsbHllc2RlYmlh
bjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNk
ZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy1u
ZnNyb290LXJvYW0tMjA6MjAxMzEwMDgxNDE2Mzg6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEy
LjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4v
OGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290
LXJvYW0tODoyMDEzMTAwODExMDA0Mzp4ODZfNjQtYWxseWVzZGViaWFuOjMuMTIuMC1yYzQt
MDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi84YjVlZGU2
OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLW5mc3Jvb3QtYXRoZW5z
LTQ6MjAxMzEwMDgxNDE2NDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5
LWc4YjVlZGU2OjEyNgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRk
YjkzOWY1MmI0N2VmZmZmMmY2ZmUxZTgzZTA4Yi9kbWVzZy1xdWFudGFsLWF0aGVucy0yOjIw
MTMxMDA4MTEwMDQzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAxOS1nOGI1
ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0ZGI5Mzlm
NTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9vdC1yb2FtLTE1OjIwMTMxMDA4
MTEwMDQ3Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAxOS1nOGI1ZWRlNjox
MjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0ZGI5MzlmNTJiNDdl
ZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2cteW9jdG8tbGtwLXR0MDItMTg6MjAxMzEwMDgwMTMx
NDM6eDg2XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgov
a2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZm
MmY2ZmUxZTgzZTA4Yi9kbWVzZy1uZnNyb290LXJvYW0tMjU6MjAxMzEwMDgxMTAwNTA6eDg2
XzY0LWFsbHllc2RlYmlhbjozLjEyLjAtcmM0LTAwMDE5LWc4YjVlZGU2OjEyNgova2VybmVs
L3g4Nl82NC1hbGx5ZXNkZWJpYW4vOGI1ZWRlNjlkMjRkYjkzOWY1MmI0N2VmZmZmMmY2ZmUx
ZTgzZTA4Yi9kbWVzZy1uZnNyb290LWlubi0yODoyMDEzMTAwODE0MTYzOTp4ODZfNjQtYWxs
eWVzZGViaWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0
LWFsbHllc2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhi
L2RtZXNnLW5mc3Jvb3Qtcm9hbS0yMzoyMDEzMTAwODE0MTYzNjp4ODZfNjQtYWxseWVzZGVi
aWFuOjMuMTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHll
c2RlYmlhbi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNn
LW5mc3Jvb3QteGlhbi0xMToyMDEzMTAwODE0MTY0Mjp4ODZfNjQtYWxseWVzZGViaWFuOjMu
MTIuMC1yYzQtMDAwMTktZzhiNWVkZTY6MTI2Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlh
bi84YjVlZGU2OWQyNGRiOTM5ZjUyYjQ3ZWZmZmYyZjZmZTFlODNlMDhiL2RtZXNnLW5mc3Jv
b3QtYXRoZW5zLTMwOjIwMTMxMDA4MTEwMDQzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4w
LXJjNC0wMDAxOS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhi
NWVkZTY5ZDI0ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2cteW9jdG8tc25i
LTMxOjIwMTMxMDA4MTQxNjQzOng4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAx
OS1nOGI1ZWRlNjoxMjYKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuLzhiNWVkZTY5ZDI0
ZGI5MzlmNTJiNDdlZmZmZjJmNmZlMWU4M2UwOGIvZG1lc2ctbmZzcm9vdC1yb2FtLTI5OjIw
MTMxMDA4MTEwMDQ2Ong4Nl82NC1hbGx5ZXNkZWJpYW46My4xMi4wLXJjNC0wMDAxOS1nOGI1
ZWRlNjoxMjYKMDoxOToxOSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKCj09PT09PT09
PSBsaW51eC1uZXh0ID09PT09PT09PQpGZXRjaGluZyBuZXh0CmxzIC1hIC9rZXJuZWwtdGVz
dHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtYWxseWVzZGViaWFuL2xpbnVzOm1hc3RlcjphMGNm
MWFiYzI1YWMxOTdkZDk3Yjg1N2MwZjYzNDEwNjZhOGNiMWNmOmJpc2VjdC1tbQogVEVTVCBG
QUlMVVJFClsgICAgMi41MjM3MDZdIHBjaSAwMDAwOjAwOjAyLjA6IEJvb3QgdmlkZW8gZGV2
aWNlClsgICAgMi41MjYwNjldIFBDSTogQ0xTIDAgYnl0ZXMsIGRlZmF1bHQgNjQKWyAgICAy
Ljk5MDg5N10gc3dhcHBlci8wIGludm9rZWQgb29tLWtpbGxlcjogZ2ZwX21hc2s9MHgyMDAw
ZDAsIG9yZGVyPTEsIG9vbV9zY29yZV9hZGo9MApbICAgIDIuOTk2MTc2XSBzd2FwcGVyLzAg
Y3B1c2V0PS8gbWVtc19hbGxvd2VkPTAKWyAgICAyLjk5ODIzOV0gQ1BVOiAxIFBJRDogMSBD
b21tOiBzd2FwcGVyLzAgTm90IHRhaW50ZWQgMy4xMi4wLXJjMi1uZXh0LTIwMTMwOTI3LTAz
MTAwLWdhMGNmMWFiICM0ODIKWyAgICAzLjAwMjM4M10gSGFyZHdhcmUgbmFtZTogQm9jaHMg
Qm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgIDMuMDA0NzExXSAgMDAwMDAwMDAw
MDAwMDAwMiBmZmZmODgwMDFlZjdmYjI4IGZmZmZmZmZmODJjODgzNGYgZmZmZjg4MDAxZGQ0
MDA0MApbICAgIDMuMDA4ODQ3XSAgZmZmZjg4MDAxZWY3ZmJhOCBmZmZmZmZmZjgyYzdlYzMz
IGZmZmZmZmZmODNjNTQ5NDAgZmZmZjg4MDAxZWY3ZmI2MApbICAgIDMuMDEyODk4XSAgZmZm
ZmZmZmY4MTBmM2RhYSAwMDAwMDAwMDAwMDAzNWU0IDAwMDAwMDAwMDAwMDAyNDYgZmZmZjg4
MDAxZWY3ZmI5OApbICAgIDMuMDE3MTA1XSBDYWxsIFRyYWNlOgpbICAgIDMuMDE4NjAyXSAg
WzxmZmZmZmZmZjgyYzg4MzRmPl0gZHVtcF9zdGFjaysweDRkLzB4NjYKWyAgICAzLjAyMDc1
Ml0gIFs8ZmZmZmZmZmY4MmM3ZWMzMz5dIGR1bXBfaGVhZGVyLmlzcmEuMTArMHg3YS8weDFi
YQpbICAgIDMuMDIzMjk1XSAgWzxmZmZmZmZmZjgxMGYzZGFhPl0gPyBsb2NrX3JlbGVhc2Vf
aG9sZHRpbWUucGFydC4yNysweDcxLzB4N2QKWyAgICAzLjAyNjI3OF0gIFs8ZmZmZmZmZmY4
MTBmNzUyMj5dID8gbG9ja19yZWxlYXNlKzB4MThjLzB4MWQ3ClsgICAgMy4wMjk0NzJdICBb
PGZmZmZmZmZmODExNTIxYzA+XSBvdXRfb2ZfbWVtb3J5KzB4MzllLzB4M2VlClsgICAgMy4w
MzI0NDFdICBbPGZmZmZmZmZmODExNTZhYmQ+XSBfX2FsbG9jX3BhZ2VzX25vZGVtYXNrKzB4
NjU5LzB4N2Q1ClsgICAgMy4wMzU2OTddICBbPGZmZmZmZmZmODExOGQ5ODQ+XSBrbWVtX2dl
dHBhZ2VzKzB4NzUvMHgxNmMKWyAgICAzLjAzODI0NV0gIFs8ZmZmZmZmZmY4MTE4ZmI1ZD5d
IGZhbGxiYWNrX2FsbG9jKzB4MTJjLzB4MWVhClsgICAgMy4wNDEwMDhdICBbPGZmZmZmZmZm
ODEwZjM0MmY+XSA/IHRyYWNlX2hhcmRpcnFzX29mZisweGQvMHhmClsgICAgMy4wNDMyNjhd
ICBbPGZmZmZmZmZmODExOGZhMjI+XSBfX19fY2FjaGVfYWxsb2Nfbm9kZSsweDE0YS8weDE1
OQpbICAgIDMuMDQ2MTU2XSAgWzxmZmZmZmZmZjgxNmZmMTlmPl0gPyBkbWFfZGVidWdfaW5p
dCsweDFlZi8weDI5YQpbICAgIDMuMDQ4ODQyXSAgWzxmZmZmZmZmZjgxMTkwNDcyPl0ga21l
bV9jYWNoZV9hbGxvY190cmFjZSsweDgzLzB4MTFhClsgICAgMy4wNTIwODFdICBbPGZmZmZm
ZmZmODE2ZmYxOWY+XSBkbWFfZGVidWdfaW5pdCsweDFlZi8weDI5YQpbICAgIDMuMDU0Mjk1
XSAgWzxmZmZmZmZmZjg0MWFiMzIxPl0gcGNpX2lvbW11X2luaXQrMHgxNi8weDUyClsgICAg
My4wNTc1ODldICBbPGZmZmZmZmZmODQxYWIzMGI+XSA/IGlvbW11X3NldHVwKzB4MjdkLzB4
MjdkClsgICAgMy4wNjE3MDddICBbPGZmZmZmZmZmODEwMDIwZDI+XSBkb19vbmVfaW5pdGNh
bGwrMHg5My8weDEzOQpbICAgIDMuMDY1OTYxXSAgWzxmZmZmZmZmZjgxMGJkMDAwPl0gPyBw
YXJhbWVxbisweDIxLzB4M2IKWyAgICAzLjA2OTkzNl0gIFs8ZmZmZmZmZmY4MTBiZDFjNz5d
ID8gcGFyc2VfYXJncysweDE4OS8weDI0NwpbICAgIDMuMDczOTczXSAgWzxmZmZmZmZmZjg0
MTllZWNhPl0ga2VybmVsX2luaXRfZnJlZWFibGUrMHgxNWUvMHgxZTQKWyAgICAzLjA3Nzgw
NV0gIFs8ZmZmZmZmZmY4NDE5ZTcyOT5dID8gZG9fZWFybHlfcGFyYW0rMHg4OC8weDg4Clsg
ICAgMy4wODE4OTVdICBbPGZmZmZmZmZmODJjNzJiNjk+XSA/IHJlc3RfaW5pdCsweGNkLzB4
Y2QKWyAgICAzLjA4NTc2OV0gIFs8ZmZmZmZmZmY4MmM3MmI3Nz5dIGtlcm5lbF9pbml0KzB4
ZS8weGRiClsgICAgMy4wODkwMTJdICBbPGZmZmZmZmZmODJjYjY2N2M+XSByZXRfZnJvbV9m
b3JrKzB4N2MvMHhiMApbICAgIDMuMDkxNTI1XSAgWzxmZmZmZmZmZjgyYzcyYjY5Pl0gPyBy
ZXN0X2luaXQrMHhjZC8weGNkClsgICAgMy4wOTQwMzVdIE1lbS1JbmZvOgpbICAgIDMuMDk1
MjA4XSBOb2RlIDAgRE1BIHBlci1jcHU6Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9h
MGNmMWFiYzI1YWMxOTdkZDk3Yjg1N2MwZjYzNDEwNjZhOGNiMWNmL2RtZXNnLW5mc3Jvb3Qt
d2FpbWVhLTU6MjAxMzA5MjgxODMyMTI6My4xMi4wLXJjMi1uZXh0LTIwMTMwOTI3LTAzMTAw
LWdhMGNmMWFiOjQ4Mgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYTBjZjFhYmMyNWFj
MTk3ZGQ5N2I4NTdjMGY2MzQxMDY2YThjYjFjZi9kbWVzZy1xdWFudGFsLWFudC0yOjIwMTMw
OTI4MTAzNDE1OjMuMTIuMC1yYzItbmV4dC0yMDEzMDkyNy0wMzEwMC1nYTBjZjFhYjo0ODIK
L2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2EwY2YxYWJjMjVhYzE5N2RkOTdiODU3YzBm
NjM0MTA2NmE4Y2IxY2YvZG1lc2ctbmZzcm9vdC13YWltZWEtMzoyMDEzMDkyODE4MzM0Mzoz
LjEyLjAtcmMyLW5leHQtMjAxMzA5MjctMDMxMDAtZ2EwY2YxYWI6NDgyCi9rZXJuZWwveDg2
XzY0LWFsbHllc2RlYmlhbi9hMGNmMWFiYzI1YWMxOTdkZDk3Yjg1N2MwZjYzNDEwNjZhOGNi
MWNmL2RtZXNnLXlvY3RvLWxrcC10dDAyLTIxOjIwMTMwOTI4MDEwMzM2OjMuMTIuMC1yYzIt
bmV4dC0yMDEzMDkyNy0wMzEwMC1nYTBjZjFhYjo0ODIKL2tlcm5lbC94ODZfNjQtYWxseWVz
ZGViaWFuL2EwY2YxYWJjMjVhYzE5N2RkOTdiODU3YzBmNjM0MTA2NmE4Y2IxY2YvZG1lc2ct
cXVhbnRhbC13YWltZWEtMTI6MjAxMzA5MjgxODM4MTc6My4xMi4wLXJjMi1uZXh0LTIwMTMw
OTI3LTAzMTAwLWdhMGNmMWFiOjQ4Mgova2VybmVsL3g4Nl82NC1hbGx5ZXNkZWJpYW4vYTBj
ZjFhYmMyNWFjMTk3ZGQ5N2I4NTdjMGY2MzQxMDY2YThjYjFjZi9kbWVzZy1xdWFudGFsLXdh
aW1lYS03OjIwMTMwOTI4MTgzODExOjMuMTIuMC1yYzItbmV4dC0yMDEzMDkyNy0wMzEwMC1n
YTBjZjFhYjo0ODIKL2tlcm5lbC94ODZfNjQtYWxseWVzZGViaWFuL2EwY2YxYWJjMjVhYzE5
N2RkOTdiODU3YzBmNjM0MTA2NmE4Y2IxY2YvZG1lc2ctbmZzcm9vdC13YWltZWEtMzoyMDEz
MDkyODE4MzM1ODozLjEyLjAtcmMyLW5leHQtMjAxMzA5MjctMDMxMDAtZ2EwY2YxYWI6NDgy
Ci9rZXJuZWwveDg2XzY0LWFsbHllc2RlYmlhbi9hMGNmMWFiYzI1YWMxOTdkZDk3Yjg1N2Mw
ZjYzNDEwNjZhOGNiMWNmL2RtZXNnLXF1YW50YWwtbGtwLXR0MDItMjI6MjAxMzA5MjgwMTAz
NTQ6My4xMi4wLXJjMi1uZXh0LTIwMTMwOTI3LTAzMTAwLWdhMGNmMWFiOjQ4Mgova2VybmVs
L3g4Nl82NC1hbGx5ZXNkZWJpYW4vYTBjZjFhYmMyNWFjMTk3ZGQ5N2I4NTdjMGY2MzQxMDY2
YThjYjFjZi9kbWVzZy1xdWFudGFsLXdhaW1lYS0xMjoyMDEzMDkyODE4MzgwMDozLjEyLjAt
cmMyLW5leHQtMjAxMzA5MjctMDMxMDAtZ2EwY2YxYWI6NDgyCjA6OTo5IGFsbF9nb29kOmJh
ZDphbGxfYmFkIGJvb3RzCgo=

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.12.0-rc4-00019-g8b5ede6"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.12.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
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
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
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
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING is not set
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
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
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
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
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
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
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
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
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

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
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set
# CONFIG_BLK_CMDLINE_PARSER is not set

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
# CONFIG_AIX_PARTITION is not set
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
# CONFIG_CMDLINE_PARTITION is not set
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
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
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
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
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
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
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
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
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
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
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
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
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
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
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
# CONFIG_X86_INTEL_PSTATE is not set
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=y
# CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
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

#
# PCI host controller drivers
#
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
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
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
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
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
# CONFIG_IPV6_GRE is not set
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
CONFIG_NF_CONNTRACK_TIMESTAMP=y
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
CONFIG_NF_CONNTRACK_SNMP=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
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
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
# CONFIG_NETFILTER_XT_MATCH_BPF is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
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
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
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
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
# CONFIG_IP_NF_TARGET_SYNPROXY is not set
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_NF_NAT_IPV4 is not set
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
# CONFIG_IP6_NF_TARGET_SYNPROXY is not set
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_SECURITY=y
# CONFIG_NF_NAT_IPV6 is not set

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
# DCCP CCIDs Configuration
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
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
CONFIG_RDS=y
CONFIG_RDS_RDMA=y
CONFIG_RDS_TCP=y
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_TIPC_MEDIA_IB is not set
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
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
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
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_6LOWPAN=y
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
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
# CONFIG_NET_SCH_FQ is not set
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
# CONFIG_NET_EMATCH_IPSET is not set
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
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_NET_FLOW_LIMIT=y

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
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_MCP251X=y
CONFIG_PCH_CAN=y
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCMCIA=y
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
CONFIG_CAN_PEAK_PCI=y
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
CONFIG_CAN_ESD_USB2=y
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_8DEV_USB is not set
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y
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
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
CONFIG_KS959_DONGLE=y

#
# FIR device drivers
#
CONFIG_USB_IRDA=y
CONFIG_SIGMATEL_FIR=y
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_MCS_FIR=y
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_CMTP=y
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=y
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_BT_ATH3K=y
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
CONFIG_NFC=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_SPI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
# CONFIG_NFC_SIM is not set
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
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
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
CONFIG_MTD_SWAP=y

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
CONFIG_MTD_SC520CDP=y
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
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_DENALI is not set
# CONFIG_MTD_NAND_GPIO is not set
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

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
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
CONFIG_XEN_BLKDEV_BACKEND=y
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
# CONFIG_ATMEL_SSC is not set
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
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
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set
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
CONFIG_SCSI_CXGB4_ISCSI=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
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
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
# CONFIG_SCSI_ESAS2R is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_SCSI_FLASHPOINT is not set
CONFIG_VMWARE_PVSCSI=y
CONFIG_HYPERV_STORAGE=y
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
CONFIG_SCSI_ISCI=y
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
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
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
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
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
# CONFIG_SATA_HIGHBANK is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
# CONFIG_SATA_RCAR is not set
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
CONFIG_PATA_ARASAN_CF=y
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
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_THIN_PROVISIONING=y
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
# CONFIG_DM_CACHE is not set
CONFIG_DM_MIRROR=y
CONFIG_DM_RAID=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
# CONFIG_SBP_TARGET is not set
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
CONFIG_FIREWIRE_NOSY=y
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
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
# CONFIG_VXLAN is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
CONFIG_SUNGEM_PHY=y
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
CONFIG_ARCNET_COM20020_CS=y
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
CONFIG_ATM_NICSTAR=y
CONFIG_ATM_NICSTAR_USE_SUNI=y
CONFIG_ATM_NICSTAR_USE_IDT77105=y
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
CONFIG_VHOST_NET=y
# CONFIG_VHOST_SCSI is not set
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_PCMCIA_3C574=y
CONFIG_PCMCIA_3C589=y
CONFIG_VORTEX=y
CONFIG_TYPHOON=y
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=y
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
CONFIG_PCMCIA_NMCLAN=y
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_BNX2X_SRIOV=y
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=y
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=y
CONFIG_TULIP_NAPI_HW_MITIGATION=y
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
CONFIG_PCMCIA_XIRCOM=y
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
CONFIG_SUNDANCE=y
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
CONFIG_PCMCIA_FMVJ18X=y
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
CONFIG_KS8851=y
CONFIG_KS8851_MLL=y
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
# CONFIG_ENC28J60_WRITEVERIFY is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
CONFIG_FEALNX=y
CONFIG_NET_VENDOR_NATSEMI=y
CONFIG_NATSEMI=y
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
CONFIG_PCMCIA_AXNET=y
CONFIG_NE2K_PCI=y
CONFIG_PCMCIA_PCNET=y
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_ATP=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
# CONFIG_SH_ETH is not set
CONFIG_NET_VENDOR_RDC=y
CONFIG_R6040=y
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
CONFIG_SC92031=y
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
CONFIG_PCMCIA_SMC91C92=y
CONFIG_EPIC100=y
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
CONFIG_CASSINI=y
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=y
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
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
# CONFIG_AT803X_PHY is not set
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
CONFIG_PPTP=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_HSO=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=y
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PCMCIA_ATMEL=y
CONFIG_AT76C50X_USB=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=y
CONFIG_USB_NET_RNDIS_WLAN=y
CONFIG_RTL8180=y
CONFIG_RTL8187=y
CONFIG_RTL8187_LEDS=y
CONFIG_ADM8211=y
CONFIG_MAC80211_HWSIM=y
CONFIG_MWL8K=y
# CONFIG_ATH_CARDS is not set
CONFIG_B43=y
CONFIG_B43_BCMA=y
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_BCMA_PIO=y
CONFIG_B43_PIO=y
CONFIG_B43_PHY_N=y
CONFIG_B43_PHY_LP=y
CONFIG_B43_PHY_HT=y
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
CONFIG_BRCMUTIL=y
CONFIG_BRCMSMAC=y
# CONFIG_BRCMFMAC is not set
# CONFIG_BRCM_TRACING is not set
# CONFIG_BRCMDBG is not set
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
# CONFIG_IWLMVM is not set

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_IWLEGACY=y
CONFIG_IWL4965=y
CONFIG_IWL3945=y

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
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
CONFIG_ORINOCO_USB=y
CONFIG_P54_COMMON=y
CONFIG_P54_USB=y
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
CONFIG_RT2500USB=y
CONFIG_RT73USB=y
CONFIG_RT2800USB=y
CONFIG_RT2800USB_RT33XX=y
CONFIG_RT2800USB_RT35XX=y
# CONFIG_RT2800USB_RT3573 is not set
CONFIG_RT2800USB_RT53XX=y
# CONFIG_RT2800USB_RT55XX is not set
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_MMIO=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
CONFIG_RTL_CARDS=y
CONFIG_RTL8192CE=y
CONFIG_RTL8192SE=y
CONFIG_RTL8192DE=y
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8188EE is not set
CONFIG_RTL8192CU=y
CONFIG_RTLWIFI=y
CONFIG_RTLWIFI_PCI=y
CONFIG_RTLWIFI_USB=y
CONFIG_RTLWIFI_DEBUG=y
CONFIG_RTL8192C_COMMON=y
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
# CONFIG_ZD1211RW_DEBUG is not set
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
CONFIG_MWIFIEX_PCIE=y
# CONFIG_MWIFIEX_USB is not set
# CONFIG_CW1200 is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
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
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_XEN_NETDEV_FRONTEND=y
CONFIG_XEN_NETDEV_BACKEND=y
CONFIG_VMXNET3=y
CONFIG_HYPERV_NET=y
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
CONFIG_GIGASET_BASE=y
CONFIG_GIGASET_M105=y
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
CONFIG_MISDN_HFCUSB=y
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
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_CYAPA is not set
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
CONFIG_JOYSTICK_IFORCE_USB=y
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
CONFIG_JOYSTICK_XPAD=y
CONFIG_JOYSTICK_XPAD_FF=y
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_WACOM=y
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
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
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
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_ELO=y
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
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
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

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
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
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

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_PCH_UART=y
# CONFIG_SERIAL_PCH_UART_CONSOLE is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
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
CONFIG_HW_RANDOM_TPM=y
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
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
# CONFIG_TCG_ST33_I2C is not set
# CONFIG_TCG_XEN is not set
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
# CONFIG_I2C_ISMT is not set
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
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y

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
# CONFIG_SPI_FSL_DSPI is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
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
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

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
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
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
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#

#
# USB GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
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
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
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
# CONFIG_SENSORS_ADT7310 is not set
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_HTU21 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
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
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
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
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=m

#
# Texas Instruments thermal drivers
#
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
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
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
CONFIG_NV_TCO=y
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
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
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
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_BLOCKIO=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_TPS51632 is not set
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
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_CYPRESS_FIRMWARE is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#

#
# Customise DVB Frontends
#
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

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

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_UMS is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
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
CONFIG_FB_VIA_X_COMPATIBILITY=y
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
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=y
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_HYPERV is not set
# CONFIG_FB_SIMPLE is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3630 is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
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
CONFIG_SND_MAX_CARDS=32
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
CONFIG_SND_ALOOP=y
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
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
# CONFIG_SND_HDA_CODEC_CA0132_DSP is not set
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
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
CONFIG_SND_LOLA=y
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
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_USB_UA101=y
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=y
CONFIG_SND_USB_6FIRE=y
# CONFIG_SND_USB_HIFACE is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
CONFIG_SND_FIREWIRE_SPEAKERS=y
CONFIG_SND_ISIGHT=y
# CONFIG_SND_SCS1X is not set
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
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_HYPERV_MOUSE is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_WHCI_HCD=y
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=y
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
CONFIG_USB_STORAGE_ENE_UB6250=y

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=y
CONFIG_USB_SERIAL_ARK3116=y
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
# CONFIG_USB_SERIAL_F81232 is not set
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_NAVMAN=y
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
CONFIG_USB_SERIAL_TI=y
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_WISHBONE is not set
# CONFIG_USB_SERIAL_ZTE is not set
CONFIG_USB_SERIAL_SSU100=y
# CONFIG_USB_SERIAL_QT2 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
CONFIG_USB_CXACRU=y
CONFIG_USB_UEAGLEATM=y
CONFIG_USB_XUSBATM=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_AM335X_PHY_USB is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=y
# CONFIG_USB_DUMMY_HCD is not set
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
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
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_DELL_NETBOOKS=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
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
CONFIG_INFINIBAND_QIB_DCA=y
CONFIG_INFINIBAND_AMSO1100=y
# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=y
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
# CONFIG_MLX5_INFINIBAND is not set
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=y
# CONFIG_INFINIBAND_SRPT is not set
CONFIG_INFINIBAND_ISER=y
# CONFIG_INFINIBAND_ISERT is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
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
CONFIG_EDAC_I7300=y
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_SYSTOHC=y
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
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
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
# CONFIG_RTC_DRV_RX4581 is not set

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
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_DW_DMAC_CORE is not set
# CONFIG_DW_DMAC is not set
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
CONFIG_PCH_DMA=y
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

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
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_UIO_MF624 is not set
# CONFIG_VFIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_UTILS=y
# CONFIG_HYPERV_BALLOON is not set

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
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_STAGING=y
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_HOST=y
# CONFIG_USBIP_DEBUG is not set
# CONFIG_W35UND is not set
CONFIG_PRISM2_USB=y
# CONFIG_ECHO is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_PCMCIA_DRIVERS is not set
# CONFIG_COMEDI_USB_DRIVERS is not set
CONFIG_COMEDI_8255=m
# CONFIG_PANEL is not set
CONFIG_R8187SE=m
CONFIG_RTL8192U=m
# CONFIG_RTLLIB is not set
CONFIG_R8712U=y
# CONFIG_R8188EU is not set
# CONFIG_RTS5139 is not set
# CONFIG_TRANZPORT is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_VT6655 is not set
CONFIG_VT6656=m
# CONFIG_DX_SEP is not set
CONFIG_ZSMALLOC=y
CONFIG_ZRAM=y
# CONFIG_ZRAM_DEBUG is not set
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_SBE_2T3E3 is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
CONFIG_SPEAKUP_SYNTH_ACNTSA=y
CONFIG_SPEAKUP_SYNTH_ACNTPC=y
CONFIG_SPEAKUP_SYNTH_APOLLO=y
CONFIG_SPEAKUP_SYNTH_AUDPTR=y
CONFIG_SPEAKUP_SYNTH_BNS=y
CONFIG_SPEAKUP_SYNTH_DECTLK=y
CONFIG_SPEAKUP_SYNTH_DECEXT=y
# CONFIG_SPEAKUP_SYNTH_DECPC is not set
CONFIG_SPEAKUP_SYNTH_DTLK=y
CONFIG_SPEAKUP_SYNTH_KEYPC=y
CONFIG_SPEAKUP_SYNTH_LTLK=y
CONFIG_SPEAKUP_SYNTH_SOFT=y
CONFIG_SPEAKUP_SYNTH_SPKOUT=y
CONFIG_SPEAKUP_SYNTH_TXPRT=y
CONFIG_SPEAKUP_SYNTH_DUMMY=y
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_STAGING_MEDIA=y

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_LTE_GDM724X is not set
# CONFIG_NET_VENDOR_SILICOM is not set
# CONFIG_CED1401 is not set
# CONFIG_DGRP is not set
# CONFIG_FIREWIRE_SERIAL is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_LUSTRE_FS is not set
# CONFIG_USB_BTMTK is not set
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_AIO=y
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=y
CONFIG_HP_ACCEL=y
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=y
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
CONFIG_ASUS_WMI=y
CONFIG_ASUS_NB_WMI=y
CONFIG_EEEPC_WMI=y
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_IPS=y
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
# CONFIG_AMD_IOMMU_V2 is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_VARS_PSTORE=y
# CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE is not set

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
# CONFIG_XFS_WARN is not set
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
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
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
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
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
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
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
# CONFIG_F2FS_FS is not set
# CONFIG_EFIVAR_FS is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
# CONFIG_NFS_V4_2 is not set
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
# CONFIG_NFSD_V4_SECURITY_LABEL is not set
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
# CONFIG_CEPH_FSCACHE is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB2 is not set
CONFIG_CIFS_FSCACHE=y
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
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
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

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
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
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=300
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
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
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
CONFIG_DOUBLEFAULT=y
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
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

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
# CONFIG_INTEL_TXT is not set
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
CONFIG_SECURITY_APPARMOR_HASH=y
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
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
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

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
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
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
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_KVM_DEVICE_ASSIGNMENT=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
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
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
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
CONFIG_DECOMPRESS_LZ4=y
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
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y

--8t9RHnE3ZwKMSgU+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
