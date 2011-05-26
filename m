Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0656B0025
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:37:22 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DC2673EE0C2
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:37:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2CCB45DE9C
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:37:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9944845DEC3
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:37:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A0F31DB803E
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:37:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 42FC01DB803F
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:37:18 +0900 (JST)
Date: Thu, 26 May 2011 14:30:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 7/10] workqueue: add WQ_IDLEPRI
Message-Id: <20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>


When this idea came to me, I wonder which is better to maintain memcg's thread
pool or add support in workqueue for generic use. In genral, I feel enhancing
genric one is better...so, wrote this one.
==
This patch adds a new workqueue class as WQ_IDLEPRI.

The worker thread for this workqueue will have SCHED_IDLE scheduling
policy and don't use (too much) CPU if there are other active threads.
IOW, unless the system is idle, work will not progress.

Considering to schedule an asynchronous work which can be a help
for reduce latency of applications, it's good to use idle time
of the system. The CPU time which was used by application's context
will be moved to fill idle time of the system.

Applications can hide its latency by shifting cpu time for a work
to be done in idle time. This will be used by memory cgroup to hide
memory reclaim latency.

I may miss something...any comments are welcomed.

NOTE 1: SCHED_IDLE is just a lowest priority of SCHED_OTHER.
NOTE 2: It may be better to add cond_resched() in worker thread somewhere..
        but I couldn't find where is the best.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/workqueue.txt |   10 ++++
 include/linux/workqueue.h   |    8 ++-
 kernel/workqueue.c          |  101 +++++++++++++++++++++++++++++++++-----------
 mm/memcontrol.c             |    3 -
 4 files changed, 93 insertions(+), 29 deletions(-)

Index: memcg_async/include/linux/workqueue.h
===================================================================
--- memcg_async.orig/include/linux/workqueue.h
+++ memcg_async/include/linux/workqueue.h
@@ -56,7 +56,8 @@ enum {
 
 	/* special cpu IDs */
 	WORK_CPU_UNBOUND	= NR_CPUS,
-	WORK_CPU_NONE		= NR_CPUS + 1,
+	WORK_CPU_IDLEPRI	= NR_CPUS + 1,
+	WORK_CPU_NONE		= NR_CPUS + 2,
 	WORK_CPU_LAST		= WORK_CPU_NONE,
 
 	/*
@@ -254,9 +255,10 @@ enum {
 	WQ_MEM_RECLAIM		= 1 << 3, /* may be used for memory reclaim */
 	WQ_HIGHPRI		= 1 << 4, /* high priority */
 	WQ_CPU_INTENSIVE	= 1 << 5, /* cpu instensive workqueue */
+	WQ_IDLEPRI		= 1 << 6, /* the lowest priority in scheduler*/
 
-	WQ_DYING		= 1 << 6, /* internal: workqueue is dying */
-	WQ_RESCUER		= 1 << 7, /* internal: workqueue has rescuer */
+	WQ_DYING		= 1 << 7, /* internal: workqueue is dying */
+	WQ_RESCUER		= 1 << 8, /* internal: workqueue has rescuer */
 
 	WQ_MAX_ACTIVE		= 512,	  /* I like 512, better ideas? */
 	WQ_MAX_UNBOUND_PER_CPU	= 4,	  /* 4 * #cpus for unbound wq */
Index: memcg_async/kernel/workqueue.c
===================================================================
--- memcg_async.orig/kernel/workqueue.c
+++ memcg_async/kernel/workqueue.c
@@ -61,9 +61,11 @@ enum {
 	WORKER_REBIND		= 1 << 5,	/* mom is home, come back */
 	WORKER_CPU_INTENSIVE	= 1 << 6,	/* cpu intensive */
 	WORKER_UNBOUND		= 1 << 7,	/* worker is unbound */
+	WORKER_IDLEPRI		= 1 << 8,
 
 	WORKER_NOT_RUNNING	= WORKER_PREP | WORKER_ROGUE | WORKER_REBIND |
-				  WORKER_CPU_INTENSIVE | WORKER_UNBOUND,
+				  WORKER_CPU_INTENSIVE | WORKER_UNBOUND |
+				  WORKER_IDLEPRI,
 
 	/* gcwq->trustee_state */
 	TRUSTEE_START		= 0,		/* start */
@@ -276,14 +278,25 @@ static inline int __next_gcwq_cpu(int cp
 		}
 		if (sw & 2)
 			return WORK_CPU_UNBOUND;
-	}
+		if (sw & 4)
+			return WORK_CPU_IDLEPRI;
+	} else if (cpu == WORK_CPU_UNBOUND && (sw & 4))
+		return WORK_CPU_IDLEPRI;
 	return WORK_CPU_NONE;
 }
 
 static inline int __next_wq_cpu(int cpu, const struct cpumask *mask,
 				struct workqueue_struct *wq)
 {
-	return __next_gcwq_cpu(cpu, mask, !(wq->flags & WQ_UNBOUND) ? 1 : 2);
+	int sw = 1;
+
+	if (wq->flags & WQ_UNBOUND) {
+		if (!(wq->flags & WQ_IDLEPRI))
+			sw = 2;
+		else
+			sw = 4;
+	}
+	return __next_gcwq_cpu(cpu, mask, sw);
 }
 
 /*
@@ -294,20 +307,21 @@ static inline int __next_wq_cpu(int cpu,
  * specific CPU.  The following iterators are similar to
  * for_each_*_cpu() iterators but also considers the unbound gcwq.
  *
- * for_each_gcwq_cpu()		: possible CPUs + WORK_CPU_UNBOUND
- * for_each_online_gcwq_cpu()	: online CPUs + WORK_CPU_UNBOUND
- * for_each_cwq_cpu()		: possible CPUs for bound workqueues,
- *				  WORK_CPU_UNBOUND for unbound workqueues
+ * for_each_gcwq_cpu()	      : possible CPUs + WORK_CPU_UNBOUND + IDLEPRI
+ * for_each_online_gcwq_cpu() : online CPUs + WORK_CPU_UNBOUND + IDLEPRI
+ * for_each_cwq_cpu()	      : possible CPUs for bound workqueues,
+ *				WORK_CPU_UNBOUND for unbound workqueues
+ *				IDLEPRI for idle workqueues.
  */
 #define for_each_gcwq_cpu(cpu)						\
-	for ((cpu) = __next_gcwq_cpu(-1, cpu_possible_mask, 3);		\
+	for ((cpu) = __next_gcwq_cpu(-1, cpu_possible_mask, 7);		\
 	     (cpu) < WORK_CPU_NONE;					\
-	     (cpu) = __next_gcwq_cpu((cpu), cpu_possible_mask, 3))
+	     (cpu) = __next_gcwq_cpu((cpu), cpu_possible_mask, 7))
 
 #define for_each_online_gcwq_cpu(cpu)					\
-	for ((cpu) = __next_gcwq_cpu(-1, cpu_online_mask, 3);		\
+	for ((cpu) = __next_gcwq_cpu(-1, cpu_online_mask, 7);		\
 	     (cpu) < WORK_CPU_NONE;					\
-	     (cpu) = __next_gcwq_cpu((cpu), cpu_online_mask, 3))
+	     (cpu) = __next_gcwq_cpu((cpu), cpu_online_mask, 7))
 
 #define for_each_cwq_cpu(cpu, wq)					\
 	for ((cpu) = __next_wq_cpu(-1, cpu_possible_mask, (wq));	\
@@ -451,22 +465,34 @@ static DEFINE_PER_CPU_SHARED_ALIGNED(ato
 static struct global_cwq unbound_global_cwq;
 static atomic_t unbound_gcwq_nr_running = ATOMIC_INIT(0);	/* always 0 */
 
+/*
+ * Global cpu workqueue and nr_running for idle gcwq. The idle gcwq is
+ * always online has GCWQ_DISASSOCIATED set. and all its worker have
+ * WORKER_UNBOUND and WORKER_IDLEPRI set.
+ */
+static struct global_cwq unbound_idle_global_cwq;
+static atomic_t unbound_idle_gcwq_nr_running = ATOMIC_INIT(0);	/* always 0 */
+
 static int worker_thread(void *__worker);
 
 static struct global_cwq *get_gcwq(unsigned int cpu)
 {
-	if (cpu != WORK_CPU_UNBOUND)
+	if (cpu < WORK_CPU_UNBOUND)
 		return &per_cpu(global_cwq, cpu);
-	else
+	else if (cpu == WORK_CPU_UNBOUND)
 		return &unbound_global_cwq;
+	else
+		return &unbound_idle_global_cwq;
 }
 
 static atomic_t *get_gcwq_nr_running(unsigned int cpu)
 {
-	if (cpu != WORK_CPU_UNBOUND)
+	if (cpu < WORK_CPU_UNBOUND)
 		return &per_cpu(gcwq_nr_running, cpu);
-	else
+	else if (cpu == WORK_CPU_UNBOUND)
 		return &unbound_gcwq_nr_running;
+	else
+		return &unbound_idle_gcwq_nr_running;
 }
 
 static struct cpu_workqueue_struct *get_cwq(unsigned int cpu,
@@ -480,7 +506,8 @@ static struct cpu_workqueue_struct *get_
 			return wq->cpu_wq.single;
 #endif
 		}
-	} else if (likely(cpu == WORK_CPU_UNBOUND))
+	} else if (likely(cpu == WORK_CPU_UNBOUND ||
+			  cpu == WORK_CPU_IDLEPRI))
 		return wq->cpu_wq.single;
 	return NULL;
 }
@@ -563,7 +590,9 @@ static struct global_cwq *get_work_gcwq(
 	if (cpu == WORK_CPU_NONE)
 		return NULL;
 
-	BUG_ON(cpu >= nr_cpu_ids && cpu != WORK_CPU_UNBOUND);
+	BUG_ON(cpu >= nr_cpu_ids
+		&& cpu != WORK_CPU_UNBOUND
+		&& cpu != WORK_CPU_IDLEPRI);
 	return get_gcwq(cpu);
 }
 
@@ -599,6 +628,10 @@ static bool keep_working(struct global_c
 {
 	atomic_t *nr_running = get_gcwq_nr_running(gcwq->cpu);
 
+	if (unlikely((gcwq->cpu == WORK_CPU_IDLEPRI)) &&
+		need_resched())
+		return false;
+
 	return !list_empty(&gcwq->worklist) &&
 		(atomic_read(nr_running) <= 1 ||
 		 gcwq->flags & GCWQ_HIGHPRI_PENDING);
@@ -1025,9 +1058,12 @@ static void __queue_work(unsigned int cp
 			}
 		} else
 			spin_lock_irqsave(&gcwq->lock, flags);
-	} else {
+	} else if (!(wq->flags & WQ_IDLEPRI)) {
 		gcwq = get_gcwq(WORK_CPU_UNBOUND);
 		spin_lock_irqsave(&gcwq->lock, flags);
+	} else {
+		gcwq = get_gcwq(WORK_CPU_IDLEPRI);
+		spin_lock_irqsave(&gcwq->lock, flags);
 	}
 
 	/* gcwq determined, get cwq and queue */
@@ -1160,8 +1196,10 @@ int queue_delayed_work_on(int cpu, struc
 				lcpu = gcwq->cpu;
 			else
 				lcpu = raw_smp_processor_id();
-		} else
+		} else if (!(wq->flags & WQ_IDLEPRI))
 			lcpu = WORK_CPU_UNBOUND;
+		else
+			lcpu = WORK_CPU_IDLEPRI;
 
 		set_work_cwq(work, get_cwq(lcpu, wq), 0);
 
@@ -1352,6 +1390,7 @@ static struct worker *alloc_worker(void)
 static struct worker *create_worker(struct global_cwq *gcwq, bool bind)
 {
 	bool on_unbound_cpu = gcwq->cpu == WORK_CPU_UNBOUND;
+	bool on_idle_cpu = gcwq->cpu == WORK_CPU_IDLEPRI;
 	struct worker *worker = NULL;
 	int id = -1;
 
@@ -1371,14 +1410,17 @@ static struct worker *create_worker(stru
 	worker->gcwq = gcwq;
 	worker->id = id;
 
-	if (!on_unbound_cpu)
+	if (!on_unbound_cpu && !on_idle_cpu)
 		worker->task = kthread_create_on_node(worker_thread,
 						      worker,
 						      cpu_to_node(gcwq->cpu),
 						      "kworker/%u:%d", gcwq->cpu, id);
-	else
+	else if (!on_idle_cpu)
 		worker->task = kthread_create(worker_thread, worker,
 					      "kworker/u:%d", id);
+	else
+		worker->task = kthread_create(worker_thread, worker,
+						"kworker/i:%d", id);
 	if (IS_ERR(worker->task))
 		goto fail;
 
@@ -1387,12 +1429,14 @@ static struct worker *create_worker(stru
 	 * online later on.  Make sure every worker has
 	 * PF_THREAD_BOUND set.
 	 */
-	if (bind && !on_unbound_cpu)
+	if (bind && !on_unbound_cpu && !on_idle_cpu)
 		kthread_bind(worker->task, gcwq->cpu);
 	else {
 		worker->task->flags |= PF_THREAD_BOUND;
 		if (on_unbound_cpu)
 			worker->flags |= WORKER_UNBOUND;
+		if (on_idle_cpu)
+			worker->flags |= WORKER_IDLEPRI;
 	}
 
 	return worker;
@@ -1496,7 +1540,7 @@ static bool send_mayday(struct work_stru
 	/* mayday mayday mayday */
 	cpu = cwq->gcwq->cpu;
 	/* WORK_CPU_UNBOUND can't be set in cpumask, use cpu 0 instead */
-	if (cpu == WORK_CPU_UNBOUND)
+	if ((cpu == WORK_CPU_UNBOUND) || (cpu == WORK_CPU_IDLEPRI))
 		cpu = 0;
 	if (!mayday_test_and_set_cpu(cpu, wq->mayday_mask))
 		wake_up_process(wq->rescuer->task);
@@ -1935,6 +1979,11 @@ static int worker_thread(void *__worker)
 
 	/* tell the scheduler that this is a workqueue worker */
 	worker->task->flags |= PF_WQ_WORKER;
+	/* if worker is for IDLEPRI, set scheduler */
+	if (worker->flags & WORKER_IDLEPRI) {
+		struct sched_param param;
+		sched_setscheduler(current, SCHED_IDLE, &param);
+	}
 woke_up:
 	spin_lock_irq(&gcwq->lock);
 
@@ -2912,8 +2961,9 @@ struct workqueue_struct *__alloc_workque
 	/*
 	 * Workqueues which may be used during memory reclaim should
 	 * have a rescuer to guarantee forward progress.
+	 * But IDLE workqueue will not have any rescuer.
 	 */
-	if (flags & WQ_MEM_RECLAIM)
+	if ((flags & WQ_MEM_RECLAIM) && !(flags & WQ_IDLEPRI))
 		flags |= WQ_RESCUER;
 
 	/*
@@ -3775,7 +3825,8 @@ static int __init init_workqueues(void)
 		struct global_cwq *gcwq = get_gcwq(cpu);
 		struct worker *worker;
 
-		if (cpu != WORK_CPU_UNBOUND)
+		if ((cpu != WORK_CPU_UNBOUND) &&
+		    (cpu != WORK_CPU_IDLEPRI))
 			gcwq->flags &= ~GCWQ_DISASSOCIATED;
 		worker = create_worker(gcwq, true);
 		BUG_ON(!worker);
Index: memcg_async/Documentation/workqueue.txt
===================================================================
--- memcg_async.orig/Documentation/workqueue.txt
+++ memcg_async/Documentation/workqueue.txt
@@ -247,6 +247,16 @@ resources, scheduled and executed.
 	highpri CPU-intensive wq start execution as soon as resources
 	are available and don't affect execution of other work items.
 
+  WQ_UNBOUND | WQ_IDLEPRI
+	An special case of unbound wq, the worker thread for this workqueue
+	will run in the lowest priority of SCHED_IDLE. Most of characteristics
+	are same to UNBOUND workqueue but the thread's priority is SCHED_IDLE.
+	This is useful when you want to run a work for hiding application's
+	latency by making use of idle time of the system. Because scheduling
+	priority of this class workqueue is minimum, you must assume that
+	the work will not run for a long time when the system is cpu hogging.
+	Then, unlike UNBOUND WQ, this will not have rescuer threads.
+
 @max_active:
 
 @max_active determines the maximum number of execution contexts per
Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -3872,7 +3872,8 @@ struct workqueue_struct *memcg_async_shr
 static int memcg_async_shrinker_init(void)
 {
 	memcg_async_shrinker = alloc_workqueue("memcg_async",
-			WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
+		WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_IDLEPRI | WQ_FREEZABLE,
+		0);
 	return 0;
 }
 module_init(memcg_async_shrinker_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
