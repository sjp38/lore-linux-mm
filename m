Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A83818E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:51:05 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 135so31341245itk.5
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:51:05 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id l25sor17014576ioj.101.2018.12.30.23.51.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:51:04 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 30 Dec 2018 23:51:04 -0800
Message-ID: <000000000000c06550057e4cac7c@google.com>
Subject: KMSAN: uninit-value in mpol_rebind_mm
From: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, akpm@linux-foundation.org, glider@google.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, xieyisheng1@huawei.com, zhongjiang@huawei.com

Hello,

syzbot found the following crash on:

HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
git tree:       kmsan
console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
compiler:       clang version 8.0.0 (trunk 349734)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com

==================================================================
BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
CPU: 1 PID: 17420 Comm: syz-executor4 Not tainted 4.20.0-rc7+ #15
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x173/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x12e/0x2a0 mm/kmsan/kmsan.c:613
  __msan_warning+0x82/0xf0 mm/kmsan/kmsan_instr.c:295
  mpol_rebind_policy mm/mempolicy.c:353 [inline]
  mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
  update_tasks_nodemask+0x608/0xca0 kernel/cgroup/cpuset.c:1120
  update_nodemasks_hier kernel/cgroup/cpuset.c:1185 [inline]
  update_nodemask kernel/cgroup/cpuset.c:1253 [inline]
  cpuset_write_resmask+0x2a98/0x34b0 kernel/cgroup/cpuset.c:1728
  cgroup_file_write+0x44a/0x8e0 kernel/cgroup/cgroup.c:3473
  kernfs_fop_write+0x558/0x840 fs/kernfs/file.c:316
  __vfs_write+0x1f4/0xb70 fs/read_write.c:485
  __kernel_write+0x1fb/0x590 fs/read_write.c:506
  write_pipe_buf+0x1c0/0x270 fs/splice.c:797
  splice_from_pipe_feed fs/splice.c:503 [inline]
  __splice_from_pipe+0x48c/0xf10 fs/splice.c:627
  splice_from_pipe fs/splice.c:662 [inline]
  default_file_splice_write+0x1ee/0x3c0 fs/splice.c:809
  do_splice_from fs/splice.c:851 [inline]
  direct_splice_actor+0x19e/0x200 fs/splice.c:1023
  splice_direct_to_actor+0x852/0x1140 fs/splice.c:978
  do_splice_direct+0x342/0x580 fs/splice.c:1066
  do_sendfile+0x108f/0x1de0 fs/read_write.c:1439
  __do_sys_sendfile64 fs/read_write.c:1494 [inline]
  __se_sys_sendfile64+0x189/0x360 fs/read_write.c:1486
  __x64_sys_sendfile64+0x56/0x70 fs/read_write.c:1486
  do_syscall_64+0xbc/0xf0 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7
RIP: 0033:0x4579b9
Code: fd b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f132b74cc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 00000000004579b9
RDX: 0000000020000080 RSI: 0000000000000005 RDI: 0000000000000004
RBP: 000000000073bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 00007f132b74d6d4
R13: 00000000004c471e R14: 00000000004d7d10 R15: 00000000ffffffff

Uninit was stored to memory at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_save_stack mm/kmsan/kmsan.c:219 [inline]
  kmsan_internal_chain_origin+0x134/0x230 mm/kmsan/kmsan.c:439
  kmsan_memcpy_memmove_metadata+0x58f/0xfa0 mm/kmsan/kmsan.c:316
  kmsan_memcpy_metadata+0xb/0x10 mm/kmsan/kmsan.c:337
  __msan_memcpy+0x5b/0x70 mm/kmsan/kmsan_instr.c:133
  __mpol_dup+0x146/0x470 mm/mempolicy.c:2149
  mpol_dup include/linux/mempolicy.h:91 [inline]
  vma_dup_policy+0x93/0x190 mm/mempolicy.c:2116
  dup_mmap kernel/fork.c:529 [inline]
  dup_mm kernel/fork.c:1320 [inline]
  copy_mm kernel/fork.c:1375 [inline]
  copy_process+0x65e6/0xb020 kernel/fork.c:1919
  _do_fork+0x384/0x1050 kernel/fork.c:2218
  __do_sys_clone kernel/fork.c:2325 [inline]
  __se_sys_clone+0xf6/0x110 kernel/fork.c:2319
  __x64_sys_clone+0x62/0x80 kernel/fork.c:2319
  do_syscall_64+0xbc/0xf0 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7

Uninit was stored to memory at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_save_stack mm/kmsan/kmsan.c:219 [inline]
  kmsan_internal_chain_origin+0x134/0x230 mm/kmsan/kmsan.c:439
  kmsan_memcpy_memmove_metadata+0x58f/0xfa0 mm/kmsan/kmsan.c:316
  kmsan_memcpy_metadata+0xb/0x10 mm/kmsan/kmsan.c:337
  __msan_memcpy+0x5b/0x70 mm/kmsan/kmsan_instr.c:133
  __mpol_dup+0x146/0x470 mm/mempolicy.c:2149
  mpol_dup include/linux/mempolicy.h:91 [inline]
  vma_replace_policy mm/mempolicy.c:656 [inline]
  mbind_range mm/mempolicy.c:728 [inline]
  do_mbind mm/mempolicy.c:1223 [inline]
  kernel_mbind+0x254d/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]
  __se_sys_mbind+0x11c/0x130 mm/mempolicy.c:1350
  __x64_sys_mbind+0x6e/0x90 mm/mempolicy.c:1350
  do_syscall_64+0xbc/0xf0 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_internal_poison_shadow+0x92/0x150 mm/kmsan/kmsan.c:158
  kmsan_kmalloc+0xa6/0x130 mm/kmsan/kmsan_hooks.c:176
  kmem_cache_alloc+0x572/0xb90 mm/slub.c:2777
  mpol_new mm/mempolicy.c:276 [inline]
  do_mbind mm/mempolicy.c:1180 [inline]
  kernel_mbind+0x8a7/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]
  __se_sys_mbind+0x11c/0x130 mm/mempolicy.c:1350
  __x64_sys_mbind+0x6e/0x90 mm/mempolicy.c:1350
  do_syscall_64+0xbc/0xf0 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
