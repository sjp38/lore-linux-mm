Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 589CD900010
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:14 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so2796077pab.3
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:14 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 20/63] sched: Select a preferred node with the most numa hinting faults
Date: Fri, 27 Sep 2013 14:27:05 +0100
Message-Id: <1380288468-5551-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
index dfba435..d6ec68a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1336,6 +1336,7 @@ struct task_struct {
 	struct callback_head numa_work;
 
 	unsigned long *numa_faults;
+	int numa_preferred_nid;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index dbc2de6..0235ab8 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1643,6 +1643,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
+	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 55ec7ad..f9bc867 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -879,7 +879,8 @@ static unsigned int task_scan_max(struct task_struct *p)
 
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq;
+	int seq, nid, max_nid = -1;
+	unsigned long max_faults = 0;
 
 	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
 		return;
@@ -889,7 +890,19 @@ static void task_numa_placement(struct task_struct *p)
 	p->numa_scan_seq = seq;
 	p->numa_scan_period_max = task_scan_max(p);
 
-	/* FIXME: Scheduling placement policy hints go here */
+	/* Find the node with the highest number of faults */
+	for_each_online_node(nid) {
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
