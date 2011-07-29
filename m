Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 048486B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 03:58:43 -0400 (EDT)
Subject: [PATCH] mm: add free_hot_cold_page_list helper
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 29 Jul 2011 11:58:37 +0400
Message-ID: <20110729075837.12274.58405.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch adds helper free_hot_cold_page_list() to free list of 0-order pages.
It frees pages directly from list without temporary page-vector.
It also calls trace_mm_pagevec_free() to simulate pagevec_free() behaviour.

bloat-o-meter:

add/remove: 1/1 grow/shrink: 1/3 up/down: 267/-295 (-28)
function                                     old     new   delta
free_hot_cold_page_list                        -     264    +264
get_page_from_freelist                      2129    2132      +3
__pagevec_free                               243     239      -4
split_free_page                              380     373      -7
release_pages                                606     510     -96
free_page_list                               188       -    -188

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/gfp.h |    1 +
 mm/page_alloc.c     |   12 ++++++++++++
 mm/swap.c           |   14 +++-----------
 mm/vmscan.c         |   20 +-------------------
 4 files changed, 17 insertions(+), 30 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index cb40892..dd7b9cc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -358,6 +358,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, int cold);
+extern void free_hot_cold_page_list(struct list_head *list, int cold);
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1dbcf88..af486e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1209,6 +1209,18 @@ out:
 	local_irq_restore(flags);
 }
 
+void free_hot_cold_page_list(struct list_head *list, int cold)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		trace_mm_pagevec_free(page, cold);
+		free_hot_cold_page(page, cold);
+	}
+
+	INIT_LIST_HEAD(list);
+}
+
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..b9138c7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -562,11 +562,10 @@ int lru_add_drain_all(void)
 void release_pages(struct page **pages, int nr, int cold)
 {
 	int i;
-	struct pagevec pages_to_free;
+	LIST_HEAD(pages_to_free);
 	struct zone *zone = NULL;
 	unsigned long uninitialized_var(flags);
 
-	pagevec_init(&pages_to_free, cold);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
@@ -597,19 +596,12 @@ void release_pages(struct page **pages, int nr, int cold)
 			del_page_from_lru(zone, page);
 		}
 
-		if (!pagevec_add(&pages_to_free, page)) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
-			}
-			__pagevec_free(&pages_to_free);
-			pagevec_reinit(&pages_to_free);
-  		}
+		list_add_tail(&page->lru, &pages_to_free);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	pagevec_free(&pages_to_free);
+	free_hot_cold_page_list(&pages_to_free, cold);
 }
 EXPORT_SYMBOL(release_pages);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..47403c9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -737,24 +737,6 @@ static enum page_references page_check_references(struct page *page,
 	return PAGEREF_RECLAIM;
 }
 
-static noinline_for_stack void free_page_list(struct list_head *free_pages)
-{
-	struct pagevec freed_pvec;
-	struct page *page, *tmp;
-
-	pagevec_init(&freed_pvec, 1);
-
-	list_for_each_entry_safe(page, tmp, free_pages, lru) {
-		list_del(&page->lru);
-		if (!pagevec_add(&freed_pvec, page)) {
-			__pagevec_free(&freed_pvec);
-			pagevec_reinit(&freed_pvec);
-		}
-	}
-
-	pagevec_free(&freed_pvec);
-}
-
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -996,7 +978,7 @@ keep_lumpy:
 	if (nr_dirty && nr_dirty == nr_congested && scanning_global_lru(sc))
 		zone_set_flag(zone, ZONE_CONGESTED);
 
-	free_page_list(&free_pages);
+	free_hot_cold_page_list(&free_pages, 1);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
