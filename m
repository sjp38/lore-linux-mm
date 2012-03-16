Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 8C6F36B00FA
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:12 -0400 (EDT)
Message-Id: <20120316144241.154053094@chello.nl>
Date: Fri, 16 Mar 2012 15:40:44 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 16/26] sched, numa: Abstract the numa_entity
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-foo-7.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

In order to prepare the NUMA balancer for non-process entities, add
further abstraction to the thing.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_types.h |    5 +-
 kernel/sched/numa.c      |   85 +++++++++++++++++++++++++++++------------------
 2 files changed, 57 insertions(+), 33 deletions(-)
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -287,8 +287,9 @@ struct mm_rss_stat {
 
 struct numa_entity {
 #ifdef CONFIG_NUMA
-	int		 node;		/* home node */
-	struct list_head numa_entry;	/* balance list */
+	int			node;		/* home node */
+	struct list_head	numa_entry;	/* balance list */
+	const struct numa_ops	*nops;
 #endif
 };
 
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -7,6 +7,17 @@
 
 static const int numa_balance_interval = 2 * HZ; /* 2 seconds */
 
+struct numa_ops {
+	unsigned long	(*mem_load)(struct numa_entity *ne);
+	unsigned long	(*cpu_load)(struct numa_entity *ne);
+
+	void		(*mem_migrate)(struct numa_entity *ne, int node);
+	void		(*cpu_migrate)(struct numa_entity *ne, int node);
+
+	bool		(*tryget)(struct numa_entity *ne);
+	void		(*put)(struct numa_entity *ne);
+};
+
 struct numa_cpu_load {
 	unsigned long	remote; /* load of tasks running away from their home node */
 	unsigned long	all;	/* load of tasks that should be running on this node */
@@ -147,6 +158,26 @@ static inline struct task_struct *ne_own
 	return rcu_dereference(ne_mm(ne)->owner);
 }
 
+static unsigned long process_cpu_load(struct numa_entity *ne)
+{
+	unsigned long load = 0;
+	struct task_struct *t, *p;
+
+	rcu_read_lock();
+	t = p = ne_owner(ne);
+	if (p) do {
+		load += t->numa_contrib;
+	} while ((t = next_thread(t)) != p);
+	rcu_read_unlock();
+
+	return load;
+}
+
+static unsigned long process_mem_load(struct numa_entity *ne)
+{
+	return get_mm_counter(ne_mm(ne), MM_ANONPAGES);
+}
+
 static void process_cpu_migrate(struct numa_entity *ne, int node)
 {
 	struct task_struct *p, *t;
@@ -164,7 +195,7 @@ static void process_mem_migrate(struct n
 	lazy_migrate_process(ne_mm(ne), node);
 }
 
-static int process_tryget(struct numa_entity *ne)
+static bool process_tryget(struct numa_entity *ne)
 {
 	/*
 	 * This is possible when we hold &nq_of(ne->node)->lock since then
@@ -180,6 +211,17 @@ static void process_put(struct numa_enti
 	mmput(ne_mm(ne));
 }
 
+static const struct numa_ops process_numa_ops = {
+	.mem_load	= process_mem_load,
+	.cpu_load	= process_cpu_load,
+
+	.mem_migrate	= process_mem_migrate,
+	.cpu_migrate	= process_cpu_migrate,
+
+	.tryget		= process_tryget,
+	.put		= process_put,
+};
+
 static struct node_queue *lock_ne_nq(struct numa_entity *ne)
 {
 	struct node_queue *nq;
@@ -239,8 +281,8 @@ static void enqueue_ne(struct numa_entit
 
 	BUG_ON(ne->node != -1);
 
-	process_cpu_migrate(ne, node);
-	process_mem_migrate(ne, node);
+	ne->nops->cpu_migrate(ne, node);
+	ne->nops->mem_migrate(ne, node);
 
 	spin_lock(&nq->lock);
 	__enqueue_ne(nq, ne);
@@ -260,14 +302,15 @@ static void dequeue_ne(struct numa_entit
 	spin_unlock(&nq->lock);
 }
 
-static void init_ne(struct numa_entity *ne)
+static void init_ne(struct numa_entity *ne, const struct numa_ops *nops)
 {
 	ne->node = -1;
+	ne->nops = nops;
 }
 
 void mm_init_numa(struct mm_struct *mm)
 {
-	init_ne(&mm->numa);
+	init_ne(&mm->numa, &process_numa_ops);
 }
 
 void exit_numa(struct mm_struct *mm)
@@ -449,26 +492,6 @@ struct numa_imbalance {
 	enum numa_balance_type type;
 };
 
-static unsigned long process_cpu_load(struct numa_entity *ne)
-{
-	unsigned long load = 0;
-	struct task_struct *t, *p;
-
-	rcu_read_lock();
-	t = p = ne_owner(ne);
-	if (p) do {
-		load += t->numa_contrib;
-	} while ((t = next_thread(t)) != p);
-	rcu_read_unlock();
-
-	return load;
-}
-
-static unsigned long process_mem_load(struct numa_entity *ne)
-{
-	return get_mm_counter(ne_mm(ne), MM_ANONPAGES);
-}
-
 static int find_busiest_node(int this_node, struct numa_imbalance *imb)
 {
 	unsigned long cpu_load, mem_load;
@@ -590,8 +613,8 @@ static void move_processes(struct node_q
 				     struct numa_entity,
 				     numa_entry);
 
-		ne_cpu = process_cpu_load(ne);
-		ne_mem = process_mem_load(ne);
+		ne_cpu = ne->nops->cpu_load(ne);
+		ne_mem = ne->nops->mem_load(ne);
 
 		if (sched_feat(NUMA_BALANCE_FILTER)) {
 			/*
@@ -616,13 +639,13 @@ static void move_processes(struct node_q
 
 		__dequeue_ne(busiest_nq, ne);
 		__enqueue_ne(this_nq, ne);
-		if (process_tryget(ne)) {
+		if (ne->nops->tryget(ne)) {
 			double_unlock_nq(this_nq, busiest_nq);
 
-			process_cpu_migrate(ne, this_nq->node);
-			process_mem_migrate(ne, this_nq->node);
+			ne->nops->cpu_migrate(ne, this_nq->node);
+			ne->nops->mem_migrate(ne, this_nq->node);
+			ne->nops->put(ne);
 
-			process_put(ne);
 			double_lock_nq(this_nq, busiest_nq);
 		}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
