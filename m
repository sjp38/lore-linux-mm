Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8C26B0261
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:33 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so164084921wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh2si20833239wib.11.2015.07.28.07.40.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:21 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 14/14] kthread_worker: Add set_kthread_worker_scheduler*()
Date: Tue, 28 Jul 2015 16:39:31 +0200
Message-Id: <1438094371-8326-15-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The kthread worker API will be used for kthreads that need to modify
the scheduling policy.

This patch adds a function that allows to make it easily, safe way,
and hides implementation details. It might even help to get rid
of an init work.

It uses @sched_priority as a parameter instead of struct sched_param.
The structure has been there already in the initial kernel git commit
(April 2005) and always included only one member: sched_priority.
So, it rather looks like an overkill that is better to hide.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h              |  5 +++
 kernel/kthread.c                     | 59 ++++++++++++++++++++++++++++++++++++
 kernel/rcu/tree.c                    | 10 +++---
 kernel/trace/ring_buffer_benchmark.c | 11 +++----
 4 files changed, 72 insertions(+), 13 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index b75847e1a4c9..d503dc16613c 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -144,6 +144,11 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 
 void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice);
 
+int set_kthread_worker_scheduler(struct kthread_worker *worker,
+				 int policy, int sched_priority);
+int set_kthread_worker_scheduler_nocheck(struct kthread_worker *worker,
+					 int policy, int sched_priority);
+
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void flush_kthread_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index ab2e235b6144..4ab31b914676 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -662,6 +662,65 @@ void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice)
 }
 EXPORT_SYMBOL(set_kthread_worker_user_nice);
 
+static int
+__set_kthread_worker_scheduler(struct kthread_worker *worker,
+			       int policy, int sched_priority, bool check)
+{
+	struct task_struct *task = worker->task;
+	const struct sched_param sp = {
+		.sched_priority = sched_priority
+	};
+	int ret;
+
+	WARN_ON(!task);
+
+	if (check)
+		ret = sched_setscheduler(task, policy, &sp);
+	else
+		ret = sched_setscheduler_nocheck(task, policy, &sp);
+
+	return ret;
+}
+
+/**
+ * set_kthread_worker_scheduler - change the scheduling policy and/or RT
+ *	priority of a kthread worker.
+ * @worker: target kthread_worker
+ * @policy: new policy
+ * @sched_priority: new RT priority
+ *
+ * Return: 0 on success. An error code otherwise.
+ */
+int set_kthread_worker_scheduler(struct kthread_worker *worker,
+				 int policy, int sched_priority)
+{
+	return __set_kthread_worker_scheduler(worker, policy, sched_priority,
+					      true);
+}
+EXPORT_SYMBOL(set_kthread_worker_scheduler);
+
+/**
+ * set_kthread_worker_scheduler_nocheck - change the scheduling policy and/or RT
+ *	priority of a kthread worker.
+ * @worker: target kthread_worker
+ * @policy: new policy
+ * @sched_priority: new RT priority
+ *
+ * Just like set_kthread_worker_sheduler(), only don't bother checking
+ * if the current context has permission. For example, this is needed
+ * in stop_machine(): we create temporary high priority worker threads,
+ * but our caller might not have that capability.
+ *
+ * Return: 0 on success. An error code otherwise.
+ */
+int set_kthread_worker_scheduler_nocheck(struct kthread_worker *worker,
+					 int policy, int sched_priority)
+{
+	return __set_kthread_worker_scheduler(worker, policy, sched_priority,
+					      false);
+}
+EXPORT_SYMBOL(set_kthread_worker_scheduler_nocheck);
+
 /* insert @work before @pos in @worker */
 static void insert_kthread_work(struct kthread_worker *worker,
 			       struct kthread_work *work,
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 3a286f3b8b3c..d882464c71d7 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3916,7 +3916,6 @@ static int __init rcu_spawn_gp_kthread(void)
 	int kthread_prio_in = kthread_prio;
 	struct rcu_node *rnp;
 	struct rcu_state *rsp;
-	struct sched_param sp;
 	int ret;
 
 	/* Force priority into range. */
@@ -3940,11 +3939,10 @@ static int __init rcu_spawn_gp_kthread(void)
 		BUG_ON(ret);
 		rnp = rcu_get_root(rsp);
 		raw_spin_lock_irqsave(&rnp->lock, flags);
-		if (kthread_prio) {
-			sp.sched_priority = kthread_prio;
-			sched_setscheduler_nocheck(rsp->gp_worker.task,
-						   SCHED_FIFO, &sp);
-		}
+		if (kthread_prio)
+			set_kthread_worker_scheduler_nocheck(&rsp->gp_worker,
+							     SCHED_FIFO,
+							     kthread_prio);
 		queue_kthread_work(&rsp->gp_worker, &rsp->gp_init_work);
 		raw_spin_unlock_irqrestore(&rnp->lock, flags);
 	}
diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 73e4c7f11a2c..89028165bb22 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -469,13 +469,10 @@ static int __init ring_buffer_benchmark_init(void)
 			set_user_nice(consumer, consumer_nice);
 	}
 
-	if (producer_fifo >= 0) {
-		struct sched_param param = {
-			.sched_priority = producer_fifo
-		};
-		sched_setscheduler(rb_producer_worker.task,
-				   SCHED_FIFO, &param);
-	} else
+	if (producer_fifo >= 0)
+		set_kthread_worker_scheduler(&rb_producer_worker,
+					     SCHED_FIFO, producer_fifo);
+	else
 		set_kthread_worker_user_nice(&rb_producer_worker,
 					     producer_nice);
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
