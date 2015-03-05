Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4A66B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 20:37:29 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so38419890pdb.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 17:37:29 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id ki9si7129555pdb.160.2015.03.04.17.37.26
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 17:37:28 -0800 (PST)
Date: Thu, 5 Mar 2015 12:36:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150305013652.GC18360@dastard>
References: <20150227073949.GJ4251@dastard>
 <201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
 <20150227131209.GK4251@dastard>
 <201503042141.FIC48980.OFFtVSQFOOMHJL@I-love.SAKURA.ne.jp>
 <20150304132514.GW4251@dastard>
 <201503042311.CHA93957.tJFFOHMQLSOFVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503042311.CHA93957.tJFFOHMQLSOFVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Wed, Mar 04, 2015 at 11:11:48PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > > Forever blocking kswapd0 somewhere inside filesystem shrinker functions is
> > > equivalent with removing kswapd() function because it also prevents non
> > > filesystem shrinker functions from being called by kswapd0, doesn't it?
> > 
> > Yes, but that's not intentional. Remember, we keep talking about the
> > filesystem not being able to guarantee forwards progress if
> > allocations block forever? Well...
> > 
> > > Then, the description will become "We won't have _some_ free memory available
> > > if there is no other activity that frees anything up", won't it?
> > 
> > ... we've ended up blocking kswapd because it's waiting on a journal
> > commit to complete, and that journal commit is blocked waiting for
> > forwards progress in memory allocation...
> > 
> > Yes, it's another one of those nasty dependencies I keep pointing
> > out that filesystems have, and that can only be solved by
> > guaranteeing we can always make forwards allocation progress from
> > transaction reserve to transaction commit.
> 
> If this is an unexpected deadlock, don't we want below change for
> xfs_reclaim_inodes_ag() ?
> 
> -	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
> +	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0 && !current_is_kswapd()) {
>  		trylock = 0;
>  		goto restart;
>  	}

What, so when direct reclaim has choked up all inode reclaim slots
completely kswapd just burns CPU spinning while it fails to make
progress?

Besides, that does not address the actual issue that caused kswapd
to block on a log force. That's caused by the SYNC_WAIT flag telling
reclaim to wait for IO completion - this is the reclaim throttling
mechanism we need to prevent reclaim from degrading to random IO
patterns and completely trashing reclaim rates.  Hence reclaiming an
inode waits in xfs_iunpin_wait() for the log to be flushed before
reclaiming inode that is pinned by an unflushed transaction.

This works because there is also a background reclaim worker running
doing fast, highly efficient, sequential order, non-blocking
asynchronous inode writeback. Hence, more often than not, reclaim
does not block on more than one dirty inode per scan because the
rest of the inodes it walks have already been cleaned and are ready
for immediate reclaim.

We have multiple layers of reclaim work going on in XFS even within
each cache/shrinker infrastructure. Indeed, If I start having to
explain how this inode shrinker algorithm ties back into journal
tail pushing to optimise async metadata flushing so that the XFS
buffer cache shrinker hits clean inode buffers and hence can reclaim
the memory the inode shrinker consumes doing inode writeback as
quickly as possible, then I think heads might start to explode.

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
