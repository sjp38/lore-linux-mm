Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCA590008B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:24:52 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V5 03/10] New APIs to adjust per-memcg wmarks
Date: Fri, 15 Apr 2011 16:23:28 -0700
Message-Id: <1302909815-4362-4-git-send-email-yinghan@google.com>
In-Reply-To: <1302909815-4362-1-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

Add memory.low_wmark_distance, memory.high_wmark_distance and reclaim_wmarks
APIs per-memcg. The first two adjust the internal low/high wmark calculation
and the reclaim_wmarks exports the current value of watermarks.

By default, the low/high_wmark is calculated by subtracting the distance from
the hard_limit(limit_in_bytes).

$ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
$ cat /dev/cgroup/A/memory.limit_in_bytes
524288000

$ echo 50m >/dev/cgroup/A/memory.high_wmark_distance
$ echo 40m >/dev/cgroup/A/memory.low_wmark_distance

$ cat /dev/cgroup/A/memory.reclaim_wmarks
low_wmark 482344960
high_wmark 471859200

change v5..v4
1. add sanity check for setting high/low_wmark_distance for root cgroup.

changelog v4..v3:
1. replace the "wmark_ratio" API with individual tunable for low/high_wmarks.

changelog v3..v2:
1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
feedbacks

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1ec4014..76ad009 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3974,6 +3974,78 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,
+					       struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return memcg->high_wmark_distance;
+}
+
+static u64 mem_cgroup_low_wmark_distance_read(struct cgroup *cgrp,
+					      struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return memcg->low_wmark_distance;
+}
+
+static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,
+						struct cftype *cft,
+						const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	u64 low_wmark_distance = memcg->low_wmark_distance;
+	unsigned long long val;
+	u64 limit;
+	int ret;
+
+	if (!cont->parent)
+		return -EINVAL;
+
+	ret = res_counter_memparse_write_strategy(buffer, &val);
+	if (ret)
+		return -EINVAL;
+
+	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	if ((val >= limit) || (val < low_wmark_distance) ||
+	   (low_wmark_distance && val == low_wmark_distance))
+		return -EINVAL;
+
+	memcg->high_wmark_distance = val;
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+}
+
+static int mem_cgroup_low_wmark_distance_write(struct cgroup *cont,
+					       struct cftype *cft,
+					       const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	u64 high_wmark_distance = memcg->high_wmark_distance;
+	unsigned long long val;
+	u64 limit;
+	int ret;
+
+	if (!cont->parent)
+		return -EINVAL;
+
+	ret = res_counter_memparse_write_strategy(buffer, &val);
+	if (ret)
+		return -EINVAL;
+
+	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	if ((val >= limit) || (val > high_wmark_distance) ||
+	    (high_wmark_distance && val == high_wmark_distance))
+		return -EINVAL;
+
+	memcg->low_wmark_distance = val;
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4265,6 +4337,21 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	mutex_unlock(&memcg_oom_mutex);
 }
 
+static int mem_cgroup_wmark_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	u64 low_wmark, high_wmark;
+
+	low_wmark = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
+	high_wmark = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
+
+	cb->fill(cb, "low_wmark", low_wmark);
+	cb->fill(cb, "high_wmark", high_wmark);
+
+	return 0;
+}
+
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
@@ -4368,6 +4455,20 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "high_wmark_distance",
+		.write_string = mem_cgroup_high_wmark_distance_write,
+		.read_u64 = mem_cgroup_high_wmark_distance_read,
+	},
+	{
+		.name = "low_wmark_distance",
+		.write_string = mem_cgroup_low_wmark_distance_write,
+		.read_u64 = mem_cgroup_low_wmark_distance_read,
+	},
+	{
+		.name = "reclaim_wmarks",
+		.read_map = mem_cgroup_wmark_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
