Message-Id: <20071218211549.456502890@redhat.com>
References: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:48 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 09/20] split anon & file LRUs for memcontrol code
Content-Disposition: inline; filename=rvr-03-linux-2.6-memcontrol-lrus.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Update the split anon & file LRU code to deal with the recent
memory controller changes.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc3-mm2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.24-rc3-mm2.orig/include/linux/memcontrol.h
+++ linux-2.6.24-rc3-mm2/include/linux/memcontrol.h
@@ -73,10 +73,8 @@ extern void mem_cgroup_note_reclaim_prio
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
 
-extern long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
-extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
+extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+					int priority, int active, int file);
 
 #else /* CONFIG_CGROUP_MEM_CONT */
 static inline void mm_init_cgroup(struct mm_struct *mm,
@@ -174,14 +172,9 @@ static inline void mem_cgroup_record_rec
 {
 }
 
-static inline long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
-{
-	return 0;
-}
-
-static inline long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
+static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
+					struct zone *zone, int priority,
+					int active, int file)
 {
 	return 0;
 }
Index: linux-2.6.24-rc3-mm2/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/memcontrol.c
+++ linux-2.6.24-rc3-mm2/mm/memcontrol.c
@@ -81,22 +81,13 @@ static s64 mem_cgroup_read_stat(struct m
 /*
  * per-zone information in memory controller.
  */
-
-enum mem_cgroup_zstat_index {
-	MEM_CGROUP_ZSTAT_ACTIVE,
-	MEM_CGROUP_ZSTAT_INACTIVE,
-
-	NR_MEM_CGROUP_ZSTAT,
-};
-
 struct mem_cgroup_per_zone {
 	/*
 	 * spin_lock to protect the per cgroup LRU
 	 */
 	spinlock_t		lru_lock;
-	struct list_head	active_list;
-	struct list_head	inactive_list;
-	unsigned long count[NR_MEM_CGROUP_ZSTAT];
+	struct list_head	lists[NR_LRU_LISTS];
+	unsigned long		count[NR_LRU_LISTS];
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -162,6 +153,7 @@ struct page_cgroup {
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
 
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -223,7 +215,7 @@ page_cgroup_zoneinfo(struct page_cgroup 
 }
 
 static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
-					enum mem_cgroup_zstat_index idx)
+					enum lru_list idx)
 {
 	int nid, zid;
 	struct mem_cgroup_per_zone *mz;
@@ -349,13 +341,15 @@ static struct page_cgroup *clear_page_cg
 
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
-	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int lru = LRU_BASE;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
-	if (from)
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
-	else
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
+	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
+
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
 	list_del_init(&pc->lru);
@@ -363,38 +357,37 @@ static void __mem_cgroup_remove_list(str
 
 static void __mem_cgroup_add_list(struct page_cgroup *pc)
 {
-	int to = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+	int lru = LRU_BASE;
+
+	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
+
+	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	list_add(&pc->lru, &mz->lists[lru]);
 
-	if (!to) {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
-		list_add(&pc->lru, &mz->inactive_list);
-	} else {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
-		list_add(&pc->lru, &mz->active_list);
-	}
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int file = pc->flags & PAGE_CGROUP_FLAG_FILE;
+	int lru = LRU_FILE * !!file + !!from;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
-	if (from)
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
-	else
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
-	if (active) {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
+	if (active)
 		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
-		list_move(&pc->lru, &mz->active_list);
-	} else {
-		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
+	else
 		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		list_move(&pc->lru, &mz->inactive_list);
-	}
+
+	lru = LRU_FILE * !!file + !!active;
+	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	list_move(&pc->lru, &mz->lists[lru]);
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -440,20 +433,6 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
-/*
- * This function is called from vmscan.c. In page reclaiming loop. balance
- * between active and inactive list is calculated. For memory controller
- * page reclaiming, we should use using mem_cgroup's imbalance rather than
- * zone's global lru imbalance.
- */
-long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
-{
-	unsigned long active, inactive;
-	/* active and inactive are the number of pages. 'long' is ok.*/
-	active = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_ACTIVE);
-	inactive = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_INACTIVE);
-	return (long) (active / (inactive + 1));
-}
 
 /*
  * prev_priority control...this will be used in memory reclaim path.
@@ -482,29 +461,16 @@ void mem_cgroup_record_reclaim_priority(
  * (see include/linux/mmzone.h)
  */
 
-long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-				   struct zone *zone, int priority)
-{
-	long nr_active;
-	int nid = zone->zone_pgdat->node_id;
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
-
-	nr_active = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE);
-	return (nr_active >> priority);
-}
-
-long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-					struct zone *zone, int priority)
+long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+				int priority, int active, int file)
 {
-	long nr_inactive;
+	long nr_pages;
 	int nid = zone->zone_pgdat->node_id;
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
-	return (nr_inactive >> priority);
+	nr_pages = MEM_CGROUP_ZSTAT(mz, LRU_FILE * !!file + !!active);
+	return (nr_pages >> priority);
 }
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -522,14 +488,12 @@ unsigned long mem_cgroup_isolate_pages(u
 	struct page_cgroup *pc, *tmp;
 	int nid = z->zone_pgdat->node_id;
 	int zid = zone_idx(z);
+	int lru = LRU_FILE * !!file + !!active;
 	struct mem_cgroup_per_zone *mz;
 
 	/* TODO: split file and anon LRUs - Rik */
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	if (active)
-		src = &mz->active_list;
-	else
-		src = &mz->inactive_list;
+	src = &mz->lists[lru];
 
 
 	spin_lock(&mz->lru_lock);
@@ -684,6 +648,8 @@ noreclaim:
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	if (page_file_cache(page))
+		pc->flags |= PAGE_CGROUP_FLAG_FILE;
 	if (page_cgroup_assign_new_page_cgroup(page, pc)) {
 		/*
 		 * an another charge is added to this page already.
@@ -840,18 +806,17 @@ retry:
 static void
 mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
-			    int active)
+			    int active, int file)
 {
 	struct page_cgroup *pc;
 	struct page *page;
 	int count;
 	unsigned long flags;
 	struct list_head *list;
+	int lru;
 
-	if (active)
-		list = &mz->active_list;
-	else
-		list = &mz->inactive_list;
+	lru = LRU_FILE * !!file + !!active;
+	list = &mz->lists[lru];
 
 	if (list_empty(list))
 		return;
@@ -904,10 +869,14 @@ int mem_cgroup_force_empty(struct mem_cg
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				struct mem_cgroup_per_zone *mz;
 				mz = mem_cgroup_zoneinfo(mem, node, zid);
-				/* drop all page_cgroup in active_list */
-				mem_cgroup_force_empty_list(mem, mz, 1);
-				/* drop all page_cgroup in inactive_list */
-				mem_cgroup_force_empty_list(mem, mz, 0);
+				/* drop all page_cgroup in ACTIVE_ANON */
+				mem_cgroup_force_empty_list(mem, mz, 1, 0);
+				/* drop all page_cgroup in INACTIVE_ANON */
+				mem_cgroup_force_empty_list(mem, mz, 0, 0);
+				/* drop all page_cgroup in ACTIVE_FILE */
+				mem_cgroup_force_empty_list(mem, mz, 1, 1);
+				/* drop all page_cgroup in INACTIVE_FILE */
+				mem_cgroup_force_empty_list(mem, mz, 0, 1);
 			}
 	}
 	ret = 0;
@@ -1055,14 +1024,21 @@ static int mem_control_stat_show(struct 
 	}
 	/* showing # of active pages */
 	{
-		unsigned long active, inactive;
+		unsigned long active_anon, inactive_anon;
+		unsigned long active_file, inactive_file;
 
-		inactive = mem_cgroup_get_all_zonestat(mem_cont,
-						MEM_CGROUP_ZSTAT_INACTIVE);
-		active = mem_cgroup_get_all_zonestat(mem_cont,
-						MEM_CGROUP_ZSTAT_ACTIVE);
-		seq_printf(m, "active %ld\n", (active) * PAGE_SIZE);
-		seq_printf(m, "inactive %ld\n", (inactive) * PAGE_SIZE);
+		inactive_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_ANON);
+		active_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_ANON);
+		inactive_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_FILE);
+		active_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_FILE);
+		seq_printf(m, "active_anon %ld\n", (active_anon) * PAGE_SIZE);
+		seq_printf(m, "inactive_anon %ld\n", (inactive_anon) * PAGE_SIZE);
+		seq_printf(m, "active_file %ld\n", (active_file) * PAGE_SIZE);
+		seq_printf(m, "inactive_file %ld\n", (inactive_file) * PAGE_SIZE);
 	}
 	return 0;
 }
@@ -1121,6 +1097,7 @@ static int alloc_mem_cgroup_per_zone_inf
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
+	int i;
 	int zone;
 
 	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, node);
@@ -1132,8 +1109,8 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		INIT_LIST_HEAD(&mz->active_list);
-		INIT_LIST_HEAD(&mz->inactive_list);
+		for (i = 0; i < NR_LRU_LISTS ; i++)
+			INIT_LIST_HEAD(&mz->lists[i]);
 		spin_lock_init(&mz->lru_lock);
 	}
 	return 0;
Index: linux-2.6.24-rc3-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/vmscan.c
+++ linux-2.6.24-rc3-mm2/mm/vmscan.c
@@ -1250,11 +1250,15 @@ static unsigned long shrink_zone(int pri
 		 * because memory controller hits its limit.
 		 * Then, don't modify zone reclaim related data.
 		 */
-		nr[LRU_ACTIVE] = mem_cgroup_calc_reclaim_active(sc->mem_cgroup,
-					zone, priority);
-
-		nr[LRU_INACTIVE] = mem_cgroup_calc_reclaim_inactive(sc->mem_cgroup,
-					zone, priority);
+		nr[LRU_ACTIVE_FILE] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
+					zone, priority, 1, 1);
+		nr[LRU_INACTIVE_FILE] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
+					zone, priority, 0, 1);
+
+		nr[LRU_ACTIVE_ANON] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
+					zone, priority, 1, 0);
+		nr[LRU_INACTIVE_ANON] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
+					zone, priority, 0, 0);
 	}
 
 	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
