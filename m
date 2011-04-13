Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E04690008B
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:04:25 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 3/7] New APIs to adjust per-memcg wmarks
Date: Wed, 13 Apr 2011 00:03:03 -0700
Message-Id: <1302678187-24154-4-git-send-email-yinghan@google.com>
In-Reply-To: <1302678187-24154-1-git-send-email-yinghan@google.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

Add wmark_ratio and reclaim_wmarks APIs per-memcg. The wmark_ratio
adjusts the internal low/high wmark calculation and the reclaim_wmarks
exports the current value of watermarks. By default, the wmark_ratio is
set to 0 and the watermarks are equal to the hard_limit(limit_in_bytes).

$ cat /dev/cgroup/A/memory.wmark_ratio
0

$ cat /dev/cgroup/A/memory.limit_in_bytes
524288000

$ echo 80 >/dev/cgroup/A/memory.wmark_ratio

$ cat /dev/cgroup/A/memory.reclaim_wmarks
low_wmark 393216000
high_wmark 419430400

changelog v3..v2:
1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
feedbacks

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 664cdc5..36ae377 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3983,6 +3983,31 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 mem_cgroup_wmark_ratio_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return get_wmark_ratio(memcg);
+}
+
+static int mem_cgroup_wmark_ratio_write(struct cgroup *cgrp, struct cftype *cfg,
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
+	memcg->wmark_ratio = val;
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4274,6 +4299,21 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
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
@@ -4377,6 +4417,15 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "wmark_ratio",
+		.write_u64 = mem_cgroup_wmark_ratio_write,
+		.read_u64 = mem_cgroup_wmark_ratio_read,
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
