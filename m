Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC096B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 13:01:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h81-v6so12441572itb.0
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 10:01:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id g185sor5767361iof.13.2018.04.01.10.01.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 10:01:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 01 Apr 2018 10:01:02 -0700
Message-ID: <94eb2c0546040ebb4d0568cc6bdb@google.com>
Subject: general protection fault in kernfs_kill_sb
From: syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot hit the following crash on bpf-next commit
7828f20e3779e4e85e55371e0e43f5006a15fb41 (Sat Mar 31 00:17:57 2018 +0000)
Merge branch 'bpf-cgroup-bind-connect'
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=151de3f2be6b40ac8026

So far this crash happened 3 times on bpf-next.
C reproducer: https://syzkaller.appspot.com/x/repro.c?id=4857382450495488
syzkaller reproducer:  
https://syzkaller.appspot.com/x/repro.syz?id=4644052230209536
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5798498637185024
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=5909223872832634926
compiler: gcc (GCC) 7.1.1 20170620

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

kasan: GPF could be caused by NULL-ptr deref or user memory access
  should_failslab+0xec/0x120 mm/failslab.c:32
  slab_pre_alloc_hook mm/slab.h:422 [inline]
  slab_alloc mm/slab.c:3365 [inline]
  __do_kmalloc mm/slab.c:3703 [inline]
  __kmalloc+0x63/0x760 mm/slab.c:3714
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
    (ftrace buffer empty)
  kmalloc include/linux/slab.h:517 [inline]
  kzalloc include/linux/slab.h:701 [inline]
  register_shrinker+0x10e/0x2d0 mm/vmscan.c:268
Modules linked in:
CPU: 1 PID: 4471 Comm: syzkaller129261 Not tainted 4.16.0-rc6+ #43
  sget_userns+0xbbf/0xe40 fs/super.c:520
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51
RSP: 0018:ffff8801ae017658 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8801d97a6e98 RDI: ffff8801d97a6ea0
RBP: ffff8801ae017670 R08: ffffffff81d39d22 R09: 0000000000000004
R10: ffff8801ae017670 R11: 0000000000000000 R12: 0000000000000000
R13: ffff8801d91dec00 R14: ffff8801ae017700 R15: ffff8801d97a6e98
FS:  0000000001569880(0000) GS:ffff8801db100000(0000) knlGS:0000000000000000
  kernfs_mount_ns+0x13d/0x8b0 fs/kernfs/mount.c:320
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000006d0188 CR3: 00000001da40c005 CR4: 00000000001606e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  sysfs_mount+0xc2/0x1c0 fs/sysfs/mount.c:36
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  __list_del_entry include/linux/list.h:117 [inline]
  list_del include/linux/list.h:125 [inline]
  kernfs_kill_sb+0x9e/0x330 fs/kernfs/mount.c:361
  mount_fs+0x66/0x2d0 fs/super.c:1222
  vfs_kern_mount.part.26+0xc6/0x4a0 fs/namespace.c:1037
  sysfs_kill_sb+0x22/0x40 fs/sysfs/mount.c:50
  vfs_kern_mount fs/namespace.c:2509 [inline]
  do_new_mount fs/namespace.c:2512 [inline]
  do_mount+0xea4/0x2bb0 fs/namespace.c:2842
  deactivate_locked_super+0x88/0xd0 fs/super.c:312
  sget_userns+0xbda/0xe40 fs/super.c:522
  SYSC_mount fs/namespace.c:3058 [inline]
  SyS_mount+0xab/0x120 fs/namespace.c:3035
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  kernfs_mount_ns+0x13d/0x8b0 fs/kernfs/mount.c:320
  sysfs_mount+0xc2/0x1c0 fs/sysfs/mount.c:36
  mount_fs+0x66/0x2d0 fs/super.c:1222
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
  vfs_kern_mount.part.26+0xc6/0x4a0 fs/namespace.c:1037
RIP: 0033:0x442609
RSP: 002b:00007fff40a278e8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442609
RDX: 0000000020000140 RSI: 0000000020000040 RDI: 0000000020000000
RBP: 00007fff40a28190 R08: 00000000200002c0 R09: 0000000300000000
  vfs_kern_mount fs/namespace.c:2509 [inline]
  do_new_mount fs/namespace.c:2512 [inline]
  do_mount+0xea4/0x2bb0 fs/namespace.c:2842
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
R13: 0000000000000003 R14: 0000000000001380 R15: 00007fff40a27a28
  SYSC_mount fs/namespace.c:3058 [inline]
  SyS_mount+0xab/0x120 fs/namespace.c:3035
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x442609
RSP: 002b:00007fff40a278e8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442609
RDX: 0000000020000140 RSI: 0000000020000040 RDI: 0000000020000000
RBP: 00007fff40a28190 R08: 00000000200002c0 R09: 0000000300000000
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
R13: 0000000000000003 R14: 0000000000001380 R15: 00007fff40a27a28
Code: 00 00 00 00 ad de 49 39 c4 74 66 48 b8 00 02 00 00 00 00 ad de 48 89  
da 48 39 c3 74 65 48 c1 ea 03 48 b8 00 00 00 00 00 fc ff df <80> 3c 02 00  
75 7b 48 8b 13 48 39 f2 75 57 49 8d 7c 24 08 48 b8
RIP: __list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51 RSP:  
ffff8801ae017658
---[ end trace b14d521943ecadbd ]---


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

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
