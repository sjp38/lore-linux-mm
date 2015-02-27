Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7916B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:43:05 -0500 (EST)
Received: by paceu11 with SMTP id eu11so22406404pac.10
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 04:43:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qe5si5321166pbb.116.2015.02.27.04.43.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 04:43:03 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
	<20150224152033.GA3782@thunk.org>
	<20150224210244.GA13666@dastard>
	<201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
	<20150227073949.GJ4251@dastard>
In-Reply-To: <20150227073949.GJ4251@dastard>
Message-Id: <201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
Date: Fri, 27 Feb 2015 21:42:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

Dave Chinner wrote:
> On Wed, Feb 25, 2015 at 11:31:17PM +0900, Tetsuo Handa wrote:
> > I got two problems (one is stall at io_schedule()
> 
> This is a typical "blame the messenger" bug report. XFS is stuck in
> inode reclaim waiting for log IO completion to occur, along with all
> the other processes iin xfs_log_force also stuck waiting for the
> same Io completion.

I wanted to know whether transaction based reservations can solve these
problems. Inside filesystem layer, I guess you can calculate how much
memory is needed for your filesystem transaction. But I'm wondering
whether we can calculate how much memory is needed inside block layer.
If block layer failed to reserve memory, won't file I/O fail under
extreme memory pressure? And if __GFP_NOFAIL were used inside block
layer, won't the OOM killer deadlock problem arise?

> 
> You need to find where that IO completion that everything is waiting
> on has got stuck or show that it's not a lost IO and actually an
> XFS problem. e.g has the IO stack got stuck on a mempool somewhere?
> 

I didn't get a vmcore for this stall. But it seemed to me that

kworker/3:0H is doing

  xfs_fs_free_cached_objects()
  => xfs_reclaim_inodes_nr()
    => xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan)
      => xfs_reclaim_inode() because mutex_trylock(&pag->pag_ici_reclaim_lock)
         was succeessful
         => xfs_iunpin_wait(ip) because xfs_ipincount(ip) was non 0
           => __xfs_iunpin_wait()
             => waiting inside io_schedule() for somebody to unpin

kswapd0 is doing

  xfs_fs_free_cached_objects()
  => xfs_reclaim_inodes_nr()
    => xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan)
      => not calling xfs_reclaim_inode() because
         mutex_trylock(&pag->pag_ici_reclaim_lock) failed due to kworker/3:0H
      => SYNC_TRYLOCK is dropped for retry loop due to

            if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
                    trylock = 0;
                    goto restart;
            }

      => calling mutex_lock(&pag->pag_ici_reclaim_lock) and gets blocked
         due to kworker/3:0H

kworker/3:0H is trying to free memory but somebody needs memory to make
forward progress. kswapd0 is also trying to free memory but is blocked by
kworker/3:0H already holding the lock. Since kswapd0 cannot make forward
progress, somebody can't allocate memory. Finally the system started
stalling. Is this decoding correct?

----------
[ 1225.773411] kworker/3:0H    D ffff88007cadb4f8 11632    27      2 0x00000000
[ 1225.776911]  ffff88007cadb4f8 ffff88007cadb508 ffff88007cac6740 0000000000014080
[ 1225.780670]  ffffffff8101cd19 ffff88007cadbfd8 0000000000014080 ffff88007c28b740
[ 1225.784431]  ffff88007cac6740 ffff88007cadb540 ffff88007f8d4998 ffff88007cadb540
[ 1225.788766] Call Trace:
[ 1225.789988]  [<ffffffff8101cd19>] ? read_tsc+0x9/0x10
[ 1225.792444]  [<ffffffff812acbd9>] ? xfs_iunpin_wait+0x19/0x20
[ 1225.795228]  [<ffffffff816b2590>] io_schedule+0xa0/0x130
[ 1225.797802]  [<ffffffff812a9569>] __xfs_iunpin_wait+0xe9/0x140
arch/x86/include/asm/atomic.h:27
fs/xfs/xfs_inode.c:2433
[ 1225.800621]  [<ffffffff810af3b0>] ? autoremove_wake_function+0x40/0x40
[ 1225.803770]  [<ffffffff812acbd9>] xfs_iunpin_wait+0x19/0x20
fs/xfs/xfs_inode.c:2443
[ 1225.806471]  [<ffffffff812a209c>] xfs_reclaim_inode+0x7c/0x360
include/linux/spinlock.h:309
fs/xfs/xfs_inode.h:144
fs/xfs/xfs_icache.c:920
[ 1225.809283]  [<ffffffff812a25d7>] xfs_reclaim_inodes_ag+0x257/0x370
fs/xfs/xfs_icache.c:1105
[ 1225.812308]  [<ffffffff81340839>] ? radix_tree_gang_lookup_tag+0x89/0xd0
[ 1225.815532]  [<ffffffff8116fe58>] ? list_lru_walk_node+0x148/0x190
[ 1225.817951]  [<ffffffff812a2783>] xfs_reclaim_inodes_nr+0x33/0x40
fs/xfs/xfs_icache.c:1166
[ 1225.819373]  [<ffffffff812b3545>] xfs_fs_free_cached_objects+0x15/0x20
[ 1225.820898]  [<ffffffff811c29e9>] super_cache_scan+0x169/0x170
[ 1225.822245]  [<ffffffff8115aed6>] shrink_node_slabs+0x1d6/0x370
[ 1225.823588]  [<ffffffff8115dd2a>] shrink_zone+0x20a/0x240
[ 1225.824830]  [<ffffffff8115e0dc>] do_try_to_free_pages+0x16c/0x460
[ 1225.826230]  [<ffffffff8115e48a>] try_to_free_pages+0xba/0x150
[ 1225.827570]  [<ffffffff81151542>] __alloc_pages_nodemask+0x5b2/0x9d0
[ 1225.829030]  [<ffffffff8119ecbc>] kmem_getpages+0x8c/0x200
[ 1225.830277]  [<ffffffff811a122b>] fallback_alloc+0x17b/0x230
[ 1225.831561]  [<ffffffff811a107b>] ____cache_alloc_node+0x18b/0x1c0
[ 1225.833061]  [<ffffffff811a3b00>] kmem_cache_alloc+0x330/0x5c0
[ 1225.834435]  [<ffffffff8133c9d9>] ? ida_pre_get+0x69/0x100
[ 1225.835719]  [<ffffffff8133c9d9>] ida_pre_get+0x69/0x100
[ 1225.836963]  [<ffffffff8133d312>] ida_simple_get+0x42/0xf0
[ 1225.838248]  [<ffffffff81086211>] create_worker+0x31/0x1c0
[ 1225.839519]  [<ffffffff81087831>] worker_thread+0x3d1/0x4d0
[ 1225.840800]  [<ffffffff81087460>] ? rescuer_thread+0x3a0/0x3a0
[ 1225.842123]  [<ffffffff8108c5e2>] kthread+0xd2/0xf0
[ 1225.843234]  [<ffffffff81010000>] ? perf_trace_xen_mmu_ptep_modify_prot+0x90/0xf0
[ 1225.844978]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.846481]  [<ffffffff816b63fc>] ret_from_fork+0x7c/0xb0
[ 1225.847718]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.849279] kswapd0         D ffff88007708f998 11552    45      2 0x00000000
[ 1225.850977]  ffff88007708f998 0000000000000000 ffff88007c28b740 0000000000014080
[ 1225.852798]  0000000000000003 ffff88007708ffd8 0000000000014080 ffff880077ff2740
[ 1225.854575]  ffff88007c28b740 0000000000000000 ffff88007948e3a8 ffff88007948e3ac
[ 1225.856358] Call Trace:
[ 1225.856928]  [<ffffffff816b2799>] schedule_preempt_disabled+0x29/0x70
[ 1225.858384]  [<ffffffff816b43d5>] __mutex_lock_slowpath+0x95/0x100
[ 1225.859799]  [<ffffffff816b4463>] mutex_lock+0x23/0x37
arch/x86/include/asm/current.h:14
kernel/locking/mutex.h:22
kernel/locking/mutex.c:103
[ 1225.860983]  [<ffffffff812a264c>] xfs_reclaim_inodes_ag+0x2cc/0x370
fs/xfs/xfs_icache.c:1034
[ 1225.862403]  [<ffffffff8109eb48>] ? __enqueue_entity+0x78/0x80
[ 1225.863742]  [<ffffffff810a5f37>] ? enqueue_entity+0x237/0x8f0
[ 1225.865100]  [<ffffffff81340839>] ? radix_tree_gang_lookup_tag+0x89/0xd0
[ 1225.866659]  [<ffffffff8116fe58>] ? list_lru_walk_node+0x148/0x190
[ 1225.868106]  [<ffffffff812a2783>] xfs_reclaim_inodes_nr+0x33/0x40
fs/xfs/xfs_icache.c:1166
[ 1225.869522]  [<ffffffff812b3545>] xfs_fs_free_cached_objects+0x15/0x20
[ 1225.871015]  [<ffffffff811c29e9>] super_cache_scan+0x169/0x170
[ 1225.872338]  [<ffffffff8115aed6>] shrink_node_slabs+0x1d6/0x370
[ 1225.873679]  [<ffffffff8115dd2a>] shrink_zone+0x20a/0x240
[ 1225.874920]  [<ffffffff8115ed2d>] kswapd+0x4fd/0x9c0
[ 1225.876049]  [<ffffffff8115e830>] ? mem_cgroup_shrink_node_zone+0x140/0x140
[ 1225.877654]  [<ffffffff8108c5e2>] kthread+0xd2/0xf0
[ 1225.878762]  [<ffffffff81010000>] ? perf_trace_xen_mmu_ptep_modify_prot+0x90/0xf0
[ 1225.880495]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
[ 1225.881996]  [<ffffffff816b63fc>] ret_from_fork+0x7c/0xb0
[ 1225.883336]  [<ffffffff8108c510>] ? kthread_create_on_node+0x180/0x180
----------

I killed mutex_lock() and memory allocation from shrinker functions
in drivers/gpu/drm/ttm/ttm_page_alloc[_dma].c because I observed that
kswapd0 was blocked for so long at mutex_lock().

If kswapd0 is blocked forever at e.g. mutex_lock() inside shrinker
functions, who else can make forward progress?

Shouldn't we avoid calling functions which could potentially block for
unpredictable duration (e.g. unkillable locks and/or completion) from
shrinker functions?



> IOWs, when you run CONFIG_XFS_DEBUG=y, you'll often get failures
> that are valuable to XFS developers but have no runtime effect on
> production systems.

Oh, I didn't know this failure is specific to CONFIG_XFS_DEBUG=y ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
