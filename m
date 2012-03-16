Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id CCD776B00E8
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:05 -0400 (EDT)
Message-Id: <20120316144241.612966692@chello.nl>
Date: Fri, 16 Mar 2012 15:40:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 23/26] sched, numa: Introduce sys_numa_{t,m}bind()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-foo-syscall.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Now that we have a NUMA process scheduler, provide a syscall interface
for finer granularity NUMA balancing. In particular this allows
setting up NUMA groups of threads and vmas within a process.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/x86/syscalls/syscall_32.tbl |    2 
 arch/x86/syscalls/syscall_64.tbl |    2 
 include/asm-generic/unistd.h     |    6 
 include/linux/mempolicy.h        |   35 ++
 include/linux/sched.h            |    2 
 include/linux/syscalls.h         |    3 
 kernel/exit.c                    |    1 
 kernel/sched/numa.c              |  582 ++++++++++++++++++++++++++++++++++++++-
 kernel/sys_ni.c                  |    4 
 mm/mempolicy.c                   |    8 
 10 files changed, 639 insertions(+), 6 deletions(-)
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -355,3 +355,5 @@
 346	i386	setns			sys_setns
 347	i386	process_vm_readv	sys_process_vm_readv		compat_sys_process_vm_readv
 348	i386	process_vm_writev	sys_process_vm_writev		compat_sys_process_vm_writev
+349	i386	numa_mbind		sys_numa_mbind			compat_sys_numa_mbind
+350	i386	numa_tbind		sys_numa_tbind			compat_sys_numa_tbind
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -318,6 +318,8 @@
 309	common	getcpu			sys_getcpu
 310	64	process_vm_readv	sys_process_vm_readv
 311	64	process_vm_writev	sys_process_vm_writev
+312	64	numa_mbind		sys_numa_mbind
+313	64	numa_tbind		sys_numa_tbind
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
 # for native 64-bit operation.
--- a/include/asm-generic/unistd.h
+++ b/include/asm-generic/unistd.h
@@ -691,9 +691,13 @@ __SC_COMP(__NR_process_vm_readv, sys_pro
 #define __NR_process_vm_writev 271
 __SC_COMP(__NR_process_vm_writev, sys_process_vm_writev, \
           compat_sys_process_vm_writev)
+#define __NR_numa_mbind 272
+__SC_COMP(__NR_numa_mbind, sys_numa_mbind, compat_sys_ms_mbind)
+#define __NR_numa_tbind 273
+__SC_COMP(__NR_numa_tbind, sys_numa_tbind, compat_sys_ms_tbind)
 
 #undef __NR_syscalls
-#define __NR_syscalls 272
+#define __NR_syscalls 274
 
 /*
  * All syscalls below here should go away really,
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -78,6 +78,8 @@ enum mpol_rebind_step {
 #include <linux/nodemask.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
+#include <linux/list.h>
+#include <linux/sched.h>
 
 struct mm_struct;
 
@@ -109,6 +111,10 @@ struct mempolicy {
 	atomic_t refcnt;
 	unsigned short mode; 	/* See MPOL_* above */
 	unsigned short flags;	/* See set_mempolicy() MPOL_F_* above */
+	struct numa_group *numa_group;
+	struct list_head ng_entry;
+	struct vm_area_struct *vma;
+	struct rcu_head rcu;
 	union {
 		short 		 preferred_node; /* preferred */
 		nodemask_t	 nodes;		/* interleave/bind */
@@ -396,6 +402,35 @@ static inline int mpol_to_str(char *buff
 }
 
 #endif /* CONFIG_NUMA */
+
+#ifdef CONFIG_NUMA
+
+extern void __numa_task_exit(struct task_struct *);
+extern void numa_vma_link(struct vm_area_struct *, struct vm_area_struct *);
+extern void numa_vma_unlink(struct vm_area_struct *);
+extern void __numa_add_vma_counter(struct vm_area_struct *, int, long);
+
+static inline
+void numa_add_vma_counter(struct vm_area_struct *vma, int member, long value)
+{
+	if (vma->vm_policy && vma->vm_policy->numa_group)
+		__numa_add_vma_counter(vma, member, value);
+}
+
+static inline void numa_task_exit(struct task_struct *p)
+{
+	if (p->numa_group)
+		__numa_task_exit(p);
+}
+
+#else /* CONFIG_NUMA */
+
+static inline void numa_task_exit(struct task_struct *) { }
+static inline void numa_vma_link(struct vm_area_struct *, struct vm_area_struct *) { }
+static inline void numa_vma_unlink(struct vm_area_struct *) { }
+
+#endif /* CONFIG_NUMA */
+
 #endif /* __KERNEL__ */
 
 #endif
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1548,6 +1548,8 @@ struct task_struct {
 	short il_next;
 	short pref_node_fork;
 	int node;
+	struct numa_group *numa_group;
+	struct list_head ng_entry;
 #endif
 	struct rcu_head rcu;
 
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -856,5 +856,8 @@ asmlinkage long sys_process_vm_writev(pi
 				      const struct iovec __user *rvec,
 				      unsigned long riovcnt,
 				      unsigned long flags);
+asmlinkage long sys_numa_mbind(unsigned long addr, unsigned long len,
+			       int ng_id, unsigned long flags);
+asmlinkage long sys_numa_tbind(int tid, int ng_id, unsigned long flags);
 
 #endif
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1010,6 +1010,7 @@ void do_exit(long code)
 	mpol_put(tsk->mempolicy);
 	tsk->mempolicy = NULL;
 	task_unlock(tsk);
+	numa_task_exit(tsk);
 #endif
 #ifdef CONFIG_FUTEX
 	if (unlikely(current->pi_state_cache))
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -14,6 +14,7 @@
 
 #include <linux/mempolicy.h>
 #include <linux/kthread.h>
+#include <linux/compat.h>
 
 #include "sched.h"
 
@@ -302,17 +303,20 @@ static void enqueue_ne(struct numa_entit
 	spin_unlock(&nq->lock);
 }
 
-static void dequeue_ne(struct numa_entity *ne)
+static int dequeue_ne(struct numa_entity *ne)
 {
 	struct node_queue *nq;
+	int node = ne->node; // XXX serialization
 
-	if (ne->node == -1) // XXX serialization
-		return;
+	if (node == -1) // XXX serialization
+		return node;
 
 	nq = lock_ne_nq(ne);
 	ne->node = -1;
 	__dequeue_ne(nq, ne);
 	spin_unlock(&nq->lock);
+
+	return node;
 }
 
 static void init_ne(struct numa_entity *ne, const struct numa_ops *nops)
@@ -400,6 +404,8 @@ static int find_idlest_node(int this_nod
 
 void select_task_node(struct task_struct *p, struct mm_struct *mm, int sd_flags)
 {
+	int node;
+
 	if (!sched_feat(NUMA_SELECT)) {
 		p->node = -1;
 		return;
@@ -424,7 +430,11 @@ void select_task_node(struct task_struct
 		}
 	}
 
-	enqueue_ne(&mm->numa, find_idlest_node(p->node));
+	node = find_idlest_node(p->node);
+	if (node == -1)
+		node = numa_node_id();
+
+	enqueue_ne(&mm->numa, node);
 }
 
 __init void init_sched_numa(void)
@@ -804,3 +814,567 @@ static __init int numa_init(void)
 	return 0;
 }
 early_initcall(numa_init);
+
+
+/*
+ *  numa_group bits
+ */
+
+#include <linux/idr.h>
+#include <linux/srcu.h>
+#include <linux/syscalls.h>
+
+struct numa_group {
+	spinlock_t		lock;
+	int			id;
+
+	struct mm_rss_stat	rss;
+
+	struct list_head	tasks;
+	struct list_head	vmas;
+
+	const struct cred	*cred;
+	atomic_t		ref;
+
+	struct numa_entity	numa_entity;
+
+	struct rcu_head		rcu;
+};
+
+static struct srcu_struct ng_srcu;
+
+static DEFINE_MUTEX(numa_group_idr_lock);
+static DEFINE_IDR(numa_group_idr);
+
+static inline struct numa_group *ne_ng(struct numa_entity *ne)
+{
+	return container_of(ne, struct numa_group, numa_entity);
+}
+
+static inline bool ng_tryget(struct numa_group *ng)
+{
+	return atomic_inc_not_zero(&ng->ref);
+}
+
+static inline void ng_get(struct numa_group *ng)
+{
+	atomic_inc(&ng->ref);
+}
+
+static void __ng_put_rcu(struct rcu_head *rcu)
+{
+	struct numa_group *ng = container_of(rcu, struct numa_group, rcu);
+
+	put_cred(ng->cred);
+	kfree(ng);
+}
+
+static void __ng_put(struct numa_group *ng)
+{
+	mutex_lock(&numa_group_idr_lock);
+	idr_remove(&numa_group_idr, ng->id);
+	mutex_unlock(&numa_group_idr_lock);
+
+	WARN_ON(!list_empty(&ng->tasks));
+	WARN_ON(!list_empty(&ng->vmas));
+
+	dequeue_ne(&ng->numa_entity);
+
+	call_rcu(&ng->rcu, __ng_put_rcu);
+}
+
+static inline void ng_put(struct numa_group *ng)
+{
+	if (atomic_dec_and_test(&ng->ref))
+		__ng_put(ng);
+}
+
+/*
+ * numa_ops
+ */
+
+static unsigned long numa_group_mem_load(struct numa_entity *ne)
+{
+	struct numa_group *ng = ne_ng(ne);
+
+	return atomic_long_read(&ng->rss.count[MM_ANONPAGES]);
+}
+
+static unsigned long numa_group_cpu_load(struct numa_entity *ne)
+{
+	struct numa_group *ng = ne_ng(ne);
+	unsigned long load = 0;
+	struct task_struct *p;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(p, &ng->tasks, ng_entry)
+		load += p->numa_contrib;
+	rcu_read_unlock();
+
+	return load;
+}
+
+static void numa_group_mem_migrate(struct numa_entity *ne, int node)
+{
+	struct numa_group *ng = ne_ng(ne);
+	struct vm_area_struct *vma;
+	struct mempolicy *mpol;
+	struct mm_struct *mm;
+	int idx;
+
+	/*
+	 * Horrid code this..
+	 *
+	 * The main problem is that ng->lock nests inside mmap_sem [
+	 * numa_vma_{,un}link() gets called under mmap_sem ]. But here we need
+	 * to iterate that list and acquire mmap_sem for each entry.
+	 *
+	 * We get here without serialization. We abuse numa_vma_unlink() to add
+	 * an SRCU delayed reference count to the mpols. This allows us to do
+	 * lockless iteration of the list.
+	 *
+	 * Once we have an mpol we need to acquire mmap_sem, this too isn't
+	 * straight fwd, take ng->lock to pin mpol->vma due to its
+	 * serialization against numa_vma_unlink(). While that vma pointer is
+	 * stable the vma->vm_mm pointer must be good too, so acquire an extra
+	 * reference to the mm.
+	 *
+	 * This reference keeps mm stable so we can drop ng->lock and acquire
+	 * mmap_sem. After which mpol->vma is stable again since the memory map
+	 * is stable. So verify ->vma is still good (numa_vma_unlink clears it)
+	 * and the mm is still the same (paranoia, can't see how that could
+	 * happen).
+	 */
+
+	idx = srcu_read_lock(&ng_srcu);
+	list_for_each_entry_rcu(mpol, &ng->vmas, ng_entry) {
+		nodemask_t mask = nodemask_of_node(node);
+
+		spin_lock(&ng->lock); /* pin mpol->vma */
+		vma = mpol->vma;
+		if (!vma) {
+			spin_unlock(&ng->lock);
+			continue;
+		}
+		mm = vma->vm_mm;
+		atomic_inc(&mm->mm_users); /* pin mm */
+		spin_unlock(&ng->lock);
+
+		down_read(&mm->mmap_sem);
+		vma = mpol->vma;
+		if (!vma)
+			goto unlock_next;
+
+		mpol_rebind_policy(mpol, &mask, MPOL_REBIND_ONCE);
+		lazy_migrate_vma(vma, node);
+unlock_next:
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+	srcu_read_unlock(&ng_srcu, idx);
+}
+
+static void numa_group_cpu_migrate(struct numa_entity *ne, int node)
+{
+	struct numa_group *ng = ne_ng(ne);
+	struct task_struct *p;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(p, &ng->tasks, ng_entry)
+		sched_setnode(p, node);
+	rcu_read_unlock();
+}
+
+static bool numa_group_tryget(struct numa_entity *ne)
+{
+	/*
+	 * See process_tryget(), similar but against ng_put().
+	 */
+	return ng_tryget(ne_ng(ne));
+}
+
+static void numa_group_put(struct numa_entity *ne)
+{
+	ng_put(ne_ng(ne));
+}
+
+static const struct numa_ops numa_group_ops = {
+	.mem_load	= numa_group_mem_load,
+	.cpu_load	= numa_group_cpu_load,
+
+	.mem_migrate	= numa_group_mem_migrate,
+	.cpu_migrate	= numa_group_cpu_migrate,
+
+	.tryget		= numa_group_tryget,
+	.put		= numa_group_put,
+};
+
+void __numa_task_exit(struct task_struct *p)
+{
+	struct numa_group *ng = p->numa_group;
+
+	spin_lock(&ng->lock);
+	list_del_rcu(&p->ng_entry);
+	spin_unlock(&ng->lock);
+
+	p->numa_group = NULL; // XXX serialization ?!
+
+	ng_put(ng);
+}
+
+/*
+ * memory (vma) accounting/tracking
+ *
+ * We assume a 1:1 relation between vmas and mpols and keep a list of mpols in
+ * the numa_group, and a vma backlink in the mpol.
+ */
+
+void numa_vma_link(struct vm_area_struct *new, struct vm_area_struct *old)
+{
+	struct numa_group *ng = NULL;
+
+	if (old && old->vm_policy)
+		ng = old->vm_policy->numa_group;
+
+	if (!ng && new->vm_policy)
+		ng = new->vm_policy->numa_group;
+
+	if (!ng)
+		return;
+
+	ng_get(ng);
+	new->vm_policy->numa_group = ng;
+	new->vm_policy->vma = new;
+
+	spin_lock(&ng->lock);
+	list_add_rcu(&new->vm_policy->ng_entry, &ng->vmas);
+	spin_unlock(&ng->lock);
+}
+
+void __numa_add_vma_counter(struct vm_area_struct *vma, int member, long value)
+{
+	/*
+	 * Since the caller passes the vma argument, the caller is responsible
+	 * for making sure the vma is stable, hence the ->vm_policy->numa_group
+	 * dereference is safe. (caller usually has vma->vm_mm->mmap_sem for
+	 * reading).
+	 */
+	atomic_long_add(value, &vma->vm_policy->numa_group->rss.count[member]);
+}
+
+static void __mpol_put_rcu(struct rcu_head *rcu)
+{
+	struct mempolicy *mpol = container_of(rcu, struct mempolicy, rcu);
+	mpol_put(mpol);
+}
+
+void numa_vma_unlink(struct vm_area_struct *vma)
+{
+	struct mempolicy *mpol;
+	struct numa_group *ng;
+
+	if (!vma)
+		return;
+
+	mpol = vma->vm_policy;
+	if (!mpol)
+		return;
+
+	ng = mpol->numa_group;
+	if (!ng)
+		return;
+
+	spin_lock(&ng->lock);
+	list_del_rcu(&mpol->ng_entry);
+	/*
+	 * Rediculous, see numa_group_mem_migrate.
+	 */
+	mpol->vma = NULL;
+	mpol_get(mpol);
+	call_srcu(&ng_srcu, &mpol->rcu, __mpol_put_rcu);
+	spin_unlock(&ng->lock);
+
+	ng_put(ng);
+}
+
+/*
+ * syscall bits
+ */
+
+#define MS_ID_GET	-2
+#define MS_ID_NEW	-1
+
+static struct numa_group *ng_create(struct task_struct *p)
+{
+	struct numa_group *ng;
+	int node, err;
+
+	ng = kzalloc(sizeof(*ng), GFP_KERNEL);
+	if (!ng)
+		goto fail;
+
+	err = idr_pre_get(&numa_group_idr, GFP_KERNEL);
+	if (!err)
+		goto fail_alloc;
+
+	mutex_lock(&numa_group_idr_lock);
+	err = idr_get_new(&numa_group_idr, ng, &ng->id);
+	mutex_unlock(&numa_group_idr_lock);
+
+	if (err)
+		goto fail_alloc;
+
+	spin_lock_init(&ng->lock);
+	atomic_set(&ng->ref, 1);
+	ng->cred = get_task_cred(p);
+	INIT_LIST_HEAD(&ng->tasks);
+	INIT_LIST_HEAD(&ng->vmas);
+	init_ne(&ng->numa_entity, &numa_group_ops);
+
+	dequeue_ne(&p->mm->numa); // XXX
+
+	node = find_idlest_node(tsk_home_node(p));
+	enqueue_ne(&ng->numa_entity, node);
+
+	return ng;
+
+fail_alloc:
+	kfree(ng);
+fail:
+	return ERR_PTR(-ENOMEM);
+}
+
+/*
+ * More or less equal to ptrace_may_access(); XXX
+ */
+static int ng_allowed(struct numa_group *ng, struct task_struct *p)
+{
+	const struct cred *cred = ng->cred, *tcred;
+
+	rcu_read_lock();
+	tcred = __task_cred(p);
+	if (cred->user->user_ns == tcred->user->user_ns &&
+	    (cred->uid == tcred->euid &&
+	     cred->uid == tcred->suid &&
+	     cred->uid == tcred->uid  &&
+	     cred->gid == tcred->egid &&
+	     cred->gid == tcred->sgid &&
+	     cred->gid == tcred->gid))
+		goto ok;
+	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
+		goto ok;
+	rcu_read_unlock();
+	return -EPERM;
+
+ok:
+	rcu_read_unlock();
+	return 0;
+}
+
+static struct numa_group *ng_lookup(int ng_id, struct task_struct *p)
+{
+	struct numa_group *ng;
+
+	rcu_read_lock();
+again:
+	ng = idr_find(&numa_group_idr, ng_id);
+	if (!ng) {
+		rcu_read_unlock();
+		return ERR_PTR(-EINVAL);
+	}
+	if (ng_allowed(ng, p)) {
+		rcu_read_unlock();
+		return ERR_PTR(-EPERM);
+	}
+	if (!ng_tryget(ng))
+		goto again;
+	rcu_read_unlock();
+
+	return ng;
+}
+
+static int ng_task_assign(struct task_struct *p, int ng_id)
+{
+	struct numa_group *old_ng, *ng;
+
+	ng = ng_lookup(ng_id, p);
+	if (IS_ERR(ng))
+		return PTR_ERR(ng);
+
+	old_ng = p->numa_group; // XXX racy
+	if (old_ng) {
+		spin_lock(&old_ng->lock);
+		list_del_rcu(&p->ng_entry);
+		spin_unlock(&old_ng->lock);
+
+		/*
+		 * We have to wait for the old ng_entry users to go away before
+		 * we can re-use the link entry for the new list.
+		 */
+		synchronize_rcu();
+	}
+
+	spin_lock(&ng->lock);
+	p->numa_group = ng;
+	list_add_rcu(&p->ng_entry, &ng->tasks);
+	spin_unlock(&ng->lock);
+
+	sched_setnode(p, ng->numa_entity.node);
+
+	if (old_ng)
+		ng_put(old_ng);
+
+	return ng_id;
+}
+
+static struct task_struct *find_get_task(pid_t tid)
+{
+	struct task_struct *p;
+
+	rcu_read_lock();
+	if (!tid)
+		p = current;
+	else
+		p = find_task_by_vpid(tid);
+	if (p)
+		get_task_struct(p);
+	rcu_read_unlock();
+
+	if (!p)
+		return ERR_PTR(-ESRCH);
+
+	return p;
+}
+
+/*
+ * Bind a thread to a numa group or query its binding or create a new group.
+ *
+ * sys_numa_tbind(tid, -1, 0);	  // create new group, return new ng_id
+ * sys_numa_tbind(tid, -2, 0);	  // returns existing ng_id
+ * sys_numa_tbind(tid, ng_id, 0); // set ng_id
+ *
+ * Returns:
+ *  -ESRCH	tid->task resolution failed
+ *  -EINVAL	task didn't have a ng_id, flags was wrong
+ *  -EPERM	tid isn't in our process
+ *
+ */
+SYSCALL_DEFINE3(numa_tbind, int, tid, int, ng_id, unsigned long, flags)
+{
+	struct task_struct *p = find_get_task(tid);
+	struct numa_group *ng = NULL;
+	int orig_ng_id = ng_id;
+
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+
+	if (flags) {
+		ng_id = -EINVAL;
+		goto out;
+	}
+
+	switch (ng_id) {
+	case MS_ID_GET:
+		ng_id = -EINVAL;
+		rcu_read_lock();
+		ng = rcu_dereference(p->numa_group);
+		if (ng)
+			ng_id = ng->id;
+		rcu_read_unlock();
+		break;
+
+	case MS_ID_NEW:
+		ng = ng_create(p);
+		if (IS_ERR(ng)) {
+			ng_id = PTR_ERR(ng);
+			break;
+		}
+		ng_id = ng->id;
+		/* fall through */
+
+	default:
+		ng_id = ng_task_assign(p, ng_id);
+		if (ng && orig_ng_id < 0)
+			ng_put(ng);
+		break;
+	}
+
+out:
+	put_task_struct(p);
+	return ng_id;
+}
+
+/*
+ * Bind a memory region to a numa group.
+ *
+ * sys_numa_mbind(addr, len, ng_id, 0);
+ *
+ * create a non-mergable vma over [addr,addr+len) and assign a mpol binding it
+ * to the numa group identified by ng_id.
+ *
+ */
+SYSCALL_DEFINE4(numa_mbind, unsigned long, addr, unsigned long, len,
+			    int, ng_id, unsigned long, flags)
+{
+	struct mm_struct *mm = current->mm;
+	struct mempolicy *mpol;
+	struct numa_group *ng;
+	nodemask_t mask;
+	int node, err = 0;
+
+	if (flags)
+		return -EINVAL;
+
+	if (addr & ~PAGE_MASK)
+		return -EINVAL;
+
+	ng = ng_lookup(ng_id, current);
+	if (IS_ERR(ng))
+		return PTR_ERR(ng);
+
+	mask = nodemask_of_node(ng->numa_entity.node);
+	mpol = mpol_new(MPOL_BIND, 0, &mask);
+	if (!mpol) {
+		ng_put(ng);
+		return -ENOMEM;
+	}
+	mpol->flags |= MPOL_MF_LAZY;
+	mpol->numa_group = ng;
+
+	node = dequeue_ne(&mm->numa); // XXX
+
+	down_write(&mm->mmap_sem);
+	err = mpol_do_mbind(addr, len, mpol, MPOL_BIND,
+			&mask, MPOL_MF_MOVE|MPOL_MF_LAZY);
+	up_write(&mm->mmap_sem);
+	mpol_put(mpol);
+	ng_put(ng);
+
+	if (err && node != -1)
+		enqueue_ne(&mm->numa, node); // XXX
+
+	return err;
+}
+
+#ifdef CONFIG_COMPAT
+
+asmlinkage long compat_sys_numa_mbind(compat_ulong_t addr, compat_ulong_t len,
+				      compat_int_t ng_id, compat_ulong_t flags)
+{
+	return sys_numa_mbind(addr, len, ng_id, flags);
+}
+
+asmlinkage long compat_sys_numa_tbind(compat_int_t tid, compat_int_t ng_id,
+				      compat_ulong_t flags)
+{
+	return sys_numa_tbind(tid, ng_id, flags);
+}
+
+#endif /* CONFIG_COMPAT */
+
+static __init int numa_group_init(void)
+{
+	init_srcu_struct(&ng_srcu);
+	return 0;
+}
+early_initcall(numa_group_init);
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -103,6 +103,10 @@ cond_syscall(sys_set_mempolicy);
 cond_syscall(compat_sys_mbind);
 cond_syscall(compat_sys_get_mempolicy);
 cond_syscall(compat_sys_set_mempolicy);
+cond_syscall(sys_numa_mbind);
+cond_syscall(compat_sys_numa_mbind);
+cond_syscall(sys_numa_tbind);
+cond_syscall(compat_sys_numa_tbind);
 cond_syscall(sys_add_key);
 cond_syscall(sys_request_key);
 cond_syscall(sys_keyctl);
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -287,12 +287,13 @@ struct mempolicy *mpol_new(unsigned shor
 		}
 	} else if (nodes_empty(*nodes))
 		return ERR_PTR(-EINVAL);
-	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL | __GFP_ZERO);
 	if (!policy)
 		return ERR_PTR(-ENOMEM);
 	atomic_set(&policy->refcnt, 1);
 	policy->mode = mode;
 	policy->flags = flags;
+	INIT_LIST_HEAD(&policy->ng_entry);
 
 	return policy;
 }
@@ -607,6 +608,9 @@ static int policy_vma(struct vm_area_str
 	if (!err) {
 		mpol_get(new);
 		vma->vm_policy = new;
+		numa_vma_link(vma, NULL);
+		if (old)
+			numa_vma_unlink(old->vma);
 		mpol_put(old);
 	}
 	return err;
@@ -1994,11 +1998,13 @@ int vma_dup_policy(struct vm_area_struct
 	if (IS_ERR(mpol))
 		return PTR_ERR(mpol);
 	vma_set_policy(new, mpol);
+	numa_vma_link(new, old);
 	return 0;
 }
 
 void vma_put_policy(struct vm_area_struct *vma)
 {
+	numa_vma_unlink(vma);
 	mpol_put(vma_policy(vma));
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
