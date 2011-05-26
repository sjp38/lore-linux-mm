Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E15C6B0026
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:39:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6A9ED3EE0B6
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:39:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A7AE45DF26
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:39:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BE5145DF20
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:39:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AABEE08008
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:39:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB6DBE08002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:39:45 +0900 (JST)
Date: Thu, 26 May 2011 14:32:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 8/10] memcg: scan ratio calculation
Message-Id: <20110526143256.442603eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


==
This patch adds a function to calculate reclam/scan ratio.
By the recent scan. 
This wil be shown by memory.reclaim_stat interface in later patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    8 +-
 mm/memcontrol.c      |  137 +++++++++++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c          |    9 ++-
 3 files changed, 138 insertions(+), 16 deletions(-)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -73,7 +73,6 @@ static int really_do_swap_account __init
 #define do_swap_account		(0)
 #endif
 
-
 /*
  * Statistics for memory cgroup.
  */
@@ -215,6 +214,7 @@ static void mem_cgroup_oom_notify(struct
 static void mem_cgroup_reset_margin_to_limit(struct mem_cgroup *mem);
 static void mem_cgroup_update_margin_to_limit(struct mem_cgroup *mem);
 static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
+static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);
 
 /*
  * The memory controller data structure. The memory controller controls both
@@ -294,6 +294,12 @@ struct mem_cgroup {
 #define FAILED_TO_KEEP_MARGIN		(1) /* someone hit limit */
 #define ASYNC_WORKER_RUNNING		(2) /* a worker runs */
 #define ASYNC_WORKER_SHOULD_STOP	(3) /* worker thread should stop */
+
+	/* For calculating scan success ratio */
+	spinlock_t	scan_stat_lock;
+	unsigned long	scanned;
+	unsigned long	reclaimed;
+	unsigned long	next_scanratio_update;
 	/*
 	 * percpu counter.
 	 */
@@ -758,6 +764,7 @@ static void memcg_check_events(struct me
 		}
 		/* update margin-to-limit and run async reclaim if necessary */
 		if (__memcg_event_check(mem, MEM_CGROUP_TARGET_KEEP_MARGIN)) {
+			mem_cgroup_reflesh_scan_ratio(mem);
 			mem_cgroup_may_async_reclaim(mem);
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_KEEP_MARGIN);
@@ -1417,6 +1424,96 @@ unsigned int mem_cgroup_swappiness(struc
 	return memcg->swappiness;
 }
 
+static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
+				unsigned long scanned,
+				unsigned long reclaimed)
+{
+	unsigned long limit;
+
+	limit = res_counter_read_u64(&mem->res, RES_LIMIT) >> PAGE_SHIFT;
+	spin_lock(&mem->scan_stat_lock);
+	mem->scanned += scanned;
+	mem->reclaimed += reclaimed;
+	/* avoid overflow */
+	if (mem->scanned > limit) {
+		mem->scanned /= 2;
+		mem->reclaimed /= 2;
+	}
+	spin_unlock(&mem->scan_stat_lock);
+}
+
+/**
+ * mem_cgroup_update_scan_ratio
+ * @memcg: the memcg
+ * @root : root memcg of hierarchy walk.
+ * @scanned : scanned pages
+ * @reclaimed: reclaimed pages.
+ *
+ * record scan/reclaim ratio to the memcg both to a child and it's root
+ * mem cgroup, which is a reclaim target. This value is used for
+ * detect congestion and for determining sleep time at memory reclaim.
+ */
+
+static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
+				  struct mem_cgroup *root,
+				unsigned long scanned,
+				unsigned long reclaimed)
+{
+	__mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);
+	if (mem != root)
+		__mem_cgroup_update_scan_ratio(root, scanned, reclaimed);
+
+}
+
+/*
+ * Workload can be changed over time. This routine is for forgetting old
+ * information to some extent. This is triggered by event counter i.e.
+ * some amounts of pagein/pageout events and rate limited once per 1 min.
+ *
+ * By this, recent 1min information will be twice informative than old
+ * information.
+ */
+static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem)
+{
+	struct cgroup *parent;
+	/* Update all parent's information if they are old */
+	while (1) {
+		if (time_after(mem->next_scanratio_update, jiffies))
+			break;
+		mem->next_scanratio_update = jiffies + HZ*60;
+		spin_lock(&mem->scan_stat_lock);
+		mem->scanned /= 2;
+		mem->reclaimed /= 2;
+		spin_unlock(&mem->scan_stat_lock);
+		if (!mem->use_hierarchy)
+			break;
+		parent = mem->css.cgroup->parent;
+		if (!parent)
+			break;
+		mem = mem_cgroup_from_cont(parent);
+	}
+}
+
+/**
+ * mem_cgroup_scan_ratio:
+ * @mem: the mem cgroup
+ *
+ * Returns recent reclaim/scan ratio. If this is low, memory is filled by
+ * active pages(or dirty pages). If high, memory includes inactive, unneccesary
+ * files. This can be a hint for admins to show the limit is correct or not.
+ */
+static int mem_cgroup_scan_ratio(struct mem_cgroup *mem)
+{
+	int scan_success_ratio;
+
+	spin_lock(&mem->scan_stat_lock);
+	scan_success_ratio = mem->reclaimed * 100 / (mem->scanned + 1);
+	spin_unlock(&mem->scan_stat_lock);
+
+	return scan_success_ratio;
+}
+
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
@@ -1855,9 +1952,14 @@ static int mem_cgroup_hierarchical_recla
 			*total_scanned += nr_scanned;
 			mem_cgroup_soft_steal(victim, is_kswapd, ret);
 			mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
-		} else
+			mem_cgroup_update_scan_ratio(victim,
+					root_mem, nr_scanned, ret);
+		} else {
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-					noswap);
+					noswap, &nr_scanned);
+			mem_cgroup_update_scan_ratio(victim,
+					root_mem, nr_scanned, ret);
+		}
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3895,12 +3997,14 @@ static void mem_cgroup_stop_async_worker
  * someone tries to delete cgroup, stop reclaim.
  * If margin is big even after shrink memory, reschedule itself again.
  */
+
 static void mem_cgroup_async_shrink_worker(struct work_struct *work)
 {
 	struct delayed_work *dw = to_delayed_work(work);
-	struct mem_cgroup *mem;
-	int delay = 0;
+	struct mem_cgroup *mem, *victim;
 	long nr_to_reclaim;
+	unsigned long nr_scanned, nr_reclaimed;
+	int delay = 0;
 
 	mem = container_of(dw, struct mem_cgroup, async_work);
 
@@ -3910,12 +4014,22 @@ static void mem_cgroup_async_shrink_work
 
 	nr_to_reclaim = mem->margin_to_limit_pages - mem_cgroup_margin(mem);
 
-	if (nr_to_reclaim > 0)
-		mem_cgroup_shrink_rate_limited(mem, nr_to_reclaim);
-	else
+	if (nr_to_reclaim <= 0)
+		goto finish_scan;
+
+	/* select a memcg under hierarchy */
+	victim = mem_cgroup_select_get_victim(mem);
+	if (!victim)
 		goto finish_scan;
+
+	nr_reclaimed = mem_cgroup_shrink_rate_limited(victim, nr_to_reclaim,
+					&nr_scanned);
+	mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed);
+	css_put(&victim->css);
+
 	/* If margin is enough big, stop */
-	if (mem_cgroup_margin(mem) >= mem->margin_to_limit_pages)
+	nr_to_reclaim = mem->margin_to_limit_pages - mem_cgroup_margin(mem);
+	if (nr_to_reclaim <= 0)
 		goto finish_scan;
 	/* If someone tries to rmdir(), we should stop */
 	if (test_bit(ASYNC_WORKER_SHOULD_STOP, &mem->async_flags))
@@ -4083,12 +4197,14 @@ try_to_free:
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
 		int progress;
+		unsigned long nr_scanned;
 
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL, false);
+		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+						false, &nr_scanned);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -5315,6 +5431,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	spin_lock_init(&mem->update_margin_lock);
+	spin_lock_init(&mem->scan_stat_lock);
 	INIT_DELAYED_WORK(&mem->async_work, mem_cgroup_async_shrink_worker);
 	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
Index: memcg_async/include/linux/swap.h
===================================================================
--- memcg_async.orig/include/linux/swap.h
+++ memcg_async/include/linux/swap.h
@@ -252,13 +252,15 @@ static inline void lru_cache_add_file(st
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap);
+			  		gfp_t gfp_mask, bool noswap,
+					unsigned long *nr_scanned);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
-extern void mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
-				           unsigned long nr_to_reclaim);
+extern unsigned long mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
+				           unsigned long nr_to_reclaim,
+					unsigned long *nr_scanned);
 
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
Index: memcg_async/mm/vmscan.c
===================================================================
--- memcg_async.orig/mm/vmscan.c
+++ memcg_async/mm/vmscan.c
@@ -2221,7 +2221,8 @@ unsigned long mem_cgroup_shrink_node_zon
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
-					   bool noswap)
+					   bool noswap,
+					   unsigned long *nr_scanned)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
@@ -2258,12 +2259,14 @@ unsigned long try_to_free_mem_cgroup_pag
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
+	*nr_scanned = sc.nr_scanned;
 
 	return nr_reclaimed;
 }
 
-void mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
-				unsigned long nr_to_reclaim)
+unsigned long mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
+					unsigned long nr_to_reclaim,
+					unsigned long *nr_scanned)
 {
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
