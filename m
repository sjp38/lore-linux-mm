Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 596BF6B0055
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 20:40:59 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so379730pbc.9
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 17:40:59 -0700 (PDT)
Date: Thu, 26 Sep 2013 08:40:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [munlock] BUG: Bad page map in process killall5 pte:cf17e720
 pmd:05a22067
Message-ID: <20130926004028.GB9394@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+QahgC5+KEYLbs62"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Vlastimil,

FYI, this bug seems still not fixed in linux-next 20130925.

commit 7a8010cd36273ff5f6fea5201ef9232f30cebbd9
Author: Vlastimil Babka <vbabka@suse.cz>
Date:   Wed Sep 11 14:22:35 2013 -0700

    mm: munlock: manual pte walk in fast path instead of follow_page_mask()
    
    Currently munlock_vma_pages_range() calls follow_page_mask() to obtain
    each individual struct page.  This entails repeated full page table
    translations and page table lock taken for each page separately.
    
    This patch avoids the costly follow_page_mask() where possible, by
    iterating over ptes within single pmd under single page table lock.  The
    first pte is obtained by get_locked_pte() for non-THP page acquired by the
    initial follow_page_mask().  The rest of the on-stack pagevec for munlock
    is filled up using pte_walk as long as pte_present() and vm_normal_page()
    are sufficient to obtain the struct page.
    
    After this patch, a 14% speedup was measured for munlocking a 56GB large
    memory area with THP disabled.
    
    Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
    Cc: JA?rn Engel <joern@logfs.org>
    Cc: Mel Gorman <mgorman@suse.de>
    Cc: Michel Lespinasse <walken@google.com>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Michal Hocko <mhocko@suse.cz>
    Cc: Vlastimil Babka <vbabka@suse.cz>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>


[   89.835504] init: plymouth-upstart-bridge main process (3556) terminated with status 1
[   89.986606] init: tty6 main process (3529) killed by TERM signal
[   91.414086] BUG: Bad page map in process killall5  pte:cf17e720 pmd:05a22067
[   91.416626] addr:bfc00000 vm_flags:00100173 anon_vma:cf128c80 mapping:  (null) index:bfff0
[   91.419402] CPU: 0 PID: 3574 Comm: killall5 Not tainted 3.12.0-rc1-00010-g5fbc0a6 #24
[   91.422171] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   91.423998]  00000000 00000000 c0199e34 c1db5db4 00000000 c0199e54 c10e72d4 000bfff0
[   91.427933]  00000000 bfc00000 00000000 000cf17e cf17e720 c0199e74 c10e7995 00000000
[   91.431940]  bfc00000 cf1ca190 bfc00000 cf180000 cf1ca190 c0199ee0 c10eb8cf ce6d1900
[   91.435894] Call Trace:
[   91.436969]  [<c1db5db4>] dump_stack+0x4b/0x66
[   91.438503]  [<c10e72d4>] print_bad_pte+0x14b/0x162
[   91.440204]  [<c10e7995>] vm_normal_page+0x67/0x9b
[   91.441811]  [<c10eb8cf>] munlock_vma_pages_range+0xf9/0x176
[   91.443633]  [<c10ede09>] exit_mmap+0x86/0xf7
[   91.445156]  [<c10885b8>] ? lock_release+0x169/0x1ef
[   91.446795]  [<c113e5b6>] ? rcu_read_unlock+0x17/0x23
[   91.448465]  [<c113effe>] ? exit_aio+0x2b/0x6c
[   91.449990]  [<c103d4b0>] mmput+0x6a/0xcb
[   91.451508]  [<c104141a>] do_exit+0x362/0x8be
[   91.453013]  [<c105d280>] ? hrtimer_debug_hint+0xd/0xd
[   91.454700]  [<c10419f8>] do_group_exit+0x51/0x9e
[   91.456296]  [<c1041a5b>] SyS_exit_group+0x16/0x16
[   91.457901]  [<c1dc6719>] sysenter_do_call+0x12/0x33
[   91.459553] Disabling lock debugging due to kernel taint

git bisect start 272b98c6455f00884f0350f775c5342358ebb73f v3.11 --
git bisect good 57d730924d5cc2c3e280af16a9306587c3a511db  # 02:21    495+  Merge branch 'timers-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 3bb22ec53e2bd12a241ed84359bffd591a40ab87  # 12:03    495+  staging/lustre/ptlrpc: convert to new shrinker API
git bisect  bad a5b7c87f92076352dbff2fe0423ec255e1c9a71b  # 12:18     31-  vmscan, memcg: do softlimit reclaim also for targeted reclaim
git bisect good 3d94ea51c1d8db6f41268a9d2aea5f5771e9a8d3  # 15:40    495+  ocfs2: clean up dead code in ocfs2_acl_from_xattr()
git bisect  bad d62a201f24cba74e2fbf9f6f7af86ff5f5e276fc  # 16:46     79-  checkpatch: enforce sane perl version
git bisect good 83467efbdb7948146581a56cbd683a22a0684bbb  # 01:29    585+  mm: migrate: check movability of hugepage in unmap_and_move_huge_page()
git bisect  bad 2bff24a3707093c435ab3241c47dcdb5f16e432b  # 02:07    148-  memcg: fix multiple large threshold notifications
git bisect  bad 1ecfd533f4c528b0b4cc5bc115c4c47f0b5e4828  # 02:34     64-  mm/mremap.c: call pud_free() after fail calling pmd_alloc()
git bisect good 0ec3b74c7f5599c8a4d2b33d430a5470af26ebf6  # 13:10   1170+  mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 16:52   1170+  mm: munlock: remove redundant get_page/put_page pair on the fast path
git bisect  bad 187320932dcece9c4b93f38f56d1f888bd5c325f  # 17:11      0-  mm/sparse: introduce alloc_usemap_and_memmap
git bisect  bad 6e543d5780e36ff5ee56c44d7e2e30db3457a7ed  # 17:29      2-  mm: vmscan: fix do_try_to_free_pages() livelock
git bisect  bad 7a8010cd36273ff5f6fea5201ef9232f30cebbd9  # 17:59     14-  mm: munlock: manual pte walk in fast path instead of follow_page_mask()
git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 22:10   3510+  mm: munlock: remove redundant get_page/put_page pair on the fast path
git bisect  bad 5fbc0a6263a147cde905affbfb6622c26684344f  # 22:10      0-  Merge remote-tracking branch 'pinctrl/for-next' into kbuild_tmp
git bisect good 87e37036dcf96eb73a8627524be8b722bd1ac526  # 04:31   3510+  Revert "mm: munlock: manual pte walk in fast path instead of follow_page_mask()"
git bisect  bad 22356f447ceb8d97a4885792e7d9e4607f712e1b  # 04:40     48-  mm: Place preemption point in do_mlockall() loop
git bisect  bad 050f4da86e9bdbcc9e11789e0f291aafa57b8a20  # 04:55    133-  Add linux-next specific files for 20130925

Thanks,
Fengguang

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-lkp-tt02-11:20130923084547:3.12.0-rc1-00010-g5fbc0a6:24"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.12.0-rc1-00010-g5fbc0a6 (kbuild@roam) (gcc v=
ersion 4.8.1 (Debian 4.8.1-8) ) #24 SMP Mon Sep 23 18:20:41 CST 2013
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
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
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[c00fdae0]
[    0.000000]   mpc: fdaf0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x033fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e000000-0x0e3fffff]
[    0.000000]  [mem 0x0e000000-0x0e3fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0dffffff]
[    0.000000]  [mem 0x08000000-0x0dffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x07ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0e400000-0x0fffdfff]
[    0.000000]  [mem 0x0e400000-0x0fbfffff] page 2M
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x02f54000, 0x02f54fff] PGTABLE
[    0.000000] cma: dma_contiguous_reserve(limit 00000000)
[    0.000000] cma: dma_contiguous_reserve: reserving 16 MiB for global area
[    0.000000] cma: dma_contiguous_reserve_area(size 1000000, base 00000000=
, limit 00000000)
[    0.000000] cma: CMA: reserved 16 MiB at 0d400000
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127604(97%)
[    0.000000] RAMDISK: [mem 0x0e73f000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd950 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 00034 (v01 BOCHS  BXPCRSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACP 0fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC=
 00000001)
[    0.000000] ACPI: DSDT 0fffe490 011A9 (v01   BXPC   BXDSDT 00000001 INTL=
 20100528)
[    0.000000] ACPI: FACS 0fffff40 00040
[    0.000000] ACPI: SSDT 0ffff7a0 00796 (v01 BOCHS  BXPCSSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: APIC 0ffff680 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC=
 00000001)
[    0.000000] ACPI: HPET 0ffff640 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC=
 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x0fffdfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c269b580, node_mem_map ce=
53f020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 480 pages used for memmap
[    0.000000]   Normal zone: 61438 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 332 pages/cpu @cc968000 s1344128 r0 d15744 =
u1359872
[    0.000000] pcpu-alloc: s1344128 r0 d15744 u1359872 alloc=3D332*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr c96a840
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64924
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3D=
debug dynamic_printk sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 co=
nsole=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kernel-tests/run-queue/kvm/i386-randconfig-r0-0923/devel-roam-i386-2013=
09231807/.vmlinuz-5fbc0a6263a147cde905affbfb6622c26684344f-20130923182124-4=
-lkp-tt02 branch=3Dlinux-devel/devel-roam-i386-201309231807 BOOT_IMAGE=3D/k=
ernel/i386-randconfig-r0-0923/5fbc0a6263a147cde905affbfb6622c26684344f/vmli=
nuz-3.12.0-rc1-00010-g5fbc0a6
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 174780K/261744K available (14108K kernel code, 2012K=
 rwdata, 7780K rodata, 2044K init, 6044K bss, 86964K reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd35000 - 0xfffff000   (2856 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xffd33000   ( 757 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc275a000 - 0xc2959000   (2044 kB)
[    0.000000]       .data : 0xc1dc7717 - 0xc2759240   (9798 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1dc7717   (14109 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:56 16
[    0.000000] CPU 0 irqstacks, hard=3Dcc40c000 soft=3Dcc40e000
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
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ODEBUG: 12 of 12 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2393.914 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value.. 4787.82 Bogo=
MIPS (lpj=3D23939140)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] Mount-cache hash table entries: 512
[    0.020871] Initializing cgroup subsys debug
[    0.022393] Initializing cgroup subsys devices
[    0.023951] Initializing cgroup subsys perf_event
[    0.025548] Initializing cgroup subsys hugetlb
[    0.027284] mce: CPU supports 10 MCE banks
[    0.028856] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.028856] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.028856] tlb_flushall_shift: 6
[    0.031872] Freeing SMP alternatives memory: 24K (c2959000 - c295f000)
[    0.036005] ACPI: Core revision 20130725
[    0.047022] ACPI: All ACPI Tables successfully acquired
[    0.050470] Getting VERSION: 50014
[    0.051820] Getting VERSION: 50014
[    0.053158] Getting ID: 0
[    0.054305] Getting ID: f000000
[    0.055611] Getting LVT0: 8700
[    0.056859] Getting LVT1: 8400
[    0.058115] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.060138] enabled ExtINT on CPU#0
[    0.063173] ENABLING IO-APIC IRQs
[    0.064483] init IO_APIC IRQs
[    0.065698]  apic 0 pin 0 not connected
[    0.067178] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.070044] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.072888] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.075735] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.078562] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.080037] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.082845] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.085651] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.090037] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.092837] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.095713] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.098575] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.100052] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.102916] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.105774] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.110033]  apic 0 pin 16 not connected
[    0.111505]  apic 0 pin 17 not connected
[    0.112941]  apic 0 pin 18 not connected
[    0.114398]  apic 0 pin 19 not connected
[    0.115839]  apic 0 pin 20 not connected
[    0.117310]  apic 0 pin 21 not connected
[    0.118756]  apic 0 pin 22 not connected
[    0.120006]  apic 0 pin 23 not connected
[    0.121627] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.123889] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.127767] Using local APIC timer interrupts.
[    0.127767] calibrating APIC timer ...
[    0.140000] ... lapic delta =3D 6248099
[    0.140000] ... PM-Timer delta =3D 357727
[    0.140000] ... PM-Timer result ok
[    0.140000] ..... delta 6248099
[    0.140000] ..... mult: 268353808
[    0.140000] ..... calibration result: 9996958
[    0.140000] ..... CPU clock speed is 2391.8369 MHz.
[    0.140000] ..... host bus clock speed is 999.6958 MHz.
[    0.140139] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.145214] ftrace: Allocated trace_printk buffers
[    0.153214] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.157150] SMP alternatives: lockdep: fixing up alternatives
[    0.159162] CPU 1 irqstacks, hard=3Dcc7b2000 soft=3Dcc7b4000
[    0.160008] smpboot: Booting Node   0, Processors  #1 OK
[    0.020000] Initializing CPU#1
[    0.020000] kvm-clock: cpu 1, msr 0:fffd041, secondary cpu clock
[    0.020000] masked ExtINT on CPU#1
[    0.180000] TSC synchronization [CPU#0 -> CPU#1]:
[    0.180000] Measured 568 cycles TSC warp between CPUs, turning off TSC c=
lock.
[    0.180000] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.190077] KVM setup async PF for cpu 1
[    0.190160] Brought up 2 CPUs
[    0.190169] ----------------
[    0.190169] | NMI testsuite:
[    0.190170] --------------------
[    0.196221] kvm-stealtime: cpu 1, msr cab6840
[    0.190171]   remote IPI:  ok  |
[    0.211470]    local IPI:  ok  |
[    0.230068] --------------------
[    0.231335] Good, all   2 testcases passed! |
[    0.232863] ---------------------------------
[    0.234398] smpboot: Total of 2 processors activated (9575.65 BogoMIPS)
[    0.239915] CPU0 attaching sched-domain:
[    0.240019]  domain 0: span 0-1 level CPU
[    0.241621]   groups: 0 (cpu_power =3D 1023) 1
[    0.243755] CPU1 attaching sched-domain:
[    0.245185]  domain 0: span 0-1 level CPU
[    0.246802]   groups: 1 0 (cpu_power =3D 1023)
[    0.257434] xor: measuring software checksum speed
[    0.360005]    pIII_sse  :  7509.600 MB/sec
[    0.460006]    prefetch64-sse:  8331.200 MB/sec
[    0.461595] xor: using function: prefetch64-sse (8331.200 MB/sec)
[    0.463502] atomic64 test passed for i386+ platform with CX8 and with SSE
[    0.469671] NET: Registered protocol family 16
[    0.472391] cpuidle: using governor ladder
[    0.473826] cpuidle: using governor menu
[    0.476720] ACPI: bus type PCI registered
[    0.478381] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.480006] PCI: Using configuration type 1 for base access
[    0.483189] Missing cpus node, bailing out
[    0.484738] Missing cpus node, bailing out
[    0.525780] bio: create slab <bio-0> at 0
[    0.525780] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.530067] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.532492] ACPI: Added _OSI(Module Device)
[    0.534011] ACPI: Added _OSI(Processor Device)
[    0.535582] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.537212] ACPI: Added _OSI(Processor Aggregator Device)
[    0.544458] ACPI: EC: Look up EC in DSDT
[    0.561581] ACPI: Interpreter enabled
[    0.563014] ACPI: (supports S0 S5)
[    0.564314] ACPI: Using IOAPIC for interrupt routing
[    0.566095] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.596965] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.598984] acpi PNP0A03:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    0.600007] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.603701] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.607550] PCI host bridge to bus 0000:00
[    0.610011] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.611840] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.613826] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.615820] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.618026] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.620113] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.623347] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.631556] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.643508] pci 0000:00:01.1: reg 0x20: [io  0xc060-0xc06f]
[    0.647364] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.650459] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.653049] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.656183] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.660724] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.664295] pci 0000:00:02.0: reg 0x14: [mem 0xfebe0000-0xfebe0fff]
[    0.672637] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    0.675781] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.678825] pci 0000:00:03.0: reg 0x10: [io  0xc040-0xc05f]
[    0.681017] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    0.687938] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    0.691020] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.693980] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.696965] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.704583] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    0.707488] pci 0000:00:05.0: [8086:25ab] type 00 class 0x088000
[    0.710309] pci 0000:00:05.0: reg 0x10: [mem 0xfebe2000-0xfebe200f]
[    0.716738] pci_bus 0000:00: on NUMA node 0
[    0.721121] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.724212] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.727274] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.730361] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.733175] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.737190] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.739147] ACPI: \_SB_.PCI0: notify handler is installed
[    0.740241] Found 1 acpi root devices
[    0.742028] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.744754] vgaarb: loaded
[    0.745856] vgaarb: bridge control possible 0000:00:02.0
[    0.747817] tps65010: version 2 May 2005
[    0.790099] tps65010: no chip?
[    0.792635] SCSI subsystem initialized
[    0.794473] media: Linux media interface: v0.10
[    0.796095] Linux video capture interface: v2.00
[    0.797783] pps_core: LinuxPPS API ver. 1 registered
[    0.799434] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.800034] PTP clock support registered
[    0.801700] wmi: Mapper loaded
[    0.803000] PCI: Using ACPI for IRQ routing
[    0.804489] PCI: pci_cache_line_size set to 64 bytes
[    0.806410] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.810011] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.812701] NET: Registered protocol family 23
[    0.814369] Bluetooth: Core ver 2.16
[    0.815752] NET: Registered protocol family 31
[    0.817297] Bluetooth: HCI device and connection manager initialized
[    0.820029] Bluetooth: HCI socket layer initialized
[    0.821685] Bluetooth: L2CAP socket layer initialized
[    0.823404] Bluetooth: SCO socket layer initialized
[    0.826538] nfc: nfc_init: NFC Core ver 0.1
[    0.828163] NET: Registered protocol family 39
[    0.831543] Switched to clocksource kvm-clock
[    0.831706] cfg80211: Calling CRDA to update world regulatory domain
[    0.834896] Warning: could not register annotated branches stats
[    0.944065] pnp: PnP ACPI init
[    0.945601] ACPI: bus type PNP registered
[    0.947230] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.950201] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.952394] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.955222] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.957366] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.960288] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.962488] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.965228] pnp 00:03: [dma 2]
[    0.966551] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.968767] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.971636] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.973838] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.976691] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.979769] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.982513] pnp: PnP ACPI: found 7 devices
[    0.983964] ACPI: bus type PNP unregistered
[    0.985460] PnPBIOS: Disabled
[    1.461452] mdacon: MDA with 8K of memory detected.
[    1.461598] Console: switching consoles 13-16 to MDA-2
[    1.500282] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.502145] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.503973] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.506000] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.508221] NET: Registered protocol family 1
[    1.509825] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.511854] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.513797] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.515852] pci 0000:00:02.0: Boot video device
[    1.517576] PCI: CLS 0 bytes, default 64
[    1.519824] Trying to unpack rootfs image as initramfs...
[    3.236238] Freeing initrd memory: 25284K (ce73f000 - cfff0000)
[    3.240286] Machine check injector initialized
[    3.242204] Scanning for low memory corruption every 60 seconds
[    3.247867] PCLMULQDQ-NI instructions are not detected.
[    3.249602] NatSemi SCx200 Driver
[    3.253902] Initializing RT-Tester: OK
[    3.255391] audit: initializing netlink socket (disabled)
[    3.257204] type=3D2000 audit(1379897054.738:1): initialized
[    3.262449] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    3.265745] VFS: Disk quotas dquot_6.5.2
[    3.267291] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    3.272031] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    3.273739] jffs2: version 2.2.=20
[    3.276063] ROMFS MTD (C) 2007 Red Hat, Inc.
[    3.277649] QNX4 filesystem 0.2.3 registered.
[    3.279205] QNX6 filesystem 1.0.0 registered.
[    3.280882] fuse init (API version 7.22)
[    3.282597] SGI XFS with ACLs, security attributes, large block/inode nu=
mbers, debug enabled
[    3.287164] NILFS version 2 loaded
[    3.288430] OCFS2 1.5.0
[    3.289909] OCFS2 DLMFS 1.5.0
[    3.291426] OCFS2 User DLM kernel interface loaded
[    3.293010] OCFS2 Node Manager 1.5.0
[    3.300372] GFS2 installed
[    3.312818] alg: No test for lz4 (lz4-generic)
[    3.314575] alg: No test for lz4hc (lz4hc-generic)
[    3.316386] alg: No test for stdrng (krng)
[    3.330857] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    3.333170] NET: Registered protocol family 38
[    3.334700] Key type asymmetric registered
[    3.336252] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    3.338775] io scheduler noop registered (default)
[    3.341419] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    3.343200] cpqphp: Compaq Hot Plug PCI Controller Driver version: 0.9.8
[    3.345304] ibmphpd: IBM Hot Plug PCI Controller Driver version: 0.6
[    3.347389] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    3.349641] Console: switching consoles 13-16 to MDA-2
[    3.352100] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    3.354543] vmlfb: initializing
[    3.355830] no IO addresses supplied
[    3.357366] hgafb: HGA card not detected.
[    3.358794] hgafb: probe of hgafb.0 failed with error -22
[    3.361001] ipmi message handler version 39.2
[    3.362509] ipmi device interface
[    3.363827] IPMI System Interface driver.
[    3.365355] ipmi_si: Adding default-specified kcs state machine
[    3.367359] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    3.370528] ipmi_si: Interface detection failed
[    3.471472] ipmi_si: Adding default-specified smic state machine
[    3.473596] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    3.476914] ipmi_si: Interface detection failed
[   12.630065] [sched_delayed] sched: RT throttling activated
[   12.640166] ipmi_si: Adding default-specified bt state machine
[   12.642264] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[   12.645419] ipmi_si: Interface detection failed
[   12.660350] ipmi_si: Unable to find any System Interface(s)
[   12.662197] IPMI Watchdog: driver initialized
[   12.664108] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   12.666684] ACPI: Power Button [PWRF]
[   12.669183] isapnp: Scanning for PnP cards...
[   13.037419] isapnp: No Plug & Play device found
[   13.041828] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   13.043679] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:3)
[   13.047101] virtio-pci 0000:00:03.0: setting latency timer to 64
[   13.049425] r3964: Philips r3964 Driver $Revision: 1.10 $
[   13.051233] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   13.077813] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[   13.081914] STMicroelectronics ASC driver initialized
[   13.084231] serial: Freescale lpuart driver
[   13.085776] Initializing Nozomi driver 2.1d
[   13.087633] DoubleTalk PC - not found
[   13.088977] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 =
Exp $
[   13.091199] ac.o: No PCI boards found.
[   13.092562] ac.o: For an ISA board you must supply memory and irq parame=
ters.
[   13.094703] sonypi: Sony Programmable I/O Controller Driver v1.26.
[   13.106871] Non-volatile memory driver v1.3
[   13.108389] ppdev: user-space parallel port driver
[   13.109969] nsc_gpio initializing
[   13.111295] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[   13.112981] smapi::smapi_init, ERROR invalid usSmapiID
[   13.114658] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[   13.117647] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[   13.120170] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   13.122191] SyncLink PC Card driver $Revision: 4.34 $, tty major#240
[   13.124279] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[   13.127186] Hangcheck: Using getrawmonotonic().
[   13.128938] [drm] Initialized drm 1.1.0 20060810
[   13.130708] [drm] radeon kernel modesetting enabled.
[   13.133007] parport_pc 00:04: reported by Plug and Play ACPI
[   13.135023] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   13.214507] Floppy drive(s): fd0 is 1.44M
[   13.220401] brd: module loaded
[   13.221634] Compaq SMART2 Driver (v 2.6.0)
[   13.223642] MM: desc_per_page =3D 128
[   13.226605] nbd: registered device at major 43
[   13.231162] FDC 0 is a S82078B
[   13.234930] mtip32xx Version 1.2.6os3
[   13.236677] dummy-irq: no IRQ given.  Use irq=3DN
[   13.238290] lkdtm: No crash points registered, enable through debugfs
[   13.240474] Phantom Linux Driver, version n0.9.8, init OK
[   13.242615] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[   13.245293] c2port c2port0: C2 port uc added
[   13.246760] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[   13.249539] Guest personality initialized and is inactive
[   13.251438] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D57)
[   13.253484] Initialized host personality
[   13.256901] Loading iSCSI transport class v2.0-870.
[   13.260412] fnic: Cisco FCoE HBA Driver, ver 1.5.0.23
[   13.262228] fnic: Successfully Initialized Trace Buffer
[   13.264655] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.14 (Ma=
r 08, 2013)
[   13.270875] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[   13.272692] Detecting Adaptec I2O RAID controllers...
[   13.275874] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[   13.278028] scsi: <fdomain> Detection failed (no card)
[   13.279941] NCR53c406a: no available ports found
[   13.281576] sym53c416.c: Version 1.0.0-ac
[   13.283075] qlogicfas: no cards were found, please specify I/O address a=
nd IRQ using iobase=3D and irq=3D options
[   13.286099] iscsi: registered transport (qla4xxx)
[   13.288238] QLogic iSCSI HBA Driver
[   13.289518] Brocade BFA FC/FCOE SCSI driver - version: 3.2.21.1
[   13.291561] csiostor: Chelsio FCoE driver 1.0.0
[   13.330154] Failed initialization of WD-7000 SCSI card!
[   13.494496] mpt2sas version 16.100.00.00 loaded
[   13.496215] mpt3sas version 02.100.00.00 loaded
[   13.497971] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   13.500050] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[   13.502644] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v=
3.26.02.000.
[   13.505308] imm: Version 2.05 (for Linux 2.4.0)
[   13.507552] nsp32: loading...
[   13.508764] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[   13.510961] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.6.2 (Jun 06, 2=
013)
[   13.513196] iscsi: registered transport (bnx2i)
[   13.515229] esas2r: driver will not be loaded because no ATTO esas2r dev=
ices were found
[   13.518135] VMware PVSCSI driver - version 1.0.2.0-k
[   13.519826] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[   13.522008] osst :I: Tape driver with OnStream support version 0.99.4
[   13.522008] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   13.526149] osd: LOADED open-osd 0.2.1
[   13.528434] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[   13.536017] SSFDC read-only Flash Translation layer
[   13.537765] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[   13.540395] device id =3D 2440
[   13.541566] device id =3D 2480
[   13.542733] device id =3D 24c0
[   13.543902] device id =3D 24d0
[   13.545056] device id =3D 25a1
[   13.546210] device id =3D 2670
[   13.547595] NetSc520 flash device: 0x100000 at 0x200000
[   13.549293] Failed to ioremap_nocache
[   13.551957] ftl_cs: FTL header not found.
[   13.556988] LocalTalk card not found; 220 =3D ff, 240 =3D ff.
[   13.560564] libphy: Fixed MDIO Bus: probed
[   13.562692] arcnet loaded.
[   13.563806] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[   13.565890] arcnet: RFC1051 "simple standard" (`s') encapsulation suppor=
t loaded.
[   13.568448] arcnet: raw mode (`r') encapsulation support loaded.
[   13.570379] arcnet: cap mode (`c') encapsulation support loaded.
[   13.572284] arcnet: COM90xx chipset support
[   13.874759] S3: No ARCnet cards found.
[   13.876288] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[   13.878802] E-mail me if you actually test this driver, please!
[   13.880744]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[   13.883562] arcnet: RIM I (entirely mem-mapped) support
[   13.885333] E-mail me if you actually test the RIM I driver, please!
[   13.887358] Given: node 00h, shmem 0h, irq 0
[   13.888866] No autoprobe for RIM I; you must specify the shmem and irq!
[   13.891065] arcnet: COM20020 ISA support (by David Woodhouse et al.)
[   13.893081]  arc%d: No autoprobe (yet) for IO mapped cards; you must spe=
cify the base address!
[   13.895953] arcnet: COM20020 PCI support
[   13.897523] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[   13.900583] ipddp0: Appletalk-IP Decap. mode by Jay Schulist <jschlst@sa=
mba.org>
[   13.903186] vcan: Virtual CAN interface driver
[   13.904886] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[   13.907353] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.18 (Sept 0=
1, 2013)
[   13.910312] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.17-0 (2013/04/11)
[   13.914209] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.50
[   13.916321] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   13.918228] e100: Copyright(c) 1999-2006 Intel Corporation
[   13.920149] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   13.922368] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   13.926797] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[   13.928647] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:3)
[   13.932258] e1000 0000:00:04.0: setting latency timer to 64
[   14.327400] e1000 0000:00:04.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:57
[   14.329588] e1000 0000:00:04.0 eth0: Intel(R) PRO/1000 Network Connection
[   14.331771] igbvf: Intel(R) Gigabit Virtual Function Network Driver - ve=
rsion 2.0.2-k
[   14.334461] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   14.336403] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.15.1-k
[   14.339001] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[   14.340979] i40e: Intel(R) Ethernet Connection XL710 Network Driver - ve=
rsion 0.3.9-k
[   14.343636] i40e: Copyright (c) 2013 Intel Corporation.
[   14.345413] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[   14.347583] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   14.349485] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   14.351496] sky2: driver version 1.30
[   14.353642] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   14.355770] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[   14.357825] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.3.50
[   14.359939] QLogic/NetXen Network Driver v4.0.81
[   14.361714] atp.c:v1.09=3Dac 2002/10/01 Donald Becker <becker@scyld.com>
[   14.365687] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   14.367472] plip0: Parallel port at 0x378, using IRQ 7.
[   14.369159] PPP generic driver version 2.4.2
[   14.370918] PPP Deflate Compression module registered
[   14.372590] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256).
[   14.374727] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   14.376651] LAPB Ethernet driver version 0.02
[   14.378146] I2O subsystem v1.325
[   14.379361] i2o: max drivers =3D 8
[   14.381172] I2O Configuration OSM v1.323
[   14.382756] I2O Bus Adapter OSM v1.317
[   14.384152] I2O Block Device OSM v1.325
[   14.386445] Fusion MPT base driver 3.04.20
[   14.387890] Copyright (c) 1999-2008 LSI Corporation
[   14.389554] Fusion MPT SPI Host driver 3.04.20
[   14.391187] Fusion MPT FC Host driver 3.04.20
[   14.392784] Fusion MPT misc device (ioctl) driver 3.04.20
[   14.394618] mptctl: Registered with Fusion MPT base driver
[   14.396391] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[   14.399409] Intel ISA PCIC probe: not found.
[   14.401470] Databook TCIC-2 PCMCIA probe: not found.
[   14.404701] aoe: AoE v85 initialised.
[   14.406135] paride: bpck registered as protocol 0
[   14.407711] paride: comm registered as protocol 1
[   14.409293] paride: epat registered as protocol 2
[   14.410878] paride: frpw registered as protocol 3
[   14.412473] paride: friq registered as protocol 4
[   14.414052] paride: on26 registered as protocol 5
[   14.415624] bpck6: BACKPACK Protocol Driver V2.0.2
[   14.417210] bpck6: Copyright 2001 by Micro Solutions, Inc., DeKalb IL. U=
SA
[   14.419283] paride: bpck6 registered as protocol 6
[   14.421005] pd: pd version 1.05, major 45, cluster 64, nice 0
[   17.628229] pda: Autoprobe failed
[   17.629490] pd: no valid drive found
[   17.631157] pcd: pcd version 1.07, major 46, nice 0
[   20.827032] pcd0: Autoprobe failed
[   20.828353] pcd: No CD-ROM drive found
[   20.829818] pf: pf version 1.04, major 47, cluster 64, nice 0
[   20.831718] pf: No ATAPI disk detected
[   20.833122] pt: pt version 1.04, major 96
[   24.032235] pt0: Autoprobe failed
[   24.033510] pt: No ATAPI tape drive detected
[   24.034976] pg: pg version 1.02, major 97
[   27.231761] pga: Autoprobe failed
[   27.233019] pg: No ATAPI device detected
[   27.234880] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   27.239006] serio: i8042 KBD port at 0x60,0x64 irq 1
[   27.240727] serio: i8042 AUX port at 0x60,0x64 irq 12
[   27.242445] parport0: cannot grant exclusive access for device parkbd
[   27.347146] mousedev: PS/2 mouse device common for all mice
[   27.349067] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[   27.352967] mk712: device not present
[   27.354763] rtc_cmos 00:00: RTC can wake from S4
[   27.356936] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   27.359114] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[   27.362452] i2c /dev entries driver
[   27.364884] i2c-parport-light: adapter type unspecified
[   27.366762] isa i2c-pca-isa.0: Please specify I/O base
[   27.370588] Marvell M88ALP01 'CAFE' Camera Controller version 2
[   27.372715] Colour QuickCam for Video4Linux v0.06
[   28.889001] No Quickcam found on port parport0
[   28.890546] Quickcam detection counter: 0
[   28.893530] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   28.896521] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[   28.932518] pps pps0: new PPS source ktimer
[   28.934135] pps pps0: ktimer PPS source registered
[   28.935805] pps_ldisc: PPS line discipline registered
[   28.937547] pps_parport: parallel port PPS client
[   28.939231] parport0: cannot grant exclusive access for device pps_parpo=
rt
[   28.941453] pps_parport: couldn't register with parport0
[   28.943349] Driver for 1-wire Dallas network protocol.
[   28.945384] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[   28.950315] applesmc: supported laptop not found!
[   28.951929] applesmc: driver init failed (ret=3D-19)!
[   28.955499] pc87360: PC8736x not detected, module not inserted
[   28.958182] Bluetooth: Virtual HCI driver ver 1.3
[   28.959841] Bluetooth: HCI UART driver ver 2.2
[   28.961441] Bluetooth: HCI BCSP protocol initialized
[   28.963094] Bluetooth: HCILL protocol initialized
[   28.964716] Bluetooth: HCI Three-wire UART (H5) protocol initialized
[   28.974825] ISDN subsystem Rev: 1.1.2.3/1.1.2.2/none/none/1.1.2.2
[   28.977586] Modular ISDN core version 1.1.29
[   28.979228] NET: Registered protocol family 34
[   28.980799] DSP module 2.0
[   28.981924] mISDN_dsp: DSP clocks every 80 samples. This equals 1 jiffie=
s.
[   28.986673] AVM Fritz PCI driver Rev. 2.3
[   28.988171] Infineon ISDN Driver Rev. 1.0
[   28.989703] Netjet PCI driver Rev. 2.0
[   28.991254] mISDNipac module version 2.0
[   28.992663] dss1_divert module successfully installed
[   28.994354] ICN-ISDN-driver Rev 1.65.6.8 mem=3D0x000d0000
[   28.996157] icn: (line0) ICN-2B, port 0x320 added
[   28.997757] PCBIT-D device driver v 0.5-fjpc0 19991204 - Copyright (C) 1=
996 Universidade de Lisboa
[   29.000726] Trying to detect board using default settings
[   29.002596] IBM Active 2000 ISDN driver
[   29.004183] act2000: No cards defined yet
[   29.005593] gigaset: Driver for Gigaset 307x (debug build)
[   29.007372] gigaset: ISDN4Linux interface
[   29.008883] cpufreq-nforce2: No nForce2 chipset.
[   29.011180] leds_ss4200: no LED devices found
[   29.012905] ledtrig-cpu: registered to indicate activity on CPUs
[   29.018408] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   29.021092] cs5535-clockevt: Could not allocate MFGPT timer
[   29.025315] vme_user: VME User Space Access Driver
[   29.026948] vme_user: No cards, skipping registration
[   29.029833] zram: Created 1 device(s) ...
[   29.031447] Loading crystalhd 0.9.27
[   29.033143] input: Speakup as /devices/virtual/input/input2
[   29.035098] evbug: Connected device: input2 (Speakup at speakup/input0)
[   29.037448] initialized device: /dev/synth, node (MAJOR 10, MINOR 25)
[   29.039833] speakup 3.1.6: initialized
[   29.041300] synth name on entry is: (null)
[   29.043028] dgnc: dgnc-1.3-16, Digi International Part Number 40002369_F
[   29.045309] dgnc: For the tools package or updated drivers please visit =
http://www.digi.com
[   29.048614] dgap: dgap-1.3-16, Digi International Part Number 40002347_C
[   29.050908] dgap: For the tools package or updated drivers please visit =
http://www.digi.com
[   29.056328]  fake-fmc-carrier: mezzanine 0
[   29.057787]       Manufacturer: fake-vendor
[   29.059281]       Product name: fake-design-for-testing
[   29.061223] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[   29.063395] fmc_write_eeprom fake-design-for-testing-f001: fmc_write_eep=
rom: no busid passed, refusing all cards
[   29.066709] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[   29.069007] fmc_chardev fake-design-for-testing-f001: Created misc devic=
e "fake-design-for-testing-f001"
[   29.072328] NET: Registered protocol family 17
[   29.073966] NET: Registered protocol family 5
[   29.075609] NET: Registered protocol family 9
[   29.077148] X.25 for Linux Version 0.2
[   29.078610] can: controller area network core (rev 20120528 abi 9)
[   29.080837] NET: Registered protocol family 29
[   29.082399] can: raw protocol (rev 20120528)
[   29.083908] can: netlink gateway (rev 20130117) max_hops=3D1
[   29.085795] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   29.087580] Bluetooth: BNEP filters: protocol=20
[   29.089143] Bluetooth: BNEP socket layer initialized
[   29.090856] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   29.092768] Bluetooth: HIDP socket layer initialized
[   29.094446] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   29.097465] DECnet: Routing cache hash table of 256 buckets, 11Kbytes
[   29.099585] NET: Registered protocol family 12
[   29.101314] NET: Registered protocol family 35
[   29.102976] 8021q: 802.1Q VLAN Support v1.8
[   29.104690] Key type dns_resolver registered
[   29.106208] openvswitch: Open vSwitch switching datapath
[   29.108485] NET: Registered protocol family 40
[   29.110091] mpls_gso: MPLS GSO support
[   29.113713]=20
[   29.113713] printing PIC contents
[   29.115667] ... PIC  IMR: ffff
[   29.116895] ... PIC  IRR: 1153
[   29.118144] ... PIC  ISR: 0000
[   29.119352] ... PIC ELCR: 0c00
[   29.120620] printing local APIC contents on CPU#0/0:
[   29.122301] ... APIC ID:      00000000 (0)
[   29.123765] ... APIC VERSION: 00050014
[   29.125147] ... APIC TASKPRI: 00000000 (00)
[   29.126638] ... APIC PROCPRI: 00000000
[   29.128006] ... APIC LDR: 01000000
[   29.129304] ... APIC DFR: ffffffff
[   29.130571] ... APIC SPIV: 000001ff
[   29.130571] ... APIC ISR field:
[   29.130571] 000000000000000000000000000000000000000000000000000000000000=
0000
[   29.130571] ... APIC TMR field:
[   29.130571] 000000000220000000000000000000000000000000000000000000000000=
0000
[   29.130571] ... APIC IRR field:
[   29.130571] 000000000000000000000000000000000000000000000000000000000000=
8000
[   29.130571] ... APIC ESR: 00000000
[   29.130571] ... APIC ICR: 000008fb
[   29.130571] ... APIC ICR2: 02000000
[   29.130571] ... APIC LVTT: 000000ef
[   29.130571] ... APIC LVTPC: 00010000
[   29.130571] ... APIC LVT0: 00010700
[   29.130571] ... APIC LVT1: 00000400
[   29.130571] ... APIC LVTERR: 000000fe
[   29.130571] ... APIC TMICT: 0008fbcb
[   29.130571] ... APIC TMCCT: 00000000
[   29.130571] ... APIC TDCR: 00000003
[   29.130571]=20
[   29.162027] number of MP IRQ sources: 15.
[   29.163478] number of IO-APIC #0 registers: 24.
[   29.165027] testing the IO APIC.......................
[   29.166782] IO APIC #0......
[   29.167940] .... register #00: 00000000
[   29.169345] .......    : physical APIC id: 00
[   29.170884] .......    : Delivery Type: 0
[   29.172308] .......    : LTS          : 0
[   29.173740] .... register #01: 00170011
[   29.175125] .......     : max redirection entries: 17
[   29.176805] .......     : PRQ implemented: 0
[   29.178301] .......     : IO APIC version: 11
[   29.179803] .... register #02: 00000000
[   29.181270] .......     : arbitration: 00
[   29.182693] .... IRQ redirection table:
[   29.184118] 1    0    0   0   0    0    0    00
[   29.185696] 0    0    0   0   0    1    1    31
[   29.187291] 0    0    0   0   0    1    1    30
[   29.188861] 0    0    0   0   0    1    1    33
[   29.190492] 1    0    0   0   0    1    1    34
[   29.192065] 0    1    0   0   0    1    1    35
[   29.193665] 0    0    0   0   0    1    1    36
[   29.195229] 0    0    0   0   0    1    1    37
[   29.207374] 0    0    0   0   0    1    1    38
[   29.208955] 0    1    0   0   0    1    1    39
[   29.210583] 1    1    0   0   0    1    1    3A
[   29.212159] 1    1    0   0   0    1    1    3B
[   29.213749] 0    0    0   0   0    1    1    3C
[   29.215334] 0    0    0   0   0    1    1    3D
[   29.216910] 0    0    0   0   0    1    1    3E
[   29.218498] 0    0    0   0   0    1    1    3F
[   29.220139] 1    0    0   0   0    0    0    00
[   29.221731] 1    0    0   0   0    0    0    00
[   29.223295] 1    0    0   0   0    0    0    00
[   29.224862] 1    0    0   0   0    0    0    00
[   29.226474] 1    0    0   0   0    0    0    00
[   29.228058] 1    0    0   0   0    0    0    00
[   29.229634] 1    0    0   0   0    0    0    00
[   29.231262] 1    0    0   0   0    0    0    00
[   29.232809] IRQ to pin mappings:
[   29.234079] IRQ0 -> 0:2
[   29.235456] IRQ1 -> 0:1
[   29.236842] IRQ3 -> 0:3
[   29.238241] IRQ4 -> 0:4
[   29.239607] IRQ5 -> 0:5
[   29.241061] IRQ6 -> 0:6
[   29.242437] IRQ7 -> 0:7
[   29.243824] IRQ8 -> 0:8
[   29.245208] IRQ9 -> 0:9
[   29.246612] IRQ10 -> 0:10
[   29.248035] IRQ11 -> 0:11
[   29.249471] IRQ12 -> 0:12
[   29.250928] IRQ13 -> 0:13
[   29.252356] IRQ14 -> 0:14
[   29.253788] IRQ15 -> 0:15
[   29.255212] .................................... done.
[   29.256934] Using IPI No-Shortcut mode
[   29.258823] registered taskstats version 1
[   29.261214] Key type trusted registered
[   29.263914] Key type encrypted registered
[   29.268211] hd: no drives specified - use hd=3Dcyl,head,sectors on kerne=
l command line
[   29.271240] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   29.273149] EDD information not available.
[   29.274743] ### dt-test ### No testcase data in device tree; not running=
 tests
[   29.282568] Freeing unused kernel memory: 2044K (c275a000 - c2959000)
[   29.285772] Write protecting the kernel text: 14112k
[   29.288900] Write protecting the kernel read-only data: 7784k
[   59.076593] init: Failed to create pty - disabling logging for job
[   59.079366] init: Temporary process spawn error: No such file or directo=
ry
[   59.139328] init: Failed to create pty - disabling logging for job
[   59.142270] init: Temporary process spawn error: No such file or directo=
ry
[   59.281954] (stc): gdata/new_proto/recv or reg_complete_cb not ready
[   59.283877] fmdrv: Failed to get ST write func pointer
[   59.286200] (stc):  chnl_id 8 not supported
[   59.287370] fmdrv: st_unregister failed -93
[   59.289403] fmdrv: Unable to prepare FM CORE
[   59.301621] init: Failed to create pty - disabling logging for job
[   59.304070] init: Temporary process spawn error: No such file or directo=
ry
[   59.327994] init: Failed to create pty - disabling logging for job
[   59.331096] init: Temporary process spawn error: No such file or directo=
ry
[   59.351210] init: Failed to create pty - disabling logging for job
[   59.353724] init: Temporary process spawn error: No such file or directo=
ry
[   59.369440] init: udev-fallback-graphics main process (3490) terminated =
with status 1
[   59.453736] init: failsafe main process (3478) killed by TERM signal
[   59.501415] init: networking main process (3500) terminated with status 1
[   59.611591] init: Failed to create pty - disabling logging for job
[   59.613913] init: Temporary process spawn error: No such file or directo=
ry
[   59.628995] init: Failed to create pty - disabling logging for job
[   59.631651] init: Temporary process spawn error: No such file or directo=
ry
[   59.645428] init: Failed to create pty - disabling logging for job
[   59.647923] init: Temporary process spawn error: No such file or directo=
ry
[   59.664741] init: Failed to create pty - disabling logging for job
[   59.667412] init: Temporary process spawn error: No such file or directo=
ry
[   59.685582] init: Failed to create pty - disabling logging for job
[   59.688146] init: Temporary process spawn error: No such file or directo=
ry
Kernel tests: Boot OK!
[   89.500806] init: Failed to create pty - disabling logging for job
[   89.503384] init: Temporary process spawn error: No such file or directo=
ry
[   89.788224] init: rc main process (3523) killed by TERM signal
[   89.812186] init: tty4 main process (3524) killed by TERM signal
[   89.816578] init: tty5 main process (3525) killed by TERM signal
[   89.821230] init: tty2 main process (3526) killed by TERM signal
[   89.825669] init: tty3 main process (3527) killed by TERM signal
[   89.831001] init: hwclock-save main process (3555) terminated with statu=
s 70
[   89.835504] init: plymouth-upstart-bridge main process (3556) terminated=
 with status 1
[   89.986606] init: tty6 main process (3529) killed by TERM signal
[   91.414086] BUG: Bad page map in process killall5  pte:cf17e720 pmd:05a2=
2067
[   91.416626] addr:bfc00000 vm_flags:00100173 anon_vma:cf128c80 mapping:  =
(null) index:bfff0
[   91.419402] CPU: 0 PID: 3574 Comm: killall5 Not tainted 3.12.0-rc1-00010=
-g5fbc0a6 #24
[   91.422171] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   91.423998]  00000000 00000000 c0199e34 c1db5db4 00000000 c0199e54 c10e7=
2d4 000bfff0
[   91.427933]  00000000 bfc00000 00000000 000cf17e cf17e720 c0199e74 c10e7=
995 00000000
[   91.431940]  bfc00000 cf1ca190 bfc00000 cf180000 cf1ca190 c0199ee0 c10eb=
8cf ce6d1900
[   91.435894] Call Trace:
[   91.436969]  [<c1db5db4>] dump_stack+0x4b/0x66
[   91.438503]  [<c10e72d4>] print_bad_pte+0x14b/0x162
[   91.440204]  [<c10e7995>] vm_normal_page+0x67/0x9b
[   91.441811]  [<c10eb8cf>] munlock_vma_pages_range+0xf9/0x176
[   91.443633]  [<c10ede09>] exit_mmap+0x86/0xf7
[   91.445156]  [<c10885b8>] ? lock_release+0x169/0x1ef
[   91.446795]  [<c113e5b6>] ? rcu_read_unlock+0x17/0x23
[   91.448465]  [<c113effe>] ? exit_aio+0x2b/0x6c
[   91.449990]  [<c103d4b0>] mmput+0x6a/0xcb
[   91.451508]  [<c104141a>] do_exit+0x362/0x8be
[   91.453013]  [<c105d280>] ? hrtimer_debug_hint+0xd/0xd
[   91.454700]  [<c10419f8>] do_group_exit+0x51/0x9e
[   91.456296]  [<c1041a5b>] SyS_exit_group+0x16/0x16
[   91.457901]  [<c1dc6719>] sysenter_do_call+0x12/0x33
[   91.459553] Disabling lock debugging due to kernel taint

BUG: kernel test oops
Elapsed time: 100
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-r=
0-0923/5fbc0a6263a147cde905affbfb6622c26684344f/vmlinuz-3.12.0-rc1-00010-g5=
fbc0a6 -append 'hung_task_panic=3D1 rcutree.rcu_cpu_stall_timeout=3D100 log=
_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dynamic_printk=
 sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 console=3DttyS0,115200=
 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-=
queue/kvm/i386-randconfig-r0-0923/devel-roam-i386-201309231807/.vmlinuz-5fb=
c0a6263a147cde905affbfb6622c26684344f-20130923182124-4-lkp-tt02 branch=3Dli=
nux-devel/devel-roam-i386-201309231807 BOOT_IMAGE=3D/kernel/i386-randconfig=
-r0-0923/5fbc0a6263a147cde905affbfb6622c26684344f/vmlinuz-3.12.0-rc1-00010-=
g5fbc0a6'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 256M -smp =
2 -net nic,vlan=3D0,macaddr=3D00:00:00:00:00:00,model=3Dvirtio -net user,vl=
an=3D0,hostfwd=3Dtcp::9441-:22 -net nic,vlan=3D1,model=3De1000 -net user,vl=
an=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -pidfile /dev/shm/kbo=
ot/pid-lkp-tt02-lkp-5345 -serial file:/dev/shm/kboot/serial-lkp-tt02-lkp-53=
45 -daemonize -display none -monitor null=20

--+QahgC5+KEYLbs62
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-5fbc0a6263a147cde905affbfb6622c26684344f-i386-randconfig-r0-0923-BUG:-Bad-page-map-in-process-13263.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDI3MmI5OGM2NDU1ZjAwODg0ZjAzNTBmNzc1YzUzNDIzNThlYmI3M2YK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgNWZiYzBhNi4uLiBNZXJnZSByZW1vdGUtdHJh
Y2tpbmcgYnJhbmNoICdwaW5jdHJsL2Zvci1uZXh0JyBpbnRvIGtidWlsZF90bXAKSEVBRCBp
cyBub3cgYXQgMjcyYjk4Yy4uLiBMaW51eCAzLjEyLXJjMQpscyAtYSAva2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2
ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzoyNzJiOThjNjQ1NWYwMDg4NGYwMzUwZjc3NWM1
MzQyMzU4ZWJiNzNmOmJpc2VjdC1uZXQKCjIwMTMtMDktMjMtMTg6NDA6MDcgMjcyYjk4YzY0
NTVmMDA4ODRmMDM1MGY3NzVjNTM0MjM1OGViYjczZiByZXVzZSAva2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1yMC0wOTIzLzI3MmI5OGM2NDU1ZjAwODg0ZjAzNTBmNzc1YzUzNDIzNThlYmI3
M2Yvdm1saW51ei0zLjEyLjAtcmMxCgoyMDEzLTA5LTIzLTE4OjQwOjA3IGRldGVjdGluZyBi
b290IHN0YXRlIC4uCTIJNQkxNwkyNgkyOAkzMwk0MAk1Mwk1NyBURVNUIEZBSUxVUkUKG1sx
OzM1bUluY3JlYXNpbmcgcmVwZWF0IGNvdW50IGZyb20gMzcwIHRvIDQ5NRtbMG0KQlVHOiBr
ZXJuZWwgZWFybHkgaGFuZyB3aXRob3V0IGFueSBwcmludGsgb3V0cHV0CkNvbW1hbmQgbGlu
ZTogaHVuZ190YXNrX3BhbmljPTEgcmN1dHJlZS5yY3VfY3B1X3N0YWxsX3RpbWVvdXQ9MTAw
IGxvZ19idWZfbGVuPThNIGlnbm9yZV9sb2dsZXZlbCBkZWJ1ZyBzY2hlZF9kZWJ1ZyBhcGlj
PWRlYnVnIGR5bmFtaWNfcHJpbnRrIHN5c3JxX2Fsd2F5c19lbmFibGVkIHBhbmljPTEwICBw
cm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAwIGNvbnNvbGU9dHR5MCB2Z2E9
bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVl
L2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDkyMy9tNjhrbm9tbXU6Y2ZtbXUvLnZtbGludXot
MjcyYjk4YzY0NTVmMDA4ODRmMDM1MGY3NzVjNTM0MjM1OGViYjczZi0yMDEzMDkyMzE1MjEz
MC00LWFudCBicmFuY2g9bTY4a25vbW11L2NmbW11IEJPT1RfSU1BR0U9L2tlcm5lbC9pMzg2
LXJhbmRjb25maWctcjAtMDkyMy8yNzJiOThjNjQ1NWYwMDg4NGYwMzUwZjc3NWM1MzQyMzU4
ZWJiNzNmL3ZtbGludXotMy4xMi4wLXJjMSBub2FwaWMgbm9sYXBpYyBub2h6PW9mZgpFYXJs
eSBoYW5nIGtlcm5lbDogdm1saW51ei0zLjEyLjAtcmMxIDMuMTIuMC1yYzEgIzkKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy8yNzJiOThjNjQ1NWYwMDg4NGYwMzUwZjc3NWM1
MzQyMzU4ZWJiNzNmL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtODoyMDEzMDkyMzE4NDUxNzoz
LjEyLjAtcmMxOjkKCmJpc2VjdDogYmFkIGNvbW1pdCAyNzJiOThjNjQ1NWYwMDg4NGYwMzUw
Zjc3NWM1MzQyMzU4ZWJiNzNmCmdpdCBjaGVja291dCB2My4xMQpQcmV2aW91cyBIRUFEIHBv
c2l0aW9uIHdhcyAyNzJiOThjLi4uIExpbnV4IDMuMTItcmMxCkhFQUQgaXMgbm93IGF0IDZl
NDY2NDUuLi4gTGludXggMy4xMQpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
aTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIw
MTMwOTIzMTgwNzo2ZTQ2NjQ1MjViMWRiMjhmOGM0ZTExMzA5NTdmNzBhOTRjMTkyMTNlOmJp
c2VjdC1uZXQKCjIwMTMtMDktMjMtMTg6NDU6NDQgNmU0NjY0NTI1YjFkYjI4ZjhjNGUxMTMw
OTU3ZjcwYTk0YzE5MjEzZSBjb21waWxpbmcKNDQxIHJlYWwgIDIyNDYgdXNlciAgMTk2IHN5
cyAgNTUzLjIxJSBjcHUgCWkzODYtcmFuZGNvbmZpZy1yMC0wOTIzCgoyMDEzLTA5LTIzLTE4
OjU1OjE0IGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC4JMwk0CTEyCTE1CTI2CTM5CTQ1
CTU1CTY0CTc2CTg0CTg5CTkyCTkzCTk0CTEwNQkxMTEuCTExMgkxNTgJMTcxCTE3OQkxODkJ
MjA1CTIxNQkyMzEJMjUyCTI2MgkyODIJMjkwCTMxMAkzMjgJMzQ0CTM1NQkzNjYJMzgwCTM5
NAk0MTUJNDQ3CTQ2Mgk0NjgJNDc3Li4uLi4uLi4uCTQ3OC4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAxNxtbMG0KLi4uCTQ3OS4uCTQ4
MQk0ODIuLi4JNDgzLgk0ODQuLi4uLi4uLgk0ODUuLi4uLi4JNDg2Li4uLgk0ODcuLi4JNDg4
Li4JNDg5Li4JNDkwLgk0OTMuLi4uCTQ5NC4uLi4JNDk1IFNVQ0NFU1MKCmJpc2VjdDogZ29v
ZCBjb21taXQgdjMuMTEKZ2l0IGJpc2VjdCBzdGFydCAyNzJiOThjNjQ1NWYwMDg4NGYwMzUw
Zjc3NWM1MzQyMzU4ZWJiNzNmIHYzLjExIC0tClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2Fz
IDZlNDY2NDUuLi4gTGludXggMy4xMQpTd2l0Y2hlZCB0byBicmFuY2ggJ21hc3RlcicKWW91
ciBicmFuY2ggaXMgYmVoaW5kICdvcmlnaW4vbWFzdGVyJyBieSA0MTIxMyBjb21taXRzLCBh
bmQgY2FuIGJlIGZhc3QtZm9yd2FyZGVkLgogICh1c2UgImdpdCBwdWxsIiB0byB1cGRhdGUg
eW91ciBsb2NhbCBicmFuY2gpCkJpc2VjdGluZzogNTA5NCByZXZpc2lvbnMgbGVmdCB0byB0
ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTIgc3RlcHMpCls1N2Q3MzA5MjRkNWNjMmMzZTI4
MGFmMTZhOTMwNjU4N2MzYTUxMWRiXSBNZXJnZSBicmFuY2ggJ3RpbWVycy11cmdlbnQtZm9y
LWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9n
aXQvdGlwL3RpcApnaXQgYmlzZWN0IHJ1biAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApydW5uaW5nIC9jL2tl
cm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9v
YmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRj
b25maWctcjAtMDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3
OjU3ZDczMDkyNGQ1Y2MyYzNlMjgwYWYxNmE5MzA2NTg3YzNhNTExZGI6YmlzZWN0LW5ldAoK
MjAxMy0wOS0yMy0yMjoyMToyNSA1N2Q3MzA5MjRkNWNjMmMzZTI4MGFmMTZhOTMwNjU4N2Mz
YTUxMWRiIGNvbXBpbGluZwozMjMgcmVhbCAgMjQxNSB1c2VyICAyMDMgc3lzICA4MTAuNDUl
IGNwdSAJaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMKCjIwMTMtMDktMjMtMjI6Mjc6MDAgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTA1MDU4LWc1N2Q3MzA5LgkxLgk0CTcJOAk5CTEw
CTExCTEzCTE1LgkxNwkxOAkxOQkyMC4uCTIxLi4JMjIuCTIzCTI0LgkyNQkyNwkyOC4JMjku
LgkzMAkzMS4uLi4JMzIuCTM0LgkzNS4uLi4uLi4uLi4uLgkzNgkzNy4JMzgJMzkJNDAuCTQy
Lgk0My4JNDQuCTQ2CTQ4CTQ5Li4uLgk1Ngk2Mwk2Ngk2Ny4uLgk3MQk3Mgk3NAk3Ngk3OC4u
CTgxCTg0CTg1CTk0CTEwMAkxMTAJMTE3CTEyMwkxMzAJMTM1CTEzOQkxNDgJMTUyCTE2MAkx
NjcJMTY5CTE3MgkxNzYJMTc5CTE4MQkxODQJMTg3CTE5MAkxOTQJMTk3LgkxOTguCTIwMC4J
MjAxCTIwMy4JMjA0CTIwNgkyMDcuCTIwOAkyMTAJMjE0CTIyMQkyMjgJMjM5CTI2MAkyNjYJ
Mjc4CTI5MwkzMDEJMzEyCTMxNQkzMzMJMzU5CTM3NAkzODYJMzk5CTQxOQk0MzYJNDQ0CTQ1
MAk0NjIJNDY3CTQ3MC4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4bWzE7MzVtYWRk
X3RvX3J1bl9xdWV1ZSAyNRtbMG0KCTQ3MQk0NzMJNDc4CTQ3OQk0ODUJNDkyLi4uLgk0OTQu
Li4JNDk1IFNVQ0NFU1MKCkJpc2VjdGluZzogMjUzMyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgMTEgc3RlcHMpClsyN2M3NjUxYTZhNWYxNDNlY2NkNjZk
YjM4YzdhMzAzNWUxZjhiY2ZiXSBNZXJnZSB0YWcgJ2dwaW8tdjMuMTItMScgb2YgZ2l0Oi8v
Z2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2xpbnVzdy9saW51eC1n
cGlvCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5z
aCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVl
dWUva3ZtL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4LWRldmVsOmRldmVsLXJvYW0t
aTM4Ni0yMDEzMDkyMzE4MDc6MjdjNzY1MWE2YTVmMTQzZWNjZDY2ZGIzOGM3YTMwMzVlMWY4
YmNmYjpiaXNlY3QtbmV0CgoyMDEzLTA5LTI0LTAyOjIxOjA3IDI3Yzc2NTFhNmE1ZjE0M2Vj
Y2Q2NmRiMzhjN2EzMDM1ZTFmOGJjZmIgY29tcGlsaW5nCjI4MyByZWFsICAyMzY4IHVzZXIg
IDE5OSBzeXMgIDkwNC44MSUgY3B1IAlpMzg2LXJhbmRjb25maWctcjAtMDkyMwoyMDEzLTA5
LTI0LTAyOjI1OjU5IDI3Yzc2NTFhNmE1ZjE0M2VjY2Q2NmRiMzhjN2EzMDM1ZTFmOGJjZmIg
U0tJUCBCUk9LRU4gQlVJTEQKQ2hlY2sgZXJyb3MgaW4gL2NjL3dmZy9uZXQtYmlzZWN0IGFu
ZCAvdG1wL2tlcm5lbC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy8yN2M3NjUxYTZhNWYxNDNl
Y2NkNjZkYjM4YzdhMzAzNWUxZjhiY2ZiCkJpc2VjdGluZzogMjUzMyByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTEgc3RlcHMpCls3MzA5ZTUwMjJiZGQ2
ZmUxMzEyNGQ0MmE2YjdjZjA1NDMxMTAzMGEwXSBNQUlOVEFJTkVSUzogdXBkYXRlIGF0aDZr
bCBnaXQgbG9jYXRpb24KcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9v
dC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6
ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzo3MzA5ZTUwMjJiZGQ2ZmUxMzEyNGQ0MmE2
YjdjZjA1NDMxMTAzMGEwOmJpc2VjdC1uZXQKCjIwMTMtMDktMjQtMDI6MjY6MDYgNzMwOWU1
MDIyYmRkNmZlMTMxMjRkNDJhNmI3Y2YwNTQzMTEwMzBhMCBjb21waWxpbmcKMjUwIHJlYWwg
IDIzMTkgdXNlciAgMTkzIHN5cyAgMTAwMi4wNCUgY3B1IAlpMzg2LXJhbmRjb25maWctcjAt
MDkyMwoyMDEzLTA5LTI0LTAyOjMwOjI2IDczMDllNTAyMmJkZDZmZTEzMTI0ZDQyYTZiN2Nm
MDU0MzExMDMwYTAgU0tJUCBCUk9LRU4gQlVJTEQKQ2hlY2sgZXJyb3MgaW4gL2NjL3dmZy9u
ZXQtYmlzZWN0IGFuZCAvdG1wL2tlcm5lbC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy83MzA5
ZTUwMjJiZGQ2ZmUxMzEyNGQ0MmE2YjdjZjA1NDMxMTAzMGEwCkJpc2VjdGluZzogMjUzMyBy
ZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTEgc3RlcHMpClsz
YmIyMmVjNTNlMmJkMTJhMjQxZWQ4NDM1OWJmZmQ1OTFhNDBhYjg3XSBzdGFnaW5nL2x1c3Ry
ZS9wdGxycGM6IGNvbnZlcnQgdG8gbmV3IHNocmlua2VyIEFQSQpydW5uaW5nIC9jL2tlcm5l
bC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmot
YmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25m
aWctcjAtMDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjNi
YjIyZWM1M2UyYmQxMmEyNDFlZDg0MzU5YmZmZDU5MWE0MGFiODc6YmlzZWN0LW5ldAoKMjAx
My0wOS0yNC0wMjozMDoyOSAzYmIyMmVjNTNlMmJkMTJhMjQxZWQ4NDM1OWJmZmQ1OTFhNDBh
Yjg3IGNvbXBpbGluZwoyOTMgcmVhbCAgMjM5MCB1c2VyICAyMDAgc3lzICA4ODEuNTglIGNw
dSAJaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMKCjIwMTMtMDktMjQtMDI6MzU6MzcgZGV0ZWN0
aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTA4NzYyLWczYmIyMmVjLi4uLi4uCTIuCTMJNAk1Li4u
CTYuLi4uLgk3CTkuCTE1CTI1CTQxCTU3CTc0CTk0CTEwOQkxMzAJMTU5CTE4MQkyMDAJMjI3
CTI1MQkyNjYJMjkxCTMxNgkzMzEJMzM5CTM1NwkzNjQJMzg3CTQwMAk0MTQJNDMzCTQ0MQk0
NDQuCTQ1MQk0NTYuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgk0NTcuLi4JNDU4Li4u
Lgk0NTkuLi4JNDYwLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtbMTszNW1hZGRf
dG9fcnVuX3F1ZXVlIDM1G1swbQouLi4uCTQ2MS4uLi4uLi4uLgk0NjQJNDY2CTQ2OAk0NzIJ
NDc3CTQ4NAk0ODguLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90
b19ydW5fcXVldWUgNxtbMG0KLi4uLi4JNDg5Li4uLi4uLi4uLgk0OTAuLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4JNDkxLi4uCTQ5Mi4uLi4uLi4uCTQ5My4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAyG1swbQouLi4uLi4JNDk1IFNV
Q0NFU1MKCkJpc2VjdGluZzogNjk0IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAxMCBzdGVwcykKW2E1YjdjODdmOTIwNzYzNTJkYmZmMmZlMDQyM2VjMjU1
ZTFjOWE3MWJdIHZtc2NhbiwgbWVtY2c6IGRvIHNvZnRsaW1pdCByZWNsYWltIGFsc28gZm9y
IHRhcmdldGVkIHJlY2xhaW0KcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVs
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2
ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzphNWI3Yzg3ZjkyMDc2MzUyZGJmZjJm
ZTA0MjNlYzI1NWUxYzlhNzFiOmJpc2VjdC1uZXQKCjIwMTMtMDktMjQtMTI6MDM6MzAgYTVi
N2M4N2Y5MjA3NjM1MmRiZmYyZmUwNDIzZWMyNTVlMWM5YTcxYiBjb21waWxpbmcKNDA3IHJl
YWwgIDIzNDAgdXNlciAgMjA5IHN5cyAgNjI1LjYxJSBjcHUgCWkzODYtcmFuZGNvbmZpZy1y
MC0wOTIzCgoyMDEzLTA5LTI0LTEyOjEwOjMzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTEu
MC0wOTQyNC1nYTViN2M4Ny4uCTIJNC4JNQk5CTEwCTEyCTE1CTE4CTIxCTIzCTI3CTI5CTMx
IFRFU1QgRkFJTFVSRQpbICAgNDEuNzAxNzM0XSBwdDogTm8gQVRBUEkgdGFwZSBkcml2ZSBk
ZXRlY3RlZApbICAgNDEuNzA0NjE1XSBwZzogcGcgdmVyc2lvbiAxLjAyLCBtYWpvciA5Nwpb
ICAgNDUuODgwMDQyXSBJTkZPOiByY3Vfc2NoZWQgc2VsZi1kZXRlY3RlZCBzdGFsbCBvbiBD
UFUgeyAxfSAgKHQ9MjEwMCBqaWZmaWVzIGc9NDI5NDk2NzI0OSBjPTQyOTQ5NjcyNDggcT0w
KQpbICAgNDUuODgwMDQyXSBzZW5kaW5nIE5NSSB0byBhbGwgQ1BVczoKWyAgIDQ1Ljg4MDA0
Ml0gTk1JIGJhY2t0cmFjZSBmb3IgY3B1IDEKWyAgIDQ1Ljg4MDA0Ml0gQ1BVOiAxIFBJRDog
MSBDb21tOiBzd2FwcGVyLzAgTm90IHRhaW50ZWQgMy4xMS4wLTA5NDI0LWdhNWI3Yzg3ICMy
NTIKWyAgIDQ1Ljg4MDA0Ml0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9j
aHMgMDEvMDEvMjAxMQpbICAgNDUuODgwMDQyXSB0YXNrOiBjYzQ1MjAyMCB0aTogY2M0NTQw
MDAgdGFzay50aTogY2M0NTQwMDAKWyAgIDQ1Ljg4MDA0Ml0gRUlQOiAwMDYwOls8YzEwMjdh
YjQ+XSBFRkxBR1M6IDAwMDEwMDQ2IENQVTogMQpbICAgNDUuODgwMDQyXSBFSVAgaXMgYXQg
bmF0aXZlX2FwaWNfbWVtX3dyaXRlKzB4MTIvMHgxNApbICAgNDUuODgwMDQyXSBFQVg6IGZm
ZmZiMzAwIEVCWDogMDAwMDAwMDEgRUNYOiBmZmZmZjAwMCBFRFg6IDAwMDAwYzAwClsgICA0
NS44ODAwNDJdIEVTSTogMDAwMDAwMDIgRURJOiAwMDAwMDgwMCBFQlA6IGNjNDU1Y2RjIEVT
UDogY2M0NTVjZGMKWyAgIDQ1Ljg4MDA0Ml0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMGQ4
IEdTOiAwMGUwIFNTOiAwMDY4ClsgICA0NS44ODAwNDJdIENSMDogODAwNTAwM2IgQ1IyOiBm
ZmZmZmZmZiBDUjM6IDAyOTFkMDAwIENSNDogMDAwMDA2ZDAKWyAgIDQ1Ljg4MDA0Ml0gU3Rh
Y2s6ClsgICA0NS44ODAwNDJdICBjYzQ1NWNmNCBjMTAyN2JjZCAwMDAwMDAwMyAwMDAwMDAw
NiAwMDAwMDAwMyAwMDAwMDAwMCBjYzQ1NWQxMCBjMTAyN2U0OApbICAgNDUuODgwMDQyXSAg
MDAwMDAwMDIgMDAwMDAwMDAgMDAwMDI3MTAgY2NiZjcwYjggMDAwMDAwMDAgY2M0NTVkMTgg
YzEwMjdlYzQgY2M0NTVkMjgKWyAgIDQ1Ljg4MDA0Ml0gIGMxMDI4MGVjIGMyMzA4ZWVkIGMy
NTQ2ZGMwIGNjNDU1ZDY0IGMxMGE0YjUyIGMyMzE2MGFjIDAwMDAwODM0IGZmZmZmZmQxClsg
ICA0NS44ODAwNDJdIENhbGwgVHJhY2U6ClsgICA0NS44ODAwNDJdICBbPGMxMDI3YmNkPl0g
X19kZWZhdWx0X3NlbmRfSVBJX2Rlc3RfZmllbGQrMHg2MS8weDY3ClsgICA0NS44ODAwNDJd
ICBbPGMxMDI3ZTQ4Pl0gZGVmYXVsdF9zZW5kX0lQSV9tYXNrX2xvZ2ljYWwrMHg3OS8weDg3
ClsgICA0NS44ODAwNDJdICBbPGMxMDI3ZWM0Pl0gZGVmYXVsdF9zZW5kX0lQSV9hbGwrMHgy
Ni8weDM3ClsgICA0NS44ODAwNDJdICBbPGMxMDI4MGVjPl0gYXJjaF90cmlnZ2VyX2FsbF9j
cHVfYmFja3RyYWNlKzB4NDEvMHg2OQpbICAgNDUuODgwMDQyXSAgWzxjMTBhNGI1Mj5dIHJj
dV9jaGVja19jYWxsYmFja3MrMHgxNWYvMHgzZWQKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzEwNDk2
Njk+XSB1cGRhdGVfcHJvY2Vzc190aW1lcysweDMyLzB4NTkKWyAgIDQ1Ljg4MDA0Ml0gIFs8
YzEwN2Y0Y2Q+XSB0aWNrX25vaHpfaGFuZGxlcisweGFmLzB4ZmYKWyAgIDQ1Ljg4MDA0Ml0g
IFs8YzEwMjY2NmM+XSBsb2NhbF9hcGljX3RpbWVyX2ludGVycnVwdCsweDQ2LzB4NGIKWyAg
IDQ1Ljg4MDA0Ml0gIFs8YzEwMjZhNWQ+XSBzbXBfYXBpY190aW1lcl9pbnRlcnJ1cHQrMHgy
NS8weDM0ClsgICA0NS44ODAwNDJdICBbPGMxZDliODA0Pl0gYXBpY190aW1lcl9pbnRlcnJ1
cHQrMHgzNC8weDQwClsgICA0NS44ODAwNDJdICBbPGMxMDQwMDdiPl0gPyBkZWxheWVkX3B1
dF90YXNrX3N0cnVjdCsweDQxLzB4NjQKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzEwMjAwZDg+XSA/
IGludGVsX3RoZXJtYWxfaW50ZXJydXB0KzB4ZmEvMHgxOGIKWyAgIDQ1Ljg4MDA0Ml0gIFs8
YzEzYjI2Mzc+XSA/IGRlbGF5X3RzYysweDUxLzB4YTcKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzEz
YjI2ZDc+XSBfX2RlbGF5KzB4ZS8weDEwClsgICA0NS44ODAwNDJdICBbPGMxM2IyNmYzPl0g
X19jb25zdF91ZGVsYXkrMHgxYS8weDFjClsgICA0NS44ODAwNDJdICBbPGMxM2IyNzA4Pl0g
X191ZGVsYXkrMHgxMy8weDE1ClsgICA0NS44ODAwNDJdICBbPGMxOWVjZjZkPl0gb24yNl93
cml0ZV9yZWdyKzB4MjIzLzB4Mzg4ClsgICA0NS44ODAwNDJdICBbPGMxOWU0ODYyPl0gcGlf
d3JpdGVfcmVncisweDExLzB4MTcKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzE5ZTQ4ZjA+XSBwaV90
ZXN0X3Byb3RvKzB4NzcvMHgxMDIKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzE5ZTQ5ZjE+XSBwaV9w
cm9iZV9tb2RlKzB4NzYvMHhhZQpbICAgNDUuODgwMDQyXSAgWzxjMTllNGIyYT5dIHBpX3By
b2JlX3VuaXQrMHgxMDEvMHgxMjYKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzE5ZTRlNGE+XSBwaV9p
bml0KzB4MTViLzB4MWRhClsgICA0NS44ODAwNDJdICBbPGMyNzY5MWY0Pl0gcGdfaW5pdCsw
eGRhLzB4MmE0ClsgICA0NS44ODAwNDJdICBbPGMyNzY5MTFhPl0gPyBwdF9pbml0KzB4MmE1
LzB4MmE1ClsgICA0NS44ODAwNDJdICBbPGMyNzE1YWFkPl0gZG9fb25lX2luaXRjYWxsKzB4
ZTQvMHgxOWIKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzEzYjM2ZTY+XSA/IHN0cmxlbisweDkvMHgx
YwpbICAgNDUuODgwMDQyXSAgWzxjMjcxNTQ0ND5dID8gZG9fZWFybHlfcGFyYW0rMHg3My8w
eDczClsgICA0NS44ODAwNDJdICBbPGMxMDU5ODViPl0gPyBwYXJzZV9hcmdzKzB4Mjk4LzB4
Mzc1ClsgICA0NS44ODAwNDJdICBbPGMyNzE1NDQ0Pl0gPyBkb19lYXJseV9wYXJhbSsweDcz
LzB4NzMKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzI3MTVjOGU+XSBrZXJuZWxfaW5pdF9mcmVlYWJs
ZSsweDEyYS8weDFhMgpbICAgNDUuODgwMDQyXSAgWzxjMjcxNWM4ZT5dID8ga2VybmVsX2lu
aXRfZnJlZWFibGUrMHgxMmEvMHgxYTIKWyAgIDQ1Ljg4MDA0Ml0gIFs8YzFkN2Y1MTI+XSBr
ZXJuZWxfaW5pdCsweGQvMHhiOQpbICAgNDUuODgwMDQyXSAgWzxjMWQ5YmU3Yj5dIHJldF9m
cm9tX2tlcm5lbF90aHJlYWQrMHgxYi8weDMwClsgICA0NS44ODAwNDJdICBbPGMxZDdmNTA1
Pl0gPyByZXN0X2luaXQrMHhiMS8weGIxClsgICA0NS44ODAwNDJdIENvZGU6IDAwIDVkIGMz
IDU1IDg5IGU1IDUwIDlkIDhkIDc0IDI2IDAwIDVkIGMzIDU1IDg5IGU1IGZhIDkwIDhkIDc0
IDI2IDAwIDVkIGMzIDhiIDBkIDJjIGRhIDUzIGMyIDU1IDg5IGU1IDhkIDg0IDA4IDAwIGMw
IGZmIGZmIDg5IDEwIDw1ZD4gYzMgNTUgODkgZTUgNTcgNTYgODkgYzYgNTMgODMgZWMgMDgg
ODMgZjggZmYgODkgNTUgZWMgNzQgNzMKWyAgIDQ1LjkwMDA1NF0gTk1JIGJhY2t0cmFjZSBm
b3IgY3B1IDAKWyAgIDQ1LjkwMDA1NF0gQ1BVOiAwIFBJRDogMCBDb21tOiBzd2FwcGVyLzAg
Tm90IHRhaW50ZWQgMy4xMS4wLTA5NDI0LWdhNWI3Yzg3ICMyNTIKWyAgIDQ1LjkwMDA1NF0g
SGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAg
NDUuOTAwMDU0XSB0YXNrOiBjMjUzMjk3OCB0aTogYzI1MjAwMDAgdGFzay50aTogYzI1MjAw
MDAKWyAgIDQ1LjkwMDA1NF0gRUlQOiAwMDYwOls8YzEwMmQ4MjU+XSBFRkxBR1M6IDAwMjAw
Mjk2IENQVTogMApbICAgNDUuOTAwMDU0XSBFSVAgaXMgYXQgbmF0aXZlX3NhZmVfaGFsdCsw
eDUvMHg3ClsgICA0NS45MDAwNTRdIEVBWDogYzI2ODc3NzggRUJYOiAwMDAwMDAwMCBFQ1g6
IDAwMDAwMDAwIEVEWDogMDAwMDAwMDAKWyAgIDQ1LjkwMDA1NF0gRVNJOiBmZmZmZmZmZiBF
REk6IDAwMDAwMDAwIEVCUDogYzI1MjFmOTQgRVNQOiBjMjUyMWY5NApbICAgNDUuOTAwMDU0
XSAgRFM6IDAwN2IgRVM6IDAwN2IgRlM6IDAwZDggR1M6IDAwZTAgU1M6IDAwNjgKWyAgIDQ1
LjkwMDA1NF0gQ1IwOiA4MDA1MDAzYiBDUjI6IDAwMDAwMDAwIENSMzogMDI5MWQwMDAgQ1I0
OiAwMDAwMDZkMApbICAgNDUuOTAwMDU0XSBTdGFjazoKWyAgIDQ1LjkwMDA1NF0gIGMyNTIx
ZjljIGMxMDA4N2Q4IGMyNTIxZmE0IGMxMDA4Y2U5IGMyNTIxZmM0IGMxMDc2ZjJlIDAwMDAw
MDAwIGM3MGU0YjM1ClsgICA0NS45MDAwNTRdICBlMWJlMmUxNyAwMDAwMDAwMiAwMDAwMDAw
MCBjMjkxZTgwMCBjMjUyMWZkMCBjMWQ3ZjUwMCAwMDAwMDAwMCBjMjUyMWZlOApbICAgNDUu
OTAwMDU0XSAgYzI3MTU5YzIgYzI3OGQwZDAgYmNjZGM3YWYgMDAwMDA4MDAgMDAwMjA4MDAg
YzI1MjFmZjggYzI3MTUyY2YgMDAwMDA4MDAKWyAgIDQ1LjkwMDA1NF0gQ2FsbCBUcmFjZToK
WyAgIDQ1LjkwMDA1NF0gIFs8YzEwMDg3ZDg+XSBkZWZhdWx0X2lkbGUrMHgxZS8weDMwClsg
ICA0NS45MDAwNTRdICBbPGMxMDA4Y2U5Pl0gYXJjaF9jcHVfaWRsZSsweDE3LzB4MjAKWyAg
IDQ1LjkwMDA1NF0gIFs8YzEwNzZmMmU+XSBjcHVfc3RhcnR1cF9lbnRyeSsweDE5Yi8weDIz
OApbICAgNDUuOTAwMDU0XSAgWzxjMWQ3ZjUwMD5dIHJlc3RfaW5pdCsweGFjLzB4YjEKWyAg
IDQ1LjkwMDA1NF0gIFs8YzI3MTU5YzI+XSBzdGFydF9rZXJuZWwrMHgzN2IvMHgzODIKWyAg
IDQ1LjkwMDA1NF0gIFs8YzI3MTUyY2Y+XSBpMzg2X3N0YXJ0X2tlcm5lbCsweDc5LzB4N2QK
WyAgIDQ1LjkwMDA1NF0gQ29kZTogMGYgMjIgZTAgNWQgYzMgNTUgODkgZTUgMGYgMDkgNWQg
YzMgNTUgODkgZTUgOWMgNTggNWQgYzMgNTUgODkgZTUgNTAgOWQgNWQgYzMgNTUgODkgZTUg
ZmEgNWQgYzMgNTUgODkgZTUgZmIgNWQgYzMgNTUgODkgZTUgZmIgZjQgPDVkPiBjMyA1NSA4
OSBlNSBmNCA1ZCBjMyA1NSA4OSBlNSA1NyA4OSBjNyA1NiA4OSBjZSA1MyA1MyA4YiAwMAov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzL2E1YjdjODdmOTIwNzYzNTJkYmZmMmZl
MDQyM2VjMjU1ZTFjOWE3MWIvZG1lc2ctcXVhbnRhbC1sa3AtdHQwMi0xMzoyMDEzMDkyNDAy
NDAzMzozLjExLjAtMDk0MjQtZ2E1YjdjODc6MjUyCgpCaXNlY3Rpbmc6IDM0NyByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKWzNkOTRlYTUx
YzFkOGRiNmY0MTI2OGE5ZDJhZWE1ZjU3NzFlOWE4ZDNdIG9jZnMyOiBjbGVhbiB1cCBkZWFk
IGNvZGUgaW4gb2NmczJfYWNsX2Zyb21feGF0dHIoKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0
cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0
CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAt
MDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjNkOTRlYTUx
YzFkOGRiNmY0MTI2OGE5ZDJhZWE1ZjU3NzFlOWE4ZDM6YmlzZWN0LW5ldAoKMjAxMy0wOS0y
NC0xMjoxODozNSAzZDk0ZWE1MWMxZDhkYjZmNDEyNjhhOWQyYWVhNWY1NzcxZTlhOGQzIGNv
bXBpbGluZwozMDIgcmVhbCAgMjQxNSB1c2VyICAyMTcgc3lzICA4NzEuMTMlIGNwdSAJaTM4
Ni1yYW5kY29uZmlnLXIwLTA5MjMKCjIwMTMtMDktMjQtMTI6MjM6NDYgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy4xMS4wLTA5MDc2LWczZDk0ZWE1Li4JMQkzCTQJNgk3Lgk5CTExCTEyCTEz
CTE2CTE4CTIxCTI0CTI2CTMwCTMyCTQzCTQ5CTU4CTYyCTY3CTcyCTgzCTkyCTEwMgkxMTEJ
MTI2CTEyOQkxMzgJMTQ4CTE1NAkxNjUJMTc3CTE4MwkxODkJMjAwCTIwOQkyMjAJMjMxCTI0
MgkyNTYJMjYyCTI3MgkyODIJMjg2CTI5NQkzMDMJMzE2CTMyNAkzMzAJMzM5CTM0NwkzNTEJ
MzYyCTM3NAkzODcJNDA2CTQxNgk0MjkJNDM3CTQ0Nwk0NTMJNDY0CTQ3NAk0NzYJNDc3Li4u
Li4JNDc4Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtbMTszNW1hZGRfdG9fcnVu
X3F1ZXVlIDE3G1swbQouLi4uLgk0NzkuLi4JNDgxLi4JNDgyLgk0ODQJNDg3CTQ5NAk0OTUg
U1VDQ0VTUwoKQmlzZWN0aW5nOiAxNzMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDggc3RlcHMpCltkNjJhMjAxZjI0Y2JhNzRlMmZiZjlmNmY3YWY4NmZm
NWY1ZTI3NmZjXSBjaGVja3BhdGNoOiBlbmZvcmNlIHNhbmUgcGVybCB2ZXJzaW9uCnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93
ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4LWRldmVsOmRldmVsLXJvYW0taTM4Ni0yMDEz
MDkyMzE4MDc6ZDYyYTIwMWYyNGNiYTc0ZTJmYmY5ZjZmN2FmODZmZjVmNWUyNzZmYzpiaXNl
Y3QtbmV0CgoyMDEzLTA5LTI0LTE1OjQwOjUyIGQ2MmEyMDFmMjRjYmE3NGUyZmJmOWY2Zjdh
Zjg2ZmY1ZjVlMjc2ZmMgY29tcGlsaW5nCjM5NCByZWFsICAyMzg4IHVzZXIgIDIwOCBzeXMg
IDY1OC4yMyUgY3B1IAlpMzg2LXJhbmRjb25maWctcjAtMDkyMwoKMjAxMy0wOS0yNC0xNTo0
NzozOCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDkyNTAtZ2Q2MmEyMDEuLi4uLi4u
Li4JMS4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCTIuLi4uLi4uLi4uCTQuLgk1Li4JNi4u
Lgk4CTkuLi4uLi4uLi4uLi4uLi4uLi4uLgkxMAkxMi4JMTQJMTUuLi4uLi4JMTYuCTE3CTE4
CTIxLi4uLi4JMjIuLgkyMy4JMjQuCTI2CTI5CTMwCTM0CTM2CTM5Lgk0OQk1OQk2Ngk3OSBU
RVNUIEZBSUxVUkUKG1sxOzM1bUluY3JlYXNpbmcgcmVwZWF0IGNvdW50IGZyb20gNDk1IHRv
IDU4NRtbMG0KQlVHOiBrZXJuZWwgZWFybHkgaGFuZyB3aXRob3V0IGFueSBwcmludGsgb3V0
cHV0CkNvbW1hbmQgbGluZTogaHVuZ190YXNrX3BhbmljPTEgcmN1dHJlZS5yY3VfY3B1X3N0
YWxsX3RpbWVvdXQ9MTAwIGxvZ19idWZfbGVuPThNIGlnbm9yZV9sb2dsZXZlbCBkZWJ1ZyBz
Y2hlZF9kZWJ1ZyBkeW5hbWljX3ByaW50ayBzeXNycV9hbHdheXNfZW5hYmxlZCBwYW5pYz0x
MCAgcHJvbXB0X3JhbWRpc2s9MCBjb25zb2xlPXR0eVMwLDExNTIwMCBjb25zb2xlPXR0eTAg
dmdhPW5vcm1hbCAgcm9vdD0vZGV2L3JhbTAgcncgbGluaz0va2VybmVsLXRlc3RzL3J1bi1x
dWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwtcm9h
bS1pMzg2LTIwMTMwOTIzMTgwNzpkNjJhMjAxZjI0Y2JhNzRlMmZiZjlmNmY3YWY4NmZmNWY1
ZTI3NmZjOmJpc2VjdC1uZXQvLnZtbGludXotZDYyYTIwMWYyNGNiYTc0ZTJmYmY5ZjZmN2Fm
ODZmZjVmNWUyNzZmYy0yMDEzMDkyNDE1NDczNi0yNzItYW50IGJyYW5jaD1saW51eC1kZXZl
bC9kZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3IEJPT1RfSU1BR0U9L2tlcm5lbC9pMzg2
LXJhbmRjb25maWctcjAtMDkyMy9kNjJhMjAxZjI0Y2JhNzRlMmZiZjlmNmY3YWY4NmZmNWY1
ZTI3NmZjL3ZtbGludXotMy4xMS4wLTA5MjUwLWdkNjJhMjAxIG5vYXBpYyBub2xhcGljIG5v
aHo9b2ZmCkVhcmx5IGhhbmcga2VybmVsOiB2bWxpbnV6LTMuMTEuMC0wOTI1MC1nZDYyYTIw
MSAzLjExLjAtMDkyNTAtZ2Q2MmEyMDEgIzI1NAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1y
MC0wOTIzL2Q2MmEyMDFmMjRjYmE3NGUyZmJmOWY2ZjdhZjg2ZmY1ZjVlMjc2ZmMvZG1lc2ct
cXVhbnRhbC1sa3AtdHQwMi0yMToyMDEzMDkyNDA3MDg0MTozLjExLjAtMDkyNTAtZ2Q2MmEy
MDE6MjU0CgpCaXNlY3Rpbmc6IDg2IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSA3IHN0ZXBzKQpbODM0NjdlZmJkYjc5NDgxNDY1ODFhNTZjYmQ2ODNhMjJh
MDY4NGJiYl0gbW06IG1pZ3JhdGU6IGNoZWNrIG1vdmFiaWxpdHkgb2YgaHVnZXBhZ2UgaW4g
dW5tYXBfYW5kX21vdmVfaHVnZV9wYWdlKCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlz
ZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAt
YSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMv
bGludXgtZGV2ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzo4MzQ2N2VmYmRiNzk0
ODE0NjU4MWE1NmNiZDY4M2EyMmEwNjg0YmJiOmJpc2VjdC1uZXQKCjIwMTMtMDktMjQtMTY6
NDY6NDAgODM0NjdlZmJkYjc5NDgxNDY1ODFhNTZjYmQ2ODNhMjJhMDY4NGJiYiBjb21waWxp
bmcKMzIyIHJlYWwgIDI0MjkgdXNlciAgMjA0IHN5cyAgODE3LjI3JSBjcHUgCWkzODYtcmFu
ZGNvbmZpZy1yMC0wOTIzCgoyMDEzLTA5LTI0LTE2OjUyOjE0IGRldGVjdGluZyBib290IHN0
YXRlIDMuMTEuMC0wOTE2My1nODM0NjdlZi4uCTEuCTMJNwk5CTEyCTE0CTIxCTIyLgkyOAkz
MgkzNgkzOQk0MAk0MQk0Mgk0NAk0NS4JNDYuLi4JNDkJNTAuCTU0Lgk1NS4JNTkJNjIuCTYz
CTY2CTY3CTc0Li4JODAJODQJODUJODYJODgJODkJOTcJMTAyCTEwMwkxMDcJMTA5CTExMS4J
MTE0Li4JMTE1CTExNy4JMTE5CTEyMi4uLi4JMTI2CTEyOQkxMzEJMTMyCTEzNAkxNDEJMTQ1
CTE0NwkxNTYJMTY0CTE3MAkxNzQJMTc5CTE4OQkxOTQJMjAxCTIwMwkyMTIJMjE0CTIxOS4J
MjIyCTIyOQkyMzUJMjQwCTI0MwkyNDQJMjQ2CTI0OAkyNTEuLgkyNTQJMjU3CTI1OAkyNTku
CTI2MAkyNjEJMjYyCTI2NAkyNjcJMjcxCTI3MgkyNzQuCTI3NgkyNzcuCTI4MwkyODQuCTI4
NQkyODcuCTI4OAkyODkJMjkwLi4JMjkzCTI5NAkyOTYJMjk5LgkzMDMuCTMwNC4uLgkzMDUJ
MzA3Li4uLgkzMDgJMzA5CTMxMC4JMzExCTMxMy4JMzE3CTMyMgkzMjkJMzM0CTMzNwkzMzkJ
MzQxCTM0MgkzNDcuCTM0OC4uLi4JMzQ5CTM1MQkzNTQJMzU3LgkzNTkJMzYwLgkzNjEuCTM2
MgkzNjUJMzY3CTM3MAkzNzgJMzg0CTM4NwkzOTIJMzk3CTQwNAk0MTEJNDE2CTQxOQk0MjEu
CTQyNi4JNDI5CTQzMQk0MzIJNDMzCTQzNS4JNDM2CTQzNy4JNDQxLgk0NDMuLgk0NDQJNDQ5
CTQ1MAk0NTIJNDUzCTQ2MQk0NjcJNDc1CTQ4MAk0ODgJNDk4CTUwMwk1MDQJNTA3CTUxMQk1
MTcJNTIxCTUyNAk1MjYuCTUyOAk1MzEJNTM0CTUzOAk1NDIJNTQzCTU0NAk1NDYJNTQ4CTU1
MAk1NTEJNTUyCTU1NQk1NTcuCTU1OC4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCTU1OS4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAyNhtbMG0KLi4uLi4JNTYwLgk1
NjEJNTYyLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgk1NjMuLi4uLi4u
CTU2NS4uLgk1NjYuLgk1NjcuLi4uLi4uLi4uCTU2OS4JNTcxCTU3Mi4uLi4JNTczCTU3NC4u
Li4uCTU3NS4uLi4uLgk1NzYuCTU3Nwk1NzkJNTgxLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLhtbMTszNW1hZGRfdG9fcnVuX3F1ZXVlIDQbWzBtCi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uCTU4My4JNTg1IFNVQ0NFU1MKCkJpc2VjdGluZzogNDIgcmV2aXNpb25zIGxlZnQg
dG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDYgc3RlcHMpClsyYmZmMjRhMzcwNzA5M2M0
MzVhYjMyNDFjNDdkY2RiNWYxNmU0MzJiXSBtZW1jZzogZml4IG11bHRpcGxlIGxhcmdlIHRo
cmVzaG9sZCBub3RpZmljYXRpb25zCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tl
cm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4
LWRldmVsOmRldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDc6MmJmZjI0YTM3MDcwOTNjNDM1
YWIzMjQxYzQ3ZGNkYjVmMTZlNDMyYjpiaXNlY3QtbmV0CgoyMDEzLTA5LTI1LTAxOjI5OjU1
IDJiZmYyNGEzNzA3MDkzYzQzNWFiMzI0MWM0N2RjZGI1ZjE2ZTQzMmIgY29tcGlsaW5nCjYz
MiByZWFsICAyNTA2IHVzZXIgIDE5OCBzeXMgIDQyNy40OSUgY3B1IAlpMzg2LXJhbmRjb25m
aWctcjAtMDkyMwoKMjAxMy0wOS0yNS0wMTo0NTo0MSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAz
LjExLjAtMDkyMDctZzJiZmYyNGEuLi4uLgkxLgkyCTMuLgk0Li4uCTcJMTAJMTEJMTIJMTUu
CTE4Li4JMTkJMjAJMjQJMzAJMzgJNTIJNTQJNjMJNjcJNzEuLi4JNzMJNzYJNzcuLgkxMjkJ
MTQ4IFRFU1QgRkFJTFVSRQobWzE7MzVtSW5jcmVhc2luZyByZXBlYXQgY291bnQgZnJvbSA1
ODUgdG8gMTE3MBtbMG0KQlVHOiBrZXJuZWwgZWFybHkgaGFuZyB3aXRob3V0IGFueSBwcmlu
dGsgb3V0cHV0CkNvbW1hbmQgbGluZTogaHVuZ190YXNrX3BhbmljPTEgcmN1dHJlZS5yY3Vf
Y3B1X3N0YWxsX3RpbWVvdXQ9MTAwIGxvZ19idWZfbGVuPThNIGlnbm9yZV9sb2dsZXZlbCBk
ZWJ1ZyBzY2hlZF9kZWJ1ZyBkeW5hbWljX3ByaW50ayBzeXNycV9hbHdheXNfZW5hYmxlZCBw
YW5pYz0xMCAgcHJvbXB0X3JhbWRpc2s9MCBjb25zb2xlPXR0eVMwLDExNTIwMCBjb25zb2xl
PXR0eTAgdmdhPW5vcm1hbCAgcm9vdD0vZGV2L3JhbTAgcncgbGluaz0va2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2
ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzoyYmZmMjRhMzcwNzA5M2M0MzVhYjMyNDFjNDdk
Y2RiNWYxNmU0MzJiOmJpc2VjdC1uZXQvLnZtbGludXotMmJmZjI0YTM3MDcwOTNjNDM1YWIz
MjQxYzQ3ZGNkYjVmMTZlNDMyYi0yMDEzMDkyNTAxNDUwNC02NS1hbnQgYnJhbmNoPWxpbnV4
LWRldmVsL2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFHRT0va2VybmVs
L2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzLzJiZmYyNGEzNzA3MDkzYzQzNWFiMzI0MWM0N2Rj
ZGI1ZjE2ZTQzMmIvdm1saW51ei0zLjExLjAtMDkyMDctZzJiZmYyNGEgbm9hcGljIG5vbGFw
aWMgbm9oej1vZmYKRWFybHkgaGFuZyBrZXJuZWw6IHZtbGludXotMy4xMS4wLTA5MjA3LWcy
YmZmMjRhIDMuMTEuMC0wOTIwNy1nMmJmZjI0YSAjMjU2Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLXIwLTA5MjMvMmJmZjI0YTM3MDcwOTNjNDM1YWIzMjQxYzQ3ZGNkYjVmMTZlNDMyYi9k
bWVzZy1xdWFudGFsLWxrcC10dDAyLTIzOjIwMTMwOTI0MTYyNzMzOjMuMTEuMC0wOTIwNy1n
MmJmZjI0YToyNTYKCkJpc2VjdGluZzogMjEgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRl
ciB0aGlzIChyb3VnaGx5IDUgc3RlcHMpClsxZWNmZDUzM2Y0YzUyOGIwYjRjYzViYzExNWM0
YzQ3ZjBiNWU0ODI4XSBtbS9tcmVtYXAuYzogY2FsbCBwdWRfZnJlZSgpIGFmdGVyIGZhaWwg
Y2FsbGluZyBwbWRfYWxsb2MoKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVz
dC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJu
ZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDkyMy9saW51eC1k
ZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjFlY2ZkNTMzZjRjNTI4YjBiNGNj
NWJjMTE1YzRjNDdmMGI1ZTQ4Mjg6YmlzZWN0LW5ldAoKMjAxMy0wOS0yNS0wMjowNzo1MSAx
ZWNmZDUzM2Y0YzUyOGIwYjRjYzViYzExNWM0YzQ3ZjBiNWU0ODI4IGNvbXBpbGluZwo5NzQg
cmVhbCAgMjQ5MiB1c2VyICAxOTcgc3lzICAyNzYuMTMlIGNwdSAJaTM4Ni1yYW5kY29uZmln
LXIwLTA5MjMKCjIwMTMtMDktMjUtMDI6MjQ6MzQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4x
MS4wLTA5MTg1LWcxZWNmZDUzLi4JMS4JNAk1CTcJMTYJMTgJMTkJMjAuCTI2CTM1CTM3CTQ2
CTUyCTU2CTY0IFRFU1QgRkFJTFVSRQpCVUc6IGtlcm5lbCBlYXJseSBoYW5nIHdpdGhvdXQg
YW55IHByaW50ayBvdXRwdXQKQ29tbWFuZCBsaW5lOiBodW5nX3Rhc2tfcGFuaWM9MSByY3V0
cmVlLnJjdV9jcHVfc3RhbGxfdGltZW91dD0xMDAgbG9nX2J1Zl9sZW49OE0gaWdub3JlX2xv
Z2xldmVsIGRlYnVnIHNjaGVkX2RlYnVnIGR5bmFtaWNfcHJpbnRrIHN5c3JxX2Fsd2F5c19l
bmFibGVkIHBhbmljPTEwICBwcm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAw
IGNvbnNvbGU9dHR5MCB2Z2E9bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rZXJu
ZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDkyMy9saW51eC1k
ZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjFlY2ZkNTMzZjRjNTI4YjBiNGNj
NWJjMTE1YzRjNDdmMGI1ZTQ4Mjg6YmlzZWN0LW5ldC8udm1saW51ei0xZWNmZDUzM2Y0YzUy
OGIwYjRjYzViYzExNWM0YzQ3ZjBiNWU0ODI4LTIwMTMwOTI1MDIyNDI0LTcyNS1hbnQgYnJh
bmNoPWxpbnV4LWRldmVsL2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFH
RT0va2VybmVsL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzLzFlY2ZkNTMzZjRjNTI4YjBiNGNj
NWJjMTE1YzRjNDdmMGI1ZTQ4Mjgvdm1saW51ei0zLjExLjAtMDkxODUtZzFlY2ZkNTMgbm9h
cGljIG5vbGFwaWMgbm9oej1vZmYKRWFybHkgaGFuZyBrZXJuZWw6IHZtbGludXotMy4xMS4w
LTA5MTg1LWcxZWNmZDUzIDMuMTEuMC0wOTE4NS1nMWVjZmQ1MyAjMjU3Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLXIwLTA5MjMvMWVjZmQ1MzNmNGM1MjhiMGI0Y2M1YmMxMTVjNGM0N2Yw
YjVlNDgyOC9kbWVzZy1xdWFudGFsLXhwcy00OjIwMTMwOTI1MDIzMzQ0OjMuMTEuMC0wOTE4
NS1nMWVjZmQ1MzoyNTcKCkJpc2VjdGluZzogMTAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBh
ZnRlciB0aGlzIChyb3VnaGx5IDQgc3RlcHMpClswZWMzYjc0YzdmNTU5OWM4YTRkMmIzM2Q0
MzBhNTQ3MGFmMjZlYmY2XSBtbTogcHV0YmFja19scnVfcGFnZTogcmVtb3ZlIHVubmVjZXNz
YXJ5IGNhbGwgdG8gcGFnZV9scnVfYmFzZV90eXBlKCkKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2Vj
dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIw
LTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzowZWMzYjc0
YzdmNTU5OWM4YTRkMmIzM2Q0MzBhNTQ3MGFmMjZlYmY2OmJpc2VjdC1uZXQKCjIwMTMtMDkt
MjUtMDI6MzQ6MTYgMGVjM2I3NGM3ZjU1OTljOGE0ZDJiMzNkNDMwYTU0NzBhZjI2ZWJmNiBj
b21waWxpbmcKNjk0IHJlYWwgIDI0NzggdXNlciAgMTk1IHN5cyAgMzg1LjE5JSBjcHUgCWkz
ODYtcmFuZGNvbmZpZy1yMC0wOTIzCgoyMDEzLTA5LTI1LTAyOjUwOjI0IGRldGVjdGluZyBi
b290IHN0YXRlIDMuMTEuMC0wOTE3NC1nMGVjM2I3NAkzCTQJOAkxMgkyNQkzMAk0Mwk0OAk1
NQk2MS4JNjMuCTY1Li4JNzUJODMJODYJOTEJOTMJOTUJOTcuCTEwOAkxMTkJMTMwCTEzOAkx
NDAuLi4uLgkxNDIJMTQzCTE1NwkxNjUJMTcwCTE3MS4JMTcyLi4JMTc5CTE4NgkxOTgJMjAy
CTIxMgkyMjUJMjM1CTI0MC4JMjQzCTI0NQkyNTMJMjU2LgkyNjUJMjcwCTI3NAkyNzgJMjc5
CTI4MAkyODEJMjg0LgkyODUJMjg2Li4JMjg3CTI4OAkyODkJMjkxLi4uCTI5NwkzMDAJMzAx
CTMwMgkzMDMuCTMwNgkzMDcJMzA5CTMxMi4uCTMxMwkzMTQJMzE1Li4uLi4uLi4uLi4uLi4u
CTMxNi4uLi4JMzE3Li4uLi4uLi4uLi4uCTMxOAkzMTkuLi4JMzIwLgkzMjEuLgkzMjIuLgkz
MjUuLgkzMjcuLi4uLi4JMzI4Li4uLgkzMjkuLi4uLi4uLi4JMzMwCTMzNAkzMzUJMzM4Li4u
CTM0MAkzNDUuCTM0NgkzNDcuCTM0OQkzNTAuCTM1MgkzNTMuLi4uLi4uLgkzNTUJMzU2Li4u
Li4uCTM1OQkzNjIuLi4uLgkzNjQuCTM2NQkzNjYuLi4uCTM2NwkzNjguCTM2OS4JMzcwLgkz
NzIuCTM3NAkzNzUuLgkzNzguLi4uCTM4MgkzODMuLi4uCTM4NgkzODcJMzg4Li4JMzg5Lgkz
OTAJMzkzCTM5NC4uCTM5NQkzOTYJMzk3LgkzOTguCTM5OS4JNDAwLgk0MDEuCTQwMgk0MDMu
Li4uCTQwNC4uLi4JNDA1Li4uLi4uLi4JNDA2CTQwOC4JNDEwLgk0MTEJNDE0Li4JNDE1Li4u
Li4uLi4JNDE2Lgk0MTguCTQxOS4JNDIwLi4JNDIzCTQyNC4JNDI1CTQyOAk0MzYJNDQ2CTQ1
MC4JNDUyCTQ1My4JNDU0CTQ1NQk0NTYJNDU3CTQ1OQk0NjAJNDYyLi4JNDY0CTQ3MAk0NzQJ
NDc5CTQ4MC4uCTQ4Mwk0ODgJNDk1CTUwMgk1MTEJNTE0CTUxNQk1MTYJNTE4CTUyMAk1MjEJ
NTI1CTUyOAk1NDAJNTQ1CTU1MAk1NTcJNTcxCTU3Nwk1ODgJNTk1CTYwNQk2MTAJNjI2CTYz
MQk2MzIJNjQwCTY0Ngk2NTYJNjYxCTY2Mgk2NjgJNjcxCTY3NAk2ODIJNjg0CTY5Mgk2OTcJ
NzAzCTcwOAk3MTEJNzIxCTczMwk3NDIJNzQ2Lgk3NTAJNzU1Li4JNzU2Li4uLi4uCTc2NQk3
NzkJNzkyCTc5OQk4MDQuLi4uCTgwNQk4MTMJODQ0CTg3OQk4OTMuCTg5Ngk5MDEJMTAxNQkx
MDMwCTEwNTkJMTA3MwkxMDc3CTEwODMJMTA5MgkxMDk1CTExMDIJMTEwNy4uCTExMDguLi4J
MTExMQkxMTEyLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLgkxMTEzLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtb
MTszNW1hZGRfdG9fcnVuX3F1ZXVlIDU3G1swbQouLgkxMTE0Li4uLi4uCTExMTYuCTExMTcJ
MTExOQkxMTIwCTExMjEuCTExMjIuCTExMjMuCTExMjQuLi4JMTEyNS4uLgkxMTI2Li4JMTEy
Ny4JMTEyOC4uCTExMzAuLgkxMTMxLgkxMTM1CTExMzYJMTEzOAkxMTM5CTExNDAuCTExNDEu
CTExNDMuCTExNDQuLi4JMTE0NwkxMTQ5CTExNTAJMTE1MQkxMTUzCTExNTgJMTE1OS4JMTE2
MQkxMTYyLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkxMTYzCTExNjQuLgkx
MTY2CTExNjcJMTE2OAkxMTY5CTExNzAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA1IHJldmlzaW9u
cyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbNWI0MDk5OGFl
MzVjZjY0NTYxODY4MzcwZTZjOWYzZDNlOTRiNmJmN10gbW06IG11bmxvY2s6IHJlbW92ZSBy
ZWR1bmRhbnQgZ2V0X3BhZ2UvcHV0X3BhZ2UgcGFpciBvbiB0aGUgZmFzdCBwYXRoCnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93
ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4LWRldmVsOmRldmVsLXJvYW0taTM4Ni0yMDEz
MDkyMzE4MDc6NWI0MDk5OGFlMzVjZjY0NTYxODY4MzcwZTZjOWYzZDNlOTRiNmJmNzpiaXNl
Y3QtbmV0CgoyMDEzLTA5LTI1LTEzOjEwOjQ4IDViNDA5OThhZTM1Y2Y2NDU2MTg2ODM3MGU2
YzlmM2QzZTk0YjZiZjcgY29tcGlsaW5nCjE3NCByZWFsICA3OCB1c2VyICAxNCBzeXMgIDUz
LjEzJSBjcHUgCWkzODYtcmFuZGNvbmZpZy1yMC0wOTIzCgoyMDEzLTA5LTI1LTEzOjE0OjEx
IGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wOTE3OS1nNWI0MDk5OC4uLgkxCTIJNQkx
MAkxNQkyNAkzMQkzNAk1Mgk2MAk3Mgk4OQkxMTAJMTE1CTEyOAkxNDIJMTU1CTE2OAkxOTQJ
MTk4CTIxMQkyMjgJMjQ3CTI2NQkyODkJMzA2CTMxNwkzNDQJMzU2CTM2OQkzODgJNDAwCTQy
OAk0NDgJNDY0CTQ3Nwk0ODUJNDk2CTUyNAk1MzEJNTM1CTUzNgk1MzcuLi4uCTUzOC4JNTM5
Lgk1NDAuCTU0Mgk1NDUuCTU0Ngk1NDcuCTU0OC4JNTUxLgk1NTYJNTU4CTU2Mgk1NjQJNTY2
CTU2OQk1NzQJNTgyCTU5Nwk2MDkJNjEyCTYyMwk2MzgJNjQ1CTY1OAk2NzMJNjgzCTcwNgk3
MjIJNzI4CTc1NQk3NzgJNzk2CTgxNQk4MzAJODM4CTg2Mi4JODY5CTg4Mwk4OTAJODk3Lgk5
MDYJOTIwCTkyMS4uCTkyMi4JMTAxMAkxMDQwCTEwNTYJMTA3MQkxMDg2CTExMDUJMTEwNgkx
MTIwLi4JMTEyMi4uCTExMjMuCTExMjQuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
G1sxOzM1bWFkZF90b19ydW5fcXVldWUgNDYbWzBtCi4uLi4uLgkxMTI1CTExNTIJMTE1Ngkx
MTY1CTExNzAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3Qg
YWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbMTg3MzIwOTMyZGNlY2U5YzRiOTNmMzhm
NTZkMWY4ODhiZDVjMzI1Zl0gbW0vc3BhcnNlOiBpbnRyb2R1Y2UgYWxsb2NfdXNlbWFwX2Fu
ZF9tZW1tYXAKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1
bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwt
cm9hbS1pMzg2LTIwMTMwOTIzMTgwNzoxODczMjA5MzJkY2VjZTljNGI5M2YzOGY1NmQxZjg4
OGJkNWMzMjVmOmJpc2VjdC1uZXQKCjIwMTMtMDktMjUtMTY6NTI6MzAgMTg3MzIwOTMyZGNl
Y2U5YzRiOTNmMzhmNTZkMWY4ODhiZDVjMzI1ZiBjb21waWxpbmcKMzc2IHJlYWwgIDI0NDMg
dXNlciAgMjA2IHN5cyAgNzAzLjcwJSBjcHUgCWkzODYtcmFuZGNvbmZpZy1yMC0wOTIzCgoy
MDEzLTA5LTI1LTE3OjAwOjUyIGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wOTE4Mi1n
MTg3MzIwOS4uLi4uLi4uLi4uLi4uLi4uLi4uLiBURVNUIEZBSUxVUkUKWyAgIDg1LjQ3NTQ3
OV0gaW5pdDogaHdjbG9jay1zYXZlIG1haW4gcHJvY2VzcyAoMzU1NCkgdGVybWluYXRlZCB3
aXRoIHN0YXR1cyA3MApbICAgODUuNDc3NjQyXSBpbml0OiBwbHltb3V0aC11cHN0YXJ0LWJy
aWRnZSBtYWluIHByb2Nlc3MgKDM1NTUpIHRlcm1pbmF0ZWQgd2l0aCBzdGF0dXMgMQpbICAg
OTQuNjkxMDg2XSBCVUc6IEJhZCBwYWdlIG1hcCBpbiBwcm9jZXNzIGtpbGxhbGw1ICBwdGU6
OThkNjQxZTUgcG1kOjBmMjJjMDY3ClsgICA5NC42OTI2NzRdIGFkZHI6YmZjMDAwMDAgdm1f
ZmxhZ3M6MDAxMDAxNzMgYW5vbl92bWE6Y2Y3MDE3YjAgbWFwcGluZzogIChudWxsKSBpbmRl
eDpiZmZlMgpbICAgOTQuNjk0NjcwXSBDUFU6IDAgUElEOiAzNTgwIENvbW06IGtpbGxhbGw1
IE5vdCB0YWludGVkIDMuMTEuMC0wOTE4Mi1nMTg3MzIwOSAjMjYwClsgICA5NC42OTY1NDBd
IEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAg
IDk0LjY5Nzg2OF0gIDAwMDAwMDAwIDAwMDAwMDAwIGNmMWI3ZTM0IGMxZDc1ZjBjIDAwMDAw
MDAwIGNmMWI3ZTU0IGMxMGU2OWNkIDAwMGJmZmUyClsgICA5NC43MDA2ODldICAwMDAwMDAw
MCBiZmMwMDAwMCAwMDAwMDAwMSAwMDA5OGQ2NCA5OGQ2NDFlNSBjZjFiN2U3NCBjMTBlNzQ1
YSAwMDAwMDAwMApbICAgOTQuNzAzNDYzXSAgYmZjMDAwMDAgY2YxZGNiMzAgYmZjMDAwMDAg
Y2Y3NmQwMDAgY2YxZGNiMzAgY2YxYjdlZTAgYzEwZWIzYmYgY2U3MzgzYTAKWyAgIDk0Ljcw
NjI0MV0gQ2FsbCBUcmFjZToKWyAgIDk0LjcwNzA0MF0gIFs8YzFkNzVmMGM+XSBkdW1wX3N0
YWNrKzB4NGIvMHg2NgpbICAgOTQuNzA4MTY4XSAgWzxjMTBlNjljZD5dIHByaW50X2JhZF9w
dGUrMHgxNGIvMHgxNjIKWyAgIDk0LjcwOTM0OF0gIFs8YzEwZTc0NWE+XSB2bV9ub3JtYWxf
cGFnZSsweDY3LzB4OWIKWyAgIDk0LjcxMDUzMV0gIFs8YzEwZWIzYmY+XSBtdW5sb2NrX3Zt
YV9wYWdlc19yYW5nZSsweGY5LzB4MTc2ClsgICA5NC43MTE4NTBdICBbPGMxMGVkOGY5Pl0g
ZXhpdF9tbWFwKzB4ODYvMHhmNwpbICAgOTQuNzEyOTQ5XSAgWzxjMTA2OTU2Nj5dID8gbG9j
YWxfY2xvY2srMHgyNy8weDMzClsgICA5NC43MTQxMDNdICBbPGMxMDY4NDg3Pl0gPyBfX21p
Z2h0X3NsZWVwKzB4MzgvMHhkYwpbICAgOTQuNzE1Mjg2XSAgWzxjMTAzZDRiMD5dIG1tcHV0
KzB4NmEvMHhjYgpbICAgOTQuNzE2MzE4XSAgWzxjMTA0MTQxYT5dIGRvX2V4aXQrMHgzNjIv
MHg4YmUKWyAgIDk0LjcxNzQxNV0gIFs8YzEwNWQyNmE+XSA/IGhydGltZXJfZGVidWdfaGlu
dCsweGQvMHhkClsgICA5NC43MTg2NDJdICBbPGMxMDQxOWY4Pl0gZG9fZ3JvdXBfZXhpdCsw
eDUxLzB4OWUKWyAgIDk0LjcxOTc4NF0gIFs8YzEwNDFhNWI+XSBTeVNfZXhpdF9ncm91cCsw
eDE2LzB4MTYKWyAgIDk0LjcyMDk3N10gIFs8YzFkODVkZDk+XSBzeXNlbnRlcl9kb19jYWxs
KzB4MTIvMHgzMwpbICAgOTQuNzIyMTY5XSBEaXNhYmxpbmcgbG9jayBkZWJ1Z2dpbmcgZHVl
IHRvIGtlcm5lbCB0YWludApbICAgOTUuMDU3MTQ3XSBVbnJlZ2lzdGVyIHB2IHNoYXJlZCBt
ZW1vcnkgZm9yIGNwdSAxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvMTg3MzIw
OTMyZGNlY2U5YzRiOTNmMzhmNTZkMWY4ODhiZDVjMzI1Zi9kbWVzZy1xdWFudGFsLWJheS00
OjIwMTMwOTI1MTcxMDU1OjMuMTEuMC0wOTE4Mi1nMTg3MzIwOToyNjAKCkJpc2VjdGluZzog
MCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMSBzdGVwKQpb
NmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZF0gbW06IHZtc2Nhbjog
Zml4IGRvX3RyeV90b19mcmVlX3BhZ2VzKCkgbGl2ZWxvY2sKcnVubmluZyAvYy9rZXJuZWwt
dGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJp
c2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmln
LXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzo2ZTU0
M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkOmJpc2VjdC1uZXQKCjIwMTMt
MDktMjUtMTc6MTE6MjggNmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdl
ZCBjb21waWxpbmcKNzAgcmVhbCAgNzggdXNlciAgMTIgc3lzICAxMjkuMDklIGNwdSAJaTM4
Ni1yYW5kY29uZmlnLXIwLTA5MjMKCjIwMTMtMDktMjUtMTc6MTM6MjMgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy4xMS4wLTA5MTgxLWc2ZTU0M2Q1Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4J
MS4uLi4uCTIuIFRFU1QgRkFJTFVSRQpbICAgOTAuNjM5ODYzXSBpbml0OiB0dHk2IG1haW4g
cHJvY2VzcyAoMzUxOSkga2lsbGVkIGJ5IFRFUk0gc2lnbmFsClsgICA5MC42NDQyMTFdIGlu
aXQ6IGh3Y2xvY2stc2F2ZSBtYWluIHByb2Nlc3MgKDM1NDYpIHRlcm1pbmF0ZWQgd2l0aCBz
dGF0dXMgNzAKWyAgMTAwLjQ5MDM2MV0gQlVHOiBCYWQgcGFnZSBtYXAgaW4gcHJvY2VzcyBr
aWxsYWxsNSAgcHRlOjA3MjAwNzIwIHBtZDowZjZlODA2NwpbICAxMDAuNDkyNjg4XSBhZGRy
OjA5NDAwMDAwIHZtX2ZsYWdzOjAwMTAwMDczIGFub25fdm1hOmNlZTBhODkwIG1hcHBpbmc6
ICAobnVsbCkgaW5kZXg6OTQwMApbICAxMDAuNDk1NTEzXSBDUFU6IDAgUElEOiAzNTcyIENv
bW06IGtpbGxhbGw1IE5vdCB0YWludGVkIDMuMTEuMC0wOTE4MS1nNmU1NDNkNSAjMjYxClsg
IDEwMC40OTgyMzhdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAx
LzAxLzIwMTEKWyAgMTAwLjUwMDI1NV0gIDAwMDAwMDAwIDAwMDAwMDAwIGNlZTZmZTM0IGMx
ZDc1ZjBjIDAwMDAwMDAwIGNlZTZmZTU0IGMxMGU2OWNkIDAwMDA5NDAwClsgIDEwMC41MDQy
NTJdICAwMDAwMDAwMCAwOTQwMDAwMCAwMDAwMDAwMCAwMDAwNzIwMCAwNzIwMDcyMCBjZWU2
ZmU3NCBjMTBlNzQ1YSAwMDAwMDAwMApbICAxMDAuNTA4MjY2XSAgMDk0MDAwMDAgY2VkZjYx
MjAgMDk0MDAwMDAgY2VlOTMwMDAgY2VkZjYxMjAgY2VlNmZlZTAgYzEwZWIzYmYgY2U1OGUw
YTAKWyAgMTAwLjUxMjQxMl0gQ2FsbCBUcmFjZToKWyAgMTAwLjUxMzUwOV0gIFs8YzFkNzVm
MGM+XSBkdW1wX3N0YWNrKzB4NGIvMHg2NgpbICAxMDAuNTE1MTAyXSAgWzxjMTBlNjljZD5d
IHByaW50X2JhZF9wdGUrMHgxNGIvMHgxNjIKWyAgMTAwLjUxNjgwOV0gIFs8YzEwZTc0NWE+
XSB2bV9ub3JtYWxfcGFnZSsweDY3LzB4OWIKWyAgMTAwLjUxODQ1NF0gIFs8YzEwZWIzYmY+
XSBtdW5sb2NrX3ZtYV9wYWdlc19yYW5nZSsweGY5LzB4MTc2ClsgIDEwMC41MjA0MjZdICBb
PGMxMDY5NDAxPl0gPyBzY2hlZF9jbG9ja19jcHUrMHgxODIvMHgxOGEKWyAgMTAwLjUyMjIx
NV0gIFs8YzEwZWQ4Zjk+XSBleGl0X21tYXArMHg4Ni8weGY3ClsgIDEwMC41MjM3ODNdICBb
PGMxMDY5NTY2Pl0gPyBsb2NhbF9jbG9jaysweDI3LzB4MzMKWyAgMTAwLjUyNTQwOF0gIFs8
YzEwNjg0ODc+XSA/IF9fbWlnaHRfc2xlZXArMHgzOC8weGRjClsgIDEwMC41MjcxMTBdICBb
PGMxMDNkNGIwPl0gbW1wdXQrMHg2YS8weGNiClsgIDEwMC41Mjg1OTZdICBbPGMxMDQxNDFh
Pl0gZG9fZXhpdCsweDM2Mi8weDhiZQpbICAxMDAuNTMwMjQwXSAgWzxjMTA1ZDI2YT5dID8g
aHJ0aW1lcl9kZWJ1Z19oaW50KzB4ZC8weGQKWyAgMTAwLjUzMTk5M10gIFs8YzEwNDE5Zjg+
XSBkb19ncm91cF9leGl0KzB4NTEvMHg5ZQpbICAxMDAuNTMzNjUxXSAgWzxjMTA0MWE1Yj5d
IFN5U19leGl0X2dyb3VwKzB4MTYvMHgxNgpbICAxMDAuNTM1Mjk5XSAgWzxjMWQ4NWRkOT5d
IHN5c2VudGVyX2RvX2NhbGwrMHgxMi8weDMzClsgIDEwMC41MzcwMjddIERpc2FibGluZyBs
b2NrIGRlYnVnZ2luZyBkdWUgdG8ga2VybmVsIHRhaW50ClsgIDEwMS4yODI0MTZdIFVucmVn
aXN0ZXIgcHYgc2hhcmVkIG1lbW9yeSBmb3IgY3B1IDAKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctcjAtMDkyMy82ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkL2Rt
ZXNnLXF1YW50YWwtbGtwLXR0MDItNToyMDEzMDkyNTA3NDg0OTozLjExLjAtMDkxODEtZzZl
NTQzZDU6MjYxCgpCaXNlY3Rpbmc6IDAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDAgc3RlcHMpCls3YTgwMTBjZDM2MjczZmY1ZjZmZWE1MjAxZWY5MjMy
ZjMwY2ViYmQ5XSBtbTogbXVubG9jazogbWFudWFsIHB0ZSB3YWxrIGluIGZhc3QgcGF0aCBp
bnN0ZWFkIG9mIGZvbGxvd19wYWdlX21hc2soKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9i
aXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0Cmxz
IC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDky
My9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjdhODAxMGNkMzYy
NzNmZjVmNmZlYTUyMDFlZjkyMzJmMzBjZWJiZDk6YmlzZWN0LW5ldAoKMjAxMy0wOS0yNS0x
NzoyOToxMyA3YTgwMTBjZDM2MjczZmY1ZjZmZWE1MjAxZWY5MjMyZjMwY2ViYmQ5IGNvbXBp
bGluZwoxNTExIHJlYWwgIDI1MTggdXNlciAgMTkyIHN5cyAgMTc5LjMwJSBjcHUgCWkzODYt
cmFuZGNvbmZpZy1yMC0wOTIzCgoyMDEzLTA5LTI1LTE3OjU2OjU0IGRldGVjdGluZyBib290
IHN0YXRlIDMuMTEuMC0wOTE4MC1nN2E4MDEwYy4uCTIJNQkxNCBURVNUIEZBSUxVUkUKQlVH
OiBrZXJuZWwgZWFybHkgaGFuZyB3aXRob3V0IGFueSBwcmludGsgb3V0cHV0CkNvbW1hbmQg
bGluZTogaHVuZ190YXNrX3BhbmljPTEgcmN1dHJlZS5yY3VfY3B1X3N0YWxsX3RpbWVvdXQ9
MTAwIGxvZ19idWZfbGVuPThNIGlnbm9yZV9sb2dsZXZlbCBkZWJ1ZyBzY2hlZF9kZWJ1ZyBh
cGljPWRlYnVnIGR5bmFtaWNfcHJpbnRrIHN5c3JxX2Fsd2F5c19lbmFibGVkIHBhbmljPTEw
ICBwcm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAwIGNvbnNvbGU9dHR5MCB2
Z2E9bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rZXJuZWwtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2Ft
LWkzODYtMjAxMzA5MjMxODA3OjdhODAxMGNkMzYyNzNmZjVmNmZlYTUyMDFlZjkyMzJmMzBj
ZWJiZDk6YmlzZWN0LW5ldC8udm1saW51ei03YTgwMTBjZDM2MjczZmY1ZjZmZWE1MjAxZWY5
MjMyZjMwY2ViYmQ5LTIwMTMwOTI1MTc1NjQ2LTEzNC1hbnQgYnJhbmNoPWxpbnV4LWRldmVs
L2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFHRT0va2VybmVsL2kzODYt
cmFuZGNvbmZpZy1yMC0wOTIzLzdhODAxMGNkMzYyNzNmZjVmNmZlYTUyMDFlZjkyMzJmMzBj
ZWJiZDkvdm1saW51ei0zLjExLjAtMDkxODAtZzdhODAxMGMgbm9hcGljIG5vbGFwaWMgbm9o
ej1vZmYKRWFybHkgaGFuZyBrZXJuZWw6IHZtbGludXotMy4xMS4wLTA5MTgwLWc3YTgwMTBj
IDMuMTEuMC0wOTE4MC1nN2E4MDEwYyAjMjYyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXIw
LTA5MjMvN2E4MDEwY2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOS9kbWVzZy1x
dWFudGFsLXN0b2FrbGV5LTU6MjAxMzA5MjUxNzU5MDQ6My4xMS4wLTA5MTgwLWc3YTgwMTBj
OjI2MgoKN2E4MDEwY2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOSBpcyB0aGUg
Zmlyc3QgYmFkIGNvbW1pdApjb21taXQgN2E4MDEwY2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIz
MmYzMGNlYmJkOQpBdXRob3I6IFZsYXN0aW1pbCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+CkRh
dGU6ICAgV2VkIFNlcCAxMSAxNDoyMjozNSAyMDEzIC0wNzAwCgogICAgbW06IG11bmxvY2s6
IG1hbnVhbCBwdGUgd2FsayBpbiBmYXN0IHBhdGggaW5zdGVhZCBvZiBmb2xsb3dfcGFnZV9t
YXNrKCkKICAgIAogICAgQ3VycmVudGx5IG11bmxvY2tfdm1hX3BhZ2VzX3JhbmdlKCkgY2Fs
bHMgZm9sbG93X3BhZ2VfbWFzaygpIHRvIG9idGFpbgogICAgZWFjaCBpbmRpdmlkdWFsIHN0
cnVjdCBwYWdlLiAgVGhpcyBlbnRhaWxzIHJlcGVhdGVkIGZ1bGwgcGFnZSB0YWJsZQogICAg
dHJhbnNsYXRpb25zIGFuZCBwYWdlIHRhYmxlIGxvY2sgdGFrZW4gZm9yIGVhY2ggcGFnZSBz
ZXBhcmF0ZWx5LgogICAgCiAgICBUaGlzIHBhdGNoIGF2b2lkcyB0aGUgY29zdGx5IGZvbGxv
d19wYWdlX21hc2soKSB3aGVyZSBwb3NzaWJsZSwgYnkKICAgIGl0ZXJhdGluZyBvdmVyIHB0
ZXMgd2l0aGluIHNpbmdsZSBwbWQgdW5kZXIgc2luZ2xlIHBhZ2UgdGFibGUgbG9jay4gIFRo
ZQogICAgZmlyc3QgcHRlIGlzIG9idGFpbmVkIGJ5IGdldF9sb2NrZWRfcHRlKCkgZm9yIG5v
bi1USFAgcGFnZSBhY3F1aXJlZCBieSB0aGUKICAgIGluaXRpYWwgZm9sbG93X3BhZ2VfbWFz
aygpLiAgVGhlIHJlc3Qgb2YgdGhlIG9uLXN0YWNrIHBhZ2V2ZWMgZm9yIG11bmxvY2sKICAg
IGlzIGZpbGxlZCB1cCB1c2luZyBwdGVfd2FsayBhcyBsb25nIGFzIHB0ZV9wcmVzZW50KCkg
YW5kIHZtX25vcm1hbF9wYWdlKCkKICAgIGFyZSBzdWZmaWNpZW50IHRvIG9idGFpbiB0aGUg
c3RydWN0IHBhZ2UuCiAgICAKICAgIEFmdGVyIHRoaXMgcGF0Y2gsIGEgMTQlIHNwZWVkdXAg
d2FzIG1lYXN1cmVkIGZvciBtdW5sb2NraW5nIGEgNTZHQiBsYXJnZQogICAgbWVtb3J5IGFy
ZWEgd2l0aCBUSFAgZGlzYWJsZWQuCiAgICAKICAgIFNpZ25lZC1vZmYtYnk6IFZsYXN0aW1p
bCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+CiAgICBDYzogSsO2cm4gRW5nZWwgPGpvZXJuQGxv
Z2ZzLm9yZz4KICAgIENjOiBNZWwgR29ybWFuIDxtZ29ybWFuQHN1c2UuZGU+CiAgICBDYzog
TWljaGVsIExlc3BpbmFzc2UgPHdhbGtlbkBnb29nbGUuY29tPgogICAgQ2M6IEh1Z2ggRGlj
a2lucyA8aHVnaGRAZ29vZ2xlLmNvbT4KICAgIENjOiBSaWsgdmFuIFJpZWwgPHJpZWxAcmVk
aGF0LmNvbT4KICAgIENjOiBKb2hhbm5lcyBXZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4K
ICAgIENjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmN6PgogICAgQ2M6IFZsYXN0aW1p
bCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+CiAgICBTaWduZWQtb2ZmLWJ5OiBBbmRyZXcgTW9y
dG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPgogICAgU2lnbmVkLW9mZi1ieTogTGlu
dXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgoKOjA0MDAwMCAw
NDAwMDAgMWE0YTAyNjE0NDlmNTkzMjllMTk3YTBkYjZlZjRkMzAyZDMxY2JhOCA5ZDYwZDQ0
ZmE0MTY4YmU0ZWI3N2U4NjZkZDI3Y2Q2ZDZmMjU5ODc5IE0JaW5jbHVkZQo6MDQwMDAwIDA0
MDAwMCBlOGU3NTIzZGVhZmY1NjVkMDQxY2U0NTM1NmE0NDRkZWJiMmM2YzUzIDk1MTg2MmNh
YjY4OWE2MmNkOWI4ODBiZjE2OTI4MDEwNzBkNzM2ZjYgTQltbQpiaXNlY3QgcnVuIHN1Y2Nl
c3MKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1y
MC0wOTIzL2xpbnV4LWRldmVsOmRldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDc6NWI0MDk5
OGFlMzVjZjY0NTYxODY4MzcwZTZjOWYzZDNlOTRiNmJmNzpiaXNlY3QtbmV0CgoyMDEzLTA5
LTI1LTE3OjU5OjMzIDViNDA5OThhZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjcg
cmV1c2UgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy81YjQwOTk4YWUzNWNmNjQ1
NjE4NjgzNzBlNmM5ZjNkM2U5NGI2YmY3L3ZtbGludXotMy4xMS4wLTA5MTc5LWc1YjQwOTk4
CgoyMDEzLTA5LTI1LTE3OjU5OjM4IGRldGVjdGluZyBib290IHN0YXRlIC4uLi4uLi4uCTIJ
Mwk1CTYJMTAuCTExCTEyCTE3CTIzCTI0CTMyCTM2CTM4CTQ0Lgk0NQk0Nwk1MAk2MAk2Mgk2
Mwk2NAk2Nwk2OAk3MC4JNzEJNzIJNzUJNzcJODEuCTg1CTg4Lgk4OQk5OQkxMDUuCTExMQkx
MTMuCTExNS4uCTExOQkxMjIJMTI0CTEyNQkxMjcJMTI4CTEyOQkxMzEJMTMyCTEzMwkxMzku
LgkxNTUJMTU4CTE2MgkxNzIJMTc0CTE4MQkxODYJMTk0CTE5OAkyMDcJMjA5CTIxMi4JMjEz
CTIxNgkyMjEJMjIzLgkyMjcJMjMwCTIzMQkyMzUJMjM5CTI1MAkyNTEJMjU0CTI1Ni4uCTI1
NwkyNjEJMjYyLgkyNjYJMjcwCTI3MgkyNzYuCTI3Ny4JMjg0CTI4NQkyODYuCTI4OQkyOTYJ
Mjk5Li4uLgkzMTEJMzE1LgkzMTcJMzE4CTMyMAkzMjQJMzI1LgkzMjcJMzMwCTMzNAkzMzcu
CTMzOC4JMzM5CTM0NwkzNTEJMzYwCTM2My4JMzY2CTM2OAkzNzQJMzg4CTM4OQkzOTkJNDAy
CTQwNwk0MDgJNDEwCTQxMQk0MTYuCTQyMAk0MjEuLgk0MjYJNDMwCTQzMgk0MzQJNDM3CTQz
OS4uCTQ0Nwk0NTAJNDUyCTQ1Mwk0NjMuCTQ2OQk0NzMJNDg3CTQ5MAk0OTcJNDk4CTUwMQk1
MDcJNTEyCTUxNwk1MTgJNTIwCTUyNgk1MzEJNTM4CTU0Nwk1NDkJNTU4CTU2MQk1NjMJNTc4
CTU4MAk1OTAJNTk3CTU5OAk2MDAJNjAyCTYwNAk2MTkJNjIwCTYyMgk2MjUJNjI2CTYyOQk2
MzUJNjQwCTY0OQk2NTEJNjYwCTY2My4uCTY2NAk2NjUJNjcyCTY3NC4JNjc2CTY3OS4uLi4u
Li4uCTcwNAk3NDcJNzUwCTc1Mgk3NjEJNzYyLi4uCTc2Nwk3ODkJODA1CTgwNgk4MTEJODE3
CTgyNQk4MzIJODM3CTg0Mgk4NDcJODUxCTg1Mgk4NzIJODkyCTg5Ngk5MDMJOTI4CTk0Mwk5
NTEJOTcxCTk3Mwk5ODMJOTg3CTk5Mgk5OTUJOTk4CTk5OQkxMDEzCTEwMjEJMTAyMi4JMTAy
NwkxMDQxCTEwNjQJMTA3MAkxMDc3CTEwODgJMTExMC4JMTExNgkxMTM4CTExNDEJMTE0Mgkx
MTQ0CTExNjQJMTE2OC4JMTE5NQkxMjIzCTEyNDkJMTI2MAkxMjg2CTEzMjQJMTM3NC4JMTQx
OAkxNDIxCTE0NTAJMTQ5MwkxNTA3CTE1NDIJMTU1NwkxNTYwCTE1NjgJMTU5MwkxNjA1CTE2
MjgJMTY0NwkxNjcwCTE2ODYJMTcxMAkxNzM1CTE3NTUJMTc3NgkxNzk4CTE4MTcJMTgzMwkx
ODM5CTE4NzQJMTg4NgkxOTAzCTE5MTIJMTkxNgkxOTI4CTE5MzMJMTkzOQkxOTQ5CTE5NjIJ
MTk2OQkxOTcxCTE5NzMJMTk3OQkxOTkyCTE5OTgJMjAyMgkyMDM3CTIwNDQJMjA1MgkyMDU2
CTIwOTEJMjA5NQkyMTAzCTIxMDcJMjExNQkyMTIwCTIxMjEJMjEyMwkyMTI2CTIxNDkJMjE1
OC4JMjE2NAkyMTcxCTIxODcJMjIwMgkyMjMyCTIyMzkJMjI0NQkyMjQ5CTIyNTAJMjI1Nwky
MjcxCTIyNzkJMjI4MwkyMjg3CTIyOTIJMjI5My4uLgkyMjk1CTIyOTYJMjMwMgkyMzA0CTIz
MDcJMjMxOQkyMzIzCTIzMjQJMjMyNi4uLi4uCTIzMjcuLi4uLi4uCTIzOTgJMjUwNAkyNTM1
CTI1NDEJMjU1MQkyNTc1CTI1ODcJMjU5NgkyNjAzCTI2MjMJMjY0NgkyNjU0CTI2NTcJMjY2
Mi4JMjcxMAkyNzI0CTI3MjgJMjczMgkyNzQ4CTI3NjkJMjc4MQkyNzg5CTI3OTAJMjc5MQky
Nzk0CTI4MDEJMjgxMAkyODE0Li4uCTI4MTgJMjgyOQkyODM2CTI4NDcJMjg0OAkyODY2CTI4
NjkJMjg3My4JMjg3NgkyOTAxCTI5MDMJMjkxOAkyOTMyCTI5MzMJMjkzNQkyOTQ0CTI5NTcJ
Mjk2NgkyOTY4CTI5ODAJMjk4NwkyOTkzCTI5OTQJMjk5OQkzMDM0CTMwODMJMzExMQkzMTMw
CTMxNDQJMzE1MwkzMTYwCTMxNzEJMzE4NgkzMjE2CTMyMjUJMzIzNQkzMjUxCTMyNzIJMzI3
NwkzMjg2CTMzMjkJMzMzMAkzMzQwCTMzNjIJMzM4OQkzNDM2CTM0NDEJMzQ1NwkzNDY4CTM0
NzAuCTM0NzEJMzQ3NwkzNDk3CTM1MDEJMzUwOC4uLi4uLi4uLi4uLi4uLgkzNTEwIFNVQ0NF
U1MKCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWct
cjAtMDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjVmYmMw
YTYyNjNhMTQ3Y2RlOTA1YWZmYmZiNjYyMmMyNjY4NDM0NGY6YmlzZWN0LW5ldAogVEVTVCBG
QUlMVVJFCkJVRzoga2VybmVsIGVhcmx5IGhhbmcgd2l0aG91dCBhbnkgcHJpbnRrIG91dHB1
dApDb21tYW5kIGxpbmU6IGh1bmdfdGFza19wYW5pYz0xIHJjdXRyZWUucmN1X2NwdV9zdGFs
bF90aW1lb3V0PTEwMCBsb2dfYnVmX2xlbj04TSBpZ25vcmVfbG9nbGV2ZWwgZGVidWcgc2No
ZWRfZGVidWcgYXBpYz1kZWJ1ZyBkeW5hbWljX3ByaW50ayBzeXNycV9hbHdheXNfZW5hYmxl
ZCBwYW5pYz0xMCAgcHJvbXB0X3JhbWRpc2s9MCBjb25zb2xlPXR0eVMwLDExNTIwMCBjb25z
b2xlPXR0eTAgdmdhPW5vcm1hbCAgcm9vdD0vZGV2L3JhbTAgcncgbGluaz0va2VybmVsLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvbGludXgtZGV2ZWw6
ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzo1ZmJjMGE2MjYzYTE0N2NkZTkwNWFmZmJm
YjY2MjJjMjY2ODQzNDRmOmJpc2VjdC1uZXQvLnZtbGludXotNWZiYzBhNjI2M2ExNDdjZGU5
MDVhZmZiZmI2NjIyYzI2Njg0MzQ0Zi0yMDEzMDkyMzE4MjY0OC0xMS1hbnQgYnJhbmNoPWxp
bnV4LWRldmVsL2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFHRT0va2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzLzVmYmMwYTYyNjNhMTQ3Y2RlOTA1YWZmYmZi
NjYyMmMyNjY4NDM0NGYvdm1saW51ei0zLjEyLjAtcmMxLTAwMDEwLWc1ZmJjMGE2IG5vYXBp
YyBub2xhcGljIG5vaHo9b2ZmCkVhcmx5IGhhbmcga2VybmVsOiB2bWxpbnV6LTMuMTIuMC1y
YzEtMDAwMTAtZzVmYmMwYTYgMy4xMi4wLXJjMS0wMDAxMC1nNWZiYzBhNiAjMjQKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy81ZmJjMGE2MjYzYTE0N2NkZTkwNWFmZmJmYjY2
MjJjMjY2ODQzNDRmL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtNzoyMDEzMDkyMzE4MzkxNjoz
LjEyLjAtcmMxLTAwMDEwLWc1ZmJjMGE2OjI0Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXIw
LTA5MjMvNWZiYzBhNjI2M2ExNDdjZGU5MDVhZmZiZmI2NjIyYzI2Njg0MzQ0Zi9kbWVzZy1x
dWFudGFsLWxrcC10dDAyLTExOjIwMTMwOTIzMDg0NTQ3OjMuMTIuMC1yYzEtMDAwMTAtZzVm
YmMwYTY6MjQKCltkZXRhY2hlZCBIRUFEIDg3ZTM3MDNdIFJldmVydCAibW06IG11bmxvY2s6
IG1hbnVhbCBwdGUgd2FsayBpbiBmYXN0IHBhdGggaW5zdGVhZCBvZiBmb2xsb3dfcGFnZV9t
YXNrKCkiCiAyIGZpbGVzIGNoYW5nZWQsIDM3IGluc2VydGlvbnMoKyksIDg1IGRlbGV0aW9u
cygtKQpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmln
LXIwLTA5MjMvbGludXgtZGV2ZWw6ZGV2ZWwtcm9hbS1pMzg2LTIwMTMwOTIzMTgwNzo4N2Uz
NzAzNmRjZjk2ZWI3M2E4NjI3NTI0YmU4YjcyMmJkMWFjNTI2OmJpc2VjdC1uZXQKCjIwMTMt
MDktMjUtMjI6MTA6MTkgODdlMzcwMzZkY2Y5NmViNzNhODYyNzUyNGJlOGI3MjJiZDFhYzUy
NiBjb21waWxpbmcKCjIwMTMtMDktMjUtMjI6MjM6NTUgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUg
My4xMi4wLXJjMS0wMDAxMS1nODdlMzcwMy4uLi4uLi4uLgkxMQkyOAkzMQkzNQkzNwk0Ngk1
NAk2Ni4uCTY3CTEyNgkxNTUuCTE3NQkyMDQJMjA2CTIxNgkyMzUJMjQ1CTI1MAkyNjAJMjYy
LgkyNjMJMjczCTI5MAkzMjAJMzUwCTM1MgkzNTQJMzU3CTM2MQkzNjcJMzY4CTM3NAkzODAJ
MzkwCTQwMgk0MDcJNDExCTQxNQk0MjEJNDMwCTQzMgk0MzQJNDQyCTQ0OAk0NTIuCTQ3OAk0
ODgJNTAyCTUxNQk1MjAJNTI3CTU0MAk1NDgJNTUyCTU2Mwk1NjYJNTgyCTYyMC4uCTYzNy4u
Li4JNjQ0CTY0Nwk2NTIJNjUzLi4uLgk2NTQJNjY4CTY3Mwk2NzkuLgk2ODAJNjgyLgk2ODUJ
NzA1CTcxOAk3MTkuCTcyMC4JODI1CTg0MAk4NDEJODQ5CTg1Ngk4NTcJOTA4CTkzMQk5Mzgu
CTk0OAk5NjcJOTgyCTk4OQk5OTAJMTAwMAkxMDAzCTEwMTUJMTAxNwkxMDE4CTEwMzEuCTEw
NDIJMTA0OQkxMDUzCTEwNjMJMTA3OAkxMDgzCTEwODgJMTA5MAkxMDk0CTExMDcJMTExMAkx
MTE3CTExMzEJMTE0OS4uCTExNTcJMTE2MAkxMTYxCTExNzQJMTIwMQkxMjE2CTEyMjcJMTIz
MgkxMjM5CTEyNTQJMTI2NwkxMjk2CTEzMDYJMTMxOAkxMzI1CTEzMjkJMTM1MgkxMzU3CTEz
NjAJMTM2NwkxMzc4CTE0MDYJMTQzNAkxNDQ5CTE1MDAJMTUzOAkxNTU4CTE1ODQJMTU5OQkx
NjMwCTE2NTQJMTcwMQkxNzIxCTE3NDIJMTc2NgkxNzk2CTE4MTAJMTgzMwkxODgwCTE5MTQJ
MTkyMwkxOTI3CTE5MzUJMTk1MQkxOTU0CTE5NjYJMTk3NgkxOTgyCTIwMjgJMjA2NgkyMDg0
CTIwOTQJMjA5NgkyMTEwCTIxMTMJMjEzMwkyMTM5CTIxNTgJMjE2OQkyMTc3CTIxODkJMjIw
MQkyMjA2CTIyMTAJMjIxNQkyMjI4CTIyNTQJMjI3MAkyMjc2CTIyODcJMjI5NQkyMjk4CTIz
MDAJMjMxNAkyMzE5CTIzMjQJMjMyNS4uLi4JMjMzMQkyMzQ2CTIzNTcJMjM2NAkyMzY4CTIz
NzEJMjM3MgkyMzg2CTI0MjIJMjQyNgkyNDMxCTI0MzQJMjQ2NwkyNDcxLi4JMjQ5MAkyNTAy
CTI1MTcJMjUxOQkyNTIyCTI1MzIJMjU0NgkyNTUzCTI1NTYuLi4JMjU1NwkyNTcxCTI2NDAu
LgkyNjUzCTI2NzMJMjY4NAkyNjk2CTI3MDUJMjcwOAkyNzA5LgkyNzExCTI3MTcJMjcyNgky
NzMzCTI3MzkJMjc0MC4uCTI3NDIJMjc2MAkyNzY1LgkyNzY2CTI3NjcJMjc4MAkyNzkxCTI3
OTQJMjc5OQkyODE4CTI4MjMJMjgyOAkyODQzCTI4NDcJMjg1MQkyODU1CTI4NjIJMjg2NAky
ODc4CTI4ODAJMjg4NAkyODkzCTI5MTMJMjkyNgkyOTUzCTI5NTgJMjk2NwkyOTc1CTI5ODMJ
Mjk5NQkzMDI3CTMwMzMJMzA0MAkzMDQyCTMwNTEJMzA1MwkzMDU3CTMwNjAJMzA3NQkzMDg2
CTMwOTIJMzExNi4JMzEyNAkzMTMwCTMxMzIuLi4uLi4uCTMxMzMuLgkzMTM0Li4uCTMxNDQJ
MzE0NgkzMTQ3CTMxNDgJMzE1MS4JMzE1My4JMzE3OAkzMTc5CTMxODcJMzE4OQkzMjAyCTMy
MTkJMzIyNi4JMzIzMQkzMjQwCTMyNDkJMzI1NgkzMjY1CTMyNzcJMzI5NAkzMzEyCTMzMzAJ
MzM0MgkzMzUwCTMzNjAJMzM2OAkzMzcxCTMzNzYJMzM4OQkzMzk2LgkzMzk3CTM0MDQJMzQx
OAkzNDI2CTM0NDEJMzQ2NgkzNDc2CTM0ODIJMzQ5MQkzNDk5Li4uCTM1MDAuCTM1MDEuCTM1
MDIuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4JMzUwMy4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSA3G1swbQouLi4JMzUw
NC4JMzUwNQkzNTA2CTM1MTAgU1VDQ0VTUwoKCj09PT09PT09PSB1cHN0cmVhbSA9PT09PT09
PT0KRmV0Y2hpbmcgbGludXMKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4LWRldmVsOmRldmVsLXJvYW0taTM4Ni0yMDEz
MDkyMzE4MDc6MjIzNTZmNDQ3Y2ViOGQ5N2E0ODg1NzkyZTdkOWU0NjA3ZjcxMmUxYjpiaXNl
Y3QtbmV0CgoyMDEzLTA5LTI2LTA0OjMxOjQ2IDIyMzU2ZjQ0N2NlYjhkOTdhNDg4NTc5MmU3
ZDllNDYwN2Y3MTJlMWIgcmV1c2UgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctcjAtMDkyMy8y
MjM1NmY0NDdjZWI4ZDk3YTQ4ODU3OTJlN2Q5ZTQ2MDdmNzEyZTFiL3ZtbGludXotMy4xMi4w
LXJjMi0wMDAzMy1nMjIzNTZmNAoKMjAxMy0wOS0yNi0wNDozMTo1MSBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAuCTEuLgkyCTMJMTAJMTIJMTMuLi4uLgkxNQkxOQkyNAk0OCBURVNUIEZBSUxV
UkUKQlVHOiBrZXJuZWwgZWFybHkgaGFuZyB3aXRob3V0IGFueSBwcmludGsgb3V0cHV0CkNv
bW1hbmQgbGluZTogaHVuZ190YXNrX3BhbmljPTEgcmN1dHJlZS5yY3VfY3B1X3N0YWxsX3Rp
bWVvdXQ9MTAwIGxvZ19idWZfbGVuPThNIGlnbm9yZV9sb2dsZXZlbCBkZWJ1ZyBzY2hlZF9k
ZWJ1ZyBhcGljPWRlYnVnIGR5bmFtaWNfcHJpbnRrIHN5c3JxX2Fsd2F5c19lbmFibGVkIHBh
bmljPTEwICBwcm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAwIGNvbnNvbGU9
dHR5MCB2Z2E9bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rZXJuZWwtdGVzdHMv
cnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctcjAtMDkyMy9saW51eC1kZXZlbDpkZXZl
bC1yb2FtLWkzODYtMjAxMzA5MjMxODA3OjIyMzU2ZjQ0N2NlYjhkOTdhNDg4NTc5MmU3ZDll
NDYwN2Y3MTJlMWI6YmlzZWN0LW5ldC8udm1saW51ei0yMjM1NmY0NDdjZWI4ZDk3YTQ4ODU3
OTJlN2Q5ZTQ2MDdmNzEyZTFiLTIwMTMwOTI2MDQzMTQ2LTkzMi1hbnQgYnJhbmNoPWxpbnV4
LWRldmVsL2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFHRT0va2VybmVs
L2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzLzIyMzU2ZjQ0N2NlYjhkOTdhNDg4NTc5MmU3ZDll
NDYwN2Y3MTJlMWIvdm1saW51ei0zLjEyLjAtcmMyLTAwMDMzLWcyMjM1NmY0IG5vYXBpYyBu
b2xhcGljIG5vaHo9b2ZmCkVhcmx5IGhhbmcga2VybmVsOiB2bWxpbnV6LTMuMTIuMC1yYzIt
MDAwMzMtZzIyMzU2ZjQgMy4xMi4wLXJjMi0wMDAzMy1nMjIzNTZmNCAjOAova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1yMC0wOTIzLzIyMzU2ZjQ0N2NlYjhkOTdhNDg4NTc5MmU3ZDllNDYw
N2Y3MTJlMWIvZG1lc2ctcXVhbnRhbC1sa3Atc3QwMS02OjIwMTMwOTI2MDQ0MDA3OjMuMTIu
MC1yYzItMDAwMzMtZzIyMzU2ZjQ6OAoKCj09PT09PT09PSBsaW51eC1uZXh0ID09PT09PT09
PQpGZXRjaGluZyBuZXh0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2
LXJhbmRjb25maWctcjAtMDkyMy9saW51eC1kZXZlbDpkZXZlbC1yb2FtLWkzODYtMjAxMzA5
MjMxODA3OjA1MGY0ZGE4NmU5YmRiY2M5ZTExNzg5ZTBmMjkxYWFmYTU3YjhhMjA6YmlzZWN0
LW5ldAoKMjAxMy0wOS0yNi0wNDo0MTowOSAwNTBmNGRhODZlOWJkYmNjOWUxMTc4OWUwZjI5
MWFhZmE1N2I4YTIwIHJldXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXIwLTA5MjMvMDUw
ZjRkYTg2ZTliZGJjYzllMTE3ODllMGYyOTFhYWZhNTdiOGEyMC92bWxpbnV6LTMuMTIuMC1y
YzItbmV4dC0yMDEzMDkyNS0wMjA2Ni1nMDUwZjRkYQoKMjAxMy0wOS0yNi0wNDo0MToxNSBk
ZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkxCTMJNQk2CTE5CTI4CTUwCTYwCTczCTc3CTg0CTg5
CTkyCTk1CTk3CTEwMAkxMDIJMTAzCTEwNC4JMTA3LgkxMDkJMTExCTExMy4JMTMzIFRFU1Qg
RkFJTFVSRQpCVUc6IGtlcm5lbCBlYXJseSBoYW5nIHdpdGhvdXQgYW55IHByaW50ayBvdXRw
dXQKQ29tbWFuZCBsaW5lOiBodW5nX3Rhc2tfcGFuaWM9MSByY3V0cmVlLnJjdV9jcHVfc3Rh
bGxfdGltZW91dD0xMDAgbG9nX2J1Zl9sZW49OE0gaWdub3JlX2xvZ2xldmVsIGRlYnVnIHNj
aGVkX2RlYnVnIGFwaWM9ZGVidWcgZHluYW1pY19wcmludGsgc3lzcnFfYWx3YXlzX2VuYWJs
ZWQgcGFuaWM9MTAgIHByb21wdF9yYW1kaXNrPTAgY29uc29sZT10dHlTMCwxMTUyMDAgY29u
c29sZT10dHkwIHZnYT1ub3JtYWwgIHJvb3Q9L2Rldi9yYW0wIHJ3IGxpbms9L2tlcm5lbC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzL2xpbnV4LWRldmVs
OmRldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDc6MDUwZjRkYTg2ZTliZGJjYzllMTE3ODll
MGYyOTFhYWZhNTdiOGEyMDpiaXNlY3QtbmV0Ly52bWxpbnV6LTA1MGY0ZGE4NmU5YmRiY2M5
ZTExNzg5ZTBmMjkxYWFmYTU3YjhhMjAtMjAxMzA5MjYwNDQxMDktMzExMC1hbnQgYnJhbmNo
PWxpbnV4LWRldmVsL2RldmVsLXJvYW0taTM4Ni0yMDEzMDkyMzE4MDcgQk9PVF9JTUFHRT0v
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1yMC0wOTIzLzA1MGY0ZGE4NmU5YmRiY2M5ZTExNzg5
ZTBmMjkxYWFmYTU3YjhhMjAvdm1saW51ei0zLjEyLjAtcmMyLW5leHQtMjAxMzA5MjUtMDIw
NjYtZzA1MGY0ZGEgbm9hcGljIG5vbGFwaWMgbm9oej1vZmYKRWFybHkgaGFuZyBrZXJuZWw6
IHZtbGludXotMy4xMi4wLXJjMi1uZXh0LTIwMTMwOTI1LTAyMDY2LWcwNTBmNGRhIDMuMTIu
MC1yYzItbmV4dC0yMDEzMDkyNS0wMjA2Ni1nMDUwZjRkYSAjMTIKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctcjAtMDkyMy8wNTBmNGRhODZlOWJkYmNjOWUxMTc4OWUwZjI5MWFhZmE1N2I4
YTIwL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtNzoyMDEzMDkyNjA0NTUxNjozLjEyLjAtcmMy
LW5leHQtMjAxMzA5MjUtMDIwNjYtZzA1MGY0ZGE6MTIKCg==

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.12.0-rc1-00010-g5fbc0a6"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.12.0-rc1 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
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
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
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
CONFIG_COMPILE_TEST=y
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
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
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
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
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
CONFIG_TASK_XACCT=y
# CONFIG_TASK_IO_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
# CONFIG_NET_NS is not set
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
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
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
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
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_CMDLINE_PARSER=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
CONFIG_ACORN_PARTITION_EESOX=y
CONFIG_ACORN_PARTITION_ICS=y
CONFIG_ACORN_PARTITION_ADFS=y
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_AIX_PARTITION=y
CONFIG_OSF_PARTITION=y
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
CONFIG_LDM_DEBUG=y
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
CONFIG_M586MMX=y
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_F00F_BUG=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_TSC=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_ZBUD is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_CC_STACKPROTECTOR=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_POWERNOW_K6 is not set
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
# CONFIG_X86_SPEEDSTEP_ICH is not set
# CONFIG_X86_SPEEDSTEP_SMI is not set
# CONFIG_X86_P4_CLOCKMOD is not set
CONFIG_X86_CPUFREQ_NFORCE2=y
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
# CONFIG_PCIEASPM_DEFAULT is not set
CONFIG_PCIEASPM_POWERSAVE=y
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
CONFIG_OLPC=y
# CONFIG_OLPC_XO15_SCI is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
CONFIG_GEOS=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
CONFIG_I82092=y
CONFIG_I82365=y
CONFIG_TCIC=y
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_COMPAQ=y
# CONFIG_HOTPLUG_PCI_COMPAQ_NVRAM is not set
CONFIG_HOTPLUG_PCI_IBM=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
# CONFIG_ATM is not set
CONFIG_MRP=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_DECNET=y
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_LTPC=y
# CONFIG_COPS is not set
CONFIG_IPDDP=y
# CONFIG_IPDDP_ENCAP is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
CONFIG_VMWARE_VMCI_VSOCKETS=y
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
# CONFIG_IRLAN is not set
# CONFIG_IRNET is not set
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_TOSHIBA_FIR=y
# CONFIG_SMC_IRCC_FIR is not set
CONFIG_ALI_FIR=y
# CONFIG_VLSI_FIR is not set
CONFIG_VIA_FIR=y
CONFIG_BT=y
# CONFIG_BT_RFCOMM is not set
CONFIG_BT_BNEP=y
# CONFIG_BT_BNEP_MC_FILTER is not set
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUART=y
# CONFIG_BT_HCIUART_H4 is not set
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
CONFIG_BT_HCIUART_LL=y
CONFIG_BT_HCIUART_3WIRE=y
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
# CONFIG_BT_WILINK is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_REG_DEBUG is not set
# CONFIG_CFG80211_DEFAULT_PS is not set
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
CONFIG_MAC80211_DEBUG_MENU=y
# CONFIG_MAC80211_NOINLINE is not set
CONFIG_MAC80211_VERBOSE_DEBUG=y
# CONFIG_MAC80211_MLME_DEBUG is not set
CONFIG_MAC80211_STA_DEBUG=y
CONFIG_MAC80211_HT_DEBUG=y
# CONFIG_MAC80211_IBSS_DEBUG is not set
CONFIG_MAC80211_PS_DEBUG=y
CONFIG_MAC80211_TDLS_DEBUG=y
# CONFIG_MAC80211_DEBUG_COUNTERS is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_NFC=y
CONFIG_NFC_NCI=y
CONFIG_NFC_HCI=y
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_WILINK=y
CONFIG_NFC_SIM=y
# CONFIG_NFC_PN544 is not set
# CONFIG_NFC_MICROREAD is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=7

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_OF_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
# CONFIG_MTD_CFI_GEOMETRY is not set
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
CONFIG_MTD_OTP=y
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
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
CONFIG_MTD_PHYSMAP_OF=y
# CONFIG_MTD_SC520CDP is not set
CONFIG_MTD_NETSC520=y
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_SBC_GXX is not set
# CONFIG_MTD_SCx200_DOCFLASH is not set
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_PCI=y
# CONFIG_MTD_PCMCIA is not set
CONFIG_MTD_GPIO_ADDR=y
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
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
# CONFIG_MTD_NAND is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
# CONFIG_MTD_ONENAND_GENERIC is not set
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_UBI is not set
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
CONFIG_PROC_DEVICETREE=y
CONFIG_OF_SELFTEST=y
CONFIG_OF_PROMTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
# CONFIG_PNPBIOS_PROC_FS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
CONFIG_PARIDE=y

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=y
CONFIG_PARIDE_PCD=y
CONFIG_PARIDE_PF=y
CONFIG_PARIDE_PT=y
CONFIG_PARIDE_PG=y

#
# Parallel IDE protocol modules
#
# CONFIG_PARIDE_ATEN is not set
CONFIG_PARIDE_BPCK=y
CONFIG_PARIDE_BPCK6=y
CONFIG_PARIDE_COMM=y
# CONFIG_PARIDE_DSTR is not set
# CONFIG_PARIDE_FIT2 is not set
# CONFIG_PARIDE_FIT3 is not set
CONFIG_PARIDE_EPAT=y
CONFIG_PARIDE_EPATC8=y
# CONFIG_PARIDE_EPIA is not set
CONFIG_PARIDE_FRIQ=y
CONFIG_PARIDE_FRPW=y
# CONFIG_PARIDE_KBIC is not set
# CONFIG_PARIDE_KTTI is not set
# CONFIG_PARIDE_ON20 is not set
CONFIG_PARIDE_ON26=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
CONFIG_BLK_CPQ_DA=y
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
CONFIG_ATA_OVER_ETH=y
# CONFIG_VIRTIO_BLK is not set
CONFIG_BLK_DEV_HD=y
CONFIG_BLK_DEV_RSXX=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_VMWARE_VMCI=y
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_MULTI_LUN is not set
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
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_7000FASST=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AHA152X=y
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AACRAID is not set
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_IN2000=y
# CONFIG_SCSI_ARCMSR is not set
CONFIG_SCSI_ESAS2R=y
# CONFIG_MEGARAID_NEWGEN is not set
CONFIG_MEGARAID_LEGACY=y
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_LOGGING=y
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
# CONFIG_SCSI_DTC3280 is not set
CONFIG_SCSI_EATA=y
# CONFIG_SCSI_EATA_TAGGED_QUEUE is not set
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=y
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_GENERIC_NCR5380_MMIO is not set
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=y
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
CONFIG_SCSI_IMM=y
CONFIG_SCSI_IZIP_EPP16=y
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_NCR53C406A=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_PAS16 is not set
CONFIG_SCSI_QLOGIC_FAS=y
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_FC is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_SYM53C416=y
CONFIG_SCSI_DC395x=y
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_T128=y
CONFIG_SCSI_U14_34F=y
# CONFIG_SCSI_U14_34F_TAGGED_QUEUE is not set
# CONFIG_SCSI_U14_34F_LINKED_COMMANDS is not set
CONFIG_SCSI_U14_34F_MAX_TAGS=8
# CONFIG_SCSI_ULTRASTOR is not set
CONFIG_SCSI_NSP32=y
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
CONFIG_SCSI_VIRTIO=y
CONFIG_SCSI_CHELSIO_FCOE=y
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
# CONFIG_TCM_FILEIO is not set
# CONFIG_TCM_PSCSI is not set
# CONFIG_LOOPBACK_TARGET is not set
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
CONFIG_SBP_TARGET=y
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_SBP2 is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
# CONFIG_I2O_SCSI is not set
# CONFIG_I2O_PROC is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_ISA=y
CONFIG_ARCNET_COM20020_PCI=y
CONFIG_ARCNET_COM20020_CS=y

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6060=y
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
CONFIG_NET_DSA_MV88E6123_61_65=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
CONFIG_ACENIC_OMIT_TIGON_I=y
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
# CONFIG_LANCE is not set
CONFIG_PCNET32=y
CONFIG_PCMCIA_NMCLAN=y
CONFIG_NI65=y
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
CONFIG_NET_CADENCE=y
CONFIG_ARM_AT91_ETHER=y
CONFIG_MACB=y
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=y
CONFIG_CNIC=y
# CONFIG_TIGON3 is not set
CONFIG_BNX2X=y
CONFIG_BNX2X_SRIOV=y
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_CALXEDA_XGMAC=y
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
# CONFIG_CHELSIO_T4 is not set
CONFIG_CHELSIO_T4VF=y
CONFIG_NET_VENDOR_CIRRUS=y
CONFIG_CS89x0=y
CONFIG_CS89x0_PLATFORM=y
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_DNET=y
# CONFIG_NET_VENDOR_DEC is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
CONFIG_SUNDANCE=y
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_FUJITSU is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_I40E=y
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_MLX5_CORE=y
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_FEALNX=y
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
CONFIG_NS83820=y
# CONFIG_NET_VENDOR_8390 is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
CONFIG_QLCNIC=y
CONFIG_QLCNIC_SRIOV=y
# CONFIG_QLGE is not set
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_ATP=y
# CONFIG_8139CP is not set
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_SH_ETH=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_NET_VENDOR_SILAN is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_SMC9194=y
CONFIG_PCMCIA_SMC91C92=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_NET_VENDOR_XIRCOM is not set
# CONFIG_FDDI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
CONFIG_AMD_PHY=y
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
# CONFIG_STE10XP is not set
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
# CONFIG_MDIO_BUS_MUX_MMIOREG is not set
CONFIG_PLIP=y
CONFIG_PPP=y
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
# CONFIG_PPP_MPPE is not set
# CONFIG_PPP_MULTILINK is not set
# CONFIG_PPPOE is not set
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
CONFIG_SLIP=y
CONFIG_SLHC=y
# CONFIG_SLIP_COMPRESSED is not set
# CONFIG_SLIP_SMART is not set
# CONFIG_SLIP_MODE_SLIP6 is not set
# CONFIG_WLAN is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
CONFIG_WAN=y
# CONFIG_HDLC is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
# CONFIG_SDLA is not set
CONFIG_LAPBETHER=y
# CONFIG_X25_ASY is not set
# CONFIG_SBNI is not set
CONFIG_ISDN=y
CONFIG_ISDN_I4L=y
# CONFIG_ISDN_AUDIO is not set
CONFIG_ISDN_X25=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=y

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set

#
# Active cards
#
CONFIG_ISDN_DRV_ICN=y
CONFIG_ISDN_DRV_PCBIT=y
# CONFIG_ISDN_DRV_SC is not set
CONFIG_ISDN_DRV_ACT2000=y
# CONFIG_ISDN_CAPI is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_I4L=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_M101=y
CONFIG_GIGASET_DEBUG=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
# CONFIG_MISDN_L1OIP is not set

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=y
# CONFIG_MISDN_HFCMULTI is not set
CONFIG_MISDN_AVMFRITZ=y
# CONFIG_MISDN_SPEEDFAX is not set
CONFIG_MISDN_INFINEON=y
# CONFIG_MISDN_W6692 is not set
CONFIG_MISDN_NETJET=y
CONFIG_MISDN_IPAC=y
CONFIG_ISDN_HDLC=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
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
CONFIG_KEYBOARD_ADP5520=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TC3589X=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
CONFIG_TOUCHSCREEN_DA9034=y
# CONFIG_TOUCHSCREEN_DA9052 is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
# CONFIG_TOUCHSCREEN_EETI is not set
CONFIG_TOUCHSCREEN_EGALAX=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_HTCPEN is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
CONFIG_TOUCHSCREEN_PIXCIR=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_INPUT_MISC is not set

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
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_OF_PLATFORM=y
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_PCH_UART=y
CONFIG_SERIAL_PCH_UART_CONSOLE=y
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_ST_ASC=y
# CONFIG_SERIAL_ST_ASC_CONSOLE is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
CONFIG_DTLK=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_SONYPI=y

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
# CONFIG_SCx200_GPIO is not set
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
# CONFIG_I2C_MUX_PCA954x is not set
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
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=y
CONFIG_SCx200_ACB=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=y
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_TS5500=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_GRGPIO is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TC3589X=y
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_WM8994=y
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_ADNP=y

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_LANGWELL=y
# CONFIG_GPIO_PCH is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_SODAVILLE is not set
# CONFIG_GPIO_TIMBERDALE is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MCP23S08=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
# CONFIG_GPIO_KEMPLD is not set

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_PALMAS=y

#
# USB GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

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
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_OLPC is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=y
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GOLDFISH=y
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
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
# CONFIG_SENSORS_DA9052_ADC is not set
CONFIG_SENSORS_DA9055=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_ZL6100 is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=y

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=y
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEO_V4L2_INT_DEVICE=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_VIDEO_CAFE_CCIC=y
# CONFIG_VIDEO_VIA_CAMERA is not set
CONFIG_SOC_CAMERA=y
CONFIG_SOC_CAMERA_SCALE_CROP=y
# CONFIG_SOC_CAMERA_PLATFORM is not set
CONFIG_VIDEO_RCAR_VIN=y
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_SH_VEU=y
# CONFIG_V4L_TEST_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_MEDIA_PARPORT_SUPPORT=y
CONFIG_VIDEO_BWQCAM=y
CONFIG_VIDEO_CQCAM=y
# CONFIG_VIDEO_PMS is not set
CONFIG_VIDEO_W9966=y
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
CONFIG_RADIO_SI470X=y
CONFIG_I2C_SI470X=y
CONFIG_RADIO_MAXIRADIO=y
CONFIG_I2C_SI4713=y
CONFIG_RADIO_SI4713=y
# CONFIG_RADIO_TEA5764 is not set
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
# CONFIG_RADIO_TIMBERDALE is not set
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_RADIO_WL128X=y
# CONFIG_V4L_RADIO_ISA_DRIVERS is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
# CONFIG_VIDEO_TDA9840 is not set
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
# CONFIG_VIDEO_MSP3400 is not set
CONFIG_VIDEO_CS5345=y
CONFIG_VIDEO_CS53L32A=y
# CONFIG_VIDEO_TLV320AIC23B is not set
# CONFIG_VIDEO_UDA1342 is not set
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
# CONFIG_VIDEO_VP27SMPX is not set
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
# CONFIG_VIDEO_ADV7180 is not set
# CONFIG_VIDEO_ADV7183 is not set
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
# CONFIG_VIDEO_ML86V7667 is not set
# CONFIG_VIDEO_SAA7110 is not set
# CONFIG_VIDEO_SAA711X is not set
CONFIG_VIDEO_SAA7191=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
# CONFIG_VIDEO_TW9906 is not set
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
# CONFIG_VIDEO_ADV7343 is not set
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_VS6624=y
# CONFIG_VIDEO_MT9V011 is not set
CONFIG_VIDEO_TCM825X=y
CONFIG_VIDEO_SR030PC30=y

#
# Flash devices
#
CONFIG_VIDEO_ADP1653=y
CONFIG_VIDEO_AS3645A=y

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Miscelaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=y

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
# CONFIG_SOC_CAMERA_IMX074 is not set
CONFIG_SOC_CAMERA_MT9M001=y
# CONFIG_SOC_CAMERA_MT9M111 is not set
# CONFIG_SOC_CAMERA_MT9T031 is not set
CONFIG_SOC_CAMERA_MT9T112=y
CONFIG_SOC_CAMERA_MT9V022=y
CONFIG_SOC_CAMERA_OV2640=y
CONFIG_SOC_CAMERA_OV5642=y
CONFIG_SOC_CAMERA_OV6650=y
CONFIG_SOC_CAMERA_OV772X=y
# CONFIG_SOC_CAMERA_OV9640 is not set
CONFIG_SOC_CAMERA_OV9740=y
# CONFIG_SOC_CAMERA_RJ54N1 is not set
CONFIG_SOC_CAMERA_TW9910=y
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
# CONFIG_MEDIA_TUNER_TDA9887 is not set
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=y
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=y
# CONFIG_MEDIA_TUNER_XC2028 is not set
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
# CONFIG_MEDIA_TUNER_MAX2165 is not set
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
# CONFIG_MEDIA_TUNER_FC0013 is not set
# CONFIG_MEDIA_TUNER_TDA18212 is not set
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_IT913X=y
CONFIG_MEDIA_TUNER_R820T=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
# CONFIG_DVB_STB0899 is not set
CONFIG_DVB_STB6100=y
# CONFIG_DVB_STV090x is not set
CONFIG_DVB_STV6110x=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10036=y
# CONFIG_DVB_ZL10039 is not set
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
# CONFIG_DVB_STV0299 is not set
CONFIG_DVB_STV6110=y
# CONFIG_DVB_STV0900 is not set
# CONFIG_DVB_TDA8083 is not set
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
# CONFIG_DVB_VES1X93 is not set
# CONFIG_DVB_TUNER_ITD1000 is not set
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_SI21XX=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y
CONFIG_DVB_MB86A16=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
# CONFIG_DVB_SP887X is not set
CONFIG_DVB_CX22700=y
# CONFIG_DVB_CX22702 is not set
CONFIG_DVB_S5H1432=y
# CONFIG_DVB_DRXD is not set
# CONFIG_DVB_L64781 is not set
# CONFIG_DVB_TDA1004X is not set
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
# CONFIG_DVB_ZL10353 is not set
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
CONFIG_DVB_DIB7000M=y
# CONFIG_DVB_DIB7000P is not set
CONFIG_DVB_DIB9000=y
# CONFIG_DVB_TDA10048 is not set
# CONFIG_DVB_AF9013 is not set
# CONFIG_DVB_EC100 is not set
CONFIG_DVB_HD29L2=y
CONFIG_DVB_STV0367=y
# CONFIG_DVB_CXD2820R is not set
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
# CONFIG_DVB_TDA10021 is not set
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
CONFIG_DVB_OR51132=y
CONFIG_DVB_BCM3510=y
# CONFIG_DVB_LGDT330X is not set
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LG2160=y
# CONFIG_DVB_S5H1409 is not set
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_DIB8000=y
CONFIG_DVB_MB86A20S=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_LNBP21 is not set
CONFIG_DVB_LNBP22=y
# CONFIG_DVB_ISL6405 is not set
CONFIG_DVB_ISL6421=y
# CONFIG_DVB_ISL6423 is not set
# CONFIG_DVB_A8293 is not set
CONFIG_DVB_LGS8GL5=y
# CONFIG_DVB_LGS8GXX is not set
# CONFIG_DVB_ATBM8830 is not set
# CONFIG_DVB_TDA665x is not set
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_IT913X_FE=y
# CONFIG_DVB_M88RS2000 is not set
CONFIG_DVB_AF9033=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
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
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_UMS is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
# CONFIG_DRM_MGA is not set
CONFIG_DRM_VIA=y
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_QXL=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
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
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SM501=y
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_LM3533 is not set
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_ADP5520 is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_OT200=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_MDA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_FB_SSD1307=y
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_OMAP_CONTROL_USB is not set
# CONFIG_OMAP_USB3 is not set
# CONFIG_AM335X_PHY_USB is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_MLX5_INFINIBAND=y
# CONFIG_INFINIBAND_OCRDMA is not set
# CONFIG_INFINIBAND_SRP is not set
# CONFIG_INFINIBAND_SRPT is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_MAX77686=y
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PALMAS is not set
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MC13XXX is not set
# CONFIG_RTC_DRV_SNVS is not set
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_MF624=y
CONFIG_VIRT_DRIVERS=y
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
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
CONFIG_ECHO=y
CONFIG_FB_OLPC_DCON=y
CONFIG_FB_OLPC_DCON_1=y
CONFIG_FB_OLPC_DCON_1_5=y
# CONFIG_PANEL is not set
CONFIG_DX_SEP=y

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
CONFIG_AD7291=y
# CONFIG_AD7606 is not set
CONFIG_AD799X=y
CONFIG_AD799X_RING_BUFFER=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
CONFIG_TSL2583=y
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
# CONFIG_IIO_SIMPLE_DUMMY is not set
CONFIG_ZSMALLOC=y
CONFIG_ZRAM=y
CONFIG_ZRAM_DEBUG=y
CONFIG_FB_SM7XX=y
CONFIG_CRYSTALHD=y
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
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
CONFIG_SPEAKUP_SYNTH_DTLK=y
# CONFIG_SPEAKUP_SYNTH_KEYPC is not set
# CONFIG_SPEAKUP_SYNTH_LTLK is not set
CONFIG_SPEAKUP_SYNTH_SOFT=y
# CONFIG_SPEAKUP_SYNTH_SPKOUT is not set
CONFIG_SPEAKUP_SYNTH_TXPRT=y
# CONFIG_SPEAKUP_SYNTH_DUMMY is not set
CONFIG_TOUCHSCREEN_CLEARPAD_TM1217=y
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_STAGING_MEDIA=y
CONFIG_DVB_CXD2099=y
CONFIG_VIDEO_DT3155=y
CONFIG_DT3155_CCIR=y
CONFIG_DT3155_STREAMING=y

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
# CONFIG_ASHMEM is not set
# CONFIG_ANDROID_LOGGER is not set
# CONFIG_ANDROID_TIMED_OUTPUT is not set
CONFIG_ANDROID_LOW_MEMORY_KILLER=y
# CONFIG_ANDROID_INTF_ALARM_DEV is not set
CONFIG_SYNC=y
CONFIG_SW_SYNC=y
# CONFIG_SW_SYNC_USER is not set
# CONFIG_NET_VENDOR_SILICOM is not set
# CONFIG_DGRP is not set
CONFIG_FIREWIRE_SERIAL=y
# CONFIG_XILLYBUS is not set
CONFIG_DGNC=y
CONFIG_DGAP=y
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_CHROMEOS_LAPTOP is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WMI is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO1_RFKILL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_OF_IOMMU=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_OF_EXTCON=y
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_PALMAS=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set

#
# Analog to digital converters
#
# CONFIG_EXYNOS_ADC is not set
CONFIG_MAX1363=y
CONFIG_NAU7802=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_AM335X_ADC=y

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_HID_SENSOR_ENUM_BASE_QUIRKS=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_MAX517=y
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
# CONFIG_HID_SENSOR_GYRO_3D is not set
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
# CONFIG_APDS9300 is not set
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_SENSORS_LM3533=y
CONFIG_SENSORS_TSL2563=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y

#
# Temperature sensors
#
CONFIG_TMP006=y
CONFIG_NTB=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y

#
# VME Board Drivers
#
# CONFIG_VMIVME_7805 is not set

#
# VME Device Drivers
#
CONFIG_VME_USER=y
# CONFIG_VME_PIO2 is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_PCA9685 is not set
CONFIG_IRQCHIP=y
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_SMI is not set
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
# CONFIG_EXT3_FS_POSIX_ACL is not set
# CONFIG_EXT3_FS_SECURITY is not set
# CONFIG_EXT4_FS is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=y
# CONFIG_OCFS2_FS_O2CB is not set
# CONFIG_OCFS2_FS_STATS is not set
CONFIG_OCFS2_DEBUG_MASKLOG=y
CONFIG_OCFS2_DEBUG_FS=y
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
CONFIG_ROMFS_BACKED_BY_MTD=y
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
CONFIG_EXOFS_DEBUG=y
# CONFIG_F2FS_FS is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
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
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_FIREWIRE_OHCI_REMOTE_DMA=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
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
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_XOR=y
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
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_586 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_LGUEST is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
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
CONFIG_AUDIT_GENERIC=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
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
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y

--+QahgC5+KEYLbs62--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
