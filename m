Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id C20906B0034
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:20:28 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/18] sched: Select a preferred node with the most numa hinting faults
Date: Mon, 15 Jul 2013 16:20:07 +0100
Message-Id: <1373901620-2021-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch selects a preferred node for a task to run on based on the
NUMA hinting faults. This information is later used to migrate tasks
towards the node during balancing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  1 +
 kernel/sched/core.c   |  1 +
 kernel/sched/fair.c   | 17 +++++++++++++++--
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 72861b4..ba46a64 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1507,6 +1507,7 @@ struct task_struct {
 	struct callback_head numa_work;
 
 	unsigned long *numa_faults;
+	int numa_preferred_nid;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index f332ec0..ed4e785 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1593,6 +1593,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
+	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 904fd6f..731ee9e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -793,7 +793,8 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq;
+	int seq, nid, max_nid = -1;
+	unsigned long max_faults = 0;
 
 	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
 		return;
@@ -802,7 +803,19 @@ static void task_numa_placement(struct task_struct *p)
 		return;
 	p->numa_scan_seq = seq;
 
-	/* FIXME: Scheduling placement policy hints go here */
+	/* Find the node with the highest number of faults */
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		unsigned long faults = p->numa_faults[nid];
+		p->numa_faults[nid] >>= 1;
+		if (faults > max_faults) {
+			max_faults = faults;
+			max_nid = nid;
+		}
+	}
+
+	/* Update the tasks preferred node if necessary */
+	if (max_faults && max_nid != p->numa_preferred_nid)
+		p->numa_preferred_nid = max_nid;
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
