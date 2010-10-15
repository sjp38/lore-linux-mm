Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 32C955F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:49 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 09/11] memcg: add cgroupfs interface to memcg dirty limits
Date: Fri, 15 Oct 2010 14:14:37 -0700
Message-Id: <1287177279-30876-10-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

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

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1e4c9d2..4f5a103 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -100,6 +100,13 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+enum {
+	MEM_CGROUP_DIRTY_RATIO,
+	MEM_CGROUP_DIRTY_LIMIT_IN_BYTES,
+	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES,
+};
+
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
 };
@@ -4306,6 +4313,91 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	bool root;
+
+	root = mem_cgroup_is_root(mem);
+
+	switch (cft->private) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		return root ? vm_dirty_ratio : mem->dirty_param.dirty_ratio;
+	case MEM_CGROUP_DIRTY_LIMIT_IN_BYTES:
+		return root ? vm_dirty_bytes : mem->dirty_param.dirty_bytes;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		return root ? dirty_background_ratio :
+			mem->dirty_param.dirty_background_ratio;
+	case MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES:
+		return root ? dirty_background_bytes :
+			mem->dirty_param.dirty_background_bytes;
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
+	if (cgrp->parent == NULL)
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
+	if (cgrp->parent == NULL)
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
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4369,6 +4461,30 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
