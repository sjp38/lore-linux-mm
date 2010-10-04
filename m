Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E019C6B0047
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 03:02:50 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty limits
Date: Sun,  3 Oct 2010 23:58:03 -0700
Message-Id: <1286175485-30643-9-git-send-email-gthelen@google.com>
In-Reply-To: <1286175485-30643-1-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Add cgroupfs interface to memcg dirty page limits:
  Direct write-out is controlled with:
  - memory.dirty_ratio
  - memory.dirty_bytes

  Background write-out is controlled with:
  - memory.dirty_background_ratio
  - memory.dirty_background_bytes

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ec2625..2d45a0a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -100,6 +100,13 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+enum {
+	MEM_CGROUP_DIRTY_RATIO,
+	MEM_CGROUP_DIRTY_BYTES,
+	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
+};
+
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
 };
@@ -4292,6 +4299,64 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
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
+	case MEM_CGROUP_DIRTY_BYTES:
+		return root ? vm_dirty_bytes : mem->dirty_param.dirty_bytes;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		return root ? dirty_background_ratio :
+			mem->dirty_param.dirty_background_ratio;
+	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
+		return root ? dirty_background_bytes :
+			mem->dirty_param.dirty_background_bytes;
+	default:
+		BUG();
+	}
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
+	case MEM_CGROUP_DIRTY_BYTES:
+		memcg->dirty_param.dirty_bytes = val;
+		memcg->dirty_param.dirty_ratio  = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		memcg->dirty_param.dirty_background_ratio = val;
+		memcg->dirty_param.dirty_background_bytes = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
+		memcg->dirty_param.dirty_background_bytes = val;
+		memcg->dirty_param.dirty_background_ratio = 0;
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
@@ -4355,6 +4420,30 @@ static struct cftype mem_cgroup_files[] = {
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
+		.name = "dirty_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BYTES,
+	},
+	{
+		.name = "dirty_background_ratio",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	},
+	{
+		.name = "dirty_background_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
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
