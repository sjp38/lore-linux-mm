Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CCD9D8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:58:42 -0500 (EST)
Date: Thu, 10 Feb 2011 14:58:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110210145813.GK17873@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org> <20110209164656.GA1063@csn.ul.ie> <20110209182846.GN3347@random.random> <20110210102109.GB17873@csn.ul.ie> <20110210124838.GU3347@random.random> <20110210133323.GH17873@csn.ul.ie> <20110210141447.GW3347@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110210141447.GW3347@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 03:14:47PM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 10, 2011 at 01:33:24PM +0000, Mel Gorman wrote:
> > Also true, I commented on this in the "Note" your patch deletes and a
> > suggestion on how an alternative would be to break early unless GFP_REPEAT.
> 
> Yep noticed that ;), doing that with __GFP_REPEAT sounds just fine to me.
> 

Great.

> > Sortof. Lumpy reclaim would have scanned more than SWAP_CLUSTER_MAX so
> > scanning was still pretty high. The other costs of lumpy reclaim would hide
> > it of course.
> 
> Ok but we know lumpy reclaim was not ok to start with.
> 

Sure.

> > What about other cases such as order-1 allocations for stack or order-3
> > allocations for those network cards using jumbo frames without
> > scatter/gather?
> 
> stack order 1 is one of the few cases that come to mind where failing
> an allocation becomes fatal. Maybe we should use __GFP_REPEAT there
> too.
> 

Actually, there shouldn't be need. Small allocations such as order-1
effectively loop indefinitely due to the check in should_alloc_retry().
This means that even if reclaim/compaction breaks earlier than it
should, it'll get tried again.

> But we probably need a way to discriminate callers that can gracefully
> fallback. I'd be extremely surprised if the cost of looping all over
> the lru taking down all young bits could ever be offseted by the jumbo
> frame. In fact the jumbo frame I'm afraid might be better off without
> using compaction at all because it's probably very latency
> sensitive.

It depends entirely on whether the jumbo frame can be received with
order-0 pages. If not, it means it's dropping packets which as worse
latency.

> We need a 'lowlatency' version of compaction for these
> users where the improvement of having a compound page instead of a
> regular page isn't very significant.
> 

It's not impossible to pass this information in once the cases where it
is required are identified.

> On a separated topic, I'm currently trying to use the new async
> compaction code upstream with jumbo frames. I'm also wondering if I'll
> have to set sync=0 by default unless __GFP_REPEAT is set. It seems
> adding compaction to jumbo frames is increasing latency to certain
> workloads in a measurable way.

This is interesting. Any profiles showing where the time is being spent?
In the event an order-3 allocation fails with the particular network
card, is it able to fallback to order-0 pages?

> Things were fine when compaction was
> only used by THP and not for all order allocations (but I didn't test
> the async mode yet plus the other optimizations for compaction you did
> recently, I hope they're enough to jumbo frames).
> 

Wish I had your test rig :/

> > Don't get me wrong, I see your point but I'm wondering if there really are
> > cases where we routinely scan an entire LRU list of unevictable pages that
> > are somehow not being migrated properly to the unevictable lists. If
> > this is happening, we are also in trouble for reclaiming for order-0
> > pages, right?
> 
> Well unevictable pages are just an example and like you said they last
> only one round of the loop at most. But other caching bits like the
> referenced bits and all young bits will get all taken down during all
> later loops too. We definitely don't want to swap just to allow
> compaction to succeed! I think this argument explains it pretty well,
> if you takedown all young bits in a constant loop, then system may end
> up swapping. That's definitely something we don't want.
> 

Avoiding the clearing of young bits is a much stronger arguement.

> Things may be different if this is a stack allocation without
> fallback, or if it's hugetlbfs again without kernel fallback (only
> userland fallback).
> 
> > It uses GFP_REPEAT. That is why I specifically mentioned it in the "NOTE"
> > as an alternative to how we could break early while still being agressive
> > when required. The only reason it's not that way now is because a) I didn't
> > consider an LRU mostly full of unevictable pages to be the normal case and b)
> > for allocations such as order-3 that are preferable not to fail.
> 
> Ok.
> 
> > Where should be draw the line? We could come up with ratio of the lists
> > depending on priority but it'd be hard to measure the gain or loss
> > without having a profile of a problem case to look at.
> 
> I would just stick to !nr_reclaimed to break the loop, and ignore the
> nr_scanned unless __GFP_REPEAT is set, in which case you're welcome to
> scan everything.
> 

Patch that should do this is below.

> Then we've to decide if to add __GFP_REPEAT to the stack allocation...
> 

It shouldn't be necessary as the allocator will continue looping.

> > I don't think you have misread anything but if we're going to weaken
> > this logic, I'd at least like to see the GFP_REPEAT option tried - i.e.
> 
> I see the point of __GFP_REPEAT, that sounds the best, I should have
> just followed your comment but I felt scanning everything was too
> heavyweight regardless, but ok I see you want as much accuracy as
> possible in that case, even if that end up in a swap storm.
> 
> > preserve being aggressive if set. I'm also not convinced we routinely get
> > into a situation where the LRU consists of almost all unevictable pages
> > and if we are in this situation, that is a serious problem on its own. It
> > would also be preferable if we could get latency figures on alloc_pages for
> > hugepage-sized allocations and a count of how many are succeeding or failing
> > to measure the impact (if any).
> 
> I think I made not the best example talking about unevictable pages. I
> said that because the code is like below, but to me all the goto
> something following the !page_evictable check were also relevant for
> this shrink_zone loop. The real life issue is avoid swap storm (or
> expensive loop flooding the whole system of ipis to takedown all young
> bits in all ptes), to allocate an hugepage or jumboframe that has a
> graceful fallback that performs not hugely slower than the
> hugepage/jumboframe.
> 
>      	  sc->nr_scanned++;
> 
>           if (unlikely(!page_evictable(page, NULL)))
> 	      goto cull_mlocked;
> 
> I think making the !nr_scanned check conditional to __GFP_REPEAT as
> the comment suggested, for now is the best way to go.
> 

Ok, here is a patch that should do that. This does *not* replace Johannes'
patch which I think should still be merged. However, I am unable to test this
at the moment. My laptop and test machines are 200KM away and inaccessible
until next Tuesday at the earliest. The machine I'm typing this mail from
is unsuitable for testing with. Are you in the position to test THP with it
applied for me please?

==== CUT HERE ====
mm: vmscan: Stop reclaim/compaction when reclaim is failing for !__GFP_REPEAT allocations

should_continue_reclaim() for reclaim/compaction allows scanning to continue
even if pages are not being reclaimed until the full list is scanned. In
terms of allocation success, this makes sense but potentially it introduces
unwanted latency for transparent hugepages and network jumbo frames that
would prefer to fail the allocation attempt and fallback to order-0 pages.
Worse, there is a potential that the full LRU scan will clear all the young
bits, distort page aging information and potentially push pages into swap
that would have otherwise remained resident.

This patch will stop reclaim/compaction if no pages were reclaimed in the
last SWAP_CLUSTER_MAX pages that were considered. For allocations such as
hugetlbfs that use GFP_REPEAT and have fewer fallback options, the full LRU
list may still be scanned.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 148c6e6..591b907 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1841,16 +1841,28 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTION))
 		return false;
 
-	/*
-	 * If we failed to reclaim and have scanned the full list, stop.
-	 * NOTE: Checking just nr_reclaimed would exit reclaim/compaction far
-	 *       faster but obviously would be less likely to succeed
-	 *       allocation. If this is desirable, use GFP_REPEAT to decide
-	 *       if both reclaimed and scanned should be checked or just
-	 *       reclaimed
-	 */
-	if (!nr_reclaimed && !nr_scanned)
-		return false;
+	/* Consider stopping depending on scan and reclaim activity */
+	if (sc->gfp_mask & __GFP_REPEAT) {
+		/*
+		 * For GFP_REPEAT allocations, stop reclaiming if the
+		 * full LRU list has been scanned and we are still failing
+		 * to reclaim pages. This full LRU scan is potentially
+		 * expensive but a GFP_REPEAT caller really wants to succeed
+		 */
+		if (!nr_reclaimed && !nr_scanned)
+			return false;
+	} else {
+		/*
+		 * For non-GFP_REPEAT allocations which can presumably
+		 * fail without consequence, stop if we failed to reclaim
+		 * any pages from the last SWAP_CLUSTER_MAX number of
+		 * pages that were scanned. This will return to the
+		 * caller faster at the risk reclaim/compaction and
+		 * the resulting allocation attempt will fail
+		 */
+		if (!nr_reclaimed)
+			return false;
+	}
 
 	/*
 	 * If we have not reclaimed enough pages for compaction and the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
