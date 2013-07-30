Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1C8AA6B003A
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:38 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:49:37 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 91A7E19D8043
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:23 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nZZ3155888
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nYN5015142
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:35 -0600
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 06/10] sched: Limit migrations from a node
Date: Tue, 30 Jul 2013 13:18:21 +0530
Message-Id: <1375170505-5967-7-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

While tasks are being moved from one node to another, run-queue's look
at nodes that have least numa affinity. However this can lead to more
requests to pull tasks from a single node than the available non-local
tasks on that node.

Add a counter that limits the number of simultaneous
migrations. With this counter, if a source node (that acts as a node with
least numa affinity for a address-space) has enough requests to
relinquish  tasks, then we choose a node with the next least number of
affinity threads for a address-space.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 fs/exec.c                |    1 +
 include/linux/mm_types.h |    1 +
 kernel/fork.c            |    1 +
 kernel/sched/fair.c      |    9 +++++++++
 4 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index b086e9e..9ce5cab 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -835,6 +835,7 @@ static int exec_mmap(struct mm_struct *mm)
 	arch_pick_mmap_layout(mm);
 #ifdef CONFIG_NUMA_BALANCING
 	mm->numa_weights = kzalloc(sizeof(atomic_t) * (nr_node_ids + 1), GFP_KERNEL);
+	mm->limit_migrations = kzalloc(sizeof(atomic_t) * nr_node_ids, GFP_KERNEL);
 	atomic_inc(&mm->numa_weights[cpu_to_node(task_cpu(tsk))]);
 	atomic_inc(&mm->numa_weights[nr_node_ids]);
 #endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45d02df..4b0ba71 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -436,6 +436,7 @@ struct mm_struct {
 	 */
 	int first_nid;
 	atomic_t *numa_weights;
+	atomic_t *limit_migrations;
 #endif
 	struct uprobes_state uprobes_state;
 };
diff --git a/kernel/fork.c b/kernel/fork.c
index 21421bd..2b55676 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -847,6 +847,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_NUMA_BALANCING
 	mm->first_nid = NUMA_PTE_SCAN_INIT;
 	mm->numa_weights = kzalloc(sizeof(atomic_t) * (nr_node_ids + 1), GFP_KERNEL);
+	mm->limit_migrations = kzalloc(sizeof(atomic_t) * nr_node_ids, GFP_KERNEL);
 #endif
 	return mm;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 43af8d9..17027e0 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -5673,6 +5673,12 @@ select_node_to_pull(struct mm_struct *mm, unsigned int nr_running, int nid)
 		if (nr_running * other_running >= other_nr_running * running)
 			continue;
 
+		if (!atomic_add_unless(&mm->limit_migrations[other_node], 1, other_running))
+			continue;
+
+		if (least_node != -1)
+			atomic_dec(&mm->limit_migrations[least_node]);
+
 		least_running = other_running;
 		least_node = other_node;
 	}
@@ -5801,6 +5807,7 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 			p = select_task_to_pull(mm, cpu, other_node);
 			if (p)
 				break;
+			atomic_dec(&mm->limit_migrations[other_node]);
 		}
 		if (p) {
 			struct rq *this_rq;
@@ -5827,6 +5834,8 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 
 			if (active_balance)
 				active_load_balance(this_rq);
+
+			atomic_dec(&mm->limit_migrations[other_node]);
 		}
 	}
 #endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
