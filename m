Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 657538D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:49:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E2D613EE0AE
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:49:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC79245DE51
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:49:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B0A7D45DE4E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:49:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A3C18E78002
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:49:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61B341DB803B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:49:55 +0900 (JST)
Date: Mon, 25 Apr 2011 18:43:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 8/7] memcg : reclaim statistics
Message-Id: <20110425184318.07e717ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

At tuning memcg background reclaim, cpu usage per memcg's work is an
interesting information because some amount of shared resource is used.
(i.e. background reclaim uses workqueue.) And other information as
pgscan and pgreclaim is important.

This patch shows them via memory.stat with cpu usage for direct reclaim
and softlimit reclaim and page scan statistics.


 # cat /cgroup/memory/A/memory.stat
 ....
 direct_elapsed_ns 0
 soft_elapsed_ns 0
 wmark_elapsed_ns 103566424
 direct_scanned 0
 soft_scanned 0
 wmark_scanned 29303
 direct_freed 0
 soft_freed 0
 wmark_freed 29290


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   18 +++++++++
 include/linux/memcontrol.h       |    6 +++
 include/linux/swap.h             |    7 +++
 mm/memcontrol.c                  |   77 +++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                      |   15 +++++++
 5 files changed, 120 insertions(+), 3 deletions(-)

Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -274,6 +274,17 @@ struct mem_cgroup {
 	bool			bgreclaim_resched;
 	struct delayed_work	bgreclaim_work;
 	/*
+	 * reclaim statistics (not per zone, node)
+	 */
+	spinlock_t		elapsed_lock;
+	u64			bgreclaim_elapsed;
+	u64			direct_elapsed;
+	u64			soft_elapsed;
+
+	u64			reclaim_scan[NR_RECLAIM_CONTEXTS];
+	u64			reclaim_freed[NR_RECLAIM_CONTEXTS];
+
+	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
@@ -1346,6 +1357,18 @@ void mem_cgroup_clear_unreclaimable(stru
 	return;
 }
 
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem,
+		int context, unsigned long scanned,
+		unsigned long freed)
+{
+	if (!mem)
+		return;
+	spin_lock(&mem->elapsed_lock);
+	mem->reclaim_scan[context] += scanned;
+	mem->reclaim_freed[context] += freed;
+	spin_unlock(&mem->elapsed_lock);
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -1692,6 +1715,7 @@ static int mem_cgroup_hierarchical_recla
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
 	unsigned long nr_scanned;
+	s64 start, end;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1735,16 +1759,27 @@ static int mem_cgroup_hierarchical_recla
 		}
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
+			start = sched_clock();
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
 				noswap, mem_cgroup_swappiness(victim), zone,
 				&nr_scanned);
 			*total_scanned += nr_scanned;
+			end = sched_clock();
+			spin_lock(&victim->elapsed_lock);
+			victim->soft_elapsed += end - start;
+			spin_unlock(&victim->elapsed_lock);
 			mem_cgroup_soft_steal(victim, ret);
 			mem_cgroup_soft_scan(victim, nr_scanned);
-		} else
+		} else {
+			start = sched_clock();
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap,
 						mem_cgroup_swappiness(victim));
+			end = sched_clock();
+			spin_lock(&victim->elapsed_lock);
+			victim->direct_elapsed += end - start;
+			spin_unlock(&victim->elapsed_lock);
+		}
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3702,15 +3737,22 @@ static void memcg_bgreclaim(struct work_
 	struct delayed_work *dw = to_delayed_work(work);
 	struct mem_cgroup *mem =
 		container_of(dw, struct mem_cgroup, bgreclaim_work);
-	int delay = 0;
+	int delay;
 	unsigned long long required, usage, hiwat;
 
+	delay = 0;
 	hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
 	usage = res_counter_read_u64(&mem->res, RES_USAGE);
 	required = usage - hiwat;
 	if (required >= 0)  {
+		u64 start, end;
 		required = ((usage - hiwat) >> PAGE_SHIFT) + 1;
+		start = sched_clock();
 		delay = shrink_mem_cgroup(mem, (long)required);
+		end = sched_clock();
+		spin_lock(&mem->elapsed_lock);
+		mem->bgreclaim_elapsed += end - start;
+		spin_unlock(&mem->elapsed_lock);
 	}
 	if (!mem->bgreclaim_resched  ||
 		mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
@@ -4152,6 +4194,15 @@ enum {
 	MCS_INACTIVE_FILE,
 	MCS_ACTIVE_FILE,
 	MCS_UNEVICTABLE,
+	MCS_DIRECT_ELAPSED,
+	MCS_SOFT_ELAPSED,
+	MCS_WMARK_ELAPSED,
+	MCS_DIRECT_SCANNED,
+	MCS_SOFT_SCANNED,
+	MCS_WMARK_SCANNED,
+	MCS_DIRECT_FREED,
+	MCS_SOFT_FREED,
+	MCS_WMARK_FREED,
 	NR_MCS_STAT,
 };
 
@@ -4177,7 +4228,16 @@ struct {
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
 	{"active_file", "total_active_file"},
-	{"unevictable", "total_unevictable"}
+	{"unevictable", "total_unevictable"},
+	{"direct_elapsed_ns", "total_direct_elapsed_ns"},
+	{"soft_elapsed_ns", "total_soft_elapsed_ns"},
+	{"wmark_elapsed_ns", "total_wmark_elapsed_ns"},
+	{"direct_scanned", "total_direct_scanned"},
+	{"soft_scanned", "total_soft_scanned"},
+	{"wmark_scanned", "total_wmark_scanned"},
+	{"direct_freed", "total_direct_freed"},
+	{"soft_freed", "total_soft_freed"},
+	{"wmark_freed", "total_wamrk_freed"}
 };
 
 
@@ -4185,6 +4245,7 @@ static void
 mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 {
 	s64 val;
+	int i;
 
 	/* per cpu stat */
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
@@ -4221,6 +4282,15 @@ mem_cgroup_get_local_stat(struct mem_cgr
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
 	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
+
+	/* reclaim stats */
+	s->stat[MCS_DIRECT_ELAPSED] += mem->direct_elapsed;
+	s->stat[MCS_SOFT_ELAPSED] += mem->soft_elapsed;
+	s->stat[MCS_WMARK_ELAPSED] += mem->bgreclaim_elapsed;
+	for (i = 0; i < NR_RECLAIM_CONTEXTS; i++) {
+		s->stat[i + MCS_DIRECT_SCANNED] += mem->reclaim_scan[i];
+		s->stat[i + MCS_DIRECT_FREED] += mem->reclaim_freed[i];
+	}
 }
 
 static void
@@ -4889,6 +4959,7 @@ static struct mem_cgroup *mem_cgroup_all
 		goto out_free;
 	spin_lock_init(&mem->pcp_counter_lock);
 	INIT_DELAYED_WORK(&mem->bgreclaim_work, memcg_bgreclaim);
+	spin_lock_init(&mem->elapsed_lock);
 	mem->bgreclaim_resched = true;
 	return mem;
 
Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -90,6 +90,8 @@ extern int mem_cgroup_select_victim_node
 					const nodemask_t *nodes);
 
 int shrink_mem_cgroup(struct mem_cgroup *mem, long required);
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,
+			unsigned long scanned, unsigned long freed);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
@@ -423,6 +425,10 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+void mem_cgroup_reclaim_statistics(struct mem_cgroup *mem, int context,
+				unsigned long scanned, unsigned long freed)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
Index: memcg/include/linux/swap.h
===================================================================
--- memcg.orig/include/linux/swap.h
+++ memcg/include/linux/swap.h
@@ -250,6 +250,13 @@ static inline void lru_cache_add_file(st
 #define ISOLATE_ACTIVE 1	/* Isolate active pages. */
 #define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
 
+/* context for memory reclaim.( comes from memory cgroup.) */
+enum {
+	RECLAIM_DIRECT,		/* under direct reclaim */
+	RECLAIM_KSWAPD,		/* under global kswapd's soft limit */
+	RECLAIM_WMARK,		/* under background reclaim by watermark */
+	NR_RECLAIM_CONTEXTS
+};
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -72,6 +72,9 @@ typedef unsigned __bitwise__ reclaim_mod
 #define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode_t)0x08u)
 #define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
 
+/* 3 reclaim contexts fro memcg statistics. */
+enum {DIRECT_RECLAIM, KSWAPD_RECLAIM, WMARK_RECLAIM};
+
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -107,6 +110,7 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
+	int	reclaim_context;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -2116,6 +2120,10 @@ out:
 	delayacct_freepages_end();
 	put_mems_allowed();
 
+	if (!scanning_global_lru(sc))
+		mem_cgroup_reclaim_statistics(sc->mem_cgroup,
+			sc->reclaim_context, total_scanned, sc->nr_reclaimed);
+
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
 
@@ -2178,6 +2186,7 @@ unsigned long mem_cgroup_shrink_node_zon
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
+		.reclaim_context = RECLAIM_KSWAPD,
 	};
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2198,6 +2207,8 @@ unsigned long mem_cgroup_shrink_node_zon
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
+	mem_cgroup_reclaim_statistics(sc.mem_cgroup,
+			sc.reclaim_context, sc.nr_scanned, sc.nr_reclaimed);
 	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
@@ -2217,6 +2228,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
+		.reclaim_context = RECLAIM_DIRECT,
 		.nodemask = NULL, /* we don't care the placement */
 	};
 
@@ -2384,6 +2396,7 @@ int shrink_mem_cgroup(struct mem_cgroup 
 		.may_swap = 1,
 		.order = 0,
 		.mem_cgroup = mem,
+		.reclaim_context = RECLAIM_WMARK,
 	};
 	/* writepage will be set later per zone */
 	sc.may_writepage = 0;
@@ -2434,6 +2447,8 @@ int shrink_mem_cgroup(struct mem_cgroup 
 	if (sc.nr_reclaimed > sc.nr_to_reclaim/2)
 		delay = 0;
 out:
+	mem_cgroup_reclaim_statistics(sc.mem_cgroup, sc.reclaim_context,
+			total_scanned, sc.nr_reclaimed);
 	current->flags &= ~PF_SWAPWRITE;
 	return delay;
 }
Index: memcg/Documentation/cgroups/memory.txt
===================================================================
--- memcg.orig/Documentation/cgroups/memory.txt
+++ memcg/Documentation/cgroups/memory.txt
@@ -398,6 +398,15 @@ active_anon	- # of bytes of anonymous an
 inactive_file	- # of bytes of file-backed memory on inactive LRU list.
 active_file	- # of bytes of file-backed memory on active LRU list.
 unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
+direct_elapsed_ns  - # of elapsed cpu time at hard limit reclaim (ns)
+soft_elapsed_ns  - # of elapsed cpu time at soft limit reclaim (ns)
+wmark_elapsed_ns  - # of elapsed cpu time at hi/low watermark reclaim (ns)
+direct_scanned	- # of page scans at hard limit reclaim
+soft_scanned	- # of page scans at soft limit reclaim
+wmark_scanned	- # of page scans at hi/low watermark reclaim
+direct_freed	- # of page freeing at hard limit reclaim
+soft_freed	- # of page freeing at soft limit reclaim
+wmark_freed	- # of page freeing at hi/low watermark reclaim
 
 # status considering hierarchy (see memory.use_hierarchy settings)
 
@@ -421,6 +430,15 @@ total_active_anon	- sum of all children'
 total_inactive_file	- sum of all children's "inactive_file"
 total_active_file	- sum of all children's "active_file"
 total_unevictable	- sum of all children's "unevictable"
+total_direct_elapsed_ns - sum of all children's "direct_elapsed_ns"
+total_soft_elapsed_ns	- sum of all children's "soft_elapsed_ns"
+total_wmark_elapsed_ns	- sum of all children's "wmark_elapsed_ns"
+total_direct_scanned	- sum of all children's "direct_scanned"
+total_soft_scanned	- sum of all children's "soft_scanned"
+total_wmark_scanned	- sum of all children's "wmark_scanned"
+total_direct_freed	- sum of all children's "direct_freed"
+total_soft_freed	- sum of all children's "soft_freed"
+total_wamrk_freed	- sum of all children's "wmark_freed"
 
 # The following additional stats are dependent on CONFIG_DEBUG_VM.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
