Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F35436B000D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:39:04 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g6-v6so10716551iti.7
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 15:39:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id c73-v6sor2987140itd.52.2018.07.06.15.39.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 15:39:03 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 06 Jul 2018 15:39:03 -0700
Message-ID: <000000000000af3c0305705c5425@google.com>
Subject: KASAN: slab-out-of-bounds Read in find_first_bit
From: syzbot <syzbot+5248ff94d8e3548ee995@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    526674536360 Add linux-next specific files for 20180706
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=13e6a50c400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
dashboard link: https://syzkaller.appspot.com/bug?extid=5248ff94d8e3548ee995
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=13a08a78400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17a08a78400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+5248ff94d8e3548ee995@syzkaller.appspotmail.com

random: sshd: uninitialized urandom read (32 bytes read)
random: sshd: uninitialized urandom read (32 bytes read)
random: sshd: uninitialized urandom read (32 bytes read)
IPVS: ftp: loaded support on port[0] = 21
==================================================================
BUG: KASAN: slab-out-of-bounds in find_first_bit+0xf7/0x100  
lib/find_bit.c:107
Read of size 8 at addr ffff8801d7548d50 by task syz-executor441/4505

CPU: 1 PID: 4505 Comm: syz-executor441 Not tainted  
4.18.0-rc3-next-20180706+ #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  find_first_bit+0xf7/0x100 lib/find_bit.c:107
  shrink_slab_memcg mm/vmscan.c:580 [inline]
  shrink_slab+0x5d0/0xdb0 mm/vmscan.c:672
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
RIP: 0033:0x4419d9
Code: e8 ec b5 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 7b 08 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007ffcd44b9a78 EFLAGS: 00000217 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00000000004419d9
RDX: 000000000000006b RSI: 0000000020000740 RDI: 0000000000000004
RBP: 0000000000000000 R08: 0000000000000006 R09: 0000000000000006
R10: 0000000000000006 R11: 0000000000000217 R12: 0000000000000000
R13: 6c616b7a79732f2e R14: 0000000000000000 R15: 0000000000000000

Allocated by task 4504:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  __do_kmalloc_node mm/slab.c:3682 [inline]
  __kmalloc_node+0x47/0x70 mm/slab.c:3689
  kmalloc_node include/linux/slab.h:555 [inline]
  kvmalloc_node+0x65/0xf0 mm/util.c:423
  kvmalloc include/linux/mm.h:557 [inline]
  kvzalloc include/linux/mm.h:565 [inline]
  memcg_alloc_shrinker_maps mm/memcontrol.c:386 [inline]
  mem_cgroup_css_online+0x169/0x3c0 mm/memcontrol.c:4685
  online_css+0x10c/0x350 kernel/cgroup/cgroup.c:4768
  css_create kernel/cgroup/cgroup.c:4839 [inline]
  cgroup_apply_control_enable+0x777/0xe90 kernel/cgroup/cgroup.c:2987
  cgroup_mkdir+0x88a/0x1170 kernel/cgroup/cgroup.c:5029
  kernfs_iop_mkdir+0x159/0x1e0 fs/kernfs/dir.c:1099
  vfs_mkdir+0x42e/0x6b0 fs/namei.c:3874
  do_mkdirat+0x27b/0x310 fs/namei.c:3897
  __do_sys_mkdir fs/namei.c:3913 [inline]
  __se_sys_mkdir fs/namei.c:3911 [inline]
  __x64_sys_mkdir+0x5c/0x80 fs/namei.c:3911
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 2873:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kfree+0xd9/0x260 mm/slab.c:3813
  single_release+0x8f/0xb0 fs/seq_file.c:596
  __fput+0x35d/0x930 fs/file_table.c:215
  ____fput+0x15/0x20 fs/file_table.c:251
  task_work_run+0x1ec/0x2a0 kernel/task_work.c:113
  tracehook_notify_resume include/linux/tracehook.h:192 [inline]
  exit_to_usermode_loop+0x313/0x370 arch/x86/entry/common.c:166
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8801d7548d40
  which belongs to the cache kmalloc-32 of size 32
The buggy address is located 16 bytes inside of
  32-byte region [ffff8801d7548d40, ffff8801d7548d60)
The buggy address belongs to the page:
page:ffffea00075d5200 count:1 mapcount:0 mapping:ffff8801da8001c0  
index:0xffff8801d7548fc1
flags: 0x2fffc0000000100(slab)
raw: 02fffc0000000100 ffffea00075d5448 ffffea00075d3b08 ffff8801da8001c0
raw: ffff8801d7548fc1 ffff8801d7548000 0000000100000039 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801d7548c00: 00 04 fc fc fc fc fc fc 00 03 fc fc fc fc fc fc
  ffff8801d7548c80: 00 05 fc fc fc fc fc fc 00 03 fc fc fc fc fc fc
> ffff8801d7548d00: 00 07 fc fc fc fc fc fc 00 00 05 fc fc fc fc fc
                                                  ^
  ffff8801d7548d80: 00 00 00 fc fc fc fc fc 00 00 00 fc fc fc fc fc
  ffff8801d7548e00: 00 00 00 fc fc fc fc fc 00 00 00 fc fc fc fc fc
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
