Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C509790010E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:20:00 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DE3FC3EE0BC
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:19:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BD245DF4A
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:19:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F37745DF47
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:19:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E616E08001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:19:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FDE31DB803C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:19:57 +0900 (JST)
Date: Tue, 10 May 2011 19:13:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/7] memcg : static scan for async reclaim
Message-Id: <20110510191317.65d45598.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


Major change is adding scan_limit to scan_control. I'll need to add more
comments in codes...

==
static scan rate async memory reclaim for memcg.

This patch implements a routine for asynchronous memory reclaim for memory
cgroup, which will be triggered when the usage is near to the limit.
This patch includes only code codes for memory freeing.

Asynchronous memory reclaim can be a help for reduce latency because
memory reclaim goes while an application need to wait or compute something.

To do memory reclaim in async, we need some thread or worker.
Unlike node or zones, memcg can be created on demand and there may be
a system with thousands of memcgs. So, the number of jobs for memcg
asynchronous memory reclaim can be big number in theory. So, node kswapd
codes doesn't fit well. And some scheduling on memcg layer will be appreciated.

This patch implements a static scan rate memory reclaim.
When shrink_mem_cgroup_static_scan() is called, it scans pages at most
MEMCG_STATIC_SCAN_LIMIT(2048) pages and returnes how memory shrinking
was hard. When the function returns false, the caller can assume memory
reclaim on the memcg seemed difficult and can add some scheduling delay
for the job.

Note:
  - I think this concept can be used for enhancing softlimit, too.
    But need more study.

Changes (since pilot version)
  - add scan_limit to scan_control
  - support memcg's hierarchy
  - removed nodemask on stack

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 
 include/linux/swap.h       |    2 
 mm/memcontrol.c            |    7 +
 mm/vmscan.c                |  164 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 173 insertions(+), 2 deletions(-)

Index: mmotm-May6/mm/vmscan.c
===================================================================
--- mmotm-May6.orig/mm/vmscan.c
+++ mmotm-May6/mm/vmscan.c
@@ -106,6 +106,7 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
+	unsigned long scan_limit; /* async reclaim uses static scan rate */
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -1717,7 +1718,7 @@ static unsigned long shrink_list(enum lr
 static void get_scan_count(struct zone *zone, struct scan_control *sc,
 					unsigned long *nr, int priority)
 {
-	unsigned long anon, file, free;
+	unsigned long anon, file, free, total_scan;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
@@ -1807,6 +1808,8 @@ static void get_scan_count(struct zone *
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
+	total_scan = 0;
+
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
 		unsigned long scan;
@@ -1833,6 +1836,20 @@ out:
 				scan = SWAP_CLUSTER_MAX;
 		}
 		nr[l] = scan;
+		total_scan += nr[l];
+	}
+	/*
+	 * Asynchronous reclaim for memcg uses static scan rate for avoiding
+	 * too much cpu consumption. Adjust the scan number to fit scan count
+	 * into scan_limit.
+	 */
+	if (total_scan > sc->scan_limit) {
+		for_each_evictable_lru(l) {
+			if (!nr[l] < SWAP_CLUSTER_MAX)
+				continue;
+			nr[l] = div64_u64(nr[l] * sc->scan_limit, total_scan);
+			nr[l] = max((unsigned long)SWAP_CLUSTER_MAX, nr[l]);
+		}
 	}
 }
 
@@ -1938,6 +1955,11 @@ restart:
 		 */
 		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
+		/*
+		 * static scan rate memory reclaim ?
+		 */
+		if (sc->nr_scanned > sc->scan_limit)
+			break;
 	}
 	sc->nr_reclaimed += nr_reclaimed;
 
@@ -2158,6 +2180,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.nodemask = nodemask,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2189,6 +2212,7 @@ unsigned long mem_cgroup_shrink_node_zon
 		.may_swap = !noswap,
 		.order = 0,
 		.mem_cgroup = mem,
+		.scan_limit = ULONG_MAX,
 	};
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2232,6 +2256,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2257,6 +2282,140 @@ unsigned long try_to_free_mem_cgroup_pag
 
 	return nr_reclaimed;
 }
+
+/*
+ * Routines for static scan rate memory reclaim for memory cgroup.
+ *
+ * Because asyncronous memory reclaim is served by the kernel as background
+ * service for reduce latency, we don't want to scan too much as priority=0
+ * scan of kswapd. We just scan MEMCG_ASYNCSCAN_LIMIT per iteration at most
+ * and frees MEMCG_ASYNCSCAN_LIMIT/2 of pages. Then, check our success rate
+ * and returns the information to the caller.
+ */
+
+static void shrink_mem_cgroup_node(int nid, int priority, struct scan_control *sc)
+{
+	unsigned long total_scanned = 0;
+	int i;
+
+	for (i = 0; i < NODE_DATA(nid)->nr_zones; i++) {
+		struct zone *zone = NODE_DATA(nid)->node_zones + i;
+		struct zone_reclaim_stat *zrs;
+		unsigned long scan;
+		unsigned long rotate;
+
+		if (!populated_zone(zone))
+			continue;
+		if (!mem_cgroup_zone_reclaimable_pages(sc->mem_cgroup, nid, i))
+			continue;
+		/* If recent scan didn't go good, do writepate */
+		zrs = get_reclaim_stat(zone, sc);
+		scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
+		rotate = zrs->recent_rotated[0] + zrs->recent_rotated[1];
+		if (rotate > scan/2)
+			sc->may_writepage = 1;
+
+		sc->nr_scanned = 0;
+		shrink_zone(priority, zone, sc);
+		total_scanned += sc->nr_scanned;
+		sc->may_writepage = 0;
+		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
+			break;
+	}
+	sc->nr_scanned = total_scanned;
+}
+
+#define MEMCG_ASYNCSCAN_LIMIT		(2048)
+
+bool mem_cgroup_shrink_static_scan(struct mem_cgroup *mem, long required)
+{
+	int nid, priority, next_prio, noscan, loop_check;
+	unsigned long total_scanned, progress;
+	struct scan_control sc = {
+		.gfp_mask      = GFP_HIGHUSER_MOVABLE,
+		.may_unmap     = 1,
+		.may_swap      = 1,
+		.order         = 0,
+	};
+	struct mem_cgroup *victim;
+	bool congested = true;
+
+	/* this param will be set per zone */
+	sc.may_writepage = 0;
+	sc.nr_reclaimed = 0;
+	total_scanned = 0;
+	progress = 0;
+	loop_check = 0;
+	sc.nr_to_reclaim = min(required, MEMCG_ASYNCSCAN_LIMIT/2L);
+	sc.swappiness = mem_cgroup_swappiness(mem);
+
+	current->flags |= PF_SWAPWRITE;
+	/*
+	 * We always scan static number of pages (unlike kswapd) with visiting
+	 * victim node/zones. This next_prio is used for emulate priority.
+	 */
+	next_prio = MEMCG_ASYNCSCAN_LIMIT/8;
+	priority = DEF_PRIORITY;
+	noscan = 0;
+	while ((total_scanned < MEMCG_ASYNCSCAN_LIMIT) &&
+		(sc.nr_to_reclaim > sc.nr_reclaimed)) {
+		/* select a victim from hierarchy */
+		victim = mem_cgroup_select_victim(mem);
+		/*
+		 * If a memcg was selected twice while we don't make any
+		 * progress, break and avoid loop.
+		 */
+		if (victim == mem){
+			if (loop_check && total_scanned == progress) {
+				mem_cgroup_release_victim(victim);
+				break;
+			}
+			progress = total_scanned;
+			loop_check = 1;
+		}
+
+		if (!mem_cgroup_test_reclaimable(victim)) {
+			mem_cgroup_release_victim(victim);
+			continue;
+		}
+		/* select a node to scan */
+		nid = mem_cgroup_select_victim_node(victim);
+
+		sc.mem_cgroup = victim;
+		sc.scan_limit = MEMCG_ASYNCSCAN_LIMIT - total_scanned;
+		shrink_mem_cgroup_node(nid, priority, &sc);
+		if (sc.nr_scanned) {
+			total_scanned += sc.nr_scanned;
+			noscan = 0;
+		} else
+			noscan++;
+		mem_cgroup_release_victim(victim);
+		if (mem_cgroup_async_should_stop(mem))
+			break;
+		if (total_scanned > next_prio) {
+			priority--;
+			next_prio <<= 1;
+		}
+		/* If memory reclaim seems heavy, return that we're congested */
+		if (total_scanned > MEMCG_ASYNCSCAN_LIMIT/4 &&
+		    total_scanned > sc.nr_reclaimed*8)
+			break;
+		/*
+		 * The whole system is busy or some status update
+		 * is not synched. It's better to wait for a while.
+		 */
+		if (noscan > 1)
+			break;
+	}
+	current->flags &= ~PF_SWAPWRITE;
+	/*
+	 * If we successfully freed the half of target, report that
+	 * memory reclaim went smoothly.
+	 */
+	if (sc.nr_reclaimed > sc.nr_to_reclaim/2)
+		congested = false;
+	return congested;
+}
 #endif
 
 /*
@@ -2380,6 +2539,7 @@ static unsigned long balance_pgdat(pg_da
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2839,6 +2999,7 @@ unsigned long shrink_all_memory(unsigned
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
 		.order = 0,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3026,6 +3187,7 @@ static int __zone_reclaim(struct zone *z
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1523,7 +1523,7 @@ u64 mem_cgroup_get_limit(struct mem_cgro
  * of the cgroup list, since we track last_scanned_child) of @mem and use
  * that to reclaim free pages from.
  */
-static struct mem_cgroup *
+struct mem_cgroup *
 mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 {
 	struct mem_cgroup *ret = NULL;
@@ -3631,6 +3631,11 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+bool mem_cgroup_async_should_stop(struct mem_cgroup *mem)
+{
+	return res_counter_margin(&mem->res) >= MEMCG_ASYNC_STOP_MARGIN;
+}
+
 static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
 {
 	if (!mem->need_async_reclaim)
Index: mmotm-May6/include/linux/memcontrol.h
===================================================================
--- mmotm-May6.orig/include/linux/memcontrol.h
+++ mmotm-May6/include/linux/memcontrol.h
@@ -124,6 +124,8 @@ extern void mem_cgroup_print_oom_info(st
 					struct task_struct *p);
 struct mem_cgroup *mem_cgroup_select_victim(struct mem_cgroup *mem);
 void mem_cgroup_release_victim(struct mem_cgroup *mem);
+bool mem_cgroup_async_should_stop(struct mem_cgroup *mem);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
Index: mmotm-May6/include/linux/swap.h
===================================================================
--- mmotm-May6.orig/include/linux/swap.h
+++ mmotm-May6/include/linux/swap.h
@@ -257,6 +257,8 @@ extern unsigned long mem_cgroup_shrink_n
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
+extern bool
+mem_cgroup_shrink_static_scan(struct mem_cgroup *mem, long required);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
