Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6536B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 09:44:12 -0500 (EST)
Subject: On numa interfaces and stuff
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 Nov 2011 15:43:41 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1321541021.27735.64.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

I promised to send this out way sooner, but here goes.

So the problem is that our current NUMA scheduling and control
interfaces all suck. On the scheduling side we have no clue as to where
our memory resides, esp. interesting for threaded applications.

For the control interfaces we only have stuff that allows hard pinning
to physical topology, but nothing useful if you don't want to have to
manage your applications by hand or have all applications talk to each
other through some common middle-ware.

So there's two things we need to do, fix up our defaults, and the simple
way to do this is by simply assigning a (mem) node to an application and
when we find the tasks are predominantly running away from the home node
migrate everything over to another node, including full memory
migration.=20

We also need to provide a new NUMA interface that allows (threaded)
applications to specify what they want. The below patch outlines such an
interface although the patch is very much incomplete and uncompilable, I
guess its complete enough to illustrate the idea.

The abstraction proposed is that of coupling threads (tasks) with
virtual address ranges (vmas) and guaranteeing they are all located on
the same node. This leaves the kernel in charge of where to place all
that and gives it the freedom to move them around, as long as the
threads and v-ranges stay together.

A typical use for this would be HPC where the compute threads and
v-space want to stay on the node, but starting multiple jobs will allow
the kernel to balance resources properly etc.

Another use-case would be kvm/qemu like things where you group vcpus and
v-space to provide virtual numa nodes to the guest OS.

I spoke to a number of people in Prague and PJT wanted to merge the task
grouping the below does into cgroups, preferably the cpu controller I
think. The advantage of doing so is that it removes a duplicate layer of
accounting, the dis-advantage however is that it entangles it with the
cpu-controller in that you might not want the threads you group to be
scheduled differently etc. Also it would restrict the functionality to a
cgroup enabled kernel only.

AA mentioned wanting to run a pte scanner to dynamically find the numa
distribution of tasks, although I think assigning them to a particular
node and assuming they all end up there is simpler (and less overhead).
If your application is large enough to not fit on a single node you've
got to manually interfere anyway if you care about performance.

As to memory migration (and I think a comment in the below patch refers
to it) we can unmap and lazy migrate on fault. Alternatively AA
mentioned a background process that trickle migrates everything. I don't
really like the latter option since it hides the work/overhead in yet
another opaque kernel thread.

Anyway, there were plenty of ideas and I think we need to start forming
a consensus as to what we want to do before we continue much further
with writing code or so.. who knows. Then again, writing stuff to find
out what doesn't work is useful too :-)

---
 include/linux/mempolicy.h |    8 +
 include/linux/memsched.h  |   27 ++
 include/linux/sched.h     |    5 +-
 kernel/exit.c             |    1 +
 kernel/fork.c             |    7 +-
 kernel/memsched.c         | 1003 +++++++++++++++++++++++++++++++++++++++++=
++++
 kernel/sched.c            |   16 +-
 kernel/sched_fair.c       |    8 +-
 kernel/sched_rt.c         |    1 +
 mm/mempolicy.c            |   14 +
 mm/mmap.c                 |   18 +-
 11 files changed, 1087 insertions(+), 21 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 7978eec..26799c8 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -68,6 +68,8 @@ enum mpol_rebind_step {
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
 #include <linux/pagemap.h>
+#include <linux/list.h>
+#include <linux/memsched.h>
=20
 struct mm_struct;
=20
@@ -99,6 +101,9 @@ struct mempolicy {
 	atomic_t refcnt;
 	unsigned short mode; 	/* See MPOL_* above */
 	unsigned short flags;	/* See set_mempolicy() MPOL_F_* above */
+	struct memsched_struct *memsched;
+	struct vm_area_struct *vma;
+	struct list_head memsched_entry;
 	union {
 		short 		 preferred_node; /* preferred */
 		nodemask_t	 nodes;		/* interleave/bind */
@@ -158,6 +163,8 @@ static inline struct mempolicy *mpol_dup(struct mempoli=
cy *pol)
 #define vma_policy(vma) ((vma)->vm_policy)
 #define vma_set_policy(vma, pol) ((vma)->vm_policy =3D (pol))
=20
+int vma_dup_policy(struct vm_area_struct *new, struct vm_area_struct *old)=
;
+
 static inline void mpol_get(struct mempolicy *pol)
 {
 	if (pol)
@@ -311,6 +318,7 @@ mpol_shared_policy_lookup(struct shared_policy *sp, uns=
igned long idx)
=20
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
+#define vma_dup_policy(new, old) (0)
=20
 static inline void numa_policy_init(void)
 {
diff --git a/include/linux/memsched.h b/include/linux/memsched.h
index e69de29..6a0fd5a 100644
--- a/include/linux/memsched.h
+++ b/include/linux/memsched.h
@@ -0,0 +1,27 @@
+#ifndef _LINUX_MEMSCHED_H
+#define _LINUX_MEMSCHED_H
+
+struct task_struct;
+struct vm_area_struct;
+
+#ifdef CONFIG_NUMA
+
+extern void memsched_cpu_weight_update(struct task_struct *p, unsigned lon=
g);
+extern void memsched_cpu_acct_wait(struct task_struct *, u64, u64);
+extern void memsched_task_exit(struct task_struct *);
+extern void memsched_vma_link(struct vm_area_struct *, struct vm_area_stru=
ct *);
+extern void memsched_vma_adjust(struct vm_area_struct *, unsigned long, un=
signed long);
+extern void memsched_vma_unlink(struct vm_area_struct *);
+
+#else /* CONFIG_NUMA */
+
+static inline void memsched_cpu_weight_update(struct task_struct *p, unsig=
ned long) { };
+static inline void memsched_cpu_acct_wait(struct task_struct *, u64, u64) =
{ };
+static inline void memsched_task_exit(struct task_struct *) { };
+static inline void memsched_vma_link(struct vm_area_struct *, struct vm_ar=
ea_struct *) { };
+static inline void memsched_vma_adjust(struct vm_area_struct *, unsigned l=
ong, unsigned long) { };
+static inline void memsched_vma_unlink(struct vm_area_struct *) { };
+
+#endif /* CONFIG_NUMA */
+
+#endif /* _LINUX_MEMSCHED_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f3c5273..20c09e8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1133,7 +1133,7 @@ struct load_weight {
=20
 #ifdef CONFIG_SCHEDSTATS
 struct sched_statistics {
-	u64			wait_start;
+	u64			wait_start; // XXX kill me
 	u64			wait_max;
 	u64			wait_count;
 	u64			wait_sum;
@@ -1174,6 +1174,7 @@ struct sched_entity {
 	unsigned int		on_rq;
=20
 	u64			exec_start;
+	u64			wait_start; // XXX remove statistics::wait_start
 	u64			sum_exec_runtime;
 	u64			vruntime;
 	u64			prev_sum_exec_runtime;
@@ -1512,6 +1513,8 @@ struct task_struct {
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 	short pref_node_fork;
+	struct list_entry memsched_entry;
+	struct memsched_struct *memsched;
 #endif
 	struct rcu_head rcu;
=20
diff --git a/kernel/exit.c b/kernel/exit.c
index 2913b35..aa07540 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1014,6 +1014,7 @@ NORET_TYPE void do_exit(long code)
 	mpol_put(tsk->mempolicy);
 	tsk->mempolicy =3D NULL;
 	task_unlock(tsk);
+	memsched_task_exit(tsk);
 #endif
 #ifdef CONFIG_FUTEX
 	if (unlikely(current->pi_state_cache))
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..21f4c20 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -365,11 +365,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_st=
ruct *oldmm)
 			goto fail_nomem;
 		*tmp =3D *mpnt;
 		INIT_LIST_HEAD(&tmp->anon_vma_chain);
-		pol =3D mpol_dup(vma_policy(mpnt));
-		retval =3D PTR_ERR(pol);
-		if (IS_ERR(pol))
+		retval =3D vma_dup_policy(tmp, mpnt);
+		if (retval)
 			goto fail_nomem_policy;
-		vma_set_policy(tmp, pol);
 		tmp->vm_mm =3D mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
@@ -431,6 +429,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_str=
uct *oldmm)
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_anon_vma_fork:
+	memsched_vma_unlink(tmp);
 	mpol_put(pol);
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
diff --git a/kernel/memsched.c b/kernel/memsched.c
index e69de29..476ac7e 100644
--- a/kernel/memsched.c
+++ b/kernel/memsched.c
@@ -0,0 +1,1003 @@
+
+/*
+ * memsched - an interface for dynamic NUMA bindings
+ *
+ *  Copyright (C) 2011 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * The purpose of these system calls are to provide means of grouping cert=
ain
+ * tasks and memory regions of a process on the same NUMA node but explici=
tly
+ * not require a static assignment to a particular NUMA node such that the
+ * kernel is free to migrate these groups around while preserving the inva=
riant
+ * that these tasks/memory-regions remain on the same node.
+ *
+ * This allows writing programs that are NUMA aware but frees the programs=
 (or
+ * middle-ware) of the burden of explicitly managing the resources.
+ *
+ * This new interface will interact properly with cpusets, its interaction=
 with
+ * the existing systemcalls:
+ *
+ *   sys_mbind()
+ *   sys_sched_setaffinity()
+ *   ...
+ *
+ * Will be undefined at this stage and should be assumed incompatible.
+ *
+ * For licensing details see kernel-base/COPYING
+ */
+
+#include <linux/sched.h>
+#include <linux/cpuset.h>
+#include <linux/mempolicy.h>
+#include <linux/idr.h>
+#include <linux/list.h>
+#include <linux/init.h>
+#include <linux/mutex.h>
+#include <linux/atomic.h>
+#include <linux/rcupdate.h>
+#include <linux/nodemask.h>
+#include <linux/kthread.h>
+#include <linux/seqlock.h>
+#include <linux/atomic64.h>
+
+static const u64 memsched_cpu_period =3D 500 * NSEC_PER_MSEC; /* 0.5s */
+static const u64 memsched_cpu_maxperiod =3D memsched_cpu_period * 64; /* 3=
2s */
+static const unsigned long memsched_balance_interval =3D 10 * HZ; /* 10s *=
/
+
+#define CPU_UNIT	(1 << 16)
+
+/*
+ * Per node 'runqueue' structure containing memsched groups
+ */
+struct node_queue_struct {
+	spinlock_t		lock;
+	unsigned long		total_pages;
+	unsigned long		nr_ms;
+	struct list_head	ms_list;
+	struct task_struct	*numad;
+	unsigned long		next_schedule;
+	int			node;
+}
+
+static struct node_queue_struct *nqs[MAX_NUMNODES];
+
+static inline struct node_queue_struct *nq_of(int node)
+{
+	return nqs[node];
+}
+
+static void nq_add_pages(int node, long pages)
+{
+	struct node_queue_struct *nq =3D nq_of(node);
+
+	spin_lock(&nq->lock);
+	nq->total_pages +=3D pages;
+	WARN_ON_ONCE(nq->total_pages < 0);
+	spin_unlock(&nq->lock);
+}
+
+struct load_avg {
+	struct seqcount	seq;
+	u64		load;
+	u64		period;
+	u64		last;
+};
+
+/*
+ * Primary data structure describing a memsched group (tasks + vmas) withi=
n a
+ * process.
+ */
+struct memsched_struct {
+	struct mutex		mutex;
+	int			id;
+	int			node;
+	atomic64_t		weight;
+	struct load_avg		__percpu *cpu_load;
+	u64			nr_pages;
+	u64			nr_res; // XXX how?
+	struct list_head	tasks;
+	struct list_head	vmas;
+	struct list_head	entry; // on nq::ms_list
+	struct cred		*cred;
+	atomic_t		ref;
+	struct rcu_head		rcu;
+}
+
+
+#define MS_ID_GET	0
+#define MS_ID_NEW	-1
+
+static DEFINE_MUTEX(memsched_ids_lock);
+static DEFINE_IDR(memsched_ids);
+
+static void ms_enqueue(struct memsched_struct *ms)
+{
+	struct node_queue_struct *nq;
+
+	nq =3D nq_of(ms->node);
+	spin_lock(&nq->lock);
+	list_add(&ms->entry, &nq->ms_list);
+	nq->nr_ms++;
+	spin_unlock(&nq->lock);
+}
+
+static void ms_dequeue(struct memsched_struct *ms)
+{
+	struct node_queue_struct *nq;
+
+	nq =3D nq_of(ms->node);
+	spin_lock(&nq->lock);
+	nq->nr_ms--;
+	list_del(&ms->entry);
+	spin_unlock(&nq->lock);
+}
+
+/*
+ * Find least loaded node, only look at memory load for now, we're an empt=
y
+ * group and have no idea about the cpu load anyway, nor memory for that
+ * matter, but memory is the most expensive one to fix up.
+ */
+static int find_idlest_mem_node(void)
+{
+	long mem_min =3D LONG_MAX;
+	int mem_node =3D -1;
+
+	get_online_cpus();
+	for_each_online_node(node) {
+		struct node_queue_struct *nq =3D nq_of(node);
+
+		if (nq->total_pages > mem_min) {
+			mem_min =3D nq->total_pages;
+			mem_node =3D node;
+		}
+	}
+	put_online_cpus();
+
+	BUG_ON(mem_node =3D=3D -1);
+
+	return mem_node;
+}
+
+/*
+ * CPU accounting
+ *
+ * Compute the effective load of a group. That is, if the tasks only run f=
or
+ * 25% of the time, create an effective load of 25% of the straight sum of=
 the
+ * tasks weight.
+ *
+ * The problem is when the cpu is over-loaded, in that case getting 25% ru=
ntime
+ * might just mean that's all they're entitled to under the weight proport=
ional
+ * scheduling scheme. This means we're under-accounting load.
+ *
+ * Instead, measure the wait-time (time the tasks are scheduled out) and r=
educe
+ * the total load with the amount of time the tasks aren't trying to run.
+ *
+ * This too has problems under overload, since if a task that wants 25% ru=
ntime
+ * can only get 20% it will always be runnable. But this deviation causes =
us to
+ * over-account, a safer proposition than under-accounting.
+ *
+ * So the weight accounting will look like:
+ *
+ *                           dt_i
+ * eW =3D \Sum_i { w_i * (1 - ------) }
+ *                          period
+ *
+ *          \Sum w_i * dt_i
+ *    =3D W - ---------------
+ *              period
+ *
+ * Which we can easily compute by tracking the weighted wait time.
+ *
+ * XXX we will totally ignore RT tasks since they had better not use this,
+ *     node migration isn't deterministic in any useful way.
+ *
+ * XXX deal with F*CKING cgroups, p->se.load.weight isn't good for those
+ */
+
+static void memsched_cpu_weight_update(struct task_struct *p, unsigned lon=
g weight)
+{
+	struct memsched_struct *ms =3D p->memsched;
+
+	if (!ms)
+		return;
+
+	atomic64_add(weight - p->se.load.weight, &ms->weight);
+}
+
+void memsched_cpu_acct_wait(struct task_struct *p, u64 now, u64 wait_start=
)
+{
+	struct memsched *ms =3D p->memsched;
+	struct load_avg *avg;
+	u64 wait, load_wait, period;
+
+	if (!ms)
+		return;
+
+	avg =3D __get_cpu_var(ms->cpu_load);
+
+	write_seqcount_start(&avg->seq);
+
+	wait =3D now - wait_start;
+	period =3D avg->last - now;
+	avg->last +=3D period;
+
+	if (period > memsched_cpu_maxperiod) {
+		avg.load =3D 0;
+		avg.period =3D 0;
+		period =3D wait;
+	}
+
+	avg->load +=3D p->se.load.weight * wait;
+	avg->period +=3D period;
+
+	while (avg->period > memsched_cpu_period) {
+		avg->load /=3D 2;
+		avg->period /=3D 2;
+	}
+
+	write_seqcount_end(&avg->seq);
+}
+
+void memsched_task_exit(struct task_struct *p)
+{
+	struct memsched_struct *ms =3D p->memsched;
+
+	if (!ms)
+		return;
+
+	atomic64_add(-p->se.load.weight, &ms->weight);
+	p->memsched =3D 0;
+	ms_put(ms);
+}
+
+static unsigned long memsched_get_load(struct memsched_struct *ms)
+{
+	unsigned long weight =3D atomic64_read(&ms->weight);
+	unsigned long weight_wait =3D 0;
+	int cpu;
+
+	for_each_cpu_mask(cpu, cpumask_of_node(ms->node)) {
+		struct load_avg *avg =3D per_cpu(ms->cpu_load, cpu);
+		unsigned int seq;
+		u64 l, p;
+
+		do {
+			seq =3D read_seqcount_begin(&avg->seq);
+
+			l =3D avg.load;
+			p =3D avg.period;
+
+		} while (read_seqcount_retry(&avg->seq, seq));
+
+		weight_wait +=3D div_u64(l, p+1);
+	}
+
+	return clamp_t(unsigned long, weight - weight_wait, 0, weight);
+}
+
+/*
+ * tasks and syscal bits
+ */
+
+static struct memsched_struct *ms_create(struct task_struct *p)
+{
+	struct memsched_struct *ms;
+	int err;
+
+	ms =3D kzalloc(sizeof(*ms), GFP_KERNEL);
+	if (!ms)
+		goto fail;
+
+	ms->cpu_load =3D alloc_percpu(*ms->cpu_load);
+	if (!ms->cpu_load)
+		goto fail_alloc;
+
+	mutex_lock(&memsched_ids_lock);
+	err =3D idr_get_new(&memsched_ids, ms, &ms->id);
+	mutex_unlock(&memsched_ids_lock);
+
+	if (err)
+		goto fail_percpu;
+
+	mutex_init(&ms->mutex);
+	atomic_set(&ms->ref, 1);
+	ms->cred =3D get_task_cred(p);
+	ms->node =3D find_idlest_mem_node();
+
+	ms_enqueue(ms);
+
+	return ms;
+
+fail_percpu:
+	free_percpu(ms->cpu_load);
+fail_alloc:
+	kfree(ms);
+fail:
+	return ERR_PTR(-ENOMEM);
+}
+
+static void __ms_put_rcu(struct rcu_head *rcu)
+{
+	struct memsched_struct *ms =3D
+		container_of(rcu, struct memsched_struct, rcu);
+
+	put_cred(ms->cred);
+	mpol_put(ms->mpol);
+	free_percpu(ms->cpu_load);
+	kfree(ms);
+}
+
+static int ms_try_get(struct memsched_struct *ms)
+{
+	return atomic_inc_not_zero(&ms->ref);
+}
+
+static void ms_put(struct memsched_struct *ms)
+{
+	if (!atomic_dec_and_test(&ms->ref))
+		return;
+
+	mutex_lock(&memsched_ids_lock);
+	idr_remove(&memsched_ids, ms->id);
+	mutex_unlock(&memsched_ids_lock);
+
+	WARN_ON(!list_empty(&ms->tasks));
+	WARN_ON(!list_empty(&ms->vmas));
+
+	ms_dequeue(ms);
+
+	call_rcu(&ms->rcu, __ms_put_rcu);
+}
+
+/*
+ * More or less equal to ptrace_may_access(); XXX
+ */
+static int ms_allowed(struct memsched_struct *ms, struct task_struct *p)
+{
+	struct cred *cred =3D ms->cred, *tcred;
+
+	rcu_read_lock();
+	tcred =3D __task_cred(p);
+	if (cred->user->user_ns =3D=3D tcred->user->user_ns &&
+	    (cred->uid =3D=3D tcred->euid &&
+	     cred->uid =3D=3D tcred->suid &&
+	     cred->uid =3D=3D tcred->uid  &&
+	     cred->gid =3D=3D tcred->egid &&
+	     cred->gid =3D=3D tcred->sgid &&
+	     cred->gid =3D=3D tcred->gid))
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
+static struct memsched_struct *ms_lookup(int ms_id, struct task_struct *p)
+{
+	struct memsched *ms;
+
+	rcu_read_lock();
+again:
+	ms =3D idr_find(&memsched_ids, ms_id);
+	if (!ms) {
+		rcu_read_unlock();
+		return ERR_PTR(-EINVAL);
+	}
+	if (!ms_allowed(ms, p)) {
+		rcu_read_unlock();
+		return ERR_PTR(-EPERM);
+	}
+	if (!ms_try_get(ms))
+		goto again;
+	rcu_read_unlock();
+
+	return ms;
+}
+
+static int ms_task_assign(struct task_struct *task, int ms_id)
+{
+	struct memsched *old_ms, *ms;
+
+	ms =3D ms_lookup(ms_id, task);
+	if (IS_ERR(ms))
+		return PTR_ERR(ms);
+
+	old_ms =3D task->memsched; // XXX racy
+	if (old_ms) {
+		mutex_lock(&old_ms->mutex);
+		list_del(&task->ms_entry);
+		mutex_unlock(&old_ms->mutex);
+	}
+
+	mutex_lock(&ms->mutex);
+	list_add(&task->ms_entry, &ms->tasks);
+	task->memsched =3D ms;
+	set_cpus_allowed_ptr(task, cpumask_of_node(ms->node));
+	atomic64_add(task->se.load.weight, &ms->weight);
+	mutex_unlock(&ms->mutex);
+
+	if (old_ms)
+		ms_put(old_ms);
+
+	return ms_id;
+}
+
+static struct task_struct *find_get_task(pid_t tid)
+{
+	struct task_struct *task;
+	int err;
+=09
+	rcu_read_lock();
+	if (!tid)
+		task =3D current;
+	else
+		task =3D find_task_by_vpid(tid);
+	if (task)
+		get_task_struct(task);
+	rcu_read_unlock();
+
+	if (!task)
+		return ERR_PTR(-ESRCH);
+
+	return task;
+}
+
+/*
+ * Bind a thread so a memsched group or query its binding or create a new =
group.
+ *
+ * sys_ms_tbind(tid, -1, 0);	// create new group, return new ms_id
+ * sys_ms_tbind(tid, 0, 0);  	// returns existing ms_id
+ * sys_ms_tbind(tid, ms_id, 0); // set ms_id
+ *
+ * Returns:
+ *  -ESRCH	tid->task resolution failed
+ *  -EINVAL	task didn't have a ms_id, flags was wrong
+ *  -EPERM	tid isn't in our process
+ *
+ */
+SYSCALL_DEFINE3(ms_tbind, int, tid, int, ms_id, unsigned long, flags)
+{
+	struct task_struct *task =3D find_get_task(tid);
+	struct memsched_struct *ms =3D NULL;
+
+	if (IS_ERR(task))
+		return ERR_PTR(task);
+
+	if (flags) {
+		ms_id =3D -EINVAL;
+		goto out;
+	}
+
+	switch (ms_id) {
+	case MS_ID_GET:
+		ms_id =3D -EINVAL;
+		rcu_read_lock();
+		ms =3D rcu_dereference(task->memsched);
+		if (ms)
+			ms_id =3D ms->id;
+		rcu_read_unlock();
+		break;
+
+	case MS_ID_NEW:
+		ms =3D ms_create(task);
+		if (IS_ERR(ms)) {
+			ms_id =3D PTR_ERR(ms);
+			break;
+		}
+		ms_id =3D ms->id;
+		/* fall through */
+
+	default:
+		ms_id =3D ms_task_assign(task, ms_id);
+		if (ms && ms_id < 0)
+			ms_put(ms);
+		break;
+	}
+
+out:
+	put_task_struct(task);
+	return ms_id;
+}
+
+/*
+ * memory (vma) accounting
+ *
+ * We assume (check) a 1:1 relation between vma's and mpol's and keep a li=
st of
+ * mpols in the memsched, and a vma backlink in the mpol.
+ *
+ * For now we simply account the total vma size linked to the memsched, id=
eally
+ * we'd track resident set size, but that involves a lot more accounting.
+ */
+
+void memsched_vma_link(struct vm_area_struct *new, struct vm_area_struct *=
old)
+{
+	struct memsched_struct *ms;
+	long pages;
+
+	if (old && old->vm_policy)
+	       	ms =3D old->vm_policy->memsched;
+
+	if (!ms && new->vm_policy)
+		ms =3D new->vm_policy->memsched;
+
+	if (!ms)
+		return;
+
+	ms_get(ms);
+	new->vm_policy->memsched =3D ms;
+	new->vm_policy->vma =3D new; // XXX probably broken for shared-mem
+	mutex_lock(&ms->mutex);
+	list_add(&new->vm_policy->memsched_entry, &ms->vmas);
+	pages =3D (new->vm_end - new->vm_start) >> PAGE_SHIFT;
+	ms->nr_pages +=3D pages;
+	nq_add_pages(ms->node, pages);
+	mutex_unlock(&ms->mutex);
+}
+
+void memsched_vma_adjust(struct vm_area_struct *vma,
+			 unsigned long start, unsigned long end)
+{
+	struct memsched_struct *ms;
+	struct mempolicy *mpol;
+	long pages;
+
+	if (!vma->vm_policy)
+		return;
+
+	mpol =3D vma->vm_policy;
+	if (!mpol->memsched)
+		return;
+
+	ms =3D mpol->memsched;
+	mutex_lock(&ms->mutex);
+	pages  =3D (end - start) >> PAGE_SHIFT;
+	pages -=3D (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	ms->nr_pages +=3D pages;
+	nq_add_pages(ms->node, pages);
+	mutex_unlock(&ms->mutex);
+}
+
+void memsched_vma_unlink(struct vm_area_struct *vma)
+{
+	struct memsched_struct *ms;
+	struct mempolicy *mpol;
+	long pages;
+
+	if (!vma->vm_policy)
+		return;
+
+	mpol =3D vma->vm_policy;
+	if (!mpol->memsched)
+		return;
+
+	ms =3D mpol->memsched;
+	mutex_lock(&ms->mutex);
+	list_del(&mpol->memsched_entry);
+	pages =3D (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	ms->nr_pages -=3D pages;
+	nq_add_pages(ms->node, -pages);
+	mutex_unlock(&ms->mutex);
+
+	ms_put(ms);
+}
+
+/*
+ * Bind a memory region to a memsched group.
+ *
+ * sys_ms_mbind(addr, len, ms_id, 0);
+ *
+ * create a non-mergable vma over [addr,addr+len) and assign a mpol bindin=
g it
+ * to the memsched group identified by ms_id.
+ *
+ */
+SYSCALL_DEFINE4(ms_mbind, unsigned long, addr, unsigned long, len,
+			  int, ms_id, unsigned long, flags)
+{
+	struct mm_struct *mm =3D current->mm;
+	struct memsched_struct *ms;
+	struct mempolicy *mpol;
+	int err =3D 0;
+
+	if (flags)
+		return -EINVAL;
+
+	ms =3D ms_lookup(ms_id, current);
+	if (IS_ERR(ms))
+		return PTR_ERR(ms);
+
+	mpol =3D mpol_new(MPOL_BIND, 0, nodemask_of_node(ms->node));
+	if (!mpol) {
+		ms_put(ms);
+		return -ENOMEM;
+	}
+	mpol->memsched =3D ms;
+
+	// XXX do we need to validate mbind_range() input?
+	// XXX see what shared-memory mpol vs mpol::vma does
+	mutex_lock(&ms->mutex);
+	err =3D mbind_range(mm, addr, addr+len, mpol);
+	mutex_unlock(&ms->mutex);
+
+	return err;
+}
+
+/*
+ * load-balancing
+ */
+
+struct stats {
+	long min, max;
+	long min_node, max_node;
+	long avg, nr;
+};
+
+static void stats_init(struct stats *s)
+{
+	s->min =3D LONG_MAX;
+	s->max =3D LONG_MIN;
+	s->min_node =3D s->max_node =3D -1;
+	s->avg =3D s->nr =3D 0;
+}
+
+static inline void stats_update(struct stats *s, int node, long load)
+{
+	if (!s)
+		return;
+
+	if (load < s->min) {
+		s->min =3D load;
+		s->min_node =3D node;
+	}
+
+	if (load > s->max) {
+		s->max =3D load;
+		s->max_node =3D node;
+	}
+
+	s->avg +=3D load;
+	s->nr++;
+}
+
+struct node_stats {
+	struct stats ms_mem, ms_cpu;
+	struct stats mem, cpu;
+	long this_mem, this_cpu;
+	long busiest_mem, busiest_cpu;
+	long mem_imb, cpu_imb;
+};
+
+/*
+ * return significance of this load:
+ *  0 - we suck
+ *  1 - max > this
+ *  >1 - max > this && significantly so
+ */
+static int stats_sig(struct stats *s, long this)
+{
+	long var =3D (s->max - (s->avg / s->nr) / 2); // XXX proper variance
+	long diff =3D this - s->max;
+	int ret =3D 0;
+
+	if (diff > 0) {
+		if (diff > var) // XXX this - avg ?
+			ret +=3D diff / (var+1);
+		ret++;
+	}
+
+	return ret;
+}
+
+static long nq_mem_load(struct node_queue_struct *nq, struct stats *s)
+{
+	long load =3D 0;
+
+	spin_lock(&nq->lock);
+	list_for_each_entry(ms, &nq->ms_list, entry) {
+		long ms_load =3D ms->nr_pages;
+		stats_update(s, -1, ms_load);
+		load +=3D ms_load;
+	}
+	spin_unlock(&nq->lock);
+}
+
+static long nq_cpu_load(struct node_queue_struct *nq, struct stats *s)
+{
+	long load =3D 0;
+
+	spin_lock(&nq->lock);
+	list_for_each_entry(ms, &nq->ms_list, entry) {
+		long ms_load =3D memsched_get_load(ms);
+		stats_update(s, -1, ms_load);
+		load +=3D ms_load;
+	}
+	spin_unlock(&nq->lock);
+}
+
+static struct node_queue_struct *
+find_busiest_node(struct node_queue_struct *this, struct node_stats *stats=
)
+{
+	int node;
+	int mem_sig, cpu_sig;
+
+	stats_init(&stats->mem);
+	stats_init(&stats->cpu);
+
+	for_each_online_node(node) {
+		struct node_queue_struct *nq =3D nq_of(node);
+
+		if (nq =3D=3D this) {
+			stats->this_mem =3D nq_mem_load(nq, &stats->ms_mem);
+			stats->this_cpu =3D nq_cpu_load(nq, &stats->ms_cpu);
+			continue;
+		}
+
+		stats_update(&stats->mem, node, nq_mem_load(nq, &stats->ms_mem));
+		stats_update(&stats->cpu, node, nq_cpu_load(nq, &stats->ms_cpu));
+	}
+
+	mem_sig =3D stats_sig(&stats->mem, stats->this_mem);
+	cpu_sig =3D stats_sig(&stats->cpu, stats->this_cpu);
+
+	if (mem_sig > cpu_sig)
+		return nq_of(stats->mem.max_node);
+
+	if (cpu_sig > mem_sig)
+		return nq_of(stats->cpu.max_node);
+
+	if (mem_sig)
+		return nq_of(stats->mem.max_node);
+
+	if (cpu_sig)
+		return nq_of(stats->cpu.max_node);
+
+	return NULL;
+}
+
+static void calc_node_imbalance(struct node_queue_struct *nq,=20
+		struct node_queue_struct *busiest,
+		struct node_stats *stats)
+{
+	long mem_avg, mem_imb;
+	long cpu_avg, cpu_imb;
+
+       	// XXX get clever with stats_update ?
+	stats->busiest_mem =3D nq_mem_load(busiest, NULL);
+	stats->busiest_cpu =3D nq_cpu_load(busiest, NULL);
+
+	mem_avg =3D (stats->mem.avg + stats->this_mem) / (stats->mem.nr + 1);
+	mem_imb =3D min(stats->busiest_mem - stats->this_mem,
+		      stats->busiest_mem - mem_avg);
+
+	cpu_avg =3D (stats->cpu.avg + stats->this_cpu) / (stats->cpu.nr + 1);
+	cpu_imb =3D min(stats->busiest_cpu - stats->this_cpu,
+		      stats->busiest_cpu - cpu_avg);
+
+	stats->mem_imb =3D mem_imb;
+	stats->cpu_imb =3D cpu_imb;
+}
+
+static void ms_migrate_tasks(struct memsched_struct *ms)
+{
+	struct task_struct *task;
+
+	// XXX migrate load
+
+	list_for_each_entry(task, &ms->tasks, memsched_entry)
+		set_cpus_allowed_ptr(task, cpumask_of_node(ms->node));
+}
+
+static void ms_migrate_memory(struct memsched_struct *ms)
+{
+	struct mempolicy *mpol;
+
+	/*
+	 * VMAs are pinned due to ms->mutex in memsched_vma_unlink()
+	 */
+	list_for_each_entry(mpol, &ms->vmas, memsched_entry) {
+		struct vm_area_struct *vma =3D mpol->vma;
+		mpol_rebind_policy(mpol, new, MPOL_REBIND_ONCE);
+
+		/*
+		 * XXX migrate crap.. either direct migrate_pages()
+		 * or preferably unmap and move on fault.
+		 */
+	}
+}
+
+enum {
+	MIGRATE_OK =3D 0,
+	MIGRATE_OTHER,
+	MIGRATE_DONE,
+};
+
+static int ms_can_migrate(struct node_queue_struct *this,
+			  struct node_queue_struct *busiest,
+			  struct memsched_struct *ms,
+			  struct node_stats *stats)
+{
+	long ms_mem, ms_cpu;
+	long ms_mem_avg, mem_cpu_avg;
+=09
+	// XXX something about:
+	//  - last migration
+	//  ...=20
+=09
+	if (stats->mem_imb <=3D 0 && stats->cpu_imb <=3D 0)
+		return MIGRATE_DONE;
+
+	ms_mem =3D ms->nr_pages;
+	ms_cpu =3D memsched_get_load(ms);
+
+	ms_mem_avg =3D stats->ms_mem.avg / stats->ms_mem.nr;
+	ms_cpu_avg =3D stats->ms_cpu.avg / stats->ms_cpu.nr;
+
+	if (stats->mem_imb <=3D 0 && stats->cpu_imb > 0) {
+		if (ms_mem < ms_mem_avg && ms_cpu > ms_cpu_avg)
+			goto do_migrate;
+	} else if (stats->mem_imb > 0 && stats->cpu_imb <=3D 0) {
+		if (ms_mem > ms_mem_avg && ms_cpu < ms_cpu_avg)
+			goto do_migrate;
+	} else if (stats->mem_imb > 0 && stats->cpu_imb > 0) {
+		goto do_migrate;
+	}
+
+	return MIGRATE_OTHER;
+
+do_migrate:
+	stats->mem_imb -=3D ms_mem;
+	stats->cpu_imb -=3D ms_cpu;
+
+	return MIGRATE_OK;
+}
+
+static void ms_migrate(struct memsched_struct *ms, int node)
+{
+	struct node_queue_struct *nq;
+
+	mutex_lock(&ms->lock);
+	nq_add_pages(ms->node, -ms->nr_pages);
+	ms->node =3D node;
+	nq_add_pages(ms->node, ms->nr_pages);
+
+	ms_migrate_tasks(ms);
+	ms_migrate_memory(ms);
+	mutex_unlock(&ms->lock);
+}
+
+static struct memsched_struct *nq_pop(struct node_queue_struct *nq)
+{
+	struct memsched_struct *ms;
+
+	spin_lock(&nq->lock);
+	list_for_each_entry(ms, &nq->ms_list, entry) {
+		/*
+		 * Existence guaranteed by ms_put()->ms_dequeue()
+		 */
+		if (!ms_try_get(ms))
+			continue;
+
+		list_del(&ms->entry);
+		nq->nr_ms--;
+		goto unlock;
+	}
+	ms =3D NULL;
+unlock:
+	spin_unlock(&nq->lock);
+
+	return ms;
+}
+
+static void nq_push(struct node_queue_struct *nq, struct memsched_struct *=
ms)
+{
+	spin_lock(&nq->lock);
+	list_add_tail(&ms->entry, &nq->ms_list);
+	nq->nr_ms++;
+	spin_unlock(&nq->lock);
+
+	ms_put(ms);
+}
+
+static void migrate_groups(struct node_queue_struct *nq,=20
+			   struct node_queue_struct *busiest,=20
+			   struct node_stats *stats)
+{
+	int i, nr =3D ACCESS_ONCE(busiest->nr_ms);
+
+	for (i =3D 0; i < nr; i++) {
+		struct memsched_struct *ms =3D nq_pop(busiest);
+		int state;
+
+		if (!ms)
+			return;
+
+		state =3D ms_can_migrate(nq, busiest, ms, stats);
+		switch (state) {
+		case MIGRATE_DONE:
+			nq_push(busiest, ms);
+			return;
+
+		case MIGRATE_OTHER:
+			nq_push(busiest, ms);
+			continue;
+
+		case MIGRATE_OK:
+			break;
+		}
+
+		ms_migrate(ms, nq->node);
+		nq_push(nq, ms);
+	}
+}
+
+static void do_numa_balance(struct node_queue_struct *nq)
+{
+	struct node_queue_struct *busiest;
+	struct node_stats stats;
+
+	get_online_cpus();
+	busiest =3D find_busiest_node(nq, &stats);
+	if (!busiest)
+		goto done;
+
+	if (busiest->nr_ms < 2)
+		goto done;
+
+	calc_node_imbalance(nq, busiest, &stats);
+	if (stats.mem_imb <=3D 0 && stats.cpu_imb <=3D 0)
+		goto done;
+
+	migrate_groups(nq, busiest, &stats);
+done:
+	nq->next_schedule +=3D memsched_balance_interval;
+	put_online_cpus();
+}
+
+int numad_thread(void *data)
+{
+	struct node_queue_struct *nq =3D data;
+	struct task_struct *p =3D nq->numad;
+
+	set_cpus_allowed_ptr(p, cpumask_of_node(nq->node));
+
+	while (!kthread_stop(p)) {
+
+		do_numa_balance(nq);
+
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+		timeout =3D nq->next_schedule - jiffies;
+		if (timeout > 0)
+			schedule_timeout(timeout);
+		set_current_state(TASK_RUNNING);
+	}
+
+	return 0;
+}
+
+/*
+ * init bits
+ */
+
+static __init void memsched_init(void)
+{
+	int node;
+
+	for_each_online_node(node) { // XXX hotplug
+		struct node_queue_struct *nq;
+		nq =3D kmalloc_node(sizeof(*nq), node, GFP_KERNEL);
+		BUG_ON(!nq);
+		spin_lock_init(&nq->lock);
+		INIT_LIST_HEAD(&nq->ms_list);
+		nq->numad =3D kthread_create_on_node(numad_thread,
+				nq, node, "numad/%d", node);
+		BUG_ON(nq->numad);
+		nq->next_schedule =3D jiffies + HZ;
+		nq->node =3D node;
+		nqs[node] =3D nq;
+
+		wake_up_process(nq->numad);
+	}
+}
+early_initcall(memsched_init);
diff --git a/kernel/sched.c b/kernel/sched.c
index 24637c7..38d603b 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -71,6 +71,7 @@
 #include <linux/ctype.h>
 #include <linux/ftrace.h>
 #include <linux/slab.h>
+#include <linux/memsched.h>
=20
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
@@ -1924,19 +1925,22 @@ static void dec_nr_running(struct rq *rq)
 static void set_load_weight(struct task_struct *p)
 {
 	int prio =3D p->static_prio - MAX_RT_PRIO;
-	struct load_weight *load =3D &p->se.load;
+	struct load_weight load;
=20
 	/*
 	 * SCHED_IDLE tasks get minimal weight:
 	 */
 	if (p->policy =3D=3D SCHED_IDLE) {
-		load->weight =3D scale_load(WEIGHT_IDLEPRIO);
-		load->inv_weight =3D WMULT_IDLEPRIO;
-		return;
+		load.weight =3D scale_load(WEIGHT_IDLEPRIO);
+		load.inv_weight =3D WMULT_IDLEPRIO;
+	} else {
+		load.weight =3D scale_load(prio_to_weight[prio]);
+		load.inv_weight =3D prio_to_wmult[prio];
 	}
=20
-	load->weight =3D scale_load(prio_to_weight[prio]);
-	load->inv_weight =3D prio_to_wmult[prio];
+	memsched_cpu_weight_update(p, load.weight);
+
+       	p->se.load =3D load;
 }
=20
 static void enqueue_task(struct rq *rq, struct task_struct *p, int flags)
diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
index 5c9e679..6201ea1 100644
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -598,6 +598,7 @@ static void update_curr(struct cfs_rq *cfs_rq)
 		trace_sched_stat_runtime(curtask, delta_exec, curr->vruntime);
 		cpuacct_charge(curtask, delta_exec);
 		account_group_exec_runtime(curtask, delta_exec);
+		memsched_cpu_acct(curtask, delta_exec);
 	}
=20
 	account_cfs_rq_runtime(cfs_rq, delta_exec);
@@ -607,6 +608,7 @@ static inline void
 update_stats_wait_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
 	schedstat_set(se->statistics.wait_start, rq_of(cfs_rq)->clock);
+	se->wait_start =3D rq_of(cfs_rq)->clock_task;
 }
=20
 /*
@@ -630,12 +632,14 @@ update_stats_wait_end(struct cfs_rq *cfs_rq, struct s=
ched_entity *se)
 	schedstat_set(se->statistics.wait_count, se->statistics.wait_count + 1);
 	schedstat_set(se->statistics.wait_sum, se->statistics.wait_sum +
 			rq_of(cfs_rq)->clock - se->statistics.wait_start);
-#ifdef CONFIG_SCHEDSTATS
 	if (entity_is_task(se)) {
+#ifdef CONFIG_SCHEDSTATS
 		trace_sched_stat_wait(task_of(se),
 			rq_of(cfs_rq)->clock - se->statistics.wait_start);
-	}
 #endif
+		memsched_cpu_acct_wait(task_of(se),=20
+				rq_of(cfs_rq)->clock_task, se->wait_start);
+	}
 	schedstat_set(se->statistics.wait_start, 0);
 }
=20
diff --git a/kernel/sched_rt.c b/kernel/sched_rt.c
index 056cbd2..4a05003 100644
--- a/kernel/sched_rt.c
+++ b/kernel/sched_rt.c
@@ -690,6 +690,7 @@ static void update_curr_rt(struct rq *rq)
=20
 	curr->se.exec_start =3D rq->clock_task;
 	cpuacct_charge(curr, delta_exec);
+	memsched_cpu_acct(curr, delta_exec);
=20
 	sched_rt_avg_update(rq, delta_exec);
=20
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9c51f9f..4c38c91 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -623,6 +623,8 @@ static int policy_vma(struct vm_area_struct *vma, struc=
t mempolicy *new)
 	if (!err) {
 		mpol_get(new);
 		vma->vm_policy =3D new;
+		memsched_vma_link(vma, NULL);
+		memsched_vma_unlink(old);
 		mpol_put(old);
 	}
 	return err;
@@ -1951,6 +1953,18 @@ struct mempolicy *__mpol_dup(struct mempolicy *old)
 	return new;
 }
=20
+int vma_dup_policy(struct vm_area_struct *new, struct vm_area_struct *old)
+{
+	struct mempolicy *mpol;
+
+	mpol =3D mpol_dup(vma_policy(old));
+	if (IS_ERR(mpol))
+		return PTR_ERR(mpol);
+	vma_set_policy(new, mpol);
+	memsched_vma_link(new, old);
+	return 0;
+}
+
 /*
  * If *frompol needs [has] an extra ref, copy *frompol to *tompol ,
  * eliminate the * MPOL_F_* flags that require conditional ref and
diff --git a/mm/mmap.c b/mm/mmap.c
index a65efd4..50e05f6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -235,6 +235,7 @@ static struct vm_area_struct *remove_vma(struct vm_area=
_struct *vma)
 		if (vma->vm_flags & VM_EXECUTABLE)
 			removed_exe_file_vma(vma->vm_mm);
 	}
+	memsched_vma_unlink(vma);
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
@@ -579,10 +580,13 @@ again:			remove_next =3D 1 + (end > next->vm_end);
 			vma_prio_tree_remove(next, root);
 	}
=20
+	memsched_vma_adjust(vma, start, end);
 	vma->vm_start =3D start;
 	vma->vm_end =3D end;
 	vma->vm_pgoff =3D pgoff;
 	if (adjust_next) {
+		memsched_vma_adjust(vma, next->vm_start + (adjust_next << PAGE_SHIFT),
+					 next->vm_end);
 		next->vm_start +=3D adjust_next << PAGE_SHIFT;
 		next->vm_pgoff +=3D adjust_next;
 	}
@@ -625,6 +629,7 @@ again:			remove_next =3D 1 + (end > next->vm_end);
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
+		memsched_vma_unlink(next);
 		mpol_put(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
 		/*
@@ -1953,12 +1958,9 @@ static int __split_vma(struct mm_struct * mm, struct=
 vm_area_struct * vma,
 		new->vm_pgoff +=3D ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
=20
-	pol =3D mpol_dup(vma_policy(vma));
-	if (IS_ERR(pol)) {
-		err =3D PTR_ERR(pol);
+	err =3D vma_dup_policy(new, vma);
+	if (err)
 		goto out_free_vma;
-	}
-	vma_set_policy(new, pol);
=20
 	if (anon_vma_clone(new, vma))
 		goto out_free_mpol;
@@ -1992,6 +1994,7 @@ static int __split_vma(struct mm_struct * mm, struct =
vm_area_struct * vma,
 	}
 	unlink_anon_vmas(new);
  out_free_mpol:
+	memsched_vma_unlock(new);
 	mpol_put(pol);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new);
@@ -2344,13 +2347,11 @@ struct vm_area_struct *copy_vma(struct vm_area_stru=
ct **vmap,
 		new_vma =3D kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
 			*new_vma =3D *vma;
-			pol =3D mpol_dup(vma_policy(vma));
-			if (IS_ERR(pol))
+			if (vma_dup_policy(new_vma, vma))
 				goto out_free_vma;
 			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
 			if (anon_vma_clone(new_vma, vma))
 				goto out_free_mempol;
-			vma_set_policy(new_vma, pol);
 			new_vma->vm_start =3D addr;
 			new_vma->vm_end =3D addr + len;
 			new_vma->vm_pgoff =3D pgoff;
@@ -2367,6 +2368,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct=
 **vmap,
 	return new_vma;
=20
  out_free_mempol:
+	memsched_vma_unlink(new_vma);
 	mpol_put(pol);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new_vma);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
