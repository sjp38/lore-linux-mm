Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 657C29C003B
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:42 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so6849292pbc.23
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:42 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 62/63] sched: numa: use unsigned longs for numa group fault stats
Date: Mon,  7 Oct 2013 11:29:40 +0100
Message-Id: <1381141781-10992-63-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

As Peter says "If you're going to hold locks you can also do away with all
that atomic_long_*() nonsense". Lock aquisition moved slightly to protect
the updates.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 49 ++++++++++++++++++++-----------------------------
 1 file changed, 20 insertions(+), 29 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9e2271b..f45dd4c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -916,8 +916,8 @@ struct numa_group {
 	struct list_head task_list;
 
 	struct rcu_head rcu;
-	atomic_long_t total_faults;
-	atomic_long_t faults[0];
+	unsigned long total_faults;
+	unsigned long faults[0];
 };
 
 pid_t task_numa_group_id(struct task_struct *p)
@@ -944,8 +944,7 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
 	if (!p->numa_group)
 		return 0;
 
-	return atomic_long_read(&p->numa_group->faults[2*nid]) +
-	       atomic_long_read(&p->numa_group->faults[2*nid+1]);
+	return p->numa_group->faults[2*nid] + p->numa_group->faults[2*nid+1];
 }
 
 /*
@@ -971,17 +970,10 @@ static inline unsigned long task_weight(struct task_struct *p, int nid)
 
 static inline unsigned long group_weight(struct task_struct *p, int nid)
 {
-	unsigned long total_faults;
-
-	if (!p->numa_group)
-		return 0;
-
-	total_faults = atomic_long_read(&p->numa_group->total_faults);
-
-	if (!total_faults)
+	if (!p->numa_group || !p->numa_group->total_faults)
 		return 0;
 
-	return 1000 * group_faults(p, nid) / total_faults;
+	return 1000 * group_faults(p, nid) / p->numa_group->total_faults;
 }
 
 static unsigned long weighted_cpuload(const int cpu);
@@ -1397,9 +1389,9 @@ static void task_numa_placement(struct task_struct *p)
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
-				atomic_long_add(diff, &p->numa_group->faults[i]);
-				atomic_long_add(diff, &p->numa_group->total_faults);
-				group_faults += atomic_long_read(&p->numa_group->faults[i]);
+				p->numa_group->faults[i] += diff;
+				p->numa_group->total_faults += diff;
+				group_faults += p->numa_group->faults[i];
 			}
 		}
 
@@ -1475,7 +1467,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	if (unlikely(!p->numa_group)) {
 		unsigned int size = sizeof(struct numa_group) +
-				    2*nr_node_ids*sizeof(atomic_long_t);
+				    2*nr_node_ids*sizeof(unsigned long);
 
 		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!grp)
@@ -1487,9 +1479,9 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		grp->gid = p->pid;
 
 		for (i = 0; i < 2*nr_node_ids; i++)
-			atomic_long_set(&grp->faults[i], p->numa_faults[i]);
+			grp->faults[i] = p->numa_faults[i];
 
-		atomic_long_set(&grp->total_faults, p->total_numa_faults);
+		grp->total_faults = p->total_numa_faults;
 
 		list_add(&p->numa_entry, &grp->task_list);
 		grp->nr_tasks++;
@@ -1543,14 +1535,14 @@ unlock:
 	if (!join)
 		return;
 
+	double_lock(&my_grp->lock, &grp->lock);
+
 	for (i = 0; i < 2*nr_node_ids; i++) {
-		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
-		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
+		my_grp->faults[i] -= p->numa_faults[i];
+		grp->faults[i] += p->numa_faults[i];
 	}
-	atomic_long_sub(p->total_numa_faults, &my_grp->total_faults);
-	atomic_long_add(p->total_numa_faults, &grp->total_faults);
-
-	double_lock(&my_grp->lock, &grp->lock);
+	my_grp->total_faults -= p->total_numa_faults;
+	grp->total_faults += p->total_numa_faults;
 
 	list_move(&p->numa_entry, &grp->task_list);
 	my_grp->nr_tasks--;
@@ -1571,12 +1563,11 @@ void task_numa_free(struct task_struct *p)
 	void *numa_faults = p->numa_faults;
 
 	if (grp) {
+		spin_lock(&grp->lock);
 		for (i = 0; i < 2*nr_node_ids; i++)
-			atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
-
-		atomic_long_sub(p->total_numa_faults, &grp->total_faults);
+			grp->faults[i] -= p->numa_faults[i];
+		grp->total_faults -= p->total_numa_faults;
 
-		spin_lock(&grp->lock);
 		list_del(&p->numa_entry);
 		grp->nr_tasks--;
 		spin_unlock(&grp->lock);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
