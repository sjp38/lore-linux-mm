Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 2579F6B0038
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:30 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:49:29 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 87FCD6E803C
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:22 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nR3d18284734
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:27 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nQ4F011465
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:27 -0400
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 05/10] sched: Extend idle balancing to look for consolidation of tasks
Date: Tue, 30 Jul 2013 13:18:20 +0530
Message-Id: <1375170505-5967-6-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

If the cpu is idle even after a regular load balance, then
try to move a task from another node to this node, such that
node locality improves.

While choosing a task to pull, choose a task/address-space from the
currently running set of tasks on this node. Make sure that the chosen
address-space has a numa affinity to the current node. Choose another
node that has the least number of tasks that belong to this address
space.

This change might induce a slight imbalance but there are enough checks
to make sure that the imbalance is within limits. This slight imbalance
that is created can act as a catalyst/opportunity for the other node to
pull its node affine tasks.

TODO: current checks that look at nr_running should be modified to
look at task loads instead.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |  156 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 156 insertions(+), 0 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index debb75a..43af8d9 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -5609,6 +5609,77 @@ void update_max_interval(void)
 	max_load_balance_interval = HZ*num_online_cpus()/10;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static struct task_struct *
+select_task_to_pull(struct mm_struct *this_mm, int this_cpu, int nid)
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
+				return rq->curr;
+		}
+	}
+	return NULL;
+}
+
+static int
+select_node_to_pull(struct mm_struct *mm, unsigned int nr_running, int nid)
+{
+	atomic_t *weights = mm->numa_weights;
+	int least_running, running, other_nr_running, other_running;
+	int least_node = -1;
+	int other_node, cpu;
+
+	least_running = atomic_read(&weights[nid]);
+	running = least_running;
+	for_each_online_node(other_node) {
+		/* our own node? skip */
+		if (other_node == nid)
+			continue;
+
+		other_running = atomic_read(&weights[other_node]);
+		/* no interesting thread in this node */
+		if (other_running == 0)
+			continue;
+
+		/* other_node has more numa affinity? Dont move. */
+		if (other_running > least_running)
+			continue;
+
+		other_nr_running = 0;
+		for_each_cpu(cpu, cpumask_of_node(other_node))
+			other_nr_running += cpu_rq(cpu)->nr_running;
+
+		/* other_node is already lightly loaded? */
+		if (nr_running > other_nr_running)
+			continue;
+
+		/*
+		 * If the other node has significant proportion of load of
+		 * the process in question. Or relatively has more affinity
+		 * to this address space than the current node, then dont
+		 * move
+		 */
+		if (other_nr_running < 2 * other_running)
+			continue;
+
+		if (nr_running * other_running >= other_nr_running * running)
+			continue;
+
+		least_running = other_running;
+		least_node = other_node;
+	}
+	return least_node;
+}
+#endif
+
 /*
  * It checks each scheduling domain to see if it is due to be balanced,
  * and initiates a balancing operation if so.
@@ -5674,6 +5745,91 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 		if (!balance)
 			break;
 	}
+#ifdef CONFIG_NUMA_BALANCING
+	if (!rq->nr_running) {
+		struct mm_struct *prev_mm, *mm;
+		struct task_struct *p = NULL;
+		unsigned int nr_running = 0;
+		int curr_running, total_running;
+		int other_node, nid, dcpu;
+
+		nid = cpu_to_node(cpu);
+		prev_mm = NULL;
+
+		for_each_cpu(dcpu, cpumask_of_node(nid))
+			nr_running += cpu_rq(dcpu)->nr_running;
+
+		for_each_cpu(dcpu, cpumask_of_node(nid)) {
+			struct rq *this_rq;
+
+			this_rq = cpu_rq(dcpu);
+			mm = this_rq->curr->mm;
+			if (!mm || !mm->numa_weights)
+				continue;
+
+			/*
+			 * Dont retry if the previous and the current
+			 * requests share the same address space
+			 */
+			if (mm == prev_mm)
+				continue;
+
+			curr_running = atomic_read(&mm->numa_weights[nid]);
+			total_running = atomic_read(&mm->numa_weights[nr_node_ids]);
+
+			if (curr_running < 2 || total_running < 2)
+				continue;
+
+			prev_mm = mm;
+
+			/* all threads have consolidated */
+			if (curr_running == total_running)
+				continue;
+
+			/*
+			 * in-significant proportion of load running on
+			 * this node?
+			 */
+			if (total_running > curr_running * (nr_node_ids + 1)) {
+				if (nr_running > 2 * curr_running)
+					continue;
+			}
+
+			other_node = select_node_to_pull(mm, nr_running, nid);
+			if (other_node == -1)
+				continue;
+			p = select_task_to_pull(mm, cpu, other_node);
+			if (p)
+				break;
+		}
+		if (p) {
+			struct rq *this_rq;
+			unsigned long flags;
+			int active_balance;
+
+			this_rq = task_rq(p);
+			active_balance = 0;
+
+			/*
+			 * ->active_balance synchronizes accesses to
+			 * ->active_balance_work.  Once set, it's cleared
+			 * only after active load balance is finished.
+			 */
+			raw_spin_lock_irqsave(&this_rq->lock, flags);
+			if (task_rq(p) == this_rq) {
+				if (!this_rq->active_balance) {
+					this_rq->active_balance = 1;
+					this_rq->push_cpu = cpu;
+					active_balance = 1;
+				}
+			}
+			raw_spin_unlock_irqrestore(&this_rq->lock, flags);
+
+			if (active_balance)
+				active_load_balance(this_rq);
+		}
+	}
+#endif
 	rcu_read_unlock();
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
