Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 114306B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:37:24 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:36:47 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] numa,sched: use group fault statistics in numa placement
Message-ID: <20130805153647.7d6e58a2@annuminas.surriel.com>
In-Reply-To: <20130802165032.GQ27162@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<20130730113857.GR3008@twins.programming.kicks-ass.net>
	<20130731150751.GA15144@twins.programming.kicks-ass.net>
	<51F93105.8020503@hp.com>
	<20130802164715.GP27162@twins.programming.kicks-ass.net>
	<20130802165032.GQ27162@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Don Morris <don.morris@hp.com>, Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2 Aug 2013 18:50:32 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Subject: mm, numa: Do not group on RO pages

Using the fraction of the faults that happen on each node to
determine both the group weight and the task weight of each
node, and attempting to move the task to the node with the
highest score, seems to work fairly well.

Here are the specjbb scores with this patch, on top of your
task grouping patches:

                vanilla                 numasched7
Warehouses     
      1                40651            45657
      2                82897            88827
      3               116623            130644
      4               144512            171051
      5               176681            209915
      6               190471            247480
      7               204036            283966
      8               214466            318464
      9               223451            348657
     10               227439            380886
     11               226163            374822
     12               220857            370519
     13               215871            367582
     14               210965            361110

I suspect there may be further room for improvement, but it
may be time for this patch to go into Mel's tree, so others
will test it as well, helping us all learn what is broken
and how it can be improved...

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |   1 +
 kernel/sched/fair.c   | 109 +++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 91 insertions(+), 19 deletions(-)

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
index 6a06bef..2c9c1dd 100644
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
@@ -857,6 +869,51 @@ static inline unsigned long task_faults(struct task_struct *p, int nid)
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
+	unsigned long total_faults;
+
+	if (!p->numa_faults)
+		return 0;
+
+	total_faults = p->total_numa_faults;
+
+	if (!total_faults)
+		return 0;
+
+	return 1000 * task_faults(p, nid) / total_faults;
+}
+
+static inline unsigned long group_weight(struct task_struct *p, int nid)
+{
+	unsigned long total_faults;
+
+	if (!p->numa_group)
+		return 0;
+
+	total_faults = atomic_long_read(&p->numa_group->total_faults);
+
+	if (!total_faults)
+		return 0;
+
+	return 1200 * group_faults(p, nid) / total_faults;
+}
+
 /*
  * Create/Update p->mempolicy MPOL_INTERLEAVE to match p->numa_faults[].
  */
@@ -979,8 +1036,10 @@ static void task_numa_compare(struct task_numa_env *env, long imp)
 		cur = NULL;
 
 	if (cur) {
-		imp += task_faults(cur, env->src_nid) -
-		       task_faults(cur, env->dst_nid);
+		imp += task_weight(cur, env->src_nid) +
+		       group_weight(cur, env->src_nid) -
+		       task_weight(cur, env->dst_nid) -
+		       group_weight(cur, env->dst_nid);
 	}
 
 	trace_printk("compare[%d] task:%s/%d improvement: %ld\n",
@@ -1051,7 +1110,7 @@ static int task_numa_migrate(struct task_struct *p)
 		.best_cpu = -1
 	};
 	struct sched_domain *sd;
-	unsigned long faults;
+	unsigned long weight;
 	int nid, cpu, ret;
 
 	/*
@@ -1067,7 +1126,7 @@ static int task_numa_migrate(struct task_struct *p)
 	}
 	rcu_read_unlock();
 
-	faults = task_faults(p, env.src_nid);
+	weight = task_weight(p, env.src_nid) + group_weight(p, env.src_nid);
 	update_numa_stats(&env.src_stats, env.src_nid);
 
 	for_each_online_node(nid) {
@@ -1076,7 +1135,7 @@ static int task_numa_migrate(struct task_struct *p)
 		if (nid == env.src_nid)
 			continue;
 
-		imp = task_faults(p, nid) - faults;
+		imp = task_weight(p, nid) + group_weight(p, nid) - weight;
 		if (imp < 0)
 			continue;
 
@@ -1122,21 +1181,10 @@ static void numa_migrate_preferred(struct task_struct *p)
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
@@ -1148,7 +1196,7 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
-		unsigned long faults = 0;
+		unsigned long faults = 0, group_faults = 0;
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
@@ -1161,6 +1209,7 @@ static void task_numa_placement(struct task_struct *p)
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
 			p->numa_faults[i] += p->numa_faults_buffer[i];
+			p->total_numa_faults += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
 			diff += p->numa_faults[i];
@@ -1169,6 +1218,8 @@ static void task_numa_placement(struct task_struct *p)
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
 				atomic_long_add(diff, &p->numa_group->faults[i]);
+				atomic_long_add(diff, &p->numa_group->total_faults);
+				group_faults += atomic_long_read(&p->numa_group->faults[i]);
 			}
 		}
 
@@ -1176,11 +1227,29 @@ static void task_numa_placement(struct task_struct *p)
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
 
@@ -1242,6 +1311,7 @@ void task_numa_group(struct task_struct *p, int cpu, int pid)
 		atomic_set(&grp->refcount, 1);
 		spin_lock_init(&grp->lock);
 		INIT_LIST_HEAD(&grp->task_list);
+		atomic_long_set(&grp->total_faults, 0);
 
 		spin_lock(&p->numa_lock);
 		list_add(&p->numa_entry, &grp->task_list);
@@ -1336,6 +1406,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
 
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
