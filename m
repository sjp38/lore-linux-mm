Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 4EA436B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 14:02:37 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 14:02:36 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id ED3BDC90041
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 14:02:31 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r64I2Wx8253028
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 14:02:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r64I2VhZ006532
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 14:02:32 -0400
Date: Thu, 4 Jul 2013 23:32:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC WIP] Process weights based scheduling for better
 consolidation
Message-ID: <20130704180227.GA31348@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Here is an approach to look at numa balanced scheduling from a non numa fault
angle. This approach uses process weights instead of faults as a basis to
move or bring tasks together.

Here are the advantages of this approach.
1. Provides excellent consolidation of tasks.
	- I have verified with  sched_autonuma_dump_mm() which was part
	  of Andrea's autonuma patches refer commit id: 

	commit aba373d04251691b5e0987a0fff2fa7007311810
	Author: Andrea Arcangeli <aarcange@redhat.com>
	Date:   Fri Mar 23 20:35:07 2012 +0100

	    autonuma: CPU follows memory algorithm
 
 From limited experiments, I have found that the better the task
 consolidation, we achieve better the memory layout, which results in
 better the performance.

2. Provides good benefit in whatever limited testing that I have done so
  far. For example it provides _20+%_ improvement for numa01
  (autonuma-benchmark). 

3. Since it doesnt depend on numa faulting, it doesnt have the overhead
  of having to get the scanning rate correctly.

4. Looks to extend the load balancer esp when the cpus are idling.

5. Code looks much simpler and naive to me. (But yes this is relative!!!)

Results on a 2 node 12 core system:

KernelVersion: 3.9.0 (with hyper threading)
		Testcase:      Min      Max      Avg
		  numa01:   220.12   246.96   239.18
		  numa02:    41.85    43.02    42.43

KernelVersion: 3.9.0 + code (with hyper threading)
		Testcase:      Min      Max      Avg  %Change
		  numa01:   174.97   219.38   198.99   20.20%
		  numa02:    38.24    38.50    38.38   10.55%

KernelVersion: 3.9.0 (noht)
		Testcase:      Min      Max      Avg
		  numa01:   118.72   121.04   120.23
		  numa02:    36.64    37.56    36.99

KernelVersion: 3.9.0 + code (noht)
		Testcase:      Min      Max      Avg  %Change
		  numa01:    92.95   113.36   108.21   11.11%
		  numa02:    36.76    38.91    37.34   -0.94%


/usr/bin/time -f %e %S %U %c %w 
i.e elapsed,user,sys, voluntary  and involuntary context switches
Best case performance for v3.9

numa01 		220.12 17.14 5041.27 522147 1273
numa02		 41.91 2.47 887.46 92079 8

Best case performance for v3.9 + code.
numa01			 174.97 17.46 4102.64 433804 1846
numa01_THREAD_ALLOC	 288.04 15.76 6783.86 718220 174
numa02			 38.41 0.75 905.65 95364 5
numa02_SMT		 46.43 0.55 487.30 66416 7

Best case memory layout for v3.9
9	416.44		5728.73	
19	356.42		5788.75	
30	722.49		5422.68	
40	1936.50		4208.67	
50	1372.40		4772.77	
60	1354.39		4790.78	
71	1512.39		4632.78	
81	1598.40		4546.77	
91	2242.40		3902.77	
101	2242.40		3902.78	
111	2654.41		3490.77	
122	2654.40		3490.77	
132	2976.30		3168.87	
142	2956.30		3188.87	
152	2956.30		3188.87	
162	2956.30		3188.87	
173	3044.30		3100.87	
183	3058.30		3086.87	
193	3204.20		2942.87	
203	3262.20		2884.89	
213	3262.18		2884.91	

Best case memory layout for v3.9 + code
10	6140.55		4.64	
20	3728.99		2416.18	
30	3066.45		3078.73	
40	3072.46		3072.73	
51	3072.46		3072.73	
61	3072.46		3072.73	
71	3072.46		3072.73	
81	3072.46		3072.73	
91	3072.46		3072.73	
102	3072.46		3072.73	
112	3072.46		3072.73	
122	3072.46		3072.73	
132	3072.46		3072.73	
142	3072.46		3072.73	
152	3072.46		3072.73	
163	3072.46		3072.73	
173	3072.44		3072.74	


Having said that I am sure the experts would have already thought of
this approach and might have reasons to discard it. Hence the code is
not yet in a patchset format, nor do I have extensive analysis that Mel
has for his patchset. I thought of posting the code out in some form so
that I know if there are any obvious pitfalls for which this approach

Here is the outline of the approach.

- Every process has a per node array where we store the weight of all
  its tasks running on that node. This arrays gets updated on task
  enqueue/dequeue.

- Added a 2 pass mechanism (somewhat taken from numacore but not
  exactly) while choosing tasks to move across nodes. 

  In the first pass, choose only tasks that are ideal to be moved.
  While choosing a task, look at the per node process arrays to see if
  moving task helps.
  If the first pass fails to move a task, any task can be chosen on the
  second pass.
 
- If the regular load balancer (rebalance_domain()) fails to balance the
  load (or finds no imbalance) and there is a cpu, use the cpu to
  consolidate tasks to the nodes by using the information in the per
  node process arrays.

  Every idle cpu if its doesnt have tasks queued after load balance,
  - will walk thro the cpus in its node and checks if there are buddy
    tasks that are not part of the node but should have been ideally
    part of this node. 
  - To make sure that we dont pull all buddy tasks and create an
    imbalance, we look at load on the load, pinned tasks and the
    processes contribution to the load for this node.
  - Each cpu looks at the node which has the least number of buddy tasks
    running and tries to pull the tasks from such nodes.

  - Once it finds the cpu from which to pull the tasks, it triggers
    active_balancing. This type of active balancing triggers just one
    pass. i.e it only fetches tasks that increase numa locality.

Thanks for taking a look and providing your valuable inputs.

---8<---

sched: Using process weights to consolidate tasks

If we consolidate related tasks to one node, memory tends to follow to
that node. If the memory and tasks end up in one node, it results in
better performance. 

To achieve this, the code below tries to extend the current load
balancing while idling to move tasks in such a way that the related
tasks end up being based on the same node. Care is taken not to overload
the tasks while moving the tasks. 

This code also adds iterations logic to the regular move task logic to
further consolidate tasks while performing the regular load balancing.

Not-yet-signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 fs/exec.c                |    4 +
 include/linux/migrate.h  |    1 -
 include/linux/mm_types.h |    1 +
 include/linux/sched.h    |    2 +
 kernel/fork.c            |   10 +-
 kernel/sched/core.c      |    2 +
 kernel/sched/fair.c      |  338 ++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/sched.h     |    4 +
 8 files changed, 344 insertions(+), 18 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index a96a488..54589d0 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -833,6 +833,10 @@ static int exec_mmap(struct mm_struct *mm)
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
+#ifdef CONFIG_NUMA_BALANCING
+	mm->numa_weights = kzalloc(sizeof(unsigned long) * (nr_node_ids + 1), GFP_KERNEL);
+	tsk->task_load = 0;
+#endif
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a405d3d..086bd33 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -93,7 +93,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 #ifdef CONFIG_NUMA_BALANCING
 extern int migrate_misplaced_page(struct page *page, int node);
-extern int migrate_misplaced_page(struct page *page, int node);
 extern bool migrate_ratelimited(int node);
 #else
 static inline int migrate_misplaced_page(struct page *page, int node)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..bb402d3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -435,6 +435,7 @@ struct mm_struct {
 	 * a different node than Make PTE Scan Go Now.
 	 */
 	int first_nid;
+	unsigned long *numa_weights;
 #endif
 	struct uprobes_state uprobes_state;
 };
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..2736ec6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -815,6 +815,7 @@ enum cpu_idle_type {
 #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
 #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
 #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
+#define SD_NUMA			0x4000	/* cross-node balancing */
 
 extern int __weak arch_sd_sibiling_asym_packing(void);
 
@@ -1505,6 +1506,7 @@ struct task_struct {
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
+	unsigned long task_load;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/fork.c b/kernel/fork.c
index 1766d32..14c7aea 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -617,6 +617,9 @@ void mmput(struct mm_struct *mm)
 		khugepaged_exit(mm); /* must run before exit_mmap */
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
+#ifdef CONFIG_NUMA_BALANCING
+		kfree(mm->numa_weights);
+#endif
 		if (!list_empty(&mm->mmlist)) {
 			spin_lock(&mmlist_lock);
 			list_del(&mm->mmlist);
@@ -823,9 +826,6 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
-#ifdef CONFIG_NUMA_BALANCING
-	mm->first_nid = NUMA_PTE_SCAN_INIT;
-#endif
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
@@ -844,6 +844,10 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (mm->binfmt && !try_module_get(mm->binfmt->module))
 		goto free_pt;
 
+#ifdef CONFIG_NUMA_BALANCING
+	mm->first_nid = NUMA_PTE_SCAN_INIT;
+	mm->numa_weights = kzalloc(sizeof(unsigned long) * (nr_node_ids + 1), GFP_KERNEL);
+#endif
 	return mm;
 
 free_pt:
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 67d0465..82f8f79 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1593,6 +1593,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
+	p->task_load = 0;
 	p->numa_work.next = &p->numa_work;
 #endif /* CONFIG_NUMA_BALANCING */
 }
@@ -6136,6 +6137,7 @@ sd_numa_init(struct sched_domain_topology_level *tl, int cpu)
 					| 0*SD_SHARE_PKG_RESOURCES
 					| 1*SD_SERIALIZE
 					| 0*SD_PREFER_SIBLING
+					| 1*SD_NUMA
 					| sd_local_flags(level)
 					,
 		.last_balance		= jiffies,
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7a33e59..15d71a1 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -777,6 +777,8 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * Scheduling class queueing methods:
  */
 
+static unsigned long task_h_load(struct task_struct *p);
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * numa task sample period in ms
@@ -791,6 +793,60 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
+static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+	struct rq *rq = rq_of(cfs_rq);
+	unsigned long task_load = 0;
+	int curnode = cpu_to_node(cpu_of(rq));
+#ifdef CONFIG_SCHED_AUTOGROUP
+	struct sched_entity *se;
+
+	se = cfs_rq->tg->se[cpu_of(rq)];
+	if (!se)
+		return;
+
+	if (cfs_rq->load.weight) {
+		task_load =  p->se.load.weight * se->load.weight;
+		task_load /= cfs_rq->load.weight;
+	} else {
+		task_load = 0;
+	}
+#else
+	task_load = p->se.load.weight;
+#endif
+	p->task_load = 0;
+	if (!task_load)
+		return;
+
+	if (p->mm && p->mm->numa_weights) {
+		p->mm->numa_weights[curnode] += task_load;
+		p->mm->numa_weights[nr_node_ids] += task_load;
+	}
+
+	if (p->nr_cpus_allowed != num_online_cpus())
+		rq->pinned_load += task_load;
+	p->task_load = task_load;
+}
+
+static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+	struct rq *rq = rq_of(cfs_rq);
+	unsigned long task_load = p->task_load;
+	int curnode = cpu_to_node(cpu_of(rq));
+
+	p->task_load = 0;
+	if (!task_load)
+		return;
+
+	if (p->mm && p->mm->numa_weights) {
+		p->mm->numa_weights[curnode] -= task_load;
+		p->mm->numa_weights[nr_node_ids] -= task_load;
+	}
+
+	if (p->nr_cpus_allowed != num_online_cpus())
+		rq->pinned_load -= task_load;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq;
@@ -999,6 +1055,12 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 {
 }
+static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+}
+static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 static void
@@ -1008,8 +1070,11 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
-		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
+	if (entity_is_task(se)) {
+		struct rq *rq = rq_of(cfs_rq);
+
+		list_add(&se->group_node, &rq->cfs_tasks);
+	}
 #endif
 	cfs_rq->nr_running++;
 }
@@ -1713,6 +1778,8 @@ enqueue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 	if (se != cfs_rq->curr)
 		__enqueue_entity(cfs_rq, se);
 	se->on_rq = 1;
+	if (entity_is_task(se))
+		account_numa_enqueue(cfs_rq, task_of(se));
 
 	if (cfs_rq->nr_running == 1) {
 		list_add_leaf_cfs_rq(cfs_rq);
@@ -1810,6 +1877,8 @@ dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 
 	update_min_vruntime(cfs_rq);
 	update_cfs_shares(cfs_rq);
+	if (entity_is_task(se))
+		account_numa_dequeue(cfs_rq, task_of(se));
 }
 
 /*
@@ -3292,6 +3361,33 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	return target;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static int
+check_numa_affinity(struct task_struct *p, int cpu, int prev_cpu)
+{
+	struct mm_struct *mm = p->mm;
+	struct rq *rq = cpu_rq(prev_cpu);
+	int source_node = cpu_to_node(prev_cpu);
+	int target_node = cpu_to_node(cpu);
+
+	if (mm && mm->numa_weights) {
+		unsigned long *weights = mm->numa_weights;
+
+		if (weights[target_node] > weights[source_node]) {
+			if (!rq->ab_node_load || weights[target_node] < rq->ab_node_load)
+				return 1;
+		}
+	}
+	return 0;
+}
+#else
+static int
+check_numa_affinity(struct task_struct *p, int cpu, int prev_cpu)
+{
+	return 0;
+}
+#endif
+
 /*
  * sched_balance_self: balance the current task (running on cpu) in domains
  * that have the 'flag' flag set. In practice, this is SD_BALANCE_FORK and
@@ -3317,7 +3413,7 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 	if (sd_flag & SD_BALANCE_WAKE) {
-		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) && check_numa_affinity(p, cpu, prev_cpu))
 			want_affine = 1;
 		new_cpu = prev_cpu;
 	}
@@ -3819,6 +3915,7 @@ struct lb_env {
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
+	unsigned int		iterations;
 };
 
 /*
@@ -3865,6 +3962,37 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 	return delta < (s64)sysctl_sched_migration_cost;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static bool force_migrate(struct lb_env *env, struct task_struct *p)
+{
+	struct mm_struct *mm = p->mm;
+	struct rq *rq = env->src_rq;
+	int source_node = cpu_to_node(env->src_cpu);
+	int target_node = cpu_to_node(env->dst_cpu);
+
+	if (env->sd->nr_balance_failed > env->sd->cache_nice_tries)
+		return true;
+
+	if (!(env->sd->flags & SD_NUMA))
+		return false;
+
+	if (mm && mm->numa_weights) {
+		unsigned long *weights = mm->numa_weights;
+
+		if (weights[target_node] > weights[source_node]) {
+			if (!rq->ab_node_load || weights[target_node] < rq->ab_node_load)
+				return true;
+		}
+	}
+	return false;
+}
+#else
+static bool force_migrate(struct lb_env *env, struct task_struct *p)
+{
+	return false;
+}
+#endif
+
 /*
  * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
  */
@@ -3916,26 +4044,51 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	 * 1) task is cache cold, or
 	 * 2) too many balance attempts have failed.
 	 */
-
 	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
-	if (!tsk_cache_hot ||
-		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
+	if (tsk_cache_hot) {
+		if (force_migrate(env, p)) {
 #ifdef CONFIG_SCHEDSTATS
-		if (tsk_cache_hot) {
 			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
 			schedstat_inc(p, se.statistics.nr_forced_migrations);
-		}
 #endif
-		return 1;
-	}
-
-	if (tsk_cache_hot) {
+			return 1;
+		}
 		schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
 		return 0;
 	}
 	return 1;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static int preferred_node(struct task_struct *p, struct lb_env *env)
+{
+	struct mm_struct *mm = p->mm;
+
+	if (!(env->sd->flags & SD_NUMA))
+		return false;
+
+	if (mm && mm->numa_weights) {
+		struct rq *rq = env->src_rq;
+		unsigned long *weights = mm->numa_weights;
+		int target_node = cpu_to_node(env->dst_cpu);
+		int source_node = cpu_to_node(env->src_cpu);
+
+		if (weights[target_node] > weights[source_node]) {
+			if (!rq->ab_node_load || weights[target_node] < rq->ab_node_load)
+				return 1;
+		}
+	}
+	if (env->iterations)
+		return 1;
+	return 0;
+}
+#else
+static int preferred_node(struct task_struct *p, struct lb_env *env)
+{
+	return 0;
+}
+#endif
+
 /*
  * move_one_task tries to move exactly one task from busiest to this_rq, as
  * part of active balancing operations within "domain".
@@ -3947,7 +4100,11 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+again:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
+		if (!preferred_node(p, env))
+			continue;
+
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
 
@@ -3955,6 +4112,7 @@ static int move_one_task(struct lb_env *env)
 			continue;
 
 		move_task(p, env);
+
 		/*
 		 * Right now, this is only the second place move_task()
 		 * is called, so we can safely collect move_task()
@@ -3963,11 +4121,12 @@ static int move_one_task(struct lb_env *env)
 		schedstat_inc(env->sd, lb_gained[env->idle]);
 		return 1;
 	}
+	if (!env->iterations++  && env->src_rq->active_balance != 2)
+		goto again;
+
 	return 0;
 }
 
-static unsigned long task_h_load(struct task_struct *p);
-
 static const unsigned int sched_nr_migrate_break = 32;
 
 /*
@@ -4002,6 +4161,9 @@ static int move_tasks(struct lb_env *env)
 			break;
 		}
 
+		if (!preferred_node(p, env))
+			goto next;
+
 		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
 			goto next;
 
@@ -5005,6 +5167,7 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		.idle		= idle,
 		.loop_break	= sched_nr_migrate_break,
 		.cpus		= cpus,
+		.iterations	= 1,
 	};
 
 	cpumask_copy(cpus, cpu_active_mask);
@@ -5047,6 +5210,11 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		env.src_rq    = busiest;
 		env.loop_max  = min(sysctl_sched_nr_migrate, busiest->nr_running);
 
+		if (sd->flags & SD_NUMA) {
+			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu))
+				env.iterations = 0;
+		}
+
 		update_h_load(env.src_cpu);
 more_balance:
 		local_irq_save(flags);
@@ -5066,6 +5234,13 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 			goto more_balance;
 		}
 
+		if (!ld_moved && !env.iterations) {
+			env.iterations++;
+			env.loop	 = 0;
+			env.loop_break	 = sched_nr_migrate_break;
+			goto more_balance;
+		}
+
 		/*
 		 * some other cpu did the load balance for us.
 		 */
@@ -5152,6 +5327,9 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 			if (!busiest->active_balance) {
 				busiest->active_balance = 1;
 				busiest->push_cpu = this_cpu;
+#ifdef CONFIG_NUMA_BALANCING
+				busiest->ab_node_load = 0;
+#endif
 				active_balance = 1;
 			}
 			raw_spin_unlock_irqrestore(&busiest->lock, flags);
@@ -5313,8 +5491,14 @@ static int active_load_balance_cpu_stop(void *data)
 			.src_cpu	= busiest_rq->cpu,
 			.src_rq		= busiest_rq,
 			.idle		= CPU_IDLE,
+			.iterations	= 1,
 		};
 
+		if ((sd->flags & SD_NUMA)) {
+			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu))
+				env.iterations = 0;
+		}
+
 		schedstat_inc(sd, alb_count);
 
 		if (move_one_task(&env))
@@ -5326,6 +5510,9 @@ static int active_load_balance_cpu_stop(void *data)
 	double_unlock_balance(busiest_rq, target_rq);
 out_unlock:
 	busiest_rq->active_balance = 0;
+#ifdef CONFIG_NUMA_BALANCING
+	busiest_rq->ab_node_load = 0;
+#endif
 	raw_spin_unlock_irq(&busiest_rq->lock);
 	return 0;
 }
@@ -5464,6 +5651,59 @@ void update_max_interval(void)
 	max_load_balance_interval = HZ*num_online_cpus()/10;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static int migrate_from_cpu(struct mm_struct *this_mm, int this_cpu, int nid)
+{
+	struct mm_struct *mm;
+	struct rq *rq;
+	int cpu;
+
+	for_each_cpu(cpu, cpumask_of_node(nid)) {
+		rq = cpu_rq(cpu);
+		mm = rq->curr->mm;
+
+		if (mm == this_mm) {
+			if (cpumask_test_cpu(this_cpu, tsk_cpus_allowed(rq->curr)))
+				return cpu;
+		}
+	}
+	return -1;
+}
+
+static int migrate_from_node(unsigned long *weights, unsigned long load, int nid)
+{
+	unsigned long least_weight = weights[nid];
+	unsigned long node_load;
+	int least_node = -1;
+	int node, cpu;
+
+	for_each_online_node(node) {
+		if (node == nid)
+			continue;
+		if (weights[node] == 0)
+			continue;
+
+		node_load = 0;
+		for_each_cpu(cpu, cpumask_of_node(node)) {
+			node_load += weighted_cpuload(cpu);
+		}
+
+		if (load > node_load) {
+			if (load * nr_node_ids >= node_load * (nr_node_ids + 1))
+				continue;
+			if (weights[node] == least_weight)
+				continue;
+		}
+
+		if (weights[node] <=  least_weight) {
+			least_weight = weights[node];
+			least_node = node;
+		}
+	}
+	return least_node;
+}
+#endif
+
 /*
  * It checks each scheduling domain to see if it is due to be balanced,
  * and initiates a balancing operation if so.
@@ -5529,6 +5769,76 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 		if (!balance)
 			break;
 	}
+#ifdef CONFIG_NUMA_BALANCING
+	if (!rq->nr_running) {
+		struct mm_struct *prev_mm = NULL;
+		unsigned long load = 0, pinned_load = 0;
+		unsigned long *weights = NULL;
+		int node, nid, dcpu;
+		int this_cpu = -1;
+
+		nid = cpu_to_node(cpu);
+
+		/* Traverse only the allowed CPUs */
+		for_each_cpu(dcpu, cpumask_of_node(nid)) {
+			load += weighted_cpuload(dcpu);
+			pinned_load += cpu_rq(dcpu)->pinned_load;
+		}
+		for_each_cpu(dcpu, cpumask_of_node(nid)) {
+			struct rq *rq = cpu_rq(dcpu);
+			struct mm_struct *mm = rq->curr->mm;
+
+			if (!mm || !mm->numa_weights)
+				continue;
+
+			weights = mm->numa_weights;
+			if (!weights[nr_node_ids] || !weights[nid])
+				continue;
+
+			if (weights[nid] + pinned_load >= load)
+				break;
+			if (weights[nr_node_ids]/weights[nid] > nr_node_ids)
+				continue;
+
+			if (mm == prev_mm)
+				continue;
+
+			prev_mm = mm;
+			node = migrate_from_node(weights, load, nid);
+			if (node == -1)
+				continue;
+			this_cpu = migrate_from_cpu(mm, cpu, node);
+			if (this_cpu != -1)
+				break;
+		}
+		if (this_cpu != -1) {
+			struct rq *this_rq;
+			unsigned long flags;
+			int active_balance;
+
+			this_rq = cpu_rq(this_cpu);
+			active_balance = 0;
+
+			/*
+			 * ->active_balance synchronizes accesses to
+			 * ->active_balance_work.  Once set, it's cleared
+			 * only after active load balance is finished.
+			 */
+			raw_spin_lock_irqsave(&this_rq->lock, flags);
+			if (!this_rq->active_balance) {
+				this_rq->active_balance = 2;
+				this_rq->push_cpu = cpu;
+				this_rq->ab_node_load = load - pinned_load;
+				active_balance = 1;
+			}
+			raw_spin_unlock_irqrestore(&this_rq->lock, flags);
+
+			if (active_balance) {
+				stop_one_cpu_nowait(this_cpu, active_load_balance_cpu_stop, this_rq, &this_rq->active_balance_work);
+			}
+		}
+	}
+#endif
 	rcu_read_unlock();
 
 	/*
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index cc03cfd..0011bba 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -484,6 +484,10 @@ struct rq {
 #endif
 
 	struct sched_avg avg;
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long pinned_load;
+	unsigned long ab_node_load;
+#endif
 };
 
 static inline int cpu_of(struct rq *rq)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
