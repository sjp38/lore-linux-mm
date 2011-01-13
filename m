Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7547E6B00ED
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:04:42 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 4/5] Per cgroup background reclaim.
Date: Thu, 13 Jan 2011 14:00:34 -0800
Message-Id: <1294956035-12081-5-git-send-email-yinghan@google.com>
In-Reply-To: <1294956035-12081-1-git-send-email-yinghan@google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The current implementation of memcg only supports direct reclaim and this
patch adds the support for background reclaim. Per cgroup background reclaim
is needed which spreads out the memory pressure over longer period of time
and smoothes out the system performance.

There is a kswapd kernel thread for each memory node. We add a different kswapd
for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
field of a kswapd descriptor.

The kswapd() function now is shared between global and per cgroup kswapd thread.
It is passed in with the kswapd descriptor which contains the information of
either node or cgroup. Then the new function balance_mem_cgroup_pgdat is invoked
if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs a
priority loop similar to global reclaim. In each iteration it invokes
balance_pgdat_node for all nodes on the system, which is a new function performs
background reclaim per node. A fairness mechanism is implemented to remember the
last node it was reclaiming from and always start at the next one. After reclaiming
each node, it checks mem_cgroup_watermark_ok() and breaks the priority loop if
returns true. A per memcg zone will be marked as "unreclaimable" if the scanning
rate is much greater than the reclaiming rate on the per cgroup LRU. The bit is
cleared when there is a page charged to the cgroup being freed. Kswapd breaks the
priority loop if all the zones are marked as "unreclaimable".

Change log v2...v1:
1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
2. remove checking the wmark from per-page charging. now it checks the wmark
periodically based on the event counter.
3. move the per-cgroup per-zone clear_unreclaimable into uncharge stage.
4. shared the kswapd_run/kswapd_stop for per-cgroup and global background
reclaim.
5. name the per-cgroup memcg as "memcg-id" (css->id). And the global kswapd
keeps the same name.
6. fix a race on kswapd_stop while the per-memcg-per-zone info could be accessed
after freeing.
7. add the fairness in zonelist where memcg remember the last zone reclaimed
from.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   37 ++++++
 include/linux/swap.h       |    4 +-
 mm/memcontrol.c            |  192 ++++++++++++++++++++++++++++-
 mm/vmscan.c                |  298 ++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 504 insertions(+), 27 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 80a605f..69c6e41 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -25,6 +25,7 @@ struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+struct kswapd;
 
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
@@ -94,6 +95,12 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
+extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
+				  struct kswapd *kswapd_p);
+extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
+extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
+extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
+					nodemask_t *nodes);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
@@ -166,6 +173,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
+void mem_cgroup_clear_unreclaimable(struct page_cgroup *pc);
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
+					unsigned long nr_scanned);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -361,6 +374,25 @@ static inline unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
 	return -ENOSYS;
 }
 
+static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
+						struct zone *zone,
+						unsigned long nr_scanned)
+{
+}
+
+static inline void mem_cgroup_clear_unreclaimable(struct page *page,
+							struct zone *zone)
+{
+}
+static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
+		struct zone *zone)
+{
+}
+static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
+						struct zone *zone)
+{
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
@@ -374,6 +406,11 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
 	return 0;
 }
 
+static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
+								int zid)
+{
+	return false;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 52122fa..b6b5cbb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -292,8 +292,8 @@ static inline void scan_unevictable_unregister_node(struct node *node)
 }
 #endif
 
-extern int kswapd_run(int nid);
-extern void kswapd_stop(int nid);
+extern int kswapd_run(int nid, struct mem_cgroup *mem);
+extern void kswapd_stop(int nid, struct mem_cgroup *mem);
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ef26a7..e716ece 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -48,6 +48,8 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/kthread.h>
+
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -75,6 +77,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
  */
 #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
 #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
+#define WMARK_EVENTS_THRESH (10) /* once in 1024 */
 
 /*
  * Statistics for memory cgroup.
@@ -131,7 +134,10 @@ struct mem_cgroup_per_zone {
 	bool			on_tree;
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
+	unsigned long		pages_scanned;	/* since last reclaim */
+	int			all_unreclaimable;	/* All pages pinned */
 };
+
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
@@ -289,8 +295,16 @@ struct mem_cgroup {
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
 
+	/*
+	 * per cgroup background reclaim.
+	 */
 	wait_queue_head_t *kswapd_wait;
 	unsigned long min_free_kbytes;
+
+	/* While doing per cgroup background reclaim, we cache the
+	 * last node we reclaimed from
+	 */
+	int last_scanned_node;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -380,6 +394,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
+static void wake_memcg_kswapd(struct mem_cgroup *mem);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -568,6 +583,12 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 	return mz;
 }
 
+static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
+{
+	if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
+		wake_memcg_kswapd(mem);
+}
+
 /*
  * Implementation Note: reading percpu statistics for memcg.
  *
@@ -692,6 +713,8 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 		mem_cgroup_threshold(mem);
 		if (unlikely(__memcg_event_check(mem, SOFTLIMIT_EVENTS_THRESH)))
 			mem_cgroup_update_tree(mem, page);
+		if (unlikely(__memcg_event_check(mem, WMARK_EVENTS_THRESH)))
+			mem_cgroup_check_wmark(mem);
 	}
 }
 
@@ -1121,6 +1144,95 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return &mz->reclaim_stat;
 }
 
+static unsigned long mem_cgroup_zone_reclaimable_pages(
+						struct mem_cgroup_per_zone *mz)
+{
+	int nr;
+	nr = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
+		MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) +
+			MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+
+	return nr;
+}
+
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
+						unsigned long nr_scanned)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		mz->pages_scanned += nr_scanned;
+}
+
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+
+	if (!mem)
+		return 0;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		return mz->pages_scanned <
+				mem_cgroup_zone_reclaimable_pages(mz) * 6;
+	return 0;
+}
+
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return false;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		return mz->all_unreclaimable;
+
+	return false;
+}
+
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		mz->all_unreclaimable = 1;
+}
+
+void mem_cgroup_clear_unreclaimable(struct page_cgroup *pc)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+
+	if (!pc)
+		return;
+
+	mz = page_cgroup_zoneinfo(pc);
+	if (mz) {
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = 0;
+	}
+
+	return;
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -1773,6 +1885,34 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 }
 
 /*
+ * Visit the first node after the last_scanned_node of @mem and use that to
+ * reclaim free pages from.
+ */
+int
+mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t *nodes)
+{
+	int next_nid;
+	int last_scanned;
+
+	last_scanned = mem->last_scanned_node;
+
+	/* Initial stage and start from node0 */
+	if (last_scanned == -1)
+		next_nid = 0;
+	else
+		next_nid = next_node(last_scanned, *nodes);
+
+	if (next_nid == MAX_NUMNODES)
+		next_nid = first_node(*nodes);
+
+	spin_lock(&mem->reclaim_param_lock);
+	mem->last_scanned_node = next_nid;
+	spin_unlock(&mem->reclaim_param_lock);
+
+	return next_nid;
+}
+
+/*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
  */
@@ -2955,6 +3095,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 * special functions.
 	 */
 
+	mem_cgroup_clear_unreclaimable(pc);
 	unlock_page_cgroup(pc);
 	/*
 	 * even after unlock, we have mem->res.usage here and this memcg
@@ -3377,7 +3518,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
-  		if (curusage >= oldusage)
+		if (curusage >= oldusage)
 			retry_count--;
 		else
 			oldusage = curusage;
@@ -3385,6 +3526,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
+	if (!mem_cgroup_is_root(memcg) && !memcg->kswapd_wait)
+		kswapd_run(0, memcg);
+
 	return ret;
 }
 
@@ -4747,6 +4891,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = 0;
 	}
 	return 0;
 }
@@ -4799,6 +4945,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	kswapd_stop(0, mem);
 	mem_cgroup_remove_from_trees(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
@@ -4867,6 +5014,48 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
 	return ret;
 }
 
+int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *kswapd_p)
+{
+	if (!mem || !kswapd_p)
+		return 0;
+
+	mem->kswapd_wait = &kswapd_p->kswapd_wait;
+	kswapd_p->kswapd_mem = mem;
+
+	return css_id(&mem->css);
+}
+
+wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return NULL;
+
+	return mem->kswapd_wait;
+}
+
+int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return -1;
+
+	return mem->last_scanned_node;
+}
+
+static void wake_memcg_kswapd(struct mem_cgroup *mem)
+{
+	wait_queue_head_t *wait;
+
+	if (!mem)
+		return;
+
+	wait = mem->kswapd_wait;
+
+	if (!waitqueue_active(wait))
+		return;
+
+	wake_up_interruptible(wait);
+}
+
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
@@ -4942,6 +5131,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->last_scanned_node = -1;
 	spin_lock_init(&mem->reclaim_param_lock);
 	INIT_LIST_HEAD(&mem->oom_notify);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a53d91d..34f6165 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -46,6 +46,8 @@
 
 #include <linux/swapops.h>
 
+#include <linux/res_counter.h>
+
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -98,6 +100,8 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
+
+	int priority;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -1385,6 +1389,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, sc->mem_cgroup,
 			0, file);
+
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
+
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
@@ -1504,6 +1511,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
@@ -2127,11 +2135,19 @@ static int sleeping_prematurely(struct kswapd *kswapd, int order,
 {
 	int i;
 	pg_data_t *pgdat = kswapd->kswapd_pgdat;
+	struct mem_cgroup *mem = kswapd->kswapd_mem;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return 1;
 
+	/* If after HZ/10, the cgroup is below the high wmark, it's premature */
+	if (mem) {
+		if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH))
+			return 1;
+		return 0;
+	}
+
 	/* If after HZ/10, a zone is below the high mark, it's premature */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
@@ -2370,6 +2386,212 @@ out:
 	return sc.nr_reclaimed;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * The function is used for per-memcg LRU. It scanns all the zones of the
+ * node and returns the nr_scanned and nr_reclaimed.
+ */
+static void balance_pgdat_node(pg_data_t *pgdat, int order,
+					struct scan_control *sc)
+{
+	int i, end_zone;
+	unsigned long total_scanned;
+	struct mem_cgroup *mem_cont = sc->mem_cgroup;
+	int priority = sc->priority;
+	int nid = pgdat->node_id;
+
+	/*
+	 * Scan in the highmem->dma direction for the highest
+	 * zone which needs scanning
+	 */
+	for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
+
+		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
+				priority != DEF_PRIORITY)
+			continue;
+		/*
+		 * Do some background aging of the anon list, to give
+		 * pages a chance to be referenced before reclaiming.
+		 */
+		if (inactive_anon_is_low(zone, sc))
+			shrink_active_list(SWAP_CLUSTER_MAX, zone,
+							sc, priority, 0);
+
+		end_zone = i;
+		goto scan;
+	}
+	return;
+
+scan:
+	total_scanned = 0;
+	/*
+	 * Now scan the zone in the dma->highmem direction, stopping
+	 * at the last zone which needs scanning.
+	 *
+	 * We do this because the page allocator works in the opposite
+	 * direction.  This prevents the page allocator from allocating
+	 * pages behind kswapd's direction of progress, which would
+	 * cause too much scanning of the lower zones.
+	 */
+	for (i = 0; i <= end_zone; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
+
+		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
+			priority != DEF_PRIORITY)
+			continue;
+
+		sc->nr_scanned = 0;
+		shrink_zone(priority, zone, sc);
+		total_scanned += sc->nr_scanned;
+
+		if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
+			continue;
+
+		if (!mem_cgroup_zone_reclaimable(mem_cont, nid, i))
+			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
+
+		/*
+		 * If we've done a decent amount of scanning and
+		 * the reclaim ratio is low, start doing writepage
+		 * even in laptop mode
+		 */
+		if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
+		    total_scanned > sc->nr_reclaimed + sc->nr_reclaimed / 2) {
+			sc->may_writepage = 1;
+		}
+	}
+
+	sc->nr_scanned = total_scanned;
+	return;
+}
+
+/*
+ * Per cgroup background reclaim.
+ * TODO: Take off the order since memcg always do order 0
+ */
+static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
+					      int order)
+{
+	int i, nid;
+	int start_node;
+	int priority;
+	int wmark_ok;
+	int loop = 0;
+	pg_data_t *pgdat;
+	nodemask_t do_nodes;
+	unsigned long total_scanned = 0;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.nr_to_reclaim = ULONG_MAX,
+		.swappiness = vm_swappiness,
+		.order = order,
+		.mem_cgroup = mem_cont,
+	};
+
+loop_again:
+	do_nodes = NODE_MASK_NONE;
+	sc.may_writepage = !laptop_mode;
+	sc.nr_reclaimed = 0;
+	total_scanned = 0;
+
+	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+		sc.priority = priority;
+		wmark_ok = 0;
+		loop = 0;
+
+		/* The swap token gets in the way of swapout... */
+		if (!priority)
+			disable_swap_token();
+
+		if (priority == DEF_PRIORITY)
+			do_nodes = node_states[N_ONLINE];
+
+		while (1) {
+			nid = mem_cgroup_select_victim_node(mem_cont,
+							&do_nodes);
+
+			/* Indicate we have cycled the nodelist once
+			 * TODO: we might add MAX_RECLAIM_LOOP for preventing
+			 * kswapd burning cpu cycles.
+			 */
+			if (loop == 0) {
+				start_node = nid;
+				loop++;
+			} else if (nid == start_node)
+				break;
+
+			pgdat = NODE_DATA(nid);
+			balance_pgdat_node(pgdat, order, &sc);
+			total_scanned += sc.nr_scanned;
+
+			/* Set the node which has at least
+			 * one reclaimable zone
+			 */
+			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+				struct zone *zone = pgdat->node_zones + i;
+
+				if (!populated_zone(zone))
+					continue;
+
+				if (!mem_cgroup_mz_unreclaimable(mem_cont,
+								zone))
+					break;
+			}
+			if (i < 0)
+				node_clear(nid, do_nodes);
+
+			if (mem_cgroup_watermark_ok(mem_cont,
+							CHARGE_WMARK_HIGH)) {
+				wmark_ok = 1;
+				goto out;
+			}
+
+			if (nodes_empty(do_nodes)) {
+				wmark_ok = 1;
+				goto out;
+			}
+		}
+
+		/* All the nodes are unreclaimable, kswapd is done */
+		if (nodes_empty(do_nodes)) {
+			wmark_ok = 1;
+			goto out;
+		}
+
+		if (total_scanned && priority < DEF_PRIORITY - 2)
+			congestion_wait(WRITE, HZ/10);
+
+		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
+			break;
+	}
+out:
+	if (!wmark_ok) {
+		cond_resched();
+
+		try_to_freeze();
+
+		goto loop_again;
+	}
+
+	return sc.nr_reclaimed;
+}
+#else
+static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
+							int order)
+{
+	return 0;
+}
+#endif
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
@@ -2388,6 +2610,7 @@ int kswapd(void *p)
 	unsigned long order;
 	struct kswapd *kswapd_p = (struct kswapd *)p;
 	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
+	struct mem_cgroup *mem = kswapd_p->kswapd_mem;
 	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
@@ -2430,8 +2653,10 @@ int kswapd(void *p)
 		if (is_node_kswapd(kswapd_p)) {
 			new_order = pgdat->kswapd_max_order;
 			pgdat->kswapd_max_order = 0;
-		} else
+		} else {
+			/* mem cgroup does order 0 charging always */
 			new_order = 0;
+		}
 
 		if (order < new_order) {
 			/*
@@ -2492,8 +2717,12 @@ int kswapd(void *p)
 		 * after returning from the refrigerator
 		 */
 		if (!ret) {
-			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balance_pgdat(pgdat, order);
+			if (is_node_kswapd(kswapd_p)) {
+				trace_mm_vmscan_kswapd_wake(pgdat->node_id,
+								order);
+				balance_pgdat(pgdat, order);
+			} else
+				balance_mem_cgroup_pgdat(mem, order);
 		}
 	}
 	return 0;
@@ -2635,60 +2864,81 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 }
 
 /*
- * This kswapd start function will be called by init and node-hot-add.
- * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
+ * This kswapd start function will be called by init, node-hot-add and memcg
+ * limiting. On node-hot-add, kswapd will moved to proper cpus if cpus are
+ * hot-added.
  */
-int kswapd_run(int nid)
+int kswapd_run(int nid, struct mem_cgroup *mem)
 {
-	pg_data_t *pgdat = NODE_DATA(nid);
 	struct task_struct *thr;
+	pg_data_t *pgdat = NULL;
 	struct kswapd *kswapd_p;
+	static char name[TASK_COMM_LEN];
+	int memcg_id;
 	int ret = 0;
 
-	if (pgdat->kswapd_wait)
-		return 0;
+	if (!mem) {
+		pgdat = NODE_DATA(nid);
+		if (pgdat->kswapd_wait)
+			return ret;
+	}
 
 	kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
 	if (!kswapd_p)
 		return -ENOMEM;
 
 	init_waitqueue_head(&kswapd_p->kswapd_wait);
-	pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
-	kswapd_p->kswapd_pgdat = pgdat;
-	thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
+	if (!mem) {
+		pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
+		kswapd_p->kswapd_pgdat = pgdat;
+		snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
+	} else {
+		memcg_id = mem_cgroup_init_kswapd(mem, kswapd_p);
+		if (!memcg_id) {
+			kfree(kswapd_p);
+			return ret;
+		}
+		snprintf(name, TASK_COMM_LEN, "memcg_%d", memcg_id);
+	}
+
+	thr = kthread_run(kswapd, kswapd_p, name);
 	if (IS_ERR(thr)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
-		printk("Failed to start kswapd on node %d\n",nid);
 		ret = -1;
-	}
-	kswapd_p->kswapd_task = thr;
+	} else
+		kswapd_p->kswapd_task = thr;
 	return ret;
 }
 
 /*
  * Called by memory hotplug when all memory in a node is offlined.
+ * Also called by memcg when the cgroup is deleted.
  */
-void kswapd_stop(int nid)
+void kswapd_stop(int nid, struct mem_cgroup *mem)
 {
 	struct task_struct *thr = NULL;
 	struct kswapd *kswapd_p = NULL;
 	wait_queue_head_t *wait;
 
-	pg_data_t *pgdat = NODE_DATA(nid);
-
 	spin_lock(&kswapds_spinlock);
-	wait = pgdat->kswapd_wait;
+	if (!mem) {
+		pg_data_t *pgdat = NODE_DATA(nid);
+		wait = pgdat->kswapd_wait;
+	} else
+		wait = mem_cgroup_kswapd_wait(mem);
+
 	if (wait) {
 		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
 		thr = kswapd_p->kswapd_task;
 	}
 	spin_unlock(&kswapds_spinlock);
 
-	if (thr)
-		kthread_stop(thr);
-
-	kfree(kswapd_p);
+	if (kswapd_p) {
+		if (thr)
+			kthread_stop(thr);
+		kfree(kswapd_p);
+	}
 }
 
 static int __init kswapd_init(void)
@@ -2697,7 +2947,7 @@ static int __init kswapd_init(void)
 
 	swap_setup();
 	for_each_node_state(nid, N_HIGH_MEMORY)
- 		kswapd_run(nid);
+		kswapd_run(nid, NULL);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
