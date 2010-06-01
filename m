Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 190D96B01EF
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:33:55 -0400 (EDT)
Date: Tue, 1 Jun 2010 17:33:43 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] forked kernel task and mm structures imbalanced on NUMA
Message-ID: <20100601073343.GQ9453@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

This isn't really a new problem, and I don't know how important it is,
but I recently came across it again when doing some aim7 testing with
huge numbers of tasks.

Basically the parent process forks off children processes, which quickly
go to sleep. Then the parent signals them all to start running.

We do a relatively good job of sched-fork balancing, however the memory
allocations to set up the child task (task struct, stack, mm, page
tables, vmas, fds, etc etc) are all coming from the parent.

So this causes two problems. Firstly memory consumption. With tens of
thousands of tasks, aim7 can allocate hundreds of megs of unswappable
kernel memory on a single node. aim7 is not a good workload to optimise
for, but improving memory balancing over nodes is always preferable.

The other one is remote memory access and interconnect hot-spots with
page tables, stack, vmas etc all allocated on one node. I think it will
be good to allocate these on task-local nodes if possible (or at least
spread them over nodes so there is interleaving rather than accessing
a single memory controller).

I have just put together a basic patch which uses memory policy stuff
for this. It has a problem that it doesn't obey parent policy properly
if parent has an unusual policy that should carry over to the child
(to do that right, we either need surgery on mpol layer or migrate the
parent to the target CPU before forking, which is obviously nasty).

Another problem I found when testing this patch is that the scheduler
has some issues of its own when balancing. This is improved by
traversing the sd groups starting from a different spot each time, so
processes get sprinkled around the nodes a bit better.

This patch is not to be applied (yet), just want to get opinions.

Thanks,
Nick

---
 include/linux/mempolicy.h |   11 +++++++++++
 include/linux/sched.h     |    7 +++++++
 kernel/fork.c             |   27 +++++++++++++++++++++++++--
 kernel/sched.c            |   31 ++++++++++++++++++++++---------
 kernel/sched_fair.c       |   15 +++++++++++----
 mm/mempolicy.c            |   30 ++++++++++++++++++++++++++++++
 6 files changed, 106 insertions(+), 15 deletions(-)

Index: linux-2.6/include/linux/mempolicy.h
===================================================================
--- linux-2.6.orig/include/linux/mempolicy.h
+++ linux-2.6/include/linux/mempolicy.h
@@ -199,6 +199,8 @@ void mpol_free_shared_policy(struct shar
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
+extern void *mpol_prefer_cpu_start(int cpu);
+extern void mpol_prefer_cpu_end(void *arg);
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
@@ -307,6 +309,15 @@ mpol_shared_policy_lookup(struct shared_
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
 
+static inline int mpol_prefer_cpu_start(int cpu)
+{
+	return 0;
+}
+
+static inline void mpol_prefer_cpu_end(int arg)
+{
+}
+
 static inline void numa_policy_init(void)
 {
 }
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -918,6 +918,7 @@ struct sched_domain {
 	enum sched_domain_level level;
 
 	/* Runtime fields. */
+	struct sched_group *iter;
 	unsigned long last_balance;	/* init to jiffies. units in jiffies */
 	unsigned int balance_interval;	/* initialise to 1. units in ms. */
 	unsigned int nr_balance_failed; /* initialise to 0 */
@@ -1997,6 +1998,7 @@ extern void wake_up_new_task(struct task
 #else
  static inline void kick_process(struct task_struct *tsk) { }
 #endif
+extern int sched_fork_suggest_cpu(int clone_flags);
 extern void sched_fork(struct task_struct *p, int clone_flags);
 extern void sched_dead(struct task_struct *p);
 
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -950,6 +950,8 @@ static void posix_cpu_timers_init(struct
 	INIT_LIST_HEAD(&tsk->cpu_timers[2]);
 }
 
+void sched_migrate_task(struct task_struct *p, int dest_cpu);
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -966,6 +968,9 @@ static struct task_struct *copy_process(
 					struct pid *pid,
 					int trace)
 {
+	int my_cpu;
+	int cpu;
+	void *mpol_arg;
 	int retval;
 	struct task_struct *p;
 	int cgroup_callbacks_done = 0;
@@ -1002,10 +1007,20 @@ static struct task_struct *copy_process(
 	if (retval)
 		goto fork_out;
 
+	cpu = sched_fork_suggest_cpu(clone_flags);
+	my_cpu = raw_smp_processor_id();
+//	if (cpu != my_cpu && cpu_to_node(cpu) != cpu_to_node(my_cpu))
+//		sched_migrate_task(current, cpu);
+//	else
+//		my_cpu = -1;
+	mpol_arg = mpol_prefer_cpu_start(cpu);
+
+//	printk("%d:%s forks %d->%d (mpol=%p)\n", current->pid, current->comm, my_cpu, cpu, mpol_arg);
+
 	retval = -ENOMEM;
 	p = dup_task_struct(current);
 	if (!p)
-		goto fork_out;
+		goto fork_mpol;
 
 	ftrace_graph_init_task(p);
 
@@ -1119,8 +1134,9 @@ static struct task_struct *copy_process(
 	p->memcg_batch.memcg = NULL;
 #endif
 
-	/* Perform scheduler related setup. Assign this task to a CPU. */
+	/* Perform scheduler related setup. */
 	sched_fork(p, clone_flags);
+	set_task_cpu(p, cpu);
 
 	retval = perf_event_init_task(p);
 	if (retval)
@@ -1284,6 +1300,9 @@ static struct task_struct *copy_process(
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	perf_event_fork(p);
+	mpol_prefer_cpu_end(mpol_arg);
+//	if (my_cpu != -1)
+//		sched_migrate_task(current, my_cpu);
 	return p;
 
 bad_fork_free_pid:
@@ -1324,6 +1343,10 @@ bad_fork_cleanup_count:
 	exit_creds(p);
 bad_fork_free:
 	free_task(p);
+fork_mpol:
+	mpol_prefer_cpu_end(mpol_arg);
+//	if (my_cpu != -1)
+//		sched_migrate_task(current, my_cpu);
 fork_out:
 	return ERR_PTR(retval);
 }
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -2433,6 +2433,24 @@ int wake_up_state(struct task_struct *p,
 	return try_to_wake_up(p, state, 0);
 }
 
+int sched_fork_suggest_cpu(int clone_flags)
+{
+#ifdef CONFIG_SMP
+	struct rq *rq;
+	unsigned long flags;
+	int cpu;
+
+	rq = task_rq_lock(current, &flags);
+	cpu = current->sched_class->select_task_rq(rq, current, SD_BALANCE_FORK, 0);
+
+	task_rq_unlock(rq, &flags);
+
+	return cpu;
+#else
+	return 0; /* Could avoid the out of line call if this were inline */
+#endif
+}
+
 /*
  * Perform scheduler related setup for a newly forked process p.
  * p is forked by current.
@@ -2464,8 +2482,6 @@ static void __sched_fork(struct task_str
  */
 void sched_fork(struct task_struct *p, int clone_flags)
 {
-	int cpu = get_cpu();
-
 	__sched_fork(p);
 	/*
 	 * We mark the process as running here. This guarantees that
@@ -2507,8 +2523,6 @@ void sched_fork(struct task_struct *p, i
 	if (p->sched_class->task_fork)
 		p->sched_class->task_fork(p);
 
-	set_task_cpu(p, cpu);
-
 #if defined(CONFIG_SCHEDSTATS) || defined(CONFIG_TASK_DELAY_ACCT)
 	if (likely(sched_info_on()))
 		memset(&p->sched_info, 0, sizeof(p->sched_info));
@@ -2521,8 +2535,6 @@ void sched_fork(struct task_struct *p, i
 	task_thread_info(p)->preempt_count = 1;
 #endif
 	plist_node_init(&p->pushable_tasks, MAX_PRIO);
-
-	put_cpu();
 }
 
 /*
@@ -2538,9 +2550,8 @@ void wake_up_new_task(struct task_struct
 	struct rq *rq;
 	int cpu __maybe_unused = get_cpu();
 
-#ifdef CONFIG_SMP
 	rq = task_rq_lock(p, &flags);
-	p->state = TASK_WAKING;
+#ifdef CONFIG_SMP
 
 	/*
 	 * Fork balancing, do it here and not earlier because:
@@ -2550,14 +2561,16 @@ void wake_up_new_task(struct task_struct
 	 * We set TASK_WAKING so that select_task_rq() can drop rq->lock
 	 * without people poking at ->cpus_allowed.
 	 */
-	cpu = select_task_rq(rq, p, SD_BALANCE_FORK, 0);
-	set_task_cpu(p, cpu);
-
-	p->state = TASK_RUNNING;
-	task_rq_unlock(rq, &flags);
+	if (!cpumask_test_cpu(cpu, &p->cpus_allowed)) {
+		p->state = TASK_WAKING;
+		cpu = select_task_rq(rq, p, SD_BALANCE_FORK, 0);
+		set_task_cpu(p, cpu);
+		p->state = TASK_RUNNING;
+		task_rq_unlock(rq, &flags);
+		rq = task_rq_lock(p, &flags);
+	}
 #endif
 
-	rq = task_rq_lock(p, &flags);
 	activate_task(rq, p, 0);
 	trace_sched_wakeup_new(p, 1);
 	check_preempt_curr(rq, p, WF_FORK);
@@ -6492,6 +6505,7 @@ static int build_numa_sched_groups(struc
 	for_each_cpu(j, d->nodemask) {
 		sd = &per_cpu(node_domains, j).sd;
 		sd->groups = sg;
+		sd->iter = sd->groups;
 	}
 
 	sg->cpu_power = 0;
@@ -6809,6 +6823,7 @@ static struct sched_domain *__build_cpu_
 	if (parent)
 		parent->child = sd;
 	cpu_to_phys_group(i, cpu_map, &sd->groups, d->tmpmask);
+	sd->iter = sd->groups;
 	return sd;
 }
 
@@ -6825,6 +6840,7 @@ static struct sched_domain *__build_mc_s
 	sd->parent = parent;
 	parent->child = sd;
 	cpu_to_core_group(i, cpu_map, &sd->groups, d->tmpmask);
+	sd->iter = sd->groups;
 #endif
 	return sd;
 }
@@ -6842,6 +6858,7 @@ static struct sched_domain *__build_smt_
 	sd->parent = parent;
 	parent->child = sd;
 	cpu_to_cpu_group(i, cpu_map, &sd->groups, d->tmpmask);
+	sd->iter = sd->groups;
 #endif
 	return sd;
 }
Index: linux-2.6/kernel/sched_fair.c
===================================================================
--- linux-2.6.orig/kernel/sched_fair.c
+++ linux-2.6/kernel/sched_fair.c
@@ -1302,10 +1302,14 @@ static struct sched_group *
 find_idlest_group(struct sched_domain *sd, struct task_struct *p,
 		  int this_cpu, int load_idx)
 {
-	struct sched_group *idlest = NULL, *this = NULL, *group = sd->groups;
+	struct sched_group *idlest = NULL, *this = NULL;
+	struct sched_group *iter = sd->iter;
+	struct sched_group *group = iter;
 	unsigned long min_load = ULONG_MAX, this_load = 0;
 	int imbalance = 100 + (sd->imbalance_pct-100)/2;
 
+	sd->iter = iter->next;
+
 	do {
 		unsigned long load, avg_load;
 		int local_group;
@@ -1342,7 +1346,7 @@ find_idlest_group(struct sched_domain *s
 			min_load = avg_load;
 			idlest = group;
 		}
-	} while (group = group->next, group != sd->groups);
+	} while (group = group->next, group != iter);
 
 	if (!idlest || 100*this_load < imbalance*min_load)
 		return NULL;
@@ -2434,10 +2438,13 @@ static inline void update_sd_lb_stats(st
 			struct sd_lb_stats *sds)
 {
 	struct sched_domain *child = sd->child;
-	struct sched_group *group = sd->groups;
+	struct sched_group *iter = sd->iter;
+	struct sched_group *group = iter;
 	struct sg_lb_stats sgs;
 	int load_idx, prefer_sibling = 0;
 
+	sd->iter = iter->next;
+
 	if (child && child->flags & SD_PREFER_SIBLING)
 		prefer_sibling = 1;
 
@@ -2485,7 +2492,7 @@ static inline void update_sd_lb_stats(st
 
 		update_sd_power_savings_stats(group, sds, local_group, &sgs);
 		group = group->next;
-	} while (group != sd->groups);
+	} while (group != iter);
 }
 
 /**
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c
+++ linux-2.6/mm/mempolicy.c
@@ -2163,6 +2163,36 @@ void mpol_free_shared_policy(struct shar
 	spin_unlock(&p->lock);
 }
 
+void *mpol_prefer_cpu_start(int cpu)
+{
+	struct mempolicy *old;
+	nodemask_t prefer_node = nodemask_of_node(cpu_to_node(cpu));
+
+	task_lock(current);
+	old = current->mempolicy;
+	current->mempolicy = NULL;
+	task_unlock(current);
+
+	if (do_set_mempolicy(MPOL_PREFERRED, 0, &prefer_node)) {
+		current->mempolicy = old;
+		return NULL;
+	}
+
+	return old;
+}
+
+void mpol_prefer_cpu_end(void *arg)
+{
+	struct mempolicy *old;
+
+	task_lock(current);
+	old = current->mempolicy;
+	current->mempolicy = arg;
+	task_unlock(current);
+
+	mpol_put(old);
+}
+
 /* assumes fs == KERNEL_DS */
 void __init numa_policy_init(void)
 {
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c
+++ linux-2.6/fs/exec.c
@@ -1327,6 +1327,8 @@ int do_execve(char * filename,
 	bool clear_in_exec;
 	int retval;
 
+	sched_exec();
+
 	retval = unshare_files(&displaced);
 	if (retval)
 		goto out_ret;
@@ -1351,8 +1353,6 @@ int do_execve(char * filename,
 	if (IS_ERR(file))
 		goto out_unmark;
 
-	sched_exec();
-
 	bprm->file = file;
 	bprm->filename = filename;
 	bprm->interp = filename;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
