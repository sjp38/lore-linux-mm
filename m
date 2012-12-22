Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 615B16B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 13:54:07 -0500 (EST)
Date: Sat, 22 Dec 2012 19:54:01 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr> <20121220111208.GD10819@suse.de> <20121220125802.23e9b22d.akpm@linux-foundation.org>
In-Reply-To: <20121220125802.23e9b22d.akpm@linux-foundation.org>
Message-ID: <50D601C9.9060803@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Subject: [PATCH] mm: modify pgdat_balanced() so that it also handles order=0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 20.12.2012 21:58, Andrew Morton wrote:
> There seems to be some complexity/duplication here between the new
> unbalanced_zone() and pgdat_balanced().
> 
> Can we modify pgdat_balanced() so that it also handles order=0, then do
> 
> -		if (!unbalanced_zone || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
> +		if (!pgdat_balanced(...))
> 
> ?
> 

Makes sense, I like the idea! Took me some time to wrap my mind around
all the logic in balance_pgdat(), while writing my previous patch. Also had
to revert one if-case logic to avoid double negation, which would be even
harder to grok. But unbalanced_zone (var, not a function!) has to stay because
wait_iff_congested() needs a struct zone* param. Here's my take on the subject:

---8<---
mm: modify pgdat_balanced() so that it also handles order=0

Teach pgdat_balanced() about order-0 allocations so that we can simplify
code in a few places in vmstat.c.

Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
---
 mm/vmscan.c | 101 +++++++++++++++++++++++++++---------------------------------
 1 file changed, 45 insertions(+), 56 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index adc7e90..0d15d99 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2452,12 +2452,16 @@ static bool zone_balanced(struct zone *zone, int order,
 }
 
 /*
- * pgdat_balanced is used when checking if a node is balanced for high-order
- * allocations. Only zones that meet watermarks and are in a zone allowed
- * by the callers classzone_idx are added to balanced_pages. The total of
- * balanced pages must be at least 25% of the zones allowed by classzone_idx
- * for the node to be considered balanced. Forcing all zones to be balanced
- * for high orders can cause excessive reclaim when there are imbalanced zones.
+ * pgdat_balanced() is used when checking if a node is balanced.
+ *
+ * For order-0, all zones must be balanced!
+ *
+ * For high-order allocations only zones that meet watermarks and are in a
+ * zone allowed by the callers classzone_idx are added to balanced_pages. The
+ * total of balanced pages must be at least 25% of the zones allowed by
+ * classzone_idx for the node to be considered balanced. Forcing all zones to
+ * be balanced for high orders can cause excessive reclaim when there are
+ * imbalanced zones.
  * The choice of 25% is due to
  *   o a 16M DMA zone that is balanced will not balance a zone on any
  *     reasonable sized machine
@@ -2467,17 +2471,43 @@ static bool zone_balanced(struct zone *zone, int order,
  *     Similarly, on x86-64 the Normal zone would need to be at least 1G
  *     to balance a node on its own. These seemed like reasonable ratios.
  */
-static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
-						int classzone_idx)
+static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	unsigned long present_pages = 0;
+	unsigned long balanced_pages = 0;
 	int i;
 
-	for (i = 0; i <= classzone_idx; i++)
-		present_pages += pgdat->node_zones[i].present_pages;
+	/* Check the watermark levels */
+	for (i = 0; i <= classzone_idx; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
+
+		present_pages += zone->present_pages;
+
+		/*
+		 * A special case here:
+		 *
+		 * balance_pgdat() skips over all_unreclaimable after
+		 * DEF_PRIORITY. Effectively, it considers them balanced so
+		 * they must be considered balanced here as well!
+		 */
+		if (zone->all_unreclaimable) {
+			balanced_pages += zone->present_pages;
+			continue;
+		}
+
+		if (zone_balanced(zone, order, 0, i))
+			balanced_pages += zone->present_pages;
+		else if (!order)
+			return false;
+	}
 
-	/* A special case here: if zone has no page, we think it's balanced */
-	return balanced_pages >= (present_pages >> 2);
+	if (order)
+		return balanced_pages >= (present_pages >> 2);
+	else
+		return true;
 }
 
 /*
@@ -2511,39 +2541,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 		return false;
 	}
 
-	/* Check the watermark levels */
-	for (i = 0; i <= classzone_idx; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		if (!populated_zone(zone))
-			continue;
-
-		/*
-		 * balance_pgdat() skips over all_unreclaimable after
-		 * DEF_PRIORITY. Effectively, it considers them balanced so
-		 * they must be considered balanced here as well if kswapd
-		 * is to sleep
-		 */
-		if (zone->all_unreclaimable) {
-			balanced += zone->present_pages;
-			continue;
-		}
-
-		if (!zone_balanced(zone, order, 0, i))
-			all_zones_ok = false;
-		else
-			balanced += zone->present_pages;
-	}
-
-	/*
-	 * For high-order requests, the balanced zones must contain at least
-	 * 25% of the nodes pages for kswapd to sleep. For order-0, all zones
-	 * must be balanced
-	 */
-	if (order)
-		return pgdat_balanced(pgdat, balanced, classzone_idx);
-	else
-		return all_zones_ok;
+	return pgdat_balanced(pgdat, order, classzone_idx);
 }
 
 /*
@@ -2571,7 +2569,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
 	struct zone *unbalanced_zone;
-	unsigned long balanced;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
@@ -2605,7 +2602,6 @@ loop_again:
 		int has_under_min_watermark_zone = 0;
 
 		unbalanced_zone = NULL;
-		balanced = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2761,8 +2757,6 @@ loop_again:
 				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= *classzone_idx)
-					balanced += zone->present_pages;
 			}
 
 		}
@@ -2776,7 +2770,7 @@ loop_again:
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up(&pgdat->pfmemalloc_wait);
 
-		if (!unbalanced_zone || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
+		if (pgdat_balanced(pgdat, order, *classzone_idx))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2800,12 +2794,7 @@ loop_again:
 	} while (--sc.priority >= 0);
 out:
 
-	/*
-	 * order-0: All zones must meet high watermark for a balanced node
-	 * high-order: Balanced zones must make up at least 25% of the node
-	 *             for the node to be balanced
-	 */
-	if (unbalanced_zone && (!order || !pgdat_balanced(pgdat, balanced, *classzone_idx))) {
+	if (!pgdat_balanced(pgdat, order, *classzone_idx)) {
 		cond_resched();
 
 		try_to_freeze();
-- 
1.8.1.rc0

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
