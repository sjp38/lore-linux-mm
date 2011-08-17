Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 53634900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:05 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 07/13] memcg: add cgroupfs interface to memcg dirty limits
Date: Wed, 17 Aug 2011 09:14:59 -0700
Message-Id: <1313597705-6093-8-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

Add cgroupfs interface to memcg dirty page limits:
  Direct write-out is controlled with:
  - memory.dirty_ratio
  - memory.dirty_limit_in_bytes

  Background write-out is controlled with:
  - memory.dirty_background_ratio
  - memory.dirty_background_limit_bytes

Other memcg cgroupfs files support 'M', 'm', 'k', 'K', 'g'
and 'G' suffixes for byte counts.  This patch provides the
same functionality for memory.dirty_limit_in_bytes and
memory.dirty_background_limit_bytes.

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:
- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 mm/memcontrol.c |  115 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 115 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 070c4ab..4e01699 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -121,6 +121,13 @@ enum mem_cgroup_events_target {
 #define SOFTLIMIT_EVENTS_TARGET (1024)
 #define NUMAINFO_EVENTS_TARGET	(1024)
 
+enum {
+	MEM_CGROUP_DIRTY_RATIO,
+	MEM_CGROUP_DIRTY_LIMIT_IN_BYTES,
+	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES,
+};
+
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
 	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
@@ -4927,6 +4934,90 @@ static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
 	return 0;
 }
 
+static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	bool use_sys = !mem_cgroup_has_dirty_limit(memcg);
+
+	switch (cft->private) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		return use_sys ? vm_dirty_ratio :
+			memcg->dirty_param.dirty_ratio;
+	case MEM_CGROUP_DIRTY_LIMIT_IN_BYTES:
+		return use_sys ? vm_dirty_bytes :
+			memcg->dirty_param.dirty_bytes;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		return use_sys ? dirty_background_ratio :
+			memcg->dirty_param.dirty_background_ratio;
+	case MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES:
+		return use_sys ? dirty_background_bytes :
+			memcg->dirty_param.dirty_background_bytes;
+	default:
+		BUG();
+	}
+}
+
+static int
+mem_cgroup_dirty_write_string(struct cgroup *cgrp, struct cftype *cft,
+				const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	int type = cft->private;
+	int ret = -EINVAL;
+	unsigned long long val;
+
+	if (!mem_cgroup_has_dirty_limit(memcg))
+		return ret;
+
+	switch (type) {
+	case MEM_CGROUP_DIRTY_LIMIT_IN_BYTES:
+		/* This function does all necessary parse...reuse it */
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		memcg->dirty_param.dirty_bytes = val;
+		memcg->dirty_param.dirty_ratio  = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		memcg->dirty_param.dirty_background_bytes = val;
+		memcg->dirty_param.dirty_background_ratio = 0;
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+static int
+mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	int type = cft->private;
+
+	if (!mem_cgroup_has_dirty_limit(memcg))
+		return -EINVAL;
+	if ((type == MEM_CGROUP_DIRTY_RATIO ||
+	     type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)
+		return -EINVAL;
+	switch (type) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		memcg->dirty_param.dirty_ratio = val;
+		memcg->dirty_param.dirty_bytes = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		memcg->dirty_param.dirty_background_ratio = val;
+		memcg->dirty_param.dirty_background_bytes = 0;
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return 0;
+}
 
 static struct cftype mem_cgroup_files[] = {
 	{
@@ -5003,6 +5094,30 @@ static struct cftype mem_cgroup_files[] = {
 		.read_map = mem_cgroup_vmscan_stat_read,
 		.trigger = mem_cgroup_reset_vmscan_stat,
 	},
+	{
+		.name = "dirty_ratio",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_RATIO,
+	},
+	{
+		.name = "dirty_limit_in_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_string = mem_cgroup_dirty_write_string,
+		.private = MEM_CGROUP_DIRTY_LIMIT_IN_BYTES,
+	},
+	{
+		.name = "dirty_background_ratio",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	},
+	{
+		.name = "dirty_background_limit_in_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_string = mem_cgroup_dirty_write_string,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES,
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
