Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE5918E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 22:47:05 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so33605452qte.10
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 19:47:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12sor38841569qtx.51.2018.12.30.19.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 19:47:04 -0800 (PST)
Subject: Re: kernel panic: corrupted stack end in wb_workfn
References: <000000000000b05d0c057e492e33@google.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <9fe14b68-5a3c-5964-62b1-53a4ef4c0b76@lca.pw>
Date: Sun, 30 Dec 2018 22:47:02 -0500
MIME-Version: 1.0
In-Reply-To: <000000000000b05d0c057e492e33@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, shakeelb@google.com, syzkaller-bugs@googlegroups.com, willy@infradead.org

Ah, it has KASAN_EXTRA. Need this patch then.

https://lore.kernel.org/lkml/20181228020639.80425-1-cai@lca.pw/

or to use GCC from the HEAD which suppose to reduce the stack-size in half.

shrink_page_list
shrink_inactive_list

Those things are 7k each, so 32k would be soon gone.

On 12/30/18 10:41 PM, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    195303136f19 Merge tag 'kconfig-v4.21-2' of git://git.kern..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=176c0ebf400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
> dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
> 
> Kernel panic - not syncing: corrupted stack end detected inside scheduler
> CPU: 0 PID: 7 Comm: kworker/u4:0 Not tainted 4.20.0+ #396
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> 01/01/2011
> Workqueue: writeback wb_workfn (flush-8:0)
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
>  panic+0x2ad/0x55f kernel/panic.c:189
>  schedule_debug kernel/sched/core.c:3285 [inline]
>  __schedule+0x1ec6/0x1ed0 kernel/sched/core.c:3394
>  preempt_schedule_common+0x1f/0xe0 kernel/sched/core.c:3596
>  preempt_schedule+0x4d/0x60 kernel/sched/core.c:3622
>  ___preempt_schedule+0x16/0x18
>  __raw_spin_unlock_irqrestore include/linux/spinlock_api_smp.h:161 [inline]
>  _raw_spin_unlock_irqrestore+0xbb/0xd0 kernel/locking/spinlock.c:184
>  spin_unlock_irqrestore include/linux/spinlock.h:384 [inline]
>  __remove_mapping+0x932/0x1af0 mm/vmscan.c:967
>  shrink_page_list+0x6610/0xc2e0 mm/vmscan.c:1461
>  shrink_inactive_list+0x77b/0x1c60 mm/vmscan.c:1961
>  shrink_list mm/vmscan.c:2273 [inline]
>  shrink_node_memcg+0x7a8/0x19a0 mm/vmscan.c:2538
>  shrink_node+0x3e1/0x17f0 mm/vmscan.c:2753
>  shrink_zones mm/vmscan.c:2987 [inline]
>  do_try_to_free_pages+0x3df/0x12a0 mm/vmscan.c:3049
>  try_to_free_pages+0x4d0/0xb90 mm/vmscan.c:3265
>  __perform_reclaim mm/page_alloc.c:3920 [inline]
>  __alloc_pages_direct_reclaim mm/page_alloc.c:3942 [inline]
>  __alloc_pages_slowpath+0xa5a/0x2db0 mm/page_alloc.c:4335
>  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
>  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
>  alloc_pages include/linux/gfp.h:509 [inline]
>  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
>  pagecache_get_page+0x396/0xf00 mm/filemap.c:1615
>  find_or_create_page include/linux/pagemap.h:322 [inline]
>  ext4_mb_load_buddy_gfp+0xddf/0x1e70 fs/ext4/mballoc.c:1158
>  ext4_mb_load_buddy fs/ext4/mballoc.c:1241 [inline]
>  ext4_mb_regular_allocator+0x634/0x1590 fs/ext4/mballoc.c:2190
>  ext4_mb_new_blocks+0x1de3/0x4840 fs/ext4/mballoc.c:4538
>  ext4_ext_map_blocks+0x2eef/0x6180 fs/ext4/extents.c:4404
>  ext4_map_blocks+0x8f7/0x1b60 fs/ext4/inode.c:636
>  mpage_map_one_extent fs/ext4/inode.c:2480 [inline]
>  mpage_map_and_submit_extent fs/ext4/inode.c:2533 [inline]
>  ext4_writepages+0x2564/0x4170 fs/ext4/inode.c:2884
>  do_writepages+0x9a/0x1a0 mm/page-writeback.c:2335
>  __writeback_single_inode+0x20a/0x1660 fs/fs-writeback.c:1316
>  writeback_sb_inodes+0x71f/0x1210 fs/fs-writeback.c:1580
>  __writeback_inodes_wb+0x1b9/0x340 fs/fs-writeback.c:1649
>  wb_writeback+0xa73/0xfc0 fs/fs-writeback.c:1758
> oom_reaper: reaped process 7963 (syz-executor189), now anon-rss:0kB,
> file-rss:0kB, shmem-rss:0kB
> rsyslogd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0,
> oom_score_adj=0
>  wb_check_start_all fs/fs-writeback.c:1882 [inline]
>  wb_do_writeback fs/fs-writeback.c:1908 [inline]
>  wb_workfn+0xee9/0x1790 fs/fs-writeback.c:1942
>  process_one_work+0xc90/0x1c40 kernel/workqueue.c:2153
>  worker_thread+0x17f/0x1390 kernel/workqueue.c:2296
>  kthread+0x35a/0x440 kernel/kthread.c:246
>  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> CPU: 1 PID: 7840 Comm: rsyslogd Not tainted 4.20.0+ #396
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
>  dump_header+0x253/0x1239 mm/oom_kill.c:451
>  oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:966
>  out_of_memory+0x8ba/0x1480 mm/oom_kill.c:1133
>  __alloc_pages_may_oom mm/page_alloc.c:3666 [inline]
>  __alloc_pages_slowpath+0x230c/0x2db0 mm/page_alloc.c:4379
>  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
>  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
>  alloc_pages include/linux/gfp.h:509 [inline]
>  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
>  page_cache_read mm/filemap.c:2373 [inline]
>  filemap_fault+0x1595/0x25f0 mm/filemap.c:2557
>  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6317
>  __do_fault+0x100/0x6b0 mm/memory.c:2997
>  do_read_fault mm/memory.c:3409 [inline]
>  do_fault mm/memory.c:3535 [inline]
>  handle_pte_fault mm/memory.c:3766 [inline]
>  __handle_mm_fault+0x392f/0x5630 mm/memory.c:3890
>  handle_mm_fault+0x54f/0xc70 mm/memory.c:3927
>  do_user_addr_fault arch/x86/mm/fault.c:1475 [inline]
>  __do_page_fault+0x5f6/0xd70 arch/x86/mm/fault.c:1541
>  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1572
>  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
> RIP: 0033:0x7f00f990e1fd
> Code: Bad RIP value.
> RSP: 002b:00007f00f6eade30 EFLAGS: 00010293
> RAX: 0000000000000fd2 RBX: 000000000111f170 RCX: 00007f00f990e1fd
> RDX: 0000000000000fff RSI: 00007f00f86e25a0 RDI: 0000000000000004
> RBP: 0000000000000000 R08: 000000000110a260 R09: 0000000000000000
> R10: 74616c7567657227 R11: 0000000000000293 R12: 000000000065e420
> R13: 00007f00f6eae9c0 R14: 00007f00f9f53040 R15: 0000000000000003
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
> 
> 
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
> 
