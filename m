Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A33B66B003B
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:53 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:49:52 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D5CCC19D8041
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:38 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nomA349016
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:50 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nnhl015841
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:50 -0600
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 08/10] sched: Prevent a task from migrating immediately after an active balance
Date: Tue, 30 Jul 2013 13:18:23 +0530
Message-Id: <1375170505-5967-9-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Once a task has been carefully chosen to be migrated to a destination
node from a source node, try to avoid some other cpus moving this task
away from the destinagtion node.

If not, tasks might end up being in a ping-pong; one cpu pulling it
because of numa affinity, the other cpu pulling it for the slight
imbalance created because of previous migration (instead of actually
trying to pull a task that might lead to more consolidation)

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/sched.h |    1 +
 kernel/sched/core.c   |    1 +
 kernel/sched/fair.c   |    9 +++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a77c3cd..ba188f1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1506,6 +1506,7 @@ struct task_struct {
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
+	int migrate_seq;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e792312..453d989 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1594,6 +1594,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_work.next = &p->numa_work;
+	p->migrate_seq = 0;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e04703e..a99aebc 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1014,6 +1014,7 @@ static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
 	struct rq *rq = rq_of(cfs_rq);
 	int curnode = cpu_to_node(cpu_of(rq));
 
+	p->migrate_seq = 0;
 	if (mm && mm->numa_weights) {
 		atomic_dec(&mm->numa_weights[curnode]);
 		atomic_dec(&mm->numa_weights[nr_node_ids]);
@@ -4037,6 +4038,13 @@ static bool preferred_node(struct task_struct *p, struct lb_env *env)
 	if (!(env->sd->flags & SD_NUMA))
 		return false;
 
+	if (env->iterations) {
+		if (!p->migrate_seq)
+			return true;
+
+		p->migrate_seq--;
+		return false;
+	}
 	return (can_numa_migrate_task(p, env->dst_rq, env->src_rq) == 1);
 }
 #else
@@ -4063,6 +4071,7 @@ static int move_one_task(struct lb_env *env)
 		if (p->on_rq && task_cpu(p) == env->src_rq->cpu) {
 			move_task(p, env);
 			schedstat_inc(env->sd, lb_gained[env->idle]);
+			p->migrate_seq = 3;
 			return 1;
 		}
 		return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
