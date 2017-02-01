Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFE16B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 06:49:16 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s36so346121852otd.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 03:49:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e1si8056237otb.5.2017.02.01.03.49.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 03:49:14 -0800 (PST)
Subject: Re: [PATCH 0/3] fix few OOM victim allocation runaways
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170201092706.9966-1-mhocko@kernel.org>
In-Reply-To: <20170201092706.9966-1-mhocko@kernel.org>
Message-Id: <201702012049.BAG95379.VJFFOHMStLQFOO@I-love.SAKURA.ne.jp>
Date: Wed, 1 Feb 2017 20:49:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hch@lst.de, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Tetsuo was suggesting introducing __GFP_KILLABLE which would fail the
> allocation rather than consuming the reserves. I see two problems with
> this approach.
>         1) in order this flags work as expected all the blocking
>         operations in the allocator call chain (including the direct
>         reclaim) would have to be killable and this is really non
>         trivial to achieve. Especially when we do not have any control
>         over shrinkers.
>         2) even if the above could be dealt with we would still have to
>         find all the places which do allocation in the loop based on
>         the user request. So it wouldn't be simpler than an explicit
>         fatal_signal_pending check.
> 
> Thoughts?

I don't think they are problems.
I think it is OK to start __GFP_KILLABLE with best-effort implementation.

(1) is a sign of "direct reclaim considered harmful". Like I demonstrated
in "mm/page_alloc: Wait for oom_lock before retrying." thread, it is trivial
to consume all CPU times by letting far many threads (than available CPUs)
perform direct reclaim. It can cause more IPIs in drain_all_pages() than
needed (which we are considering workqueue in "mm, page_alloc: drain per-cpu
pages from workqueue context" thread). There is no need to let all allocating
threads do direct reclaim. By offloading direct reclaim to dedicated kernel
threads (we are talking about slowpath where allocating threads need to wait
for reclaim operation, so overhead of context switching should be acceptable),
we will be able to manage dependency better within reclaim operation (e.g.
propagate allowable level of memory reserves to use) compared to current
situation (e.g. let wb_workfn being blocked for more than a minute due to
doing direct reclaim observed in "Bug 192981 - page allocation stalls" thread).

----------
2017-01-28T04:05:57.064278+03:00 storage8 [154827.258547] MemAlloc: kworker/u33:3(27274) flags=0x4a08860 switches=22584 seq=158 gfp=0x26012d0(GFP_TEMPORARY|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOTRACK) order=0 delay=22745 uninterruptible
2017-01-28T04:05:57.064278+03:00 storage8 [154827.258925] kworker/u33:3   D
2017-01-28T04:05:57.064420+03:00 storage8     0 27274      2 0x00000000
2017-01-28T04:05:57.064420+03:00 storage8 [154827.259062] Workqueue: writeback wb_workfn
2017-01-28T04:05:57.064442+03:00 storage8  (flush-66:80)
2017-01-28T04:05:57.064542+03:00 storage8
2017-01-28T04:05:57.064543+03:00 storage8 [154827.259195]  0000000000000000
2017-01-28T04:05:57.064597+03:00 storage8  ffff924f6fc21e00
2017-01-28T04:05:57.064606+03:00 storage8  ffff924f882b8000
2017-01-28T04:05:57.064693+03:00 storage8  ffff924796b5a4c0
2017-01-28T04:05:57.064821+03:00 storage8 [154827.259465]  ffff924f8f114240
2017-01-28T04:05:57.064815+03:00 storage8
2017-01-28T04:05:57.064815+03:00 storage8  ffffa53bc23c2ff8
2017-01-28T04:05:57.064829+03:00 storage8  ffffffffaf82f819
2017-01-28T04:05:57.064957+03:00 storage8  ffff924796b5a4c0
2017-01-28T04:05:57.065077+03:00 storage8
2017-01-28T04:05:57.065078+03:00 storage8 [154827.259724]  0000000000000002
2017-01-28T04:05:57.065154+03:00 storage8  7fffffffffffffff
2017-01-28T04:05:57.065154+03:00 storage8  ffffffffaf82fd42
2017-01-28T04:05:57.065219+03:00 storage8  ffff9259278bc858
2017-01-28T04:05:57.065338+03:00 storage8
2017-01-28T04:05:57.065460+03:00 storage8 [154827.259984] Call Trace:
2017-01-28T04:05:57.065632+03:00 storage8 [154827.260120]  [<ffffffffaf82f819>] ? __schedule+0x179/0x5c8
2017-01-28T04:05:57.065873+03:00 storage8 [154827.260257]  [<ffffffffaf82fd42>] ? schedule+0x32/0x80
2017-01-28T04:05:57.065873+03:00 storage8 [154827.260395]  [<ffffffffaf37b433>] ? xfs_reclaim_inode+0xd3/0x3d0
2017-01-28T04:05:57.066023+03:00 storage8 [154827.260537]  [<ffffffffaf82fd42>] ? schedule+0x32/0x80
2017-01-28T04:05:57.066201+03:00 storage8 [154827.260688]  [<ffffffffaf8322f5>] ? schedule_timeout+0x1a5/0x2a0
2017-01-28T04:05:57.066329+03:00 storage8 [154827.260837]  [<ffffffffaf37b433>] ? xfs_reclaim_inode+0xd3/0x3d0
2017-01-28T04:05:57.066467+03:00 storage8 [154827.260978]  [<ffffffffaf82f62d>] ? io_schedule_timeout+0x9d/0x110
2017-01-28T04:05:57.066611+03:00 storage8 [154827.261119]  [<ffffffffaf388d58>] ? xfs_iunpin_wait+0x128/0x1a0
2017-01-28T04:05:57.066830+03:00 storage8 [154827.261261]  [<ffffffffaf0d47d0>] ? wake_atomic_t_function+0x40/0x40
2017-01-28T04:05:57.066888+03:00 storage8 [154827.261404]  [<ffffffffaf37b433>] ? xfs_reclaim_inode+0xd3/0x3d0
2017-01-28T04:05:57.067025+03:00 storage8 [154827.261542]  [<ffffffffaf37b8e4>] ? xfs_reclaim_inodes_ag+0x1b4/0x2c0
2017-01-28T04:05:57.067167+03:00 storage8 [154827.261683]  [<ffffffffaf37ce31>] ? xfs_reclaim_inodes_nr+0x31/0x40
2017-01-28T04:05:57.067321+03:00 storage8 [154827.261825]  [<ffffffffaf20b030>] ? super_cache_scan+0x1a0/0x1b0
2017-01-28T04:05:57.067447+03:00 storage8 [154827.261965]  [<ffffffffaf195cc2>] ? shrink_slab+0x262/0x440
2017-01-28T04:05:57.067582+03:00 storage8 [154827.262103]  [<ffffffffaf0bd4af>] ? try_to_wake_up+0x1df/0x370
2017-01-28T04:05:57.067723+03:00 storage8 [154827.262239]  [<ffffffffaf19966f>] ? shrink_node+0xef/0x2d0
2017-01-28T04:05:57.067874+03:00 storage8 [154827.262377]  [<ffffffffaf199b44>] ? do_try_to_free_pages+0xc4/0x2e0
2017-01-28T04:05:57.068001+03:00 storage8 [154827.262518]  [<ffffffffaf19a014>] ? try_to_free_pages+0xe4/0x1c0
2017-01-28T04:05:57.068150+03:00 storage8 [154827.262657]  [<ffffffffaf18a6eb>] ? __alloc_pages_nodemask+0x78b/0xe50
2017-01-28T04:05:57.068282+03:00 storage8 [154827.262801]  [<ffffffffaf2c8873>] ? __ext4_journal_stop+0x83/0xc0
2017-01-28T04:05:57.068423+03:00 storage8 [154827.262938]  [<ffffffffaf1e27c3>] ? kmem_cache_alloc+0x113/0x1b0
2017-01-28T04:05:57.068571+03:00 storage8 [154827.263079]  [<ffffffffaf1d855a>] ? alloc_pages_current+0x9a/0x120
2017-01-28T04:05:57.068735+03:00 storage8 [154827.263216]  [<ffffffffaf1e03fb>] ? new_slab+0x39b/0x600
2017-01-28T04:05:57.068836+03:00 storage8 [154827.263354]  [<ffffffffaf42177e>] ? bio_attempt_back_merge+0x8e/0x110
2017-01-28T04:05:57.069018+03:00 storage8 [154827.263502]  [<ffffffffaf1e1a84>] ? ___slab_alloc+0x3e4/0x580
2017-01-28T04:05:57.069267+03:00 storage8 [154827.263642]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:05:57.069292+03:00 storage8 [154827.263787]  [<ffffffffaf420675>] ? generic_make_request+0x105/0x190
2017-01-28T04:05:57.069405+03:00 storage8 [154827.263926]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:05:57.069553+03:00 storage8 [154827.264065]  [<ffffffffaf20452f>] ? __slab_alloc+0xe/0x12
2017-01-28T04:05:57.069688+03:00 storage8 [154827.264203]  [<ffffffffaf1e2856>] ? kmem_cache_alloc+0x1a6/0x1b0
2017-01-28T04:05:57.069834+03:00 storage8 [154827.264342]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:05:57.069979+03:00 storage8 [154827.264482]  [<ffffffffaf29c4f8>] ? ext4_writepages+0x438/0xd80
2017-01-28T04:05:57.070106+03:00 storage8 [154827.264621]  [<ffffffffaf0d40a0>] ? __wake_up_common+0x50/0x90
2017-01-28T04:05:57.070249+03:00 storage8 [154827.264761]  [<ffffffffaf23462d>] ? __writeback_single_inode+0x3d/0x340
2017-01-28T04:05:57.070385+03:00 storage8 [154827.264903]  [<ffffffffaf235091>] ? writeback_sb_inodes+0x1e1/0x440
2017-01-28T04:05:57.070529+03:00 storage8 [154827.265040]  [<ffffffffaf23537d>] ? __writeback_inodes_wb+0x8d/0xc0
2017-01-28T04:05:57.070660+03:00 storage8 [154827.265178]  [<ffffffffaf2355e7>] ? wb_writeback+0x237/0x2c0
2017-01-28T04:05:57.070807+03:00 storage8 [154827.265317]  [<ffffffffaf235d96>] ? wb_workfn+0x1f6/0x370
2017-01-28T04:05:57.070965+03:00 storage8 [154827.265456]  [<ffffffffaf0ad2a4>] ? process_one_work+0x124/0x3b0
2017-01-28T04:05:57.071078+03:00 storage8 [154827.265594]  [<ffffffffaf0ad693>] ? worker_thread+0x123/0x470
2017-01-28T04:05:57.071219+03:00 storage8 [154827.265733]  [<ffffffffaf0ad570>] ? process_scheduled_works+0x40/0x40
2017-01-28T04:05:57.071380+03:00 storage8 [154827.265881]  [<ffffffffaf0ad570>] ? process_scheduled_works+0x40/0x40
2017-01-28T04:05:57.071526+03:00 storage8 [154827.266024]  [<ffffffffaf0b3672>] ? kthread+0xc2/0xe0
2017-01-28T04:05:57.071638+03:00 storage8 [154827.266160]  [<ffffffffaf0b35b0>] ? __kthread_init_worker+0xb0/0xb0
2017-01-28T04:05:57.071781+03:00 storage8 [154827.266300]  [<ffffffffaf833662>] ? ret_from_fork+0x22/0x30

2017-01-28T04:08:40.702099+03:00 storage8 [154990.895457] MemAlloc: kworker/u33:3(27274) flags=0x4a08860 switches=23547 seq=158 gfp=0x26012d0(GFP_TEMPORARY|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOTRACK) order=0 delay=71833 uninterruptible
2017-01-28T04:08:40.702105+03:00 storage8 [154990.895835] kworker/u33:3   D
2017-01-28T04:08:40.702248+03:00 storage8     0 27274      2 0x00000000
2017-01-28T04:08:40.702256+03:00 storage8 [154990.895970] Workqueue: writeback wb_workfn
2017-01-28T04:08:40.702263+03:00 storage8  (flush-66:80)
2017-01-28T04:08:40.702360+03:00 storage8
2017-01-28T04:08:40.702360+03:00 storage8 [154990.896102]  0000000000000000
2017-01-28T04:08:40.702371+03:00 storage8  ffff924bbb3c0b40
2017-01-28T04:08:40.702371+03:00 storage8  ffff924f882ba4c0
2017-01-28T04:08:40.702497+03:00 storage8  ffff924796b5a4c0
2017-01-28T04:08:40.702639+03:00 storage8
2017-01-28T04:08:40.702647+03:00 storage8 [154990.896357]  ffff924f8f914240
2017-01-28T04:08:40.702647+03:00 storage8  ffffffffaf82f819
2017-01-28T04:08:40.702650+03:00 storage8  ffffa53bc23c2fe8
2017-01-28T04:08:40.702753+03:00 storage8  0000000000000000
2017-01-28T04:08:40.702891+03:00 storage8
2017-01-28T04:08:40.702891+03:00 storage8 [154990.896611]  ffff924666c78b60
2017-01-28T04:08:40.702904+03:00 storage8  ffff924796b5a4c0
2017-01-28T04:08:40.702904+03:00 storage8  0000000000000002
2017-01-28T04:08:40.703008+03:00 storage8  7fffffffffffffff
2017-01-28T04:08:40.703123+03:00 storage8
2017-01-28T04:08:40.703245+03:00 storage8 [154990.896866] Call Trace:
2017-01-28T04:08:40.703376+03:00 storage8 [154990.896988]  [<ffffffffaf82f819>] ? __schedule+0x179/0x5c8
2017-01-28T04:08:40.703498+03:00 storage8 [154990.897113]  [<ffffffffaf82fd42>] ? schedule+0x32/0x80
2017-01-28T04:08:40.703638+03:00 storage8 [154990.897240]  [<ffffffffaf39a70d>] ? _xfs_log_force_lsn+0x1cd/0x340
2017-01-28T04:08:40.703763+03:00 storage8 [154990.897371]  [<ffffffffaf0bd640>] ? try_to_wake_up+0x370/0x370
2017-01-28T04:08:40.703913+03:00 storage8 [154990.897509]  [<ffffffffaf388d23>] ? xfs_iunpin_wait+0xf3/0x1a0
2017-01-28T04:08:40.704489+03:00 storage8 [154990.897834]  [<ffffffffaf37b433>] ? xfs_reclaim_inode+0xd3/0x3d0
2017-01-28T04:08:40.704482+03:00 storage8 [154990.897637]  [<ffffffffaf39a8ca>] ? xfs_log_force_lsn+0x4a/0x100
2017-01-28T04:08:40.704482+03:00 storage8 [154990.897961]  [<ffffffffaf388d23>] ? xfs_iunpin_wait+0xf3/0x1a0
2017-01-28T04:08:40.704496+03:00 storage8 [154990.898089]  [<ffffffffaf0d47d0>] ? wake_atomic_t_function+0x40/0x40
2017-01-28T04:08:40.704610+03:00 storage8 [154990.898216]  [<ffffffffaf37b433>] ? xfs_reclaim_inode+0xd3/0x3d0
2017-01-28T04:08:40.704737+03:00 storage8 [154990.898345]  [<ffffffffaf37b8e4>] ? xfs_reclaim_inodes_ag+0x1b4/0x2c0
2017-01-28T04:08:40.704863+03:00 storage8 [154990.898475]  [<ffffffffaf37ce31>] ? xfs_reclaim_inodes_nr+0x31/0x40
2017-01-28T04:08:40.704993+03:00 storage8 [154990.898606]  [<ffffffffaf20b030>] ? super_cache_scan+0x1a0/0x1b0
2017-01-28T04:08:40.705127+03:00 storage8 [154990.898734]  [<ffffffffaf195cc2>] ? shrink_slab+0x262/0x440
2017-01-28T04:08:40.705249+03:00 storage8 [154990.898861]  [<ffffffffaf0bd4af>] ? try_to_wake_up+0x1df/0x370
2017-01-28T04:08:40.705403+03:00 storage8 [154990.898993]  [<ffffffffaf19966f>] ? shrink_node+0xef/0x2d0
2017-01-28T04:08:40.705524+03:00 storage8 [154990.899133]  [<ffffffffaf199b44>] ? do_try_to_free_pages+0xc4/0x2e0
2017-01-28T04:08:40.705663+03:00 storage8 [154990.899265]  [<ffffffffaf19a014>] ? try_to_free_pages+0xe4/0x1c0
2017-01-28T04:08:40.705792+03:00 storage8 [154990.899394]  [<ffffffffaf18a6eb>] ? __alloc_pages_nodemask+0x78b/0xe50
2017-01-28T04:08:40.705912+03:00 storage8 [154990.899526]  [<ffffffffaf2c8873>] ? __ext4_journal_stop+0x83/0xc0
2017-01-28T04:08:40.706061+03:00 storage8 [154990.899655]  [<ffffffffaf1e27c3>] ? kmem_cache_alloc+0x113/0x1b0
2017-01-28T04:08:40.706176+03:00 storage8 [154990.899784]  [<ffffffffaf1d855a>] ? alloc_pages_current+0x9a/0x120
2017-01-28T04:08:40.706316+03:00 storage8 [154990.899910]  [<ffffffffaf1e03fb>] ? new_slab+0x39b/0x600
2017-01-28T04:08:40.706432+03:00 storage8 [154990.900037]  [<ffffffffaf42177e>] ? bio_attempt_back_merge+0x8e/0x110
2017-01-28T04:08:40.706557+03:00 storage8 [154990.900168]  [<ffffffffaf1e1a84>] ? ___slab_alloc+0x3e4/0x580
2017-01-28T04:08:40.706686+03:00 storage8 [154990.900297]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:08:40.706821+03:00 storage8 [154990.900425]  [<ffffffffaf420675>] ? generic_make_request+0x105/0x190
2017-01-28T04:08:40.706943+03:00 storage8 [154990.900556]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:08:40.707077+03:00 storage8 [154990.900684]  [<ffffffffaf20452f>] ? __slab_alloc+0xe/0x12
2017-01-28T04:08:40.707245+03:00 storage8 [154990.900816]  [<ffffffffaf1e2856>] ? kmem_cache_alloc+0x1a6/0x1b0
2017-01-28T04:08:40.707337+03:00 storage8 [154990.900945]  [<ffffffffaf29dffb>] ? ext4_init_io_end+0x1b/0x40
2017-01-28T04:08:40.707471+03:00 storage8 [154990.901073]  [<ffffffffaf29c4f8>] ? ext4_writepages+0x438/0xd80
2017-01-28T04:08:40.707603+03:00 storage8 [154990.901205]  [<ffffffffaf0d40a0>] ? __wake_up_common+0x50/0x90
2017-01-28T04:08:40.707743+03:00 storage8 [154990.901344]  [<ffffffffaf23462d>] ? __writeback_single_inode+0x3d/0x340
2017-01-28T04:08:40.707872+03:00 storage8 [154990.901481]  [<ffffffffaf235091>] ? writeback_sb_inodes+0x1e1/0x440
2017-01-28T04:08:40.708002+03:00 storage8 [154990.901615]  [<ffffffffaf23537d>] ? __writeback_inodes_wb+0x8d/0xc0
2017-01-28T04:08:40.708136+03:00 storage8 [154990.901742]  [<ffffffffaf2355e7>] ? wb_writeback+0x237/0x2c0
2017-01-28T04:08:40.708264+03:00 storage8 [154990.901873]  [<ffffffffaf235d96>] ? wb_workfn+0x1f6/0x370
2017-01-28T04:08:40.708390+03:00 storage8 [154990.902006]  [<ffffffffaf0ad2a4>] ? process_one_work+0x124/0x3b0
2017-01-28T04:08:40.708538+03:00 storage8 [154990.902134]  [<ffffffffaf0ad693>] ? worker_thread+0x123/0x470
2017-01-28T04:08:40.708652+03:00 storage8 [154990.902263]  [<ffffffffaf0ad570>] ? process_scheduled_works+0x40/0x40
2017-01-28T04:08:40.708785+03:00 storage8 [154990.902394]  [<ffffffffaf0ad570>] ? process_scheduled_works+0x40/0x40
2017-01-28T04:08:40.708929+03:00 storage8 [154990.902526]  [<ffffffffaf0b3672>] ? kthread+0xc2/0xe0
2017-01-28T04:08:40.709044+03:00 storage8 [154990.902655]  [<ffffffffaf0b35b0>] ? __kthread_init_worker+0xb0/0xb0
2017-01-28T04:08:40.709181+03:00 storage8 [154990.902784]  [<ffffffffaf833662>] ? ret_from_fork+0x22/0x30
----------

And why do you want to limit __GFP_KILLABLE to "do allocation in the loop" in (2) ?
Any single allocation can use __GFP_KILLABLE. Not allocating from memory reserves
(even it is a single page) will reduce the possibility of falling into OOM livelock on
CONFIG_MMU=n kernels, reduce the possibility of unwanted allocation stalls/failures,
for it will help preserving memory reserves for allocation requests which are really
important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
