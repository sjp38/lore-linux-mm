Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 246636B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:26:10 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f5-v6so1692344plf.18
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 04:26:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k91-v6si2252788pld.248.2018.06.20.04.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 04:26:08 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: xfs: circular locking dependency between fs_reclaim and sb_internal
 [kernel 4.18]
Message-ID: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
Date: Wed, 20 Jun 2018 20:25:51 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

I'm hitting below lockdep warning (essentially same with
http://lkml.kernel.org/r/1518666178.6070.25.camel@gmail.com ) as of commit
ba4dbdedd3edc279 ("Merge tag 'jfs-4.18' of git://github.com/kleikamp/linux-shaggy")
on linux.git . I think that this became visible by commit 93781325da6e07af
("lockdep: fix fs_reclaim annotation") which went to 4.18-rc1. What should we do?

[   63.207781] 
[   63.471926] ======================================================
[   64.432812] WARNING: possible circular locking dependency detected
[   64.948272] 4.18.0-rc1+ #594 Tainted: G                T
[   65.512546] ------------------------------------------------------
[   65.519722] kswapd0/79 is trying to acquire lock:
[   65.525792] 00000000f3581fab (sb_internal){.+.+}, at: xfs_trans_alloc+0xe0/0x120 [xfs]
[   66.034497] 
[   66.034497] but task is already holding lock:
[   66.661024] 00000000c7665973 (fs_reclaim){+.+.}, at: __fs_reclaim_acquire+0x0/0x30
[   67.554480] 
[   67.554480] which lock already depends on the new lock.
[   67.554480] 
[   68.760085] 
[   68.760085] the existing dependency chain (in reverse order) is:
[   69.258520] 
[   69.258520] -> #1 (fs_reclaim){+.+.}:
[   69.623516] 
[   69.623516] -> #0 (sb_internal){.+.+}:
[   70.152322] 
[   70.152322] other info that might help us debug this:
[   70.152322] 
[   70.164923]  Possible unsafe locking scenario:
[   70.164923] 
[   70.168174]        CPU0                    CPU1
[   70.170441]        ----                    ----
[   70.171827]   lock(fs_reclaim);
[   70.172771]                                lock(sb_internal);
[   70.174447]                                lock(fs_reclaim);
[   70.176104]   lock(sb_internal);
[   70.177062] 
[   70.177062]  *** DEADLOCK ***
[   70.177062] 
[   70.178789] 1 lock held by kswapd0/79:
[   70.179893]  #0: 00000000c7665973 (fs_reclaim){+.+.}, at: __fs_reclaim_acquire+0x0/0x30
[   70.182213] 
[   70.182213] stack backtrace:
[   70.184100] CPU: 2 PID: 79 Comm: kswapd0 Kdump: loaded Tainted: G                T 4.18.0-rc1+ #594
[   70.187320] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   70.191064] Call Trace:
[   70.192487]  ? dump_stack+0x85/0xcb
[   70.194186]  ? print_circular_bug.isra.37+0x1d7/0x1e4
[   70.196343]  ? __lock_acquire+0x126e/0x1330
[   70.198232]  ? lock_acquire+0x51/0x70
[   70.199964]  ? lock_acquire+0x51/0x70
[   70.201735]  ? xfs_trans_alloc+0xe0/0x120 [xfs]
[   70.203727]  ? __sb_start_write+0x126/0x1a0       /* __preempt_count_add at ./arch/x86/include/asm/preempt.h:76 (inlined by) percpu_down_read_preempt_disable at ./include/linux/percpu-rwsem.h:38 (inlined by) percpu_down_read at ./include/linux/percpu-rwsem.h:59 (inlined by) __sb_start_write at fs/super.c:1403 */
[   70.205618]  ? xfs_trans_alloc+0xe0/0x120 [xfs]
[   70.207624]  ? xfs_trans_alloc+0xe0/0x120 [xfs]   /* sb_start_intwrite at ./include/linux/fs.h:1601 (inlined by) xfs_trans_alloc at fs/xfs/xfs_trans.c:259 */
[   70.209599]  ? xfs_iomap_write_allocate+0x1df/0x360 [xfs] /* xfs_iomap_write_allocate at fs/xfs/xfs_iomap.c:713 */
[   70.211801]  ? xfs_iunlock+0x6f/0x180 [xfs]
[   70.213657]  ? xfs_map_blocks+0x1c6/0x240 [xfs]   /* xfs_map_blocks at fs/xfs/xfs_aops.c:424 */
[   70.215602]  ? xfs_do_writepage+0x16d/0x7c0 [xfs] /* xfs_writepage_map at fs/xfs/xfs_aops.c:979 (inlined by) xfs_do_writepage at fs/xfs/xfs_aops.c:1162 */
[   70.217585]  ? find_held_lock+0x2d/0x90
[   70.219308]  ? clear_page_dirty_for_io+0x19d/0x470
[   70.221291]  ? xfs_vm_writepage+0x31/0x60 [xfs]   /* xfs_vm_writepage at fs/xfs/xfs_aops.c:1181 */
[   70.223201]  ? pageout.isra.53+0x122/0x4f0        /* pageout at mm/vmscan.c:683 */
[   70.224967]  ? shrink_page_list+0xcc4/0x18f0      /* shrink_page_list at mm/vmscan.c:1200 */
[   70.226771]  ? shrink_inactive_list+0x2e8/0x5b0   /* spin_lock_irq at ./include/linux/spinlock.h:335 (inlined by) shrink_inactive_list at mm/vmscan.c:1787 */
[   70.228624]  ? shrink_node_memcg+0x367/0x780      /* shrink_list at mm/vmscan.c:2095 (inlined by) shrink_node_memcg at mm/vmscan.c:2358 */
[   70.230433]  ? __lock_is_held+0x55/0x90
[   70.232167]  ? shrink_node+0xc9/0x470
[   70.233792]  ? shrink_node+0xc9/0x470             /* shrink_node at mm/vmscan.c:2576 */
[   70.235395]  ? balance_pgdat+0x154/0x3a0          /* kswapd_shrink_node at mm/vmscan.c:3304 (inlined by) balance_pgdat at mm/vmscan.c:3405 */
[   70.237070]  ? finish_task_switch+0x93/0x290
[   70.238861]  ? kswapd+0x151/0x370
[   70.240464]  ? wait_woken+0xa0/0xa0
[   70.242069]  ? balance_pgdat+0x3a0/0x3a0
[   70.243746]  ? kthread+0x112/0x130
[   70.245294]  ? kthread_create_worker_on_cpu+0x70/0x70
[   70.247281]  ? ret_from_fork+0x24/0x30
