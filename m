Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 372F26B006E
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 05:08:03 -0400 (EDT)
Date: Wed, 8 Aug 2012 10:07:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] mm: kswapd: Continue reclaiming for
 reclaim/compaction if the minimum number of pages have not been reclaimed
Message-ID: <20120808090757.GK29814@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-4-git-send-email-mgorman@suse.de>
 <20120808020749.GC4247@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120808020749.GC4247@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 11:07:49AM +0900, Minchan Kim wrote:
> On Tue, Aug 07, 2012 at 01:31:14PM +0100, Mel Gorman wrote:
> > When direct reclaim is running reclaim/compaction, there is a minimum
> > number of pages it reclaims. As it must be under the low watermark to be
> > in direct reclaim it has also woken kswapd to do some work. This patch
> > has kswapd use the same logic as direct reclaim to reclaim a minimum
> > number of pages so compaction can run later.
> 
> -ENOPARSE by my stupid brain.
> Could you elaborate a bit more?
> 

Which part did not make sense so I know which part to elaborate on? Lets
try again randomly with this;

When direct reclaim is running reclaim/compaction for high-order allocations,
it aims to reclaim a minimum number of pages for compaction as controlled
by should_continue_reclaim. Before it entered direct reclaim, kswapd was
woken to reclaim pages at the same order. This patch forces kswapd to use
the same logic as direct reclaim to reclaim a minimum number of pages so
that subsequent allocation requests are less likely to enter direct reclaim.

> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c |   19 ++++++++++++++++---
> >  1 file changed, 16 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 0cb2593..afdec93 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1701,7 +1701,7 @@ static bool in_reclaim_compaction(struct scan_control *sc)
> >   * calls try_to_compact_zone() that it will have enough free pages to succeed.
> >   * It will give up earlier than that if there is difficulty reclaiming pages.
> >   */
> > -static inline bool should_continue_reclaim(struct lruvec *lruvec,
> > +static bool should_continue_reclaim(struct lruvec *lruvec,
> >  					unsigned long nr_reclaimed,
> >  					unsigned long nr_scanned,
> >  					struct scan_control *sc)
> > @@ -1768,6 +1768,17 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
> >  	}
> >  }
> >  
> > +static inline bool should_continue_reclaim_zone(struct zone *zone,
> > +					unsigned long nr_reclaimed,
> > +					unsigned long nr_scanned,
> > +					struct scan_control *sc)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_iter(NULL, NULL, NULL);
> > +	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> > +
> > +	return should_continue_reclaim(lruvec, nr_reclaimed, nr_scanned, sc);
> > +}
> > +
> >  /*
> >   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
> >   */
> > @@ -2496,8 +2507,10 @@ loop_again:
> >  			 */
> >  			testorder = order;
> >  			if (COMPACTION_BUILD && order &&
> > -					compaction_suitable(zone, order) !=
> > -						COMPACT_SKIPPED)
> > +					!should_continue_reclaim_zone(zone,
> > +						nr_soft_reclaimed,
> 
> nr_soft_reclaimed is always zero with !CONFIG_MEMCG.
> So should_continue_reclaim_zone would return normally true in case of
> non-__GFP_REPEAT allocation. Is it intentional?
> 

It was intentional at the time but asking me about it made me reconsider,
thanks. In too many cases, this is a no-op and any apparent increase of
kswapd activity is likely a co-incidence. This is untested but is what I
intended.

---8<---
mm: kswapd: Continue reclaiming for reclaim/compaction if the minimum number of pages have not been reclaimed

When direct reclaim is running reclaim/compaction for high-order allocations,
it aims to reclaim a minimum number of pages for compaction as controlled
by should_continue_reclaim. Before it entered direct reclaim, kswapd was
woken to reclaim pages at the same order. This patch forces kswapd to use
the same logic as direct reclaim to reclaim a minimum number of pages so
that subsequent allocation requests are less likely to enter direct reclaim.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   81 ++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 50 insertions(+), 31 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0cb2593..6840218 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1696,14 +1696,11 @@ static bool in_reclaim_compaction(struct scan_control *sc)
 
 /*
  * Reclaim/compaction is used for high-order allocation requests. It reclaims
- * order-0 pages before compacting the zone. should_continue_reclaim() returns
+ * order-0 pages before compacting the zone. __should_continue_reclaim() returns
  * true if more pages should be reclaimed such that when the page allocator
  * calls try_to_compact_zone() that it will have enough free pages to succeed.
- * It will give up earlier than that if there is difficulty reclaiming pages.
  */
-static inline bool should_continue_reclaim(struct lruvec *lruvec,
-					unsigned long nr_reclaimed,
-					unsigned long nr_scanned,
+static bool __should_continue_reclaim(struct lruvec *lruvec,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
@@ -1714,29 +1711,6 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	if (!in_reclaim_compaction(sc))
 		return false;
 
-	/* Consider stopping depending on scan and reclaim activity */
-	if (sc->gfp_mask & __GFP_REPEAT) {
-		/*
-		 * For __GFP_REPEAT allocations, stop reclaiming if the
-		 * full LRU list has been scanned and we are still failing
-		 * to reclaim pages. This full LRU scan is potentially
-		 * expensive but a __GFP_REPEAT caller really wants to succeed
-		 */
-		if (!nr_reclaimed && !nr_scanned)
-			return false;
-	} else {
-		/*
-		 * For non-__GFP_REPEAT allocations which can presumably
-		 * fail without consequence, stop if we failed to reclaim
-		 * any pages from the last SWAP_CLUSTER_MAX number of
-		 * pages that were scanned. This will return to the
-		 * caller faster at the risk reclaim/compaction and
-		 * the resulting allocation attempt fails
-		 */
-		if (!nr_reclaimed)
-			return false;
-	}
-
 	/*
 	 * If we have not reclaimed enough pages for compaction and the
 	 * inactive lists are large enough, continue reclaiming
@@ -1768,6 +1742,51 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	}
 }
 
+/* Looks up the lruvec before calling __should_continue_reclaim */
+static inline bool should_kswapd_continue_reclaim(struct zone *zone,
+					struct scan_control *sc)
+{
+	struct mem_cgroup *memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+
+	return __should_continue_reclaim(lruvec, sc);
+}
+
+/*
+ * This uses __should_continue_reclaim at its core but will also give up
+ * earlier than that if there is difficulty reclaiming pages.
+ */
+static inline bool should_direct_continue_reclaim(struct lruvec *lruvec,
+					unsigned long nr_reclaimed,
+					unsigned long nr_scanned,
+					struct scan_control *sc)
+{
+	/* Consider stopping depending on scan and reclaim activity */
+	if (sc->gfp_mask & __GFP_REPEAT) {
+		/*
+		 * For __GFP_REPEAT allocations, stop reclaiming if the
+		 * full LRU list has been scanned and we are still failing
+		 * to reclaim pages. This full LRU scan is potentially
+		 * expensive but a __GFP_REPEAT caller really wants to succeed
+		 */
+		if (!nr_reclaimed && !nr_scanned)
+			return false;
+	} else {
+		/*
+		 * For non-__GFP_REPEAT allocations which can presumably
+		 * fail without consequence, stop if we failed to reclaim
+		 * any pages from the last SWAP_CLUSTER_MAX number of
+		 * pages that were scanned. This will return to the
+		 * caller faster at the risk reclaim/compaction and
+		 * the resulting allocation attempt fails
+		 */
+		if (!nr_reclaimed)
+			return false;
+	}
+
+	return __should_continue_reclaim(lruvec, sc);
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -1822,7 +1841,7 @@ restart:
 				   sc, LRU_ACTIVE_ANON);
 
 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(lruvec, nr_reclaimed,
+	if (should_direct_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
@@ -2496,8 +2515,8 @@ loop_again:
 			 */
 			testorder = order;
 			if (COMPACTION_BUILD && order &&
-					compaction_suitable(zone, order) !=
-						COMPACT_SKIPPED)
+					!should_kswapd_continue_reclaim(zone,
+						&sc))
 				testorder = 0;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
