From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/3] introduce HIGH_ORDER delineating easily reclaimable orders
References: <exportbomb.1177081388@pinky>
Message-ID: <cc3c22ba296c3d75cd7bd66747fb08c0@pinky>
Date: Fri, 20 Apr 2007 16:04:36 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The memory allocator treats lower order (order <= 3) and higher order
(order >= 4) allocations in slightly different ways.  As lower orders
are much more likely to be available and also more likely to be
simply reclaimed it is deemed reasonable to wait longer for those.
Lumpy reclaim also changes behaviour at this same boundary, more
agressivly targetting pages in reclaim at higher order.

This patch removes all these magical numbers and replaces with
with a constant HIGH_ORDER.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8c87d79..f9d2ced 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -25,6 +25,13 @@
 #endif
 #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
 
+/*
+ * The boundary between small and large allocations.  That is between
+ * allocation orders which should colesce naturally under reasonable
+ * reclaim pressure and those which will not.
+ */
+#define HIGH_ORDER 3
+
 #ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7e33cb..44786d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1768,7 +1768,7 @@ nofail_alloc:
 	 */
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
-		if ((order <= 3) || (gfp_mask & __GFP_REPEAT))
+		if ((order <= HIGH_ORDER) || (gfp_mask & __GFP_REPEAT))
 			do_retry = 1;
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5e77fb..79aedcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -472,7 +472,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= 3 && referenced && page_mapping_inuse(page))
+		if (sc->order <= HIGH_ORDER &&
+					referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -505,7 +506,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= 3 && referenced)
+			if (sc->order <= HIGH_ORDER && referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -774,9 +775,9 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_active;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-				     &zone->inactive_list,
-				     &page_list, &nr_scan, sc->order,
-				     (sc->order > 3)? ISOLATE_BOTH : 0);
+			     &zone->inactive_list,
+			     &page_list, &nr_scan, sc->order,
+			     (sc->order > HIGH_ORDER)? ISOLATE_BOTH : 0);
 		nr_active = deactivate_pages(&page_list);
 
 		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
