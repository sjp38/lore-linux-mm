Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7516B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:29:21 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so40530616pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:29:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id px1si34845232pbb.240.2015.07.07.07.29.19
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 07:29:20 -0700 (PDT)
Date: Tue, 07 Jul 2015 22:27:58 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm: meminit]  WARNING: CPU: 1 PID: 15 at
 kernel/locking/lockdep.c:3382 lock_release()
Message-ID: <559be1ee.oKzhDxqT1ZZpBUZm%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_559be1ee./9tdyPbznChQo7YkntdXp/uaiwvnlAbayZyItQ03e8HMF6wr"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com

This is a multi-part message in MIME format.

--=_559be1ee./9tdyPbznChQo7YkntdXp/uaiwvnlAbayZyItQ03e8HMF6wr
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 0e1cc95b4cc7293bb7b39175035e7f7e45c90977
Author:     Mel Gorman <mgorman@suse.de>
AuthorDate: Tue Jun 30 14:57:27 2015 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Tue Jun 30 19:44:56 2015 -0700

    mm: meminit: finish initialisation of struct pages before basic setup
    
    Waiman Long reported that 24TB machines hit OOM during basic setup when
    struct page initialisation was deferred.  One approach is to initialise
    memory on demand but it interferes with page allocator paths.  This patch
    creates dedicated threads to initialise memory before basic setup.  It
    then blocks on a rw_semaphore until completion as a wait_queue and counter
    is overkill.  This may be slower to boot but it's simplier overall and
    also gets rid of a section mangling which existed so kswapd could do the
    initialisation.
    
    [akpm@linux-foundation.org: include rwsem.h, use DECLARE_RWSEM, fix comment, remove unneeded cast]
    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Cc: Waiman Long <waiman.long@hp.com
    Cc: Nathan Zimmer <nzimmer@sgi.com>
    Cc: Dave Hansen <dave.hansen@intel.com>
    Cc: Scott Norton <scott.norton@hp.com>
    Tested-by: Daniel J Blueman <daniel@numascale.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

+-----------------------------------------------------+------------+------------+-----------------+
|                                                     | 74033a798f | 0e1cc95b4c | v4.2-rc1_070709 |
+-----------------------------------------------------+------------+------------+-----------------+
| boot_successes                                      | 63         | 0          | 0               |
| boot_failures                                       | 0          | 24         | 13              |
| WARNING:at_kernel/locking/lockdep.c:#lock_release() | 0          | 24         | 13              |
| backtrace:up_read                                   | 0          | 24         | 13              |
| backtrace:deferred_init_memmap                      | 0          | 24         | 13              |
+-----------------------------------------------------+------------+------------+-----------------+

[    0.240862] kvm-stealtime: cpu 1, msr 1100d140
[    0.260270] ------------[ cut here ]------------
[    0.260270] ------------[ cut here ]------------
[    0.261323] WARNING: CPU: 1 PID: 15 at kernel/locking/lockdep.c:3382 lock_release+0xde/0x3d3()
[    0.261323] WARNING: CPU: 1 PID: 15 at kernel/locking/lockdep.c:3382 lock_release+0xde/0x3d3()
[    0.264199] DEBUG_LOCKS_WARN_ON(depth <= 0)
[    0.264199] DEBUG_LOCKS_WARN_ON(depth <= 0)

[    0.265313] CPU: 1 PID: 15 Comm: pgdatinit0 Not tainted 4.1.0-11369-g0e1cc95 #1
[    0.265313] CPU: 1 PID: 15 Comm: pgdatinit0 Not tainted 4.1.0-11369-g0e1cc95 #1
[    0.269739] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.269739] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.270000]  0000000000000009
[    0.270000]  0000000000000009 ffff88000f997c48 ffff88000f997c48 ffffffff817d5686 ffffffff817d5686 ffffffff810cb07d ffffffff810cb07d

[    0.270000]  ffff88000f997c98
[    0.270000]  ffff88000f997c98 ffff88000f997c88 ffff88000f997c88 ffffffff8108bd43 ffffffff8108bd43 ffff88000f997c68 ffff88000f997c68

[    0.270000]  ffffffff810c3b8d
[    0.270000]  ffffffff810c3b8d ffff88000f990000 ffff88000f990000 ffff8800114fe000 ffff8800114fe000 ffffffff8236e530 ffffffff8236e530

[    0.270000] Call Trace:
[    0.270000] Call Trace:
[    0.270000]  [<ffffffff817d5686>] dump_stack+0x4c/0x6e
[    0.270000]  [<ffffffff817d5686>] dump_stack+0x4c/0x6e
[    0.270000]  [<ffffffff810cb07d>] ? console_unlock+0x3f3/0x422
[    0.270000]  [<ffffffff810cb07d>] ? console_unlock+0x3f3/0x422
[    0.270000]  [<ffffffff8108bd43>] warn_slowpath_common+0x9c/0xb6
[    0.270000]  [<ffffffff8108bd43>] warn_slowpath_common+0x9c/0xb6
[    0.270000]  [<ffffffff810c3b8d>] ? lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff810c3b8d>] ? lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff821dc011>] ? deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff821dc011>] ? deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff8108bdc2>] warn_slowpath_fmt+0x46/0x48
[    0.270000]  [<ffffffff8108bdc2>] warn_slowpath_fmt+0x46/0x48
[    0.270000]  [<ffffffff810c3b8d>] lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff810c3b8d>] lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff810c08ac>] up_read+0x20/0x2c
[    0.270000]  [<ffffffff810c08ac>] up_read+0x20/0x2c
[    0.270000]  [<ffffffff821dc011>] deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff821dc011>] deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff817d9ea9>] ? __schedule+0x3b9/0x5af
[    0.270000]  [<ffffffff817d9ea9>] ? __schedule+0x3b9/0x5af
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff810a2cb8>] kthread+0xe0/0xe8
[    0.270000]  [<ffffffff810a2cb8>] kthread+0xe0/0xe8
[    0.270000]  [<ffffffff817de2eb>] ? _raw_spin_unlock_irq+0x32/0x46
[    0.270000]  [<ffffffff817de2eb>] ? _raw_spin_unlock_irq+0x32/0x46
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff817df1cf>] ret_from_fork+0x3f/0x70
[    0.270000]  [<ffffffff817df1cf>] ret_from_fork+0x3f/0x70
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000] ---[ end trace 95f3f95a9e2dd516 ]---
[    0.270000] ---[ end trace 95f3f95a9e2dd516 ]---

git bisect start 9bbbdce9ba479ee60d157b45e83c2060f5e6ceac v4.1 --
git bisect good f822dcc63f966fc79b11a8254fa0942b1aa8c71e  # 14:45     20+      0  Merge tag 'sound-fix-4.2-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect  bad daa259f637dc2e674b38884342f0ded0189aceff  # 15:40      0-     11  Merge 'mediatek/v4.2-next/soc' into devel-hourly-2015070709
git bisect  bad 13d45f79a2af84de9083310db58b309a61065208  # 16:14      0-      3  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/cooloney/linux-leds
git bisect good d5fb82137b6cd39e67c4321f4f5ce9b03d4d04e6  # 16:23     22+      0  Merge branch 'irq-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 2d01eedf1d14432f4db5388a49dc5596a8c5bd02  # 16:29      0-      4  Merge branch 'akpm' (patches from Andrew)
git bisect good 6ac15baacb6ecd87c66209627753b96ded3b4515  # 17:36     21+      0  Merge branch 'timers-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 9ce71148b027e2bd27016139cae1c39401587695  # 19:04      0-     13  devpts: if initialization failed, don't crash when opening /dev/ptmx
git bisect  bad 460b865e53c347ebf110e50d499718cd9b39d810  # 20:05      0-      2  fs: document seq_open()'s usage of file->private_data
git bisect good 7e18adb4f80bea90d30b62158694d97c31f71d37  # 20:14     20+      0  mm: meminit: initialise remaining struct pages in parallel with kswapd
git bisect good ac5d2539b2382689b1cdb90bd60dcd49f61c2773  # 21:18     22+      0  mm: meminit: reduce number of times pageblocks are set during struct page init
git bisect  bad 0e1cc95b4cc7293bb7b39175035e7f7e45c90977  # 21:26      0-     12  mm: meminit: finish initialisation of struct pages before basic setup
git bisect good 74033a798f5a5db368126ee6f690111cf019bf7a  # 21:37     22+      0  mm: meminit: remove mminit_verify_page_links
# first bad commit: [0e1cc95b4cc7293bb7b39175035e7f7e45c90977] mm: meminit: finish initialisation of struct pages before basic setup
git bisect good 74033a798f5a5db368126ee6f690111cf019bf7a  # 21:41     63+      0  mm: meminit: remove mminit_verify_page_links
# extra tests with DEBUG_INFO
git bisect  bad 0e1cc95b4cc7293bb7b39175035e7f7e45c90977  # 21:50      0-      5  mm: meminit: finish initialisation of struct pages before basic setup
# extra tests on HEAD of linux-devel/devel-hourly-2015070709
git bisect  bad 9bbbdce9ba479ee60d157b45e83c2060f5e6ceac  # 21:50      0-     13  0day head guard for 'devel-hourly-2015070709'
# extra tests on tree/branch linus/master
# extra tests with first bad commit reverted
# extra tests on tree/branch linus/master
# extra tests on tree/branch next/master
git bisect  bad 8e551e96341aa57779ea93a87c857ae61a057f11  # 22:27      0-      1  Add linux-next specific files for 20150707


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 300
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	systemd.log_level=err
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_559be1ee./9tdyPbznChQo7YkntdXp/uaiwvnlAbayZyItQ03e8HMF6wr
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="dmesg-quantal-intel12-1:20150707213044:x86_64-randconfig-h0-07070925:4.1.0-11369-g0e1cc95:1"

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.1.0-11369-g0e1cc95 (kbuild@lkp-nex05) (g=
cc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP PREEMPT Tue Jul 7 21:22:08 =
CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,11=
5200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_enabled rc=
update.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 conso=
le=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-h0-07070925/linux-deve=
l:devel-hourly-2015070709:0e1cc95b4cc7293bb7b39175035e7f7e45c90977:bise=
ct-linux-6/.vmlinuz-0e1cc95b4cc7293bb7b39175035e7f7e45c90977-2015070721=
2227-3-intel12 branch=3Dlinux-devel/devel-hourly-2015070709 BOOT_IMAGE=
=3D/pkg/linux/x86_64-randconfig-h0-07070925/gcc-4.9/0e1cc95b4cc7293bb7b=
39175035e7f7e45c90977/vmlinuz-4.1.0-11369-g0e1cc95 drbd.minor_count=3D8
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] u=
sable
[    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] r=
eserved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-=
20140531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> =
reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x400000000
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
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC=
- UC =20
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size =
24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x04046000, 0x04046fff] PGTABLE
[    0.000000] BRK [0x04047000, 0x04047fff] PGTABLE
[    0.000000] BRK [0x04048000, 0x04048fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11200000-0x113fffff]
[    0.000000]  [mem 0x11200000-0x113fffff] page 4k
[    0.000000] BRK [0x04049000, 0x04049fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x111fffff]
[    0.000000]  [mem 0x00100000-0x111fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x11400000-0x12bdffff]
[    0.000000]  [mem 0x11400000-0x12bdffff] page 4k
[    0.000000] BRK [0x0404a000, 0x0404afff] PGTABLE
[    0.000000] BRK [0x0404b000, 0x0404bfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x11525000-0x12bd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFAC=
P 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000012BE0000 000040
[    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPI=
C 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPE=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000012bdf=
fff]
[    0.000000] NODE_DATA(0) allocated [mem 0x114fe000-0x11524fff]
[    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1147e001, primary cpu clock
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cyc=
les: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000012bdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001=
2bdffff]
[    0.000000] On node 0 totalpages: 76670
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1136 pages used for memmap
[    0.000000]   DMA32 zone: 72672 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, A=
PIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, A=
PIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, A=
PIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, A=
PIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, A=
PIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, A=
PIC INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, A=
PIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, A=
PIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, A=
PIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, A=
PIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, A=
PIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, A=
PIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, A=
PIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, A=
PIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, A=
PIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devi=
ces
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycle=
s: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:2 nr_cpu_ids:=
2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 477 pages/cpu @ffff880010e00000 s192275=
2 r0 d31040 u2097152
[    0.000000] pcpu-alloc: s1922752 r0 d31040 u2097152 alloc=3D1*209715=
2
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 10e0d140
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  =
Total pages: 75449
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dt=
tyS0,115200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_ena=
bled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ra=
m0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-h0-07070925/=
linux-devel:devel-hourly-2015070709:0e1cc95b4cc7293bb7b39175035e7f7e45c=
90977:bisect-linux-6/.vmlinuz-0e1cc95b4cc7293bb7b39175035e7f7e45c90977-=
20150707212227-3-intel12 branch=3Dlinux-devel/devel-hourly-2015070709 B=
OOT_IMAGE=3D/pkg/linux/x86_64-randconfig-h0-07070925/gcc-4.9/0e1cc95b4c=
c7293bb7b39175035e7f7e45c90977/vmlinuz-4.1.0-11369-g0e1cc95 drbd.minor_=
count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bai=
ling!
[    0.000000] Memory: 221944K/306680K available (8069K kernel code, 19=
32K rwdata, 4648K rodata, 4248K init, 28888K bss, 84736K reserved, 0K c=
ma-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
2, Nodes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu=
_ids=3D2
[    0.000000]=20
[    0.000000] ********************************************************=
**
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   =
**
[    0.000000] **                                                      =
**
[    0.000000] ** trace_printk() being used. Allocating extra memory.  =
**
[    0.000000] **                                                      =
**
[    0.000000] ** This means that this is a DEBUG kernel and it is     =
**
[    0.000000] ** unsafe for production use.                           =
**
[    0.000000] **                                                      =
**
[    0.000000] ** If you see this message and you are not debugging    =
**
[    0.000000] ** the kernel, report this immediately to your vendor!  =
**
[    0.000000] **                                                      =
**
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   =
**
[    0.000000] ********************************************************=
**
[    0.000000] NR_IRQS:4352 nr_irqs:440 16
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.1.0-11369-g0e1cc95 (kbuild@lkp-nex05) (g=
cc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP PREEMPT Tue Jul 7 21:22:08 =
CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,11=
5200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_enabled rc=
update.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 conso=
le=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-h0-07070925/linux-deve=
l:devel-hourly-2015070709:0e1cc95b4cc7293bb7b39175035e7f7e45c90977:bise=
ct-linux-6/.vmlinuz-0e1cc95b4cc7293bb7b39175035e7f7e45c90977-2015070721=
2227-3-intel12 branch=3Dlinux-devel/devel-hourly-2015070709 BOOT_IMAGE=
=3D/pkg/linux/x86_64-randconfig-h0-07070925/gcc-4.9/0e1cc95b4cc7293bb7b=
39175035e7f7e45c90977/vmlinuz-4.1.0-11369-g0e1cc95 drbd.minor_count=3D8
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] u=
sable
[    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] r=
eserved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-=
20140531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> =
reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x400000000
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
[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC=
- UC =20
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size =
24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x04046000, 0x04046fff] PGTABLE
[    0.000000] BRK [0x04047000, 0x04047fff] PGTABLE
[    0.000000] BRK [0x04048000, 0x04048fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11200000-0x113fffff]
[    0.000000]  [mem 0x11200000-0x113fffff] page 4k
[    0.000000] BRK [0x04049000, 0x04049fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x111fffff]
[    0.000000]  [mem 0x00100000-0x111fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x11400000-0x12bdffff]
[    0.000000]  [mem 0x11400000-0x12bdffff] page 4k
[    0.000000] BRK [0x0404a000, 0x0404afff] PGTABLE
[    0.000000] BRK [0x0404b000, 0x0404bfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x11525000-0x12bd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFAC=
P 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000012BE0000 000040
[    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPI=
C 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPE=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000012bdf=
fff]
[    0.000000] NODE_DATA(0) allocated [mem 0x114fe000-0x11524fff]
[    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1147e001, primary cpu clock
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cyc=
les: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000012bdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000001=
2bdffff]
[    0.000000] On node 0 totalpages: 76670
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1136 pages used for memmap
[    0.000000]   DMA32 zone: 72672 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, A=
PIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, A=
PIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, A=
PIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, A=
PIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, A=
PIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, A=
PIC INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, A=
PIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, A=
PIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, A=
PIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, A=
PIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, A=
PIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, A=
PIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, A=
PIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, A=
PIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, A=
PIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devi=
ces
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycle=
s: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:2 nr_cpu_ids:=
2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 477 pages/cpu @ffff880010e00000 s192275=
2 r0 d31040 u2097152
[    0.000000] pcpu-alloc: s1922752 r0 d31040 u2097152 alloc=3D1*209715=
2
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 10e0d140
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  =
Total pages: 75449
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dt=
tyS0,115200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_ena=
bled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ra=
m0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-h0-07070925/=
linux-devel:devel-hourly-2015070709:0e1cc95b4cc7293bb7b39175035e7f7e45c=
90977:bisect-linux-6/.vmlinuz-0e1cc95b4cc7293bb7b39175035e7f7e45c90977-=
20150707212227-3-intel12 branch=3Dlinux-devel/devel-hourly-2015070709 B=
OOT_IMAGE=3D/pkg/linux/x86_64-randconfig-h0-07070925/gcc-4.9/0e1cc95b4c=
c7293bb7b39175035e7f7e45c90977/vmlinuz-4.1.0-11369-g0e1cc95 drbd.minor_=
count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bai=
ling!
[    0.000000] Memory: 221944K/306680K available (8069K kernel code, 19=
32K rwdata, 4648K rodata, 4248K init, 28888K bss, 84736K reserved, 0K c=
ma-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
2, Nodes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu=
_ids=3D2
[    0.000000]=20
[    0.000000] ********************************************************=
**
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   =
**
[    0.000000] **                                                      =
**
[    0.000000] ** trace_printk() being used. Allocating extra memory.  =
**
[    0.000000] **                                                      =
**
[    0.000000] ** This means that this is a DEBUG kernel and it is     =
**
[    0.000000] ** unsafe for production use.                           =
**
[    0.000000] **                                                      =
**
[    0.000000] ** If you see this message and you are not debugging    =
**
[    0.000000] ** the kernel, report this immediately to your vendor!  =
**
[    0.000000] **                                                      =
**
[    0.000000] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   =
**
[    0.000000] ********************************************************=
**
[    0.000000] NR_IRQS:4352 nr_irqs:440 16
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] --------------------------------------------------------=
--------------------
[    0.000000] --------------------------------------------------------=
--------------------
[    0.000000]                                  | spin |wlock |rlock |m=
utex | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |m=
utex | wsem | rsem |
[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|f=
ailed|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |        =
     |  ok  |  ok  |             |             |failed|failed|

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |        =
     |  ok  |  ok  |             |             |failed|failed|

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |        =
     |failed|failed|             |             |failed|failed|

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |        =
     |failed|failed|             |             |failed|failed|

[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed=
|failed|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed=
|failed|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]   ------------------------------------------------------=
--------------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:failed|failed|  ok  | =
 ok  |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:failed|failed|  ok  | =
 ok  |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:failed|failed|  ok  | =
 ok  |failed|failed|

[    0.000000]                             block:
[    0.000000]                             block:failed|failed|  ok  | =
 ok  |failed|failed|

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:failed|failed|  ok  | =
 ok  |failed|failed|

[    0.000000] --------------------------------------------------------
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ----------------------------------------------------
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffff=
ff, max_idle_ns: 19112604467 ns
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffff=
ff, max_idle_ns: 19112604467 ns
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2926.330 MHz processor
[    0.000000] tsc: Detected 2926.330 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5852.66 =
BogoMIPS (lpj=3D29263300)
5852.66 BogoMIPS (lpj=3D29263300)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] ACPI: Core revision 20150515
[    0.020000] ACPI: Core revision 20150515
[    0.041319] ACPI:=20
[    0.041319] ACPI: All ACPI Tables successfully acquiredAll ACPI Tabl=
es successfully acquired

[    0.043088] Dentry cache hash table entries: 65536 (order: 7, 524288=
 bytes)
[    0.043088] Dentry cache hash table entries: 65536 (order: 7, 524288=
 bytes)
[    0.050215] Inode-cache hash table entries: 32768 (order: 6, 262144 =
bytes)
[    0.050215] Inode-cache hash table entries: 32768 (order: 6, 262144 =
bytes)
[    0.060089] Mount-cache hash table entries: 1024 (order: 1, 8192 byt=
es)
[    0.060089] Mount-cache hash table entries: 1024 (order: 1, 8192 byt=
es)
[    0.061975] Mountpoint-cache hash table entries: 1024 (order: 1, 819=
2 bytes)
[    0.061975] Mountpoint-cache hash table entries: 1024 (order: 1, 819=
2 bytes)
[    0.064365] Initializing cgroup subsys perf_event
[    0.064365] Initializing cgroup subsys perf_event
[    0.065772] numa_add_cpu cpu 0 node 0: mask now 0
[    0.065772] numa_add_cpu cpu 0 node 0: mask now 0
[    0.067089] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.067089] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.068614] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.068614] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.070092] debug: unmapping init [mem 0xffffffff8240b000-0xffffffff=
8240efff]
[    0.070092] debug: unmapping init [mem 0xffffffff8240b000-0xffffffff=
8240efff]
[    0.081277] ftrace: allocating 36591 entries in 143 pages
[    0.081277] ftrace: allocating 36591 entries in 143 pages
[    0.110320] enabled ExtINT on CPU#0
[    0.110320] enabled ExtINT on CPU#0
[    0.112385] ENABLING IO-APIC IRQs
[    0.112385] ENABLING IO-APIC IRQs
[    0.113294] init IO_APIC IRQs
[    0.113294] init IO_APIC IRQs
[    0.114103]  apic 0 pin 0 not connected
[    0.114103]  apic 0 pin 0 not connected
[    0.115184] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0 Dest:1)
[    0.115184] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0 Dest:1)
[    0.117489] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:=
0 Active:0 Dest:1)
[    0.117489] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:=
1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:=
1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:=
1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:=
1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mod=
e:1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mod=
e:1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mod=
e:1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mod=
e:1 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mod=
e:0 Active:0 Dest:1)
[    0.120000] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mod=
e:0 Active:0 Dest:1)
[    0.120000]  apic 0 pin 16 not connected
[    0.120000]  apic 0 pin 16 not connected
[    0.120000]  apic 0 pin 17 not connected
[    0.120000]  apic 0 pin 17 not connected
[    0.120000]  apic 0 pin 18 not connected
[    0.120000]  apic 0 pin 18 not connected
[    0.120000]  apic 0 pin 19 not connected
[    0.120000]  apic 0 pin 19 not connected
[    0.120000]  apic 0 pin 20 not connected
[    0.120000]  apic 0 pin 20 not connected
[    0.120000]  apic 0 pin 21 not connected
[    0.120000]  apic 0 pin 21 not connected
[    0.120000]  apic 0 pin 22 not connected
[    0.120000]  apic 0 pin 22 not connected
[    0.120000]  apic 0 pin 23 not connected
[    0.120000]  apic 0 pin 23 not connected
[    0.120000] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.120000] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.120000] Using local APIC timer interrupts.
[    0.120000] calibrating APIC timer ...
[    0.120000] Using local APIC timer interrupts.
[    0.120000] calibrating APIC timer ...
[    0.130000] ... lapic delta =3D 12857607
[    0.130000] ... lapic delta =3D 12857607
[    0.130000] ... PM-Timer delta =3D 736379
[    0.130000] ... PM-Timer delta =3D 736379
[    0.130000] APIC calibration not consistent with PM-Timer: 205ms ins=
tead of 100ms
[    0.130000] APIC calibration not consistent with PM-Timer: 205ms ins=
tead of 100ms
[    0.130000] APIC delta adjusted to PM-Timer: 6250085 (12857607)
[    0.130000] APIC delta adjusted to PM-Timer: 6250085 (12857607)
[    0.130000] TSC delta adjusted to PM-Timer: 292632660 (602000665)
[    0.130000] TSC delta adjusted to PM-Timer: 292632660 (602000665)
[    0.130000] ..... delta 6250085
[    0.130000] ..... delta 6250085
[    0.130000] ..... mult: 268439106
[    0.130000] ..... mult: 268439106
[    0.130000] ..... calibration result: 10000136
[    0.130000] ..... calibration result: 10000136
[    0.130000] ..... CPU clock speed is 2926.3266 MHz.
[    0.130000] ..... CPU clock speed is 2926.3266 MHz.
[    0.130000] ..... host bus clock speed is 1000.0136 MHz.
[    0.130000] ..... host bus clock speed is 1000.0136 MHz.
[    0.130117] smpboot: CPU0:=20
[    0.130117] smpboot: CPU0: Intel Intel Common KVM processorCommon KV=
M processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.141452] Performance Events:=20
[    0.141452] Performance Events: unsupported Netburst CPU model 6 uns=
upported Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.180943] x86: Booting SMP configuration:
[    0.180943] x86: Booting SMP configuration:
[    0.182800] .... node  #0, CPUs: =20
[    0.182800] .... node  #0, CPUs:         #1 #1
[    0.170187] kvm-clock: cpu 1, msr 0:1147e041, secondary cpu clock
[    0.170187] masked ExtINT on CPU#1
[    0.170187] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.230106] x86: Booted up 1 node, 2 CPUs
[    0.230106] x86: Booted up 1 node, 2 CPUs
[    0.231023] smpboot: Total of 2 processors activated (11705.32 BogoM=
IPS)
[    0.231023] smpboot: Total of 2 processors activated (11705.32 BogoM=
IPS)
[    0.240010] KVM setup async PF for cpu 1
[    0.240010] KVM setup async PF for cpu 1
[    0.240862] kvm-stealtime: cpu 1, msr 1100d140
[    0.240862] kvm-stealtime: cpu 1, msr 1100d140
[    0.260270] ------------[ cut here ]------------
[    0.260270] ------------[ cut here ]------------
[    0.261323] WARNING: CPU: 1 PID: 15 at kernel/locking/lockdep.c:3382=
 lock_release+0xde/0x3d3()
[    0.261323] WARNING: CPU: 1 PID: 15 at kernel/locking/lockdep.c:3382=
 lock_release+0xde/0x3d3()
[    0.264199] DEBUG_LOCKS_WARN_ON(depth <=3D 0)
[    0.264199] DEBUG_LOCKS_WARN_ON(depth <=3D 0)

[    0.265313] CPU: 1 PID: 15 Comm: pgdatinit0 Not tainted 4.1.0-11369-=
g0e1cc95 #1
[    0.265313] CPU: 1 PID: 15 Comm: pgdatinit0 Not tainted 4.1.0-11369-=
g0e1cc95 #1
[    0.269739] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), B=
IOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.269739] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), B=
IOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.270000]  0000000000000009
[    0.270000]  0000000000000009 ffff88000f997c48 ffff88000f997c48 ffff=
ffff817d5686 ffffffff817d5686 ffffffff810cb07d ffffffff810cb07d

[    0.270000]  ffff88000f997c98
[    0.270000]  ffff88000f997c98 ffff88000f997c88 ffff88000f997c88 ffff=
ffff8108bd43 ffffffff8108bd43 ffff88000f997c68 ffff88000f997c68

[    0.270000]  ffffffff810c3b8d
[    0.270000]  ffffffff810c3b8d ffff88000f990000 ffff88000f990000 ffff=
8800114fe000 ffff8800114fe000 ffffffff8236e530 ffffffff8236e530

[    0.270000] Call Trace:
[    0.270000] Call Trace:
[    0.270000]  [<ffffffff817d5686>] dump_stack+0x4c/0x6e
[    0.270000]  [<ffffffff817d5686>] dump_stack+0x4c/0x6e
[    0.270000]  [<ffffffff810cb07d>] ? console_unlock+0x3f3/0x422
[    0.270000]  [<ffffffff810cb07d>] ? console_unlock+0x3f3/0x422
[    0.270000]  [<ffffffff8108bd43>] warn_slowpath_common+0x9c/0xb6
[    0.270000]  [<ffffffff8108bd43>] warn_slowpath_common+0x9c/0xb6
[    0.270000]  [<ffffffff810c3b8d>] ? lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff810c3b8d>] ? lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff821dc011>] ? deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff821dc011>] ? deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff8108bdc2>] warn_slowpath_fmt+0x46/0x48
[    0.270000]  [<ffffffff8108bdc2>] warn_slowpath_fmt+0x46/0x48
[    0.270000]  [<ffffffff810c3b8d>] lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff810c3b8d>] lock_release+0xde/0x3d3
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff810c08ac>] up_read+0x20/0x2c
[    0.270000]  [<ffffffff810c08ac>] up_read+0x20/0x2c
[    0.270000]  [<ffffffff821dc011>] deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff821dc011>] deferred_init_memmap+0x306/0x32d
[    0.270000]  [<ffffffff817d9ea9>] ? __schedule+0x3b9/0x5af
[    0.270000]  [<ffffffff817d9ea9>] ? __schedule+0x3b9/0x5af
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff821dbd0b>] ? deferred_free_range+0x63/0x63
[    0.270000]  [<ffffffff810a2cb8>] kthread+0xe0/0xe8
[    0.270000]  [<ffffffff810a2cb8>] kthread+0xe0/0xe8
[    0.270000]  [<ffffffff817de2eb>] ? _raw_spin_unlock_irq+0x32/0x46
[    0.270000]  [<ffffffff817de2eb>] ? _raw_spin_unlock_irq+0x32/0x46
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff817df1cf>] ret_from_fork+0x3f/0x70
[    0.270000]  [<ffffffff817df1cf>] ret_from_fork+0x3f/0x70
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000]  [<ffffffff810a2bd8>] ? __kthread_parkme+0xad/0xad
[    0.270000] ---[ end trace 95f3f95a9e2dd516 ]---
[    0.270000] ---[ end trace 95f3f95a9e2dd516 ]---
[    0.380104] devtmpfs: initialized
[    0.380104] devtmpfs: initialized
[    0.402412] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfff=
fffff, max_idle_ns: 19112604462750000 ns
[    0.402412] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfff=
fffff, max_idle_ns: 19112604462750000 ns
[    0.420118] atomic64_test: passed for x86-64 platform with CX8 and w=
ith SSE
[    0.420118] atomic64_test: passed for x86-64 platform with CX8 and w=
ith SSE
[    0.422083] RTC time: 21:29:08, date: 07/07/15
[    0.422083] RTC time: 21:29:08, date: 07/07/15
[    0.423800] NET: Registered protocol family 16
[    0.423800] NET: Registered protocol family 16
[    0.460038] cpuidle: using governor ladder
[    0.460038] cpuidle: using governor ladder
[    0.490035] cpuidle: using governor menu
[    0.490035] cpuidle: using governor menu
[    0.491893] ACPI: bus type PCI registered
[    0.491893] ACPI: bus type PCI registered
[    0.493008] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.=
5
[    0.493008] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.=
5
[    0.494882] PCI: Using configuration type 1 for base access
[    0.494882] PCI: Using configuration type 1 for base access
[    0.530366] ACPI: Added _OSI(Module Device)
[    0.530366] ACPI: Added _OSI(Module Device)
[    0.531505] ACPI: Added _OSI(Processor Device)
[    0.531505] ACPI: Added _OSI(Processor Device)
[    0.532688] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.532688] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.533948] ACPI: Added _OSI(Processor Aggregator Device)
[    0.533948] ACPI: Added _OSI(Processor Aggregator Device)
[    0.540432] ACPI: Interpreter enabled
[    0.540432] ACPI: Interpreter enabled
[    0.541518] ACPI Exception: AE_NOT_FOUND,=20
[    0.541518] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep Sta=
te [\_S1_]While evaluating Sleep State [\_S1_] (20150515/hwxface-580)
 (20150515/hwxface-580)
[    0.560680] ACPI Exception: AE_NOT_FOUND,=20
[    0.560680] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep Sta=
te [\_S2_]While evaluating Sleep State [\_S2_] (20150515/hwxface-580)
 (20150515/hwxface-580)
[    0.563294] ACPI: (supports S0 S3 S5)
[    0.563294] ACPI: (supports S0 S3 S5)
[    0.564318] ACPI: Using IOAPIC for interrupt routing
[    0.564318] ACPI: Using IOAPIC for interrupt routing
[    0.565724] PCI: Using host bridge windows from ACPI; if necessary, =
use "pci=3Dnocrs" and report a bug
[    0.565724] PCI: Using host bridge windows from ACPI; if necessary, =
use "pci=3Dnocrs" and report a bug
[    0.590497] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.590497] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.600015] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.600015] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.610022] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling A=
SPM
[    0.610022] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling A=
SPM
[    0.612053] acpi PNP0A03:00: fail to add MMCONFIG information, can't=
 access extended PCI configuration space under this bridge.
[    0.612053] acpi PNP0A03:00: fail to add MMCONFIG information, can't=
 access extended PCI configuration space under this bridge.
[    0.620647] acpiphp: Slot [3] registered
[    0.620647] acpiphp: Slot [3] registered
[    0.621913] acpiphp: Slot [4] registered
[    0.621913] acpiphp: Slot [4] registered
[    0.630063] acpiphp: Slot [5] registered
[    0.630063] acpiphp: Slot [5] registered
[    0.631228] acpiphp: Slot [6] registered
[    0.631228] acpiphp: Slot [6] registered
[    0.632376] acpiphp: Slot [7] registered
[    0.632376] acpiphp: Slot [7] registered
[    0.633530] acpiphp: Slot [8] registered
[    0.633530] acpiphp: Slot [8] registered
[    0.634695] acpiphp: Slot [9] registered
[    0.634695] acpiphp: Slot [9] registered
[    0.635860] acpiphp: Slot [10] registered
[    0.635860] acpiphp: Slot [10] registered
[    0.637040] acpiphp: Slot [11] registered
[    0.637040] acpiphp: Slot [11] registered
[    0.638221] acpiphp: Slot [12] registered
[    0.638221] acpiphp: Slot [12] registered
[    0.640060] acpiphp: Slot [13] registered
[    0.640060] acpiphp: Slot [13] registered
[    0.641235] acpiphp: Slot [14] registered
[    0.641235] acpiphp: Slot [14] registered
[    0.650086] acpiphp: Slot [15] registered
[    0.650086] acpiphp: Slot [15] registered
[    0.651269] acpiphp: Slot [16] registered
[    0.651269] acpiphp: Slot [16] registered
[    0.652446] acpiphp: Slot [17] registered
[    0.652446] acpiphp: Slot [17] registered
[    0.653630] acpiphp: Slot [18] registered
[    0.653630] acpiphp: Slot [18] registered
[    0.660061] acpiphp: Slot [19] registered
[    0.660061] acpiphp: Slot [19] registered
[    0.661247] acpiphp: Slot [20] registered
[    0.661247] acpiphp: Slot [20] registered
[    0.662422] acpiphp: Slot [21] registered
[    0.662422] acpiphp: Slot [21] registered
[    0.663600] acpiphp: Slot [22] registered
[    0.663600] acpiphp: Slot [22] registered
[    0.664781] acpiphp: Slot [23] registered
[    0.664781] acpiphp: Slot [23] registered
[    0.665958] acpiphp: Slot [24] registered
[    0.665958] acpiphp: Slot [24] registered
[    0.667131] acpiphp: Slot [25] registered
[    0.667131] acpiphp: Slot [25] registered
[    0.670081] acpiphp: Slot [26] registered
[    0.670081] acpiphp: Slot [26] registered
[    0.680053] acpiphp: Slot [27] registered
[    0.680053] acpiphp: Slot [27] registered
[    0.681162] acpiphp: Slot [28] registered
[    0.681162] acpiphp: Slot [28] registered
[    0.682289] acpiphp: Slot [29] registered
[    0.682289] acpiphp: Slot [29] registered
[    0.683404] acpiphp: Slot [30] registered
[    0.683404] acpiphp: Slot [30] registered
[    0.684516] acpiphp: Slot [31] registered
[    0.684516] acpiphp: Slot [31] registered
[    0.685603] PCI host bridge to bus 0000:00
[    0.685603] PCI host bridge to bus 0000:00
[    0.686659] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.686659] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.688087] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 wi=
ndow]
[    0.688087] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 wi=
ndow]
[    0.690010] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff wi=
ndow]
[    0.690010] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff wi=
ndow]
[    0.700011] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff wi=
ndow]
[    0.700011] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff wi=
ndow]
[    0.701729] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf wi=
ndow]
[    0.701729] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf wi=
ndow]
[    0.703486] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff wi=
ndow]
[    0.703486] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff wi=
ndow]
[    0.710009] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000=
bffff window]
[    0.710009] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000=
bffff window]
[    0.711972] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfeb=
fffff window]
[    0.711972] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfeb=
fffff window]
[    0.713985] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.713985] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.716195] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.716195] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.720819] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.720819] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.753379] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.753379] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.763346] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f=
0-0x01f7]
[    0.763346] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f=
0-0x01f7]
[    0.765211] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f=
6]
[    0.765211] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f=
6]
[    0.766894] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x017=
0-0x0177]
[    0.766894] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x017=
0-0x0177]
[    0.770013] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x037=
6]
[    0.770013] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x037=
6]
[    0.772132] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.772132] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.773900] pci 0000:00:01.3: can't claim BAR 13 [io  0x0600-0x063f]=
: address conflict with ACPI PM1a_EVT_BLK [io  0x0600-0x0603]
[    0.773900] pci 0000:00:01.3: can't claim BAR 13 [io  0x0600-0x063f]=
: address conflict with ACPI PM1a_EVT_BLK [io  0x0600-0x0603]
[    0.780023] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by =
PIIX4 SMB
[    0.780023] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by =
PIIX4 SMB
[    0.783568] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.783568] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.790023] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff p=
ref]
[    0.790023] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff p=
ref]
[    0.803518] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.803518] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.850029] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff p=
ref]
[    0.850029] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff p=
ref]
[    0.860126] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.860126] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.870014] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.870014] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.878371] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.878371] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.940011] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff p=
ref]
[    0.940011] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff p=
ref]
[    0.942171] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.942171] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.963365] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.963365] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.973593] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.973593] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    1.030487] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.030487] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.038703] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.038703] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.046091] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.046091] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.100515] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.100515] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.120017] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.120017] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.133355] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.133355] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.208506] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.208506] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.216783] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.216783] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.223013] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.223013] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.282647] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.282647] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.300014] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.300014] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.320012] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.320012] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.390517] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.390517] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.400013] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.400013] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.410014] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.410014] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.500437] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    1.500437] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    1.520015] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    1.520015] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    1.540012] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    1.540012] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    1.631500] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    1.631500] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    1.650012] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    1.650012] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    1.727263] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.727263] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11)=
)

[    1.730632] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.730632] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11)=
)

[    1.736329] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.736329] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11)=
)

[    1.741603] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.741603] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11)=
)

[    1.745632] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.745632] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.752024] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.752024] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.752024] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    1.752024] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    1.753875] vgaarb: loaded
[    1.753875] vgaarb: loaded
[    1.754626] vgaarb: bridge control possible 0000:00:02.0
[    1.754626] vgaarb: bridge control possible 0000:00:02.0
[    1.760646] ACPI: bus type USB registered
[    1.760646] ACPI: bus type USB registered
[    1.760646] usbcore: registered new interface driver usbfs
[    1.760646] usbcore: registered new interface driver usbfs
[    1.761610] usbcore: registered new interface driver hub
[    1.761610] usbcore: registered new interface driver hub
[    1.765365] usbcore: registered new device driver usb
[    1.765365] usbcore: registered new device driver usb
[    1.765365] pps_core: LinuxPPS API ver. 1 registered
[    1.765365] pps_core: LinuxPPS API ver. 1 registered
[    1.765365] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodo=
lfo Giometti <giometti@linux.it>
[    1.765365] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodo=
lfo Giometti <giometti@linux.it>
[    1.765671] wmi: Mapper loaded
[    1.765671] wmi: Mapper loaded
[    1.770109] PCI: Using ACPI for IRQ routing
[    1.770109] PCI: Using ACPI for IRQ routing
[    1.771279] PCI: pci_cache_line_size set to 64 bytes
[    1.771279] PCI: pci_cache_line_size set to 64 bytes
[    1.772923] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.772923] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.774560] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
[    1.774560] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
[    1.805984] clocksource: Switched to clocksource kvm-clock
[    1.805984] clocksource: Switched to clocksource kvm-clock
[    1.853082] FS-Cache: Loaded
[    1.853082] FS-Cache: Loaded
[    1.853840] pnp: PnP ACPI init
[    1.853840] pnp: PnP ACPI init
[    1.855800] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    1.855800] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    1.859697] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (activ=
e)
[    1.859697] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (activ=
e)
[    1.863677] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (activ=
e)
[    1.863677] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (activ=
e)
[    1.867631] pnp 00:03: [dma 2]
[    1.867631] pnp 00:03: [dma 2]
[    1.882585] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (activ=
e)
[    1.882585] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (activ=
e)
[    1.884506] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (activ=
e)
[    1.884506] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (activ=
e)
[    1.886405] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (activ=
e)
[    1.886405] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (activ=
e)
[    1.908815] pnp: PnP ACPI: found 6 devices
[    1.908815] pnp: PnP ACPI: found 6 devices
[    1.942061] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xfffff=
f, max_idle_ns: 2085701024 ns
[    1.942061] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xfffff=
f, max_idle_ns: 2085701024 ns
[    1.944133] pci 0000:00:01.3: BAR 13: [io  size 0x0040] has bogus al=
ignment
[    1.944133] pci 0000:00:01.3: BAR 13: [io  size 0x0040] has bogus al=
ignment
[    1.945682] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.945682] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.947052] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    1.947052] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    1.948448] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    1.948448] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    1.966908] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    1.966908] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    1.968322] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    1.968322] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    1.969779] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff w=
indow]
[    1.969779] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff w=
indow]
[    1.971640] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff =
window]
[    1.971640] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff =
window]
[    1.973561] NET: Registered protocol family 1
[    1.973561] NET: Registered protocol family 1
[    1.974774] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.974774] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.994260] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.994260] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.995587] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.995587] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.997139] pci 0000:00:02.0: Video device with shadowed ROM
[    1.997139] pci 0000:00:02.0: Video device with shadowed ROM
[    1.998771] PCI: CLS 0 bytes, default 64
[    1.998771] PCI: CLS 0 bytes, default 64
[    1.999928] Unpacking initramfs...
[    1.999928] Unpacking initramfs...
[    4.091596] debug: unmapping init [mem 0xffff880011525000-0xffff8800=
12bd7fff]
[    4.091596] debug: unmapping init [mem 0xffff880011525000-0xffff8800=
12bd7fff]
[    4.152326] Scanning for low memory corruption every 60 seconds
[    4.152326] Scanning for low memory corruption every 60 seconds
[    4.162086] camellia-x86_64: performance on this CPU would be subopt=
imal: disabling camellia-x86_64.
[    4.162086] camellia-x86_64: performance on this CPU would be subopt=
imal: disabling camellia-x86_64.
[    4.171080] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/=
usable.
[    4.171080] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/=
usable.
[    4.172986] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    4.172986] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    4.174710] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    4.174710] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    4.176435] CPU feature 'AVX registers' is not supported.
[    4.176435] CPU feature 'AVX registers' is not supported.
[    4.177896] CPU feature 'AVX registers' is not supported.
[    4.177896] CPU feature 'AVX registers' is not supported.
[    4.179371] AVX2 or AES-NI instructions are not detected.
[    4.179371] AVX2 or AES-NI instructions are not detected.
[    4.199261] futex hash table entries: 512 (order: 4, 65536 bytes)
[    4.199261] futex hash table entries: 512 (order: 4, 65536 bytes)
[    4.209452] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    4.209452] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    4.228619] fuse init (API version 7.23)
[    4.228619] fuse init (API version 7.23)
[    4.247685] Key type asymmetric registered
[    4.247685] Key type asymmetric registered
[    4.249134] test_string_helpers: Running tests...
[    4.249134] test_string_helpers: Running tests...
[    4.250674] test_hexdump: Running tests...
[    4.250674] test_hexdump: Running tests...
[    4.252377] test_firmware: interface ready
[    4.252377] test_firmware: interface ready
[    4.253518] Running rhashtable test nelem=3D8, max_size=3D65536, shr=
inking=3D0
[    4.253518] Running rhashtable test nelem=3D8, max_size=3D65536, shr=
inking=3D0
[    4.255358] Test 00:
[    4.255358] Test 00:
[    4.276897]   Adding 50000 keys
[    4.276897]   Adding 50000 keys
[    4.425413] Info: encountered resize
[    4.425413] Info: encountered resize
[    4.427654]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D1
[    4.427654]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D1
[    4.494708]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.494708]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.496640]   Deleting 50000 keys
[    4.496640]   Deleting 50000 keys
[    4.564251]   Duration of test: 286589245 ns
[    4.564251]   Duration of test: 286589245 ns
[    4.565323] Test 01:
[    4.565323] Test 01:
[    4.567674]   Adding 50000 keys
[    4.567674]   Adding 50000 keys
[    4.809759]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.809759]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.886784]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.886784]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    4.888700]   Deleting 50000 keys
[    4.888700]   Deleting 50000 keys
[    4.977249]   Duration of test: 408808017 ns
[    4.977249]   Duration of test: 408808017 ns
[    4.986239] Test 02:
[    4.986239] Test 02:
[    4.988796]   Adding 50000 keys
[    4.988796]   Adding 50000 keys
[    5.112160] tsc: Refined TSC clocksource calibration: 2926.330 MHz
[    5.112160] tsc: Refined TSC clocksource calibration: 2926.330 MHz
[    5.130039] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0=
x2a2e6c2e1bb, max_idle_ns: 440795237926 ns
[    5.130039] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0=
x2a2e6c2e1bb, max_idle_ns: 440795237926 ns
[    5.201415]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.201415]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.272211]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.272211]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.281294]   Deleting 50000 keys
[    5.281294]   Deleting 50000 keys
[    5.369607]   Duration of test: 373133553 ns
[    5.369607]   Duration of test: 373133553 ns
[    5.370888] Test 03:
[    5.370888] Test 03:
[    5.380225]   Adding 50000 keys
[    5.380225]   Adding 50000 keys
[    5.591430]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.591430]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.669744]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.669744]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    5.672114]   Deleting 50000 keys
[    5.672114]   Deleting 50000 keys
[    5.760468]   Duration of test: 379510429 ns
[    5.760468]   Duration of test: 379510429 ns
[    5.761480] Average test time: 362010311
[    5.761480] Average test time: 362010311
[    5.770330] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    5.770330] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    5.771674] crc32: self tests passed, processed 225944 bytes in 6080=
34 nsec
[    5.771674] crc32: self tests passed, processed 225944 bytes in 6080=
34 nsec
[    5.780864] crc32c: CRC_LE_BITS =3D 8
[    5.780864] crc32c: CRC_LE_BITS =3D 8
[    5.781842] crc32c: self tests passed, processed 225944 bytes in 262=
827 nsec
[    5.781842] crc32c: self tests passed, processed 225944 bytes in 262=
827 nsec
[    5.917809] crc32_combine: 8373 self tests passed
[    5.917809] crc32_combine: 8373 self tests passed
[    6.016805] crc32c_combine: 8373 self tests passed
[    6.016805] crc32c_combine: 8373 self tests passed
[    6.018375] xz_dec_test: module loaded
[    6.018375] xz_dec_test: module loaded
[    6.019417] xz_dec_test: Create a device node with 'mknod xz_dec_tes=
t c 250 0' and write .xz files to it.
[    6.019417] xz_dec_test: Create a device node with 'mknod xz_dec_tes=
t c 250 0' and write .xz files to it.
[    6.022816] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.022816] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.042511] shpchp: Standard Hot Plug PCI Controller Driver version:=
 0.4
[    6.042511] shpchp: Standard Hot Plug PCI Controller Driver version:=
 0.4
[    6.046969] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace faile=
d
[    6.046969] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace faile=
d
[    6.049303] rivafb_setup START
[    6.049303] rivafb_setup START
[    6.050550] vmlfb: initializing
[    6.050550] vmlfb: initializing
[    6.069548] Could not find Carillo Ranch MCH device.
[    6.069548] Could not find Carillo Ranch MCH device.
[    6.070988] no IO addresses supplied
[    6.070988] no IO addresses supplied
[    6.072144] hgafb: HGA card not detected.
[    6.072144] hgafb: HGA card not detected.
[    6.073245] hgafb: probe of hgafb.0 failed with error -22
[    6.073245] hgafb: probe of hgafb.0 failed with error -22
[    6.074870] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, =
RAM (4096 kB) at 0xfc000000
[    6.074870] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, =
RAM (4096 kB) at 0xfc000000
[    6.089647] usbcore: registered new interface driver udlfb
[    6.089647] usbcore: registered new interface driver udlfb
[    6.090913] usbcore: registered new interface driver smscufx
[    6.090913] usbcore: registered new interface driver smscufx
[    6.092377] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/=
input/input0
[    6.092377] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/=
input/input0
[    6.101047] ACPI: Power Button [PWRF]
[    6.101047] ACPI: Power Button [PWRF]
[    6.102164] button: probe of LNXPWRBN:00 failed with error -22
[    6.102164] button: probe of LNXPWRBN:00 failed with error -22
[    6.111067] GHES: HEST is not enabled!
[    6.111067] GHES: HEST is not enabled!
[    6.495103] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    6.495103] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    6.503482] virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy =
driver
[    6.503482] virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy =
driver
[    7.283760] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    7.283760] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    7.285353] virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy =
driver
[    7.285353] virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy =
driver
[    8.064068] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    8.064068] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    8.065651] virtio-pci 0000:00:06.0: virtio_pci: leaving for legacy =
driver
[    8.065651] virtio-pci 0000:00:06.0: virtio_pci: leaving for legacy =
driver
[    8.779155] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    8.779155] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    8.780833] virtio-pci 0000:00:07.0: virtio_pci: leaving for legacy =
driver
[    8.780833] virtio-pci 0000:00:07.0: virtio_pci: leaving for legacy =
driver
[    9.578929] virtio-pci 0000:00:08.0: virtio_pci: leaving for legacy =
driver
[    9.578929] virtio-pci 0000:00:08.0: virtio_pci: leaving for legacy =
driver
[   10.394918] virtio-pci 0000:00:09.0: virtio_pci: leaving for legacy =
driver
[   10.394918] virtio-pci 0000:00:09.0: virtio_pci: leaving for legacy =
driver
[   11.197531] virtio-pci 0000:00:0a.0: virtio_pci: leaving for legacy =
driver
[   11.197531] virtio-pci 0000:00:0a.0: virtio_pci: leaving for legacy =
driver
[   11.961741] r3964: Philips r3964 Driver $Revision: 1.10 $
[   11.961741] r3964: Philips r3964 Driver $Revision: 1.10 $
[   11.963168] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   11.963168] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   12.070032] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1152=
00) is a 16550A
[   12.070032] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1152=
00) is a 16550A
[   12.089454] Initializing Nozomi driver 2.1d
[   12.089454] Initializing Nozomi driver 2.1d
[   12.090624] lp: driver loaded but no devices found
[   12.090624] lp: driver loaded but no devices found
[   12.091933] Non-volatile memory driver v1.3
[   12.091933] Non-volatile memory driver v1.3
[   12.093239] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[   12.093239] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[   12.094471] smapi::smapi_init, ERROR invalid usSmapiID
[   12.094471] smapi::smapi_init, ERROR invalid usSmapiID
[   12.095721] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAP=
I is not available on this machine
[   12.095721] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAP=
I is not available on this machine
[   12.120025] mwave: mwavedd::mwave_init: Error: Failed to initialize =
board data
[   12.120025] mwave: mwavedd::mwave_init: Error: Failed to initialize =
board data
[   12.121775] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   12.121775] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   12.123317] Linux agpgart interface v0.103
[   12.123317] Linux agpgart interface v0.103
[   12.124510] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 s=
econds, margin is 60 seconds).
[   12.124510] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 s=
econds, margin is 60 seconds).
[   12.126926] [drm] Initialized drm 1.1.0 20060810
[   12.126926] [drm] Initialized drm 1.1.0 20060810
[   12.148458] [drm] amdgpu kernel modesetting enabled.
[   12.148458] [drm] amdgpu kernel modesetting enabled.
[   12.149953] usbcore: registered new interface driver udl
[   12.149953] usbcore: registered new interface driver udl
[   12.181146] ibmasm: IBM ASM Service Processor Driver version 1.0 loa=
ded
[   12.181146] ibmasm: IBM ASM Service Processor Driver version 1.0 loa=
ded
[   12.182835] dummy-irq: no IRQ given.  Use irq=3DN
[   12.182835] dummy-irq: no IRQ given.  Use irq=3DN
[   12.184070] Phantom Linux Driver, version n0.9.8, init OK
[   12.184070] Phantom Linux Driver, version n0.9.8, init OK
[   12.199806] usbcore: registered new interface driver viperboard
[   12.199806] usbcore: registered new interface driver viperboard
[   12.201474] mtdoops: mtd device (mtddev=3Dname/number) must be suppl=
ied
[   12.201474] mtdoops: mtd device (mtddev=3Dname/number) must be suppl=
ied
[   12.203082] device id =3D 2440
[   12.203082] device id =3D 2440
[   12.203828] device id =3D 2480
[   12.203828] device id =3D 2480
[   12.204578] device id =3D 24c0
[   12.204578] device id =3D 24c0
[   12.205335] device id =3D 24d0
[   12.205335] device id =3D 24d0
[   12.228162] device id =3D 25a1
[   12.228162] device id =3D 25a1
[   12.228929] device id =3D 2670
[   12.228929] device id =3D 2670
[   12.229873] slram: not enough parameters.
[   12.229873] slram: not enough parameters.
[   12.350038] No valid DiskOnChip devices found
[   12.350038] No valid DiskOnChip devices found
[   12.351170] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.351170] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.353637] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.353637] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.356209] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.356209] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.380841] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.380841] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.383134] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.383134] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.385531] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.385531] [nandsim] warning: read_byte: unexpected data output cyc=
le, state is STATE_READY return 0x0
[   12.408325] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   12.408325] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   12.416736] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   12.416736] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   12.417949] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, =
OOB size: 16
[   12.417949] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, =
OOB size: 16
[   12.430392] flash size: 128 MiB
[   12.430392] flash size: 128 MiB
[   12.431288] page size: 512 bytes
[   12.431288] page size: 512 bytes
[   12.432196] OOB area size: 16 bytes
[   12.432196] OOB area size: 16 bytes
[   12.439723] sector size: 16 KiB
[   12.439723] sector size: 16 KiB
[   12.440551] pages number: 262144
[   12.440551] pages number: 262144
[   12.441353] pages per sector: 32
[   12.441353] pages per sector: 32
[   12.442156] bus width: 8
[   12.442156] bus width: 8
[   12.442788] bits in sector size: 14
[   12.442788] bits in sector size: 14
[   12.443688] bits in page size: 9
[   12.443688] bits in page size: 9
[   12.444523] bits in OOB size: 4
[   12.444523] bits in OOB size: 4
[   12.445336] flash size with OOB: 135168 KiB
[   12.445336] flash size with OOB: 135168 KiB
[   12.466504] page address bytes: 4
[   12.466504] page address bytes: 4
[   12.467378] sector address bytes: 3
[   12.467378] sector address bytes: 3
[   12.468294] options: 0x42
[   12.468294] options: 0x42
[   12.469978] Scanning device for bad blocks
[   12.469978] Scanning device for bad blocks
[   12.547629] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   12.547629] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   12.567321] 0x000000000000-0x000008000000 : "NAND simulator partitio=
n 0"
[   12.567321] 0x000000000000-0x000008000000 : "NAND simulator partitio=
n 0"
[   12.591537] usbcore: registered new interface driver hwa-rc
[   12.591537] usbcore: registered new interface driver hwa-rc
[   12.593121] usbcore: registered new interface driver i1480-dfu-usb
[   12.593121] usbcore: registered new interface driver i1480-dfu-usb
[   12.597679] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   12.597679] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   12.599375] ohci-platform: OHCI generic platform driver
[   12.599375] ohci-platform: OHCI generic platform driver
[   12.610027] uhci_hcd: USB Universal Host Controller Interface driver
[   12.610027] uhci_hcd: USB Universal Host Controller Interface driver
[   12.615245] driver u132_hcd
[   12.615245] driver u132_hcd
[   12.616146] usbcore: registered new interface driver hwa-hc
[   12.616146] usbcore: registered new interface driver hwa-hc
[   12.630234] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[   12.630234] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[   12.634046] usbcore: registered new interface driver cdc_acm
[   12.634046] usbcore: registered new interface driver cdc_acm
[   12.644779] cdc_acm: USB Abstract Control Model driver for USB modem=
s and ISDN adapters
[   12.644779] cdc_acm: USB Abstract Control Model driver for USB modem=
s and ISDN adapters
[   12.653048] usbcore: registered new interface driver usblp
[   12.653048] usbcore: registered new interface driver usblp
[   12.654721] usbcore: registered new interface driver usbtmc
[   12.654721] usbcore: registered new interface driver usbtmc
[   12.656292] usbcore: registered new interface driver mdc800
[   12.656292] usbcore: registered new interface driver mdc800
[   12.657798] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800=
 Digital Camera
[   12.657798] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800=
 Digital Camera
[   12.659722] usbcore: registered new interface driver adutux
[   12.659722] usbcore: registered new interface driver adutux
[   12.673367] usbcore: registered new interface driver cytherm
[   12.673367] usbcore: registered new interface driver cytherm
[   12.678457] usbcore: registered new interface driver emi26 - firmwar=
e loader
[   12.678457] usbcore: registered new interface driver emi26 - firmwar=
e loader
[   12.685811] ftdi_elan: driver ftdi-elan
[   12.685811] ftdi_elan: driver ftdi-elan
[   12.689592] usbcore: registered new interface driver ftdi-elan
[   12.689592] usbcore: registered new interface driver ftdi-elan
[   12.696653] usbcore: registered new interface driver idmouse
[   12.696653] usbcore: registered new interface driver idmouse
[   12.703032] usbcore: registered new interface driver iowarrior
[   12.703032] usbcore: registered new interface driver iowarrior
[   12.709496] usbcore: registered new interface driver isight_firmware
[   12.709496] usbcore: registered new interface driver isight_firmware
[   12.715316] usbcore: registered new interface driver usblcd
[   12.715316] usbcore: registered new interface driver usblcd
[   12.721141] usbcore: registered new interface driver ldusb
[   12.721141] usbcore: registered new interface driver ldusb
[   12.726305] usbcore: registered new interface driver usbled
[   12.726305] usbcore: registered new interface driver usbled
[   12.729838] usbcore: registered new interface driver legousbtower
[   12.729838] usbcore: registered new interface driver legousbtower
[   12.738322] usbcore: registered new interface driver rio500
[   12.738322] usbcore: registered new interface driver rio500
[   12.744410] usbcore: registered new interface driver usbtest
[   12.744410] usbcore: registered new interface driver usbtest
[   12.748934] usbcore: registered new interface driver usb_ehset_test
[   12.748934] usbcore: registered new interface driver usb_ehset_test
[   12.762469] usbcore: registered new interface driver trancevibrator
[   12.762469] usbcore: registered new interface driver trancevibrator
[   12.780206] usbcore: registered new interface driver uss720
[   12.780206] usbcore: registered new interface driver uss720
[   12.781663] uss720: v0.6:USB Parport Cable driver for Cables using t=
he Lucent Technologies USS720 Chip
[   12.781663] uss720: v0.6:USB Parport Cable driver for Cables using t=
he Lucent Technologies USS720 Chip
[   12.783986] uss720: NOTE: this is a special purpose driver to allow =
nonstandard
[   12.783986] uss720: NOTE: this is a special purpose driver to allow =
nonstandard
[   12.801979] uss720: protocols (eg. bitbang) over USS720 usb to paral=
lel cables
[   12.801979] uss720: protocols (eg. bitbang) over USS720 usb to paral=
lel cables
[   12.803808] uss720: If you just want to connect to a printer, use us=
blp instead
[   12.803808] uss720: If you just want to connect to a printer, use us=
blp instead
[   12.821883] usbcore: registered new interface driver usbsevseg
[   12.821883] usbcore: registered new interface driver usbsevseg
[   12.823471] usbcore: registered new interface driver yurex
[   12.823471] usbcore: registered new interface driver yurex
[   12.824928] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at=
 0x60,0x64 irq 1,12
[   12.824928] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at=
 0x60,0x64 irq 1,12
[   12.847403] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.847403] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.862339] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.862339] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.874473] parkbd: no such parport
[   12.874473] parkbd: no such parport
[   13.058116] mousedev: PS/2 mouse device common for all mice
[   13.058116] mousedev: PS/2 mouse device common for all mice
[   13.059723] usbcore: registered new interface driver appletouch
[   13.059723] usbcore: registered new interface driver appletouch
[   13.064543] input: AT Translated Set 2 keyboard as /devices/platform=
/i8042/serio0/input/input1
[   13.064543] input: AT Translated Set 2 keyboard as /devices/platform=
/i8042/serio0/input/input1
[   13.069510] evbug: Connected device: input1 (AT Translated Set 2 key=
board at isa0060/serio0/input0)
[   13.069510] evbug: Connected device: input1 (AT Translated Set 2 key=
board at isa0060/serio0/input0)
[   13.078394] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700=
, revision 0
[   13.078394] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700=
, revision 0
[   13.323258] input: ImExPS/2 Generic Explorer Mouse as /devices/platf=
orm/i8042/serio1/input/input3
[   13.323258] input: ImExPS/2 Generic Explorer Mouse as /devices/platf=
orm/i8042/serio1/input/input3
[   13.325634] evbug: Connected device: input3 (ImExPS/2 Generic Explor=
er Mouse at isa0060/serio1/input0)
[   13.325634] evbug: Connected device: input3 (ImExPS/2 Generic Explor=
er Mouse at isa0060/serio1/input0)
[   13.341470] i2c-parport: adapter type unspecified
[   13.341470] i2c-parport: adapter type unspecified
[   13.342813] usbcore: registered new interface driver RobotFuzz Open =
Source InterFace, OSIF
[   13.342813] usbcore: registered new interface driver RobotFuzz Open =
Source InterFace, OSIF
[   13.352894] usbcore: registered new interface driver i2c-tiny-usb
[   13.352894] usbcore: registered new interface driver i2c-tiny-usb
[   13.371091] pps pps0: new PPS source ktimer
[   13.371091] pps pps0: new PPS source ktimer
[   13.372282] pps pps0: ktimer PPS source registered
[   13.372282] pps pps0: ktimer PPS source registered
[   13.373588] pps_parport: parallel port PPS client
[   13.373588] pps_parport: parallel port PPS client
[   13.384204] Driver for 1-wire Dallas network protocol.
[   13.384204] Driver for 1-wire Dallas network protocol.
[   13.385842] usbcore: registered new interface driver DS9490R
[   13.385842] usbcore: registered new interface driver DS9490R
[   13.392417] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   13.392417] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   13.394093] 1-Wire driver for the DS2760 battery monitor chip - (c) =
2004-2005, Szabolcs Gyurko
[   13.394093] 1-Wire driver for the DS2760 battery monitor chip - (c) =
2004-2005, Szabolcs Gyurko
[   13.403278] __power_supply_register: Expected proper parent device f=
or 'test_ac'
[   13.403278] __power_supply_register: Expected proper parent device f=
or 'test_ac'
[   13.415304] __power_supply_register: Expected proper parent device f=
or 'test_battery'
[   13.415304] __power_supply_register: Expected proper parent device f=
or 'test_battery'
[   13.422261] __power_supply_register: Expected proper parent device f=
or 'test_usb'
[   13.422261] __power_supply_register: Expected proper parent device f=
or 'test_usb'
[   14.337713] f71882fg: Not a Fintek device
[   14.337713] f71882fg: Not a Fintek device
[   14.338876] f71882fg: Not a Fintek device
[   14.338876] f71882fg: Not a Fintek device
[   16.180178] sch56xx_common: Unsupported device id: 0xff
[   16.180178] sch56xx_common: Unsupported device id: 0xff
[   16.181539] sch56xx_common: Unsupported device id: 0xff
[   16.181539] sch56xx_common: Unsupported device id: 0xff
[   16.340372] intel_powerclamp: Intel powerclamp does not run on famil=
y 15 model 6
[   16.340372] intel_powerclamp: Intel powerclamp does not run on famil=
y 15 model 6
[   16.342390] usbcore: registered new interface driver pcwd_usb
[   16.342390] usbcore: registered new interface driver pcwd_usb
[   16.343981] acquirewdt: WDT driver for Acquire single board computer=
 initialising
[   16.343981] acquirewdt: WDT driver for Acquire single board computer=
 initialising
[   16.346032] acquirewdt: I/O address 0x0043 already in use
[   16.346032] acquirewdt: I/O address 0x0043 already in use
[   16.347368] acquirewdt: probe of acquirewdt failed with error -5
[   16.347368] acquirewdt: probe of acquirewdt failed with error -5
[   16.349024] advantechwdt: WDT driver for Advantech single board comp=
uter initialising
[   16.349024] advantechwdt: WDT driver for Advantech single board comp=
uter initialising
[   16.351283] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D=
1)
[   16.351283] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D=
1)
[   16.352805] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   16.352805] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   16.354135] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   16.354135] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   16.355738] ib700wdt: WDT driver for IB700 single board computer ini=
tialising
[   16.355738] ib700wdt: WDT driver for IB700 single board computer ini=
tialising
[   16.375931] ib700wdt: START method I/O 443 is not available
[   16.375931] ib700wdt: START method I/O 443 is not available
[   16.377467] ib700wdt: probe of ib700wdt failed with error -5
[   16.377467] ib700wdt: probe of ib700wdt failed with error -5
[   16.385828] wafer5823wdt: WDT driver for Wafer 5823 single board com=
puter initialising
[   16.385828] wafer5823wdt: WDT driver for Wafer 5823 single board com=
puter initialising
[   16.396267] wafer5823wdt: I/O address 0x0443 already in use
[   16.396267] wafer5823wdt: I/O address 0x0443 already in use
[   16.406334] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   16.406334] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   16.414837] i6300esb: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   16.414837] i6300esb: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   16.416626] i6300ESB timer: probe of 0000:00:0b.0 failed with error =
-16
[   16.416626] i6300ESB timer: probe of 0000:00:0b.0 failed with error =
-16
[   16.425239] sc1200wdt: build 20020303
[   16.425239] sc1200wdt: build 20020303
[   16.426273] sc1200wdt: io parameter must be specified
[   16.426273] sc1200wdt: io parameter must be specified
[   16.440968] pc87413_wdt: Version 1.1 at io 0x2E
[   16.440968] pc87413_wdt: Version 1.1 at io 0x2E
[   16.442218] pc87413_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[   16.442218] pc87413_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[   16.450568] nv_tco: NV TCO WatchDog Timer Driver v0.01
[   16.450568] nv_tco: NV TCO WatchDog Timer Driver v0.01
[   16.454375] cpu5wdt: misc_register failed
[   16.454375] cpu5wdt: misc_register failed
[   16.455370] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.=
1 initialising...
[   16.455370] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.=
1 initialising...
[   16.466519] smsc37b787_wdt: Unable to register miscdev on minor 130
[   16.466519] smsc37b787_wdt: Unable to register miscdev on minor 130
[   16.468281] w83877f_wdt: I/O address 0x0443 already in use
[   16.468281] w83877f_wdt: I/O address 0x0443 already in use
[   16.481904] w83977f_wdt: driver v1.00
[   16.481904] w83977f_wdt: driver v1.00
[   16.482822] w83977f_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[   16.482822] w83977f_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[   16.484514] watchdog: Software Watchdog: cannot register miscdev on =
minor=3D130 (err=3D-16).
[   16.484514] watchdog: Software Watchdog: cannot register miscdev on =
minor=3D130 (err=3D-16).
[   16.494832] watchdog: Software Watchdog: a legacy watchdog module is=
 probably present.
[   16.494832] watchdog: Software Watchdog: a legacy watchdog module is=
 probably present.
[   16.497029] softdog: Software Watchdog Timer: 0.08 initialized. soft=
_noboot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[   16.497029] softdog: Software Watchdog Timer: 0.08 initialized. soft=
_noboot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[   16.499830] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   16.499830] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   16.533353] wbsd: Copyright(c) Pierre Ossman
[   16.533353] wbsd: Copyright(c) Pierre Ossman
[   16.534627] usbcore: registered new interface driver ushc
[   16.534627] usbcore: registered new interface driver ushc
[   16.560636] dcdbas dcdbas: Dell Systems Management Base Driver (vers=
ion 5.6.0-3.2)
[   16.560636] dcdbas dcdbas: Dell Systems Management Base Driver (vers=
ion 5.6.0-3.2)
[   16.563768] usbcore: registered new interface driver usbhid
[   16.563768] usbcore: registered new interface driver usbhid
[   16.565589] usbhid: USB HID core driver
[   16.565589] usbhid: USB HID core driver
[   16.566736] panel: driver version 0.9.5 not yet registered
[   16.566736] panel: driver version 0.9.5 not yet registered
[   16.568892] no options.
[   16.568892] no options.
[   16.569738] ashmem: initialized
[   16.569738] ashmem: initialized
[   16.570887] dgap: dgap-1.3-16, Digi International Part Number 400023=
47_C
[   16.570887] dgap: dgap-1.3-16, Digi International Part Number 400023=
47_C
[   16.572552] dgap: For the tools package please visit http://www.digi=
.com
[   16.572552] dgap: For the tools package please visit http://www.digi=
.com
[   16.614288] asus_wmi: Asus Management GUID not found
[   16.614288] asus_wmi: Asus Management GUID not found
[   16.615601] dell_wmi: No known WMI GUID found
[   16.615601] dell_wmi: No known WMI GUID found
[   16.616781] acer_wmi: Acer Laptop ACPI-WMI Extras
[   16.616781] acer_wmi: Acer Laptop ACPI-WMI Extras
[   16.618076] acer_wmi: No or unsupported WMI interface, unable to loa=
d
[   16.618076] acer_wmi: No or unsupported WMI interface, unable to loa=
d
[   16.619868] hdaps: supported laptop not found!
[   16.619868] hdaps: supported laptop not found!
[   16.645386] hdaps: driver init failed (ret=3D-19)!
[   16.645386] hdaps: driver init failed (ret=3D-19)!
[   16.646605] fujitsu_tablet: Unknown (using defaults)
[   16.646605] fujitsu_tablet: Unknown (using defaults)
[   16.648094] alienware_wmi: alienware-wmi: No known WMI GUID found
[   16.648094] alienware_wmi: alienware-wmi: No known WMI GUID found
[   16.663646] oprofile: using NMI interrupt.
[   16.663646] oprofile: using NMI interrupt.
[   16.674809] ... APIC ID:      00000000 (0)
[   16.674809] ... APIC ID:      00000000 (0)
[   16.674809] ... APIC VERSION: 01050014
[   16.674809] ... APIC VERSION: 01050014
[   16.674809] 00000000
[   16.674809] 00000000000000000000000000000000000000000000000000000000=
0000000000000000000000000000000000000000000000000000000000000000

[   16.674809] 00000000
[   16.674809] 00000000000000000000000000000000000000000000000000000000=
0000000000000000000000000000000000000000000000000000000000000000

[   16.674809] 00000000
[   16.674809] 00000000000000000000000000000000000000000000000000000000=
0000000000000000000000000000000000000000000000000000800000008000

[   16.674809]=20
[   16.674809]=20
[   16.716107] number of MP IRQ sources: 15.
[   16.716107] number of MP IRQ sources: 15.
[   16.717136] number of IO-APIC #0 registers: 24.
[   16.717136] number of IO-APIC #0 registers: 24.
[   16.718294] testing the IO APIC.......................
[   16.718294] testing the IO APIC.......................
[   16.719672] IO APIC #0......
[   16.719672] IO APIC #0......
[   16.740068] .... register #00: 00000000
[   16.740068] .... register #00: 00000000
[   16.741087] .......    : physical APIC id: 00
[   16.741087] .......    : physical APIC id: 00
[   16.742207] .......    : Delivery Type: 0
[   16.742207] .......    : Delivery Type: 0
[   16.743260] .......    : LTS          : 0
[   16.743260] .......    : LTS          : 0
[   16.744290] .... register #01: 00170011
[   16.744290] .... register #01: 00170011
[   16.750160] .......     : max redirection entries: 17
[   16.750160] .......     : max redirection entries: 17
[   16.758582] .......     : PRQ implemented: 0
[   16.758582] .......     : PRQ implemented: 0
[   16.759739] .......     : IO APIC version: 11
[   16.759739] .......     : IO APIC version: 11
[   16.766126] .... register #02: 00000000
[   16.766126] .... register #02: 00000000
[   16.767231] .......     : arbitration: 00
[   16.767231] .......     : arbitration: 00
[   16.771733] .... IRQ redirection table:
[   16.771733] .... IRQ redirection table:
[   16.772780] IOAPIC 0:
[   16.772780] IOAPIC 0:
[   16.773432]  pin00, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.773432]  pin00, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.791725]  pin01, enabled , edge , high, V(31), IRR(0), S(0), logi=
cal , D(03), M(1)
[   16.791725]  pin01, enabled , edge , high, V(31), IRR(0), S(0), logi=
cal , D(03), M(1)
[   16.793812]  pin02, enabled , edge , high, V(30), IRR(0), S(0), logi=
cal , D(01), M(1)
[   16.793812]  pin02, enabled , edge , high, V(30), IRR(0), S(0), logi=
cal , D(01), M(1)
[   16.805705]  pin03, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.805705]  pin03, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.812875]  pin04, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.812875]  pin04, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.830433]  pin05, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.830433]  pin05, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.832540]  pin06, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.832540]  pin06, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.849841]  pin07, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.849841]  pin07, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.851887]  pin08, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.851887]  pin08, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.866128]  pin09, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.866128]  pin09, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.868216]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.868216]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.874530]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.874530]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.876718]  pin0c, enabled , edge , high, V(3C), IRR(0), S(0), logi=
cal , D(03), M(1)
[   16.876718]  pin0c, enabled , edge , high, V(3C), IRR(0), S(0), logi=
cal , D(03), M(1)
[   16.891004]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.891004]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.893021]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.893021]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.895045]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.895045]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.897002]  pin10, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.897002]  pin10, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.910359]  pin11, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.910359]  pin11, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.912308]  pin12, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.912308]  pin12, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.926415]  pin13, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.926415]  pin13, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.928455]  pin14, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.928455]  pin14, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.938581]  pin15, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.938581]  pin15, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.940645]  pin16, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.940645]  pin16, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.942606]  pin17, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.942606]  pin17, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[   16.944576] IRQ to pin mappings:
[   16.944576] IRQ to pin mappings:
[   16.945417] IRQ0=20
[   16.945417] IRQ0 -> 0:2-> 0:2

[   16.961513] IRQ1=20
[   16.961513] IRQ1 -> 0:1-> 0:1

[   16.962181] IRQ3=20
[   16.962181] IRQ3 -> 0:3-> 0:3

[   16.962827] IRQ4=20
[   16.962827] IRQ4 -> 0:4-> 0:4

[   16.963475] IRQ5=20
[   16.963475] IRQ5 -> 0:5-> 0:5

[   16.964186] IRQ6=20
[   16.964186] IRQ6 -> 0:6-> 0:6

[   16.964859] IRQ7=20
[   16.964859] IRQ7 -> 0:7-> 0:7

[   16.969623] IRQ8=20
[   16.969623] IRQ8 -> 0:8-> 0:8

[   16.970358] IRQ9=20
[   16.970358] IRQ9 -> 0:9-> 0:9

[   16.971036] IRQ10=20
[   16.971036] IRQ10 -> 0:10-> 0:10

[   16.971721] IRQ11=20
[   16.971721] IRQ11 -> 0:11-> 0:11

[   16.972413] IRQ12=20
[   16.972413] IRQ12 -> 0:12-> 0:12

[   16.973122] IRQ13=20
[   16.973122] IRQ13 -> 0:13-> 0:13

[   16.985985] IRQ14=20
[   16.985985] IRQ14 -> 0:14-> 0:14

[   16.986730] IRQ15=20
[   16.986730] IRQ15 -> 0:15-> 0:15

[   16.987470] .................................... done.
[   16.987470] .................................... done.
[   16.989067] bootconsole [earlyser0] disabled
[   16.989067] bootconsole [earlyser0] disabled
[   16.998371] Running ring buffer tests...
[   27.046163] finished
[   27.046942] CPU 0:
[   27.048256]               events:    73908
[   27.048775]        dropped bytes:    0
[   27.050338]        alloced bytes:    5645372
[   27.050878]        written bytes:    5540281
[   27.052463]        biggest event:    216
[   27.052971]       smallest event:    4
[   27.064046]          read events:   12874
[   27.064533]          lost events:   61034
[   27.065009]         total events:   73908
[   27.065480]   recorded len bytes:   971460
[   27.065959]  recorded size bytes:   950907
[   27.077425]  With dropped events, record len and size may not match
[   27.077425]  alloced and written from above
[   27.078742] CPU 1:
[   27.078986]               events:    86517
[   27.092582]        dropped bytes:    0
[   27.093102]        alloced bytes:    6804484
[   27.093652]        written bytes:    6675276
[   27.094212]        biggest event:    282
[   27.094709]       smallest event:    4
[   27.103121]          read events:   16512
[   27.103618]          lost events:   70005
[   27.104097]         total events:   86517
[   27.104566]   recorded len bytes:   968780
[   27.105050]  recorded size bytes:   943002
[   27.105553]  With dropped events, record len and size may not match
[   27.105553]  alloced and written from above
[   27.106778] Ring buffer PASSED!
[   27.117492] Key type trusted registered
[   27.119860] Key type encrypted registered
[   27.121245]   Magic number: 7:685:499
[   27.122143] Unregister pv shared memory for cpu 0
[   27.346293] numa_remove_cpu cpu 0 node 0: mask now 1
[   27.348446] CPU 0 is now offline
[   27.349517] debug: unmapping init [mem 0xffffffff81fe5000-0xffffffff=
8240afff]
[   27.350781] Write protecting the kernel read-only data: 14336k
[   27.352285] debug: unmapping init [mem 0xffff8800017e3000-0xffff8800=
017fffff]
[   27.353332] debug: unmapping init [mem 0xffff880001c8a000-0xffff8800=
01dfffff]
[   27.373317] random: init urandom read with 14 bits of entropy availa=
ble
mountall: Event failed
[   27.553329] init: Failed to create pty - disabling logging for job
[   27.554275] init: Temporary process spawn error: No such file or dir=
ectory
mount: unknown filesystem type 'devpts'
mountall: mount /dev/pts [150] terminated with status 32
mountall: Filesystem could not be mounted: /dev/pts
mountall: Skipping mounting /dev/pts since Plymouth is not available
[   27.578433] init: Failed to create pty - disabling logging for job
[   27.579368] init: Temporary process spawn error: No such file or dir=
ectory
[   27.638406] init: Failed to create pty - disabling logging for job
[   27.639362] init: Temporary process spawn error: No such file or dir=
ectory
[   27.641366] init: Failed to create pty - disabling logging for job
[   27.642306] init: Temporary process spawn error: No such file or dir=
ectory
[   27.769566] init: Failed to create pty - disabling logging for job
[   27.771057] init: Temporary process spawn error: No such file or dir=
ectory
[   27.773101] init: Failed to create pty - disabling logging for job
[   27.795900] init: Temporary process spawn error: No such file or dir=
ectory
[   27.798303] init: Failed to create pty - disabling logging for job
[   27.799091] init: Temporary process spawn error: No such file or dir=
ectory
[   27.819023] init: Failed to create pty - disabling logging for job
[   27.819813] init: Temporary process spawn error: No such file or dir=
ectory
[   27.834431] init: plymouth-log main process (188) terminated with st=
atus 1
[   27.839372] init: Failed to create pty - disabling logging for job
[   27.840269] init: Temporary process spawn error: No such file or dir=
ectory
[   27.873319] init: Failed to create pty - disabling logging for job
[   27.874262] init: Temporary process spawn error: No such file or dir=
ectory
[   27.875554] udevd[195]: starting version 175
[   27.897038] init: Failed to create pty - disabling logging for job
[   27.897969] init: Temporary process spawn error: No such file or dir=
ectory
[   27.901362] init: Failed to create pty - disabling logging for job
[   27.902289] init: Temporary process spawn error: No such file or dir=
ectory
udevd[210]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXSYSTM:': No such file or directory
udevd[211]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00008086d00007000sv00001AF4sd00001100bc06sc01i00': No such file or dir=
ectory
udevd[212]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00008086d00007010sv00001AF4sd00001100bc01sc01i80': No such file or dir=
ectory
udevd[222]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[221]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[220]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[219]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[237]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00008086d000025ABsv00001AF4sd00001100bc08sc80i00': No such file or dir=
ectory
udevd[238]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[239]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[240]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00001AF4d00001001sv00001AF4sd00000002bc01sc00i00': No such file or dir=
ectory
udevd[241]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00008086d0000100Esv00001AF4sd00001100bc02sc00i00': No such file or dir=
ectory
udevd[242]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:NV_TCO': No such file or directory
udevd[243]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0103:': No such file or directory
udevd[245]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:hgafb': No such file or directory
udevd[246]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:i5k_amb': No such file or directory
udevd[209]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:=
v00008086d00001237sv00001AF4sd00001100bc06sc00i00': No such file or dir=
ectory
udevd[248]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXSYBUS:': No such file or directory
udevd[249]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXSYBUS:': No such file or directory
udevd[250]: failed to execute '/sbin/modprobe' '/sbin/modprobe -q fbcon=
': No such file or directory
udevd[251]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv inpu=
t:b0011v0001p0001eAB41-e0,1,4,11,14,k71,72,73,74,75,76,77,79,7A,7B,7C,7=
D,7E,7F,80,8C,8E,8F,9B,9C,9D,9E,9F,A3,A4,A5,A6,AC,AD,B7,B8,B9,D9,E2,ram=
4,l0,1,2,sfw': No such file or directory
udevd[252]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv inpu=
t:b0011v0002p0006e0000-e0,1,2,k110,111,112,113,114,r0,1,6,8,amlsfw': No=
 such file or directory
udevd[253]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:pcspkr': No such file or directory
udevd[255]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXPWRBN:': No such file or directory
udevd[244]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:dell_rbu': No such file or directory
udevd[258]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXCPU:': No such file or directory
udevd[259]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:LNXCPU:': No such file or directory
udevd[260]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0103:': No such file or directory
udevd[261]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0A03:': No such file or directory
udevd[262]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0A06:': No such file or directory
udevd[264]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0C0F:': No such file or directory
udevd[265]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0C0F:': No such file or directory
udevd[266]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0C0F:': No such file or directory
udevd[267]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0A06:': No such file or directory
udevd[282]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:APP0001:': No such file or directory
udevd[283]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0303:': No such file or directory
udevd[284]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0400:': No such file or directory
udevd[285]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0501:': No such file or directory
[   28.646140] init: Failed to create pty - disabling logging for job
[   28.646981] init: Temporary process spawn error: No such file or dir=
ectory
udevd[286]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0501:': No such file or directory
udevd[287]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0700:': No such file or directory
udevd[288]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0B00:': No such file or directory
udevd[289]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0F13:': No such file or directory
udevd[290]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:QEMU0001:': No such file or directory
udevd[254]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv plat=
form:platform-framebuffer': No such file or directory
udevd[263]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi=
:PNP0C0F:': No such file or directory
[   28.819290] init: Failed to create pty - disabling logging for job
[   28.830777] init: Temporary process spawn error: No such file or dir=
ectory
[   29.001313] init: Failed to create pty - disabling logging for job
[   29.002238] init: Temporary process spawn error: No such file or dir=
ectory
[   29.184647] init: Failed to create pty - disabling logging for job
[   29.185456] init: Temporary process spawn error: No such file or dir=
ectory
[   29.246778] init: Failed to create pty - disabling logging for job
[   29.247590] init: Temporary process spawn error: No such file or dir=
ectory
[   29.251720] init: Failed to create pty - disabling logging for job
[   29.252521] init: Temporary process spawn error: No such file or dir=
ectory
[   29.255323] init: Failed to create pty - disabling logging for job
[   29.256115] init: Temporary process spawn error: No such file or dir=
ectory
[   29.367315] init: networking main process (318) terminated with stat=
us 1
[   29.423464] init: failsafe main process (301) killed by TERM signal
[   29.608455] init: Failed to create pty - disabling logging for job
[   29.609427] init: Temporary process spawn error: No such file or dir=
ectory
[   29.614924] init: Failed to create pty - disabling logging for job
[   29.615783] init: Temporary process spawn error: No such file or dir=
ectory
[   29.618716] init: Failed to create pty - disabling logging for job
[   29.619606] init: Temporary process spawn error: No such file or dir=
ectory
[   29.668084] init: Failed to create pty - disabling logging for job
[   29.668891] init: Temporary process spawn error: No such file or dir=
ectory
[   29.673300] init: Failed to create pty - disabling logging for job
[   29.674243] init: Temporary process spawn error: No such file or dir=
ectory
Kernel tests: Boot OK!
Kernel tests: Boot OK!
Trinity v1.4pre  Dave Jones <davej@redhat.com>
[init] Marking syscall get_robust_list (64bit:274 32bit:312) as to be d=
isabled.
Done parsing arguments.
Marking all syscalls as enabled.
[init] Disabling syscalls marked as disabled by command line options
[init] Marked 64-bit syscall get_robust_list (274) as deactivated.
[init] Marked 32-bit syscall get_robust_list (312) as deactivated.
[init] 32-bit syscalls: 350 enabled, 1 disabled.  64-bit syscalls: 313 =
enabled, 1 disabled.
DANGER: RUNNING AS ROOT.
Unless you are running in a virtual machine, this could cause serious p=
roblems such as overwriting CMOS
or similar which could potentially make this machine unbootable without=
 a firmware reset.

ctrl-c now unless you really know what you are doing.
[   39.622302] init: tty4 main process ended, respawning
[   39.651144] init: tty5 main process (343) terminated with status 1
[   39.652078] init: tty5 main process ended, respawning
[   39.681265] init: tty2 main process (346) terminated with status 1
[   39.682187] init: tty2 main process ended, respawning
[   39.683876] init: tty3 main process (347) terminated with status 1
[   39.684808] init: tty3 main process ended, respawning
[   39.686331] init: tty6 main process (349) terminated with status 1
[   39.687925] init: tty6 main process ended, respawning
fopen: No such file or directory
Couldn't read pid_max from proc
[init] Using pid_max =3D 4194304
[init] Kernel was tainted on startup. Will ignore flags that are alread=
y set.
[init] Started watchdog process, PID is 387
[main] Main thread is alive.
[main] Setsockopt(1 b 693000 4) on fd 7 [1:1:1]
[main] Setsockopt(1 10 693000 4) on fd 8 [1:2:1]
[main] Setsockopt(10e 3 693000 4) on fd 9 [16:2:4]
[main] Setsockopt(1 f 693000 41) on fd 10 [1:1:1]
[main] Setsockopt(1 12 693000 4) on fd 11 [16:3:2]
[main] Setsockopt(1 2d 693000 4) on fd 12 [1:1:1]
[main] Setsockopt(10e 5 693000 4) on fd 14 [16:2:2]
[main] Setsockopt(1 22 693000 4) on fd 15 [1:2:1]
[main] Setsockopt(1 9 693000 d2) on fd 16 [1:1:1]
[main] Setsockopt(1 2d 693000 4) on fd 18 [1:2:1]
[main] Setsockopt(1 21 693000 4) on fd 20 [1:2:1]
[main] Setsockopt(1 28 693000 2e) on fd 22 [1:1:1]
[main] Setsockopt(1 12 693000 c2) on fd 24 [1:1:1]
[main] Setsockopt(1 12 693000 34) on fd 25 [1:1:1]
[main] Setsockopt(1 1 693000 34) on fd 32 [16:3:15]
[main] Setsockopt(1 24 693000 93) on fd 33 [1:1:1]
[main] Setsockopt(1 12 693000 4) on fd 35 [1:2:1]
[main] Setsockopt(1 12 693000 ec) on fd 38 [1:5:1]
[main] Setsockopt(10e 3 693000 be) on fd 42 [16:3:15]
[main] Setsockopt(1 1d 693000 4) on fd 43 [1:5:1]
[main] Setsockopt(1 2b 693000 6f) on fd 44 [16:2:2]
[main] Setsockopt(1 e 693000 b7) on fd 45 [1:5:1]
[main] Setsockopt(1 8 693000 5f) on fd 47 [1:1:1]
[main] Setsockopt(1 12 693000 f5) on fd 52 [1:1:1]
[main] Setsockopt(1 2 693000 17) on fd 53 [1:5:1]
[main] Setsockopt(1 29 693000 bb) on fd 54 [1:5:1]
[main] Setsockopt(1 1 693000 4) on fd 55 [1:5:1]
[main] Setsockopt(1 2e 693000 4) on fd 56 [1:2:1]
[main] Setsockopt(1 1d 693000 50) on fd 58 [1:5:1]
[main] Setsockopt(1 12 693000 4) on fd 59 [1:2:1]
[main] Setsockopt(1 c 693000 d5) on fd 61 [1:5:1]
[main] Setsockopt(1 20 693000 ba) on fd 63 [1:5:1]
[main] Setsockopt(1 10 693000 4) on fd 64 [1:2:1]
[main] Setsockopt(1 28 693000 4) on fd 65 [1:5:1]
[main] Setsockopt(1 e 693000 d3) on fd 66 [1:1:1]
[main] Setsockopt(1 25 693000 da) on fd 67 [16:2:4]
[main] Setsockopt(10e 3 693000 37) on fd 71 [16:2:2]
[main] Setsockopt(1 24 693000 eb) on fd 72 [1:1:1]
[main] Setsockopt(1 29 693000 4) on fd 73 [1:2:1]
[main] Setsockopt(1 2f 693000 4) on fd 78 [1:5:1]
[main] Setsockopt(1 2b 693000 4) on fd 81 [1:1:1]
[main] Setsockopt(1 10 693000 25) on fd 83 [1:5:1]
[main] Setsockopt(1 b 693000 4) on fd 84 [16:2:4]
[main] Setsockopt(1 24 693000 4) on fd 85 [1:2:1]
[main] Setsockopt(1 25 693000 6f) on fd 86 [1:5:1]
[main] Setsockopt(1 1 693000 31) on fd 87 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 88 [16:3:4]
[main] Setsockopt(1 12 693000 4) on fd 91 [1:1:1]
[main] Setsockopt(1 1d 693000 73) on fd 92 [1:1:1]
[main] Setsockopt(1 7 693000 e6) on fd 93 [1:1:1]
[main] Setsockopt(1 2d 693000 78) on fd 94 [1:1:1]
[main] Setsockopt(10e 3 693000 97) on fd 95 [16:3:16]
[main] Setsockopt(1 22 693000 e3) on fd 96 [1:1:1]
[main] Setsockopt(10e 5 693000 4) on fd 97 [16:2:15]
[main] Setsockopt(1 1d 693000 4) on fd 98 [1:1:1]
[main] Setsockopt(1 1d 693000 4) on fd 99 [1:1:1]
[main] Setsockopt(1 c 693000 3a) on fd 100 [1:5:1]
[main] Setsockopt(1 29 693000 4) on fd 101 [1:5:1]
[main] Setsockopt(1 2b 693000 6) on fd 102 [1:1:1]
[main] Setsockopt(1 b 693000 4) on fd 103 [1:1:1]
[main] Setsockopt(1 29 693000 4) on fd 104 [1:5:1]
[main] Setsockopt(1 24 693000 4) on fd 107 [16:2:15]
[main] Setsockopt(1 14 693000 10) on fd 108 [1:2:1]
[main] Setsockopt(1 22 693000 4) on fd 109 [1:2:1]
[main] Setsockopt(1 23 693000 4) on fd 110 [1:1:1]
[main] Setsockopt(10e 5 693000 b6) on fd 111 [16:2:15]
[main] Setsockopt(1 2d 693000 4) on fd 115 [1:2:1]
[main] Setsockopt(1 23 693000 b3) on fd 116 [16:3:4]
[main] Setsockopt(1 1 693000 4) on fd 117 [1:1:1]
[main] Setsockopt(1 23 693000 c2) on fd 118 [1:1:1]
[main] Setsockopt(1 2e 693000 4) on fd 119 [1:2:1]
[main] Setsockopt(1 24 693000 4) on fd 120 [1:1:1]
[main] Setsockopt(1 2b 693000 67) on fd 122 [16:3:15]
[main] Setsockopt(1 e 693000 c2) on fd 127 [1:1:1]
[main] Setsockopt(10e 4 693000 1b) on fd 128 [16:2:16]
[main] Setsockopt(1 2d 693000 4) on fd 129 [1:1:1]
[main] Setsockopt(1 b 693000 5) on fd 130 [1:1:1]
[main] Setsockopt(1 e 693000 4) on fd 131 [16:2:0]
[main] Setsockopt(1 14 693000 10) on fd 133 [1:1:1]
[main] Setsockopt(1 5 693000 7a) on fd 136 [1:5:1]
[main] Setsockopt(1 29 693000 4) on fd 141 [1:2:1]
[main] Setsockopt(1 15 693000 10) on fd 142 [1:5:1]
[main] Setsockopt(1 20 693000 4) on fd 145 [1:5:1]
[main] Setsockopt(1 22 693000 7f) on fd 146 [1:5:1]
[main] Setsockopt(1 14 693000 10) on fd 147 [1:1:1]
[main] Setsockopt(1 1 693000 a5) on fd 148 [1:5:1]
[main] Setsockopt(1 2b 693000 d6) on fd 149 [1:5:1]
[main] Setsockopt(1 2 693000 4) on fd 150 [1:5:1]
[main] Setsockopt(1 22 693000 4) on fd 151 [1:2:1]
[main] Setsockopt(1 15 693000 10) on fd 152 [16:2:15]
[main] Setsockopt(1 24 693000 72) on fd 153 [1:1:1]
[main] Setsockopt(1 14 693000 10) on fd 154 [1:5:1]
[main] Setsockopt(10e 3 693000 4) on fd 156 [16:2:15]
[main] Setsockopt(1 2b 693000 4) on fd 157 [1:2:1]
[main] Setsockopt(10e 3 693000 4) on fd 159 [16:2:15]
[main] Setsockopt(1 c 693000 4) on fd 165 [1:1:1]
[main] Setsockopt(1 9 693000 4) on fd 166 [1:5:1]
[main] Setsockopt(1 9 693000 20) on fd 167 [1:1:1]
[main] Setsockopt(1 1 693000 85) on fd 169 [1:2:1]
[main] Setsockopt(1 21 693000 4) on fd 173 [1:1:1]
[main] Setsockopt(1 e 693000 4) on fd 175 [16:3:16]
[main] Setsockopt(1 22 693000 93) on fd 177 [1:5:1]
[main] Setsockopt(10e 1 693000 f1) on fd 179 [16:3:2]
[main] Setsockopt(1 b 693000 27) on fd 180 [1:1:1]
[main] Setsockopt(1 2 693000 c7) on fd 182 [1:1:1]
[main] Setsockopt(1 2d 693000 48) on fd 186 [1:1:1]
[main] Setsockopt(1 15 693000 10) on fd 187 [1:5:1]
[main] Setsockopt(1 12 693000 88) on fd 188 [1:1:1]
[main] Setsockopt(1 2f 693000 4) on fd 189 [1:5:1]
[main] Setsockopt(1 b 693000 4) on fd 192 [1:1:1]
[main] Setsockopt(1 7 693000 4) on fd 193 [1:2:1]
[main] Setsockopt(1 29 693000 4) on fd 194 [1:1:1]
[main] Setsockopt(1 1d 693000 d7) on fd 197 [1:1:1]
[main] Setsockopt(1 2c 693000 4) on fd 199 [1:1:1]
[main] Setsockopt(10e 1 693000 4) on fd 200 [16:3:4]
[main] Setsockopt(1 14 693000 10) on fd 201 [1:2:1]
[main] Setsockopt(1 12 693000 4) on fd 204 [1:2:1]
[main] Setsockopt(1 f 693000 4) on fd 205 [1:2:1]
[main] Setsockopt(1 8 693000 4) on fd 207 [1:5:1]
[main] Setsockopt(1 15 693000 10) on fd 210 [1:1:1]
[main] Setsockopt(10e 5 693000 4) on fd 211 [16:2:4]
[main] Setsockopt(1 2a 693000 5b) on fd 212 [1:2:1]
[main] Setsockopt(1 7 693000 e6) on fd 213 [16:3:4]
[main] Setsockopt(1 2a 693000 c5) on fd 215 [1:5:1]
[main] Setsockopt(1 20 693000 4) on fd 217 [1:1:1]
[main] Setsockopt(1 15 693000 10) on fd 218 [1:2:1]
[main] Setsockopt(1 2e 693000 6d) on fd 219 [1:5:1]
[main] Setsockopt(1 a 693000 4) on fd 220 [1:2:1]
[main] Setsockopt(1 6 693000 f0) on fd 221 [1:1:1]
[main] Setsockopt(10e 4 693000 2b) on fd 222 [16:3:0]
[main] Setsockopt(1 24 693000 4) on fd 223 [1:2:1]
[main] Setsockopt(1 9 693000 4) on fd 224 [1:2:1]
[main] Setsockopt(1 20 693000 4) on fd 228 [1:5:1]
[main] Setsockopt(1 25 693000 4) on fd 230 [16:2:16]
[main] Setsockopt(1 21 693000 4) on fd 231 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 232 [1:2:1]
[main] Setsockopt(1 6 693000 4) on fd 237 [16:3:15]
[main] Setsockopt(1 c 693000 80) on fd 238 [1:5:1]
[main] Setsockopt(1 29 693000 4) on fd 239 [16:3:0]
[main] Setsockopt(1 1 693000 5) on fd 241 [1:5:1]
[main] Setsockopt(1 e 693000 4) on fd 242 [16:3:16]
[main] Setsockopt(1 10 693000 4) on fd 243 [1:2:1]
[main] Setsockopt(1 1 693000 4) on fd 245 [1:1:1]
[main] Setsockopt(1 9 693000 4) on fd 246 [1:1:1]
[main] Setsockopt(1 e 693000 4) on fd 247 [1:5:1]
[main] Setsockopt(1 2 693000 a0) on fd 248 [16:2:16]
[main] Setsockopt(1 d 693000 8) on fd 251 [1:1:1]
[main] Setsockopt(1 2f 693000 8b) on fd 256 [1:5:1]
[main] Setsockopt(1 12 693000 4) on fd 257 [16:2:16]
[main] Setsockopt(1 2d 693000 4) on fd 258 [1:5:1]
[main] Setsockopt(1 25 693000 4) on fd 259 [16:3:2]
[main] Setsockopt(1 23 693000 4) on fd 260 [1:5:1]
[main] Setsockopt(1 21 693000 29) on fd 261 [1:1:1]
[main] Setsockopt(1 2b 693000 8d) on fd 262 [1:1:1]
[main] Setsockopt(1 5 693000 8) on fd 263 [1:5:1]
[main] Setsockopt(1 e 693000 eb) on fd 264 [1:2:1]
[main] Setsockopt(1 6 693000 4) on fd 265 [1:5:1]
[main] Setsockopt(1 b 693000 4) on fd 267 [16:3:0]
[main] Setsockopt(1 d 693000 8) on fd 268 [1:5:1]
[main] Setsockopt(1 1d 693000 4) on fd 269 [1:2:1]
[main] Setsockopt(1 6 693000 4) on fd 270 [1:2:1]
[main] Setsockopt(1 20 693000 f3) on fd 272 [1:2:1]
[main] Setsockopt(1 12 693000 33) on fd 273 [1:1:1]
[main] Setsockopt(1 2d 693000 4) on fd 274 [1:1:1]
[main] Setsockopt(1 2d 693000 4) on fd 277 [1:2:1]
[main] Setsockopt(10e 5 693000 4) on fd 281 [16:2:16]
[main] Setsockopt(10e 4 693000 ba) on fd 284 [16:3:16]
[main] Setsockopt(1 e 693000 4) on fd 287 [1:5:1]
[main] Setsockopt(1 2c 693000 4) on fd 293 [1:5:1]
[main] Setsockopt(1 24 693000 ee) on fd 295 [1:5:1]
[main] Setsockopt(10e 3 693000 4f) on fd 298 [16:3:4]
[main] Setsockopt(1 2f 693000 9b) on fd 300 [1:1:1]
[main] Setsockopt(1 1d 693000 a3) on fd 303 [1:5:1]
[main] Setsockopt(1 1 693000 4) on fd 304 [16:3:15]
[main] Setsockopt(1 f 693000 4) on fd 305 [1:5:1]
[main] Setsockopt(1 c 693000 9e) on fd 306 [1:2:1]
[main] Setsockopt(1 c 693000 20) on fd 308 [1:1:1]
[main] Setsockopt(1 e 693000 4) on fd 310 [1:5:1]
[main] Setsockopt(1 2b 693000 4) on fd 311 [1:2:1]
[main] Setsockopt(1 b 693000 4) on fd 313 [1:2:1]
[main] Setsockopt(1 a 693000 2b) on fd 314 [1:5:1]
[main] Setsockopt(1 a 693000 5f) on fd 315 [1:5:1]
[main] Setsockopt(1 25 693000 4) on fd 316 [1:2:1]
[main] Setsockopt(1 8 693000 4) on fd 317 [1:1:1]
[main] Setsockopt(1 29 693000 4) on fd 319 [1:2:1]
[main] Setsockopt(1 2d 693000 4) on fd 321 [1:2:1]
[main] Setsockopt(1 24 693000 dd) on fd 322 [1:5:1]
[main] Setsockopt(1 2b 693000 da) on fd 323 [1:5:1]
[main] Setsockopt(1 6 693000 4) on fd 324 [1:5:1]
[main] Setsockopt(1 25 693000 b6) on fd 325 [1:5:1]
[main] Setsockopt(1 2d 693000 f1) on fd 327 [1:1:1]
[main] Setsockopt(1 f 693000 d2) on fd 330 [1:2:1]
[main] Setsockopt(1 9 693000 4) on fd 332 [16:2:4]
[main] Setsockopt(10e 3 693000 4) on fd 334 [16:2:4]
[main] Setsockopt(1 a 693000 76) on fd 335 [1:5:1]
[main] Setsockopt(1 7 693000 4) on fd 336 [1:2:1]
[main] Setsockopt(1 9 693000 4) on fd 337 [1:5:1]
[main] Setsockopt(1 1 693000 4) on fd 339 [1:5:1]
[main] Setsockopt(1 28 693000 15) on fd 340 [1:2:1]
[main] Setsockopt(1 21 693000 4) on fd 342 [1:5:1]
[main] Setsockopt(1 6 693000 a0) on fd 343 [1:1:1]
[main] Setsockopt(1 15 693000 10) on fd 345 [1:2:1]
[main] Setsockopt(1 25 693000 5c) on fd 347 [1:2:1]
[main] Setsockopt(1 12 693000 4) on fd 349 [1:5:1]
[main] Setsockopt(1 24 693000 c1) on fd 350 [1:2:1]
[main] Setsockopt(1 29 693000 8c) on fd 351 [1:5:1]
[main] Setsockopt(1 1 693000 df) on fd 352 [1:5:1]
[main] Setsockopt(1 b 693000 4) on fd 354 [1:5:1]
[main] Setsockopt(1 9 693000 9a) on fd 355 [1:2:1]
[main] Setsockopt(1 2c 693000 d1) on fd 356 [1:5:1]
[main] Setsockopt(1 23 693000 4) on fd 357 [16:2:4]
[main] Setsockopt(1 2b 693000 4) on fd 358 [1:2:1]
[main] Setsockopt(1 e 693000 4) on fd 359 [1:2:1]
[main] Setsockopt(1 10 693000 63) on fd 360 [1:1:1]
[main] Setsockopt(1 24 693000 4) on fd 361 [1:1:1]
[main] Setsockopt(1 f 693000 8c) on fd 363 [1:5:1]
[main] Setsockopt(1 15 693000 10) on fd 367 [1:5:1]
[main] Setsockopt(10e 5 693000 90) on fd 369 [16:3:2]
[main] Setsockopt(1 8 693000 b6) on fd 370 [1:2:1]
[main] Setsockopt(1 9 693000 4) on fd 371 [1:5:1]
[main] Setsockopt(1 9 693000 e6) on fd 372 [1:1:1]
[main] Setsockopt(1 29 693000 4) on fd 374 [1:2:1]
[main] Setsockopt(1 8 693000 4) on fd 377 [1:5:1]
[main] Setsockopt(1 a 693000 24) on fd 379 [16:3:2]
[main] Setsockopt(1 b 693000 36) on fd 380 [1:2:1]
[main] 375 sockets created based on info from socket cachefile.
[main] Generating file descriptors
[main] Added 298 filenames from /dev
[main] Added 6284 filenames from /proc
[main] Added 13376 filenames from /sys
[child0:389] uid changed! Was: 0, now -178
Bailing main loop. Exit reason: UID changed.
[watchdog] [387] Watchdog exiting
[init]=20
Ran 1 syscalls. Successes: 1  Failures: 0
[   49.645736] init: tty4 main process (382) terminated with status 1
[   49.647028] init: tty4 main process ended, respawning
[   49.672721] init: tty5 main process (383) terminated with status 1
[   49.673619] init: tty5 main process ended, respawning
[   49.704116] init: tty2 main process (384) terminated with status 1
[   49.704956] init: tty2 main process ended, respawning
[   49.706324] init: tty3 main process (385) terminated with status 1
[   49.707145] init: tty3 main process ended, respawning
[   49.731536] init: tty6 main process (386) terminated with status 1
[   49.732436] init: tty6 main process ended, respawning
[   59.660383] init: tty4 main process (390) terminated with status 1
[   59.661874] init: tty4 main process ended, respawning
[   59.710414] init: tty5 main process (391) terminated with status 1
[   59.711358] init: tty5 main process ended, respawning
[   59.740722] init: tty2 main process (392) terminated with status 1
[   59.741660] init: tty2 main process ended, respawning
[   59.742909] init: tty3 main process (393) terminated with status 1
[   59.743797] init: tty3 main process ended, respawning
[   59.744907] init: tty6 main process (394) terminated with status 1
[   59.745809] init: tty6 main process ended, respawning
[   69.683742] init: tty4 main process (395) terminated with status 1
[   69.684923] init: tty4 main process ended, respawning
[   69.723626] init: tty5 main process (396) terminated with status 1
[   69.724578] init: tty5 main process ended, respawning
[   69.768491] init: tty2 main process (397) terminated with status 1
[   69.769442] init: tty2 main process ended, respawning
[   69.770895] init: tty3 main process (398) terminated with status 1
[   69.771855] init: tty3 main process ended, respawning
[   69.773060] init: tty6 main process (399) terminated with status 1
[   69.774055] init: tty6 main process ended, respawning
[   79.690379] init: tty4 main process (400) terminated with status 1
[   79.691801] init: tty4 main process ended, respawning
[   79.730382] init: tty5 main process (401) terminated with status 1
[   79.731332] init: tty5 main process ended, respawning
[   79.780404] init: tty2 main process (402) terminated with status 1
[   79.781362] init: tty2 main process ended, respawning
[   79.790345] init: tty3 main process (403) terminated with status 1
[   79.791279] init: tty3 main process ended, respawning
[   79.810485] init: tty6 main process (404) terminated with status 1
[   79.811439] init: tty6 main process ended, respawning
error: 'rc.local' exited outside the expected code flow.
[   87.503656] init: Failed to create pty - disabling logging for job
[   87.505646] init: Temporary process spawn error: No such file or dir=
ectory
[   87.591731] init: rc main process (340) killed by TERM signal
[   87.604459] init: tty4 main process (405) killed by TERM signal
[   87.613335] init: tty5 main process (406) killed by TERM signal
[   87.617680] init: tty2 main process (407) killed by TERM signal
[   87.625101] init: tty3 main process (408) killed by TERM signal
[   87.635259] init: tty6 main process (409) killed by TERM signal
[   87.638815] init: hwclock-save main process (412) terminated with st=
atus 70
[   87.643647] init: plymouth-upstart-bridge main process (413) termina=
ted with status 1
umount: /run/lock: not mounted
 * Will now restart
[   88.776245] Unregister pv shared memory for cpu 1
[   88.776921] no ifx modem active;
[   88.783430] reboot: Restarting system
[   88.783898] reboot: machine restart

Elapsed time: 110
qemu-system-x86_64 -enable-kvm -cpu kvm64 -kernel /pkg/linux/x86_64-ran=
dconfig-h0-07070925/gcc-4.9/0e1cc95b4cc7293bb7b39175035e7f7e45c90977/vm=
linuz-4.1.0-11369-g0e1cc95 -append 'hung_task_panic=3D1 earlyprintk=3Dt=
tyS0,115200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_ena=
bled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ra=
m0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-h0-07070925/=
linux-devel:devel-hourly-2015070709:0e1cc95b4cc7293bb7b39175035e7f7e45c=
90977:bisect-linux-6/.vmlinuz-0e1cc95b4cc7293bb7b39175035e7f7e45c90977-=
20150707212227-3-intel12 branch=3Dlinux-devel/devel-hourly-2015070709 B=
OOT_IMAGE=3D/pkg/linux/x86_64-randconfig-h0-07070925/gcc-4.9/0e1cc95b4c=
c7293bb7b39175035e7f7e45c90977/vmlinuz-4.1.0-11369-g0e1cc95 drbd.minor_=
count=3D8'  -initrd /osimage/quantal/quantal-core-x86_64.cgz -m 300 -sm=
p 2 -device e1000,netdev=3Dnet0 -netdev user,id=3Dnet0 -boot order=3Dnc=
 -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs/=
sda2/disk0-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs=
/sda2/disk1-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive file=3D/f=
s/sda2/disk2-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive file=3D/=
fs/sda2/disk3-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive file=3D=
/fs/sda2/disk4-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/sda2/disk5-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -drive fil=
e=3D/fs/sda2/disk6-quantal-intel12-1,media=3Ddisk,if=3Dvirtio -pidfile =
/dev/shm/kboot/pid-quantal-intel12-1 -serial file:/dev/shm/kboot/serial=
-quantal-intel12-1 -daemonize -display none -monitor null=20

--=_559be1ee./9tdyPbznChQo7YkntdXp/uaiwvnlAbayZyItQ03e8HMF6wr
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.1.0-11369-g0e1cc95"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.1.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
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
CONFIG_X86_64_SMP=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
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
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
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
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_NOCB_CPU is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_HUGETLB is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
# CONFIG_RD_LZ4 is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
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
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_SLUB_DEBUG is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
# CONFIG_BLOCK is not set
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_X86_16BIT is not set
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NUMA=y
# CONFIG_AMD_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
# CONFIG_ACPI_FAN is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
CONFIG_ACPI_REDUCED_HARDWARE_ONLY=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_PMIC_OPREGION=y
CONFIG_CRC_PMIC_OPREGION=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
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
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

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
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
# CONFIG_PCIEAER is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
# CONFIG_YENTA_TOSHIBA is not set
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
# CONFIG_RAPIDIO_TSI568 is not set
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
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
# CONFIG_NET_PTP_CLASSIFY is not set
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
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
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
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
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
CONFIG_MTD_OTP=y
# CONFIG_MTD_CFI_INTELEXT is not set
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
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=y
# CONFIG_MTD_PCMCIA is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
CONFIG_MTD_M25P80=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
CONFIG_MTD_NAND_DENALI=y
CONFIG_MTD_NAND_DENALI_PCI=y
CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=0xFF108018
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH is not set
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_NANDSIM=y
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_NAND_HISI504 is not set
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
# CONFIG_MTD_UBI is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
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

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_BMP085_SPI is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
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
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
# CONFIG_INTEL_MEI_ME is not set
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#
CONFIG_SCIF=y
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

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
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
# CONFIG_MOUSE_PS2_ALPS is not set
CONFIG_MOUSE_PS2_LOGIPS2PP=y
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
# CONFIG_MOUSE_PS2_CYPRESS is not set
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
# CONFIG_MOUSE_SERIAL is not set
CONFIG_MOUSE_APPLETOUCH=y
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_ELAN_I2C=y
# CONFIG_MOUSE_ELAN_I2C_I2C is not set
# CONFIG_MOUSE_ELAN_I2C_SMBUS is not set
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_DMA is not set
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
CONFIG_SERIAL_8250_FINTEK=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
# CONFIG_SERIAL_SC16IS7XX_SPI is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_IFX6X60=y
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_SERIAL_MEN_Z135=y
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
# CONFIG_PPDEV is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
CONFIG_CARDMAN_4040=y
CONFIG_MWAVE=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_TIS_ST33ZP24 is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
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
CONFIG_I2C_GPIO=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_SLAVE is not set
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
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
CONFIG_SPI_OC_TINY=y
CONFIG_SPI_PXA2XX_DMA=y
CONFIG_SPI_PXA2XX=y
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_ZYNQMP_GQSPI=y
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
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
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
# CONFIG_GPIO_MAX7300 is not set
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_CRYSTAL_COVE=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_PALMAS is not set
# CONFIG_GPIO_TPS65910 is not set
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_INTEL_MID=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
# CONFIG_GPIO_MCP23S08 is not set
# CONFIG_GPIO_MC33880 is not set

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
# CONFIG_WM8350_POWER is not set
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
CONFIG_CHARGER_DA9150=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_PCF50633=y
CONFIG_BATTERY_RX51=y
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_TWL4030 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65090=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_I5500=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_HTU21=y
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_TWL4030_MADC=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set
# CONFIG_INT340X_THERMAL is not set

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
CONFIG_DA9052_WATCHDOG=y
# CONFIG_DA9055_WATCHDOG is not set
CONFIG_WM831X_WATCHDOG=y
# CONFIG_WM8350_WATCHDOG is not set
# CONFIG_XILINX_WATCHDOG is not set
CONFIG_CADENCE_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
CONFIG_RN5T618_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
# CONFIG_RETU_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
# CONFIG_IT87_WDT is not set
CONFIG_HP_WATCHDOG=y
# CONFIG_HPWDT_NMI_DECODING is not set
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
# CONFIG_60XX_WDT is not set
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_MEN_A21_WDT=y

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
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X is not set
# CONFIG_MFD_CROS_EC is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RT5033=y
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
# CONFIG_AGP_INTEL is not set
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y

#
# Direct Rendering Manager
#
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=y
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_AMDGPU=y
# CONFIG_DRM_AMDGPU_CIK is not set
# CONFIG_DRM_AMDGPU_USERPTR is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_I915 is not set
CONFIG_DRM_MGA=y
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y
CONFIG_DRM_VIRTIO_GPU=y

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
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
CONFIG_FB_CIRRUS=y
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
# CONFIG_FB_SIS_315 is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_DA9052 is not set
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_AS3711 is not set
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
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
# CONFIG_UHID is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
CONFIG_HID_APPLEIR=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_BETOP_FF=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PENMOUNT=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
# CONFIG_USB_ULPI_BUS is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
# CONFIG_USB_EHCI_HCD is not set
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FUSBH200_HCD is not set
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PCI is not set
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_SL811_CS is not set
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_WHCI_HCD=y
CONFIG_USB_HWA_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y

#
# Debugging features
#
# CONFIG_USB_DWC3_DEBUG is not set
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PCI=y
# CONFIG_USB_DWC2_DEBUG is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_USB_ISP1301=y
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
CONFIG_MMC_CB710=y
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_REALTEK_PCI=y
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8788 is not set
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_PM8941_WLED=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM80X is not set
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1374_WDT is not set
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_LP8788 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PALMAS=y
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_TPS65910=y
CONFIG_RTC_DRV_TPS80031=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_DS3234=y
# CONFIG_RTC_DRV_PCF2123 is not set
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_MCP795=y

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
CONFIG_RTC_DRV_DS17885=y
# CONFIG_RTC_DS1685_PROC_REGS is not set
# CONFIG_RTC_DS1685_SYSFS_REGS is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_WM831X=y
CONFIG_RTC_DRV_WM8350=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_MT6397=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_HSU_DMA_PCI is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_PCI_LEGACY is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
# CONFIG_ADIS16201 is not set
# CONFIG_ADIS16203 is not set
CONFIG_ADIS16204=y
CONFIG_ADIS16209=y
# CONFIG_ADIS16220 is not set
CONFIG_ADIS16240=y
# CONFIG_LIS3L02DQ is not set
CONFIG_SCA3000=y

#
# Analog to digital converters
#
CONFIG_AD7606=y
CONFIG_AD7606_IFACE_PARALLEL=y
# CONFIG_AD7606_IFACE_SPI is not set
CONFIG_AD7780=y
CONFIG_AD7816=y
# CONFIG_AD7192 is not set
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
# CONFIG_AD9832 is not set
# CONFIG_AD9834 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

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
CONFIG_SENSORS_HMC5843_I2C=y
CONFIG_SENSORS_HMC5843_SPI=y

#
# Active energy metering IC
#
CONFIG_ADE7753=y
CONFIG_ADE7754=y
CONFIG_ADE7758=y
CONFIG_ADE7759=y
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#
# CONFIG_AD2S90 is not set
# CONFIG_AD2S1200 is not set
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
# CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
CONFIG_IIO_DUMMY_EVGEN=y
CONFIG_IIO_SIMPLE_DUMMY=y
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y
# CONFIG_FB_SM7XX is not set
CONFIG_FB_SM750=y
CONFIG_FB_XGI=y
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ASHMEM=y
CONFIG_ANDROID_TIMED_OUTPUT=y
CONFIG_ANDROID_TIMED_GPIO=y
CONFIG_ANDROID_LOW_MEMORY_KILLER=y
CONFIG_SYNC=y
CONFIG_SW_SYNC=y
# CONFIG_SW_SYNC_USER is not set
CONFIG_ION=y
# CONFIG_ION_TEST is not set
# CONFIG_ION_DUMMY is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
CONFIG_FIREWIRE_SERIAL=y
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_MTD_SPINAND_MT29F=y
# CONFIG_MTD_SPINAND_ONDIEECC is not set
CONFIG_DGNC=y
CONFIG_DGAP=y
# CONFIG_GS_FPGABOOT is not set
CONFIG_CRYPTO_SKEIN=y
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORBUS=y
# CONFIG_UNISYS_VISORNIC is not set
CONFIG_FB_TFT=y
CONFIG_FB_TFT_AGM1264K_FL=y
CONFIG_FB_TFT_BD663474=y
# CONFIG_FB_TFT_HX8340BN is not set
CONFIG_FB_TFT_HX8347D=y
CONFIG_FB_TFT_HX8353D=y
# CONFIG_FB_TFT_HX8357D is not set
CONFIG_FB_TFT_ILI9163=y
CONFIG_FB_TFT_ILI9320=y
# CONFIG_FB_TFT_ILI9325 is not set
CONFIG_FB_TFT_ILI9340=y
# CONFIG_FB_TFT_ILI9341 is not set
CONFIG_FB_TFT_ILI9481=y
CONFIG_FB_TFT_ILI9486=y
CONFIG_FB_TFT_PCD8544=y
# CONFIG_FB_TFT_RA8875 is not set
CONFIG_FB_TFT_S6D02A1=y
CONFIG_FB_TFT_S6D1121=y
CONFIG_FB_TFT_SSD1289=y
# CONFIG_FB_TFT_SSD1306 is not set
CONFIG_FB_TFT_SSD1331=y
# CONFIG_FB_TFT_SSD1351 is not set
# CONFIG_FB_TFT_ST7735R is not set
CONFIG_FB_TFT_TINYLCD=y
# CONFIG_FB_TFT_TLS8204 is not set
CONFIG_FB_TFT_UC1701=y
CONFIG_FB_TFT_UPD161704=y
# CONFIG_FB_TFT_WATTEROTT is not set
# CONFIG_FB_FLEX is not set
CONFIG_FB_TFT_FBTFT_DEVICE=y
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
# CONFIG_ACERHDF is not set
CONFIG_ALIENWARE_WMI=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
CONFIG_DELL_SMO8800=y
# CONFIG_FUJITSU_LAPTOP is not set
CONFIG_FUJITSU_TABLET=y
CONFIG_HP_ACCEL=y
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_DEBUGFACILITIES=y
# CONFIG_THINKPAD_ACPI_DEBUG is not set
CONFIG_THINKPAD_ACPI_UNSAFE_LEDS=y
# CONFIG_THINKPAD_ACPI_VIDEO is not set
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=y
CONFIG_INTEL_MENLOW=y
# CONFIG_EEEPC_LAPTOP is not set
CONFIG_ASUS_WMI=y
# CONFIG_ASUS_NB_WMI is not set
# CONFIG_EEEPC_WMI is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
CONFIG_INTEL_SMARTCONNECT=y
CONFIG_PVPANIC=y
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_LAPTOP is not set
# CONFIG_CHROMEOS_PSTORE is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
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
CONFIG_BMA180=y
CONFIG_BMC150_ACCEL=y
CONFIG_HID_SENSOR_ACCEL_3D=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y
# CONFIG_KXSD9 is not set
# CONFIG_MMA8452 is not set
CONFIG_KXCJK1013=y
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_STK8312=y
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
# CONFIG_AD7291 is not set
CONFIG_AD7298=y
CONFIG_AD7476=y
# CONFIG_AD7791 is not set
CONFIG_AD7793=y
CONFIG_AD7887=y
# CONFIG_AD7923 is not set
CONFIG_AD799X=y
CONFIG_DA9150_GPADC=y
# CONFIG_LP8788_ADC is not set
# CONFIG_MAX1027 is not set
CONFIG_MAX1363=y
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
# CONFIG_QCOM_SPMI_IADC is not set
# CONFIG_QCOM_SPMI_VADC is not set
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADC128S052=y
CONFIG_TI_AM335X_ADC=y
CONFIG_TWL4030_MADC=y
# CONFIG_TWL6030_GPADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORS_COMMONS is not set
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
# CONFIG_AD5686 is not set
# CONFIG_AD5755 is not set
CONFIG_AD5764=y
CONFIG_AD5791=y
# CONFIG_AD7303 is not set
CONFIG_M62332=y
CONFIG_MAX517=y
CONFIG_MCP4725=y
# CONFIG_MCP4922 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
# CONFIG_ADIS16260 is not set
CONFIG_ADXRS450=y
# CONFIG_BMG160 is not set
# CONFIG_HID_SENSOR_GYRO_3D is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_DHT11=y
# CONFIG_SI7005 is not set
CONFIG_SI7020=y

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
# CONFIG_ADIS16480 is not set
# CONFIG_KMX61 is not set
# CONFIG_INV_MPU6050_IIO is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ACPI_ALS=y
CONFIG_ADJD_S311=y
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
CONFIG_BH1750=y
CONFIG_CM32181=y
# CONFIG_CM3232 is not set
CONFIG_CM3323=y
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
CONFIG_ISL29125=y
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_HID_SENSOR_PROX=y
# CONFIG_JSA1212 is not set
CONFIG_LTR501=y
CONFIG_STK3310=y
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
# CONFIG_AK09911 is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
# CONFIG_MMC35240 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_BMC150_MAGN=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y
CONFIG_HID_SENSOR_DEVICE_ROTATION=y

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
CONFIG_HID_SENSOR_PRESS=y
CONFIG_MPL115=y
CONFIG_MPL3115=y
# CONFIG_MS5611 is not set
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity sensors
#
CONFIG_SX9500=y

#
# Temperature sensors
#
CONFIG_MLX90614=y
# CONFIG_TMP006 is not set
CONFIG_NTB=y
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LP3943=y
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
CONFIG_PWM_LPSS_PLATFORM=y
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=y
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_SAMSUNG_USB2 is not set
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=y
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=y
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
CONFIG_OVERLAY_FS=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
# CONFIG_PROC_PAGE_MONITOR is not set
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
# CONFIG_JFFS2_ZLIB is not set
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
CONFIG_JFFS2_RUBIN=y
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
# CONFIG_LOGFS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_PMSG is not set
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_MEMORY_NOTIFIER_ERROR_INJECT is not set
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_PREEMPT is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MMC_REQUEST=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
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
# CONFIG_FUNCTION_GRAPH_TRACER is not set
CONFIG_IRQSOFF_TRACER=y
# CONFIG_PREEMPT_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_TRACEPOINT_BENCHMARK=y
CONFIG_RING_BUFFER_BENCHMARK=y
CONFIG_RING_BUFFER_STARTUP_TEST=y
CONFIG_TRACE_ENUM_MAP_FILE=y

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_RHASHTABLE=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
CONFIG_MEMTEST=y
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
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
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
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

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
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y

--=_559be1ee./9tdyPbznChQo7YkntdXp/uaiwvnlAbayZyItQ03e8HMF6wr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
