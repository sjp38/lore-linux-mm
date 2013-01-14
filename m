Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 19D3F6B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 09:43:59 -0500 (EST)
Date: Mon, 14 Jan 2013 15:43:52 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
Message-ID: <50F419A8.8000307@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Subject: [PATCH] mm: don't wait on congested zones in balance_pgdat()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

From: Zlatko Calusic <zlatko.calusic@iskon.hr>

Commit 92df3a72 (mm: vmscan: throttle reclaim if encountering too many
dirty pages under writeback) introduced waiting on congested zones
based on a sane algorithm in shrink_inactive_list(). What this means
is that there's no more need for throttling and additional heuristics
in balance_pgdat(). So, let's remove it and tidy up the code.

Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
---
 include/linux/vm_event_item.h |  1 -
 mm/vmscan.c                   | 29 +----------------------------
 mm/vmstat.c                   |  1 -
 3 files changed, 1 insertion(+), 30 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index e84a25e..d4b7a18 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -36,7 +36,6 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
-		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32fbfdb..fea5a0b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2619,7 +2619,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
 	bool pgdat_is_balanced = false;
-	struct zone *unbalanced_zone;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
@@ -2650,9 +2649,6 @@ loop_again:
 
 	do {
 		unsigned long lru_pages = 0;
-		int has_under_min_watermark_zone = 0;
-
-		unbalanced_zone = NULL;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2792,17 +2788,7 @@ loop_again:
 				continue;
 			}
 
-			if (!zone_balanced(zone, testorder, 0, end_zone)) {
-				unbalanced_zone = zone;
-				/*
-				 * We are still under min water mark.  This
-				 * means that we have a GFP_ATOMIC allocation
-				 * failure risk. Hurry up!
-				 */
-				if (!zone_watermark_ok_safe(zone, order,
-					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
-			} else {
+			if (zone_balanced(zone, testorder, 0, end_zone))
 				/*
 				 * If a zone reaches its high watermark,
 				 * consider it to be no longer congested. It's
@@ -2811,8 +2797,6 @@ loop_again:
 				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
-			}
-
 		}
 
 		/*
@@ -2830,17 +2814,6 @@ loop_again:
 		}
 
 		/*
-		 * OK, kswapd is getting into trouble.  Take a nap, then take
-		 * another pass across the zones.
-		 */
-		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
-			if (has_under_min_watermark_zone)
-				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
-			else if (unbalanced_zone)
-				wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
-		}
-
-		/*
 		 * We do this so kswapd doesn't build up large priorities for
 		 * example when it is freeing in parallel with allocators. It
 		 * matches the direct reclaim path behaviour in terms of impact
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 58e3da5..bb492b5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -769,7 +769,6 @@ const char * const vmstat_text[] = {
 	"kswapd_inodesteal",
 	"kswapd_low_wmark_hit_quickly",
 	"kswapd_high_wmark_hit_quickly",
-	"kswapd_skip_congestion_wait",
 	"pageoutrun",
 	"allocstall",
 
-- 
1.8.1

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
