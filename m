Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 569096B0073
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:24 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id hv19so15211313lab.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:23 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id ny7si773846lbb.135.2015.01.15.10.49.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:19 -0800 (PST)
Subject: [PATCH 5/6] delay-injection: resource management via procrastination
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:17 +0300
Message-ID: <20150115184917.10450.38284.stgit@buzz>
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

inject_delay() allows to pause current task before returning
into userspace in place where kernel doesn't hold any locks
thus wait wouldn't introduce any priority-inversion problems.

This code abuses existing task-work and 'TASK_PARKED' state.
Parked tasks are killable and don't contribute into cpu load.

Together with percpu_ratelimit this could be used in this manner:

if (percpu_ratelimit_charge(&ratelimit, events))
        inject_delay(percpu_ratelimit_target(&ratelimit));

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/sched.h        |    7 ++++
 include/trace/events/sched.h |    7 ++++
 kernel/sched/core.c          |   66 ++++++++++++++++++++++++++++++++++++++++++
 kernel/sched/fair.c          |   12 ++++++++
 4 files changed, 92 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef..2363918 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1132,6 +1132,7 @@ struct sched_statistics {
 	u64			iowait_sum;
 
 	u64			sleep_start;
+	u64			delay_start;
 	u64			sleep_max;
 	s64			sum_sleep_runtime;
 
@@ -1662,6 +1663,10 @@ struct task_struct {
 	unsigned long timer_slack_ns;
 	unsigned long default_timer_slack_ns;
 
+	/* Pause task till this time before returning into userspace */
+	ktime_t delay_injection_target;
+	struct callback_head delay_injection_work;
+
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 	/* Index of current stored address in ret_stack */
 	int curr_ret_stack;
@@ -2277,6 +2282,8 @@ extern void set_curr_task(int cpu, struct task_struct *p);
 
 void yield(void);
 
+extern void inject_delay(ktime_t target);
+
 /*
  * The default (Linux) execution domain.
  */
diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
index 30fedaf..d35154e 100644
--- a/include/trace/events/sched.h
+++ b/include/trace/events/sched.h
@@ -365,6 +365,13 @@ DEFINE_EVENT(sched_stat_template, sched_stat_blocked,
 	     TP_ARGS(tsk, delay));
 
 /*
+ * Tracepoint for accounting delay-injection
+ */
+DEFINE_EVENT(sched_stat_template, sched_stat_delayed,
+	     TP_PROTO(struct task_struct *tsk, u64 delay),
+	     TP_ARGS(tsk, delay));
+
+/*
  * Tracepoint for accounting runtime (time the task is executing
  * on a CPU).
  */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index c0accc0..7a9d6a1 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -65,6 +65,7 @@
 #include <linux/unistd.h>
 #include <linux/pagemap.h>
 #include <linux/hrtimer.h>
+#include <linux/task_work.h>
 #include <linux/tick.h>
 #include <linux/debugfs.h>
 #include <linux/ctype.h>
@@ -8377,3 +8378,68 @@ void dump_cpu_task(int cpu)
 	pr_info("Task dump for CPU %d:\n", cpu);
 	sched_show_task(cpu_curr(cpu));
 }
+
+#define DELAY_INJECTION_SLACK_NS	(NSEC_PER_SEC / 50)
+
+static enum hrtimer_restart delay_injection_wakeup(struct hrtimer *timer)
+{
+	struct hrtimer_sleeper *t =
+		container_of(timer, struct hrtimer_sleeper, timer);
+	struct task_struct *task = t->task;
+
+	t->task = NULL;
+	if (task)
+		wake_up_state(task, TASK_PARKED);
+
+	return HRTIMER_NORESTART;
+}
+
+/*
+ * Here delayed task sleeps in 'P'arked state.
+ */
+static void delay_injection_sleep(struct callback_head *head)
+{
+	struct task_struct *task = current;
+	struct hrtimer_sleeper t;
+
+	head->func = NULL;
+	__set_task_state(task, TASK_WAKEKILL | TASK_PARKED);
+	hrtimer_init_on_stack(&t.timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_set_expires_range_ns(&t.timer, current->delay_injection_target,
+				     DELAY_INJECTION_SLACK_NS);
+
+	t.timer.function = delay_injection_wakeup;
+	t.task = task;
+
+	hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);
+	if (!hrtimer_active(&t.timer))
+		t.task = NULL;
+
+	if (likely(t.task))
+		schedule();
+
+	hrtimer_cancel(&t.timer);
+	destroy_hrtimer_on_stack(&t.timer);
+
+	__set_task_state(task, TASK_RUNNING);
+}
+
+/*
+ * inject_delay - injects delay before returning into userspace
+ * @target: absolute monotomic timestamp to sleeping for,
+ *	    task will not return into userspace before this time
+ */
+void inject_delay(ktime_t target)
+{
+	struct task_struct *task = current;
+
+	if (ktime_after(target, task->delay_injection_target)) {
+		task->delay_injection_target = target;
+		if (!task->delay_injection_work.func) {
+			init_task_work(&task->delay_injection_work,
+					delay_injection_sleep);
+			task_work_add(task, &task->delay_injection_work, true);
+		}
+	}
+}
+EXPORT_SYMBOL(inject_delay);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 40667cb..2e3269b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2944,6 +2944,15 @@ static void enqueue_sleeper(struct cfs_rq *cfs_rq, struct sched_entity *se)
 			account_scheduler_latency(tsk, delta >> 10, 0);
 		}
 	}
+	if (se->statistics.delay_start) {
+		u64 delta = rq_clock(rq_of(cfs_rq)) - se->statistics.delay_start;
+
+		if ((s64)delta < 0)
+			delta = 0;
+
+		se->statistics.delay_start = 0;
+		trace_sched_stat_delayed(tsk, delta);
+	}
 #endif
 }
 
@@ -3095,6 +3104,9 @@ dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 				se->statistics.sleep_start = rq_clock(rq_of(cfs_rq));
 			if (tsk->state & TASK_UNINTERRUPTIBLE)
 				se->statistics.block_start = rq_clock(rq_of(cfs_rq));
+			if ((tsk->state & TASK_PARKED) &&
+			    tsk->delay_injection_target.tv64)
+				se->statistics.delay_start = rq_clock(rq_of(cfs_rq));
 		}
 #endif
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
