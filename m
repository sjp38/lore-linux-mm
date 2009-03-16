Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 65C676B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:19:11 -0400 (EDT)
Date: Mon, 16 Mar 2009 11:19:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316111906.GA6382@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <20090316104054.GA23046@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090316104054.GA23046@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 11:40:54AM +0100, Nick Piggin wrote:
> On Mon, Mar 16, 2009 at 09:45:55AM +0000, Mel Gorman wrote:
> > Here is V3 of an attempt to cleanup and optimise the page allocator and should
> > be ready for general testing. The page allocator is now faster (16%
> > reduced time overall for kernbench on one machine) and it has a smaller cache
> > footprint (16.5% less L1 cache misses and 19.5% less L2 cache misses for
> > kernbench on one machine). The text footprint has unfortunately increased,
> > largely due to the introduction of a form of lazy buddy merging mechanism
> > that avoids cache misses by postponing buddy merging until a high-order
> > allocation needs it.
> 
> You!? You want to do lazy buddy? ;)

I'm either a man of surprises, an idiot or just plain inconsistent :)

> That's wonderful, but it would
> significantly increase the fragmentation problem, wouldn't it?

Not necessarily, anti-fragmentation groups movable pages within a
hugepage-aligned block and high-order allocations will trigger a merge of
buddies from PAGE_ALLOC_MERGE_ORDER (defined in the relevant patch) up to
MAX_ORDER-1. Critically, a merge is also triggered when anti-fragmentation
wants to fallback to another migratetype to satisfy an allocation. As
long as the grouping works, it doesn't matter if they were only merged up
to PAGE_ALLOC_MERGE_ORDER as a full merge will still free up hugepages.
So two slow paths are made slower but the fast path should be faster and it
should be causing fewer cache line bounces due to writes to struct page.

The success rate of high-order allocations should be roughly the same but
they will be slower, particularly as I remerge more often than required. This
slowdown is undesirable but the assumptions are that either a) it's the
static hugepage pool being resized in which case the delay is irrelevant or
b) the pool is being dynamically resized but the expected lifetime of the
page far exceeds the allocation cost of merging.

I fully agree with you that it's more important that order-0 allocations
are faster than order-9 allocations but I'm not totally off high-order
allocs either. You'll see the patchset allows higher-order pages (up to
PAGE_ALLOC_COSTLY_ORDER) onto the PCP lists for order-1 allocations used
by sig handlers, stacks and the like (important for fork-heavy loads I am
guessing) and because SLUB uses high-order allocations that are currently
bypassing the PCP lists altogether. I haven't measured it but SLUB-heavy
workloads must be contending on the zone->lock to some extent.

When I last checked (about 10 days) ago, I hadn't damaged anti-fragmentation
but that was a lot of revisions ago. I'm redoing the tests to make sure
anti-fragmentation is still ok.

> (although pcp lists are conceptually a form of lazy buddy already)
> 

Indeed.

> No objections from me of course, if it is making significant
> speedups. I assume you mean overall time on kernbench is overall sys
> time?

Both, I should be clearer. The amount of oprofile samples measured in the
page allocator is reduced by a large amount but it does not always translate
into overall speedups although it did for 8 out of 9 machines I tested. On
most machines the overall "System Time" for kernbench is reduced but in 2
out of 9 test machines, the elapsed time increases due to some other caching
weirdness or due to a change in timing with respect to locking.

Pinning down the exact problem is tricky as profile sometimes reverses the
performance effects. i.e. without profiling I'll see a slowdown and
with profiling I see significant speedups so I can't measure what is going
on.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
