Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E5FE1900013
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:23 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so2598442pdj.17
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:23 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 30/63] sched: Do not migrate memory immediately after switching node
Date: Fri, 27 Sep 2013 14:27:15 +0100
Message-Id: <1380288468-5551-31-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

The load balancer can move tasks between nodes and does not take NUMA
locality into account. With automatic NUMA balancing this may result in the
tasks working set being migrated to the new node. However, as the fault
buffer will still store faults from the old node the schduler may decide to
reset the preferred node and migrate the task back resulting in more
migrations.

The ideal would be that the scheduler did not migrate tasks with a heavy
memory footprint but this may result nodes being overloaded. We could
also discard the fault information on task migration but this would still
cause all the tasks working set to be migrated. This patch simply avoids
migrating the memory for a short time after a task is migrated.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c |  2 +-
 kernel/sched/fair.c | 18 ++++++++++++++++--
 mm/mempolicy.c      | 12 ++++++++++++
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e94509d..374da2b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1641,7 +1641,7 @@ static void __sched_fork(struct task_struct *p)
 
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
-	p->numa_migrate_seq = 0;
+	p->numa_migrate_seq = 1;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 891105c..f136057 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -884,7 +884,7 @@ static unsigned int task_scan_max(struct task_struct *p)
  * the preferred node but still allow the scheduler to move the task again if
  * the nodes CPUs are overloaded.
  */
-unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
+unsigned int sysctl_numa_balancing_settle_count __read_mostly = 4;
 
 static inline int task_faults_idx(int nid, int priv)
 {
@@ -980,7 +980,7 @@ static void task_numa_placement(struct task_struct *p)
 
 		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
-		p->numa_migrate_seq = 0;
+		p->numa_migrate_seq = 1;
 		migrate_task_to(p, preferred_cpu);
 	}
 }
@@ -4074,6 +4074,20 @@ static void move_task(struct task_struct *p, struct lb_env *env)
 	set_task_cpu(p, env->dst_cpu);
 	activate_task(env->dst_rq, p, 0);
 	check_preempt_curr(env->dst_rq, p, 0);
+#ifdef CONFIG_NUMA_BALANCING
+	if (p->numa_preferred_nid != -1) {
+		int src_nid = cpu_to_node(env->src_cpu);
+		int dst_nid = cpu_to_node(env->dst_cpu);
+
+		/*
+		 * If the load balancer has moved the task then limit
+		 * migrations from taking place in the short term in
+		 * case this is a short-lived migration.
+		 */
+		if (src_nid != dst_nid && dst_nid != p->numa_preferred_nid)
+			p->numa_migrate_seq = 0;
+	}
+#endif
 }
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8e2a364..adc93b2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2322,6 +2322,18 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
 		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != polnid)
 			goto out;
+
+#ifdef CONFIG_NUMA_BALANCING
+		/*
+		 * If the scheduler has just moved us away from our
+		 * preferred node, do not bother migrating pages yet.
+		 * This way a short and temporary process migration will
+		 * not cause excessive memory migration.
+		 */
+		if (polnid != current->numa_preferred_nid &&
+				!current->numa_migrate_seq)
+			goto out;
+#endif
 	}
 
 	if (curnid != polnid)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
