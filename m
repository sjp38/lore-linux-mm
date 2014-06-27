Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 339696B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 14:42:34 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so3282576wiv.2
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 11:42:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x16si18643580wiv.50.2014.06.27.11.42.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 11:42:32 -0700 (PDT)
Date: Fri, 27 Jun 2014 19:42:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/5] mm: vmscan: Do not reclaim from lower zones if they
 are balanced
Message-ID: <20140627184227.GL10819@suse.de>
References: <1403856880-12597-1-git-send-email-mgorman@suse.de>
 <1403856880-12597-4-git-send-email-mgorman@suse.de>
 <20140627172657.GU7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140627172657.GU7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Jun 27, 2014 at 01:26:57PM -0400, Johannes Weiner wrote:
> On Fri, Jun 27, 2014 at 09:14:38AM +0100, Mel Gorman wrote:
> > Historically kswapd scanned from DMA->Movable in the opposite direction
> > to the page allocator to avoid allocating behind kswapd direction of
> > progress. The fair zone allocation policy altered this in a non-obvious
> > manner.
> > 
> > Traditionally, the page allocator prefers to use the highest eligible zone
> > until the watermark is depleted, woke kswapd and moved onto the next zone.
> 
> That's not quite right, the page allocator tries all zones in the
> zonelist, then wakes up kswapd, then tries again from the beginning.
> 

You're right of course, sorry about that. It still is the case that once
kswapd is awake that it can reclaim from the lower zones for longer than
the higher zones and this does not play well with the fair zone policy
interleaving between them.

> > kswapd scans zones in the opposite direction so the scanning lists on
> > 64-bit look like this;
> > 
> > Page alloc		Kswapd
> > ----------              ------
> > Movable			DMA
> > Normal			DMA32
> > DMA32			Normal
> > DMA			Movable
> > 
> > If kswapd scanned in the same direction as the page allocator then it is
> > possible that kswapd would proportionally reclaim the lower zones that
> > were never used as the page allocator was always allocating behind the
> > reclaim. This would work as follows
> > 
> > 	pgalloc hits Normal low wmark
> > 					kswapd reclaims Normal
> > 					kswapd reclaims DMA32
> > 	pgalloc hits Normal low wmark
> > 					kswapd reclaims Normal
> > 					kswapd reclaims DMA32
> > 
> > The introduction of the fair zone allocation policy fundamentally altered
> > this problem by interleaving between zones until the low watermark is
> > reached. There are at least two issues with this
> > 
> > o The page allocator can allocate behind kswapds progress (scans/reclaims
> >   lower zone and fair zone allocation policy then uses those pages)
> > o When the low watermark of the high zone is reached there may recently
> >   allocated pages allocated from the lower zone but as kswapd scans
> >   dma->highmem to the highest zone needing balancing it'll reclaim the
> >   lower zone even if it was balanced.
> > 
> > Let N = high_wmark(Normal) + high_wmark(DMA32). Of the last N allocations,
> > some percentage will be allocated from Normal and some from DMA32. The
> > percentage depends on the ratio of the zone sizes and when their watermarks
> > were hit. If Normal is unbalanced, DMA32 will be shrunk by kswapd. If DMA32
> > is unbalanced only DMA32 will be shrunk. This leads to a difference of
> > ages between DMA32 and Normal. Relatively young pages are then continually
> > rotated and reclaimed from DMA32 due to the higher zone being unbalanced.
> > Some of these pages may be recently read-ahead pages requiring that the page
> > be re-read from disk and impacting overall performance.
> > 
> > The problem is fundamental to the fact we have per-zone LRU and allocation
> > policies and ideally we would only have per-node allocation and LRU lists.
> > This would avoid the need for the fair zone allocation policy but the
> > low-memory-starvation issue would have to be addressed again from scratch.
> > 
> > This patch will only scan/reclaim from lower zones if they have not
> > reached their watermark. This should not break the normal page aging
> > as the proportional allocations due to the fair zone allocation policy
> > should compensate.
> 
> That's already the case, kswapd_shrink_zone() checks whether the zone
> is balanced before scanning in, so something in this analysis is off -
> but I have to admit that I have trouble following it.
> 
> The only difference in the two checks is that the outer one you add
> does not enforce the balance gap, which means that we stop reclaiming
> zones a little earlier than before. 

Not only is the balance gap a factor (which can be large) but the classzone
reserves are also applied which will keep kswapd reclaiming longer.  Still,
you're right. It's far more appropriate to push the checks down where the
buffer head reserves are accounted for.

I still think that ultimately we want to move the LRUs to a per-node
basis. It should be possible to do this piecemeal and keep the free page
lists on a per-zone basis and have direct reclaim skip through the LRU
finding lowmem pages if that is required. It would be a fairly far-reaching
change but overall the aging would make more sense and it would remove
the fair zone allocation policy entirely. It'd hurt while reclaiming for
lowmem on 32-bit with large highmem zones but I think that is far less a
concern than it would have been 10 years ago.

> I guess this is where the
> throughput improvements come from, but there is a chance it will
> regress latency for bursty allocations.

Any suggestions on how to check that? I would expect that bursty
allocations are falling into the slow path and potentially doing direct
reclaim. That would make the effect difficult to measure.

This is the version that is currently being tested

---8<---
mm: vmscan: Do not reclaim from lower zones if they are balanced

Historically kswapd scanned from DMA->Movable in the opposite direction
to the page allocator to avoid allocating behind kswapd direction of
progress. The fair zone allocation policy altered this in a non-obvious
manner.

Traditionally, the page allocator prefers to use the highest eligible
zones in order until the low watermarks are reached and then wakes kswapd.
Once kswapd is awake, it scans zones in the opposite direction so the
scanning lists on 64-bit look like this;

Page alloc		Kswapd
----------              ------
Movable			DMA
Normal			DMA32
DMA32			Normal
DMA			Movable

If kswapd scanned in the same direction as the page allocator then it is
possible that kswapd would proportionally reclaim the lower zones that
were never used as the page allocator was always allocating behind the
reclaim. This would work as follows

	pgalloc hits Normal low wmark
					kswapd reclaims Normal
					kswapd reclaims DMA32
	pgalloc hits Normal low wmark
					kswapd reclaims Normal
					kswapd reclaims DMA32

The introduction of the fair zone allocation policy fundamentally altered
this problem by interleaving between zones until the low watermark is
reached. There are at least two issues with this

o The page allocator can allocate behind kswapds progress (scans/reclaims
  lower zone and fair zone allocation policy then uses those pages)
o When the low watermark of the high zone is reached there may recently
  allocated pages allocated from the lower zone but as kswapd scans
  dma->highmem to the highest zone needing balancing it'll reclaim the
  lower zone even if it was balanced.

Let N = high_wmark(Normal) + high_wmark(DMA32). Of the last N allocations,
some percentage will be allocated from Normal and some from DMA32. The
percentage depends on the ratio of the zone sizes and when their watermarks
were hit. If Normal is unbalanced, DMA32 will be shrunk by kswapd. If DMA32
is unbalanced only DMA32 will be shrunk. This leads to a difference of
ages between DMA32 and Normal. Relatively young pages are then continually
rotated and reclaimed from DMA32 due to the higher zone being unbalanced.
Some of these pages may be recently read-ahead pages requiring that the page
be re-read from disk and impacting overall performance.

The problem is fundamental to the fact we have per-zone LRU and allocation
policies and ideally we would only have per-node allocation and LRU lists.
This would avoid the need for the fair zone allocation policy but the
low-memory-starvation issue would have to be addressed again from scratch.

kswapd shrinks equally from all zones up to the high watermark plus a
balance gap and the lowmem reserves. This patch removes the additional
reclaim from lower zones on the grounds that the fair zone allocation
policy will typically be interleaving between the zones.  This should not
break the normal page aging as the proportional allocations due to the
fair zone allocation policy should compensate.

tiobench was used to evaluate this because it includes a simple
sequential reader which is the most obvious regression. It also has threaded
readers that produce reasonably steady figures.

                                      3.16.0-rc2            3.16.0-rc2                 3.0.0
                                         vanilla           checklow-v4               vanilla
TO-BE-UPDATED

There are still regressions for higher number of threads but this is
related to changes in the CFQ IO scheduler.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/swap.h |  9 ---------
 mm/vmscan.c          | 46 ++++++++++++++++------------------------------
 2 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bdbee8..1680307 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -165,15 +165,6 @@ enum {
 #define SWAP_CLUSTER_MAX 32UL
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
-/*
- * Ratio between zone->managed_pages and the "gap" that above the per-zone
- * "high_wmark". While balancing nodes, We allow kswapd to shrink zones that
- * do not meet the (high_wmark + gap) watermark, even which already met the
- * high_wmark, in order to provide better per-zone lru behavior. We are ok to
- * spend not more than 1% of the memory for this zone balancing "gap".
- */
-#define KSWAPD_ZONE_BALANCE_GAP_RATIO 100
-
 #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
 #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
 #define SWAP_HAS_CACHE	0x40	/* Flag page is cached, in first swap_map */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe..3e315c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2294,7 +2294,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 /* Returns true if compaction should go ahead for a high-order request */
 static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 {
-	unsigned long balance_gap, watermark;
+	unsigned long watermark;
 	bool watermark_ok;
 
 	/* Do not consider compaction for orders reclaim is meant to satisfy */
@@ -2307,9 +2307,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
-	watermark = high_wmark_pages(zone) + balance_gap + (2UL << sc->order);
+	watermark = high_wmark_pages(zone) + (2UL << sc->order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
 
 	/*
@@ -2816,11 +2814,9 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	} while (memcg);
 }
 
-static bool zone_balanced(struct zone *zone, int order,
-			  unsigned long balance_gap, int classzone_idx)
+static bool zone_balanced(struct zone *zone, int order)
 {
-	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
-				    balance_gap, classzone_idx, 0))
+	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone), 0, 0))
 		return false;
 
 	if (IS_ENABLED(CONFIG_COMPACTION) && order &&
@@ -2877,7 +2873,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 			continue;
 		}
 
-		if (zone_balanced(zone, order, 0, i))
+		if (zone_balanced(zone, order))
 			balanced_pages += zone->managed_pages;
 		else if (!order)
 			return false;
@@ -2934,7 +2930,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
 			       unsigned long *nr_attempted)
 {
 	int testorder = sc->order;
-	unsigned long balance_gap;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
@@ -2956,21 +2951,11 @@ static bool kswapd_shrink_zone(struct zone *zone,
 		testorder = 0;
 
 	/*
-	 * We put equal pressure on every zone, unless one zone has way too
-	 * many pages free already. The "too many pages" is defined as the
-	 * high wmark plus a "gap" where the gap is either the low
-	 * watermark or 1% of the zone, whichever is smaller.
-	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
-
-	/*
 	 * If there is no low memory pressure or the zone is balanced then no
 	 * reclaim is necessary
 	 */
 	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
-	if (!lowmem_pressure && zone_balanced(zone, testorder,
-						balance_gap, classzone_idx))
+	if (!lowmem_pressure && zone_balanced(zone, testorder))
 		return true;
 
 	shrink_zone(zone, sc);
@@ -2993,7 +2978,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * waits.
 	 */
 	if (zone_reclaimable(zone) &&
-	    zone_balanced(zone, testorder, 0, classzone_idx)) {
+	    zone_balanced(zone, testorder)) {
 		zone_clear_flag(zone, ZONE_CONGESTED);
 		zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
 	}
@@ -3079,7 +3064,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order)) {
 				end_zone = i;
 				break;
 			} else {
@@ -3124,12 +3109,13 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 
 		/*
 		 * Now scan the zone in the dma->highmem direction, stopping
-		 * at the last zone which needs scanning.
-		 *
-		 * We do this because the page allocator works in the opposite
-		 * direction.  This prevents the page allocator from allocating
-		 * pages behind kswapd's direction of progress, which would
-		 * cause too much scanning of the lower zones.
+		 * at the last zone which needs scanning. We do this because
+		 * the page allocators prefers to work in the opposite
+		 * direction and we want to avoid the page allocator reclaiming
+		 * behind kswapd's direction of progress. Due to the fair zone
+		 * allocation policy interleaving allocations between zones
+		 * we no longer proportionally scan the lower zones if the
+		 * watermarks are ok.
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
@@ -3397,7 +3383,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0))
+	if (zone_balanced(zone, order))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
