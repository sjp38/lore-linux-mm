From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch v2] vmscan: protect zone rotation stats by lru lock
Message-Id: <E1L6y5T-0003q3-M3@cmpxchg.org>
Date: Mon, 01 Dec 2008 03:00:35 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The zone's rotation statistics must not be accessed without the
corresponding LRU lock held.  Fix an unprotected write in
shrink_active_list().

Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Applies to your tree, Linus, and should probably go into .28.

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1243,32 +1243,32 @@ static void shrink_active_list(unsigned 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
 		    page_referenced(page, 0, sc->mem_cgroup))
 			pgmoved++;
 
 		list_add(&page->lru, &l_inactive);
 	}
 
+	spin_lock_irq(&zone->lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as
 	 * rotated, even though they are moved to the inactive list.
 	 * This helps balance scan pressure between file and anonymous
 	 * pages in get_scan_ratio.
 	 */
 	zone->recent_rotated[!!file] += pgmoved;
 
 	/*
 	 * Move the pages to the [file or anon] inactive list.
 	 */
 	pagevec_init(&pvec, 1);
 
 	pgmoved = 0;
 	lru = LRU_BASE + file * LRU_FILE;
-	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
