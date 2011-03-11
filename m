Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 77BF98D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:45:18 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v6 5/9] memcg: add dirty limits to mem_cgroup
Date: Fri, 11 Mar 2011 10:43:27 -0800
Message-Id: <1299869011-26152-6-git-send-email-gthelen@google.com>
In-Reply-To: <1299869011-26152-1-git-send-email-gthelen@google.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

Extend mem_cgroup to contain dirty page limits.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Changelog since v5:
- To simplify this patch, deferred adding routines for kernel to query dirty
  usage and limits to a later patch in this series.
- Collapsed __mem_cgroup_has_dirty_limit() into mem_cgroup_has_dirty_limit().
- Renamed __mem_cgroup_dirty_param() to mem_cgroup_dirty_param().

Changelog since v4:
- Added support for hierarchical dirty limits.
- Simplified __mem_cgroup_dirty_param().
- Simplified mem_cgroup_page_stat().
- Deleted mem_cgroup_nr_pages_item enum, which was added little value.
  Instead the mem_cgroup_page_stat_item enum values are used to identify
  memcg dirty statistics exported to kernel.
- Fixed overflow issues in mem_cgroup_hierarchical_free_pages().

Changelog since v3:
- Previously memcontrol.c used struct vm_dirty_param and vm_dirty_param() to
  advertise dirty memory limits.  Now struct dirty_info and
  mem_cgroup_dirty_info() is used to share dirty limits between memcontrol and
  the rest of the kernel.
- __mem_cgroup_has_dirty_limit() now returns false if use_hierarchy is set.
- memcg_hierarchical_free_pages() now uses parent_mem_cgroup() and is simpler.
- created internal routine, __mem_cgroup_has_dirty_limit(), to consolidate the
  logic.

Changelog since v1:
- Rename (for clarity):
  - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
  - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
- Removed unnecessary get_ prefix from get_xxx() functions.
- Avoid lockdep warnings by using rcu_read_[un]lock() in
  mem_cgroup_has_dirty_limit().

 mm/memcontrol.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b8f517d..5c80622 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -203,6 +203,14 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+/* Dirty memory parameters */
+struct vm_dirty_param {
+	int dirty_ratio;
+	int dirty_background_ratio;
+	unsigned long dirty_bytes;
+	unsigned long dirty_background_bytes;
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -242,6 +250,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
+
+	/* control memory cgroup dirty pages */
+	struct vm_dirty_param dirty_param;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1198,6 +1210,36 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
+/*
+ * Return true if the current memory cgroup has local dirty memory settings.
+ * There is an allowed race between the current task migrating in-to/out-of the
+ * root cgroup while this routine runs.  So the return value may be incorrect if
+ * the current task is being simultaneously migrated.
+ */
+static bool mem_cgroup_has_dirty_limit(struct mem_cgroup *mem)
+{
+	return mem && !mem_cgroup_is_root(mem);
+}
+
+/*
+ * Returns a snapshot of the current dirty limits which is not synchronized with
+ * the routines that change the dirty limits.  If this routine races with an
+ * update to the dirty bytes/ratio value, then the caller must handle the case
+ * where neither dirty_[background_]_ratio nor _bytes are set.
+ */
+static void mem_cgroup_dirty_param(struct vm_dirty_param *param,
+				   struct mem_cgroup *mem)
+{
+	if (mem_cgroup_has_dirty_limit(mem)) {
+		*param = mem->dirty_param;
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
@@ -4669,8 +4711,15 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
-	if (parent)
+	if (parent) {
 		mem->swappiness = get_swappiness(parent);
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
