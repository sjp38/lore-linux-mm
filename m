Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 388206B01F9
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:13:20 -0400 (EDT)
Message-ID: <4BD05953.7070308@cn.fujitsu.com>
Date: Thu, 22 Apr 2010 22:12:35 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH 2/2] cpuset,mm: fix no node to alloc memory when changing
 cpuset's mems
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Before applying this patch, cpuset updates task->mems_allowed and mempolicy by
setting all new bits in the nodemask first, and clearing all old unallowed bits
later. But in the way, the allocator may find that there is no node to alloc
memory.

this patch fixes this problem by clearing newly disallowed nodes lazily.
we use a variable to tell the write-side task that read-side task is reading
nodemask, and the write-side task clears newly disallowed nodes after read-side
task ends the memory allocation.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 include/linux/cpuset.h    |   62 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/init_task.h |    8 ++++++
 include/linux/sched.h     |   12 ++++++---
 kernel/cpuset.c           |   49 +++++++++++++++++++++++++++++++----
 kernel/exit.c             |    3 ++
 kernel/fork.c             |   18 +++++++++++++
 mm/hugetlb.c              |   12 ++++++---
 mm/mempolicy.c            |   52 ++++++++++++++++++++++++-------------
 mm/page_alloc.c           |    6 +++-
 mm/slab.c                 |    4 +++
 mm/slub.c                 |    6 +++-
 mm/vmscan.c               |    2 +
 12 files changed, 200 insertions(+), 34 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index a5740fc..692792f 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -90,9 +90,55 @@ extern void rebuild_sched_domains(void);
 
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
+/*
+ * reading current mems_allowed and mempolicy in the fastpath must protected
+ * by get_mems_allowed()
+ */
+static inline void get_mems_allowed(void)
+{
+	current->mems_allowed_change_disable++;
+
+	/*
+	 * ensure that reading mems_allowed and mempolicy happens after the
+	 * update of ->mems_allowed_change_disable.
+	 *
+	 * the write-side task finds ->mems_allowed_change_disable is not 0,
+	 * and knows the read-side task is reading mems_allowed or mempolicy,
+	 * so it will clear old bits lazily.
+	 */
+	smp_mb();
+}
+
+static inline void put_mems_allowed(void)
+{
+	/*
+	 * ensure that reading mems_allowed and mempolicy before reducing
+	 * mems_allowed_change_disable. 
+	 *
+	 * the write-side task will know that the read-side task is still
+	 * reading mems_allowed or mempolicy, don't clears old bits in the
+	 * nodemask.
+	 */
+	smp_mb();
+	--ACCESS_ONCE(current->mems_allowed_change_disable);
+}
+
+/* We shouldn't use this lock under get_mems_allowed() */
+static inline void task_mems_lock(struct task_struct *tsk)
+{
+	spin_lock(&tsk->mems_spinlock);
+}
+
+static inline void task_mems_unlock(struct task_struct *tsk)
+{
+	spin_unlock(&tsk->mems_spinlock);
+}
+
 static inline void set_mems_allowed(nodemask_t nodemask)
 {
+	task_mems_lock(current);
 	current->mems_allowed = nodemask;
+	task_mems_unlock(current);
 }
 
 #else /* !CONFIG_CPUSETS */
@@ -193,6 +239,22 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
 
+static inline void get_mems_allowed(void)
+{
+}
+
+static inline void put_mems_allowed(void)
+{
+}
+
+static inline void task_mems_lock(struct task_struct *tsk)
+{
+}
+
+static inline void task_mems_unlock(struct task_struct *tsk)
+{
+}
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index b1ed1cd..d174765 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -103,6 +103,13 @@ extern struct cred init_cred;
 # define INIT_PERF_EVENTS(tsk)
 #endif
 
+#ifdef CONFIG_CPUSETS
+# define INIT_MEMS_SPINLOCK(tsk)					\
+	.mems_spinlock = __SPIN_LOCK_UNLOCKED(tsk.mems_spinlock),
+#else
+# define INIT_MEMS_SPINLOCK(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -172,6 +179,7 @@ extern struct cred init_cred;
 	INIT_FTRACE_GRAPH						\
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
+	INIT_MEMS_SPINLOCK(tsk)						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index dad7f66..b55a523 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1355,8 +1355,7 @@ struct task_struct {
 /* Thread group tracking */
    	u32 parent_exec_id;
    	u32 self_exec_id;
-/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_allowed,
- * mempolicy */
+/* Protection of (de-)allocation: mm, files, fs, tty, keyrings */
 	spinlock_t alloc_lock;
 
 #ifdef CONFIG_GENERIC_HARDIRQS
@@ -1424,7 +1423,11 @@ struct task_struct {
 	cputime_t acct_timexpd;	/* stime + utime since last update */
 #endif
 #ifdef CONFIG_CPUSETS
-	nodemask_t mems_allowed;	/* Protected by alloc_lock */
+	/* Protected by spin_lock when changing */
+	nodemask_t mems_allowed;
+	int mems_allowed_change_disable;
+	/* Protection of mems_allowed, and mempolicy */
+	spinlock_t mems_spinlock;
 	int cpuset_mem_spread_rotor;
 #endif
 #ifdef CONFIG_CGROUPS
@@ -1447,7 +1450,8 @@ struct task_struct {
 	struct list_head perf_event_list;
 #endif
 #ifdef CONFIG_NUMA
-	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
+	/* Protected by alloc_lock  when changed by cpuset*/
+	struct mempolicy *mempolicy;
 	short il_next;
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index d109467..f827bd7 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -946,16 +946,57 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
  * In order to avoid seeing no nodes if the old and new nodes are disjoint,
  * we structure updates as setting all new allowed nodes, then clearing newly
  * disallowed ones.
- *
- * Called with task's alloc_lock held
  */
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
+	task_mems_lock(tsk);
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, &tsk->mems_allowed);
+	/*
+	 * Don't worry that tsk calls set_mempolicy to setting a new mempolicy,
+	 * because we will do rebind when we clear newly disallowed ones.
+	 */
+	task_mems_unlock(tsk);
+
+	/*
+	 * ensure checking ->mems_allowed_change_disable after setting all new
+	 * allowed nodes.
+	 *
+	 * the read-side task can see an nodemask with new allowed nodes and
+	 * old allowed nodes. and if it allocates page when cpuset clears newly 
+	 * disallowed ones continuous, it can see the new allowed bits.
+	 *
+	 * And if setting all new allowed nodes is after the checking, setting
+	 * all new allowed nodes and clearing newly disallowed ones will be done
+	 * continuous, and the read-side task may find no node to alloc page.
+	 */
+	smp_mb();
+
+	/*
+	 * Allocating of memory is very fast, we needn't sleep when waitting
+	 * for the read-side.
+	 */
+	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
+		if (task_curr(tsk))
+			cpu_relax();
+		else
+			yield();
+	}
+
+	/*
+	 * ensure checking ->mems_allowed_change_disable before clearing all new
+	 * disallowed nodes. 
+	 *
+	 * if clearing newly disallowed bits before the checking, the read-side 
+	 * task may find no node to alloc page.
+	 */
+	smp_mb();
+
+	task_mems_lock(tsk);
 	mpol_rebind_task(tsk, newmems);
 	tsk->mems_allowed = *newmems;
+	task_mems_unlock(tsk);
 }
 
 /*
@@ -978,9 +1019,7 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	cs = cgroup_cs(scan->cg);
 	guarantee_online_mems(cs, newmems);
 
-	task_lock(p);
 	cpuset_change_task_nodemask(p, newmems);
-	task_unlock(p);
 
 	NODEMASK_FREE(newmems);
 
@@ -1383,9 +1422,7 @@ static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
 	err = set_cpus_allowed_ptr(tsk, cpus_attach);
 	WARN_ON_ONCE(err);
 
-	task_lock(tsk);
 	cpuset_change_task_nodemask(tsk, to);
-	task_unlock(tsk);
 	cpuset_update_task_spread_flag(cs, tsk);
 
 }
diff --git a/kernel/exit.c b/kernel/exit.c
index 7f2683a..a38ecfc 100644
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
@@ -1003,8 +1004,10 @@ NORET_TYPE void do_exit(long code)
 
 	exit_notify(tsk, group_dead);
 #ifdef CONFIG_NUMA
+	task_mems_lock(tsk);
 	mpol_put(tsk->mempolicy);
 	tsk->mempolicy = NULL;
+	task_mems_unlock(tsk);
 #endif
 #ifdef CONFIG_FUTEX
 	if (unlikely(current->pi_state_cache))
diff --git a/kernel/fork.c b/kernel/fork.c
index 44b0791..38f0a2a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -31,6 +31,7 @@
 #include <linux/nsproxy.h>
 #include <linux/capability.h>
 #include <linux/cpu.h>
+#include <linux/cpuset.h>
 #include <linux/cgroup.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
@@ -1071,7 +1072,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->audit_context = NULL;
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
+	get_mems_allowed();
 	p->mempolicy = mpol_dup(p->mempolicy);
+	put_mems_allowed();
  	if (IS_ERR(p->mempolicy)) {
  		retval = PTR_ERR(p->mempolicy);
  		p->mempolicy = NULL;
@@ -1281,6 +1284,21 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	perf_event_fork(p);
+#ifdef CONFIG_CPUSETS
+	/*
+	 * p's cpuset's mems may be changed between cgroup_post_fork()
+	 * and dup_task_struct(). so we must update p's mems_allowed and
+	 * mempolicy.
+	 *
+	 * Originally get_mems_allowed() is used to protect mempolicy and
+	 * mems_allowed when reading them. Here we use it to fix the race
+	 * of this update and changing mems. It is foxy.
+	 */
+	get_mems_allowed();
+	p->mems_allowed = cpuset_mems_allowed(p);
+	mpol_rebind_task(p, &p->mems_allowed);
+	put_mems_allowed();
+#endif
 	return p;
 
 bad_fork_free_pid:
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6034dc9..33b824b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -465,11 +465,13 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
-	struct zonelist *zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask, &mpol, &nodemask);
+	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
 
+	get_mems_allowed();
+	zonelist = huge_zonelist(vma, address,
+					htlb_alloc_mask, &mpol, &nodemask);
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
@@ -477,11 +479,11 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	 */
 	if (!vma_has_reserves(vma) &&
 			h->free_huge_pages - h->resv_huge_pages == 0)
-		return NULL;
+		goto err;
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
-		return NULL;
+		goto err;;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
@@ -500,7 +502,9 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 			break;
 		}
 	}
+err:
 	mpol_cond_put(mpol);
+	put_mems_allowed();
 	return page;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 03ba9fc..de7dfe5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -189,7 +189,7 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
  * parameter with respect to the policy mode and flags.  But, we need to
  * handle an empty nodemask with MPOL_PREFERRED here.
  *
- * Must be called holding task's alloc_lock to protect task's mems_allowed
+ * Must be called holding task's mems_spinlock to protect task's mems_allowed
  * and mempolicy.  May also be called holding the mmap_semaphore for write.
  */
 static int mpol_set_nodemask(struct mempolicy *pol,
@@ -667,10 +667,10 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	 */
 	if (mm)
 		down_write(&mm->mmap_sem);
-	task_lock(current);
+	task_mems_lock(current);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
-		task_unlock(current);
+		task_mems_unlock(current);
 		if (mm)
 			up_write(&mm->mmap_sem);
 		mpol_put(new);
@@ -682,7 +682,7 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
 		current->il_next = first_node(new->v.nodes);
-	task_unlock(current);
+	task_mems_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
 
@@ -750,9 +750,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
 			return -EINVAL;
 		*policy = 0;	/* just so it's initialized */
-		task_lock(current);
+		task_mems_lock(current);
 		*nmask  = cpuset_current_mems_allowed;
-		task_unlock(current);
+		task_mems_unlock(current);
 		return 0;
 	}
 
@@ -811,9 +811,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		if (mpol_store_user_nodemask(pol)) {
 			*nmask = pol->w.user_nodemask;
 		} else {
-			task_lock(current);
+			task_mems_lock(current);
 			get_policy_nodemask(pol, nmask);
-			task_unlock(current);
+			task_mems_unlock(current);
 		}
 	}
 
@@ -1060,9 +1060,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
 			down_write(&mm->mmap_sem);
-			task_lock(current);
+			task_mems_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
-			task_unlock(current);
+			task_mems_unlock(current);
 			if (err)
 				up_write(&mm->mmap_sem);
 		} else
@@ -1575,6 +1575,8 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
  * to the struct mempolicy for conditional unref after allocation.
  * If the effective policy is 'BIND, returns a pointer to the mempolicy's
  * @nodemask for filtering the zonelist.
+ *
+ * Must be protected by get_mems_allowed()
  */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 				gfp_t gfp_flags, struct mempolicy **mpol,
@@ -1620,6 +1622,7 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 	if (!(mask && current->mempolicy))
 		return false;
 
+	task_mems_lock(current);
 	mempolicy = current->mempolicy;
 	switch (mempolicy->mode) {
 	case MPOL_PREFERRED:
@@ -1639,6 +1642,7 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 	default:
 		BUG();
 	}
+	task_mems_unlock(current);
 
 	return true;
 }
@@ -1686,13 +1690,17 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
+	struct page *page;
 
+	get_mems_allowed();
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		mpol_cond_put(pol);
-		return alloc_page_interleave(gfp, 0, nid);
+		page = alloc_page_interleave(gfp, 0, nid);
+		put_mems_allowed();
+		return page;
 	}
 	zl = policy_zonelist(gfp, pol);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
@@ -1702,12 +1710,15 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 		struct page *page =  __alloc_pages_nodemask(gfp, 0,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
+		put_mems_allowed();
 		return page;
 	}
 	/*
 	 * fast path:  default or task policy
 	 */
-	return __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	page = __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	put_mems_allowed();
+	return page;
 }
 
 /**
@@ -1732,18 +1743,23 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
+	struct page *page;
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
 
+	get_mems_allowed();
 	/*
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	return __alloc_pages_nodemask(gfp, order,
+		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+	else
+		page = __alloc_pages_nodemask(gfp, order,
 			policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
+	put_mems_allowed();
+	return page;
 }
 EXPORT_SYMBOL(alloc_pages_current);
 
@@ -2015,9 +2031,9 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 			return;		/* no valid nodemask intersection */
 		}
 
-		task_lock(current);
+		task_mems_lock(current);
 		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
-		task_unlock(current);
+		task_mems_unlock(current);
 		mpol_put(mpol);	/* drop our ref on sb mpol */
 		if (ret) {
 			NODEMASK_SCRATCH_FREE(scratch);
@@ -2257,9 +2273,9 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		int ret;
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			task_lock(current);
+			task_mems_lock(current);
 			ret = mpol_set_nodemask(new, &nodes, scratch);
-			task_unlock(current);
+			task_mems_unlock(current);
 		} else
 			ret = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d03c946..25130f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1970,10 +1970,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
+	get_mems_allowed();
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
-	if (!preferred_zone)
+	if (!preferred_zone) {
+		put_mems_allowed();
 		return NULL;
+	}
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
@@ -1983,6 +1986,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
+	put_mems_allowed();
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 	return page;
diff --git a/mm/slab.c b/mm/slab.c
index bac0f4f..1344f57 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3148,10 +3148,12 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
 	nid_alloc = nid_here = numa_node_id();
+	get_mems_allowed();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
+	put_mems_allowed();
 	if (nid_alloc != nid_here)
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
@@ -3178,6 +3180,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
+	get_mems_allowed();
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
@@ -3233,6 +3236,7 @@ retry:
 			}
 		}
 	}
+	put_mems_allowed();
 	return obj;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 7d6c8b1..5d18bab 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1368,6 +1368,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
+	get_mems_allowed();
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
@@ -1377,10 +1378,13 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > s->min_partial) {
 			page = get_partial_node(n);
-			if (page)
+			if (page) {
+				put_mems_allowed();
 				return page;
+			}
 		}
 	}
+	put_mems_allowed();
 #endif
 	return NULL;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3ff3311..f2c367c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1774,6 +1774,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long writeback_threshold;
 
+	get_mems_allowed();
 	delayacct_freepages_start();
 
 	if (scanning_global_lru(sc))
@@ -1857,6 +1858,7 @@ out:
 		mem_cgroup_record_reclaim_priority(sc->mem_cgroup, priority);
 
 	delayacct_freepages_end();
+	put_mems_allowed();
 
 	return ret;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
