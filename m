Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 138726B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 18:37:16 -0400 (EDT)
Date: Thu, 1 Aug 2013 18:36:46 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH -v2] numa,sched: use group fault statistics in numa
 placement
Message-ID: <20130801183646.37b04171@annuminas.surriel.com>
In-Reply-To: <20130730113857.GR3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<20130730113857.GR3008@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 30 Jul 2013 13:38:57 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> 
> Subject: sched, numa: Use {cpu, pid} to create task groups for shared faults
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue Jul 30 10:40:20 CEST 2013
> 
> A very simple/straight forward shared fault task grouping
> implementation.

Here is another (untested) version of task placement on top of
your task grouping. Better send it to you now, rather than on
your friday evening :)

The algorithm is loosely based on Andrea's placement algorithm,
but not as strict because I am not entirely confident that the
task grouping code works right yet...

It also has no "fall back to a better node than the current one" 
code yet, for the case where we fail to migrate to the best node,
but that should be a separate patch anyway.


Subject: [PATCH,RFC] numa,sched: use group fault statistics in numa placement

This version uses the fraction of faults on a particular node for
both task and group, to figure out the best node to place a task.

I wish I had benchmark numbers to report, but our timezones just
don't seem to work out that way. Enjoy at your own peril :)

I will be testing these tomorrow.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |  1 +
 kernel/sched/fair.c   | 94 +++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 77 insertions(+), 18 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9e7fcfe..5e175ae 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1355,6 +1355,7 @@ struct task_struct {
 	 * The values remain static for the duration of a PTE scan
 	 */
 	unsigned long *numa_faults;
+	unsigned long total_numa_faults;
 
 	/*
 	 * numa_faults_buffer records faults per node during the current
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6a06bef..3ef4d45 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -844,6 +844,18 @@ static unsigned int task_scan_max(struct task_struct *p)
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
+struct numa_group {
+	atomic_t refcount;
+
+	spinlock_t lock; /* nr_tasks, tasks */
+	int nr_tasks;
+	struct list_head task_list;
+
+	struct rcu_head rcu;
+	atomic_long_t total_faults;
+	atomic_long_t faults[0];
+};
+
 static inline int task_faults_idx(int nid, int priv)
 {
 	return 2 * nid + priv;
@@ -857,6 +869,38 @@ static inline unsigned long task_faults(struct task_struct *p, int nid)
 	return p->numa_faults[2*nid] + p->numa_faults[2*nid+1];
 }
 
+static inline unsigned long group_faults(struct task_struct *p, int nid)
+{
+	if (!p->numa_group)
+		return 0;
+
+	return atomic_long_read(&p->numa_group->faults[2*nid]) +
+	       atomic_long_read(&p->numa_group->faults[2*nid+1]);
+}
+
+/*
+ * These return the fraction of accesses done by a particular task, or
+ * task group, on a particular numa node.  The group weight is given a
+ * larger multiplier, in order to group tasks together that are almost
+ * evenly spread out between numa nodes.
+ */
+static inline unsigned long task_weight(struct task_struct *p, int nid)
+{
+	if (!p->numa_faults)
+		return 0;
+
+	return 1000 * task_faults(p, nid) / p->total_numa_faults;
+}
+
+static inline unsigned long group_weight(struct task_struct *p, int nid)
+{
+	if (!p->numa_group)
+		return 0;
+
+	return 1200 * group_faults(p, nid) /
+			atomic_long_read(&p->numa_group->total_faults);
+}
+
 /*
  * Create/Update p->mempolicy MPOL_INTERLEAVE to match p->numa_faults[].
  */
@@ -979,8 +1023,10 @@ static void task_numa_compare(struct task_numa_env *env, long imp)
 		cur = NULL;
 
 	if (cur) {
-		imp += task_faults(cur, env->src_nid) -
-		       task_faults(cur, env->dst_nid);
+		imp += task_faults(cur, env->src_nid) +
+		       group_faults(cur, env->src_nid) -
+		       task_faults(cur, env->dst_nid) -
+		       group_faults(cur, env->dst_nid);
 	}
 
 	trace_printk("compare[%d] task:%s/%d improvement: %ld\n",
@@ -1067,7 +1113,7 @@ static int task_numa_migrate(struct task_struct *p)
 	}
 	rcu_read_unlock();
 
-	faults = task_faults(p, env.src_nid);
+	faults = task_faults(p, env.src_nid) + group_faults(p, env.src_nid);
 	update_numa_stats(&env.src_stats, env.src_nid);
 
 	for_each_online_node(nid) {
@@ -1076,7 +1122,7 @@ static int task_numa_migrate(struct task_struct *p)
 		if (nid == env.src_nid)
 			continue;
 
-		imp = task_faults(p, nid) - faults;
+		imp = task_faults(p, nid) + group_faults(p, nid) - faults;
 		if (imp < 0)
 			continue;
 
@@ -1122,21 +1168,10 @@ static void numa_migrate_preferred(struct task_struct *p)
 	p->numa_migrate_retry = jiffies + HZ/10;
 }
 
-struct numa_group {
-	atomic_t refcount;
-
-	spinlock_t lock; /* nr_tasks, tasks */
-	int nr_tasks;
-	struct list_head task_list;
-
-	struct rcu_head rcu;
-	atomic_long_t faults[0];
-};
-
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq, nid, max_nid = -1;
-	unsigned long max_faults = 0;
+	int seq, nid, max_nid = -1, max_group_nid = -1;
+	unsigned long max_faults = 0, max_group_faults = 0;
 
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
@@ -1148,7 +1183,7 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
-		unsigned long faults = 0;
+		unsigned long faults = 0, group_faults = 0;
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
@@ -1161,6 +1196,7 @@ static void task_numa_placement(struct task_struct *p)
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
 			p->numa_faults[i] += p->numa_faults_buffer[i];
+			p->total_numa_faults += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
 			diff += p->numa_faults[i];
@@ -1169,6 +1205,8 @@ static void task_numa_placement(struct task_struct *p)
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
 				atomic_long_add(diff, &p->numa_group->faults[i]);
+				atomic_long_add(diff, &p->numa_group->total_faults);
+				group_faults += atomic_long_read(&p->numa_group->faults[i]);
 			}
 		}
 
@@ -1176,11 +1214,29 @@ static void task_numa_placement(struct task_struct *p)
 			max_faults = faults;
 			max_nid = nid;
 		}
+
+		if (group_faults > max_group_faults) {
+			max_group_faults = group_faults;
+			max_group_nid = nid;
+		}
 	}
 
 	if (sched_feat(NUMA_INTERLEAVE))
 		task_numa_mempol(p, max_faults);
 
+	/*
+	 * Should we stay on our own, or move in with the group?
+	 * If the task's memory accesses are concentrated on one node, go
+	 * to (more likely, stay on) that node. If the group's accesses
+	 * are more concentrated than the task's accesses, join the group.
+	 *
+	 *  max_group_faults     max_faults
+	 * ------------------ > ------------
+	 * total_group_faults   total_faults
+	 */
+	if (group_weight(p, max_group_nid) > task_weight(p, max_nid))
+		max_nid = max_group_nid;
+
 	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 
@@ -1242,6 +1298,7 @@ void task_numa_group(struct task_struct *p, int cpu, int pid)
 		atomic_set(&grp->refcount, 1);
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
+		atomic_long_set(&grp->total_faults, 0);
 
 		spin_lock(&p->numa_lock);
 		list_add(&p->numa_entry, &grp->task_list);
@@ -1336,6 +1393,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
 
 		BUG_ON(p->numa_faults_buffer);
 		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
+		p->total_numa_faults = 0;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
