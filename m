Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 246516B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 04:21:13 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so7204376pad.11
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 01:21:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id s5si210872pdc.27.2014.09.30.01.21.10
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 01:21:11 -0700 (PDT)
Date: Tue, 30 Sep 2014 16:21:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm/slab] WARNING: CPU: 0 PID: 0 at
 arch/x86/kernel/cpu/common.c:1430 warn_pre_alternatives()
Message-ID: <20140930082105.GG9561@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cz6wLo+OExbGG7q/"
Content-Disposition: inline
In-Reply-To: <20140930075624.GA9561@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--cz6wLo+OExbGG7q/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joonsoo,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 8d8590d51e2b169f327a74c032333368f7f97f97
Author:     Joonsoo Kim <iamjoonsoo.kim@lge.com>
AuthorDate: Fri Sep 26 10:18:56 2014 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Fri Sep 26 10:18:56 2014 +1000

    mm/slab: support slab merge
    
    Slab merge is good feature to reduce fragmentation.  If new creating slab
    have similar size and property with exsitent slab, this feature reuse it
    rather than creating new one.  As a result, objects are packed into fewer
    slabs so that fragmentation is reduced.
    
    Below is result of my testing.
    
    * After boot, sleep 20; cat /proc/meminfo | grep Slab
    
    <Before>
    Slab: 25136 kB
    
    <After>
    Slab: 24364 kB
    
    We can save 3% memory used by slab.
    
    For supporting this feature in SLAB, we need to implement SLAB specific
    kmem_cache_flag() and __kmem_cache_alias(), because SLUB implements some
    SLUB specific processing related to debug flag and object size change on
    these functions.
    
    Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+-----------------------------------------------------------------+------------+------------+---------------+
|                                                                 | f49e433b66 | 8d8590d51e | next-20140926 |
+-----------------------------------------------------------------+------------+------------+---------------+
| boot_successes                                                  | 60         | 0          | 0             |
| boot_failures                                                   | 0          | 20         | 11            |
| WARNING:at_arch/x86/kernel/cpu/common.c:warn_pre_alternatives() | 0          | 20         |               |
| BUG:unable_to_handle_kernel                                     | 0          | 20         | 11            |
| Oops                                                            | 0          | 20         | 11            |
| EIP_is_at_kernfs_add_one                                        | 0          | 20         |               |
| Kernel_panic-not_syncing:Fatal_exception                        | 0          | 20         | 11            |
| backtrace:kobject_create_and_add                                | 0          | 20         |               |
| backtrace:mnt_init                                              | 0          | 20         |               |
| backtrace:vfs_caches_init                                       | 0          | 20         |               |
| EIP_is_at_kernfs_put                                            | 0          | 0          | 11            |
| backtrace:sysfs_remove_group                                    | 0          | 0          | 11            |
| backtrace:param_sysfs_init                                      | 0          | 0          | 11            |
| backtrace:kernel_init_freeable                                  | 0          | 0          | 11            |
+-----------------------------------------------------------------+------------+------------+---------------+

[    0.060070] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.064160] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.070024] ------------[ cut here ]------------
[    0.072984] WARNING: CPU: 0 PID: 0 at arch/x86/kernel/cpu/common.c:1430 warn_pre_alternatives+0x30/0x40()
[    0.079331] You're using static_cpu_has before alternatives have run!
[    0.080000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.17.0-rc6-00222-g8d8590d #2
[    0.080000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.080000]  c21022f8 c21cdd64 c1d3c98c c21cdd98 c1070636 c2102348 c21cddc4 00000000
[    0.080000]  c21022f8 00000596 c1020830 00000596 c1020830 43a81621 c21cde6c c1057f20
[    0.080000]  c21cddb0 c107072a 00000009 c21cdda8 c2102348 c21cddc4 c21cddc4 c1020830
[    0.080000] Call Trace:
[    0.080000]  [<c1d3c98c>] dump_stack+0x40/0x5e
[    0.080000]  [<c1070636>] warn_slowpath_common+0xb6/0x100
[    0.080000]  [<c1020830>] ? warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c1020830>] ? warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c1057f20>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.080000]  [<c107072a>] warn_slowpath_fmt+0x4a/0x60
[    0.080000]  [<c1020830>] warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c105d8a3>] __do_page_fault+0x153/0xa80
[    0.080000]  [<c105873f>] ? kvm_clock_read+0x2f/0x60
[    0.080000]  [<c1010067>] ? sched_clock+0x17/0x30
[    0.080000]  [<c1057f20>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.080000]  [<c105e5d6>] do_page_fault+0x36/0x50
[    0.080000]  [<c1057f40>] do_async_page_fault+0x20/0xf0
[    0.080000]  [<c1d53b3d>] error_code+0x65/0x6c
[    0.080000]  [<c1270000>] ? proc_pid_status+0x620/0xff0
[    0.080000]  [<c127a139>] ? kernfs_add_one+0x119/0x270
[    0.080000]  [<c1279bb7>] ? kernfs_new_node+0x67/0x90
[    0.080000]  [<c127a2fa>] kernfs_create_dir_ns+0x6a/0xc0
[    0.080000]  [<c127e036>] sysfs_create_dir_ns+0x56/0x120
[    0.080000]  [<c141986a>] kobject_add_internal+0x20a/0x870
[    0.080000]  [<c1432de6>] ? kvasprintf+0x86/0xa0
[    0.080000]  [<c141a153>] kobject_add_varg+0x43/0x90
[    0.080000]  [<c141a240>] kobject_add+0x40/0xb0
[    0.080000]  [<c14192f5>] ? kobject_create+0xf5/0x110
[    0.080000]  [<c141a30a>] kobject_create_and_add+0x5a/0xd0
[    0.080000]  [<c2551bc9>] mnt_init+0x1e4/0x380
[    0.080000]  [<c25511b5>] ? files_init+0x2c/0x7c
[    0.080000]  [<c255156f>] vfs_caches_init+0xe2/0x1b3
[    0.080000]  [<c25585de>] ? integrity_iintcache_init+0x2c/0x4d
[    0.080000]  [<c13d0b90>] ? devcgroup_inode_mknod+0x90/0x90
[    0.080000]  [<c251d6a3>] start_kernel+0x8cf/0x97d
[    0.080000]  [<c251c33b>] i386_start_kernel+0xe9/0xfb
[    0.080000] ---[ end trace 8c750c6fe159171a ]---
[    0.080000] BUG: unable to handle kernel paging request at 43a81621

git bisect start 4d8426f9ac601db2a64fa7be64051d02b9c9fe01 0f33be009b89d2268e94194dc4fd01a7851b6d51 --
git bisect good deb2ffc8689a85df3c127d6e6f8dc2901f4c7cd8  # 15:29     20+      0  Merge remote-tracking branch 'i2c/i2c/for-next'
git bisect good 462e0af1d10845875c68c4ebab8763e8aa745fc1  # 16:58     20+      0  Merge remote-tracking branch 'tip/auto-latest'
git bisect good 0a87e9437bf1d5d2947759165ed45d0e488e0958  # 17:08     20+      0  Revert "ipr: don't log error messages when applications issues illegal requests"
git bisect good 12308da406319a479375cf028966efca8aef6796  # 17:18     20+      0  Merge remote-tracking branch 'random/dev'
git bisect good 1f5c6373dd0714874a4870b6a94b8fc2510beb98  # 17:46     20+      0  Merge remote-tracking branch 'signal-cleanup/signal_v4'
git bisect  bad e5d19a1e64b7124747bde87ff154ba1c7b1b9bd8  # 17:51      0-      2  Merge branch 'akpm-current/current'
git bisect good a25c1d8786aeed7712fe04ce3f65b06f97d51072  # 18:01     20+      0  sparc: io: fix for asm-generic: io: implement relaxed accessor macros as conditional wrappers
git bisect  bad 5be2e725b91d2b2e512ff66cfb23a239012dc955  # 18:10      0-      1  mm: page_alloc: avoid wakeup kswapd on the unintended node
git bisect good caf144bbfe9ccab358ab7dd6c69a409f38002a89  # 18:25     20+      0  proc/maps: make vm_is_stack() logic namespace-friendly
git bisect  bad 85139d6797ed11cfefbe7b9b47f83f3a2f26848c  # 18:39      0-      3  block_dev: implement readpages() to optimize sequential read
git bisect  bad ef5783e1aa20c7d40ed952dfe9ace8f1f1a2e925  # 18:43      0-      1  mm/mmap.c: whitespace fixes
git bisect good 106033415f2306c188fc3993983856ff1b61730d  # 19:04     20+      0  mm/slab: noinline __ac_put_obj()
git bisect good 7beefd02978e077edeee6bca011ed3357cb88ab4  # 19:25     20+      0  kernel/kthread.c: partial revert of 81c98869faa5 ("kthread: ensure locality of task_struct allocations")
git bisect good f49e433b66f5d6a0a0feef60c0d984daccdce2c4  # 19:44     20+      0  mm/slab_common: fix build failure if CONFIG_SLUB
git bisect  bad 997888488ef92da365b870247de773255227ce1f  # 19:48      0-      1  mm/slab: use percpu allocator for cpu cache
git bisect  bad 8d8590d51e2b169f327a74c032333368f7f97f97  # 19:50      0-      1  mm/slab: support slab merge
# first bad commit: [8d8590d51e2b169f327a74c032333368f7f97f97] mm/slab: support slab merge
git bisect good f49e433b66f5d6a0a0feef60c0d984daccdce2c4  # 20:27     60+      0  mm/slab_common: fix build failure if CONFIG_SLUB
git bisect  bad 4d8426f9ac601db2a64fa7be64051d02b9c9fe01  # 20:27      0-     11  Add linux-next specific files for 20140926
git bisect good 1e3827bf8aebe29af2d6e49b89d85dfae4d0154f  # 20:48     60+      0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect  bad 4d8426f9ac601db2a64fa7be64051d02b9c9fe01  # 20:49      0-     11  Add linux-next specific files for 20140926


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-m 320
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
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

Thanks,
Fengguang

--cz6wLo+OExbGG7q/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-37:20140928195125:i386-randconfig-ib1-09281302::"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.17.0-rc6-00222-g8d8590d (kbuild@lkp-ib03) (g=
cc version 4.9.1 (Debian 4.9.1-11) ) #2 Sun Sep 28 19:49:30 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x1000000
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
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x035fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x125fffff]
[    0.000000]  [mem 0x12400000-0x125fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x123fffff]
[    0.000000]  [mem 0x10000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12600000-0x13fdffff]
[    0.000000]  [mem 0x12600000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x0307e000, 0x0307efff] PGTABLE
[    0.000000] cma: Reserved 16 MiB at 11400000
[    0.000000] RAMDISK: [mem 0x12793000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACS 0x13FE0000 000040
[    0.000000] ACPI: SSDT 0x13FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FE1885 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13fe0000
[    0.000000]   low ram: 0 - 13fe0000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] BRK [0x0307f000, 0x0307ffff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x13fdffff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13fdffff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   Normal zone: 640 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 81790 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 21f3880
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81150
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-r=
andconfig-ib1-09281302/next:master:8d8590d51e2b169f327a74c032333368f7f97f97=
:bisect-linux-6/.vmlinuz-8d8590d51e2b169f327a74c032333368f7f97f97-201409281=
94941-11-ivb41 branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib=
1-09281302/8d8590d51e2b169f327a74c032333368f7f97f97/vmlinuz-3.17.0-rc6-0022=
2-g8d8590d drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 247828K/327160K available (13649K kernel code, 3387K=
 rwdata, 4532K rodata, 768K init, 10776K bss, 79332K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa2000 - 0xfffff000   ( 372 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47e0000 - 0xffbfe000   ( 692 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3fe0000   ( 319 MB)
[    0.000000]       .init : 0xc251c000 - 0xc25dc000   ( 768 kB)
[    0.000000]       .data : 0xc1d548e1 - 0xc251ac80   (7960 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1d548e1   (13650 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] NR_IRQS:2304 nr_irqs:256 0
[    0.000000] CPU 0 irqstacks, hard=3Dc0094000 soft=3Dc0096000
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 5151 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value.. 5387.01 Bogo=
MIPS (lpj=3D26935080)
[    0.020013] pid_max: default: 4096 minimum: 301
[    0.022997] ACPI: Core revision 20140724
[    0.049142] ACPI: All ACPI Tables successfully acquired
[    0.052998] Security Framework initialized
[    0.056012] AppArmor: AppArmor disabled by boot time parameter
[    0.060070] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.064160] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 by=
tes)
[    0.070024] ------------[ cut here ]------------
[    0.072984] WARNING: CPU: 0 PID: 0 at arch/x86/kernel/cpu/common.c:1430 =
warn_pre_alternatives+0x30/0x40()
[    0.079331] You're using static_cpu_has before alternatives have run!
[    0.080000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.17.0-rc6-00222-g8d=
8590d #2
[    0.080000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.080000]  c21022f8 c21cdd64 c1d3c98c c21cdd98 c1070636 c2102348 c21cd=
dc4 00000000
[    0.080000]  c21022f8 00000596 c1020830 00000596 c1020830 43a81621 c21cd=
e6c c1057f20
[    0.080000]  c21cddb0 c107072a 00000009 c21cdda8 c2102348 c21cddc4 c21cd=
dc4 c1020830
[    0.080000] Call Trace:
[    0.080000]  [<c1d3c98c>] dump_stack+0x40/0x5e
[    0.080000]  [<c1070636>] warn_slowpath_common+0xb6/0x100
[    0.080000]  [<c1020830>] ? warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c1020830>] ? warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c1057f20>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.080000]  [<c107072a>] warn_slowpath_fmt+0x4a/0x60
[    0.080000]  [<c1020830>] warn_pre_alternatives+0x30/0x40
[    0.080000]  [<c105d8a3>] __do_page_fault+0x153/0xa80
[    0.080000]  [<c105873f>] ? kvm_clock_read+0x2f/0x60
[    0.080000]  [<c1010067>] ? sched_clock+0x17/0x30
[    0.080000]  [<c1057f20>] ? kvm_read_and_reset_pf_reason+0x40/0x40
[    0.080000]  [<c105e5d6>] do_page_fault+0x36/0x50
[    0.080000]  [<c1057f40>] do_async_page_fault+0x20/0xf0
[    0.080000]  [<c1d53b3d>] error_code+0x65/0x6c
[    0.080000]  [<c1270000>] ? proc_pid_status+0x620/0xff0
[    0.080000]  [<c127a139>] ? kernfs_add_one+0x119/0x270
[    0.080000]  [<c1279bb7>] ? kernfs_new_node+0x67/0x90
[    0.080000]  [<c127a2fa>] kernfs_create_dir_ns+0x6a/0xc0
[    0.080000]  [<c127e036>] sysfs_create_dir_ns+0x56/0x120
[    0.080000]  [<c141986a>] kobject_add_internal+0x20a/0x870
[    0.080000]  [<c1432de6>] ? kvasprintf+0x86/0xa0
[    0.080000]  [<c141a153>] kobject_add_varg+0x43/0x90
[    0.080000]  [<c141a240>] kobject_add+0x40/0xb0
[    0.080000]  [<c14192f5>] ? kobject_create+0xf5/0x110
[    0.080000]  [<c141a30a>] kobject_create_and_add+0x5a/0xd0
[    0.080000]  [<c2551bc9>] mnt_init+0x1e4/0x380
[    0.080000]  [<c25511b5>] ? files_init+0x2c/0x7c
[    0.080000]  [<c255156f>] vfs_caches_init+0xe2/0x1b3
[    0.080000]  [<c25585de>] ? integrity_iintcache_init+0x2c/0x4d
[    0.080000]  [<c13d0b90>] ? devcgroup_inode_mknod+0x90/0x90
[    0.080000]  [<c251d6a3>] start_kernel+0x8cf/0x97d
[    0.080000]  [<c251c33b>] i386_start_kernel+0xe9/0xfb
[    0.080000] ---[ end trace 8c750c6fe159171a ]---
[    0.080000] BUG: unable to handle kernel paging request at 43a81621
[    0.080000] IP: [<c127a139>] kernfs_add_one+0x119/0x270
[    0.080000] *pdpt =3D 0000000000000000 *pde =3D f000ff53f000ff53=20
[    0.080000] Oops: 0002 [#1]=20
[    0.080000] CPU: 0 PID: 0 Comm: swapper Tainted: G        W      3.17.0-=
rc6-00222-g8d8590d #2
[    0.080000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.080000] task: c21d4d40 ti: c21cc000 task.ti: c21cc000
[    0.080000] EIP: 0060:[<c127a139>] EFLAGS: 00210246 CPU: 0
[    0.080000] EIP is at kernfs_add_one+0x119/0x270
[    0.080000] EAX: 5427f634 EBX: 43a81601 ECX: 00000008 EDX: 29a94b9a
[    0.080000] ESI: c0011570 EDI: c00115d0 EBP: c21cdecc ESP: c21cdea8
[    0.080000]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    0.080000] CR0: 8005003b CR2: 43a81621 CR3: 025df000 CR4: 000006b0
[    0.080000] Stack:
[    0.080000]  c0091f00 c00115d0 00000001 c00115d0 c21cdecc c1279bb7 c0011=
570 c00115d0
[    0.080000]  c0080d80 c21cdee0 c127a2fa 00000001 c0080d80 c00115d0 c21cd=
efc c127e036
[    0.080000]  c0080d80 00000000 c0080d80 c0080d80 00000000 c21cdf34 c1419=
86a c21cdf74
[    0.080000] Call Trace:
[    0.080000]  [<c1279bb7>] ? kernfs_new_node+0x67/0x90
[    0.080000]  [<c127a2fa>] kernfs_create_dir_ns+0x6a/0xc0
[    0.080000]  [<c127e036>] sysfs_create_dir_ns+0x56/0x120
[    0.080000]  [<c141986a>] kobject_add_internal+0x20a/0x870
[    0.080000]  [<c1432de6>] ? kvasprintf+0x86/0xa0
[    0.080000]  [<c141a153>] kobject_add_varg+0x43/0x90
[    0.080000]  [<c141a240>] kobject_add+0x40/0xb0
[    0.080000]  [<c14192f5>] ? kobject_create+0xf5/0x110
[    0.080000]  [<c141a30a>] kobject_create_and_add+0x5a/0xd0
[    0.080000]  [<c2551bc9>] mnt_init+0x1e4/0x380
[    0.080000]  [<c25511b5>] ? files_init+0x2c/0x7c
[    0.080000]  [<c255156f>] vfs_caches_init+0xe2/0x1b3
[    0.080000]  [<c25585de>] ? integrity_iintcache_init+0x2c/0x4d
[    0.080000]  [<c13d0b90>] ? devcgroup_inode_mknod+0x90/0x90
[    0.080000]  [<c251d6a3>] start_kernel+0x8cf/0x97d
[    0.080000]  [<c251c33b>] i386_start_kernel+0xe9/0xfb
[    0.080000] Code: 15 e4 34 cd c2 00 85 db 74 2d 83 05 e8 34 cd c2 01 83 =
15 ec 34 cd c2 00 e8 05 68 e8 ff 83 05 f0 34 cd c2 01 83 15 f4 34 cd c2 00 =
<89> 43 20 89 53 24 89 43 28 89 53 2c b8 80 e5 37 c2 e8 b1 32 ad
[    0.080000] EIP: [<c127a139>] kernfs_add_one+0x119/0x270 SS:ESP 0068:c21=
cdea8
[    0.080000] CR2: 0000000043a81621
[    0.080000] ---[ end trace 8c750c6fe159171b ]---
[    0.080000] Kernel panic - not syncing: Fatal exception

Elapsed time: 20
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-i=
b1-09281302/8d8590d51e2b169f327a74c032333368f7f97f97/vmlinuz-3.17.0-rc6-002=
22-g8d8590d -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=
=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal =
 root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-ib1=
-09281302/next:master:8d8590d51e2b169f327a74c032333368f7f97f97:bisect-linux=
-6/.vmlinuz-8d8590d51e2b169f327a74c032333368f7f97f97-20140928194941-11-ivb4=
1 branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib1-09281302/8d=
8590d51e2b169f327a74c032333368f7f97f97/vmlinuz-3.17.0-rc6-00222-g8d8590d dr=
bd.minor_count=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m =
320 -smp 2 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=
=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm=
/kboot/pid-quantal-ivb41-37 -serial file:/dev/shm/kboot/serial-quantal-ivb4=
1-37 -daemonize -display none -monitor null=20

--cz6wLo+OExbGG7q/
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="i386-randconfig-ib1-09281302-4d8426f9ac601db2a64fa7be64051d02b9c9fe01-BUG:-unable-to-handle-kernel-118693.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgNGQ4NDI2Zi4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxl
cyBmb3IgMjAxNDA5MjYKZ2l0IGNoZWNrb3V0IDBmMzNiZTAwOWI4OWQyMjY4ZTk0MTk0ZGM0
ZmQwMWE3ODUxYjZkNTEKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6MGYzM2JlMDA5Yjg5ZDIyNjhl
OTQxOTRkYzRmZDAxYTc4NTFiNmQ1MTpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0yOCAxNTox
OToyOCAwZjMzYmUwMDliODlkMjI2OGU5NDE5NGRjNGZkMDFhNzg1MWI2ZDUxIHJldXNlIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi8wZjMzYmUwMDliODlkMjI2OGU5
NDE5NGRjNGZkMDFhNzg1MWI2ZDUxL3ZtbGludXotMy4xNy4wLXJjNgoKMjAxNC0wOS0yOCAx
NToxOToyOCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgk0CTEwLgkxMwkxNgkyMCBTVUNDRVNT
CgpiaXNlY3Q6IGdvb2QgY29tbWl0IDBmMzNiZTAwOWI4OWQyMjY4ZTk0MTk0ZGM0ZmQwMWE3
ODUxYjZkNTEKZ2l0IGJpc2VjdCBzdGFydCA0ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1
MWQwMmI5YzlmZTAxIDBmMzNiZTAwOWI4OWQyMjY4ZTk0MTk0ZGM0ZmQwMWE3ODUxYjZkNTEg
LS0KL2Mva2VybmVsLXRlc3RzL2xpbmVhci1iaXNlY3Q6IFsiLWIiLCAiNGQ4NDI2ZjlhYzYw
MWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMSIsICItZyIsICIwZjMzYmUwMDliODlkMjI2
OGU5NDE5NGRjNGZkMDFhNzg1MWI2ZDUxIiwgIi9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVz
dC1ib290LWZhaWx1cmUuc2giLCAiL2MvYm9vdC1iaXNlY3QvbGludXgtNi9vYmotYmlzZWN0
Il0KQmlzZWN0aW5nOiA5MjczIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSAxNCBzdGVwcykKW2RlYjJmZmM4Njg5YTg1ZGYzYzEyN2Q2ZTZmOGRjMjkwMWY0
YzdjZDhdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ2kyYy9pMmMvZm9yLW5leHQn
CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAv
Yy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9y
dW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6
ZGViMmZmYzg2ODlhODVkZjNjMTI3ZDZlNmY4ZGMyOTAxZjRjN2NkODpiaXNlY3QtbGludXgt
NgoKMjAxNC0wOS0yOCAxNToyMzozMSBkZWIyZmZjODY4OWE4NWRmM2MxMjdkNmU2ZjhkYzI5
MDFmNGM3Y2Q4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItZGVi
MmZmYzg2ODlhODVkZjNjMTI3ZDZlNmY4ZGMyOTAxZjRjN2NkOApDaGVjayBmb3Iga2VybmVs
IGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9kZWIyZmZjODY4OWE4
NWRmM2MxMjdkNmU2ZjhkYzI5MDFmNGM3Y2Q4CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2Yg
L2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjgxMzAyLWRlYjJmZmM4Njg5YTg1ZGYzYzEyN2Q2ZTZmOGRjMjkwMWY0YzdjZDgKG1sx
OzM1bTIwMTQtMDktMjggMTU6MjY6MzEgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWlsZC10
ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi1kZWIyZmZj
ODY4OWE4NWRmM2MxMjdkNmU2ZjhkYzI5MDFmNGM3Y2Q4G1swbQpSZXRyeSBidWlsZCAuLgpr
ZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9kZWIyZmZjODY4
OWE4NWRmM2MxMjdkNmU2ZjhkYzI5MDFmNGM3Y2Q4L3ZtbGludXotMy4xNy4wLXJjNi0wMjI0
MC1nZGViMmZmYwoKMjAxNC0wOS0yOCAxNToyNzozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAJ
MwkxMQkxNgkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDY5MDYgcmV2aXNpb25zIGxlZnQgdG8g
dGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEzIHN0ZXBzKQpbNDYyZTBhZjFkMTA4NDU4NzVj
NjhjNGViYWI4NzYzZThhYTc0NWZjMV0gTWVyZ2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAn
dGlwL2F1dG8tbGF0ZXN0JwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgtNi9vYmotYmlzZWN0CmxzIC1h
IC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5Mjgx
MzAyL25leHQ6bWFzdGVyOjQ2MmUwYWYxZDEwODQ1ODc1YzY4YzRlYmFiODc2M2U4YWE3NDVm
YzE6YmlzZWN0LWxpbnV4LTYKCjIwMTQtMDktMjggMTU6Mjk6MzQgNDYyZTBhZjFkMTA4NDU4
NzVjNjhjNGViYWI4NzYzZThhYTc0NWZjMSBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sg
dG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLTQ2MmUwYWYxZDEwODQ1ODc1YzY4YzRlYmFiODc2M2U4YWE3NDVmYzEK
Q2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDIvNDYyZTBhZjFkMTA4NDU4NzVjNjhjNGViYWI4NzYzZThhYTc0NWZjMQp3YWl0aW5nIGZv
ciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi00NjJlMGFmMWQxMDg0NTg3NWM2OGM0ZWJhYjg3
NjNlOGFhNzQ1ZmMxChtbMTszNW0yMDE0LTA5LTI4IDE2OjIyOjM0IE5vIGJ1aWxkIHNlcnZl
ZCBmaWxlIC9rYnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyODEzMDItNDYyZTBhZjFkMTA4NDU4NzVjNjhjNGViYWI4NzYzZThhYTc0NWZjMRtbMG0K
UmV0cnkgYnVpbGQgLi4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDItNDYyZTBhZjFkMTA4NDU4NzVjNjhjNGViYWI4NzYzZThhYTc0NWZjMQprZXJuZWw6IC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80NjJlMGFmMWQxMDg0NTg3NWM2
OGM0ZWJhYjg3NjNlOGFhNzQ1ZmMxL3ZtbGludXotMy4xNy4wLXJjNi0wNjI5My1nNDYyZTBh
ZjEKCjIwMTQtMDktMjggMTY6NTI6MzQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4JNAk1CTgJ
MTEJMTQJMTUuCTE2CTE5CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMjg1MyByZXZpc2lvbnMg
bGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTIgc3RlcHMpClswYTg3ZTk0Mzdi
ZjFkNWQyOTQ3NzU5MTY1ZWQ0NWQwZTQ4OGUwOTU4XSBSZXZlcnQgImlwcjogZG9uJ3QgbG9n
IGVycm9yIG1lc3NhZ2VzIHdoZW4gYXBwbGljYXRpb25zIGlzc3VlcyBpbGxlZ2FsIHJlcXVl
c3RzIgpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUu
c2ggL2MvYm9vdC1iaXNlY3QvbGludXgtNi9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVz
dHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL25leHQ6bWFz
dGVyOjBhODdlOTQzN2JmMWQ1ZDI5NDc3NTkxNjVlZDQ1ZDBlNDg4ZTA5NTg6YmlzZWN0LWxp
bnV4LTYKCjIwMTQtMDktMjggMTY6NTg6MzcgMGE4N2U5NDM3YmYxZDVkMjk0Nzc1OTE2NWVk
NDVkMGU0ODhlMDk1OCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAy
LTBhODdlOTQzN2JmMWQ1ZDI5NDc3NTkxNjVlZDQ1ZDBlNDg4ZTA5NTgKQ2hlY2sgZm9yIGtl
cm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvMGE4N2U5NDM3
YmYxZDVkMjk0Nzc1OTE2NWVkNDVkMGU0ODhlMDk1OAp3YWl0aW5nIGZvciBjb21wbGV0aW9u
IG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTI4MTMwMi0wYTg3ZTk0MzdiZjFkNWQyOTQ3NzU5MTY1ZWQ0NWQwZTQ4OGUwOTU4
ChtbMTszNW0yMDE0LTA5LTI4IDE3OjAwOjM3IE5vIGJ1aWxkIHNlcnZlZCBmaWxlIC9rYnVp
bGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItMGE4
N2U5NDM3YmYxZDVkMjk0Nzc1OTE2NWVkNDVkMGU0ODhlMDk1OBtbMG0KUmV0cnkgYnVpbGQg
Li4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVl
L2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItMGE4N2U5NDM3
YmYxZDVkMjk0Nzc1OTE2NWVkNDVkMGU0ODhlMDk1OAprZXJuZWw6IC9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTI4MTMwMi8wYTg3ZTk0MzdiZjFkNWQyOTQ3NzU5MTY1ZWQ0NWQw
ZTQ4OGUwOTU4L3ZtbGludXotMy4xNy4wLXJjNi0wODUyMC1nMGE4N2U5NAoKMjAxNC0wOS0y
OCAxNzowMjozNyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAJMQkyCTQJNgk5LgkxMQkxMwkxNQkx
OC4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA2MjYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBh
ZnRlciB0aGlzIChyb3VnaGx5IDEwIHN0ZXBzKQpbMTIzMDhkYTQwNjMxOWE0NzkzNzVjZjAy
ODk2NmVmY2E4YWVmNjc5Nl0gTWVyZ2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAncmFuZG9t
L2RldicKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9uZXh0Om1h
c3RlcjoxMjMwOGRhNDA2MzE5YTQ3OTM3NWNmMDI4OTY2ZWZjYThhZWY2Nzk2OmJpc2VjdC1s
aW51eC02CgoyMDE0LTA5LTI4IDE3OjA4OjQyIDEyMzA4ZGE0MDYzMTlhNDc5Mzc1Y2YwMjg5
NjZlZmNhOGFlZjY3OTYgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMw
Mi0xMjMwOGRhNDA2MzE5YTQ3OTM3NWNmMDI4OTY2ZWZjYThhZWY2Nzk2CkNoZWNrIGZvciBr
ZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzEyMzA4ZGE0
MDYzMTlhNDc5Mzc1Y2YwMjg5NjZlZmNhOGFlZjY3OTYKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyODEzMDItMTIzMDhkYTQwNjMxOWE0NzkzNzVjZjAyODk2NmVmY2E4YWVmNjc5
NgobWzE7MzVtMjAxNC0wOS0yOCAxNzoxMTo0MiBObyBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1
aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTEy
MzA4ZGE0MDYzMTlhNDc5Mzc1Y2YwMjg5NjZlZmNhOGFlZjY3OTYbWzBtClJldHJ5IGJ1aWxk
IC4uCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzEyMzA4
ZGE0MDYzMTlhNDc5Mzc1Y2YwMjg5NjZlZmNhOGFlZjY3OTYvdm1saW51ei0zLjE3LjAtcmM2
LTA4NjU3LWcxMjMwOGRhCgoyMDE0LTA5LTI4IDE3OjEyOjQyIGRldGVjdGluZyBib290IHN0
YXRlIC4uCTIJMwk0CTgJMTEJMTIJMTYJMTkJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA0ODkg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDkgc3RlcHMpClsx
ZjVjNjM3M2RkMDcxNDg3NGE0ODcwYjZhOTRiOGZjMjUxMGJlYjk4XSBNZXJnZSByZW1vdGUt
dHJhY2tpbmcgYnJhbmNoICdzaWduYWwtY2xlYW51cC9zaWduYWxfdjQnCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2Vj
dC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6MWY1YzYzNzNkZDA3
MTQ4NzRhNDg3MGI2YTk0YjhmYzI1MTBiZWI5ODpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0y
OCAxNzoxODoxNCAxZjVjNjM3M2RkMDcxNDg3NGE0ODcwYjZhOTRiOGZjMjUxMGJlYjk4IGNv
bXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVl
L2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItMWY1YzYzNzNkZDA3MTQ4
NzRhNDg3MGI2YTk0YjhmYzI1MTBiZWI5OApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi8xZjVjNjM3M2RkMDcxNDg3NGE0ODcwYjZh
OTRiOGZjMjUxMGJlYjk4CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0
cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTFm
NWM2MzczZGQwNzE0ODc0YTQ4NzBiNmE5NGI4ZmMyNTEwYmViOTgKG1sxOzM1bTIwMTQtMDkt
MjggMTc6MjE6MTQgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWlsZC10ZXN0cy9idWlsZC1z
ZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi0xZjVjNjM3M2RkMDcxNDg3NGE0
ODcwYjZhOTRiOGZjMjUxMGJlYjk4G1swbQpSZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBj
b21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMtc21va2Uv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi0xZjVjNjM3M2RkMDcxNDg3NGE0ODcwYjZh
OTRiOGZjMjUxMGJlYjk4Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjgxMzAyLzFmNWM2MzczZGQwNzE0ODc0YTQ4NzBiNmE5NGI4ZmMyNTEwYmViOTgvdm1saW51
ei0zLjE3LjAtcmM2LTA4NzM5LWcxZjVjNjM3CgoyMDE0LTA5LTI4IDE3OjIzOjE0IGRldGVj
dGluZyBib290IHN0YXRlIC4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
CTEJNQk3CTExCTEzCTE2LgkxNwkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDQwNyByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKW2U1ZDE5YTFl
NjRiNzEyNDc0N2JkZTg3ZmYxNTRiYTFjN2IxYjliZDhdIE1lcmdlIGJyYW5jaCAnYWtwbS1j
dXJyZW50L2N1cnJlbnQnCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJv
b3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMgLWEg
L2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDIvbmV4dDptYXN0ZXI6ZTVkMTlhMWU2NGI3MTI0NzQ3YmRlODdmZjE1NGJhMWM3YjFiOWJk
ODpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0yOCAxNzo0Njo0NSBlNWQxOWExZTY0YjcxMjQ3
NDdiZGU4N2ZmMTU0YmExYzdiMWI5YmQ4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyODEzMDItZTVkMTlhMWU2NGI3MTI0NzQ3YmRlODdmZjE1NGJhMWM3YjFiOWJkOApD
aGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMw
Mi9lNWQxOWExZTY0YjcxMjQ3NDdiZGU4N2ZmMTU0YmExYzdiMWI5YmQ4CndhaXRpbmcgZm9y
IGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLWU1ZDE5YTFlNjRiNzEyNDc0N2JkZTg3ZmYxNTRi
YTFjN2IxYjliZDgKG1sxOzM1bTIwMTQtMDktMjggMTc6NDg6NDUgTm8gYnVpbGQgc2VydmVk
IGZpbGUgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTI4MTMwMi1lNWQxOWExZTY0YjcxMjQ3NDdiZGU4N2ZmMTU0YmExYzdiMWI5YmQ4G1swbQpS
ZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMw
Mi1lNWQxOWExZTY0YjcxMjQ3NDdiZGU4N2ZmMTU0YmExYzdiMWI5YmQ4Cmtlcm5lbDogL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL2U1ZDE5YTFlNjRiNzEyNDc0N2Jk
ZTg3ZmYxNTRiYTFjN2IxYjliZDgvdm1saW51ei0zLjE3LjAtcmM2LTA5MDc0LWdlNWQxOWEx
CgoyMDE0LTA5LTI4IDE3OjUwOjQ1IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlM
VVJFClsgICAgMC4yMDAzMTZdIFBDSSA6IFBDSSBCSU9TIGFyZWEgaXMgcncgYW5kIHguIFVz
ZSBwY2k9bm9iaW9zIGlmIHlvdSB3YW50IGl0IE5YLgpbICAgIDAuMjAyNDUxXSBQQ0k6IFBD
SSBCSU9TIHJldmlzaW9uIDIuMTAgZW50cnkgYXQgMHhmZDQ1NiwgbGFzdCBidXM9MApbICAg
IDAuMjA0NDU5XSBQQ0k6IFVzaW5nIGNvbmZpZ3VyYXRpb24gdHlwZSAxIGZvciBiYXNlIGFj
Y2VzcwpbICAgIDAuMjM1OTc2XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIHBhZ2lu
ZyByZXF1ZXN0IGF0IDM1NTUzYTNhClsgICAgMC4yMzgwNDBdIElQOiBbPGMxMjdlYjQ3Pl0g
a2VybmZzX3B1dCsweGQ3LzB4M2EwClsgICAgMC4yMzk4MDldICpwZHB0ID0gMDAwMDAwMDAw
MDAwMDAwMCAqcGRlID0gMDAwMDAwMDAwMDAwMDAwMCAKWyAgICAwLjI0MDAwMF0gT29wczog
MDAwMCBbIzFdIApbICAgIDAuMjQwMDAwXSBDUFU6IDAgUElEOiAxIENvbW06IHN3YXBwZXIg
Tm90IHRhaW50ZWQgMy4xNy4wLXJjNi0wOTA3NC1nZTVkMTlhMSAjMQpbICAgIDAuMjQwMDAw
XSBIYXJkd2FyZSBuYW1lOiBRRU1VIFN0YW5kYXJkIFBDIChpNDQwRlggKyBQSUlYLCAxOTk2
KSwgQklPUyAxLjcuNS0yMDE0MDUzMV8wODMwMzAtZ2FuZGFsZiAwNC8wMS8yMDE0ClsgICAg
MC4yNDAwMDBdIHRhc2s6IGMwMDJlMDEwIHRpOiBjMDAzMDAwMCB0YXNrLnRpOiBjMDAzMDAw
MApbICAgIDAuMjQwMDAwXSBFSVA6IDAwNjA6WzxjMTI3ZWI0Nz5dIEVGTEFHUzogMDAwMTAy
MDYgQ1BVOiAwClsgICAgMC4yNDAwMDBdIEVJUCBpcyBhdCBrZXJuZnNfcHV0KzB4ZDcvMHgz
YTAKWyAgICAwLjI0MDAwMF0gRUFYOiAzNTU1M2EwNiBFQlg6IGMwMTAwZjkwIEVDWDogMDAw
MDAwMDEgRURYOiAwMDAwMDAwMgpbICAgIDAuMjQwMDAwXSBFU0k6IGMwMTAwZjkwIEVESTog
MDAwMDAwMDAgRUJQOiBjMDAzMWUxOCBFU1A6IGMwMDMxZGU0ClsgICAgMC4yNDAwMDBdICBE
UzogMDA3YiBFUzogMDA3YiBGUzogMDAwMCBHUzogMDBlMCBTUzogMDA2OApbICAgIDAuMjQw
MDAwXSBDUjA6IDgwMDUwMDNiIENSMjogMzU1NTNhM2EgQ1IzOiAwMjVmMzAwMCBDUjQ6IDAw
MDAwNmIwClsgICAgMC4yNDAwMDBdIFN0YWNrOgpbICAgIDAuMjQwMDAwXSAgMDAwMDAwMDEg
MDAwMDAwMDAgYzEyN2Y5ZDUgMDAwMDAyNDYgMDAwMDAwMDAgYzIzOGM4NDAgYzAwOTFmMDAg
YzAwOTFmMDgKWyAgICAwLjI0MDAwMF0gIGMwMTAwZjk4IGMwMDdlMDMwIGMwMTAwZjkwIGMw
MTAwZjkwIDAwMDAwMDAwIGMwMDMxZTU0IGMxMjdmNzY1IDAwMDAwMDAwClsgICAgMC4yNDAw
MDBdICAwMDAwMDAwMSAwMDAwMDAwMCBjMTI4MDk0ZiBjMDEwMGY5OCBjMjM4Yzg0MCBjMWQ1
NmEzNiAwMDAwMDA0NiBjMWUxYTgwZApbICAgIDAuMjQwMDAwXSBDYWxsIFRyYWNlOgpbICAg
IDAuMjQwMDAwXSAgWzxjMTI3ZjlkNT5dID8gX19rZXJuZnNfcmVtb3ZlKzB4MzY1LzB4Njcw
ClsgICAgMC4yNDAwMDBdICBbPGMxMjdmNzY1Pl0gX19rZXJuZnNfcmVtb3ZlKzB4ZjUvMHg2
NzAKWyAgICAwLjI0MDAwMF0gIFs8YzEyODA5NGY+XSA/IGtlcm5mc19yZW1vdmVfYnlfbmFt
ZV9ucysweDZmLzB4MTIwClsgICAgMC4yNDAwMDBdICBbPGMxZDU2YTM2Pl0gPyBtdXRleF91
bmxvY2srMHgxNi8weDMwClsgICAgMC4yNDAwMDBdICBbPGMxMjgwOTRmPl0ga2VybmZzX3Jl
bW92ZV9ieV9uYW1lX25zKzB4NmYvMHgxMjAKWyAgICAwLjI0MDAwMF0gIFs8YzEyODRiZDE+
XSByZW1vdmVfZmlsZXMuaXNyYS4xKzB4NTEvMHhjMApbICAgIDAuMjQwMDAwXSAgWzxjMTI4
NTIxNj5dIHN5c2ZzX3JlbW92ZV9ncm91cCsweDU2LzB4MTQwClsgICAgMC4yNDAwMDBdICBb
PGMyNTUxZjUwPl0gPyBsb2NhdGVfbW9kdWxlX2tvYmplY3QrMHgyMi8weDFjZApbICAgIDAu
MjQwMDAwXSAgWzxjMjU1MjM0MD5dIHBhcmFtX3N5c2ZzX2luaXQrMHgyNDUvMHg1MTEKWyAg
ICAwLjI0MDAwMF0gIFs8YzE0Mzk5NzY+XSA/IGt2YXNwcmludGYrMHg4Ni8weGEwClsgICAg
MC4yNDAwMDBdICBbPGMyNTUyMGZiPl0gPyBsb2NhdGVfbW9kdWxlX2tvYmplY3QrMHgxY2Qv
MHgxY2QKWyAgICAwLjI0MDAwMF0gIFs8YzI1MmQ5NWM+XSBkb19vbmVfaW5pdGNhbGwrMHgx
ZjMvMHgzMGUKWyAgICAwLjI0MDAwMF0gIFs8YzI1MmRjYTc+XSBrZXJuZWxfaW5pdF9mcmVl
YWJsZSsweDIzMC8weDM4YgpbICAgIDAuMjQwMDAwXSAgWzxjMWQzOTEyOT5dIGtlcm5lbF9p
bml0KzB4MTkvMHgyMzAKWyAgICAwLjI0MDAwMF0gIFs8YzEwYWJhZmE+XSA/IHNjaGVkdWxl
X3RhaWwrMHgxYS8weGEwClsgICAgMC4yNDAwMDBdICBbPGMxZDVjNzgwPl0gcmV0X2Zyb21f
a2VybmVsX3RocmVhZCsweDIwLzB4MzAKWyAgICAwLjI0MDAwMF0gIFs8YzFkMzkxMTA+XSA/
IHJlc3RfaW5pdCsweDE4MC8weDE4MApbICAgIDAuMjQwMDAwXSBDb2RlOiAwMSAwMCAwMCA5
MCAwZiBiNyA0NiA1NCA4OSBjMiA4MyBlMiAwZiA2NiA4MyBmYSAwNCAwZiA4NCA1ZCAwMiAw
MCAwMCBmNiBjNCAwMiAwZiA4NCAwYyAwMiAwMCAwMCA4YiA0NiA1YyA4NSBjMCAwZiA4NCAz
MCAwMiAwMCAwMCA8OGI+IDQ4IDM0IDgzIDA1IGY4IDhlIGNlIGMyIDAxIDgzIDE1IGZjIDhl
IGNlIGMyIDAwIDg1IGM5IDc0IDI5ClsgICAgMC4yNDAwMDBdIEVJUDogWzxjMTI3ZWI0Nz5d
IGtlcm5mc19wdXQrMHhkNy8weDNhMCBTUzpFU1AgMDA2ODpjMDAzMWRlNApbICAgIDAuMjQw
MDAwXSBDUjI6IDAwMDAwMDAwMzU1NTNhM2EKWyAgICAwLjI0MDAwMF0gLS0tWyBlbmQgdHJh
Y2UgMzhiN2UwOGUxNTk0ZDljMyBdLS0tClsgICAgMC4yNDAwMDBdIEtlcm5lbCBwYW5pYyAt
IG5vdCBzeW5jaW5nOiBGYXRhbCBleGNlcHRpb24KL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyL2U1ZDE5YTFlNjRiNzEyNDc0N2JkZTg3ZmYxNTRiYTFjN2IxYjliZDgv
ZG1lc2cteW9jdG8taXZiNDEtMTI3OjIwMTQwOTI4MTc1MDEyOmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyODEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvZTVk
MTlhMWU2NGI3MTI0NzQ3YmRlODdmZjE1NGJhMWM3YjFiOWJkOC9kbWVzZy15b2N0by1pdmI0
MS04MjoyMDE0MDkyODE3NTA0MTppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjoKMDoy
OjIgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQtMDktMjggMTc6NTE6
MTUgUkVQRUFUIENPVU5UOiAyMCAgIyAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNl
Y3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMzM1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3Qg
YWZ0ZXIgdGhpcyAocm91Z2hseSA5IHN0ZXBzKQpbYTI1YzFkODc4NmFlZWQ3NzEyZmUwNGNl
M2Y2NWIwNmY5N2Q1MTA3Ml0gc3BhcmM6IGlvOiBmaXggZm9yIGFzbS1nZW5lcmljOiBpbzog
aW1wbGVtZW50IHJlbGF4ZWQgYWNjZXNzb3IgbWFjcm9zIGFzIGNvbmRpdGlvbmFsIHdyYXBw
ZXJzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5z
aCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0
ZXI6YTI1YzFkODc4NmFlZWQ3NzEyZmUwNGNlM2Y2NWIwNmY5N2Q1MTA3MjpiaXNlY3QtbGlu
dXgtNgoKMjAxNC0wOS0yOCAxNzo1MToxNiBhMjVjMWQ4Nzg2YWVlZDc3MTJmZTA0Y2UzZjY1
YjA2Zjk3ZDUxMDcyIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRl
c3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIt
YTI1YzFkODc4NmFlZWQ3NzEyZmUwNGNlM2Y2NWIwNmY5N2Q1MTA3MgpDaGVjayBmb3Iga2Vy
bmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9hMjVjMWQ4Nzg2
YWVlZDc3MTJmZTA0Y2UzZjY1YjA2Zjk3ZDUxMDcyCndhaXRpbmcgZm9yIGNvbXBsZXRpb24g
b2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLWEyNWMxZDg3ODZhZWVkNzcxMmZlMDRjZTNmNjViMDZmOTdkNTEwNzIK
G1sxOzM1bTIwMTQtMDktMjggMTc6NTM6MTYgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWls
ZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi1hMjVj
MWQ4Nzg2YWVlZDc3MTJmZTA0Y2UzZjY1YjA2Zjk3ZDUxMDcyG1swbQpSZXRyeSBidWlsZCAu
Lgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUv
bGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi1hMjVjMWQ4Nzg2
YWVlZDc3MTJmZTA0Y2UzZjY1YjA2Zjk3ZDUxMDcyCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjgxMzAyL2EyNWMxZDg3ODZhZWVkNzcxMmZlMDRjZTNmNjViMDZm
OTdkNTEwNzIvdm1saW51ei0zLjE3LjAtcmM2LTA4NzQwLWdhMjVjMWQ4CgoyMDE0LTA5LTI4
IDE3OjU1OjE2IGRldGVjdGluZyBib290IHN0YXRlIAkyLgkzLgk1CTcJMTAJMTUJMTcuCTE5
LgkyMCBTVUNDRVNTCgpsaW5lYXItYmlzZWN0OiBiYWQgYnJhbmNoIG1heSBiZSBicmFuY2gg
J2FrcG0tY3VycmVudC9jdXJyZW50JwpsaW5lYXItYmlzZWN0OiBoYW5kbGUgb3ZlciB0byBn
aXQgYmlzZWN0CmxpbmVhci1iaXNlY3Q6IGdpdCBiaXNlY3Qgc3RhcnQgZTVkMTlhMWU2NGI3
MTI0NzQ3YmRlODdmZjE1NGJhMWM3YjFiOWJkOCBhMjVjMWQ4Nzg2YWVlZDc3MTJmZTA0Y2Uz
ZjY1YjA2Zjk3ZDUxMDcyIC0tClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIGEyNWMxZDgu
Li4gc3BhcmM6IGlvOiBmaXggZm9yIGFzbS1nZW5lcmljOiBpbzogaW1wbGVtZW50IHJlbGF4
ZWQgYWNjZXNzb3IgbWFjcm9zIGFzIGNvbmRpdGlvbmFsIHdyYXBwZXJzCkhFQUQgaXMgbm93
IGF0IGI0ZDMzMTguLi4gTWVyZ2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAnY3J5cHRvL21h
c3RlcicKQmlzZWN0aW5nOiAxNjYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDcgc3RlcHMpCls1YmUyZTcyNWI5MWQyYjJlNTEyZmY2NmNmYjIzYTIzOTAx
MmRjOTU1XSBtbTogcGFnZV9hbGxvYzogYXZvaWQgd2FrZXVwIGtzd2FwZCBvbiB0aGUgdW5p
bnRlbmRlZCBub2RlCmxpbmVhci1iaXNlY3Q6IGdpdCBiaXNlY3QgcnVuIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgt
Ni9vYmotYmlzZWN0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3Qt
ZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2ti
dWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIv
bmV4dDptYXN0ZXI6NWJlMmU3MjViOTFkMmIyZTUxMmZmNjZjZmIyM2EyMzkwMTJkYzk1NTpi
aXNlY3QtbGludXgtNgoKMjAxNC0wOS0yOCAxODowMzowMyA1YmUyZTcyNWI5MWQyYjJlNTEy
ZmY2NmNmYjIzYTIzOTAxMmRjOTU1IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyODEzMDItNWJlMmU3MjViOTFkMmIyZTUxMmZmNjZjZmIyM2EyMzkwMTJkYzk1NQpDaGVj
ayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi81
YmUyZTcyNWI5MWQyYjJlNTEyZmY2NmNmYjIzYTIzOTAxMmRjOTU1CndhaXRpbmcgZm9yIGNv
bXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjgxMzAyLTViZTJlNzI1YjkxZDJiMmU1MTJmZjY2Y2ZiMjNhMjM5
MDEyZGM5NTUKG1sxOzM1bTIwMTQtMDktMjggMTg6MDc6MDQgTm8gYnVpbGQgc2VydmVkIGZp
bGUgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4
MTMwMi01YmUyZTcyNWI5MWQyYjJlNTEyZmY2NmNmYjIzYTIzOTAxMmRjOTU1G1swbQpSZXRy
eSBidWlsZCAuLgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMw
Mi81YmUyZTcyNWI5MWQyYjJlNTEyZmY2NmNmYjIzYTIzOTAxMmRjOTU1L3ZtbGludXotMy4x
Ny4wLXJjNi0wMDI4Ny1nNWJlMmU3MgoKMjAxNC0wOS0yOCAxODowODowNCBkZXRlY3Rpbmcg
Ym9vdCBzdGF0ZSAuLi4uIFRFU1QgRkFJTFVSRQpbICAgIDAuMTA3NTU5XSBQQ0kgOiBQQ0kg
QklPUyBhcmVhIGlzIHJ3IGFuZCB4LiBVc2UgcGNpPW5vYmlvcyBpZiB5b3Ugd2FudCBpdCBO
WC4KWyAgICAwLjEwODQwMV0gUENJOiBQQ0kgQklPUyByZXZpc2lvbiAyLjEwIGVudHJ5IGF0
IDB4ZmM2ZDUsIGxhc3QgYnVzPTAKWyAgICAwLjEwOTEzMl0gUENJOiBVc2luZyBjb25maWd1
cmF0aW9uIHR5cGUgMSBmb3IgYmFzZSBhY2Nlc3MKWyAgICAwLjE0MDczOF0gQlVHOiB1bmFi
bGUgdG8gaGFuZGxlIGtlcm5lbCBwYWdpbmcgcmVxdWVzdCBhdCAxYjU2ZTNlOApbICAgIDAu
MTQxNTIxXSBJUDogWzxjMTI3YWJlOT5dIGtlcm5mc19hZGRfb25lKzB4MTE5LzB4MjcwClsg
ICAgMC4xNDIxNjFdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMDAw
MDAwMDAwMCAKWyAgICAwLjE0Mjg2Nl0gT29wczogMDAwMiBbIzFdIApbICAgIDAuMTQzMjMy
XSBDUFU6IDAgUElEOiAxIENvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNy4wLXJjNi0w
MDI4Ny1nNWJlMmU3MiAjMQpbICAgIDAuMTQ0MDg5XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBC
b2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAgMC4xNDQ3NTldIHRhc2s6IGMwMDJl
MDEwIHRpOiBjMDAzMDAwMCB0YXNrLnRpOiBjMDAzMDAwMApbICAgIDAuMTQ1MzkxXSBFSVA6
IDAwNjA6WzxjMTI3YWJlOT5dIEVGTEFHUzogMDAwMTAyNDYgQ1BVOiAwClsgICAgMC4xNDYw
MzhdIEVJUCBpcyBhdCBrZXJuZnNfYWRkX29uZSsweDExOS8weDI3MApbICAgIDAuMTQ2NTc1
XSBFQVg6IDU0MjdkZTY1IEVCWDogMWI1NmUzYzggRUNYOiAwMDAwMDAwOCBFRFg6IDFiYTJk
YjYyClsgICAgMC4xNDczMDNdIEVTSTogYzAxMDFlNzAgRURJOiBjMDEwMWVkMCBFQlA6IGMw
MDMxZTU0IEVTUDogYzAwMzFlMzAKWyAgICAwLjE0ODA0MV0gIERTOiAwMDdiIEVTOiAwMDdi
IEZTOiAwMDAwIEdTOiAwMGUwIFNTOiAwMDY4ClsgICAgMC4xNDg2NTddIENSMDogODAwNTAw
M2IgQ1IyOiAxYjU2ZTNlOCBDUjM6IDAyNWUxMDAwIENSNDogMDAwMDA2YjAKWyAgICAwLjE0
OTM5NV0gU3RhY2s6ClsgICAgMC4xNDk2NDFdICBjMTBjY2ZiOSBjMDEwMWVkMCAwMDAwMDIw
MiBjMDEwMWVkMCBjMDAzMWU1NCBjMjQxNjcxYyBjMDEwMWU3MCBjMWQ3NmNjMApbICAgIDAu
MTUwMDAwXSAgYzI0MTY3MWMgYzAwMzFlNmMgYzEyN2QzMjMgMDAwMDAwMDAgYzI0MTY3MTAg
YzAxMDFlZDAgYzFkNzZjYzAgYzAwMzFlYTgKWyAgICAwLjE1MDAwMF0gIGMxMjdlMGJmIDAw
MDAxMDAwIDAwMDAwMDAwIGMxZDc2Y2MwIGMyNDE2NzEwIDAwMDAwMDAwIDAwMDAwMDAxIGMy
NDE2NzFjClsgICAgMC4xNTAwMDBdIENhbGwgVHJhY2U6ClsgICAgMC4xNTAwMDBdICBbPGMx
MGNjZmI5Pl0gPyBsb2NrZGVwX2luaXRfbWFwKzB4MTE5LzB4MzIwClsgICAgMC4xNTAwMDBd
ICBbPGMxMjdkMzIzPl0gX19rZXJuZnNfY3JlYXRlX2ZpbGUrMHgxMDMvMHgxNjAKWyAgICAw
LjE1MDAwMF0gIFs8YzEyN2UwYmY+XSBzeXNmc19hZGRfZmlsZV9tb2RlX25zKzB4MTBmLzB4
MmQwClsgICAgMC4xNTAwMDBdICBbPGMxMjdlMzJkPl0gc3lzZnNfY3JlYXRlX2ZpbGVfbnMr
MHg2ZC8weDkwClsgICAgMC4xNTAwMDBdICBbPGMxNjFkZGFkPl0gZHJpdmVyX2NyZWF0ZV9m
aWxlKzB4MmQvMHg1MApbICAgIDAuMTUwMDAwXSAgWzxjMTYxYWVjYz5dIGJ1c19hZGRfZHJp
dmVyKzB4MjljLzB4NGUwClsgICAgMC4xNTAwMDBdICBbPGMyNTVlNjUzPl0gPyBwY2E5NTN4
X2luaXQrMHgyZC8weDJkClsgICAgMC4xNTAwMDBdICBbPGMyNTVlNjUzPl0gPyBwY2E5NTN4
X2luaXQrMHgyZC8weDJkClsgICAgMC4xNTAwMDBdICBbPGMxNjFlMDRhPl0gZHJpdmVyX3Jl
Z2lzdGVyKzB4Y2EvMHgyMTAKWyAgICAwLjE1MDAwMF0gIFs8YzE0MzM4OTY+XSA/IGt2YXNw
cmludGYrMHg4Ni8weGEwClsgICAgMC4xNTAwMDBdICBbPGMxODAyMGU1Pl0gaTJjX3JlZ2lz
dGVyX2RyaXZlcisweDQ1LzB4MTQwClsgICAgMC4xNTAwMDBdICBbPGMxNDMzOGNmPl0gPyBr
YXNwcmludGYrMHgxZi8weDMwClsgICAgMC4xNTAwMDBdICBbPGMyNTVlNjcwPl0gcGNmODU3
eF9pbml0KzB4MWQvMHgyZApbICAgIDAuMTUwMDAwXSAgWzxjMjUxZjk0ND5dIGRvX29uZV9p
bml0Y2FsbCsweDFmMy8weDMwZQpbICAgIDAuMTUwMDAwXSAgWzxjMjUxZmM4Zj5dIGtlcm5l
bF9pbml0X2ZyZWVhYmxlKzB4MjMwLzB4MzhiClsgICAgMC4xNTAwMDBdICBbPGMxZDMwYWM5
Pl0ga2VybmVsX2luaXQrMHgxOS8weDIzMApbICAgIDAuMTUwMDAwXSAgWzxjMTBhYTEzYT5d
ID8gc2NoZWR1bGVfdGFpbCsweDFhLzB4YTAKWyAgICAwLjE1MDAwMF0gIFs8YzFkNTQwODA+
XSByZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4MjAvMHgzMApbICAgIDAuMTUwMDAwXSAgWzxj
MWQzMGFiMD5dID8gcmVzdF9pbml0KzB4MTgwLzB4MTgwClsgICAgMC4xNTAwMDBdIENvZGU6
IDE1IGU0IDU1IGNkIGMyIDAwIDg1IGRiIDc0IDJkIDgzIDA1IGU4IDU1IGNkIGMyIDAxIDgz
IDE1IGVjIDU1IGNkIGMyIDAwIGU4IDM1IDY1IGU4IGZmIDgzIDA1IGYwIDU1IGNkIGMyIDAx
IDgzIDE1IGY0IDU1IGNkIGMyIDAwIDw4OT4gNDMgMjAgODkgNTMgMjQgODkgNDMgMjggODkg
NTMgMmMgYjggMDAgMDYgMzggYzIgZTggNTEgMzcgYWQKWyAgICAwLjE1MDAwMF0gRUlQOiBb
PGMxMjdhYmU5Pl0ga2VybmZzX2FkZF9vbmUrMHgxMTkvMHgyNzAgU1M6RVNQIDAwNjg6YzAw
MzFlMzAKWyAgICAwLjE1MDAwMF0gQ1IyOiAwMDAwMDAwMDFiNTZlM2U4ClsgICAgMC4xNTAw
MDBdIC0tLVsgZW5kIHRyYWNlIGZjZDEzOWQwY2QxZDc4ZGUgXS0tLQpbICAgIDAuMTUwMDAw
XSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2luZzogRmF0YWwgZXhjZXB0aW9uCi9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi81YmUyZTcyNWI5MWQyYjJlNTEyZmY2NmNm
YjIzYTIzOTAxMmRjOTU1L2RtZXNnLXlvY3RvLXZwLTE5OjIwMTQwOTI4MTgwOTQ3OmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyODEzMDI6My4xNy4wLXJjNi0wMDI4Ny1nNWJlMmU3MjoxCjA6
MToxIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA5LTI4IDE4OjEw
OjA0IFJFUEVBVCBDT1VOVDogMjAgICMgL2MvYm9vdC1iaXNlY3QvbGludXgtNi9vYmotYmlz
ZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDgzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3Qg
YWZ0ZXIgdGhpcyAocm91Z2hseSA2IHN0ZXBzKQpbY2FmMTQ0YmJmZTljY2FiMzU4YWI3ZGQ2
YzY5YTQwOWYzODAwMmE4OV0gcHJvYy9tYXBzOiBtYWtlIHZtX2lzX3N0YWNrKCkgbG9naWMg
bmFtZXNwYWNlLWZyaWVuZGx5CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMg
LWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
ODEzMDIvbmV4dDptYXN0ZXI6Y2FmMTQ0YmJmZTljY2FiMzU4YWI3ZGQ2YzY5YTQwOWYzODAw
MmE4OTpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0yOCAxODoxMDowNSBjYWYxNDRiYmZlOWNj
YWIzNThhYjdkZDZjNjlhNDA5ZjM4MDAyYTg5IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyODEzMDItY2FmMTQ0YmJmZTljY2FiMzU4YWI3ZGQ2YzY5YTQwOWYzODAwMmE4
OQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4
MTMwMi9jYWYxNDRiYmZlOWNjYWIzNThhYjdkZDZjNjlhNDA5ZjM4MDAyYTg5CndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy1z
bW9rZS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLWNhZjE0NGJiZmU5Y2NhYjM1OGFi
N2RkNmM2OWE0MDlmMzgwMDJhODkKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyODEzMDIvY2FmMTQ0YmJmZTljY2FiMzU4YWI3ZGQ2YzY5YTQwOWYzODAwMmE4OS92
bWxpbnV6LTMuMTcuMC1yYzYtMDAyMDMtZ2NhZjE0NGIKCjIwMTQtMDktMjggMTg6MTI6MDUg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4JMQkzLi4JNAk1CTgJOQkxMAkxMQkxNAkxNS4u
Li4uLi4JMTcJMTkJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA0MSByZXZpc2lvbnMgbGVmdCB0
byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVwcykKWzg1MTM5ZDY3OTdlZDExY2Zl
ZmJlN2I5YjQ3ZjgzZjNhMmYyNjg0OGNdIGJsb2NrX2RldjogaW1wbGVtZW50IHJlYWRwYWdl
cygpIHRvIG9wdGltaXplIHNlcXVlbnRpYWwgcmVhZApydW5uaW5nIC9jL2tlcm5lbC10ZXN0
cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgtNi9v
YmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjgxMzAyL25leHQ6bWFzdGVyOjg1MTM5ZDY3OTdlZDExY2ZlZmJlN2I5
YjQ3ZjgzZjNhMmYyNjg0OGM6YmlzZWN0LWxpbnV4LTYKCjIwMTQtMDktMjggMTg6MjU6MzYg
ODUxMzlkNjc5N2VkMTFjZmVmYmU3YjliNDdmODNmM2EyZjI2ODQ4YyBjb21waWxpbmcKUXVl
dWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTg1MTM5ZDY3OTdlZDExY2ZlZmJlN2I5YjQ3
ZjgzZjNhMmYyNjg0OGMKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyODEzMDIvODUxMzlkNjc5N2VkMTFjZmVmYmU3YjliNDdmODNmM2EyZjI2
ODQ4Ywp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi04NTEzOWQ2Nzk3ZWQx
MWNmZWZiZTdiOWI0N2Y4M2YzYTJmMjY4NDhjChtbMTszNW0yMDE0LTA5LTI4IDE4OjM2OjM2
IE5vIGJ1aWxkIHNlcnZlZCBmaWxlIC9rYnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyODEzMDItODUxMzlkNjc5N2VkMTFjZmVmYmU3YjliNDdmODNm
M2EyZjI2ODQ4YxtbMG0KUmV0cnkgYnVpbGQgLi4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyODEzMDItODUxMzlkNjc5N2VkMTFjZmVmYmU3YjliNDdmODNmM2EyZjI2
ODQ4YwprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi84NTEz
OWQ2Nzk3ZWQxMWNmZWZiZTdiOWI0N2Y4M2YzYTJmMjY4NDhjL3ZtbGludXotMy4xNy4wLXJj
Ni0wMDI0NS1nODUxMzlkNgoKMjAxNC0wOS0yOCAxODozODozNiBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuIFRFU1QgRkFJTFVSRQpbICAgIDAuMTczOTE5XSBQQ0kgOiBQQ0kgQklPUyBhcmVh
IGlzIHJ3IGFuZCB4LiBVc2UgcGNpPW5vYmlvcyBpZiB5b3Ugd2FudCBpdCBOWC4KWyAgICAw
LjE3NzAzNF0gUENJOiBQQ0kgQklPUyByZXZpc2lvbiAyLjEwIGVudHJ5IGF0IDB4ZmQ0NTYs
IGxhc3QgYnVzPTAKWyAgICAwLjE4MDAwNl0gUENJOiBVc2luZyBjb25maWd1cmF0aW9uIHR5
cGUgMSBmb3IgYmFzZSBhY2Nlc3MKWyAgICAwLjIwODU3NV0gQlVHOiB1bmFibGUgdG8gaGFu
ZGxlIGtlcm5lbCBwYWdpbmcgcmVxdWVzdCBhdCBhOTlkYWFhMApbICAgIDAuMjEwMDAwXSBJ
UDogWzxjMTI3OWY1OT5dIGtlcm5mc19hZGRfb25lKzB4MTE5LzB4MjcwClsgICAgMC4yMTAw
MDBdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMDAwMDAwMDAwMCAK
WyAgICAwLjIxMDAwMF0gT29wczogMDAwMiBbIzFdIApbICAgIDAuMjEwMDAwXSBDUFU6IDAg
UElEOiAxIENvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNy4wLXJjNi0wMDI0NS1nODUx
MzlkNiAjMQpbICAgIDAuMjEwMDAwXSBIYXJkd2FyZSBuYW1lOiBRRU1VIFN0YW5kYXJkIFBD
IChpNDQwRlggKyBQSUlYLCAxOTk2KSwgQklPUyAxLjcuNS0yMDE0MDUzMV8wODMwMzAtZ2Fu
ZGFsZiAwNC8wMS8yMDE0ClsgICAgMC4yMTAwMDBdIHRhc2s6IGMwMDJlMDEwIHRpOiBjMDAz
MDAwMCB0YXNrLnRpOiBjMDAzMDAwMApbICAgIDAuMjEwMDAwXSBFSVA6IDAwNjA6WzxjMTI3
OWY1OT5dIEVGTEFHUzogMDAwMTAyNDYgQ1BVOiAwClsgICAgMC4yMTAwMDBdIEVJUCBpcyBh
dCBrZXJuZnNfYWRkX29uZSsweDExOS8weDI3MApbICAgIDAuMjEwMDAwXSBFQVg6IDU0Mjdl
NTBjIEVCWDogYTk5ZGFhODAgRUNYOiAwMDAwMDAwOCBFRFg6IDFiNGVkMjgzClsgICAgMC4y
MTAwMDBdIEVTSTogYzAxMDFlNzAgRURJOiBjMDEwMWVkMCBFQlA6IGMwMDMxZTU0IEVTUDog
YzAwMzFlMzAKWyAgICAwLjIxMDAwMF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMDAwIEdT
OiAwMGUwIFNTOiAwMDY4ClsgICAgMC4yMTAwMDBdIENSMDogODAwNTAwM2IgQ1IyOiBhOTlk
YWFhMCBDUjM6IDAyNWRmMDAwIENSNDogMDAwMDA2YjAKWyAgICAwLjIxMDAwMF0gU3RhY2s6
ClsgICAgMC4yMTAwMDBdICBjMTBjYzdkOSBjMDEwMWVkMCAwMDAwMDIwMiBjMDEwMWVkMCBj
MDAzMWU1NCBjMjQxNDY1YyBjMDEwMWU3MCBjMWQ3NWJjMApbICAgIDAuMjEwMDAwXSAgYzI0
MTQ2NWMgYzAwMzFlNmMgYzEyN2M2OTMgMDAwMDAwMDAgYzI0MTQ2NTAgYzAxMDFlZDAgYzFk
NzViYzAgYzAwMzFlYTgKWyAgICAwLjIxMDAwMF0gIGMxMjdkNDJmIDAwMDAxMDAwIDAwMDAw
MDAwIGMxZDc1YmMwIGMyNDE0NjUwIDAwMDAwMDAwIDAwMDAwMDAxIGMyNDE0NjVjClsgICAg
MC4yMTAwMDBdIENhbGwgVHJhY2U6ClsgICAgMC4yMTAwMDBdICBbPGMxMGNjN2Q5Pl0gPyBs
b2NrZGVwX2luaXRfbWFwKzB4MTE5LzB4MzIwClsgICAgMC4yMTAwMDBdICBbPGMxMjdjNjkz
Pl0gX19rZXJuZnNfY3JlYXRlX2ZpbGUrMHgxMDMvMHgxNjAKWyAgICAwLjIxMDAwMF0gIFs8
YzEyN2Q0MmY+XSBzeXNmc19hZGRfZmlsZV9tb2RlX25zKzB4MTBmLzB4MmQwClsgICAgMC4y
MTAwMDBdICBbPGMxMjdkNjlkPl0gc3lzZnNfY3JlYXRlX2ZpbGVfbnMrMHg2ZC8weDkwClsg
ICAgMC4yMTAwMDBdICBbPGMxNjFkMTFkPl0gZHJpdmVyX2NyZWF0ZV9maWxlKzB4MmQvMHg1
MApbICAgIDAuMjEwMDAwXSAgWzxjMTYxYTIzYz5dIGJ1c19hZGRfZHJpdmVyKzB4MjljLzB4
NGUwClsgICAgMC4yMTAwMDBdICBbPGMyNTVjNjUzPl0gPyBwY2E5NTN4X2luaXQrMHgyZC8w
eDJkClsgICAgMC4yMTAwMDBdICBbPGMyNTVjNjUzPl0gPyBwY2E5NTN4X2luaXQrMHgyZC8w
eDJkClsgICAgMC4yMTAwMDBdICBbPGMxNjFkM2JhPl0gZHJpdmVyX3JlZ2lzdGVyKzB4Y2Ev
MHgyMTAKWyAgICAwLjIxMDAwMF0gIFs8YzE0MzJjMDY+XSA/IGt2YXNwcmludGYrMHg4Ni8w
eGEwClsgICAgMC4yMTAwMDBdICBbPGMxODAxNDU1Pl0gaTJjX3JlZ2lzdGVyX2RyaXZlcisw
eDQ1LzB4MTQwClsgICAgMC4yMTAwMDBdICBbPGMxNDMyYzNmPl0gPyBrYXNwcmludGYrMHgx
Zi8weDMwClsgICAgMC4yMTAwMDBdICBbPGMyNTVjNjcwPl0gcGNmODU3eF9pbml0KzB4MWQv
MHgyZApbICAgIDAuMjEwMDAwXSAgWzxjMjUxZDk0ND5dIGRvX29uZV9pbml0Y2FsbCsweDFm
My8weDMwZQpbICAgIDAuMjEwMDAwXSAgWzxjMjUxZGM4Zj5dIGtlcm5lbF9pbml0X2ZyZWVh
YmxlKzB4MjMwLzB4MzhiClsgICAgMC4yMTAwMDBdICBbPGMxZDJmZTM5Pl0ga2VybmVsX2lu
aXQrMHgxOS8weDIzMApbICAgIDAuMjEwMDAwXSAgWzxjMTBhOTk1YT5dID8gc2NoZWR1bGVf
dGFpbCsweDFhLzB4YTAKWyAgICAwLjIxMDAwMF0gIFs8YzFkNTM0MDA+XSByZXRfZnJvbV9r
ZXJuZWxfdGhyZWFkKzB4MjAvMHgzMApbICAgIDAuMjEwMDAwXSAgWzxjMWQyZmUyMD5dID8g
cmVzdF9pbml0KzB4MTgwLzB4MTgwClsgICAgMC4yMTAwMDBdIENvZGU6IDE1IDI0IDMyIGNk
IGMyIDAwIDg1IGRiIDc0IDJkIDgzIDA1IDI4IDMyIGNkIGMyIDAxIDgzIDE1IDJjIDMyIGNk
IGMyIDAwIGU4IGU1IDY5IGU4IGZmIDgzIDA1IDMwIDMyIGNkIGMyIDAxIDgzIDE1IDM0IDMy
IGNkIGMyIDAwIDw4OT4gNDMgMjAgODkgNTMgMjQgODkgNDMgMjggODkgNTMgMmMgYjggNDAg
ZTUgMzcgYzIgZTggNTEgMzcgYWQKWyAgICAwLjIxMDAwMF0gRUlQOiBbPGMxMjc5ZjU5Pl0g
a2VybmZzX2FkZF9vbmUrMHgxMTkvMHgyNzAgU1M6RVNQIDAwNjg6YzAwMzFlMzAKWyAgICAw
LjIxMDAwMF0gQ1IyOiAwMDAwMDAwMGE5OWRhYWEwClsgICAgMC4yMTAwMDBdIC0tLVsgZW5k
IHRyYWNlIGY1NDIwOWE4YTVlM2U3YTYgXS0tLQpbICAgIDAuMjEwMDAwXSBLZXJuZWwgcGFu
aWMgLSBub3Qgc3luY2luZzogRmF0YWwgZXhjZXB0aW9uCi9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTI4MTMwMi84NTEzOWQ2Nzk3ZWQxMWNmZWZiZTdiOWI0N2Y4M2YzYTJmMjY4
NDhjL2RtZXNnLXF1YW50YWwtaXZiNDEtMTIyOjIwMTQwOTI4MTgzODA5OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyODEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDIvODUxMzlkNjc5N2VkMTFjZmVmYmU3YjliNDdmODNmM2EyZjI2ODQ4Yy9kbWVzZy15b2N0
by1rYnVpbGQtMjY6MjAxNDA5MjgxODM1MjE6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMw
MjozLjE3LjAtcmM2LTAwMjQ1LWc4NTEzOWQ2OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLzg1MTM5ZDY3OTdlZDExY2ZlZmJlN2I5YjQ3ZjgzZjNhMmYyNjg0OGMv
ZG1lc2cteW9jdG8taXZiNDEtMTk6MjAxNDA5MjgxODM4Mjk6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTI4MTMwMjo6CjA6MzozIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0y
MDE0LTA5LTI4IDE4OjM5OjA3IFJFUEVBVCBDT1VOVDogMjAgICMgL2MvYm9vdC1iaXNlY3Qv
bGludXgtNi9vYmotYmlzZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDIwIHJldmlzaW9u
cyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbZWY1NzgzZTFh
YTIwYzdkNDBlZDk1MmRmZTlhY2U4ZjFmMWEyZTkyNV0gbW0vbW1hcC5jOiB3aGl0ZXNwYWNl
IGZpeGVzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDpt
YXN0ZXI6ZWY1NzgzZTFhYTIwYzdkNDBlZDk1MmRmZTlhY2U4ZjFmMWEyZTkyNTpiaXNlY3Qt
bGludXgtNgoKMjAxNC0wOS0yOCAxODozOTowNyBlZjU3ODNlMWFhMjBjN2Q0MGVkOTUyZGZl
OWFjZThmMWYxYTJlOTI1IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDItZWY1NzgzZTFhYTIwYzdkNDBlZDk1MmRmZTlhY2U4ZjFmMWEyZTkyNQpDaGVjayBmb3Ig
a2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9lZjU3ODNl
MWFhMjBjN2Q0MGVkOTUyZGZlOWFjZThmMWYxYTJlOTI1CndhaXRpbmcgZm9yIGNvbXBsZXRp
b24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjgxMzAyLWVmNTc4M2UxYWEyMGM3ZDQwZWQ5NTJkZmU5YWNlOGYxZjFhMmU5
MjUKG1sxOzM1bTIwMTQtMDktMjggMTg6NDI6MDcgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2ti
dWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi1l
ZjU3ODNlMWFhMjBjN2Q0MGVkOTUyZGZlOWFjZThmMWYxYTJlOTI1G1swbQpSZXRyeSBidWls
ZCAuLgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9lZjU3
ODNlMWFhMjBjN2Q0MGVkOTUyZGZlOWFjZThmMWYxYTJlOTI1L3ZtbGludXotMy4xNy4wLXJj
Ni0wMDIyNC1nZWY1NzgzZQoKMjAxNC0wOS0yOCAxODo0MzowNyBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuIFRFU1QgRkFJTFVSRQpbICAgIDAuMDc4NzMxXSBQQ0kgOiBQQ0kgQklPUyBhcmVh
IGlzIHJ3IGFuZCB4LiBVc2UgcGNpPW5vYmlvcyBpZiB5b3Ugd2FudCBpdCBOWC4KWyAgICAw
LjA4MDAxOV0gUENJOiBQQ0kgQklPUyByZXZpc2lvbiAyLjEwIGVudHJ5IGF0IDB4ZmM2ZDUs
IGxhc3QgYnVzPTAKWyAgICAwLjA4MTE5Nl0gUENJOiBVc2luZyBjb25maWd1cmF0aW9uIHR5
cGUgMSBmb3IgYmFzZSBhY2Nlc3MKWyAgICAwLjA5ODE2MV0gQlVHOiB1bmFibGUgdG8gaGFu
ZGxlIGtlcm5lbCBwYWdpbmcgcmVxdWVzdCBhdCAyYTYzNmFjMApbICAgIDAuMDk5NDIxXSBJ
UDogWzxjMTI3YTAyOT5dIGtlcm5mc19hZGRfb25lKzB4MTE5LzB4MjcwClsgICAgMC4xMDAw
MDBdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMDAwMDAwMDAwMCAK
WyAgICAwLjEwMDAwMF0gT29wczogMDAwMiBbIzFdIApbICAgIDAuMTAwMDAwXSBDUFU6IDAg
UElEOiAxIENvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNy4wLXJjNi0wMDIyNC1nZWY1
NzgzZSAjMgpbICAgIDAuMTAwMDAwXSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklP
UyBCb2NocyAwMS8wMS8yMDExClsgICAgMC4xMDAwMDBdIHRhc2s6IGMwMDJlMDEwIHRpOiBj
MDAzMDAwMCB0YXNrLnRpOiBjMDAzMDAwMApbICAgIDAuMTAwMDAwXSBFSVA6IDAwNjA6Wzxj
MTI3YTAyOT5dIEVGTEFHUzogMDAwMTAyNDYgQ1BVOiAwClsgICAgMC4xMDAwMDBdIEVJUCBp
cyBhdCBrZXJuZnNfYWRkX29uZSsweDExOS8weDI3MApbICAgIDAuMTAwMDAwXSBFQVg6IDU0
MjdlNjE3IEVCWDogMmE2MzZhYTAgRUNYOiAwMDAwMDAwOCBFRFg6IDE0MmIzODU3ClsgICAg
MC4xMDAwMDBdIEVTSTogYzAxMDFlNzAgRURJOiBjMDEwMWVkMCBFQlA6IGMwMDMxZTU0IEVT
UDogYzAwMzFlMzAKWyAgICAwLjEwMDAwMF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMDAw
IEdTOiAwMGUwIFNTOiAwMDY4ClsgICAgMC4xMDAwMDBdIENSMDogODAwNTAwM2IgQ1IyOiAy
YTYzNmFjMCBDUjM6IDAyNWRmMDAwIENSNDogMDAwMDA2YjAKWyAgICAwLjEwMDAwMF0gU3Rh
Y2s6ClsgICAgMC4xMDAwMDBdICBjMTBjYzdkOSBjMDEwMWVkMCAwMDAwMDIwMiBjMDEwMWVk
MCBjMDAzMWU1NCBjMjQxNDYxYyBjMDEwMWU3MCBjMWQ3NWJjMApbICAgIDAuMTAwMDAwXSAg
YzI0MTQ2MWMgYzAwMzFlNmMgYzEyN2M3NjMgMDAwMDAwMDAgYzI0MTQ2MTAgYzAxMDFlZDAg
YzFkNzViYzAgYzAwMzFlYTgKWyAgICAwLjEwMDAwMF0gIGMxMjdkNGZmIDAwMDAxMDAwIDAw
MDAwMDAwIGMxZDc1YmMwIGMyNDE0NjEwIDAwMDAwMDAwIDAwMDAwMDAxIGMyNDE0NjFjClsg
ICAgMC4xMDAwMDBdIENhbGwgVHJhY2U6ClsgICAgMC4xMDAwMDBdICBbPGMxMGNjN2Q5Pl0g
PyBsb2NrZGVwX2luaXRfbWFwKzB4MTE5LzB4MzIwClsgICAgMC4xMDAwMDBdICBbPGMxMjdj
NzYzPl0gX19rZXJuZnNfY3JlYXRlX2ZpbGUrMHgxMDMvMHgxNjAKWyAgICAwLjEwMDAwMF0g
IFs8YzEyN2Q0ZmY+XSBzeXNmc19hZGRfZmlsZV9tb2RlX25zKzB4MTBmLzB4MmQwClsgICAg
MC4xMDAwMDBdICBbPGMxMjdkNzZkPl0gc3lzZnNfY3JlYXRlX2ZpbGVfbnMrMHg2ZC8weDkw
ClsgICAgMC4xMDAwMDBdICBbPGMxNjFkMDJkPl0gZHJpdmVyX2NyZWF0ZV9maWxlKzB4MmQv
MHg1MApbICAgIDAuMTAwMDAwXSAgWzxjMTYxYTE0Yz5dIGJ1c19hZGRfZHJpdmVyKzB4Mjlj
LzB4NGUwClsgICAgMC4xMDAwMDBdICBbPGMyNTVjNGRmPl0gPyBwY2E5NTN4X2luaXQrMHgy
ZC8weDJkClsgICAgMC4xMDAwMDBdICBbPGMyNTVjNGRmPl0gPyBwY2E5NTN4X2luaXQrMHgy
ZC8weDJkClsgICAgMC4xMDAwMDBdICBbPGMxNjFkMmNhPl0gZHJpdmVyX3JlZ2lzdGVyKzB4
Y2EvMHgyMTAKWyAgICAwLjEwMDAwMF0gIFs8YzE0MzJjZDY+XSA/IGt2YXNwcmludGYrMHg4
Ni8weGEwClsgICAgMC4xMDAwMDBdICBbPGMxODAxMDA1Pl0gaTJjX3JlZ2lzdGVyX2RyaXZl
cisweDQ1LzB4MTQwClsgICAgMC4xMDAwMDBdICBbPGMxNDMyZDBmPl0gPyBrYXNwcmludGYr
MHgxZi8weDMwClsgICAgMC4xMDAwMDBdICBbPGMyNTVjNGZjPl0gcGNmODU3eF9pbml0KzB4
MWQvMHgyZApbICAgIDAuMTAwMDAwXSAgWzxjMjUxZDk0ND5dIGRvX29uZV9pbml0Y2FsbCsw
eDFmMy8weDMwZQpbICAgIDAuMTAwMDAwXSAgWzxjMjUxZGM4Zj5dIGtlcm5lbF9pbml0X2Zy
ZWVhYmxlKzB4MjMwLzB4MzhiClsgICAgMC4xMDAwMDBdICBbPGMxZDJmOWU5Pl0ga2VybmVs
X2luaXQrMHgxOS8weDIzMApbICAgIDAuMTAwMDAwXSAgWzxjMTBhOTk1YT5dID8gc2NoZWR1
bGVfdGFpbCsweDFhLzB4YTAKWyAgICAwLjEwMDAwMF0gIFs8YzFkNTJmYzA+XSByZXRfZnJv
bV9rZXJuZWxfdGhyZWFkKzB4MjAvMHgzMApbICAgIDAuMTAwMDAwXSAgWzxjMWQyZjlkMD5d
ID8gcmVzdF9pbml0KzB4MTgwLzB4MTgwClsgICAgMC4xMDAwMDBdIENvZGU6IDE1IDI0IDMy
IGNkIGMyIDAwIDg1IGRiIDc0IDJkIDgzIDA1IDI4IDMyIGNkIGMyIDAxIDgzIDE1IDJjIDMy
IGNkIGMyIDAwIGU4IDE1IDY5IGU4IGZmIDgzIDA1IDMwIDMyIGNkIGMyIDAxIDgzIDE1IDM0
IDMyIGNkIGMyIDAwIDw4OT4gNDMgMjAgODkgNTMgMjQgODkgNDMgMjggODkgNTMgMmMgYjgg
NDAgZTUgMzcgYzIgZTggMzEgMzIgYWQKWyAgICAwLjEwMDAwMF0gRUlQOiBbPGMxMjdhMDI5
Pl0ga2VybmZzX2FkZF9vbmUrMHgxMTkvMHgyNzAgU1M6RVNQIDAwNjg6YzAwMzFlMzAKWyAg
ICAwLjEwMDAwMF0gQ1IyOiAwMDAwMDAwMDJhNjM2YWMwClsgICAgMC4xMDAwMDBdIC0tLVsg
ZW5kIHRyYWNlIDFlNDU1MDg5OGViN2NjZTEgXS0tLQpbICAgIDAuMTAwMDAwXSBLZXJuZWwg
cGFuaWMgLSBub3Qgc3luY2luZzogRmF0YWwgZXhjZXB0aW9uCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTI4MTMwMi9lZjU3ODNlMWFhMjBjN2Q0MGVkOTUyZGZlOWFjZThmMWYx
YTJlOTI1L2RtZXNnLXF1YW50YWwtdnAtMToyMDE0MDkyODE4NDIzNzppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjgxMzAyOjMuMTcuMC1yYzYtMDAyMjQtZ2VmNTc4M2U6MgowOjE6MSBhbGxf
Z29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wOS0yOCAxODo0MzozOCBSRVBF
QVQgQ09VTlQ6IDIwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTYvb2JqLWJpc2VjdC8ucmVw
ZWF0G1swbQoKQmlzZWN0aW5nOiAxMCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRo
aXMgKHJvdWdobHkgMyBzdGVwcykKWzEwNjAzMzQxNWYyMzA2YzE4OGZjMzk5Mzk4Mzg1NmZm
MWI2MTczMGRdIG1tL3NsYWI6IG5vaW5saW5lIF9fYWNfcHV0X29iaigpCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2Vj
dC9saW51eC02L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6MTA2MDMzNDE1ZjIz
MDZjMTg4ZmMzOTkzOTgzODU2ZmYxYjYxNzMwZDpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0y
OCAxODo0MzozOSAxMDYwMzM0MTVmMjMwNmMxODhmYzM5OTM5ODM4NTZmZjFiNjE3MzBkIGNv
bXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVl
L2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItMTA2MDMzNDE1ZjIzMDZj
MTg4ZmMzOTkzOTgzODU2ZmYxYjYxNzMwZApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi8xMDYwMzM0MTVmMjMwNmMxODhmYzM5OTM5
ODM4NTZmZjFiNjE3MzBkCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0
cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTEw
NjAzMzQxNWYyMzA2YzE4OGZjMzk5Mzk4Mzg1NmZmMWI2MTczMGQKG1sxOzM1bTIwMTQtMDkt
MjggMTg6NDU6MzkgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWlsZC10ZXN0cy9idWlsZC1z
ZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi0xMDYwMzM0MTVmMjMwNmMxODhm
YzM5OTM5ODM4NTZmZjFiNjE3MzBkG1swbQpSZXRyeSBidWlsZCAuLgprZXJuZWw6IC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi8xMDYwMzM0MTVmMjMwNmMxODhmYzM5
OTM5ODM4NTZmZjFiNjE3MzBkL3ZtbGludXotMy4xNy4wLXJjNi0wMDIxMy1nMTA2MDMzNAoK
MjAxNC0wOS0yOCAxODo0NjozOSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMQkyCTMJNC4J
NS4uLgk4Li4JOS4JMTAJMTEJMTIuCTEzLgkxNS4uCTE3Li4uCTE4LgkxOS4JMjAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiA1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSAzIHN0ZXBzKQpbN2JlZWZkMDI5NzhlMDc3ZWRlZWU2YmNhMDExZWQzMzU3Y2I4OGFi
NF0ga2VybmVsL2t0aHJlYWQuYzogcGFydGlhbCByZXZlcnQgb2YgODFjOTg4NjlmYWE1ICgi
a3RocmVhZDogZW5zdXJlIGxvY2FsaXR5IG9mIHRhc2tfc3RydWN0IGFsbG9jYXRpb25zIikK
cnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9j
L2Jvb3QtYmlzZWN0L2xpbnV4LTYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1
bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi9uZXh0Om1hc3Rlcjo3
YmVlZmQwMjk3OGUwNzdlZGVlZTZiY2EwMTFlZDMzNTdjYjg4YWI0OmJpc2VjdC1saW51eC02
CgoyMDE0LTA5LTI4IDE5OjA0OjEzIDdiZWVmZDAyOTc4ZTA3N2VkZWVlNmJjYTAxMWVkMzM1
N2NiODhhYjQgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi03YmVl
ZmQwMjk3OGUwNzdlZGVlZTZiY2EwMTFlZDMzNTdjYjg4YWI0CkNoZWNrIGZvciBrZXJuZWwg
aW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzdiZWVmZDAyOTc4ZTA3
N2VkZWVlNmJjYTAxMWVkMzM1N2NiODhhYjQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyODEzMDItN2JlZWZkMDI5NzhlMDc3ZWRlZWU2YmNhMDExZWQzMzU3Y2I4OGFiNAobWzE7
MzVtMjAxNC0wOS0yOCAxOTowODoxMyBObyBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1aWxkLXRl
c3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTdiZWVmZDAy
OTc4ZTA3N2VkZWVlNmJjYTAxMWVkMzM1N2NiODhhYjQbWzBtClJldHJ5IGJ1aWxkIC4uCndh
aXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3At
aWIwMy1zbW9rZS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLTdiZWVmZDAyOTc4ZTA3
N2VkZWVlNmJjYTAxMWVkMzM1N2NiODhhYjQKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyODEzMDIvN2JlZWZkMDI5NzhlMDc3ZWRlZWU2YmNhMDExZWQzMzU3Y2I4
OGFiNC92bWxpbnV6LTMuMTcuMC1yYzYtMDAyMTgtZzdiZWVmZDAKCjIwMTQtMDktMjggMTk6
MTU6MTMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkzLi4JNgk3Lgk4CTkuCTExCTEyLgkxMy4J
MTQJMTUJMTYJMTkJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyIHJldmlzaW9ucyBsZWZ0IHRv
IHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbZjQ5ZTQzM2I2NmY1ZDZhMGEw
ZmVlZjYwYzBkOTg0ZGFjY2RjZTJjNF0gbW0vc2xhYl9jb21tb246IGZpeCBidWlsZCBmYWls
dXJlIGlmIENPTkZJR19TTFVCCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC02L29iai1iaXNlY3QKbHMg
LWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
ODEzMDIvbmV4dDptYXN0ZXI6ZjQ5ZTQzM2I2NmY1ZDZhMGEwZmVlZjYwYzBkOTg0ZGFjY2Rj
ZTJjNDpiaXNlY3QtbGludXgtNgoKMjAxNC0wOS0yOCAxOToyNToxNCBmNDllNDMzYjY2ZjVk
NmEwYTBmZWVmNjBjMGQ5ODRkYWNjZGNlMmM0IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyODEzMDItZjQ5ZTQzM2I2NmY1ZDZhMGEwZmVlZjYwYzBkOTg0ZGFjY2RjZTJj
NApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4
MTMwMi9mNDllNDMzYjY2ZjVkNmEwYTBmZWVmNjBjMGQ5ODRkYWNjZGNlMmM0CndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLWY0OWU0MzNiNjZmNWQ2YTBhMGZlZWY2MGMw
ZDk4NGRhY2NkY2UyYzQKG1sxOzM1bTIwMTQtMDktMjggMTk6MzI6MTQgTm8gYnVpbGQgc2Vy
dmVkIGZpbGUgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTI4MTMwMi1mNDllNDMzYjY2ZjVkNmEwYTBmZWVmNjBjMGQ5ODRkYWNjZGNlMmM0G1sw
bQpSZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4
MTMwMi1mNDllNDMzYjY2ZjVkNmEwYTBmZWVmNjBjMGQ5ODRkYWNjZGNlMmM0Cmtlcm5lbDog
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL2Y0OWU0MzNiNjZmNWQ2YTBh
MGZlZWY2MGMwZDk4NGRhY2NkY2UyYzQvdm1saW51ei0zLjE3LjAtcmM2LTAwMjIxLWdmNDll
NDMzCgoyMDE0LTA5LTI4IDE5OjM1OjE0IGRldGVjdGluZyBib290IHN0YXRlIC4uLi4JMS4u
CTMuCTQJOAk5CTExCTE0CTE2LgkxNwkxOQkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDAgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEgc3RlcCkKWzk5Nzg4
ODQ4OGVmOTJkYTM2NWI4NzAyNDdkZTc3MzI1NTIyN2NlMWZdIG1tL3NsYWI6IHVzZSBwZXJj
cHUgYWxsb2NhdG9yIGZvciBjcHUgY2FjaGUKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlz
ZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTYvb2JqLWJp
c2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmln
LWliMS0wOTI4MTMwMi9uZXh0Om1hc3Rlcjo5OTc4ODg0ODhlZjkyZGEzNjViODcwMjQ3ZGU3
NzMyNTUyMjdjZTFmOmJpc2VjdC1saW51eC02CgoyMDE0LTA5LTI4IDE5OjQ0OjQ1IDk5Nzg4
ODQ4OGVmOTJkYTM2NWI4NzAyNDdkZTc3MzI1NTIyN2NlMWYgY29tcGlsaW5nClF1ZXVlZCBi
dWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTI4MTMwMi05OTc4ODg0ODhlZjkyZGEzNjViODcwMjQ3ZGU3NzMy
NTUyMjdjZTFmCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLzk5Nzg4ODQ4OGVmOTJkYTM2NWI4NzAyNDdkZTc3MzI1NTIyN2NlMWYK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xr
cC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDItOTk3ODg4NDg4ZWY5MmRhMzY1
Yjg3MDI0N2RlNzczMjU1MjI3Y2UxZgobWzE7MzVtMjAxNC0wOS0yOCAxOTo0Njo0NSBObyBi
dWlsZCBzZXJ2ZWQgZmlsZSAva2J1aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjgxMzAyLTk5Nzg4ODQ4OGVmOTJkYTM2NWI4NzAyNDdkZTc3MzI1NTIy
N2NlMWYbWzBtClJldHJ5IGJ1aWxkIC4uCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjgxMzAyLzk5Nzg4ODQ4OGVmOTJkYTM2NWI4NzAyNDdkZTc3MzI1NTIyN2Nl
MWYvdm1saW51ei0zLjE3LjAtcmM2LTAwMjIzLWc5OTc4ODg0CgoyMDE0LTA5LTI4IDE5OjQ3
OjQ1IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlMVVJFClsgICAgMC4yMDI3ODBd
IFBDSSA6IFBDSSBCSU9TIGFyZWEgaXMgcncgYW5kIHguIFVzZSBwY2k9bm9iaW9zIGlmIHlv
dSB3YW50IGl0IE5YLgpbICAgIDAuMjA2NTc3XSBQQ0k6IFBDSSBCSU9TIHJldmlzaW9uIDIu
MTAgZW50cnkgYXQgMHhmYzZkNSwgbGFzdCBidXM9MApbICAgIDAuMjA3NjA1XSBQQ0k6IFVz
aW5nIGNvbmZpZ3VyYXRpb24gdHlwZSAxIGZvciBiYXNlIGFjY2VzcwpbICAgIDAuMjMwMTAy
XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDJhNjM2
YWMwClsgICAgMC4yMzE0NDRdIElQOiBbPGMxMjdhMDI5Pl0ga2VybmZzX2FkZF9vbmUrMHgx
MTkvMHgyNzAKWyAgICAwLjIzMjEzNF0gKnBkcHQgPSAwMDAwMDAwMDAwMDAwMDAwICpwZGUg
PSAwMDAwMDAwMDAwMDAwMDAwIApbICAgIDAuMjMzMTgyXSBPb3BzOiAwMDAyIFsjMV0gClsg
ICAgMC4yMzM4OTNdIENQVTogMCBQSUQ6IDEgQ29tbTogc3dhcHBlciBOb3QgdGFpbnRlZCAz
LjE3LjAtcmM2LTAwMjIzLWc5OTc4ODg0ICMxClsgICAgMC4yMzUwOTRdIEhhcmR3YXJlIG5h
bWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgICAwLjIzNjA5OF0g
dGFzazogYzAwMmUwMTAgdGk6IGMwMDMwMDAwIHRhc2sudGk6IGMwMDMwMDAwClsgICAgMC4y
MzcwNDZdIEVJUDogMDA2MDpbPGMxMjdhMDI5Pl0gRUZMQUdTOiAwMDAxMDI0NiBDUFU6IDAK
WyAgICAwLjIzNzk5MF0gRUlQIGlzIGF0IGtlcm5mc19hZGRfb25lKzB4MTE5LzB4MjcwClsg
ICAgMC4yMzg4NjRdIEVBWDogNTQyN2Y1NDQgRUJYOiAyYTYzNmFhMCBFQ1g6IDAwMDAwMDA4
IEVEWDogMjc3ZTUxYjUKWyAgICAwLjIzOTkwOF0gRVNJOiBjMDEwMWU3MCBFREk6IGMwMTAx
ZWQwIEVCUDogYzAwMzFlNTQgRVNQOiBjMDAzMWUzMApbICAgIDAuMjQwMDAwXSAgRFM6IDAw
N2IgRVM6IDAwN2IgRlM6IDAwMDAgR1M6IDAwZTAgU1M6IDAwNjgKWyAgICAwLjI0MDAwMF0g
Q1IwOiA4MDA1MDAzYiBDUjI6IDJhNjM2YWMwIENSMzogMDI1ZGYwMDAgQ1I0OiAwMDAwMDZi
MApbICAgIDAuMjQwMDAwXSBTdGFjazoKWyAgICAwLjI0MDAwMF0gIGMxMGNjN2Q5IGMwMTAx
ZWQwIDAwMDAwMjAyIGMwMTAxZWQwIGMwMDMxZTU0IGMyNDE0NjFjIGMwMTAxZTcwIGMxZDc1
YmMwClsgICAgMC4yNDAwMDBdICBjMjQxNDYxYyBjMDAzMWU2YyBjMTI3Yzc2MyAwMDAwMDAw
MCBjMjQxNDYxMCBjMDEwMWVkMCBjMWQ3NWJjMCBjMDAzMWVhOApbICAgIDAuMjQwMDAwXSAg
YzEyN2Q0ZmYgMDAwMDEwMDAgMDAwMDAwMDAgYzFkNzViYzAgYzI0MTQ2MTAgMDAwMDAwMDAg
MDAwMDAwMDEgYzI0MTQ2MWMKWyAgICAwLjI0MDAwMF0gQ2FsbCBUcmFjZToKWyAgICAwLjI0
MDAwMF0gIFs8YzEwY2M3ZDk+XSA/IGxvY2tkZXBfaW5pdF9tYXArMHgxMTkvMHgzMjAKWyAg
ICAwLjI0MDAwMF0gIFs8YzEyN2M3NjM+XSBfX2tlcm5mc19jcmVhdGVfZmlsZSsweDEwMy8w
eDE2MApbICAgIDAuMjQwMDAwXSAgWzxjMTI3ZDRmZj5dIHN5c2ZzX2FkZF9maWxlX21vZGVf
bnMrMHgxMGYvMHgyZDAKWyAgICAwLjI0MDAwMF0gIFs8YzEyN2Q3NmQ+XSBzeXNmc19jcmVh
dGVfZmlsZV9ucysweDZkLzB4OTAKWyAgICAwLjI0MDAwMF0gIFs8YzE2MWQwMmQ+XSBkcml2
ZXJfY3JlYXRlX2ZpbGUrMHgyZC8weDUwClsgICAgMC4yNDAwMDBdICBbPGMxNjFhMTRjPl0g
YnVzX2FkZF9kcml2ZXIrMHgyOWMvMHg0ZTAKWyAgICAwLjI0MDAwMF0gIFs8YzI1NWM0ZGY+
XSA/IHBjYTk1M3hfaW5pdCsweDJkLzB4MmQKWyAgICAwLjI0MDAwMF0gIFs8YzI1NWM0ZGY+
XSA/IHBjYTk1M3hfaW5pdCsweDJkLzB4MmQKWyAgICAwLjI0MDAwMF0gIFs8YzE2MWQyY2E+
XSBkcml2ZXJfcmVnaXN0ZXIrMHhjYS8weDIxMApbICAgIDAuMjQwMDAwXSAgWzxjMTQzMmNk
Nj5dID8ga3Zhc3ByaW50ZisweDg2LzB4YTAKWyAgICAwLjI0MDAwMF0gIFs8YzE4MDEwMDU+
XSBpMmNfcmVnaXN0ZXJfZHJpdmVyKzB4NDUvMHgxNDAKWyAgICAwLjI0MDAwMF0gIFs8YzE0
MzJkMGY+XSA/IGthc3ByaW50ZisweDFmLzB4MzAKWyAgICAwLjI0MDAwMF0gIFs8YzI1NWM0
ZmM+XSBwY2Y4NTd4X2luaXQrMHgxZC8weDJkClsgICAgMC4yNDAwMDBdICBbPGMyNTFkOTQ0
Pl0gZG9fb25lX2luaXRjYWxsKzB4MWYzLzB4MzBlClsgICAgMC4yNDAwMDBdICBbPGMyNTFk
YzhmPl0ga2VybmVsX2luaXRfZnJlZWFibGUrMHgyMzAvMHgzOGIKWyAgICAwLjI0MDAwMF0g
IFs8YzFkMmY5ZTk+XSBrZXJuZWxfaW5pdCsweDE5LzB4MjMwClsgICAgMC4yNDAwMDBdICBb
PGMxMGE5OTVhPl0gPyBzY2hlZHVsZV90YWlsKzB4MWEvMHhhMApbICAgIDAuMjQwMDAwXSAg
WzxjMWQ1MmZjMD5dIHJldF9mcm9tX2tlcm5lbF90aHJlYWQrMHgyMC8weDMwClsgICAgMC4y
NDAwMDBdICBbPGMxZDJmOWQwPl0gPyByZXN0X2luaXQrMHgxODAvMHgxODAKWyAgICAwLjI0
MDAwMF0gQ29kZTogMTUgMjQgMzIgY2QgYzIgMDAgODUgZGIgNzQgMmQgODMgMDUgMjggMzIg
Y2QgYzIgMDEgODMgMTUgMmMgMzIgY2QgYzIgMDAgZTggMTUgNjkgZTggZmYgODMgMDUgMzAg
MzIgY2QgYzIgMDEgODMgMTUgMzQgMzIgY2QgYzIgMDAgPDg5PiA0MyAyMCA4OSA1MyAyNCA4
OSA0MyAyOCA4OSA1MyAyYyBiOCA0MCBlNSAzNyBjMiBlOCAzMSAzMiBhZApbICAgIDAuMjQw
MDAwXSBFSVA6IFs8YzEyN2EwMjk+XSBrZXJuZnNfYWRkX29uZSsweDExOS8weDI3MCBTUzpF
U1AgMDA2ODpjMDAzMWUzMApbICAgIDAuMjQwMDAwXSBDUjI6IDAwMDAwMDAwMmE2MzZhYzAK
WyAgICAwLjI0MDAwMF0gLS0tWyBlbmQgdHJhY2UgY2Y0ZmMzMmM4ZTFjYTYyNSBdLS0tClsg
ICAgMC4yNDAwMDBdIEtlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5nOiBGYXRhbCBleGNlcHRp
b24KL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzk5Nzg4ODQ4OGVmOTJk
YTM2NWI4NzAyNDdkZTc3MzI1NTIyN2NlMWYvZG1lc2cteW9jdG8tdnAtMTk6MjAxNDA5Mjgx
OTQ3MjM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMjozLjE3LjAtcmM2LTAwMjIzLWc5
OTc4ODg0OjEKMDoxOjEgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQt
MDktMjggMTk6NDg6MTggUkVQRUFUIENPVU5UOiAyMCAgIyAvYy9ib290LWJpc2VjdC9saW51
eC02L29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMCByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMCBzdGVwcykKWzhkODU5MGQ1MWUyYjE2
OWYzMjdhNzRjMDMyMzMzMzY4ZjdmOTdmOTddIG1tL3NsYWI6IHN1cHBvcnQgc2xhYiBtZXJn
ZQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2gg
L2MvYm9vdC1iaXNlY3QvbGludXgtNi9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMv
cnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL25leHQ6bWFzdGVy
OjhkODU5MGQ1MWUyYjE2OWYzMjdhNzRjMDMyMzMzMzY4ZjdmOTdmOTc6YmlzZWN0LWxpbnV4
LTYKCjIwMTQtMDktMjggMTk6NDg6MjAgOGQ4NTkwZDUxZTJiMTY5ZjMyN2E3NGMwMzIzMzMz
NjhmN2Y5N2Y5NyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0
cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLThk
ODU5MGQ1MWUyYjE2OWYzMjdhNzRjMDMyMzMzMzY4ZjdmOTdmOTcKQ2hlY2sgZm9yIGtlcm5l
bCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvOGQ4NTkwZDUxZTJi
MTY5ZjMyN2E3NGMwMzIzMzMzNjhmN2Y5N2Y5Nwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9m
IC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTI4MTMwMi04ZDg1OTBkNTFlMmIxNjlmMzI3YTc0YzAzMjMzMzM2OGY3Zjk3
Zjk3Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzhkODU5
MGQ1MWUyYjE2OWYzMjdhNzRjMDMyMzMzMzY4ZjdmOTdmOTcvdm1saW51ei0zLjE3LjAtcmM2
LTAwMjIyLWc4ZDg1OTBkCgoyMDE0LTA5LTI4IDE5OjUwOjIxIGRldGVjdGluZyBib290IHN0
YXRlIC4gVEVTVCBGQUlMVVJFClsgICAgMC4wNDA1NjhdIE1vdW50LWNhY2hlIGhhc2ggdGFi
bGUgZW50cmllczogMTAyNCAob3JkZXI6IDAsIDQwOTYgYnl0ZXMpClsgICAgMC4wNDE5MjJd
IE1vdW50cG9pbnQtY2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVzOiAxMDI0IChvcmRlcjogMCwg
NDA5NiBieXRlcykKWyAgICAwLjA0NDk1NF0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0t
LS0tLS0tLS0tClsgICAgMC4wNDczNDVdIFdBUk5JTkc6IENQVTogMCBQSUQ6IDAgYXQgYXJj
aC94ODYva2VybmVsL2NwdS9jb21tb24uYzoxNDMwIHdhcm5fcHJlX2FsdGVybmF0aXZlcysw
eDMwLzB4NDAoKQpbICAgIDAuMDUwMDAwXSBZb3UncmUgdXNpbmcgc3RhdGljX2NwdV9oYXMg
YmVmb3JlIGFsdGVybmF0aXZlcyBoYXZlIHJ1biEKWyAgICAwLjA1MDAwMF0gQ1BVOiAwIFBJ
RDogMCBDb21tOiBzd2FwcGVyIE5vdCB0YWludGVkIDMuMTcuMC1yYzYtMDAyMjItZzhkODU5
MGQgIzIKWyAgICAwLjA1MDAwMF0gSGFyZHdhcmUgbmFtZTogUUVNVSBTdGFuZGFyZCBQQyAo
aTQ0MEZYICsgUElJWCwgMTk5NiksIEJJT1MgMS43LjUtMjAxNDA1MzFfMDgzMDMwLWdhbmRh
bGYgMDQvMDEvMjAxNApbICAgIDAuMDUwMDAwXSAgYzIxMDIyZjggYzIxY2RkNjQgYzFkM2M5
OGMgYzIxY2RkOTggYzEwNzA2MzYgYzIxMDIzNDggYzIxY2RkYzQgMDAwMDAwMDAKWyAgICAw
LjA1MDAwMF0gIGMyMTAyMmY4IDAwMDAwNTk2IGMxMDIwODMwIDAwMDAwNTk2IGMxMDIwODMw
IDQzYTgxNjIxIGMyMWNkZTZjIGMxMDU3ZjIwClsgICAgMC4wNTAwMDBdICBjMjFjZGRiMCBj
MTA3MDcyYSAwMDAwMDAwOSBjMjFjZGRhOCBjMjEwMjM0OCBjMjFjZGRjNCBjMjFjZGRjNCBj
MTAyMDgzMApbICAgIDAuMDUwMDAwXSBDYWxsIFRyYWNlOgpbICAgIDAuMDUwMDAwXSAgWzxj
MWQzYzk4Yz5dIGR1bXBfc3RhY2srMHg0MC8weDVlClsgICAgMC4wNTAwMDBdICBbPGMxMDcw
NjM2Pl0gd2Fybl9zbG93cGF0aF9jb21tb24rMHhiNi8weDEwMApbICAgIDAuMDUwMDAwXSAg
WzxjMTAyMDgzMD5dID8gd2Fybl9wcmVfYWx0ZXJuYXRpdmVzKzB4MzAvMHg0MApbICAgIDAu
MDUwMDAwXSAgWzxjMTAyMDgzMD5dID8gd2Fybl9wcmVfYWx0ZXJuYXRpdmVzKzB4MzAvMHg0
MApbICAgIDAuMDUwMDAwXSAgWzxjMTA1N2YyMD5dID8ga3ZtX3JlYWRfYW5kX3Jlc2V0X3Bm
X3JlYXNvbisweDQwLzB4NDAKWyAgICAwLjA1MDAwMF0gIFs8YzEwNzA3MmE+XSB3YXJuX3Ns
b3dwYXRoX2ZtdCsweDRhLzB4NjAKWyAgICAwLjA1MDAwMF0gIFs8YzEwMjA4MzA+XSB3YXJu
X3ByZV9hbHRlcm5hdGl2ZXMrMHgzMC8weDQwClsgICAgMC4wNTAwMDBdICBbPGMxMDVkOGEz
Pl0gX19kb19wYWdlX2ZhdWx0KzB4MTUzLzB4YTgwClsgICAgMC4wNTAwMDBdICBbPGMxMDU4
NzNmPl0gPyBrdm1fY2xvY2tfcmVhZCsweDJmLzB4NjAKWyAgICAwLjA1MDAwMF0gIFs8YzEw
MTAwNjc+XSA/IHNjaGVkX2Nsb2NrKzB4MTcvMHgzMApbICAgIDAuMDUwMDAwXSAgWzxjMTA1
N2YyMD5dID8ga3ZtX3JlYWRfYW5kX3Jlc2V0X3BmX3JlYXNvbisweDQwLzB4NDAKWyAgICAw
LjA1MDAwMF0gIFs8YzEwNWU1ZDY+XSBkb19wYWdlX2ZhdWx0KzB4MzYvMHg1MApbICAgIDAu
MDUwMDAwXSAgWzxjMTA1N2Y0MD5dIGRvX2FzeW5jX3BhZ2VfZmF1bHQrMHgyMC8weGYwClsg
ICAgMC4wNTAwMDBdICBbPGMxZDUzYjNkPl0gZXJyb3JfY29kZSsweDY1LzB4NmMKWyAgICAw
LjA1MDAwMF0gIFs8YzEyNzAwMDA+XSA/IHByb2NfcGlkX3N0YXR1cysweDYyMC8weGZmMApb
ICAgIDAuMDUwMDAwXSAgWzxjMTI3YTEzOT5dID8ga2VybmZzX2FkZF9vbmUrMHgxMTkvMHgy
NzAKWyAgICAwLjA1MDAwMF0gIFs8YzEyNzliYjc+XSA/IGtlcm5mc19uZXdfbm9kZSsweDY3
LzB4OTAKWyAgICAwLjA1MDAwMF0gIFs8YzEyN2EyZmE+XSBrZXJuZnNfY3JlYXRlX2Rpcl9u
cysweDZhLzB4YzAKWyAgICAwLjA1MDAwMF0gIFs8YzEyN2UwMzY+XSBzeXNmc19jcmVhdGVf
ZGlyX25zKzB4NTYvMHgxMjAKWyAgICAwLjA1MDAwMF0gIFs8YzE0MTk4NmE+XSBrb2JqZWN0
X2FkZF9pbnRlcm5hbCsweDIwYS8weDg3MApbICAgIDAuMDUwMDAwXSAgWzxjMTQzMmRlNj5d
ID8ga3Zhc3ByaW50ZisweDg2LzB4YTAKWyAgICAwLjA1MDAwMF0gIFs8YzE0MWExNTM+XSBr
b2JqZWN0X2FkZF92YXJnKzB4NDMvMHg5MApbICAgIDAuMDUwMDAwXSAgWzxjMTQxYTI0MD5d
IGtvYmplY3RfYWRkKzB4NDAvMHhiMApbICAgIDAuMDUwMDAwXSAgWzxjMTQxOTJmNT5dID8g
a29iamVjdF9jcmVhdGUrMHhmNS8weDExMApbICAgIDAuMDUwMDAwXSAgWzxjMTQxYTMwYT5d
IGtvYmplY3RfY3JlYXRlX2FuZF9hZGQrMHg1YS8weGQwClsgICAgMC4wNTAwMDBdICBbPGMy
NTUxYmM5Pl0gbW50X2luaXQrMHgxZTQvMHgzODAKWyAgICAwLjA1MDAwMF0gIFs8YzI1NTEx
YjU+XSA/IGZpbGVzX2luaXQrMHgyYy8weDdjClsgICAgMC4wNTAwMDBdICBbPGMyNTUxNTZm
Pl0gdmZzX2NhY2hlc19pbml0KzB4ZTIvMHgxYjMKWyAgICAwLjA1MDAwMF0gIFs8YzI1NTg1
ZGU+XSA/IGludGVncml0eV9paW50Y2FjaGVfaW5pdCsweDJjLzB4NGQKWyAgICAwLjA1MDAw
MF0gIFs8YzEzZDBiOTA+XSA/IGRldmNncm91cF9pbm9kZV9ta25vZCsweDkwLzB4OTAKWyAg
ICAwLjA1MDAwMF0gIFs8YzI1MWQ2YTM+XSBzdGFydF9rZXJuZWwrMHg4Y2YvMHg5N2QKWyAg
ICAwLjA1MDAwMF0gIFs8YzI1MWMzM2I+XSBpMzg2X3N0YXJ0X2tlcm5lbCsweGU5LzB4ZmIK
WyAgICAwLjA1MDAwMF0gLS0tWyBlbmQgdHJhY2UgYmNlODg4N2E5ZWUwZTA3OSBdLS0tClsg
ICAgMC4wNTAwMDBdIEJVRzogdW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVl
c3QgYXQgNDNhODE2MjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzhk
ODU5MGQ1MWUyYjE2OWYzMjdhNzRjMDMyMzMzMzY4ZjdmOTdmOTcvZG1lc2cteW9jdG8taXZi
NDEtMTA3OjIwMTQwOTI4MTk1MDA5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDI6Ogow
OjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wOS0yOCAxOTo1
MDo1MSBSRVBFQVQgQ09VTlQ6IDIwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTYvb2JqLWJp
c2VjdC8ucmVwZWF0G1swbQoKOGQ4NTkwZDUxZTJiMTY5ZjMyN2E3NGMwMzIzMzMzNjhmN2Y5
N2Y5NyBpcyB0aGUgZmlyc3QgYmFkIGNvbW1pdApjb21taXQgOGQ4NTkwZDUxZTJiMTY5ZjMy
N2E3NGMwMzIzMzMzNjhmN2Y5N2Y5NwpBdXRob3I6IEpvb25zb28gS2ltIDxpYW1qb29uc29v
LmtpbUBsZ2UuY29tPgpEYXRlOiAgIEZyaSBTZXAgMjYgMTA6MTg6NTYgMjAxNCArMTAwMAoK
ICAgIG1tL3NsYWI6IHN1cHBvcnQgc2xhYiBtZXJnZQogICAgCiAgICBTbGFiIG1lcmdlIGlz
IGdvb2QgZmVhdHVyZSB0byByZWR1Y2UgZnJhZ21lbnRhdGlvbi4gIElmIG5ldyBjcmVhdGlu
ZyBzbGFiCiAgICBoYXZlIHNpbWlsYXIgc2l6ZSBhbmQgcHJvcGVydHkgd2l0aCBleHNpdGVu
dCBzbGFiLCB0aGlzIGZlYXR1cmUgcmV1c2UgaXQKICAgIHJhdGhlciB0aGFuIGNyZWF0aW5n
IG5ldyBvbmUuICBBcyBhIHJlc3VsdCwgb2JqZWN0cyBhcmUgcGFja2VkIGludG8gZmV3ZXIK
ICAgIHNsYWJzIHNvIHRoYXQgZnJhZ21lbnRhdGlvbiBpcyByZWR1Y2VkLgogICAgCiAgICBC
ZWxvdyBpcyByZXN1bHQgb2YgbXkgdGVzdGluZy4KICAgIAogICAgKiBBZnRlciBib290LCBz
bGVlcCAyMDsgY2F0IC9wcm9jL21lbWluZm8gfCBncmVwIFNsYWIKICAgIAogICAgPEJlZm9y
ZT4KICAgIFNsYWI6IDI1MTM2IGtCCiAgICAKICAgIDxBZnRlcj4KICAgIFNsYWI6IDI0MzY0
IGtCCiAgICAKICAgIFdlIGNhbiBzYXZlIDMlIG1lbW9yeSB1c2VkIGJ5IHNsYWIuCiAgICAK
ICAgIEZvciBzdXBwb3J0aW5nIHRoaXMgZmVhdHVyZSBpbiBTTEFCLCB3ZSBuZWVkIHRvIGlt
cGxlbWVudCBTTEFCIHNwZWNpZmljCiAgICBrbWVtX2NhY2hlX2ZsYWcoKSBhbmQgX19rbWVt
X2NhY2hlX2FsaWFzKCksIGJlY2F1c2UgU0xVQiBpbXBsZW1lbnRzIHNvbWUKICAgIFNMVUIg
c3BlY2lmaWMgcHJvY2Vzc2luZyByZWxhdGVkIHRvIGRlYnVnIGZsYWcgYW5kIG9iamVjdCBz
aXplIGNoYW5nZSBvbgogICAgdGhlc2UgZnVuY3Rpb25zLgogICAgCiAgICBTaWduZWQtb2Zm
LWJ5OiBKb29uc29vIEtpbSA8aWFtam9vbnNvby5raW1AbGdlLmNvbT4KICAgIENjOiBDaHJp
c3RvcGggTGFtZXRlciA8Y2xAbGludXguY29tPgogICAgQ2M6IFBla2thIEVuYmVyZyA8cGVu
YmVyZ0BrZXJuZWwub3JnPgogICAgQ2M6IERhdmlkIFJpZW50amVzIDxyaWVudGplc0Bnb29n
bGUuY29tPgogICAgU2lnbmVkLW9mZi1ieTogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1m
b3VuZGF0aW9uLm9yZz4KCjowNDAwMDAgMDQwMDAwIDU0NWMxZDYzNGZmZTY3MmFmMDM3MWYx
YzYxNDBjZjQ0OWNhMDEyYTQgNjMzZjAwNWRhNDA2Yzc1YzRlODVhODYzNWQ3YTI1N2VmNDVj
Njk0MiBNCW1tCmJpc2VjdCBydW4gc3VjY2VzcwpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdh
cyA4ZDg1OTBkLi4uIG1tL3NsYWI6IHN1cHBvcnQgc2xhYiBtZXJnZQpIRUFEIGlzIG5vdyBh
dCBmNDllNDMzLi4uIG1tL3NsYWJfY29tbW9uOiBmaXggYnVpbGQgZmFpbHVyZSBpZiBDT05G
SUdfU0xVQgpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTI4MTMwMi9uZXh0Om1hc3RlcjpmNDllNDMzYjY2ZjVkNmEwYTBmZWVmNjBj
MGQ5ODRkYWNjZGNlMmM0OmJpc2VjdC1saW51eC02CgoyMDE0LTA5LTI4IDE5OjUwOjU0IGY0
OWU0MzNiNjZmNWQ2YTBhMGZlZWY2MGMwZDk4NGRhY2NkY2UyYzQgcmV1c2UgL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL2Y0OWU0MzNiNjZmNWQ2YTBhMGZlZWY2MGMw
ZDk4NGRhY2NkY2UyYzQvdm1saW51ei0zLjE3LjAtcmM2LTAwMjIxLWdmNDllNDMzCgoyMDE0
LTA5LTI4IDE5OjUwOjU0IGRldGVjdGluZyBib290IHN0YXRlIC4JMjIuCTI0CTI1CTI3Li4u
Li4uCTI5Li4JMzAJMzEJMzIuCTM1CTM3CTM4CTM5CTQxCTQyCTQzCTQ1Li4uLi4JNDYJNDcu
Li4uLi4uLi4uLgk0OS4uLi4uCTUwLi4uLi4JNTIJNTMuLgk1NS4uCTU2Li4JNTguCTU5Li4J
NjAgU1VDQ0VTUwoKUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgZjQ5ZTQzMy4uLiBtbS9z
bGFiX2NvbW1vbjogZml4IGJ1aWxkIGZhaWx1cmUgaWYgQ09ORklHX1NMVUIKSEVBRCBpcyBu
b3cgYXQgNGQ4NDI2Zi4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAx
NDA5MjYKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6NGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQw
NTFkMDJiOWM5ZmUwMTpiaXNlY3QtbGludXgtNgogVEVTVCBGQUlMVVJFClsgICAgMC4xNjM4
NjRdIFBDSSA6IFBDSSBCSU9TIGFyZWEgaXMgcncgYW5kIHguIFVzZSBwY2k9bm9iaW9zIGlm
IHlvdSB3YW50IGl0IE5YLgpbICAgIDAuMTY1Mzk3XSBQQ0k6IFBDSSBCSU9TIHJldmlzaW9u
IDIuMTAgZW50cnkgYXQgMHhmZDQ1NiwgbGFzdCBidXM9MApbICAgIDAuMTY2NzA5XSBQQ0k6
IFVzaW5nIGNvbmZpZ3VyYXRpb24gdHlwZSAxIGZvciBiYXNlIGFjY2VzcwpbICAgIDAuMTc5
NDk5XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDU1
M2E1ZjAxClsgICAgMC4xODAwMDBdIElQOiBbPGMxMjdlNzA3Pl0ga2VybmZzX3B1dCsweGQ3
LzB4M2EwClsgICAgMC4xODAwMDBdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0g
MDAwMDAwMDAwMDAwMDAwMCAKWyAgICAwLjE4MDAwMF0gT29wczogMDAwMCBbIzFdIApbICAg
IDAuMTgwMDAwXSBDUFU6IDAgUElEOiAxIENvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4x
Ny4wLXJjNi1uZXh0LTIwMTQwOTI2ICM0ClsgICAgMC4xODAwMDBdIEhhcmR3YXJlIG5hbWU6
IFFFTVUgU3RhbmRhcmQgUEMgKGk0NDBGWCArIFBJSVgsIDE5OTYpLCBCSU9TIDEuNy41LTIw
MTQwNTMxXzA4MzAzMC1nYW5kYWxmIDA0LzAxLzIwMTQKWyAgICAwLjE4MDAwMF0gdGFzazog
YzAwMmUwMTAgdGk6IGMwMDMwMDAwIHRhc2sudGk6IGMwMDMwMDAwClsgICAgMC4xODAwMDBd
IEVJUDogMDA2MDpbPGMxMjdlNzA3Pl0gRUZMQUdTOiAwMDAxMDIwMiBDUFU6IDAKWyAgICAw
LjE4MDAwMF0gRUlQIGlzIGF0IGtlcm5mc19wdXQrMHhkNy8weDNhMApbICAgIDAuMTgwMDAw
XSBFQVg6IDU1M2E1ZWNkIEVCWDogYzAxMDBmOTAgRUNYOiAwMDAwMDAwMSBFRFg6IDAwMDAw
MDAyClsgICAgMC4xODAwMDBdIEVTSTogYzAxMDBmOTAgRURJOiAwMDAwMDAwMCBFQlA6IGMw
MDMxZTE4IEVTUDogYzAwMzFkZTQKWyAgICAwLjE4MDAwMF0gIERTOiAwMDdiIEVTOiAwMDdi
IEZTOiAwMDAwIEdTOiAwMGUwIFNTOiAwMDY4ClsgICAgMC4xODAwMDBdIENSMDogODAwNTAw
M2IgQ1IyOiA1NTNhNWYwMSBDUjM6IDAyNWY1MDAwIENSNDogMDAwMDA2YjAKWyAgICAwLjE4
MDAwMF0gU3RhY2s6ClsgICAgMC4xODAwMDBdICAwMDAwMDAwMSAwMDAwMDAwMCBjMTI3ZjU5
NSAwMDAwMDI0NiAwMDAwMDAwMCBjMjM4ZTg4MCBjMDA5MWYwMCBjMDA5MWYwOApbICAgIDAu
MTgwMDAwXSAgYzAxMDBmOTggYzAwN2UwMzAgYzAxMDBmOTAgYzAxMDBmOTAgMDAwMDAwMDAg
YzAwMzFlNTQgYzEyN2YzMjUgMDAwMDAwMDAKWyAgICAwLjE4MDAwMF0gIDAwMDAwMDAxIDAw
MDAwMDAwIGMxMjgwNTBmIGMwMTAwZjk4IGMyMzhlODgwIGMxZDU2ZTQ2IDAwMDAwMDQ2IGMx
ZTFiODRkClsgICAgMC4xODAwMDBdIENhbGwgVHJhY2U6ClsgICAgMC4xODAwMDBdICBbPGMx
MjdmNTk1Pl0gPyBfX2tlcm5mc19yZW1vdmUrMHgzNjUvMHg2NzAKWyAgICAwLjE4MDAwMF0g
IFs8YzEyN2YzMjU+XSBfX2tlcm5mc19yZW1vdmUrMHhmNS8weDY3MApbICAgIDAuMTgwMDAw
XSAgWzxjMTI4MDUwZj5dID8ga2VybmZzX3JlbW92ZV9ieV9uYW1lX25zKzB4NmYvMHgxMjAK
WyAgICAwLjE4MDAwMF0gIFs8YzFkNTZlNDY+XSA/IG11dGV4X3VubG9jaysweDE2LzB4MzAK
WyAgICAwLjE4MDAwMF0gIFs8YzEyODA1MGY+XSBrZXJuZnNfcmVtb3ZlX2J5X25hbWVfbnMr
MHg2Zi8weDEyMApbICAgIDAuMTgwMDAwXSAgWzxjMTI4NDc5MT5dIHJlbW92ZV9maWxlcy5p
c3JhLjErMHg1MS8weGMwClsgICAgMC4xODAwMDBdICBbPGMxMjg0ZGQ2Pl0gc3lzZnNfcmVt
b3ZlX2dyb3VwKzB4NTYvMHgxNDAKWyAgICAwLjE4MDAwMF0gIFs8YzI1NTNmNTA+XSA/IGxv
Y2F0ZV9tb2R1bGVfa29iamVjdCsweDIyLzB4MWNkClsgICAgMC4xODAwMDBdICBbPGMyNTU0
MzQwPl0gcGFyYW1fc3lzZnNfaW5pdCsweDI0NS8weDUxMQpbICAgIDAuMTgwMDAwXSAgWzxj
MTQzOTdjNj5dID8ga3Zhc3ByaW50ZisweDg2LzB4YTAKWyAgICAwLjE4MDAwMF0gIFs8YzI1
NTQwZmI+XSA/IGxvY2F0ZV9tb2R1bGVfa29iamVjdCsweDFjZC8weDFjZApbICAgIDAuMTgw
MDAwXSAgWzxjMjUyZjk1Yz5dIGRvX29uZV9pbml0Y2FsbCsweDFmMy8weDMwZQpbICAgIDAu
MTgwMDAwXSAgWzxjMjUyZmNhNz5dIGtlcm5lbF9pbml0X2ZyZWVhYmxlKzB4MjMwLzB4Mzhi
ClsgICAgMC4xODAwMDBdICBbPGMxZDM5NTM5Pl0ga2VybmVsX2luaXQrMHgxOS8weDIzMApb
ICAgIDAuMTgwMDAwXSAgWzxjMTBhYmI5YT5dID8gc2NoZWR1bGVfdGFpbCsweDFhLzB4YTAK
WyAgICAwLjE4MDAwMF0gIFs8YzFkNWNiODA+XSByZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4
MjAvMHgzMApbICAgIDAuMTgwMDAwXSAgWzxjMWQzOTUyMD5dID8gcmVzdF9pbml0KzB4MTgw
LzB4MTgwClsgICAgMC4xODAwMDBdIENvZGU6IDAxIDAwIDAwIDkwIDBmIGI3IDQ2IDU0IDg5
IGMyIDgzIGUyIDBmIDY2IDgzIGZhIDA0IDBmIDg0IDVkIDAyIDAwIDAwIGY2IGM0IDAyIDBm
IDg0IDBjIDAyIDAwIDAwIDhiIDQ2IDVjIDg1IGMwIDBmIDg0IDMwIDAyIDAwIDAwIDw4Yj4g
NDggMzQgODMgMDUgMzggYWQgY2UgYzIgMDEgODMgMTUgM2MgYWQgY2UgYzIgMDAgODUgYzkg
NzQgMjkKWyAgICAwLjE4MDAwMF0gRUlQOiBbPGMxMjdlNzA3Pl0ga2VybmZzX3B1dCsweGQ3
LzB4M2EwIFNTOkVTUCAwMDY4OmMwMDMxZGU0ClsgICAgMC4xODAwMDBdIENSMjogMDAwMDAw
MDA1NTNhNWYwMQpbICAgIDAuMTgwMDAwXSAtLS1bIGVuZCB0cmFjZSBhZDIyOWE3NDk0YTM1
MTVkIF0tLS0KWyAgICAwLjE4MDAwMF0gS2VybmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZh
dGFsIGV4Y2VwdGlvbgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvNGQ4
NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy1xdWFudGFsLWxr
cC1uZXgwNC03MToyMDE0MDkyODE1MTk0MDppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAy
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFk
YjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8taXZiNDEtNTU6MjAxNDA5
MjgxNTE5MTk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMjo6Ci9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTI4MTMwMi80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQw
MmI5YzlmZTAxL2RtZXNnLXlvY3RvLXZwLTEzOjIwMTQwOTI4MTUxOTA3OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyODEzMDI6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTI2OjQKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0
MDUxZDAyYjljOWZlMDEvZG1lc2ctcXVhbnRhbC1pdmI0MS0yNToyMDE0MDkyODE1MTkyMjpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEv
ZG1lc2cteW9jdG8tdnAtOToyMDE0MDkyODEzMDgwNzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjgxMzAyOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyNjo0Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTI4MTMwMi80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5Yzlm
ZTAxL2RtZXNnLXF1YW50YWwtbGtwLW5leDA0LTE3NToyMDE0MDkyODE1MTk0MTppMzg2LXJh
bmRjb25maWctaWIxLTA5MjgxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjgxMzAyLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2ct
eW9jdG8tbGtwLW5leDA0LTk1OjIwMTQwOTI4MTUxOTE1OmkzODYtcmFuZGNvbmZpZy1pYjEt
MDkyODEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvNGQ4NDI2
ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by12cC00MToy
MDE0MDkyODE1MTkxOTppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjMuMTcuMC1yYzYt
bmV4dC0yMDE0MDkyNjo0Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80
ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXF1YW50YWwt
bGtwLW5leDA0LTE3OjIwMTQwOTI4MTUxOTQzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEz
MDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvNGQ4NDI2ZjlhYzYw
MWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy1xdWFudGFsLWxrcC1uZXgwNC0x
NzE6MjAxNDA5MjgxNTE5MjQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMjo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3
YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC03NDoyMDE0MDkyODE1
MTkzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjoKMDoxMToxMSBhbGxfZ29vZDpi
YWQ6YWxsX2JhZCBib290cwoKSEVBRCBpcyBub3cgYXQgNGQ4NDI2ZiBBZGQgbGludXgtbmV4
dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA5MjYKCj09PT09PT09PSBsaW51cy9tYXN0ZXIg
PT09PT09PT09Ck5vdGU6IGNoZWNraW5nIG91dCAnbGludXMvbWFzdGVyJy4KCllvdSBhcmUg
aW4gJ2RldGFjaGVkIEhFQUQnIHN0YXRlLiBZb3UgY2FuIGxvb2sgYXJvdW5kLCBtYWtlIGV4
cGVyaW1lbnRhbApjaGFuZ2VzIGFuZCBjb21taXQgdGhlbSwgYW5kIHlvdSBjYW4gZGlzY2Fy
ZCBhbnkgY29tbWl0cyB5b3UgbWFrZSBpbiB0aGlzCnN0YXRlIHdpdGhvdXQgaW1wYWN0aW5n
IGFueSBicmFuY2hlcyBieSBwZXJmb3JtaW5nIGFub3RoZXIgY2hlY2tvdXQuCgpJZiB5b3Ug
d2FudCB0byBjcmVhdGUgYSBuZXcgYnJhbmNoIHRvIHJldGFpbiBjb21taXRzIHlvdSBjcmVh
dGUsIHlvdSBtYXkKZG8gc28gKG5vdyBvciBsYXRlcikgYnkgdXNpbmcgLWIgd2l0aCB0aGUg
Y2hlY2tvdXQgY29tbWFuZCBhZ2Fpbi4gRXhhbXBsZToKCiAgZ2l0IGNoZWNrb3V0IC1iIG5l
d19icmFuY2hfbmFtZQoKSEVBRCBpcyBub3cgYXQgMWUzODI3Yi4uLiBNZXJnZSBicmFuY2gg
J2Zvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJu
ZWwvZ2l0L3Zpcm8vdmZzCmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjgxMzAyL2xpbnVzOm1hc3RlcjoxZTM4MjdiZjhhZWJlMjlh
ZjJkNmU0OWI4OWQ4NWRmYWU0ZDAxNTRmOmJpc2VjdC1saW51eC02CgoyMDE0LTA5LTI4IDIw
OjI3OjM0IDFlMzgyN2JmOGFlYmUyOWFmMmQ2ZTQ5Yjg5ZDg1ZGZhZTRkMDE1NGYgY29tcGls
aW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtw
LWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi0xZTM4MjdiZjhhZWJlMjlhZjJk
NmU0OWI4OWQ4NWRmYWU0ZDAxNTRmCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzFlMzgyN2JmOGFlYmUyOWFmMmQ2ZTQ5Yjg5ZDg1
ZGZhZTRkMDE1NGYKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIt
MWUzODI3YmY4YWViZTI5YWYyZDZlNDliODlkODVkZmFlNGQwMTU0ZgprZXJuZWw6IC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi8xZTM4MjdiZjhhZWJlMjlhZjJkNmU0
OWI4OWQ4NWRmYWU0ZDAxNTRmL3ZtbGludXotMy4xNy4wLXJjNi0wMDIwNy1nMWUzODI3YgoK
MjAxNC0wOS0yOCAyMDozMDozNCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAJMQkyLgkzLgk1CTcJ
OAkxMC4JMTIJMTYJMTgJMjAuCTI2CTI5CTMzCTM1CTM3CTM5CTQxLgk0Mi4JNDUJNDcJNTAu
CTUxCTU2CTU4CTU5Lgk2MCBTVUNDRVNTCgoKPT09PT09PT09IG5leHQvbWFzdGVyID09PT09
PT09PQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyAxZTM4MjdiLi4uIE1lcmdlIGJyYW5j
aCAnZm9yLWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tl
cm5lbC9naXQvdmlyby92ZnMKSEVBRCBpcyBub3cgYXQgNGQ4NDI2Zi4uLiBBZGQgbGludXgt
bmV4dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA5MjYKbHMgLWEgL2tidWlsZC10ZXN0cy9y
dW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvbmV4dDptYXN0ZXI6
NGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMTpiaXNlY3QtbGludXgt
NgogVEVTVCBGQUlMVVJFClsgICAgMC4xNjM4NjRdIFBDSSA6IFBDSSBCSU9TIGFyZWEgaXMg
cncgYW5kIHguIFVzZSBwY2k9bm9iaW9zIGlmIHlvdSB3YW50IGl0IE5YLgpbICAgIDAuMTY1
Mzk3XSBQQ0k6IFBDSSBCSU9TIHJldmlzaW9uIDIuMTAgZW50cnkgYXQgMHhmZDQ1NiwgbGFz
dCBidXM9MApbICAgIDAuMTY2NzA5XSBQQ0k6IFVzaW5nIGNvbmZpZ3VyYXRpb24gdHlwZSAx
IGZvciBiYXNlIGFjY2VzcwpbICAgIDAuMTc5NDk5XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUg
a2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDU1M2E1ZjAxClsgICAgMC4xODAwMDBdIElQOiBb
PGMxMjdlNzA3Pl0ga2VybmZzX3B1dCsweGQ3LzB4M2EwClsgICAgMC4xODAwMDBdICpwZHB0
ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMDAwMDAwMDAwMCAKWyAgICAwLjE4
MDAwMF0gT29wczogMDAwMCBbIzFdIApbICAgIDAuMTgwMDAwXSBDUFU6IDAgUElEOiAxIENv
bW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNy4wLXJjNi1uZXh0LTIwMTQwOTI2ICM0Clsg
ICAgMC4xODAwMDBdIEhhcmR3YXJlIG5hbWU6IFFFTVUgU3RhbmRhcmQgUEMgKGk0NDBGWCAr
IFBJSVgsIDE5OTYpLCBCSU9TIDEuNy41LTIwMTQwNTMxXzA4MzAzMC1nYW5kYWxmIDA0LzAx
LzIwMTQKWyAgICAwLjE4MDAwMF0gdGFzazogYzAwMmUwMTAgdGk6IGMwMDMwMDAwIHRhc2su
dGk6IGMwMDMwMDAwClsgICAgMC4xODAwMDBdIEVJUDogMDA2MDpbPGMxMjdlNzA3Pl0gRUZM
QUdTOiAwMDAxMDIwMiBDUFU6IDAKWyAgICAwLjE4MDAwMF0gRUlQIGlzIGF0IGtlcm5mc19w
dXQrMHhkNy8weDNhMApbICAgIDAuMTgwMDAwXSBFQVg6IDU1M2E1ZWNkIEVCWDogYzAxMDBm
OTAgRUNYOiAwMDAwMDAwMSBFRFg6IDAwMDAwMDAyClsgICAgMC4xODAwMDBdIEVTSTogYzAx
MDBmOTAgRURJOiAwMDAwMDAwMCBFQlA6IGMwMDMxZTE4IEVTUDogYzAwMzFkZTQKWyAgICAw
LjE4MDAwMF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMDAwIEdTOiAwMGUwIFNTOiAwMDY4
ClsgICAgMC4xODAwMDBdIENSMDogODAwNTAwM2IgQ1IyOiA1NTNhNWYwMSBDUjM6IDAyNWY1
MDAwIENSNDogMDAwMDA2YjAKWyAgICAwLjE4MDAwMF0gU3RhY2s6ClsgICAgMC4xODAwMDBd
ICAwMDAwMDAwMSAwMDAwMDAwMCBjMTI3ZjU5NSAwMDAwMDI0NiAwMDAwMDAwMCBjMjM4ZTg4
MCBjMDA5MWYwMCBjMDA5MWYwOApbICAgIDAuMTgwMDAwXSAgYzAxMDBmOTggYzAwN2UwMzAg
YzAxMDBmOTAgYzAxMDBmOTAgMDAwMDAwMDAgYzAwMzFlNTQgYzEyN2YzMjUgMDAwMDAwMDAK
WyAgICAwLjE4MDAwMF0gIDAwMDAwMDAxIDAwMDAwMDAwIGMxMjgwNTBmIGMwMTAwZjk4IGMy
MzhlODgwIGMxZDU2ZTQ2IDAwMDAwMDQ2IGMxZTFiODRkClsgICAgMC4xODAwMDBdIENhbGwg
VHJhY2U6ClsgICAgMC4xODAwMDBdICBbPGMxMjdmNTk1Pl0gPyBfX2tlcm5mc19yZW1vdmUr
MHgzNjUvMHg2NzAKWyAgICAwLjE4MDAwMF0gIFs8YzEyN2YzMjU+XSBfX2tlcm5mc19yZW1v
dmUrMHhmNS8weDY3MApbICAgIDAuMTgwMDAwXSAgWzxjMTI4MDUwZj5dID8ga2VybmZzX3Jl
bW92ZV9ieV9uYW1lX25zKzB4NmYvMHgxMjAKWyAgICAwLjE4MDAwMF0gIFs8YzFkNTZlNDY+
XSA/IG11dGV4X3VubG9jaysweDE2LzB4MzAKWyAgICAwLjE4MDAwMF0gIFs8YzEyODA1MGY+
XSBrZXJuZnNfcmVtb3ZlX2J5X25hbWVfbnMrMHg2Zi8weDEyMApbICAgIDAuMTgwMDAwXSAg
WzxjMTI4NDc5MT5dIHJlbW92ZV9maWxlcy5pc3JhLjErMHg1MS8weGMwClsgICAgMC4xODAw
MDBdICBbPGMxMjg0ZGQ2Pl0gc3lzZnNfcmVtb3ZlX2dyb3VwKzB4NTYvMHgxNDAKWyAgICAw
LjE4MDAwMF0gIFs8YzI1NTNmNTA+XSA/IGxvY2F0ZV9tb2R1bGVfa29iamVjdCsweDIyLzB4
MWNkClsgICAgMC4xODAwMDBdICBbPGMyNTU0MzQwPl0gcGFyYW1fc3lzZnNfaW5pdCsweDI0
NS8weDUxMQpbICAgIDAuMTgwMDAwXSAgWzxjMTQzOTdjNj5dID8ga3Zhc3ByaW50ZisweDg2
LzB4YTAKWyAgICAwLjE4MDAwMF0gIFs8YzI1NTQwZmI+XSA/IGxvY2F0ZV9tb2R1bGVfa29i
amVjdCsweDFjZC8weDFjZApbICAgIDAuMTgwMDAwXSAgWzxjMjUyZjk1Yz5dIGRvX29uZV9p
bml0Y2FsbCsweDFmMy8weDMwZQpbICAgIDAuMTgwMDAwXSAgWzxjMjUyZmNhNz5dIGtlcm5l
bF9pbml0X2ZyZWVhYmxlKzB4MjMwLzB4MzhiClsgICAgMC4xODAwMDBdICBbPGMxZDM5NTM5
Pl0ga2VybmVsX2luaXQrMHgxOS8weDIzMApbICAgIDAuMTgwMDAwXSAgWzxjMTBhYmI5YT5d
ID8gc2NoZWR1bGVfdGFpbCsweDFhLzB4YTAKWyAgICAwLjE4MDAwMF0gIFs8YzFkNWNiODA+
XSByZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4MjAvMHgzMApbICAgIDAuMTgwMDAwXSAgWzxj
MWQzOTUyMD5dID8gcmVzdF9pbml0KzB4MTgwLzB4MTgwClsgICAgMC4xODAwMDBdIENvZGU6
IDAxIDAwIDAwIDkwIDBmIGI3IDQ2IDU0IDg5IGMyIDgzIGUyIDBmIDY2IDgzIGZhIDA0IDBm
IDg0IDVkIDAyIDAwIDAwIGY2IGM0IDAyIDBmIDg0IDBjIDAyIDAwIDAwIDhiIDQ2IDVjIDg1
IGMwIDBmIDg0IDMwIDAyIDAwIDAwIDw4Yj4gNDggMzQgODMgMDUgMzggYWQgY2UgYzIgMDEg
ODMgMTUgM2MgYWQgY2UgYzIgMDAgODUgYzkgNzQgMjkKWyAgICAwLjE4MDAwMF0gRUlQOiBb
PGMxMjdlNzA3Pl0ga2VybmZzX3B1dCsweGQ3LzB4M2EwIFNTOkVTUCAwMDY4OmMwMDMxZGU0
ClsgICAgMC4xODAwMDBdIENSMjogMDAwMDAwMDA1NTNhNWYwMQpbICAgIDAuMTgwMDAwXSAt
LS1bIGVuZCB0cmFjZSBhZDIyOWE3NDk0YTM1MTVkIF0tLS0KWyAgICAwLjE4MDAwMF0gS2Vy
bmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZhdGFsIGV4Y2VwdGlvbgova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyODEzMDIvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFk
MDJiOWM5ZmUwMS9kbWVzZy1xdWFudGFsLWxrcC1uZXgwNC03MToyMDE0MDkyODE1MTk0MDpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEv
ZG1lc2cteW9jdG8taXZiNDEtNTU6MjAxNDA5MjgxNTE5MTk6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTI4MTMwMjo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80ZDg0
MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLXZwLTEz
OjIwMTQwOTI4MTUxOTA3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDI6My4xNy4wLXJj
Ni1uZXh0LTIwMTQwOTI2OjQKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAy
LzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2ctcXVhbnRh
bC1pdmI0MS0yNToyMDE0MDkyODE1MTkyMjppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAy
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFk
YjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tdnAtOToyMDE0MDkyODEz
MDgwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjMuMTcuMC1yYzYtbmV4dC0yMDE0
MDkyNjo0Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80ZDg0MjZmOWFj
NjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXF1YW50YWwtbGtwLW5leDA0
LTE3NToyMDE0MDkyODE1MTk0MTppMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjgxMzAyLzRkODQyNmY5YWM2MDFkYjJhNjRm
YTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTk1OjIwMTQwOTI4
MTUxOTE1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDI6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyODEzMDIvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJi
OWM5ZmUwMS9kbWVzZy15b2N0by12cC00MToyMDE0MDkyODE1MTkxOTppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjgxMzAyOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyNjo0Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTI4MTMwMi80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1
MWQwMmI5YzlmZTAxL2RtZXNnLXF1YW50YWwtbGtwLW5leDA0LTE3OjIwMTQwOTI4MTUxOTQz
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyODEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyODEzMDIvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUw
MS9kbWVzZy1xdWFudGFsLWxrcC1uZXgwNC0xNzE6MjAxNDA5MjgxNTE5MjQ6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTI4MTMwMjo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTI4
MTMwMi80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlv
Y3RvLWxrcC1uZXgwNC03NDoyMDE0MDkyODE1MTkzMzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjgxMzAyOjoKMDoxMToxMSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoK

--cz6wLo+OExbGG7q/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.17.0-rc6-00222-g8d8590d"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.17.0-rc6 Kernel Configuration
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
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
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
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_FHANDLE is not set
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_PROFILING=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
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
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_RDC321X=y
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
CONFIG_M686=y
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
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_UP_APIC=y
CONFIG_X86_UP_IOAPIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=y
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
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
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_HIGHPTE is not set
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
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
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
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_SCx200 is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_GEOS=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_IOSF_MBI=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_IPVTI=y
CONFIG_NET_UDP_TUNNEL=y
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
CONFIG_INET_UDP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
CONFIG_IP_DCCP_DEBUG=y
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_HSR is not set
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
# CONFIG_NETROM is not set
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
# CONFIG_6PACK is not set
# CONFIG_BPQETHER is not set
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_BAYCOM_EPP=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
CONFIG_CAN_SJA1000_PLATFORM=y
# CONFIG_CAN_EMS_PCMCIA is not set
# CONFIG_CAN_EMS_PCI is not set
CONFIG_CAN_PEAK_PCMCIA=y
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_C_CAN=y
CONFIG_CAN_C_CAN_PLATFORM=y
# CONFIG_CAN_C_CAN_PCI is not set
CONFIG_CAN_CC770=y
CONFIG_CAN_CC770_ISA=y
CONFIG_CAN_CC770_PLATFORM=y

#
# CAN SPI interfaces
#
CONFIG_CAN_MCP251X=y

#
# CAN USB interfaces
#
# CONFIG_CAN_EMS_USB is not set
# CONFIG_CAN_ESD_USB2 is not set
CONFIG_CAN_GS_USB=y
# CONFIG_CAN_KVASER_USB is not set
CONFIG_CAN_PEAK_USB=y
CONFIG_CAN_8DEV_USB=y
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_IRDA is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTUSB is not set
# CONFIG_BT_HCIUART is not set
# CONFIG_BT_HCIBCM203X is not set
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
CONFIG_BT_HCIDTL1=y
# CONFIG_BT_HCIBT3C is not set
# CONFIG_BT_HCIBLUECARD is not set
# CONFIG_BT_HCIBTUART is not set
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_REG_CELLULAR_HINTS=y
# CONFIG_CFG80211_REG_RELAX_NO_IR is not set
# CONFIG_CFG80211_DEFAULT_PS is not set
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
# CONFIG_MAC80211_RC_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT=""

#
# Some wireless drivers require a rate control algorithm
#
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
CONFIG_MAC80211_DEBUG_MENU=y
CONFIG_MAC80211_NOINLINE=y
# CONFIG_MAC80211_VERBOSE_DEBUG is not set
CONFIG_MAC80211_MLME_DEBUG=y
CONFIG_MAC80211_STA_DEBUG=y
CONFIG_MAC80211_HT_DEBUG=y
# CONFIG_MAC80211_IBSS_DEBUG is not set
CONFIG_MAC80211_PS_DEBUG=y
# CONFIG_MAC80211_TDLS_DEBUG is not set
CONFIG_MAC80211_DEBUG_COUNTERS=y
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_RFKILL_GPIO is not set
# CONFIG_NET_9P is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_SPI is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_PN533 is not set
CONFIG_NFC_TRF7970A=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PORT100=y
# CONFIG_NFC_PN544 is not set
CONFIG_NFC_MICROREAD=y
# CONFIG_NFC_MICROREAD_I2C is not set
CONFIG_NFC_MRVL=y
CONFIG_NFC_MRVL_USB=y
# CONFIG_NFC_ST21NFCA is not set
CONFIG_NFC_ST21NFCB=y
CONFIG_NFC_ST21NFCB_I2C=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
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
CONFIG_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_PERCENTAGE=10
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_BMP085_SPI=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_LATTICE_ECP3_CONFIG is not set
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_ECHO=y
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
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

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
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
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
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

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
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
# CONFIG_IPMI_WATCHDOG is not set
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_ST33_I2C is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
# CONFIG_I2C_ALGOPCA is not set

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
# CONFIG_HSI is not set

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
CONFIG_PPS_CLIENT_GPIO=y

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
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_CRYSTAL_COVE is not set
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TWL6040=y
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8350=y
# CONFIG_GPIO_WM8994 is not set
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set
CONFIG_GPIO_TPS65910=y

#
# USB GPIO expanders:
#
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_LP8788 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_DA9055 is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_ACPI_INT3403_THERMAL is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

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
CONFIG_DA9055_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
CONFIG_WM8350_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_RDC321X_WDT=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=y
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_MEN_A21_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
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
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_EZX_PCAP=y
# CONFIG_MFD_VIPERBOARD is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
# CONFIG_MFD_TPS65912 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_88PM800 is not set
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LP3971 is not set
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_PCAP is not set
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65090=y
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_WM8994 is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
CONFIG_DRM=y
CONFIG_DRM_USB=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_PTN3460 is not set
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
# CONFIG_FB_CFB_FILLRECT is not set
# CONFIG_FB_CFB_COPYAREA is not set
# CONFIG_FB_CFB_IMAGEBLIT is not set
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
# CONFIG_FB_BIG_ENDIAN is not set
CONFIG_FB_LITTLE_ENDIAN=y
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
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
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
# CONFIG_LCD_AMS369FG06 is not set
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
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
# CONFIG_HID_CP2112 is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_GT683R is not set
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
# CONFIG_HID_LENOVO is not set
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
# CONFIG_HID_RMI is not set
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
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1362_HCD=y
CONFIG_USB_FUSBH200_HCD=y
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

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
CONFIG_USB_DWC3_DEBUG=y
# CONFIG_USB_DWC3_VERBOSE is not set
CONFIG_DWC3_HOST_USB3_LPM_ENABLE=y
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_DEBUG=y
# CONFIG_USB_DWC2_VERBOSE is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_HOST=y
CONFIG_USB_CHIPIDEA_DEBUG=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_LINK_LAYER_TEST=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
CONFIG_SAMSUNG_USB3PHY=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_USB_ISP1301=y
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_WM8350=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
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
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_LP8788 is not set
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_RS5C372=y
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_TPS6586X is not set
CONFIG_RTC_DRV_TPS65910=y
CONFIG_RTC_DRV_TPS80031=y
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV3029C2 is not set
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
# CONFIG_RTC_DRV_DS3234 is not set
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_MCP795=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
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
CONFIG_RTC_DRV_XGENE=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
CONFIG_CHROMEOS_PSTORE=y

#
# SOC (System On Chip) specific Drivers
#

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
CONFIG_IOMMU_SUPPORT=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
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
# CONFIG_BMA180 is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=y
CONFIG_MMA8452=y
# CONFIG_KXCJK1013 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
# CONFIG_AD7266 is not set
# CONFIG_AD7291 is not set
# CONFIG_AD7298 is not set
# CONFIG_AD7476 is not set
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
# CONFIG_AD799X is not set
CONFIG_LP8788_ADC=y
CONFIG_MAX1027=y
CONFIG_MAX1363=y
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
# CONFIG_NAU7802 is not set
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5360 is not set
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
CONFIG_AD5446=y
# CONFIG_AD5449 is not set
# CONFIG_AD5504 is not set
# CONFIG_AD5624R_SPI is not set
# CONFIG_AD5686 is not set
CONFIG_AD5755=y
# CONFIG_AD5764 is not set
# CONFIG_AD5791 is not set
# CONFIG_AD7303 is not set
CONFIG_MAX517=y
# CONFIG_MCP4725 is not set
# CONFIG_MCP4922 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
# CONFIG_ADIS16130 is not set
CONFIG_ADIS16136=y
# CONFIG_ADIS16260 is not set
# CONFIG_ADXRS450 is not set
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Humidity sensors
#
# CONFIG_DHT11 is not set
# CONFIG_SI7005 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
# CONFIG_ADIS16480 is not set
CONFIG_INV_MPU6050_IIO=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
# CONFIG_APDS9300 is not set
# CONFIG_CM32181 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_ISL29125=y
CONFIG_LTR501=y
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_TSL4531 is not set
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
# CONFIG_AK09911 is not set
CONFIG_MAG3110=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_MPL115=y
# CONFIG_MPL3115 is not set
# CONFIG_IIO_ST_PRESS is not set
# CONFIG_T5403 is not set

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
CONFIG_TMP006=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_EXYNOS4210_USB2 is not set
# CONFIG_PHY_EXYNOS4X12_USB2 is not set
# CONFIG_PHY_EXYNOS5250_USB2 is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
# CONFIG_THUNDERBOLT is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_CEPH_FS=y
CONFIG_CEPH_FSCACHE=y
CONFIG_CEPH_FS_POSIX_ACL=y
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
# CONFIG_CIFS_DEBUG is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB2 is not set
CONFIG_CIFS_FSCACHE=y
# CONFIG_NCP_FS is not set
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
# CONFIG_AFS_DEBUG is not set
# CONFIG_AFS_FSCACHE is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

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
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
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
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
# CONFIG_RCU_TRACE is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
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
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
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
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
# CONFIG_SECURITY_SELINUX_AVC_STATS is not set
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_SMACK=y
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_APPARMOR_HASH is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
# CONFIG_INTEGRITY_AUDIT is not set
# CONFIG_INTEGRITY_ASYMMETRIC_KEYS is not set
# CONFIG_IMA is not set
CONFIG_EVM=y

#
# EVM options
#
# CONFIG_EVM_ATTR_FSUUID is not set
# CONFIG_EVM_EXTRA_SMACK_XATTRS is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_SMACK is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
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
CONFIG_CRYPTO_PCOMP=y
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
# CONFIG_CRYPTO_GCM is not set
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
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_586 is not set
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
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
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
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_AUDIT_GENERIC=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--cz6wLo+OExbGG7q/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--cz6wLo+OExbGG7q/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
