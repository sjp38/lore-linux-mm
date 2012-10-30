Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 712D18D0003
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 15:18:49 -0400 (EDT)
Date: Tue, 30 Oct 2012 19:18:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd0: excessive CPU usage
Message-ID: <20121030191843.GH3888@suse.de>
References: <5076E700.2030909@suse.cz>
 <118079.1349978211@turing-police.cc.vt.edu>
 <50770905.5070904@suse.cz>
 <119175.1349979570@turing-police.cc.vt.edu>
 <5077434D.7080008@suse.cz>
 <50780F26.7070007@suse.cz>
 <20121012135726.GY29125@suse.de>
 <507BDD45.1070705@suse.cz>
 <20121015110937.GE29125@suse.de>
 <508E5FD3.1060105@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <508E5FD3.1060105@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 29, 2012 at 11:52:03AM +0100, Thorsten Leemhuis wrote:
> Hi!
> 
> On 15.10.2012 13:09, Mel Gorman wrote:
> >On Mon, Oct 15, 2012 at 11:54:13AM +0200, Jiri Slaby wrote:
> >>On 10/12/2012 03:57 PM, Mel Gorman wrote:
> >>>mm: vmscan: scale number of pages reclaimed by reclaim/compaction only in direct reclaim
> >>>Jiri Slaby reported the following:
> > [...]
> >>>diff --git a/mm/vmscan.c b/mm/vmscan.c
> >>>index 2624edc..2b7edfa 100644
> >>>--- a/mm/vmscan.c
> >>>+++ b/mm/vmscan.c
> >>>@@ -1763,14 +1763,20 @@ static bool in_reclaim_compaction(struct scan_control *sc)
> >>>  #ifdef CONFIG_COMPACTION
> >>>  /*
> >>>   * If compaction is deferred for sc->order then scale the number of pages
> >>>- * reclaimed based on the number of consecutive allocation failures
> >>>+ * reclaimed based on the number of consecutive allocation failures. This
> >>>+ * scaling only happens for direct reclaim as it is about to attempt
> >>>+ * compaction. If compaction fails, future allocations will be deferred
> >>>+ * and reclaim avoided. On the other hand, kswapd does not take compaction
> >>>+ * deferral into account so if it scaled, it could scan excessively even
> >>>+ * though allocations are temporarily not being attempted.
> >>>   */
> >>>  static unsigned long scale_for_compaction(unsigned long pages_for_compaction,
> >>>  			struct lruvec *lruvec, struct scan_control *sc)
> >>>  {
> >>>  	struct zone *zone = lruvec_zone(lruvec);
> >>>
> >>>-	if (zone->compact_order_failed <= sc->order)
> >>>+	if (zone->compact_order_failed <= sc->order &&
> >>>+	    !current_is_kswapd())
> >>>  		pages_for_compaction <<= zone->compact_defer_shift;
> >>>  	return pages_for_compaction;
> >>>  }
> >>Yes, applying this instead of the revert fixes the issue as well.
> 
> Just wondering, is there a reason why this patch wasn't applied to
> mainline? Did it simply fall through the cracks? Or am I missing
> something?
> 

It's because a problem was reported related to the patch (off-list,
whoops). I'm waiting to hear if a second patch fixes the problem or not.

> I'm asking because I think I stil see the issue on
> 3.7-rc2-git-checkout-from-friday. Seems Fedora rawhide users are
> hitting it, too:
> https://bugzilla.redhat.com/show_bug.cgi?id=866988
> 

I like the steps to reproduce. Is step 3 profit?

> Or are we seeing something different which just looks similar?  I can
> test the patch if it needs further testing, but from the discussion
> I got the impression that everything is clear and the patch ready
> for merging.

It could be the same issue. Can you test with the "mm: vmscan: scale
number of pages reclaimed by reclaim/compaction only in direct reclaim"
patch and the following on top please?

Thanks.

---8<---
mm: page_alloc: Do not wake kswapd if the request is for THP but deferred

Since commit c6543459 (mm: remove __GFP_NO_KSWAPD), kswapd gets woken
for every THP request in the slow path. If compaction has been deferred
the waker will not compact or enter direct reclaim on its own behalf
but kswapd is still woken to reclaim free pages that no one may consume.
If compaction was deferred because pages and slab was not reclaimable
then kswapd is just consuming cycles for no gain.

This patch avoids waking kswapd if the compaction has been deferred.
It'll still wake when compaction is running to reduce the latency of
THP allocations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..e72674c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2378,6 +2378,15 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
+/* Returns true if the allocation is likely for THP */
+static bool is_thp_alloc(gfp_t gfp_mask, unsigned int order)
+{
+	if (order == pageblock_order &&
+	    (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
+		return true;
+	return false;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2416,7 +2425,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	wake_all_kswapd(order, zonelist, high_zoneidx,
+	/*
+	 * kswapd is woken except when this is a THP request and compaction
+	 * is deferred. If we are backing off reclaim/compaction then kswapd
+	 * should not be awake aggressively reclaiming with no consumers of
+	 * the freed pages
+	 */
+	if (!(is_thp_alloc(gfp_mask, order) &&
+	      compaction_deferred(preferred_zone, order)))
+		wake_all_kswapd(order, zonelist, high_zoneidx,
 					zone_idx(preferred_zone));
 
 	/*
@@ -2494,7 +2511,7 @@ rebalance:
 	 * system then fail the allocation instead of entering direct reclaim.
 	 */
 	if ((deferred_compaction || contended_compaction) &&
-	    (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
+	    is_thp_alloc(gfp_mask, order))
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
