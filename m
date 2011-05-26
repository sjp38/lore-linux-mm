Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE5E6B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:41:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 550633EE0B5
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:41:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3764045DF20
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:41:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1430545DF1F
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:41:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A89E08004
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:41:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9913E08001
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:41:50 +0900 (JST)
Date: Thu, 26 May 2011 14:35:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 9/10] memcg: scan limited memory reclaim
Message-Id: <20110526143504.08b2c2c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


Better name is welcomed ;(

==
rate limited memory LRU scanning for memcg.

This patch implements a routine for asynchronous memory reclaim for memory
cgroup, which will be triggered when the usage is near to the limit.
This patch includes only code codes for memory freeing.

Asynchronous memory reclaim can be a help for reduce latency because
memory reclaim goes while an application need to wait or compute something.

To do memory reclaim in async, we need some thread or worker.
Unlike node or zones, memcg can be created on demand and there may be
a system with thousands of memcgs. So, the number of jobs for memcg
asynchronous memory reclaim can be big number in theory. So, node kswapd
codes doesn't fit well. And some scheduling on memcg layer will be
appreciated.

This patch implements a LRU scanning which the number of scan is limited.

When shrink_mem_cgroup_shrink_rate_limited() is called, it scans pages at most
MEMCG_STATIC_SCAN_LIMIT(2Mbytes) pages. By this, round-robin can be
implemented.

Changelog:
  - dropped most of un-explained heuristic codes.
  - added more comments.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 
 mm/memcontrol.c            |    4 -
 mm/vmscan.c                |  153 +++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 153 insertions(+), 6 deletions(-)

Index: memcg_async/mm/vmscan.c
===================================================================
--- memcg_async.orig/mm/vmscan.c
+++ memcg_async/mm/vmscan.c
@@ -106,6 +106,7 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
+	unsigned long scan_limit; /* async reclaim uses static scan rate */
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -1722,7 +1723,7 @@ static unsigned long shrink_list(enum lr
 static void get_scan_count(struct zone *zone, struct scan_control *sc,
 					unsigned long *nr, int priority)
 {
-	unsigned long anon, file, free;
+	unsigned long anon, file, free, total_scan;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
@@ -1812,6 +1813,8 @@ static void get_scan_count(struct zone *
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
+	total_scan = 0;
+
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
 		unsigned long scan;
@@ -1838,6 +1841,20 @@ out:
 				scan = SWAP_CLUSTER_MAX;
 		}
 		nr[l] = scan;
+		total_scan += nr[l];
+	}
+	/*
+	 * Asynchronous reclaim for memcg uses static scan rate for avoiding
+	 * too much cpu consumption in a memcg. Adjust the scan count to fit
+	 * into scan_limit.
+	 */
+	if (!scanning_global_lru(sc) && (total_scan > sc->scan_limit)) {
+		for_each_evictable_lru(l) {
+			if (nr[l] < SWAP_CLUSTER_MAX)
+				continue;
+			nr[l] = div64_u64(nr[l] * sc->scan_limit, total_scan);
+			nr[l] = max((unsigned long)SWAP_CLUSTER_MAX, nr[l]);
+		}
 	}
 }
 
@@ -1943,6 +1960,11 @@ restart:
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
 
@@ -2162,6 +2184,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.nodemask = nodemask,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2193,6 +2216,7 @@ unsigned long mem_cgroup_shrink_node_zon
 		.may_swap = !noswap,
 		.order = 0,
 		.mem_cgroup = mem,
+		.scan_limit = ULONG_MAX,
 	};
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2237,6 +2261,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2264,12 +2289,129 @@ unsigned long try_to_free_mem_cgroup_pag
 	return nr_reclaimed;
 }
 
-unsigned long mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
-					unsigned long nr_to_reclaim,
-					unsigned long *nr_scanned)
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
+static void shrink_mem_cgroup_node(int nid,
+		int priority, struct scan_control *sc)
 {
+	unsigned long this_scanned = 0;
+	unsigned long this_reclaimed = 0;
+	int i;
+
+	for (i = 0; i < NODE_DATA(nid)->nr_zones; i++) {
+		struct zone *zone = NODE_DATA(nid)->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
+		if (!mem_cgroup_zone_reclaimable_pages(sc->mem_cgroup, nid, i))
+			continue;
+		/* If recent scan didn't go good, do writepate */
+		sc->nr_scanned = 0;
+		sc->nr_reclaimed = 0;
+		shrink_zone(priority, zone, sc);
+		this_scanned += sc->nr_scanned;
+		this_reclaimed += sc->nr_reclaimed;
+		if ((sc->nr_to_reclaim < this_reclaimed) ||
+		    (sc->scan_limit < this_scanned))
+			break;
+		if (need_resched())
+			break;
+	}
+	sc->nr_scanned = this_scanned;
+	sc->nr_reclaimed = this_reclaimed;
+	return;
 }
 
+/**
+ * mem_cgroup_shrink_rate_limited
+ * @mem : the mem cgroup to be scanned.
+ * @required: number of required pages to be freed
+ * @nr_scanned: total number of scanned pages will be returned by this.
+ *
+ * This is a memory reclaim routine designed for background memory shrinking
+ * for memcg. Main idea is to do limited scan for implementing round-robin
+ * work per memcg. This routine scans MEMCG_SCAN_LIMIT of pages per iteration
+ * and reclaim MEMCG_SCAN_LIMIT/2 of pages per scan.
+ * The number of MEMCG_SCAN_LIMIT can be...arbitrary if it's enough small.
+ * Here, we scan 2M bytes of memory per iteration. If scan is not enough
+ * for the caller, it will call this again.
+ * This routine's memory scan success rate is reported to the caller and
+ * the caller will adjust the next call.
+ */
+#define MEMCG_SCAN_LIMIT	(2*1024*1024/PAGE_SIZE)
+
+unsigned long mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
+					     unsigned long required,
+					     unsigned long *nr_scanned)
+{
+	int nid, priority;
+	unsigned long total_scanned, total_reclaimed, reclaim_target;
+	struct scan_control sc = {
+		.gfp_mask      = GFP_HIGHUSER_MOVABLE,
+		.may_unmap     = 1,
+		.may_swap      = 1,
+		.order         = 0,
+		/* we don't writepage in our scan. but kick flusher threads */
+		.may_writepage = 0,
+	};
+
+	total_scanned = 0;
+	total_reclaimed = 0;
+	reclaim_target = min(required, MEMCG_SCAN_LIMIT/2L);
+	sc.swappiness = mem_cgroup_swappiness(mem);
+
+	current->flags |= PF_SWAPWRITE;
+	/*
+	 * We can use arbitrary priority for our run because we just scan
+	 * up to MEMCG_ASYNCSCAN_LIMIT and reclaim only the half of it.
+	 * But, we need to have early-give-up chance for avoid cpu hogging.
+	 * So, start from a small priority and increase it.
+	 */
+	priority = DEF_PRIORITY;
+
+	/* select a node to scan */
+	nid = mem_cgroup_select_victim_node(mem);
+	/* We do scan until scanning up to scan_limit. */
+	while ((total_scanned < MEMCG_SCAN_LIMIT) &&
+		(total_reclaimed < reclaim_target)) {
+
+		if (!mem_cgroup_has_reclaimable(mem))
+			break;
+		sc.mem_cgroup = mem;
+		sc.nr_scanned = 0;
+		sc.nr_reclaimed = 0;
+		sc.scan_limit = MEMCG_SCAN_LIMIT - total_scanned;
+		sc.nr_to_reclaim = reclaim_target - total_reclaimed;
+		shrink_mem_cgroup_node(nid, priority, &sc);
+		total_scanned += sc.nr_scanned;
+		total_reclaimed += sc.nr_reclaimed;
+		if (sc.nr_scanned < SWAP_CLUSTER_MAX) { /* no page ? */
+			nid = mem_cgroup_select_victim_node(mem);
+			priority = DEF_PRIORITY;
+		}
+		/*
+		 * If priority == 0, swappiness will be ignored.
+		 * we should avoid it.
+		 */
+		if (priority > 1)
+			priority--;
+	}
+	/* if scan rate was not good, wake flusher thread */
+	if (total_scanned > total_reclaimed * 2)
+		wakeup_flusher_threads(total_scanned - total_reclaimed);
+
+	current->flags &= ~PF_SWAPWRITE;
+	*nr_scanned = total_scanned;
+	return total_reclaimed;
+}
 #endif
 
 /*
@@ -2393,6 +2535,7 @@ static unsigned long balance_pgdat(pg_da
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2851,6 +2994,7 @@ unsigned long shrink_all_memory(unsigned
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
 		.order = 0,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3038,6 +3182,7 @@ static int __zone_reclaim(struct zone *z
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
Index: memcg_async/include/linux/memcontrol.h
===================================================================
--- memcg_async.orig/include/linux/memcontrol.h
+++ memcg_async/include/linux/memcontrol.h
@@ -123,6 +123,8 @@ mem_cgroup_get_reclaim_stat_from_page(st
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+extern bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -1783,7 +1783,7 @@ int mem_cgroup_select_victim_node(struct
  * For non-NUMA, this cheks reclaimable pages on zones because we don't
  * update scan_nodes.(see below)
  */
-static bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
+bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
 {
 	return !nodes_empty(memcg->scan_nodes);
 }
@@ -1799,7 +1799,7 @@ int mem_cgroup_select_victim_node(struct
 	return 0;
 }
 
-static bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
+bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
 {
 	unsigned long nr;
 	int zid;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
