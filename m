Subject: memcg swappiness (Re: memo: mem+swap controller)
In-Reply-To: Your message of "Fri, 01 Aug 2008 09:43:43 +0530"
	<48928D77.3090306@linux.vnet.ibm.com>
References: <48928D77.3090306@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080801050718.A13CE5A64@siro.lan>
Date: Fri,  1 Aug 2008 14:07:18 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

hi,

> >> I do intend to add the swappiness feature soon for control groups.
> >>
> > How does it work?
> > Does it affect global page reclaim?
> > 
> 
> We have a swappiness parameter in scan_control. Each control group indicates
> what it wants it swappiness to be when the control group is over it's limit and
> reclaim kicks in.

the following is an untested work-in-progress patch i happen to have.
i'd appreciate it if you take care of it.

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..7618944 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -47,6 +47,7 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fcfa8b4..e1eeb09 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -129,6 +129,7 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned int swappiness;	/* swappiness */
 	/*
 	 * statistics.
 	 */
@@ -437,14 +438,11 @@ void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
 long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru)
 {
-	long nr_pages;
 	int nid = zone->zone_pgdat->node_id;
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
-	nr_pages = MEM_CGROUP_ZSTAT(mz, lru);
-
-	return (nr_pages >> priority);
+	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -963,6 +961,24 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
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
@@ -995,8 +1011,21 @@ static struct cftype mem_cgroup_files[] = {
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
@@ -1072,6 +1101,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 			return ERR_PTR(-ENOMEM);
 	}
 
+	mem->swappiness = 60; /* XXX probably should inherit a value from
+				either parent cgroup or global vm_swappiness */
 	res_counter_init(&mem->res);
 
 	for_each_node_state(node, N_POSSIBLE)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6527e04..9f2ddbc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1364,15 +1364,10 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
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
+	unsigned long recent_scanned[2];
+	unsigned long recent_rotated[2];
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (nr_swap_pages <= 0) {
@@ -1381,36 +1376,59 @@ static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
 		return;
 	}
 
-	/* If we have very few page cache pages, force-scan anon pages. */
-	if (unlikely(file + free <= zone->pages_high)) {
-		percent[0] = 100;
-		percent[1] = 0;
-		return;
-	}
+	if (scan_global_lru(sc)) {
+		unsigned long anon, file, free;
 
-	/*
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
-	}
+		anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+			zone_page_state(zone, NR_INACTIVE_ANON);
+		file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+			zone_page_state(zone, NR_INACTIVE_FILE);
+		free  = zone_page_state(zone, NR_FREE_PAGES);
 
-	if (unlikely(zone->recent_scanned[1] > file / 4)) {
-		spin_lock_irq(&zone->lru_lock);
-		zone->recent_scanned[1] /= 2;
-		zone->recent_rotated[1] /= 2;
-		spin_unlock_irq(&zone->lru_lock);
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
+		 *
+		 * Because workloads change over time (and to avoid overflow)
+		 * we keep these statistics as a floating average, which ends
+		 * up weighing recent references more than old ones.
+		 *
+		 * anon in [0], file in [1]
+		 */
+		if (unlikely(zone->recent_scanned[0] > anon / 4)) {
+			spin_lock_irq(&zone->lru_lock);
+			zone->recent_scanned[0] /= 2;
+			zone->recent_rotated[0] /= 2;
+			spin_unlock_irq(&zone->lru_lock);
+		}
+
+		if (unlikely(zone->recent_scanned[1] > file / 4)) {
+			spin_lock_irq(&zone->lru_lock);
+			zone->recent_scanned[1] /= 2;
+			zone->recent_rotated[1] /= 2;
+			spin_unlock_irq(&zone->lru_lock);
+		}
+
+		recent_scanned[0] = zone->recent_scanned[0];
+		recent_scanned[1] = zone->recent_scanned[1];
+		recent_rotated[0] = zone->recent_rotated[0];
+		recent_rotated[1] = zone->recent_rotated[1];
+	} else {
+		/* XXX */
+		recent_scanned[0] = 0;
+		recent_scanned[1] = 0;
+		recent_rotated[0] = 0;
+		recent_rotated[1] = 0;
 	}
 
 	/*
@@ -1425,11 +1443,11 @@ static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
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
@@ -1452,9 +1470,10 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 	get_scan_ratio(zone, sc, percent);
 
 	for_each_evictable_lru(l) {
+		int file = is_file_lru(l);
+		unsigned long scan;
+
 		if (scan_global_lru(sc)) {
-			int file = is_file_lru(l);
-			int scan;
 			/*
 			 * Add one to nr_to_scan just to make sure that the
 			 * kernel will slowly sift through each list.
@@ -1476,8 +1495,13 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
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
+			nr[l] = scan + 1;
 		}
 	}
 
@@ -1704,7 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
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
