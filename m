Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 082526B00E7
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:01:15 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 3/5] New APIs to adjust per cgroup wmarks.
Date: Thu, 13 Jan 2011 14:00:33 -0800
Message-Id: <1294956035-12081-4-git-send-email-yinghan@google.com>
In-Reply-To: <1294956035-12081-1-git-send-email-yinghan@google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add min_free_kbytes and reclaim_wmarks APIs per memory cgroup.
The first one is to adjust the internal low/high wmark calculation
and the second one is to export the wmarks.

$ echo 1024 >/dev/cgroup/A/memory.min_free_kbytes

$ cat /dev/cgroup/A/memory.reclaim_wmarks
low_wmark 98304000
high_wmark 81920000

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5508d94..6ef26a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4122,6 +4122,33 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 mem_cgroup_min_free_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return get_min_free_kbytes(memcg);
+}
+
+static int mem_cgroup_min_free_write(struct cgroup *cgrp, struct cftype *cfg,
+				     u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *parent;
+
+	if (cgrp->parent == NULL)
+		return -EINVAL;
+
+	parent = mem_cgroup_from_cont(cgrp->parent);
+
+	spin_lock(&memcg->reclaim_param_lock);
+	memcg->min_free_kbytes = val;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4413,6 +4440,21 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
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
@@ -4623,6 +4665,15 @@ static struct cftype mem_cgroup_files[] = {
 		.write_string = mem_cgroup_dirty_write_string,
 		.private = MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES,
 	},
+	{
+		.name = "min_free_kbytes",
+		.write_u64 = mem_cgroup_min_free_write,
+		.read_u64 = mem_cgroup_min_free_read,
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
