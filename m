From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/2] introduce HIGH_ORDER delineating easily reclaimable orders cleanups
References: <exportbomb.1177520981@pinky>
Message-ID: <d8d5c9ade92fe4d96b08e9cd4554fa7b@pinky>
Date: Wed, 25 Apr 2007 18:10:13 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Switch from HIGH_ORDER to the more logical and descriptive
PAGE_ALLOC_COSTLY_ORDER indicating the boundary between orders
easily reclaimed and allocated and those which are not.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f9d2ced..444851c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -26,11 +26,12 @@
 #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
 
 /*
- * The boundary between small and large allocations.  That is between
- * allocation orders which should colesce naturally under reasonable
- * reclaim pressure and those which will not.
+ * PAGE_ALLOC_COSTLY_ORDER is the order at which allocations are deemed
+ * costly to service.  That is between allocation orders which should
+ * coelesce naturally under reasonable reclaim pressure and those which
+ * will not.
  */
-#define HIGH_ORDER 3
+#define PAGE_ALLOC_COSTLY_ORDER 3
 
 #ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 #define MIGRATE_UNMOVABLE     0
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 44786d9..b7134d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1768,7 +1768,8 @@ nofail_alloc:
 	 */
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
-		if ((order <= HIGH_ORDER) || (gfp_mask & __GFP_REPEAT))
+		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
+						(gfp_mask & __GFP_REPEAT))
 			do_retry = 1;
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79aedcb..ab7f4c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -472,7 +472,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= HIGH_ORDER &&
+		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
 					referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
@@ -506,7 +506,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= HIGH_ORDER && referenced)
+			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -777,7 +777,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 			     &zone->inactive_list,
 			     &page_list, &nr_scan, sc->order,
-			     (sc->order > HIGH_ORDER)? ISOLATE_BOTH : 0);
+			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
+							ISOLATE_BOTH : 0);
 		nr_active = deactivate_pages(&page_list);
 
 		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
