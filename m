Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 630A1900088
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:59:00 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 01/10] Add kswapd descriptor
Date: Mon, 18 Apr 2011 20:57:37 -0700
Message-Id: <1303185466-2532-2-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

There is a kswapd kernel thread for each numa node. We will add a different
kswapd for each memcg. The kswapd is sleeping in the wait queue headed at
kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
information of node or memcg and it allows the global and per-memcg background
reclaim to share common reclaim algorithms.

This patch adds the kswapd descriptor and moves the per-node kswapd to use the
new structure.

changelog v6..v5:
1. rename kswapd_thr to kswapd_tsk
2. revert the api change on sleeping_prematurely since memcg doesn't support it.

changelog v5..v4:
1. add comment on kswapds_spinlock
2. remove the kswapds_spinlock. we don't need it here since the kswapd and pgdat
have 1:1 mapping.

changelog v3..v2:
1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
2. rename thr in kswapd_run to something else.

changelog v2..v1:
1. dynamic allocate kswapd descriptor and initialize the wait_queue_head of pgdat
at kswapd_run.
2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup kswapd
descriptor.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/mmzone.h |    3 +-
 include/linux/swap.h   |    7 ++++
 mm/page_alloc.c        |    1 -
 mm/vmscan.c            |   80 ++++++++++++++++++++++++++++++++++++-----------
 4 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 628f07b..6cba7d2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -640,8 +640,7 @@ typedef struct pglist_data {
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
 	int node_id;
-	wait_queue_head_t kswapd_wait;
-	struct task_struct *kswapd;
+	wait_queue_head_t *kswapd_wait;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 } pg_data_t;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ed6ebe6..f43d406 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)
 	return current->flags & PF_KSWAPD;
 }
 
+struct kswapd {
+	struct task_struct *kswapd_task;
+	wait_queue_head_t kswapd_wait;
+	pg_data_t *kswapd_pgdat;
+};
+
+int kswapd(void *p);
 /*
  * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
  * be swapped to.  The swap type and the offset into that swap type are
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e1b52a..6340865 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
-	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..ba5e591 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2570,21 +2570,24 @@ out:
 	return order;
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
+static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
+				int classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
+	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
+	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
 
 	if (freezing(current) || kthread_should_stop())
 		return;
 
-	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
 	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
 		remaining = schedule_timeout(HZ/10);
-		finish_wait(&pgdat->kswapd_wait, &wait);
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+		finish_wait(wait_h, &wait);
+		prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
 	}
 
 	/*
@@ -2611,7 +2614,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		else
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 	}
-	finish_wait(&pgdat->kswapd_wait, &wait);
+	finish_wait(wait_h, &wait);
 }
 
 /*
@@ -2627,20 +2630,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
-static int kswapd(void *p)
+int kswapd(void *p)
 {
 	unsigned long order;
 	int classzone_idx;
-	pg_data_t *pgdat = (pg_data_t*)p;
+	struct kswapd *kswapd_p = (struct kswapd *)p;
+	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
+	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
 	struct task_struct *tsk = current;
 
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
-	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	const struct cpumask *cpumask;
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
+	BUG_ON(pgdat->kswapd_wait != wait_h);
+	cpumask = cpumask_of_node(pgdat->node_id);
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
 	current->reclaim_state = &reclaim_state;
@@ -2679,7 +2686,7 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, order, classzone_idx);
+			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order = 0;
@@ -2719,13 +2726,13 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 		pgdat->kswapd_max_order = order;
 		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
 	}
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
@@ -2817,12 +2824,21 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 		for_each_node_state(nid, N_HIGH_MEMORY) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 			const struct cpumask *mask;
+			struct kswapd *kswapd_p;
+			struct task_struct *kswapd_tsk;
+			wait_queue_head_t *wait;
 
 			mask = cpumask_of_node(pgdat->node_id);
 
+			wait = pgdat->kswapd_wait;
+			kswapd_p = container_of(wait, struct kswapd,
+						kswapd_wait);
+			kswapd_tsk = kswapd_p->kswapd_task;
+
 			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
 				/* One of our CPUs online: restore mask */
-				set_cpus_allowed_ptr(pgdat->kswapd, mask);
+				if (kswapd_tsk)
+					set_cpus_allowed_ptr(kswapd_tsk, mask);
 		}
 	}
 	return NOTIFY_OK;
@@ -2835,18 +2851,31 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 int kswapd_run(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
+	struct task_struct *kswapd_tsk;
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
+
+	kswapd_tsk = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
+	if (IS_ERR(kswapd_tsk)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
 		printk("Failed to start kswapd on node %d\n",nid);
+		pgdat->kswapd_wait = NULL;
+		kfree(kswapd_p);
 		ret = -1;
-	}
+	} else
+		kswapd_p->kswapd_task = kswapd_tsk;
 	return ret;
 }
 
@@ -2855,10 +2884,23 @@ int kswapd_run(int nid)
  */
 void kswapd_stop(int nid)
 {
-	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
+	struct task_struct *kswapd_tsk = NULL;
+	struct kswapd *kswapd_p = NULL;
+	wait_queue_head_t *wait;
+
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	wait = pgdat->kswapd_wait;
+	if (wait) {
+		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
+		kswapd_tsk = kswapd_p->kswapd_task;
+		kswapd_p->kswapd_task = NULL;
+	}
+
+	if (kswapd_tsk)
+		kthread_stop(kswapd_tsk);
 
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
