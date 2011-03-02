Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CAF708D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 00:52:51 -0500 (EST)
Date: Wed, 2 Mar 2011 06:52:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] remove compaction from kswapd
Message-ID: <20110302055221.GD23911@random.random>
References: <20110228222138.GP22700@random.random>
 <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
 <20110301223954.GI19057@random.random>
 <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
 <20110301164143.e44e5699.akpm@linux-foundation.org>
 <20110302043856.GB23911@random.random>
 <20110301205324.f0daaf86.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301205324.f0daaf86.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Tue, Mar 01, 2011 at 08:53:24PM -0800, Andrew Morton wrote:
> The original patch description didn't explain this.

Right, I should have added one line saying it was a revert of commit
5a03b051ed87e72b959f32a86054e1142ac4cf55 sorry. Mel knew it well, I
thought it was well known but it was better to specify it.

Minchan also noted I didn't remove compact_mode from the
compact_control structure but that's entirely harmless.

All we need is to run `git show
5a03b051ed87e72b959f32a86054e1142ac4cf55|patch -p1 -R` except it's not
going to apply clean so I had to create a patch for that.

> And no patch is "zero risk", especially at -rc6.

Well sure, but I see little chance for this to give unexpected
troubles (also CONFIG_COMPACTION remains an option default to N).

> And we have no useful information about benchmark results.

I've been discussing with Mel to write a simulator with some dummy
kernel module that floods the kernel with order 2 allocations. We need
that before we can try to readd this. So we can have real sure
benchmarks and we can reproduce easily. The multimedia setup and the
network jumbo frame benchmarks are not the simplest way to reproduce.

> What change?  Commit ID?  What testing returned -EFAIL?  That's
> different from slower benchmark results.

I meant testing showed a definitive regression on two absolutely
different workload (but that they both had compound allocation in
drivers, and both bisected down to that specific compaction-kswapd
code), no syscall really returned -EFAULT. I posted commit id above.

> *What* two patches???  I don't have a clue which patches you're referring to. 
> Patches have names, please use them.

These are the other two patches that are needed for both workloads to
be better than before.

mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration
mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pages

These two are important too because even the NMI watchdog triggered
once without these. But this irq latency problem in compaction was
shown by commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 that made
compaction run too much. These are separate problems.

> This is just hopeless.  Please, just send the thing again and this time
> include a *full* description of what it does and why it does it.

Ok the thing is I'm being quite busy and wifi coverage isn't full, I'm
writing this in some lobby where I pick up the connection, but I tried
to get it submitted anyway because I liked to revert the feature ASAP
as I didn't want to risk regressions because of this one. I'll give it
another shot now, but if it isn't ok let me know and I'll try again
tomorrow afternoon. (also note this isn't related to THP, THP uses
__GFP_NO_KSWAPD, it's for the other users of compound pages). This is
one case where we thought it was a good idea, but in practice it
didn't payoff the way we thought.

I initially asked Mel to submit the patch as I hoped he had more time
than me this week, but he suggested me to send it, so I did. But I
didn't intend to cause this confusion, sorry Andrew!

My rationale is that even assuming the benchmarking is absolutely
wrong and commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 improved
latency and througput (almost impossible considering that two people
running different workloads sent me bugreports bisecting down to that
exact same commit showing both bad irq latencies showing kswapd
overwork in the profiling or top) to me it's still safer to revert it
in doubt (considering it's not very important) and re-evaluate it
fully for 2.6.39. This is really all about going safe. This is about
not risking to introduce a regression. Unfortunately it was reported
only late that this patch caused trouble, if they reported it before I
would have never submitted commit
5a03b051ed87e72b959f32a86054e1142ac4cf55 in the first place.

I still hope we can find with Mel, Minchan and everyone else a better
logic to run compaction from kswapd without creating an overload
later. My improved logic already works almost as good as reverting the
feature, but it's still not as fast as with the below applied (close
enough though). I'm not sending the "improved" version exactly because
I don't want risk and it's not yet "faster" than the below. So I
surely prefer the backout for 2.6.38.

===
Subject: compaction: fix high compaction latencies and remove compaction-kswapd

From: Andrea Arcangeli <aarcange@redhat.com>

This reverts commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 which is causing
latency problems and higher kswapd cpu utilization. Reverting that commit that
adds the compaction-in-kswapd feature is safer than trying to fix it to return
to 2.6.37 status.

NOTE: this is not related to THP (THP allocations uses __GFP_NO_KSWAPD), this
is only related to frequent and small order allocations that make kswapd go
wild with compaction.

v2: removed compact_mode from compact_control (noticed by Minchan Kim).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/compaction.h |    9 ++-------
 mm/compaction.c            |   42 +++++++++++++++++++++---------------------
 mm/vmscan.c                |   18 +-----------------
 3 files changed, 24 insertions(+), 45 deletions(-)

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -42,8 +42,6 @@ struct compact_control {
 	unsigned int order;		/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-
-	int compact_mode;
 };
 
 static unsigned long release_freepages(struct list_head *freelist)
@@ -279,9 +277,27 @@ static unsigned long isolate_migratepage
 	}
 
 	/* Time to isolate some pages for migration */
+	cond_resched();
 	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
+		int unlocked = 0;
+
+		/* give a chance to irqs before checking need_resched() */
+		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
+			spin_unlock_irq(&zone->lru_lock);
+			unlocked = 1;
+		}
+		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
+			if (!unlocked)
+				spin_unlock_irq(&zone->lru_lock);
+			cond_resched();
+			spin_lock_irq(&zone->lru_lock);
+			if (fatal_signal_pending(current))
+				break;
+		} else if (unlocked)
+			spin_lock_irq(&zone->lru_lock);
+
 		if (!pfn_valid_within(low_pfn))
 			continue;
 		nr_scanned++;
@@ -405,10 +421,7 @@ static int compact_finished(struct zone 
 		return COMPACT_COMPLETE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	if (cc->compact_mode != COMPACT_MODE_KSWAPD)
-		watermark = low_wmark_pages(zone);
-	else
-		watermark = high_wmark_pages(zone);
+	watermark = low_wmark_pages(zone);
 	watermark += (1 << cc->order);
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
@@ -421,15 +434,6 @@ static int compact_finished(struct zone 
 	if (cc->order == -1)
 		return COMPACT_CONTINUE;
 
-	/*
-	 * Generating only one page of the right order is not enough
-	 * for kswapd, we must continue until we're above the high
-	 * watermark as a pool for high order GFP_ATOMIC allocations
-	 * too.
-	 */
-	if (cc->compact_mode == COMPACT_MODE_KSWAPD)
-		return COMPACT_CONTINUE;
-
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		/* Job done if page is free of the right migratetype */
@@ -551,8 +555,7 @@ static int compact_zone(struct zone *zon
 
 unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync,
-				 int compact_mode)
+				 bool sync)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -561,7 +564,6 @@ unsigned long compact_zone_order(struct 
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.compact_mode = compact_mode,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -607,8 +609,7 @@ unsigned long try_to_compact_pages(struc
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync,
-					    COMPACT_MODE_DIRECT_RECLAIM);
+		status = compact_zone_order(zone, order, gfp_mask, sync);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -639,7 +640,6 @@ static int compact_node(int nid)
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
 			.order = -1,
-			.compact_mode = COMPACT_MODE_DIRECT_RECLAIM,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -11,9 +11,6 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
-#define COMPACT_MODE_DIRECT_RECLAIM	0
-#define COMPACT_MODE_KSWAPD		1
-
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -28,8 +25,7 @@ extern unsigned long try_to_compact_page
 			bool sync);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 extern unsigned long compact_zone_order(struct zone *zone, int order,
-					gfp_t gfp_mask, bool sync,
-					int compact_mode);
+					gfp_t gfp_mask, bool sync);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -74,8 +70,7 @@ static inline unsigned long compaction_s
 }
 
 static inline unsigned long compact_zone_order(struct zone *zone, int order,
-					       gfp_t gfp_mask, bool sync,
-					       int compact_mode)
+					       gfp_t gfp_mask, bool sync)
 {
 	return COMPACT_CONTINUE;
 }
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,7 +2397,6 @@ loop_again:
 		 * cause too much scanning of the lower zones.
 		 */
 		for (i = 0; i <= end_zone; i++) {
-			int compaction;
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
 			unsigned long balance_gap;
@@ -2438,24 +2437,9 @@ loop_again:
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 
-			compaction = 0;
-			if (order &&
-			    zone_watermark_ok(zone, 0,
-					       high_wmark_pages(zone),
-					      end_zone, 0) &&
-			    !zone_watermark_ok(zone, order,
-					       high_wmark_pages(zone),
-					       end_zone, 0)) {
-				compact_zone_order(zone,
-						   order,
-						   sc.gfp_mask, false,
-						   COMPACT_MODE_KSWAPD);
-				compaction = 1;
-			}
-
 			if (zone->all_unreclaimable)
 				continue;
-			if (!compaction && nr_slab == 0 &&
+			if (nr_slab == 0 &&
 			    !zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
