Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A66A16B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 09:07:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p138-v6so2277147itc.3
        for <linux-mm@kvack.org>; Fri, 04 May 2018 06:07:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id f80-v6sor957788itc.142.2018.05.04.06.07.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 06:07:03 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 04 May 2018 06:07:03 -0700
Message-ID: <00000000000004e875056b60fffe@google.com>
Subject: KASAN: use-after-free Read in should_fail
From: syzbot <syzbot+7f7b8d424eb621469f0a@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hmclauchlan@fb.com, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot found the following crash on:

HEAD commit:    150426981426 Merge tag 'linux-kselftest-4.17-rc4' of git:/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=17e4975b800000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5a1dc06635c10d27
dashboard link: https://syzkaller.appspot.com/bug?extid=7f7b8d424eb621469f0a
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=10652e57800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11036e47800000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+7f7b8d424eb621469f0a@syzkaller.appspotmail.com

R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
CPU: 0 PID: 4531 Comm: syz-executor152 Not tainted 4.17.0-rc3+ #32
==================================================================
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
BUG: KASAN: use-after-free in __lock_acquire+0x3888/0x5140  
kernel/locking/lockdep.c:3310
Read of size 8 at addr ffff8801b75554c8 by task syz-executor152/4523
Call Trace:

  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  __do_kmalloc mm/slab.c:3716 [inline]
  __kmalloc_track_caller+0x2c4/0x760 mm/slab.c:3733
  kstrdup+0x39/0x70 mm/util.c:56
  fs_set_subtype fs/namespace.c:2443 [inline]
  do_new_mount fs/namespace.c:2521 [inline]
  do_mount+0x25e7/0x3070 fs/namespace.c:2848
  ksys_mount+0x12d/0x140 fs/namespace.c:3064
  __do_sys_mount fs/namespace.c:3078 [inline]
  __se_sys_mount fs/namespace.c:3075 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3075
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x447cd9
RSP: 002b:00007fbb431e0828 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000447cd9
RDX: 00000000004b08f6 RSI: 0000000020000100 RDI: 00000000004c74a5
RBP: 000000000000c000 R08: 00007fbb431e0840 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
CPU: 1 PID: 4523 Comm: syz-executor152 Not tainted 4.17.0-rc3+ #32
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
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
RIP: 0033:0x447cd9
RSP: 002b:00007fbb431e0828 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000447cd9
RDX: 00000000004b08f6 RSI: 0000000020000100 RDI: 00000000004c74a5
RBP: 000000000000c000 R08: 00007fbb431e0840 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000

Allocated by task 4523:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  kmem_cache_alloc_trace+0x152/0x780 mm/slab.c:3620
  kmalloc include/linux/slab.h:512 [inline]
  fuse_fill_super+0xc92/0x1e20 fs/fuse/inode.c:1096
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

Freed by task 4312:
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

The buggy address belongs to the object at ffff8801b7555200
  which belongs to the cache kmalloc-1024 of size 1024
The buggy address is located 712 bytes inside of
  1024-byte region [ffff8801b7555200, ffff8801b7555600)
The buggy address belongs to the page:
page:ffffea0006dd5500 count:1 mapcount:0 mapping:ffff8801b7554000 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffff8801b7554000 0000000000000000 0000000100000007
raw: ffffea0006dd9020 ffffea0006db0d20 ffff8801da800ac0 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801b7555380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801b7555400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8801b7555480: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                               ^
  ffff8801b7555500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801b7555580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
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
