Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 038AC8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 15:51:06 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j3so24670385itf.5
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 12:51:05 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v20sor23634487ita.10.2018.12.28.12.51.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 12:51:04 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 28 Dec 2018 12:51:04 -0800
Message-ID: <000000000000b57d19057e1b383d@google.com>
Subject: KASAN: use-after-free Read in filemap_fault
From: syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, darrick.wong@oracle.com, hannes@cmpxchg.org, hughd@google.com, jack@suse.cz, josef@toxicpanda.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, willy@infradead.org

Hello,

syzbot found the following crash on:

HEAD commit:    6a1d293238c1 Add linux-next specific files for 20181224
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=102ca567400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=f9369d117d073843
dashboard link: https://syzkaller.appspot.com/bug?extid=b437b5a429d680cf2217
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=15f059b3400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ac602d400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com

sshd (8177) used greatest stack depth: 15720 bytes left
hrtimer: interrupt took 27544 ns
==================================================================
BUG: KASAN: use-after-free in filemap_fault+0x2818/0x2a70 mm/filemap.c:2559
Read of size 8 at addr ffff8881b15026b0 by task syz-executor997/8196

CPU: 0 PID: 8196 Comm: syz-executor997 Not tainted 4.20.0-rc7-next-20181224  
#188
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
  print_address_description.cold.5+0x9/0x1ff mm/kasan/report.c:187
  kasan_report.cold.6+0x1b/0x39 mm/kasan/report.c:317
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:135
  filemap_fault+0x2818/0x2a70 mm/filemap.c:2559
  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6326
  __do_fault+0x176/0x6f0 mm/memory.c:3013
  do_shared_fault mm/memory.c:3479 [inline]
  do_fault mm/memory.c:3554 [inline]
  handle_pte_fault mm/memory.c:3781 [inline]
  __handle_mm_fault+0x373b/0x55f0 mm/memory.c:3905
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3942
  do_user_addr_fault arch/x86/mm/fault.c:1475 [inline]
  __do_page_fault+0x5f6/0xd70 arch/x86/mm/fault.c:1541
  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1572
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
RIP: 0033:0x400a57
Code: 00 00 00 00 e8 ba 59 04 00 8b 03 85 c0 74 d8 c7 45 08 00 00 00 00 83  
7d 04 05 0f 87 49 02 00 00 8b 45 04 ff 24 c5 e8 e4 4a 00 <c7> 04 25 fa ff  
00 20 2e 2f 62 75 66 c7 04 25 fe ff 00 20 73 00 b9
RSP: 002b:00007f48cd9c0dc0 EFLAGS: 00010293
RAX: 0000000000000000 RBX: 00000000006dbc28 RCX: 0000000000446409
RDX: 0000000000446409 RSI: 0000000000000081 RDI: 00000000006dbc2c
RBP: 00000000006dbc20 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dbc2c
R13: 00007ffd0bb6676f R14: 00007f48cd9c19c0 R15: 00000000006dbd2c

Allocated by task 8196:
  save_stack+0x43/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  kasan_kmalloc+0xcb/0xd0 mm/kasan/common.c:482
  kasan_slab_alloc+0x12/0x20 mm/kasan/common.c:397
  kmem_cache_alloc+0x130/0x730 mm/slab.c:3541
  vm_area_alloc+0x7a/0x1d0 kernel/fork.c:331
  mmap_region+0x9d7/0x1cd0 mm/mmap.c:1756
  do_mmap+0xa22/0x1230 mm/mmap.c:1559
  do_mmap_pgoff include/linux/mm.h:2421 [inline]
  vm_mmap_pgoff+0x213/0x2c0 mm/util.c:350
  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:90 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:90
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 8197:
  save_stack+0x43/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:444
  kasan_slab_free+0xe/0x10 mm/kasan/common.c:452
  __cache_free mm/slab.c:3485 [inline]
  kmem_cache_free+0x83/0x290 mm/slab.c:3747
  vm_area_free+0x1c/0x20 kernel/fork.c:350
  remove_vma+0x13a/0x180 mm/mmap.c:185
  remove_vma_list mm/mmap.c:2585 [inline]
  __do_munmap+0x729/0xf50 mm/mmap.c:2822
  do_munmap mm/mmap.c:2830 [inline]
  mmap_region+0x6a7/0x1cd0 mm/mmap.c:1729
  do_mmap+0xa22/0x1230 mm/mmap.c:1559
  do_mmap_pgoff include/linux/mm.h:2421 [inline]
  vm_mmap_pgoff+0x213/0x2c0 mm/util.c:350
  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:90 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:90
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8881b1502670
  which belongs to the cache vm_area_struct of size 200
The buggy address is located 64 bytes inside of
  200-byte region [ffff8881b1502670, ffff8881b1502738)
The buggy address belongs to the page:
page:ffffea0006c54080 count:1 mapcount:0 mapping:ffff8881da9827c0  
index:0xffff8881b1502eb0
flags: 0x2fffc0000000200(slab)
raw: 02fffc0000000200 ffffea0007477408 ffffea0006c5ec48 ffff8881da9827c0
raw: ffff8881b1502eb0 ffff8881b1502040 0000000100000004 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8881b1502580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8881b1502600: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fb fb
> ffff8881b1502680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                      ^
  ffff8881b1502700: fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc fb
  ffff8881b1502780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
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
