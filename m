Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6263B6B0083
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:19 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:18 -0800 (PST)
Subject: [PATCH RFC 03/15] mm: add book->pages_count
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:15 +0400
Message-ID: <20120215225715.22050.70811.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Move lru pages counter from mem_cgroup_per_zone->count[] to book->pages_count[]

Account pages in all books, incuding root,
this isn't a huge overhead, but it greatly simplifies all code.

redundant page -> book translations will be optimized in further patches.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   29 -------------
 include/linux/mm_inline.h  |   14 ++++--
 include/linux/mmzone.h     |    2 +
 mm/memcontrol.c            |   98 ++------------------------------------------
 mm/page_alloc.c            |    4 +-
 mm/swap.c                  |    7 +--
 mm/vmscan.c                |   21 +++++++--
 7 files changed, 36 insertions(+), 139 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c97fff9..4183753 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -63,12 +63,6 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 
 struct book *mem_cgroup_zone_book(struct zone *, struct mem_cgroup *);
-struct book *mem_cgroup_lru_add_list(struct zone *, struct page *,
-				       enum lru_list);
-void mem_cgroup_lru_del_list(struct page *, enum lru_list);
-void mem_cgroup_lru_del(struct page *);
-struct book *mem_cgroup_lru_move_lists(struct zone *, struct page *,
-					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -220,29 +214,6 @@ static inline struct book *mem_cgroup_zone_book(struct zone *zone,
 	return &zone->book;
 }
 
-static inline struct book *mem_cgroup_lru_add_list(struct zone *zone,
-						     struct page *page,
-						     enum lru_list lru)
-{
-	return &zone->book;
-}
-
-static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
-{
-}
-
-static inline void mem_cgroup_lru_del(struct page *page)
-{
-}
-
-static inline struct book *mem_cgroup_lru_move_lists(struct zone *zone,
-						       struct page *page,
-						       enum lru_list from,
-						       enum lru_list to)
-{
-	return &zone->book;
-}
-
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 6f42819..9c484c0 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -60,19 +60,23 @@ static inline int page_is_file_cache(struct page *page)
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	struct book *book;
+	struct book *book = page_book(page);
+	int numpages = hpage_nr_pages(page);
 
-	book = mem_cgroup_lru_add_list(zone, page, lru);
 	list_add(&page->lru, &book->pages_lru[lru]);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
+	book->pages_count[lru] += numpages;
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, numpages);
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	mem_cgroup_lru_del_list(page, lru);
+	struct book *book = page_book(page);
+	int numpages = hpage_nr_pages(page);
+
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
+	book->pages_count[lru] -= numpages;
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -numpages);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e05b003..ef4b984 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -302,6 +302,8 @@ struct book {
 	struct zone		*zone;
 #endif
 	struct list_head	pages_lru[NR_LRU_LISTS];
+	unsigned long		pages_count[NR_LRU_LISTS];
+
 	struct list_head	list;	/* for zone->book_list */
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 06d946f..8e1765a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -135,7 +135,6 @@ struct mem_cgroup_reclaim_iter {
  */
 struct mem_cgroup_per_zone {
 	struct book		book;
-	unsigned long		count[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
@@ -147,8 +146,6 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
-/* Macro for accessing counter */
-#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
@@ -715,7 +712,7 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 
 	for_each_lru(l) {
 		if (BIT(l) & lru_mask)
-			ret += MEM_CGROUP_ZSTAT(mz, l);
+			ret += mz->book.pages_count[l];
 	}
 	return ret;
 }
@@ -1051,93 +1048,6 @@ struct book *mem_cgroup_zone_book(struct zone *zone,
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-/**
- * mem_cgroup_lru_add_list - account for adding an lru page and return book
- * @zone: zone of the page
- * @page: the page
- * @lru: current lru
- *
- * This function accounts for @page being added to @lru, and returns
- * the book for the given @zone and the memcg @page is charged to.
- *
- * The callsite is then responsible for physically linking the page to
- * the returned book->pages_lru[@lru].
- */
-struct book *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
-				       enum lru_list lru)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return &zone->book;
-
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* compound_order() is stabilized through lru_lock */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
-	return &mz->book;
-}
-
-/**
- * mem_cgroup_lru_del_list - account for removing an lru page
- * @page: the page
- * @lru: target lru
- *
- * This function accounts for @page being removed from @lru.
- *
- * The callsite is then responsible for physically unlinking
- * @page->lru.
- */
-void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	VM_BUG_ON(!memcg);
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	VM_BUG_ON(MEM_CGROUP_ZSTAT(mz, lru) < (1 << compound_order(page)));
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-}
-
-void mem_cgroup_lru_del(struct page *page)
-{
-	mem_cgroup_lru_del_list(page, page_lru(page));
-}
-
-/**
- * mem_cgroup_lru_move_lists - account for moving a page between lrus
- * @zone: zone of the page
- * @page: the page
- * @from: current lru
- * @to: target lru
- *
- * This function accounts for @page being moved between the lrus @from
- * and @to, and returns the book for the given @zone and the memcg
- * @page is charged to.
- *
- * The callsite is then responsible for physically relinking
- * @page->lru to the returned book->lists[@to].
- */
-struct book *mem_cgroup_lru_move_lists(struct zone *zone,
-					 struct page *page,
-					 enum lru_list from,
-					 enum lru_list to)
-{
-	/* XXX: Optimize this, especially for @from == @to */
-	mem_cgroup_lru_del_list(page, from);
-	return mem_cgroup_lru_add_list(zone, page, to);
-}
-
 /*
  * Checks whether given mem is same or in the root_mem_cgroup's
  * hierarchy subtree
@@ -3639,7 +3549,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->book.pages_lru[lru];
 
-	loop = MEM_CGROUP_ZSTAT(mz, lru);
+	loop = mz->book.pages_count[lru];
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
@@ -4765,8 +4675,10 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(l)
+		for_each_lru(l) {
 			INIT_LIST_HEAD(&mz->book.pages_lru[l]);
+			mz->book.pages_count[l] = 0;
+		}
 		mz->book.node = NODE_DATA(node);
 		mz->book.zone = &NODE_DATA(node)->node_zones[zone];
 		spin_lock(&mz->book.zone->lock);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ead327b..c62a1d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4310,8 +4310,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		for_each_lru(lru)
+		for_each_lru(lru) {
 			INIT_LIST_HEAD(&zone->book.pages_lru[lru]);
+			zone->book.pages_count[lru] = 0;
+		}
 #ifdef CONFIG_MEMORY_BOOKKEEPING
 		zone->book.node = pgdat;
 		zone->book.zone = zone;
diff --git a/mm/swap.c b/mm/swap.c
index d7c4c8f..ba29c3c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -234,10 +234,8 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct book *book;
+		struct book *book = page_book(page);
 
-		book = mem_cgroup_lru_move_lists(page_zone(page),
-						   page, lru, lru);
 		list_move_tail(&page->lru, &book->pages_lru[lru]);
 		(*pgmoved)++;
 	}
@@ -476,12 +474,11 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct book *book;
+		struct book *book = page_book(page);
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		book = mem_cgroup_lru_move_lists(zone, page, lru, lru);
 		list_move_tail(&page->lru, &book->pages_lru[lru]);
 		__count_vm_event(PGROTATED);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fba9dfd..eddf617 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1188,7 +1188,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
 			nr_taken += hpage_nr_pages(page);
 			break;
@@ -1246,10 +1245,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				unsigned int isolated_pages;
+				struct book *cursor_book;
+				int cursor_lru = page_lru(cursor_page);
 
-				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
+				cursor_book = page_book(cursor_page);
+				cursor_book->pages_count[cursor_lru] -=
+								isolated_pages;
 				nr_taken += isolated_pages;
 				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
@@ -1281,6 +1284,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_lumpy_failed++;
 	}
 
+	book->pages_count[lru] -= nr_taken - nr_lumpy_taken;
+
 	*nr_scanned = scan;
 
 	trace_mm_vmscan_lru_isolate(order,
@@ -1670,15 +1675,18 @@ static void move_active_pages_to_lru(struct zone *zone,
 
 	while (!list_empty(list)) {
 		struct book *book;
+		int numpages;
 
 		page = lru_to_page(list);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		book = mem_cgroup_lru_add_list(zone, page, lru);
+		book = page_book(page);
 		list_move(&page->lru, &book->pages_lru[lru]);
-		pgmoved += hpage_nr_pages(page);
+		numpages = hpage_nr_pages(page);
+		book->pages_count[lru] += numpages;
+		pgmoved += numpages;
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
@@ -3542,8 +3550,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
 			__dec_zone_state(zone, NR_UNEVICTABLE);
-			book = mem_cgroup_lru_move_lists(zone, page,
-						LRU_UNEVICTABLE, lru);
+			book = page_book(page);
+			book->pages_count[LRU_UNEVICTABLE]--;
+			book->pages_count[lru]++;
 			list_move(&page->lru, &book->pages_lru[lru]);
 			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
 			pgrescued++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
