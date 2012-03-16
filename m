Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B91076B00FD
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:12 -0400 (EDT)
Message-Id: <20120316144241.074193109@chello.nl>
Date: Fri, 16 Mar 2012 15:40:43 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 15/26] sched, numa: Implement hotplug hooks
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-foo-6a.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

start/stop numa balance threads on-demand using cpu-hotlpug.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/sched/numa.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 55 insertions(+), 7 deletions(-)
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -596,31 +596,79 @@ static int numad_thread(void *data)
 	return 0;
 }
 
+static int __cpuinit
+numa_hotplug(struct notifier_block *nb, unsigned long action, void *hcpu)
+{
+	int cpu = (long)hcpu;
+	int node = cpu_to_node(cpu);
+	struct node_queue *nq = nq_of(node);
+	struct task_struct *numad;
+	int err = 0;
+
+	switch (action & ~CPU_TASKS_FROZEN) {
+	case CPU_UP_PREPARE:
+		if (nq->numad)
+			break;
+
+		numad = kthread_create_on_node(numad_thread,
+				nq, node, "numad/%d", node);
+		if (IS_ERR(numad)) {
+			err = PTR_ERR(numad);
+			break;
+		}
+
+		nq->numad = numad;
+		nq->next_schedule = jiffies + HZ; // XXX sync-up?
+		break;
+
+	case CPU_ONLINE:
+		wake_up_process(nq->numad);
+		break;
+
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		if (!nq->numad)
+			break;
+
+		if (cpumask_any_and(cpu_online_mask,
+				    cpumask_of_node(node)) >= nr_cpu_ids) {
+			kthread_stop(nq->numad);
+			nq->numad = NULL;
+		}
+		break;
+	}
+
+	return notifier_from_errno(err);
+}
+
 static __init int numa_init(void)
 {
-	int node;
+	int node, cpu, err;
 
 	nqs = kzalloc(sizeof(struct node_queue*) * nr_node_ids, GFP_KERNEL);
 	BUG_ON(!nqs);
 
-	for_each_node(node) { // XXX hotplug
+	for_each_node(node) {
 		struct node_queue *nq = kmalloc_node(sizeof(*nq),
 				GFP_KERNEL | __GFP_ZERO, node);
 		BUG_ON(!nq);
 
-		nq->numad = kthread_create_on_node(numad_thread,
-				nq, node, "numad/%d", node);
-		BUG_ON(IS_ERR(nq->numad));
-
 		spin_lock_init(&nq->lock);
 		INIT_LIST_HEAD(&nq->entity_list);
 
 		nq->next_schedule = jiffies + HZ;
 		nq->node = node;
 		nqs[node] = nq;
+	}
 
-		wake_up_process(nq->numad);
+	get_online_cpus();
+	cpu_notifier(numa_hotplug, 0);
+	for_each_online_cpu(cpu) {
+		err = numa_hotplug(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
+		BUG_ON(notifier_to_errno(err));
+		numa_hotplug(NULL, CPU_ONLINE, (void *)(long)cpu);
 	}
+	put_online_cpus();
 
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
