Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43DAF6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 06:48:30 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id fg3so118718391obb.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 03:48:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d191si17071294ioe.15.2016.04.17.03.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 03:48:29 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: use-after-free in free_vmap_area_noflush
Message-ID: <571369F7.1040300@oracle.com>
Date: Sun, 17 Apr 2016 06:48:23 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, npiggin@suse.de, "jeremy@goop.org >> Jeremy Fitzhardinge" <jeremy@goop.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[ 1912.231243] ==================================================================

[ 1912.231319] BUG: KASAN: use-after-free in free_vmap_area_noflush+0x106/0x210 at addr ffff88034ba75568

[ 1912.231329] Read of size 8 by task syz-executor/2704

[ 1912.231336] =============================================================================

[ 1912.231346] BUG kmalloc-128 (Not tainted): kasan: bad access detected

[ 1912.231349] -----------------------------------------------------------------------------

[ 1912.231349]

[ 1912.231354] Disabling lock debugging due to kernel taint

[ 1912.231366] INFO: Allocated in 0xbbbbbbbbbbbbbbbb age=18446702227844796754 cpu=0 pid=0

[ 1912.231380] 	devkmsg_write+0xd7/0x320

[ 1912.231395] 	___slab_alloc+0x7af/0x870

[ 1912.231401] 	__slab_alloc.isra.22+0xf4/0x130

[ 1912.231407] 	__kmalloc+0x1fe/0x340

[ 1912.231413] 	devkmsg_write+0xd7/0x320

[ 1912.231423] 	__vfs_write+0x44b/0x520

[ 1912.231445] syzkaller: executing program 54:

[ 1912.231445] mmap(&(0x7f0000000000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)

[ 1912.231445] r0 = syz_open_dev$vcsn(&(0x7f0000000000)="2f6465762f7663732300", 0x3, 0x4000)

[ 1912.231445] mmap(&(0x7f0000000000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)

[ 1912.231445] setsockopt$NETLINK_LISTEN_ALL_NSID(r0, 0x10e, 0x8, &(0x7f0000001000-0x3)=0x7, 0x4)

[ 1912.231445] mmap(&(0x7f0000000000)=nil, (0x65c000), 0x3, 0x32, 0xffffffffffffffff, 0x0)

[ 1912.231445] socket(0x18, 0x7, 0x1)

[ 1912.231445] select(0x40, &(0x7f0000658000+0x3ca)={0x503e, 0x7, 0xd3ef857af37e84aa, 0x3ff, 0x9, 0x3, 0x10000, 0x80}, &(0x7f0000659000-0x40)={0x4, 0x0, 0x6, 0x4, 0x9, 0x7, 0x2, 0x9}, &(0x7f000051e000)={0xa8, 0x8, 0x3, 0x400, 0x9, 0x68613453, 0x4, 0x100000001}, &(0x7f0000658000)={0x0, 0x0})

[ 1912.231452] 	vfs_write+0x225/0x4a0

[ 1912.231459] 	SyS_write+0xe5/0x1b0

[ 1912.231473] 	do_syscall_64+0x2a6/0x4a0

[ 1912.231508] 	return_from_SYSCALL_64+0x0/0x6a

[ 1912.231515] INFO: Freed in 0x10018914f age=18446702227844796754 cpu=0 pid=0

[ 1912.231522] 	devkmsg_write+0x2ba/0x320

[ 1912.231527] 	__slab_free+0x6a/0x2f0

[ 1912.231532] 	kfree+0x22c/0x270

[ 1912.231539] 	devkmsg_write+0x2ba/0x320

[ 1912.231545] 	__vfs_write+0x44b/0x520

[ 1912.231552] 	vfs_write+0x225/0x4a0

[ 1912.231558] 	SyS_write+0xe5/0x1b0

[ 1912.231565] 	do_syscall_64+0x2a6/0x4a0

[ 1912.231572] 	return_from_SYSCALL_64+0x0/0x6a

[ 1912.231583] INFO: Slab 0xffffea000d2e9d00 objects=35 used=6 fp=0xffff88034ba75568 flags=0x2fffff80004080

[ 1912.231588] INFO: Object 0xffff88034ba75560 @offset=5472 fp=0xbbbbbbbbbbbbbbbb

[ 1912.231588]

[ 1912.231602] Redzone ffff88034ba75558: 70 a8 6f a2 ff ff ff ff                          p.o.....

[ 1912.231609] Object ffff88034ba75560: bb bb bb bb bb bb bb bb 20 70 a7 4b 03 88 ff ff  ........ p.K....

[ 1912.231615] Object ffff88034ba75570: 72 3a 20 65 78 65 63 75 74 69 6e 67 20 70 72 6f  r: executing pro

[ 1912.231621] Object ffff88034ba75580: 67 72 61 6d 20 39 38 3a 0a 6d 6d 61 70 28 26 28  gram 98:.mmap(&(

[ 1912.231627] Object ffff88034ba75590: 30 78 37 66 30 30 30 30 34 33 30 30 30 30 29 3d  0x7f0000430000)=

[ 1912.231633] Object ffff88034ba755a0: 6e 69 6c 2c 20 28 30 78 33 30 30 30 29 2c 20 30  nil, (0x3000), 0

[ 1912.231639] Object ffff88034ba755b0: 78 33 2c 20 30 78 64 64 38 63 38 38 61 31 61 38  x3, 0xdd8c88a1a8

[ 1912.231645] Object ffff88034ba755c0: 31 34 61 32 62 33 2c 20 30 78 66 66 66 66 66 66  14a2b3, 0xffffff

[ 1912.231652] Object ffff88034ba755d0: 66 66 66 66 66 66 66 66 66 66 2c 20 30 78 30 29  ffffffffff, 0x0)

[ 1912.231657] Redzone ffff88034ba755e0: 0a 00 36 a2 ff ff ff ff                          ..6.....

[ 1912.231663] Padding ffff88034ba75718: 4f 91 18 00 01 00 00 00                          O.......

[ 1912.231678] CPU: 0 PID: 2704 Comm: syz-executor Tainted: G    B           4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998

[ 1912.231702]  0000000000000000 00000000335bd7ae ffff88034bb47698 ffffffffa3fc9d01

[ 1912.231710]  ffffffff00000000 fffffbfff5dad2a0 0000000041b58ab3 ffffffffae65eee0

[ 1912.231718]  ffffffffa3fc9b88 00000000335bd7ae ffff880335f5c000 ffffffffae67cede

[ 1912.231720] Call Trace:

[ 1912.231748] dump_stack (lib/dump_stack.c:53)
[ 1912.231780] print_trailer (mm/slub.c:668)
[ 1912.231788] object_err (mm/slub.c:675)
[ 1912.231796] kasan_report_error (mm/kasan/report.c:180 mm/kasan/report.c:276)
[ 1912.231830] __asan_report_load8_noabort (mm/kasan/report.c:319)
[ 1912.231846] free_vmap_area_noflush (mm/vmalloc.c:709)
[ 1912.231869] remove_vm_area (mm/vmalloc.c:721 mm/vmalloc.c:730 mm/vmalloc.c:1470)
[ 1912.231876] __vunmap (mm/vmalloc.c:1489)
[ 1912.231883] vfree (mm/vmalloc.c:1542)
[ 1912.231895] kvfree (mm/util.c:326)
[ 1912.231909] __free_fdtable (fs/file.c:51)
[ 1912.231916] put_files_struct (fs/file.c:439)
[ 1912.231950] exit_files (fs/file.c:465)
[ 1912.231963] do_exit (kernel/exit.c:744)
[ 1912.231988] do_group_exit (kernel/exit.c:862)
[ 1912.231996] get_signal (kernel/signal.c:2307)
[ 1912.232011] do_signal (arch/x86/kernel/signal.c:784)
[ 1912.232113] exit_to_usermode_loop (arch/x86/entry/common.c:231)
[ 1912.232122] do_syscall_64 (arch/x86/entry/common.c:274 arch/x86/entry/common.c:329 arch/x86/entry/common.c:355)
[ 1912.232131] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 1912.232134] Memory state around the buggy address:

[ 1912.232140]  ffff88034ba75400: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc

[ 1912.232145]  ffff88034ba75480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 1912.232151] >ffff88034ba75500: fc fc fc fc fc fc fc fc fc fc fc fc fc fb fb fb

[ 1912.232154]                                                           ^

[ 1912.232160]  ffff88034ba75580: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc

[ 1912.232165]  ffff88034ba75600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 1912.232168] ==================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
