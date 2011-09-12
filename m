Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9227A900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:36 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 10/11] mm: make per-memcg LRU lists exclusive
Date: Mon, 12 Sep 2011 12:57:27 +0200
Message-Id: <1315825048-3437-11-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that all code that operated on global per-zone LRU lists is
converted to operate on per-memory cgroup LRU lists instead, there is
no reason to keep the double-LRU scheme around any longer.

The pc->lru member is removed and page->lru is linked directly to the
per-memory cgroup LRU lists, which removes two pointers from a
descriptor that exists for every page frame in the system.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h  |   54 +++-----
 include/linux/mm_inline.h   |   21 +--
 include/linux/page_cgroup.h |    1 -
 mm/memcontrol.c             |  319 ++++++++++++++++++++-----------------------
 mm/page_cgroup.c            |    1 -
 mm/swap.c                   |   23 ++-
 mm/vmscan.c                 |   81 +++++-------
 7 files changed, 228 insertions(+), 272 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7795b72..a12f16f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -32,17 +32,6 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
 };
 
-extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					isolate_mode_t mode,
-					struct zone *z,
-					struct mem_cgroup *mem_cont,
-					int active, int file);
-
-struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
-				    enum lru_list);
-
 struct mem_cgroup_iter {
 	struct zone *zone;
 	int priority;
@@ -72,13 +61,14 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
-extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru(struct page *page);
-extern void mem_cgroup_move_lists(struct page *page,
-				  enum lru_list from, enum lru_list to);
+
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
+				       enum lru_list);
+void mem_cgroup_lru_del_list(struct page *, enum lru_list);
+void mem_cgroup_lru_del(struct page *);
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
+					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -221,33 +211,33 @@ static inline void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 }
 
-static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
+static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+						    struct mem_cgroup *mem)
 {
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
+static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
+						     struct page *page,
+						     enum lru_list lru)
 {
-	return ;
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
+static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 {
-	return ;
 }
 
-static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
+static inline void mem_cgroup_lru_del(struct page *page)
 {
-	return ;
 }
 
-static inline void mem_cgroup_del_lru(struct page *page)
-{
-	return ;
-}
-
-static inline void
-mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_list to)
+static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+						       struct page *page,
+						       enum lru_list from,
+						       enum lru_list to)
 {
+	return &zone->lruvec;
 }
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e6a7ffe..4e3478e 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -22,26 +22,21 @@ static inline int page_is_file_cache(struct page *page)
 }
 
 static inline void
-__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
-		       struct list_head *head)
-{
-	list_add(&page->lru, head);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
-	mem_cgroup_add_lru_list(page, l);
-}
-
-static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	__add_page_to_lru_list(zone, page, l, &zone->lruvec.lists[l]);
+	struct lruvec *lruvec;
+
+	lruvec = mem_cgroup_lru_add_list(zone, page, l);
+	list_add(&page->lru, &lruvec->lists[l]);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
+	mem_cgroup_lru_del_list(page, l);
 	list_del(&page->lru);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
@@ -64,7 +59,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l;
 
-	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
@@ -75,8 +69,9 @@ del_page_from_lru(struct zone *zone, struct page *page)
 			l += LRU_ACTIVE;
 		}
 	}
+	mem_cgroup_lru_del_list(page, l);
+	list_del(&page->lru);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 961ecc7..5bae753 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -31,7 +31,6 @@ enum {
 struct page_cgroup {
 	unsigned long flags;
 	struct mem_cgroup *mem_cgroup;
-	struct list_head lru;		/* per cgroup LRU list */
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 465001c..a7d14a5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -920,6 +920,26 @@ out:
 }
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
+/**
+ * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
+ * @zone: zone of the wanted lruvec
+ * @mem: memcg of the wanted lruvec
+ *
+ * Returns the lru list vector holding pages for the given @zone and
+ * @mem.  This can be the global zone lruvec, if the memory controller
+ * is disabled.
+ */
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgroup *mem)
+{
+	struct mem_cgroup_per_zone *mz;
+
+	if (mem_cgroup_disabled())
+		return &zone->lruvec;
+
+	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
+	return &mz->lruvec;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -934,115 +954,123 @@ EXPORT_SYMBOL(mem_cgroup_count_vm_event);
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *mem,
-				    enum lru_list lru)
+/**
+ * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
+ * @zone: zone of the page
+ * @page: the page
+ * @lru: current lru
+ *
+ * This function accounts for @page being added to @lru, and returns
+ * the lruvec for the given @zone and the memcg @page is charged to.
+ *
+ * The callsite is then responsible for physically linking the page to
+ * the returned lruvec->lists[@lru].
+ */
+struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
+				       enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
-
-	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
-	pc = list_entry(mz->lruvec.lists[lru].prev, struct page_cgroup, lru);
-	return lookup_cgroup_page(pc);
-}
-
-void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
-{
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *mem;
 
 	if (mem_cgroup_disabled())
-		return;
+		return &zone->lruvec;
+
 	pc = lookup_page_cgroup(page);
-	/* can happen while we handle swapcache. */
-	if (!TestClearPageCgroupAcctLRU(pc))
-		return;
-	VM_BUG_ON(!pc->mem_cgroup);
+	VM_BUG_ON(PageCgroupAcctLRU(pc));
 	/*
-	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
-	 * removed from global LRU.
+	 * putback:				charge:
+	 * SetPageLRU				SetPageCgroupUsed
+	 * smp_mb				smp_mb
+	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
+	 *
+	 * Ensure that one of the two sides adds the page to the memcg
+	 * LRU during a race.
 	 */
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-	VM_BUG_ON(list_empty(&pc->lru));
-	list_del_init(&pc->lru);
-}
-
-void mem_cgroup_del_lru(struct page *page)
-{
-	mem_cgroup_del_lru_list(page, page_lru(page));
+	smp_mb();
+	/*
+	 * If the page is uncharged, it may be freed soon, but it
+	 * could also be swap cache (readahead, swapoff) that needs to
+	 * be reclaimable in the future.  root_mem_cgroup will babysit
+	 * it for the time being.
+	 */
+	if (PageCgroupUsed(pc)) {
+		/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+		smp_rmb();
+		mem = pc->mem_cgroup;
+		SetPageCgroupAcctLRU(pc);
+	} else
+		mem = root_mem_cgroup;
+	mz = page_cgroup_zoneinfo(mem, page);
+	/* compound_order() is stabilized through lru_lock */
+	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
+	return &mz->lruvec;
 }
 
-/*
- * Writeback is about to end against a page which has been marked for immediate
- * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.
+/**
+ * mem_cgroup_lru_del_list - account for removing an lru page
+ * @page: the page
+ * @lru: target lru
+ *
+ * This function accounts for @page being removed from @lru.
+ *
+ * The callsite is then responsible for physically unlinking
+ * @page->lru.
  */
-void mem_cgroup_rotate_reclaimable_page(struct page *page)
+void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
-	enum lru_list lru = page_lru(page);
 
 	if (mem_cgroup_disabled())
 		return;
 
 	pc = lookup_page_cgroup(page);
-	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lruvec.lists[lru]);
+	/*
+	 * root_mem_cgroup babysits uncharged LRU pages, but
+	 * PageCgroupUsed is cleared when the page is about to get
+	 * freed.  PageCgroupAcctLRU remembers whether the
+	 * LRU-accounting happened against pc->mem_cgroup or
+	 * root_mem_cgroup.
+	 */
+	if (TestClearPageCgroupAcctLRU(pc)) {
+		VM_BUG_ON(!pc->mem_cgroup);
+		mem = pc->mem_cgroup;
+	} else
+		mem = root_mem_cgroup;
+	mz = page_cgroup_zoneinfo(mem, page);
+	/* huge page split is done under lru_lock. so, we have no races. */
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 }
 
-void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
+void mem_cgroup_lru_del(struct page *page)
 {
-	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move(&pc->lru, &mz->lruvec.lists[lru]);
+	mem_cgroup_lru_del_list(page, page_lru(page));
 }
 
-void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
+/**
+ * mem_cgroup_lru_move_lists - account for moving a page between lrus
+ * @zone: zone of the page
+ * @page: the page
+ * @from: current lru
+ * @to: target lru
+ *
+ * This function accounts for @page being moved between the lrus @from
+ * and @to, and returns the lruvec for the given @zone and the memcg
+ * @page is charged to.
+ *
+ * The callsite is then responsible for physically relinking
+ * @page->lru to the returned lruvec->lists[@to].
+ */
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+					 struct page *page,
+					 enum lru_list from,
+					 enum lru_list to)
 {
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-
-	if (mem_cgroup_disabled())
-		return;
-	pc = lookup_page_cgroup(page);
-	VM_BUG_ON(PageCgroupAcctLRU(pc));
-	/*
-	 * putback:				charge:
-	 * SetPageLRU				SetPageCgroupUsed
-	 * smp_mb				smp_mb
-	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
-	 *
-	 * Ensure that one of the two sides adds the page to the memcg
-	 * LRU during a race.
-	 */
-	smp_mb();
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
-	SetPageCgroupAcctLRU(pc);
-	list_add(&pc->lru, &mz->lruvec.lists[lru]);
+	/* XXX: Optimize this, especially for @from == @to */
+	mem_cgroup_lru_del_list(page, from);
+	return mem_cgroup_lru_add_list(zone, page, to);
 }
 
 /*
@@ -1053,6 +1081,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
  */
 static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
+	enum lru_list lru;
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -1069,17 +1098,28 @@ static void mem_cgroup_lru_del_before_commit(struct page *page)
 		return;
 
 	spin_lock_irqsave(&zone->lru_lock, flags);
+	lru = page_lru(page);
 	/*
-	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
-	 * is guarded by lock_page() because the page is SwapCache.
+	 * The uncharged page could still be registered to the LRU of
+	 * the stale pc->mem_cgroup.
+	 *
+	 * As pc->mem_cgroup is about to get overwritten, the old LRU
+	 * accounting needs to be taken care of.  Let root_mem_cgroup
+	 * babysit the page until the new memcg is responsible for it.
+	 *
+	 * The PCG_USED bit is guarded by lock_page() as the page is
+	 * swapcache/pagecache.
 	 */
-	if (!PageCgroupUsed(pc))
-		mem_cgroup_del_lru_list(page, page_lru(page));
+	if (PageLRU(page) && PageCgroupAcctLRU(pc) && !PageCgroupUsed(pc)) {
+		del_page_from_lru_list(zone, page, lru);
+		add_page_to_lru_list(zone, page, lru);
+	}
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
 static void mem_cgroup_lru_add_after_commit(struct page *page)
 {
+	enum lru_list lru;
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -1097,22 +1137,22 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
 	if (likely(!PageLRU(page)))
 		return;
 	spin_lock_irqsave(&zone->lru_lock, flags);
-	/* link when the page is linked to LRU but page_cgroup isn't */
-	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
-		mem_cgroup_add_lru_list(page, page_lru(page));
+	lru = page_lru(page);
+	/*
+	 * If the page is not on the LRU, someone will soon put it
+	 * there.  If it is, and also already accounted for on the
+	 * memcg-side, it must be on the right lruvec as setting
+	 * pc->mem_cgroup and PageCgroupUsed is properly ordered.
+	 * Otherwise, root_mem_cgroup has been babysitting the page
+	 * during the charge.  Move it to the new memcg now.
+	 */
+	if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
+		del_page_from_lru_list(zone, page, lru);
+		add_page_to_lru_list(zone, page, lru);
+	}
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-
-void mem_cgroup_move_lists(struct page *page,
-			   enum lru_list from, enum lru_list to)
-{
-	if (mem_cgroup_disabled())
-		return;
-	mem_cgroup_del_lru_list(page, from);
-	mem_cgroup_add_lru_list(page, to);
-}
-
 /*
  * Checks whether given mem is same or in the root_mem's
  * hierarchy subtree
@@ -1218,68 +1258,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return &mz->reclaim_stat;
 }
 
-unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					isolate_mode_t mode,
-					struct zone *z,
-					struct mem_cgroup *mem_cont,
-					int active, int file)
-{
-	unsigned long nr_taken = 0;
-	struct page *page;
-	unsigned long scan;
-	LIST_HEAD(pc_list);
-	struct list_head *src;
-	struct page_cgroup *pc, *tmp;
-	int nid = zone_to_nid(z);
-	int zid = zone_idx(z);
-	struct mem_cgroup_per_zone *mz;
-	int lru = LRU_FILE * file + active;
-	int ret;
-
-	BUG_ON(!mem_cont);
-	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	src = &mz->lruvec.lists[lru];
-
-	scan = 0;
-	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
-		if (scan >= nr_to_scan)
-			break;
-
-		if (unlikely(!PageCgroupUsed(pc)))
-			continue;
-
-		page = lookup_cgroup_page(pc);
-
-		if (unlikely(!PageLRU(page)))
-			continue;
-
-		scan++;
-		ret = __isolate_lru_page(page, mode, file);
-		switch (ret) {
-		case 0:
-			list_move(&page->lru, dst);
-			mem_cgroup_del_lru(page);
-			nr_taken += hpage_nr_pages(page);
-			break;
-		case -EBUSY:
-			/* we don't affect global LRU but rotate in our LRU */
-			mem_cgroup_rotate_lru_list(page, page_lru(page));
-			break;
-		default:
-			break;
-		}
-	}
-
-	*scanned = scan;
-
-	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
-				      0, 0, 0, mode);
-
-	return nr_taken;
-}
-
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -3615,11 +3593,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
 {
-	struct zone *zone;
 	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc, *busy;
 	unsigned long flags, loop;
 	struct list_head *list;
+	struct page *busy;
+	struct zone *zone;
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
@@ -3631,6 +3609,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	loop += 256;
 	busy = NULL;
 	while (loop--) {
+		struct page_cgroup *pc;
 		struct page *page;
 
 		ret = 0;
@@ -3639,16 +3618,16 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			break;
 		}
-		pc = list_entry(list->prev, struct page_cgroup, lru);
-		if (busy == pc) {
-			list_move(&pc->lru, list);
+		page = list_entry(list->prev, struct page, lru);
+		if (busy == page) {
+			list_move(&page->lru, list);
 			busy = NULL;
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-		page = lookup_cgroup_page(pc);
+		pc = lookup_page_cgroup(page);
 
 		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
 		if (ret == -ENOMEM)
@@ -3656,7 +3635,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 		if (ret == -EBUSY || ret == -EINVAL) {
 			/* found lock contention or "pc" is obsolete. */
-			busy = pc;
+			busy = page;
 			cond_resched();
 		} else
 			busy = NULL;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 6bdc67d..256dee8 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -16,7 +16,6 @@ static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned long id)
 	pc->flags = 0;
 	set_page_cgroup_array_id(pc, id);
 	pc->mem_cgroup = NULL;
-	INIT_LIST_HEAD(&pc->lru);
 }
 static unsigned long total_usage;
 
diff --git a/mm/swap.c b/mm/swap.c
index 66e8292..81c6da9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -209,12 +209,14 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 static void pagevec_move_tail_fn(struct page *page, void *arg)
 {
 	int *pgmoved = arg;
-	struct zone *zone = page_zone(page);
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
-		mem_cgroup_rotate_reclaimable_page(page);
+		struct lruvec *lruvec;
+
+		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
+						   page, lru, lru);
+		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
 }
@@ -453,12 +455,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
+		struct lruvec *lruvec;
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
-		mem_cgroup_rotate_reclaimable_page(page);
+		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
+		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		__count_vm_event(PGROTATED);
 	}
 
@@ -648,6 +651,8 @@ void lru_add_page_tail(struct zone* zone,
 	SetPageLRU(page_tail);
 
 	if (page_evictable(page_tail, NULL)) {
+		struct lruvec *lruvec;
+
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
 			active = 1;
@@ -657,11 +662,13 @@ void lru_add_page_tail(struct zone* zone,
 			lru = LRU_INACTIVE_ANON;
 		}
 		update_page_reclaim_stat(zone, page_tail, file, active);
+		lruvec = mem_cgroup_lru_add_list(zone, page_tail, lru);
 		if (likely(PageLRU(page)))
-			__add_page_to_lru_list(zone, page_tail, lru,
-					       page->lru.prev);
+			list_add(&page_tail->lru, page->lru.prev);
 		else
-			add_page_to_lru_list(zone, page_tail, lru);
+			list_add(&page_tail->lru, &lruvec->lists[lru]);
+		__mod_zone_page_state(zone, NR_LRU_BASE + lru,
+				      hpage_nr_pages(page_tail));
 	} else {
 		SetPageUnevictable(page_tail);
 		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index df00195..10f5edb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1156,15 +1156,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
+			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
-			mem_cgroup_del_lru(page);
 			nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
 			/* else it is being freed elsewhere */
 			list_move(&page->lru, src);
-			mem_cgroup_rotate_lru_list(page, page_lru(page));
 			continue;
 
 		default:
@@ -1214,8 +1213,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
-				mem_cgroup_del_lru(cursor_page);
 				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
@@ -1256,18 +1255,20 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	return nr_taken;
 }
 
-static unsigned long isolate_pages_global(unsigned long nr,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					isolate_mode_t mode,
-					struct zone *z,	int active, int file)
+static unsigned long isolate_pages(unsigned long nr, struct mem_cgroup_zone *mz,
+				   struct list_head *dst,
+				   unsigned long *scanned, int order,
+				   isolate_mode_t mode, int active, int file)
 {
+	struct lruvec *lruvec;
 	int lru = LRU_BASE;
+
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
 	if (active)
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lruvec.lists[lru], dst,
+	return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
 				 scanned, order, mode, file);
 }
 
@@ -1535,14 +1536,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	if (scanning_global_lru(mz)) {
-		nr_taken = isolate_pages_global(nr_to_scan, &page_list,
-			&nr_scanned, sc->order, reclaim_mode, zone, 0, file);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
-			&nr_scanned, sc->order, reclaim_mode, zone,
-			mz->mem_cgroup, 0, file);
-	}
+	nr_taken = isolate_pages(nr_to_scan, mz, &page_list,
+				 &nr_scanned, sc->order,
+				 reclaim_mode, 0, file);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1626,13 +1622,15 @@ static void move_active_pages_to_lru(struct zone *zone,
 	pagevec_init(&pvec, 1);
 
 	while (!list_empty(list)) {
+		struct lruvec *lruvec;
+
 		page = lru_to_page(list);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lruvec.lists[lru]);
-		mem_cgroup_add_lru_list(page, lru);
+		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += hpage_nr_pages(page);
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
@@ -1673,17 +1671,10 @@ static void shrink_active_list(unsigned long nr_pages,
 		reclaim_mode |= ISOLATE_CLEAN;
 
 	spin_lock_irq(&zone->lru_lock);
-	if (scanning_global_lru(mz)) {
-		nr_taken = isolate_pages_global(nr_pages, &l_hold,
-						&pgscanned, sc->order,
-						reclaim_mode, zone,
-						1, file);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
-						&pgscanned, sc->order,
-						reclaim_mode, zone,
-						mz->mem_cgroup, 1, file);
-	}
+
+	nr_taken = isolate_pages(nr_pages, mz, &l_hold,
+				 &pgscanned, sc->order,
+				 reclaim_mode, 1, file);
 
 	if (global_reclaim(sc))
 		zone->pages_scanned += pgscanned;
@@ -3403,16 +3394,18 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
-	VM_BUG_ON(PageActive(page));
+	struct lruvec *lruvec;
 
+	VM_BUG_ON(PageActive(page));
 retry:
 	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
 		enum lru_list l = page_lru_base_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
-		list_move(&page->lru, &zone->lruvec.lists[l]);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
+		lruvec = mem_cgroup_lru_move_lists(zone, page,
+						   LRU_UNEVICTABLE, l);
+		list_move(&page->lru, &lruvec->lists[l]);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
@@ -3420,8 +3413,9 @@ retry:
 		 * rotate unevictable list
 		 */
 		SetPageUnevictable(page);
-		list_move(&page->lru, &zone->lruvec.lists[LRU_UNEVICTABLE]);
-		mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
+		lruvec = mem_cgroup_lru_move_lists(zone, page, LRU_UNEVICTABLE,
+						   LRU_UNEVICTABLE);
+		list_move(&page->lru, &lruvec->lists[LRU_UNEVICTABLE]);
 		if (page_evictable(page, NULL))
 			goto retry;
 	}
@@ -3482,17 +3476,6 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 
 }
 
-/*
- * XXX: Temporary helper to get to the last page of a mem_cgroup_zone
- * lru list.  This will be reasonably unified in a second.
- */
-static struct page *lru_tailpage(struct mem_cgroup_zone *mz, enum lru_list lru)
-{
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_lru_to_page(mz->zone, mz->mem_cgroup, lru);
-	return lru_to_page(&mz->zone->lruvec.lists[lru]);
-}
-
 /**
  * scan_zone_unevictable_pages - check unevictable list for evictable pages
  * @zone - zone of which to scan the unevictable list
@@ -3515,8 +3498,12 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 			.zone = zone,
 		};
 		unsigned long nr_to_scan;
+		struct list_head *list;
+		struct lruvec *lruvec;
 
 		nr_to_scan = zone_nr_lru_pages(&mz, LRU_UNEVICTABLE);
+		lruvec = mem_cgroup_zone_lruvec(zone, mem);
+		list = &lruvec->lists[LRU_UNEVICTABLE];
 		while (nr_to_scan > 0) {
 			unsigned long batch_size;
 			unsigned long scan;
@@ -3527,7 +3514,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 			for (scan = 0; scan < batch_size; scan++) {
 				struct page *page;
 
-				page = lru_tailpage(&mz, LRU_UNEVICTABLE);
+				page = lru_to_page(list);
 				if (!trylock_page(page))
 					continue;
 				if (likely(PageLRU(page) &&
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
