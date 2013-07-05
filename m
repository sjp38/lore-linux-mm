Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F0E436B0062
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 19:09:17 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/15] sched: Account for the number of preferred tasks running on a node when selecting a preferred node
Date: Sat,  6 Jul 2013 00:09:01 +0100
Message-Id: <1373065742-9753-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1373065742-9753-1-git-send-email-mgorman@suse.de>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It is preferred that tasks always run local to their memory but it is
not optimal if that node is compute overloaded and failing to get
access to a CPU. This would compete with the load balancer trying to
move tasks off and NUMA balancing moving it back.

Ultimately, it will be required that the compute load be calculated
of each node and minimise that as well as minimising the number of
remote accesses until the optimal balance point is reached. Begin
this process by simply accounting for the number of tasks that are
running on their preferred node. When deciding what node to place
a task on, do not place a task on a node that has more preferred
placement tasks than there are CPUs.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c  | 34 ++++++++++++++++++++++++++++++++++
 kernel/sched/fair.c  | 49 +++++++++++++++++++++++++++++++++++++++++++------
 kernel/sched/sched.h |  5 +++++
 3 files changed, 82 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 02db92a..13b9068 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6112,6 +6112,40 @@ static struct sched_domain_topology_level default_topology[] = {
 
 static struct sched_domain_topology_level *sched_domain_topology = default_topology;
 
+#ifdef CONFIG_NUMA_BALANCING
+void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu)
+{
+	struct rq *rq;
+	unsigned long flags;
+	bool on_rq, running;
+
+	/*
+	 * Dequeue task before updating preferred_nid so
+	 * rq->nr_preferred_running is accurate
+	 */
+	rq = task_rq_lock(p, &flags);
+	on_rq = p->on_rq;
+	running = task_current(rq, p);
+
+	if (on_rq)
+		dequeue_task(rq, p, 0);
+	if (running)
+		p->sched_class->put_prev_task(rq, p);
+
+	/* Update the preferred nid and migrate task if possible */
+	p->numa_preferred_nid = nid;
+	p->numa_migrate_seq = 0;
+
+	/* Requeue task if necessary */
+	if (running)
+		p->sched_class->set_curr_task(rq);
+	if (on_rq)
+		enqueue_task(rq, p, 0);
+	task_rq_unlock(rq, p, &flags);
+}
+
+#endif
+
 #ifdef CONFIG_NUMA
 
 static int sched_domains_numa_levels;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5933e24..c303ba6 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -777,6 +777,18 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * Scheduling class queueing methods:
  */
 
+static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	rq->nr_preferred_running +=
+			(cpu_to_node(task_cpu(p)) == p->numa_preferred_nid);
+}
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+	rq->nr_preferred_running -=
+			(cpu_to_node(task_cpu(p)) == p->numa_preferred_nid);
+}
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * Approximate time to scan a full NUMA task in ms. The task scan period is
@@ -880,6 +892,21 @@ static inline int task_faults_idx(int nid, int priv)
 	return 2 * nid + priv;
 }
 
+/* Returns true if the given node is compute overloaded */
+static bool sched_numa_overloaded(int nid)
+{
+	int nr_cpus = 0;
+	int nr_preferred = 0;
+	int i;
+
+	for_each_cpu(i, cpumask_of_node(nid)) {
+		nr_cpus++;
+		nr_preferred += cpu_rq(i)->nr_preferred_running;
+	}
+
+	return nr_preferred >= nr_cpus << 1;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = 0;
@@ -908,7 +935,7 @@ static void task_numa_placement(struct task_struct *p)
 
 		/* Find maximum private faults */
 		faults = p->numa_faults[task_faults_idx(nid, 1)];
-		if (faults > max_faults) {
+		if (faults > max_faults && !sched_numa_overloaded(nid)) {
 			max_faults = faults;
 			max_nid = nid;
 		}
@@ -934,9 +961,7 @@ static void task_numa_placement(struct task_struct *p)
 							     max_nid);
 		}
 
-		/* Update the preferred nid and migrate task if possible */
-		p->numa_preferred_nid = max_nid;
-		p->numa_migrate_seq = 0;
+		sched_setnuma(p, max_nid, preferred_cpu);
 		migrate_task_to(p, preferred_cpu);
 
 		/*
@@ -1165,6 +1190,14 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 {
 }
+
+static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+}
+
+static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 static void
@@ -1174,8 +1207,10 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
+		account_numa_enqueue(rq_of(cfs_rq), task_of(se));
 		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
+	}
 #endif
 	cfs_rq->nr_running++;
 }
@@ -1186,8 +1221,10 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
+		account_numa_dequeue(rq_of(cfs_rq), task_of(se));
 		list_del_init(&se->group_node);
+	}
 	cfs_rq->nr_running--;
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 795346d..1d7c0fb 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -433,6 +433,10 @@ struct rq {
 
 	struct list_head cfs_tasks;
 
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long nr_preferred_running;
+#endif
+
 	u64 rt_avg;
 	u64 age_stamp;
 	u64 idle_stamp;
@@ -504,6 +508,7 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
 #ifdef CONFIG_NUMA_BALANCING
+extern void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu);
 extern int migrate_task_to(struct task_struct *p, int cpu);
 static inline void task_numa_free(struct task_struct *p)
 {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
