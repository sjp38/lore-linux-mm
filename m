Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733746B100C
	for <linux-mm@kvack.org>; Sat, 18 Aug 2018 18:05:04 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s14-v6so10168684ioc.0
        for <linux-mm@kvack.org>; Sat, 18 Aug 2018 15:05:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id l8-v6sor2820596itc.121.2018.08.18.15.05.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 18 Aug 2018 15:05:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 18 Aug 2018 15:05:02 -0700
Message-ID: <0000000000003427e80573bcde5c@google.com>
Subject: KASAN: use-after-free Read in do_shrink_slab
From: syzbot <syzbot+d5f648a1bfe15678786b@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    1f7a4c73a739 Merge tag '9p-for-4.19-2' of git://github.com..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16c46d9a400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=68e80edb3c9718c5
dashboard link: https://syzkaller.appspot.com/bug?extid=d5f648a1bfe15678786b
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+d5f648a1bfe15678786b@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: use-after-free in do_shrink_slab+0xbd4/0xcb0 mm/vmscan.c:456
Read of size 8 at addr ffff8801ae513558 by task syz-executor6/20506

CPU: 0 PID: 20506 Comm: syz-executor6 Not tainted 4.18.0+ #195
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  do_shrink_slab+0xbd4/0xcb0 mm/vmscan.c:456
  shrink_slab_memcg mm/vmscan.c:600 [inline]
  shrink_slab+0x7b7/0x990 mm/vmscan.c:673
  shrink_node+0x429/0x16a0 mm/vmscan.c:2734
  shrink_zones mm/vmscan.c:2963 [inline]
  do_try_to_free_pages+0x3e7/0x1290 mm/vmscan.c:3025
  try_to_free_mem_cgroup_pages+0x49d/0xc90 mm/vmscan.c:3323
  memory_high_write+0x283/0x310 mm/memcontrol.c:5399
  cgroup_file_write+0x31f/0x840 kernel/cgroup/cgroup.c:3447
  kernfs_fop_write+0x2ba/0x480 fs/kernfs/file.c:316
  __vfs_write+0x117/0x9d0 fs/read_write.c:485
  __kernel_write+0x10c/0x380 fs/read_write.c:506
  write_pipe_buf+0x181/0x240 fs/splice.c:798
  splice_from_pipe_feed fs/splice.c:503 [inline]
  __splice_from_pipe+0x38e/0x7c0 fs/splice.c:627
  splice_from_pipe+0x1ea/0x340 fs/splice.c:662
  default_file_splice_write+0x3c/0x90 fs/splice.c:810
  do_splice_from fs/splice.c:852 [inline]
  direct_splice_actor+0x128/0x190 fs/splice.c:1019
  splice_direct_to_actor+0x318/0x8f0 fs/splice.c:974
  do_splice_direct+0x2d4/0x420 fs/splice.c:1062
  do_sendfile+0x623/0xe20 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1501 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x1fd/0x250 fs/read_write.c:1487
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457089
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f7151c7ac78 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007f7151c7b6d4 RCX: 0000000000457089
RDX: 0000000000000000 RSI: 0000000000000005 RDI: 0000000000000004
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d3cb0 R14: 00000000004c8769 R15: 0000000000000000

Allocated by task 19741:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  __do_kmalloc mm/slab.c:3718 [inline]
  __kmalloc+0x14e/0x760 mm/slab.c:3727
  kmalloc_array include/linux/slab.h:635 [inline]
  kcalloc include/linux/slab.h:646 [inline]
  iter_file_splice_write+0x25d/0x1010 fs/splice.c:693
  do_splice_from fs/splice.c:852 [inline]
  direct_splice_actor+0x128/0x190 fs/splice.c:1019
  splice_direct_to_actor+0x318/0x8f0 fs/splice.c:974
  do_splice_direct+0x2d4/0x420 fs/splice.c:1062
  do_sendfile+0x623/0xe20 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1487
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 19741:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kfree+0xd9/0x260 mm/slab.c:3813
  iter_file_splice_write+0x78d/0x1010 fs/splice.c:777
  do_splice_from fs/splice.c:852 [inline]
  direct_splice_actor+0x128/0x190 fs/splice.c:1019
  splice_direct_to_actor+0x318/0x8f0 fs/splice.c:974
  do_splice_direct+0x2d4/0x420 fs/splice.c:1062
  do_sendfile+0x623/0xe20 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1487
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8801ae513500
  which belongs to the cache kmalloc-256 of size 256
The buggy address is located 88 bytes inside of
  256-byte region [ffff8801ae513500, ffff8801ae513600)
The buggy address belongs to the page:
page:ffffea0006b944c0 count:1 mapcount:0 mapping:ffff8801dac007c0  
index:0xffff8801ae513b40
flags: 0x2fffc0000000100(slab)
raw: 02fffc0000000100 ffffea000701dd48 ffff8801dac01638 ffff8801dac007c0
raw: ffff8801ae513b40 ffff8801ae513000 000000010000000a 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801ae513400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801ae513480: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
> ffff8801ae513500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                     ^
  ffff8801ae513580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801ae513600: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
