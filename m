Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 4C6346B009D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 04:48:09 -0400 (EDT)
Date: Mon, 16 Sep 2013 16:47:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [munlock] BUG: Bad page map in process killall5 pte:53425553
 pmd:075f4067
Message-ID: <20130916084752.GC11479@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="qDbXVdCdHGoSgWSk"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Greetings,

I got the below dmesg and the first bad commit is

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


[   56.020577] BUG: Bad page map in process killall5  pte:53425553 pmd:075f4067
[   56.022578] addr:08800000 vm_flags:00100073 anon_vma:7f5f6f00 mapping:  (null) index:8800
[   56.025276] CPU: 0 PID: 101 Comm: killall5 Not tainted 3.11.0-09272-g666a584 #52

git bisect start 666a584d3a765a914642f80deef7a33fb309df5d v3.11 --
git bisect good a09e9a7a4b907f2dfa9bdb2b98a1828ab4b340b2  # 22:15   1080+  Merge branch 'drm-next' of git://people.freedesktop.org/~airlied/linux
git bisect good 8e73e367f7dc50f1d1bc22a63e5764bb4eea9b48  # 22:43   1080+  Merge tag 'cleanup-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good 64c353864e3f7ccba0ade1bd6f562f9a3bc7e68d  # 00:14   1080+  Merge branch 'for-v3.12' of git://git.linaro.org/people/mszyprowski/linux-dma-mapping
git bisect good 640414171818c6293c23e74a28d1c69b2a1a7fe5  # 00:23   1080+  Merge tag 'late-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good fa1586a7e43760f0e25e72b2e3f97ee18b2be967  # 01:08   1080+  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux
git bisect good bc4b4448dba660afc8df3790564320302d9709a1  # 01:43   1080+  mm: move pgtable related functions to right place
git bisect  bad 325c4ef5c4b17372c3222d896040d7848e67fbdb  # 02:08    133-  mm/madvise.c:madvise_hwpoison(): remove local `ret'
git bisect good e76b63f80d938a1319eb5fb0ae7ea69bddfbae38  # 02:27   1340+  memblock, numa: binary search node id
git bisect  bad 762216ab4e175f49d17bc7ad778c57b9028184e6  # 02:51    708-  mm/vmalloc: use wrapper function get_vm_area_size to caculate size of vm area
git bisect good 586a32ac1d33ce7a7548a27e4087e98842c3a06f  # 03:40   3517+  mm: munlock: remove unnecessary call to lru_add_drain()
git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 04:23   3517+  mm: munlock: remove redundant get_page/put_page pair on the fast path
git bisect  bad 6e543d5780e36ff5ee56c44d7e2e30db3457a7ed  # 04:53    148-  mm: vmscan: fix do_try_to_free_pages() livelock
git bisect  bad 7a8010cd36273ff5f6fea5201ef9232f30cebbd9  # 05:03     69-  mm: munlock: manual pte walk in fast path instead of follow_page_mask()
git bisect good 5b40998ae35cf64561868370e6c9f3d3e94b6bf7  # 09:42  10000+  mm: munlock: remove redundant get_page/put_page pair on the fast path
git bisect  bad d5d04bb48f0eb89c14e76779bb46212494de0bec  # 10:08    128-  Bye, bye, WfW flag
git bisect good 14f83d4c02fa126fd699570429a0bb888e12ddf7  # 16:20  10000+  Revert "mm: munlock: manual pte walk in fast path instead of follow_page_mask()"
git bisect  bad d8efd82eece89f8a5790b0febf17522affe9e1f1  # 16:34     45-  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/ralf/upstream-linus

Thanks,
Fengguang

--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-ant-14:20130912234102:3.11.0-09272-g666a584:52"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Linux version 3.11.0-09272-g666a584 (kbuild@inn) (gcc versio=
n 4.8.1 (Debian 4.8.1-8) ) #52 SMP Thu Sep 12 19:28:52 CST 2013
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   UMC UMC UMC UMC
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
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
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x01ffffff]
[    0.000000] Base memory trampoline at [7809b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e000000-0x0e3fffff]
[    0.000000]  [mem 0x0e000000-0x0e3fffff] page 4k
[    0.000000] BRK [0x01982000, 0x01982fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0dffffff]
[    0.000000]  [mem 0x08000000-0x0dffffff] page 4k
[    0.000000] BRK [0x01983000, 0x01983fff] PGTABLE
[    0.000000] BRK [0x01984000, 0x01984fff] PGTABLE
[    0.000000] BRK [0x01985000, 0x01985fff] PGTABLE
[    0.000000] BRK [0x01986000, 0x01986fff] PGTABLE
[    0.000000] BRK [0x01987000, 0x01987fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e400000-0x0fffdfff]
[    0.000000]  [mem 0x0e400000-0x0fffdfff] page 4k
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128212(97%)
[    0.000000] RAMDISK: [mem 0x0e73f000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd920 00014 (v00 BOCHS )
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
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   Normal zone: 640 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] APIC: disable apic facility
[    0.000000] APIC: switched to apic NOOP
[    0.000000] nr_irqs_gsi: 16
[    0.000000] e820: [mem 0x10000000-0xfffbffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @8648b000 s27136 r0 d22016 u49=
152
[    0.000000] pcpu-alloc: s27136 r0 d22016 u49152 alloc=3D12*4096
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64796
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3D=
debug dynamic_printk sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 co=
nsole=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kernel-tests/run-queue/kvm/i386-randconfig-i002-0912/linus:master/.vmli=
nuz-666a584d3a765a914642f80deef7a33fb309df5d-20130912222131-9-ant branch=3D=
linus/master noapic nolapic nohz=3Doff BOOT_IMAGE=3D/kernel/i386-randconfig=
-i002-0912/666a584d3a765a914642f80deef7a33fb309df5d/vmlinuz-3.11.0-09272-g6=
66a584
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 215256K/261744K available (2130K kernel code, 200K r=
wdata, 1188K rodata, 304K init, 5860K bss, 46488K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6d000 - 0xfffff000   (1608 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0x887fe000 - 0xff7fe000   (1904 MB)
[    0.000000]     lowmem  : 0x78000000 - 0x87ffe000   ( 255 MB)
[    0.000000]       .init : 0x79372000 - 0x793be000   ( 304 kB)
[    0.000000]       .data : 0x79214ece - 0x79371340   (1393 kB)
[    0.000000]       .text : 0x79000000 - 0x79214ece   (2131 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:24 16
[    0.000000] CPU 0 irqstacks, hard=3D78094000 soft=3D78096000
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
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ODEBUG: 10 of 10 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration failed
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: using HPET reference calibration
[    0.000000] tsc: Detected 3191.855 MHz processor
[    0.061531] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 6383.71 BogoMIPS (lpj=3D31918550)
[    0.063918] pid_max: default: 32768 minimum: 301
[    0.081404] Security Framework initialized
[    0.086339] Yama: becoming mindful.
[    0.090258] Mount-cache hash table entries: 512
[    0.152382] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.152382] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.152382] tlb_flushall_shift: -1
[    0.287649] debug: unmapping init [mem 0x793be000-0x793c0fff]
[    0.322112] ACPI: Core revision 20130725
[    0.474607] ACPI: All ACPI Tables successfully acquired
[    0.476123] ACPI: setting ELCR to 0200 (from 0c00)
[    0.524574] smpboot: weird, boot CPU (#0) not listed by the BIOS
[    0.525493] smpboot: SMP motherboard not detected
[    0.526389] Apic disabled
[    0.526774] smpboot: Local APIC not detected. Using dummy APIC emulation.
[    0.527588] smpboot: SMP disabled
[    0.529222] Performance Events:=20
[    0.530755] no APIC, boot with the "lapic" boot parameter to force-enabl=
e it.
[    0.531652] no hardware sampling interrupt available.
[    0.532977] Broken PMU hardware detected, using software events only.
[    0.533861] Failed to access perfctr msr (MSR c0010004 is 0)
[    0.588035] Brought up 1 CPUs
[    0.590423] smpboot: Total of 1 processors activated (6383.71 BogoMIPS)
[    0.612674] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.676349] devtmpfs: initialized
[    0.792395] regulator-dummy: no parameters
[    0.813830] NET: Registered protocol family 16
[    0.835196] cpuidle: using governor menu
[    0.842869] ACPI: bus type PCI registered
[    0.847573] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.935400] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.937174] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.941489] ACPI: Added _OSI(Module Device)
[    0.942143] ACPI: Added _OSI(Processor Device)
[    0.942721] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.943336] ACPI: Added _OSI(Processor Aggregator Device)
[    1.020561] ACPI: EC: Look up EC in DSDT
[    1.370880] ACPI: Interpreter enabled
[    1.373157] ACPI: (supports S0 S5)
[    1.373780] ACPI: Using PIC for interrupt routing
[    1.376700] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.911475] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.913550] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    1.940708] PCI host bridge to bus 0000:00
[    1.941905] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.942735] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.943400] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.944179] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.944899] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    1.952417] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.976400] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.985106] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.996956] pci 0000:00:01.1: reg 0x20: [io  0xc1e0-0xc1ef]
[    2.013993] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    2.017908] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    2.018835] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    2.032204] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    2.036935] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    2.042056] pci 0000:00:02.0: reg 0x14: [mem 0xfebe0000-0xfebe0fff]
[    2.060324] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    2.066298] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    2.072049] pci 0000:00:03.0: reg 0x10: [io  0xc1c0-0xc1df]
[    2.076203] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    2.093722] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    2.107593] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    2.112076] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    2.116296] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    2.135462] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    2.148681] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    2.153923] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    2.158188] pci 0000:00:05.0: reg 0x14: [mem 0xfebe2000-0xfebe2fff]
[    2.188778] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    2.193993] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    2.198165] pci 0000:00:06.0: reg 0x14: [mem 0xfebe3000-0xfebe3fff]
[    2.228602] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    2.232116] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    2.236289] pci 0000:00:07.0: reg 0x14: [mem 0xfebe4000-0xfebe4fff]
[    2.268716] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    2.274023] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    2.278237] pci 0000:00:08.0: reg 0x14: [mem 0xfebe5000-0xfebe5fff]
[    2.309377] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    2.314036] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    2.318118] pci 0000:00:09.0: reg 0x14: [mem 0xfebe6000-0xfebe6fff]
[    2.349028] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    2.353943] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    2.358159] pci 0000:00:0a.0: reg 0x14: [mem 0xfebe7000-0xfebe7fff]
[    2.388855] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    2.391368] pci 0000:00:0b.0: reg 0x10: [mem 0xfebe8000-0xfebe800f]
[    2.418075] pci_bus 0000:00: on NUMA node 0
[    2.466183] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    2.475901] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    2.483520] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    2.491331] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    2.495664] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    2.527367] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    2.528485] Unable to map lapic to logical cpu number
[    2.536516] ACPI: Enabled 16 GPEs in block 00 to 0F
[    2.538877] ACPI: \_SB_.PCI0: notify handler is installed
[    2.544440] Found 1 acpi root devices
[    2.556627] pps_core: LinuxPPS API ver. 1 registered
[    2.557368] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    2.561202] PCI: Using ACPI for IRQ routing
[    2.562318] PCI: pci_cache_line_size set to 64 bytes
[    2.566124] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    2.567582] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    2.629891] Switched to clocksource hpet
[    2.636908] pnp: PnP ACPI init
[    2.639316] ACPI: bus type PNP registered
[    2.650668] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    2.655828] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    2.659924] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    2.664368] pnp 00:03: [dma 2]
[    2.666742] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    2.672027] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    2.678042] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    2.694661] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    2.704871] pnp: PnP ACPI: found 7 devices
[    2.705687] ACPI: bus type PNP unregistered
[    2.796866] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    2.797682] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    2.798354] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    2.799072] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    2.800930] NET: Registered protocol family 1
[    2.802095] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    2.803902] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    2.805272] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    2.806552] pci 0000:00:02.0: Boot video device
[    2.808171] PCI: CLS 0 bytes, default 64
[    2.830029] Unpacking initramfs...
[   33.294117] debug: unmapping init [mem 0x8673f000-0x87feffff]
[   33.317956] microcode: AMD CPU family 0x6 not supported
[   33.318949] Scanning for low memory corruption every 60 seconds
[   33.356989] NatSemi SCx200 Driver
[   33.420643] Initializing RT-Tester: OK
[   33.668203] crc32: CRC_LE_BITS =3D 32, CRC_BE BITS =3D 32
[   33.669111] crc32: self tests passed, processed 225944 bytes in 4057260 =
nsec
[   33.675176] crc32c: CRC_LE_BITS =3D 32
[   33.675813] crc32c: self tests passed, processed 225944 bytes in 1876570=
 nsec
[   33.690545] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   33.691442] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver =
version: 0.1
[   33.693122] cpcihp_generic: not configured, disabling.
[   33.695801] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   33.698073] ipmi message handler version 39.2
[   33.699215] ipmi device interface
[   33.703673] IPMI Watchdog: driver initialized
[   33.719376] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   33.723369] ACPI: Power Button [PWRF]
[   34.325270] tsc: Refined TSC clocksource calibration: 3191.881 MHz
[   34.330260] Switched to clocksource tsc
[   35.253389] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   35.292940] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[   35.341611] Non-volatile memory driver v1.3
[   35.343244] toshiba: not a supported Toshiba laptop
[   35.344048] nsc_gpio initializing
[   35.355975] dummy-irq: no IRQ given.  Use irq=3DN
[   35.358802] Phantom Linux Driver, version n0.9.8, init OK
[   35.376333] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   35.395007] serio: i8042 KBD port at 0x60,0x64 irq 1
[   35.398834] serio: i8042 AUX port at 0x60,0x64 irq 12
[   35.430880] mousedev: PS/2 mouse device common for all mice
[   35.439909] rtc_cmos 00:00: RTC can wake from S4
[   35.449121] rtc (null): alarm rollover: day
[   35.461617] rtc rtc0: rtc_cmos: dev (254:0)
[   35.464370] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   35.468153] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[   35.471369] Driver for 1-wire Dallas network protocol.
[   35.480415] intel_powerclamp: Intel powerclamp does not run on family 6 =
model 2
[   35.510132] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   35.555548] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   35.606646] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[   35.609832] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   35.616886] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[   35.621046] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[   35.623485] pc87413_wdt: Version 1.1 at io 0x2E
[   35.624361] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   35.625693] sbc7240_wdt: I/O address 0x0443 already in use
[   35.628838] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   35.629877] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[   35.637506] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[   35.648847]=20
[   35.648847] printing PIC contents
[   35.649688] ... PIC  IMR: ecf8
[   35.650146] ... PIC  IRR: 0010
[   35.650668] ... PIC  ISR: 0000
[   35.651122] ... PIC ELCR: 0200
[   35.651713] Using IPI No-Shortcut mode
[   35.676588] IMA: No TPM chip found, activating TPM-bypass!
[   35.715442] rtc_cmos 00:00: setting system clock to 2013-09-12 15:38:58 =
UTC (1379000338)
[   35.764474] debug: unmapping init [mem 0x79372000-0x793bdfff]
[   35.767803] Write protecting the kernel text: 2132k
[   35.769193] Write protecting the kernel read-only data: 1192k
[   36.236584] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input2
modprobe: FATAL: Could not load /lib/modules/3.11.0-09272-g666a584/modules.=
dep: No such file or directory

modprobe: FATAL: Could not load /lib/modules/3.11.0-09272-g666a584/modules.=
dep: No such file or directory

mountall: Event failed
 * Asking all remaining processes to terminate...      =20
[   54.649810] init: Failed to create pty - disabling logging for job
[   54.666722] init: Temporary process spawn error: No space left on device

[   56.020577] BUG: Bad page map in process killall5  pte:53425553 pmd:075f=
4067
[   56.022578] addr:08800000 vm_flags:00100073 anon_vma:7f5f6f00 mapping:  =
(null) index:8800
[   56.025276] CPU: 0 PID: 101 Comm: killall5 Not tainted 3.11.0-09272-g666=
a584 #52
[   56.026971]  00000000 00000000 7f607e14 7920eb26 7f609d10 7f607e48 79098=
f57 792efd3c
[   56.029836]  08800000 00100073 7f5f6f00 00000000 00008800 53425553 00000=
000 08800000
[   56.031178]  7f609d10 08800000 7f607e60 79099d01 00000000 08800000 00000=
000 7f609d10
[   56.033387] Call Trace:
[   56.036240]  [<7920eb26>] dump_stack+0x4b/0x66
[   56.037009]  [<79098f57>] print_bad_pte+0x173/0x18a
[   56.037723]  [<79099d01>] vm_normal_page+0x5a/0x78
[   56.038445]  [<7909c621>] munlock_vma_pages_range+0xa6/0x150
[   56.039289]  [<7909e532>] exit_mmap+0x3d/0xeb
[   56.039951]  [<7902f05d>] mmput+0x45/0x9f
[   56.040567]  [<79031b1e>] do_exit+0x22d/0x65d
[   56.041267]  [<79047be8>] ? hrtimer_get_res+0x34/0x34
[   56.041978]  [<792140d6>] ? sysenter_exit+0xf/0x39
[   56.043463]  [<79032b1a>] do_group_exit+0x5a/0x87
[   56.044263]  [<79032b58>] SyS_exit_group+0x11/0x11
[   56.044957]  [<7921409d>] sysenter_do_call+0x12/0x3c
[   56.045910] Disabling lock debugging due to kernel taint
mountall: Event failed

udevd[156]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   77.135929] udevd[162]: starting version 175
udevd[162]: inotify_init failed: Function not implemented

udevd[162]: error initializing inotify

[   78.900293] init: plymouth-log main process (159) terminated with status=
 1
[   79.178144] init: udev main process (162) terminated with status 4
[   79.181136] init: udev main process ended, respawning
udevd[171]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   81.373943] udevd[174]: starting version 175
udevd[174]: inotify_init failed: Function not implemented

udevd[174]: error initializing inotify

[   81.518694] init: udev main process (174) terminated with status 4
[   81.521607] init: udev main process ended, respawning
udevd[175]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   82.603677] udevd[176]: starting version 175
udevd[176]: inotify_init failed: Function not implemented

udevd[176]: error initializing inotify

[   82.737829] init: udev main process (176) terminated with status 4
[   82.740796] init: udev main process ended, respawning
udevd[177]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   83.906636] udevd[178]: starting version 175
udevd[178]: inotify_init failed: Function not implemented

udevd[178]: error initializing inotify

[   84.016160] init: udev main process (178) terminated with status 4
[   84.019085] init: udev main process ended, respawning
udevd[180]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   84.877439] udevd[181]: starting version 175
udevd[181]: inotify_init failed: Function not implemented

udevd[181]: error initializing inotify

[   85.038664] init: udev main process (181) terminated with status 4
[   85.041542] init: udev main process ended, respawning
udevd[183]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   85.939654] udevd[184]: starting version 175
udevd[184]: inotify_init failed: Function not implemented

udevd[184]: error initializing inotify

[   86.047783] init: udev main process (184) terminated with status 4
[   86.050694] init: udev main process ended, respawning
udevd[185]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   87.388534] udevd[190]: starting version 175
udevd[190]: inotify_init failed: Function not implemented

udevd[190]: error initializing inotify

[   87.620911] init: udev main process (190) terminated with status 4
[   87.645673] init: udev main process ended, respawning
udevd[191]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   90.830270] udevd[192]: starting version 175
udevd[192]: inotify_init failed: Function not implemented

udevd[192]: error initializing inotify

[   91.124020] init: udev main process (192) terminated with status 4
[   91.161656] init: udev main process ended, respawning
udevd[193]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   92.251348] udevd[195]: starting version 175
udevd[195]: inotify_init failed: Function not implemented

udevd[195]: error initializing inotify

[   92.401909] init: udev main process (195) terminated with status 4
[   92.429364] init: udev main process ended, respawning
udevd[196]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   94.464002] udevd[200]: starting version 175
udevd[200]: inotify_init failed: Function not implemented

udevd[200]: error initializing inotify

[   94.734420] init: udev main process (200) terminated with status 4
[   94.737739] init: udev main process ended, respawning
[   96.067706] init: udev-fallback-graphics main process (197) terminated w=
ith status 1
udevd[204]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   96.656257] udevd[208]: starting version 175
udevd[208]: inotify_init failed: Function not implemented

udevd[208]: error initializing inotify

[   97.027958] init: udev main process (208) terminated with status 4
[   97.031518] init: udev main process ended, respawning
[   97.847132] init: plymouth-splash main process (207) terminated with sta=
tus 1
udevd[210]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   98.229368] udevd[212]: starting version 175
udevd[212]: inotify_init failed: Function not implemented

udevd[212]: error initializing inotify

[   98.337943] init: udev main process (212) terminated with status 4
[   98.340899] init: udev main process ended, respawning
udevd[213]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[   99.357074] udevd[219]: starting version 175
udevd[219]: inotify_init failed: Function not implemented

udevd[219]: error initializing inotify

[   99.577450] init: udev main process (219) terminated with status 4
[   99.580438] init: udev main process ended, respawning
udevd[220]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  100.889840] udevd[222]: starting version 175
udevd[222]: inotify_init failed: Function not implemented

udevd[222]: error initializing inotify

[  101.035919] init: udev main process (222) terminated with status 4
[  101.038743] init: udev main process ended, respawning
udevd[223]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  102.274394] udevd[224]: starting version 175
udevd[224]: inotify_init failed: Function not implemented

udevd[224]: error initializing inotify

[  102.417324] init: udev main process (224) terminated with status 4
[  102.420484] init: udev main process ended, respawning
udevd[226]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  104.455982] udevd[227]: starting version 175
udevd[227]: inotify_init failed: Function not implemented

udevd[227]: error initializing inotify

[  104.820524] init: udev main process (227) terminated with status 4
[  104.883862] init: udev main process ended, respawning
udevd[230]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  106.096436] udevd[232]: starting version 175
udevd[232]: inotify_init failed: Function not implemented

udevd[232]: error initializing inotify

[  106.362471] init: udev main process (232) terminated with status 4
[  106.418058] init: udev main process ended, respawning
udevd[234]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  107.319966] udevd[235]: starting version 175
udevd[235]: inotify_init failed: Function not implemented

udevd[235]: error initializing inotify

[  107.427737] init: udev main process (235) terminated with status 4
[  107.431536] init: udev main process ended, respawning
[  107.591571] init: networking main process (206) terminated with status 1
udevd[237]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  107.994708] udevd[238]: starting version 175
udevd[238]: inotify_init failed: Function not implemented

udevd[238]: error initializing inotify

[  108.075791] init: udev main process (238) terminated with status 4
[  108.078979] init: udev main process ended, respawning
udevd[243]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  109.308455] udevd[244]: starting version 175
udevd[244]: inotify_init failed: Function not implemented

udevd[244]: error initializing inotify

[  109.435427] init: udev main process (244) terminated with status 4
[  109.438951] init: udev main process ended, respawning
udevd[245]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  110.391076] udevd[246]: starting version 175
udevd[246]: inotify_init failed: Function not implemented

udevd[246]: error initializing inotify

[  110.527745] init: udev main process (246) terminated with status 4
[  110.531062] init: udev main process ended, respawning
udevd[247]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  111.490915] udevd[249]: starting version 175
udevd[249]: inotify_init failed: Function not implemented

udevd[249]: error initializing inotify

[  111.596704] init: udev main process (249) terminated with status 4
[  111.600189] init: udev main process ended, respawning
udevd[250]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  112.444501] udevd[251]: starting version 175
udevd[251]: inotify_init failed: Function not implemented

udevd[251]: error initializing inotify

[  112.557509] init: udev main process (251) terminated with status 4
[  112.561215] init: udev main process ended, respawning
udevd[253]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  112.994323] udevd[254]: starting version 175
udevd[254]: inotify_init failed: Function not implemented

udevd[254]: error initializing inotify

[  113.059231] init: udev main process (254) terminated with status 4
[  113.063899] init: udev main process ended, respawning
udevd[255]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  113.496552] udevd[256]: starting version 175
udevd[256]: inotify_init failed: Function not implemented

udevd[256]: error initializing inotify

[  113.565099] init: udev main process (256) terminated with status 4
[  113.568614] init: udev main process ended, respawning
udevd[257]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  114.075389] udevd[262]: starting version 175
udevd[262]: inotify_init failed: Function not implemented

udevd[262]: error initializing inotify

[  114.187780] init: udev main process (262) terminated with status 4
[  114.190906] init: udev main process ended, respawning
udevd[263]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  115.228134] udevd[264]: starting version 175
udevd[264]: inotify_init failed: Function not implemented

udevd[264]: error initializing inotify

[  115.347505] init: udev main process (264) terminated with status 4
[  115.350561] init: udev main process ended, respawning
udevd[265]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  116.280950] udevd[266]: starting version 175
udevd[266]: inotify_init failed: Function not implemented

udevd[266]: error initializing inotify

[  116.398316] init: udev main process (266) terminated with status 4
[  116.401413] init: udev main process ended, respawning
udevd[267]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  117.249929] udevd[269]: starting version 175
udevd[269]: inotify_init failed: Function not implemented

udevd[269]: error initializing inotify

[  117.345095] init: udev main process (269) terminated with status 4
[  117.348484] init: udev main process ended, respawning
udevd[270]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  118.791371] udevd[274]: starting version 175
udevd[274]: inotify_init failed: Function not implemented

udevd[274]: error initializing inotify

[  119.210718] init: udev main process (274) terminated with status 4
[  119.244981] init: udev main process ended, respawning
udevd[275]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  120.215472] udevd[276]: starting version 175
udevd[276]: inotify_init failed: Function not implemented

udevd[276]: error initializing inotify

[  120.349515] init: udev main process (276) terminated with status 4
[  120.363742] init: udev main process ended, respawning
udevd[277]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  121.296529] udevd[278]: starting version 175
udevd[278]: inotify_init failed: Function not implemented

udevd[278]: error initializing inotify

[  121.415025] init: udev main process (278) terminated with status 4
[  121.427528] init: udev main process ended, respawning
udevd[279]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  122.370103] udevd[280]: starting version 175
udevd[280]: inotify_init failed: Function not implemented

udevd[280]: error initializing inotify

[  122.485916] init: udev main process (280) terminated with status 4
[  122.491579] init: udev main process ended, respawning
udevd[282]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  123.158835] udevd[284]: starting version 175
udevd[284]: inotify_init failed: Function not implemented

udevd[284]: error initializing inotify

[  123.256734] init: udev main process (284) terminated with status 4
[  123.259863] init: udev main process ended, respawning
udevd[285]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  123.922959] udevd[288]: starting version 175
udevd[288]: inotify_init failed: Function not implemented

udevd[288]: error initializing inotify

[  123.998949] init: udev main process (288) terminated with status 4
[  124.002245] init: udev main process ended, respawning
udevd[289]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  124.688159] udevd[292]: starting version 175
udevd[292]: inotify_init failed: Function not implemented

udevd[292]: error initializing inotify

[  124.776571] init: udev main process (292) terminated with status 4
[  124.779474] init: udev main process ended, respawning
 * All processes ended within 8 seconds....       udevd[293]: error: runtim=
e directory '/run/udev' not writable, for now falling back to '/dev/.udev'
[  125.419010] udevd[295]: starting version 175
udevd[295]: inotify_init failed: Function not implemented

udevd[295]: error initializing inotify

[  125.513908] init: udev main process (295) terminated with status 4
[  125.517426] init: udev main process ended, respawning

[  126.218963] udevd[299]: starting version 175
udevd[299]: inotify_init failed: Function not implemented

udevd[299]: error initializing inotify

[  126.307554] init: udev main process (299) terminated with status 4
[  126.310509] init: udev main process ended, respawning

udevd[300]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  127.073107] udevd[302]: starting version 175
udevd[302]: inotify_init failed: Function not implemented

udevd[302]: error initializing inotify

[  127.155357] init: udev main process (302) terminated with status 4
[  127.158751] init: udev main process ended, respawning
udevd[304]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  127.857233] udevd[307]: starting version 175
udevd[307]: inotify_init failed: Function not implemented

udevd[307]: error initializing inotify

[  127.971091] init: udev main process (307) terminated with status 4
[  127.975295] init: udev main process ended, respawning
udevd[308]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  128.613828] udevd[310]: starting version 175
udevd[310]: inotify_init failed: Function not implemented

udevd[310]: error initializing inotify

[  128.697111] init: udev main process (310) terminated with status 4
[  128.700037] init: udev main process ended, respawning
udevd[311]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  129.468829] udevd[314]: starting version 175
udevd[314]: inotify_init failed: Function not implemented

udevd[314]: error initializing inotify

[  129.660115] init: udev main process (314) terminated with status 4
[  129.675498] init: udev main process ended, respawning
udevd[316]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  130.477604] udevd[319]: starting version 175
udevd[319]: inotify_init failed: Function not implemented

udevd[319]: error initializing inotify

[  130.587817] init: udev main process (319) terminated with status 4
[  130.591001] init: udev main process ended, respawning
udevd[321]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  131.339656] udevd[323]: starting version 175
udevd[323]: inotify_init failed: Function not implemented

udevd[323]: error initializing inotify

[  131.447278] init: udev main process (323) terminated with status 4
[  131.450334] init: udev main process ended, respawning
udevd[324]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  132.951397] udevd[326]: starting version 175
udevd[326]: inotify_init failed: Function not implemented

udevd[326]: error initializing inotify

[  133.331623] init: udev main process (326) terminated with status 4
[  133.353966] init: udev main process ended, respawning
udevd[327]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  134.431543] udevd[331]: starting version 175
udevd[331]: inotify_init failed: Function not implemented

udevd[331]: error initializing inotify

[  134.543537] init: udev main process (331) terminated with status 4
[  134.549717] init: udev main process ended, respawning
udevd[332]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  135.236366] udevd[333]: starting version 175
udevd[333]: inotify_init failed: Function not implemented

udevd[333]: error initializing inotify

[  135.326300] init: udev main process (333) terminated with status 4
[  135.344148] init: udev main process ended, respawning
udevd[335]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  136.059137] udevd[338]: starting version 175
udevd[338]: inotify_init failed: Function not implemented

udevd[338]: error initializing inotify

[  136.157434] init: udev main process (338) terminated with status 4
[  136.160442] init: udev main process ended, respawning
udevd[339]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  136.897452] udevd[342]: starting version 175
udevd[342]: inotify_init failed: Function not implemented

udevd[342]: error initializing inotify

[  137.019266] init: udev main process (342) terminated with status 4
[  137.046578] init: udev main process ended, respawning
udevd[345]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  137.994692] udevd[348]: starting version 175
udevd[348]: inotify_init failed: Function not implemented

udevd[348]: error initializing inotify

[  138.118179] init: udev main process (348) terminated with status 4
[  138.134053] init: udev main process ended, respawning
udevd[349]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  138.851636] udevd[352]: starting version 175
udevd[352]: inotify_init failed: Function not implemented

udevd[352]: error initializing inotify

[  139.027052] init: udev main process (352) terminated with status 4
[  139.029947] init: udev main process ended, respawning
udevd[355]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  139.582813] udevd[358]: starting version 175
udevd[358]: inotify_init failed: Function not implemented

udevd[358]: error initializing inotify

[  139.647858] init: udev main process (358) terminated with status 4
[  139.650793] init: udev main process ended, respawning
udevd[359]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  140.369620] udevd[362]: starting version 175
udevd[362]: inotify_init failed: Function not implemented

udevd[362]: error initializing inotify

[  140.475805] init: udev main process (362) terminated with status 4
[  140.478535] init: udev main process ended, respawning
udevd[365]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  141.187301] udevd[368]: starting version 175
udevd[368]: inotify_init failed: Function not implemented

udevd[368]: error initializing inotify

[  141.275978] init: udev main process (368) terminated with status 4
[  141.278778] init: udev main process ended, respawning
udevd[369]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  142.028157] udevd[373]: starting version 175
udevd[373]: inotify_init failed: Function not implemented

udevd[373]: error initializing inotify

[  142.127614] init: udev main process (373) terminated with status 4
[  142.130486] init: udev main process ended, respawning
udevd[374]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  142.844844] udevd[376]: starting version 175
udevd[376]: inotify_init failed: Function not implemented

udevd[376]: error initializing inotify

[  142.944693] init: udev main process (376) terminated with status 4
[  142.947356] init: udev main process ended, respawning
udevd[378]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  143.674192] udevd[380]: starting version 175
udevd[380]: inotify_init failed: Function not implemented

udevd[380]: error initializing inotify

[  143.747335] init: udev main process (380) terminated with status 4
[  143.750371] init: udev main process ended, respawning
udevd[382]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  144.493103] udevd[384]: starting version 175
udevd[384]: inotify_init failed: Function not implemented

udevd[384]: error initializing inotify

[  144.594856] init: udev main process (384) terminated with status 4
[  144.598137] init: udev main process ended, respawning
 * Deactivating swap...       udevd[386]: error: runtime directory '/run/ud=
ev' not writable, for now falling back to '/dev/.udev'

 udevd[388]: inotify_init failed: Function not implemented

udevd[388]: error initializing inotify

[  146.274998] init: udev main process (388) terminated with status 4
[  146.293800] init: udev main process ended, respawning

[  147.204005] udevd[393]: starting version 175
udevd[393]: inotify_init failed: Function not implemented

udevd[393]: error initializing inotify

[  147.303326] init: udev main process (393) terminated with status 4
[  147.310557] init: udev main process ended, respawning

udevd[394]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  147.979498] udevd[396]: starting version 175
udevd[396]: inotify_init failed: Function not implemented

udevd[396]: error initializing inotify

[  148.074513] init: udev main process (396) terminated with status 4
[  148.080481] init: udev main process ended, respawning
udevd[397]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  148.773592] udevd[400]: starting version 175
udevd[400]: inotify_init failed: Function not implemented

udevd[400]: error initializing inotify

[  148.857658] init: udev main process (400) terminated with status 4
[  148.860833] init: udev main process ended, respawning
udevd[401]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  149.536199] udevd[404]: starting version 175
udevd[404]: inotify_init failed: Function not implemented

udevd[404]: error initializing inotify

[  149.630680] init: udev main process (404) terminated with status 4
[  149.634525] init: udev main process ended, respawning
udevd[405]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  150.309523] udevd[407]: starting version 175
udevd[407]: inotify_init failed: Function not implemented

udevd[407]: error initializing inotify

[  150.418518] init: udev main process (407) terminated with status 4
[  150.421315] init: udev main process ended, respawning
udevd[408]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  151.114860] udevd[411]: starting version 175
udevd[411]: inotify_init failed: Function not implemented

udevd[411]: error initializing inotify

[  151.195653] init: udev main process (411) terminated with status 4
[  151.198475] init: udev main process ended, respawning
udevd[413]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
umount: /run/lock: not mounted
[  151.908187] udevd[414]: starting version 175
udevd[414]: inotify_init failed: Function not implemented

udevd[414]: error initializing inotify

[  152.005454] init: udev main process (414) terminated with status 4
[  152.008435] init: udev main process ended, respawning
udevd[416]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  152.565683] udevd[418]: starting version 175
udevd[418]: inotify_init failed: Function not implemented

udevd[418]: error initializing inotify

[  152.647390] init: udev main process (418) terminated with status 4
[  152.650453] init: udev main process ended, respawning
udevd[420]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  153.353958] udevd[423]: starting version 175
udevd[423]: inotify_init failed: Function not implemented

udevd[423]: error initializing inotify

[  153.436396] init: udev main process (423) terminated with status 4
[  153.439166] init: udev main process ended, respawning
udevd[424]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  154.157049] udevd[426]: starting version 175
udevd[426]: inotify_init failed: Function not implemented

udevd[426]: error initializing inotify

[  154.236413] init: udev main process (426) terminated with status 4
[  154.239270] init: udev main process ended, respawning
 * Will now restart
udevd[427]: error: runtime directory '/run/udev' not writable, for now fall=
ing back to '/dev/.udev'
[  154.875286] reboot: Restarting system
[  154.876189] reboot: machine restart
Elapsed time: 190
qemu-system-x86_64 -kernel /tmp//kernel/i386-randconfig-i002-0912/666a584d3=
a765a914642f80deef7a33fb309df5d/vmlinuz-3.11.0-09272-g666a584-27867 -append=
 'hung_task_panic=3D1 rcutree.rcu_cpu_stall_timeout=3D100 log_buf_len=3D8M =
ignore_loglevel debug sched_debug apic=3Ddebug dynamic_printk sysrq_always_=
enabled panic=3D10  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty=
0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/i386=
-randconfig-i002-0912/linus:master/.vmlinuz-666a584d3a765a914642f80deef7a33=
fb309df5d-20130912222131-9-ant branch=3Dlinus/master noapic nolapic nohz=3D=
off BOOT_IMAGE=3D/kernel/i386-randconfig-i002-0912/666a584d3a765a914642f80d=
eef7a33fb309df5d/vmlinuz-3.11.0-09272-g666a584'  -initrd /kernel-tests/init=
rd/quantal-core-i386.cgz -m 256M -smp 2 -net nic,vlan=3D0,macaddr=3D00:00:0=
0:00:00:00,model=3Dvirtio -net user,vlan=3D0,hostfwd=3Dtcp::31963-:22 -net =
nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -=
watchdog i6300esb -drive file=3D/fs/sdc1/disk0-ant-27867,media=3Ddisk,if=3D=
virtio -drive file=3D/fs/sdc1/disk1-ant-27867,media=3Ddisk,if=3Dvirtio -dri=
ve file=3D/fs/sdc1/disk2-ant-27867,media=3Ddisk,if=3Dvirtio -drive file=3D/=
fs/sdc1/disk3-ant-27867,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdc1/dis=
k4-ant-27867,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdc1/disk5-ant-2786=
7,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-ant-lkp-27867 -seria=
l file:/dev/shm/kboot/serial-ant-lkp-27867 -daemonize -display none -monito=
r null=20

--qDbXVdCdHGoSgWSk
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-666a584d3a765a914642f80deef7a33fb309df5d-i386-randconfig-i002-0912-BUG:-Bad-page-map-in-process-22004.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDY2NmE1ODRkM2E3NjVhOTE0NjQyZjgwZGVlZjdhMzNmYjMwOWRmNWQK
SEVBRCBpcyBub3cgYXQgNjY2YTU4NC4uLiBkcml2ZXJzL3J0Yy9ydGMtcGFsbWFzLmM6IHN1
cHBvcnQgZm9yIGJhY2t1cCBiYXR0ZXJ5IGNoYXJnaW5nCmxzIC1hIC9rZXJuZWwtdGVzdHMv
cnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3Rlcjo2
NjZhNTg0ZDNhNzY1YTkxNDY0MmY4MGRlZWY3YTMzZmIzMDlkZjVkOmJpc2VjdC1tbQogVEVT
VCBGQUlMVVJFClsgICA1NC42NjY3MjJdIGluaXQ6IFRlbXBvcmFyeSBwcm9jZXNzIHNwYXdu
IGVycm9yOiBObyBzcGFjZSBsZWZ0IG9uIGRldmljZQoKWyAgIDU2LjAyMDU3N10gQlVHOiBC
YWQgcGFnZSBtYXAgaW4gcHJvY2VzcyBraWxsYWxsNSAgcHRlOjUzNDI1NTUzIHBtZDowNzVm
NDA2NwpbICAgNTYuMDIyNTc4XSBhZGRyOjA4ODAwMDAwIHZtX2ZsYWdzOjAwMTAwMDczIGFu
b25fdm1hOjdmNWY2ZjAwIG1hcHBpbmc6ICAobnVsbCkgaW5kZXg6ODgwMApbICAgNTYuMDI1
Mjc2XSBDUFU6IDAgUElEOiAxMDEgQ29tbToga2lsbGFsbDUgTm90IHRhaW50ZWQgMy4xMS4w
LTA5MjcyLWc2NjZhNTg0ICM1Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIv
NjY2YTU4NGQzYTc2NWE5MTQ2NDJmODBkZWVmN2EzM2ZiMzA5ZGY1ZC9kbWVzZy1xdWFudGFs
LWFudC0xNDoyMDEzMDkxMjIzNDEwMjozLjExLjAtMDkyNzItZzY2NmE1ODQ6NTIKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyLzY2NmE1ODRkM2E3NjVhOTE0NjQyZjgwZGVl
ZjdhMzNmYjMwOWRmNWQvZG1lc2ctcXVhbnRhbC1hbnQtNzoyMDEzMDkxNTIwMTgyMzozLjEx
LjAtMDkyNzItZzY2NmE1ODQ6NTIKCmJpc2VjdDogYmFkIGNvbW1pdCA2NjZhNTg0ZDNhNzY1
YTkxNDY0MmY4MGRlZWY3YTMzZmIzMDlkZjVkCmdpdCBjaGVja291dCB2My4xMQpQcmV2aW91
cyBIRUFEIHBvc2l0aW9uIHdhcyA2NjZhNTg0Li4uIGRyaXZlcnMvcnRjL3J0Yy1wYWxtYXMu
Yzogc3VwcG9ydCBmb3IgYmFja3VwIGJhdHRlcnkgY2hhcmdpbmcKSEVBRCBpcyBub3cgYXQg
NmU0NjY0NS4uLiBMaW51eCAzLjExCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3Rlcjo2ZTQ2NjQ1MjViMWRi
MjhmOGM0ZTExMzA5NTdmNzBhOTRjMTkyMTNlOmJpc2VjdC1tbQoKMjAxMy0wOS0xNS0yMDox
OTo1OSA2ZTQ2NjQ1MjViMWRiMjhmOGM0ZTExMzA5NTdmNzBhOTRjMTkyMTNlIHJldXNlIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi82ZTQ2NjQ1MjViMWRiMjhmOGM0ZTEx
MzA5NTdmNzBhOTRjMTkyMTNlL3ZtbGludXotMy4xMS4wCgoyMDEzLTA5LTE1LTIwOjIwOjAw
IGRldGVjdGluZyBib290IHN0YXRlIC4JNjMJNzAJNzYJODcJOTcJMTA0CTExMwkxMzIJMTQw
CTE0NQkxNTIJMTU2CTE2MAkxNjEJMTY2CTE3NQkxODcJMTkwCTE5NQkyMDUJMjE4CTIzOAky
NjUJMjk5CTMxNgkzMzkJMzYxCTM3MwkzOTQJNDExCTQ0MAk0NTYJNDc4CTQ5MAk1MDMJNTEy
CTUyMwk1MzMJNTQ1CTU1Mgk1NTQJNTU4CTU2MAk1NjEJNTYyCTU2NAk1NjguCTU3MAk1NzEJ
NTczLi4uLgk1NzQuCTU3Ngk1NzcuCTU4MC4JNTgyCTU4NC4uLi4uCTU4Nwk1ODkuLgk1OTAu
Lgk1OTEuCTU5Mgk1OTMuLi4uLi4JNjAxCTYwNC4JNjA1CTYxMAk2MTgJNjMzCTY0Mgk2NDgJ
NjY0CTY3MQk2NzMuLgk2ODEJNjg2CTY4Nwk2ODgJNjg5Li4JNjkxCTY5Mwk3MDEJNzE2CTcz
MAk3NjgJODEwCTg0OAk4NjYJODg5CTkwNwk5MjMJOTQzCTk5NgkxMDQ0CTEwNTgJMTA3MQkx
MDczCTEwNzQJMTA3NS4uCTEwNzguCTEwNzkuLi4uLi4uCTEwODAgU1VDQ0VTUwoKYmlzZWN0
OiBnb29kIGNvbW1pdCB2My4xMQpnaXQgYmlzZWN0IHN0YXJ0IDY2NmE1ODRkM2E3NjVhOTE0
NjQyZjgwZGVlZjdhMzNmYjMwOWRmNWQgdjMuMTEgLS0KUHJldmlvdXMgSEVBRCBwb3NpdGlv
biB3YXMgNmU0NjY0NS4uLiBMaW51eCAzLjExCkhFQUQgaXMgbm93IGF0IDNjMGVlZTMuLi4g
TGludXggMi42LjM3CkJpc2VjdGluZzogNDQ2MiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgMTIgc3RlcHMpClthMDllOWE3YTRiOTA3ZjJkZmE5YmRiMmI5
OGExODI4YWI0YjM0MGIyXSBNZXJnZSBicmFuY2ggJ2RybS1uZXh0JyBvZiBnaXQ6Ly9wZW9w
bGUuZnJlZWRlc2t0b3Aub3JnL35haXJsaWVkL2xpbnV4CmdpdCBiaXNlY3QgcnVuIC9jL2tl
cm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21tL29i
ai1iaXNlY3QKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3RlcjphMDll
OWE3YTRiOTA3ZjJkZmE5YmRiMmI5OGExODI4YWI0YjM0MGIyOmJpc2VjdC1tbQoKMjAxMy0w
OS0xNS0yMTozMTowOSBhMDllOWE3YTRiOTA3ZjJkZmE5YmRiMmI5OGExODI4YWI0YjM0MGIy
IGNvbXBpbGluZwoyODIgcmVhbCAgMTM0NSB1c2VyICAxNDIgc3lzICA1MjcuMTglIGNwdSAJ
aTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMgoKMjAxMy0wOS0xNS0yMTozNjozOCBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAzLjExLjAtMDQ4MDktZ2EwOWU5YTcuCTMJNwkxMAkxNAkxNgkxNwkx
OC4uLi4uCTE5CTIwLi4uLgkyMS4uLi4uLi4uLi4JMjIuLgkyMy4JMjYJMjcJMjkJMzMJMzQJ
NDAJNTIJNjkJOTMJMTMxCTE1NQkxOTEJMjEwCTIzOAkyNTAJMjU4CTI3MgkyODYJMjk1CTMx
NQkzNDUJMzY0CTM3NAkzODcJNDM1CTQ2OAk1NDUJNjAxCTcwMwk3NDcJOTIyCTEwMjIJMTA1
MgkxMDYwCTEwNzMJMTA3NgkxMDc4Li4uCTEwNzkuCTEwODAgU1VDQ0VTUwoKQmlzZWN0aW5n
OiAyMjg0IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMSBz
dGVwcykKWzhlNzNlMzY3ZjdkYzUwZjFkMWJjMjJhNjNlNTc2NGJiNGVlYTliNDhdIE1lcmdl
IHRhZyAnY2xlYW51cC1mb3ItbGludXMnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9z
Y20vbGludXgva2VybmVsL2dpdC9hcm0vYXJtLXNvYwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0
cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21tL29iai1iaXNlY3QK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pMDAy
LTA5MTIvbGludXM6bWFzdGVyOjhlNzNlMzY3ZjdkYzUwZjFkMWJjMjJhNjNlNTc2NGJiNGVl
YTliNDg6YmlzZWN0LW1tCgoyMDEzLTA5LTE1LTIyOjE1OjQxIDhlNzNlMzY3ZjdkYzUwZjFk
MWJjMjJhNjNlNTc2NGJiNGVlYTliNDggY29tcGlsaW5nCjIwMyByZWFsICAxMzU0IHVzZXIg
IDE0MCBzeXMgIDczNS40MSUgY3B1IAlpMzg2LXJhbmRjb25maWctaTAwMi0wOTEyCgoyMDEz
LTA5LTE1LTIyOjE5OjI2IGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wNjk4Ny1nOGU3
M2UzNi4JNgkxMwkxOAk0Nwk3NQk5NAkxMTgJMTQ3CTE2NwkxOTkJMjI3CTI1NgkyODUJMzA3
CTMzOQkzNjQJMzk1CTQyNQk0NDcJNDc5CTUwOAk1MjgJNTM4CTU0OAk1NTMJNTU1CTU1Nwk1
NjQJNTY3Lgk1NjguLgk1NjkJNTcwCTU3Mwk1ODEJNTk1CTYxMAk2MjQJNjY0CTc1Mgk4NTQJ
OTQwCTEwMTIJMTA2MAkxMDc4CTEwODAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxMTQ0IHJldmlz
aW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzY0YzM1
Mzg2NGUzZjdjY2JhMGFkZTFiZDZmNTYyZjlhM2JjN2U2OGRdIE1lcmdlIGJyYW5jaCAnZm9y
LXYzLjEyJyBvZiBnaXQ6Ly9naXQubGluYXJvLm9yZy9wZW9wbGUvbXN6eXByb3dza2kvbGlu
dXgtZG1hLW1hcHBpbmcKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9v
dC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVz
dHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3Rl
cjo2NGMzNTM4NjRlM2Y3Y2NiYTBhZGUxYmQ2ZjU2MmY5YTNiYzdlNjhkOmJpc2VjdC1tbQoK
MjAxMy0wOS0xNS0yMjo0Mzo1NyA2NGMzNTM4NjRlM2Y3Y2NiYTBhZGUxYmQ2ZjU2MmY5YTNi
YzdlNjhkIGNvbXBpbGluZwoxOTYgcmVhbCAgMTM1MiB1c2VyICAxMzcgc3lzICA3NTcuOTkl
IGNwdSAJaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMgoKMjAxMy0wOS0xNS0yMjo0NzozNCBk
ZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDgxMjctZzY0YzM1MzguCTMJNAk1Li4JNwkx
MgkxOAkyOQk0Mgk1Ngk3MQk4NwkxMDcJMTMwCTE0MS4JMjA3CTIyNQkyNjIJMjg0CTMyMQkz
NDQJMzc4CTQxMQk0MzgJNDYyCTQ5NQk1MjgJNTUxCTU4Mgk1OTkJNjEyCTYyMwk2MjcJNjM0
CTY0MQk2NDkJNjUxCTY3MAk2OTQJNzEwCTcyMgk3MzEJNzM3CTc1Mgk3NjgJNzc0CTc3OQk4
MTMJOTA1CTk4NAkxMDYyCTEwNjcJMTA3NAkxMDc5Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkxMDgwIFNVQ0NFU1MKCkJp
c2VjdGluZzogNTY4IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hs
eSA5IHN0ZXBzKQpbNjQwNDE0MTcxODE4YzYyOTNjMjNlNzRhMjhkMWM2OWIyYTFhN2ZlNV0g
TWVyZ2UgdGFnICdsYXRlLWZvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHVi
L3NjbS9saW51eC9rZXJuZWwvZ2l0L2FybS9hcm0tc29jCnJ1bm5pbmcgL2Mva2VybmVsLXRl
c3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2Vj
dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkw
MDItMDkxMi9saW51czptYXN0ZXI6NjQwNDE0MTcxODE4YzYyOTNjMjNlNzRhMjhkMWM2OWIy
YTFhN2ZlNTpiaXNlY3QtbW0KCjIwMTMtMDktMTYtMDA6MTQ6MDcgNjQwNDE0MTcxODE4YzYy
OTNjMjNlNzRhMjhkMWM2OWIyYTFhN2ZlNSByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pMDAyLTA5MTIvNjQwNDE0MTcxODE4YzYyOTNjMjNlNzRhMjhkMWM2OWIyYTFhN2ZlNS92
bWxpbnV6LTMuMTEuMC0wODcwMy1nNjQwNDE0MQoKMjAxMy0wOS0xNi0wMDoxNDowOCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAuLgkyCTUJMzcJMjA2CTI2MAkzODIJNDcwCTUzOQk3NDAJODUy
CTkzOQkxMDMwCTEwNjgJMTA3MgkxMDc3CTEwODAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyNzYg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDggc3RlcHMpCltm
YTE1ODZhN2U0Mzc2MGYwZTI1ZTcyYjJlM2Y5N2VlMThiMmJlOTY3XSBNZXJnZSBicmFuY2gg
J2RybS1maXhlcycgb2YgZ2l0Oi8vcGVvcGxlLmZyZWVkZXNrdG9wLm9yZy9+YWlybGllZC9s
aW51eApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUu
c2ggL2hvbWUvd2ZnL21tL29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVl
dWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvbGludXM6bWFzdGVyOmZhMTU4NmE3
ZTQzNzYwZjBlMjVlNzJiMmUzZjk3ZWUxOGIyYmU5Njc6YmlzZWN0LW1tCgoyMDEzLTA5LTE2
LTAwOjIzOjEwIGZhMTU4NmE3ZTQzNzYwZjBlMjVlNzJiMmUzZjk3ZWUxOGIyYmU5NjcgY29t
cGlsaW5nCjIwNyByZWFsICAxMzYyIHVzZXIgIDEzOSBzeXMgIDcyNC45MCUgY3B1IAlpMzg2
LXJhbmRjb25maWctaTAwMi0wOTEyCgoyMDEzLTA5LTE2LTAwOjI2OjU4IGRldGVjdGluZyBi
b290IHN0YXRlIDMuMTEuMC0wODk5NS1nZmExNTg2YQkxCTUJMTAJMTcJMjQJMzYJMzcJNDAJ
NDIuLgk0NAk0Nwk1NAk2MQk2OQk3NAk4NAk5NwkxMDkJMTI0CTEzNAkxNDcJMTYwCTE3NAkx
ODEJMTk1CTIwOAkyMTcJMjI0CTIyNwkyMzIJMjM1CTIzOAkyNDMJMjQ0CTI1MAkyNTQJMjU4
CTI2MAkyNjMJMjcwCTI3NgkyODAJMjg0CTI4NwkyODkuCTI5MQkyOTQJMzI5CTM1MgkzNzkJ
NDMyCTQ2OAk1MTAJNjAwCTY1OAk3MzgJNzg5CTg1NQk5MTIJOTg0CTEwNTIJMTA1MwkxMDcx
CTEwNzcJMTA3OAkxMDc5Li4uLi4uLi4uLi4uLi4JMTA4MCBTVUNDRVNTCgpCaXNlY3Rpbmc6
IDEzOCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNyBzdGVw
cykKW2JjNGI0NDQ4ZGJhNjYwYWZjOGRmMzc5MDU2NDMyMDMwMmQ5NzA5YTFdIG1tOiBtb3Zl
IHBndGFibGUgcmVsYXRlZCBmdW5jdGlvbnMgdG8gcmlnaHQgcGxhY2UKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9v
YmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRj
b25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3RlcjpiYzRiNDQ0OGRiYTY2MGFmYzhkZjM3OTA1
NjQzMjAzMDJkOTcwOWExOmJpc2VjdC1tbQoKMjAxMy0wOS0xNi0wMTowODo1OSBiYzRiNDQ0
OGRiYTY2MGFmYzhkZjM3OTA1NjQzMjAzMDJkOTcwOWExIGNvbXBpbGluZwoyMjAgcmVhbCAg
MTMzMiB1c2VyICAxMzggc3lzICA2NjYuOTglIGNwdSAJaTM4Ni1yYW5kY29uZmlnLWkwMDIt
MDkxMgoKMjAxMy0wOS0xNi0wMToxMzowMyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAt
MDkxMzMtZ2JjNGI0NDQuLi4uLi4uLi4uLi4uCTEuCTMuLi4JNQk2Li4JNy4JOAk5Li4uLgkx
MAkxMS4JMTMuCTMyCTMzCTE3MwkyNTAJMzE2CTQ1Mwk1MjkJNjQ5CTgxMAk5NDYJMTA2MAkx
MDY2CTEwNjkJMTA3MgkxMDc1CTEwNzYuLi4uLi4JMTA3OAkxMDc5CTEwODAgU1VDQ0VTUwoK
QmlzZWN0aW5nOiA2OSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdo
bHkgNiBzdGVwcykKWzMyNWM0ZWY1YzRiMTczNzJjMzIyMmQ4OTYwNDBkNzg0OGU2N2ZiZGJd
IG1tL21hZHZpc2UuYzptYWR2aXNlX2h3cG9pc29uKCk6IHJlbW92ZSBsb2NhbCBgcmV0Jwpy
dW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hv
bWUvd2ZnL21tL29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvbGludXM6bWFzdGVyOjMyNWM0ZWY1YzRiMTcz
NzJjMzIyMmQ4OTYwNDBkNzg0OGU2N2ZiZGI6YmlzZWN0LW1tCgoyMDEzLTA5LTE2LTAxOjQz
OjM0IDMyNWM0ZWY1YzRiMTczNzJjMzIyMmQ4OTYwNDBkNzg0OGU2N2ZiZGIgY29tcGlsaW5n
CjIwMSByZWFsICAxMzcyIHVzZXIgIDE0MCBzeXMgIDc0OS43NSUgY3B1IAlpMzg2LXJhbmRj
b25maWctaTAwMi0wOTEyCgoyMDEzLTA5LTE2LTAxOjQ3OjE3IGRldGVjdGluZyBib290IHN0
YXRlIDMuMTEuMC0wOTIwMi1nMzI1YzRlZi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uCTIJMTYJODEJMTMzIFRFU1QgRkFJTFVSRQobWzE7MzVtSW5jcmVhc2luZyBy
ZXBlYXQgY291bnQgZnJvbSAxMDgwIHRvIDEzNDAbWzBtClsgICAgMy45NzAyODhdIHRzYzog
UmVmaW5lZCBUU0MgY2xvY2tzb3VyY2UgY2FsaWJyYXRpb246IDI2NjYuNjAwIE1IegpbICAg
IDQuMTYwMDUyXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICA0
LjE2MDg3N10gV0FSTklORzogQ1BVOiAxIFBJRDogOSBhdCAvYy93ZmcvbW0vbGliL2xpc3Rf
ZGVidWcuYzozMyBfX2xpc3RfYWRkKzB4NmMvMHhhZSgpClsgICAgNC4xNjIxNzhdIGxpc3Rf
YWRkIGNvcnJ1cHRpb24uIHByZXYtPm5leHQgc2hvdWxkIGJlIG5leHQgKDc4MTAwM2MwKSwg
YnV0IHdhcyA2Zjk2NTQwOC4gKHByZXY9NzgxOGUxNzApLgpbICAgIDQuMTYzNjY3XSBNb2R1
bGVzIGxpbmtlZCBpbjoKWyAgICA0LjE2NDE4OF0gQ1BVOiAxIFBJRDogOSBDb21tOiByY3Vf
c2NoZWQgTm90IHRhaW50ZWQgMy4xMS4wLTA5MjAyLWczMjVjNGVmICMzMzAKWyAgICA0LjE2
NTM0N10gIDAwMDAwMDAwIDAwMDAwMDAwIDc4MDY3ZGY0IDc5MjBkNjNiIDc4MDY3ZTM0IDc4
MDY3ZTI0IDc5MDMwZWEyIDc5MmYyZDUxClsgICAgNC4xNjY3NDRdICA3ODA2N2U1MCAwMDAw
MDAwOSA3OTJmMmQzNiAwMDAwMDAyMSA3OTEwNmNjMiA3OTEwNmNjMiA3ODE4ZTE3MCA3ODEw
MDNjMApbICAgIDQuMTY4MTQ5XSAgNzgwNjdlYTAgNzgwNjdlM2MgNzkwMzBlZTcgMDAwMDAw
MDkgNzgwNjdlMzQgNzkyZjJkNTEgNzgwNjdlNTAgNzgwNjdlNjgKWyAgICA0LjE2OTU0OF0g
Q2FsbCBUcmFjZToKWyAgICA0LjE2OTk2NF0gIFs8NzkyMGQ2M2I+XSBkdW1wX3N0YWNrKzB4
NGIvMHg2NgpbICAgIDQuMTcwMDE1XSAgWzw3OTAzMGVhMj5dIHdhcm5fc2xvd3BhdGhfY29t
bW9uKzB4NzQvMHg4YgpbICAgIDQuMTcwMDE1XSAgWzw3OTEwNmNjMj5dID8gX19saXN0X2Fk
ZCsweDZjLzB4YWUKWyAgICA0LjE3MDAxNV0gIFs8NzkxMDZjYzI+XSA/IF9fbGlzdF9hZGQr
MHg2Yy8weGFlClsgICAgNC4xNzAwMTVdICBbPDc5MDMwZWU3Pl0gd2Fybl9zbG93cGF0aF9m
bXQrMHgyZS8weDMwClsgICAgNC4xNzAwMTVdICBbPDc5MTA2Y2MyPl0gX19saXN0X2FkZCsw
eDZjLzB4YWUKWyAgICA0LjE3MDAxNV0gIFs8NzkwMzcxNzc+XSBfX2ludGVybmFsX2FkZF90
aW1lcisweDhhLzB4OGUKWyAgICA0LjE3MDAxNV0gIFs8NzkwMzcxODk+XSBpbnRlcm5hbF9h
ZGRfdGltZXIrMHhlLzB4MjYKWyAgICA0LjE3MDAxNV0gIFs8NzkyMGRlNDY+XSBzY2hlZHVs
ZV90aW1lb3V0KzB4MTI2LzB4MTZlClsgICAgNC4xNzAwMTVdICBbPDc5MDM3MjQzPl0gPyBj
YXNjYWRlKzB4NWEvMHg1YQpbICAgIDQuMTcwMDE1XSAgWzw3OTA3YmViYj5dIHJjdV9ncF9r
dGhyZWFkKzB4Mjk5LzB4NDY3ClsgICAgNC4xNzAwMTVdICBbPDc5MDQ2MGYxPl0gPyBhYm9y
dF9leGNsdXNpdmVfd2FpdCsweDYzLzB4NjMKWyAgICA0LjE3MDAxNV0gIFs8NzkwN2JjMjI+
XSA/IHJjdV9ncF9mcXMrMHg2YS8weDZhClsgICAgNC4xNzAwMTVdICBbPDc5MDQ1OTRiPl0g
a3RocmVhZCsweDk1LzB4OWEKWyAgICA0LjE3MDAxNV0gIFs8NzkwNDAwMDA+XSA/IGRlc3Ry
b3lfd29ya3F1ZXVlKzB4ODkvMHgxNzkKWyAgICA0LjE3MDAxNV0gIFs8NzkyMTJiM2I+XSBy
ZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4MWIvMHgzMApbICAgIDQuMTcwMDE1XSAgWzw3OTA0
NThiNj5dID8ga3RocmVhZF9zdG9wKzB4NGUvMHg0ZQpbICAgIDQuMTcwMDE1XSAtLS1bIGVu
ZCB0cmFjZSAzZWRiNDBkNWVkYjQzZTBhIF0tLS0KL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aTAwMi0wOTEyLzMyNWM0ZWY1YzRiMTczNzJjMzIyMmQ4OTYwNDBkNzg0OGU2N2ZiZGIvZG1l
c2ctcXVhbnRhbC1iZW5zLTE6MjAxMzA5MTYwMjA3NDg6My4xMS4wLTA5MjAyLWczMjVjNGVm
OjMzMAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvMzI1YzRlZjVjNGIxNzM3
MmMzMjIyZDg5NjA0MGQ3ODQ4ZTY3ZmJkYi9kbWVzZy1xdWFudGFsLXhpYW4tOToyMDEzMDkx
NjAyMDgxNjozLjExLjAtMTAxMDUtZ2QwMWVlMzM6NQoKQmlzZWN0aW5nOiAzNCByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVwcykKW2U3NmI2M2Y4
MGQ5MzhhMTMxOWViNWZiMGFlN2VhNjliZGRmYmFlMzhdIG1lbWJsb2NrLCBudW1hOiBiaW5h
cnkgc2VhcmNoIG5vZGUgaWQKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1h
c3RlcjplNzZiNjNmODBkOTM4YTEzMTllYjVmYjBhZTdlYTY5YmRkZmJhZTM4OmJpc2VjdC1t
bQoKMjAxMy0wOS0xNi0wMjowODoyMCBlNzZiNjNmODBkOTM4YTEzMTllYjVmYjBhZTdlYTY5
YmRkZmJhZTM4IGNvbXBpbGluZwoyMDcgcmVhbCAgMTM1OSB1c2VyICAxNDEgc3lzICA3MjIu
NjglIGNwdSAJaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMgoKMjAxMy0wOS0xNi0wMjoxMjoy
MiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjExLjAtMDkxNjctZ2U3NmI2M2YJNDEJMTA2CTE5
NAkyODEJNDEwCTUyMAk2MjgJNzI1CTgzOAk5NTEJMTA1MwkxMTY1CTEyNzMJMTMyNgkxMzMz
CTEzMzcJMTMzOS4uLi4uLi4uLi4uLi4JMTM0MCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDE3IHJl
dmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbNzYy
MjE2YWI0ZTE3NWY0OWQxN2JjN2FkNzc4YzU3YjkwMjgxODRlNl0gbW0vdm1hbGxvYzogdXNl
IHdyYXBwZXIgZnVuY3Rpb24gZ2V0X3ZtX2FyZWFfc2l6ZSB0byBjYWN1bGF0ZSBzaXplIG9m
IHZtIGFyZWEKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyL2xpbnVzOm1hc3Rlcjo3NjIy
MTZhYjRlMTc1ZjQ5ZDE3YmM3YWQ3NzhjNTdiOTAyODE4NGU2OmJpc2VjdC1tbQoKMjAxMy0w
OS0xNi0wMjoyNzo1MyA3NjIyMTZhYjRlMTc1ZjQ5ZDE3YmM3YWQ3NzhjNTdiOTAyODE4NGU2
IGNvbXBpbGluZwoxOTIgcmVhbCAgMTMzNCB1c2VyICAxMzggc3lzICA3NjQuOTglIGNwdSAJ
aTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMgoKMjAxMy0wOS0xNi0wMjozMToyMyBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAzLjExLjAtMDkxODQtZzc2MjIxNmEuCTEuCTIuLi4uCTMJNAk1CTYJ
OAkxNgkyNQk0MQk0OQk2MQk4MAk4OQkxMDcJMTIxCTEzMQkxNDgJMTYzCTE3NwkxOTQJMjEw
CTIyNgkyNDUJMjY4CTI4MwkzMDMJMzE5CTMyNQkzNTAJNDA5CTQ5MAk2MDQJNzA4IFRFU1Qg
RkFJTFVSRQobWzE7MzVtSW5jcmVhc2luZyByZXBlYXQgY291bnQgZnJvbSAxMzQwIHRvIDM1
MTcbWzBtCgpbICAgNDkuNTEyMzQxXSBpbml0OiB1ZGV2IG1haW4gcHJvY2VzcyAoMTg4KSB0
ZXJtaW5hdGVkIHdpdGggc3RhdHVzIDQKWyAgIDQ5LjUxODU3M10gQlVHOiBCYWQgcGFnZSBt
YXAgaW4gcHJvY2VzcyBraWxsYWxsNSAgcHRlOjdmNjIyMTQwIHBtZDowNzYwNTA2NwpbICAg
NDkuNTE5NTg3XSBhZGRyOjBhMDAwMDAwIHZtX2ZsYWdzOjAwMTAwMDczIGFub25fdm1hOjdm
NjQyNTUwIG1hcHBpbmc6ICAobnVsbCkgaW5kZXg6YTAwMApbICAgNDkuNTIwNzU5XSBDUFU6
IDAgUElEOiAxODcgQ29tbToga2lsbGFsbDUgTm90IHRhaW50ZWQgMy4xMS4wLTA5MTg0LWc3
NjIyMTZhICMzMzIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyLzc2MjIxNmFi
NGUxNzVmNDlkMTdiYzdhZDc3OGM1N2I5MDI4MTg0ZTYvZG1lc2ctcXVhbnRhbC14aWFuLTEx
OjIwMTMwOTE2MDI1MDQ1OjMuMTEuMC0xMDA3MS1nNTI2ZmQ2YjoxMTUKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaTAwMi0wOTEyLzc2MjIxNmFiNGUxNzVmNDlkMTdiYzdhZDc3OGM1N2I5
MDI4MTg0ZTYvZG1lc2ctcXVhbnRhbC1hbnQtNzoyMDEzMDkxNjAyNTA1NTozLjExLjAtMTAw
NzEtZzUyNmZkNmI6MTEzCgpCaXNlY3Rpbmc6IDggcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBh
ZnRlciB0aGlzIChyb3VnaGx5IDMgc3RlcHMpCls1ODZhMzJhYzFkMzNjZTdhNzU0OGEyN2U0
MDg3ZTk4ODQyYzNhMDZmXSBtbTogbXVubG9jazogcmVtb3ZlIHVubmVjZXNzYXJ5IGNhbGwg
dG8gbHJ1X2FkZF9kcmFpbigpCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAva2VybmVs
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi9saW51czpt
YXN0ZXI6NTg2YTMyYWMxZDMzY2U3YTc1NDhhMjdlNDA4N2U5ODg0MmMzYTA2ZjpiaXNlY3Qt
bW0KCjIwMTMtMDktMTYtMDI6NTE6MjYgNTg2YTMyYWMxZDMzY2U3YTc1NDhhMjdlNDA4N2U5
ODg0MmMzYTA2ZiBjb21waWxpbmcKMzIwIHJlYWwgIDEzNDAgdXNlciAgMTM5IHN5cyAgNDYx
LjkyJSBjcHUgCWkzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIKCjIwMTMtMDktMTYtMDI6NTc6
MzMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTA5MTc1LWc1ODZhMzJhCTEJMwk3CTE0
CTI2CTQwCTUwCTYxCTY5CTgyCTk2CTEwNwkxMTcJMTMyCTE0NQkxNjEJMTcyCTE5MAkyMDAJ
MjE4CTIyOQkyNDgJMjU5CTI3MwkyOTAJMzAzCTMyMQkzMzAJMzQzCTM2MAkzNzcJMzgxCTM4
NQkzOTQJNDA5CTQyNgk0MzUJNDQ3CTQ2OAk0NzcJNDkyCTUxMAk1MjcJNTM3CTU1MQk1NzAJ
NTg0CTU5NAk1OTgJNjAzCTYwNQk2MDgJNjE0CTYxOQk2MjMJNjg3CTc3Mwk4NDcJOTQ0CTEw
NTYJMTE3NAkxMjg5CTEzOTUJMTUxNgkxNjIzCTE3NDYJMTg0NAkxOTQ5CTIwMzcJMjE1Mwky
MjU3CTIzNzMJMjQ3MQkyNTgzCTI2ODQJMjc4MAkyODg2CTI5ODcJMzA5MAkzMTc1CTMyMTMJ
MzQwNgkzNDk2CTM1MDAJMzUwOQkzNTE3IFNVQ0NFU1MKCkJpc2VjdGluZzogNCByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMiBzdGVwcykKWzViNDA5OThh
ZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjddIG1tOiBtdW5sb2NrOiByZW1vdmUg
cmVkdW5kYW50IGdldF9wYWdlL3B1dF9wYWdlIHBhaXIgb24gdGhlIGZhc3QgcGF0aApydW5u
aW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUv
d2ZnL21tL29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvbGludXM6bWFzdGVyOjViNDA5OThhZTM1Y2Y2NDU2
MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjc6YmlzZWN0LW1tCgoyMDEzLTA5LTE2LTAzOjQwOjM1
IDViNDA5OThhZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjcgY29tcGlsaW5nCjY4
IHJlYWwgIDE0OCB1c2VyICAyMyBzeXMgIDI1MC43NCUgY3B1IAlpMzg2LXJhbmRjb25maWct
aTAwMi0wOTEyCgoyMDEzLTA5LTE2LTAzOjQyOjEwIGRldGVjdGluZyBib290IHN0YXRlIDMu
MTEuMC0wOTE3OS1nNWI0MDk5OC4JOQkxOAkzNgk0MAk0OAk1Mwk1OAk2NQk3Nwk4OQk5OQkx
MDgJMTI1CTEzOAkxNTAJMTU2CTE3MAkxODEJMjA1CTIyOAkyNTAJMjc1CTI5NwkzMTgJMzQ3
CTM2NgkzOTcJNDE0CTQzNgk0NjEJNDc5CTUwNwk1MjUJNTQ1CTU3NAk1OTAJNjE5CTY0NQk2
NjgJNjkwCTY5NAk3MDIJNzE2CTczMQk3NjAJNzg5CTgwNQk4MzIJODYyCTg3OAk5MDQJOTMw
CTk2NQkxMDM3CTExMTEJMTIwOQkxMzExCTE0MDEJMTUwMAkxNjA1CTE3MDgJMTgxNgkxOTEz
CTIwMzEJMjEzNQkyMjM5CTIyOTEJMjQ1OQkyNTYxCTI2NzMJMjc4OAkyODk3CTI5OTMJMzEx
NgkzMjI3CTMzMjUJMzQxNwkzNDk4CTM1MDYJMzUxMgkzNTE2CTM1MTcgU1VDQ0VTUwoKQmlz
ZWN0aW5nOiAyIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAx
IHN0ZXApCls2ZTU0M2Q1NzgwZTM2ZmY1ZWU1NmM0NGQ3ZTJlMzBkYjM0NTdhN2VkXSBtbTog
dm1zY2FuOiBmaXggZG9fdHJ5X3RvX2ZyZWVfcGFnZXMoKSBsaXZlbG9jawpydW5uaW5nIC9j
L2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21t
L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFu
ZGNvbmZpZy1pMDAyLTA5MTIvbGludXM6bWFzdGVyOjZlNTQzZDU3ODBlMzZmZjVlZTU2YzQ0
ZDdlMmUzMGRiMzQ1N2E3ZWQ6YmlzZWN0LW1tCgoyMDEzLTA5LTE2LTA0OjIzOjQyIDZlNTQz
ZDU3ODBlMzZmZjVlZTU2YzQ0ZDdlMmUzMGRiMzQ1N2E3ZWQgY29tcGlsaW5nCjE3NyByZWFs
ICAxMzU4IHVzZXIgIDEzOSBzeXMgIDg0My4yNSUgY3B1IAlpMzg2LXJhbmRjb25maWctaTAw
Mi0wOTEyCgoyMDEzLTA5LTE2LTA0OjI3OjAzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTEu
MC0wOTE4MS1nNmU1NDNkNS4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkxCTIu
Li4uLi4uLi4uLi4uLgk4CTYzCTE0OCBURVNUIEZBSUxVUkUKWyAgICAzLjg1MDE1NF0gdHNj
OiBSZWZpbmVkIFRTQyBjbG9ja3NvdXJjZSBjYWxpYnJhdGlvbjogMjk5Mi40OTAgTUh6Clsg
ICAgNC4wNjAwNjBdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAg
IDQuMDYwNzI3XSBXQVJOSU5HOiBDUFU6IDEgUElEOiA5IGF0IC9jL3dmZy9tbS9saWIvbGlz
dF9kZWJ1Zy5jOjMzIF9fbGlzdF9hZGQrMHg2Yy8weGFlKCkKWyAgICA0LjA2MTgxM10gbGlz
dF9hZGQgY29ycnVwdGlvbi4gcHJldi0+bmV4dCBzaG91bGQgYmUgbmV4dCAoNzgxMDAzNzAp
LCBidXQgd2FzICAgKG51bGwpLiAocHJldj03ODA5MTU3MCkuClsgICAgNC4wNjMwNjldIE1v
ZHVsZXMgbGlua2VkIGluOgpbICAgIDQuMDYzNTAzXSBDUFU6IDEgUElEOiA5IENvbW06IHJj
dV9zY2hlZCBOb3QgdGFpbnRlZCAzLjExLjAtMDkxODEtZzZlNTQzZDUgIzMzNQpbICAgIDQu
MDY0NDc3XSAgMDAwMDAwMDAgMDAwMDAwMDAgNzgwNjdkZjQgNzkyMGQzY2IgNzgwNjdlMzQg
NzgwNjdlMjQgNzkwMzBlYTIgNzkyZjJkNzEKWyAgICA0LjA2NTY1MF0gIDc4MDY3ZTUwIDAw
MDAwMDA5IDc5MmYyZDU2IDAwMDAwMDIxIDc5MTA2YTUyIDc5MTA2YTUyIDc4MDkxNTcwIDc4
MTAwMzcwClsgICAgNC4wNjY4MjNdICA3ODA2N2VhMCA3ODA2N2UzYyA3OTAzMGVlNyAwMDAw
MDAwOSA3ODA2N2UzNCA3OTJmMmQ3MSA3ODA2N2U1MCA3ODA2N2U2OApbICAgIDQuMDY4MDAz
XSBDYWxsIFRyYWNlOgpbICAgIDQuMDY4MzQ3XSAgWzw3OTIwZDNjYj5dIGR1bXBfc3RhY2sr
MHg0Yi8weDY2ClsgICAgNC4wNjg5NDJdICBbPDc5MDMwZWEyPl0gd2Fybl9zbG93cGF0aF9j
b21tb24rMHg3NC8weDhiClsgICAgNC4wNjk2NTFdICBbPDc5MTA2YTUyPl0gPyBfX2xpc3Rf
YWRkKzB4NmMvMHhhZQpbICAgIDQuMDcwMDE5XSAgWzw3OTEwNmE1Mj5dID8gX19saXN0X2Fk
ZCsweDZjLzB4YWUKWyAgICA0LjA3MDAxOV0gIFs8NzkwMzBlZTc+XSB3YXJuX3Nsb3dwYXRo
X2ZtdCsweDJlLzB4MzAKWyAgICA0LjA3MDAxOV0gIFs8NzkxMDZhNTI+XSBfX2xpc3RfYWRk
KzB4NmMvMHhhZQpbICAgIDQuMDcwMDE5XSAgWzw3OTAzNzE3Nz5dIF9faW50ZXJuYWxfYWRk
X3RpbWVyKzB4OGEvMHg4ZQpbICAgIDQuMDcwMDE5XSAgWzw3OTAzNzE4OT5dIGludGVybmFs
X2FkZF90aW1lcisweGUvMHgyNgpbICAgIDQuMDcwMDE5XSAgWzw3OTIwZGJkNj5dIHNjaGVk
dWxlX3RpbWVvdXQrMHgxMjYvMHgxNmUKWyAgICA0LjA3MDAxOV0gIFs8NzkwMzcyNDM+XSA/
IGNhc2NhZGUrMHg1YS8weDVhClsgICAgNC4wNzAwMTldICBbPDc5MDdiZWJiPl0gcmN1X2dw
X2t0aHJlYWQrMHgyOTkvMHg0NjcKWyAgICA0LjA3MDAxOV0gIFs8NzkwNDYwZjE+XSA/IGFi
b3J0X2V4Y2x1c2l2ZV93YWl0KzB4NjMvMHg2MwpbICAgIDQuMDcwMDE5XSAgWzw3OTA3YmMy
Mj5dID8gcmN1X2dwX2ZxcysweDZhLzB4NmEKWyAgICA0LjA3MDAxOV0gIFs8NzkwNDU5NGI+
XSBrdGhyZWFkKzB4OTUvMHg5YQpbICAgIDQuMDcwMDE5XSAgWzw3OTA0MDAwMD5dID8gZGVz
dHJveV93b3JrcXVldWUrMHg4OS8weDE3OQpbICAgIDQuMDcwMDE5XSAgWzw3OTIxMjhiYj5d
IHJldF9mcm9tX2tlcm5lbF90aHJlYWQrMHgxYi8weDMwClsgICAgNC4wNzAwMTldICBbPDc5
MDQ1OGI2Pl0gPyBrdGhyZWFkX3N0b3ArMHg0ZS8weDRlClsgICAgNC4wNzAwMTldIC0tLVsg
ZW5kIHRyYWNlIDdkNjgyZDljZjNhNTQyMzUgXS0tLQova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pMDAyLTA5MTIvNmU1NDNkNTc4MGUzNmZmNWVlNTZjNDRkN2UyZTMwZGIzNDU3YTdlZC9k
bWVzZy1xdWFudGFsLXJvYW0tMjM6MjAxMzA5MTYwNDUyMzA6My4xMS4wLTEwMDcxLWc1MjZm
ZDZiOjU5CgpCaXNlY3Rpbmc6IDAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDAgc3RlcHMpCls3YTgwMTBjZDM2MjczZmY1ZjZmZWE1MjAxZWY5MjMyZjMw
Y2ViYmQ5XSBtbTogbXVubG9jazogbWFudWFsIHB0ZSB3YWxrIGluIGZhc3QgcGF0aCBpbnN0
ZWFkIG9mIGZvbGxvd19wYWdlX21hc2soKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL21tL29iai1iaXNlY3QKbHMgLWEg
L2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIv
bGludXM6bWFzdGVyOjdhODAxMGNkMzYyNzNmZjVmNmZlYTUyMDFlZjkyMzJmMzBjZWJiZDk6
YmlzZWN0LW1tCgoyMDEzLTA5LTE2LTA0OjUzOjA3IDdhODAxMGNkMzYyNzNmZjVmNmZlYTUy
MDFlZjkyMzJmMzBjZWJiZDkgY29tcGlsaW5nCjQ5NyByZWFsICAxMzQ2IHVzZXIgIDE0MyBz
eXMgIDI5OS41NyUgY3B1IAlpMzg2LXJhbmRjb25maWctaTAwMi0wOTEyCgoyMDEzLTA5LTE2
LTA1OjAyOjQ1IGRldGVjdGluZyBib290IHN0YXRlIDMuMTEuMC0wOTE4MC1nN2E4MDEwYwk2
OSBURVNUIEZBSUxVUkUKWyAgICA0Ljk5MDIxNF0gdHNjOiBSZWZpbmVkIFRTQyBjbG9ja3Nv
dXJjZSBjYWxpYnJhdGlvbjogMjY2Ni42MDMgTUh6ClsgICAgNS4xODA2MDddIC0tLS0tLS0t
LS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDUuMTgxNDI4XSBXQVJOSU5HOiBD
UFU6IDEgUElEOiA5IGF0IC9jL3dmZy9tbS9saWIvbGlzdF9kZWJ1Zy5jOjMzIF9fbGlzdF9h
ZGQrMHg2Yy8weGFlKCkKWyAgICA1LjE4MjcyM10gbGlzdF9hZGQgY29ycnVwdGlvbi4gcHJl
di0+bmV4dCBzaG91bGQgYmUgbmV4dCAoNzgxMDA2ZTgpLCBidXQgd2FzIDcwMWQxZjg4LiAo
cHJldj03ODFhYzE3MCkuClsgICAgNS4xODQyMDNdIE1vZHVsZXMgbGlua2VkIGluOgpbICAg
IDUuMTg0NzIxXSBDUFU6IDEgUElEOiA5IENvbW06IHJjdV9zY2hlZCBOb3QgdGFpbnRlZCAz
LjExLjAtMDkxODAtZzdhODAxMGMgIzMzNgpbICAgIDUuMTg1ODc0XSAgMDAwMDAwMDAgMDAw
MDAwMDAgNzgwNjdkZjQgNzkyMGQzYWIgNzgwNjdlMzQgNzgwNjdlMjQgNzkwMzBlYTIgNzky
ZjJkNjEKWyAgICA1LjE4NzI1Nl0gIDc4MDY3ZTUwIDAwMDAwMDA5IDc5MmYyZDQ2IDAwMDAw
MDIxIDc5MTA2YTMyIDc5MTA2YTMyIDc4MWFjMTcwIDc4MTAwNmU4ClsgICAgNS4xODg2Mzld
ICA3ODA2N2VhMCA3ODA2N2UzYyA3OTAzMGVlNyAwMDAwMDAwOSA3ODA2N2UzNCA3OTJmMmQ2
MSA3ODA2N2U1MCA3ODA2N2U2OApbICAgIDUuMTkwMDE1XSBDYWxsIFRyYWNlOgpbICAgIDUu
MTkwMDE1XSAgWzw3OTIwZDNhYj5dIGR1bXBfc3RhY2srMHg0Yi8weDY2ClsgICAgNS4xOTAw
MTVdICBbPDc5MDMwZWEyPl0gd2Fybl9zbG93cGF0aF9jb21tb24rMHg3NC8weDhiClsgICAg
NS4xOTAwMTVdICBbPDc5MTA2YTMyPl0gPyBfX2xpc3RfYWRkKzB4NmMvMHhhZQpbICAgIDUu
MTkwMDE1XSAgWzw3OTEwNmEzMj5dID8gX19saXN0X2FkZCsweDZjLzB4YWUKWyAgICA1LjE5
MDAxNV0gIFs8NzkwMzBlZTc+XSB3YXJuX3Nsb3dwYXRoX2ZtdCsweDJlLzB4MzAKWyAgICA1
LjE5MDAxNV0gIFs8NzkxMDZhMzI+XSBfX2xpc3RfYWRkKzB4NmMvMHhhZQpbICAgIDUuMTkw
MDE1XSAgWzw3OTAzNzE3Nz5dIF9faW50ZXJuYWxfYWRkX3RpbWVyKzB4OGEvMHg4ZQpbICAg
IDUuMTkwMDE1XSAgWzw3OTAzNzE4OT5dIGludGVybmFsX2FkZF90aW1lcisweGUvMHgyNgpb
ICAgIDUuMTkwMDE1XSAgWzw3OTIwZGJiNj5dIHNjaGVkdWxlX3RpbWVvdXQrMHgxMjYvMHgx
NmUKWyAgICA1LjE5MDAxNV0gIFs8NzkwMzcyNDM+XSA/IGNhc2NhZGUrMHg1YS8weDVhClsg
ICAgNS4xOTAwMTVdICBbPDc5MDdiZWJiPl0gcmN1X2dwX2t0aHJlYWQrMHgyOTkvMHg0NjcK
WyAgICA1LjE5MDAxNV0gIFs8NzkwNDYwZjE+XSA/IGFib3J0X2V4Y2x1c2l2ZV93YWl0KzB4
NjMvMHg2MwpbICAgIDUuMTkwMDE1XSAgWzw3OTA3YmMyMj5dID8gcmN1X2dwX2ZxcysweDZh
LzB4NmEKWyAgICA1LjE5MDAxNV0gIFs8NzkwNDU5NGI+XSBrdGhyZWFkKzB4OTUvMHg5YQpb
ICAgIDUuMTkwMDE1XSAgWzw3OTA0MDAwMD5dID8gZGVzdHJveV93b3JrcXVldWUrMHg4OS8w
eDE3OQpbICAgIDUuMTkwMDE1XSAgWzw3OTIxMjg3Yj5dIHJldF9mcm9tX2tlcm5lbF90aHJl
YWQrMHgxYi8weDMwClsgICAgNS4xOTAwMTVdICBbPDc5MDQ1OGI2Pl0gPyBrdGhyZWFkX3N0
b3ArMHg0ZS8weDRlClsgICAgNS4xOTAwMTVdIC0tLVsgZW5kIHRyYWNlIDVkOTM2NGZiNzk5
NTU3MWMgXS0tLQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvN2E4MDEwY2Qz
NjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOS9kbWVzZy1xdWFudGFsLXJvYW0tNjoy
MDEzMDkxNjA1MDI1MTozLjExLjAtMTAwNzEtZzUyNmZkNmI6NwoKN2E4MDEwY2QzNjI3M2Zm
NWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOSBpcyB0aGUgZmlyc3QgYmFkIGNvbW1pdApjb21t
aXQgN2E4MDEwY2QzNjI3M2ZmNWY2ZmVhNTIwMWVmOTIzMmYzMGNlYmJkOQpBdXRob3I6IFZs
YXN0aW1pbCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+CkRhdGU6ICAgV2VkIFNlcCAxMSAxNDoy
MjozNSAyMDEzIC0wNzAwCgogICAgbW06IG11bmxvY2s6IG1hbnVhbCBwdGUgd2FsayBpbiBm
YXN0IHBhdGggaW5zdGVhZCBvZiBmb2xsb3dfcGFnZV9tYXNrKCkKICAgIAogICAgQ3VycmVu
dGx5IG11bmxvY2tfdm1hX3BhZ2VzX3JhbmdlKCkgY2FsbHMgZm9sbG93X3BhZ2VfbWFzaygp
IHRvIG9idGFpbgogICAgZWFjaCBpbmRpdmlkdWFsIHN0cnVjdCBwYWdlLiAgVGhpcyBlbnRh
aWxzIHJlcGVhdGVkIGZ1bGwgcGFnZSB0YWJsZQogICAgdHJhbnNsYXRpb25zIGFuZCBwYWdl
IHRhYmxlIGxvY2sgdGFrZW4gZm9yIGVhY2ggcGFnZSBzZXBhcmF0ZWx5LgogICAgCiAgICBU
aGlzIHBhdGNoIGF2b2lkcyB0aGUgY29zdGx5IGZvbGxvd19wYWdlX21hc2soKSB3aGVyZSBw
b3NzaWJsZSwgYnkKICAgIGl0ZXJhdGluZyBvdmVyIHB0ZXMgd2l0aGluIHNpbmdsZSBwbWQg
dW5kZXIgc2luZ2xlIHBhZ2UgdGFibGUgbG9jay4gIFRoZQogICAgZmlyc3QgcHRlIGlzIG9i
dGFpbmVkIGJ5IGdldF9sb2NrZWRfcHRlKCkgZm9yIG5vbi1USFAgcGFnZSBhY3F1aXJlZCBi
eSB0aGUKICAgIGluaXRpYWwgZm9sbG93X3BhZ2VfbWFzaygpLiAgVGhlIHJlc3Qgb2YgdGhl
IG9uLXN0YWNrIHBhZ2V2ZWMgZm9yIG11bmxvY2sKICAgIGlzIGZpbGxlZCB1cCB1c2luZyBw
dGVfd2FsayBhcyBsb25nIGFzIHB0ZV9wcmVzZW50KCkgYW5kIHZtX25vcm1hbF9wYWdlKCkK
ICAgIGFyZSBzdWZmaWNpZW50IHRvIG9idGFpbiB0aGUgc3RydWN0IHBhZ2UuCiAgICAKICAg
IEFmdGVyIHRoaXMgcGF0Y2gsIGEgMTQlIHNwZWVkdXAgd2FzIG1lYXN1cmVkIGZvciBtdW5s
b2NraW5nIGEgNTZHQiBsYXJnZQogICAgbWVtb3J5IGFyZWEgd2l0aCBUSFAgZGlzYWJsZWQu
CiAgICAKICAgIFNpZ25lZC1vZmYtYnk6IFZsYXN0aW1pbCBCYWJrYSA8dmJhYmthQHN1c2Uu
Y3o+CiAgICBDYzogSsO2cm4gRW5nZWwgPGpvZXJuQGxvZ2ZzLm9yZz4KICAgIENjOiBNZWwg
R29ybWFuIDxtZ29ybWFuQHN1c2UuZGU+CiAgICBDYzogTWljaGVsIExlc3BpbmFzc2UgPHdh
bGtlbkBnb29nbGUuY29tPgogICAgQ2M6IEh1Z2ggRGlja2lucyA8aHVnaGRAZ29vZ2xlLmNv
bT4KICAgIENjOiBSaWsgdmFuIFJpZWwgPHJpZWxAcmVkaGF0LmNvbT4KICAgIENjOiBKb2hh
bm5lcyBXZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4KICAgIENjOiBNaWNoYWwgSG9ja28g
PG1ob2Nrb0BzdXNlLmN6PgogICAgQ2M6IFZsYXN0aW1pbCBCYWJrYSA8dmJhYmthQHN1c2Uu
Y3o+CiAgICBTaWduZWQtb2ZmLWJ5OiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5k
YXRpb24ub3JnPgogICAgU2lnbmVkLW9mZi1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRz
QGxpbnV4LWZvdW5kYXRpb24ub3JnPgoKOjA0MDAwMCAwNDAwMDAgMWE0YTAyNjE0NDlmNTkz
MjllMTk3YTBkYjZlZjRkMzAyZDMxY2JhOCA5ZDYwZDQ0ZmE0MTY4YmU0ZWI3N2U4NjZkZDI3
Y2Q2ZDZmMjU5ODc5IE0JaW5jbHVkZQo6MDQwMDAwIDA0MDAwMCBlOGU3NTIzZGVhZmY1NjVk
MDQxY2U0NTM1NmE0NDRkZWJiMmM2YzUzIDk1MTg2MmNhYjY4OWE2MmNkOWI4ODBiZjE2OTI4
MDEwNzBkNzM2ZjYgTQltbQpiaXNlY3QgcnVuIHN1Y2Nlc3MKbHMgLWEgL2tlcm5lbC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pMDAyLTA5MTIvbGludXM6bWFzdGVy
OjViNDA5OThhZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjc6YmlzZWN0LW1tCgoy
MDEzLTA5LTE2LTA1OjAzOjI0IDViNDA5OThhZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0
YjZiZjcgcmV1c2UgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaTAwMi0wOTEyLzViNDA5OThh
ZTM1Y2Y2NDU2MTg2ODM3MGU2YzlmM2QzZTk0YjZiZjcvdm1saW51ei0zLjExLjAtMDkxNzkt
ZzViNDA5OTgKG1sxOzM1bWFkZF90b19ydW5fcXVldWU6IHJlcXVlc3RlZCAxMDAwMCwgbGlt
aXQgdG8gNTAwMBtbMG0KCjIwMTMtMDktMTYtMDU6MDM6MzkgZGV0ZWN0aW5nIGJvb3Qgc3Rh
dGUgCTMwCTc0CTkyCTE5NQkyNDEJMzExCTM3MQk0NDEJNTE5CTU5NAk2NTgJNzExCTc3NAk4
MzEJODc5CTkyNwk5NzMJMTA0OAkxMDk3CTExNTQJMTE5NAkxMjUzCTEyODkJMTMzOAkxMzk1
CTE0ODYJMTUzMQkxNjI0CTE2ODQJMTc3OAkxODc3CTE5MzMJMjAxNQkyMDk1CTIxMzMJMjIz
MwkyMzAxCTIzOTIJMjQ2NQkyNTQyCTI2MTYJMjY5NAkyNzk5CTI4NTkJMjg3OQkzMDA1CTMw
NzIJMzIwMgkzMjg2CTMzOTcJMzUwMgkzNjE5CTM3MDgJMzgwOQkzOTMzCTQwNDgJNDE0MAk0
MjI0CTQzMTUJNDQyMQk0NDc5CTQ2NDMJNDc0MQk0ODYwCTQ5NTgJNDk5MQk0OTk3CTUwMDAu
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19ydW5fcXVldWUg
NTAwMBtbMG0KLi4uLi4uLgk1MDAxLi4uLi4uLi4uLi4uCTUwMDIJNTAwMy4uLi4uLi4uLi4u
Li4uCTUwMDUJNTAwNi4uLi4uLi4JNTAwNy4uLi4JNTAwOAk1MDA5Li4JNTAxMC4uLi4uLi4u
Li4JNTAxMQk1MDEzLi4JNTAxNAk1MDE1CTUwMTguCTUwMTkJNTAyMC4JNTAyNC4JNTAyNQk1
MDI2Lgk1MDI5Li4JNTAzMC4uLi4uLi4uLi4uLi4uLgk1MDMyCTUwMzQJNTAzNgk1MDQzCTUw
NTQJNTA4Ni4JNTA4OQk1MTIyLgk1MjIzCTUzNjAJNTQ5MAk1NTM4CTU1NjEJNTU3NAk1NTkz
CTU2MDcJNTYxOQk1NjMyCTU2NTcJNTY3NC4uCTU3MTgJNTcyMwk1NzQxCTU3ODEuCTU4MDYJ
NTkxNwk2MDIwCTYwNzUJNjI2MAk2MzY1CTY0NjgJNjYwMQk2NzEzCTY3NTEJNjkyMQk3MDE4
CTcxMzcJNzI2MQk3MzY0CTc0OTIJNzU3MAk3NzAxCTc3NjMJNzg4NQk3OTQ4CTgwMjkJODA4
OQk4MTg3CTgyNTAJODMzNQk4NDIzCTg0NTIJODQ2Nwk4NDkxCTg1NDEJODU2Mwk4NTg1CTg2
MzgJODcyMAk4Nzg5CTg5MDUJODk5NAk5MTIxCTkyMDEJOTI4Mwk5MzYwCTk0MzIJOTU4MQk5
NzAzCTk4MzEJOTkxNgk5OTgyCTk5OTEJOTk5Nwk5OTk5Li4uLi4uLgkxMDAwMCBTVUNDRVNT
CgpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkw
MDItMDkxMi9saW51czptYXN0ZXI6ZDVkMDRiYjQ4ZjBlYjg5YzE0ZTc2Nzc5YmI0NjIxMjQ5
NGRlMGJlYzpiaXNlY3QtbW0KCjIwMTMtMDktMTYtMDk6NDI6MzMgZDVkMDRiYjQ4ZjBlYjg5
YzE0ZTc2Nzc5YmI0NjIxMjQ5NGRlMGJlYyByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pMDAyLTA5MTIvZDVkMDRiYjQ4ZjBlYjg5YzE0ZTc2Nzc5YmI0NjIxMjQ5NGRlMGJlYy92
bWxpbnV6LTMuMTEuMC0wOTQyMC1nZDVkMDRiYgobWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZTog
cmVxdWVzdGVkIDEwMDAwLCBsaW1pdCB0byA1MDAwG1swbQoKMjAxMy0wOS0xNi0wOTo0Mjoz
OSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuCTIuLgkzLgk0CTUuCTYuCTcuLi4uLi4JOC4uLgk5
Li4uLi4uLi4uLgkxMC4uCTExLi4uLgkxMi4JMTMuCTE0LgkxNgkxOAkzMQk4MgkxMjggVEVT
VCBGQUlMVVJFClsgICAgNS4wMDY2MzhdIGluaXQ6IFRlbXBvcmFyeSBwcm9jZXNzIHNwYXdu
IGVycm9yOiBObyBzcGFjZSBsZWZ0IG9uIGRldmljZQpbICAgIDUuMDM3OTAxXSAtLS0tLS0t
LS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICA1LjAzODU1N10gV0FSTklORzog
Q1BVOiAxIFBJRDogOSBhdCBsaWIvbGlzdF9kZWJ1Zy5jOjMzIF9fbGlzdF9hZGQrMHg2Yy8w
eGFlKCkKWyAgICA1LjAzOTgyMF0gbGlzdF9hZGQgY29ycnVwdGlvbi4gcHJldi0+bmV4dCBz
aG91bGQgYmUgbmV4dCAoNzgxMDA2NzgpLCBidXQgd2FzICAgKG51bGwpLiAocHJldj03ODA5
MTU3MCkuClsgICAgNS4wNDExMDNdIE1vZHVsZXMgbGlua2VkIGluOgpbICAgIDUuMDQxNTQ0
XSBDUFU6IDEgUElEOiA5IENvbW06IHJjdV9zY2hlZCBOb3QgdGFpbnRlZCAzLjExLjAtMDk0
MjAtZ2Q1ZDA0YmIgIzMwClsgICAgNS4wNDI1MjVdICAwMDAwMDAwMCAwMDAwMDAwMCA3ODA2
N2RmNCA3OTIwZWMwNiA3ODA2N2UzNCA3ODA2N2UyNCA3OTAzMGU3MiA3OTJmNTMzMQpbICAg
IDUuMDQzNzI0XSAgNzgwNjdlNTAgMDAwMDAwMDkgNzkyZjUzMDcgMDAwMDAwMjEgNzkxMDZj
NjAgNzkxMDZjNjAgNzgwOTE1NzAgNzgxMDA2NzgKWyAgICA1LjA0NDkyM10gIDc4MDY3ZWEw
IDc4MDY3ZTNjIDc5MDMwZWI3IDAwMDAwMDA5IDc4MDY3ZTM0IDc5MmY1MzMxIDc4MDY3ZTUw
IDc4MDY3ZTY4ClsgICAgNS4wNDYxMjBdIENhbGwgVHJhY2U6ClsgICAgNS4wNDY0NjldICBb
PDc5MjBlYzA2Pl0gZHVtcF9zdGFjaysweDRiLzB4NjYKWyAgICA1LjA0NzA4NV0gIFs8Nzkw
MzBlNzI+XSB3YXJuX3Nsb3dwYXRoX2NvbW1vbisweDc0LzB4OGIKWyAgICA1LjA0NzgwMl0g
IFs8NzkxMDZjNjA+XSA/IF9fbGlzdF9hZGQrMHg2Yy8weGFlClsgICAgNS4wNDc4NzVdICBb
PDc5MTA2YzYwPl0gPyBfX2xpc3RfYWRkKzB4NmMvMHhhZQpbICAgIDUuMDQ3ODc1XSAgWzw3
OTAzMGViNz5dIHdhcm5fc2xvd3BhdGhfZm10KzB4MmUvMHgzMApbICAgIDUuMDQ3ODc1XSAg
Wzw3OTEwNmM2MD5dIF9fbGlzdF9hZGQrMHg2Yy8weGFlClsgICAgNS4wNDc4NzVdICBbPDc5
MDM3MTUxPl0gX19pbnRlcm5hbF9hZGRfdGltZXIrMHg4YS8weDhlClsgICAgNS4wNDc4NzVd
ICBbPDc5MDM3MTYzPl0gaW50ZXJuYWxfYWRkX3RpbWVyKzB4ZS8weDI2ClsgICAgNS4wNDc4
NzVdICBbPDc5MjBmNDBlPl0gc2NoZWR1bGVfdGltZW91dCsweDEyNi8weDE2ZQpbICAgIDUu
MDQ3ODc1XSAgWzw3OTAzNzIxZD5dID8gY2FzY2FkZSsweDVhLzB4NWEKWyAgICA1LjA0Nzg3
NV0gIFs8NzkwN2JlN2M+XSByY3VfZ3Bfa3RocmVhZCsweDI5OS8weDQ2NwpbICAgIDUuMDQ3
ODc1XSAgWzw3OTA0NjBjYj5dID8gYWJvcnRfZXhjbHVzaXZlX3dhaXQrMHg2My8weDYzClsg
ICAgNS4wNDc4NzVdICBbPDc5MDdiYmUzPl0gPyByY3VfZ3BfZnFzKzB4NmEvMHg2YQpbICAg
IDUuMDQ3ODc1XSAgWzw3OTA0NTkyNT5dIGt0aHJlYWQrMHg5NS8weDlhClsgICAgNS4wNDc4
NzVdICBbPDc5MDQwMDAwPl0gPyBkZXN0cm95X3dvcmtxdWV1ZSsweGFmLzB4MTc5ClsgICAg
NS4wNDc4NzVdICBbPDc5MjE0MGZiPl0gcmV0X2Zyb21fa2VybmVsX3RocmVhZCsweDFiLzB4
MzAKWyAgICA1LjA0Nzg3NV0gIFs8NzkwNDU4OTA+XSA/IGt0aHJlYWRfc3RvcCsweDRlLzB4
NGUKWyAgICA1LjA0Nzg3NV0gLS0tWyBlbmQgdHJhY2UgMzhhYjlmNjA3NTNiNDUxZCBdLS0t
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi9kNWQwNGJiNDhmMGViODljMTRl
NzY3NzliYjQ2MjEyNDk0ZGUwYmVjL2RtZXNnLXF1YW50YWwteGlhbi0xOjIwMTMwOTE2MTAw
NzU0OjMuMTEuMC1yYzctMDA3NjYtZzg1NWY1ZjE6NjgKCltkZXRhY2hlZCBIRUFEIDE0Zjgz
ZDRdIFJldmVydCAibW06IG11bmxvY2s6IG1hbnVhbCBwdGUgd2FsayBpbiBmYXN0IHBhdGgg
aW5zdGVhZCBvZiBmb2xsb3dfcGFnZV9tYXNrKCkiCiAyIGZpbGVzIGNoYW5nZWQsIDM3IGlu
c2VydGlvbnMoKyksIDg1IGRlbGV0aW9ucygtKQpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1x
dWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi9saW51czptYXN0ZXI6MTRmODNk
NGMwMmZhMTI2ZmQ2OTk1NzA0MjlhMGJiODg4ZTEyZGRmNzpiaXNlY3QtbW0KCjIwMTMtMDkt
MTYtMTA6MDg6NDYgMTRmODNkNGMwMmZhMTI2ZmQ2OTk1NzA0MjlhMGJiODg4ZTEyZGRmNyBj
b21waWxpbmcKG1sxOzM1bWFkZF90b19ydW5fcXVldWU6IHJlcXVlc3RlZCAxMDAwMCwgbGlt
aXQgdG8gNTAwMBtbMG0KCjIwMTMtMDktMTYtMTA6MTU6MTMgZGV0ZWN0aW5nIGJvb3Qgc3Rh
dGUgMy4xMS4wLTA5NDIxLWcxNGY4M2Q0CTYzCTExOQkxOTYJMjY3CTM0Mwk0MjgJNDk0CTU3
Nwk2NjEJNzQwCTc5NQk4ODYJOTY5CTEwNDIJMTExNgkxMTkwCTEyODAJMTM2MwkxNDUxCTE1
MjMJMTYyMAkxNzAwCTE3ODAJMTg0OQkxOTMwCTIwMzEJMjA5MAkyMTc4CTIyNzkJMjM3Nwky
NDc0CTI1NTgJMjY0MwkyNzQxCTI4MDgJMjg5MQkyOTYyCTMwNDQJMzA5MgkzMTU1CTMyNDQJ
MzMwOQkzMzk0CTM0NzAJMzU1MQkzNjE4CTM2OTkJMzgwMAkzOTE3CTQwMTYJNDEyNwk0MjQy
CTQzNTQJNDQ2Mwk0NTcwCTQ2ODUJNDgwMQk0ODk0CTQ5NDkJNDk5Mwk0OTk5Li4uLi4uCTUw
MDAuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19ydW5fcXVl
dWUgNTAwMBtbMG0KLi4uLi4uLi4uLi4uCTUwMDEuCTUwMDIuLi4uLi4uLi4uLi4uCTUwMDMu
Li4uLi4uLi4uLi4uLi4uLi4uLi4uCTUwMDQuCTUwMDUuLi4uCTUwMDYuLgk1MDA3Lgk1MDA4
Li4uLi4uLgk1MDA5Li4JNTAxMC4uLi4JNTAxMS4uLi4uLgk1MDEyLi4uLi4uLi4uLi4uLi4u
Li4uCTUwMTMuCTUwMTQJNTAxNS4uLi4uLgk1MDE2Li4uLi4JNTAxNy4uCTUwMTguCTUwMTku
Li4uLgk1MDIwCTUwMjEuCTUwMjIuLi4uLi4uLi4JNTAyNC4uLi4JNTAyNS4uCTUwMjcJNTAy
OAk1MDM5CTUwNDEJNTA3OAk1MTIyCTUxOTEJNTI1Mwk1MzI5CTU0MDcJNTQ2OAk1NTE5CTU1
NjQJNTU5Ngk1NjE5CTU2NDcuCTU3MTcJNTc3Nwk1ODIxCTU4NjUJNTg5NAk1OTM1CTU5NjUJ
NjA1MQk2MDk0CTYwOTUJNjE3Nwk2MjQ1CTYyODkJNjM0MAk2MzcyCTY0MjQJNjQ1Nwk2NTEw
CTY1NDUJNjU4Mgk2NjE3CTY2NDIJNjY1Ngk2NjY2CTY2ODQJNjcwMQk2NzA4CTY3MTcJNjcy
Mgk2NzMyCTY3MzgJNjc0MAk2NzQyCTY3NDUJNjc0Ni4JNjc0Nwk2NzQ4CTY3NTAJNjc1MS4J
Njc1Mi4JNjc1My4JNjc1NC4uCTY3NTUJNjc1OQk2NzYyCTY3NjUJNjc3MQk2Nzc1CTY3ODUJ
Njc4OC4JNjgwNQk2ODEwCTY4MTUJNjgyMAk2ODI1CTY4MzMJNjg0OAk2ODU5Lgk2ODYxCTY4
NzMJNjg3NAk2ODgwCTY4ODIuCTY4OTkJNjkzMAk2OTU2CTY5NzgJNjk5Mgk3MDAyCTcwMTgJ
NzA2NQk3MTEwCTcxNjQJNzI1Nwk3MzEyCTc0MTIJNzUwNgk3NTc3CTc2MTQJNzc2Mgk3ODIy
CTc5MDkJODAwMQk4MDY5CTgxNDUJODE1Mwk4MzQxCTg0NDIJODU1MQk4NjIxCTg3MjEJODc2
OS4JOTAzMgk5MTM5CTkyMzMJOTM2NQk5NDc5CTk2MDAJOTcwMwk5ODE5CTk5MTcJOTk2Mwk5
OTgyCTk5OTQJOTk5NQk5OTk2Li4uLi4uLi4uLi4uLi4JOTk5OC4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4JOTk5OS4uLi4uLi4uLi4uLi4uLgkxMDAwMCBT
VUNDRVNTCgoKPT09PT09PT09IHVwc3RyZWFtID09PT09PT09PQpGZXRjaGluZyBsaW51cwps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkwMDIt
MDkxMi9saW51czptYXN0ZXI6ZDhlZmQ4MmVlY2U4OWY4YTU3OTBiMGZlYmYxNzUyMmFmZmU5
ZTFmMTpiaXNlY3QtbW0KCjIwMTMtMDktMTYtMTY6MjA6NTMgZDhlZmQ4MmVlY2U4OWY4YTU3
OTBiMGZlYmYxNzUyMmFmZmU5ZTFmMSBjb21waWxpbmcKG1sxOzM1bWFkZF90b19ydW5fcXVl
dWU6IHJlcXVlc3RlZCAxMDAwMCwgbGltaXQgdG8gNTAwMBtbMG0KCjIwMTMtMDktMTYtMTY6
MjY6MTkgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMS4wLTEwMTMwLWdkOGVmZDgyLgkxCTIu
CTQJNgk3Li4uCTExCTEzCTIwCTM5CTQ0CTQ1IFRFU1QgRkFJTFVSRQpbICAgIDMuOTIwMjE2
XSB0c2M6IFJlZmluZWQgVFNDIGNsb2Nrc291cmNlIGNhbGlicmF0aW9uOiAyNjU5Ljk2NCBN
SHoKWyAgICA0LjEwMDA5Nl0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0t
ClsgICAgNC4xMDA4NzldIFdBUk5JTkc6IENQVTogMSBQSUQ6IDkgYXQgL2Mvd2ZnL21tL2xp
Yi9saXN0X2RlYnVnLmM6MzMgX19saXN0X2FkZCsweDZjLzB4YWUoKQpbICAgIDQuMTAyMTIw
XSBsaXN0X2FkZCBjb3JydXB0aW9uLiBwcmV2LT5uZXh0IHNob3VsZCBiZSBuZXh0ICg3ODEw
MDM4OCksIGJ1dCB3YXMgICAobnVsbCkuIChwcmV2PTc4MDkxNTcwKS4KWyAgICA0LjEwMzU0
Nl0gTW9kdWxlcyBsaW5rZWQgaW46ClsgICAgNC4xMDQwNDJdIENQVTogMSBQSUQ6IDkgQ29t
bTogcmN1X3NjaGVkIE5vdCB0YWludGVkIDMuMTEuMC0xMDEzMC1nZDhlZmQ4MiAjMzM4Clsg
ICAgNC4xMDUxNTRdICAwMDAwMDAwMCAwMDAwMDAwMCA3ODA2N2RmNCA3OTIwZTdmZiA3ODA2
N2UzNCA3ODA2N2UyNCA3OTAzMGVmMiA3OTJmNDY5NApbICAgIDQuMTA2NDkzXSAgNzgwNjdl
NTAgMDAwMDAwMDkgNzkyZjQ2NzkgMDAwMDAwMjEgNzkxMDgwNTAgNzkxMDgwNTAgNzgwOTE1
NzAgNzgxMDAzODgKWyAgICA0LjEwNzgzOF0gIDc4MDY3ZWEwIDc4MDY3ZTNjIDc5MDMwZjM3
IDAwMDAwMDA5IDc4MDY3ZTM0IDc5MmY0Njk0IDc4MDY3ZTUwIDc4MDY3ZTY4ClsgICAgNC4x
MDkxNzBdIENhbGwgVHJhY2U6ClsgICAgNC4xMDk1NjFdICBbPDc5MjBlN2ZmPl0gZHVtcF9z
dGFjaysweDRiLzB4NjYKWyAgICA0LjExMDAyOF0gIFs8NzkwMzBlZjI+XSB3YXJuX3Nsb3dw
YXRoX2NvbW1vbisweDc0LzB4OGIKWyAgICA0LjExMDAyOF0gIFs8NzkxMDgwNTA+XSA/IF9f
bGlzdF9hZGQrMHg2Yy8weGFlClsgICAgNC4xMTAwMjhdICBbPDc5MTA4MDUwPl0gPyBfX2xp
c3RfYWRkKzB4NmMvMHhhZQpbICAgIDQuMTEwMDI4XSAgWzw3OTAzMGYzNz5dIHdhcm5fc2xv
d3BhdGhfZm10KzB4MmUvMHgzMApbICAgIDQuMTEwMDI4XSAgWzw3OTEwODA1MD5dIF9fbGlz
dF9hZGQrMHg2Yy8weGFlClsgICAgNC4xMTAwMjhdICBbPDc5MDM3MWQxPl0gX19pbnRlcm5h
bF9hZGRfdGltZXIrMHg4YS8weDhlClsgICAgNC4xMTAwMjhdICBbPDc5MDM3MWUzPl0gaW50
ZXJuYWxfYWRkX3RpbWVyKzB4ZS8weDI2ClsgICAgNC4xMTAwMjhdICBbPDc5MjBmMDA2Pl0g
c2NoZWR1bGVfdGltZW91dCsweDEyNi8weDE2ZQpbICAgIDQuMTEwMDI4XSAgWzw3OTAzNzI5
ZD5dID8gY2FzY2FkZSsweDVhLzB4NWEKWyAgICA0LjExMDAyOF0gIFs8NzkwN2JmMzM+XSBy
Y3VfZ3Bfa3RocmVhZCsweDI5OS8weDQ2NwpbICAgIDQuMTEwMDI4XSAgWzw3OTA0NjE0Yj5d
ID8gYWJvcnRfZXhjbHVzaXZlX3dhaXQrMHg2My8weDYzClsgICAgNC4xMTAwMjhdICBbPDc5
MDdiYzlhPl0gPyByY3VfZ3BfZnFzKzB4NmEvMHg2YQpbICAgIDQuMTEwMDI4XSAgWzw3OTA0
NTlhNT5dIGt0aHJlYWQrMHg5NS8weDlhClsgICAgNC4xMTAwMjhdICBbPDc5MDQwMDAwPl0g
PyBkZXN0cm95X3dvcmtxdWV1ZSsweDJmLzB4MTc5ClsgICAgNC4xMTAwMjhdICBbPDc5MjEz
Y2ZiPl0gcmV0X2Zyb21fa2VybmVsX3RocmVhZCsweDFiLzB4MzAKWyAgICA0LjExMDAyOF0g
IFs8NzkwNDU5MTA+XSA/IGt0aHJlYWRfc3RvcCsweDRlLzB4NGUKWyAgICA0LjExMDAyOF0g
LS0tWyBlbmQgdHJhY2UgMzljOTRiNjIwNGNkY2E5MyBdLS0tCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWkwMDItMDkxMi9kOGVmZDgyZWVjZTg5ZjhhNTc5MGIwZmViZjE3NTIyYWZmZTll
MWYxL2RtZXNnLXlvY3RvLXJvYW0tMjg6MjAxMzA5MTYxNjMzNDc6My4xMS4wLTAwMDIyLWc0
YjJjOGM0Ojk4Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi9kOGVmZDgyZWVj
ZTg5ZjhhNTc5MGIwZmViZjE3NTIyYWZmZTllMWYxL2RtZXNnLXlvY3RvLWxrcC10dDAyLTE2
OjIwMTMwOTE2MDY1MjQyOjMuMTEuMC0xMDEzNy1nYzg5NzU3MDoxMTAKCgo9PT09PT09PT0g
bGludXgtbmV4dCA9PT09PT09PT0KRmV0Y2hpbmcgbmV4dApscyAtYSAva2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWkwMDItMDkxMi9saW51czptYXN0ZXI6
YWRlN2I2NjFhZTlhMmVmYWM0Y2QyZWQzNmQ4MDUzYmZjYjEzYmMzMTpiaXNlY3QtbW0KCjIw
MTMtMDktMTYtMTY6MzQ6MzcgYWRlN2I2NjFhZTlhMmVmYWM0Y2QyZWQzNmQ4MDUzYmZjYjEz
YmMzMSBjb21waWxpbmcKMjAxMy0wOS0xNi0xNjozNzoxNiBhZGU3YjY2MWFlOWEyZWZhYzRj
ZDJlZDM2ZDgwNTNiZmNiMTNiYzMxIFNLSVAgQlJPS0VOIEJVSUxECkNoZWNrIGVycm9zIGlu
IC9jYy93ZmcvbW0tYmlzZWN0IGFuZCAvdG1wL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaTAw
Mi0wOTEyL2FkZTdiNjYxYWU5YTJlZmFjNGNkMmVkMzZkODA1M2JmY2IxM2JjMzEK

--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.11.0-09272-g666a584"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.11.0 Kernel Configuration
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
CONFIG_CONSTRUCTORS=y
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
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
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
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
# CONFIG_SHMEM is not set
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_SLUB_DEBUG is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
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
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
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
# CONFIG_BLOCK is not set
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
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
CONFIG_M486=y
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
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
CONFIG_X86_INVD_BUG=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
# CONFIG_CPU_SUP_TRANSMETA_32 is not set
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=8
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
# CONFIG_VM86 is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=m
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_2G_OPT=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x78000000
CONFIG_HIGHMEM=y
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
# CONFIG_COMPACTION is not set
# CONFIG_MIGRATION is not set
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

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
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
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
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
# CONFIG_CPU_FREQ_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=m
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=m
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
CONFIG_X86_SPEEDSTEP_ICH=y
# CONFIG_X86_SPEEDSTEP_SMI is not set
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=m
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_GOBIOS=y
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_BIOS=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
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
# CONFIG_SCx200HR_TIMER is not set
# CONFIG_OLPC is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=m
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
# CONFIG_YENTA_RICOH is not set
# CONFIG_YENTA_TI is not set
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
# CONFIG_I82092 is not set
CONFIG_I82365=m
CONFIG_TCIC=m
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_COMPAQ=m
# CONFIG_HOTPLUG_PCI_COMPAQ_NVRAM is not set
# CONFIG_HOTPLUG_PCI_IBM is not set
# CONFIG_HOTPLUG_PCI_ACPI is not set
CONFIG_HOTPLUG_PCI_CPCI=y
# CONFIG_HOTPLUG_PCI_CPCI_ZT5550 is not set
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
# CONFIG_RAPIDIO_ENUM_BASIC is not set

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=m
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=m
# CONFIG_RAPIDIO_CPS_GEN2 is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=m
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=m
CONFIG_REGMAP_MMIO=m
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=m
CONFIG_MTD_TESTS=m
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=m
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
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
# CONFIG_MTD_OTP is not set
# CONFIG_MTD_CFI_INTELEXT is not set
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=m
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_SC520CDP=m
# CONFIG_MTD_NETSC520 is not set
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_SCx200_DOCFLASH is not set
CONFIG_MTD_AMD76XROM=m
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
CONFIG_MTD_CK804XROM=m
CONFIG_MTD_SCB2_FLASH=m
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_INTEL_VR_NOR=m
CONFIG_MTD_PLATRAM=m

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_SLRAM=m
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=m
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_GPIO=m
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=m
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_CS553X=m
CONFIG_MTD_NAND_NANDSIM=m
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_ONENAND=m
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
# CONFIG_MTD_ONENAND_GENERIC is not set
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=m
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=m
CONFIG_AD525X_DPOT_I2C=m
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=m
# CONFIG_ATMEL_SSC is not set
CONFIG_ENCLOSURE_SERVICES=m
# CONFIG_CS5535_MFGPT is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=m
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1780=m
CONFIG_SENSORS_BH1770=m
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=m
CONFIG_DS1682=m
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=m
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
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
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=m
CONFIG_PC8736x_GPIO=m
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_INFINEON=m
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=m
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=m
CONFIG_I2C_MUX_PCA9541=m
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCF=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=m
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
# CONFIG_I2C_AMD756_S4882 is not set
CONFIG_I2C_AMD8111=m
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=m
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=m
# CONFIG_I2C_KEMPLD is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_ISA is not set
# CONFIG_SCx200_I2C is not set
CONFIG_SCx200_ACB=m
CONFIG_I2C_STUB=m
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
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_TS5500=m
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_MAX7300=m
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=m
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=m
CONFIG_GPIO_BT8XX=m
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_LANGWELL=y
CONFIG_GPIO_PCH=m
CONFIG_GPIO_ML_IOH=m
# CONFIG_GPIO_TIMBERDALE is not set
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MCP23S08=m

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

#
# USB GPIO expanders:
#
# CONFIG_GPIO_VIPERBOARD is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=m
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=m
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_TEST_POWER=m
CONFIG_BATTERY_DS2760=m
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=m
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27x00=m
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=m
CONFIG_BATTERY_MAX17042=m
CONFIG_CHARGER_PCF50633=m
CONFIG_CHARGER_ISP1704=m
CONFIG_CHARGER_MAX8903=m
CONFIG_CHARGER_LP8727=m
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_SMB347=m
CONFIG_BATTERY_GOLDFISH=y
CONFIG_POWER_RESET=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7414=m
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=m
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=m
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_GPIO_FAN=m
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_HTU21=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_IIO_HWMON is not set
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LTC4151=m
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
CONFIG_SENSORS_MAX6639=m
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
CONFIG_SENSORS_ADS1015=m
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=m
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_MC13783_ADC=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_RETU_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_F71808E_WDT is not set
CONFIG_SP5100_TCO=m
CONFIG_SC520_WDT=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_IT87_WDT=m
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=m
# CONFIG_SC1200_WDT is not set
# CONFIG_SCx200_WDT is not set
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
CONFIG_SBC7240_WDT=y
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
CONFIG_SMSC37B787_WDT=m
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83697HF_WDT=m
CONFIG_W83697UG_WDT=m
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=m
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=m
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
CONFIG_PCWATCHDOG=y
# CONFIG_MIXCOMWD is not set
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_SILENT=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
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
CONFIG_MFD_CS5535=y
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_I2C=m
CONFIG_MFD_MC13783=m
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_HTC_PASIC3=m
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=m
CONFIG_MFD_VIPERBOARD=m
CONFIG_MFD_RETU=m
CONFIG_MFD_PCF50633=m
CONFIG_PCF50633_ADC=m
# CONFIG_PCF50633_GPIO is not set
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=m
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65217=m
# CONFIG_MFD_TPS65912 is not set
CONFIG_MFD_WL1273_CORE=m
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TIMBERDALE=m
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=m
CONFIG_REGULATOR_VIRTUAL_CONSUMER=m
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
CONFIG_REGULATOR_AD5398=m
CONFIG_REGULATOR_DA9210=m
CONFIG_REGULATOR_FAN53555=m
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=m
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_MAX1586=m
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=m
CONFIG_REGULATOR_MAX8952=m
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MC13XXX_CORE=m
# CONFIG_REGULATOR_MC13783 is not set
CONFIG_REGULATOR_MC13892=m
CONFIG_REGULATOR_PCF50633=m
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_TPS51632=m
CONFIG_REGULATOR_TPS6105X=m
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=m
CONFIG_REGULATOR_TPS65217=m
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEO_V4L2_INT_DEVICE=m
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Analog TV USB devices
#
# CONFIG_VIDEO_PVRUSB2 is not set
# CONFIG_VIDEO_HDPVR is not set
# CONFIG_VIDEO_USBVISION is not set
CONFIG_VIDEO_STK1160_COMMON=m
CONFIG_VIDEO_STK1160=m

#
# Analog/digital TV USB devices
#

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture/analog TV support
#
CONFIG_VIDEO_ZORAN=m
CONFIG_VIDEO_ZORAN_DC30=m
# CONFIG_VIDEO_ZORAN_ZR36060 is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
CONFIG_VIDEO_HEXIUM_ORION=m
CONFIG_VIDEO_MXB=m

#
# Media capture/analog/hybrid TV support
#
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_SAA7134=m

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
# CONFIG_RADIO_SI470X is not set
CONFIG_USB_MR800=m
CONFIG_USB_DSBR=m
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
CONFIG_RADIO_SHARK2=m
CONFIG_I2C_SI4713=m
# CONFIG_RADIO_SI4713 is not set
CONFIG_USB_KEENE=m
# CONFIG_USB_MA901 is not set
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=m
CONFIG_RADIO_TEF6862=m
CONFIG_RADIO_TIMBERDALE=m
CONFIG_RADIO_WL1273=m

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_V4L_RADIO_ISA_DRIVERS is not set
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TDA9840=m
CONFIG_VIDEO_TEA6415C=m
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_VPX3220=m

#
# Video and audio decoders
#

#
# Video encoders
#
CONFIG_VIDEO_ADV7175=m

#
# Camera sensor devices
#
CONFIG_VIDEO_MT9V011=m

#
# Flash devices
#

#
# Video improvement chips
#

#
# Miscelaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MC44S803=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=m
# CONFIG_AGP_ALI is not set
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
CONFIG_AGP_AMD64=m
CONFIG_AGP_INTEL=m
CONFIG_AGP_NVIDIA=m
# CONFIG_AGP_SIS is not set
CONFIG_AGP_SWORKS=m
CONFIG_AGP_VIA=m
CONFIG_AGP_EFFICEON=m
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_USB=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_NOUVEAU=m
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_MGA=m
CONFIG_DRM_SIS=m
CONFIG_DRM_VIA=m
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
# CONFIG_DRM_QXL is not set
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_HDMI=y
CONFIG_FB=m
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=m
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
CONFIG_FB_PM2=m
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=m
# CONFIG_FB_CYBER2000_DDC is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=m
CONFIG_FB_I810=m
CONFIG_FB_I810_GTF=y
# CONFIG_FB_I810_I2C is not set
# CONFIG_FB_LE80578 is not set
CONFIG_FB_INTEL=m
# CONFIG_FB_INTEL_DEBUG is not set
CONFIG_FB_INTEL_I2C=y
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
# CONFIG_FB_MATROX_MAVEN is not set
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=m
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=m
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=m
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=m
CONFIG_FB_3DFX=m
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=m
CONFIG_FB_TRIDENT=m
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=m
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=m
CONFIG_FB_GEODE_GX=m
CONFIG_FB_GEODE_GX1=m
CONFIG_FB_TMIO=m
# CONFIG_FB_TMIO_ACCELL is not set
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=m
CONFIG_FB_GOLDFISH=m
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
CONFIG_FB_AUO_K1901=m
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=m
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_ADP8860=m
CONFIG_BACKLIGHT_ADP8870=m
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3630 is not set
CONFIG_BACKLIGHT_LM3639=m
CONFIG_BACKLIGHT_LP855X=m
# CONFIG_BACKLIGHT_TPS65217 is not set
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=m
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=m
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=m
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_MON=m
CONFIG_USB_WUSB=m
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=m
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
CONFIG_USB_ISP1760_HCD=m
CONFIG_USB_ISP1362_HCD=m
CONFIG_USB_FUSBH200_HCD=m
CONFIG_USB_FOTG210_HCD=m
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_HCD_PCI is not set
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=m
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_SL811_CS is not set
CONFIG_USB_R8A66597_HCD=m
# CONFIG_USB_RENESAS_USBHS_HCD is not set
CONFIG_USB_WHCI_HCD=m
CONFIG_USB_HWA_HCD=m
CONFIG_USB_HCD_BCMA=m
CONFIG_USB_HCD_SSB=m
CONFIG_USB_HCD_TEST_MODE=y
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_RENESAS_USBHS=m

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=m
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_CHIPIDEA=m
CONFIG_USB_CHIPIDEA_UDC=y
# CONFIG_USB_CHIPIDEA_DEBUG is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
CONFIG_USB_RIO500=m
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
CONFIG_USB_CYPRESS_CY7C63=m
CONFIG_USB_CYTHERM=m
CONFIG_USB_IDMOUSE=m
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=m
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
CONFIG_USB_TEST=m
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
CONFIG_USB_HSIC_USB3503=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=m
CONFIG_OMAP_CONTROL_USB=m
CONFIG_OMAP_USB3=m
CONFIG_AM335X_CONTROL_USB=m
CONFIG_AM335X_PHY_USB=m
CONFIG_SAMSUNG_USBPHY=m
CONFIG_SAMSUNG_USB2PHY=m
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_USB_ISP1301=m
CONFIG_USB_RCAR_PHY=m
CONFIG_USB_GADGET=m
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FUSB300=m
CONFIG_USB_FOTG210_UDC=m
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_RENESAS_USBHS_UDC is not set
CONFIG_USB_PXA27X=m
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_MV_U3D=m
CONFIG_USB_M66592=m
CONFIG_USB_AMD5536UDC=m
# CONFIG_USB_NET2272 is not set
CONFIG_USB_NET2280=m
CONFIG_USB_GOKU=m
# CONFIG_USB_EG20T is not set
CONFIG_USB_DUMMY_HCD=m
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_SS_LB=m
CONFIG_USB_CONFIGFS=m
# CONFIG_USB_CONFIGFS_SERIAL is not set
# CONFIG_USB_CONFIGFS_ACM is not set
# CONFIG_USB_CONFIGFS_OBEX is not set
# CONFIG_USB_CONFIGFS_NCM is not set
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
# CONFIG_USB_CONFIGFS_RNDIS is not set
# CONFIG_USB_CONFIGFS_EEM is not set
CONFIG_USB_ZERO=m
# CONFIG_USB_ZERO_HNPTEST is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
CONFIG_USB_FUNCTIONFS=m
# CONFIG_USB_FUNCTIONFS_ETH is not set
# CONFIG_USB_FUNCTIONFS_RNDIS is not set
CONFIG_USB_FUNCTIONFS_GENERIC=y
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
CONFIG_USB_G_WEBCAM=m
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_NET48XX=m
CONFIG_LEDS_WRAP=m
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=m
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP55XX_COMMON=m
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=m
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA9633 is not set
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_MC13783=m
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_LM355x=m
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=m

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=m
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_DS3232=m
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=m
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=m
CONFIG_RTC_DRV_S35390A=m
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8581=m
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=m
CONFIG_RTC_DRV_RV3029C2=m

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=m
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=m
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_PCF50633=m

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=m
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=m
CONFIG_INTEL_IOATDMA=m
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=m
CONFIG_TIMB_DMA=m
CONFIG_PCH_DMA=m
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DCA=m
CONFIG_AUXDISPLAY=y
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=m
CONFIG_UIO_MF624=m
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=m

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=m
CONFIG_VIRTIO_BALLOON=m
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=m
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=m
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_SAMSUNG_Q10=m
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

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=m
CONFIG_STE_MODEM_RPROC=m

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_IIO_ST_ACCEL_3AXIS=m
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=m

#
# Analog to digital converters
#
CONFIG_MAX1363=m
CONFIG_NAU7802=m
CONFIG_TI_ADC081C=m
# CONFIG_TI_AM335X_ADC is not set
CONFIG_VIPERBOARD_ADC=m

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Digital to analog converters
#
CONFIG_AD5064=m
CONFIG_AD5380=m
# CONFIG_AD5446 is not set
CONFIG_MAX517=m
# CONFIG_MCP4725 is not set

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
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_ITG3200=m

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=m

#
# Light sensors
#
CONFIG_ADJD_S311=m
# CONFIG_APDS9300 is not set
CONFIG_SENSORS_TSL2563=m
CONFIG_VCNL4000=m

#
# Magnetometer sensors
#
CONFIG_AK8975=m
# CONFIG_IIO_ST_MAGN_3AXIS is not set

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=m
CONFIG_IIO_SYSFS_TRIGGER=m

#
# Pressure sensors
#
CONFIG_IIO_ST_PRESS=m
CONFIG_IIO_ST_PRESS_I2C=m

#
# Temperature sensors
#
# CONFIG_TMP006 is not set
CONFIG_NTB=m
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=m
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
# CONFIG_FSNOTIFY is not set
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=m
CONFIG_CUSE=m

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_CODEPAGE_737=m
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=m
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=m
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=m
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
# CONFIG_NLS_UTF8 is not set

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
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
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
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

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
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_SCHED_DEBUG is not set
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
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_KOBJECT_RELEASE=y
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=m
CONFIG_TEST_KSTRTOX=m
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_FIREWIRE_OHCI_REMOTE_DMA=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DOUBLEFAULT is not set
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
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_YAMA_STACKED=y
CONFIG_INTEGRITY=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_APPRAISE=y
CONFIG_DEFAULT_SECURITY_YAMA=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="yama"
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
# CONFIG_CRYPTO_NULL is not set
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=m
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA256 is not set
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=m
# CONFIG_CRYPTO_DES is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_586=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
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
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_LGUEST is not set
# CONFIG_BINARY_PRINTF is not set

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
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=m
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=m
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set

--qDbXVdCdHGoSgWSk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
