Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3A9B56B0044
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/13] sched: Account for the number of preferred tasks running on a node when selecting a preferred node
Date: Wed,  3 Jul 2013 15:21:40 +0100
Message-Id: <1372861300-9973-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
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
 kernel/sched/fair.c  | 45 ++++++++++++++++++++++++++++++++++++++++++---
 kernel/sched/sched.h |  4 ++++
 2 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3c796b0..9ffdff3 100644
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
@@ -865,6 +877,21 @@ static inline int task_faults_idx(int nid, int priv)
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
@@ -892,7 +919,7 @@ static void task_numa_placement(struct task_struct *p)
 
 		/* Find maximum private faults */
 		faults = p->numa_faults[task_faults_idx(nid, 1)];
-		if (faults > max_faults) {
+		if (faults > max_faults && !sched_numa_overloaded(nid)) {
 			max_faults = faults;
 			max_nid = nid;
 		}
@@ -1144,6 +1171,14 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
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
@@ -1153,8 +1188,10 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
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
@@ -1165,8 +1202,10 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
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
index 64c37a3..f05b31b 100644
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
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
