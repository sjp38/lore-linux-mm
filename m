Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D81695F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 06:55:24 -0400 (EDT)
Message-ID: <49DB3077.7090800@cn.fujitsu.com>
Date: Tue, 07 Apr 2009 18:52:39 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [RFC][PATCH 3/3] cpuset,mm: update tasks' mems_allowed in time
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch fixes allocating page cache/slab object on the unallowed node
when memory spread is set by updating tasks' mems_allowed after its cpuset's
mems is changed.

In order to update tasks' mems_allowed in time, we must modify the code of
memory policy. Because the memory policy is applied in the process's context
originally. After applying this patch, one task directly manipulates anothers
mems_allowed, and we use alloc_lock in the task_struct to protect mems_allowed
and memory policy of the task.

But in the fast path, we didn't use lock to protect them, because adding a lock
may lead to performance regression. But if we don't add a lock,the task might
see no nodes when changing cpuset's mems_allowed to some non-overlapping set.
In order to avoid it, we set all new allowed nodes, then clear newly disallowed
ones.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 include/linux/cpuset.h |   13 +++-
 include/linux/sched.h  |    8 +-
 init/main.c            |    6 ++-
 kernel/cpuset.c        |  184 ++++++++++++------------------------------------
 kernel/kthread.c       |    2 +
 mm/mempolicy.c         |  134 +++++++++++++++++++++++++----------
 mm/page_alloc.c        |    5 +-
 7 files changed, 162 insertions(+), 190 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 05ea1dd..a5740fc 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -18,7 +18,6 @@
 
 extern int number_of_cpusets;	/* How many cpusets are defined in system? */
 
-extern int cpuset_init_early(void);
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
 extern void cpuset_cpus_allowed(struct task_struct *p, struct cpumask *mask);
@@ -27,7 +26,6 @@ extern void cpuset_cpus_allowed_locked(struct task_struct *p,
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 #define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
-void cpuset_update_task_memory_state(void);
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
 extern int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask);
@@ -92,9 +90,13 @@ extern void rebuild_sched_domains(void);
 
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
+static inline void set_mems_allowed(nodemask_t nodemask)
+{
+	current->mems_allowed = nodemask;
+}
+
 #else /* !CONFIG_CPUSETS */
 
-static inline int cpuset_init_early(void) { return 0; }
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
@@ -116,7 +118,6 @@ static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
 
 #define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
-static inline void cpuset_update_task_memory_state(void) {}
 
 static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
@@ -188,6 +189,10 @@ static inline void cpuset_print_task_mems_allowed(struct task_struct *p)
 {
 }
 
+static inline void set_mems_allowed(nodemask_t nodemask)
+{
+}
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2bad3f0..2ddc9d8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1300,7 +1300,8 @@ struct task_struct {
 /* Thread group tracking */
    	u32 parent_exec_id;
    	u32 self_exec_id;
-/* Protection of (de-)allocation: mm, files, fs, tty, keyrings */
+/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_allowed,
+ * mempolicy */
 	spinlock_t alloc_lock;
 
 	/* Protection of the PI data structures: */
@@ -1363,8 +1364,7 @@ struct task_struct {
 	cputime_t acct_timexpd;	/* stime + utime since last update */
 #endif
 #ifdef CONFIG_CPUSETS
-	nodemask_t mems_allowed;
-	int cpuset_mems_generation;
+	nodemask_t mems_allowed;	/* Protected by alloc_lock */
 	int cpuset_mem_spread_rotor;
 #endif
 #ifdef CONFIG_CGROUPS
@@ -1382,7 +1382,7 @@ struct task_struct {
 	struct futex_pi_state *pi_state_cache;
 #endif
 #ifdef CONFIG_NUMA
-	struct mempolicy *mempolicy;
+	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
diff --git a/init/main.c b/init/main.c
index 437af40..4c0533b 100644
--- a/init/main.c
+++ b/init/main.c
@@ -650,7 +650,6 @@ asmlinkage void __init start_kernel(void)
 #endif
 	vmalloc_init();
 	vfs_caches_init_early();
-	cpuset_init_early();
 	page_cgroup_init();
 	mem_init();
 	enable_debug_pagealloc();
@@ -857,6 +856,11 @@ static noinline int init_post(void)
 static int __init kernel_init(void * unused)
 {
 	lock_kernel();
+
+	/*
+	 * init can allocate pages on any node
+	 */
+	set_mems_allowed(node_possible_map);
 	/*
 	 * init can run on any cpu.
 	 */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 8bff8e6..7e75a41 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -97,12 +97,6 @@ struct cpuset {
 
 	struct cpuset *parent;		/* my parent */
 
-	/*
-	 * Copy of global cpuset_mems_generation as of the most
-	 * recent time this cpuset changed its mems_allowed.
-	 */
-	int mems_generation;
-
 	struct fmeter fmeter;		/* memory_pressure filter */
 
 	/* partition number for rebuild_sched_domains() */
@@ -176,27 +170,6 @@ static inline int is_spread_slab(const struct cpuset *cs)
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
-/*
- * Increment this integer everytime any cpuset changes its
- * mems_allowed value.  Users of cpusets can track this generation
- * number, and avoid having to lock and reload mems_allowed unless
- * the cpuset they're using changes generation.
- *
- * A single, global generation is needed because cpuset_attach_task() could
- * reattach a task to a different cpuset, which must not have its
- * generation numbers aliased with those of that tasks previous cpuset.
- *
- * Generations are needed for mems_allowed because one task cannot
- * modify another's memory placement.  So we must enable every task,
- * on every visit to __alloc_pages(), to efficiently check whether
- * its current->cpuset->mems_allowed has changed, requiring an update
- * of its current->mems_allowed.
- *
- * Since writes to cpuset_mems_generation are guarded by the cgroup lock
- * there is no need to mark it atomic.
- */
-static int cpuset_mems_generation;
-
 static struct cpuset top_cpuset = {
 	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
 };
@@ -228,8 +201,9 @@ static struct cpuset top_cpuset = {
  * If a task is only holding callback_mutex, then it has read-only
  * access to cpusets.
  *
- * The task_struct fields mems_allowed and mems_generation may only
- * be accessed in the context of that task, so require no locks.
+ * Now, the task_struct fields mems_allowed and mempolicy may be changed
+ * by other task, we use alloc_lock in the task_struct fields to protect
+ * them.
  *
  * The cpuset_common_file_read() handlers only hold callback_mutex across
  * small pieces of code, such as when reading out possibly multi-word
@@ -349,69 +323,6 @@ static void cpuset_update_task_spread_flag(struct cpuset *cs,
 		tsk->flags &= ~PF_SPREAD_SLAB;
 }
 
-/**
- * cpuset_update_task_memory_state - update task memory placement
- *
- * If the current tasks cpusets mems_allowed changed behind our
- * backs, update current->mems_allowed, mems_generation and task NUMA
- * mempolicy to the new value.
- *
- * Task mempolicy is updated by rebinding it relative to the
- * current->cpuset if a task has its memory placement changed.
- * Do not call this routine if in_interrupt().
- *
- * Call without callback_mutex or task_lock() held.  May be
- * called with or without cgroup_mutex held.  Thanks in part to
- * 'the_top_cpuset_hack', the task's cpuset pointer will never
- * be NULL.  This routine also might acquire callback_mutex during
- * call.
- *
- * Reading current->cpuset->mems_generation doesn't need task_lock
- * to guard the current->cpuset derefence, because it is guarded
- * from concurrent freeing of current->cpuset using RCU.
- *
- * The rcu_dereference() is technically probably not needed,
- * as I don't actually mind if I see a new cpuset pointer but
- * an old value of mems_generation.  However this really only
- * matters on alpha systems using cpusets heavily.  If I dropped
- * that rcu_dereference(), it would save them a memory barrier.
- * For all other arch's, rcu_dereference is a no-op anyway, and for
- * alpha systems not using cpusets, another planned optimization,
- * avoiding the rcu critical section for tasks in the root cpuset
- * which is statically allocated, so can't vanish, will make this
- * irrelevant.  Better to use RCU as intended, than to engage in
- * some cute trick to save a memory barrier that is impossible to
- * test, for alpha systems using cpusets heavily, which might not
- * even exist.
- *
- * This routine is needed to update the per-task mems_allowed data,
- * within the tasks context, when it is trying to allocate memory
- * (in various mm/mempolicy.c routines) and notices that some other
- * task has been modifying its cpuset.
- */
-
-void cpuset_update_task_memory_state(void)
-{
-	int my_cpusets_mem_gen;
-	struct task_struct *tsk = current;
-	struct cpuset *cs;
-
-	rcu_read_lock();
-	my_cpusets_mem_gen = task_cs(tsk)->mems_generation;
-	rcu_read_unlock();
-
-	if (my_cpusets_mem_gen != tsk->cpuset_mems_generation) {
-		mutex_lock(&callback_mutex);
-		task_lock(tsk);
-		cs = task_cs(tsk); /* Maybe changed when task not locked */
-		guarantee_online_mems(cs, &tsk->mems_allowed);
-		tsk->cpuset_mems_generation = cs->mems_generation;
-		task_unlock(tsk);
-		mutex_unlock(&callback_mutex);
-		mpol_rebind_task(tsk, &tsk->mems_allowed);
-	}
-}
-
 /*
  * is_cpuset_subset(p, q) - Is cpuset p a subset of cpuset q?
  *
@@ -1017,14 +928,6 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
  *    other task, the task_struct mems_allowed that we are hacking
  *    is for our current task, which must allocate new pages for that
  *    migrating memory region.
- *
- *    We call cpuset_update_task_memory_state() before hacking
- *    our tasks mems_allowed, so that we are assured of being in
- *    sync with our tasks cpuset, and in particular, callbacks to
- *    cpuset_update_task_memory_state() from nested page allocations
- *    won't see any mismatch of our cpuset and task mems_generation
- *    values, so won't overwrite our hacked tasks mems_allowed
- *    nodemask.
  */
 
 static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
@@ -1032,22 +935,37 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 {
 	struct task_struct *tsk = current;
 
-	cpuset_update_task_memory_state();
-
-	mutex_lock(&callback_mutex);
 	tsk->mems_allowed = *to;
-	mutex_unlock(&callback_mutex);
 
 	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
 
-	mutex_lock(&callback_mutex);
 	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
-	mutex_unlock(&callback_mutex);
 }
 
 /*
- * Rebind task's vmas to cpuset's new mems_allowed, and migrate pages to new
- * nodes if memory_migrate flag is set. Called with cgroup_mutex held.
+ * cpuset_change_task_nodemask - change task's mems_allowed and mempolicy
+ * @tsk: the task to change
+ * @newmems: new nodes that the task will be set
+ *
+ * In order to avoid seeing no nodes if the old and new nodes are disjoint,
+ * we structure updates as setting all new allowed nodes, then clearing newly
+ * disallowed ones.
+ *
+ * Called with task's alloc_lock held
+ */
+static void cpuset_change_task_nodemask(struct task_struct *tsk,
+					nodemask_t *newmems)
+{
+	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
+	mpol_rebind_task(tsk, &tsk->mems_allowed);
+	mpol_rebind_task(tsk, newmems);
+	tsk->mems_allowed = *newmems;
+}
+
+/*
+ * Update task's mems_allowed and rebind its mempolicy and vmas' mempolicy
+ * of it to cpuset's new mems_allowed, and migrate pages to new nodes if
+ * memory_migrate flag is set. Called with cgroup_mutex held.
  */
 static void cpuset_change_nodemask(struct task_struct *p,
 				   struct cgroup_scanner *scan)
@@ -1056,12 +974,19 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
+	nodemask_t newmems;
+
+	cs = cgroup_cs(scan->cg);
+	guarantee_online_mems(cs, &newmems);
+
+	task_lock(p);
+	cpuset_change_task_nodemask(p, &newmems);
+	task_unlock(p);
 
 	mm = get_task_mm(p);
 	if (!mm)
 		return;
 
-	cs = cgroup_cs(scan->cg);
 	migrate = is_memory_migrate(cs);
 
 	mpol_rebind_mm(mm, &cs->mems_allowed);
@@ -1114,10 +1039,10 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 /*
  * Handle user request to change the 'mems' memory placement
  * of a cpuset.  Needs to validate the request, update the
- * cpusets mems_allowed and mems_generation, and for each
- * task in the cpuset, rebind any vma mempolicies and if
- * the cpuset is marked 'memory_migrate', migrate the tasks
- * pages to the new memory.
+ * cpusets mems_allowed, and for each task in the cpuset,
+ * update mems_allowed and rebind task's mempolicy and any vma
+ * mempolicies and if the cpuset is marked 'memory_migrate',
+ * migrate the tasks pages to the new memory.
  *
  * Call with cgroup_mutex held.  May take callback_mutex during call.
  * Will take tasklist_lock, scan tasklist for tasks in cpuset cs,
@@ -1170,7 +1095,6 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 
 	mutex_lock(&callback_mutex);
 	cs->mems_allowed = trialcs->mems_allowed;
-	cs->mems_generation = cpuset_mems_generation++;
 	mutex_unlock(&callback_mutex);
 
 	update_tasks_nodemask(cs, &oldmem, &heap);
@@ -1434,15 +1358,18 @@ static void cpuset_attach(struct cgroup_subsys *ss,
 
 	if (cs == &top_cpuset) {
 		cpumask_copy(cpus_attach, cpu_possible_mask);
+		to = node_possible_map;
 	} else {
-		mutex_lock(&callback_mutex);
 		guarantee_online_cpus(cs, cpus_attach);
-		mutex_unlock(&callback_mutex);
+		guarantee_online_mems(cs, &to);
 	}
 	err = set_cpus_allowed_ptr(tsk, cpus_attach);
 	if (err)
 		return;
 
+	task_lock(tsk);
+	cpuset_change_task_nodemask(tsk, &to);
+	task_unlock(tsk);
 	cpuset_update_task_spread_flag(cs, tsk);
 
 	from = oldcs->mems_allowed;
@@ -1848,8 +1775,6 @@ static struct cgroup_subsys_state *cpuset_create(
 	struct cpuset *parent;
 
 	if (!cont->parent) {
-		/* This is early initialization for the top cgroup */
-		top_cpuset.mems_generation = cpuset_mems_generation++;
 		return &top_cpuset.css;
 	}
 	parent = cgroup_cs(cont->parent);
@@ -1861,7 +1786,6 @@ static struct cgroup_subsys_state *cpuset_create(
 		return ERR_PTR(-ENOMEM);
 	}
 
-	cpuset_update_task_memory_state();
 	cs->flags = 0;
 	if (is_spread_page(parent))
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
@@ -1870,7 +1794,6 @@ static struct cgroup_subsys_state *cpuset_create(
 	set_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
-	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
 	cs->relax_domain_level = -1;
 
@@ -1889,8 +1812,6 @@ static void cpuset_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
 {
 	struct cpuset *cs = cgroup_cs(cont);
 
-	cpuset_update_task_memory_state();
-
 	if (is_sched_load_balance(cs))
 		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
 
@@ -1911,21 +1832,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.early_init = 1,
 };
 
-/*
- * cpuset_init_early - just enough so that the calls to
- * cpuset_update_task_memory_state() in early init code
- * are harmless.
- */
-
-int __init cpuset_init_early(void)
-{
-	alloc_bootmem_cpumask_var(&top_cpuset.cpus_allowed);
-
-	top_cpuset.mems_generation = cpuset_mems_generation++;
-	return 0;
-}
-
-
 /**
  * cpuset_init - initialize cpusets at system boot
  *
@@ -1936,11 +1842,13 @@ int __init cpuset_init(void)
 {
 	int err = 0;
 
+	if (!alloc_cpumask_var(&top_cpuset.cpus_allowed, GFP_KERNEL))
+		BUG();
+
 	cpumask_setall(top_cpuset.cpus_allowed);
 	nodes_setall(top_cpuset.mems_allowed);
 
 	fmeter_init(&top_cpuset.fmeter);
-	top_cpuset.mems_generation = cpuset_mems_generation++;
 	set_bit(CS_SCHED_LOAD_BALANCE, &top_cpuset.flags);
 	top_cpuset.relax_domain_level = -1;
 
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 4ebaf85..b1da8aa 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -13,6 +13,7 @@
 #include <linux/file.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/cpuset.h>
 #include <trace/sched.h>
 
 #define KTHREAD_NICE_LEVEL (-5)
@@ -239,6 +240,7 @@ int kthreadd(void *unused)
 	ignore_signals(tsk);
 	set_user_nice(tsk, KTHREAD_NICE_LEVEL);
 	set_cpus_allowed_ptr(tsk, cpu_all_mask);
+	set_mems_allowed(node_possible_map);
 
 	current->flags |= PF_NOFREEZE | PF_FREEZER_NOSIG;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3eb4a6f..8a5d2b8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -181,14 +181,47 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
 	pol->v.nodes = *nodes;
 	return 0;
 }
+/*
+ * This function is called after mpol_new(). The parameter -- nodes needn't
+ * been check because mpol_new() has done it. Maybe this implement is ugly.
+ *
+ * We use task's alloc_lock to protect task's mems_allowed and mempolicy.
+ * so this function should be called with task's alloc_lock held.
+ */
+static int mpol_new_mempolicy(struct mempolicy *pol, const nodemask_t *nodes)
+{
+	nodemask_t cpuset_context_nmask;
+	int ret;
+
+	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
+	if (pol == NULL)
+		return 0;
+
+	if (nodes) {
+		if (pol->flags & MPOL_F_RELATIVE_NODES)
+			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
+					       &cpuset_current_mems_allowed);
+		else
+			nodes_and(cpuset_context_nmask, *nodes,
+				  cpuset_current_mems_allowed);
+		if (mpol_store_user_nodemask(pol))
+			pol->w.user_nodemask = *nodes;
+		else
+			pol->w.cpuset_mems_allowed =
+						cpuset_current_mems_allowed;
+	}
+
+	ret = mpol_ops[pol->mode].create(pol,
+				nodes ? &cpuset_context_nmask : NULL);
+	return ret;
+}
 
-/* Create a new policy */
+/* This function just creates a new policy, does some check and simple
+ * initializtion. You must invoke mpol_new_mempolicy to set nodes */
 static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 				  nodemask_t *nodes)
 {
 	struct mempolicy *policy;
-	nodemask_t cpuset_context_nmask;
-	int ret;
 
 	pr_debug("setting mode %d flags %d nodes[0] %lx\n",
 		 mode, flags, nodes ? nodes_addr(*nodes)[0] : -1);
@@ -221,30 +254,6 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 	policy->mode = mode;
 	policy->flags = flags;
 
-	if (nodes) {
-		/*
-		 * cpuset related setup doesn't apply to local allocation
-		 */
-		cpuset_update_task_memory_state();
-		if (flags & MPOL_F_RELATIVE_NODES)
-			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
-					       &cpuset_current_mems_allowed);
-		else
-			nodes_and(cpuset_context_nmask, *nodes,
-				  cpuset_current_mems_allowed);
-		if (mpol_store_user_nodemask(policy))
-			policy->w.user_nodemask = *nodes;
-		else
-			policy->w.cpuset_mems_allowed =
-						cpuset_mems_allowed(current);
-	}
-
-	ret = mpol_ops[mode].create(policy,
-				nodes ? &cpuset_context_nmask : NULL);
-	if (ret < 0) {
-		kmem_cache_free(policy_cache, policy);
-		return ERR_PTR(ret);
-	}
 	return policy;
 }
 
@@ -324,6 +333,8 @@ static void mpol_rebind_policy(struct mempolicy *pol,
 /*
  * Wrapper for mpol_rebind_policy() that just requires task
  * pointer, and updates task mempolicy.
+ *
+ * Called with task's alloc_lock held.
  */
 
 void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
@@ -600,8 +611,9 @@ static void mpol_set_task_struct_flag(void)
 static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 			     nodemask_t *nodes)
 {
-	struct mempolicy *new;
+	struct mempolicy *new, *old;
 	struct mm_struct *mm = current->mm;
+	int ret;
 
 	new = mpol_new(mode, flags, nodes);
 	if (IS_ERR(new))
@@ -615,20 +627,33 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	 */
 	if (mm)
 		down_write(&mm->mmap_sem);
-	mpol_put(current->mempolicy);
+	task_lock(current);
+	ret = mpol_new_mempolicy(new, nodes);
+	if (ret) {
+		task_unlock(current);
+		if (mm)
+			up_write(&mm->mmap_sem);
+		mpol_put(new);
+		return ret;
+	}
+	old = current->mempolicy;
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
 		current->il_next = first_node(new->v.nodes);
+	task_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
 
+	mpol_put(old);
 	return 0;
 }
 
 /*
  * Return nodemask for policy for get_mempolicy() query
+ *
+ * Called with task's alloc_lock held
  */
 static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
@@ -674,7 +699,6 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
 
-	cpuset_update_task_memory_state();
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
 		return -EINVAL;
@@ -683,7 +707,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
 			return -EINVAL;
 		*policy = 0;	/* just so it's initialized */
+		task_lock(current);
 		*nmask  = cpuset_current_mems_allowed;
+		task_unlock(current);
 		return 0;
 	}
 
@@ -738,8 +764,11 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
 	err = 0;
-	if (nmask)
+	if (nmask) {
+		task_lock(current);
 		get_policy_nodemask(pol, nmask);
+		task_unlock(current);
+	}
 
  out:
 	mpol_cond_put(pol);
@@ -979,6 +1008,14 @@ static long do_mbind(unsigned long start, unsigned long len,
 			return err;
 	}
 	down_write(&mm->mmap_sem);
+	task_lock(current);
+	err = mpol_new_mempolicy(new, nmask);
+	task_unlock(current);
+	if (err) {
+		up_write(&mm->mmap_sem);
+		mpol_put(new);
+		return err;
+	}
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
@@ -1545,8 +1582,6 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
 
-	cpuset_update_task_memory_state();
-
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
@@ -1593,8 +1628,6 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
 
-	if ((gfp & __GFP_WAIT) && !in_interrupt())
-		cpuset_update_task_memory_state();
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
 
@@ -1854,6 +1887,8 @@ restart:
  */
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 {
+	int ret;
+
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
 	spin_lock_init(&sp->lock);
 
@@ -1863,9 +1898,19 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 
 		/* contextualize the tmpfs mount point mempolicy */
 		new = mpol_new(mpol->mode, mpol->flags, &mpol->w.user_nodemask);
-		mpol_put(mpol);	/* drop our ref on sb mpol */
-		if (IS_ERR(new))
+		if (IS_ERR(new)) {
+			mpol_put(mpol);	/* drop our ref on sb mpol */
 			return;		/* no valid nodemask intersection */
+		}
+
+		task_lock(current);
+		ret = mpol_new_mempolicy(new, &mpol->w.user_nodemask);
+		task_unlock(current);
+		mpol_put(mpol);	/* drop our ref on sb mpol */
+		if (ret) {
+			mpol_put(new);
+			return;
+		}
 
 		/* Create pseudo-vma that contains just the policy */
 		memset(&pvma, 0, sizeof(struct vm_area_struct));
@@ -2086,8 +2131,19 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 	new = mpol_new(mode, mode_flags, &nodes);
 	if (IS_ERR(new))
 		err = 1;
-	else if (no_context)
-		new->w.user_nodemask = nodes;	/* save for contextualization */
+	else {
+		int ret;
+
+		task_lock(current);
+		ret = mpol_new_mempolicy(new, &nodes);
+		task_unlock(current);
+		if (ret)
+			err = 1;
+		else if (no_context) {
+			/* save for contextualization */
+			new->w.user_nodemask = nodes;
+		}
+	}
 
 out:
 	/* Restore string for error message */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ad6817e..f8893fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1632,10 +1632,7 @@ nofail_alloc:
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
-	/*
-	 * The task's cpuset might have expanded its set of allowable nodes
-	 */
-	cpuset_update_task_memory_state();
+
 	p->flags |= PF_MEMALLOC;
 
 	lockdep_set_current_reclaim_state(gfp_mask);
-- 
1.6.0.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
