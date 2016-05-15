Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCAE828E1
	for <linux-mm@kvack.org>; Sun, 15 May 2016 11:29:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so307037757pfw.0
        for <linux-mm@kvack.org>; Sun, 15 May 2016 08:29:01 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id g85si39006349pfb.124.2016.05.15.08.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 May 2016 08:29:00 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id xm6so1793865pab.3
        for <linux-mm@kvack.org>; Sun, 15 May 2016 08:29:00 -0700 (PDT)
From: Baozeng Ding <sploving1@gmail.com>
Subject: BUG: mm/slub NULL-ptr deref in get_freepointer
Message-ID: <573895B0.3050906@gmail.com>
Date: Sun, 15 May 2016 23:28:48 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi all,
I've got the following report NULL-ptr deref in  get_freepointer 
(mm/slub.c) while running syzkaller.
Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory 
accessgeneral protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 0 PID: 14637 Comm: syz-executor Tainted: G    B 4.6.0-rc2+ #16
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
task: ffff880067c71780 ti: ffff880067450000 task.ti: ffff880067450000
RIP: 0010:[<ffffffff81711b59>]  [<ffffffff81711b59>] 
deactivate_slab+0x99/0x710
RSP: 0018:ffff880067457b40  EFLAGS: 00010002
RAX: 0000000000000000 RBX: ffffea0000dab800 RCX: 0000000180180018
RDX: 0000000000000000 RSI: ffffea0000dab800 RDI: 0000000000010400
RBP: ffff880067457bf8 R08: 0000000000008018 R09: 0000000000008000
R10: 0000000000000000 R11: 0000000000000000 R12: 05fffc000004004c
R13: ffffea0001843640 R14: ffff88003e800c40 R15: ffff88003e806f00
FS:  00007ff2eec2e700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020008ff8 CR3: 00000000378cf000 CR4: 00000000000006f0
Stack:
  ffff880067457b90 ffffffff8177f632 ffff880067c71780 ffffffff8177f632
  ffffffff8177f632 0000000f67457b80 ffffffff811cf3e6 ffff880036ae7d88
  ffff880067457bc0 ffffffff8170ef8f 0000001000000008 ffff880036ae7d90
Call Trace:
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<ffffffff811cf3e6>] ? save_stack_trace+0x26/0x50 
arch/x86/kernel/stacktrace.c:67
  [<ffffffff8170ef8f>] ? set_track+0x6f/0x120 mm/slub.c:541
  [<ffffffff8170fd24>] ? init_object+0x64/0xa0 mm/slub.c:704
  [<ffffffff81710cde>] ? alloc_debug_processing+0x6e/0x1b0 mm/slub.c:1085
  [<ffffffff81712b27>] ___slab_alloc+0x167/0x500 mm/slub.c:2449
  [<ffffffff81403220>] ? lockdep_init_map+0xf0/0x13e0 
kernel/locking/lockdep.c:3120
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<ffffffff81403220>] ? lockdep_init_map+0xf0/0x13e0 
kernel/locking/lockdep.c:3120
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<ffffffff81712f0c>] __slab_alloc+0x4c/0x90 mm/slub.c:2475
  [<     inline     >] ? kmalloc include/linux/slab.h:483
  [<     inline     >] ? kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] ? alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<     inline     >] slab_alloc_node mm/slub.c:2538
  [<     inline     >] slab_alloc mm/slub.c:2580
  [<ffffffff81713e77>] __kmalloc+0x297/0x360 mm/slub.c:3561
  [<     inline     >] kmalloc include/linux/slab.h:483
  [<     inline     >] kzalloc include/linux/slab.h:622
  [<ffffffff8177f632>] alloc_pipe_info+0x292/0x3a0 fs/pipe.c:622
  [<     inline     >] get_pipe_inode fs/pipe.c:683
  [<ffffffff817807d4>] create_pipe_files+0xd4/0x8f0 fs/pipe.c:716
  [<ffffffff813fe03a>] ? up_write+0x1a/0x60 kernel/locking/rwsem.c:91
  [<ffffffff81780700>] ? fifo_open+0x9f0/0x9f0 fs/pipe.c:884
  [<ffffffff81670d60>] ? vma_is_stack_for_task+0xa0/0xa0 mm/util.c:235
  [<ffffffff81781029>] __do_pipe_flags+0x39/0x210 fs/pipe.c:774
  [<     inline     >] SYSC_pipe2 fs/pipe.c:822
  [<ffffffff817813cc>] SyS_pipe2+0x8c/0x170 fs/pipe.c:816
  [<ffffffff81781340>] ? do_pipe_flags+0x140/0x140 fs/pipe.c:807
  [<ffffffff816ba430>] ? find_mergeable_anon_vma+0xd0/0xd0 mm/mmap.c:1090
  [<ffffffff814011ad>] ? trace_hardirqs_off+0xd/0x10 
kernel/locking/lockdep.c:2772
  [<ffffffff8100301b>] ? trace_hardirqs_on_thunk+0x1b/0x1d 
arch/x86/entry/thunk_64.S:42
  [<ffffffff85c8ab80>] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
Code: 89 54 05 00 4d 89 e8 49 8b 7f 08 48 89 de 48 89 4c 24 68 66 83 6c 
24 68 01 4c 8b 4c 24 68 e8 7f fe ff ff 84 c0 74 cc 49 63 47 20 <49> 8b 
0c 04 48 85 c9 74 0c 4d 89 e5 48 8b 53 10 49 89 cc eb bb
RIP  [<     inline     >] get_freepointer mm/slub.c:245
RIP  [<ffffffff81711b59>] deactivate_slab+0x99/0x710 mm/slub.c:1893
  RSP <ffff880067457b40>
---[ end trace b34379b339f95a27 ]---

Best Regards,
Baozeng Ding

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
