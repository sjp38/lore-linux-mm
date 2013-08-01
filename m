Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 496ED6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 18:16:36 -0400 (EDT)
Date: Fri, 2 Aug 2013 00:16:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130801221628.GA9505@redhat.com>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
 <20130801025636.GC19540@bbox>
 <51F9E4A6.2090909@redhat.com>
 <20130801155111.GO25926@redhat.com>
 <20130801195823.GN715@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801195823.GN715@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 01, 2013 at 03:58:23PM -0400, Johannes Weiner wrote:
> But we might be able to get away with a small error.

The idea is that there's a small error anyway, because multiple CPUs
can reset it at the same time, while another CPU is decreasing it, so
the decrease sometime may get lost regardless if atomic or not. How
worse the error will become I don't know for sure but I would expect
to still be in the noise level.

Removing the locked op won't help much when multiple processes
allocates from the same node, but it'll speed it up when just one CPU
runs.

> So the discussion diverged between on-list and off-list.  I suggested
> ignoring the alloc_batch in the slowpath completely (since allocations
> are very unlikely to fail due to the batches immediately after they
> were reset, and the occasional glitch does not matter).  This should
> solve the problem of spurious direct reclaim invocations.  The

I'm fine with this solution of ignoring alloc_batch in the slowpath,
it definitely solves the risk of suprious direct reclaim and it
contributes to solving zone_reclaim_mode too.

> zone_reclaim_mode allocation sequence would basically be:
> 
> 1. Try zones in the local node with low watermark while maintaining
>    fairness with the allocation batch and invoking zone reclaim if
>    necessary
> 
> 2. If that fails, wake up kswapd and reset the alloc batches on the
>    local node
> 
> 3. Try zones in order of preference with the min watermark, invoking
>    zone reclaim if necessary, ignoring allocation batches.

One difference is that kswapd wasn't involved before. But maybe it's
beneficial.

> So in the fastpath we try to be local and fair, in the slow path we
> are likely to be local and fair, unless we have to spill into remote
> nodes.  But then there is nothing we can do anyway.

I think it should work well.

And with these changes, alloc_batch will help tremendously
zone_reclaim_mode too (not just prevent its breakage): the allocations
will be spread evenly on multiple zones of the same nodes, instead of
insisting calling zone_reclaim on the highest zone of the node until
zone_reclaim finally fails on it (with the current behavior if
zone_reclaim_mode is enabled, the LRU is rotated only the high zone
until full). And it's common to have a least one node with two zones
(pci32 zone).

By skipping any non-local zone in the fast path if zone_reclaim_mode
is enabled, will prevent multiple CPUs in different nodes to step in
each other toes, and alloc_batch will never be resetted by remote CPUs
with the zone_local check introduced in prepare_slowpath.

Changing the prepare_slowpath to reset only the local node will also
decrease the very distant interconnect traffic for very big NUMA where
zone_reclaim_mode is enabled by default, so it'll speedup
prepare_slowpath too.

Can you submit the fixes to Andrew? I'm very happy with your patch, so
then I can submit the compaction zone_reclaim_mode fixes on top of
it.

Changing topic on my zone_reclaim compaction fixes, hope to get more
review on those, especially the high order watermark algorithm
improvements. I'll try to get a specsfs with jumbo frames run on it
too to see if there's any positive measurable effect out of the
watermark changes and the substantial improvement in compaction
reliability. (the increase of the low watermark level for high order
pages is needed to get more accuracy out of zone_reclaim_mode hugepage
placement, and the decrease of the min watermark level will avoid us
to waste precious CPU to generate a zillon of high order pages that
cannot be possibly be useful to PF_MEMALLOC, we've currently a ton 8k
pages, that any GFP_ATOMIC or GFP_KERNEL allocation are totally
forbidden to use, but we still generate those for nothing, and over
time we split them right away at the first 4k allocation so they don't
even stick)

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
