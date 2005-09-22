Received: from hastur.corp.sgi.com (hastur.corp.sgi.com [198.149.32.33])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j8MM3SxT014899
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 17:03:29 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by hastur.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j8MM3NeS195445325
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 15:03:23 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j8MM3SsT90916273
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 15:03:28 -0700 (PDT)
Date: Thu, 22 Sep 2005 15:03:28 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Use alloc_percpu to allocate workqueues locally
Message-ID: <Pine.LNX.4.62.0509221503090.18900@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch makes the workqueus use alloc_percpu instead of an array.
The workqueues are placed on nodes local to each processor.

The workqueue structure can grow to a significant size on a system
with lots of processors if this patch is not applied. 64 bit architectures
with all debugging features enabled and configured for 512 processors will
not be able to boot without this patch.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/kernel/workqueue.c
===================================================================
--- linux-2.6.14-rc2.orig/kernel/workqueue.c	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/kernel/workqueue.c	2005-09-22 15:00:36.000000000 -0700
@@ -12,6 +12,8 @@
  *   Andrew Morton <andrewm@uow.edu.au>
  *   Kai Petzke <wpp@marie.physik.tu-berlin.de>
  *   Theodore Ts'o <tytso@mit.edu>
+ *
+ * Made to use alloc_percpu by Christoph Lameter <clameter@sgi.com>.
  */
 
 #include <linux/module.h>
@@ -57,7 +59,7 @@ struct cpu_workqueue_struct {
  * per-CPU workqueues:
  */
 struct workqueue_struct {
-	struct cpu_workqueue_struct cpu_wq[NR_CPUS];
+	struct cpu_workqueue_struct *cpu_wq;
 	const char *name;
 	struct list_head list; 	/* Empty if single thread */
 };
@@ -102,7 +104,7 @@ int fastcall queue_work(struct workqueue
 		if (unlikely(is_single_threaded(wq)))
 			cpu = 0;
 		BUG_ON(!list_empty(&work->entry));
-		__queue_work(wq->cpu_wq + cpu, work);
+		__queue_work(per_cpu_ptr(wq->cpu_wq, cpu), work);
 		ret = 1;
 	}
 	put_cpu();
@@ -118,7 +120,7 @@ static void delayed_work_timer_fn(unsign
 	if (unlikely(is_single_threaded(wq)))
 		cpu = 0;
 
-	__queue_work(wq->cpu_wq + cpu, work);
+	__queue_work(per_cpu_ptr(wq->cpu_wq, cpu), work);
 }
 
 int fastcall queue_delayed_work(struct workqueue_struct *wq,
@@ -265,13 +267,13 @@ void fastcall flush_workqueue(struct wor
 
 	if (is_single_threaded(wq)) {
 		/* Always use cpu 0's area. */
-		flush_cpu_workqueue(wq->cpu_wq + 0);
+		flush_cpu_workqueue(per_cpu_ptr(wq->cpu_wq, 0));
 	} else {
 		int cpu;
 
 		lock_cpu_hotplug();
 		for_each_online_cpu(cpu)
-			flush_cpu_workqueue(wq->cpu_wq + cpu);
+			flush_cpu_workqueue(per_cpu_ptr(wq->cpu_wq, cpu));
 		unlock_cpu_hotplug();
 	}
 }
@@ -279,7 +281,7 @@ void fastcall flush_workqueue(struct wor
 static struct task_struct *create_workqueue_thread(struct workqueue_struct *wq,
 						   int cpu)
 {
-	struct cpu_workqueue_struct *cwq = wq->cpu_wq + cpu;
+	struct cpu_workqueue_struct *cwq = per_cpu_ptr(wq->cpu_wq, cpu);
 	struct task_struct *p;
 
 	spin_lock_init(&cwq->lock);
@@ -312,6 +314,7 @@ struct workqueue_struct *__create_workqu
 	if (!wq)
 		return NULL;
 
+	wq->cpu_wq = alloc_percpu(struct cpu_workqueue_struct);
 	wq->name = name;
 	/* We don't need the distraction of CPUs appearing and vanishing. */
 	lock_cpu_hotplug();
@@ -353,7 +356,7 @@ static void cleanup_workqueue_thread(str
 	unsigned long flags;
 	struct task_struct *p;
 
-	cwq = wq->cpu_wq + cpu;
+	cwq = per_cpu_ptr(wq->cpu_wq, cpu);
 	spin_lock_irqsave(&cwq->lock, flags);
 	p = cwq->thread;
 	cwq->thread = NULL;
@@ -380,6 +383,7 @@ void destroy_workqueue(struct workqueue_
 		spin_unlock(&workqueue_lock);
 	}
 	unlock_cpu_hotplug();
+	free_percpu(wq->cpu_wq);
 	kfree(wq);
 }
 
@@ -458,7 +462,7 @@ int current_is_keventd(void)
 
 	BUG_ON(!keventd_wq);
 
-	cwq = keventd_wq->cpu_wq + cpu;
+	cwq = per_cpu_ptr(keventd_wq->cpu_wq, cpu);
 	if (current == cwq->thread)
 		ret = 1;
 
@@ -470,7 +474,7 @@ int current_is_keventd(void)
 /* Take the work from this (downed) CPU. */
 static void take_over_work(struct workqueue_struct *wq, unsigned int cpu)
 {
-	struct cpu_workqueue_struct *cwq = wq->cpu_wq + cpu;
+	struct cpu_workqueue_struct *cwq = per_cpu_ptr(wq->cpu_wq, cpu);
 	LIST_HEAD(list);
 	struct work_struct *work;
 
@@ -481,7 +485,7 @@ static void take_over_work(struct workqu
 		printk("Taking work for %s\n", wq->name);
 		work = list_entry(list.next,struct work_struct,entry);
 		list_del(&work->entry);
-		__queue_work(wq->cpu_wq + smp_processor_id(), work);
+		__queue_work(per_cpu_ptr(wq->cpu_wq, smp_processor_id()), work);
 	}
 	spin_unlock_irq(&cwq->lock);
 }
@@ -508,15 +512,15 @@ static int __devinit workqueue_cpu_callb
 	case CPU_ONLINE:
 		/* Kick off worker threads. */
 		list_for_each_entry(wq, &workqueues, list) {
-			kthread_bind(wq->cpu_wq[hotcpu].thread, hotcpu);
-			wake_up_process(wq->cpu_wq[hotcpu].thread);
+			kthread_bind(per_cpu_ptr(wq->cpu_wq, hotcpu)->thread, hotcpu);
+			wake_up_process(per_cpu_ptr(wq->cpu_wq)->thread);
 		}
 		break;
 
 	case CPU_UP_CANCELED:
 		list_for_each_entry(wq, &workqueues, list) {
 			/* Unbind so it can run. */
-			kthread_bind(wq->cpu_wq[hotcpu].thread,
+			kthread_bind(per_cpu_tr(wq->cpu_wq, hotcpu)->thread,
 				     smp_processor_id());
 			cleanup_workqueue_thread(wq, hotcpu);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
