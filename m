Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 5D9E96B00AC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:51:30 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch v2 02/14] cpuset: use N_MEMORY instead N_HIGH_MEMORY
Date: Thu, 15 Nov 2012 16:57:25 +0800
Message-Id: <1352969857-26623-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
References: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 Documentation/cgroups/cpusets.txt |  2 +-
 include/linux/cpuset.h            |  2 +-
 kernel/cpuset.c                   | 32 ++++++++++++++++----------------
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/Documentation/cgroups/cpusets.txt b/Documentation/cgroups/cpusets.txt
index cefd3d8..12e01d4 100644
--- a/Documentation/cgroups/cpusets.txt
+++ b/Documentation/cgroups/cpusets.txt
@@ -218,7 +218,7 @@ and name space for cpusets, with a minimum of additional kernel code.
 The cpus and mems files in the root (top_cpuset) cpuset are
 read-only.  The cpus file automatically tracks the value of
 cpu_online_mask using a CPU hotplug notifier, and the mems file
-automatically tracks the value of node_states[N_HIGH_MEMORY]--i.e.,
+automatically tracks the value of node_states[N_MEMORY]--i.e.,
 nodes with memory--using the cpuset_track_online_nodes() hook.
 
 
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 838320f..8c8a60d 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -144,7 +144,7 @@ static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
 	return node_possible_map;
 }
 
-#define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
+#define cpuset_current_mems_allowed (node_states[N_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
 
 static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f33c715..2b133db 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -302,10 +302,10 @@ static void guarantee_online_cpus(const struct cpuset *cs,
  * are online, with memory.  If none are online with memory, walk
  * up the cpuset hierarchy until we find one that does have some
  * online mems.  If we get all the way to the top and still haven't
- * found any online mems, return node_states[N_HIGH_MEMORY].
+ * found any online mems, return node_states[N_MEMORY].
  *
  * One way or another, we guarantee to return some non-empty subset
- * of node_states[N_HIGH_MEMORY].
+ * of node_states[N_MEMORY].
  *
  * Call with callback_mutex held.
  */
@@ -313,14 +313,14 @@ static void guarantee_online_cpus(const struct cpuset *cs,
 static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
 {
 	while (cs && !nodes_intersects(cs->mems_allowed,
-					node_states[N_HIGH_MEMORY]))
+					node_states[N_MEMORY]))
 		cs = cs->parent;
 	if (cs)
 		nodes_and(*pmask, cs->mems_allowed,
-					node_states[N_HIGH_MEMORY]);
+					node_states[N_MEMORY]);
 	else
-		*pmask = node_states[N_HIGH_MEMORY];
-	BUG_ON(!nodes_intersects(*pmask, node_states[N_HIGH_MEMORY]));
+		*pmask = node_states[N_MEMORY];
+	BUG_ON(!nodes_intersects(*pmask, node_states[N_MEMORY]));
 }
 
 /*
@@ -1100,7 +1100,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 		return -ENOMEM;
 
 	/*
-	 * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
+	 * top_cpuset.mems_allowed tracks node_stats[N_MEMORY];
 	 * it's read-only
 	 */
 	if (cs == &top_cpuset) {
@@ -1122,7 +1122,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			goto done;
 
 		if (!nodes_subset(trialcs->mems_allowed,
-				node_states[N_HIGH_MEMORY])) {
+				node_states[N_MEMORY])) {
 			retval =  -EINVAL;
 			goto done;
 		}
@@ -2034,7 +2034,7 @@ static struct cpuset *cpuset_next(struct list_head *queue)
  * before dropping down to the next.  It always processes a node before
  * any of its children.
  *
- * In the case of memory hot-unplug, it will remove nodes from N_HIGH_MEMORY
+ * In the case of memory hot-unplug, it will remove nodes from N_MEMORY
  * if all present pages from a node are offlined.
  */
 static void
@@ -2073,7 +2073,7 @@ scan_cpusets_upon_hotplug(struct cpuset *root, enum hotplug_event event)
 
 			/* Continue past cpusets with all mems online */
 			if (nodes_subset(cp->mems_allowed,
-					node_states[N_HIGH_MEMORY]))
+					node_states[N_MEMORY]))
 				continue;
 
 			oldmems = cp->mems_allowed;
@@ -2081,7 +2081,7 @@ scan_cpusets_upon_hotplug(struct cpuset *root, enum hotplug_event event)
 			/* Remove offline mems from this cpuset. */
 			mutex_lock(&callback_mutex);
 			nodes_and(cp->mems_allowed, cp->mems_allowed,
-						node_states[N_HIGH_MEMORY]);
+						node_states[N_MEMORY]);
 			mutex_unlock(&callback_mutex);
 
 			/* Move tasks from the empty cpuset to a parent */
@@ -2134,8 +2134,8 @@ void cpuset_update_active_cpus(bool cpu_online)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
- * Keep top_cpuset.mems_allowed tracking node_states[N_HIGH_MEMORY].
- * Call this routine anytime after node_states[N_HIGH_MEMORY] changes.
+ * Keep top_cpuset.mems_allowed tracking node_states[N_MEMORY].
+ * Call this routine anytime after node_states[N_MEMORY] changes.
  * See cpuset_update_active_cpus() for CPU hotplug handling.
  */
 static int cpuset_track_online_nodes(struct notifier_block *self,
@@ -2148,7 +2148,7 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 	case MEM_ONLINE:
 		oldmems = top_cpuset.mems_allowed;
 		mutex_lock(&callback_mutex);
-		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
+		top_cpuset.mems_allowed = node_states[N_MEMORY];
 		mutex_unlock(&callback_mutex);
 		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
 		break;
@@ -2177,7 +2177,7 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 void __init cpuset_init_smp(void)
 {
 	cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
-	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
+	top_cpuset.mems_allowed = node_states[N_MEMORY];
 
 	hotplug_memory_notifier(cpuset_track_online_nodes, 10);
 
@@ -2245,7 +2245,7 @@ void cpuset_init_current_mems_allowed(void)
  *
  * Description: Returns the nodemask_t mems_allowed of the cpuset
  * attached to the specified @tsk.  Guaranteed to return some non-empty
- * subset of node_states[N_HIGH_MEMORY], even if this means going outside the
+ * subset of node_states[N_MEMORY], even if this means going outside the
  * tasks cpuset.
  **/
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
