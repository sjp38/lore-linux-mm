Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 898006B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 06:23:46 -0400 (EDT)
Message-ID: <4BAB39B9.7080600@cn.fujitsu.com>
Date: Thu, 25 Mar 2010 18:23:53 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop> <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop>
In-Reply-To: <20100311110317.GL5812@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-11 19:03, Nick Piggin wrote:
> Well... I do think seqlocks would be a bit simpler because they don't
> require this checking and synchronizing of this patch.

Hi, Nick Piggin

I have made a new patch which uses seqlock to protect mems_allowed and mempolicy.
please review it.

title: [PATCH -mmotm] cpuset,mm: use seqlock to protect task->mempolicy and mems_allowed

Before applying this patch, cpuset updates task->mems_allowed by setting all
new bits in the nodemask first, and clearing all old unallowed bits later.
But in the way, the allocator can see an empty nodemask, though it is infrequent.

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

Besides that, if the size of nodemask_t is less than the size of long integer,
there is another problem. when the kernel allocater invokes the following function,

	struct zoneref *next_zones_zonelist(struct zoneref *z,
						enum zone_type highest_zoneidx,
						nodemask_t *nodes,
						struct zone **zone)
	{
		/*
		 * Find the next suitable zone to use for the allocation.
		 * Only filter based on nodemask if it's set
		 */
		if (likely(nodes == NULL))
			......
 	       else
			while (zonelist_zone_idx(z) > highest_zoneidx ||
					(z->zone && !zref_in_nodemask(z, nodes)))
				z++;

		*zone = zonelist_zone(z);
		return z;
	}

if we change nodemask between two calls of zref_in_nodemask(), such as
	Task1						Task2
	zref_in_nodemask(z = node0's z, nodes = 1-2)
	zref_in_nodemask return 0
							nodes = 0
	zref_in_nodemask(z = node1's z, nodes = 0)
	zref_in_nodemask return 0
z will overflow.

when the kernel allocater accesses task->mempolicy, there is the same problem. 

The following method is used to fix these two problem.
A seqlock is used to protect task's mempolicy and mems_allowed for configs where
MAX_NUMNODES > BITS_PER_LONG, and when the kernel allocater accesses nodemask,
it locks the seqlock and gets the copy of nodemask, then it passes the copy of
nodemask to the memory allocating function.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 include/linux/cpuset.h    |   79 +++++++++++++++++++++++++--
 include/linux/init_task.h |    8 +++
 include/linux/sched.h     |   17 +++++--
 kernel/cpuset.c           |   94 +++++++++++++++++++++++++-------
 kernel/exit.c             |    4 ++
 kernel/fork.c             |    4 ++
 mm/hugetlb.c              |   22 +++++++-
 mm/mempolicy.c            |  133 ++++++++++++++++++++++++++++++++++-----------
 mm/slab.c                 |   24 +++++++-
 mm/slub.c                 |    9 +++-
 10 files changed, 326 insertions(+), 68 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index a5740fc..e307f89 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -53,8 +53,8 @@ static inline int cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 	return cpuset_node_allowed_hardwall(zone_to_nid(z), gfp_mask);
 }
 
-extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
-					  const struct task_struct *tsk2);
+extern int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
+					  struct task_struct *tsk2);
 
 #define cpuset_memory_pressure_bump() 				\
 	do {							\
@@ -90,9 +90,68 @@ extern void rebuild_sched_domains(void);
 
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
+# if MAX_NUMNODES > BITS_PER_LONG
+/*
+ * Be used to protect task->mempolicy and mems_allowed when reading them for
+ * page allocation.
+ *
+ * we don't care that the kernel page allocator allocate a page on a node in
+ * the old mems_allowed, which isn't a big deal, especially since it was
+ * previously allowed.
+ *
+ * We just worry whether the kernel page allocator gets an empty mems_allowed
+ * or not. But
+ *   if MAX_NUMNODES <= BITS_PER_LONG, loading/storing task->mems_allowed are
+ *   atomic operations. So we needn't do anything to protect the loading of
+ *   task->mems_allowed in fastpaths.
+ *
+ *   if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed are
+ *   not atomic operations. So we use a seqlock to protect the loading of
+ *   task->mems_allowed in fastpaths.
+ */
+#define mems_fastpath_lock_irqsave(p, flags)				\
+	({								\
+		read_seqbegin_irqsave(&p->mems_seqlock, flags);		\
+	})
+
+#define mems_fastpath_unlock_irqrestore(p, seq, flags)			\
+	({								\
+		read_seqretry_irqrestore(&p->mems_seqlock, seq, flags);	\
+	})
+
+#define mems_slowpath_lock_irqsave(p, flags)				\
+	do {								\
+		write_seqlock_irqsave(&p->mems_seqlock, flags);		\
+	} while (0)
+
+#define mems_slowpath_unlock_irqrestore(p, flags)			\
+	do {								\
+		write_sequnlock_irqrestore(&p->mems_seqlock, flags);	\
+	} while (0)
+# else
+#define mems_fastpath_lock_irqsave(p, flags)		({ (void)(flags); 0; })
+
+#define mems_fastpath_unlock_irqrestore(p, flags)	({ (void)(flags); 0; })
+
+#define mems_slowpath_lock_irqsave(p, flags)			\
+	do {							\
+		task_lock(p);					\
+		(void)(flags);					\
+	} while (0)
+
+#define mems_slowpath_unlock_irqrestore(p, flags)		\
+	do {							\
+		task_unlock(p);					\
+		(void)(flags);					\
+	} while (0)
+# endif
+
 static inline void set_mems_allowed(nodemask_t nodemask)
 {
+	unsigned long flags;
+	mems_slowpath_lock_irqsave(current, flags);
 	current->mems_allowed = nodemask;
+	mems_slowpath_unlock_irqrestore(current, flags);
 }
 
 #else /* !CONFIG_CPUSETS */
@@ -144,8 +203,8 @@ static inline int cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 	return 1;
 }
 
-static inline int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
-						 const struct task_struct *tsk2)
+static inline int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
+						 struct task_struct *tsk2)
 {
 	return 1;
 }
@@ -193,6 +252,18 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
 
+#define mems_fastpath_lock_irqsave(p, flags)				\
+	({ (void)(flags); 0; })
+
+#define mems_fastpath_unlock_irqrestore(p, seq, flags)			\
+	({ (void)(flags); 0; })
+
+#define mems_slowpath_lock_irqsave(p, flags)				\
+	do { (void)(flags); } while (0)
+
+#define mems_slowpath_unlock_irqrestore(p, flags)			\
+	do { (void)(flags); } while (0)
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 1ed6797..0394e20 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -102,6 +102,13 @@ extern struct cred init_cred;
 # define INIT_PERF_EVENTS(tsk)
 #endif
 
+#if defined(CONFIG_CPUSETS) && MAX_NUMNODES > BITS_PER_LONG
+# define INIT_MEM_SEQLOCK(tsk)						\
+	.mems_seqlock	= __SEQLOCK_UNLOCKED(tsk.mems_seqlock),
+#else
+# define INIT_MEM_SEQLOCK(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -171,6 +178,7 @@ extern struct cred init_cred;
 	INIT_FTRACE_GRAPH						\
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
+	INIT_MEM_SEQLOCK(tsk)						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 84b8c22..1cf5fd3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1356,8 +1356,9 @@ struct task_struct {
 /* Thread group tracking */
    	u32 parent_exec_id;
    	u32 self_exec_id;
-/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_allowed,
- * mempolicy */
+/* Protection of (de-)allocation: mm, files, fs, tty, keyrings.
+ * if MAX_NUMNODES <= BITS_PER_LONG,it will protect mems_allowed and mempolicy.
+ * Or we use other seqlock - mems_seqlock to protect them. */
 	spinlock_t alloc_lock;
 
 #ifdef CONFIG_GENERIC_HARDIRQS
@@ -1425,7 +1426,13 @@ struct task_struct {
 	cputime_t acct_timexpd;	/* stime + utime since last update */
 #endif
 #ifdef CONFIG_CPUSETS
-	nodemask_t mems_allowed;	/* Protected by alloc_lock */
+# if MAX_NUMNODES > BITS_PER_LONG
+	/* Protection of mems_allowed, and mempolicy */
+	seqlock_t mems_seqlock;
+# endif
+	/* if MAX_NUMNODES <= BITS_PER_LONG, Protected by alloc_lock;
+	 * else Protected by mems_seqlock */
+	nodemask_t mems_allowed;
 	int cpuset_mem_spread_rotor;
 #endif
 #ifdef CONFIG_CGROUPS
@@ -1448,7 +1455,9 @@ struct task_struct {
 	struct list_head perf_event_list;
 #endif
 #ifdef CONFIG_NUMA
-	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
+	/* if MAX_NUMNODES <= BITS_PER_LONG, Protected by alloc_lock;
+	 * else Protected by mems_seqlock */
+	struct mempolicy *mempolicy;
 	short il_next;
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index d109467..8a658c5 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -198,12 +198,13 @@ static struct cpuset top_cpuset = {
  * from one of the callbacks into the cpuset code from within
  * __alloc_pages().
  *
- * If a task is only holding callback_mutex, then it has read-only
- * access to cpusets.
+ * If a task is only holding callback_mutex or cgroup_mutext, then it has
+ * read-only access to cpusets.
  *
  * Now, the task_struct fields mems_allowed and mempolicy may be changed
- * by other task, we use alloc_lock in the task_struct fields to protect
- * them.
+ * by other task, we use alloc_lock(if MAX_NUMNODES <= BITS_PER_LONG) or
+ * mems_seqlock(if MAX_NUMNODES > BITS_PER_LONG) in the task_struct fields
+ * to protect them.
  *
  * The cpuset_common_file_read() handlers only hold callback_mutex across
  * small pieces of code, such as when reading out possibly multi-word
@@ -920,6 +921,10 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
  *    call to guarantee_online_mems(), as we know no one is changing
  *    our task's cpuset.
  *
+ *    As the above comment said, no one can change current task's mems_allowed
+ *    except itself. so we needn't hold lock to protect task's mems_allowed
+ *    during this call.
+ *
  *    While the mm_struct we are migrating is typically from some
  *    other task, the task_struct mems_allowed that we are hacking
  *    is for our current task, which must allocate new pages for that
@@ -947,15 +952,13 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
  * we structure updates as setting all new allowed nodes, then clearing newly
  * disallowed ones.
  *
- * Called with task's alloc_lock held
+ * Called with mems_slowpath_lock held
  */
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
-	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, &tsk->mems_allowed);
-	mpol_rebind_task(tsk, newmems);
 	tsk->mems_allowed = *newmems;
+	mpol_rebind_task(tsk, newmems);
 }
 
 /*
@@ -970,6 +973,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
+	unsigned long flags;
 	NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL);
 
 	if (!newmems)
@@ -978,9 +982,9 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	cs = cgroup_cs(scan->cg);
 	guarantee_online_mems(cs, newmems);
 
-	task_lock(p);
+	mems_slowpath_lock_irqsave(p, flags);
 	cpuset_change_task_nodemask(p, newmems);
-	task_unlock(p);
+	mems_slowpath_unlock_irqrestore(p, flags);
 
 	NODEMASK_FREE(newmems);
 
@@ -1375,6 +1379,7 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
 			       struct cpuset *cs)
 {
+	unsigned long flags;
 	int err;
 	/*
 	 * can_attach beforehand should guarantee that this doesn't fail.
@@ -1383,9 +1388,10 @@ static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
 	err = set_cpus_allowed_ptr(tsk, cpus_attach);
 	WARN_ON_ONCE(err);
 
-	task_lock(tsk);
+	mems_slowpath_lock_irqsave(tsk, flags);
 	cpuset_change_task_nodemask(tsk, to);
-	task_unlock(tsk);
+	mems_slowpath_unlock_irqrestore(tsk, flags);
+
 	cpuset_update_task_spread_flag(cs, tsk);
 
 }
@@ -2233,7 +2239,15 @@ nodemask_t cpuset_mems_allowed(struct task_struct *tsk)
  */
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
-	return nodes_intersects(*nodemask, current->mems_allowed);
+	unsigned long flags, seq;
+	int retval;
+
+	do {
+		seq = mems_fastpath_lock_irqsave(current, flags);
+		retval = nodes_intersects(*nodemask, current->mems_allowed);
+	} while (mems_fastpath_unlock_irqrestore(current, seq, flags));
+
+	return retval;
 }
 
 /*
@@ -2314,11 +2328,18 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 {
 	const struct cpuset *cs;	/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
+	unsigned long flags, seq;
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
 	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
-	if (node_isset(node, current->mems_allowed))
+
+	do {
+		seq = mems_fastpath_lock_irqsave(current, flags);
+		allowed = node_isset(node, current->mems_allowed);
+	} while (mems_fastpath_unlock_irqrestore(current, seq, flags));
+
+	if (allowed)
 		return 1;
 	/*
 	 * Allow tasks that have access to memory reserves because they have
@@ -2369,9 +2390,18 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
  */
 int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
 {
+	int allowed;
+	unsigned long flags, seq;
+
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
-	if (node_isset(node, current->mems_allowed))
+
+	do {
+		seq = mems_fastpath_lock_irqsave(current, flags);
+		allowed = node_isset(node, current->mems_allowed);
+	} while (mems_fastpath_unlock_irqrestore(current, seq, flags));
+
+	if (allowed)
 		return 1;
 	/*
 	 * Allow tasks that have access to memory reserves because they have
@@ -2438,10 +2468,18 @@ void cpuset_unlock(void)
 int cpuset_mem_spread_node(void)
 {
 	int node;
+	unsigned long flags, seq;
+	/* Used for allocating memory, so can't use NODEMASK_ALLOC */
+	nodemask_t nodes;
 
-	node = next_node(current->cpuset_mem_spread_rotor, current->mems_allowed);
+	do {
+		seq = mems_fastpath_lock_irqsave(current, flags);
+		nodes = current->mems_allowed;
+	} while (mems_fastpath_unlock_irqrestore(current, seq, flags));
+
+	node = next_node(current->cpuset_mem_spread_rotor, nodes);
 	if (node == MAX_NUMNODES)
-		node = first_node(current->mems_allowed);
+		node = first_node(nodes);
 	current->cpuset_mem_spread_rotor = node;
 	return node;
 }
@@ -2458,10 +2496,26 @@ EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
  * to the other.
  **/
 
-int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
-				   const struct task_struct *tsk2)
+int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
+				   struct task_struct *tsk2)
 {
-	return nodes_intersects(tsk1->mems_allowed, tsk2->mems_allowed);
+	unsigned long flags1, flags2;
+	int retval;
+	struct task_struct *tsk;
+
+	if (tsk1 > tsk2) {
+		tsk = tsk1;
+		tsk1 = tsk2;
+		tsk2 = tsk;
+	}
+
+	mems_slowpath_lock_irqsave(tsk1, flags1);
+	mems_slowpath_lock_irqsave(tsk2, flags2);
+	retval = nodes_intersects(tsk1->mems_allowed, tsk2->mems_allowed);
+	mems_slowpath_unlock_irqrestore(tsk2, flags2);
+	mems_slowpath_unlock_irqrestore(tsk1, flags1);
+
+	return retval;
 }
 
 /**
diff --git a/kernel/exit.c b/kernel/exit.c
index 7b012a0..cbf045d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -16,6 +16,7 @@
 #include <linux/key.h>
 #include <linux/security.h>
 #include <linux/cpu.h>
+#include <linux/cpuset.h>
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/file.h>
@@ -649,6 +650,7 @@ static void exit_mm(struct task_struct * tsk)
 {
 	struct mm_struct *mm = tsk->mm;
 	struct core_state *core_state;
+	unsigned long flags;
 
 	mm_release(tsk, mm);
 	if (!mm)
@@ -694,8 +696,10 @@ static void exit_mm(struct task_struct * tsk)
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
 #ifdef CONFIG_NUMA
+	mems_slowpath_lock_irqsave(tsk, flags);
 	mpol_put(tsk->mempolicy);
 	tsk->mempolicy = NULL;
+	mems_slowpath_unlock_irqrestore(tsk, flags);
 #endif
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
index fe73f8d..591346a 100644
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
@@ -1075,6 +1076,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->io_context = NULL;
 	p->audit_context = NULL;
 	cgroup_fork(p);
+#if defined(CONFIG_CPUSETS) && MAX_NUMNODES > BITS_PER_LONG
+	seqlock_init(&p->mems_seqlock);
+#endif
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3a5aeb3..523f0f9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -465,6 +465,8 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
+	nodemask_t tmp_mask;
+	unsigned long seq, irqflag;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
 	struct zone *zone;
@@ -483,6 +485,15 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		return NULL;
 
+	if (mpol == current->mempolicy) {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, irqflag);
+			tmp_mask = *nodemask;
+		} while (mems_fastpath_unlock_irqrestore(current,
+								seq, irqflag));
+		nodemask = &tmp_mask;
+	}
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
@@ -1835,10 +1846,15 @@ __setup("default_hugepagesz=", hugetlb_default_setup);
 static unsigned int cpuset_mems_nr(unsigned int *array)
 {
 	int node;
-	unsigned int nr = 0;
+	unsigned int nr;
+	unsigned long flags, seq;
 
-	for_each_node_mask(node, cpuset_current_mems_allowed)
-		nr += array[node];
+	do {
+		nr = 0;
+		seq = mems_fastpath_lock_irqsave(current, flags);
+		for_each_node_mask(node, cpuset_current_mems_allowed)
+			nr += array[node];
+	} while (mems_fastpath_unlock_irqrestore(current, seq, flags));
 
 	return nr;
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dd3f5c5..2a42e8c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -187,8 +187,10 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
  * parameter with respect to the policy mode and flags.  But, we need to
  * handle an empty nodemask with MPOL_PREFERRED here.
  *
- * Must be called holding task's alloc_lock to protect task's mems_allowed
- * and mempolicy.  May also be called holding the mmap_semaphore for write.
+ * Must be called using
+ *     mems_slowpath_lock_irqsave()/mems_slowpath_unlock_irqrestore()
+ * to protect task's mems_allowed and mempolicy.  May also be called holding
+ * the mmap_semaphore for write.
  */
 static int mpol_set_nodemask(struct mempolicy *pol,
 		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
@@ -344,9 +346,13 @@ static void mpol_rebind_policy(struct mempolicy *pol,
  * Wrapper for mpol_rebind_policy() that just requires task
  * pointer, and updates task mempolicy.
  *
- * Called with task's alloc_lock held.
+ * if task->pol==NULL, it will return -1, and tell us it is unnecessary to
+ * rebind task's mempolicy.
+ *
+ * Using
+ *     mems_slowpath_lock_irqsave()/mems_slowpath_unlock_irqrestore()
+ * to protect it.
  */
-
 void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
 {
 	mpol_rebind_policy(tsk->mempolicy, new);
@@ -644,6 +650,7 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	struct mempolicy *new, *old;
 	struct mm_struct *mm = current->mm;
 	NODEMASK_SCRATCH(scratch);
+	unsigned long irqflags;
 	int ret;
 
 	if (!scratch)
@@ -662,10 +669,10 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	 */
 	if (mm)
 		down_write(&mm->mmap_sem);
-	task_lock(current);
+	mems_slowpath_lock_irqsave(current, irqflags);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
-		task_unlock(current);
+		mems_slowpath_unlock_irqrestore(current, irqflags);
 		if (mm)
 			up_write(&mm->mmap_sem);
 		mpol_put(new);
@@ -677,7 +684,7 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
 		current->il_next = first_node(new->v.nodes);
-	task_unlock(current);
+	mems_slowpath_unlock_irqrestore(current, irqflags);
 	if (mm)
 		up_write(&mm->mmap_sem);
 
@@ -691,7 +698,9 @@ out:
 /*
  * Return nodemask for policy for get_mempolicy() query
  *
- * Called with task's alloc_lock held
+ * Must be called using mems_slowpath_lock_irqsave()/
+ * mems_slowpath_unlock_irqrestore() to
+ * protect it.
  */
 static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 {
@@ -736,6 +745,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
+	unsigned long irqflags;
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -745,9 +755,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
 			return -EINVAL;
 		*policy = 0;	/* just so it's initialized */
-		task_lock(current);
+
+		mems_slowpath_lock_irqsave(current, irqflags);
 		*nmask  = cpuset_current_mems_allowed;
-		task_unlock(current);
+		mems_slowpath_unlock_irqrestore(current, irqflags);
 		return 0;
 	}
 
@@ -803,13 +814,13 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
 	err = 0;
 	if (nmask) {
+		mems_slowpath_lock_irqsave(current, irqflags);
 		if (mpol_store_user_nodemask(pol)) {
 			*nmask = pol->w.user_nodemask;
 		} else {
-			task_lock(current);
 			get_policy_nodemask(pol, nmask);
-			task_unlock(current);
 		}
+		mems_slowpath_unlock_irqrestore(current, irqflags);
 	}
 
  out:
@@ -1008,6 +1019,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	struct mempolicy *new;
 	unsigned long end;
 	int err;
+	unsigned long irqflags;
 	LIST_HEAD(pagelist);
 
 	if (flags & ~(unsigned long)(MPOL_MF_STRICT |
@@ -1055,9 +1067,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
 			down_write(&mm->mmap_sem);
-			task_lock(current);
+			mems_slowpath_lock_irqsave(current, irqflags);
 			err = mpol_set_nodemask(new, nmask, scratch);
-			task_unlock(current);
+			mems_slowpath_unlock_irqrestore(current, irqflags);
 			if (err)
 				up_write(&mm->mmap_sem);
 		} else
@@ -1408,8 +1420,10 @@ static struct mempolicy *get_vma_policy(struct task_struct *task,
 		} else if (vma->vm_policy)
 			pol = vma->vm_policy;
 	}
+
 	if (!pol)
 		pol = &default_policy;
+
 	return pol;
 }
 
@@ -1574,16 +1588,29 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 				nodemask_t **nodemask)
 {
 	struct zonelist *zl;
+	struct mempolicy policy;
+	struct mempolicy *pol;
+	unsigned long seq, irqflag;
 
 	*mpol = get_vma_policy(current, vma, addr);
 	*nodemask = NULL;	/* assume !MPOL_BIND */
 
-	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
-		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
+	pol = *mpol;
+	if (pol == current->mempolicy) {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, irqflag);
+			policy = *pol;
+		} while (mems_fastpath_unlock_irqrestore(current,
+								seq, irqflag));
+		pol = &policy;
+	}
+
+	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
+		zl = node_zonelist(interleave_nid(pol, vma, addr,
 				huge_page_shift(hstate_vma(vma))), gfp_flags);
 	} else {
-		zl = policy_zonelist(gfp_flags, *mpol);
-		if ((*mpol)->mode == MPOL_BIND)
+		zl = policy_zonelist(gfp_flags, pol);
+		if (pol->mode == MPOL_BIND)
 			*nodemask = &(*mpol)->v.nodes;
 	}
 	return zl;
@@ -1609,11 +1636,14 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 {
 	struct mempolicy *mempolicy;
 	int nid;
+	unsigned long irqflags;
 
 	if (!(mask && current->mempolicy))
 		return false;
 
+	mems_slowpath_lock_irqsave(current, irqflags);
 	mempolicy = current->mempolicy;
+
 	switch (mempolicy->mode) {
 	case MPOL_PREFERRED:
 		if (mempolicy->flags & MPOL_F_LOCAL)
@@ -1633,6 +1663,8 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 		BUG();
 	}
 
+	mems_slowpath_unlock_irqrestore(current, irqflags);
+
 	return true;
 }
 #endif
@@ -1722,7 +1754,18 @@ struct page *
 alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	struct mempolicy policy;
 	struct zonelist *zl;
+	struct page *page;
+	unsigned long seq, iflags;
+
+	if (pol == current->mempolicy) {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, iflags);
+			policy = *pol;
+		} while (mems_fastpath_unlock_irqrestore(current, seq, iflags));
+		pol = &policy;
+	}
 
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
@@ -1736,15 +1779,16 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 		/*
 		 * slow path: ref counted shared policy
 		 */
-		struct page *page =  __alloc_pages_nodemask(gfp, 0,
-						zl, policy_nodemask(gfp, pol));
+		page =  __alloc_pages_nodemask(gfp, 0, zl,
+					policy_nodemask(gfp, pol));
 		__mpol_put(pol);
 		return page;
 	}
 	/*
 	 * fast path:  default or task policy
 	 */
-	return __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	page = __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	return page;
 }
 
 /**
@@ -1761,26 +1805,37 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
  *	Allocate a page from the kernel page pool.  When not in
  *	interrupt context and apply the current process NUMA policy.
  *	Returns NULL when no page can be allocated.
- *
- *	Don't call cpuset_update_task_memory_state() unless
- *	1) it's ok to take cpuset_sem (can WAIT), and
- *	2) allocating for current task (not interrupt).
  */
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy policy;
+	struct page *page;
+	unsigned long seq, irqflags;
+
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
-
+	else {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, irqflags);
+			policy = *pol;
+		} while (mems_fastpath_unlock_irqrestore(current,
+								seq, irqflags));
+		pol = &policy;
+	}
 	/*
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	return __alloc_pages_nodemask(gfp, order,
-			policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
+		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+	else
+		page =  __alloc_pages_nodemask(gfp, order,
+					policy_zonelist(gfp, pol),
+					policy_nodemask(gfp, pol));
+
+	return page;
 }
 EXPORT_SYMBOL(alloc_pages_current);
 
@@ -2026,6 +2081,7 @@ restart:
  */
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 {
+	unsigned long irqflags;
 	int ret;
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
@@ -2043,9 +2099,9 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 		if (IS_ERR(new))
 			goto put_free; /* no valid nodemask intersection */
 
-		task_lock(current);
+		mems_slowpath_lock_irqsave(current, irqflags);
 		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
-		task_unlock(current);
+		mems_slowpath_unlock_irqrestore(current, irqflags);
 		mpol_put(mpol);	/* drop our ref on sb mpol */
 		if (ret)
 			goto put_free;
@@ -2200,6 +2256,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 	nodemask_t nodes;
 	char *nodelist = strchr(str, ':');
 	char *flags = strchr(str, '=');
+	unsigned long irqflags;
 	int err = 1;
 
 	if (nodelist) {
@@ -2291,9 +2348,9 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		int ret;
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			task_lock(current);
+			mems_slowpath_lock_irqsave(current, irqflags);
 			ret = mpol_set_nodemask(new, &nodes, scratch);
-			task_unlock(current);
+			mems_slowpath_unlock_irqrestore(current, irqflags);
 		} else
 			ret = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -2487,8 +2544,10 @@ int show_numa_map(struct seq_file *m, void *v)
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
 	struct mempolicy *pol;
+	struct mempolicy policy;
 	int n;
 	char buffer[50];
+	unsigned long iflags, seq;
 
 	if (!mm)
 		return 0;
@@ -2498,6 +2557,14 @@ int show_numa_map(struct seq_file *m, void *v)
 		return 0;
 
 	pol = get_vma_policy(priv->task, vma, vma->vm_start);
+	if (pol == current->mempolicy) {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, iflags);
+			policy = *pol;
+		} while (mems_fastpath_unlock_irqrestore(current, seq, iflags));
+		pol = &policy;
+	}
+
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 	mpol_cond_put(pol);
 
diff --git a/mm/slab.c b/mm/slab.c
index 09f1572..18e84a9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3282,14 +3282,24 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	int nid_alloc, nid_here;
+	unsigned long lflags, seq;
+	struct mempolicy mpol;
 
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
+
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
-	else if (current->mempolicy)
-		nid_alloc = slab_node(current->mempolicy);
+	else if (current->mempolicy) {
+		do {
+			seq = mems_fastpath_lock_irqsave(current, lflags);
+			mpol = *(current->mempolicy);
+		} while (mems_fastpath_unlock_irqrestore(current, seq, lflags));
+
+		nid_alloc = slab_node(&mpol);
+	}
+
 	if (nid_alloc != nid_here)
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
@@ -3312,11 +3322,19 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
+	unsigned long lflags, seq;
+	struct mempolicy mpol;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	do {
+		seq = mems_fastpath_lock_irqsave(current, lflags);
+		mpol = *(current->mempolicy);
+	} while (mems_fastpath_unlock_irqrestore(current, seq, lflags));
+
+	zonelist = node_zonelist(slab_node(&mpol), flags);
+
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:
diff --git a/mm/slub.c b/mm/slub.c
index b364844..cd29f48 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1345,6 +1345,8 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
+	unsigned long lflags, seq;
+	struct mempolicy mpol;
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1368,7 +1370,12 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	do {
+		seq = mems_fastpath_lock_irqsave(current, lflags);
+		mpol = *(current->mempolicy);
+	} while (mems_fastpath_unlock_irqrestore(current, seq, lflags));
+
+	zonelist = node_zonelist(slab_node(&mpol), flags);
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
