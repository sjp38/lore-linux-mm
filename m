Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 76BA26B0089
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:16:01 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1265542eaa.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:59 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 18/27] sched: Add adaptive NUMA affinity support
Date: Mon, 19 Nov 2012 03:14:35 +0100
Message-Id: <1353291284-2998-19-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

The principal ideas behind this patch are the fundamental
difference between shared and privately used memory and the very
strong desire to only rely on per-task behavioral state for
scheduling decisions.

We define 'shared memory' as all user memory that is frequently
accessed by multiple tasks and conversely 'private memory' is
the user memory used predominantly by a single task.

To approximate the above strict definition we recognise that
task placement is dominantly per cpu and thus using cpu granular
page access state is a natural fit. Thus we introduce
page::last_cpu as the cpu that last accessed a page.

Using this, we can construct two per-task node-vectors, 'S_i'
and 'P_i' reflecting the amount of shared and privately used
pages of this task respectively. Pages for which two consecutive
'hits' are of the same cpu are assumed private and the others
are shared.

[ This means that we will start evaluating this state when the
  task has not migrated for at least 2 scans, see NUMA_SETTLE ]

Using these vectors we can compute the total number of
shared/private pages of this task and determine which dominates.

[ Note that for shared tasks we only see '1/n' the total number
  of shared pages for the other tasks will take the other
  faults; where 'n' is the number of tasks sharing the memory.
  So for an equal comparison we should divide total private by
  'n' as well, but we don't have 'n' so we pick 2. ]

We can also compute which node holds most of our memory, running
on this node will be called 'ideal placement' (As per previous
patches we will prefer to pull memory towards wherever we run.)

We change the load-balancer to prefer moving tasks in order of:

  1) !numa tasks and numa tasks in the direction of more faults
  2) allow !ideal tasks getting worse in the direction of faults
  3) allow private tasks to get worse
  4) allow shared tasks to get worse

This order ensures we prefer increasing memory locality but when
we do have to make hard decisions we prefer spreading private
over shared, because spreading shared tasks significantly
increases the interconnect bandwidth since not all memory can
follow.

We also add an extra 'lateral' force to the load balancer that
perturbs the state when otherwise 'fairly' balanced. This
ensures we don't get 'stuck' in a state which is fair but
undesired from a memory location POV (see can_do_numa_run()).

Lastly, we allow shared tasks to defeat the default spreading of
tasks such that, when possible, they can aggregate on a single
node.

Shared tasks aggregate for the very simple reason that there has
to be a single node that holds most of their memory and a second
most, etc.. and tasks want to move up the faults ladder.

Enable it on x86. A number of other architectures are
most likely fine too - but they should enable and test this
feature explicitly.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 Documentation/scheduler/numa-problem.txt |  20 +-
 arch/x86/Kconfig                         |   2 +
 include/linux/sched.h                    |   1 +
 kernel/sched/core.c                      |  53 +-
 kernel/sched/fair.c                      | 975 +++++++++++++++++++++++++------
 kernel/sched/features.h                  |   8 +
 kernel/sched/sched.h                     |  38 +-
 7 files changed, 900 insertions(+), 197 deletions(-)

diff --git a/Documentation/scheduler/numa-problem.txt b/Documentation/scheduler/numa-problem.txt
index a5d2fee..7f133e3 100644
--- a/Documentation/scheduler/numa-problem.txt
+++ b/Documentation/scheduler/numa-problem.txt
@@ -133,6 +133,8 @@ XXX properties of this M vs a potential optimal
 
  2b) migrate memory towards 'n_i' using 2 samples.
 
+XXX include the statistical babble on double sampling somewhere near
+
 This separates pages into those that will migrate and those that will not due
 to the two samples not matching. We could consider the first to be of 'p_i'
 (private) and the second to be of 's_i' (shared).
@@ -142,7 +144,17 @@ This interpretation can be motivated by the previously observed property that
 's_i' (shared). (here we loose the need for memory limits again, since it
 becomes indistinguishable from shared).
 
-XXX include the statistical babble on double sampling somewhere near
+ 2c) use cpu samples instead of node samples
+
+The problem with sampling on node granularity is that one looses 's_i' for
+the local node, since one cannot distinguish between two accesses from the
+same node.
+
+By increasing the granularity to per-cpu we gain the ability to have both an
+'s_i' and 'p_i' per node. Since we do all task placement per-cpu as well this
+seems like a natural match. The line where we overcommit cpus is where we loose
+granularity again, but when we loose overcommit we naturally spread tasks.
+Therefore it should work out nicely.
 
 This reduces the problem further; we loose 'M' as per 2a, it further reduces
 the 'T_k,l' (interconnect traffic) term to only include shared (since per the
@@ -150,12 +162,6 @@ above all private will be local):
 
   T_k,l = \Sum_i bs_i,l for every n_i = k, l != k
 
-[ more or less matches the state of sched/numa and describes its remaining
-  problems and assumptions. It should work well for tasks without significant
-  shared memory usage between tasks. ]
-
-Possible future directions:
-
 Motivated by the form of 'T_k,l', try and obtain each term of the sum, so we
 can evaluate it;
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 46c3bff..95646fe 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -22,6 +22,8 @@ config X86
 	def_bool y
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
+	select ARCH_SUPPORTS_NUMA_BALANCING
+	select ARCH_WANTS_NUMA_GENERIC_PGPROT
 	select HAVE_IDE
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 418d405..bb12cc3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -823,6 +823,7 @@ enum cpu_idle_type {
 #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
 #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
 #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
+#define SD_NUMA			0x4000	/* cross-node balancing */
 
 extern int __weak arch_sd_sibiling_asym_packing(void);
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 3611f5f..7b58366 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1800,6 +1800,7 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
 	if (mm)
 		mmdrop(mm);
 	if (unlikely(prev_state == TASK_DEAD)) {
+		task_numa_free(prev);
 		/*
 		 * Remove function-return probe instances associated with this
 		 * task and put them back on the free list.
@@ -5510,7 +5511,9 @@ static void destroy_sched_domains(struct sched_domain *sd, int cpu)
 DEFINE_PER_CPU(struct sched_domain *, sd_llc);
 DEFINE_PER_CPU(int, sd_llc_id);
 
-static void update_top_cache_domain(int cpu)
+DEFINE_PER_CPU(struct sched_domain *, sd_node);
+
+static void update_domain_cache(int cpu)
 {
 	struct sched_domain *sd;
 	int id = cpu;
@@ -5521,6 +5524,15 @@ static void update_top_cache_domain(int cpu)
 
 	rcu_assign_pointer(per_cpu(sd_llc, cpu), sd);
 	per_cpu(sd_llc_id, cpu) = id;
+
+	for_each_domain(cpu, sd) {
+		if (cpumask_equal(sched_domain_span(sd),
+				  cpumask_of_node(cpu_to_node(cpu))))
+			goto got_node;
+	}
+	sd = NULL;
+got_node:
+	rcu_assign_pointer(per_cpu(sd_node, cpu), sd);
 }
 
 /*
@@ -5563,7 +5575,7 @@ cpu_attach_domain(struct sched_domain *sd, struct root_domain *rd, int cpu)
 	rcu_assign_pointer(rq->sd, sd);
 	destroy_sched_domains(tmp, cpu);
 
-	update_top_cache_domain(cpu);
+	update_domain_cache(cpu);
 }
 
 /* cpus with isolated domains */
@@ -5985,6 +5997,37 @@ static struct sched_domain_topology_level default_topology[] = {
 
 static struct sched_domain_topology_level *sched_domain_topology = default_topology;
 
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * Change a task's NUMA state - called from the placement tick.
+ */
+void sched_setnuma(struct task_struct *p, int node, int shared)
+{
+	unsigned long flags;
+	int on_rq, running;
+	struct rq *rq;
+
+	rq = task_rq_lock(p, &flags);
+	on_rq = p->on_rq;
+	running = task_current(rq, p);
+
+	if (on_rq)
+		dequeue_task(rq, p, 0);
+	if (running)
+		p->sched_class->put_prev_task(rq, p);
+
+	p->numa_shared = shared;
+	p->numa_max_node = node;
+
+	if (running)
+		p->sched_class->set_curr_task(rq);
+	if (on_rq)
+		enqueue_task(rq, p, 0);
+	task_rq_unlock(rq, p, &flags);
+}
+
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_NUMA
 
 static int sched_domains_numa_levels;
@@ -6030,6 +6073,7 @@ sd_numa_init(struct sched_domain_topology_level *tl, int cpu)
 					| 0*SD_SHARE_PKG_RESOURCES
 					| 1*SD_SERIALIZE
 					| 0*SD_PREFER_SIBLING
+					| 1*SD_NUMA
 					| sd_local_flags(level)
 					,
 		.last_balance		= jiffies,
@@ -6884,7 +6928,6 @@ void __init sched_init(void)
 		rq->post_schedule = 0;
 		rq->active_balance = 0;
 		rq->next_balance = jiffies;
-		rq->push_cpu = 0;
 		rq->cpu = i;
 		rq->online = 0;
 		rq->idle_stamp = 0;
@@ -6892,6 +6935,10 @@ void __init sched_init(void)
 
 		INIT_LIST_HEAD(&rq->cfs_tasks);
 
+#ifdef CONFIG_NUMA_BALANCING
+		rq->nr_shared_running = 0;
+#endif
+
 		rq_attach_root(rq, &def_root_domain);
 #ifdef CONFIG_NO_HZ
 		rq->nohz_flags = 0;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8af0208..f3aeaac 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -29,6 +29,9 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/random.h>
+#include <linux/mempolicy.h>
+#include <linux/task_work.h>
 
 #include <trace/events/sched.h>
 
@@ -774,6 +777,235 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
 }
 
 /**************************************************
+ * Scheduling class numa methods.
+ *
+ * The purpose of the NUMA bits are to maintain compute (task) and data
+ * (memory) locality.
+ *
+ * We keep a faults vector per task and use periodic fault scans to try and
+ * estalish a task<->page relation. This assumes the task<->page relation is a
+ * compute<->data relation, this is false for things like virt. and n:m
+ * threading solutions but its the best we can do given the information we
+ * have.
+ *
+ * We try and migrate such that we increase along the order provided by this
+ * vector while maintaining fairness.
+ *
+ * Tasks start out with their numa status unset (-1) this effectively means
+ * they act !NUMA until we've established the task is busy enough to bother
+ * with placement.
+ */
+
+#ifdef CONFIG_SMP
+static unsigned long task_h_load(struct task_struct *p);
+#endif
+
+#ifdef CONFIG_NUMA_BALANCING
+static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	if (task_numa_shared(p) != -1) {
+		p->numa_weight = task_h_load(p);
+		rq->nr_numa_running++;
+		rq->nr_shared_running += task_numa_shared(p);
+		rq->nr_ideal_running += (cpu_to_node(task_cpu(p)) == p->numa_max_node);
+		rq->numa_weight += p->numa_weight;
+	}
+}
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+	if (task_numa_shared(p) != -1) {
+		rq->nr_numa_running--;
+		rq->nr_shared_running -= task_numa_shared(p);
+		rq->nr_ideal_running -= (cpu_to_node(task_cpu(p)) == p->numa_max_node);
+		rq->numa_weight -= p->numa_weight;
+	}
+}
+
+/*
+ * numa task sample period in ms: 5s
+ */
+unsigned int sysctl_sched_numa_scan_period_min = 5000;
+unsigned int sysctl_sched_numa_scan_period_max = 5000*16;
+
+/*
+ * Wait for the 2-sample stuff to settle before migrating again
+ */
+unsigned int sysctl_sched_numa_settle_count = 2;
+
+static void task_numa_migrate(struct task_struct *p, int next_cpu)
+{
+	p->numa_migrate_seq = 0;
+}
+
+static void task_numa_placement(struct task_struct *p)
+{
+	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
+	unsigned long total[2] = { 0, 0 };
+	unsigned long faults, max_faults = 0;
+	int node, priv, shared, max_node = -1;
+
+	if (p->numa_scan_seq == seq)
+		return;
+
+	p->numa_scan_seq = seq;
+
+	for (node = 0; node < nr_node_ids; node++) {
+		faults = 0;
+		for (priv = 0; priv < 2; priv++) {
+			faults += p->numa_faults[2*node + priv];
+			total[priv] += p->numa_faults[2*node + priv];
+			p->numa_faults[2*node + priv] /= 2;
+		}
+		if (faults > max_faults) {
+			max_faults = faults;
+			max_node = node;
+		}
+	}
+
+	if (max_node != p->numa_max_node)
+		sched_setnuma(p, max_node, task_numa_shared(p));
+
+	p->numa_migrate_seq++;
+	if (sched_feat(NUMA_SETTLE) &&
+	    p->numa_migrate_seq < sysctl_sched_numa_settle_count)
+		return;
+
+	/*
+	 * Note: shared is spread across multiple tasks and in the future
+	 * we might want to consider a different equation below to reduce
+	 * the impact of a little private memory accesses.
+	 */
+	shared = (total[0] >= total[1] / 2);
+	if (shared != task_numa_shared(p)) {
+		sched_setnuma(p, p->numa_max_node, shared);
+		p->numa_migrate_seq = 0;
+	}
+}
+
+/*
+ * Got a PROT_NONE fault for a page on @node.
+ */
+void task_numa_fault(int node, int last_cpu, int pages)
+{
+	struct task_struct *p = current;
+	int priv = (task_cpu(p) == last_cpu);
+
+	if (unlikely(!p->numa_faults)) {
+		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
+
+		p->numa_faults = kzalloc(size, GFP_KERNEL);
+		if (!p->numa_faults)
+			return;
+	}
+
+	task_numa_placement(p);
+	p->numa_faults[2*node + priv] += pages;
+}
+
+/*
+ * The expensive part of numa migration is done from task_work context.
+ * Triggered from task_tick_numa().
+ */
+void task_numa_work(struct callback_head *work)
+{
+	unsigned long migrate, next_scan, now = jiffies;
+	struct task_struct *p = current;
+	struct mm_struct *mm = p->mm;
+
+	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
+
+	work->next = work; /* protect against double add */
+	/*
+	 * Who cares about NUMA placement when they're dying.
+	 *
+	 * NOTE: make sure not to dereference p->mm before this check,
+	 * exit_task_work() happens _after_ exit_mm() so we could be called
+	 * without p->mm even though we still had it when we enqueued this
+	 * work.
+	 */
+	if (p->flags & PF_EXITING)
+		return;
+
+	/*
+	 * Enforce maximal scan/migration frequency..
+	 */
+	migrate = mm->numa_next_scan;
+	if (time_before(now, migrate))
+		return;
+
+	next_scan = now + 2*msecs_to_jiffies(sysctl_sched_numa_scan_period_min);
+	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
+		return;
+
+	ACCESS_ONCE(mm->numa_scan_seq)++;
+	{
+		struct vm_area_struct *vma;
+
+		down_write(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!vma_migratable(vma))
+				continue;
+			change_prot_numa(vma, vma->vm_start, vma->vm_end);
+		}
+		up_write(&mm->mmap_sem);
+	}
+}
+
+/*
+ * Drive the periodic memory faults..
+ */
+void task_tick_numa(struct rq *rq, struct task_struct *curr)
+{
+	struct callback_head *work = &curr->numa_work;
+	u64 period, now;
+
+	/*
+	 * We don't care about NUMA placement if we don't have memory.
+	 */
+	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
+		return;
+
+	/*
+	 * Using runtime rather than walltime has the dual advantage that
+	 * we (mostly) drive the selection from busy threads and that the
+	 * task needs to have done some actual work before we bother with
+	 * NUMA placement.
+	 */
+	now = curr->se.sum_exec_runtime;
+	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
+
+	if (now - curr->node_stamp > period) {
+		curr->node_stamp = now;
+
+		/*
+		 * We are comparing runtime to wall clock time here, which
+		 * puts a maximum scan frequency limit on the task work.
+		 *
+		 * This, together with the limits in task_numa_work() filters
+		 * us from over-sampling if there are many threads: if all
+		 * threads happen to come in at the same time we don't create a
+		 * spike in overhead.
+		 *
+		 * We also avoid multiple threads scanning at once in parallel to
+		 * each other.
+		 */
+		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
+			init_task_work(work, task_numa_work); /* TODO: move this into sched_fork() */
+			task_work_add(curr, work, true);
+		}
+	}
+}
+#else /* !CONFIG_NUMA_BALANCING: */
+#ifdef CONFIG_SMP
+static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)	{ }
+#endif
+static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)	{ }
+static inline void task_tick_numa(struct rq *rq, struct task_struct *curr)	{ }
+static inline void task_numa_migrate(struct task_struct *p, int next_cpu)	{ }
+#endif /* CONFIG_NUMA_BALANCING */
+
+/**************************************************
  * Scheduling class queueing methods:
  */
 
@@ -784,9 +1016,13 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
-		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
-#endif
+	if (entity_is_task(se)) {
+		struct rq *rq = rq_of(cfs_rq);
+
+		account_numa_enqueue(rq, task_of(se));
+		list_add(&se->group_node, &rq->cfs_tasks);
+	}
+#endif /* CONFIG_SMP */
 	cfs_rq->nr_running++;
 }
 
@@ -796,8 +1032,10 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
 		list_del_init(&se->group_node);
+		account_numa_dequeue(rq_of(cfs_rq), task_of(se));
+	}
 	cfs_rq->nr_running--;
 }
 
@@ -3177,20 +3415,8 @@ unlock:
 	return new_cpu;
 }
 
-/*
- * Load-tracking only depends on SMP, FAIR_GROUP_SCHED dependency below may be
- * removed when useful for applications beyond shares distribution (e.g.
- * load-balance).
- */
 #ifdef CONFIG_FAIR_GROUP_SCHED
-/*
- * Called immediately before a task is migrated to a new cpu; task_cpu(p) and
- * cfs_rq_of(p) references at time of call are still valid and identify the
- * previous cpu.  However, the caller only guarantees p->pi_lock is held; no
- * other assumptions, including the state of rq->lock, should be made.
- */
-static void
-migrate_task_rq_fair(struct task_struct *p, int next_cpu)
+static void migrate_task_rq_entity(struct task_struct *p, int next_cpu)
 {
 	struct sched_entity *se = &p->se;
 	struct cfs_rq *cfs_rq = cfs_rq_of(se);
@@ -3206,7 +3432,27 @@ migrate_task_rq_fair(struct task_struct *p, int next_cpu)
 		atomic64_add(se->avg.load_avg_contrib, &cfs_rq->removed_load);
 	}
 }
+#else
+static void migrate_task_rq_entity(struct task_struct *p, int next_cpu) { }
 #endif
+
+/*
+ * Load-tracking only depends on SMP, FAIR_GROUP_SCHED dependency below may be
+ * removed when useful for applications beyond shares distribution (e.g.
+ * load-balance).
+ */
+/*
+ * Called immediately before a task is migrated to a new cpu; task_cpu(p) and
+ * cfs_rq_of(p) references at time of call are still valid and identify the
+ * previous cpu.  However, the caller only guarantees p->pi_lock is held; no
+ * other assumptions, including the state of rq->lock, should be made.
+ */
+static void
+migrate_task_rq_fair(struct task_struct *p, int next_cpu)
+{
+	migrate_task_rq_entity(p, next_cpu);
+	task_numa_migrate(p, next_cpu);
+}
 #endif /* CONFIG_SMP */
 
 static unsigned long
@@ -3580,7 +3826,10 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
-#define LBF_SOME_PINNED 0x04
+#define LBF_SOME_PINNED	0x04
+#define LBF_NUMA_RUN	0x08
+#define LBF_NUMA_SHARED	0x10
+#define LBF_KEEP_SHARED	0x20
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3599,6 +3848,8 @@ struct lb_env {
 	struct cpumask		*cpus;
 
 	unsigned int		flags;
+	unsigned int		failed;
+	unsigned int		iteration;
 
 	unsigned int		loop;
 	unsigned int		loop_break;
@@ -3620,11 +3871,87 @@ static void move_task(struct task_struct *p, struct lb_env *env)
 	check_preempt_curr(env->dst_rq, p, 0);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+
+static inline unsigned long task_node_faults(struct task_struct *p, int node)
+{
+	return p->numa_faults[2*node] + p->numa_faults[2*node + 1];
+}
+
+static int task_faults_down(struct task_struct *p, struct lb_env *env)
+{
+	int src_node, dst_node, node, down_node = -1;
+	unsigned long faults, src_faults, max_faults = 0;
+
+	if (!sched_feat_numa(NUMA_FAULTS_DOWN) || !p->numa_faults)
+		return 1;
+
+	src_node = cpu_to_node(env->src_cpu);
+	dst_node = cpu_to_node(env->dst_cpu);
+
+	if (src_node == dst_node)
+		return 1;
+
+	src_faults = task_node_faults(p, src_node);
+
+	for (node = 0; node < nr_node_ids; node++) {
+		if (node == src_node)
+			continue;
+
+		faults = task_node_faults(p, node);
+
+		if (faults > max_faults && faults <= src_faults) {
+			max_faults = faults;
+			down_node = node;
+		}
+	}
+
+	if (down_node == dst_node)
+		return 1; /* move towards the next node down */
+
+	return 0; /* stay here */
+}
+
+static int task_faults_up(struct task_struct *p, struct lb_env *env)
+{
+	unsigned long src_faults, dst_faults;
+	int src_node, dst_node;
+
+	if (!sched_feat_numa(NUMA_FAULTS_UP) || !p->numa_faults)
+		return 0; /* can't say it improved */
+
+	src_node = cpu_to_node(env->src_cpu);
+	dst_node = cpu_to_node(env->dst_cpu);
+
+	if (src_node == dst_node)
+		return 0; /* pointless, don't do that */
+
+	src_faults = task_node_faults(p, src_node);
+	dst_faults = task_node_faults(p, dst_node);
+
+	if (dst_faults > src_faults)
+		return 1; /* move to dst */
+
+	return 0; /* stay where we are */
+}
+
+#else /* !CONFIG_NUMA_BALANCING: */
+static inline int task_faults_up(struct task_struct *p, struct lb_env *env)
+{
+	return 0;
+}
+
+static inline int task_faults_down(struct task_struct *p, struct lb_env *env)
+{
+	return 0;
+}
+#endif
+
 /*
  * Is this task likely cache-hot:
  */
 static int
-task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
+task_hot(struct task_struct *p, struct lb_env *env)
 {
 	s64 delta;
 
@@ -3647,80 +3974,153 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 	if (sysctl_sched_migration_cost == 0)
 		return 0;
 
-	delta = now - p->se.exec_start;
+	delta = env->src_rq->clock_task - p->se.exec_start;
 
 	return delta < (s64)sysctl_sched_migration_cost;
 }
 
 /*
- * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
+ * We do not migrate tasks that cannot be migrated to this CPU
+ * due to cpus_allowed.
+ *
+ * NOTE: this function has env-> side effects, to help the balancing
+ *       of pinned tasks.
  */
-static
-int can_migrate_task(struct task_struct *p, struct lb_env *env)
+static bool can_migrate_pinned_task(struct task_struct *p, struct lb_env *env)
 {
-	int tsk_cache_hot = 0;
+	int new_dst_cpu;
+
+	if (cpumask_test_cpu(env->dst_cpu, tsk_cpus_allowed(p)))
+		return true;
+
+	schedstat_inc(p, se.statistics.nr_failed_migrations_affine);
+
 	/*
-	 * We do not migrate tasks that are:
-	 * 1) running (obviously), or
-	 * 2) cannot be migrated to this CPU due to cpus_allowed, or
-	 * 3) are cache-hot on their current CPU.
+	 * Remember if this task can be migrated to any other cpu in
+	 * our sched_group. We may want to revisit it if we couldn't
+	 * meet load balance goals by pulling other tasks on src_cpu.
+	 *
+	 * Also avoid computing new_dst_cpu if we have already computed
+	 * one in current iteration.
 	 */
-	if (!cpumask_test_cpu(env->dst_cpu, tsk_cpus_allowed(p))) {
-		int new_dst_cpu;
-
-		schedstat_inc(p, se.statistics.nr_failed_migrations_affine);
+	if (!env->dst_grpmask || (env->flags & LBF_SOME_PINNED))
+		return false;
 
-		/*
-		 * Remember if this task can be migrated to any other cpu in
-		 * our sched_group. We may want to revisit it if we couldn't
-		 * meet load balance goals by pulling other tasks on src_cpu.
-		 *
-		 * Also avoid computing new_dst_cpu if we have already computed
-		 * one in current iteration.
-		 */
-		if (!env->dst_grpmask || (env->flags & LBF_SOME_PINNED))
-			return 0;
-
-		new_dst_cpu = cpumask_first_and(env->dst_grpmask,
-						tsk_cpus_allowed(p));
-		if (new_dst_cpu < nr_cpu_ids) {
-			env->flags |= LBF_SOME_PINNED;
-			env->new_dst_cpu = new_dst_cpu;
-		}
-		return 0;
+	new_dst_cpu = cpumask_first_and(env->dst_grpmask, tsk_cpus_allowed(p));
+	if (new_dst_cpu < nr_cpu_ids) {
+		env->flags |= LBF_SOME_PINNED;
+		env->new_dst_cpu = new_dst_cpu;
 	}
+	return false;
+}
 
-	/* Record that we found atleast one task that could run on dst_cpu */
-	env->flags &= ~LBF_ALL_PINNED;
+/*
+ * We cannot (easily) migrate tasks that are currently running:
+ */
+static bool can_migrate_running_task(struct task_struct *p, struct lb_env *env)
+{
+	if (!task_running(env->src_rq, p))
+		return true;
 
-	if (task_running(env->src_rq, p)) {
-		schedstat_inc(p, se.statistics.nr_failed_migrations_running);
-		return 0;
-	}
+	schedstat_inc(p, se.statistics.nr_failed_migrations_running);
+	return false;
+}
 
+/*
+ * Can we migrate a NUMA task? The rules are rather involved:
+ */
+static bool can_migrate_numa_task(struct task_struct *p, struct lb_env *env)
+{
 	/*
-	 * Aggressive migration if:
-	 * 1) task is cache cold, or
-	 * 2) too many balance attempts have failed.
+	 * iteration:
+	 *   0		   -- only allow improvement, or !numa
+	 *   1		   -- + worsen !ideal
+	 *   2                         priv
+	 *   3                         shared (everything)
+	 *
+	 * NUMA_HOT_DOWN:
+	 *   1 .. nodes    -- allow getting worse by step
+	 *   nodes+1	   -- punt, everything goes!
+	 *
+	 * LBF_NUMA_RUN    -- numa only, only allow improvement
+	 * LBF_NUMA_SHARED -- shared only
+	 *
+	 * LBF_KEEP_SHARED -- do not touch shared tasks
 	 */
 
-	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
-	if (!tsk_cache_hot ||
-		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
-#ifdef CONFIG_SCHEDSTATS
-		if (tsk_cache_hot) {
-			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
-			schedstat_inc(p, se.statistics.nr_forced_migrations);
-		}
-#endif
-		return 1;
+	/* a numa run can only move numa tasks about to improve things */
+	if (env->flags & LBF_NUMA_RUN) {
+		if (task_numa_shared(p) < 0)
+			return false;
+		/* can only pull shared tasks */
+		if ((env->flags & LBF_NUMA_SHARED) && !task_numa_shared(p))
+			return false;
+	} else {
+		if (task_numa_shared(p) < 0)
+			goto try_migrate;
 	}
 
-	if (tsk_cache_hot) {
-		schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
-		return 0;
-	}
-	return 1;
+	/* can not move shared tasks */
+	if ((env->flags & LBF_KEEP_SHARED) && task_numa_shared(p) == 1)
+		return false;
+
+	if (task_faults_up(p, env))
+		return true; /* memory locality beats cache hotness */
+
+	if (env->iteration < 1)
+		return false;
+
+#ifdef CONFIG_NUMA_BALANCING
+	if (p->numa_max_node != cpu_to_node(task_cpu(p))) /* !ideal */
+		goto demote;
+#endif
+
+	if (env->iteration < 2)
+		return false;
+
+	if (task_numa_shared(p) == 0) /* private */
+		goto demote;
+
+	if (env->iteration < 3)
+		return false;
+
+demote:
+	if (env->iteration < 5)
+		return task_faults_down(p, env);
+
+try_migrate:
+	if (env->failed > env->sd->cache_nice_tries)
+		return true;
+
+	return !task_hot(p, env);
+}
+
+/*
+ * can_migrate_task() - may task p from runqueue rq be migrated to this_cpu?
+ */
+static int can_migrate_task(struct task_struct *p, struct lb_env *env)
+{
+	if (!can_migrate_pinned_task(p, env))
+		return false;
+
+	/* Record that we found atleast one task that could run on dst_cpu */
+	env->flags &= ~LBF_ALL_PINNED;
+
+	if (!can_migrate_running_task(p, env))
+		return false;
+
+	if (env->sd->flags & SD_NUMA)
+		return can_migrate_numa_task(p, env);
+
+	if (env->failed > env->sd->cache_nice_tries)
+		return true;
+
+	if (!task_hot(p, env))
+		return true;
+
+	schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
+
+	return false;
 }
 
 /*
@@ -3735,6 +4135,7 @@ static int move_one_task(struct lb_env *env)
 	struct task_struct *p, *n;
 
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
+
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
 
@@ -3742,6 +4143,7 @@ static int move_one_task(struct lb_env *env)
 			continue;
 
 		move_task(p, env);
+
 		/*
 		 * Right now, this is only the second place move_task()
 		 * is called, so we can safely collect move_task()
@@ -3753,8 +4155,6 @@ static int move_one_task(struct lb_env *env)
 	return 0;
 }
 
-static unsigned long task_h_load(struct task_struct *p);
-
 static const unsigned int sched_nr_migrate_break = 32;
 
 /*
@@ -3766,7 +4166,6 @@ static const unsigned int sched_nr_migrate_break = 32;
  */
 static int move_tasks(struct lb_env *env)
 {
-	struct list_head *tasks = &env->src_rq->cfs_tasks;
 	struct task_struct *p;
 	unsigned long load;
 	int pulled = 0;
@@ -3774,8 +4173,8 @@ static int move_tasks(struct lb_env *env)
 	if (env->imbalance <= 0)
 		return 0;
 
-	while (!list_empty(tasks)) {
-		p = list_first_entry(tasks, struct task_struct, se.group_node);
+	while (!list_empty(&env->src_rq->cfs_tasks)) {
+		p = list_first_entry(&env->src_rq->cfs_tasks, struct task_struct, se.group_node);
 
 		env->loop++;
 		/* We've more or less seen every task there is, call it quits */
@@ -3786,7 +4185,7 @@ static int move_tasks(struct lb_env *env)
 		if (env->loop > env->loop_break) {
 			env->loop_break += sched_nr_migrate_break;
 			env->flags |= LBF_NEED_BREAK;
-			break;
+			goto out;
 		}
 
 		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
@@ -3794,7 +4193,7 @@ static int move_tasks(struct lb_env *env)
 
 		load = task_h_load(p);
 
-		if (sched_feat(LB_MIN) && load < 16 && !env->sd->nr_balance_failed)
+		if (sched_feat(LB_MIN) && load < 16 && !env->failed)
 			goto next;
 
 		if ((load / 2) > env->imbalance)
@@ -3814,7 +4213,7 @@ static int move_tasks(struct lb_env *env)
 		 * the critical section.
 		 */
 		if (env->idle == CPU_NEWLY_IDLE)
-			break;
+			goto out;
 #endif
 
 		/*
@@ -3822,13 +4221,13 @@ static int move_tasks(struct lb_env *env)
 		 * weighted load.
 		 */
 		if (env->imbalance <= 0)
-			break;
+			goto out;
 
 		continue;
 next:
-		list_move_tail(&p->se.group_node, tasks);
+		list_move_tail(&p->se.group_node, &env->src_rq->cfs_tasks);
 	}
-
+out:
 	/*
 	 * Right now, this is one of only two places move_task() is called,
 	 * so we can safely collect move_task() stats here rather than
@@ -3953,17 +4352,18 @@ static inline void update_blocked_averages(int cpu)
 static inline void update_h_load(long cpu)
 {
 }
-
+#ifdef CONFIG_SMP
 static unsigned long task_h_load(struct task_struct *p)
 {
 	return p->se.load.weight;
 }
 #endif
+#endif
 
 /********** Helpers for find_busiest_group ************************/
 /*
  * sd_lb_stats - Structure to store the statistics of a sched_domain
- * 		during load balancing.
+ *		during load balancing.
  */
 struct sd_lb_stats {
 	struct sched_group *busiest; /* Busiest group in this sd */
@@ -3976,7 +4376,7 @@ struct sd_lb_stats {
 	unsigned long this_load;
 	unsigned long this_load_per_task;
 	unsigned long this_nr_running;
-	unsigned long this_has_capacity;
+	unsigned int  this_has_capacity;
 	unsigned int  this_idle_cpus;
 
 	/* Statistics of the busiest group */
@@ -3985,10 +4385,28 @@ struct sd_lb_stats {
 	unsigned long busiest_load_per_task;
 	unsigned long busiest_nr_running;
 	unsigned long busiest_group_capacity;
-	unsigned long busiest_has_capacity;
+	unsigned int  busiest_has_capacity;
 	unsigned int  busiest_group_weight;
 
 	int group_imb; /* Is there imbalance in this sd */
+
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long this_numa_running;
+	unsigned long this_numa_weight;
+	unsigned long this_shared_running;
+	unsigned long this_ideal_running;
+	unsigned long this_group_capacity;
+
+	struct sched_group *numa;
+	unsigned long numa_load;
+	unsigned long numa_nr_running;
+	unsigned long numa_numa_running;
+	unsigned long numa_shared_running;
+	unsigned long numa_ideal_running;
+	unsigned long numa_numa_weight;
+	unsigned long numa_group_capacity;
+	unsigned int  numa_has_capacity;
+#endif
 };
 
 /*
@@ -4004,6 +4422,13 @@ struct sg_lb_stats {
 	unsigned long group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
+
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long sum_ideal_running;
+	unsigned long sum_numa_running;
+	unsigned long sum_numa_weight;
+#endif
+	unsigned long sum_shared_running;	/* 0 on non-NUMA */
 };
 
 /**
@@ -4032,6 +4457,151 @@ static inline int get_sd_load_idx(struct sched_domain *sd,
 	return load_idx;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+
+static inline bool pick_numa_rand(int n)
+{
+	return !(get_random_int() % n);
+}
+
+static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
+{
+	sgs->sum_ideal_running += rq->nr_ideal_running;
+	sgs->sum_shared_running += rq->nr_shared_running;
+	sgs->sum_numa_running += rq->nr_numa_running;
+	sgs->sum_numa_weight += rq->numa_weight;
+}
+
+static inline
+void update_sd_numa_stats(struct sched_domain *sd, struct sched_group *sg,
+			  struct sd_lb_stats *sds, struct sg_lb_stats *sgs,
+			  int local_group)
+{
+	if (!(sd->flags & SD_NUMA))
+		return;
+
+	if (local_group) {
+		sds->this_numa_running   = sgs->sum_numa_running;
+		sds->this_numa_weight    = sgs->sum_numa_weight;
+		sds->this_shared_running = sgs->sum_shared_running;
+		sds->this_ideal_running  = sgs->sum_ideal_running;
+		sds->this_group_capacity = sgs->group_capacity;
+
+	} else if (sgs->sum_numa_running - sgs->sum_ideal_running) {
+		if (!sds->numa || pick_numa_rand(sd->span_weight / sg->group_weight)) {
+			sds->numa = sg;
+			sds->numa_load		 = sgs->avg_load;
+			sds->numa_nr_running     = sgs->sum_nr_running;
+			sds->numa_numa_running   = sgs->sum_numa_running;
+			sds->numa_shared_running = sgs->sum_shared_running;
+			sds->numa_ideal_running  = sgs->sum_ideal_running;
+			sds->numa_numa_weight    = sgs->sum_numa_weight;
+			sds->numa_has_capacity	 = sgs->group_has_capacity;
+			sds->numa_group_capacity = sgs->group_capacity;
+		}
+	}
+}
+
+static struct rq *
+find_busiest_numa_queue(struct lb_env *env, struct sched_group *sg)
+{
+	struct rq *rq, *busiest = NULL;
+	int cpu;
+
+	for_each_cpu_and(cpu, sched_group_cpus(sg), env->cpus) {
+		rq = cpu_rq(cpu);
+
+		if (!rq->nr_numa_running)
+			continue;
+
+		if (!(rq->nr_numa_running - rq->nr_ideal_running))
+			continue;
+
+		if ((env->flags & LBF_KEEP_SHARED) && !(rq->nr_running - rq->nr_shared_running))
+			continue;
+
+		if (!busiest || pick_numa_rand(sg->group_weight))
+			busiest = rq;
+	}
+
+	return busiest;
+}
+
+static bool can_do_numa_run(struct lb_env *env, struct sd_lb_stats *sds)
+{
+	/*
+	 * if we're overloaded; don't pull when:
+	 *   - the other guy isn't
+	 *   - imbalance would become too great
+	 */
+	if (!sds->this_has_capacity) {
+		if (sds->numa_has_capacity)
+			return false;
+	}
+
+	/*
+	 * pull if we got easy trade
+	 */
+	if (sds->this_nr_running - sds->this_numa_running)
+		return true;
+
+	/*
+	 * If we got capacity allow stacking up on shared tasks.
+	 */
+	if ((sds->this_shared_running < sds->this_group_capacity) && sds->numa_shared_running) {
+		env->flags |= LBF_NUMA_SHARED;
+		return true;
+	}
+
+	/*
+	 * pull if we could possibly trade
+	 */
+	if (sds->this_numa_running - sds->this_ideal_running)
+		return true;
+
+	return false;
+}
+
+/*
+ * introduce some controlled imbalance to perturb the state so we allow the
+ * state to improve should be tightly controlled/co-ordinated with
+ * can_migrate_task()
+ */
+static int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
+{
+	if (!sds->numa || !sds->numa_numa_running)
+		return 0;
+
+	if (!can_do_numa_run(env, sds))
+		return 0;
+
+	env->flags |= LBF_NUMA_RUN;
+	env->flags &= ~LBF_KEEP_SHARED;
+	env->imbalance = sds->numa_numa_weight / sds->numa_numa_running;
+	sds->busiest = sds->numa;
+	env->find_busiest_queue = find_busiest_numa_queue;
+
+	return 1;
+}
+
+#else /* !CONFIG_NUMA_BALANCING: */
+static inline
+void update_sd_numa_stats(struct sched_domain *sd, struct sched_group *sg,
+			  struct sd_lb_stats *sds, struct sg_lb_stats *sgs,
+			  int local_group)
+{
+}
+
+static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
+{
+}
+
+static inline int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
+{
+	return 0;
+}
+#endif
+
 unsigned long default_scale_freq_power(struct sched_domain *sd, int cpu)
 {
 	return SCHED_POWER_SCALE;
@@ -4245,6 +4815,9 @@ static inline void update_sg_lb_stats(struct lb_env *env,
 		sgs->group_load += load;
 		sgs->sum_nr_running += nr_running;
 		sgs->sum_weighted_load += weighted_cpuload(i);
+
+		update_sg_numa_stats(sgs, rq);
+
 		if (idle_cpu(i))
 			sgs->idle_cpus++;
 	}
@@ -4336,6 +4909,13 @@ static bool update_sd_pick_busiest(struct lb_env *env,
 	return false;
 }
 
+static void update_src_keep_shared(struct lb_env *env, bool keep_shared)
+{
+	env->flags &= ~LBF_KEEP_SHARED;
+	if (keep_shared)
+		env->flags |= LBF_KEEP_SHARED;
+}
+
 /**
  * update_sd_lb_stats - Update sched_domain's statistics for load balancing.
  * @env: The load balancing environment.
@@ -4368,6 +4948,7 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 		sds->total_load += sgs.group_load;
 		sds->total_pwr += sg->sgp->power;
 
+#ifdef CONFIG_NUMA_BALANCING
 		/*
 		 * In case the child domain prefers tasks go to siblings
 		 * first, lower the sg capacity to one so that we'll try
@@ -4378,8 +4959,11 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 		 * heaviest group when it is already under-utilized (possible
 		 * with a large weight task outweighs the tasks on the system).
 		 */
-		if (prefer_sibling && !local_group && sds->this_has_capacity)
-			sgs.group_capacity = min(sgs.group_capacity, 1UL);
+		if (0 && prefer_sibling && !local_group && sds->this_has_capacity) {
+			sgs.group_capacity = clamp_val(sgs.sum_shared_running,
+					1UL, sgs.group_capacity);
+		}
+#endif
 
 		if (local_group) {
 			sds->this_load = sgs.avg_load;
@@ -4398,8 +4982,13 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 			sds->busiest_has_capacity = sgs.group_has_capacity;
 			sds->busiest_group_weight = sgs.group_weight;
 			sds->group_imb = sgs.group_imb;
+
+			update_src_keep_shared(env,
+				sgs.sum_shared_running <= sgs.group_capacity);
 		}
 
+		update_sd_numa_stats(env->sd, sg, sds, &sgs, local_group);
+
 		sg = sg->next;
 	} while (sg != env->sd->groups);
 }
@@ -4652,14 +5241,14 @@ find_busiest_group(struct lb_env *env, int *balance)
 	 * don't try and pull any tasks.
 	 */
 	if (sds.this_load >= sds.max_load)
-		goto out_balanced;
+		goto out_imbalanced;
 
 	/*
 	 * Don't pull any tasks if this group is already above the domain
 	 * average load.
 	 */
 	if (sds.this_load >= sds.avg_load)
-		goto out_balanced;
+		goto out_imbalanced;
 
 	if (env->idle == CPU_IDLE) {
 		/*
@@ -4685,9 +5274,18 @@ force_balance:
 	calculate_imbalance(env, &sds);
 	return sds.busiest;
 
+out_imbalanced:
+	/* if we've got capacity allow for secondary placement preference */
+	if (!sds.this_has_capacity)
+		goto ret;
+
 out_balanced:
+	if (check_numa_busiest_group(env, &sds))
+		return sds.busiest;
+
 ret:
 	env->imbalance = 0;
+
 	return NULL;
 }
 
@@ -4723,6 +5321,9 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 		if (capacity && rq->nr_running == 1 && wl > env->imbalance)
 			continue;
 
+		if ((env->flags & LBF_KEEP_SHARED) && !(rq->nr_running - rq->nr_shared_running))
+			continue;
+
 		/*
 		 * For the load comparisons with the other cpu's, consider
 		 * the weighted_cpuload() scaled with the cpu power, so that
@@ -4749,25 +5350,40 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 /* Working cpumask for load_balance and load_balance_newidle. */
 DEFINE_PER_CPU(cpumask_var_t, load_balance_tmpmask);
 
-static int need_active_balance(struct lb_env *env)
-{
-	struct sched_domain *sd = env->sd;
-
-	if (env->idle == CPU_NEWLY_IDLE) {
+static int active_load_balance_cpu_stop(void *data);
 
+static void update_sd_failed(struct lb_env *env, int ld_moved)
+{
+	if (!ld_moved) {
+		schedstat_inc(env->sd, lb_failed[env->idle]);
 		/*
-		 * ASYM_PACKING needs to force migrate tasks from busy but
-		 * higher numbered CPUs in order to pack all tasks in the
-		 * lowest numbered CPUs.
+		 * Increment the failure counter only on periodic balance.
+		 * We do not want newidle balance, which can be very
+		 * frequent, pollute the failure counter causing
+		 * excessive cache_hot migrations and active balances.
 		 */
-		if ((sd->flags & SD_ASYM_PACKING) && env->src_cpu > env->dst_cpu)
-			return 1;
-	}
-
-	return unlikely(sd->nr_balance_failed > sd->cache_nice_tries+2);
+		if (env->idle != CPU_NEWLY_IDLE && !(env->flags & LBF_NUMA_RUN))
+			env->sd->nr_balance_failed++;
+	} else
+		env->sd->nr_balance_failed = 0;
 }
 
-static int active_load_balance_cpu_stop(void *data);
+/*
+ * See can_migrate_numa_task()
+ */
+static int lb_max_iteration(struct lb_env *env)
+{
+	if (!(env->sd->flags & SD_NUMA))
+		return 0;
+
+	if (env->flags & LBF_NUMA_RUN)
+		return 0; /* NUMA_RUN may only improve */
+
+	if (sched_feat_numa(NUMA_FAULTS_DOWN))
+		return 5; /* nodes^2 would suck */
+
+	return 3;
+}
 
 /*
  * Check this_cpu to ensure it is balanced within domain. Attempt to move
@@ -4793,6 +5409,8 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		.loop_break	    = sched_nr_migrate_break,
 		.cpus		    = cpus,
 		.find_busiest_queue = find_busiest_queue,
+		.failed             = sd->nr_balance_failed,
+		.iteration          = 0,
 	};
 
 	cpumask_copy(cpus, cpu_active_mask);
@@ -4816,6 +5434,8 @@ redo:
 		schedstat_inc(sd, lb_nobusyq[idle]);
 		goto out_balanced;
 	}
+	env.src_rq  = busiest;
+	env.src_cpu = busiest->cpu;
 
 	BUG_ON(busiest == env.dst_rq);
 
@@ -4895,92 +5515,72 @@ more_balance:
 		}
 
 		/* All tasks on this runqueue were pinned by CPU affinity */
-		if (unlikely(env.flags & LBF_ALL_PINNED)) {
-			cpumask_clear_cpu(cpu_of(busiest), cpus);
-			if (!cpumask_empty(cpus)) {
-				env.loop = 0;
-				env.loop_break = sched_nr_migrate_break;
-				goto redo;
-			}
-			goto out_balanced;
+		if (unlikely(env.flags & LBF_ALL_PINNED))
+			goto out_pinned;
+
+		if (!ld_moved && env.iteration < lb_max_iteration(&env)) {
+			env.iteration++;
+			env.loop = 0;
+			goto more_balance;
 		}
 	}
 
-	if (!ld_moved) {
-		schedstat_inc(sd, lb_failed[idle]);
+	if (!ld_moved && idle != CPU_NEWLY_IDLE) {
+		raw_spin_lock_irqsave(&busiest->lock, flags);
+
 		/*
-		 * Increment the failure counter only on periodic balance.
-		 * We do not want newidle balance, which can be very
-		 * frequent, pollute the failure counter causing
-		 * excessive cache_hot migrations and active balances.
+		 * Don't kick the active_load_balance_cpu_stop,
+		 * if the curr task on busiest cpu can't be
+		 * moved to this_cpu
 		 */
-		if (idle != CPU_NEWLY_IDLE)
-			sd->nr_balance_failed++;
-
-		if (need_active_balance(&env)) {
-			raw_spin_lock_irqsave(&busiest->lock, flags);
-
-			/* don't kick the active_load_balance_cpu_stop,
-			 * if the curr task on busiest cpu can't be
-			 * moved to this_cpu
-			 */
-			if (!cpumask_test_cpu(this_cpu,
-					tsk_cpus_allowed(busiest->curr))) {
-				raw_spin_unlock_irqrestore(&busiest->lock,
-							    flags);
-				env.flags |= LBF_ALL_PINNED;
-				goto out_one_pinned;
-			}
-
-			/*
-			 * ->active_balance synchronizes accesses to
-			 * ->active_balance_work.  Once set, it's cleared
-			 * only after active load balance is finished.
-			 */
-			if (!busiest->active_balance) {
-				busiest->active_balance = 1;
-				busiest->push_cpu = this_cpu;
-				active_balance = 1;
-			}
+		if (!cpumask_test_cpu(this_cpu, tsk_cpus_allowed(busiest->curr))) {
 			raw_spin_unlock_irqrestore(&busiest->lock, flags);
-
-			if (active_balance) {
-				stop_one_cpu_nowait(cpu_of(busiest),
-					active_load_balance_cpu_stop, busiest,
-					&busiest->active_balance_work);
-			}
-
-			/*
-			 * We've kicked active balancing, reset the failure
-			 * counter.
-			 */
-			sd->nr_balance_failed = sd->cache_nice_tries+1;
+			env.flags |= LBF_ALL_PINNED;
+			goto out_pinned;
 		}
-	} else
-		sd->nr_balance_failed = 0;
 
-	if (likely(!active_balance)) {
-		/* We were unbalanced, so reset the balancing interval */
-		sd->balance_interval = sd->min_interval;
-	} else {
 		/*
-		 * If we've begun active balancing, start to back off. This
-		 * case may not be covered by the all_pinned logic if there
-		 * is only 1 task on the busy runqueue (because we don't call
-		 * move_tasks).
+		 * ->active_balance synchronizes accesses to
+		 * ->active_balance_work.  Once set, it's cleared
+		 * only after active load balance is finished.
 		 */
-		if (sd->balance_interval < sd->max_interval)
-			sd->balance_interval *= 2;
+		if (!busiest->active_balance) {
+			busiest->active_balance	= 1;
+			busiest->ab_dst_cpu	= this_cpu;
+			busiest->ab_flags	= env.flags;
+			busiest->ab_failed	= env.failed;
+			busiest->ab_idle	= env.idle;
+			active_balance		= 1;
+		}
+		raw_spin_unlock_irqrestore(&busiest->lock, flags);
+
+		if (active_balance) {
+			stop_one_cpu_nowait(cpu_of(busiest),
+					active_load_balance_cpu_stop, busiest,
+					&busiest->ab_work);
+		}
 	}
 
-	goto out;
+	if (!active_balance)
+		update_sd_failed(&env, ld_moved);
+
+	sd->balance_interval = sd->min_interval;
+out:
+	return ld_moved;
+
+out_pinned:
+	cpumask_clear_cpu(cpu_of(busiest), cpus);
+	if (!cpumask_empty(cpus)) {
+		env.loop = 0;
+		env.loop_break = sched_nr_migrate_break;
+		goto redo;
+	}
 
 out_balanced:
 	schedstat_inc(sd, lb_balanced[idle]);
 
 	sd->nr_balance_failed = 0;
 
-out_one_pinned:
 	/* tune up the balancing interval */
 	if (((env.flags & LBF_ALL_PINNED) &&
 			sd->balance_interval < MAX_PINNED_INTERVAL) ||
@@ -4988,8 +5588,8 @@ out_one_pinned:
 		sd->balance_interval *= 2;
 
 	ld_moved = 0;
-out:
-	return ld_moved;
+
+	goto out;
 }
 
 /*
@@ -5060,7 +5660,7 @@ static int active_load_balance_cpu_stop(void *data)
 {
 	struct rq *busiest_rq = data;
 	int busiest_cpu = cpu_of(busiest_rq);
-	int target_cpu = busiest_rq->push_cpu;
+	int target_cpu = busiest_rq->ab_dst_cpu;
 	struct rq *target_rq = cpu_rq(target_cpu);
 	struct sched_domain *sd;
 
@@ -5098,17 +5698,23 @@ static int active_load_balance_cpu_stop(void *data)
 			.sd		= sd,
 			.dst_cpu	= target_cpu,
 			.dst_rq		= target_rq,
-			.src_cpu	= busiest_rq->cpu,
+			.src_cpu	= busiest_cpu,
 			.src_rq		= busiest_rq,
-			.idle		= CPU_IDLE,
+			.flags		= busiest_rq->ab_flags,
+			.failed		= busiest_rq->ab_failed,
+			.idle		= busiest_rq->ab_idle,
 		};
+		env.iteration = lb_max_iteration(&env);
 
 		schedstat_inc(sd, alb_count);
 
-		if (move_one_task(&env))
+		if (move_one_task(&env)) {
 			schedstat_inc(sd, alb_pushed);
-		else
+			update_sd_failed(&env, 1);
+		} else {
 			schedstat_inc(sd, alb_failed);
+			update_sd_failed(&env, 0);
+		}
 	}
 	rcu_read_unlock();
 	double_unlock_balance(busiest_rq, target_rq);
@@ -5508,6 +6114,9 @@ static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
 	}
 
 	update_rq_runnable_avg(rq, 1);
+
+	if (sched_feat_numa(NUMA) && nr_node_ids > 1)
+		task_tick_numa(rq, curr);
 }
 
 /*
@@ -5902,9 +6511,7 @@ const struct sched_class fair_sched_class = {
 
 #ifdef CONFIG_SMP
 	.select_task_rq		= select_task_rq_fair,
-#ifdef CONFIG_FAIR_GROUP_SCHED
 	.migrate_task_rq	= migrate_task_rq_fair,
-#endif
 	.rq_online		= rq_online_fair,
 	.rq_offline		= rq_offline_fair,
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index e68e69a..a432eb8 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -66,3 +66,11 @@ SCHED_FEAT(TTWU_QUEUE, true)
 SCHED_FEAT(FORCE_SD_OVERLAP, false)
 SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
+
+#ifdef CONFIG_NUMA_BALANCING
+/* Do the working set probing faults: */
+SCHED_FEAT(NUMA,             true)
+SCHED_FEAT(NUMA_FAULTS_UP,   true)
+SCHED_FEAT(NUMA_FAULTS_DOWN, false)
+SCHED_FEAT(NUMA_SETTLE,      true)
+#endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 5eca173..bb9475c 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -3,6 +3,7 @@
 #include <linux/mutex.h>
 #include <linux/spinlock.h>
 #include <linux/stop_machine.h>
+#include <linux/slab.h>
 
 #include "cpupri.h"
 
@@ -420,17 +421,29 @@ struct rq {
 	unsigned long cpu_power;
 
 	unsigned char idle_balance;
-	/* For active balancing */
 	int post_schedule;
+
+	/* For active balancing */
 	int active_balance;
-	int push_cpu;
-	struct cpu_stop_work active_balance_work;
+	int ab_dst_cpu;
+	int ab_flags;
+	int ab_failed;
+	int ab_idle;
+	struct cpu_stop_work ab_work;
+
 	/* cpu of this runqueue: */
 	int cpu;
 	int online;
 
 	struct list_head cfs_tasks;
 
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long numa_weight;
+	unsigned long nr_numa_running;
+	unsigned long nr_ideal_running;
+#endif
+	unsigned long nr_shared_running;	/* 0 on non-NUMA */
+
 	u64 rt_avg;
 	u64 age_stamp;
 	u64 idle_stamp;
@@ -501,6 +514,18 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
+#ifdef CONFIG_NUMA_BALANCING
+extern void sched_setnuma(struct task_struct *p, int node, int shared);
+static inline void task_numa_free(struct task_struct *p)
+{
+	kfree(p->numa_faults);
+}
+#else /* CONFIG_NUMA_BALANCING */
+static inline void task_numa_free(struct task_struct *p)
+{
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_SMP
 
 #define rcu_dereference_check_sched_domain(p) \
@@ -544,6 +569,7 @@ static inline struct sched_domain *highest_flag_domain(int cpu, int flag)
 
 DECLARE_PER_CPU(struct sched_domain *, sd_llc);
 DECLARE_PER_CPU(int, sd_llc_id);
+DECLARE_PER_CPU(struct sched_domain *, sd_node);
 
 extern int group_balance_cpu(struct sched_group *sg);
 
@@ -663,6 +689,12 @@ extern struct static_key sched_feat_keys[__SCHED_FEAT_NR];
 #define sched_feat(x) (sysctl_sched_features & (1UL << __SCHED_FEAT_##x))
 #endif /* SCHED_DEBUG && HAVE_JUMP_LABEL */
 
+#ifdef CONFIG_NUMA_BALANCING
+#define sched_feat_numa(x) sched_feat(x)
+#else
+#define sched_feat_numa(x) (0)
+#endif
+
 static inline u64 global_rt_period(void)
 {
 	return (u64)sysctl_sched_rt_period * NSEC_PER_USEC;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
