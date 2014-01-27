Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7CB6B003A
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:05:42 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so8914784qcx.23
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:05:42 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id t7si4195399qav.4.2014.01.27.14.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 14:05:41 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 2/9] rename p->numa_faults to numa_faults_memory
Date: Mon, 27 Jan 2014 17:03:41 -0500
Message-Id: <1390860228-21539-3-git-send-email-riel@redhat.com>
In-Reply-To: <1390860228-21539-1-git-send-email-riel@redhat.com>
References: <1390860228-21539-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

From: Rik van Riel <riel@redhat.com>

In order to get a more consistent naming scheme, making it clear
which fault statistics track memory locality, and which track
CPU locality, rename the memory fault statistics.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  8 ++++----
 kernel/sched/core.c   |  4 ++--
 kernel/sched/debug.c  |  6 +++---
 kernel/sched/fair.c   | 56 +++++++++++++++++++++++++--------------------------
 4 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d572d5b..144d509 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1469,15 +1469,15 @@ struct task_struct {
 	 * Scheduling placement decisions are made based on the these counts.
 	 * The values remain static for the duration of a PTE scan
 	 */
-	unsigned long *numa_faults;
+	unsigned long *numa_faults_memory;
 	unsigned long total_numa_faults;
 
 	/*
 	 * numa_faults_buffer records faults per node during the current
-	 * scan window. When the scan completes, the counts in numa_faults
-	 * decay and these values are copied.
+	 * scan window. When the scan completes, the counts in
+	 * numa_faults_memory decay and these values are copied.
 	 */
-	unsigned long *numa_faults_buffer;
+	unsigned long *numa_faults_buffer_memory;
 
 	/*
 	 * numa_faults_locality tracks if faults recorded during the last
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 75badda..b7c430e 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1744,8 +1744,8 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_work.next = &p->numa_work;
-	p->numa_faults = NULL;
-	p->numa_faults_buffer = NULL;
+	p->numa_faults_memory = NULL;
+	p->numa_faults_buffer_memory = NULL;
 
 	INIT_LIST_HEAD(&p->numa_entry);
 	p->numa_group = NULL;
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index dd52e7f..31b908d 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -533,15 +533,15 @@ static void sched_show_numa(struct task_struct *p, struct seq_file *m)
 			unsigned long nr_faults = -1;
 			int cpu_current, home_node;
 
-			if (p->numa_faults)
-				nr_faults = p->numa_faults[2*node + i];
+			if (p->numa_faults_memory)
+				nr_faults = p->numa_faults_memory[2*node + i];
 
 			cpu_current = !i ? (task_node(p) == node) :
 				(pol && node_isset(node, pol->v.nodes));
 
 			home_node = (p->numa_preferred_nid == node);
 
-			SEQ_printf(m, "numa_faults, %d, %d, %d, %d, %ld\n",
+			SEQ_printf(m, "numa_faults_memory, %d, %d, %d, %d, %ld\n",
 				i, node, cpu_current, home_node, nr_faults);
 		}
 	}
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7cdde91..3e616d7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -901,11 +901,11 @@ static inline int task_faults_idx(int nid, int priv)
 
 static inline unsigned long task_faults(struct task_struct *p, int nid)
 {
-	if (!p->numa_faults)
+	if (!p->numa_faults_memory)
 		return 0;
 
-	return p->numa_faults[task_faults_idx(nid, 0)] +
-		p->numa_faults[task_faults_idx(nid, 1)];
+	return p->numa_faults_memory[task_faults_idx(nid, 0)] +
+		p->numa_faults_memory[task_faults_idx(nid, 1)];
 }
 
 static inline unsigned long group_faults(struct task_struct *p, int nid)
@@ -927,7 +927,7 @@ static inline unsigned long task_weight(struct task_struct *p, int nid)
 {
 	unsigned long total_faults;
 
-	if (!p->numa_faults)
+	if (!p->numa_faults_memory)
 		return 0;
 
 	total_faults = p->total_numa_faults;
@@ -1255,7 +1255,7 @@ static int task_numa_migrate(struct task_struct *p)
 static void numa_migrate_preferred(struct task_struct *p)
 {
 	/* This task has no NUMA fault statistics yet */
-	if (unlikely(p->numa_preferred_nid == -1 || !p->numa_faults))
+	if (unlikely(p->numa_preferred_nid == -1 || !p->numa_faults_memory))
 		return;
 
 	/* Periodically retry migrating the task to the preferred node */
@@ -1371,16 +1371,16 @@ static void task_numa_placement(struct task_struct *p)
 			long diff;
 
 			i = task_faults_idx(nid, priv);
-			diff = -p->numa_faults[i];
+			diff = -p->numa_faults_memory[i];
 
 			/* Decay existing window, copy faults since last scan */
-			p->numa_faults[i] >>= 1;
-			p->numa_faults[i] += p->numa_faults_buffer[i];
-			fault_types[priv] += p->numa_faults_buffer[i];
-			p->numa_faults_buffer[i] = 0;
+			p->numa_faults_memory[i] >>= 1;
+			p->numa_faults_memory[i] += p->numa_faults_buffer_memory[i];
+			fault_types[priv] += p->numa_faults_buffer_memory[i];
+			p->numa_faults_buffer_memory[i] = 0;
 
-			faults += p->numa_faults[i];
-			diff += p->numa_faults[i];
+			faults += p->numa_faults_memory[i];
+			diff += p->numa_faults_memory[i];
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
@@ -1465,7 +1465,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		grp->gid = p->pid;
 
 		for (i = 0; i < 2*nr_node_ids; i++)
-			grp->faults[i] = p->numa_faults[i];
+			grp->faults[i] = p->numa_faults_memory[i];
 
 		grp->total_faults = p->total_numa_faults;
 
@@ -1523,8 +1523,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 	double_lock(&my_grp->lock, &grp->lock);
 
 	for (i = 0; i < 2*nr_node_ids; i++) {
-		my_grp->faults[i] -= p->numa_faults[i];
-		grp->faults[i] += p->numa_faults[i];
+		my_grp->faults[i] -= p->numa_faults_memory[i];
+		grp->faults[i] += p->numa_faults_memory[i];
 	}
 	my_grp->total_faults -= p->total_numa_faults;
 	grp->total_faults += p->total_numa_faults;
@@ -1550,12 +1550,12 @@ void task_numa_free(struct task_struct *p)
 {
 	struct numa_group *grp = p->numa_group;
 	int i;
-	void *numa_faults = p->numa_faults;
+	void *numa_faults = p->numa_faults_memory;
 
 	if (grp) {
 		spin_lock(&grp->lock);
 		for (i = 0; i < 2*nr_node_ids; i++)
-			grp->faults[i] -= p->numa_faults[i];
+			grp->faults[i] -= p->numa_faults_memory[i];
 		grp->total_faults -= p->total_numa_faults;
 
 		list_del(&p->numa_entry);
@@ -1565,8 +1565,8 @@ void task_numa_free(struct task_struct *p)
 		put_numa_group(grp);
 	}
 
-	p->numa_faults = NULL;
-	p->numa_faults_buffer = NULL;
+	p->numa_faults_memory = NULL;
+	p->numa_faults_buffer_memory = NULL;
 	kfree(numa_faults);
 }
 
@@ -1591,16 +1591,16 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		return;
 
 	/* Allocate buffer to track faults on a per-node basis */
-	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
+	if (unlikely(!p->numa_faults_memory)) {
+		int size = sizeof(*p->numa_faults_memory) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
-		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
-		if (!p->numa_faults)
+		p->numa_faults_memory = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
+		if (!p->numa_faults_memory)
 			return;
 
-		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
+		BUG_ON(p->numa_faults_buffer_memory);
+		p->numa_faults_buffer_memory = p->numa_faults_memory + (2 * nr_node_ids);
 		p->total_numa_faults = 0;
 		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}
@@ -1629,7 +1629,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	if (migrated)
 		p->numa_pages_migrated += pages;
 
-	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
+	p->numa_faults_buffer_memory[task_faults_idx(node, priv)] += pages;
 	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
@@ -4771,7 +4771,7 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 {
 	int src_nid, dst_nid;
 
-	if (!sched_feat(NUMA_FAVOUR_HIGHER) || !p->numa_faults ||
+	if (!sched_feat(NUMA_FAVOUR_HIGHER) || !p->numa_faults_memory ||
 	    !(env->sd->flags & SD_NUMA)) {
 		return false;
 	}
@@ -4802,7 +4802,7 @@ static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
 	if (!sched_feat(NUMA) || !sched_feat(NUMA_RESIST_LOWER))
 		return false;
 
-	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
+	if (!p->numa_faults_memory || !(env->sd->flags & SD_NUMA))
 		return false;
 
 	src_nid = cpu_to_node(env->src_cpu);
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
