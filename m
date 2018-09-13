Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA34F8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:18:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k143-v6so7654909ite.5
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:18:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id i8-v6sor1976347iob.213.2018.09.13.02.18.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 02:18:03 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 13 Sep 2018 02:18:02 -0700
Message-ID: <00000000000016eb330575bd2fab@google.com>
Subject: KMSAN: kernel-infoleak in copy_page_to_iter (2)
From: syzbot <syzbot+2dcfeaf8cb49b05e8f1a@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    123906095e30 kmsan: introduce kmsan_interrupt_enter()/kmsa..
git tree:       https://github.com/google/kmsan.git/master
console output: https://syzkaller.appspot.com/x/log.txt?x=1249fcb8400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=848e40757852af3e
dashboard link: https://syzkaller.appspot.com/bug?extid=2dcfeaf8cb49b05e8f1a
compiler:       clang version 7.0.0 (trunk 334104)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=116ef050400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=122870ff800000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+2dcfeaf8cb49b05e8f1a@syzkaller.appspotmail.com

random: sshd: uninitialized urandom read (32 bytes read)
==================================================================
BUG: KMSAN: kernel-infoleak in copyout lib/iov_iter.c:140 [inline]
BUG: KMSAN: kernel-infoleak in copy_page_to_iter_iovec lib/iov_iter.c:212  
[inline]
BUG: KMSAN: kernel-infoleak in copy_page_to_iter+0x754/0x1b70  
lib/iov_iter.c:716
CPU: 0 PID: 4516 Comm: blkid Not tainted 4.17.0+ #9
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x185/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x188/0x2a0 mm/kmsan/kmsan.c:1125
  kmsan_internal_check_memory+0x17e/0x1f0 mm/kmsan/kmsan.c:1238
  kmsan_copy_to_user+0x7a/0x160 mm/kmsan/kmsan.c:1261
  copyout lib/iov_iter.c:140 [inline]
  copy_page_to_iter_iovec lib/iov_iter.c:212 [inline]
  copy_page_to_iter+0x754/0x1b70 lib/iov_iter.c:716
  generic_file_buffered_read mm/filemap.c:2185 [inline]
  generic_file_read_iter+0x2ef8/0x44d0 mm/filemap.c:2362
  blkdev_read_iter+0x20d/0x280 fs/block_dev.c:1930
  call_read_iter include/linux/fs.h:1778 [inline]
  new_sync_read fs/read_write.c:406 [inline]
  __vfs_read+0x775/0x9d0 fs/read_write.c:418
  vfs_read+0x36c/0x6b0 fs/read_write.c:452
  ksys_read fs/read_write.c:578 [inline]
  __do_sys_read fs/read_write.c:588 [inline]
  __se_sys_read fs/read_write.c:586 [inline]
  __x64_sys_read+0x1bf/0x3e0 fs/read_write.c:586
  do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7fdeff68f310
RSP: 002b:00007ffe999660b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fdeff68f310
RDX: 0000000000000100 RSI: 0000000001e78df8 RDI: 0000000000000003
RBP: 0000000001e78dd0 R08: 0000000000000028 R09: 0000000001680000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000001e78030
R13: 0000000000000100 R14: 0000000001e78080 R15: 0000000001e78de8

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:282 [inline]
  kmsan_alloc_meta_for_pages+0x161/0x3a0 mm/kmsan/kmsan.c:819
  kmsan_alloc_page+0x82/0xe0 mm/kmsan/kmsan.c:889
  __alloc_pages_nodemask+0xf7b/0x5cc0 mm/page_alloc.c:4402
  alloc_pages_current+0x6b1/0x970 mm/mempolicy.c:2093
  alloc_pages include/linux/gfp.h:494 [inline]
  __page_cache_alloc+0x95/0x320 mm/filemap.c:946
  pagecache_get_page+0x52b/0x1450 mm/filemap.c:1577
  grab_cache_page_write_begin+0x10d/0x190 mm/filemap.c:3089
  block_write_begin+0xf9/0x3a0 fs/buffer.c:2068
  blkdev_write_begin+0xf5/0x110 fs/block_dev.c:584
  generic_perform_write+0x438/0x9d0 mm/filemap.c:3139
  __generic_file_write_iter+0x43b/0xa10 mm/filemap.c:3264
  blkdev_write_iter+0x3a8/0x5f0 fs/block_dev.c:1910
  do_iter_readv_writev+0x81c/0xa20 include/linux/fs.h:1778
  do_iter_write+0x30d/0xd50 fs/read_write.c:959
  vfs_writev fs/read_write.c:1004 [inline]
  do_writev+0x3be/0x820 fs/read_write.c:1039
  __do_sys_writev fs/read_write.c:1112 [inline]
  __se_sys_writev fs/read_write.c:1109 [inline]
  __x64_sys_writev+0xe1/0x120 fs/read_write.c:1109
  do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x44/0xa9

Bytes 4-255 of 256 are uninitialized
Memory access starts at ffff8801b9903000
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
