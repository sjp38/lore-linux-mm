From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/3] lumpy: increase pressure at the end of the inactive list
References: <exportbomb.1177081388@pinky>
Message-ID: <6476c564e476b1038584ea2ed39f2b7e@pinky>
Date: Fri, 20 Apr 2007 16:04:04 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Having selected an area at the end of the inactive list, reclaim is
attempted for all LRU pages within that contiguous area.  Currently,
any pages in this area found to still be active or referenced are
rotated back to the active list as normal and the rest reclaimed.
At low orders there is a reasonable likelyhood of finding contigious
inactive areas for reclaim.  However when reclaiming at higher order
there is a very low chance all pages in the area being inactive,
unreferenced and therefore reclaimable.

This patch modifies behaviour when reclaiming at higher order
(order >= 4).  All LRU pages within the target area are reclaimed,
including both active and recently referenced pages.

[mel@csn.ul.ie: additionally apply pressure to referenced paged]
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 466435f..e5e77fb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -472,7 +472,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+		if (sc->order <= 3 && referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -505,7 +505,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (referenced)
+			if (sc->order <= 3 && referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -599,6 +599,7 @@ keep:
  *
  * returns 0 on success, -ve errno on failure.
  */
+#define ISOLATE_BOTH -1		/* Isolate both active and inactive pages. */
 static int __isolate_lru_page(struct page *page, int active)
 {
 	int ret = -EINVAL;
@@ -608,7 +609,8 @@ static int __isolate_lru_page(struct page *page, int active)
 	 * dealing with comparible boolean values.  Take the logical not
 	 * of each.
 	 */
-	if (PageLRU(page) && (!PageActive(page) == !active)) {
+	if (PageLRU(page) && (active == ISOLATE_BOTH ||
+					(!PageActive(page) == !active))) {
 		ret = -EBUSY;
 		if (likely(get_page_unless_zero(page))) {
 			/*
@@ -729,6 +731,26 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 }
 
 /*
+ * deactivate_pages() is a helper for shrink_active_list(), it deactivates
+ * all active pages on the passed list.
+ */
+static unsigned long deactivate_pages(struct list_head *page_list)
+{
+	int nr_active = 0;
+	struct list_head *entry;
+
+	list_for_each(entry, page_list) {
+		struct page *page = list_entry(entry, struct page, lru);
+		if (PageActive(page)) {
+			ClearPageActive(page);
+			nr_active++;
+		}
+	}
+
+	return nr_active;
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -749,11 +771,17 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_taken;
 		unsigned long nr_scan;
 		unsigned long nr_freed;
+		unsigned long nr_active;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 				     &zone->inactive_list,
-				     &page_list, &nr_scan, sc->order, 0);
-		__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
+				     &page_list, &nr_scan, sc->order,
+				     (sc->order > 3)? ISOLATE_BOTH : 0);
+		nr_active = deactivate_pages(&page_list);
+
+		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
+		__mod_zone_page_state(zone, NR_INACTIVE,
+						-(nr_taken - nr_active));
 		zone->pages_scanned += nr_scan;
 		zone->total_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
