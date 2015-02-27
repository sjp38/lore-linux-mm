Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD0B6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 08:12:18 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so20933556pdb.11
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 05:12:17 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id gr2si2964121pac.198.2015.02.27.05.12.12
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 05:12:14 -0800 (PST)
Date: Sat, 28 Feb 2015 00:12:09 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150227131209.GK4251@dastard>
References: <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
 <20150224152033.GA3782@thunk.org>
 <20150224210244.GA13666@dastard>
 <201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
 <20150227073949.GJ4251@dastard>
 <201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Fri, Feb 27, 2015 at 09:42:55PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > On Wed, Feb 25, 2015 at 11:31:17PM +0900, Tetsuo Handa wrote:
> > > I got two problems (one is stall at io_schedule()
> > 
> > This is a typical "blame the messenger" bug report. XFS is stuck in
> > inode reclaim waiting for log IO completion to occur, along with all
> > the other processes iin xfs_log_force also stuck waiting for the
> > same Io completion.
> 
> I wanted to know whether transaction based reservations can solve these
> problems. Inside filesystem layer, I guess you can calculate how much
> memory is needed for your filesystem transaction. But I'm wondering
> whether we can calculate how much memory is needed inside block layer.
> If block layer failed to reserve memory, won't file I/O fail under
> extreme memory pressure? And if __GFP_NOFAIL were used inside block
> layer, won't the OOM killer deadlock problem arise?
> 
> > 
> > You need to find where that IO completion that everything is waiting
> > on has got stuck or show that it's not a lost IO and actually an
> > XFS problem. e.g has the IO stack got stuck on a mempool somewhere?
> > 
> 
> I didn't get a vmcore for this stall. But it seemed to me that
> 
> kworker/3:0H is doing
> 
>   xfs_fs_free_cached_objects()
>   => xfs_reclaim_inodes_nr()
>     => xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan)
>       => xfs_reclaim_inode() because mutex_trylock(&pag->pag_ici_reclaim_lock)
>          was succeessful
>          => xfs_iunpin_wait(ip) because xfs_ipincount(ip) was non 0
>            => __xfs_iunpin_wait()
>              => waiting inside io_schedule() for somebody to unpin
> 
> kswapd0 is doing
> 
>   xfs_fs_free_cached_objects()
>   => xfs_reclaim_inodes_nr()
>     => xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan)
>       => not calling xfs_reclaim_inode() because
>          mutex_trylock(&pag->pag_ici_reclaim_lock) failed due to kworker/3:0H
>       => SYNC_TRYLOCK is dropped for retry loop due to
> 
>             if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
>                     trylock = 0;
>                     goto restart;
>             }
> 
>       => calling mutex_lock(&pag->pag_ici_reclaim_lock) and gets blocked
>          due to kworker/3:0H
> 
> kworker/3:0H is trying to free memory but somebody needs memory to make
> forward progress. kswapd0 is also trying to free memory but is blocked by
> kworker/3:0H already holding the lock. Since kswapd0 cannot make forward
> progress, somebody can't allocate memory. Finally the system started
> stalling. Is this decoding correct?

Yes. The per-ag lock is a key throttling point for reclaim when
there are many more direct reclaimers than there are allocation
groups. System performance drops badly in low memory conditions if
we have more than one reclaimer operating on an allocation group at
a time as they interfere and contend with each other. Effectively
multiple rclaimers within the one AG turn ascending offset order
inode writeback into random IO, which is orders of magnitude slower
than a single thread can clean and reclaim those same inodes.

Quite simply: if one thread can't make progress due to be stuck
waiting for IO, then another hundred threads trying to do the same
operations are unlikely to make progress, either.

Thing is, the io layer below XFS that appears to be stuck does
GFP_NOIO allocations, and therefore direct reclaim for mempool
allocation in the block layer cannot get stuck on GFP_FS level
reclaim operations....

> I killed mutex_lock() and memory allocation from shrinker functions
> in drivers/gpu/drm/ttm/ttm_page_alloc[_dma].c because I observed that
> kswapd0 was blocked for so long at mutex_lock().

Which, to me, is fixing a symptom rather than understanding the root
cause of why lower layers are not making progress as they are
supposed to.

> If kswapd0 is blocked forever at e.g. mutex_lock() inside shrinker
> functions, who else can make forward progress?

You can't get into these filesystem shrinkers when you do GFP_NOIO
allocations, as the IO path does.

> Shouldn't we avoid calling functions which could potentially block for
> unpredictable duration (e.g. unkillable locks and/or completion) from
> shrinker functions?

No, because otherwise we can't throttle allocation and reclaim to
the rate at which IO can clean dirty objects. i.e. we do this for
the same reason we throttle page cache dirtying to the rate at which
we can clean dirty pages....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
