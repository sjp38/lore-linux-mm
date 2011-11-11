Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD806B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:40:04 -0500 (EST)
Received: by bke17 with SMTP id 17so2911873bke.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 04:40:00 -0800 (PST)
Subject: [PATCH v3 1/4] mm: add free_hot_cold_page_list helper
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 11 Nov 2011 16:39:57 +0300
Message-ID: <20111111123957.7371.72792.stgit@zurg>
In-Reply-To: <20110729075837.12274.58405.stgit@localhost6>
References: <20110729075837.12274.58405.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

This patch adds helper free_hot_cold_page_list() to free list of 0-order pages.
It frees pages directly from the list without temporary page-vector.
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

v2: Remove list reinititialization.
v3: Always free pages in reverse order.
    The most recently added struct page, the most likely to be hot.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/gfp.h |    1 +
 mm/page_alloc.c     |   13 +++++++++++++
 mm/swap.c           |   14 +++-----------
 mm/vmscan.c         |   20 +-------------------
 4 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..6562958 100644
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
index 9dd443d..5093114 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1211,6 +1211,19 @@ out:
 }
 
 /*
+ * Free a list of 0-order pages
+ */
+void free_hot_cold_page_list(struct list_head *list, int cold)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		trace_mm_pagevec_free(page, cold);
+		free_hot_cold_page(page, cold);
+	}
+}
+
+/*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
  * Each sub-page must be freed individually.
diff --git a/mm/swap.c b/mm/swap.c
index a91caf7..67a09a6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -585,11 +585,10 @@ int lru_add_drain_all(void)
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
 
@@ -620,19 +619,12 @@ void release_pages(struct page **pages, int nr, int cold)
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
+		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	pagevec_free(&pages_to_free);
+	free_hot_cold_page_list(&pages_to_free, cold);
 }
 EXPORT_SYMBOL(release_pages);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1893c0..f4be53d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -728,24 +728,6 @@ static enum page_references page_check_references(struct page *page,
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
@@ -1009,7 +991,7 @@ keep_lumpy:
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
