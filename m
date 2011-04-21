Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1FB8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:50:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E57D83EE0C0
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:50:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C580F45DE69
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA54E45DD74
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 985F71DB803C
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:50:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D7431DB8038
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:50:37 +0900 (JST)
Date: Thu, 21 Apr 2011 12:43:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3] memcg kswapd thread pool (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
Message-Id: <20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Ying, please take this just a hint, you don't need to implement this as is.
==
Now, memcg-kswapd is created per a cgroup. Considering there are users
who creates hundreds on cgroup on a system, it consumes too much
resources, memory, cputime.

This patch creates a thread pool for memcg-kswapd. All memcg which 
needs background recalim are linked to a list and memcg-kswapd
picks up a memcg from the list and run reclaim. This reclaimes
SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of
list. memcg-kswapd will visit memcgs in round-robin manner and
reduce usages.

This patch does

 - adds memcg-kswapd thread pool, the number of threads is now
   sqrt(num_of_cpus) + 1.
 - use unified kswapd_waitq for all memcgs.
 - refine memcg shrink codes in vmscan.c

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    5 
 include/linux/swap.h       |    7 -
 mm/memcontrol.c            |  174 +++++++++++++++++++++++----------
 mm/memory_hotplug.c        |    4 
 mm/page_alloc.c            |    1 
 mm/vmscan.c                |  237 ++++++++++++++++++---------------------------
 6 files changed, 232 insertions(+), 196 deletions(-)

Index: mmotm-Apr14/mm/memcontrol.c
===================================================================
--- mmotm-Apr14.orig/mm/memcontrol.c
+++ mmotm-Apr14/mm/memcontrol.c
@@ -49,6 +49,8 @@
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include "internal.h"
+#include <linux/kthread.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 
@@ -274,6 +276,12 @@ struct mem_cgroup {
 	 */
 	unsigned long 	move_charge_at_immigrate;
 	/*
+ 	 * memcg kswapd control stuff.
+ 	 */
+	atomic_t		kswapd_running; /* !=0 if a kswapd runs */
+	wait_queue_head_t	memcg_kswapd_end; /* for waiting the end*/
+	struct list_head	memcg_kswapd_wait_list;/* for shceduling */
+	/*
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu *stat;
@@ -296,7 +304,6 @@ struct mem_cgroup {
 	 */
 	int last_scanned_node;
 
-	wait_queue_head_t *kswapd_wait;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -380,6 +387,7 @@ static struct mem_cgroup *parent_mem_cgr
 static void drain_all_stock_async(void);
 
 static void wake_memcg_kswapd(struct mem_cgroup *mem);
+static void memcg_kswapd_stop(struct mem_cgroup *mem);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -916,9 +924,6 @@ static void setup_per_memcg_wmarks(struc
 
 		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
 		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
-
-		if (!mem_cgroup_is_root(mem) && !mem->kswapd_wait)
-			kswapd_run(0, mem);
 	}
 }
 
@@ -3729,6 +3734,7 @@ move_account:
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
+		memcg_kswapd_stop(mem);
 		ret = -EINTR;
 		if (signal_pending(current))
 			goto out;
@@ -4655,6 +4661,120 @@ static int mem_cgroup_oom_control_write(
 	return 0;
 }
 
+/*
+ * Controls for background memory reclam stuff.
+ */
+struct memcg_kswapd_work
+{
+	spinlock_t		lock;  /* lock for list */
+	struct list_head	list;  /* list of works. */
+	wait_queue_head_t	waitq;
+};
+
+struct memcg_kswapd_work	memcg_kswapd_control;
+
+static void wake_memcg_kswapd(struct mem_cgroup *mem)
+{
+	if (atomic_read(&mem->kswapd_running)) /* already running */
+		return;
+
+	spin_lock(&memcg_kswapd_control.lock);
+	if (list_empty(&mem->memcg_kswapd_wait_list))
+		list_add_tail(&mem->memcg_kswapd_wait_list,
+				&memcg_kswapd_control.list);
+	spin_unlock(&memcg_kswapd_control.lock);
+	wake_up(&memcg_kswapd_control.waitq);
+	return;
+}
+
+static void memcg_kswapd_wait_end(struct mem_cgroup *mem)
+{
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(&mem->memcg_kswapd_end, &wait, TASK_INTERRUPTIBLE);
+	if (atomic_read(&mem->kswapd_running))
+		schedule();
+	finish_wait(&mem->memcg_kswapd_end, &wait);
+}
+
+/* called at pre_destroy */
+static void memcg_kswapd_stop(struct mem_cgroup *mem)
+{
+	spin_lock(&memcg_kswapd_control.lock);
+	if (!list_empty(&mem->memcg_kswapd_wait_list))
+		list_del(&mem->memcg_kswapd_wait_list);
+	spin_unlock(&memcg_kswapd_control.lock);
+
+	memcg_kswapd_wait_end(mem);
+}
+
+struct mem_cgroup *mem_cgroup_get_shrink_target(void)
+{
+	struct mem_cgroup *mem;
+
+	spin_lock(&memcg_kswapd_control.lock);
+	rcu_read_lock();
+	do {
+		mem = NULL;
+		if (!list_empty(&memcg_kswapd_control.list)) {
+			mem = list_entry(memcg_kswapd_control.list.next,
+				 	struct mem_cgroup,
+				 	memcg_kswapd_wait_list);
+			list_del_init(&mem->memcg_kswapd_wait_list);
+		}
+	} while (mem && !css_tryget(&mem->css));
+	if (mem)
+		atomic_inc(&mem->kswapd_running);
+	rcu_read_unlock();
+	spin_unlock(&memcg_kswapd_control.lock);
+	return mem;
+}
+
+void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return;
+	atomic_dec(&mem->kswapd_running);
+	if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
+		spin_lock(&memcg_kswapd_control.lock);
+		if (list_empty(&mem->memcg_kswapd_wait_list)) {
+			list_add_tail(&mem->memcg_kswapd_wait_list,
+					&memcg_kswapd_control.list);
+		}
+		spin_unlock(&memcg_kswapd_control.lock);
+	}
+	wake_up_all(&mem->memcg_kswapd_end);
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+}
+
+bool mem_cgroup_kswapd_can_sleep(void)
+{
+	return list_empty(&memcg_kswapd_control.list);
+}
+
+wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
+{
+	return &memcg_kswapd_control.waitq;
+}
+
+static int __init memcg_kswapd_init(void)
+{
+
+	int i, nr_threads;
+
+	spin_lock_init(&memcg_kswapd_control.lock);
+	INIT_LIST_HEAD(&memcg_kswapd_control.list);
+	init_waitqueue_head(&memcg_kswapd_control.waitq);
+
+	nr_threads = int_sqrt(num_possible_cpus()) + 1;
+	for (i = 0; i < nr_threads; i++)
+		if (kswapd_run(0, i + 1) == -1)
+			break;
+	return 0;
+}
+module_init(memcg_kswapd_init);
+
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4935,33 +5055,6 @@ int mem_cgroup_watermark_ok(struct mem_c
 	return ret;
 }
 
-int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *kswapd_p)
-{
-	if (!mem || !kswapd_p)
-		return 0;
-
-	mem->kswapd_wait = &kswapd_p->kswapd_wait;
-	kswapd_p->kswapd_mem = mem;
-
-	return css_id(&mem->css);
-}
-
-void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)
-{
-	if (mem)
-		mem->kswapd_wait = NULL;
-
-	return;
-}
-
-wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
-{
-	if (!mem)
-		return NULL;
-
-	return mem->kswapd_wait;
-}
-
 int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
 {
 	if (!mem)
@@ -4970,22 +5063,6 @@ int mem_cgroup_last_scanned_node(struct 
 	return mem->last_scanned_node;
 }
 
-static inline
-void wake_memcg_kswapd(struct mem_cgroup *mem)
-{
-	wait_queue_head_t *wait;
-
-	if (!mem || !mem->high_wmark_distance)
-		return;
-
-	wait = mem->kswapd_wait;
-
-	if (!wait || !waitqueue_active(wait))
-		return;
-
-	wake_up_interruptible(wait);
-}
-
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
@@ -5069,6 +5146,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+	init_waitqueue_head(&mem->memcg_kswapd_end);
+	INIT_LIST_HEAD(&mem->memcg_kswapd_wait_list);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -5089,7 +5168,6 @@ static void mem_cgroup_destroy(struct cg
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
-	kswapd_stop(0, mem);
 	mem_cgroup_put(mem);
 }
 
Index: mmotm-Apr14/include/linux/swap.h
===================================================================
--- mmotm-Apr14.orig/include/linux/swap.h
+++ mmotm-Apr14/include/linux/swap.h
@@ -28,9 +28,8 @@ static inline int current_is_kswapd(void
 
 struct kswapd {
 	struct task_struct *kswapd_task;
-	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t *kswapd_wait;
 	pg_data_t *kswapd_pgdat;
-	struct mem_cgroup *kswapd_mem;
 };
 
 int kswapd(void *p);
@@ -307,8 +306,8 @@ static inline void scan_unevictable_unre
 }
 #endif
 
-extern int kswapd_run(int nid, struct mem_cgroup *mem);
-extern void kswapd_stop(int nid, struct mem_cgroup *mem);
+extern int kswapd_run(int nid, int id);
+extern void kswapd_stop(int nid);
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
Index: mmotm-Apr14/mm/page_alloc.c
===================================================================
--- mmotm-Apr14.orig/mm/page_alloc.c
+++ mmotm-Apr14/mm/page_alloc.c
@@ -4199,6 +4199,7 @@ static void __paginginit free_area_init_
 
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
+	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
Index: mmotm-Apr14/mm/vmscan.c
===================================================================
--- mmotm-Apr14.orig/mm/vmscan.c
+++ mmotm-Apr14/mm/vmscan.c
@@ -2256,7 +2256,7 @@ static bool pgdat_balanced(pg_data_t *pg
 	return balanced_pages > (present_pages >> 2);
 }
 
-#define is_global_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
+#define is_global_kswapd(kswapd_p) ((kswapd_p)->kswapd_pgdat)
 
 /* is kswapd sleeping prematurely? */
 static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
@@ -2599,50 +2599,56 @@ static void kswapd_try_to_sleep(struct k
 	long remaining = 0;
 	DEFINE_WAIT(wait);
 	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
-	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
+	wait_queue_head_t *wait_h = kswapd_p->kswapd_wait;
 
 	if (freezing(current) || kthread_should_stop())
 		return;
 
 	prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
 
-	if (!is_global_kswapd(kswapd_p)) {
-		schedule();
-		goto out;
-	}
-
-	/* Try to sleep for a short interval */
-	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
-		remaining = schedule_timeout(HZ/10);
-		finish_wait(wait_h, &wait);
-		prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
-	}
-
-	/*
-	 * After a short sleep, check if it was a premature sleep. If not, then
-	 * go fully to sleep until explicitly woken up.
-	 */
-	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
-		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+	if (is_global_kswapd(kswapd_p)) {
+		/* Try to sleep for a short interval */
+		if (!sleeping_prematurely(pgdat, order,
+				remaining, classzone_idx)) {
+			remaining = schedule_timeout(HZ/10);
+			finish_wait(wait_h, &wait);
+			prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
+		}
 
 		/*
-		 * vmstat counters are not perfectly accurate and the estimated
-		 * value for counters such as NR_FREE_PAGES can deviate from the
-		 * true value by nr_online_cpus * threshold. To avoid the zone
-		 * watermarks being breached while under pressure, we reduce the
-		 * per-cpu vmstat threshold while kswapd is awake and restore
-		 * them before going back to sleep.
-		 */
-		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
-		schedule();
-		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+	 	 * After a short sleep, check if it was a premature sleep.
+	 	 * If not, then go fully to sleep until explicitly woken up.
+	 	 */
+		if (!sleeping_prematurely(pgdat, order,
+					remaining, classzone_idx)) {
+			trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+			/*
+		 	 * vmstat counters are not perfectly accurate and
+		 	 * the estimated value for counters such as
+		 	 * NR_FREE_PAGES  can deviate from the true value for
+		 	 * counters such as NR_FREE_PAGES can deviate from the
+		 	 *  true value by nr_online_cpus * threshold. To avoid
+		 	 *  the zonewatermarks being breached while under
+		 	 *  pressure, we reduce the per-cpu vmstat threshold
+		 	 *  while kswapd is awake and restore them before
+		 	 *  going back to sleep.
+		 	 */
+			set_pgdat_percpu_threshold(pgdat,
+					calculate_normal_threshold);
+			schedule();
+			set_pgdat_percpu_threshold(pgdat,
+					calculate_pressure_threshold);
+		} else {
+			if (remaining)
+				count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
+			else
+				count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+		}
 	} else {
-		if (remaining)
-			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
-		else
-			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+		/* For now, we just check the remaining works.*/
+		if (mem_cgroup_kswapd_can_sleep())
+			schedule();
 	}
-out:
 	finish_wait(wait_h, &wait);
 }
 
@@ -2651,8 +2657,8 @@ out:
  * The function is used for per-memcg LRU. It scanns all the zones of the
  * node and returns the nr_scanned and nr_reclaimed.
  */
-static void balance_pgdat_node(pg_data_t *pgdat, int order,
-					struct scan_control *sc)
+static void shrink_memcg_node(pg_data_t *pgdat, int order,
+				struct scan_control *sc)
 {
 	int i;
 	unsigned long total_scanned = 0;
@@ -2705,14 +2711,9 @@ static void balance_pgdat_node(pg_data_t
  * Per cgroup background reclaim.
  * TODO: Take off the order since memcg always do order 0
  */
-static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
-					      int order)
+static int shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
 {
-	int i, nid;
-	int start_node;
-	int priority;
-	bool wmark_ok;
-	int loop;
+	int i, nid, priority, loop;
 	pg_data_t *pgdat;
 	nodemask_t do_nodes;
 	unsigned long total_scanned;
@@ -2726,43 +2727,34 @@ static unsigned long balance_mem_cgroup_
 		.mem_cgroup = mem_cont,
 	};
 
-loop_again:
 	do_nodes = NODE_MASK_NONE;
 	sc.may_writepage = !laptop_mode;
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.priority = priority;
-		wmark_ok = false;
-		loop = 0;
+	do_nodes = node_states[N_ONLINE];
 
+	for (priority = DEF_PRIORITY;
+		(priority >= 0) && (sc.nr_to_reclaim > sc.nr_reclaimed);
+		priority--) {
+
+		sc.priority = priority;
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
 			disable_swap_token();
+		/*
+		 * We'll scan a node given by memcg's logic. For avoiding
+		 * burning cpu, we have a limit of this loop.
+		 */
+		for (loop = num_online_nodes();
+			(loop > 0) && !nodes_empty(do_nodes);
+			loop--) {
 
-		if (priority == DEF_PRIORITY)
-			do_nodes = node_states[N_ONLINE];
-
-		while (1) {
 			nid = mem_cgroup_select_victim_node(mem_cont,
 							&do_nodes);
-
-			/*
-			 * Indicate we have cycled the nodelist once
-			 * TODO: we might add MAX_RECLAIM_LOOP for preventing
-			 * kswapd burning cpu cycles.
-			 */
-			if (loop == 0) {
-				start_node = nid;
-				loop++;
-			} else if (nid == start_node)
-				break;
-
 			pgdat = NODE_DATA(nid);
-			balance_pgdat_node(pgdat, order, &sc);
+			shrink_memcg_node(pgdat, order, &sc);
 			total_scanned += sc.nr_scanned;
-
 			/*
 			 * Set the node which has at least one reclaimable
 			 * zone
@@ -2770,10 +2762,8 @@ loop_again:
 			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
 				struct zone *zone = pgdat->node_zones + i;
 
-				if (!populated_zone(zone))
-					continue;
-
-				if (!mem_cgroup_mz_unreclaimable(mem_cont,
+				if (populated_zone(zone) &&
+				    !mem_cgroup_mz_unreclaimable(mem_cont,
 								zone))
 					break;
 			}
@@ -2781,36 +2771,18 @@ loop_again:
 				node_clear(nid, do_nodes);
 
 			if (mem_cgroup_watermark_ok(mem_cont,
-							CHARGE_WMARK_HIGH)) {
-				wmark_ok = true;
-				goto out;
-			}
-
-			if (nodes_empty(do_nodes)) {
-				wmark_ok = true;
+						CHARGE_WMARK_HIGH))
 				goto out;
-			}
 		}
 
 		if (total_scanned && priority < DEF_PRIORITY - 2)
 			congestion_wait(WRITE, HZ/10);
-
-		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
-			break;
 	}
 out:
-	if (!wmark_ok) {
-		cond_resched();
-
-		try_to_freeze();
-
-		goto loop_again;
-	}
-
 	return sc.nr_reclaimed;
 }
 #else
-static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
+static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont,
 							int order)
 {
 	return 0;
@@ -2836,8 +2808,7 @@ int kswapd(void *p)
 	int classzone_idx;
 	struct kswapd *kswapd_p = (struct kswapd *)p;
 	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
-	struct mem_cgroup *mem = kswapd_p->kswapd_mem;
-	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
+	struct mem_cgroup *mem;
 	struct task_struct *tsk = current;
 
 	struct reclaim_state reclaim_state = {
@@ -2848,7 +2819,6 @@ int kswapd(void *p)
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
 	if (is_global_kswapd(kswapd_p)) {
-		BUG_ON(pgdat->kswapd_wait != wait_h);
 		cpumask = cpumask_of_node(pgdat->node_id);
 		if (!cpumask_empty(cpumask))
 			set_cpus_allowed_ptr(tsk, cpumask);
@@ -2908,18 +2878,20 @@ int kswapd(void *p)
 		if (kthread_should_stop())
 			break;
 
+		if (ret)
+			continue;
 		/*
 		 * We can speed up thawing tasks if we don't call balance_pgdat
 		 * after returning from the refrigerator
 		 */
-		if (!ret) {
-			if (is_global_kswapd(kswapd_p)) {
-				trace_mm_vmscan_kswapd_wake(pgdat->node_id,
-								order);
-				order = balance_pgdat(pgdat, order,
-							&classzone_idx);
-			} else
-				balance_mem_cgroup_pgdat(mem, order);
+		if (is_global_kswapd(kswapd_p)) {
+			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
+			order = balance_pgdat(pgdat, order, &classzone_idx);
+		} else {
+			mem = mem_cgroup_get_shrink_target();
+			if (mem)
+				shrink_mem_cgroup(mem, order);
+			mem_cgroup_put_shrink_target(mem);
 		}
 	}
 	return 0;
@@ -2942,13 +2914,13 @@ void wakeup_kswapd(struct zone *zone, in
 		pgdat->kswapd_max_order = order;
 		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
 	}
-	if (!waitqueue_active(pgdat->kswapd_wait))
+	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-	wake_up_interruptible(pgdat->kswapd_wait);
+	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
 /*
@@ -3046,9 +3018,8 @@ static int __devinit cpu_callback(struct
 
 			mask = cpumask_of_node(pgdat->node_id);
 
-			wait = pgdat->kswapd_wait;
-			kswapd_p = container_of(wait, struct kswapd,
-						kswapd_wait);
+			wait = &pgdat->kswapd_wait;
+			kswapd_p = pgdat->kswapd;
 			kswapd_tsk = kswapd_p->kswapd_task;
 
 			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
@@ -3064,18 +3035,17 @@ static int __devinit cpu_callback(struct
  * This kswapd start function will be called by init and node-hot-add.
  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
  */
-int kswapd_run(int nid, struct mem_cgroup *mem)
+int kswapd_run(int nid, int memcgid)
 {
 	struct task_struct *kswapd_tsk;
 	pg_data_t *pgdat = NULL;
 	struct kswapd *kswapd_p;
 	static char name[TASK_COMM_LEN];
-	int memcg_id = -1;
 	int ret = 0;
 
-	if (!mem) {
+	if (!memcgid) {
 		pgdat = NODE_DATA(nid);
-		if (pgdat->kswapd_wait)
+		if (pgdat->kswapd)
 			return ret;
 	}
 
@@ -3083,34 +3053,26 @@ int kswapd_run(int nid, struct mem_cgrou
 	if (!kswapd_p)
 		return -ENOMEM;
 
-	init_waitqueue_head(&kswapd_p->kswapd_wait);
-
-	if (!mem) {
-		pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
+	if (!memcgid) {
+		pgdat->kswapd = kswapd_p;
+		kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
 		kswapd_p->kswapd_pgdat = pgdat;
 		snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
 	} else {
-		memcg_id = mem_cgroup_init_kswapd(mem, kswapd_p);
-		if (!memcg_id) {
-			kfree(kswapd_p);
-			return ret;
-		}
-		snprintf(name, TASK_COMM_LEN, "memcg_%d", memcg_id);
+		kswapd_p->kswapd_wait = mem_cgroup_kswapd_waitq();
+		snprintf(name, TASK_COMM_LEN, "memcg_%d", memcgid);
 	}
 
 	kswapd_tsk = kthread_run(kswapd, kswapd_p, name);
 	if (IS_ERR(kswapd_tsk)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
-		if (!mem) {
+		if (!memcgid) {
 			printk(KERN_ERR "Failed to start kswapd on node %d\n",
 								nid);
-			pgdat->kswapd_wait = NULL;
-		} else {
-			printk(KERN_ERR "Failed to start kswapd on memcg %d\n",
-								memcg_id);
-			mem_cgroup_clear_kswapd(mem);
-		}
+			pgdat->kswapd = NULL;
+		} else
+			printk(KERN_ERR "Failed to start kswapd on memcg\n");
 		kfree(kswapd_p);
 		ret = -1;
 	} else
@@ -3121,23 +3083,14 @@ int kswapd_run(int nid, struct mem_cgrou
 /*
  * Called by memory hotplug when all memory in a node is offlined.
  */
-void kswapd_stop(int nid, struct mem_cgroup *mem)
+void kswapd_stop(int nid)
 {
 	struct task_struct *kswapd_tsk = NULL;
 	struct kswapd *kswapd_p = NULL;
-	wait_queue_head_t *wait;
-
-	if (!mem)
-		wait = NODE_DATA(nid)->kswapd_wait;
-	else
-		wait = mem_cgroup_kswapd_wait(mem);
-
-	if (wait) {
-		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
-		kswapd_tsk = kswapd_p->kswapd_task;
-		kswapd_p->kswapd_task = NULL;
-	}
 
+	kswapd_p = NODE_DATA(nid)->kswapd;
+	kswapd_tsk = kswapd_p->kswapd_task;
+	kswapd_p->kswapd_task = NULL;
 	if (kswapd_tsk)
 		kthread_stop(kswapd_tsk);
 
@@ -3150,7 +3103,7 @@ static int __init kswapd_init(void)
 
 	swap_setup();
 	for_each_node_state(nid, N_HIGH_MEMORY)
-		kswapd_run(nid, NULL);
+		kswapd_run(nid, 0);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;
 }
Index: mmotm-Apr14/include/linux/memcontrol.h
===================================================================
--- mmotm-Apr14.orig/include/linux/memcontrol.h
+++ mmotm-Apr14/include/linux/memcontrol.h
@@ -94,6 +94,11 @@ extern int mem_cgroup_last_scanned_node(
 extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
 					const nodemask_t *nodes);
 
+extern bool mem_cgroup_kswapd_can_sleep(void);
+extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
+extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
+extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
+
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
Index: mmotm-Apr14/mm/memory_hotplug.c
===================================================================
--- mmotm-Apr14.orig/mm/memory_hotplug.c
+++ mmotm-Apr14/mm/memory_hotplug.c
@@ -463,7 +463,7 @@ int __ref online_pages(unsigned long pfn
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
-		kswapd_run(zone_to_nid(zone), NULL);
+		kswapd_run(zone_to_nid(zone), 0);
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
 	}
 
@@ -898,7 +898,7 @@ repeat:
 
 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
-		kswapd_stop(node, NULL);
+		kswapd_stop(node);
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
