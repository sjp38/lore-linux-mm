Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1906B0006
	for <linux-mm@kvack.org>; Sat, 31 Mar 2018 16:47:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h132so7254710ioe.2
        for <linux-mm@kvack.org>; Sat, 31 Mar 2018 13:47:09 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id q207sor5062963iod.325.2018.03.31.13.47.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 31 Mar 2018 13:47:07 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 31 Mar 2018 13:47:07 -0700
Message-ID: <001a113f8bf6c849030568bb75d3@google.com>
Subject: WARNING: refcount bug in put_pid_ns
From: syzbot <syzbot+66a731f39da94bb14930@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot hit the following crash on upstream commit
9dd2326890d89a5179967c947dab2bab34d7ddee (Fri Mar 30 17:29:47 2018 +0000)
Merge tag 'ceph-for-4.16-rc8' of git://github.com/ceph/ceph-client
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=66a731f39da94bb14930

So far this crash happened 6 times on upstream.
syzkaller reproducer:  
https://syzkaller.appspot.com/x/repro.syz?id=6405492943355904
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5483914026024960
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-2760467897697295172
compiler: gcc (GCC) 7.1.1 20170620

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+66a731f39da94bb14930@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x194/0x24d lib/dump_stack.c:53
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail+0x8c0/0xa40 lib/fault-inject.c:149
refcount_t: underflow; use-after-free.
WARNING: CPU: 0 PID: 4478 at lib/refcount.c:187  
refcount_sub_and_test+0x167/0x1b0 lib/refcount.c:187
  should_failslab+0xec/0x120 mm/failslab.c:32
Kernel panic - not syncing: panic_on_warn set ...

  slab_pre_alloc_hook mm/slab.h:422 [inline]
  slab_alloc mm/slab.c:3366 [inline]
  kmem_cache_alloc+0x47/0x760 mm/slab.c:3540
  kmem_cache_zalloc include/linux/slab.h:691 [inline]
  fill_pool lib/debugobjects.c:110 [inline]
  __debug_object_init+0xa99/0x1040 lib/debugobjects.c:339
  debug_object_init+0x17/0x20 lib/debugobjects.c:391
  __init_work+0x2b/0x60 kernel/workqueue.c:506
  __memcg_schedule_kmem_cache_create mm/memcontrol.c:2203 [inline]
  memcg_schedule_kmem_cache_create mm/memcontrol.c:2223 [inline]
  memcg_kmem_get_cache+0x571/0x890 mm/memcontrol.c:2285
  slab_pre_alloc_hook mm/slab.h:427 [inline]
  slab_alloc mm/slab.c:3366 [inline]
  kmem_cache_alloc+0x186/0x760 mm/slab.c:3540
  proc_alloc_inode+0x1b/0x190 fs/proc/inode.c:63
  alloc_inode+0x65/0x180 fs/inode.c:209
  new_inode_pseudo+0x69/0x190 fs/inode.c:890
  proc_get_inode+0x20/0x620 fs/proc/inode.c:436
  proc_fill_super+0x1dd/0x300 fs/proc/inode.c:502
  mount_ns+0xc4/0x190 fs/super.c:1036
  proc_mount+0x7a/0x90 fs/proc/root.c:101
  mount_fs+0x66/0x2d0 fs/super.c:1222
  vfs_kern_mount.part.26+0xc6/0x4a0 fs/namespace.c:1037
  vfs_kern_mount fs/namespace.c:3292 [inline]
  kern_mount_data+0x50/0xb0 fs/namespace.c:3292
  pid_ns_prepare_proc+0x1e/0x80 fs/proc/root.c:222
  alloc_pid+0x87e/0xa00 kernel/pid.c:208
  copy_process.part.38+0x2516/0x4bd0 kernel/fork.c:1807
  copy_process kernel/fork.c:1606 [inline]
  _do_fork+0x1f7/0xf70 kernel/fork.c:2087
  SYSC_clone kernel/fork.c:2194 [inline]
  SyS_clone+0x37/0x50 kernel/fork.c:2188
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x454e79
RSP: 002b:00007fe845e3ec68 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007fe845e3f6d4 RCX: 0000000000454e79
RDX: 00000000200008c0 RSI: 0000000020000800 RDI: 000000002000c100
RBP: 000000000072bea0 R08: 0000000020000940 R09: 0000000000000000
R10: 0000000020000900 R11: 0000000000000246 R12: 0000000000000004
R13: 0000000000000051 R14: 00000000006f2838 R15: 0000000000000028
CPU: 0 PID: 4478 Comm: syz-executor1 Not tainted 4.16.0-rc7+ #372
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x194/0x24d lib/dump_stack.c:53
  panic+0x1e4/0x41c kernel/panic.c:183
IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
  __warn+0x1dc/0x200 kernel/panic.c:547
  report_bug+0x1f4/0x2b0 lib/bug.c:186
  fixup_bug.part.10+0x37/0x80 arch/x86/kernel/traps.c:178
  fixup_bug arch/x86/kernel/traps.c:247 [inline]
  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
  invalid_op+0x1b/0x40 arch/x86/entry/entry_64.S:986
RIP: 0010:refcount_sub_and_test+0x167/0x1b0 lib/refcount.c:187
RSP: 0018:ffff8801ad017318 EFLAGS: 00010282
RAX: dffffc0000000008 RBX: 0000000000000000 RCX: ffffffff815b193e
RDX: 0000000000000000 RSI: 1ffff10035a02e13 RDI: 1ffff10035a02de8
RBP: ffff8801ad0173a8 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8801ad0172d0 R11: 0000000000000000 R12: 1ffff10035a02e64
R13: 00000000ffffffff R14: 0000000000000001 R15: ffff8801ad2b0630
  refcount_dec_and_test+0x1a/0x20 lib/refcount.c:212
  kref_put include/linux/kref.h:69 [inline]
  put_pid_ns+0x9d/0xc0 kernel/pid_namespace.c:192
  free_nsproxy+0xfa/0x1f0 kernel/nsproxy.c:182
  switch_task_namespaces+0x9d/0xc0 kernel/nsproxy.c:229
  exit_task_namespaces+0x17/0x20 kernel/nsproxy.c:234
  copy_process.part.38+0x3aba/0x4bd0 kernel/fork.c:1988
  copy_process kernel/fork.c:1606 [inline]
  _do_fork+0x1f7/0xf70 kernel/fork.c:2087
  SYSC_clone kernel/fork.c:2194 [inline]
  SyS_clone+0x37/0x50 kernel/fork.c:2188
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x454e79
RSP: 002b:00007f64a187cc68 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007f64a187d6d4 RCX: 0000000000454e79
RDX: 00000000200008c0 RSI: 0000000020000800 RDI: 000000002000c100
RBP: 000000000072bea0 R08: 0000000020000940 R09: 0000000000000000
R10: 0000000020000900 R11: 0000000000000246 R12: 0000000000000004
R13: 0000000000000051 R14: 00000000006f2838 R15: 0000000000000028
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


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
