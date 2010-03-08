Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0857B6B009F
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 05:11:12 -0500 (EST)
Message-ID: <4B94CD2D.8070401@cn.fujitsu.com>
Date: Mon, 08 Mar 2010 18:10:53 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes from V1 to V2:
- Update task->mems_allowed lazily, instead of using a lock to protect it

Before applying this patch, cpuset updates task->mems_allowed by setting all
new bits in the nodemask first, and clearing all old unallowed bits later.
But in the way, the allocator is likely to see an empty nodemask.

The problem is following:
The size of nodemask_t is greater than the size of long integer, so loading
and storing of nodemask_t are not atomic operations. If task->mems_allowed
don't intersect with new_mask, such as the first word of the mask is empty
and only the first word of new_mask is not empty. When the allocator
loads a word of the mask before

	current->mems_allowed |= new_mask;

and then loads another word of the mask after

	current->mems_allowed = new_mask;

the allocator gets an empty nodemask.

Considering the change of task->mems_allowed is not frequent, so in this patch,
I use two variables as a tag to indicate whether task->mems_allowed need be
update or not. And before setting the tag, cpuset caches the new mask of every
task at its task_struct.

When the allocator want to access task->mems_allowed, it must check updated-tag
first. If the tag is set, the allocator enters the slow path and updates
task->mems_allowed.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 include/linux/cpuset.h    |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/init_task.h |   20 +++++++++++++++++++-
 include/linux/sched.h     |   41 +++++++++++++++++++++++++++++++++++++----
 kernel/cpuset.c           |   44 ++++++++++++++++++++------------------------
 kernel/fork.c             |   17 +++++++++++++++++
 mm/filemap.c              |    6 +++++-
 mm/hugetlb.c              |    2 ++
 mm/mempolicy.c            |   37 +++++++++++++++++--------------------
 mm/slab.c                 |    5 +++++
 mm/slub.c                 |    2 ++
 10 files changed, 169 insertions(+), 50 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index a5740fc..2eb0fa7 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -93,6 +93,44 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 static inline void set_mems_allowed(nodemask_t nodemask)
 {
 	current->mems_allowed = nodemask;
+	current->mems_allowed_for_update = nodemask;
+}
+
+#define task_mems_lock_irqsave(p, flags)			\
+	do {							\
+		spin_lock_irqsave(&p->mems_lock, flags);	\
+	} while (0)
+
+#define task_mems_unlock_irqrestore(p, flags)			\
+	do {							\
+		spin_unlock_irqrestore(&p->mems_lock, flags);	\
+	} while (0)
+
+#include <linux/mempolicy.h>
+/**
+ * cpuset_update_task_mems_allowed - update task memory placement
+ *
+ * If the current task's mems_allowed_for_update and mempolicy_for_update are
+ * changed by cpuset behind our backs, update current->mems_allowed,
+ * mems_generation and task NUMA mempolicy to the new value.
+ *
+ * Call WITHOUT mems_lock held.
+ * 
+ * This routine is needed to update the pre-task mems_allowed and mempolicy
+ * within the tasks context, when it is trying to allocate memory.
+ */
+static __always_inline void cpuset_update_task_mems_allowed(void)
+{
+	struct task_struct *tsk = current;
+	unsigned long flags;
+
+	if (unlikely(tsk->mems_generation != tsk->mems_generation_for_update)) {
+		task_mems_lock_irqsave(tsk, flags);
+		tsk->mems_allowed = tsk->mems_allowed_for_update;
+		tsk->mems_generation = tsk->mems_generation_for_update;
+		task_mems_unlock_irqrestore(tsk, flags);
+		mpol_rebind_task(tsk, &tsk->mems_allowed);
+	}
 }
 
 #else /* !CONFIG_CPUSETS */
@@ -193,6 +231,13 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
 
+static inline void cpuset_update_task_mems_allowed(void)
+{
+}
+
+#define task_mems_lock_irqsave(p, flags)	do { (void)(flags); } while (0)
+
+#define task_mems_unlock_irqrestore(p, flags)	do { (void)(flags); } while (0)
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index abec69b..be016f0 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -103,7 +103,7 @@ extern struct group_info init_groups;
 extern struct cred init_cred;
 
 #ifdef CONFIG_PERF_EVENTS
-# define INIT_PERF_EVENTS(tsk)					\
+# define INIT_PERF_EVENTS(tsk)						\
 	.perf_event_mutex = 						\
 		 __MUTEX_INITIALIZER(tsk.perf_event_mutex),		\
 	.perf_event_list = LIST_HEAD_INIT(tsk.perf_event_list),
@@ -111,6 +111,22 @@ extern struct cred init_cred;
 # define INIT_PERF_EVENTS(tsk)
 #endif
 
+#ifdef CONFIG_CPUSETS
+# define INIT_MEMS_ALLOWED(tsk)						\
+	.mems_lock = __SPIN_LOCK_UNLOCKED(tsk.mems_lock),		\
+	.mems_generation = 0,						\
+	.mems_generation_for_update = 0,
+#else
+# define INIT_MEMS_ALLOWED(tsk)
+#endif
+
+#ifdef CONFIG_NUMA
+# define INIT_MEMPOLICY							\
+	.mempolicy = NULL,
+#else
+# define INIT_MEMPOLICY
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -180,6 +196,8 @@ extern struct cred init_cred;
 	INIT_FTRACE_GRAPH						\
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
+	INIT_MEMS_ALLOWED(tsk)						\
+	INIT_MEMPOLICY							\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 46c6f8d..9e7f14f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1351,8 +1351,9 @@ struct task_struct {
 /* Thread group tracking */
    	u32 parent_exec_id;
    	u32 self_exec_id;
-/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_allowed,
- * mempolicy */
+/*
+ * Protection of (de-)allocation: mm, files, fs, tty, keyrings
+ */
 	spinlock_t alloc_lock;
 
 #ifdef CONFIG_GENERIC_HARDIRQS
@@ -1420,8 +1421,36 @@ struct task_struct {
 	cputime_t acct_timexpd;	/* stime + utime since last update */
 #endif
 #ifdef CONFIG_CPUSETS
-	nodemask_t mems_allowed;	/* Protected by alloc_lock */
+	/*
+	 * It is unnecessary to protect mems_allowed, because it only can be
+	 * loaded and stored by current task's self
+	 */
+	nodemask_t mems_allowed;
 	int cpuset_mem_spread_rotor;
+
+	/* Protection of ->mems_allowed_for_update */
+	spinlock_t mems_lock;
+	/*
+	 * This variable(mems_allowed_for_update) are just used for caching
+	 * memory placement information.
+	 *
+	 * ->mems_allowed are used by the kernel allocator.
+	 */
+	nodemask_t mems_allowed_for_update;	/* Protected by mems_lock */
+
+	/*
+	 * Increment this integer everytime ->mems_allowed_for_update is
+	 * changed by cpuset. Task can compare this number with mems_generation,
+	 * and if they are not the same, mems_allowed_for_update is changed and
+	 * ->mems_allowed must be updated. In this way, tasks can avoid having
+	 * to lock and reload mems_allowed_for_update unless it is changed.
+	 */
+	int mems_generation_for_update;
+	/*
+	 * After updating mems_allowed, set mems_generation to
+	 * mems_generation_for_update.
+	 */
+	int mems_generation;
 #endif
 #ifdef CONFIG_CGROUPS
 	/* Control Group info protected by css_set_lock */
@@ -1443,7 +1472,11 @@ struct task_struct {
 	struct list_head perf_event_list;
 #endif
 #ifdef CONFIG_NUMA
-	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
+	/*
+	 * It is unnecessary to protect mempolicy, because it only can be
+	 * loaded/stored by current task's self.
+	 */
+	struct mempolicy *mempolicy;
 	short il_next;
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f36e577..ff6d76b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -34,7 +34,6 @@
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
-#include <linux/mempolicy.h>
 #include <linux/mm.h>
 #include <linux/memory.h>
 #include <linux/module.h>
@@ -201,9 +200,9 @@ static struct cpuset top_cpuset = {
  * If a task is only holding callback_mutex, then it has read-only
  * access to cpusets.
  *
- * Now, the task_struct fields mems_allowed and mempolicy may be changed
- * by other task, we use alloc_lock in the task_struct fields to protect
- * them.
+ * Now, the task_struct fields mems_allowed_for_update is used to cache
+ * the new mems information,we use mems_lock in the task_struct fields to
+ * protect it.
  *
  * The cpuset_common_file_read() handlers only hold callback_mutex across
  * small pieces of code, such as when reading out possibly multi-word
@@ -939,29 +938,24 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 }
 
 /*
- * cpuset_change_task_nodemask - change task's mems_allowed and mempolicy
+ * cpuset_change_task_nodemask - change task's mems_allowed
  * @tsk: the task to change
  * @newmems: new nodes that the task will be set
  *
- * In order to avoid seeing no nodes if the old and new nodes are disjoint,
- * we structure updates as setting all new allowed nodes, then clearing newly
- * disallowed ones.
- *
- * Called with task's alloc_lock held
+ * Called with task's mems_lock held and disable interrupt.
  */
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
-	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, &tsk->mems_allowed);
-	mpol_rebind_task(tsk, newmems);
-	tsk->mems_allowed = *newmems;
+	tsk->mems_allowed_for_update = *newmems;
+
+	tsk->mems_generation_for_update++;
 }
 
 /*
- * Update task's mems_allowed and rebind its mempolicy and vmas' mempolicy
- * of it to cpuset's new mems_allowed, and migrate pages to new nodes if
- * memory_migrate flag is set. Called with cgroup_mutex held.
+ * Update task's mems_allowed and vmas' mempolicy of it to cpuset's
+ * new mems_allowed, and migrate pages to new nodes if memory_migrate
+ * flag is set. Called with cgroup_mutex held.
  */
 static void cpuset_change_nodemask(struct task_struct *p,
 				   struct cgroup_scanner *scan)
@@ -970,6 +964,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
+	unsigned long flags;
 	NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL);
 
 	if (!newmems)
@@ -978,9 +973,9 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	cs = cgroup_cs(scan->cg);
 	guarantee_online_mems(cs, newmems);
 
-	task_lock(p);
+	task_mems_lock_irqsave(p, flags);
 	cpuset_change_task_nodemask(p, newmems);
-	task_unlock(p);
+	task_mems_unlock_irqrestore(p, flags);
 
 	NODEMASK_FREE(newmems);
 
@@ -1041,9 +1036,9 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
  * Handle user request to change the 'mems' memory placement
  * of a cpuset.  Needs to validate the request, update the
  * cpusets mems_allowed, and for each task in the cpuset,
- * update mems_allowed and rebind task's mempolicy and any vma
- * mempolicies and if the cpuset is marked 'memory_migrate',
- * migrate the tasks pages to the new memory.
+ * update mems_allowed and any vma mempolicies and if the
+ * cpuset is marked 'memory_migrate', migrate the tasks pages
+ * to the new memory.
  *
  * Call with cgroup_mutex held.  May take callback_mutex during call.
  * Will take tasklist_lock, scan tasklist for tasks in cpuset cs,
@@ -1375,6 +1370,7 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
 			       struct cpuset *cs)
 {
+	unsigned long flags;
 	int err;
 	/*
 	 * can_attach beforehand should guarantee that this doesn't fail.
@@ -1383,9 +1379,9 @@ static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
 	err = set_cpus_allowed_ptr(tsk, cpus_attach);
 	WARN_ON_ONCE(err);
 
-	task_lock(tsk);
+	task_mems_lock_irqsave(tsk, flags);
 	cpuset_change_task_nodemask(tsk, to);
-	task_unlock(tsk);
+	task_mems_unlock_irqrestore(tsk, flags);
 	cpuset_update_task_spread_flag(cs, tsk);
 
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index b0ec34a..a5c581d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -32,6 +32,7 @@
 #include <linux/capability.h>
 #include <linux/cpu.h>
 #include <linux/cgroup.h>
+#include <linux/cpuset.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
 #include <linux/swap.h>
@@ -1095,6 +1096,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	monotonic_to_bootbased(&p->real_start_time);
 	p->io_context = NULL;
 	p->audit_context = NULL;
+#ifdef CONFIG_CPUSETS
+	spin_lock_init(&p->mems_lock);
+	p->mems_generation_for_update = 0;
+	p->mems_generation = 0;
+#endif
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
@@ -1307,6 +1313,17 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	perf_event_fork(p);
+#ifdef CONFIG_CPUSETS
+	/*
+	 * Checking whether p's cpuset changed mems before cgroup_post_fork()
+	 * and after dup_task_struct().
+	 */
+	if (unlikely(current->mems_generation_for_update
+			!= current->mems_generation)) {
+		p->mems_allowed = cpuset_mems_allowed(current);
+		mpol_rebind_task(p, &p->mems_allowed);
+	}
+#endif
 	return p;
 
 bad_fork_free_pid:
diff --git a/mm/filemap.c b/mm/filemap.c
index 045b31c..595f5cc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -461,8 +461,12 @@ EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
 {
+	int n;
+
 	if (cpuset_do_page_mem_spread()) {
-		int n = cpuset_mem_spread_node();
+		cpuset_update_task_mems_allowed();
+
+		n = cpuset_mem_spread_node();
 		return alloc_pages_exact_node(n, gfp, 0);
 	}
 	return alloc_pages(gfp, 0);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3a5aeb3..a19865c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1837,6 +1837,8 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	int node;
 	unsigned int nr = 0;
 
+	cpuset_update_task_mems_allowed();
+
 	for_each_node_mask(node, cpuset_current_mems_allowed)
 		nr += array[node];
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bda230e..6d4cdb7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -190,8 +190,7 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
  * parameter with respect to the policy mode and flags.  But, we need to
  * handle an empty nodemask with MPOL_PREFERRED here.
  *
- * Must be called holding task's alloc_lock to protect task's mems_allowed
- * and mempolicy.  May also be called holding the mmap_semaphore for write.
+ * May be called holding the mmap_semaphore for write.
  */
 static int mpol_set_nodemask(struct mempolicy *pol,
 		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
@@ -201,6 +200,9 @@ static int mpol_set_nodemask(struct mempolicy *pol,
 	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
 	if (pol == NULL)
 		return 0;
+
+	cpuset_update_task_mems_allowed();
+
 	/* Check N_HIGH_MEMORY */
 	nodes_and(nsc->mask1,
 		  cpuset_current_mems_allowed, node_states[N_HIGH_MEMORY]);
@@ -665,10 +667,8 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	 */
 	if (mm)
 		down_write(&mm->mmap_sem);
-	task_lock(current);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
-		task_unlock(current);
 		if (mm)
 			up_write(&mm->mmap_sem);
 		mpol_put(new);
@@ -680,7 +680,6 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
 		current->il_next = first_node(new->v.nodes);
-	task_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
 
@@ -693,8 +692,6 @@ out:
 
 /*
  * Return nodemask for policy for get_mempolicy() query
- *
- * Called with task's alloc_lock held
  */
 static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
@@ -740,6 +737,8 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
 
+	cpuset_update_task_mems_allowed();
+
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
 		return -EINVAL;
@@ -748,9 +747,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
 			return -EINVAL;
 		*policy = 0;	/* just so it's initialized */
-		task_lock(current);
 		*nmask  = cpuset_current_mems_allowed;
-		task_unlock(current);
 		return 0;
 	}
 
@@ -805,11 +802,8 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	}
 
 	err = 0;
-	if (nmask) {
-		task_lock(current);
+	if (nmask)
 		get_policy_nodemask(pol, nmask);
-		task_unlock(current);
-	}
 
  out:
 	mpol_cond_put(pol);
@@ -1054,9 +1048,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
 			down_write(&mm->mmap_sem);
-			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
-			task_unlock(current);
 			if (err)
 				up_write(&mm->mmap_sem);
 		} else
@@ -1576,6 +1568,8 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct zonelist *zl;
 
+	cpuset_update_task_mems_allowed();
+
 	*mpol = get_vma_policy(current, vma, addr);
 	*nodemask = NULL;	/* assume !MPOL_BIND */
 
@@ -1614,6 +1608,8 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 	if (!(mask && current->mempolicy))
 		return false;
 
+	cpuset_update_task_mems_allowed();
+
 	mempolicy = current->mempolicy;
 	switch (mempolicy->mode) {
 	case MPOL_PREFERRED:
@@ -1678,9 +1674,12 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 struct page *
 alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
-	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	struct mempolicy *pol;
 	struct zonelist *zl;
 
+	cpuset_update_task_mems_allowed();
+
+	pol= get_vma_policy(current, vma, addr);
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
@@ -1727,6 +1726,8 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
 
+	cpuset_update_task_mems_allowed();
+
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
 
@@ -2007,9 +2008,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 			return;		/* no valid nodemask intersection */
 		}
 
-		task_lock(current);
 		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
-		task_unlock(current);
 		mpol_put(mpol);	/* drop our ref on sb mpol */
 		if (ret) {
 			NODEMASK_SCRATCH_FREE(scratch);
@@ -2241,9 +2240,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		int ret;
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			task_lock(current);
 			ret = mpol_set_nodemask(new, &nodes, scratch);
-			task_unlock(current);
 		} else
 			ret = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
diff --git a/mm/slab.c b/mm/slab.c
index a9f325b..bb13050 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3147,6 +3147,9 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
+
+	cpuset_update_task_mems_allowed();
+
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
@@ -3178,6 +3181,8 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
+	cpuset_update_task_mems_allowed();
+
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
diff --git a/mm/slub.c b/mm/slub.c
index 0bfd386..a2d02b6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1368,6 +1368,8 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
+	cpuset_update_task_mems_allowed();
+
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
