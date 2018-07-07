Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 435C26B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 03:15:03 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id b132-v6so11385749iti.2
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 00:15:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id o132-v6sor628473ioo.115.2018.07.07.00.15.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 00:15:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 07 Jul 2018 00:15:01 -0700
Message-ID: <000000000000f0319c05706389e0@google.com>
Subject: KASAN: use-after-free Read in shrink_slab
From: syzbot <syzbot+6a3cf57dddcf4e4ea443@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, willy@infradead.org, ying.huang@intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    526674536360 Add linux-next specific files for 20180706
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=1703690c400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
dashboard link: https://syzkaller.appspot.com/bug?extid=6a3cf57dddcf4e4ea443
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+6a3cf57dddcf4e4ea443@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: use-after-free in shrink_slab_memcg mm/vmscan.c:593 [inline]
BUG: KASAN: use-after-free in shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
Read of size 8 at addr ffff8801cc325210 by task syz-executor4/10315

CPU: 1 PID: 10315 Comm: syz-executor4 Not tainted 4.18.0-rc3-next-20180706+  
#1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  shrink_slab_memcg mm/vmscan.c:593 [inline]
  shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
  shrink_node+0x429/0x16a0 mm/vmscan.c:2736
  shrink_zones mm/vmscan.c:2965 [inline]
  do_try_to_free_pages+0x3e7/0x1290 mm/vmscan.c:3027
  try_to_free_mem_cgroup_pages+0x49d/0xc90 mm/vmscan.c:3325
  memory_high_write+0x283/0x310 mm/memcontrol.c:5597
  cgroup_file_write+0x31f/0x840 kernel/cgroup/cgroup.c:3500
  kernfs_fop_write+0x2ba/0x480 fs/kernfs/file.c:316
  __vfs_write+0x117/0x9f0 fs/read_write.c:485
  vfs_write+0x1fc/0x560 fs/read_write.c:549
  ksys_write+0x101/0x260 fs/read_write.c:598
  __do_sys_write fs/read_write.c:610 [inline]
  __se_sys_write fs/read_write.c:607 [inline]
  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ba9
Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fbb1ad41c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007fbb1ad426d4 RCX: 0000000000455ba9
RDX: 000000000000006b RSI: 0000000020000740 RDI: 0000000000000015
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004c28ce R14: 00000000004d4238 R15: 0000000000000000

Allocated by task 15966:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3554
  getname_flags+0xd0/0x5a0 fs/namei.c:140
  user_path_at_empty+0x2d/0x50 fs/namei.c:2625
  user_path_at include/linux/namei.h:57 [inline]
  vfs_statx+0x129/0x210 fs/stat.c:185
  vfs_stat include/linux/fs.h:3143 [inline]
  __do_sys_newstat+0x8f/0x110 fs/stat.c:337
  __se_sys_newstat fs/stat.c:333 [inline]
  __x64_sys_newstat+0x54/0x80 fs/stat.c:333
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 15966:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kmem_cache_free+0x86/0x2d0 mm/slab.c:3756
  putname+0xf2/0x130 fs/namei.c:261
  filename_lookup+0x397/0x510 fs/namei.c:2371
  user_path_at_empty+0x40/0x50 fs/namei.c:2625
  user_path_at include/linux/namei.h:57 [inline]
  vfs_statx+0x129/0x210 fs/stat.c:185
  vfs_stat include/linux/fs.h:3143 [inline]
  __do_sys_newstat+0x8f/0x110 fs/stat.c:337
  __se_sys_newstat fs/stat.c:333 [inline]
  __x64_sys_newstat+0x54/0x80 fs/stat.c:333
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8801cc324e00
  which belongs to the cache names_cache of size 4096
The buggy address is located 1040 bytes inside of
  4096-byte region [ffff8801cc324e00, ffff8801cc325e00)
The buggy address belongs to the page:
page:ffffea000730c900 count:1 mapcount:0 mapping:ffff8801da987dc0 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffffea0006609a08 ffffea0006b75508 ffff8801da987dc0
raw: 0000000000000000 ffff8801cc324e00 0000000100000001 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801cc325100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801cc325180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8801cc325200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                          ^
  ffff8801cc325280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801cc325300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
