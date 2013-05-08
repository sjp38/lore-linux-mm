Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C7E2E6B0137
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/22] mm: page allocator: Convert hot/cold parameter and immediate callers to bool
Date: Wed,  8 May 2013 17:02:51 +0100
Message-Id: <1368028987-8369-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

cold is a bool, make it one for consistency later.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/sparc/mm/init_64.c  | 4 ++--
 arch/sparc/mm/tsb.c      | 2 +-
 arch/tile/mm/homecache.c | 2 +-
 fs/fuse/dev.c            | 2 +-
 include/linux/gfp.h      | 4 ++--
 include/linux/pagemap.h  | 2 +-
 include/linux/swap.h     | 2 +-
 mm/page_alloc.c          | 6 +++---
 mm/swap.c                | 4 ++--
 mm/swap_state.c          | 2 +-
 mm/vmscan.c              | 6 +++---
 11 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 1588d33..d2e50b9 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2562,7 +2562,7 @@ void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	struct page *page = virt_to_page(pte);
 	if (put_page_testzero(page))
-		free_hot_cold_page(page, 0);
+		free_hot_cold_page(page, false);
 }
 
 static void __pte_free(pgtable_t pte)
@@ -2570,7 +2570,7 @@ static void __pte_free(pgtable_t pte)
 	struct page *page = virt_to_page(pte);
 	if (put_page_testzero(page)) {
 		pgtable_page_dtor(page);
-		free_hot_cold_page(page, 0);
+		free_hot_cold_page(page, false);
 	}
 }
 
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index 2cc3bce..b16adcd 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -520,7 +520,7 @@ void destroy_context(struct mm_struct *mm)
 	page = mm->context.pgtable_page;
 	if (page && put_page_testzero(page)) {
 		pgtable_page_dtor(page);
-		free_hot_cold_page(page, 0);
+		free_hot_cold_page(page, false);
 	}
 
 	spin_lock_irqsave(&ctx_alloc_lock, flags);
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 1ae9119..eacb91b 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -438,7 +438,7 @@ void __homecache_free_pages(struct page *page, unsigned int order)
 	if (put_page_testzero(page)) {
 		homecache_change_page_home(page, order, initial_page_home());
 		if (order == 0) {
-			free_hot_cold_page(page, 0);
+			free_hot_cold_page(page, false);
 		} else {
 			init_page_count(page);
 			__free_pages(page, order);
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 11dfa0c..8532ea3 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1580,7 +1580,7 @@ out_finish:
 
 static void fuse_retrieve_end(struct fuse_conn *fc, struct fuse_req *req)
 {
-	release_pages(req->pages, req->num_pages, 0);
+	release_pages(req->pages, req->num_pages, false);
 }
 
 static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..66e45e7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -364,8 +364,8 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
-extern void free_hot_cold_page(struct page *page, int cold);
-extern void free_hot_cold_page_list(struct list_head *list, int cold);
+extern void free_hot_cold_page(struct page *page, bool cold);
+extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
 extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0e38e13..5d7fe39 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -99,7 +99,7 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
-void release_pages(struct page **pages, int nr, int cold);
+void release_pages(struct page **pages, int nr, bool cold);
 
 /*
  * speculatively take a reference to a page.
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2818a12..ef644ab 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -414,7 +414,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 #define free_page_and_swap_cache(page) \
 	page_cache_release(page)
 #define free_pages_and_swap_cache(pages, nr) \
-	release_pages((pages), (nr), 0);
+	release_pages((pages), (nr), false);
 
 static inline void show_swap_cache_info(void)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a66a6fa..f74e16f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1314,7 +1314,7 @@ void mark_free_pages(struct zone *zone)
  * Free a 0-order page
  * cold == 1 ? free a cold page : free a hot page
  */
-void free_hot_cold_page(struct page *page, int cold)
+void free_hot_cold_page(struct page *page, bool cold)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -1362,7 +1362,7 @@ void free_hot_cold_page(struct page *page, int cold)
 /*
  * Free a list of 0-order pages
  */
-void free_hot_cold_page_list(struct list_head *list, int cold)
+void free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
 
@@ -2680,7 +2680,7 @@ void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_cold_page(page, 0);
+			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 8a529a0..36c28e5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -63,7 +63,7 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
-	free_hot_cold_page(page, 0);
+	free_hot_cold_page(page, false);
 }
 
 static void __put_compound_page(struct page *page)
@@ -667,7 +667,7 @@ int lru_add_drain_all(void)
  * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
  * will free it.
  */
-void release_pages(struct page **pages, int nr, int cold)
+void release_pages(struct page **pages, int nr, bool cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7efcf15..bf0da4d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -268,7 +268,7 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 
 		for (i = 0; i < todo; i++)
 			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, 0);
+		release_pages(pagep, todo, false);
 		pagep += todo;
 		nr -= todo;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 669fba3..6a56766 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -954,7 +954,7 @@ keep:
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
 		zone_set_flag(zone, ZONE_CONGESTED);
 
-	free_hot_cold_page_list(&free_pages, 1);
+	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1343,7 +1343,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&page_list, 1);
+	free_hot_cold_page_list(&page_list, true);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies
@@ -1534,7 +1534,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&l_hold, 1);
+	free_hot_cold_page_list(&l_hold, true);
 }
 
 #ifdef CONFIG_SWAP
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
