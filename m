Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 697196B0700
	for <linux-mm@kvack.org>; Sun, 13 May 2018 04:56:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70-v6so13291771iof.10
        for <linux-mm@kvack.org>; Sun, 13 May 2018 01:56:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id o20-v6sor4690316iob.21.2018.05.13.01.56.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 01:56:03 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 13 May 2018 01:56:02 -0700
Message-ID: <000000000000eec34b056c128997@google.com>
Subject: KASAN: use-after-free Read in corrupted
From: syzbot <syzbot+3417712847e7219a60ee@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hmclauchlan@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot found the following crash on:

HEAD commit:    427fbe89261d Merge branch 'next' of git://git.kernel.org/p..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=148eb017800000
kernel config:  https://syzkaller.appspot.com/x/.config?x=fcce42b221691ff9
dashboard link: https://syzkaller.appspot.com/bug?extid=3417712847e7219a60ee
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=1770c477800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14ecdbc7800000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+3417712847e7219a60ee@syzkaller.appspotmail.com

R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
CPU: 0 PID: 4564 Comm: syz-executor214 Not tainted 4.17.0-rc4+ #44
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
==================================================================
Call Trace:
BUG: KASAN: use-after-free in __lock_acquire+0x3888/0x5140  
kernel/locking/lockdep.c:3310
Read of size 8 at addr ffff8801d8d69088 by task syz-executor214/4551
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113

  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  kmem_cache_alloc+0x2af/0x760 mm/slab.c:3552
  __d_alloc+0xc0/0xd30 fs/dcache.c:1638
  d_alloc_anon fs/dcache.c:1742 [inline]
  d_make_root+0x42/0x90 fs/dcache.c:1934
  fuse_fill_super+0x120e/0x1e20 fs/fuse/inode.c:1131
  mount_nodev+0x6b/0x110 fs/super.c:1210
  fuse_mount+0x2c/0x40 fs/fuse/inode.c:1192
  mount_fs+0xae/0x328 fs/super.c:1267
  vfs_kern_mount.part.34+0xd4/0x4d0 fs/namespace.c:1037
  vfs_kern_mount fs/namespace.c:1027 [inline]
  do_new_mount fs/namespace.c:2518 [inline]
  do_mount+0x564/0x3070 fs/namespace.c:2848
  ksys_mount+0x12d/0x140 fs/namespace.c:3064
  __do_sys_mount fs/namespace.c:3078 [inline]
  __se_sys_mount fs/namespace.c:3075 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3075
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x447cb9
RSP: 002b:00007f7a75bca918 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000447cb9
RDX: 00000000004b08d6 RSI: 0000000020000340 RDI: 00000000004c7485
RBP: 000000000000a001 R08: 00007f7a75bca930 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
CPU: 1 PID: 4551 Comm: syz-executor214 Not tainted 4.17.0-rc4+ #44
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x2fe mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  __lock_acquire+0x3888/0x5140 kernel/locking/lockdep.c:3310
  lock_acquire+0x1dc/0x520 kernel/locking/lockdep.c:3920
  down_write+0x87/0x120 kernel/locking/rwsem.c:70
  fuse_kill_sb_anon+0x50/0xb0 fs/fuse/inode.c:1200
  deactivate_locked_super+0x97/0x100 fs/super.c:316
  mount_nodev+0xfa/0x110 fs/super.c:1212
  fuse_mount+0x2c/0x40 fs/fuse/inode.c:1192
  mount_fs+0xae/0x328 fs/super.c:1267
  vfs_kern_mount.part.34+0xd4/0x4d0 fs/namespace.c:1037
  vfs_kern_mount fs/namespace.c:1027 [inline]
  do_new_mount fs/namespace.c:2518 [inline]
  do_mount+0x564/0x3070 fs/namespace.c:2848
  ksys_mount+0x12d/0x140 fs/namespace.c:3064
  __do_sys_mount fs/namespace.c:3078 [inline]
  __se_sys_mount fs/namespace.c:3075 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3075
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x447cb9
RSP: 002b:00007f7a75bca918 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000447cb9
RDX: 00000000004b08d6 RSI: 0000000020000340 RDI: 00000000004c7485
RBP: 000000000000a001 R08: 00007f7a75bca930 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000

CPU: 0 PID: 4580 Comm: syz-executor214 Not tainted 4.17.0-rc4+ #44
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Allocated by task 4551:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
Call Trace:
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  kmem_cache_alloc_trace+0x152/0x780 mm/slab.c:3620
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  kmalloc include/linux/slab.h:512 [inline]
  fuse_fill_super+0xc92/0x1e20 fs/fuse/inode.c:1096
  mount_nodev+0x6b/0x110 fs/super.c:1210
  fuse_mount+0x2c/0x40 fs/fuse/inode.c:1192
  mount_fs+0xae/0x328 fs/super.c:1267
  vfs_kern_mount.part.34+0xd4/0x4d0 fs/namespace.c:1037
  vfs_kern_mount fs/namespace.c:1027 [inline]
  do_new_mount fs/namespace.c:2518 [inline]
  do_mount+0x564/0x3070 fs/namespace.c:2848
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  ksys_mount+0x12d/0x140 fs/namespace.c:3064
  __do_sys_mount fs/namespace.c:3078 [inline]
  __se_sys_mount fs/namespace.c:3075 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3075
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 8:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kfree+0xd9/0x260 mm/slab.c:3813
  __rcu_reclaim kernel/rcu/rcu.h:173 [inline]
  rcu_do_batch kernel/rcu/tree.c:2675 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2930 [inline]
  __rcu_process_callbacks kernel/rcu/tree.c:2897 [inline]
  rcu_process_callbacks+0xa69/0x15f0 kernel/rcu/tree.c:2914
  __do_softirq+0x2e0/0xaf5 kernel/softirq.c:285

The buggy address belongs to the object at ffff8801d8d68dc0
  which belongs to the cache kmalloc-1024 of size 1024
The buggy address is located 712 bytes inside of
  1024-byte region [ffff8801d8d68dc0, ffff8801d8d691c0)
The buggy address belongs to the page:
page:ffffea0007635a00 count:1 mapcount:0 mapping:ffff8801d8d68040 index:0x0
  compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
  __should_failslab+0x124/0x180 mm/failslab.c:32
raw: 02fffc0000008100 ffff8801d8d68040 0000000000000000 0000000100000007
  should_failslab+0x9/0x14 mm/slab_common.c:1522
raw: ffffea00076407a0 ffffea00076335a0 ffff8801da800ac0 0000000000000000
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  kmem_cache_alloc+0x2af/0x760 mm/slab.c:3552
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801d8d68f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801d8d69000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8801d8d69080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  __d_alloc+0xc0/0xd30 fs/dcache.c:1638
                       ^
  ffff8801d8d69100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801d8d69180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
If you want to test a patch for this bug, please reply with:
#syz test: git://repo/address.git branch
and provide the patch inline or as an attachment.
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
