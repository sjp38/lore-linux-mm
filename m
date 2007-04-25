From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] lumpy: increase pressure at the end of the inactive list cleanups
References: <exportbomb.1177520981@pinky>
Message-ID: <eb5ad9a1235550e175be6963183dc8f9@pinky>
Date: Wed, 25 Apr 2007 18:10:44 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Cleanups following review feedback for the patch below:

	lumpy: increase pressure at the end of the inactive list

This patch:

1) introduces ISOLATE_[ACTIVE,INACTIVE],
2) changes the name of the deactivate_pages() helper to clear_active_flags(),
3) cleans up and simplifies the checks in __isolate_lru_pages(), and
4) changes the parameter active to mode throughout.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ab7f4c0..5f3c2bb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -590,38 +590,46 @@ keep:
 	return nr_reclaimed;
 }
 
+/* LRU Isolation modes. */
+#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
+#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
+#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
+
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
  * freed elsewhere are also ignored.
  *
  * page:	page to consider
- * active:	active/inactive flag only take pages of this type
+ * mode:	one of the LRU isolation modes defined above
  *
  * returns 0 on success, -ve errno on failure.
  */
-#define ISOLATE_BOTH -1		/* Isolate both active and inactive pages. */
-static int __isolate_lru_page(struct page *page, int active)
+static int __isolate_lru_page(struct page *page, int mode)
 {
 	int ret = -EINVAL;
 
+	/* Only take pages on the LRU. */
+	if (!PageLRU(page))
+		return ret;
+
 	/*
 	 * When checking the active state, we need to be sure we are
 	 * dealing with comparible boolean values.  Take the logical not
 	 * of each.
 	 */
-	if (PageLRU(page) && (active == ISOLATE_BOTH ||
-					(!PageActive(page) == !active))) {
-		ret = -EBUSY;
-		if (likely(get_page_unless_zero(page))) {
-			/*
-			 * Be careful not to clear PageLRU until after we're
-			 * sure the page is not being freed elsewhere -- the
-			 * page release code relies on it.
-			 */
-			ClearPageLRU(page);
-			ret = 0;
-		}
+	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+		return ret;
+
+	ret = -EBUSY;
+	if (likely(get_page_unless_zero(page))) {
+		/*
+		 * Be careful not to clear PageLRU until after we're
+		 * sure the page is not being freed elsewhere -- the
+		 * page release code relies on it.
+		 */
+		ClearPageLRU(page);
+		ret = 0;
 	}
 
 	return ret;
@@ -642,13 +650,13 @@ static int __isolate_lru_page(struct page *page, int active)
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
- * @active:	The caller's trying to obtain active or inactive pages
+ * @mode:	One of the LRU isolation modes
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int active)
+		unsigned long *scanned, int order, int mode)
 {
 	unsigned long nr_taken = 0;
 	unsigned long scan;
@@ -665,7 +673,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, active)) {
+		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			list_move(&page->lru, dst);
 			nr_taken++;
@@ -711,7 +719,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			switch (__isolate_lru_page(cursor_page, active)) {
+			switch (__isolate_lru_page(cursor_page, mode)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
@@ -732,21 +740,19 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 }
 
 /*
- * deactivate_pages() is a helper for shrink_active_list(), it deactivates
- * all active pages on the passed list.
+ * clear_active_flags() is a helper for shrink_active_list(), clearing
+ * any active bits from the pages in the list.
  */
-static unsigned long deactivate_pages(struct list_head *page_list)
+static unsigned long clear_active_flags(struct list_head *page_list)
 {
 	int nr_active = 0;
-	struct list_head *entry;
+	struct page *page;
 
-	list_for_each(entry, page_list) {
-		struct page *page = list_entry(entry, struct page, lru);
+	list_for_each_entry(page, page_list, lru)
 		if (PageActive(page)) {
 			ClearPageActive(page);
 			nr_active++;
 		}
-	}
 
 	return nr_active;
 }
@@ -778,8 +784,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			     &zone->inactive_list,
 			     &page_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
-							ISOLATE_BOTH : 0);
-		nr_active = deactivate_pages(&page_list);
+					     ISOLATE_BOTH : ISOLATE_INACTIVE);
+		nr_active = clear_active_flags(&page_list);
 
 		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
 		__mod_zone_page_state(zone, NR_INACTIVE,
@@ -929,7 +935,7 @@ force_reclaim_mapped:
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned, sc->order, 1);
+			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
