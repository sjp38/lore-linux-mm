Date: Sat, 3 Nov 2007 19:03:54 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 8/10] make split VM and lumpy reclaim work together
Message-ID: <20071103190354.2ef7f5e8@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Make lumpy reclaim and the split VM code work together better, by
allowing both file and anonymous pages to be relaimed together.

Will be merged into patch 6/10 soon, split out for the benefit of
people who have looked at the older code in the past.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.23-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/vmscan.c
+++ linux-2.6.23-mm1/mm/vmscan.c
@@ -752,10 +752,6 @@ static unsigned long isolate_lru_pages(u
 
 			cursor_page = pfn_to_page(pfn);
 
-			/* Don't lump pages of different types:  file vs anon */
-			if (!PageLRU(page) || (file != !!page_file_cache(cursor_page)))
-				break;
-
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
@@ -799,16 +795,22 @@ static unsigned long isolate_pages_globa
  * clear_active_flags() is a helper for shrink_active_list(), clearing
  * any active bits from the pages in the list.
  */
-static unsigned long clear_active_flags(struct list_head *page_list)
+static unsigned long clear_active_flags(struct list_head *page_list,
+					unsigned int *count)
 {
 	int nr_active = 0;
+	int lru;
 	struct page *page;
 
-	list_for_each_entry(page, page_list, lru)
+	list_for_each_entry(page, page_list, lru) {
+		lru = page_file_cache(page);
 		if (PageActive(page)) {
+			lru += LRU_ACTIVE;
 			ClearPageActive(page);
 			nr_active++;
 		}
+		count[lru]++;
+	}
 
 	return nr_active;
 }
@@ -876,24 +878,25 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 		unsigned long nr_active;
+		unsigned int count[NR_LRU_LISTS] = { 0, };
+		int mode = (sc->order > PAGE_ALLOC_COSTLY_ORDER) ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
-			     &page_list, &nr_scan, sc->order,
-			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
-					     ISOLATE_BOTH : ISOLATE_INACTIVE,
+			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
-		nr_active = clear_active_flags(&page_list);
+		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 
-		if (file) {
-			__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_active);
-			__mod_zone_page_state(zone, NR_INACTIVE_FILE,
-						-(nr_taken - nr_active));
-		} else {
-			__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_active);
-			__mod_zone_page_state(zone, NR_INACTIVE_ANON,
-						-(nr_taken - nr_active));
-		}
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+						-count[LRU_ACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+						-count[LRU_INACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+						-count[LRU_ACTIVE_ANON]);
+		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+						-count[LRU_INACTIVE_ANON]);
+
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -914,7 +917,7 @@ static unsigned long shrink_inactive_lis
 			 * The attempt at page out may have made some
 			 * of the pages active, mark them inactive again.
 			 */
-			nr_active = clear_active_flags(&page_list);
+			nr_active = clear_active_flags(&page_list, count);
 			count_vm_events(PGDEACTIVATE, nr_active);
 
 			nr_freed += shrink_page_list(&page_list, sc,
@@ -943,11 +946,11 @@ static unsigned long shrink_inactive_lis
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			if (file) {
+			if (page_file_cache(page)) {
 				l += LRU_FILE;
-				zone->recent_rotated_file += sc->activated;
+				zone->recent_rotated_file++;
 			} else {
-				zone->recent_rotated_anon += sc->activated;
+				zone->recent_rotated_anon++;
 			}
 			if (PageActive(page))
 				l += LRU_ACTIVE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
