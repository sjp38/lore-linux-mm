Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 136E46B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:24:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so97417130pgx.6
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:24:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i10si1836646pgc.63.2016.12.15.02.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 02:24:41 -0800 (PST)
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201612151924.HJJ69799.VSFLHOQFFMOtOJ@I-love.SAKURA.ne.jp>
Date: Thu, 15 Dec 2016 19:24:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: pmladek@suse.com, sergey.senozhatsky.work@gmail.com, vegard.nossum@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> This patch adds a watchdog which periodically reports number of memory
> allocating tasks, dying tasks and OOM victim tasks when some task is
> spending too long time inside __alloc_pages_slowpath(). This patch also
> serves as a hook for obtaining additional information using SystemTap
> (e.g. examine other variables using printk(), capture a crash dump by
> calling panic()) by triggering a callback only when an stall is detected.
> Ability to take administrator-controlled actions based on some threshold
> is a big advantage gained by introducing a state tracking.

Resuming this thread as an answer to Michal's question at [1]
in order to focus on watchdog discussion.

http://I-love.SAKURA.ne.jp/tmp/serial-20161215-4.txt.xz (second run with
one-liner stall report per each second at [2]) showed that warn_alloc()
not reporting __GFP_NOWARN allocation stalls misses a chance to tell the
administrator that the system got stuck inside page allocator.

--------------------
[  177.666356] Out of memory: Kill process 5337 (a.out) score 999 or sacrifice child
[  177.670005] Killed process 5337 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  189.898315] a.out(5337): page allocation stalls for 10139ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  199.759537] a.out(5337): page allocation stalls for 20001ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  209.970568] a.out(5337): page allocation stalls for 30211ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  219.763326] a.out(5337): page allocation stalls for 40005ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  229.759599] a.out(5337): page allocation stalls for 50001ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
(...snipped...)
[  336.436299] Out of memory: Kill process 5491 (a.out) score 999 or sacrifice child
[  336.439684] Killed process 5491 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  336.447065] oom_reaper: reaped process 5491 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  339.759355] a.out(5337): page allocation stalls for 160001ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  349.760561] a.out(5337): page allocation stalls for 170002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  359.760531] a.out(5337): page allocation stalls for 180002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
(...snipped...)
[  789.759370] a.out(5337): page allocation stalls for 610001ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  799.760557] a.out(5337): page allocation stalls for 620002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  800.879431] sysrq: SysRq : Show State
[  800.880939]   task                        PC stack   pid father
[  800.883078] systemd         D11320     1      0 0x00000000
[  800.885028]  ffff88006d58d840 ffff88006d58ac40 ffff88006baf8040 ffff880074450040
[  800.887757]  ffff8800757da218 ffffc90000017590 ffffffff817524d8 ffffffff813a55b6
[  800.890420]  0000000000000000 ffff8800757da218 0000000000000296 ffff880074450040
[  800.893148] Call Trace:
[  800.894114]  [<ffffffff817524d8>] ? __schedule+0x2f8/0xbc0
[  800.896169]  [<ffffffff813a55b6>] ? debug_object_activate+0x166/0x210
[  800.898420]  [<ffffffff81752ddd>] schedule+0x3d/0x90
[  800.900215]  [<ffffffff8175806a>] schedule_timeout+0x22a/0x540
[  800.902346]  [<ffffffff81127910>] ? lock_timer_base+0xa0/0xa0
[  800.904492]  [<ffffffff811332ac>] ? ktime_get+0xac/0x140
[  800.906453]  [<ffffffff81752176>] io_schedule_timeout+0xa6/0x110
[  800.908587]  [<ffffffff81209c76>] congestion_wait+0x86/0x260
[  800.910691]  [<ffffffff810eee70>] ? prepare_to_wait_event+0xf0/0xf0
[  800.912948]  [<ffffffff811fad79>] shrink_inactive_list+0x639/0x680
[  800.915200]  [<ffffffff811fb656>] shrink_node_memcg+0x526/0x7d0
[  800.917689]  [<ffffffff811fb9e1>] shrink_node+0xe1/0x310
[  800.919774]  [<ffffffff811fbf4d>] do_try_to_free_pages+0xed/0x380
[  800.922350]  [<ffffffff811fc311>] try_to_free_pages+0x131/0x3f0
[  800.924567]  [<ffffffff81281af8>] __alloc_pages_slowpath+0x3ac/0x9db
[  800.926962]  [<ffffffff811e9966>] __alloc_pages_nodemask+0x456/0x4e0
[  800.929316]  [<ffffffff81247507>] alloc_pages_current+0x97/0x1b0
[  800.931586]  [<ffffffff811dc485>] ? find_get_entry+0x5/0x300
[  800.933721]  [<ffffffff811dbc2d>] __page_cache_alloc+0x15d/0x1a0
[  800.936030]  [<ffffffff811dddbc>] ? pagecache_get_page+0x2c/0x2b0
[  800.938314]  [<ffffffff811e06ce>] filemap_fault+0x48e/0x6d0
[  800.940394]  [<ffffffff811e0579>] ? filemap_fault+0x339/0x6d0
[  800.942717]  [<ffffffffa0272781>] xfs_filemap_fault+0x71/0x1e0 [xfs]
[  800.945106]  [<ffffffff811dcfd3>] ? filemap_map_pages+0x2d3/0x5d0
[  800.947649]  [<ffffffff8121a700>] __do_fault+0x80/0x130
[  800.949708]  [<ffffffff8121ec9b>] do_fault+0x4cb/0x6d0
[  800.951729]  [<ffffffff81220e4b>] handle_mm_fault+0x74b/0x1010
[  800.953979]  [<ffffffff8122075b>] ? handle_mm_fault+0x5b/0x1010
[  800.956294]  [<ffffffff810783a5>] ? __do_page_fault+0x175/0x530
[  800.958626]  [<ffffffff8107847a>] __do_page_fault+0x24a/0x530
[  800.960875]  [<ffffffff81078790>] do_page_fault+0x30/0x80
[  800.962956]  [<ffffffff8175b598>] page_fault+0x28/0x30
(...snipped...)
[  802.637484] kswapd0         D10584    56      2 0x00000000
[  802.639758]  0000000000000000 ffff88004b572c40 ffff88007048ca40 ffff880072174a40
[  802.642735]  ffff8800757da218 ffffc900006ff6b0 ffffffff817524d8 ffffc900006ff660
[  802.645755]  ffffc900006ff670 ffff8800757da218 0000000044e61594 ffff880072174a40
[  802.648778] Call Trace:
[  802.650042]  [<ffffffff817524d8>] ? __schedule+0x2f8/0xbc0
[  802.652339]  [<ffffffff81752ddd>] schedule+0x3d/0x90
[  802.654425]  [<ffffffff817573fd>] rwsem_down_read_failed+0xfd/0x180
[  802.657362]  [<ffffffffa0261b9f>] ? xfs_map_blocks+0x9f/0x550 [xfs]
[  802.660493]  [<ffffffff81395b78>] call_rwsem_down_read_failed+0x18/0x30
[  802.663313]  [<ffffffffa02858f4>] ? xfs_ilock+0x1a4/0x350 [xfs]
[  802.665936]  [<ffffffff810f714f>] down_read_nested+0xaf/0xc0
[  802.668457]  [<ffffffffa02858f4>] ? xfs_ilock+0x1a4/0x350 [xfs]
[  802.670988]  [<ffffffffa02858f4>] xfs_ilock+0x1a4/0x350 [xfs]
[  802.673534]  [<ffffffffa0261b9f>] xfs_map_blocks+0x9f/0x550 [xfs]
[  802.676124]  [<ffffffffa0262293>] xfs_do_writepage+0x243/0x940 [xfs]
[  802.678773]  [<ffffffff811eca54>] ? clear_page_dirty_for_io+0xb4/0x310
[  802.681872]  [<ffffffffa02629cb>] xfs_vm_writepage+0x3b/0x70 [xfs]
[  802.684442]  [<ffffffff811f77a4>] pageout.isra.49+0x1a4/0x460
[  802.686880]  [<ffffffff811f9e00>] shrink_page_list+0x8e0/0xbd0
[  802.689343]  [<ffffffff811fa94f>] shrink_inactive_list+0x20f/0x680
[  802.691864]  [<ffffffff811fb656>] shrink_node_memcg+0x526/0x7d0
[  802.694240]  [<ffffffff811fb9e1>] shrink_node+0xe1/0x310
[  802.696405]  [<ffffffff811fd1a2>] kswapd+0x362/0x9b0
[  802.698472]  [<ffffffff811fce40>] ? mem_cgroup_shrink_node+0x3b0/0x3b0
[  802.701031]  [<ffffffff810bfe92>] kthread+0x102/0x120
[  802.703175]  [<ffffffff810fbca9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  802.705797]  [<ffffffff810bfd90>] ? kthread_park+0x60/0x60
[  802.708074]  [<ffffffff8175a33a>] ret_from_fork+0x2a/0x40
(...snipped...)
[  809.550458] a.out           R  running task    11240  5337   4599 0x00000086
[  809.553340]  ffff88006e77f850 0000000000000000 0000000000000000 0000000000000000
[  809.556327]  0000000000000000 ffff8800740d7498 ffffc90007e57268 ffffffff817596b7
[  809.559340]  ffff88006e77f838 ffffc90007e57288 ffffffff812177ea ffffffff81ccf160
[  809.562334] Call Trace:
[  809.563607]  [<ffffffff817596b7>] ? _raw_spin_unlock+0x27/0x40
[  809.565997]  [<ffffffff812177ea>] ? __list_lru_count_one.isra.2+0x4a/0x80
[  809.568709]  [<ffffffff811f729e>] ? shrink_slab+0x31e/0x680
[  809.570994]  [<ffffffff81187c8e>] ? delayacct_end+0x3e/0x60
[  809.573319]  [<ffffffff810fdcd9>] ? lock_acquire+0xc9/0x250
[  809.575595]  [<ffffffff811fbbfc>] ? shrink_node+0x2fc/0x310
[  809.577864]  [<ffffffff811fbf4d>] ? do_try_to_free_pages+0xed/0x380
[  809.580396]  [<ffffffff811fc311>] ? try_to_free_pages+0x131/0x3f0
[  809.582831]  [<ffffffff81281af8>] ? __alloc_pages_slowpath+0x3ac/0x9db
[  809.585433]  [<ffffffff811e9966>] ? __alloc_pages_nodemask+0x456/0x4e0
[  809.588026]  [<ffffffff81247507>] ? alloc_pages_current+0x97/0x1b0
[  809.590476]  [<ffffffff81252e9a>] ? new_slab+0x4ca/0x6a0
[  809.592664]  [<ffffffff81255091>] ? ___slab_alloc+0x3a1/0x620
[  809.594982]  [<ffffffffa029a836>] ? kmem_alloc+0x96/0x120 [xfs]
[  809.597347]  [<ffffffffa029a836>] ? kmem_alloc+0x96/0x120 [xfs]
[  809.599736]  [<ffffffff812841ec>] ? __slab_alloc+0x46/0x7d
[  809.601961]  [<ffffffff812566c1>] ? __kmalloc+0x301/0x3b0
[  809.604177]  [<ffffffffa029a836>] ? kmem_alloc+0x96/0x120 [xfs]
[  809.606583]  [<ffffffff81254639>] ? kfree+0x1f9/0x330
[  809.608683]  [<ffffffffa02a227b>] ? xfs_log_commit_cil+0x54b/0x690 [xfs]
[  809.611335]  [<ffffffffa029ab86>] ? kmem_zone_alloc+0x96/0x120 [xfs]
[  809.613853]  [<ffffffffa0299bd7>] ? __xfs_trans_commit+0x97/0x250 [xfs]
[  809.616430]  [<ffffffffa029a2cc>] ? __xfs_trans_roll+0x6c/0xe0 [xfs]
[  809.618963]  [<ffffffffa029a365>] ? xfs_trans_roll+0x25/0x40 [xfs]
[  809.621401]  [<ffffffffa028969d>] ? xfs_itruncate_extents+0x2bd/0x730 [xfs]
[  809.624332]  [<ffffffffa02673e3>] ? xfs_free_eofblocks+0x1e3/0x240 [xfs]
[  809.626963]  [<ffffffffa0289cf4>] ? xfs_release+0x94/0x150 [xfs]
[  809.629384]  [<ffffffffa02720a5>] ? xfs_file_release+0x15/0x20 [xfs]
[  809.631887]  [<ffffffff81289ff8>] ? __fput+0xf8/0x200
[  809.633954]  [<ffffffff8128a13e>] ? ____fput+0xe/0x10
[  809.636023]  [<ffffffff810be103>] ? task_work_run+0x83/0xc0
[  809.638305]  [<ffffffff8109d43f>] ? do_exit+0x31f/0xcd0
[  809.640431]  [<ffffffff810abcfe>] ? get_signal+0xde/0x9b0
[  809.642609]  [<ffffffff8109de7c>] ? do_group_exit+0x4c/0xc0
[  809.644856]  [<ffffffff810abf7f>] ? get_signal+0x35f/0x9b0
[  809.647073]  [<ffffffffa02744f9>] ? xfs_file_buffered_aio_write+0xa9/0x3b0 [xfs]
[  809.649904]  [<ffffffff81036687>] ? do_signal+0x37/0x6c0
[  809.652104]  [<ffffffffa0274890>] ? xfs_file_write_iter+0x90/0x130 [xfs]
[  809.654725]  [<ffffffff81254639>] ? kfree+0x1f9/0x330
[  809.656805]  [<ffffffff810904cc>] ? exit_to_usermode_loop+0x51/0x92
[  809.659293]  [<ffffffff81003d65>] ? do_syscall_64+0x195/0x200
[  809.661596]  [<ffffffff8175a189>] ? entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  889.760595] a.out(5337): page allocation stalls for 710002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  899.760518] a.out(5337): page allocation stalls for 720002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  909.760429] a.out(5337): page allocation stalls for 730002ms, order:1 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  916.234927] sysrq: SysRq : Resetting
[  916.237156] ACPI MEMORY or I/O RESET_REG.
--------------------

kmallocwd would have told the administrator that the system got stuck
inside page allocator due to kswapd v.s. shrink_inactive_list() trap.

Scattering around tracepoints like [3] will not replace kmallocwd.
We don't need to enable tracepoints when allocation request is not stalling,
but we want to enable console output when allocation request got stuck.
Synchronous watchdog like warn_alloc() cannot do this because we can't
predict which line of which function gets stuck. Only asynchronous watchdog
like kmallocwd can serve as a trigger for enabling console output.

Although Michal thinks that this kmallocwd is too complex, I believe that
this complexity is inevitable for overcoming unsolvable deficiency of
warn_alloc() and tracepoints. Since it seems that nobody has objection
against the idea of having an asynchronous watchdog, I want to have it
merged. Are there any ideas/suggestions/improvements to this kmallocwd ?



[1] http://lkml.kernel.org/r/20161214181850.GC16763@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/20161214145324.26261-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
