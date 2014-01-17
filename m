Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id C68556B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 16:16:02 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so3722086qae.41
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:16:02 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id x3si14125029qat.95.2014.01.17.13.16.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 13:16:02 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 2/7] numa,sched: track from which nodes NUMA faults are triggered
Date: Fri, 17 Jan 2014 16:12:04 -0500
Message-Id: <1389993129-28180-3-git-send-email-riel@redhat.com>
In-Reply-To: <1389993129-28180-1-git-send-email-riel@redhat.com>
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, chegu_vinod@hp.com, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

From: Rik van Riel <riel@redhat.com>

Track which nodes NUMA faults are triggered from, in other words
the CPUs on which the NUMA faults happened. This uses a similar
mechanism to what is used to track the memory involved in numa faults.

The next patches use this to build up a bitmap of which nodes a
workload is actively running on.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h | 10 ++++++++--
 kernel/sched/fair.c   | 30 +++++++++++++++++++++++-------
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 97efba4..a9f7f05 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1492,6 +1492,14 @@ struct task_struct {
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
@@ -1594,8 +1602,6 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
-
-extern unsigned int sysctl_numa_balancing_migrate_deferred;
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 41e2176..1945ddc 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -886,6 +886,7 @@ struct numa_group {
 
 	struct rcu_head rcu;
 	unsigned long total_faults;
+	unsigned long *faults_from;
 	unsigned long faults[0];
 };
 
@@ -1372,10 +1373,11 @@ static void task_numa_placement(struct task_struct *p)
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
-			long diff;
+			long diff, f_diff;
 
 			i = task_faults_idx(nid, priv);
 			diff = -p->numa_faults[i];
+			f_diff = -p->numa_faults_from[i];
 
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
@@ -1383,12 +1385,18 @@ static void task_numa_placement(struct task_struct *p)
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
@@ -1457,7 +1465,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
-				    2*nr_node_ids*sizeof(unsigned long);
+				    4*nr_node_ids*sizeof(unsigned long);
 
 		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!grp)
@@ -1467,8 +1475,10 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
 		grp->gid = p->pid;
+		/* Second half of the array tracks where faults come from */
+		grp->faults_from = grp->faults + 2 * nr_node_ids;
 
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults[i];
 
 		grp->total_faults = p->total_numa_faults;
@@ -1526,7 +1536,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	double_lock(&my_grp->lock, &grp->lock);
 
-	for (i = 0; i < 2*nr_node_ids; i++) {
+	for (i = 0; i < 4*nr_node_ids; i++) {
 		my_grp->faults[i] -= p->numa_faults[i];
 		grp->faults[i] += p->numa_faults[i];
 	}
@@ -1558,7 +1568,7 @@ void task_numa_free(struct task_struct *p)
 
 	if (grp) {
 		spin_lock(&grp->lock);
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] -= p->numa_faults[i];
 		grp->total_faults -= p->total_numa_faults;
 
@@ -1571,6 +1581,8 @@ void task_numa_free(struct task_struct *p)
 
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
+	p->numa_faults_from = NULL;
+	p->numa_faults_from_buffer = NULL;
 	kfree(numa_faults);
 }
 
@@ -1581,6 +1593,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 {
 	struct task_struct *p = current;
 	bool migrated = flags & TNF_MIGRATED;
+	int this_node = task_node(current);
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1596,7 +1609,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
+		int size = sizeof(*p->numa_faults) * 4 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
@@ -1604,7 +1617,9 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 			return;
 
 		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
+		p->numa_faults_from = p->numa_faults + (2 * nr_node_ids);
+		p->numa_faults_buffer = p->numa_faults + (4 * nr_node_ids);
+		p->numa_faults_from_buffer = p->numa_faults + (6 * nr_node_ids);
 		p->total_numa_faults = 0;
 		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}
@@ -1634,6 +1649,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		p->numa_pages_migrated += pages;
 
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
+	p->numa_faults_from_buffer[task_faults_idx(this_node, priv)] += pages;
 	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
