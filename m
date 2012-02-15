Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C30576B007E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:11 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:11 -0800 (PST)
Subject: [PATCH RFC 01/15] mm: rename struct lruvec into struct book
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:08 +0400
Message-ID: <20120215225708.22050.95928.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

This patch rename:
struct lruvec into struct book
lruvec.lists into book.pages_lru
mem_cgroup_zone_lruvec(zone, memcg) into mem_cgroup_zone_book(zone, memcg)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   18 +++++++++---------
 include/linux/mm_inline.h  |    6 +++---
 include/linux/mmzone.h     |   10 +++++-----
 mm/memcontrol.c            |   38 +++++++++++++++++++-------------------
 mm/page_alloc.c            |    2 +-
 mm/swap.c                  |   12 ++++++------
 mm/vmscan.c                |   18 +++++++++---------
 7 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c697eda..c97fff9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -62,12 +62,12 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
+struct book *mem_cgroup_zone_book(struct zone *, struct mem_cgroup *);
+struct book *mem_cgroup_lru_add_list(struct zone *, struct page *,
 				       enum lru_list);
 void mem_cgroup_lru_del_list(struct page *, enum lru_list);
 void mem_cgroup_lru_del(struct page *);
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
+struct book *mem_cgroup_lru_move_lists(struct zone *, struct page *,
 					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
@@ -214,17 +214,17 @@ static inline void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 }
 
-static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+static inline struct book *mem_cgroup_zone_book(struct zone *zone,
 						    struct mem_cgroup *memcg)
 {
-	return &zone->lruvec;
+	return &zone->book;
 }
 
-static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
+static inline struct book *mem_cgroup_lru_add_list(struct zone *zone,
 						     struct page *page,
 						     enum lru_list lru)
 {
-	return &zone->lruvec;
+	return &zone->book;
 }
 
 static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
@@ -235,12 +235,12 @@ static inline void mem_cgroup_lru_del(struct page *page)
 {
 }
 
-static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+static inline struct book *mem_cgroup_lru_move_lists(struct zone *zone,
 						       struct page *page,
 						       enum lru_list from,
 						       enum lru_list to)
 {
-	return &zone->lruvec;
+	return &zone->book;
 }
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 227fd3e..e0b78ca 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -24,10 +24,10 @@ static inline int page_is_file_cache(struct page *page)
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	struct lruvec *lruvec;
+	struct book *book;
 
-	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
-	list_add(&page->lru, &lruvec->lists[lru]);
+	book = mem_cgroup_lru_add_list(zone, page, lru);
+	list_add(&page->lru, &book->pages_lru[lru]);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index facbe02..0b6e5d4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,10 +159,6 @@ static inline int is_unevictable_lru(enum lru_list lru)
 	return (lru == LRU_UNEVICTABLE);
 }
 
-struct lruvec {
-	struct list_head lists[NR_LRU_LISTS];
-};
-
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -300,6 +296,10 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+struct book {
+	struct list_head	pages_lru[NR_LRU_LISTS];
+};
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
@@ -374,7 +374,7 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;
-	struct lruvec		lruvec;
+	struct book		book;
 
 	struct zone_reclaim_stat reclaim_stat;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 343324a..578118b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -134,7 +134,7 @@ struct mem_cgroup_reclaim_iter {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	struct lruvec		lruvec;
+	struct book		book;
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
@@ -990,24 +990,24 @@ out:
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
 /**
- * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
- * @zone: zone of the wanted lruvec
- * @mem: memcg of the wanted lruvec
+ * mem_cgroup_zone_book - get the lru list vector for a zone and memcg
+ * @zone: zone of the wanted book
+ * @mem: memcg of the wanted book
  *
  * Returns the lru list vector holding pages for the given @zone and
- * @mem.  This can be the global zone lruvec, if the memory controller
+ * @mem.  This can be the global zone book, if the memory controller
  * is disabled.
  */
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+struct book *mem_cgroup_zone_book(struct zone *zone,
 				      struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_per_zone *mz;
 
 	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+		return &zone->book;
 
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
-	return &mz->lruvec;
+	return &mz->book;
 }
 
 /*
@@ -1025,18 +1025,18 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
  */
 
 /**
- * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
+ * mem_cgroup_lru_add_list - account for adding an lru page and return book
  * @zone: zone of the page
  * @page: the page
  * @lru: current lru
  *
  * This function accounts for @page being added to @lru, and returns
- * the lruvec for the given @zone and the memcg @page is charged to.
+ * the book for the given @zone and the memcg @page is charged to.
  *
  * The callsite is then responsible for physically linking the page to
- * the returned lruvec->lists[@lru].
+ * the returned book->pages_lru[@lru].
  */
-struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
+struct book *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 				       enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
@@ -1044,14 +1044,14 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 	struct page_cgroup *pc;
 
 	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+		return &zone->book;
 
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* compound_order() is stabilized through lru_lock */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
-	return &mz->lruvec;
+	return &mz->book;
 }
 
 /**
@@ -1095,13 +1095,13 @@ void mem_cgroup_lru_del(struct page *page)
  * @to: target lru
  *
  * This function accounts for @page being moved between the lrus @from
- * and @to, and returns the lruvec for the given @zone and the memcg
+ * and @to, and returns the book for the given @zone and the memcg
  * @page is charged to.
  *
  * The callsite is then responsible for physically relinking
- * @page->lru to the returned lruvec->lists[@to].
+ * @page->lru to the returned book->lists[@to].
  */
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+struct book *mem_cgroup_lru_move_lists(struct zone *zone,
 					 struct page *page,
 					 enum lru_list from,
 					 enum lru_list to)
@@ -3610,7 +3610,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lruvec.lists[lru];
+	list = &mz->book.pages_lru[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
 	/* give some margin against EBUSY etc...*/
@@ -4739,7 +4739,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
+			INIT_LIST_HEAD(&mz->book.pages_lru[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd4ea43..08b4e4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4311,7 +4311,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(lru)
-			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
+			INIT_LIST_HEAD(&zone->book.pages_lru[lru]);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
diff --git a/mm/swap.c b/mm/swap.c
index fff1ff7..d7c4c8f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -234,11 +234,11 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct lruvec *lruvec;
+		struct book *book;
 
-		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
+		book = mem_cgroup_lru_move_lists(page_zone(page),
 						   page, lru, lru);
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		list_move_tail(&page->lru, &book->pages_lru[lru]);
 		(*pgmoved)++;
 	}
 }
@@ -476,13 +476,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct lruvec *lruvec;
+		struct book *book;
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		book = mem_cgroup_lru_move_lists(zone, page, lru, lru);
+		list_move_tail(&page->lru, &book->pages_lru[lru]);
 		__count_vm_event(PGROTATED);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 751fab3..fba9dfd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1158,7 +1158,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long *nr_scanned, int order, isolate_mode_t mode,
 		int active, int file)
 {
-	struct lruvec *lruvec;
+	struct book *book;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1167,12 +1167,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long scan;
 	int lru = LRU_BASE;
 
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
 	if (active)
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	src = &lruvec->lists[lru];
+	src = &book->pages_lru[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1669,15 +1669,15 @@ static void move_active_pages_to_lru(struct zone *zone,
 	}
 
 	while (!list_empty(list)) {
-		struct lruvec *lruvec;
+		struct book *book;
 
 		page = lru_to_page(list);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
-		list_move(&page->lru, &lruvec->lists[lru]);
+		book = mem_cgroup_lru_add_list(zone, page, lru);
+		list_move(&page->lru, &book->pages_lru[lru]);
 		pgmoved += hpage_nr_pages(page);
 
 		if (put_page_testzero(page)) {
@@ -3514,7 +3514,7 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  */
 void check_move_unevictable_pages(struct page **pages, int nr_pages)
 {
-	struct lruvec *lruvec;
+	struct book *book;
 	struct zone *zone = NULL;
 	int pgscanned = 0;
 	int pgrescued = 0;
@@ -3542,9 +3542,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
 			__dec_zone_state(zone, NR_UNEVICTABLE);
-			lruvec = mem_cgroup_lru_move_lists(zone, page,
+			book = mem_cgroup_lru_move_lists(zone, page,
 						LRU_UNEVICTABLE, lru);
-			list_move(&page->lru, &lruvec->lists[lru]);
+			list_move(&page->lru, &book->pages_lru[lru]);
 			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
 			pgrescued++;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
