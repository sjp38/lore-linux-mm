Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D8D706B0024
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:54:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6A4323EE0BB
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:54:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 40B1945DE8E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:54:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15EC245DE91
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:54:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 043D41DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:54:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC97EE78003
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:54:37 +0900 (JST)
Date: Fri, 20 May 2011 12:47:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 7/8] memcg static scan reclaim for asyncrhonous reclaim
Message-Id: <20110520124753.56730b37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Ostatic scan rate async memory reclaim for memcg.

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

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 
 include/linux/swap.h       |    2 
 mm/memcontrol.c            |    5 +
 mm/vmscan.c                |  171 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 179 insertions(+), 1 deletion(-)

Index: mmotm-May11/mm/vmscan.c
===================================================================
--- mmotm-May11.orig/mm/vmscan.c
+++ mmotm-May11/mm/vmscan.c
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
+	 * too much cpu consumption in a memcg. Adjust the scan count to fit
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
@@ -2257,6 +2282,147 @@ unsigned long try_to_free_mem_cgroup_pag
 
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
+static void shrink_mem_cgroup_node(int nid,
+		int priority, struct scan_control *sc)
+{
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
+		if (this_reclaimed >= sc->nr_to_reclaim)
+			break;
+		if (sc->scan_limit < this_scanned)
+			break;
+		if (need_resched())
+			break;
+	}
+	sc->nr_scanned = this_scanned;
+	sc->nr_reclaimed = this_reclaimed;
+	return;
+}
+
+#define MEMCG_ASYNCSCAN_LIMIT		(2048)
+
+bool mem_cgroup_shrink_static_scan(struct mem_cgroup *mem, long required)
+{
+	int nid, priority, noscan;
+	unsigned long total_scanned, total_reclaimed, reclaim_target;
+	struct scan_control sc = {
+		.gfp_mask      = GFP_HIGHUSER_MOVABLE,
+		.may_unmap     = 1,
+		.may_swap      = 1,
+		.order         = 0,
+		/* we don't writepage in our scan. but kick flusher threads */
+		.may_writepage = 0,
+	};
+	struct mem_cgroup *victim, *check_again;
+	bool congested = true;
+
+	total_scanned = 0;
+	total_reclaimed = 0;
+	reclaim_target = min(required, MEMCG_ASYNCSCAN_LIMIT/2L);
+	sc.swappiness = mem_cgroup_swappiness(mem);
+
+	noscan = 0;
+	check_again = NULL;
+
+	do {
+		victim = mem_cgroup_select_victim(mem);
+
+		if (!mem_cgroup_test_reclaimable(victim)) {
+			mem_cgroup_release_victim(victim);
+			/*
+			 * if selected a hopeless victim again, give up.
+		 	 */
+			if (check_again == victim)
+				goto out;
+			if (!check_again)
+				check_again = victim;
+		} else
+			check_again = NULL;
+	} while (check_again);
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
+	while ((total_scanned < MEMCG_ASYNCSCAN_LIMIT) &&
+		(total_reclaimed < reclaim_target)) {
+
+		/* select a node to scan */
+		nid = mem_cgroup_select_victim_node(victim);
+
+		sc.mem_cgroup = victim;
+		sc.nr_scanned = 0;
+		sc.scan_limit = MEMCG_ASYNCSCAN_LIMIT - total_scanned;
+		sc.nr_reclaimed = 0;
+		sc.nr_to_reclaim = reclaim_target - total_reclaimed;
+		shrink_mem_cgroup_node(nid, priority, &sc);
+		if (sc.nr_scanned) {
+			total_scanned += sc.nr_scanned;
+			total_reclaimed += sc.nr_reclaimed;
+			noscan = 0;
+		} else
+			noscan++;
+		mem_cgroup_release_victim(victim);
+		/* ok, check condition */
+		if (total_scanned > total_reclaimed * 2)
+			wakeup_flusher_threads(sc.nr_scanned);
+
+		if (mem_cgroup_async_should_stop(mem))
+			break;
+		/* If memory reclaim seems heavy, return that we're congested */
+		if (total_scanned > MEMCG_ASYNCSCAN_LIMIT/4 &&
+		    total_scanned > total_reclaimed*8)
+			break;
+		/*
+		 * The whole system is busy or some status update
+		 * is not synched. It's better to wait for a while.
+		 */
+		if ((noscan > 1) || (need_resched()))
+			break;
+		/* ok, we can do deeper scanning. */
+		priority--;
+	}
+	current->flags &= ~PF_SWAPWRITE;
+	/*
+	 * If we successfully freed the half of target, report that
+	 * memory reclaim went smoothly.
+	 */
+	if (total_reclaimed > reclaim_target/2)
+		congested = false;
+out:
+	return congested;
+}
 #endif
 
 /*
@@ -2380,6 +2546,7 @@ static unsigned long balance_pgdat(pg_da
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2839,6 +3006,7 @@ unsigned long shrink_all_memory(unsigned
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
 		.order = 0,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3026,6 +3194,7 @@ static int __zone_reclaim(struct zone *z
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
+		.scan_limit = ULONG_MAX,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -3647,6 +3647,11 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+bool mem_cgroup_async_should_stop(struct mem_cgroup *mem)
+{
+	return res_counter_margin(&mem->res) >= MEMCG_ASYNC_MARGIN;
+}
+
 static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
 {
 	if (!test_bit(USE_AUTO_ASYNC, &mem->async_flags))
Index: mmotm-May11/include/linux/memcontrol.h
===================================================================
--- mmotm-May11.orig/include/linux/memcontrol.h
+++ mmotm-May11/include/linux/memcontrol.h
@@ -124,6 +124,8 @@ extern void mem_cgroup_print_oom_info(st
 					struct task_struct *p);
 struct mem_cgroup *mem_cgroup_select_victim(struct mem_cgroup *mem);
 void mem_cgroup_release_victim(struct mem_cgroup *mem);
+bool mem_cgroup_async_should_stop(struct mem_cgroup *mem);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
Index: mmotm-May11/include/linux/swap.h
===================================================================
--- mmotm-May11.orig/include/linux/swap.h
+++ mmotm-May11/include/linux/swap.h
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
