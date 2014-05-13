Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2BECC6B0055
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:46:11 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so212964eek.9
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:46:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si12681284eef.82.2014.05.13.02.46.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:46:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/19] mm: page_alloc: Convert hot/cold parameter and immediate callers to bool
Date: Tue, 13 May 2014 10:45:44 +0100
Message-Id: <1399974350-11089-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

cold is a bool, make it one. Make the likely case the "if" part of the
block instead of the else as according to the optimisation manual this
is preferred.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/tile/mm/homecache.c |  2 +-
 fs/fuse/dev.c            |  2 +-
 include/linux/gfp.h      |  4 ++--
 include/linux/pagemap.h  |  2 +-
 include/linux/swap.h     |  2 +-
 mm/page_alloc.c          | 20 ++++++++++----------
 mm/swap.c                |  4 ++--
 mm/swap_state.c          |  2 +-
 mm/vmscan.c              |  6 +++---
 9 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 004ba56..33294fd 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -417,7 +417,7 @@ void __homecache_free_pages(struct page *page, unsigned int order)
 	if (put_page_testzero(page)) {
 		homecache_change_page_home(page, order, PAGE_HOME_HASH);
 		if (order == 0) {
-			free_hot_cold_page(page, 0);
+			free_hot_cold_page(page, false);
 		} else {
 			init_page_count(page);
 			__free_pages(page, order);
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index aac71ce..098f97b 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1614,7 +1614,7 @@ out_finish:
 
 static void fuse_retrieve_end(struct fuse_conn *fc, struct fuse_req *req)
 {
-	release_pages(req->pages, req->num_pages, 0);
+	release_pages(req->pages, req->num_pages, false);
 }
 
 static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 39b81dc..3824ac6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -369,8 +369,8 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
-extern void free_hot_cold_page(struct page *page, int cold);
-extern void free_hot_cold_page_list(struct list_head *list, int cold);
+extern void free_hot_cold_page(struct page *page, bool cold);
+extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
 extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 45598f1..9175f52 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -110,7 +110,7 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
-void release_pages(struct page **pages, int nr, int cold);
+void release_pages(struct page **pages, int nr, bool cold);
 
 /*
  * speculatively take a reference to a page.
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..da8a250 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -496,7 +496,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 #define free_page_and_swap_cache(page) \
 	page_cache_release(page)
 #define free_pages_and_swap_cache(pages, nr) \
-	release_pages((pages), (nr), 0);
+	release_pages((pages), (nr), false);
 
 static inline void show_swap_cache_info(void)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a47f1c5..02f3ffc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1189,7 +1189,7 @@ retry_reserve:
  */
 static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
-			int migratetype, int cold)
+			int migratetype, bool cold)
 {
 	int mt = migratetype, i;
 
@@ -1208,7 +1208,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		 * merge IO requests if the physical pages are ordered
 		 * properly.
 		 */
-		if (likely(cold == 0))
+		if (likely(!cold))
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
@@ -1375,9 +1375,9 @@ void mark_free_pages(struct zone *zone)
 
 /*
  * Free a 0-order page
- * cold == 1 ? free a cold page : free a hot page
+ * cold == true ? free a cold page : free a hot page
  */
-void free_hot_cold_page(struct page *page, int cold)
+void free_hot_cold_page(struct page *page, bool cold)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -1409,10 +1409,10 @@ void free_hot_cold_page(struct page *page, int cold)
 	}
 
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
-	if (cold)
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
-	else
+	if (!cold)
 		list_add(&page->lru, &pcp->lists[migratetype]);
+	else
+		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		unsigned long batch = ACCESS_ONCE(pcp->batch);
@@ -1427,7 +1427,7 @@ out:
 /*
  * Free a list of 0-order pages
  */
-void free_hot_cold_page_list(struct list_head *list, int cold)
+void free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
 
@@ -1544,7 +1544,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
+	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
 again:
 	if (likely(order == 0)) {
@@ -2849,7 +2849,7 @@ void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_cold_page(page, 0);
+			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 9ce43ba..f2228b7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -67,7 +67,7 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
-	free_hot_cold_page(page, 0);
+	free_hot_cold_page(page, false);
 }
 
 static void __put_compound_page(struct page *page)
@@ -813,7 +813,7 @@ void lru_add_drain_all(void)
  * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
  * will free it.
  */
-void release_pages(struct page **pages, int nr, int cold)
+void release_pages(struct page **pages, int nr, bool cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e76ace3..2972eee 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -270,7 +270,7 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 
 		for (i = 0; i < todo; i++)
 			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, 0);
+		release_pages(pagep, todo, false);
 		pagep += todo;
 		nr -= todo;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f56c8d..8db1318 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1121,7 +1121,7 @@ keep:
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
-	free_hot_cold_page_list(&free_pages, 1);
+	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1519,7 +1519,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&page_list, 1);
+	free_hot_cold_page_list(&page_list, true);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies
@@ -1740,7 +1740,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
-	free_hot_cold_page_list(&l_hold, 1);
+	free_hot_cold_page_list(&l_hold, true);
 }
 
 #ifdef CONFIG_SWAP
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
