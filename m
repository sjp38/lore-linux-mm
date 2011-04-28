Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C87A96B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:23:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 325D93EE0B6
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 097BC45DE4D
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E8B45DE52
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D243EE78002
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FE141DB802F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:15 +0900 (JST)
Received: from ml13.css.fujitsu.com (ml13 [127.0.0.1])
	by ml13.s.css.fujitsu.com (Postfix) with ESMTP id 4BF21FD0014
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:15 +0900 (JST)
Received: from WIN-WAU6SZB64RR (unknown [10.124.101.103])
	by ml13.s.css.fujitsu.com (Postfix) with SMTP id DF5CAFD0010
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:23:14 +0900 (JST)
Date: Thu, 28 Apr 2011 12:16:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-Id: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

sorry, I had wrong TO:...

Begin forwarded message:

Date: Thu, 28 Apr 2011 12:02:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
To: linux-mm@vger.kernel.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: [PATCH] memcg: add reclaim statistics accounting



Now, memory cgroup provides poor reclaim statistics per memcg. This
patch adds statistics for direct/soft reclaim as the number of
pages scans, the number of page freed by reclaim, the nanoseconds of
latency at reclaim. 

It's good to add statistics before we modify memcg/global reclaim, largely.
This patch refactors current soft limit status and add an unified update logic.

For example, After #cat 195Mfile > /dev/null under 100M limit.
	# cat /cgroup/memory/A/memory.stat
	....
	limit_freed 24592
	soft_steal 0
	limit_scan 43974
	soft_scan 0
	limit_latency 133837417

nearly 96M caches are freed. scanned twice. used 133ms.

Signed-off-by: KAMEZAWA Hiroyuki <kamaezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   13 ++++++--
 include/linux/memcontrol.h       |    1 
 include/linux/swap.h             |   10 ++----
 mm/memcontrol.c                  |   63 ++++++++++++++++++++++++---------------
 mm/vmscan.c                      |   25 +++++++++++++--
 5 files changed, 77 insertions(+), 35 deletions(-)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -106,6 +106,7 @@ extern void mem_cgroup_end_migration(str
 /*
  * For memory reclaim.
  */
+enum { RECLAIM_SCAN, RECLAIM_FREE, RECLAIM_LATENCY, NR_RECLAIM_INFO};
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -96,10 +96,6 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
 	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
 	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
-	MEM_CGROUP_EVENTS_SOFT_STEAL,	/* # of pages reclaimed from */
-					/* soft reclaim               */
-	MEM_CGROUP_EVENTS_SOFT_SCAN,	/* # of pages scanned from */
-					/* soft reclaim               */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -206,6 +202,9 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+/* memory reclaim contexts */
+enum { MEM_LIMIT, MEM_SOFT, NR_MEM_CONTEXTS};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -242,6 +241,7 @@ struct mem_cgroup {
 	nodemask_t	scan_nodes;
 	unsigned long   next_scan_node_update;
 #endif
+	atomic_long_t	reclaim_info[NR_MEM_CONTEXTS][NR_RECLAIM_INFO];
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -645,16 +645,6 @@ static void mem_cgroup_charge_statistics
 	preempt_enable();
 }
 
-static void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
-{
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL], val);
-}
-
-static void mem_cgroup_soft_scan(struct mem_cgroup *mem, int val)
-{
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN], val);
-}
-
 static unsigned long
 mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
 {
@@ -679,6 +669,15 @@ static unsigned long mem_cgroup_get_loca
 	return total;
 }
 
+void mem_cgroup_update_reclaim_info(struct mem_cgroup *mem, int context,
+				unsigned long *stats)
+{
+	int i;
+	for (i = 0; i < NR_RECLAIM_INFO; i++)
+		atomic_long_add(stats[i], &mem->reclaim_info[context][i]);
+}
+
+
 static bool __memcg_event_check(struct mem_cgroup *mem, int target)
 {
 	unsigned long val, next;
@@ -1560,6 +1559,8 @@ int mem_cgroup_select_victim_node(struct
 }
 #endif
 
+
+
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -1585,7 +1586,8 @@ static int mem_cgroup_hierarchical_recla
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
-	unsigned long nr_scanned;
+	unsigned long stats[NR_RECLAIM_INFO];
+	int context = (check_soft)? MEM_SOFT : MEM_LIMIT;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1631,13 +1633,12 @@ static int mem_cgroup_hierarchical_recla
 		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
 				noswap, get_swappiness(victim), zone,
-				&nr_scanned);
-			*total_scanned += nr_scanned;
-			mem_cgroup_soft_steal(victim, ret);
-			mem_cgroup_soft_scan(victim, nr_scanned);
+				stats);
+			*total_scanned += stats[RECLAIM_SCAN];
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, get_swappiness(victim));
+					noswap, get_swappiness(victim),stats);
+		mem_cgroup_update_reclaim_info(victim, context, stats);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3661,7 +3662,7 @@ try_to_free:
 			goto out;
 		}
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, get_swappiness(mem));
+					false, get_swappiness(mem), NULL);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -3929,8 +3930,12 @@ enum {
 	MCS_SWAP,
 	MCS_PGFAULT,
 	MCS_PGMAJFAULT,
+	MCS_LIMIT_FREED,
 	MCS_SOFT_STEAL,
+	MCS_LIMIT_SCAN,
 	MCS_SOFT_SCAN,
+	MCS_LIMIT_LATENCY,
+	MCS_SOFT_LATENCY,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3955,8 +3960,12 @@ struct {
 	{"swap", "total_swap"},
 	{"pgfault", "total_pgfault"},
 	{"pgmajfault", "total_pgmajfault"},
+	{"limit_freed", "total_limit_freed"},
 	{"soft_steal", "total_soft_steal"},
+	{"limit_scan", "total_limit_scan"},
 	{"soft_scan", "total_soft_scan"},
+	{"limit_latency", "total_limit_latency"},
+	{"soft_latency", "total_soft_latency"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3985,10 +3994,18 @@ mem_cgroup_get_local_stat(struct mem_cgr
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_STEAL);
+	val = atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECLAIM_FREE]);
+	s->stat[MCS_LIMIT_FREED] += val;
+	val = atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLAIM_FREE]);
 	s->stat[MCS_SOFT_STEAL] += val;
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_SCAN);
+	val = atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECLAIM_SCAN]);
+	s->stat[MCS_LIMIT_SCAN] += val;
+	val = atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLAIM_SCAN]);
 	s->stat[MCS_SOFT_SCAN] += val;
+	val = atomic_long_read(&mem->reclaim_info[MEM_LIMIT][RECLAIM_LATENCY]);
+	s->stat[MCS_LIMIT_LATENCY] += val;
+	val = atomic_long_read(&mem->reclaim_info[MEM_SOFT][RECLAIM_LATENCY]);
+	s->stat[MCS_SOFT_LATENCY] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT);
 	s->stat[MCS_PGFAULT] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -2156,7 +2156,7 @@ unsigned long mem_cgroup_shrink_node_zon
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
 						struct zone *zone,
-						unsigned long *nr_scanned)
+						unsigned long *stats)
 {
 	struct scan_control sc = {
 		.nr_scanned = 0,
@@ -2168,6 +2168,9 @@ unsigned long mem_cgroup_shrink_node_zon
 		.order = 0,
 		.mem_cgroup = mem,
 	};
+	u64 start, end;
+
+	start = sched_clock();
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2175,7 +2178,6 @@ unsigned long mem_cgroup_shrink_node_zon
 	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
 						      sc.may_writepage,
 						      sc.gfp_mask);
-
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -2185,20 +2187,26 @@ unsigned long mem_cgroup_shrink_node_zon
 	 */
 	shrink_zone(0, zone, &sc);
 
+	stats[RECLAIM_SCAN] = sc.nr_scanned;
+	stats[RECLAIM_FREE] = sc.nr_reclaimed;
+	end = sched_clock();
+	stats[RECLAIM_LATENCY] = end - start;
+
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
 					   bool noswap,
-					   unsigned int swappiness)
+					   unsigned int swappiness,
+					   unsigned long *stats)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
+	u64 end, start;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2209,6 +2217,8 @@ unsigned long try_to_free_mem_cgroup_pag
 		.mem_cgroup = mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
 	};
+
+	start = sched_clock();
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim
 	 * don't take care of from where we get pages . So, the node where
@@ -2226,6 +2236,13 @@ unsigned long try_to_free_mem_cgroup_pag
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
+	if (stats) {
+		stats[RECLAIM_SCAN] = sc.nr_scanned;
+		stats[RECLAIM_FREE] = sc.nr_reclaimed;
+		end = sched_clock();
+		stats[RECLAIM_LATENCY] = end - start;
+	}
+
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
 	return nr_reclaimed;
Index: memcg/Documentation/cgroups/memory.txt
===================================================================
--- memcg.orig/Documentation/cgroups/memory.txt
+++ memcg/Documentation/cgroups/memory.txt
@@ -387,8 +387,13 @@ pgpgout		- # of pages paged out (equival
 swap		- # of bytes of swap usage
 pgfault		- # of page faults.
 pgmajfault	- # of major page faults.
-soft_steal	- # of pages reclaimed from global hierarchical reclaim
-soft_scan	- # of pages scanned from global hierarchical reclaim
+limit_freed	- # of pages reclaimed by hitting limit.
+soft_steal	- # of pages reclaimed by kernel with hints of soft limit
+limit_scan	- # of pages scanned by hitting limit.
+soft_scan	- # of pages scanned by kernel with hints of soft limit
+limit_latency	- # of nanosecs epalsed at reclaiming by hitting limit
+soft_latency	- # of nanosecs epalsed at reclaiming by kernel with hits of
+		soft limit.
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -412,8 +417,12 @@ total_pgpgout		- sum of all children's "
 total_swap		- sum of all children's "swap"
 total_pgfault		- sum of all children's "pgfault"
 total_pgmajfault	- sum of all children's "pgmajfault"
+total_limit_freed	- sum of all children's "limit_freed"
 total_soft_steal	- sum of all children's "soft_steal"
+total_limit_scan	- sum of all children's "limit_scan"
 total_soft_scan		- sum of all children's "soft_scan"
+total_limit_latency	- sum of all children's "limit_latency"
+total_soft_latency	- sum of all children's "soft_latency"
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
Index: memcg/include/linux/swap.h
===================================================================
--- memcg.orig/include/linux/swap.h
+++ memcg/include/linux/swap.h
@@ -252,13 +252,11 @@ static inline void lru_cache_add_file(st
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap,
-						  unsigned int swappiness);
+		gfp_t gfp_mask, bool noswap, unsigned int swappiness,
+		  unsigned long *stats);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
-						struct zone *zone,
-						unsigned long *nr_scanned);
+		gfp_t gfp_mask, bool noswap, unsigned int swappiness,
+		struct zone *zone, unsigned long *stats);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
