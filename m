Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id F17086B003C
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:06:32 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so8317227qae.10
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:06:32 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id j4si8371553qao.104.2014.01.27.14.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 14:06:11 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 9/9] numa,sched: turn some magic numbers into defines
Date: Mon, 27 Jan 2014 17:03:48 -0500
Message-Id: <1390860228-21539-10-git-send-email-riel@redhat.com>
In-Reply-To: <1390860228-21539-1-git-send-email-riel@redhat.com>
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

From: Rik van Riel <riel@redhat.com>

Cleanup suggested by Mel Gorman. Now the code contains some more
hints on what statistics go where.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 54408e4..c4001c4 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -896,6 +896,15 @@ struct numa_group {
 	unsigned long faults[0];
 };
 
+/* Shared or private faults. */
+#define NR_NUMA_HINT_FAULT_TYPES 2
+
+/* Memory and CPU locality */
+#define NR_NUMA_HINT_FAULT_STATS (NR_NUMA_HINT_FAULT_TYPES * 2)
+
+/* Averaged statistics, and temporary buffers. */
+#define NR_NUMA_HINT_FAULT_BUCKETS (NR_NUMA_HINT_FAULT_STATS * 2)
+
 pid_t task_numa_group_id(struct task_struct *p)
 {
 	return p->numa_group ? p->numa_group->gid : 0;
@@ -903,7 +912,7 @@ pid_t task_numa_group_id(struct task_struct *p)
 
 static inline int task_faults_idx(int nid, int priv)
 {
-	return 2 * nid + priv;
+	return NR_NUMA_HINT_FAULT_TYPES * nid + priv;
 }
 
 static inline unsigned long task_faults(struct task_struct *p, int nid)
@@ -1509,7 +1518,7 @@ static void task_numa_placement(struct task_struct *p)
 		unsigned long faults = 0, group_faults = 0;
 		int priv, i;
 
-		for (priv = 0; priv < 2; priv++) {
+		for (priv = 0; priv < NR_NUMA_HINT_FAULT_TYPES; priv++) {
 			long diff, f_diff, f_weight;
 
 			i = task_faults_idx(nid, priv);
@@ -1620,11 +1629,12 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		INIT_LIST_HEAD(&grp->task_list);
 		grp->gid = p->pid;
 		/* Second half of the array tracks nids where faults happen */
-		grp->faults_cpu = grp->faults + 2 * nr_node_ids;
+		grp->faults_cpu = grp->faults + NR_NUMA_HINT_FAULT_TYPES *
+						nr_node_ids;
 
 		node_set(task_node(current), grp->active_nodes);
 
-		for (i = 0; i < 4*nr_node_ids; i++)
+		for (i = 0; i < NR_NUMA_HINT_FAULT_STATS * nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults_memory[i];
 
 		grp->total_faults = p->total_numa_faults;
@@ -1682,7 +1692,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 
 	double_lock(&my_grp->lock, &grp->lock);
 
-	for (i = 0; i < 4*nr_node_ids; i++) {
+	for (i = 0; i < NR_NUMA_HINT_FAULT_STATS * nr_node_ids; i++) {
 		my_grp->faults[i] -= p->numa_faults_memory[i];
 		grp->faults[i] += p->numa_faults_memory[i];
 	}
@@ -1714,7 +1724,7 @@ void task_numa_free(struct task_struct *p)
 
 	if (grp) {
 		spin_lock(&grp->lock);
-		for (i = 0; i < 4*nr_node_ids; i++)
+		for (i = 0; i < NR_NUMA_HINT_FAULT_STATS * nr_node_ids; i++)
 			grp->faults[i] -= p->numa_faults_memory[i];
 		grp->total_faults -= p->total_numa_faults;
 
@@ -1755,14 +1765,20 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults_memory)) {
-		int size = sizeof(*p->numa_faults_memory) * 4 * nr_node_ids;
+		int size = sizeof(*p->numa_faults_memory) *
+			   NR_NUMA_HINT_FAULT_BUCKETS * nr_node_ids;
 
-		/* numa_faults and numa_faults_buffer share the allocation */
-		p->numa_faults_memory = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
+		p->numa_faults_memory = kzalloc(size, GFP_KERNEL|__GFP_NOWARN);
 		if (!p->numa_faults_memory)
 			return;
 
 		BUG_ON(p->numa_faults_buffer_memory);
+		/*
+		 * The averaged statistics, shared & private, memory & cpu,
+		 * occupy the first half of the array. The second half of the
+		 * array is for current counters, which are averaged into the
+		 * first set by task_numa_placement.
+		 */
 		p->numa_faults_cpu = p->numa_faults_memory + (2 * nr_node_ids);
 		p->numa_faults_buffer_memory = p->numa_faults_memory + (4 * nr_node_ids);
 		p->numa_faults_buffer_cpu = p->numa_faults_memory + (6 * nr_node_ids);
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
