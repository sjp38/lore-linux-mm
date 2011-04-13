Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6193690008C
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:04:25 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 4/7] Infrastructure to support per-memcg reclaim.
Date: Wed, 13 Apr 2011 00:03:04 -0700
Message-Id: <1302678187-24154-5-git-send-email-yinghan@google.com>
In-Reply-To: <1302678187-24154-1-git-send-email-yinghan@google.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

Add the kswapd_mem field in kswapd descriptor which links the kswapd
kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait
queue headed at kswapd_wait field of the kswapd descriptor.

The kswapd() function is now shared between global and per-memcg kswapd. It
is passed in with the kswapd descriptor which contains the information of
either node or memcg. Then the new function balance_mem_cgroup_pgdat is
invoked if it is per-mem kswapd thread, and the implementation of the function
is on the following patch.

changelog v3..v2:
1. split off from the initial patch which includes all changes of the following
three patches.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    5 ++
 include/linux/swap.h       |    5 +-
 mm/memcontrol.c            |   29 ++++++++
 mm/vmscan.c                |  152 ++++++++++++++++++++++++++++++--------------
 4 files changed, 141 insertions(+), 50 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3ece36d..f7ffd1f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -24,6 +24,7 @@ struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+struct kswapd;
 
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
@@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
+extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
+				  struct kswapd *kswapd_p);
+extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
+extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index f43d406..17e0511 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -30,6 +30,7 @@ struct kswapd {
 	struct task_struct *kswapd_task;
 	wait_queue_head_t kswapd_wait;
 	pg_data_t *kswapd_pgdat;
+	struct mem_cgroup *kswapd_mem;
 };
 
 int kswapd(void *p);
@@ -303,8 +304,8 @@ static inline void scan_unevictable_unregister_node(struct node *node)
 }
 #endif
 
-extern int kswapd_run(int nid);
-extern void kswapd_stop(int nid);
+extern int kswapd_run(int nid, struct mem_cgroup *mem);
+extern void kswapd_stop(int nid, struct mem_cgroup *mem);
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 36ae377..acd84a8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -274,6 +274,8 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 	int wmark_ratio;
+
+	wait_queue_head_t *kswapd_wait;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -4622,6 +4624,33 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
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
+void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)
+{
+	if (mem)
+		mem->kswapd_wait = NULL;
+
+	return;
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
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 77ac74f..a1a1211 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2242,6 +2242,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 }
 
 static DEFINE_SPINLOCK(kswapds_spinlock);
+#define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
 
 /* is kswapd sleeping prematurely? */
 static int sleeping_prematurely(struct kswapd *kswapd, int order,
@@ -2251,11 +2252,16 @@ static int sleeping_prematurely(struct kswapd *kswapd, int order,
 	unsigned long balanced = 0;
 	bool all_zones_ok = true;
 	pg_data_t *pgdat = kswapd->kswapd_pgdat;
+	struct mem_cgroup *mem = kswapd->kswapd_mem;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return true;
 
+	/* Doesn't support for per-memcg reclaim */
+	if (mem)
+		return false;
+
 	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
@@ -2598,19 +2604,25 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
 	 * go fully to sleep until explicitly woken up.
 	 */
 	if (!sleeping_prematurely(kswapd_p, order, remaining, classzone_idx)) {
-		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+		if (is_node_kswapd(kswapd_p)) {
+			trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
-		/*
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
+			/*
+			 * vmstat counters are not perfectly accurate and the
+			 * estimated value for counters such as NR_FREE_PAGES
+			 * can deviate from the true value by nr_online_cpus *
+			 * threshold. To avoid the zone watermarks being
+			 * breached while under pressure, we reduce the per-cpu
+			 * vmstat threshold while kswapd is awake and restore
+			 * them before going back to sleep.
+			 */
+			set_pgdat_percpu_threshold(pgdat,
+						   calculate_normal_threshold);
+			schedule();
+			set_pgdat_percpu_threshold(pgdat,
+						calculate_pressure_threshold);
+		} else
+			schedule();
 	} else {
 		if (remaining)
 			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
@@ -2620,6 +2632,12 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
 	finish_wait(wait_h, &wait);
 }
 
+static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
+							int order)
+{
+	return 0;
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
@@ -2639,6 +2657,7 @@ int kswapd(void *p)
 	int classzone_idx;
 	struct kswapd *kswapd_p = (struct kswapd *)p;
 	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
+	struct mem_cgroup *mem = kswapd_p->kswapd_mem;
 	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
 	struct task_struct *tsk = current;
 
@@ -2649,10 +2668,12 @@ int kswapd(void *p)
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
-	BUG_ON(pgdat->kswapd_wait != wait_h);
-	cpumask = cpumask_of_node(pgdat->node_id);
-	if (!cpumask_empty(cpumask))
-		set_cpus_allowed_ptr(tsk, cpumask);
+	if (is_node_kswapd(kswapd_p)) {
+		BUG_ON(pgdat->kswapd_wait != wait_h);
+		cpumask = cpumask_of_node(pgdat->node_id);
+		if (!cpumask_empty(cpumask))
+			set_cpus_allowed_ptr(tsk, cpumask);
+	}
 	current->reclaim_state = &reclaim_state;
 
 	/*
@@ -2677,24 +2698,29 @@ int kswapd(void *p)
 		int new_classzone_idx;
 		int ret;
 
-		new_order = pgdat->kswapd_max_order;
-		new_classzone_idx = pgdat->classzone_idx;
-		pgdat->kswapd_max_order = 0;
-		pgdat->classzone_idx = MAX_NR_ZONES - 1;
-		if (order < new_order || classzone_idx > new_classzone_idx) {
-			/*
-			 * Don't sleep if someone wants a larger 'order'
-			 * allocation or has tigher zone constraints
-			 */
-			order = new_order;
-			classzone_idx = new_classzone_idx;
-		} else {
-			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
-			order = pgdat->kswapd_max_order;
-			classzone_idx = pgdat->classzone_idx;
+		if (is_node_kswapd(kswapd_p)) {
+			new_order = pgdat->kswapd_max_order;
+			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order = 0;
 			pgdat->classzone_idx = MAX_NR_ZONES - 1;
-		}
+			if (order < new_order ||
+					classzone_idx > new_classzone_idx) {
+				/*
+				 * Don't sleep if someone wants a larger 'order'
+				 * allocation or has tigher zone constraints
+				 */
+				order = new_order;
+				classzone_idx = new_classzone_idx;
+			} else {
+				kswapd_try_to_sleep(kswapd_p, order,
+						    classzone_idx);
+				order = pgdat->kswapd_max_order;
+				classzone_idx = pgdat->classzone_idx;
+				pgdat->kswapd_max_order = 0;
+				pgdat->classzone_idx = MAX_NR_ZONES - 1;
+			}
+		} else
+			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
@@ -2705,8 +2731,13 @@ int kswapd(void *p)
 		 * after returning from the refrigerator
 		 */
 		if (!ret) {
-			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			order = balance_pgdat(pgdat, order, &classzone_idx);
+			if (is_node_kswapd(kswapd_p)) {
+				trace_mm_vmscan_kswapd_wake(pgdat->node_id,
+								order);
+				order = balance_pgdat(pgdat, order,
+							&classzone_idx);
+			} else
+				balance_mem_cgroup_pgdat(mem, order);
 		}
 	}
 	return 0;
@@ -2853,30 +2884,53 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
  * This kswapd start function will be called by init and node-hot-add.
  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
  */
-int kswapd_run(int nid)
+int kswapd_run(int nid, struct mem_cgroup *mem)
 {
-	pg_data_t *pgdat = NODE_DATA(nid);
 	struct task_struct *kswapd_thr;
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
 
-	kswapd_thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
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
+	kswapd_thr = kthread_run(kswapd, kswapd_p, name);
 	if (IS_ERR(kswapd_thr)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
-		printk("Failed to start kswapd on node %d\n",nid);
-		pgdat->kswapd_wait = NULL;
+		if (!mem) {
+			printk(KERN_ERR "Failed to start kswapd on node %d\n",
+								nid);
+			pgdat->kswapd_wait = NULL;
+		} else {
+			printk(KERN_ERR "Failed to start kswapd on memcg %d\n",
+								memcg_id);
+			mem_cgroup_clear_kswapd(mem);
+		}
 		kfree(kswapd_p);
 		ret = -1;
 	} else
@@ -2887,16 +2941,18 @@ int kswapd_run(int nid)
 /*
  * Called by memory hotplug when all memory in a node is offlined.
  */
-void kswapd_stop(int nid)
+void kswapd_stop(int nid, struct mem_cgroup *mem)
 {
 	struct task_struct *kswapd_thr = NULL;
 	struct kswapd *kswapd_p = NULL;
 	wait_queue_head_t *wait;
 
-	pg_data_t *pgdat = NODE_DATA(nid);
-
 	spin_lock(&kswapds_spinlock);
-	wait = pgdat->kswapd_wait;
+	if (!mem)
+		wait = NODE_DATA(nid)->kswapd_wait;
+	else
+		wait = mem_cgroup_kswapd_wait(mem);
+
 	if (wait) {
 		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
 		kswapd_thr = kswapd_p->kswapd_task;
@@ -2916,7 +2972,7 @@ static int __init kswapd_init(void)
 
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
