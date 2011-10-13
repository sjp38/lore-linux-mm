Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECD46B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 11:06:47 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:06:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in __vm_enough_memory
Message-ID: <20111013150642.GC6169@csn.ul.ie>
References: <20111012160202.GA18666@sgi.com>
 <20111012120118.e948f40a.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1110121452220.31218@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110121452220.31218@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 12, 2011 at 02:57:53PM -0500, Christoph Lameter wrote:
> > I think we've discussed switching vm_stat[] to a contention-avoiding
> > counter scheme.  Simply using <percpu_counter.h> would be the simplest
> > approach.  They'll introduce inaccuracies but hopefully any problems
> > from that will be minor for the global page counters.
> 
> We already have a contention avoiding scheme for counter updates in
> vmstat.c. The problem here is that vm_stat is frequently read. Updates
> from other cpus that fold counter updates in a deferred way into the
> global statistics cause cacheline eviction. The updates occur too frequent
> in this load.
> 

There is also a correctness issue to be concerned with. In the patch,
there is a two second window during which the counters are not being
read. This increases the risk that the system gets too overcommitted
when overcommit_memory == OVERCOMMIT_GUESS.

If vm_enough_memory is being heavily hit as well, it implies that this
workload is mmap-intensive which is pretty inefficient in itself. I
guess it would also apply to workloads that are malloc-intensive for
large buffers but I'd expect the cache line bounces to only dominate if
there was little or no computation on the resulting buffers.

As a result, I wonder how realistic is this test workload and who useful
fixing this problem is in general?

> > otoh, I think we've been round this loop before and I don't recall why
> > nothing happened.
> 
> The update behavior can be tuned using /proc/sys/vm/stat_interval.
> Increase the interval to reduce the folding into the global counter (set
> maybe to 10?). This will reduce contention.

Unless the thresholds for per-cpu drift are being hit. If they are
allocating and freeing pages in large numbers for example, we'll be
calling __mod_zone_page_state(NR_FREE_PAGES) in large batches,
overflowing the counters, calling zone_page_state_add() and dirtying the
global vm_stat that way. In that case, increasing stat_interval alone is
not the answer.

> The other approach is to
> increase the allowed delta per zone if frequent updates occur via the
> overflow checks in vmstat.c. See calculate_*_threshold there.
> 

If this approach is taken, be careful that threshold is an s8 so it is
limited in size.

> Note that the deltas are current reduced for memory pressure situations
> (after recent patches by Mel). This will cause a significant increase in
> vm_stat cacheline contention compared to earlier kernels.
> 

That statement is misleading. The thresholds are reduced while
kswapd is awake to avoid the possibility of all memory being allocated
and the machine livelocking. If the system is under enough pressure for
kswapd to be awake for prolonged periods of time, the overhead of cache
line bouncing while updating vm_stat is going to be a lesser concern.

I like the idea of the threshold being scaled under normal circumstances
depending on the size of the central counter. Conceivably it could be
done as part of refresh_cpu_vm_stats() using the old value of the
central counter while walking each per_cpu_pageset.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
