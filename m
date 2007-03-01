From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100410.29753.33692.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 5/12] Choose pages from the per-cpu list based on migration type
Date: Thu,  1 Mar 2007 10:04:10 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The freelists for each migrate type can slowly become polluted due to the
per-cpu list. Consider what happens when the following happens

1. A 2^(MAX_ORDER-1) list is reserved for __GFP_MOVABLE pages
2. An order-0 page is allocated from the newly reserved block
3. The page is freed and placed on the per-cpu list
4. alloc_page() is called with GFP_KERNEL as the gfp_mask
5. The per-cpu list is used to satisfy the allocation

This results in a kernel page is in the middle of a migratable region. This
patch prevents this leak occuring by storing the MIGRATE_ type of the page in
page->private. On allocate, a page will only be returned of the desired type,
else more pages will be allocated. This may temporarily allow a per-cpu list
to go over the pcp->high limit but it'll be corrected on the next free. Care
is taken to preserve the hotness of pages recently freed.

The additional code is not measurably slower for the workloads we've tested.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 page_alloc.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-004_clustering_core/mm/page_alloc.c linux-2.6.20-mm2-005_percpu/mm/page_alloc.c
--- linux-2.6.20-mm2-004_clustering_core/mm/page_alloc.c	2007-02-20 18:29:42.000000000 +0000
+++ linux-2.6.20-mm2-005_percpu/mm/page_alloc.c	2007-02-20 18:31:48.000000000 +0000
@@ -762,7 +762,8 @@ static int rmqueue_bulk(struct zone *zon
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
-		list_add_tail(&page->lru, list);
+		list_add(&page->lru, list);
+		set_page_private(page, migratetype);
 	}
 	spin_unlock(&zone->lock);
 	return i;
@@ -927,6 +928,7 @@ static void fastcall free_hot_cold_page(
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 	list_add(&page->lru, &pcp->list);
+	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
@@ -991,9 +993,27 @@ again:
 			if (unlikely(!pcp->count))
 				goto failed;
 		}
-		page = list_entry(pcp->list.next, struct page, lru);
-		list_del(&page->lru);
-		pcp->count--;
+		/* Find a page of the appropriate migrate type */
+		list_for_each_entry(page, &pcp->list, lru) {
+			if (page_private(page) == migratetype) {
+				list_del(&page->lru);
+				pcp->count--;
+				break;
+			}
+		}
+
+		/*
+		 * Check if a page of the appropriate migrate type
+		 * was found. If not, allocate more to the pcp list
+		 */
+		if (&page->lru == &pcp->list) {
+			pcp->count += rmqueue_bulk(zone, 0,
+					pcp->batch, &pcp->list, migratetype);
+			page = list_entry(pcp->list.next, struct page, lru);
+			VM_BUG_ON(page_private(page) != migratetype);
+			list_del(&page->lru);
+			pcp->count--;
+		}
 	} else {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
