Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 135B390008E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:59:01 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 08/10] Enable per-memcg background reclaim.
Date: Mon, 18 Apr 2011 20:57:44 -0700
Message-Id: <1303185466-2532-9-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
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

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0dfdf27..d5b284c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -105,10 +105,12 @@ enum mem_cgroup_events_index {
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
@@ -371,6 +373,8 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+static void wake_memcg_kswapd(struct mem_cgroup *mem);
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -549,6 +553,12 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
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
@@ -679,6 +689,9 @@ static void __mem_cgroup_target_update(struct mem_cgroup *mem, int target)
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_WMARK_EVENTS_THRESH:
+		next = val + WMARK_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -702,6 +715,10 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		if (unlikely(__memcg_event_check(mem,
+			MEM_CGROUP_WMARK_EVENTS_THRESH))){
+			mem_cgroup_check_wmark(mem);
+		}
 	}
 }
 
@@ -846,6 +863,9 @@ static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
 
 		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
 		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
+
+		if (!mem_cgroup_is_root(mem) && !mem->kswapd_wait)
+			kswapd_run(0, mem);
 	}
 }
 
@@ -4868,6 +4888,22 @@ int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
 	return mem->last_scanned_node;
 }
 
+static inline
+void wake_memcg_kswapd(struct mem_cgroup *mem)
+{
+	wait_queue_head_t *wait;
+
+	if (!mem || !mem->high_wmark_distance)
+		return;
+
+	wait = mem->kswapd_wait;
+
+	if (!wait || !waitqueue_active(wait))
+		return;
+
+	wake_up_interruptible(wait);
+}
+
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
@@ -4971,6 +5007,7 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	kswapd_stop(0, mem);
 	mem_cgroup_put(mem);
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
