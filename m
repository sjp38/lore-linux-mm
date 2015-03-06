Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 60EF26B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 01:07:33 -0500 (EST)
Received: by padfa1 with SMTP id fa1so42769882pad.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 22:07:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id md9si12956678pdb.104.2015.03.05.22.07.31
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 22:07:32 -0800 (PST)
Date: Fri, 6 Mar 2015 14:07:26 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [bdi] BUG: unable to handle kernel NULL pointer dereference at
 0000000000000550
Message-ID: <20150306060726.GE28187@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Wb5NtZlyOqqy58h0"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: fengguang.wu@intel.com, Josef Bacik <jbacik@fb.com>, LKP <lkp@01.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--Wb5NtZlyOqqy58h0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/josef/btrfs-next.git superblock-scaling

commit 40ceea09e84d1b9319236b27ad3162422310e5d0
Author:     Dave Chinner <dchinner@redhat.com>
AuthorDate: Wed Mar 4 14:36:27 2015 -0500
Commit:     Josef Bacik <jbacik@fb.com>
CommitDate: Wed Mar 4 14:39:28 2015 -0500

    bdi: add a new writeback list for sync
    
    wait_sb_inodes() current does a walk of all inodes in the filesystem
    to find dirty one to wait on during sync. This is highly
    inefficient and wastes a lot of CPU when there are lots of clean
    cached inodes that we don't need to wait on.
    
    To avoid this "all inode" walk, we need to track inodes that are
    currently under writeback that we need to wait for. We do this by
    adding inodes to a writeback list on the bdi when the mapping is
    first tagged as having pages under writeback.  wait_sb_inodes() can
    then walk this list of "inodes under IO" and wait specifically just
    for the inodes that the current sync(2) needs to wait for.
    
    To avoid needing all the realted locking to be safe against
    interrupts, Jan Kara suggested that we be lazy about removal from
    the writeback list. That is, we don't remove inodes from the
    writeback list on IO completion, but do it directly during a
    wait_sb_inodes() walk.
    
    This means that the a rare sync(2) call will have some work to do
    skipping clean inodes However, in the current problem case of
    concurrent sync workloads, concurrent wait_sb_inodes() calls only
    walk the very recently dispatched inodes and hence should have very
    little work to do.
    
    This also means that we have to remove the inodes from the writeback
    list during eviction. Do this in inode_wait_for_writeback() once
    all writeback on the inode is complete.
    
    Signed-off-by: Dave Chinner <dchinner@redhat.com>

+------------------------------------------+------------+------------+------------+
|                                          | d2ee191143 | 40ceea09e8 | 45b8e7be56 |
+------------------------------------------+------------+------------+------------+
| boot_successes                           | 72         | 0          | 0          |
| boot_failures                            | 8          | 20         | 12         |
| BUG:kernel_boot_hang                     | 8          |            |            |
| BUG:unable_to_handle_kernel              | 0          | 20         | 12         |
| Oops                                     | 0          | 20         | 12         |
| RIP:blk_get_backing_dev_info             | 0          | 20         | 12         |
| Kernel_panic-not_syncing:Fatal_exception | 0          | 20         | 12         |
| backtrace:add_disk                       | 0          | 20         | 12         |
| backtrace:brd_init                       | 0          | 20         | 12         |
| backtrace:kernel_init_freeable           | 0          | 20         | 12         |
+------------------------------------------+------------+------------+------------+

[    0.699779] Linux agpgart interface v0.103
[    0.700296] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    0.701079] [drm] Initialized drm 1.1.0 20060810
[    0.702193] BUG: unable to handle kernel NULL pointer dereference at 0000000000000550
[    0.702883] IP: [<ffffffff8121a84b>] blk_get_backing_dev_info+0xb/0x1a
[    0.703443] PGD 0 
[    0.703632] Oops: 0000 [#1] PREEMPT SMP 
[    0.704009] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc2-00135-g40ceea0 #1
[    0.704142] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.704142] task: ffff880012860000 ti: ffff880012868000 task.ti: ffff880012868000
[    0.704142] RIP: 0010:[<ffffffff8121a84b>]  [<ffffffff8121a84b>] blk_get_backing_dev_info+0xb/0x1a
[    0.704142] RSP: 0000:ffff88001286bcd8  EFLAGS: 00010202
[    0.704142] RAX: 0000000000000000 RBX: ffff8800124147a0 RCX: 0000000000000000
[    0.704142] RDX: ffff880012860720 RSI: 0000000000000000 RDI: ffff8800124145c0
[    0.704142] RBP: ffff88001286bcd8 R08: 0000000000000001 R09: 0000000000000000
[    0.704142] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88001282a000
[    0.704142] R13: ffffffff81c1c600 R14: ffffffff81c1c600 R15: ffff8800124145d8
[    0.704142] FS:  0000000000000000(0000) GS:ffff880013a00000(0000) knlGS:0000000000000000
[    0.704142] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.704142] CR2: 0000000000000550 CR3: 0000000002211000 CR4: 00000000000006f0
[    0.704142] Stack:
[    0.704142]  ffff88001286bcf8 ffffffff81155424 ffff8800124147a0 ffff880012414820
[    0.704142]  ffff88001286bd28 ffffffff8115558d ffff880012860720 ffff8800124147a0
[    0.704142]  ffff880012414958 ffffffff81c1c600 ffff88001286bd58 ffffffff8114a2e6
[    0.704142] Call Trace:
[    0.704142]  [<ffffffff81155424>] inode_to_bdi+0x36/0x45
[    0.704142]  [<ffffffff8115558d>] inode_wait_for_writeback+0x3f/0xc2
[    0.704142]  [<ffffffff8114a2e6>] evict+0xa2/0x15e
[    0.704142]  [<ffffffff8114b084>] iput+0x160/0x16d
[    0.704142]  [<ffffffff8115f8c0>] bdput+0xd/0xf
[    0.704142]  [<ffffffff8115fa28>] __blkdev_put+0x166/0x18a
[    0.704142]  [<ffffffff8116060c>] blkdev_put+0x114/0x11d
[    0.704142]  [<ffffffff81229627>] add_disk+0x44d/0x461
[    0.704142]  [<ffffffff82583a11>] brd_init+0x95/0x160
[    0.704142]  [<ffffffff8258397c>] ? ramdisk_size+0x1a/0x1a
[    0.704142]  [<ffffffff8255205b>] do_one_initcall+0xe8/0x175
[    0.704142]  [<ffffffff825522b8>] kernel_init_freeable+0x1d0/0x258
[    0.704142]  [<ffffffff81b46d9c>] ? rest_init+0xbc/0xbc
[    0.704142]  [<ffffffff81b46da5>] kernel_init+0x9/0xd5
[    0.704142]  [<ffffffff81b5d2fc>] ret_from_fork+0x7c/0xb0
[    0.704142]  [<ffffffff81b46d9c>] ? rest_init+0xbc/0xbc
[    0.704142] Code: ca 48 c1 ea 04 29 d0 ba 01 00 00 00 89 8f 80 08 00 00 ff c8 85 c0 0f 4e c2 89 87 84 08 00 00 c3 48 8b 87 10 01 00 00 55 48 89 e5 <48> 8b 80 50 05 00 00 5d 48 05 58 02 00 00 c3 48 89 fa 31 c0 b9 
[    0.704142] RIP  [<ffffffff8121a84b>] blk_get_backing_dev_info+0xb/0x1a
[    0.704142]  RSP <ffff88001286bcd8>
[    0.704142] CR2: 0000000000000550
[    0.704142] ---[ end trace 5c64cf25111d3d67 ]---
[    0.704142] Kernel panic - not syncing: Fatal exception

git bisect start 45b8e7be563c57fc42d69d5239b4829b5586620d 13a7a6ac0a11197edcd0f756a035f472b42cdf8b --
git bisect  bad 980171ac3db20fc792b9b1298067344725a5a285  # 19:07      0-     20  Merge 'luto/x86/entry' into devel-xian-x86_64-201503051818
git bisect  bad 7a2a5fad21b95990713cbdfaccc9eeba4e98f9b8  # 19:13      0-     20  Merge 'kees/format-security' into devel-xian-x86_64-201503051818
git bisect good cadb5884edc7353ecb245cf0874ead1f9565f2a7  # 19:29     20+      0  Merge 'trace/ftrace/urgent' into devel-xian-x86_64-201503051818
git bisect good 30abe812fb9b18b25ebb9d2d214a70013a191ccb  # 19:34     20+      0  Merge 'paulburton/wip-ci20-v4.0' into devel-xian-x86_64-201503051818
git bisect good 0d0fc17147f433ffe27f8d2fcd3b29e109694fe3  # 19:40     20+      0  Merge 'arm-soc/next/drivers' into devel-xian-x86_64-201503051818
git bisect  bad caca114c0271d4df06e2ff1acee68dd62be43d66  # 20:03      0-     20  Merge 'josef-btrfs/superblock-scaling' into devel-xian-x86_64-201503051818
git bisect good d2ee19114357bdf21c59a3ac61eb053ef1c0dc4e  # 20:15     20+      8  inode: rename i_wb_list to i_io_list
git bisect  bad 63738525a6ebdf74bb3eb1c3dba16c0bb6895d97  # 20:28      0-     20  inode: convert per-sb inode list to a list_lru
git bisect  bad a05899067cddc24276e43e0d440da791738cf967  # 20:42      0-     20  writeback: periodically trim the writeback list
git bisect  bad 40ceea09e84d1b9319236b27ad3162422310e5d0  # 21:12      0-     20  bdi: add a new writeback list for sync
# first bad commit: [40ceea09e84d1b9319236b27ad3162422310e5d0] bdi: add a new writeback list for sync
git bisect good d2ee19114357bdf21c59a3ac61eb053ef1c0dc4e  # 21:14     60+      8  inode: rename i_wb_list to i_io_list
# extra tests with DEBUG_INFO
git bisect  bad 40ceea09e84d1b9319236b27ad3162422310e5d0  # 22:55      0-     22  bdi: add a new writeback list for sync
# extra tests on HEAD of linux-devel/devel-xian-x86_64-201503051818
git bisect  bad 45b8e7be563c57fc42d69d5239b4829b5586620d  # 22:55      0-     12  0day head guard for 'devel-xian-x86_64-201503051818'
# extra tests on tree/branch josef-btrfs/superblock-scaling
git bisect  bad d119f33d7f868e92c2d7fd21da1aade94584994d  # 23:13      0-     60  inode: don't softlockup when evicting inodes
# extra tests on tree/branch linus/master
git bisect good 6587457b4b3d663b237a0f95ddf6e67d1828c8ea  # 23:41     60+      2  Merge tag 'dma-buf-for-4.0-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/sumits/dma-buf
# extra tests on tree/branch next/master
git bisect good cbbf783608bd1f177fd8b1f6498bb2481116beed  # 23:53     60+      0  Add linux-next specific files for 20150305


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=yocto-minimal-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 1
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
	rd.udev.log-priority=err
	systemd.log_target=journal
	systemd.log_level=warning
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

--Wb5NtZlyOqqy58h0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-client7-18:20150305211151:x86_64-acpi-redef:4.0.0-rc2-00135-g40ceea0:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-rc2-00135-g40ceea0 (kbuild@xian) (gcc ve=
rsion 4.9.2 (Debian 4.9.2-10) ) #1 SMP PREEMPT Thu Mar 5 21:11:35 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-acpi-redef/linux-devel:devel-xian-x86_64-201503051818:40ceea09e84d1b931=
9236b27ad3162422310e5d0:bisect-linux-3/.vmlinuz-40ceea09e84d1b9319236b27ad3=
162422310e5d0-20150305211149-5-client7 branch=3Dlinux-devel/devel-xian-x86_=
64-201503051818 BOOT_IMAGE=3D/kernel/x86_64-acpi-redef/40ceea09e84d1b931923=
6b27ad3162422310e5d0/vmlinuz-4.0.0-rc2-00135-g40ceea0 drbd.minor_count=3D8
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
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0ed0-0x000f0edf] mapped at =
[ffff8800000f0ed0]
[    0.000000]   mpc: f0ee0-f0fb0
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x032c2000, 0x032c2fff] PGTABLE
[    0.000000] BRK [0x032c3000, 0x032c3fff] PGTABLE
[    0.000000] BRK [0x032c4000, 0x032c4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x13a00000-0x13bfffff]
[    0.000000]  [mem 0x13a00000-0x13bfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x139fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x139fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x13c00000-0x13fdffff]
[    0.000000]  [mem 0x13c00000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x032c5000, 0x032c5fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x13cce000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0CF0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE1854 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000BF9 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE17A4 000078 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE181C 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
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
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 477 pages/cpu @ffff880013a00000 s1923736 r0=
 d30056 u2097152
[    0.000000] pcpu-alloc: s1923736 r0 d30056 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 13a0e0c0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-acpi-redef/linux-devel:devel-xian-x86_64-201503051818:40ceea09e84=
d1b9319236b27ad3162422310e5d0:bisect-linux-3/.vmlinuz-40ceea09e84d1b9319236=
b27ad3162422310e5d0-20150305211149-5-client7 branch=3Dlinux-devel/devel-xia=
n-x86_64-201503051818 BOOT_IMAGE=3D/kernel/x86_64-acpi-redef/40ceea09e84d1b=
9319236b27ad3162422310e5d0/vmlinuz-4.0.0-rc2-00135-g40ceea0 drbd.minor_coun=
t=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] Memory: 279444K/327160K available (11654K kernel code, 1511K=
 rwdata, 5632K rodata, 2884K init, 12724K bss, 47716K reserved, 0K cma-rese=
rved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
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
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 5851.99 Bogo=
MIPS (lpj=3D11703992)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.008000] ACPI: Core revision 20150204
[    0.010321] ACPI: All ACPI Tables successfully acquired
[    0.010895] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.011591] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.012196] Initializing cgroup subsys freezer
[    0.012822] Initializing cgroup subsys debug
[    0.013325] mce: CPU supports 10 MCE banks
[    0.013720] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.014309] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.028038] Freeing SMP alternatives memory: 32K (ffffffff8264c000 - fff=
fffff82654000)
[    0.032611] Getting VERSION: 1050014
[    0.033077] Getting VERSION: 1050014
[    0.033533] Getting ID: 0
[    0.033871] Getting ID: ff000000
[    0.034290] Getting LVT0: 8700
[    0.034675] Getting LVT1: 8400
[    0.035115] enabled ExtINT on CPU#0
[    0.036549] ENABLING IO-APIC IRQs
[    0.036982] init IO_APIC IRQs
[    0.037361]  apic 0 pin 0 not connected
[    0.037847] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.038836] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.039824] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.040027] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.041010] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.041990] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.042974] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.044028] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.045101] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.046083] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.047067] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.048030] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.048880] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.049766] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.050665] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.052031] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.053131]  apic 0 pin 16 not connected
[    0.053547]  apic 0 pin 17 not connected
[    0.053889]  apic 0 pin 18 not connected
[    0.054233]  apic 0 pin 19 not connected
[    0.054632]  apic 0 pin 20 not connected
[    0.056007]  apic 0 pin 21 not connected
[    0.056446]  apic 0 pin 22 not connected
[    0.056807]  apic 0 pin 23 not connected
[    0.057329] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.057855] Using local APIC timer interrupts.
[    0.057855] calibrating APIC timer ...
[    0.060000] ... lapic delta =3D 6250637
[    0.060000] ... PM-Timer delta =3D 357980
[    0.060000] ... PM-Timer result ok
[    0.060000] ..... delta 6250637
[    0.060000] ..... mult: 268462814
[    0.060000] ..... calibration result: 4000407
[    0.060000] ..... CPU clock speed is 2926.0818 MHz.
[    0.060000] ..... host bus clock speed is 1000.0407 MHz.
[    0.060057] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.061244] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.084017] x86: Booted up 1 node, 1 CPUs
[    0.084611] smpboot: Total of 1 processors activated (5851.99 BogoMIPS)
[    0.085795] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.086840] devtmpfs: initialized
[    0.089399] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.090567] NET: Registered protocol family 16
[    0.104027] cpuidle: using governor ladder
[    0.116023] cpuidle: using governor menu
[    0.117276] ACPI: bus type PCI registered
[    0.118041] PCI: Using configuration type 1 for base access
[    0.152686] ACPI: Added _OSI(Module Device)
[    0.153067] ACPI: Added _OSI(Processor Device)
[    0.153444] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.153849] ACPI: Added _OSI(Processor Aggregator Device)
[    0.155893] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.158831] ACPI: Interpreter enabled
[    0.159165] ACPI: (supports S0 S5)
[    0.160002] ACPI: Using IOAPIC for interrupt routing
[    0.160450] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.169465] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.170011] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.170514] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.171943] PCI host bridge to bus 0000:00
[    0.172004] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.172474] pci_bus 0000:00: root bus resource [io  0x0cf8-0x0cff]
[    0.172994] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.173571] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.174143] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.174734] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.175310] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.176003] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.176637] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f window]
[    0.177297] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.178308] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.179399] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.182201] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.183501] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.184003] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.184550] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.185137] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.186263] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.187114] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.187737] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.188358] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.189790] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.191188] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.196400] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.197281] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.198554] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.199817] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.204004] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.204865] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.205778] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.209041] pci_bus 0000:00: on NUMA node 0
[    0.210078] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.210779] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.211458] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.212238] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.212840] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.213764] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.215065] SCSI subsystem initialized
[    0.215457] libata version 3.00 loaded.
[    0.215856] ACPI: bus type USB registered
[    0.216045] usbcore: registered new interface driver usbfs
[    0.216529] usbcore: registered new interface driver hub
[    0.216999] usbcore: registered new device driver usb
[    0.217502] Linux video capture interface: v2.00
[    0.217934] pps_core: LinuxPPS API ver. 1 registered
[    0.218347] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.219104] PTP clock support registered
[    0.219510] wmi: Mapper loaded
[    0.220078] Advanced Linux Sound Architecture Driver Initialized.
[    0.220607] PCI: Using ACPI for IRQ routing
[    0.220963] PCI: pci_cache_line_size set to 64 bytes
[    0.221462] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.221974] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.222761] NET: Registered protocol family 8
[    0.223129] NET: Registered protocol family 20
[    0.223674] cfg80211: Calling CRDA to update world regulatory domain
[    0.224921] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.225529] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.225983] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.232059] Switched to clocksource kvm-clock
[    0.232529] pnp: PnP ACPI init
[    0.232876] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.233605] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.234205] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.234941] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.235506] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.236270] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.236898] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.237590] pnp 00:03: [dma 2]
[    0.237920] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.238533] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.239270] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.239894] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.240640] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.241690] pnp: PnP ACPI: found 6 devices
[    0.247340] pci_bus 0000:00: resource 4 [io  0x0cf8-0x0cff]
[    0.247818] pci_bus 0000:00: resource 5 [io  0x0000-0x0cf7 window]
[    0.248358] pci_bus 0000:00: resource 6 [io  0x0d00-0xadff window]
[    0.248881] pci_bus 0000:00: resource 7 [io  0xae0f-0xaeff window]
[    0.249399] pci_bus 0000:00: resource 8 [io  0xaf20-0xafdf window]
[    0.249937] pci_bus 0000:00: resource 9 [io  0xafe4-0xffff window]
[    0.250461] pci_bus 0000:00: resource 10 [mem 0x000a0000-0x000bffff wind=
ow]
[    0.251051] pci_bus 0000:00: resource 11 [mem 0x14000000-0xfebfffff wind=
ow]
[    0.251672] NET: Registered protocol family 2
[    0.252300] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    0.252947] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.253619] TCP: Hash tables configured (established 4096 bind 4096)
[    0.254188] TCP: reno registered
[    0.254476] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.255001] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.255629] NET: Registered protocol family 1
[    0.256046] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.256556] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.257062] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.257610] pci 0000:00:02.0: Video device with shadowed ROM
[    0.258116] PCI: CLS 0 bytes, default 64
[    0.258568] Trying to unpack rootfs image as initramfs...
[    0.317254] Freeing initrd memory: 3112K (ffff880013cce000 - ffff880013f=
d8000)
[    0.319021] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    0.319786] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    0.320626] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    0.321522] cryptomgr_test (26) used greatest stack depth: 14888 bytes l=
eft
[    0.322147] AVX or AES-NI instructions are not detected.
[    0.322594] AVX instructions are not detected.
[    0.322976] AVX instructions are not detected.
[    0.323351] AVX instructions are not detected.
[    0.324081] futex hash table entries: 256 (order: 3, 32768 bytes)
[    0.324611] audit: initializing netlink subsys (disabled)
[    0.325123] audit: type=3D2000 audit(1425561105.911:1): initialized
[    0.325854] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.337230] 9p: Installing v9fs 9p2000 file system support
[    0.339749] Key type asymmetric registered
[    0.340148] bounce: pool size: 64 pages
[    0.340928] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    0.341561] io scheduler noop registered (default)
[    0.341977] start plist test
[    0.343406] end plist test
[    0.348674] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    0.349108] crc32: self tests passed, processed 225944 bytes in 2469106 =
nsec
[    0.353064] crc32c: CRC_LE_BITS =3D 1
[    0.353370] crc32c: self tests passed, processed 225944 bytes in 1587897=
 nsec
[    0.495682] crc32_combine: 8373 self tests passed
[    0.637660] crc32c_combine: 8373 self tests passed
[    0.638354] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.639129] rivafb_setup START
[    0.639591] vmlfb: initializing
[    0.640044] usbcore: registered new interface driver udlfb
[    0.640529] usbcore: registered new interface driver smscufx
[    0.641202] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    0.641843] ACPI: Power Button [PWRF]
[    0.670782] r3964: Philips r3964 Driver $Revision: 1.10 $
[    0.671264] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.695488] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    0.697057] Initializing Nozomi driver 2.1d
[    0.697499] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 =
Exp $
[    0.698115] ac.o: No PCI boards found.
[    0.698440] ac.o: For an ISA board you must supply memory and irq parame=
ters.
[    0.699238] Non-volatile memory driver v1.3
[    0.699779] Linux agpgart interface v0.103
[    0.700296] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    0.701079] [drm] Initialized drm 1.1.0 20060810
[    0.702193] BUG: unable to handle kernel NULL pointer dereference at 000=
0000000000550
[    0.702883] IP: [<ffffffff8121a84b>] blk_get_backing_dev_info+0xb/0x1a
[    0.703443] PGD 0=20
[    0.703632] Oops: 0000 [#1] PREEMPT SMP=20
[    0.704009] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc2-00135-g4=
0ceea0 #1
[    0.704142] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.704142] task: ffff880012860000 ti: ffff880012868000 task.ti: ffff880=
012868000
[    0.704142] RIP: 0010:[<ffffffff8121a84b>]  [<ffffffff8121a84b>] blk_get=
_backing_dev_info+0xb/0x1a
[    0.704142] RSP: 0000:ffff88001286bcd8  EFLAGS: 00010202
[    0.704142] RAX: 0000000000000000 RBX: ffff8800124147a0 RCX: 00000000000=
00000
[    0.704142] RDX: ffff880012860720 RSI: 0000000000000000 RDI: ffff8800124=
145c0
[    0.704142] RBP: ffff88001286bcd8 R08: 0000000000000001 R09: 00000000000=
00000
[    0.704142] R10: 0000000000000000 R11: 0000000000000001 R12: ffff8800128=
2a000
[    0.704142] R13: ffffffff81c1c600 R14: ffffffff81c1c600 R15: ffff8800124=
145d8
[    0.704142] FS:  0000000000000000(0000) GS:ffff880013a00000(0000) knlGS:=
0000000000000000
[    0.704142] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.704142] CR2: 0000000000000550 CR3: 0000000002211000 CR4: 00000000000=
006f0
[    0.704142] Stack:
[    0.704142]  ffff88001286bcf8 ffffffff81155424 ffff8800124147a0 ffff8800=
12414820
[    0.704142]  ffff88001286bd28 ffffffff8115558d ffff880012860720 ffff8800=
124147a0
[    0.704142]  ffff880012414958 ffffffff81c1c600 ffff88001286bd58 ffffffff=
8114a2e6
[    0.704142] Call Trace:
[    0.704142]  [<ffffffff81155424>] inode_to_bdi+0x36/0x45
[    0.704142]  [<ffffffff8115558d>] inode_wait_for_writeback+0x3f/0xc2
[    0.704142]  [<ffffffff8114a2e6>] evict+0xa2/0x15e
[    0.704142]  [<ffffffff8114b084>] iput+0x160/0x16d
[    0.704142]  [<ffffffff8115f8c0>] bdput+0xd/0xf
[    0.704142]  [<ffffffff8115fa28>] __blkdev_put+0x166/0x18a
[    0.704142]  [<ffffffff8116060c>] blkdev_put+0x114/0x11d
[    0.704142]  [<ffffffff81229627>] add_disk+0x44d/0x461
[    0.704142]  [<ffffffff82583a11>] brd_init+0x95/0x160
[    0.704142]  [<ffffffff8258397c>] ? ramdisk_size+0x1a/0x1a
[    0.704142]  [<ffffffff8255205b>] do_one_initcall+0xe8/0x175
[    0.704142]  [<ffffffff825522b8>] kernel_init_freeable+0x1d0/0x258
[    0.704142]  [<ffffffff81b46d9c>] ? rest_init+0xbc/0xbc
[    0.704142]  [<ffffffff81b46da5>] kernel_init+0x9/0xd5
[    0.704142]  [<ffffffff81b5d2fc>] ret_from_fork+0x7c/0xb0
[    0.704142]  [<ffffffff81b46d9c>] ? rest_init+0xbc/0xbc
[    0.704142] Code: ca 48 c1 ea 04 29 d0 ba 01 00 00 00 89 8f 80 08 00 00 =
ff c8 85 c0 0f 4e c2 89 87 84 08 00 00 c3 48 8b 87 10 01 00 00 55 48 89 e5 =
<48> 8b 80 50 05 00 00 5d 48 05 58 02 00 00 c3 48 89 fa 31 c0 b9=20
[    0.704142] RIP  [<ffffffff8121a84b>] blk_get_backing_dev_info+0xb/0x1a
[    0.704142]  RSP <ffff88001286bcd8>
[    0.704142] CR2: 0000000000000550
[    0.704142] ---[ end trace 5c64cf25111d3d67 ]---
[    0.704142] Kernel panic - not syncing: Fatal exception
[    0.704142] Kernel Offset: disabled

Elapsed time: 5
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-acpi-redef=
/40ceea09e84d1b9319236b27ad3162422310e5d0/vmlinuz-4.0.0-rc2-00135-g40ceea0 =
-append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 rd.udev.log-priorit=
y=3Derr systemd.log_target=3Djournal systemd.log_level=3Dwarning debug apic=
=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D=
-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 =
prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=
=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-acpi-redef/linux-=
devel:devel-xian-x86_64-201503051818:40ceea09e84d1b9319236b27ad3162422310e5=
d0:bisect-linux-3/.vmlinuz-40ceea09e84d1b9319236b27ad3162422310e5d0-2015030=
5211149-5-client7 branch=3Dlinux-devel/devel-xian-x86_64-201503051818 BOOT_=
IMAGE=3D/kernel/x86_64-acpi-redef/40ceea09e84d1b9319236b27ad3162422310e5d0/=
vmlinuz-4.0.0-rc2-00135-g40ceea0 drbd.minor_count=3D8'  -initrd /kernel-tes=
ts/initrd/yocto-minimal-x86_64.cgz -m 320 -smp 1 -net nic,vlan=3D1,model=3D=
e1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -rt=
c base=3Dlocaltime -pidfile /dev/shm/kboot/pid-yocto-client7-18 -serial fil=
e:/dev/shm/kboot/serial-yocto-client7-18 -daemonize -display none -monitor =
null=20

--Wb5NtZlyOqqy58h0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
