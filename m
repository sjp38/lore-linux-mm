Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1740C8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:38:59 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v5 8/9] memcg: add cgroupfs interface to memcg dirty limits
Date: Fri, 25 Feb 2011 13:35:59 -0800
Message-Id: <1298669760-26344-9-git-send-email-gthelen@google.com>
In-Reply-To: <1298669760-26344-1-git-send-email-gthelen@google.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

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
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Changelog since v3:
- Make use of new routine, __mem_cgroup_has_dirty_limit(), to disable memcg
  dirty limits when use_hierarchy=1.

Changelog since v1:
- Renamed newly created proc files:
  - memory.dirty_bytes -> memory.dirty_limit_in_bytes
  - memory.dirty_background_bytes -> memory.dirty_background_limit_in_bytes
- Allow [kKmMgG] suffixes for newly created dirty limit value cgroupfs files.

 mm/memcontrol.c |  114 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bc86329..6c8885b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -109,6 +109,13 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 
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
@@ -4518,6 +4525,89 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	bool use_sys = !__mem_cgroup_has_dirty_limit(mem);
+
+	switch (cft->private) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		return use_sys ? vm_dirty_ratio : mem->dirty_param.dirty_ratio;
+	case MEM_CGROUP_DIRTY_LIMIT_IN_BYTES:
+		return use_sys ? vm_dirty_bytes : mem->dirty_param.dirty_bytes;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		return use_sys ? dirty_background_ratio :
+			mem->dirty_param.dirty_background_ratio;
+	case MEM_CGROUP_DIRTY_BACKGROUND_LIMIT_IN_BYTES:
+		return use_sys ? dirty_background_bytes :
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
+	if (!__mem_cgroup_has_dirty_limit(memcg))
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
+	if (!__mem_cgroup_has_dirty_limit(memcg))
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
@@ -4581,6 +4671,30 @@ static struct cftype mem_cgroup_files[] = {
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
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
