Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 349786B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:48:57 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:48:55 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id F25F06E803A
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:48:46 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7mqaE37552172
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:48:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7mpS5013382
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 04:48:51 -0300
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 01/10] sched: Introduce per node numa weights
Date: Tue, 30 Jul 2013 13:18:16 +0530
Message-Id: <1375170505-5967-2-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Load balancer spreads the load evenly for fairness and for maintaining
balance across different domains. However where possible related tasks
could be scheduled in the same domain (esp at node domains) to allow tasks
to have more local accesses. This consolidation can be done without
affecting fairness and leaving the domains balanced

To better consolidate the loads, account weights per-mm per-node. These
stats are used in later patches to select more appropriate tasks during
load balance.

TODO: Modify to capture and use the actual task weights rather than task
counts

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 fs/exec.c                |    5 +++++
 include/linux/mm_types.h |    1 +
 kernel/fork.c            |   10 +++++++---
 kernel/sched/fair.c      |   34 ++++++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index a96a488..b086e9e 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -833,6 +833,11 @@ static int exec_mmap(struct mm_struct *mm)
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
+#ifdef CONFIG_NUMA_BALANCING
+	mm->numa_weights = kzalloc(sizeof(atomic_t) * (nr_node_ids + 1), GFP_KERNEL);
+	atomic_inc(&mm->numa_weights[cpu_to_node(task_cpu(tsk))]);
+	atomic_inc(&mm->numa_weights[nr_node_ids]);
+#endif
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..45d02df 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -435,6 +435,7 @@ struct mm_struct {
 	 * a different node than Make PTE Scan Go Now.
 	 */
 	int first_nid;
+	atomic_t *numa_weights;
 #endif
 	struct uprobes_state uprobes_state;
 };
diff --git a/kernel/fork.c b/kernel/fork.c
index 1766d32..21421bd 100644
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
+	mm->numa_weights = kzalloc(sizeof(atomic_t) * (nr_node_ids + 1), GFP_KERNEL);
+#endif
 	return mm;
 
 free_pt:
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7a33e59..8a2b5aa 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -995,10 +995,40 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 		}
 	}
 }
+
+static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+	struct mm_struct *mm = p->mm;
+	struct rq *rq = rq_of(cfs_rq);
+	int curnode = cpu_to_node(cpu_of(rq));
+
+	if (mm && mm->numa_weights) {
+		atomic_read(&mm->numa_weights[curnode]);
+		atomic_read(&mm->numa_weights[nr_node_ids]);
+	}
+}
+
+static void account_numa_dequeue(struct cfs_rq *cfs_rq, struct task_struct *p)
+{
+	struct mm_struct *mm = p->mm;
+	struct rq *rq = rq_of(cfs_rq);
+	int curnode = cpu_to_node(cpu_of(rq));
+
+	if (mm && mm->numa_weights) {
+		atomic_dec(&mm->numa_weights[curnode]);
+		atomic_dec(&mm->numa_weights[nr_node_ids]);
+	}
+}
 #else
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
@@ -1713,6 +1743,8 @@ enqueue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 	if (se != cfs_rq->curr)
 		__enqueue_entity(cfs_rq, se);
 	se->on_rq = 1;
+	if (entity_is_task(se))
+		account_numa_enqueue(cfs_rq, task_of(se));
 
 	if (cfs_rq->nr_running == 1) {
 		list_add_leaf_cfs_rq(cfs_rq);
@@ -1810,6 +1842,8 @@ dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 
 	update_min_vruntime(cfs_rq);
 	update_cfs_shares(cfs_rq);
+	if (entity_is_task(se))
+		account_numa_dequeue(cfs_rq, task_of(se));
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
