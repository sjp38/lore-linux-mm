Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 29B278D004F
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:26:41 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V7 7/9] Per-memcg background reclaim.
Date: Thu, 21 Apr 2011 21:24:18 -0700
Message-Id: <1303446260-21333-8-git-send-email-yinghan@google.com>
In-Reply-To: <1303446260-21333-1-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
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

changelog v7..v6:
1. change based on KAMAZAWA's patchset. Each memcg reclaims now reclaims
SWAP_CLUSTER_MAX of pages and putback the memcg to the tail of list.
memcg-kswapd will visit memcgs in round-robin manner and reduce usages.

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
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    9 +++
 mm/memcontrol.c            |   18 +++++++
 mm/vmscan.c                |  118 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 145 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7444738..39eade6 100644
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
index 4696fd8..41eaa62 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1105,6 +1105,24 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
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
index 63c557e..ba03a10 100644
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
@@ -2620,10 +2624,124 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
 	finish_wait(wait_h, &wait);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * The function is used for per-memcg LRU. It scanns all the zones of the
+ * node and returns the nr_scanned and nr_reclaimed.
+ */
+static void shrink_memcg_node(pg_data_t *pgdat, int order,
+				struct scan_control *sc)
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
+static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
+{
+	int i, nid, priority, loop;
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
+	do_nodes = NODE_MASK_NONE;
+	sc.may_writepage = !laptop_mode;
+	sc.nr_reclaimed = 0;
+	total_scanned = 0;
+
+	do_nodes = node_states[N_ONLINE];
+
+	for (priority = DEF_PRIORITY;
+		(priority >= 0) && (sc.nr_to_reclaim > sc.nr_reclaimed);
+		priority--) {
+
+		sc.priority = priority;
+		/* The swap token gets in the way of swapout... */
+		if (!priority)
+			disable_swap_token();
+
+		for (loop = num_online_nodes();
+			(loop > 0) && !nodes_empty(do_nodes);
+			loop--) {
+
+			nid = mem_cgroup_select_victim_node(mem_cont,
+							&do_nodes);
+
+			pgdat = NODE_DATA(nid);
+			shrink_memcg_node(pgdat, order, &sc);
+			total_scanned += sc.nr_scanned;
+
+			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+				struct zone *zone = pgdat->node_zones + i;
+
+				if (populated_zone(zone))
+					break;
+			}
+			if (i < 0)
+				node_clear(nid, do_nodes);
+
+			if (mem_cgroup_watermark_ok(mem_cont,
+						CHARGE_WMARK_HIGH))
+				goto out;
+		}
+
+		if (total_scanned && priority < DEF_PRIORITY - 2)
+			congestion_wait(WRITE, HZ/10);
+	}
+out:
+	return sc.nr_reclaimed;
+}
+#else
 static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
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
