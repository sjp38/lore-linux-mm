Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 046CC8D004C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:26:28 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V7 9/9] Enable per-memcg background reclaim.
Date: Thu, 21 Apr 2011 21:24:20 -0700
Message-Id: <1303446260-21333-10-git-send-email-yinghan@google.com>
In-Reply-To: <1303446260-21333-1-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

By default the per-memcg background reclaim is disabled when the limit_in_bytes
is set the maximum. The kswapd_run() is called when the memcg is being resized,
and kswapd_stop() is called when the memcg is being deleted.

The per-memcg kswapd is waked up based on the usage and low_wmark, which is
checked once per 1024 increments per cpu. The memcg's kswapd is waked up if the
usage is larger than the low_wmark.

changelog v7..v6:
1. merge the thread-pool and add memcg_kswapd_stop(), memcg_kswapd_init() based
on thread-pool.

changelog v4..v3:
1. move kswapd_stop to mem_cgroup_destroy based on comments from KAMAZAWA
2. move kswapd_run to setup_mem_cgroup_wmark, since the actual watermarks
determines whether or not enabling per-memcg background reclaim.

changelog v3..v2:
1. some clean-ups

changelog v2..v1:
1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
2. remove checking the wmark from per-page charging. now it checks the wmark
periodically based on the event counter.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9e535b2..a98471b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -107,10 +107,12 @@ enum mem_cgroup_events_index {
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
@@ -379,6 +381,9 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+static void wake_memcg_kswapd(struct mem_cgroup *mem);
+static void memcg_kswapd_stop(struct mem_cgroup *mem);
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -557,6 +562,12 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
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
@@ -687,6 +698,9 @@ static void __mem_cgroup_target_update(struct mem_cgroup *mem, int target)
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_WMARK_EVENTS_THRESH:
+		next = val + WMARK_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -710,6 +724,10 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		if (unlikely(__memcg_event_check(mem,
+			MEM_CGROUP_WMARK_EVENTS_THRESH))){
+			mem_cgroup_check_wmark(mem);
+		}
 	}
 }
 
@@ -3651,6 +3669,7 @@ move_account:
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
+		memcg_kswapd_stop(mem);
 		ret = -EINTR;
 		if (signal_pending(current))
 			goto out;
@@ -4572,6 +4591,21 @@ struct memcg_kswapd_work {
 
 struct memcg_kswapd_work memcg_kswapd_control;
 
+static void wake_memcg_kswapd(struct mem_cgroup *mem)
+{
+	/* already running */
+	if (atomic_read(&mem->kswapd_running))
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
 static void memcg_kswapd_wait_end(struct mem_cgroup *mem)
 {
 	DEFINE_WAIT(wait);
@@ -4582,6 +4616,17 @@ static void memcg_kswapd_wait_end(struct mem_cgroup *mem)
 	finish_wait(&mem->memcg_kswapd_end, &wait);
 }
 
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
 struct mem_cgroup *mem_cgroup_get_shrink_target(void)
 {
 	struct mem_cgroup *mem;
@@ -4631,6 +4676,22 @@ wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
 	return &memcg_kswapd_control.waitq;
 }
 
+static int __init memcg_kswapd_init(void)
+{
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
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
