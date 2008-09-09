Subject: Re: memcg swappiness (Re: memo: mem+swap controller)
In-Reply-To: Your message of "Fri, 01 Aug 2008 12:16:13 +0530"
	<4892B135.4090203@linux.vnet.ibm.com>
References: <4892B135.4090203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080909091715.81D7E5AA5@siro.lan>
Date: Tue,  9 Sep 2008 18:17:15 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

hi,

here's the updated patch.

changes from the previous one:
	- adapt to v2.6.27-rc1-mm1.
	- implement per-cgroup per-zone recent_scanned and recent_rotated.
	- when creating a cgroup, inherit the swappiness value from its parent.
	- fix build w/o memcg.

any comments?

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..7b1b4e6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -47,6 +47,7 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
@@ -72,6 +73,19 @@ extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
 
+extern void mem_cgroup_update_scanned(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long idx,
+					unsigned long scanned);
+extern void mem_cgroup_update_rotated(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long idx,
+					unsigned long rotated);
+extern void mem_cgroup_get_scan_param(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long *anon,
+					unsigned long *file,
+					unsigned long **recent_scanned,
+					unsigned long **recent_rotated,
+					spinlock_t **lock);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void page_reset_bad_cgroup(struct page *page)
 {
@@ -163,6 +177,31 @@ static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
 {
 	return 0;
 }
+
+static inline void mem_cgroup_update_scanned(struct mem_cgroup *mem,
+					struct zone *zone,
+					unsigned long idx,
+					unsigned long scanned)
+{
+}
+
+static inline void mem_cgroup_update_rotated(struct mem_cgroup *mem,
+					struct zone *zone,
+					unsigned long idx,
+					unsigned long rotated)
+{
+}
+
+static inline void mem_cgroup_get_scan_param(struct mem_cgroup *mem,
+					struct zone *zone,
+					unsigned long *anon,
+					unsigned long *file,
+					unsigned long **recent_scanned,
+					unsigned long **recent_rotated,
+					spinlock_t **lock)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 344a477..d4ac8c6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -93,6 +93,8 @@ struct mem_cgroup_per_zone {
 	spinlock_t		lru_lock;
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
+	unsigned long		recent_scanned[2];
+	unsigned long		recent_rotated[2];
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -129,6 +131,7 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned int swappiness;	/* swappiness */
 	/*
 	 * statistics.
 	 */
@@ -437,14 +440,57 @@ void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
 long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru)
 {
-	long nr_pages;
 	int nid = zone->zone_pgdat->node_id;
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	nr_pages = MEM_CGROUP_ZSTAT(mz, lru);
+	return MEM_CGROUP_ZSTAT(mz, lru);
+}
+
+void mem_cgroup_update_scanned(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long idx,
+					unsigned long scanned)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
+
+	spin_lock(&mz->lru_lock);
+	mz->recent_scanned[idx] += scanned;
+	spin_unlock(&mz->lru_lock);
+}
+
+void mem_cgroup_update_rotated(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long idx,
+					unsigned long rotated)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
+
+	spin_lock(&mz->lru_lock);
+	mz->recent_rotated[idx] += rotated;
+	spin_unlock(&mz->lru_lock);
+}
+
+void mem_cgroup_get_scan_param(struct mem_cgroup *mem, struct zone *zone,
+					unsigned long *anon,
+					unsigned long *file,
+					unsigned long **recent_scanned,
+					unsigned long **recent_rotated,
+					spinlock_t **lock)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	return (nr_pages >> priority);
+	*anon = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON)
+	    + MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+	*file = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE)
+	    + MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+	*recent_scanned = mz->recent_scanned;
+	*recent_rotated = mz->recent_rotated;
+	*lock = &mz->lru_lock;
 }
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -1002,6 +1048,24 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	return 0;
 }
 
+static int mem_cgroup_swappiness_write(struct cgroup *cont, struct cftype *cft,
+				       u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	if (val > 100)
+		return -EINVAL;
+	mem->swappiness = val;
+	return 0;
+}
+
+static u64 mem_cgroup_swappiness_read(struct cgroup *cont, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+  
+	return mem->swappiness;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1034,8 +1098,21 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "swappiness",
+		.write_u64 = mem_cgroup_swappiness_write,
+		.read_u64 = mem_cgroup_swappiness_read,
+	},
 };
 
+/* XXX probably it's better to move try_to_free_mem_cgroup_pages to
+  memcontrol.c and kill this */
+int mem_cgroup_swappiness(struct mem_cgroup *mem)
+{
+
+	return mem->swappiness;
+}
+
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
 	struct mem_cgroup_per_node *pn;
@@ -1105,10 +1182,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		mem->swappiness = vm_swappiness;
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		/* XXX hierarchy */
+		mem->swappiness =
+		    mem_cgroup_from_cont(cont->parent)->swappiness;
 	}
 
 	res_counter_init(&mem->res);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 85ce427..b42e730 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -975,6 +975,30 @@ static unsigned long clear_active_flags(struct list_head *page_list,
 	return nr_active;
 }
 
+static void
+update_scanned(struct scan_control *sc, struct zone *zone, int idx,
+    unsigned long scanned)
+{
+
+	if (scan_global_lru(sc)) {
+		zone->recent_scanned[idx] += scanned;
+	} else {
+		mem_cgroup_update_scanned(sc->mem_cgroup, zone, idx, scanned);
+	}
+}
+
+static void
+update_rotated(struct scan_control *sc, struct zone *zone, int idx,
+    unsigned long rotated)
+{
+
+	if (scan_global_lru(sc)) {
+		zone->recent_rotated[idx] += rotated;
+	} else {
+		mem_cgroup_update_rotated(sc->mem_cgroup, zone, idx, rotated);
+	}
+}
+
 /**
  * isolate_lru_page - tries to isolate a page from its LRU list
  * @page: page to isolate from its LRU list
@@ -1075,11 +1099,11 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 
 		if (scan_global_lru(sc)) {
 			zone->pages_scanned += nr_scan;
-			zone->recent_scanned[0] += count[LRU_INACTIVE_ANON];
-			zone->recent_scanned[0] += count[LRU_ACTIVE_ANON];
-			zone->recent_scanned[1] += count[LRU_INACTIVE_FILE];
-			zone->recent_scanned[1] += count[LRU_ACTIVE_FILE];
 		}
+		update_scanned(sc, zone, 0,
+		    count[LRU_INACTIVE_ANON] + count[LRU_ACTIVE_ANON]);
+		update_scanned(sc, zone, 1,
+		    count[LRU_INACTIVE_FILE] + count[LRU_ACTIVE_FILE]);
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
@@ -1138,9 +1162,10 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			lru = page_lru(page);
 			add_page_to_lru_list(zone, page, lru);
 			mem_cgroup_move_lists(page, lru);
-			if (PageActive(page) && scan_global_lru(sc)) {
+			if (PageActive(page)) {
 				int file = !!page_is_file_cache(page);
-				zone->recent_rotated[file]++;
+
+				update_rotated(sc, zone, file, 1);
 			}
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1218,8 +1243,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 */
 	if (scan_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
-		zone->recent_scanned[!!file] += pgmoved;
 	}
+	update_scanned(sc, zone, !!file, pgmoved);
 
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
@@ -1264,7 +1289,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * to the inactive list.  This helps balance scan pressure between
 	 * file and anonymous pages in get_scan_ratio.
 	 */
-	zone->recent_rotated[!!file] += pgmoved;
+	spin_lock_irq(&zone->lru_lock);
+	update_rotated(sc, zone, !!file, pgmoved);
 
 	/*
 	 * Now put the pages back on the appropriate [file or anon] inactive
@@ -1273,7 +1299,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
 	lru = LRU_BASE + file * LRU_FILE;
-	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -1367,15 +1392,12 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
 					unsigned long *percent)
 {
-	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
-
-	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
-		zone_page_state(zone, NR_INACTIVE_ANON);
-	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
-		zone_page_state(zone, NR_INACTIVE_FILE);
-	free  = zone_page_state(zone, NR_FREE_PAGES);
+	unsigned long *recent_scanned;
+	unsigned long *recent_rotated;
+	unsigned long anon, file;
+	spinlock_t *lock;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (nr_swap_pages <= 0) {
@@ -1384,36 +1406,56 @@ static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
 		return;
 	}
 
-	/* If we have very few page cache pages, force-scan anon pages. */
-	if (unlikely(file + free <= zone->pages_high)) {
-		percent[0] = 100;
-		percent[1] = 0;
-		return;
+	if (scan_global_lru(sc)) {
+		unsigned long free;
+
+		anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+			zone_page_state(zone, NR_INACTIVE_ANON);
+		file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+			zone_page_state(zone, NR_INACTIVE_FILE);
+		free  = zone_page_state(zone, NR_FREE_PAGES);
+
+		/*
+		 * If we have very few page cache pages, force-scan anon pages.
+		 */
+		if (unlikely(file + free <= zone->pages_high)) {
+			percent[0] = 100;
+			percent[1] = 0;
+			return;
+		}
+
+		/*
+		 * OK, so we have swap space and a fair amount of page cache
+		 * pages.  We use the recently rotated / recently scanned
+		 * ratios to determine how valuable each cache is.
+		 */
+		recent_scanned = zone->recent_scanned;
+		recent_rotated = zone->recent_rotated;
+		lock = &zone->lru_lock;
+	} else {
+		mem_cgroup_get_scan_param(sc->mem_cgroup, zone, &anon, &file,
+		    &recent_scanned, &recent_rotated, &lock);
 	}
 
 	/*
-         * OK, so we have swap space and a fair amount of page cache
-         * pages.  We use the recently rotated / recently scanned
-         * ratios to determine how valuable each cache is.
-         *
-         * Because workloads change over time (and to avoid overflow)
-         * we keep these statistics as a floating average, which ends
-         * up weighing recent references more than old ones.
-         *
-         * anon in [0], file in [1]
-         */
-	if (unlikely(zone->recent_scanned[0] > anon / 4)) {
-		spin_lock_irq(&zone->lru_lock);
-		zone->recent_scanned[0] /= 2;
-		zone->recent_rotated[0] /= 2;
-		spin_unlock_irq(&zone->lru_lock);
+	 * Because workloads change over time (and to avoid overflow)
+	 * we keep these statistics as a floating average, which ends
+	 * up weighing recent references more than old ones.
+	 *
+	 * anon in [0], file in [1]
+	 */
+	if (unlikely(recent_scanned[0] > anon / 4)) {
+		spin_lock_irq(lock);
+		recent_scanned[0] /= 2;
+		recent_rotated[0] /= 2;
+		spin_unlock_irq(lock);
 	}
 
-	if (unlikely(zone->recent_scanned[1] > file / 4)) {
-		spin_lock_irq(&zone->lru_lock);
-		zone->recent_scanned[1] /= 2;
-		zone->recent_rotated[1] /= 2;
-		spin_unlock_irq(&zone->lru_lock);
+	if (unlikely(recent_scanned[1] > file / 4)) {
+		spin_lock_irq(lock);
+		recent_scanned[1] /= 2;
+		recent_rotated[1] /= 2;
+		spin_unlock_irq(lock);
 	}
 
 	/*
@@ -1428,11 +1470,11 @@ static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
 	 * %anon = 100 * ----------- / ----------------- * IO cost
 	 *               anon + file      rotate_sum
 	 */
-	ap = (anon_prio + 1) * (zone->recent_scanned[0] + 1);
-	ap /= zone->recent_rotated[0] + 1;
+	ap = (anon_prio + 1) * (recent_scanned[0] + 1);
+	ap /= recent_rotated[0] + 1;
 
-	fp = (file_prio + 1) * (zone->recent_scanned[1] + 1);
-	fp /= zone->recent_rotated[1] + 1;
+	fp = (file_prio + 1) * (recent_scanned[1] + 1);
+	fp /= recent_rotated[1] + 1;
 
 	/* Normalize to percentages */
 	percent[0] = 100 * ap / (ap + fp + 1);
@@ -1455,10 +1497,10 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 	get_scan_ratio(zone, sc, percent);
 
 	for_each_evictable_lru(l) {
-		if (scan_global_lru(sc)) {
-			int file = is_file_lru(l);
-			int scan;
+		int file = is_file_lru(l);
+		unsigned long scan;
 
+		if (scan_global_lru(sc)) {
 			scan = zone_page_state(zone, NR_LRU_BASE + l);
 			if (priority) {
 				scan >>= priority;
@@ -1476,8 +1518,13 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 			 * but because memory controller hits its limit.
 			 * Don't modify zone reclaim related data.
 			 */
-			nr[l] = mem_cgroup_calc_reclaim(sc->mem_cgroup, zone,
+			scan = mem_cgroup_calc_reclaim(sc->mem_cgroup, zone,
 								priority, l);
+			if (priority) {
+				scan >>= priority;
+				scan = (scan * percent[file]) / 100;
+			}
+			nr[l] = scan;
 		}
 	}
 
@@ -1706,7 +1753,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.may_writepage = !laptop_mode,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
-		.swappiness = vm_swappiness,
+		.swappiness = mem_cgroup_swappiness(mem_cont),
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
