Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4CA6B00EA
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:01:24 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 1/5] Add kswapd descriptor.
Date: Thu, 13 Jan 2011 14:00:31 -0800
Message-Id: <1294956035-12081-2-git-send-email-yinghan@google.com>
In-Reply-To: <1294956035-12081-1-git-send-email-yinghan@google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There is a kswapd kernel thread for each memory node. We add a different kswapd
for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
field of a kswapd descriptor. The kswapd descriptor stores information of node
or cgroup and it allows the global and per cgroup background reclaim to share
common reclaim algorithms.

Changelog v2...v1:
1. dynamic allocate kswapd descriptor and initialize the wait_queue_head of pgdat
at kswapd_run.

2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup kswapd
descriptor.

TODO:
1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
2. rename thr in kswapd_run to something else.
3. split this into two patches and the first one just add the kswapd descriptor
definition.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/mmzone.h |    3 +-
 include/linux/swap.h   |    8 +++
 mm/memcontrol.c        |    2 +
 mm/page_alloc.c        |    1 -
 mm/vmscan.c            |  118 ++++++++++++++++++++++++++++++++++++------------
 5 files changed, 100 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4890662..d9e70e6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -636,8 +636,7 @@ typedef struct pglist_data {
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
 	int node_id;
-	wait_queue_head_t kswapd_wait;
-	struct task_struct *kswapd;
+	wait_queue_head_t *kswapd_wait;
 	int kswapd_max_order;
 } pg_data_t;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index eba53e7..52122fa 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -26,6 +26,14 @@ static inline int current_is_kswapd(void)
 	return current->flags & PF_KSWAPD;
 }
 
+struct kswapd {
+	struct task_struct *kswapd_task;
+	wait_queue_head_t kswapd_wait;
+	struct mem_cgroup *kswapd_mem;
+	pg_data_t *kswapd_pgdat;
+};
+
+int kswapd(void *p);
 /*
  * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
  * be swapped to.  The swap type and the offset into that swap type are
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 73ccdfc..f6e0987 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -288,6 +288,8 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+	wait_queue_head_t *kswapd_wait;
 };
 
 /* Stuffs for move charges at task migration. */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 62b7280..0b30939 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4092,7 +4092,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
-	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8cc90d5..a53d91d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2115,12 +2115,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 
 	return nr_reclaimed;
 }
+
 #endif
 
+DEFINE_SPINLOCK(kswapds_spinlock);
+#define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
+
 /* is kswapd sleeping prematurely? */
-static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
+static int sleeping_prematurely(struct kswapd *kswapd, int order,
+				long remaining)
 {
 	int i;
+	pg_data_t *pgdat = kswapd->kswapd_pgdat;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
@@ -2377,21 +2383,27 @@ out:
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
-static int kswapd(void *p)
+int kswapd(void *p)
 {
 	unsigned long order;
-	pg_data_t *pgdat = (pg_data_t*)p;
+	struct kswapd *kswapd_p = (struct kswapd *)p;
+	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
+	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
-	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	const struct cpumask *cpumask;
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
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
@@ -2414,9 +2426,13 @@ static int kswapd(void *p)
 		unsigned long new_order;
 		int ret;
 
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		new_order = pgdat->kswapd_max_order;
-		pgdat->kswapd_max_order = 0;
+		prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
+		if (is_node_kswapd(kswapd_p)) {
+			new_order = pgdat->kswapd_max_order;
+			pgdat->kswapd_max_order = 0;
+		} else
+			new_order = 0;
+
 		if (order < new_order) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
@@ -2428,10 +2444,12 @@ static int kswapd(void *p)
 				long remaining = 0;
 
 				/* Try to sleep for a short interval */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
+				if (!sleeping_prematurely(kswapd_p, order,
+							remaining)) {
 					remaining = schedule_timeout(HZ/10);
-					finish_wait(&pgdat->kswapd_wait, &wait);
-					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+					finish_wait(wait_h, &wait);
+					prepare_to_wait(wait_h, &wait,
+							TASK_INTERRUPTIBLE);
 				}
 
 				/*
@@ -2439,13 +2457,19 @@ static int kswapd(void *p)
 				 * premature sleep. If not, then go fully
 				 * to sleep until explicitly woken up
 				 */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
-					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
-					set_pgdat_percpu_threshold(pgdat,
-						calculate_normal_threshold);
+				if (!sleeping_prematurely(kswapd_p, order,
+							remaining)) {
+					if (is_node_kswapd(kswapd_p)) {
+						trace_mm_vmscan_kswapd_sleep(
+								pgdat->node_id);
+						set_pgdat_percpu_threshold(pgdat,
+							calculate_normal_threshold);
+					}
 					schedule();
-					set_pgdat_percpu_threshold(pgdat,
-						calculate_pressure_threshold);
+					if (is_node_kswapd(kswapd_p)) {
+						set_pgdat_percpu_threshold(pgdat,
+							calculate_pressure_threshold);
+					}
 				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
@@ -2454,9 +2478,10 @@ static int kswapd(void *p)
 				}
 			}
 
-			order = pgdat->kswapd_max_order;
+			if (is_node_kswapd(kswapd_p))
+				order = pgdat->kswapd_max_order;
 		}
-		finish_wait(&pgdat->kswapd_wait, &wait);
+		finish_wait(wait_h, &wait);
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
@@ -2489,13 +2514,13 @@ void wakeup_kswapd(struct zone *zone, int order)
 	pgdat = zone->zone_pgdat;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
-	if (!waitqueue_active(&pgdat->kswapd_wait))
+	if (!waitqueue_active(pgdat->kswapd_wait))
 		return;
 	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-	wake_up_interruptible(&pgdat->kswapd_wait);
+	wake_up_interruptible(pgdat->kswapd_wait);
 }
 
 /*
@@ -2587,12 +2612,23 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 		for_each_node_state(nid, N_HIGH_MEMORY) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 			const struct cpumask *mask;
+			struct kswapd *kswapd_p;
+			struct task_struct *thr;
+			wait_queue_head_t *wait;
 
 			mask = cpumask_of_node(pgdat->node_id);
 
+			spin_lock(&kswapds_spinlock);
+			wait = pgdat->kswapd_wait;
+			kswapd_p = container_of(wait, struct kswapd,
+						kswapd_wait);
+			thr = kswapd_p->kswapd_task;
+			spin_unlock(&kswapds_spinlock);
+
 			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
 				/* One of our CPUs online: restore mask */
-				set_cpus_allowed_ptr(pgdat->kswapd, mask);
+				if (thr)
+					set_cpus_allowed_ptr(thr, mask);
 		}
 	}
 	return NOTIFY_OK;
@@ -2605,18 +2641,28 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 int kswapd_run(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
+	struct task_struct *thr;
+	struct kswapd *kswapd_p;
 	int ret = 0;
 
-	if (pgdat->kswapd)
+	if (pgdat->kswapd_wait)
 		return 0;
 
-	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
-	if (IS_ERR(pgdat->kswapd)) {
+	kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
+	if (!kswapd_p)
+		return -ENOMEM;
+
+	init_waitqueue_head(&kswapd_p->kswapd_wait);
+	pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
+	kswapd_p->kswapd_pgdat = pgdat;
+	thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
+	if (IS_ERR(thr)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
 		printk("Failed to start kswapd on node %d\n",nid);
 		ret = -1;
 	}
+	kswapd_p->kswapd_task = thr;
 	return ret;
 }
 
@@ -2625,10 +2671,24 @@ int kswapd_run(int nid)
  */
 void kswapd_stop(int nid)
 {
-	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
+	struct task_struct *thr = NULL;
+	struct kswapd *kswapd_p = NULL;
+	wait_queue_head_t *wait;
+
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	spin_lock(&kswapds_spinlock);
+	wait = pgdat->kswapd_wait;
+	if (wait) {
+		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
+		thr = kswapd_p->kswapd_task;
+	}
+	spin_unlock(&kswapds_spinlock);
+
+	if (thr)
+		kthread_stop(thr);
 
-	if (kswapd)
-		kthread_stop(kswapd);
+	kfree(kswapd_p);
 }
 
 static int __init kswapd_init(void)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
