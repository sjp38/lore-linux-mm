Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 27CA36B00A7
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:18:19 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so8282694qab.15
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:18:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s9si12334732qas.179.2013.11.26.14.18.16
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 14:18:17 -0800 (PST)
From: riel@redhat.com
Subject: [RFC PATCH 2/4] track from which nodes NUMA faults are triggered
Date: Tue, 26 Nov 2013 17:03:26 -0500
Message-Id: <1385503408-30041-3-git-send-email-riel@redhat.com>
In-Reply-To: <1385503408-30041-1-git-send-email-riel@redhat.com>
References: <1385503408-30041-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, chegu_vinod@hp.com, peterz@infradead.org

From: Rik van Riel <riel@redhat.com>

Track which nodes NUMA faults are triggered from. This uses a similar
mechanism to what is used to track the memory involved in numa faults.

This is used, in the next patch, to build up a bitmap of which nodes
a workload is actively running on.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h | 10 ++++++++--
 kernel/sched/fair.c   | 30 +++++++++++++++++++++++-------
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9e4cb598..e4b00d8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1368,6 +1368,14 @@ struct task_struct {
 	unsigned long *numa_faults_buffer;
 
 	/*
+	 * Track the nodes where faults are incurred. This is not very
+	 * interesting on a per-task basis, but it help with smarter
+	 * numa memory placement for groups of processes.
+	 */
+	unsigned long *numa_faults_from;
+	unsigned long *numa_faults_from_buffer;
+
+	/*
 	 * numa_faults_locality tracks if faults recorded during the last
 	 * scan window were remote/local. The task scan period is adapted
 	 * based on the locality of the faults with different weights
@@ -1467,8 +1475,6 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
-
-extern unsigned int sysctl_numa_balancing_migrate_deferred;
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 410858e..89b5217 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -870,6 +870,7 @@ struct numa_group {
 
 	struct rcu_head rcu;
 	unsigned long total_faults;
+	unsigned long *faults_from;
 	unsigned long faults[0];
 };
 
@@ -1327,10 +1328,11 @@ static void task_numa_placement(struct task_struct *p)
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
-			long diff;
+			long diff, f_diff;
 
 			i = task_faults_idx(nid, priv);
 			diff = -p->numa_faults[i];
+			f_diff = -p->numa_faults_from[i];
 
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
@@ -1338,12 +1340,18 @@ static void task_numa_placement(struct task_struct *p)
 			fault_types[priv] += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
+			p->numa_faults_from[i] >>= 1;
+			p->numa_faults_from[i] += p->numa_faults_from_buffer[i];
+			p->numa_faults_from_buffer[i] = 0;
+
 			faults += p->numa_faults[i];
 			diff += p->numa_faults[i];
+			f_diff += p->numa_faults_from[i];
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
 				p->numa_group->faults[i] += diff;
+				p->numa_group->faults_from[i] += f_diff;
 				p->numa_group->total_faults += diff;
 				group_faults += p->numa_group->faults[i];
 			}
@@ -1412,7 +1420,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
-				    2*nr_node_ids*sizeof(unsigned long);
+				    4*nr_node_ids*sizeof(unsigned long);
 
 		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!grp)
@@ -1422,8 +1430,10 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
 		grp->gid = p->pid;
+		/* Second half of the array tracks where faults come from */
+		grp->faults_from = grp->faults + 2 * nr_node_ids;
 
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults[i];
 
 		grp->total_faults = p->total_numa_faults;
@@ -1482,7 +1492,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	double_lock(&my_grp->lock, &grp->lock);
 
-	for (i = 0; i < 2*nr_node_ids; i++) {
+	for (i = 0; i < 4*nr_node_ids; i++) {
 		my_grp->faults[i] -= p->numa_faults[i];
 		grp->faults[i] += p->numa_faults[i];
 	}
@@ -1509,7 +1519,7 @@ void task_numa_free(struct task_struct *p)
 
 	if (grp) {
 		spin_lock(&grp->lock);
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] -= p->numa_faults[i];
 		grp->total_faults -= p->total_numa_faults;
 
@@ -1522,6 +1532,8 @@ void task_numa_free(struct task_struct *p)
 
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
+	p->numa_faults_from = NULL;
+	p->numa_faults_from_buffer = NULL;
 	kfree(numa_faults);
 }
 
@@ -1532,6 +1544,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 {
 	struct task_struct *p = current;
 	bool migrated = flags & TNF_MIGRATED;
+	int this_node = task_node(current);
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1547,7 +1560,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
+		int size = sizeof(*p->numa_faults) * 4 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
@@ -1555,7 +1568,9 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 			return;
 
 		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
+		p->numa_faults_from = p->numa_faults + (2 * nr_node_ids);
+		p->numa_faults_buffer = p->numa_faults + (4 * nr_node_ids);
+		p->numa_faults_from_buffer = p->numa_faults + (6 * nr_node_ids);
 		p->total_numa_faults = 0;
 		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}
@@ -1585,6 +1600,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		p->numa_pages_migrated += pages;
 
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
+	p->numa_faults_from_buffer[task_faults_idx(this_node, priv)] += pages;
 	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
