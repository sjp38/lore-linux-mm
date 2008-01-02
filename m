From: linux-kernel@vger.kernel.org
Subject: [patch 07/19] split anon & file LRUs for memcontrol code
Date: Wed, 02 Jan 2008 17:41:51 -0500
Message-ID: <20080102224154.309980291@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759903AbYABXYt@vger.kernel.org>
Content-Disposition: inline; filename=rvr-03-linux-2.6-memcontrol-lrus.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

Update the split anon & file LRU code to deal with the recent
memory controller changes.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/memcontrol.h	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/memcontrol.h	2008-01-02 15:56:00.000000000 -0500
@@ -69,10 +69,8 @@ extern void mem_cgroup_note_reclaim_prio
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
 
-extern long mem_cgroup_calc_reclaim_active(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
-extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
-				struct zone *zone, int priority);
+extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+					int priority, enum lru_list lru);
 
 #else /* CONFIG_CGROUP_MEM_CONT */
 static inline void mm_init_cgroup(struct mm_struct *mm,
@@ -170,14 +168,9 @@ static inline void mem_cgroup_record_rec
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
Index: linux-2.6.24-rc6-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/memcontrol.c	2008-01-02 15:55:33.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/memcontrol.c	2008-01-02 15:56:00.000000000 -0500
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
@@ -161,6 +152,7 @@ struct page_cgroup {
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
 
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -221,7 +213,7 @@ page_cgroup_zoneinfo(struct page_cgroup 
 }
 
 static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
-					enum mem_cgroup_zstat_index idx)
+					enum lru_list idx)
 {
 	int nid, zid;
 	struct mem_cgroup_per_zone *mz;
@@ -347,13 +339,15 @@ static struct page_cgroup *clear_page_cg
 
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
@@ -361,38 +355,37 @@ static void __mem_cgroup_remove_list(str
 
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
@@ -438,20 +431,6 @@ int mem_cgroup_calc_mapped_ratio(struct 
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
@@ -480,29 +459,16 @@ void mem_cgroup_record_reclaim_priority(
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
+				int priority, enum lru_list lru)
 {
-	long nr_inactive;
+	long nr_pages;
 	int nid = zone->zone_pgdat->node_id;
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
-	return (nr_inactive >> priority);
+	nr_pages = MEM_CGROUP_ZSTAT(mz, lru);
+	return (nr_pages >> priority);
 }
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -520,14 +486,12 @@ unsigned long mem_cgroup_isolate_pages(u
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
@@ -669,6 +633,8 @@ retry:
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	if (page_file_cache(page))
+		pc->flags |= PAGE_CGROUP_FLAG_FILE;
 
 	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
 		/*
@@ -838,18 +804,17 @@ retry:
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
@@ -900,10 +865,14 @@ int mem_cgroup_force_empty(struct mem_cg
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
@@ -996,14 +965,21 @@ static int mem_control_stat_show(struct 
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
@@ -1057,6 +1033,7 @@ static int alloc_mem_cgroup_per_zone_inf
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
+	int i;
 	int zone;
 	/*
 	 * This routine is called against possible nodes.
@@ -1078,8 +1055,8 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		INIT_LIST_HEAD(&mz->active_list);
-		INIT_LIST_HEAD(&mz->inactive_list);
+		for (i = 0; i < NR_LRU_LISTS ; i++)
+			INIT_LIST_HEAD(&mz->lists[i]);
 		spin_lock_init(&mz->lru_lock);
 	}
 	return 0;
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 15:55:55.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 15:56:00.000000000 -0500
@@ -1230,13 +1230,13 @@ static unsigned long shrink_zone(int pri
 
 	get_scan_ratio(zone, sc, percent);
 
-	if (scan_global_lru(sc)) {
-		/*
-		 * Add one to nr_to_scan just to make sure that the kernel
-		 * will slowly sift through the active list.
-		 */
-		for_each_lru(l) {
+	for_each_lru(l) {
+		if (scan_global_lru(sc)) {
 			int file = is_file_lru(l);
+			/*
+			 * Add one to nr_to_scan just to make sure that the
+			 * kernel will slowly sift through the active list.
+			 */
 			zone->nr_scan[l] += (zone_page_state(zone,
 				NR_INACTIVE_ANON + l) >> priority) + 1;
 			nr[l] = zone->nr_scan[l] * percent[file] / 100;
@@ -1244,18 +1244,15 @@ static unsigned long shrink_zone(int pri
 				zone->nr_scan[l] = 0;
 			else
 				nr[l] = 0;
+		} else {
+			/*
+			 * This reclaim occurs not because zone memory shortage
+			 * but because memory controller hits its limit.
+			 * Then, don't modify zone reclaim related data.
+			 */
+		nr[l] = mem_cgroup_calc_reclaim(sc->mem_cgroup, zone,
+							priority, l);
 		}
-	} else {
-		/*
-		 * This reclaim occurs not because zone memory shortage but
-		 * because memory controller hits its limit.
-		 * Then, don't modify zone reclaim related data.
-		 */
-		nr[LRU_ACTIVE] = mem_cgroup_calc_reclaim_active(sc->mem_cgroup,
-					zone, priority);
