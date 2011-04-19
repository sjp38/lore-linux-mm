Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6121C900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:58:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 06/10] Per-memcg background reclaim.
Date: Mon, 18 Apr 2011 20:57:42 -0700
Message-Id: <1303185466-2532-7-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This is the main loop of per-memcg background reclaim which is implemented in
function balance_mem_cgroup_pgdat().

The function performs a priority loop similar to global reclaim. During each
iteration it invokes balance_pgdat_node() for all nodes on the system, which
is another new function performs background reclaim per node. After reclaiming
each node, it checks mem_cgroup_watermark_ok() and breaks the priority loop if
it returns true.

changelog v6..v5:
1. add mem_cgroup_zone_reclaimable_pages()
2. fix some comment style.

changelog v5..v4:
1. remove duplicate check on nodes_empty()
2. add logic to check if the per-memcg lru is empty on the zone.

changelog v4..v3:
1. split the select_victim_node and zone_unreclaimable to a seperate patches
2. remove the logic tries to do zone balancing.

changelog v3..v2:
1. change mz->all_unreclaimable to be boolean.
2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg reclaim.
3. some more clean-up.

changelog v2..v1:
1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
2. shared the kswapd_run/kswapd_stop for per-memcg and global background
reclaim.
3. name the per-memcg memcg as "memcg-id" (css->id). And the global kswapd
keeps the same name.
4. fix a race on kswapd_stop while the per-memcg-per-zone info could be accessed
after freeing.
5. add the fairness in zonelist where memcg remember the last zone reclaimed
from.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    9 +++
 mm/memcontrol.c            |   18 +++++
 mm/vmscan.c                |  151 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 178 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d4ff7f2..a4747b0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -115,6 +115,8 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+						  struct zone *zone);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
@@ -311,6 +313,13 @@ mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 }
 
 static inline unsigned long
+mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+				    struct zone *zone)
+{
+	return 0;
+}
+
+static inline unsigned long
 mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
 			 enum lru_list lru)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 06fddd2..7490147 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1097,6 +1097,24 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 	return (active > inactive);
 }
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+						struct zone *zone)
+{
+	int nr;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
+	     MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
+		      MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
+
+	return nr;
+}
+
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0060d1e..2a5c734 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -47,6 +47,8 @@
 
 #include <linux/swapops.h>
 
+#include <linux/res_counter.h>
+
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -111,6 +113,8 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
+
+	int priority;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -2625,11 +2629,158 @@ out:
 	finish_wait(wait_h, &wait);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * The function is used for per-memcg LRU. It scanns all the zones of the
+ * node and returns the nr_scanned and nr_reclaimed.
+ */
+static void balance_pgdat_node(pg_data_t *pgdat, int order,
+					struct scan_control *sc)
+{
+	int i;
+	unsigned long total_scanned = 0;
+	struct mem_cgroup *mem_cont = sc->mem_cgroup;
+	int priority = sc->priority;
+
+	/*
+	 * This dma->highmem order is consistant with global reclaim.
+	 * We do this because the page allocator works in the opposite
+	 * direction although memcg user pages are mostly allocated at
+	 * highmem.
+	 */
+	for (i = 0; i < pgdat->nr_zones; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+		unsigned long scan = 0;
+
+		scan = mem_cgroup_zone_reclaimable_pages(mem_cont, zone);
+		if (!scan)
+			continue;
+
+		sc->nr_scanned = 0;
+		shrink_zone(priority, zone, sc);
+		total_scanned += sc->nr_scanned;
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
+	bool wmark_ok;
+	int loop;
+	pg_data_t *pgdat;
+	nodemask_t do_nodes;
+	unsigned long total_scanned;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
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
+		wmark_ok = false;
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
+			/*
+			 * Indicate we have cycled the nodelist once
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
+			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+				struct zone *zone = pgdat->node_zones + i;
+
+				if (!populated_zone(zone))
+					continue;
+			}
+			if (i < 0)
+				node_clear(nid, do_nodes);
+
+			if (mem_cgroup_watermark_ok(mem_cont,
+							CHARGE_WMARK_HIGH)) {
+				wmark_ok = true;
+				goto out;
+			}
+
+			if (nodes_empty(do_nodes)) {
+				wmark_ok = true;
+				goto out;
+			}
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
 static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
 							int order)
 {
 	return 0;
 }
+#endif
 
 /*
  * The background pageout daemon, started as a kernel thread
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
