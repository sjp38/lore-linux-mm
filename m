Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99559900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:00 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 06/13] memcg: add dirty limits to mem_cgroup
Date: Wed, 17 Aug 2011 09:14:58 -0700
Message-Id: <1313597705-6093-7-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Extend mem_cgroup to contain dirty page limits.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
Changelog since v8:
- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 mm/memcontrol.c |   50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eda0d9a..070c4ab 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -254,6 +254,13 @@ const char *scanstat_string[NR_SCANSTATS] = {
 #define SCANSTAT_WORD_SYSTEM	"_by_system"
 #define SCANSTAT_WORD_HIERARCHY	"_under_hierarchy"
 
+/* Dirty memory parameters */
+struct vm_dirty_param {
+	int dirty_ratio;
+	int dirty_background_ratio;
+	unsigned long dirty_bytes;
+	unsigned long dirty_background_bytes;
+};
 
 /*
  * The memory controller data structure. The memory controller controls both
@@ -303,6 +310,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	int	swappiness;
+
+	/* control memory cgroup dirty pages */
+	struct vm_dirty_param dirty_param;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1348,6 +1359,36 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
+/*
+ * Return true if the current memory cgroup has local dirty memory settings.
+ * There is an allowed race between the current task migrating in-to/out-of the
+ * root cgroup while this routine runs.  So the return value may be incorrect if
+ * the current task is being simultaneously migrated.
+ */
+static bool mem_cgroup_has_dirty_limit(struct mem_cgroup *memcg)
+{
+	return memcg && !mem_cgroup_is_root(memcg);
+}
+
+/*
+ * Returns a snapshot of the current dirty limits which is not synchronized with
+ * the routines that change the dirty limits.  If this routine races with an
+ * update to the dirty bytes/ratio value, then the caller must handle the case
+ * where neither dirty_[background_]_ratio nor _bytes are set.
+ */
+static void mem_cgroup_dirty_param(struct vm_dirty_param *param,
+				   struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_has_dirty_limit(memcg)) {
+		*param = memcg->dirty_param;
+	} else {
+		param->dirty_ratio = vm_dirty_ratio;
+		param->dirty_bytes = vm_dirty_bytes;
+		param->dirty_background_ratio = dirty_background_ratio;
+		param->dirty_background_bytes = dirty_background_bytes;
+	}
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
@@ -5220,8 +5261,15 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
-	if (parent)
+	if (parent) {
 		mem->swappiness = mem_cgroup_swappiness(parent);
+		mem_cgroup_dirty_param(&mem->dirty_param, parent);
+	} else {
+		/*
+		 * The root cgroup dirty_param field is not used, instead,
+		 * system-wide dirty limits are used.
+		 */
+	}
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
