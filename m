Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDC116B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 12:48:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id j22-v6so6710756pll.7
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 09:48:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f34-v6sor3599973ple.122.2018.07.07.09.48.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 09:48:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000000000008eb2820570638d2c@google.com>
References: <0000000000008eb2820570638d2c@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 7 Jul 2018 18:48:10 +0200
Message-ID: <CACT4Y+ZnmPECU9nFifDGB_kzV3ORQV86KFN+iGa8GAO24uCd3Q@mail.gmail.com>
Subject: Re: KASAN: slab-out-of-bounds Read in shrink_slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+59db6e2c8310927c035f@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <jbacik@fb.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, ying.huang@intel.com

On Sat, Jul 7, 2018 at 9:16 AM, syzbot
<syzbot+59db6e2c8310927c035f@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    526674536360 Add linux-next specific files for 20180706
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=17d88162400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> dashboard link: https://syzkaller.appspot.com/bug?extid=59db6e2c8310927c035f
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+59db6e2c8310927c035f@syzkaller.appspotmail.com

#syz dup: KASAN: stack-out-of-bounds Read in timerqueue_add

> kernel msg: ebtables bug: please report to author: Wrong len argument
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in shrink_slab_memcg mm/vmscan.c:593 [inline]
> BUG: KASAN: slab-out-of-bounds in shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
> Read of size 8 at addr ffff8801cc30b210 by task syz-executor2/20049
>
> CPU: 1 PID: 20049 Comm: syz-executor2 Not tainted 4.18.0-rc3-next-20180706+
> #1
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
>  print_address_description+0x6c/0x20b mm/kasan/report.c:256
>  kasan_report_error mm/kasan/report.c:354 [inline]
>  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
>  shrink_slab_memcg mm/vmscan.c:593 [inline]
>  shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
>  shrink_node+0x429/0x16a0 mm/vmscan.c:2736
>  shrink_zones mm/vmscan.c:2965 [inline]
>  do_try_to_free_pages+0x3e7/0x1290 mm/vmscan.c:3027
>  try_to_free_mem_cgroup_pages+0x49d/0xc90 mm/vmscan.c:3325
>  memory_high_write+0x283/0x310 mm/memcontrol.c:5597
>  cgroup_file_write+0x31f/0x840 kernel/cgroup/cgroup.c:3500
>  kernfs_fop_write+0x2ba/0x480 fs/kernfs/file.c:316
>  __vfs_write+0x117/0x9f0 fs/read_write.c:485
>  vfs_write+0x1fc/0x560 fs/read_write.c:549
>  ksys_write+0x101/0x260 fs/read_write.c:598
>  __do_sys_write fs/read_write.c:610 [inline]
>  __se_sys_write fs/read_write.c:607 [inline]
>  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x455ba9
> Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff
> 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f1b582d8c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 00007f1b582d96d4 RCX: 0000000000455ba9
> RDX: 0000000000000001 RSI: 0000000020000000 RDI: 0000000000000015
> RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 00000000004c2905 R14: 00000000004d4280 R15: 0000000000000000
>
> Allocated by task 2740:
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>  set_track mm/kasan/kasan.c:460 [inline]
>  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3554
>  dup_mmap kernel/fork.c:459 [inline]
>  dup_mm kernel/fork.c:1247 [inline]
>  copy_mm kernel/fork.c:1302 [inline]
>  copy_process.part.41+0x2fcc/0x7340 kernel/fork.c:1812
>  copy_process kernel/fork.c:1625 [inline]
>  _do_fork+0x291/0x12a0 kernel/fork.c:2110
>  __do_sys_clone kernel/fork.c:2217 [inline]
>  __se_sys_clone kernel/fork.c:2211 [inline]
>  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2211
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>
> Freed by task 18969:
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>  set_track mm/kasan/kasan.c:460 [inline]
>  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
>  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
>  __cache_free mm/slab.c:3498 [inline]
>  kmem_cache_free+0x86/0x2d0 mm/slab.c:3756
>  remove_vma+0x164/0x1b0 mm/mmap.c:185
>  exit_mmap+0x365/0x5b0 mm/mmap.c:3117
>  __mmput kernel/fork.c:974 [inline]
>  mmput+0x265/0x620 kernel/fork.c:995
>  exec_mmap fs/exec.c:1044 [inline]
>  flush_old_exec+0xbaf/0x2100 fs/exec.c:1276
>  load_elf_binary+0xa33/0x5610 fs/binfmt_elf.c:869
>  search_binary_handler+0x17d/0x570 fs/exec.c:1654
>  exec_binprm fs/exec.c:1696 [inline]
>  __do_execve_file.isra.36+0x171d/0x2730 fs/exec.c:1820
>  do_execveat_common fs/exec.c:1867 [inline]
>  do_execve fs/exec.c:1884 [inline]
>  __do_sys_execve fs/exec.c:1965 [inline]
>  __se_sys_execve fs/exec.c:1960 [inline]
>  __x64_sys_execve+0x8f/0xc0 fs/exec.c:1960
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>
> The buggy address belongs to the object at ffff8801cc30b148
>  which belongs to the cache vm_area_struct of size 200
> The buggy address is located 0 bytes to the right of
>  200-byte region [ffff8801cc30b148, ffff8801cc30b210)
> The buggy address belongs to the page:
> page:ffffea000730c2c0 count:1 mapcount:0 mapping:ffff8801da97b840
> index:0xffff8801cc30b880
> flags: 0x2fffc0000000100(slab)
> raw: 02fffc0000000100 ffffea0006b18248 ffffea0006c74308 ffff8801da97b840
> raw: ffff8801cc30b880 ffff8801cc30b040 0000000100000008 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff8801cc30b100: fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
>  ffff8801cc30b180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>
>> ffff8801cc30b200: fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb
>
>                          ^
>  ffff8801cc30b280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8801cc30b300: fb fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb
> ==================================================================
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/0000000000008eb2820570638d2c%40google.com.
> For more options, visit https://groups.google.com/d/optout.
