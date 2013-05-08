Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3043B6B0140
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/22] mm: page allocator: Remove knowledge of hot/cold from page allocator
Date: Wed,  8 May 2013 17:02:57 +0100
Message-Id: <1368028987-8369-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The intention of hot/cold in the page allocator was that known cache
hot pages would be placed at the head of the list and allocations
for data to be immediately used would use cache hot plages. Conversely,
pages that were reclaimed from the LRU would be treated as cold and
allocations for data that was not going to be immediately used such
as ring buffers or readahead pages would use cold pages.

With the introduction of magazines, the benefit is questionable.
Regardless of the cache hotness of the physical page, the struct
page is modified whether hot or cold is requested. "Cold" pages
that are freed will still have hot struct page cache lines as
a result of the free and placing them at the tail of the magazine
list is counter-productive.

As it's of dubious merit, this patch removes the free_hot_cold_page
and free_hot_cold_page_list interface. The __GFP_COLD annotations
are left in place for now in case a magazine design can be devised
that can take advantage of the hot/cold information sensibly.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/sparc/mm/init_64.c     |  4 ++--
 arch/sparc/mm/tsb.c         |  2 +-
 arch/tile/mm/homecache.c    |  2 +-
 include/linux/gfp.h         |  6 +++---
 include/trace/events/kmem.h | 11 ++++-------
 mm/page_alloc.c             | 24 ++++++++----------------
 mm/rmap.c                   |  2 +-
 mm/swap.c                   |  4 ++--
 mm/vmscan.c                 |  6 +++---
 9 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index d2e50b9..1fdeecc 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2562,7 +2562,7 @@ void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	struct page *page = virt_to_page(pte);
 	if (put_page_testzero(page))
-		free_hot_cold_page(page, false);
+		free_base_page(page);
 }
 
 static void __pte_free(pgtable_t pte)
@@ -2570,7 +2570,7 @@ static void __pte_free(pgtable_t pte)
 	struct page *page = virt_to_page(pte);
 	if (put_page_testzero(page)) {
 		pgtable_page_dtor(page);
-		free_hot_cold_page(page, false);
+		free_base_page(page);
 	}
 }
 
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index b16adcd..2fcd9b8 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -520,7 +520,7 @@ void destroy_context(struct mm_struct *mm)
 	page = mm->context.pgtable_page;
 	if (page && put_page_testzero(page)) {
 		pgtable_page_dtor(page);
-		free_hot_cold_page(page, false);
+		free_base_page(page);
 	}
 
 	spin_lock_irqsave(&ctx_alloc_lock, flags);
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index eacb91b..4c748fd 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -438,7 +438,7 @@ void __homecache_free_pages(struct page *page, unsigned int order)
 	if (put_page_testzero(page)) {
 		homecache_change_page_home(page, order, initial_page_home());
 		if (order == 0) {
-			free_hot_cold_page(page, false);
+			free_base_page(page);
 		} else {
 			init_page_count(page);
 			__free_pages(page, order);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index edf3184..45cbc43 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -70,7 +70,7 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)___GFP_FS)	/* Can call down to low-level FS? */
-#define __GFP_COLD	((__force gfp_t)___GFP_COLD)	/* Cache-cold page required */
+#define __GFP_COLD	((__force gfp_t)___GFP_COLD)	/* Cache-cold page requested, currently ignored */
 #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
@@ -364,8 +364,8 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
-extern void free_hot_cold_page(struct page *page, bool cold);
-extern void free_hot_cold_page_list(struct list_head *list, bool cold);
+extern void free_base_page(struct page *page);
+extern void free_base_page_list(struct list_head *list);
 
 extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
 extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 0a5501a..f2069e8d 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -171,24 +171,21 @@ TRACE_EVENT(mm_page_free,
 
 TRACE_EVENT(mm_page_free_batched,
 
-	TP_PROTO(struct page *page, int cold),
+	TP_PROTO(struct page *page),
 
-	TP_ARGS(page, cold),
+	TP_ARGS(page),
 
 	TP_STRUCT__entry(
 		__field(	struct page *,	page		)
-		__field(	int,		cold		)
 	),
 
 	TP_fast_assign(
 		__entry->page		= page;
-		__entry->cold		= cold;
 	),
 
-	TP_printk("page=%p pfn=%lu order=0 cold=%d",
+	TP_printk("page=%p pfn=%lu order=0",
 			__entry->page,
-			page_to_pfn(__entry->page),
-			__entry->cold)
+			page_to_pfn(__entry->page))
 );
 
 TRACE_EVENT(mm_page_alloc,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 79dfda7..bb2f116 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1175,11 +1175,8 @@ static void magazine_drain(struct zone *zone, int migratetype)
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
-/*
- * Free a 0-order page
- * cold == 1 ? free a cold page : free a hot page
- */
-void free_hot_cold_page(struct page *page, bool cold)
+/* Free a 0-order page */
+void free_base_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	int migratetype;
@@ -1215,26 +1212,21 @@ void free_hot_cold_page(struct page *page, bool cold)
 	/* Put the free page on the magazine list */
 	spin_lock(&zone->magazine_lock);
 	area = &(zone->noirq_magazine);
-	if (!cold)
-		list_add(&page->lru, &area->free_list[migratetype]);
-	else
-		list_add_tail(&page->lru, &area->free_list[migratetype]);
+	list_add(&page->lru, &area->free_list[migratetype]);
 	area->nr_free++;
 
 	/* Drain the magazine if necessary, releases the magazine lock */
 	magazine_drain(zone, migratetype);
 }
 
-/*
- * Free a list of 0-order pages
- */
-void free_hot_cold_page_list(struct list_head *list, bool cold)
+/* Free a list of 0-order pages */
+void free_base_page_list(struct list_head *list)
 {
 	struct page *page, *next;
 
 	list_for_each_entry_safe(page, next, list, lru) {
-		trace_mm_page_free_batched(page, cold);
-		free_hot_cold_page(page, cold);
+		trace_mm_page_free_batched(page);
+		free_base_page(page);
 	}
 }
 
@@ -2564,7 +2556,7 @@ void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_cold_page(page, false);
+			free_base_page(page);
 		else
 			__free_pages_ok(page, order);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 807c96b..f60152b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1166,7 +1166,7 @@ void page_remove_rmap(struct page *page)
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
 	 * which increments mapcount after us but sets mapping
-	 * before us: so leave the reset to free_hot_cold_page,
+	 * before us: so leave the reset to free_base_page,
 	 * and remember that it's only reliable while mapped.
 	 * Leaving it set also helps swapoff to reinstate ptes
 	 * faster for those pages still in swapcache.
diff --git a/mm/swap.c b/mm/swap.c
index 36c28e5..382ca11 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -63,7 +63,7 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
-	free_hot_cold_page(page, false);
+	free_base_page(page);
 }
 
 static void __put_compound_page(struct page *page)
@@ -712,7 +712,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	free_hot_cold_page_list(&pages_to_free, cold);
+	free_base_page_list(&pages_to_free);
 }
 EXPORT_SYMBOL(release_pages);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6a56766..3ca921a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -954,7 +954,7 @@ keep:
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
 		zone_set_flag(zone, ZONE_CONGESTED);
 
-	free_hot_cold_page_list(&free_pages, true);
+	free_base_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1343,7 +1343,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&page_list, true);
+	free_base_page_list(&page_list);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies
@@ -1534,7 +1534,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&l_hold, true);
+	free_base_page_list(&l_hold);
 }
 
 #ifdef CONFIG_SWAP
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
