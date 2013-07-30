Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 185E66B003C
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:50:02 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:50:01 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4E0D538C8027
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:57 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nwU6197128
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:58 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nuCO015788
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 04:49:57 -0300
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 09/10] sched: Choose a runqueue that has lesser local affinity tasks
Date: Tue, 30 Jul 2013 13:18:24 +0530
Message-Id: <1375170505-5967-10-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

While migrating tasks to a different node, choosing the busiest runqueue
may not always be the right choice. The busiest runqueue might have
tasks that are already consolidated. Choosing such a runqueue might
actually lead to more performance impact.

Alternatively choose a runqueue that has less local numa affine tasks,
i.e, tasks that benefit if run on a node other than their current node.
The load balancer would then pitchin to move load from the busiest
runqueue to the runqueue from where tasks for cross node migration were
picked. So the load would end up being better consolidated.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/sched.h |    2 +
 kernel/sched/fair.c   |   82 +++++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/sched.h  |    1 +
 3 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ba188f1..c5d0a13 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1507,6 +1507,8 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 	int migrate_seq;
+	bool pinned_task;
+	bool local_task;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index a99aebc..e749650 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -805,6 +805,36 @@ static void task_numa_placement(struct task_struct *p)
 	/* FIXME: Scheduling placement policy hints go here */
 }
 
+static void update_local_task_count(struct task_struct *p)
+{
+	struct rq *rq = task_rq(p);
+	int curnode = cpu_to_node(cpu_of(rq));
+	int cur_numa_weight = 0;
+	int total_numa_weight = 0;
+
+	if (!p->pinned_task) {
+		if (p->mm && p->mm->numa_weights) {
+			cur_numa_weight = atomic_read(&p->mm->numa_weights[curnode]);
+			total_numa_weight = atomic_read(&p->mm->numa_weights[nr_node_ids]);
+		}
+
+		/*
+		 * Account tasks that are neither pinned nor have numa affinity as
+		 * non local tasks.
+		 */
+		if (p->local_task != (cur_numa_weight * nr_node_ids > total_numa_weight)) {
+			if (!p->local_task) {
+				rq->non_local_task_count--;
+				p->local_task = true;
+			} else {
+				rq->non_local_task_count++;
+				p->local_task = false;
+			}
+
+		}
+	}
+}
+
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
@@ -826,6 +856,9 @@ void task_numa_fault(int node, int pages, bool migrated)
 			p->numa_scan_period + jiffies_to_msecs(10));
 
 	task_numa_placement(p);
+
+	/* Should this be moved to update_curr()? */
+	update_local_task_count(p);
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
@@ -996,16 +1029,31 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	}
 }
 
+static void add_non_local_task_count(struct rq *rq, struct task_struct *p,
+		int value)
+{
+	if (p->pinned_task || p->local_task)
+		return;
+	else
+		rq->non_local_task_count += value;
+}
+
 static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
 {
 	struct mm_struct *mm = p->mm;
 	struct rq *rq = rq_of(cfs_rq);
 	int curnode = cpu_to_node(cpu_of(rq));
+	int cur_numa_weight = 0;
+	int total_numa_weight = 0;
 
 	if (mm && mm->numa_weights) {
-		atomic_read(&mm->numa_weights[curnode]);
-		atomic_read(&mm->numa_weights[nr_node_ids]);
+		cur_numa_weight = atomic_inc_return(&mm->numa_weights[curnode]);
+		total_numa_weight = atomic_inc_return(&mm->numa_weights[nr_node_ids]);
 	}
+
+	p->pinned_task = (p->nr_cpus_allowed == 1);
+	p->local_task = (cur_numa_weight * nr_node_ids > total_numa_weight);
+	add_non_local_task_count(rq, p, 1);
 }
 
 static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
@@ -1019,6 +1067,10 @@ static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
 		atomic_dec(&mm->numa_weights[curnode]);
 		atomic_dec(&mm->numa_weights[nr_node_ids]);
 	}
+
+	add_non_local_task_count(rq, p, -1);
+	p->pinned_task = false;
+	p->local_task = false;
 }
 #else
 static void task_tick_numa(struct rq *rq, struct task_struct *curr)
@@ -5046,6 +5098,27 @@ find_busiest_group(struct lb_env *env, int *balance)
 	return NULL;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static struct rq *find_numa_queue(struct lb_env *env,
+				struct sched_group *group, struct rq *busy_rq)
+{
+	struct rq *rq;
+	int i;
+
+	for_each_cpu(i, sched_group_cpus(group)) {
+		if (!cpumask_test_cpu(i, env->cpus))
+			continue;
+
+		rq = cpu_rq(i);
+		if (rq->nr_running > 1) {
+			if (rq->non_local_task_count > busy_rq->non_local_task_count)
+				busy_rq = rq;
+		}
+	}
+	return busy_rq;
+}
+#endif
+
 /*
  * find_busiest_queue - find the busiest runqueue among the cpus in group.
  */
@@ -5187,8 +5260,11 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 	if (busiest->nr_running > 1) {
 #ifdef CONFIG_NUMA_BALANCING
 		if (sd->flags & SD_NUMA) {
-			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu))
+			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu)) {
 				env.iterations = 0;
+				busiest = find_numa_queue(&env, group, busiest);
+			}
+
 		}
 #endif
 		/*
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 9f60d74..5e620b7 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -486,6 +486,7 @@ struct rq {
 	struct sched_avg avg;
 #ifdef CONFIG_NUMA_BALANCING
 	struct task_struct *push_task;
+	unsigned int non_local_task_count;
 #endif
 };
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
