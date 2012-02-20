Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id A1BBB6B00EB
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:08 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:08 -0800 (PST)
Subject: [PATCH v2 08/22] mm: add lruvec->pages_count
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:05 +0400
Message-ID: <20120220172305.22196.49240.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Move lru pages counter from mem_cgroup_per_zone->count[] to lruvec->pages_count[]

Account pages in all lruvecs, incuding root,
this isn't a huge overhead, but it greatly simplifies all code.

Redundant page_lruvec() calls will be optimized in further patches.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   29 -----------
 include/linux/mm.h         |   17 ++++++
 include/linux/mm_inline.h  |   15 ++++--
 include/linux/mmzone.h     |    9 ++-
 mm/memcontrol.c            |  119 ++++++++++----------------------------------
 mm/page_alloc.c            |    4 +
 mm/swap.c                  |    7 +--
 mm/vmscan.c                |   25 +++++++--
 8 files changed, 83 insertions(+), 142 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4fbe18a..cc6061a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -63,12 +63,6 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
-				       enum lru_list);
-void mem_cgroup_lru_del_list(struct page *, enum lru_list);
-void mem_cgroup_lru_del(struct page *);
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
-					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -220,29 +214,6 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	return &zone->lruvec;
 }
 
-static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
-						     struct page *page,
-						     enum lru_list lru)
-{
-	return &zone->lruvec;
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
-static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
-						       struct page *page,
-						       enum lru_list from,
-						       enum lru_list to)
-{
-	return &zone->lruvec;
-}
-
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee3ebc1..e483f30 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -728,6 +728,23 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 #endif
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+
+/* Multiple lruvecs in zone */
+
+extern struct lruvec *page_lruvec(struct page *lruvec);
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+/* Single lruvec in zone */
+
+static inline struct lruvec *page_lruvec(struct page *page)
+{
+	return &page_zone(page)->lruvec;
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+
 /*
  * Some inline functions in vmstat.h depend on page_zone()
  */
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8415596..daa3d15 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -24,19 +24,24 @@ static inline int page_is_file_cache(struct page *page)
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	struct lruvec *lruvec;
+	struct lruvec *lruvec = page_lruvec(page);
+	int numpages = hpage_nr_pages(page);
 
-	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
 	list_add(&page->lru, &lruvec->pages_lru[lru]);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
+	lruvec->pages_count[lru] += numpages;
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, numpages);
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
-	mem_cgroup_lru_del_list(page, lru);
+	struct lruvec *lruvec = page_lruvec(page);
+	int numpages = hpage_nr_pages(page);
+
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
+	lruvec->pages_count[lru] -= numpages;
+	VM_BUG_ON((long)lruvec->pages_count[lru] < 0);
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -numpages);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0d2e6b6..b39f230 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,10 +159,6 @@ static inline int is_unevictable_lru(enum lru_list lru)
 	return (lru == LRU_UNEVICTABLE);
 }
 
-struct lruvec {
-	struct list_head pages_lru[NR_LRU_LISTS];
-};
-
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -300,6 +296,11 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+struct lruvec {
+	struct list_head	pages_lru[NR_LRU_LISTS];
+	unsigned long		pages_count[NR_LRU_LISTS];
+};
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b65c619..fa64817 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -135,7 +135,6 @@ struct mem_cgroup_reclaim_iter {
  */
 struct mem_cgroup_per_zone {
 	struct lruvec		lruvec;
-	unsigned long		lru_size[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
@@ -716,7 +715,7 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 
 	for_each_lru(lru) {
 		if (BIT(lru) & lru_mask)
-			ret += mz->lru_size[lru];
+			ret += mz->lruvec.pages_count[lru];
 	}
 	return ret;
 }
@@ -992,6 +991,28 @@ out:
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
 /**
+ * page_lruvec - get the lruvec there this page is located
+ * @page: the struct page pointer with stable reference
+ *
+ * Caller must guarantee page_cgroup->mem_cgroup pointer validity.
+ *
+ * Returns pointer to struct lruvec.
+ */
+struct lruvec *page_lruvec(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return &page_zone(page)->lruvec;
+
+	pc = lookup_page_cgroup(page);
+	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
+			page_to_nid(page), page_zonenum(page));
+	return &mz->lruvec;
+}
+
+/**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
  * @mem: memcg of the wanted lruvec
@@ -1026,93 +1047,6 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-/**
- * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
- * @zone: zone of the page
- * @page: the page
- * @lru: current lru
- *
- * This function accounts for @page being added to @lru, and returns
- * the lruvec for the given @zone and the memcg @page is charged to.
- *
- * The callsite is then responsible for physically linking the page to
- * the returned lruvec->pages_lru[@lru].
- */
-struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
-				       enum lru_list lru)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return &zone->lruvec;
-
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* compound_order() is stabilized through lru_lock */
-	mz->lru_size[lru] += 1 << compound_order(page);
-	return &mz->lruvec;
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
-	VM_BUG_ON(mz->lru_size[lru] < (1 << compound_order(page)));
-	mz->lru_size[lru] -= 1 << compound_order(page);
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
- * and @to, and returns the lruvec for the given @zone and the memcg
- * @page is charged to.
- *
- * The callsite is then responsible for physically relinking
- * @page->lru to the returned lruvec->lists[@to].
- */
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
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
@@ -3612,8 +3546,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->lruvec.pages_lru[lru];
-
-	loop = mz->lru_size[lru];
+	loop = mz->lruvec.pages_count[lru];
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
@@ -4736,8 +4669,10 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(lru)
+		for_each_lru(lru) {
 			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
+			mz->lruvec.pages_count[lru] = 0;
+		}
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b75af1e..c7fcddc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4362,8 +4362,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		for_each_lru(lru)
+		for_each_lru(lru) {
 			INIT_LIST_HEAD(&zone->lruvec.pages_lru[lru]);
+			zone->lruvec.pages_count[lru] = 0;
+		}
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
diff --git a/mm/swap.c b/mm/swap.c
index f57604f..4363daf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -239,10 +239,8 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct lruvec *lruvec;
+		struct lruvec *lruvec = page_lruvec(page);
 
-		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
-						   page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->pages_lru[lru]);
 		(*pgmoved)++;
 	}
@@ -550,12 +548,11 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct lruvec *lruvec;
+		struct lruvec *lruvec = page_lruvec(page);
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->pages_lru[lru]);
 		__count_vm_event(PGROTATED);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7083567..3e8d049 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1186,7 +1186,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
 			nr_taken += hpage_nr_pages(page);
 			break;
@@ -1244,10 +1243,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				unsigned int isolated_pages;
+				struct lruvec *cursor_lruvec;
+				int cursor_lru = page_lru(cursor_page);
 
-				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
+				cursor_lruvec = page_lruvec(cursor_page);
+				cursor_lruvec->pages_count[cursor_lru] -=
+								isolated_pages;
+				VM_BUG_ON((long)cursor_lruvec->
+						pages_count[cursor_lru] < 0);
 				nr_taken += isolated_pages;
 				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
@@ -1279,6 +1284,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_lumpy_failed++;
 	}
 
+	lruvec->pages_count[lru] -= nr_taken - nr_lumpy_taken;
+	VM_BUG_ON((long)lruvec->pages_count[lru] < 0);
+
 	*nr_scanned = scan;
 
 	trace_mm_vmscan_lru_isolate(sc->order,
@@ -1662,15 +1670,18 @@ static void move_active_pages_to_lru(struct zone *zone,
 
 	while (!list_empty(list)) {
 		struct lruvec *lruvec;
+		int numpages;
 
 		page = lru_to_page(list);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+		lruvec = page_lruvec(page);
 		list_move(&page->lru, &lruvec->pages_lru[lru]);
-		pgmoved += hpage_nr_pages(page);
+		numpages = hpage_nr_pages(page);
+		lruvec->pages_count[lru] += numpages;
+		pgmoved += numpages;
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
@@ -3581,8 +3592,10 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
 			__dec_zone_state(zone, NR_UNEVICTABLE);
-			lruvec = mem_cgroup_lru_move_lists(zone, page,
-						LRU_UNEVICTABLE, lru);
+			lruvec = page_lruvec(page);
+			lruvec->pages_count[LRU_UNEVICTABLE]--;
+			VM_BUG_ON((long)lruvec->pages_count[LRU_UNEVICTABLE] < 0);
+			lruvec->pages_count[lru]++;
 			list_move(&page->lru, &lruvec->pages_lru[lru]);
 			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
 			pgrescued++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
