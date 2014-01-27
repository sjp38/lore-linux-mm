Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 31A026B003A
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:05:46 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so9069437qcy.12
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:05:46 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id k93si9719377qgf.5.2014.01.27.14.05.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 14:05:45 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 3/9] numa,sched: track from which nodes NUMA faults are triggered
Date: Mon, 27 Jan 2014 17:03:42 -0500
Message-Id: <1390860228-21539-4-git-send-email-riel@redhat.com>
In-Reply-To: <1390860228-21539-1-git-send-email-riel@redhat.com>
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

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
Acked-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  9 +++++++--
 kernel/sched/fair.c   | 30 +++++++++++++++++++++++-------
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 144d509..5fb0cfb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1480,6 +1480,13 @@ struct task_struct {
 	unsigned long *numa_faults_buffer_memory;
 
 	/*
+	 * Track the nodes the process was running on when a NUMA hinting
+	 * fault was incurred.
+	 */
+	unsigned long *numa_faults_cpu;
+	unsigned long *numa_faults_buffer_cpu;
+
+	/*
 	 * numa_faults_locality tracks if faults recorded during the last
 	 * scan window were remote/local. The task scan period is adapted
 	 * based on the locality of the faults with different weights
@@ -1582,8 +1589,6 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
 extern void set_numabalancing_state(bool enabled);
 extern void task_numa_free(struct task_struct *p);
-
-extern unsigned int sysctl_numa_balancing_migrate_deferred;
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   int flags)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3e616d7..4841aaf 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -886,6 +886,7 @@ struct numa_group {
 
 	struct rcu_head rcu;
 	unsigned long total_faults;
+	unsigned long *faults_cpu;
 	unsigned long faults[0];
 };
 
@@ -1368,10 +1369,11 @@ static void task_numa_placement(struct task_struct *p)
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
-			long diff;
+			long diff, f_diff;
 
 			i = task_faults_idx(nid, priv);
 			diff = -p->numa_faults_memory[i];
+			f_diff = -p->numa_faults_cpu[i];
 
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults_memory[i] >>= 1;
@@ -1379,12 +1381,18 @@ static void task_numa_placement(struct task_struct *p)
 			fault_types[priv] += p->numa_faults_buffer_memory[i];
 			p->numa_faults_buffer_memory[i] = 0;
 
+			p->numa_faults_cpu[i] >>= 1;
+			p->numa_faults_cpu[i] += p->numa_faults_buffer_cpu[i];
+			p->numa_faults_buffer_cpu[i] = 0;
+
 			faults += p->numa_faults_memory[i];
 			diff += p->numa_faults_memory[i];
+			f_diff += p->numa_faults_cpu[i];
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
 				p->numa_group->faults[i] += diff;
+				p->numa_group->faults_cpu[i] += f_diff;
 				p->numa_group->total_faults += diff;
 				group_faults += p->numa_group->faults[i];
 			}
@@ -1453,7 +1461,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
-				    2*nr_node_ids*sizeof(unsigned long);
+				    4*nr_node_ids*sizeof(unsigned long);
 
 		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!grp)
@@ -1463,8 +1471,10 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
 		grp->gid = p->pid;
+		/* Second half of the array tracks nids where faults happen */
+		grp->faults_cpu = grp->faults + 2 * nr_node_ids;
 
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults_memory[i];
 
 		grp->total_faults = p->total_numa_faults;
@@ -1522,7 +1532,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	double_lock(&my_grp->lock, &grp->lock);
 
-	for (i = 0; i < 2*nr_node_ids; i++) {
+	for (i = 0; i < 4*nr_node_ids; i++) {
 		my_grp->faults[i] -= p->numa_faults_memory[i];
 		grp->faults[i] += p->numa_faults_memory[i];
 	}
@@ -1554,7 +1564,7 @@ void task_numa_free(struct task_struct *p)
 
 	if (grp) {
 		spin_lock(&grp->lock);
-		for (i = 0; i < 2*nr_node_ids; i++)
+		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] -= p->numa_faults_memory[i];
 		grp->total_faults -= p->total_numa_faults;
 
@@ -1567,6 +1577,8 @@ void task_numa_free(struct task_struct *p)
 
 	p->numa_faults_memory = NULL;
 	p->numa_faults_buffer_memory = NULL;
+	p->numa_faults_cpu= NULL;
+	p->numa_faults_buffer_cpu = NULL;
 	kfree(numa_faults);
 }
 
@@ -1577,6 +1589,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 {
 	struct task_struct *p = current;
 	bool migrated = flags & TNF_MIGRATED;
+	int this_node = task_node(current);
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1592,7 +1605,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults_memory)) {
-		int size = sizeof(*p->numa_faults_memory) * 2 * nr_node_ids;
+		int size = sizeof(*p->numa_faults_memory) * 4 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults_memory = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
@@ -1600,7 +1613,9 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 			return;
 
 		BUG_ON(p->numa_faults_buffer_memory);
-		p->numa_faults_buffer_memory = p->numa_faults_memory + (2 * nr_node_ids);
+		p->numa_faults_cpu = p->numa_faults_memory + (2 * nr_node_ids);
+		p->numa_faults_buffer_memory = p->numa_faults_memory + (4 * nr_node_ids);
+		p->numa_faults_buffer_cpu = p->numa_faults_memory + (6 * nr_node_ids);
 		p->total_numa_faults = 0;
 		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}
@@ -1630,6 +1645,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		p->numa_pages_migrated += pages;
 
 	p->numa_faults_buffer_memory[task_faults_idx(node, priv)] += pages;
+	p->numa_faults_buffer_cpu[task_faults_idx(this_node, priv)] += pages;
 	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
