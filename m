Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32E606B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:01:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id y13-v6so6410295ita.8
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:01:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 184-v6sor45479itb.38.2018.07.19.11.01.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 11:01:01 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 19 Jul 2018 11:01:01 -0700
Message-ID: <00000000000047116205715df655@google.com>
Subject: KASAN: use-after-free Read in generic_perform_write
From: syzbot <syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, willy@infradead.org

Hello,

syzbot found the following crash on:

HEAD commit:    1c34981993da Add linux-next specific files for 20180719
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=16e6ac44400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=7002497517b09aec
dashboard link: https://syzkaller.appspot.com/bug?extid=b173e77096a8ba815511
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com

IPVS: length: 141 != 24
XFS (loop5): Invalid superblock magic number
==================================================================
BUG: KASAN: use-after-free in memcpy include/linux/string.h:345 [inline]
BUG: KASAN: use-after-free in iov_iter_copy_from_user_atomic+0xb8d/0xfa0  
lib/iov_iter.c:916
Read of size 21 at addr ffff880190103660 by task kworker/0:3/4927

CPU: 0 PID: 4927 Comm: kworker/0:3 Not tainted 4.18.0-rc5-next-20180719+ #11
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Workqueue: events p9_write_work
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  check_memory_region_inline mm/kasan/kasan.c:260 [inline]
  check_memory_region+0x13e/0x1b0 mm/kasan/kasan.c:267
  memcpy+0x23/0x50 mm/kasan/kasan.c:302
  memcpy include/linux/string.h:345 [inline]
  iov_iter_copy_from_user_atomic+0xb8d/0xfa0 lib/iov_iter.c:916
  generic_perform_write+0x469/0x6c0 mm/filemap.c:3058
  __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3175
  ext4_file_write_iter+0x390/0x1450 fs/ext4/file.c:266
  call_write_iter include/linux/fs.h:1826 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x6af/0x9d0 fs/read_write.c:487
  vfs_write+0x1fc/0x560 fs/read_write.c:549
  kernel_write+0xab/0x120 fs/read_write.c:526
  p9_fd_write net/9p/trans_fd.c:427 [inline]
  p9_write_work+0x6f1/0xd50 net/9p/trans_fd.c:476
  process_one_work+0xc73/0x1ba0 kernel/workqueue.c:2153
  worker_thread+0x189/0x13c0 kernel/workqueue.c:2296
  kthread+0x345/0x410 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:415

Allocated by task 13072:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  __do_kmalloc mm/slab.c:3718 [inline]
  __kmalloc+0x14e/0x760 mm/slab.c:3727
  kmalloc include/linux/slab.h:518 [inline]
  p9_fcall_alloc+0x1e/0x90 net/9p/client.c:237
  p9_tag_alloc net/9p/client.c:266 [inline]
  p9_client_prepare_req.part.8+0x107/0xa00 net/9p/client.c:640
  p9_client_prepare_req net/9p/client.c:675 [inline]
  p9_client_rpc+0x242/0x1330 net/9p/client.c:675
  p9_client_version net/9p/client.c:890 [inline]
  p9_client_create+0xca4/0x1537 net/9p/client.c:974
  v9fs_session_init+0x21a/0x1a80 fs/9p/v9fs.c:400
  v9fs_mount+0x7c/0x900 fs/9p/vfs_super.c:135
  legacy_get_tree+0x131/0x460 fs/fs_context.c:674
  vfs_get_tree+0x1cb/0x5c0 fs/super.c:1743
  do_new_mount fs/namespace.c:2603 [inline]
  do_mount+0x6f2/0x1e20 fs/namespace.c:2927
  ksys_mount+0x12d/0x140 fs/namespace.c:3143
  __do_sys_mount fs/namespace.c:3157 [inline]
  __se_sys_mount fs/namespace.c:3154 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3154
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 13072:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kfree+0xd9/0x260 mm/slab.c:3813
  p9_free_req+0xb5/0x120 net/9p/client.c:338
  p9_client_rpc+0xa8e/0x1330 net/9p/client.c:739
  p9_client_version net/9p/client.c:890 [inline]
  p9_client_create+0xca4/0x1537 net/9p/client.c:974
  v9fs_session_init+0x21a/0x1a80 fs/9p/v9fs.c:400
  v9fs_mount+0x7c/0x900 fs/9p/vfs_super.c:135
  legacy_get_tree+0x131/0x460 fs/fs_context.c:674
  vfs_get_tree+0x1cb/0x5c0 fs/super.c:1743
  do_new_mount fs/namespace.c:2603 [inline]
  do_mount+0x6f2/0x1e20 fs/namespace.c:2927
  ksys_mount+0x12d/0x140 fs/namespace.c:3143
  __do_sys_mount fs/namespace.c:3157 [inline]
  __se_sys_mount fs/namespace.c:3154 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3154
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff880190103640
  which belongs to the cache kmalloc-16384 of size 16384
The buggy address is located 32 bytes inside of
  16384-byte region [ffff880190103640, ffff880190107640)
The buggy address belongs to the page:
page:ffffea0006404000 count:1 mapcount:0 mapping:ffff8801da802200 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000010200(slab|head)
raw: 02fffc0000010200 ffffea000643b808 ffffea0006452c08 ffff8801da802200
raw: 0000000000000000 ffff880190103640 0000000100000001 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff880190103500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880190103580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ffff880190103600: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                                        ^
  ffff880190103680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880190103700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
