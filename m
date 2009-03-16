Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E6C556B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:02:20 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:02:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316120216.GB6382@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <20090316104054.GA23046@wotan.suse.de> <20090316111906.GA6382@csn.ul.ie> <20090316113358.GA30802@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090316113358.GA30802@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 12:33:58PM +0100, Nick Piggin wrote:
> On Mon, Mar 16, 2009 at 11:19:06AM +0000, Mel Gorman wrote:
> > On Mon, Mar 16, 2009 at 11:40:54AM +0100, Nick Piggin wrote:
> > > That's wonderful, but it would
> > > significantly increase the fragmentation problem, wouldn't it?
> > 
> > Not necessarily, anti-fragmentation groups movable pages within a
> > hugepage-aligned block and high-order allocations will trigger a merge of
> > buddies from PAGE_ALLOC_MERGE_ORDER (defined in the relevant patch) up to
> > MAX_ORDER-1. Critically, a merge is also triggered when anti-fragmentation
> > wants to fallback to another migratetype to satisfy an allocation. As
> > long as the grouping works, it doesn't matter if they were only merged up
> > to PAGE_ALLOC_MERGE_ORDER as a full merge will still free up hugepages.
> > So two slow paths are made slower but the fast path should be faster and it
> > should be causing fewer cache line bounces due to writes to struct page.
> 
> Oh, but the anti-fragmentation stuff is orthogonal to this. Movable
> groups should always be defragmentable (at some cost)... the bane of
> anti-frag is fragmentation of the non-movable groups.
> 

True, the reclaimable area has varying degrees of success and the
non-movable groups are almost unworkable and depend on how much of them
depend on pagetables.

> And one reason why buddy is so good at avoiding fragmentation is
> because it will pick up _any_ pages that go past the allocator if
> they have any free buddies. And it hands out ones that don't have
> free buddies. So in that way it is naturally continually filtering
> out pages which can be merged.
> 
> Wheras if you defer this until the point you need a higher order
> page, the only thing you have to work with are the pages that are
> free *right now*.
> 

Well, buddy always uses the smallest available page first. Even with
deferred coalescing, it will merge up to order-5 at least. Lets say they
could have merged up to order-10 in ordinary circumstances, they are
still avoided for as long as possible. Granted, it might mean that an
order-5 is split that could have been merged but it's hard to tell how
much of a difference that makes.

> It will almost definitely increase fragmentation of non movable zones,
> and if you have a workload doing non-trivial, non movable higher order
> allocations that are likely to cause fragmentation, it will result
> in these allocations eating movable groups sooner I think.
> 

I think the effect will be same unless the non-movable high-order
allocations are order-5 or higher in which case we are likely going to
hit trouble anyway.

> 
> > When I last checked (about 10 days) ago, I hadn't damaged anti-fragmentation
> > but that was a lot of revisions ago. I'm redoing the tests to make sure
> > anti-fragmentation is still ok.
> 
> Your anti-frag tests probably don't stress this long term fragmentation
> problem.
> 

Probably not, but we have little data on long-term fragmentation other than
anecdotal evidence that it's ok these days.

> Still, it's significant enough that I think it should be made
> optional (and arguably default to on) even if it does harm higher
> order allocations a bit.
> 

I could make PAGE_ORDER_MERGE_ORDER a proc tunable? If it's placed as a
read-mostly variable beside the gfp_zone table, it might even fit in the
same cache line.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
