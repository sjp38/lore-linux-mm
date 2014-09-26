Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 893396B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:51:13 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id lj1so4944755pab.9
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:51:13 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hb4si9618841pac.178.2014.09.26.07.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 07:51:12 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/4] cpuset: convert callback_mutex to a spinlock
Date: Fri, 26 Sep 2014 18:50:52 +0400
Message-ID: <778e648ce62511c7aff225ca067e0abedb247f25.1411741632.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411741632.git.vdavydov@parallels.com>
References: <cover.1411741632.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The callback_mutex is only used to synchronize reads/updates of cpusets'
flags and cpu/node masks. These operations should always proceed fast so
there's no reason why we can't use a spinlock instead of the mutex.

Converting the callback_mutex into a spinlock will let us call
cpuset_zone_allowed_softwall from atomic context. This, in turn, makes
it possible to simplify the code by merging the hardwall and asoftwall
checks into the same function, which is the business of the next patch.

Suggested-by: Li Zefan <lizefan@huawei.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/cpuset.c |  107 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 55 insertions(+), 52 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 22874d7cf2c0..1c45774ee117 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -248,34 +248,34 @@ static struct cpuset top_cpuset = {
 		if (is_cpuset_online(((des_cs) = css_cs((pos_css)))))
 
 /*
- * There are two global mutexes guarding cpuset structures - cpuset_mutex
- * and callback_mutex.  The latter may nest inside the former.  We also
- * require taking task_lock() when dereferencing a task's cpuset pointer.
- * See "The task_lock() exception", at the end of this comment.
+ * There are two global locks guarding cpuset structures - cpuset_mutex and
+ * callback_lock. We also require taking task_lock() when dereferencing a
+ * task's cpuset pointer. See "The task_lock() exception", at the end of this
+ * comment.
  *
- * A task must hold both mutexes to modify cpusets.  If a task holds
+ * A task must hold both locks to modify cpusets.  If a task holds
  * cpuset_mutex, then it blocks others wanting that mutex, ensuring that it
- * is the only task able to also acquire callback_mutex and be able to
+ * is the only task able to also acquire callback_lock and be able to
  * modify cpusets.  It can perform various checks on the cpuset structure
  * first, knowing nothing will change.  It can also allocate memory while
  * just holding cpuset_mutex.  While it is performing these checks, various
- * callback routines can briefly acquire callback_mutex to query cpusets.
- * Once it is ready to make the changes, it takes callback_mutex, blocking
+ * callback routines can briefly acquire callback_lock to query cpusets.
+ * Once it is ready to make the changes, it takes callback_lock, blocking
  * everyone else.
  *
  * Calls to the kernel memory allocator can not be made while holding
- * callback_mutex, as that would risk double tripping on callback_mutex
+ * callback_lock, as that would risk double tripping on callback_lock
  * from one of the callbacks into the cpuset code from within
  * __alloc_pages().
  *
- * If a task is only holding callback_mutex, then it has read-only
+ * If a task is only holding callback_lock, then it has read-only
  * access to cpusets.
  *
  * Now, the task_struct fields mems_allowed and mempolicy may be changed
  * by other task, we use alloc_lock in the task_struct fields to protect
  * them.
  *
- * The cpuset_common_file_read() handlers only hold callback_mutex across
+ * The cpuset_common_file_read() handlers only hold callback_lock across
  * small pieces of code, such as when reading out possibly multi-word
  * cpumasks and nodemasks.
  *
@@ -284,7 +284,7 @@ static struct cpuset top_cpuset = {
  */
 
 static DEFINE_MUTEX(cpuset_mutex);
-static DEFINE_MUTEX(callback_mutex);
+static DEFINE_SPINLOCK(callback_lock);
 
 /*
  * CPU / memory hotplug is handled asynchronously.
@@ -329,7 +329,7 @@ static struct file_system_type cpuset_fs_type = {
  * One way or another, we guarantee to return some non-empty subset
  * of cpu_online_mask.
  *
- * Call with callback_mutex held.
+ * Call with callback_lock or cpuset_mutex held.
  */
 static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
 {
@@ -347,7 +347,7 @@ static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
  * One way or another, we guarantee to return some non-empty subset
  * of node_states[N_MEMORY].
  *
- * Call with callback_mutex held.
+ * Call with callback_lock or cpuset_mutex held.
  */
 static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 {
@@ -359,7 +359,7 @@ static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 /*
  * update task's spread flag if cpuset's page/slab spread flag is set
  *
- * Called with callback_mutex/cpuset_mutex held
+ * Call with callback_lock or cpuset_mutex held.
  */
 static void cpuset_update_task_spread_flag(struct cpuset *cs,
 					struct task_struct *tsk)
@@ -875,9 +875,9 @@ static void update_cpumasks_hier(struct cpuset *cs, struct cpumask *new_cpus)
 			continue;
 		rcu_read_unlock();
 
-		mutex_lock(&callback_mutex);
+		spin_lock_irq(&callback_lock);
 		cpumask_copy(cp->effective_cpus, new_cpus);
-		mutex_unlock(&callback_mutex);
+		spin_unlock_irq(&callback_lock);
 
 		WARN_ON(!cgroup_on_dfl(cp->css.cgroup) &&
 			!cpumask_equal(cp->cpus_allowed, cp->effective_cpus));
@@ -942,9 +942,9 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	if (retval < 0)
 		return retval;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cpumask_copy(cs->cpus_allowed, trialcs->cpus_allowed);
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	/* use trialcs->cpus_allowed as a temp variable */
 	update_cpumasks_hier(cs, trialcs->cpus_allowed);
@@ -1131,9 +1131,9 @@ static void update_nodemasks_hier(struct cpuset *cs, nodemask_t *new_mems)
 			continue;
 		rcu_read_unlock();
 
-		mutex_lock(&callback_mutex);
+		spin_lock_irq(&callback_lock);
 		cp->effective_mems = *new_mems;
-		mutex_unlock(&callback_mutex);
+		spin_unlock_irq(&callback_lock);
 
 		WARN_ON(!cgroup_on_dfl(cp->css.cgroup) &&
 			!nodes_equal(cp->mems_allowed, cp->effective_mems));
@@ -1154,7 +1154,7 @@ static void update_nodemasks_hier(struct cpuset *cs, nodemask_t *new_mems)
  * mempolicies and if the cpuset is marked 'memory_migrate',
  * migrate the tasks pages to the new memory.
  *
- * Call with cpuset_mutex held.  May take callback_mutex during call.
+ * Call with cpuset_mutex held. May take callback_lock during call.
  * Will take tasklist_lock, scan tasklist for tasks in cpuset cs,
  * lock each such tasks mm->mmap_sem, scan its vma's and rebind
  * their mempolicies to the cpusets new mems_allowed.
@@ -1201,9 +1201,9 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	if (retval < 0)
 		goto done;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cs->mems_allowed = trialcs->mems_allowed;
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	/* use trialcs->mems_allowed as a temp variable */
 	update_nodemasks_hier(cs, &cs->mems_allowed);
@@ -1294,9 +1294,9 @@ static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
 	spread_flag_changed = ((is_spread_slab(cs) != is_spread_slab(trialcs))
 			|| (is_spread_page(cs) != is_spread_page(trialcs)));
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cs->flags = trialcs->flags;
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	if (!cpumask_empty(trialcs->cpus_allowed) && balance_flag_changed)
 		rebuild_sched_domains_locked();
@@ -1712,7 +1712,7 @@ static int cpuset_common_seq_show(struct seq_file *sf, void *v)
 	count = seq_get_buf(sf, &buf);
 	s = buf;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 
 	switch (type) {
 	case FILE_CPULIST:
@@ -1739,7 +1739,7 @@ static int cpuset_common_seq_show(struct seq_file *sf, void *v)
 		seq_commit(sf, -1);
 	}
 out_unlock:
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 	return ret;
 }
 
@@ -1956,12 +1956,12 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 
 	cpuset_inc();
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	if (cgroup_on_dfl(cs->css.cgroup)) {
 		cpumask_copy(cs->effective_cpus, parent->effective_cpus);
 		cs->effective_mems = parent->effective_mems;
 	}
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags))
 		goto out_unlock;
@@ -1988,10 +1988,10 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	}
 	rcu_read_unlock();
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cs->mems_allowed = parent->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
-	mutex_unlock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 out_unlock:
 	mutex_unlock(&cpuset_mutex);
 	return 0;
@@ -2030,7 +2030,7 @@ static void cpuset_css_free(struct cgroup_subsys_state *css)
 static void cpuset_bind(struct cgroup_subsys_state *root_css)
 {
 	mutex_lock(&cpuset_mutex);
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 
 	if (cgroup_on_dfl(root_css->cgroup)) {
 		cpumask_copy(top_cpuset.cpus_allowed, cpu_possible_mask);
@@ -2041,7 +2041,7 @@ static void cpuset_bind(struct cgroup_subsys_state *root_css)
 		top_cpuset.mems_allowed = top_cpuset.effective_mems;
 	}
 
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 	mutex_unlock(&cpuset_mutex);
 }
 
@@ -2126,12 +2126,12 @@ hotplug_update_tasks_legacy(struct cpuset *cs,
 {
 	bool is_empty;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cpumask_copy(cs->cpus_allowed, new_cpus);
 	cpumask_copy(cs->effective_cpus, new_cpus);
 	cs->mems_allowed = *new_mems;
 	cs->effective_mems = *new_mems;
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	/*
 	 * Don't call update_tasks_cpumask() if the cpuset becomes empty,
@@ -2168,10 +2168,10 @@ hotplug_update_tasks(struct cpuset *cs,
 	if (nodes_empty(*new_mems))
 		*new_mems = parent_cs(cs)->effective_mems;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irq(&callback_lock);
 	cpumask_copy(cs->effective_cpus, new_cpus);
 	cs->effective_mems = *new_mems;
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irq(&callback_lock);
 
 	if (cpus_updated)
 		update_tasks_cpumask(cs);
@@ -2257,21 +2257,21 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 
 	/* synchronize cpus_allowed to cpu_active_mask */
 	if (cpus_updated) {
-		mutex_lock(&callback_mutex);
+		spin_lock_irq(&callback_lock);
 		if (!on_dfl)
 			cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
 		cpumask_copy(top_cpuset.effective_cpus, &new_cpus);
-		mutex_unlock(&callback_mutex);
+		spin_unlock_irq(&callback_lock);
 		/* we don't mess with cpumasks of tasks in top_cpuset */
 	}
 
 	/* synchronize mems_allowed to N_MEMORY */
 	if (mems_updated) {
-		mutex_lock(&callback_mutex);
+		spin_lock_irq(&callback_lock);
 		if (!on_dfl)
 			top_cpuset.mems_allowed = new_mems;
 		top_cpuset.effective_mems = new_mems;
-		mutex_unlock(&callback_mutex);
+		spin_unlock_irq(&callback_lock);
 		update_tasks_nodemask(&top_cpuset);
 	}
 
@@ -2364,11 +2364,13 @@ void __init cpuset_init_smp(void)
 
 void cpuset_cpus_allowed(struct task_struct *tsk, struct cpumask *pmask)
 {
-	mutex_lock(&callback_mutex);
+	unsigned long flags;
+
+	spin_lock_irqsave(&callback_lock, flags);
 	rcu_read_lock();
 	guarantee_online_cpus(task_cs(tsk), pmask);
 	rcu_read_unlock();
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irqrestore(&callback_lock, flags);
 }
 
 void cpuset_cpus_allowed_fallback(struct task_struct *tsk)
@@ -2414,12 +2416,13 @@ void cpuset_init_current_mems_allowed(void)
 nodemask_t cpuset_mems_allowed(struct task_struct *tsk)
 {
 	nodemask_t mask;
+	unsigned long flags;
 
-	mutex_lock(&callback_mutex);
+	spin_lock_irqsave(&callback_lock, flags);
 	rcu_read_lock();
 	guarantee_online_mems(task_cs(tsk), &mask);
 	rcu_read_unlock();
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irqrestore(&callback_lock, flags);
 
 	return mask;
 }
@@ -2438,7 +2441,7 @@ int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 /*
  * nearest_hardwall_ancestor() - Returns the nearest mem_exclusive or
  * mem_hardwall ancestor to the specified cpuset.  Call holding
- * callback_mutex.  If no ancestor is mem_exclusive or mem_hardwall
+ * callback_lock.  If no ancestor is mem_exclusive or mem_hardwall
  * (an unusual configuration), then returns the root cpuset.
  */
 static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
@@ -2480,13 +2483,12 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * GFP_KERNEL allocations are not so marked, so can escape to the
  * nearest enclosing hardwalled ancestor cpuset.
  *
- * Scanning up parent cpusets requires callback_mutex.  The
+ * Scanning up parent cpusets requires callback_lock.  The
  * __alloc_pages() routine only calls here with __GFP_HARDWALL bit
  * _not_ set if it's a GFP_KERNEL allocation, and all nodes in the
  * current tasks mems_allowed came up empty on the first pass over
  * the zonelist.  So only GFP_KERNEL allocations, if all nodes in the
- * cpuset are short of memory, might require taking the callback_mutex
- * mutex.
+ * cpuset are short of memory, might require taking the callback_lock.
  *
  * The first call here from mm/page_alloc:get_page_from_freelist()
  * has __GFP_HARDWALL set in gfp_mask, enforcing hardwall cpusets,
@@ -2513,6 +2515,7 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 {
 	struct cpuset *cs;		/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
+	unsigned long flags;
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
@@ -2532,14 +2535,14 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 		return 1;
 
 	/* Not hardwall and node outside mems_allowed: scan up cpusets */
-	mutex_lock(&callback_mutex);
+	spin_lock_irqsave(&callback_lock, flags);
 
 	rcu_read_lock();
 	cs = nearest_hardwall_ancestor(task_cs(current));
 	allowed = node_isset(node, cs->mems_allowed);
 	rcu_read_unlock();
 
-	mutex_unlock(&callback_mutex);
+	spin_unlock_irqrestore(&callback_lock, flags);
 	return allowed;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
