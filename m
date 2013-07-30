Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id CC6196B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 07:39:06 -0400 (EDT)
Date: Tue, 30 Jul 2013 13:38:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] sched, numa: Use {cpu, pid} to create task groups for shared
 faults
Message-ID: <20130730113857.GR3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


Subject: sched, numa: Use {cpu, pid} to create task groups for shared faults
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Jul 30 10:40:20 CEST 2013

A very simple/straight forward shared fault task grouping
implementation.

Concerns are that grouping on a single shared fault might be too
aggressive -- this only works because Mel is excluding DSOs for faults,
otherwise we'd have the world in a single group.

Future work could explore more complex means of picking groups. We
could for example track one group for the entire scan (using something
like PDM) and join it at the end of the scan if we deem it shared a
sufficient amount of memory.

Another avenue to explore is that to do with tasks where private faults
are predominant. Should we exclude them from the group or treat them as
secondary, creating a graded group that tries hardest to collate shared
tasks but also tries to move private tasks near when possible.

Also, the grouping information is completely unused, its up to future
patches to do this.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/sched.h |    4 +
 kernel/sched/core.c   |    4 +
 kernel/sched/fair.c   |  156 ++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 153 insertions(+), 11 deletions(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1338,6 +1338,10 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
+	spinlock_t numa_lock; /* for numa_entry / numa_group */
+	struct list_head numa_entry;
+	struct numa_group *numa_group;
+
 	/*
 	 * Exponential decaying average of faults on a per-node basis.
 	 * Scheduling placement decisions are made based on the these counts.
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1730,6 +1730,10 @@ static void __sched_fork(struct task_str
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
+
+	spin_lock_init(&p->numa_lock);
+	INIT_LIST_HEAD(&p->numa_entry);
+	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1160,6 +1160,17 @@ static void numa_migrate_preferred(struc
 	p->numa_migrate_retry = jiffies + HZ/10;
 }
 
+struct numa_group {
+	atomic_t refcount;
+
+	spinlock_t lock; /* nr_tasks, tasks */
+	int nr_tasks;
+	struct list_head task_list;
+
+	struct rcu_head rcu;
+	atomic_long_t faults[0];
+};
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -1168,6 +1179,7 @@ static void task_numa_placement(struct t
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
+
 	p->numa_scan_seq = seq;
 	p->numa_migrate_seq++;
 	p->numa_scan_period_max = task_scan_max(p);
@@ -1178,14 +1190,24 @@ static void task_numa_placement(struct t
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
+			long diff;
+
 			i = task_faults_idx(nid, priv);
 
+			diff = -p->numa_faults[i];
+
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
 			p->numa_faults[i] += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
+			diff += p->numa_faults[i];
 			faults += p->numa_faults[i];
+
+			if (p->numa_group) {
+				/* safe because we can only change our own group */
+				atomic_long_add(diff, &p->numa_group->faults[i]);
+			}
 		}
 
 		if (faults > max_faults) {
@@ -1222,13 +1244,117 @@ static void task_numa_placement(struct t
 	}
 }
 
+static inline int get_numa_group(struct numa_group *grp)
+{
+	return atomic_inc_not_zero(&grp->refcount);
+}
+
+static inline void put_numa_group(struct numa_group *grp)
+{
+	if (atomic_dec_and_test(&grp->refcount))
+		kfree_rcu(grp, rcu);
+}
+
+static void double_lock(spinlock_t *l1, spinlock_t *l2)
+{
+	if (l1 > l2)
+		swap(l1, l2);
+
+	spin_lock(l1);
+	spin_lock_nested(l2, SINGLE_DEPTH_NESTING);
+}
+
+void task_numa_group(struct task_struct *p, int cpu, int pid)
+{
+	struct task_struct *tsk;
+	struct numa_group *grp, *my_grp;
+	unsigned int size = sizeof(struct numa_group) +
+			    2*nr_node_ids*sizeof(atomic_long_t);
+	int i;
+
+	if (unlikely(!p->numa_group)) {
+		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+		if (!grp)
+			return;
+
+		atomic_set(&grp->refcount, 1);
+		spin_lock_init(&grp->lock);
+		INIT_LIST_HEAD(&grp->task_list);
+
+		spin_lock(&p->numa_lock);
+		list_add(&p->numa_entry, &grp->task_list);
+		grp->nr_tasks++;
+		rcu_assign_pointer(p->numa_group, grp);
+		spin_unlock(&p->numa_lock);
+	}
+
+	rcu_read_lock();
+	tsk = ACCESS_ONCE(cpu_rq(cpu)->curr);
+
+	if ((tsk->pid & LAST__PID_MASK) != pid)
+		goto unlock;
+
+	grp = rcu_dereference(tsk->numa_group);
+	if (!grp)
+		goto unlock;
+
+	my_grp = p->numa_group;
+	if (grp == my_grp)
+		goto unlock;
+
+	/*
+	 * Only join the other group if its bigger; if we're the bigger group,
+	 * the other task will join us.
+	 */
+	if (my_grp->nr_tasks > grp->nr_tasks)
+	    	goto unlock;
+
+	/*
+	 * Tie-break on the grp address.
+	 */
+	if (my_grp->nr_tasks == grp->nr_tasks && my_grp > grp)
+		goto unlock;
+
+	if (!get_numa_group(grp))
+		goto unlock;
+
+	rcu_read_unlock();
+
+	/* join with @grp */
+
+	for (i = 0; i < 2*nr_node_ids; i++) {
+		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
+		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
+	}
+
+	spin_lock(&p->numa_lock);
+	double_lock(&my_grp->lock, &grp->lock);
+
+	list_move(&p->numa_entry, &grp->task_list);
+	my_grp->nr_tasks--;
+	grp->nr_tasks++;
+
+	spin_unlock(&my_grp->lock);
+	spin_unlock(&grp->lock);
+
+	rcu_assign_pointer(p->numa_group, grp);
+	spin_unlock(&p->numa_lock);
+
+	put_numa_group(my_grp);
+	return;
+
+
+unlock:
+	rcu_read_unlock();
+}
+
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
 void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
-	int priv;
+	int priv, cpu, pid;
 
 	if (!sched_feat_numa(NUMA))
 		return;
@@ -1237,21 +1363,12 @@ void task_numa_fault(int last_cpupid, in
 	if (!p->mm)
 		return;
 
-	/*
-	 * First accesses are treated as private, otherwise consider accesses
-	 * to be private if the accessing pid has not changed
-	 */
-	if (!cpupid_pid_unset(last_cpupid))
-		priv = ((p->pid & LAST__PID_MASK) == cpupid_to_pid(last_cpupid));
-	else
-		priv = 1;
-
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
 		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
-		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
+		p->numa_faults = kzalloc(size * 2, GFP_KERNEL | __GFP_NOWARN);
 		if (!p->numa_faults)
 			return;
 
@@ -1260,6 +1377,23 @@ void task_numa_fault(int last_cpupid, in
 	}
 
 	/*
+	 * First accesses are treated as private, otherwise consider accesses
+	 * to be private if the accessing pid has not changed
+	 */
+	if (unlikely(last_cpupid == (-1 & LAST_CPUPID_MASK))) {
+		cpu = raw_smp_processor_id();
+		pid = p->pid & LAST__PID_MASK;
+	} else {
+		cpu = cpupid_to_cpu(last_cpupid);
+		pid = cpupid_to_pid(last_cpupid);
+	}
+
+	priv = (pid == (p->pid & LAST__PID_MASK));
+
+	if (!priv)
+		task_numa_group(p, cpu, pid);
+
+	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
 	 * This is reset periodically in case of phase changes
 	 *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
