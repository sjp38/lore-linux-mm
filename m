Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 78F8A6B0037
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:47:30 -0400 (EDT)
Date: Fri, 2 Aug 2013 18:47:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH -v3] sched, numa: Use {cpu, pid} to create task groups for
 shared faults
Message-ID: <20130802164715.GP27162@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130731150751.GA15144@twins.programming.kicks-ass.net>
 <51F93105.8020503@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F93105.8020503@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, riel@redhat.com


Here's the latest; it seems to not crash and appears to actually do as
advertised.

---
Subject: sched, numa: Use {cpu, pid} to create task groups for shared faults
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Jul 30 10:40:20 CEST 2013

A very simple/straight forward shared fault task grouping
implementation.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/sched.h |    3 
 kernel/sched/core.c   |    3 
 kernel/sched/fair.c   |  174 +++++++++++++++++++++++++++++++++++++++++++++++---
 kernel/sched/sched.h  |    5 -
 4 files changed, 171 insertions(+), 14 deletions(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1341,6 +1341,9 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
+	struct list_head numa_entry;
+	struct numa_group *numa_group;
+
 	/*
 	 * Exponential decaying average of faults on a per-node basis.
 	 * Scheduling placement decisions are made based on the these counts.
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1733,6 +1733,9 @@ static void __sched_fork(struct task_str
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
+
+	INIT_LIST_HEAD(&p->numa_entry);
+	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1149,6 +1149,17 @@ static void numa_migrate_preferred(struc
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
@@ -1157,6 +1168,7 @@ static void task_numa_placement(struct t
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
+
 	p->numa_scan_seq = seq;
 	p->numa_migrate_seq++;
 	p->numa_scan_period_max = task_scan_max(p);
@@ -1167,14 +1179,24 @@ static void task_numa_placement(struct t
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
@@ -1211,6 +1233,130 @@ static void task_numa_placement(struct t
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
+static void task_numa_group(struct task_struct *p, int cpu, int pid)
+{
+	struct numa_group *grp, *my_grp;
+	struct task_struct *tsk;
+	bool join = false;
+	int i;
+
+	if (unlikely(!p->numa_group)) {
+		unsigned int size = sizeof(struct numa_group) +
+			            2*nr_node_ids*sizeof(atomic_long_t);
+
+		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+		if (!grp)
+			return;
+
+		atomic_set(&grp->refcount, 1);
+		spin_lock_init(&grp->lock);
+		INIT_LIST_HEAD(&grp->task_list);
+
+		for (i = 0; i < 2*nr_node_ids; i++)
+			atomic_long_set(&grp->faults[i], p->numa_faults[i]);
+
+		list_add(&p->numa_entry, &grp->task_list);
+		grp->nr_tasks++;
+		rcu_assign_pointer(p->numa_group, grp);
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
+	join = true;
+
+unlock:
+	rcu_read_unlock();
+
+	if (!join)
+		return;
+
+	for (i = 0; i < 2*nr_node_ids; i++) {
+		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
+		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
+	}
+
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
+
+	put_numa_group(my_grp);
+}
+
+void task_numa_free(struct task_struct *p)
+{
+	struct numa_group *grp = p->numa_group;
+	int i;
+
+	kfree(p->numa_faults);
+
+	if (grp) {
+		for (i = 0; i < 2*nr_node_ids; i++)
+			atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
+
+		spin_lock(&grp->lock);
+		list_del(&p->numa_entry);
+		grp->nr_tasks--;
+		spin_unlock(&grp->lock);
+		rcu_assign_pointer(p->numa_group, NULL);
+		put_numa_group(grp);
+	}
+}
+
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
@@ -1226,21 +1372,12 @@ void task_numa_fault(int last_cpupid, in
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
 
@@ -1249,6 +1386,23 @@ void task_numa_fault(int last_cpupid, in
 	}
 
 	/*
+	 * First accesses are treated as private, otherwise consider accesses
+	 * to be private if the accessing pid has not changed
+	 */
+	if (unlikely(last_cpupid == (-1 & LAST_CPUPID_MASK))) {
+		priv = 1;
+	} else {
+		int cpu, pid;
+
+		cpu = cpupid_to_cpu(last_cpupid);
+		pid = cpupid_to_pid(last_cpupid);
+
+		priv = (pid == (p->pid & LAST__PID_MASK));
+		if (!priv)
+			task_numa_group(p, cpu, pid);
+	}
+
+	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
 	 * This is reset periodically in case of phase changes
 	 *
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -556,10 +556,7 @@ static inline u64 rq_clock_task(struct r
 #ifdef CONFIG_NUMA_BALANCING
 extern int migrate_task_to(struct task_struct *p, int cpu);
 extern int migrate_swap(struct task_struct *, struct task_struct *);
-static inline void task_numa_free(struct task_struct *p)
-{
-	kfree(p->numa_faults);
-}
+extern void task_numa_free(struct task_struct *p);
 #else /* CONFIG_NUMA_BALANCING */
 static inline void task_numa_free(struct task_struct *p)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
