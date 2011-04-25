Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 838338D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:49:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 48BA93EE0C0
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:48:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 285E645DE50
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F56745DE4D
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2FA0E78002
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:48:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3DCCE78003
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:48:56 +0900 (JST)
Date: Mon, 25 Apr 2011 18:42:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 7/7] memcg watermark reclaim workqueue.
Message-Id: <20110425184219.285c2396.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

By default the per-memcg background reclaim is disabled when the limit_in_bytes
is set the maximum. The kswapd_run() is called when the memcg is being resized,
and kswapd_stop() is called when the memcg is being deleted.

The per-memcg kswapd is waked up based on the usage and low_wmark, which is
checked once per 1024 increments per cpu. The memcg's kswapd is waked up if the
usage is larger than the low_wmark.

At each iteration of work, the work frees memory at most 2048 pages and switch
to next work for round robin. And if the memcg seems congested, it adds
delay for the next work.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 -
 mm/memcontrol.c            |   86 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   23 +++++++-----
 3 files changed, 102 insertions(+), 9 deletions(-)

Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -111,10 +111,12 @@ enum mem_cgroup_events_index {
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
 	MEM_CGROUP_TARGET_SOFTLIMIT,
+	MEM_CGROUP_WMARK_EVENTS_THRESH,
 	MEM_CGROUP_NTARGETS,
 };
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define SOFTLIMIT_EVENTS_TARGET (1024)
+#define WMARK_EVENTS_TARGET (1024)
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -267,6 +269,11 @@ struct mem_cgroup {
 	struct list_head oom_notify;
 
 	/*
+ 	 * For high/low watermark.
+ 	 */
+	bool			bgreclaim_resched;
+	struct delayed_work	bgreclaim_work;
+	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
@@ -374,6 +381,8 @@ static void mem_cgroup_put(struct mem_cg
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+static void wake_memcg_kswapd(struct mem_cgroup *mem);
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -552,6 +561,12 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
+static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
+{
+	if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
+		wake_memcg_kswapd(mem);
+}
+
 /*
  * Implementation Note: reading percpu statistics for memcg.
  *
@@ -702,6 +717,9 @@ static void __mem_cgroup_target_update(s
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_WMARK_EVENTS_THRESH:
+		next = val + WMARK_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -725,6 +743,10 @@ static void memcg_check_events(struct me
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		if (unlikely(__memcg_event_check(mem,
+			MEM_CGROUP_WMARK_EVENTS_THRESH))){
+			mem_cgroup_check_wmark(mem);
+		}
 	}
 }
 
@@ -3661,6 +3683,67 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+struct workqueue_struct *memcg_bgreclaimq;
+
+static int memcg_bgreclaim_init(void)
+{
+	/*
+	 * use UNBOUND workqueue because we traverse nodes (no locality) and
+	 * the work is cpu-intensive.
+	 */
+	memcg_bgreclaimq = alloc_workqueue("memcg",
+			WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
+	return 0;
+}
+module_init(memcg_bgreclaim_init);
+
+static void memcg_bgreclaim(struct work_struct *work)
+{
+	struct delayed_work *dw = to_delayed_work(work);
+	struct mem_cgroup *mem =
+		container_of(dw, struct mem_cgroup, bgreclaim_work);
+	int delay = 0;
+	unsigned long long required, usage, hiwat;
+
+	hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
+	usage = res_counter_read_u64(&mem->res, RES_USAGE);
+	required = usage - hiwat;
+	if (required >= 0)  {
+		required = ((usage - hiwat) >> PAGE_SHIFT) + 1;
+		delay = shrink_mem_cgroup(mem, (long)required);
+	}
+	if (!mem->bgreclaim_resched  ||
+		mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+		return;
+	}
+	/* need reschedule */
+	if (!queue_delayed_work(memcg_bgreclaimq, &mem->bgreclaim_work, delay))
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+}
+
+static void wake_memcg_kswapd(struct mem_cgroup *mem)
+{
+	if (delayed_work_pending(&mem->bgreclaim_work))
+		return;
+	cgroup_exclude_rmdir(&mem->css);
+	if (!queue_delayed_work(memcg_bgreclaimq, &mem->bgreclaim_work, 0))
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+	return;
+}
+
+static void stop_memcg_kswapd(struct mem_cgroup *mem)
+{
+	/*
+	 * at destroy(), there is no task and we don't need to take care of
+	 * new bgreclaim work queued. But we need to prevent it from reschedule
+	 * use bgreclaim_resched to tell no more reschedule.
+	 */
+	mem->bgreclaim_resched = false;
+	flush_delayed_work(&mem->bgreclaim_work);
+	mem->bgreclaim_resched = true;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -3742,6 +3825,7 @@ move_account:
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
+		stop_memcg_kswapd(mem);
 		ret = -EINTR;
 		if (signal_pending(current))
 			goto out;
@@ -4804,6 +4888,8 @@ static struct mem_cgroup *mem_cgroup_all
 	if (!mem->stat)
 		goto out_free;
 	spin_lock_init(&mem->pcp_counter_lock);
+	INIT_DELAYED_WORK(&mem->bgreclaim_work, memcg_bgreclaim);
+	mem->bgreclaim_resched = true;
 	return mem;
 
 out_free:
Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -89,7 +89,7 @@ extern int mem_cgroup_last_scanned_node(
 extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
 					const nodemask_t *nodes);
 
-unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
+int shrink_mem_cgroup(struct mem_cgroup *mem, long required);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -2373,20 +2373,19 @@ shrink_memcg_node(int nid, int priority,
 /*
  * Per cgroup background reclaim.
  */
-unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)
+int shrink_mem_cgroup(struct mem_cgroup *mem, long required)
 {
-	int nid, priority, next_prio;
+	int nid, priority, next_prio, delay;
 	nodemask_t nodes;
 	unsigned long total_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
 		.mem_cgroup = mem,
 	};
-
+	/* writepage will be set later per zone */
 	sc.may_writepage = 0;
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
@@ -2400,9 +2399,12 @@ unsigned long shrink_mem_cgroup(struct m
 	 * Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.
 	 * We use static priority 0.
 	 */
+	sc.nr_to_reclaim = min(required, (long)MEMCG_BGSCAN_LIMIT/2);
 	next_prio = min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_MEMORY),
 			MEMCG_BGSCAN_LIMIT/8);
 	priority = DEF_PRIORITY;
+	/* delay for next work at congestion */
+	delay = HZ/10;
 	while ((total_scanned < MEMCG_BGSCAN_LIMIT) &&
 	       !nodes_empty(nodes) &&
 	       (sc.nr_to_reclaim > sc.nr_reclaimed)) {
@@ -2423,12 +2425,17 @@ unsigned long shrink_mem_cgroup(struct m
 			priority--;
 			next_prio <<= 1;
 		}
-		if (sc.nr_scanned &&
-		    total_scanned > sc.nr_reclaimed * 2)
-			congestion_wait(WRITE, HZ/10);
+		/* give up early ? */
+		if (total_scanned > MEMCG_BGSCAN_LIMIT/8 &&
+		    total_scanned > sc.nr_reclaimed * 4)
+			goto out;
 	}
+	/* We scanned enough...If we reclaimed half of requested, no delay */
+	if (sc.nr_reclaimed > sc.nr_to_reclaim/2)
+		delay = 0;
+out:
 	current->flags &= ~PF_SWAPWRITE;
-	return sc.nr_reclaimed;
+	return delay;
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
