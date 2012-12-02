Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id DA6486B00CB
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:29 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082361eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:29 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 43/52] sched: Introduce directed NUMA convergence
Date: Sun,  2 Dec 2012 19:43:35 +0100
Message-Id: <1354473824-19229-44-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

This patch replaces the purely statistical NUMA convergence
method with a directed one.

These balancing functions gets called when CPU loads are otherwise
more or less in balance, so we check whether a NUMA task wants
to migrate to another node, to improve NUMA task group clustering.

Our general goal is to converge the load in such a way that
minimizes internode memory access traffic. We do this
in a 'directed', non-statistical way, which drastically
improves the speed of convergence.

We do this directed convergence via using the 'memory buddy'
task relation which we build out of the page::last_cpu NUMA
hinting page fault driven statistics, plus the following
two sets of directed task migration rules.

The first set of rules 'compresses' groups by moving related
tasks closer to each other.

The second set of rules 'spreads' groups, when compression
creates a stable but not yet converging (optimal) layout
of tasks.

1) "group spreading"

This rule checks whether the smallest group on the current node
could move to another node.

This logic is implemented in the improve_group_balance_spread()
function.

2) "group compression"

This logic triggers if the 'spreading' logic finds no more
work to do.

First we search for the 'maximum node', i.e. the node on
which we have the most buddies, but which node is not yet
completely full with our buddies.

If this 'maximum node' is the current node, then we stop.

If this 'maximum node' is a different node from the current
node then we check the size of the smallest buddy group on
it.

If our own buddy group size on that CPU is equal or larger
than the minimum buddy group size, then we can disrupt the
smallest group and migrate to one of their CPUs - even if
that CPU is not idle.

Special cases: idle tasks, non-NUMA tasks or NUMA-private
tasks are special 1-task 'buddy groups' and are preferred
over NUMA-shared tasks, in that order.

If we replace a busy task then once we migrate to the
destination CPU we try to migrate that task to our original
CPU. It will not be able to replace us in the next round of
balancing because the flipping rule is not symmetric: our
group will be larger there than theirs.

This logic is implemented in the improve_group_balance_compress()
function.

An example of a valid group convergence transition:

( G1 is a buddy group of tasks  T1, T2, T3 on node 1 and
  T6, T7, T8 on node 2, G2 is a second buddy group on node 1
  with tasks T4, T5, G3 is a third buddy group on
  node 2 with task T9 and T10, G4 and G5 are two one-task
  groups of singleton tasks T11 and T12. Both nodes are equally
  loaded with 6 tasks and are at full capacity.):

    node 1                                   node 2
    G1(T1, T2, T3), G2(T4, T5), G4(T11)      G1(T6, T7, T8) G3(T9, T10), G5(T12)

                     ||
                    \||/
                     \/

    node 1                                   node 2
    G1(T1, T2, T3, T6), G2(T4, T5)           G1(T7, T8), G3(T9, T10), G4(T11), G5(T12)

I.e. task T6 migrated from node 2 to node 1, flipping task T11.
This was a valid migration that increased the size of group G1
on node 1, at the expense of (smaller) group G4.

The next valid migration step would be for T7 and T8 to
migrate from node 2 to node 1 as well:

                     ||
                    \||/
                     \/

    node 1                            node 2
    G1(T1, T2, T3, T6, T7, T8)        G2(T4, T5), G3(T9, T10), G4(T11), G5(T12)

Which is fully converged, with all 5 groups running on
their own node with no cross-node traffic between group
member tasks.

These two migrations were valid too because group G2 is
smaller than group G1, so it can be disrupted by G1.

"Resonance"

On its face, 'compression' and 'spreading' are opposing forces
and are thus subject to bad resonance feedback effects: what
'compression' does could be undone by 'spreading', all the
time, without it stopping.

But because 'compression' only gets called when 'spreading'
can find no more work anymore, and because 'compression'
creates larger groups on otherwise balanced nodes, which then
cannot be torn apart by 'spreading', no permanent resonance
should occur between the two.

Transients can occur, as both algorithms are lockless and can
(although typically and statistically don't) run at once on
parallel CPUs.

Choice of the convergence algorithms:
=====================================

I went for directed convergence instead of statistical convergence,
because especially on larger systems convergence speed was getting
very slow with statistical methods, only convering the most trivial,
often artificial benchmark workloads.

The mathematical proof looks somewhat difficult to outline (I have
not even tried to formally construct one), but the above logic will
monotonically sort the system until it converges into a fully
and ideally sorted state, and will do that in a finite number of
steps.

In the final state each group is the largest possible and each CPU
is loaded to the fullest: i.e. inter-node traffic is minimize.

This direct path of convergence is very fast (much faster than
the statistical, Monte-Carlo / Brownian motion convergence) but
it is not the mathematically shortest possible route to equilibrium.

By my thinking, finding the minimum-steps route would have
O(NR_CPUS^3) complexity or worse, with memory allocation and
complexity constraints unpractical and unacceptable for kernel space ...

[ If you thought that the lockdep dependency graph logic was complex,
  then such a routine would be a true monster in comparison! ]

Especially with fast moving workloads it's also doubtful whether
it's worth spending kernel resources to calculate the best path
to begin with - by the time we calculate it the scheduling situation
might have changed already ;-)

This routine fits into our existing load-balancing patterns
and algorithm complexity pretty well: it is essentially O(NR_CPUs),
it runs only rarely and tries hard to never at once run on multiple
CPUs.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h   |    1 +
 init/Kconfig            |    1 +
 kernel/sched/core.c     |    3 -
 kernel/sched/fair.c     | 1185 +++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/features.h |   20 +-
 5 files changed, 1099 insertions(+), 111 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ce9ccd7..3bc69b7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1506,6 +1506,7 @@ struct task_struct {
 	int numa_shared;
 	int numa_max_node;
 	int numa_scan_seq;
+	unsigned long numa_scan_ts_secs;
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
diff --git a/init/Kconfig b/init/Kconfig
index 018c8af..f746384 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1090,6 +1090,7 @@ config UIDGID_STRICT_TYPE_CHECKS
 
 config SCHED_AUTOGROUP
 	bool "Automatic process group scheduling"
+	depends on !NUMA_BALANCING
 	select EVENTFD
 	select CGROUPS
 	select CGROUP_SCHED
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 26ab5ff..80bdc9b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4774,9 +4774,6 @@ static int __migrate_task(struct task_struct *p, int src_cpu, int dest_cpu)
 done:
 	ret = 1;
 fail:
-#ifdef CONFIG_NUMA_BALANCING
-	rq_dest->curr_buddy = NULL;
-#endif
 	double_rq_unlock(rq_src, rq_dest);
 	raw_spin_unlock(&p->pi_lock);
 	return ret;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fda1b63..417c7bb 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -848,16 +848,777 @@ static int task_ideal_cpu(struct task_struct *p)
 	return p->ideal_cpu;
 }
 
+/*
+ * Check whether two tasks are probably in the same
+ * shared memory access group:
+ */
+static bool tasks_buddies(struct task_struct *p1, struct task_struct *p2)
+{
+	struct task_struct *p1b, *p2b;
+
+	if (p1 == p2)
+		return true;
+
+	p1b = NULL;
+	if ((task_ideal_cpu(p1) >= 0) && (p1->shared_buddy_faults > 1000))
+		p1b = p1->shared_buddy;
+
+	p2b = NULL;
+	if ((task_ideal_cpu(p2) >= 0) && (p2->shared_buddy_faults > 1000))
+		p2b = p2->shared_buddy;
+
+	if (p1b && p2b) {
+		if (p1b == p2)
+			return true;
+		if (p2b == p2)
+			return true;
+		if (p1b == p2b)
+			return true;
+	}
+
+	/* Are they both NUMA-shared and in the same mm? */
+	if (task_numa_shared(p1) == 1 && task_numa_shared(p2) == 1 && p1->mm == p2->mm)
+		return true;
+
+	return false;
+}
+
+#define NUMA_LOAD_IDX_HIGHFREQ	0
+#define NUMA_LOAD_IDX_LOWFREQ	3
+
+#define LOAD_HIGHER		true
+#define LOAD_LOWER		false
+
+/*
+ * Load of all tasks:
+ */
+static long calc_node_load(int node, bool use_higher)
+{
+	long cpu_load_highfreq;
+	long cpu_load_lowfreq;
+	long cpu_load_curr;
+	long min_cpu_load;
+	long max_cpu_load;
+	long node_load;
+	int cpu;
+
+	node_load = 0;
+
+	for_each_cpu(cpu, cpumask_of_node(node)) {
+		struct rq *rq = cpu_rq(cpu);
+
+		cpu_load_curr		= rq->load.weight;
+		cpu_load_lowfreq	= rq->cpu_load[NUMA_LOAD_IDX_LOWFREQ];
+		cpu_load_highfreq	= rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
+
+		min_cpu_load = min(min(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+		max_cpu_load = max(max(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+
+		if (use_higher)
+			node_load += max_cpu_load;
+		else
+			node_load += min_cpu_load;
+	}
+
+	return node_load;
+}
+
+/*
+ * The capacity of this node:
+ */
+static long calc_node_capacity(int node)
+{
+	return cpumask_weight(cpumask_of_node(node)) * SCHED_LOAD_SCALE;
+}
+
+/*
+ * Load of shared NUMA tasks:
+ */
+static long calc_node_shared_load(int node)
+{
+	long node_load = 0;
+	int cpu;
+
+	for_each_cpu(cpu, cpumask_of_node(node)) {
+		struct rq *rq = cpu_rq(cpu);
+		struct task_struct *curr;
+
+		curr = ACCESS_ONCE(rq->curr);
+
+		if (task_numa_shared(curr) == 1)
+			node_load += rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
+	}
+
+	return node_load;
+}
+
+/*
+ * Find the least busy CPU that is below a limit load,
+ * on a specific node:
+ */
+static int __find_min_cpu(int node, long load_threshold)
+{
+	long min_cpu_load;
+	int min_cpu;
+	long cpu_load_highfreq;
+	long cpu_load_lowfreq;
+	long cpu_load;
+	int cpu;
+
+	min_cpu_load = LONG_MAX;
+	min_cpu = -1;
+
+	for_each_cpu(cpu, cpumask_of_node(node)) {
+		struct rq *rq = cpu_rq(cpu);
+
+		cpu_load_highfreq = rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
+		cpu_load_lowfreq = rq->cpu_load[NUMA_LOAD_IDX_LOWFREQ];
+
+		/* Be conservative: */
+		cpu_load = max(cpu_load_highfreq, cpu_load_lowfreq);
+
+		if (cpu_load < min_cpu_load) {
+			min_cpu_load = cpu_load;
+			min_cpu = cpu;
+		}
+	}
+
+	if (min_cpu_load > load_threshold)
+		return -1;
+
+	return min_cpu;
+}
+
+/*
+ * Find an idle CPU:
+ */
+static int find_idle_cpu(int node)
+{
+	return __find_min_cpu(node, SCHED_LOAD_SCALE/2);
+}
+
+/*
+ * Find the least loaded CPU on a node:
+ */
+static int find_min_cpu(int node)
+{
+	return __find_min_cpu(node, LONG_MAX);
+}
+
+/*
+ * Find the most idle node:
+ */
+static int find_idlest_node(int *idlest_cpu)
+{
+	int idlest_node;
+	int max_idle_cpus;
+	int target_cpu = -1;
+	int idle_cpus;
+	int node;
+	int cpu;
+
+	idlest_node = -1;
+	max_idle_cpus = 0;
+
+	for_each_online_node(node) {
+
+		idle_cpus = 0;
+		target_cpu = -1;
+
+		for_each_cpu(cpu, cpumask_of_node(node)) {
+			struct rq *rq = cpu_rq(cpu);
+			struct task_struct *curr;
+
+			curr = ACCESS_ONCE(rq->curr);
+
+			if (curr == rq->idle) {
+				idle_cpus++;
+				if (target_cpu == -1)
+					target_cpu = cpu;
+			}
+		}
+		if (idle_cpus > max_idle_cpus) {
+			max_idle_cpus = idle_cpus;
+
+			idlest_node = node;
+			*idlest_cpu = target_cpu;
+		}
+	}
+
+	return idlest_node;
+}
+
+/*
+ * Find the minimally loaded CPU on this node and see whether
+ * we can balance to it:
+ */
+static int find_intranode_imbalance(int this_node, int this_cpu)
+{
+	long cpu_load_highfreq;
+	long cpu_load_lowfreq;
+	long this_cpu_load;
+	long cpu_load_curr;
+	long min_cpu_load;
+	long cpu_load;
+	int min_cpu;
+	int cpu;
+
+	if (WARN_ON_ONCE(cpu_to_node(this_cpu) != this_node))
+		return -1;
+
+	min_cpu_load = LONG_MAX;
+	this_cpu_load = 0;
+	min_cpu = -1;
+
+	for_each_cpu(cpu, cpumask_of_node(this_node)) {
+		struct rq *rq = cpu_rq(cpu);
+
+		cpu_load_curr		= rq->load.weight;
+		cpu_load_lowfreq	= rq->cpu_load[NUMA_LOAD_IDX_LOWFREQ];
+		cpu_load_highfreq	= rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
+
+		if (cpu == this_cpu) {
+			this_cpu_load = min(min(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+		}
+		cpu_load = max(max(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+
+		/* Find the idlest CPU: */
+		if (cpu_load < min_cpu_load) {
+			min_cpu_load = cpu_load;
+			min_cpu = cpu;
+		}
+	}
+
+	if (this_cpu_load - min_cpu_load < 1536)
+		return -1;
+
+	return min_cpu;
+}
+
+
+/*
+ * Search a node for the smallest-group task and return
+ * it plus the size of the group it is in.
+ */
+static int buddy_group_size(int node, struct task_struct *p)
+{
+	const cpumask_t *node_cpus_mask = cpumask_of_node(node);
+	cpumask_t cpus_to_check_mask;
+	bool our_group_found;
+	int cpu1, cpu2;
+
+	cpumask_copy(&cpus_to_check_mask, node_cpus_mask);
+	our_group_found = false;
+
+	if (WARN_ON_ONCE(cpumask_empty(&cpus_to_check_mask)))
+		return 0;
+
+	/* Iterate over all buddy groups: */
+	do {
+		for_each_cpu(cpu1, &cpus_to_check_mask) {
+			struct task_struct *group_head;
+			struct rq *rq1 = cpu_rq(cpu1);
+			int group_size;
+			int head_cpu;
+
+			group_head = rq1->curr;
+			head_cpu = cpu1;
+			cpumask_clear_cpu(cpu1, &cpus_to_check_mask);
+
+			group_size = 1;
+			if (tasks_buddies(group_head, p))
+				our_group_found = true;
+
+			/* Non-NUMA-shared tasks are 1-task groups: */
+			if (task_numa_shared(group_head) != 1)
+				goto next;
+
+			WARN_ON_ONCE(group_head == rq1->idle);
+
+			for_each_cpu(cpu2, &cpus_to_check_mask) {
+				struct rq *rq2 = cpu_rq(cpu2);
+				struct task_struct *p2 = rq2->curr;
+
+				WARN_ON_ONCE(rq1 == rq2);
+				if (tasks_buddies(group_head, p2)) {
+					/* 'group_head' and 'rq2->curr' are in the same group: */
+					cpumask_clear_cpu(cpu2, &cpus_to_check_mask);
+					group_size++;
+					if (tasks_buddies(p2, p))
+						our_group_found = true;
+				}
+			}
+next:
+
+			/*
+			 * If we just found our group and checked all
+			 * node local CPUs then return the result:
+			 */
+			if (our_group_found)
+				return group_size;
+		}
+	} while (!cpumask_empty(&cpus_to_check_mask));
+
+	return 0;
+}
+
+/*
+ * Search a node for the smallest-group task and return
+ * it plus the size of the group it is in.
+ */
+static int find_group_min_cpu(int node, int *group_size)
+{
+	const cpumask_t *node_cpus_mask = cpumask_of_node(node);
+	cpumask_t cpus_to_check_mask;
+	int min_group_size;
+	int min_group_cpu;
+	int group_cpu;
+	int cpu1, cpu2;
+
+	min_group_size = INT_MAX;
+	min_group_cpu = -1;
+	cpumask_copy(&cpus_to_check_mask, node_cpus_mask);
+
+	WARN_ON_ONCE(cpumask_empty(&cpus_to_check_mask));
+
+	/* Iterate over all buddy groups: */
+	do {
+		group_cpu = -1;
+
+		for_each_cpu(cpu1, &cpus_to_check_mask) {
+			struct task_struct *group_head;
+			struct rq *rq1 = cpu_rq(cpu1);
+			int group_size;
+			int head_cpu;
+
+			group_head = rq1->curr;
+			head_cpu = cpu1;
+			cpumask_clear_cpu(cpu1, &cpus_to_check_mask);
+
+			group_size = 1;
+			group_cpu = cpu1;
+
+			/* Non-NUMA-shared tasks are 1-task groups: */
+			if (task_numa_shared(group_head) != 1)
+				goto pick_non_numa_task;
+
+			WARN_ON_ONCE(group_head == rq1->idle);
+
+			for_each_cpu(cpu2, &cpus_to_check_mask) {
+				struct rq *rq2 = cpu_rq(cpu2);
+				struct task_struct *p2 = rq2->curr;
+
+				WARN_ON_ONCE(rq1 == rq2);
+				if (tasks_buddies(group_head, p2)) {
+					/* 'group_head' and 'rq2->curr' are in the same group: */
+					cpumask_clear_cpu(cpu2, &cpus_to_check_mask);
+					group_size++;
+				}
+			}
+
+			if (group_size < min_group_size) {
+pick_non_numa_task:
+				min_group_size = group_size;
+				min_group_cpu = head_cpu;
+			}
+		}
+	} while (!cpumask_empty(&cpus_to_check_mask));
+
+	if (min_group_cpu != -1)
+		*group_size = min_group_size;
+	else
+		*group_size = 0;
+
+	return min_group_cpu;
+}
+
+static int find_max_node(struct task_struct *p, int *our_group_size)
+{
+	int max_group_size;
+	int group_size;
+	int max_node;
+	int node;
+
+	max_group_size = -1;
+	max_node = -1;
+
+	for_each_node(node) {
+		int full_size = cpumask_weight(cpumask_of_node(node));
+
+		group_size = buddy_group_size(node, p);
+		if (group_size == full_size)
+			continue;
+
+		if (group_size > max_group_size) {
+			max_group_size = group_size;
+			max_node = node;
+		}
+	}
+
+	*our_group_size = max_group_size;
+
+	return max_node;
+}
+
+/*
+ * NUMA convergence.
+ *
+ * This is the heart of the CONFIG_NUMA_BALANCING=y NUMA balancing logic.
+ *
+ * These functions gets called when CPU loads are otherwise more or
+ * less in balance, so we check whether this NUMA task wants to migrate
+ * to another node, to improve NUMA task group clustering.
+ *
+ * Our general goal is to converge the load in such a way that
+ * minimizes internode memory access traffic. We do this
+ * in a 'directed', non-statistical way, which drastically
+ * improves the speed of convergence.
+ *
+ * We do this directed convergence via using the 'memory buddy'
+ * task relation which we build out of the page::last_cpu NUMA
+ * hinting page fault driven statistics, plus the following
+ * two sets of directed task migration rules.
+ *
+ * The first set of rules 'compresses' groups by moving related
+ * tasks closer to each other.
+ *
+ * The second set of rules 'spreads' groups, when compression
+ * creates a stable but not yet converging (optimal) layout
+ * of tasks.
+ *
+ * 1) "group spreading"
+ *
+ * This rule checks whether the smallest group on the current node
+ * could move to another node.
+ *
+ * This logic is implemented in the improve_group_balance_spread()
+ * function.
+ *
+ * ============================================================
+ *
+ * 2) "group compression"
+ *
+ * This logic triggers if the 'spreading' logic finds no more
+ * work to do.
+ *
+ * First we search for the 'maximum node', i.e. the node on
+ * which we have the most buddies, but which node is not yet
+ * completely full with our buddies.
+ *
+ * If this 'maximum node' is the current node, then we stop.
+ *
+ * If this 'maximum node' is a different node from the current
+ * node then we check the size of the smallest buddy group on
+ * it.
+ *
+ * If our own buddy group size on that CPU is equal or larger
+ * than the minimum buddy group size, then we can disrupt the
+ * smallest group and migrate to one of their CPUs - even if
+ * that CPU is not idle.
+ *
+ * Special cases: idle tasks, non-NUMA tasks or NUMA-private
+ * tasks are special 1-task 'buddy groups' and are preferred
+ * over NUMA-shared tasks, in that order.
+ *
+ * If we replace a busy task then once we migrate to the
+ * destination CPU we try to migrate that task to our original
+ * CPU. It will not be able to replace us in the next round of
+ * balancing because the flipping rule is not symmetric: our
+ * group will be larger there than theirs.
+ *
+ * This logic is implemented in the improve_group_balance_compress()
+ * function.
+ *
+ * ============================================================
+ *
+ * An example of a valid group convergence transition:
+ *
+ * ( G1 is a buddy group of tasks  T1, T2, T3 on node 1 and
+ *   T6, T7, T8 on node 2, G2 is a second buddy group on node 1
+ *   with tasks T4, T5, G3 is a third buddy group on
+ *   node 2 with task T9 and T10, G4 and G5 are two one-task
+ *   groups of singleton tasks T11 and T12. Both nodes are equally
+ *   loaded with 6 tasks and are at full capacity.):
+ *
+ *     node 1                                   node 2
+ *     G1(T1, T2, T3), G2(T4, T5), G4(T11)      G1(T6, T7, T8) G3(T9, T10), G5(T12)
+ *
+ *                      ||
+ *                     \||/
+ *                      \/
+ *
+ *     node 1                                   node 2
+ *     G1(T1, T2, T3, T6), G2(T4, T5)           G1(T7, T8), G3(T9, T10), G4(T11), G5(T12)
+ *
+ * I.e. task T6 migrated from node 2 to node 1, flipping task T11.
+ * This was a valid migration that increased the size of group G1
+ * on node 1, at the expense of (smaller) group G4.
+ *
+ * The next valid migration step would be for T7 and T8 to
+ * migrate from node 2 to node 1 as well:
+ *
+ *                      ||
+ *                     \||/
+ *                      \/
+ *
+ *     node 1                            node 2
+ *     G1(T1, T2, T3, T6, T7, T8)        G2(T4, T5), G3(T9, T10), G4(T11), G5(T12)
+ *
+ * Which is fully converged, with all 5 groups running on
+ * their own node with no cross-node traffic between group
+ * member tasks.
+ *
+ * These two migrations were valid too because group G2 is
+ * smaller than group G1, so it can be disrupted by G1.
+ *
+ * ============================================================
+ *
+ * "Resonance"
+ *
+ * On its face, 'compression' and 'spreading' are opposing forces
+ * and are thus subject to bad resonance feedback effects: what
+ * 'compression' does could be undone by 'spreading', all the
+ * time, without it stopping.
+ *
+ * But because 'compression' only gets called when 'spreading'
+ * can find no more work anymore, and because 'compression'
+ * creates larger groups on otherwise balanced nodes, which then
+ * cannot be torn apart by 'spreading', no permanent resonance
+ * should occur between the two.
+ *
+ * Transients can occur, as both algorithms are lockless and can
+ * (although typically and statistically don't) run at once on
+ * parallel CPUs.
+ *
+ * ============================================================
+ *
+ * Choice of the convergence algorithms:
+ *
+ * I went for directed convergence instead of statistical convergence,
+ * because especially on larger systems convergence speed was getting
+ * very slow with statistical methods, only convering the most trivial,
+ * often artificial benchmark workloads.
+ *
+ * The mathematical proof looks somewhat difficult to outline (I have
+ * not even tried to formally construct one), but the above logic will
+ * monotonically sort the system until it converges into a fully
+ * and ideally sorted state, and will do that in a finite number of
+ * steps.
+ *
+ * In the final state each group is the largest possible and each CPU
+ * is loaded to the fullest: i.e. inter-node traffic is minimize.
+ *
+ * This direct path of convergence is very fast (much faster than
+ * the statistical, Monte-Carlo / Brownian motion convergence) but
+ * it is not the mathematically shortest possible route to equilibrium.
+ *
+ * By my thinking, finding the minimum-steps route would have
+ * O(NR_CPUS^3) complexity or worse, with memory allocation and
+ * complexity constraints unpractical and unacceptable for kernel space ...
+ *
+ * [ If you thought that the lockdep dependency graph logic was complex,
+ *   then such a routine would be a true monster in comparison! ]
+ *
+ * Especially with fast moving workloads it's also doubtful whether
+ * it's worth spending kernel resources to calculate the best path
+ * to begin with - by the time we calculate it the scheduling situation
+ * might have changed already ;-)
+ *
+ * This routine fits into our existing load-balancing patterns
+ * and algorithm complexity pretty well: it is essentially O(NR_CPUs),
+ * it runs only rarely and tries hard to never at once run on multiple
+ * CPUs.
+ */
+static int improve_group_balance_compress(struct task_struct *p, int this_cpu, int this_node)
+{
+	int our_group_size = -1;
+	int min_group_size = -1;
+	int max_node;
+	int min_cpu;
+
+	if (!sched_feat(NUMA_GROUP_LB_COMPRESS))
+		return -1;
+
+	max_node = find_max_node(p, &our_group_size);
+	if (max_node == -1)
+		return -1;
+
+	if (WARN_ON_ONCE(our_group_size == -1))
+		return -1;
+
+	/* We are already in the right spot: */
+	if (max_node == this_node)
+		return -1;
+
+	/* Special case, if all CPUs are fully loaded with our buddies: */
+	if (our_group_size == 0)
+		return -1;
+
+	/* Ok, we desire to go to the max node, now see whether we can do it: */
+	min_cpu = find_group_min_cpu(max_node, &min_group_size);
+	if (min_cpu == -1)
+		return -1;
+
+	if (WARN_ON_ONCE(min_group_size <= 0))
+		return -1;
+
+	/*
+	 * If the minimum group is larger than ours then skip it:
+	 */
+	if (min_group_size > our_group_size)
+		return -1;
+
+	/*
+	 * Go pick the minimum CPU:
+	 */
+	return min_cpu;
+}
+
+static int improve_group_balance_spread(struct task_struct *p, int this_cpu, int this_node)
+{
+	const cpumask_t *node_cpus_mask = cpumask_of_node(this_node);
+	cpumask_t cpus_to_check_mask;
+	bool found_our_group = false;
+	bool our_group_smallest = false;
+	int our_group_size = -1;
+	int min_group_size;
+	int idlest_node;
+	long this_group_load;
+	long idlest_node_load = -1;
+	long this_node_load = -1;
+	long delta_load_before;
+	long delta_load_after;
+	int idlest_cpu = -1;
+	int cpu1, cpu2;
+
+	if (!sched_feat(NUMA_GROUP_LB_SPREAD))
+		return -1;
+
+	/* Only consider shared tasks: */
+	if (task_numa_shared(p) != 1)
+		return -1;
+
+	min_group_size = INT_MAX;
+	cpumask_copy(&cpus_to_check_mask, node_cpus_mask);
+
+	WARN_ON_ONCE(cpumask_empty(&cpus_to_check_mask));
+
+	/* Iterate over all buddy groups: */
+	do {
+		for_each_cpu(cpu1, &cpus_to_check_mask) {
+			struct task_struct *group_head;
+			struct rq *rq1 = cpu_rq(cpu1);
+			bool our_group = false;
+			int group_size;
+			int head_cpu;
+
+			group_head = rq1->curr;
+			head_cpu = cpu1;
+			cpumask_clear_cpu(cpu1, &cpus_to_check_mask);
+
+			/* Only NUMA-shared tasks are parts of groups: */
+			if (task_numa_shared(group_head) != 1)
+				continue;
+
+			WARN_ON_ONCE(group_head == rq1->idle);
+			group_size = 1;
+
+			if (group_head == p)
+				our_group = true;
+
+			for_each_cpu(cpu2, &cpus_to_check_mask) {
+				struct rq *rq2 = cpu_rq(cpu2);
+				struct task_struct *p2 = rq2->curr;
+
+				WARN_ON_ONCE(rq1 == rq2);
+				if (tasks_buddies(group_head, p2)) {
+					/* 'group_head' and 'rq2->curr' are in the same group: */
+					cpumask_clear_cpu(cpu2, &cpus_to_check_mask);
+					group_size++;
+					if (p == p2)
+						our_group = true;
+				}
+			}
+
+			if (our_group) {
+				found_our_group = true;
+				our_group_size = group_size;
+				if (group_size <= min_group_size)
+					our_group_smallest = true;
+			} else {
+				if (found_our_group) {
+					if (group_size < our_group_size)
+						our_group_smallest = false;
+				}
+			}
 
-static int sched_update_ideal_cpu_shared(struct task_struct *p)
+			if (min_group_size == -1)
+				min_group_size = group_size;
+			else
+				min_group_size = min(group_size, min_group_size);
+		}
+	} while (!cpumask_empty(&cpus_to_check_mask));
+
+	/*
+	 * Now we know what size our group has and whether we
+	 * are the smallest one:
+	 */
+	if (!found_our_group)
+		return -1;
+	if (!our_group_smallest)
+		return -1;
+	if (WARN_ON_ONCE(min_group_size == -1))
+		return -1;
+	if (WARN_ON_ONCE(our_group_size == -1))
+		return -1;
+
+	idlest_node = find_idlest_node(&idlest_cpu);
+	if (idlest_node == -1)
+		return -1;
+
+	WARN_ON_ONCE(idlest_cpu == -1);
+
+	this_node_load		= calc_node_shared_load(this_node);
+	idlest_node_load	= calc_node_shared_load(idlest_node);
+	this_group_load		= our_group_size*SCHED_LOAD_SCALE;
+
+	/*
+	 * Lets check whether it would make sense to move this smallest
+	 * group - whether it increases system-wide balance.
+	 *
+	 * this node right now has "this_node_load", the potential
+	 * target node has "idlest_node_load". Does the difference
+	 * in load improve if we move over "this_group_load" to that
+	 * node?
+	 */
+	delta_load_before = this_node_load - idlest_node_load;
+	delta_load_after = (this_node_load-this_group_load) - (idlest_node_load+this_group_load);
+	
+	if (abs(delta_load_after)+SCHED_LOAD_SCALE > abs(delta_load_before))
+		return -1;
+
+	return idlest_cpu;
+
+}
+
+static int sched_update_ideal_cpu_shared(struct task_struct *p, int *flip_tasks)
 {
-	int full_buddies;
+	bool idle_target;
 	int max_buddies;
+	long node_load;
+	long this_node_load;
+	long this_node_capacity;
+	bool this_node_overloaded;
+	int min_node;
+	long min_node_load;
+	long ideal_node_load;
+	long ideal_node_capacity;
+	long node_capacity;
 	int target_cpu;
 	int ideal_cpu;
-	int this_cpu;
 	int this_node;
-	int best_node;
+	int ideal_node;
+	int this_cpu;
 	int buddies;
 	int node;
 	int cpu;
@@ -866,16 +1627,23 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p)
 		return -1;
 
 	ideal_cpu = -1;
-	best_node = -1;
+	ideal_node = -1;
 	max_buddies = 0;
 	this_cpu = task_cpu(p);
 	this_node = cpu_to_node(this_cpu);
+	min_node_load = LONG_MAX;
+	min_node = -1;
 
+	/*
+	 * Map out our maximum buddies layout:
+	 */
 	for_each_online_node(node) {
-		full_buddies = cpumask_weight(cpumask_of_node(node));
-
 		buddies = 0;
 		target_cpu = -1;
+		idle_target = false;
+
+		node_load = calc_node_load(node, LOAD_HIGHER);
+		node_capacity = calc_node_capacity(node);
 
 		for_each_cpu(cpu, cpumask_of_node(node)) {
 			struct task_struct *curr;
@@ -892,140 +1660,267 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p)
 			curr = ACCESS_ONCE(rq->curr);
 
 			if (curr == p) {
-				buddies += 1;
+				buddies++;
 				continue;
 			}
 
-			/* Pick up idle tasks immediately: */
-			if (curr == rq->idle && !rq->curr_buddy)
-				target_cpu = cpu;
+			if (curr == rq->idle) {
+				/* Pick up idle CPUs immediately: */
+				if (!rq->curr_buddy) {
+					target_cpu = cpu;
+					idle_target = true;
+				}
+				continue;
+			}
 
 			/* Leave alone non-NUMA tasks: */
 			if (task_numa_shared(curr) < 0)
 				continue;
 
-			/* Private task is an easy target: */
+			/* Private tasks are an easy target: */
 			if (task_numa_shared(curr) == 0) {
-				if (!rq->curr_buddy)
+				if (!rq->curr_buddy && !idle_target)
 					target_cpu = cpu;
 				continue;
 			}
 			if (curr->mm != p->mm) {
 				/* Leave alone different groups on their ideal node: */
-				if (cpu_to_node(curr->ideal_cpu) == node)
+				if (curr->ideal_cpu >= 0 && cpu_to_node(curr->ideal_cpu) == node)
 					continue;
-				if (!rq->curr_buddy)
+				if (!rq->curr_buddy && !idle_target)
 					target_cpu = cpu;
 				continue;
 			}
 
 			buddies++;
 		}
-		WARN_ON_ONCE(buddies > full_buddies);
+
+		if (node_load < min_node_load) {
+			min_node_load = node_load;
+			min_node = node;
+		}
+
 		if (buddies)
 			node_set(node, p->numa_policy.v.nodes);
 		else
 			node_clear(node, p->numa_policy.v.nodes);
 
-		/* Don't go to a node that is already at full capacity: */
-		if (buddies == full_buddies)
+		/* Don't go to a node that is near its capacity limit: */
+		if (node_load + SCHED_LOAD_SCALE > node_capacity)
 			continue;
-
 		if (!buddies)
 			continue;
 
 		if (buddies > max_buddies && target_cpu != -1) {
 			max_buddies = buddies;
-			best_node = node;
+			ideal_node = node;
 			WARN_ON_ONCE(target_cpu == -1);
 			ideal_cpu = target_cpu;
 		}
 	}
 
-	WARN_ON_ONCE(best_node == -1 && ideal_cpu != -1);
-	WARN_ON_ONCE(best_node != -1 && ideal_cpu == -1);
+	if (WARN_ON_ONCE(ideal_node == -1 && ideal_cpu != -1))
+		return this_cpu;
+	if (WARN_ON_ONCE(ideal_node != -1 && ideal_cpu == -1))
+		return this_cpu;
+	if (WARN_ON_ONCE(min_node == -1))
+		return this_cpu;
 
-	this_node = cpu_to_node(this_cpu);
+	ideal_cpu = ideal_node = -1;
+
+	/*
+	 * If things are more or less in balance, check now
+	 * whether we can improve balance by moving larger
+	 * groups than single tasks:
+	 */
+	if (ideal_cpu == -1 || cpu_to_node(ideal_cpu) == this_node) {
+		if (ideal_node == this_node || ideal_node == -1) {
+			target_cpu = improve_group_balance_spread(p, this_cpu, this_node);
+			if (target_cpu == -1) {
+				target_cpu = improve_group_balance_compress(p, this_cpu, this_node);
+				/* In compression we override (most) overload concerns: */
+				if (target_cpu != -1) {
+					*flip_tasks = 1;
+					return target_cpu;
+				}
+			}
+			if (target_cpu != -1) {
+				ideal_cpu = target_cpu;
+				ideal_node = cpu_to_node(ideal_cpu);
+			}
+		}
+	}
+
+	this_node_load		= calc_node_load(this_node, LOAD_LOWER);
+	this_node_capacity	= calc_node_capacity(this_node);
+
+	this_node_overloaded = false;
+	if (this_node_load > this_node_capacity + 512)
+		this_node_overloaded = true;
 
 	/* If we'd stay within this node then stay put: */
 	if (ideal_cpu == -1 || cpu_to_node(ideal_cpu) == this_node)
-		ideal_cpu = this_cpu;
+		goto out_handle_overload;
+
+	ideal_node = cpu_to_node(ideal_cpu);
+
+	ideal_node_load		= calc_node_load(ideal_node, LOAD_HIGHER);
+	ideal_node_capacity	= calc_node_capacity(ideal_node);
+
+	/* Don't move if the target node is near its capacity limit: */
+	if (ideal_node_load + SCHED_LOAD_SCALE > ideal_node_capacity)
+		goto out_handle_overload;
+
+	/* Only move if we can see an idle CPU: */
+	ideal_cpu = find_min_cpu(ideal_node);
+	if (ideal_cpu == -1)
+		goto out_check_intranode;
+
+	return ideal_cpu;
+
+out_handle_overload:
+	if (!this_node_overloaded)
+		goto out_check_intranode;
+
+	if (this_node == min_node)
+		goto out_check_intranode;
+
+	ideal_cpu = find_idle_cpu(min_node);
+	if (ideal_cpu == -1)
+		goto out_check_intranode;
 
 	return ideal_cpu;
+	/*
+	 * Check for imbalance within this otherwise balanced node:
+	 */
+out_check_intranode:
+	ideal_cpu = find_intranode_imbalance(this_node, this_cpu);
+	if (ideal_cpu != -1 && ideal_cpu != this_cpu)
+		return ideal_cpu;
+
+	return this_cpu;
 }
 
+/*
+ * Private tasks are not part of any groups, so they try place
+ * themselves to improve NUMA load in general.
+ *
+ * For that they simply want to find the least loaded node
+ * in the system, and check whether they can migrate there.
+ *
+ * To speed up convergence and to avoid a thundering herd of
+ * private tasks, we move from the busiest node (which still
+ * has private tasks) to the idlest node.
+ */
 static int sched_update_ideal_cpu_private(struct task_struct *p)
 {
-	int full_idles;
-	int this_idles;
-	int max_idles;
-	int target_cpu;
+	long this_node_load;
+	long this_node_capacity;
+	bool this_node_overloaded;
+	long ideal_node_load;
+	long ideal_node_capacity;
+	long min_node_load;
+	long max_node_load;
+	long node_load;
+	int ideal_node;
 	int ideal_cpu;
-	int best_node;
 	int this_node;
 	int this_cpu;
-	int idles;
+	int min_node;
+	int max_node;
 	int node;
-	int cpu;
 
 	if (!sched_feat(PUSH_PRIVATE_BUDDIES))
 		return -1;
 
 	ideal_cpu = -1;
-	best_node = -1;
-	max_idles = 0;
-	this_idles = 0;
+	ideal_node = -1;
 	this_cpu = task_cpu(p);
 	this_node = cpu_to_node(this_cpu);
 
-	for_each_online_node(node) {
-		full_idles = cpumask_weight(cpumask_of_node(node));
+	min_node_load = LONG_MAX;
+	max_node = -1;
+	max_node_load = 0;
+	min_node = -1;
 
-		idles = 0;
-		target_cpu = -1;
-
-		for_each_cpu(cpu, cpumask_of_node(node)) {
-			struct rq *rq;
+	/*
+	 * Calculate:
+	 *
+	 *  - the most loaded node
+	 *  - the least loaded node
+	 *  - our load
+	 */
+	for_each_online_node(node) {
+		node_load = calc_node_load(node, LOAD_HIGHER);
 
-			WARN_ON_ONCE(cpu_to_node(cpu) != node);
+		if (node_load > max_node_load) {
+			max_node_load = node_load;
+			max_node = node;
+		}
 
-			rq = cpu_rq(cpu);
-			if (rq->curr == rq->idle) {
-				if (!rq->curr_buddy)
-					target_cpu = cpu;
-				idles++;
-			}
+		if (node_load < min_node_load) {
+			min_node_load = node_load;
+			min_node = node;
 		}
-		WARN_ON_ONCE(idles > full_idles);
 
 		if (node == this_node)
-			this_idles = idles;
+			this_node_load = node_load;
+	}
 
-		if (!idles)
-			continue;
+	this_node_load		= calc_node_load(this_node, LOAD_LOWER);
+	this_node_capacity	= calc_node_capacity(this_node);
 
-		if (idles > max_idles && target_cpu != -1) {
-			max_idles = idles;
-			best_node = node;
-			WARN_ON_ONCE(target_cpu == -1);
-			ideal_cpu = target_cpu;
-		}
-	}
+	this_node_overloaded = false;
+	if (this_node_load > this_node_capacity + 512)
+		this_node_overloaded = true;
+
+	if (this_node == min_node)
+		goto out_check_intranode;
+
+	/* When not overloaded, only balance from the busiest node: */
+	if (0 && !this_node_overloaded && this_node != max_node)
+		return this_cpu;
+
+	WARN_ON_ONCE(max_node_load < min_node_load);
+
+	/* Is the load difference at least 125% of one standard task load? */
+	if (this_node_load - min_node_load < 1536)
+		goto out_check_intranode;
+
+	/*
+	 * Ok, the min node is a viable target for us,
+	 * find a target CPU on it, if any:
+	 */
+	ideal_node = min_node;
+	ideal_cpu = find_idle_cpu(ideal_node);
+	if (ideal_cpu == -1)
+		return this_cpu;
 
-	WARN_ON_ONCE(best_node == -1 && ideal_cpu != -1);
-	WARN_ON_ONCE(best_node != -1 && ideal_cpu == -1);
+	ideal_node = cpu_to_node(ideal_cpu);
 
-	/* If the target is not idle enough, skip: */
-	if (max_idles <= this_idles+1)
+	ideal_node_load		= calc_node_load(ideal_node, LOAD_HIGHER);
+	ideal_node_capacity	= calc_node_capacity(ideal_node);
+
+	/* Only move if the target node is less loaded than us: */
+	if (ideal_node_load > this_node_load)
 		ideal_cpu = this_cpu;
-		
-	/* If we'd stay within this node then stay put: */
-	if (ideal_cpu == -1 || cpu_to_node(ideal_cpu) == this_node)
+
+	/* And if the target node is not over capacity: */
+	if (ideal_node_load + SCHED_LOAD_SCALE > ideal_node_capacity)
 		ideal_cpu = this_cpu;
 
 	return ideal_cpu;
-}
 
+	/*
+	 * Check for imbalance within this otherwise balanced node:
+	 */
+out_check_intranode:
+	ideal_cpu = find_intranode_imbalance(this_node, this_cpu);
+	if (ideal_cpu != -1 && ideal_cpu != this_cpu)
+		return ideal_cpu;
+
+	return this_cpu;
+}
 
 /*
  * Called for every full scan - here we consider switching to a new
@@ -1072,8 +1967,10 @@ static void task_numa_placement_tick(struct task_struct *p)
 {
 	unsigned long total[2] = { 0, 0 };
 	unsigned long faults, max_faults = 0;
-	int node, priv, shared, max_node = -1;
+	int node, priv, shared, ideal_node = -1;
+	int flip_tasks;
 	int this_node;
+	int this_cpu;
 
 	/*
 	 * Update the fault average with the result of the latest
@@ -1090,25 +1987,20 @@ static void task_numa_placement_tick(struct task_struct *p)
 			p->numa_faults_curr[idx] = 0;
 
 			/* Keep a simple running average: */
-			p->numa_faults[idx] = p->numa_faults[idx]*7 + new_faults;
-			p->numa_faults[idx] /= 8;
+			p->numa_faults[idx] = p->numa_faults[idx]*15 + new_faults;
+			p->numa_faults[idx] /= 16;
 
 			faults += p->numa_faults[idx];
 			total[priv] += p->numa_faults[idx];
 		}
 		if (faults > max_faults) {
 			max_faults = faults;
-			max_node = node;
+			ideal_node = node;
 		}
 	}
 
 	shared_fault_full_scan_done(p);
 
-	p->numa_migrate_seq++;
-	if (sched_feat(NUMA_SETTLE) &&
-	    p->numa_migrate_seq < sysctl_sched_numa_settle_count)
-		return;
-
 	/*
 	 * Note: shared is spread across multiple tasks and in the future
 	 * we might want to consider a different equation below to reduce
@@ -1128,25 +2020,27 @@ static void task_numa_placement_tick(struct task_struct *p)
 			shared = 0;
 	}
 
+	flip_tasks = 0;
+
 	if (shared)
-		p->ideal_cpu = sched_update_ideal_cpu_shared(p);
+		p->ideal_cpu = sched_update_ideal_cpu_shared(p, &flip_tasks);
 	else
 		p->ideal_cpu = sched_update_ideal_cpu_private(p);
 
 	if (p->ideal_cpu >= 0) {
 		/* Filter migrations a bit - the same target twice in a row is picked: */
-		if (p->ideal_cpu == p->ideal_cpu_candidate) {
-			max_node = cpu_to_node(p->ideal_cpu);
+		if (1 || p->ideal_cpu == p->ideal_cpu_candidate) {
+			ideal_node = cpu_to_node(p->ideal_cpu);
 		} else {
 			p->ideal_cpu_candidate = p->ideal_cpu;
-			max_node = -1;
+			ideal_node = -1;
 		}
 	} else {
-		if (max_node < 0)
-			max_node = p->numa_max_node;
+		if (ideal_node < 0)
+			ideal_node = p->numa_max_node;
 	}
 
-	if (shared != task_numa_shared(p) || (max_node != -1 && max_node != p->numa_max_node)) {
+	if (shared != task_numa_shared(p) || (ideal_node != -1 && ideal_node != p->numa_max_node)) {
 
 		p->numa_migrate_seq = 0;
 		/*
@@ -1156,26 +2050,28 @@ static void task_numa_placement_tick(struct task_struct *p)
 		 * To counter-balance this effect, move this node's private
 		 * stats to the new node.
 		 */
-		if (max_node != -1 && p->numa_max_node != -1 && max_node != p->numa_max_node) {
+		if (sched_feat(MIGRATE_FAULT_STATS) && ideal_node != -1 && p->numa_max_node != -1 && ideal_node != p->numa_max_node) {
 			int idx_oldnode = p->numa_max_node*2 + 1;
-			int idx_newnode = max_node*2 + 1;
+			int idx_newnode = ideal_node*2 + 1;
 
 			p->numa_faults[idx_newnode] += p->numa_faults[idx_oldnode];
 			p->numa_faults[idx_oldnode] = 0;
 		}
-		sched_setnuma(p, max_node, shared);
+		sched_setnuma(p, ideal_node, shared);
 	} else {
 		/* node unchanged, back off: */
 		p->numa_scan_period = min(p->numa_scan_period * 2, sysctl_sched_numa_scan_period_max);
 	}
 
-	this_node = cpu_to_node(task_cpu(p));
+	this_cpu = task_cpu(p);
+	this_node = cpu_to_node(this_cpu);
 
-	if (max_node >= 0 && p->ideal_cpu >= 0 && max_node != this_node) {
+	if (ideal_node >= 0 && p->ideal_cpu >= 0 && p->ideal_cpu != this_cpu) {
 		struct rq *rq = cpu_rq(p->ideal_cpu);
 
 		rq->curr_buddy = p;
-		sched_rebalance_to(p->ideal_cpu, 0);
+		sched_rebalance_to(p->ideal_cpu, flip_tasks);
+		rq->curr_buddy = NULL;
 	}
 }
 
@@ -1317,7 +2213,7 @@ void task_numa_placement_work(struct callback_head *work)
  */
 void task_numa_scan_work(struct callback_head *work)
 {
-	long pages_total, pages_left, pages_changed;
+	long pages_total, pages_left, pages_changed, sum_pages_scanned;
 	unsigned long migrate, next_scan, now = jiffies;
 	unsigned long start0, start, end;
 	struct task_struct *p = current;
@@ -1331,6 +2227,13 @@ void task_numa_scan_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
+	p->numa_migrate_seq++;
+	if (sched_feat(NUMA_SETTLE) &&
+	    p->numa_migrate_seq < sysctl_sched_numa_settle_count) {
+		trace_printk("NUMA TICK: placement, return to let it settle, task %s:%d\n", p->comm, p->pid);
+		return;
+	}
+
 	/*
 	 * Enforce maximal scan/migration frequency..
 	 */
@@ -1350,37 +2253,69 @@ void task_numa_scan_work(struct callback_head *work)
 	if (!pages_total)
 		return;
 
-	pages_left	= pages_total;
+	sum_pages_scanned = 0;
+	pages_left = pages_total;
 
-	down_write(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, start);
 	if (!vma) {
 		ACCESS_ONCE(mm->numa_scan_seq)++;
-		end = 0;
-		vma = find_vma(mm, end);
+		start = end = 0;
+		vma = find_vma(mm, start);
 	}
+
 	for (; vma; vma = vma->vm_next) {
-		if (!vma_migratable(vma))
+		if (!vma_migratable(vma)) {
+			end = vma->vm_end;
+			continue;
+		}
+
+		/* Skip small VMAs. They are not likely to be of relevance */
+		if (((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) < HPAGE_PMD_NR) {
+			end = vma->vm_end;
 			continue;
+		}
 
 		do {
+			unsigned long pages_scanned;
+
 			start = max(end, vma->vm_start);
 			end = ALIGN(start + (pages_left << PAGE_SHIFT), HPAGE_SIZE);
 			end = min(end, vma->vm_end);
+			pages_scanned = (end - start) >> PAGE_SHIFT;
+
+			if (WARN_ON_ONCE(start >= end)) {
+				printk_once("vma->vm_start: %016lx\n", vma->vm_start);
+				printk_once("vma->vm_end:   %016lx\n", vma->vm_end);
+				continue;
+			}
+			if (WARN_ON_ONCE(start < vma->vm_start))
+				continue;
+			if (WARN_ON_ONCE(end > vma->vm_end))
+				continue;
+
 			pages_changed = change_prot_numa(vma, start, end);
 
-			WARN_ON_ONCE(pages_changed > pages_total);
-			BUG_ON(pages_changed < 0);
+			WARN_ON_ONCE(pages_changed > pages_total + HPAGE_SIZE/PAGE_SIZE);
+			WARN_ON_ONCE(pages_changed < 0);
+			WARN_ON_ONCE(pages_changed > pages_scanned);
 
 			pages_left -= pages_changed;
 			if (pages_left <= 0)
 				goto out;
-		} while (end != vma->vm_end);
+
+			sum_pages_scanned += pages_scanned;
+
+			/* Don't overscan: */
+			if (sum_pages_scanned >= 2*pages_total)
+				goto out;
+
+		} while (end < vma->vm_end);
 	}
 out:
 	mm->numa_scan_offset = end;
 
-	up_write(&mm->mmap_sem);
+	up_read(&mm->mmap_sem);
 }
 
 /*
@@ -1433,6 +2368,8 @@ static void task_tick_numa_scan(struct rq *rq, struct task_struct *curr)
 static void task_tick_numa_placement(struct rq *rq, struct task_struct *curr)
 {
 	struct callback_head *work = &curr->numa_placement_work;
+	unsigned long now_secs;
+	unsigned long jiffies_offset;
 	int seq;
 
 	if (work->next != work)
@@ -1444,10 +2381,26 @@ static void task_tick_numa_placement(struct rq *rq, struct task_struct *curr)
 	 */
 	seq = ACCESS_ONCE(curr->mm->numa_scan_seq);
 
-	if (curr->numa_scan_seq == seq)
+	/*
+	 * Smear out the NUMA placement ticks by CPU position.
+	 * We get called about once per jiffy so we can test
+	 * for precisely meeting the jiffies offset.
+	 */
+	jiffies_offset = (jiffies % num_online_cpus());
+	if (jiffies_offset != rq->cpu)
+		return;
+
+	/*
+	 * Recalculate placement at least once per second:
+	 */
+	now_secs = jiffies/HZ;
+
+	if ((curr->numa_scan_seq == seq) && (curr->numa_scan_ts_secs == now_secs))
 		return;
 
+	curr->numa_scan_ts_secs = now_secs;
 	curr->numa_scan_seq = seq;
+
 	task_work_add(curr, work, true);
 }
 
@@ -1457,7 +2410,7 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	 * We don't care about NUMA placement if we don't have memory
 	 * or are exiting:
 	 */
-	if (!curr->mm || (curr->flags & PF_EXITING))
+	if (!curr->mm || (curr->flags & PF_EXITING) || !curr->numa_faults)
 		return;
 
 	task_tick_numa_scan(rq, curr);
@@ -3815,6 +4768,10 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 #ifdef CONFIG_NUMA_BALANCING
+	/* We do NUMA balancing elsewhere: */
+	if (sched_feat(NUMA_BALANCE_ALL) && task_numa_shared(p) >= 0)
+		return prev_cpu;
+
 	if (sched_feat(WAKE_ON_IDEAL_CPU) && p->ideal_cpu >= 0)
 		return p->ideal_cpu;
 #endif
@@ -3893,6 +4850,9 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 unlock:
 	rcu_read_unlock();
 
+	if (sched_feat(NUMA_BALANCE_INTERNODE) && task_numa_shared(p) >= 0 && (cpu_to_node(prev_cpu) != cpu_to_node(new_cpu)))
+		return prev_cpu;
+
 	return new_cpu;
 }
 
@@ -4584,6 +5544,10 @@ try_migrate:
  */
 static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 {
+	/* We do NUMA balancing elsewhere: */
+	if (sched_feat(NUMA_BALANCE_ALL) && task_numa_shared(p) > 0 && env->failed <= env->sd->cache_nice_tries)
+		return false;
+
 	if (!can_migrate_pinned_task(p, env))
 		return false;
 
@@ -4600,6 +5564,7 @@ static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		int dst_node;
 
 		BUG_ON(env->dst_cpu < 0);
+		WARN_ON_ONCE(p->ideal_cpu < 0);
 
 		ideal_node = cpu_to_node(p->ideal_cpu);
 		dst_node = cpu_to_node(env->dst_cpu);
@@ -4643,6 +5608,12 @@ static int move_one_task(struct lb_env *env)
 		if (!can_migrate_task(p, env))
 			continue;
 
+		if (sched_feat(NUMA_BALANCE_ALL) && task_numa_shared(p) >= 0)
+			continue;
+
+		if (sched_feat(NUMA_BALANCE_INTERNODE) && task_numa_shared(p) >= 0 && (cpu_to_node(env->src_rq->cpu) != cpu_to_node(env->dst_cpu)))
+			continue;
+
 		move_task(p, env);
 
 		/*
@@ -4703,6 +5674,12 @@ static int move_tasks(struct lb_env *env)
 		if (!can_migrate_task(p, env))
 			goto next;
 
+		if (sched_feat(NUMA_BALANCE_ALL) && task_numa_shared(p) >= 0)
+			continue;
+
+		if (sched_feat(NUMA_BALANCE_INTERNODE) && task_numa_shared(p) >= 0 && (cpu_to_node(env->src_rq->cpu) != cpu_to_node(env->dst_cpu)))
+			goto next;
+
 		move_task(p, env);
 		pulled++;
 		env->imbalance -= load;
@@ -5074,6 +6051,9 @@ static bool can_do_numa_run(struct lb_env *env, struct sd_lb_stats *sds)
  */
 static int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
 {
+	if (!sched_feat(NUMA_LB))
+		return 0;
+
 	if (!sds->numa || !sds->numa_numa_running)
 		return 0;
 
@@ -5918,6 +6898,9 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		.iteration          = 0,
 	};
 
+	if (sched_feat(NUMA_BALANCE_ALL))
+		return 1;
+
 	cpumask_copy(cpus, cpu_active_mask);
 	max_lb_iterations = cpumask_weight(env.dst_grpmask);
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index c868a66..2529f05 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -63,9 +63,9 @@ SCHED_FEAT(NONTASK_POWER, true)
  */
 SCHED_FEAT(TTWU_QUEUE, true)
 
-SCHED_FEAT(FORCE_SD_OVERLAP, false)
-SCHED_FEAT(RT_RUNTIME_SHARE, true)
-SCHED_FEAT(LB_MIN, false)
+SCHED_FEAT(FORCE_SD_OVERLAP,		false)
+SCHED_FEAT(RT_RUNTIME_SHARE,		true)
+SCHED_FEAT(LB_MIN,			false)
 SCHED_FEAT(IDEAL_CPU,			true)
 SCHED_FEAT(IDEAL_CPU_THREAD_BIAS,	false)
 SCHED_FEAT(PUSH_PRIVATE_BUDDIES,	true)
@@ -74,8 +74,14 @@ SCHED_FEAT(WAKE_ON_IDEAL_CPU,		false)
 
 #ifdef CONFIG_NUMA_BALANCING
 /* Do the working set probing faults: */
-SCHED_FEAT(NUMA,             true)
-SCHED_FEAT(NUMA_FAULTS_UP,   false)
-SCHED_FEAT(NUMA_FAULTS_DOWN, false)
-SCHED_FEAT(NUMA_SETTLE,      true)
+SCHED_FEAT(NUMA,			true)
+SCHED_FEAT(NUMA_FAULTS_UP,		false)
+SCHED_FEAT(NUMA_FAULTS_DOWN,		false)
+SCHED_FEAT(NUMA_SETTLE,			false)
+SCHED_FEAT(NUMA_BALANCE_ALL,		false)
+SCHED_FEAT(NUMA_BALANCE_INTERNODE,		false)
+SCHED_FEAT(NUMA_LB,			false)
+SCHED_FEAT(NUMA_GROUP_LB_COMPRESS,	true)
+SCHED_FEAT(NUMA_GROUP_LB_SPREAD,	true)
+SCHED_FEAT(MIGRATE_FAULT_STATS,		false)
 #endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
