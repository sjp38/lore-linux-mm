Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3D5206B0073
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 16:36:28 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id mc8so8771128pbc.32
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 13:36:27 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/13] cpuset: reorganize CPU / memory hotplug handling
Date: Thu,  3 Jan 2013 13:36:01 -0800
Message-Id: <1357248967-24959-8-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Reorganize hotplug path to prepare for async hotplug handling.

* Both CPU and memory hotplug handlings are collected into a single
  function - cpuset_handle_hotplug().  It doesn't take any argument
  but compares the current setttings of top_cpuset against what's
  actually available to determine what happened.  This function
  directly updates top_cpuset.  If there are CPUs or memory nodes
  which are taken down, cpuset_propagate_hotplug() in invoked on all
  !root cpusets.

* cpuset_propagate_hotplug() is responsible for updating the specified
  cpuset so that it doesn't include any resource which isn't available
  to top_cpuset.  If no CPU or memory is left after update, all tasks
  are moved to the nearest ancestor with both resources.

* update_tasks_cpumask() and update_tasks_nodemask() are now always
  called after cpus or mems masks are updated even if the cpuset
  doesn't have any task.  This is for brevity and not expected to have
  any measureable effect.

* cpu_active_mask and N_HIGH_MEMORY are read exactly once per
  cpuset_handle_hotplug() invocation, all cpusets share the same view
  of what resources are available, and cpuset_handle_hotplug() can
  handle multiple resources going up and down.  These properties will
  allow async operation.

The reorganization, while drastic, is equivalent and shouldn't cause
any behavior difference.  This will enable making hotplug handling
async and remove get_online_cpus() -> cgroup_mutex nesting.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 221 ++++++++++++++++++++++++++------------------------------
 1 file changed, 104 insertions(+), 117 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index c5edc6b..3d448e6 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -148,12 +148,6 @@ typedef enum {
 	CS_SPREAD_SLAB,
 } cpuset_flagbits_t;
 
-/* the type of hotplug event */
-enum hotplug_event {
-	CPUSET_CPU_OFFLINE,
-	CPUSET_MEM_OFFLINE,
-};
-
 /* convenient tests for these bits */
 static inline bool is_cpuset_online(const struct cpuset *cs)
 {
@@ -2059,116 +2053,131 @@ static struct cpuset *cpuset_next(struct list_head *queue)
 	return cp;
 }
 
-
-/*
- * Walk the specified cpuset subtree upon a hotplug operation (CPU/Memory
- * online/offline) and update the cpusets accordingly.
- * For regular CPU/Mem hotplug, look for empty cpusets; the tasks of such
- * cpuset must be moved to a parent cpuset.
- *
- * Called with cgroup_mutex held.  We take callback_mutex to modify
- * cpus_allowed and mems_allowed.
+/**
+ * cpuset_propagate_hotplug - propagate CPU/memory hotplug to a cpuset
+ * @cs: cpuset in interest
  *
- * This walk processes the tree from top to bottom, completing one layer
- * before dropping down to the next.  It always processes a node before
- * any of its children.
+ * Compare @cs's cpu and mem masks against top_cpuset and if some have gone
+ * offline, update @cs accordingly.  If @cs ends up with no CPU or memory,
+ * all its tasks are moved to the nearest ancestor with both resources.
  *
- * In the case of memory hot-unplug, it will remove nodes from N_MEMORY
- * if all present pages from a node are offlined.
+ * Should be called with cgroup_mutex held.
  */
-static void
-scan_cpusets_upon_hotplug(struct cpuset *root, enum hotplug_event event)
+static void cpuset_propagate_hotplug(struct cpuset *cs)
 {
-	LIST_HEAD(queue);
-	struct cpuset *cp;		/* scans cpusets being updated */
-	static nodemask_t oldmems;	/* protected by cgroup_mutex */
-
-	list_add_tail((struct list_head *)&root->stack_list, &queue);
-
-	switch (event) {
-	case CPUSET_CPU_OFFLINE:
-		while ((cp = cpuset_next(&queue)) != NULL) {
+	static cpumask_t off_cpus;
+	static nodemask_t off_mems, tmp_mems;
 
-			/* Continue past cpusets with all cpus online */
-			if (cpumask_subset(cp->cpus_allowed, cpu_active_mask))
-				continue;
+	WARN_ON_ONCE(!cgroup_lock_is_held());
 
-			/* Remove offline cpus from this cpuset. */
-			mutex_lock(&callback_mutex);
-			cpumask_and(cp->cpus_allowed, cp->cpus_allowed,
-							cpu_active_mask);
-			mutex_unlock(&callback_mutex);
+	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
+	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
 
-			/* Move tasks from the empty cpuset to a parent */
-			if (cpumask_empty(cp->cpus_allowed))
-				remove_tasks_in_empty_cpuset(cp);
-			else
-				update_tasks_cpumask(cp, NULL);
-		}
-		break;
-
-	case CPUSET_MEM_OFFLINE:
-		while ((cp = cpuset_next(&queue)) != NULL) {
-
-			/* Continue past cpusets with all mems online */
-			if (nodes_subset(cp->mems_allowed,
-					node_states[N_MEMORY]))
-				continue;
-
-			oldmems = cp->mems_allowed;
-
-			/* Remove offline mems from this cpuset. */
-			mutex_lock(&callback_mutex);
-			nodes_and(cp->mems_allowed, cp->mems_allowed,
-						node_states[N_MEMORY]);
-			mutex_unlock(&callback_mutex);
+	/* remove offline cpus from @cs */
+	if (!cpumask_empty(&off_cpus)) {
+		mutex_lock(&callback_mutex);
+		cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
+		mutex_unlock(&callback_mutex);
+		update_tasks_cpumask(cs, NULL);
+	}
 
-			/* Move tasks from the empty cpuset to a parent */
-			if (nodes_empty(cp->mems_allowed))
-				remove_tasks_in_empty_cpuset(cp);
-			else
-				update_tasks_nodemask(cp, &oldmems, NULL);
-		}
+	/* remove offline mems from @cs */
+	if (!nodes_empty(off_mems)) {
+		tmp_mems = cs->mems_allowed;
+		mutex_lock(&callback_mutex);
+		nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
+		mutex_unlock(&callback_mutex);
+		update_tasks_nodemask(cs, &tmp_mems, NULL);
 	}
+
+	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
+		remove_tasks_in_empty_cpuset(cs);
 }
 
-/*
- * The top_cpuset tracks what CPUs and Memory Nodes are online,
- * period.  This is necessary in order to make cpusets transparent
- * (of no affect) on systems that are actively using CPU hotplug
- * but making no active use of cpusets.
- *
- * The only exception to this is suspend/resume, where we don't
- * modify cpusets at all.
+/**
+ * cpuset_handle_hotplug - handle CPU/memory hot[un]plug
  *
- * This routine ensures that top_cpuset.cpus_allowed tracks
- * cpu_active_mask on each CPU hotplug (cpuhp) event.
+ * This function is called after either CPU or memory configuration has
+ * changed and updates cpuset accordingly.  The top_cpuset is always
+ * synchronized to cpu_active_mask and N_MEMORY, which is necessary in
+ * order to make cpusets transparent (of no affect) on systems that are
+ * actively using CPU hotplug but making no active use of cpusets.
  *
- * Called within get_online_cpus().  Needs to call cgroup_lock()
- * before calling generate_sched_domains().
+ * Non-root cpusets are only affected by offlining.  If any CPUs or memory
+ * nodes have been taken down, cpuset_propagate_hotplug() is invoked on all
+ * descendants.
  *
- * @cpu_online: Indicates whether this is a CPU online event (true) or
- * a CPU offline event (false).
+ * Note that CPU offlining during suspend is ignored.  We don't modify
+ * cpusets across suspend/resume cycles at all.
  */
-void cpuset_update_active_cpus(bool cpu_online)
+static void cpuset_handle_hotplug(void)
 {
-	struct sched_domain_attr *attr;
-	cpumask_var_t *doms;
-	int ndoms;
+	static cpumask_t new_cpus, tmp_cpus;
+	static nodemask_t new_mems, tmp_mems;
+	bool cpus_updated, mems_updated;
+	bool cpus_offlined, mems_offlined;
 
 	cgroup_lock();
-	mutex_lock(&callback_mutex);
-	cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
-	mutex_unlock(&callback_mutex);
 
-	if (!cpu_online)
-		scan_cpusets_upon_hotplug(&top_cpuset, CPUSET_CPU_OFFLINE);
+	/* fetch the available cpus/mems and find out which changed how */
+	cpumask_copy(&new_cpus, cpu_active_mask);
+	new_mems = node_states[N_MEMORY];
+
+	cpus_updated = !cpumask_equal(top_cpuset.cpus_allowed, &new_cpus);
+	cpus_offlined = cpumask_andnot(&tmp_cpus, top_cpuset.cpus_allowed,
+				       &new_cpus);
+
+	mems_updated = !nodes_equal(top_cpuset.mems_allowed, new_mems);
+	nodes_andnot(tmp_mems, top_cpuset.mems_allowed, new_mems);
+	mems_offlined = !nodes_empty(tmp_mems);
+
+	/* synchronize cpus_allowed to cpu_active_mask */
+	if (cpus_updated) {
+		mutex_lock(&callback_mutex);
+		cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
+		mutex_unlock(&callback_mutex);
+		/* we don't mess with cpumasks of tasks in top_cpuset */
+	}
+
+	/* synchronize mems_allowed to N_MEMORY */
+	if (mems_updated) {
+		tmp_mems = top_cpuset.mems_allowed;
+		mutex_lock(&callback_mutex);
+		top_cpuset.mems_allowed = new_mems;
+		mutex_unlock(&callback_mutex);
+		update_tasks_nodemask(&top_cpuset, &tmp_mems, NULL);
+	}
+
+	/* if cpus or mems went down, we need to propagate to descendants */
+	if (cpus_offlined || mems_offlined) {
+		struct cpuset *cs;
+		LIST_HEAD(queue);
+
+		list_add_tail(&top_cpuset.stack_list, &queue);
+		while ((cs = cpuset_next(&queue)))
+			if (cs != &top_cpuset)
+				cpuset_propagate_hotplug(cs);
+	}
 
-	ndoms = generate_sched_domains(&doms, &attr);
 	cgroup_unlock();
 
-	/* Have scheduler rebuild the domains */
-	partition_sched_domains(ndoms, doms, attr);
+	/* rebuild sched domains if cpus_allowed has changed */
+	if (cpus_updated) {
+		struct sched_domain_attr *attr;
+		cpumask_var_t *doms;
+		int ndoms;
+
+		cgroup_lock();
+		ndoms = generate_sched_domains(&doms, &attr);
+		cgroup_unlock();
+
+		partition_sched_domains(ndoms, doms, attr);
+	}
+}
+
+void cpuset_update_active_cpus(bool cpu_online)
+{
+	cpuset_handle_hotplug();
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
@@ -2180,29 +2189,7 @@ void cpuset_update_active_cpus(bool cpu_online)
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
-	static nodemask_t oldmems;	/* protected by cgroup_mutex */
-
-	cgroup_lock();
-	switch (action) {
-	case MEM_ONLINE:
-		oldmems = top_cpuset.mems_allowed;
-		mutex_lock(&callback_mutex);
-		top_cpuset.mems_allowed = node_states[N_MEMORY];
-		mutex_unlock(&callback_mutex);
-		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
-		break;
-	case MEM_OFFLINE:
-		/*
-		 * needn't update top_cpuset.mems_allowed explicitly because
-		 * scan_cpusets_upon_hotplug() will update it.
-		 */
-		scan_cpusets_upon_hotplug(&top_cpuset, CPUSET_MEM_OFFLINE);
-		break;
-	default:
-		break;
-	}
-	cgroup_unlock();
-
+	cpuset_handle_hotplug();
 	return NOTIFY_OK;
 }
 #endif
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
