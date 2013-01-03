Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B26BA6B0070
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 16:36:41 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so8845512pad.26
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 13:36:40 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 13/13] cpuset: replace cgroup_mutex locking with cpuset internal locking
Date: Thu,  3 Jan 2013 13:36:07 -0800
Message-Id: <1357248967-24959-14-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Supposedly for historical reasons, cpuset depends on cgroup core for
locking.  It depends on cgroup_mutex in cgroup callbacks and grabs
cgroup_mutex from other places where it wants to be synchronized.
This is majorly messy and highly prone to introducing circular locking
dependency especially because cgroup_mutex is supposed to be one of
the outermost locks.

As previous patches already plugged possible races which may happen by
decoupling from cgroup_mutex, replacing cgroup_mutex with cpuset
specific cpuset_mutex is mostly straight-forward.  Introduce
cpuset_mutex, replace all occurrences of cgroup_mutex with it, and add
cpuset_mutex locking to places which inherited cgroup_mutex from
cgroup core.

The only complication is from cpuset wanting to initiate task
migration when a cpuset loses all cpus or memory nodes.  Task
migration may go through full cgroup and all subsystem locking and
should be initiated without holding any cpuset specific lock; however,
a previous patch already made hotplug handled asynchronously and
moving the task migration part outside other locks is easy.
cpuset_propagate_hotplug_workfn() now invokes
remove_tasks_in_empty_cpuset() without holding any lock.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 188 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 107 insertions(+), 81 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 94dd6b5..58aa99b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -208,23 +208,20 @@ static struct cpuset top_cpuset = {
 		if (is_cpuset_online(((child_cs) = cgroup_cs((pos_cgrp)))))
 
 /*
- * There are two global mutexes guarding cpuset structures.  The first
- * is the main control groups cgroup_mutex, accessed via
- * cgroup_lock()/cgroup_unlock().  The second is the cpuset-specific
- * callback_mutex, below. They can nest.  It is ok to first take
- * cgroup_mutex, then nest callback_mutex.  We also require taking
- * task_lock() when dereferencing a task's cpuset pointer.  See "The
- * task_lock() exception", at the end of this comment.
- *
- * A task must hold both mutexes to modify cpusets.  If a task
- * holds cgroup_mutex, then it blocks others wanting that mutex,
- * ensuring that it is the only task able to also acquire callback_mutex
- * and be able to modify cpusets.  It can perform various checks on
- * the cpuset structure first, knowing nothing will change.  It can
- * also allocate memory while just holding cgroup_mutex.  While it is
- * performing these checks, various callback routines can briefly
- * acquire callback_mutex to query cpusets.  Once it is ready to make
- * the changes, it takes callback_mutex, blocking everyone else.
+ * There are two global mutexes guarding cpuset structures - cpuset_mutex
+ * and callback_mutex.  The latter may nest inside the former.  We also
+ * require taking task_lock() when dereferencing a task's cpuset pointer.
+ * See "The task_lock() exception", at the end of this comment.
+ *
+ * A task must hold both mutexes to modify cpusets.  If a task holds
+ * cpuset_mutex, then it blocks others wanting that mutex, ensuring that it
+ * is the only task able to also acquire callback_mutex and be able to
+ * modify cpusets.  It can perform various checks on the cpuset structure
+ * first, knowing nothing will change.  It can also allocate memory while
+ * just holding cpuset_mutex.  While it is performing these checks, various
+ * callback routines can briefly acquire callback_mutex to query cpusets.
+ * Once it is ready to make the changes, it takes callback_mutex, blocking
+ * everyone else.
  *
  * Calls to the kernel memory allocator can not be made while holding
  * callback_mutex, as that would risk double tripping on callback_mutex
@@ -246,6 +243,7 @@ static struct cpuset top_cpuset = {
  * guidelines for accessing subsystem state in kernel/cgroup.c
  */
 
+static DEFINE_MUTEX(cpuset_mutex);
 static DEFINE_MUTEX(callback_mutex);
 
 /*
@@ -351,7 +349,7 @@ static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
 /*
  * update task's spread flag if cpuset's page/slab spread flag is set
  *
- * Called with callback_mutex/cgroup_mutex held
+ * Called with callback_mutex/cpuset_mutex held
  */
 static void cpuset_update_task_spread_flag(struct cpuset *cs,
 					struct task_struct *tsk)
@@ -371,7 +369,7 @@ static void cpuset_update_task_spread_flag(struct cpuset *cs,
  *
  * One cpuset is a subset of another if all its allowed CPUs and
  * Memory Nodes are a subset of the other, and its exclusive flags
- * are only set if the other's are set.  Call holding cgroup_mutex.
+ * are only set if the other's are set.  Call holding cpuset_mutex.
  */
 
 static int is_cpuset_subset(const struct cpuset *p, const struct cpuset *q)
@@ -420,7 +418,7 @@ static void free_trial_cpuset(struct cpuset *trial)
  * If we replaced the flag and mask values of the current cpuset
  * (cur) with those values in the trial cpuset (trial), would
  * our various subset and exclusive rules still be valid?  Presumes
- * cgroup_mutex held.
+ * cpuset_mutex held.
  *
  * 'cur' is the address of an actual, in-use cpuset.  Operations
  * such as list traversal that depend on the actual address of the
@@ -555,7 +553,7 @@ update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
  * domains when operating in the severe memory shortage situations
  * that could cause allocation failures below.
  *
- * Must be called with cgroup_lock held.
+ * Must be called with cpuset_mutex held.
  *
  * The three key local variables below are:
  *    q  - a linked-list queue of cpuset pointers, used to implement a
@@ -766,7 +764,7 @@ done:
  * 'cpus' is removed, then call this routine to rebuild the
  * scheduler's dynamic sched domains.
  *
- * Call with cgroup_mutex held.  Takes get_online_cpus().
+ * Call with cpuset_mutex held.  Takes get_online_cpus().
  */
 static void rebuild_sched_domains_locked(void)
 {
@@ -774,7 +772,7 @@ static void rebuild_sched_domains_locked(void)
 	cpumask_var_t *doms;
 	int ndoms;
 
-	WARN_ON_ONCE(!cgroup_lock_is_held());
+	lockdep_assert_held(&cpuset_mutex);
 	get_online_cpus();
 
 	/* Generate domain masks and attrs */
@@ -800,9 +798,9 @@ static int generate_sched_domains(cpumask_var_t **domains,
 
 void rebuild_sched_domains(void)
 {
-	cgroup_lock();
+	mutex_lock(&cpuset_mutex);
 	rebuild_sched_domains_locked();
-	cgroup_unlock();
+	mutex_unlock(&cpuset_mutex);
 }
 
 /**
@@ -810,7 +808,7 @@ void rebuild_sched_domains(void)
  * @tsk: task to test
  * @scan: struct cgroup_scanner contained in its struct cpuset_hotplug_scanner
  *
- * Call with cgroup_mutex held.  May take callback_mutex during call.
+ * Call with cpuset_mutex held.  May take callback_mutex during call.
  * Called for each task in a cgroup by cgroup_scan_tasks().
  * Return nonzero if this tasks's cpus_allowed mask should be changed (in other
  * words, if its mask is not equal to its cpuset's mask).
@@ -831,7 +829,7 @@ static int cpuset_test_cpumask(struct task_struct *tsk,
  * cpus_allowed mask needs to be changed.
  *
  * We don't need to re-check for the cgroup/cpuset membership, since we're
- * holding cgroup_lock() at this point.
+ * holding cpuset_mutex at this point.
  */
 static void cpuset_change_cpumask(struct task_struct *tsk,
 				  struct cgroup_scanner *scan)
@@ -844,7 +842,7 @@ static void cpuset_change_cpumask(struct task_struct *tsk,
  * @cs: the cpuset in which each task's cpus_allowed mask needs to be changed
  * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
  *
- * Called with cgroup_mutex held
+ * Called with cpuset_mutex held
  *
  * The cgroup_scan_tasks() function will scan all the tasks in a cgroup,
  * calling callback functions for each.
@@ -934,7 +932,7 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
  *    Temporarilly set tasks mems_allowed to target nodes of migration,
  *    so that the migration code can allocate pages on these nodes.
  *
- *    Call holding cgroup_mutex, so current's cpuset won't change
+ *    Call holding cpuset_mutex, so current's cpuset won't change
  *    during this call, as manage_mutex holds off any cpuset_attach()
  *    calls.  Therefore we don't need to take task_lock around the
  *    call to guarantee_online_mems(), as we know no one is changing
@@ -1009,7 +1007,7 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 /*
  * Update task's mems_allowed and rebind its mempolicy and vmas' mempolicy
  * of it to cpuset's new mems_allowed, and migrate pages to new nodes if
- * memory_migrate flag is set. Called with cgroup_mutex held.
+ * memory_migrate flag is set. Called with cpuset_mutex held.
  */
 static void cpuset_change_nodemask(struct task_struct *p,
 				   struct cgroup_scanner *scan)
@@ -1018,7 +1016,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
-	static nodemask_t newmems;	/* protected by cgroup_mutex */
+	static nodemask_t newmems;	/* protected by cpuset_mutex */
 
 	cs = cgroup_cs(scan->cg);
 	guarantee_online_mems(cs, &newmems);
@@ -1045,7 +1043,7 @@ static void *cpuset_being_rebound;
  * @oldmem: old mems_allowed of cpuset cs
  * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
  *
- * Called with cgroup_mutex held
+ * Called with cpuset_mutex held
  * No return value. It's guaranteed that cgroup_scan_tasks() always returns 0
  * if @heap != NULL.
  */
@@ -1067,7 +1065,7 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 	 * take while holding tasklist_lock.  Forks can happen - the
 	 * mpol_dup() cpuset_being_rebound check will catch such forks,
 	 * and rebind their vma mempolicies too.  Because we still hold
-	 * the global cgroup_mutex, we know that no other rebind effort
+	 * the global cpuset_mutex, we know that no other rebind effort
 	 * will be contending for the global variable cpuset_being_rebound.
 	 * It's ok if we rebind the same mm twice; mpol_rebind_mm()
 	 * is idempotent.  Also migrate pages in each mm to new nodes.
@@ -1086,7 +1084,7 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
  * mempolicies and if the cpuset is marked 'memory_migrate',
  * migrate the tasks pages to the new memory.
  *
- * Call with cgroup_mutex held.  May take callback_mutex during call.
+ * Call with cpuset_mutex held.  May take callback_mutex during call.
  * Will take tasklist_lock, scan tasklist for tasks in cpuset cs,
  * lock each such tasks mm->mmap_sem, scan its vma's and rebind
  * their mempolicies to the cpusets new mems_allowed.
@@ -1184,7 +1182,7 @@ static int update_relax_domain_level(struct cpuset *cs, s64 val)
  * Called by cgroup_scan_tasks() for each task in a cgroup.
  *
  * We don't need to re-check for the cgroup/cpuset membership, since we're
- * holding cgroup_lock() at this point.
+ * holding cpuset_mutex at this point.
  */
 static void cpuset_change_flag(struct task_struct *tsk,
 				struct cgroup_scanner *scan)
@@ -1197,7 +1195,7 @@ static void cpuset_change_flag(struct task_struct *tsk,
  * @cs: the cpuset in which each task's spread flags needs to be changed
  * @heap: if NULL, defer allocating heap memory to cgroup_scan_tasks()
  *
- * Called with cgroup_mutex held
+ * Called with cpuset_mutex held
  *
  * The cgroup_scan_tasks() function will scan all the tasks in a cgroup,
  * calling callback functions for each.
@@ -1222,7 +1220,7 @@ static void update_tasks_flags(struct cpuset *cs, struct ptr_heap *heap)
  * cs:		the cpuset to update
  * turning_on: 	whether the flag is being set or cleared
  *
- * Call with cgroup_mutex held.
+ * Call with cpuset_mutex held.
  */
 
 static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
@@ -1370,15 +1368,18 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
-/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
+/* Called by cgroups to determine if a cpuset is usable; cpuset_mutex held */
 static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct task_struct *task;
 	int ret;
 
+	mutex_lock(&cpuset_mutex);
+
+	ret = -ENOSPC;
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
-		return -ENOSPC;
+		goto out_unlock;
 
 	cgroup_taskset_for_each(task, cgrp, tset) {
 		/*
@@ -1390,10 +1391,12 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 		 * set_cpus_allowed_ptr() on all attached tasks before
 		 * cpus_allowed may be changed.
 		 */
+		ret = -EINVAL;
 		if (task->flags & PF_THREAD_BOUND)
-			return -EINVAL;
-		if ((ret = security_task_setscheduler(task)))
-			return ret;
+			goto out_unlock;
+		ret = security_task_setscheduler(task);
+		if (ret)
+			goto out_unlock;
 	}
 
 	/*
@@ -1401,18 +1404,22 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 * changes which zero cpus/mems_allowed.
 	 */
 	cs->attach_in_progress++;
-
-	return 0;
+	ret = 0;
+out_unlock:
+	mutex_unlock(&cpuset_mutex);
+	return ret;
 }
 
 static void cpuset_cancel_attach(struct cgroup *cgrp,
 				 struct cgroup_taskset *tset)
 {
+	mutex_lock(&cpuset_mutex);
 	cgroup_cs(cgrp)->attach_in_progress--;
+	mutex_unlock(&cpuset_mutex);
 }
 
 /*
- * Protected by cgroup_mutex.  cpus_attach is used only by cpuset_attach()
+ * Protected by cpuset_mutex.  cpus_attach is used only by cpuset_attach()
  * but we can't allocate it dynamically there.  Define it global and
  * allocate from cpuset_init().
  */
@@ -1420,7 +1427,7 @@ static cpumask_var_t cpus_attach;
 
 static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
-	/* static bufs protected by cgroup_mutex */
+	/* static bufs protected by cpuset_mutex */
 	static nodemask_t cpuset_attach_nodemask_from;
 	static nodemask_t cpuset_attach_nodemask_to;
 	struct mm_struct *mm;
@@ -1430,6 +1437,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *oldcs = cgroup_cs(oldcgrp);
 
+	mutex_lock(&cpuset_mutex);
+
 	/* prepare for attach */
 	if (cs == &top_cpuset)
 		cpumask_copy(cpus_attach, cpu_possible_mask);
@@ -1473,6 +1482,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	 */
 	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
 		schedule_cpuset_propagate_hotplug(cs);
+
+	mutex_unlock(&cpuset_mutex);
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -1494,12 +1505,13 @@ typedef enum {
 
 static int cpuset_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
-	int retval = 0;
 	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
+	int retval = -ENODEV;
 
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
+	mutex_lock(&cpuset_mutex);
+	if (!is_cpuset_online(cs))
+		goto out_unlock;
 
 	switch (type) {
 	case FILE_CPU_EXCLUSIVE:
@@ -1533,18 +1545,20 @@ static int cpuset_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
 		retval = -EINVAL;
 		break;
 	}
-	cgroup_unlock();
+out_unlock:
+	mutex_unlock(&cpuset_mutex);
 	return retval;
 }
 
 static int cpuset_write_s64(struct cgroup *cgrp, struct cftype *cft, s64 val)
 {
-	int retval = 0;
 	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
+	int retval = -ENODEV;
 
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
+	mutex_lock(&cpuset_mutex);
+	if (!is_cpuset_online(cs))
+		goto out_unlock;
 
 	switch (type) {
 	case FILE_SCHED_RELAX_DOMAIN_LEVEL:
@@ -1554,7 +1568,8 @@ static int cpuset_write_s64(struct cgroup *cgrp, struct cftype *cft, s64 val)
 		retval = -EINVAL;
 		break;
 	}
-	cgroup_unlock();
+out_unlock:
+	mutex_unlock(&cpuset_mutex);
 	return retval;
 }
 
@@ -1564,9 +1579,9 @@ static int cpuset_write_s64(struct cgroup *cgrp, struct cftype *cft, s64 val)
 static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 				const char *buf)
 {
-	int retval = 0;
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *trialcs;
+	int retval = -ENODEV;
 
 	/*
 	 * CPU or memory hotunplug may leave @cs w/o any execution
@@ -1586,13 +1601,14 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	flush_work(&cpuset_hotplug_work);
 	flush_workqueue(cpuset_propagate_hotplug_wq);
 
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
+	mutex_lock(&cpuset_mutex);
+	if (!is_cpuset_online(cs))
+		goto out_unlock;
 
 	trialcs = alloc_trial_cpuset(cs);
 	if (!trialcs) {
 		retval = -ENOMEM;
-		goto out;
+		goto out_unlock;
 	}
 
 	switch (cft->private) {
@@ -1608,8 +1624,8 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	}
 
 	free_trial_cpuset(trialcs);
-out:
-	cgroup_unlock();
+out_unlock:
+	mutex_unlock(&cpuset_mutex);
 	return retval;
 }
 
@@ -1867,6 +1883,8 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	if (!parent)
 		return 0;
 
+	mutex_lock(&cpuset_mutex);
+
 	set_bit(CS_ONLINE, &cs->flags);
 	if (is_spread_page(parent))
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
@@ -1876,7 +1894,7 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	number_of_cpusets++;
 
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags))
-		return 0;
+		goto out_unlock;
 
 	/*
 	 * Clone @parent's configuration if CGRP_CPUSET_CLONE_CHILDREN is
@@ -1895,7 +1913,7 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	cpuset_for_each_child(tmp_cs, pos_cg, parent) {
 		if (is_mem_exclusive(tmp_cs) || is_cpu_exclusive(tmp_cs)) {
 			rcu_read_unlock();
-			return 0;
+			goto out_unlock;
 		}
 	}
 	rcu_read_unlock();
@@ -1904,7 +1922,8 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	cs->mems_allowed = parent->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
 	mutex_unlock(&callback_mutex);
-
+out_unlock:
+	mutex_unlock(&cpuset_mutex);
 	return 0;
 }
 
@@ -1912,8 +1931,7 @@ static void cpuset_css_offline(struct cgroup *cgrp)
 {
 	struct cpuset *cs = cgroup_cs(cgrp);
 
-	/* css_offline is called w/o cgroup_mutex, grab it */
-	cgroup_lock();
+	mutex_lock(&cpuset_mutex);
 
 	if (is_sched_load_balance(cs))
 		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
@@ -1921,7 +1939,7 @@ static void cpuset_css_offline(struct cgroup *cgrp)
 	number_of_cpusets--;
 	clear_bit(CS_ONLINE, &cs->flags);
 
-	cgroup_unlock();
+	mutex_unlock(&cpuset_mutex);
 }
 
 /*
@@ -1996,7 +2014,9 @@ static void cpuset_do_move_task(struct task_struct *tsk,
 {
 	struct cgroup *new_cgroup = scan->data;
 
+	cgroup_lock();
 	cgroup_attach_task(new_cgroup, tsk);
+	cgroup_unlock();
 }
 
 /**
@@ -2004,7 +2024,7 @@ static void cpuset_do_move_task(struct task_struct *tsk,
  * @from: cpuset in which the tasks currently reside
  * @to: cpuset to which the tasks will be moved
  *
- * Called with cgroup_mutex held
+ * Called with cpuset_mutex held
  * callback_mutex must not be held, as cpuset_attach() will take it.
  *
  * The cgroup_scan_tasks() function will scan all the tasks in a cgroup,
@@ -2031,9 +2051,6 @@ static void move_member_tasks_to_cpuset(struct cpuset *from, struct cpuset *to)
  * removing that CPU or node from all cpusets.  If this removes the
  * last CPU or node from a cpuset, then move the tasks in the empty
  * cpuset to its next-highest non-empty parent.
- *
- * Called with cgroup_mutex held
- * callback_mutex must not be held, as cpuset_attach() will take it.
  */
 static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 {
@@ -2089,8 +2106,9 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 	static cpumask_t off_cpus;
 	static nodemask_t off_mems, tmp_mems;
 	struct cpuset *cs = container_of(work, struct cpuset, hotplug_work);
+	bool is_empty;
 
-	cgroup_lock();
+	mutex_lock(&cpuset_mutex);
 
 	cpumask_andnot(&off_cpus, cs->cpus_allowed, top_cpuset.cpus_allowed);
 	nodes_andnot(off_mems, cs->mems_allowed, top_cpuset.mems_allowed);
@@ -2112,10 +2130,18 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
 		update_tasks_nodemask(cs, &tmp_mems, NULL);
 	}
 
-	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
-		remove_tasks_in_empty_cpuset(cs);
+	is_empty = cpumask_empty(cs->cpus_allowed) ||
+		nodes_empty(cs->mems_allowed);
 
-	cgroup_unlock();
+	mutex_unlock(&cpuset_mutex);
+
+	/*
+	 * If @cs became empty, move tasks to the nearest ancestor with
+	 * execution resources.  This is full cgroup operation which will
+	 * also call back into cpuset.  Should be done outside any lock.
+	 */
+	if (is_empty)
+		remove_tasks_in_empty_cpuset(cs);
 
 	/* the following may free @cs, should be the last operation */
 	css_put(&cs->css);
@@ -2169,7 +2195,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	bool cpus_updated, mems_updated;
 	bool cpus_offlined, mems_offlined;
 
-	cgroup_lock();
+	mutex_lock(&cpuset_mutex);
 
 	/* fetch the available cpus/mems and find out which changed how */
 	cpumask_copy(&new_cpus, cpu_active_mask);
@@ -2211,7 +2237,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 				schedule_cpuset_propagate_hotplug(cs);
 	}
 
-	cgroup_unlock();
+	mutex_unlock(&cpuset_mutex);
 
 	/* wait for propagations to finish */
 	flush_workqueue(cpuset_propagate_hotplug_wq);
@@ -2222,9 +2248,9 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 		cpumask_var_t *doms;
 		int ndoms;
 
-		cgroup_lock();
+		mutex_lock(&cpuset_mutex);
 		ndoms = generate_sched_domains(&doms, &attr);
-		cgroup_unlock();
+		mutex_unlock(&cpuset_mutex);
 
 		partition_sched_domains(ndoms, doms, attr);
 	}
@@ -2650,7 +2676,7 @@ void __cpuset_memory_pressure_bump(void)
  *  - Used for /proc/<pid>/cpuset.
  *  - No need to task_lock(tsk) on this tsk->cpuset reference, as it
  *    doesn't really matter if tsk->cpuset changes after we read it,
- *    and we take cgroup_mutex, keeping cpuset_attach() from changing it
+ *    and we take cpuset_mutex, keeping cpuset_attach() from changing it
  *    anyway.
  */
 static int proc_cpuset_show(struct seq_file *m, void *unused_v)
@@ -2673,7 +2699,7 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
 		goto out_free;
 
 	retval = -EINVAL;
-	cgroup_lock();
+	mutex_lock(&cpuset_mutex);
 	css = task_subsys_state(tsk, cpuset_subsys_id);
 	retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
 	if (retval < 0)
@@ -2681,7 +2707,7 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
 	seq_puts(m, buf);
 	seq_putc(m, '\n');
 out_unlock:
-	cgroup_unlock();
+	mutex_unlock(&cpuset_mutex);
 	put_task_struct(tsk);
 out_free:
 	kfree(buf);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
