From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070410160344.10742.67971.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
References: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Reduce the amount of time spent in the per-cpu allocator
Date: Tue, 10 Apr 2007 17:03:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The per-cpu allocator is the most frequently entered path in the page
allocator as the majority of allocations are order-0 allocations that use it.
This patch is mainly a re-ordering to give the patch a cleaner flow and
make it more human-readable.

Performance wise, an unlikely() is added for a branch that is rarely executed
which improves performance very slightly. A VM_BUG_ON() is removed because
when the situation does occur, it means we are just really low on memory
not that the VM is buggy.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-002_disable_on_smallmem/mm/page_alloc.c linux-2.6.21-rc6-mm1-003_streamline_percpu/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-002_disable_on_smallmem/mm/page_alloc.c	2007-04-10 11:28:01.000000000 +0100
+++ linux-2.6.21-rc6-mm1-003_streamline_percpu/mm/page_alloc.c	2007-04-10 11:35:34.000000000 +0100
@@ -1204,33 +1204,25 @@ again:
 			if (unlikely(!pcp->count))
 				goto failed;
 		}
+
 #ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
 		/* Find a page of the appropriate migrate type */
-		list_for_each_entry(page, &pcp->list, lru) {
-			if (page_private(page) == migratetype) {
-				list_del(&page->lru);
-				pcp->count--;
+		list_for_each_entry(page, &pcp->list, lru)
+			if (page_private(page) == migratetype)
 				break;
-			}
-		}
 
-		/*
-		 * Check if a page of the appropriate migrate type
-		 * was found. If not, allocate more to the pcp list
-		 */
-		if (&page->lru == &pcp->list) {
+		/* Allocate more to the pcp list if necessary */
+		if (unlikely(&page->lru == &pcp->list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, &pcp->list, migratetype);
 			page = list_entry(pcp->list.next, struct page, lru);
-			VM_BUG_ON(page_private(page) != migratetype);
-			list_del(&page->lru);
-			pcp->count--;
 		}
 #else
 		page = list_entry(pcp->list.next, struct page, lru);
+#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
+
 		list_del(&page->lru);
 		pcp->count--;
-#endif /* CONFIG_PAGE_GROUP_BY_MOBILITY */
 	} else {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
