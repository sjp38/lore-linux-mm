Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 026F86B025E
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:26 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so162767274wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he9si37508579wjc.173.2015.07.28.07.40.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:16 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 11/14] ring_buffer: Use kthread worker API for the producer kthread in the benchmark
Date: Tue, 28 Jul 2015 16:39:28 +0200
Message-Id: <1438094371-8326-12-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. In many cases it is unclear to say in which state
it is and sometimes it is done a wrong way.

The plan is to convert kthreads into kthread_worker or workqueues
API. It allows to split the functionality into separate operations.
It helps to make a better structure. Also it defines a clean state
where no locks are taken, IRQs blocked, the kthread might sleep
or even be safely migrated.

The kthread worker API is useful when we want to have a dedicated
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts the ring buffer benchmark producer into a kthread
worker because it modifies the scheduling priority and policy.
Also, it is a benchmark. It makes CPU very busy. It will most likely
run only limited time. IMHO, it does not make sense to mess the system
workqueues with it.

The thread is split into two independent works. It might look more
complicated but it helped me to find a race in the sleeping part
that was fixed separately.

kthread_should_stop() could not longer be used inside the works
because it defines the life of the worker and it needs to stay
usable until all works are done. Instead, we add @test_end
global variable. It is set during normal termination in compare
with @test_error.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/trace/ring_buffer_benchmark.c | 81 ++++++++++++++++++++++--------------
 1 file changed, 49 insertions(+), 32 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 10e0ec9b797f..86514babe07f 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -26,9 +26,14 @@ static int wakeup_interval = 100;
 static int reader_finish;
 static DECLARE_COMPLETION(read_start);
 static DECLARE_COMPLETION(read_done);
-
 static struct ring_buffer *buffer;
-static struct task_struct *producer;
+
+static void rb_producer_hammer_func(struct kthread_work *dummy);
+static void rb_producer_sleep_func(struct kthread_work *dummy);
+static DEFINE_KTHREAD_WORKER(rb_producer_worker);
+static DEFINE_KTHREAD_WORK(rb_producer_hammer_work, rb_producer_hammer_func);
+static DEFINE_KTHREAD_WORK(rb_producer_sleep_work, rb_producer_sleep_func);
+
 static struct task_struct *consumer;
 static unsigned long read;
 
@@ -61,6 +66,7 @@ MODULE_PARM_DESC(consumer_fifo, "fifo prio for consumer");
 static int read_events;
 
 static int test_error;
+static int test_end;
 
 #define TEST_ERROR()				\
 	do {					\
@@ -77,7 +83,11 @@ enum event_status {
 
 static bool break_test(void)
 {
-	return test_error || kthread_should_stop();
+	/*
+	 * FIXME: The test for kthread_should_stop() will get obsoleted
+	 * once the consumer is too converted into the kthread worker API.
+	 */
+	return test_error || test_end || kthread_should_stop();
 }
 
 static enum event_status read_event(int cpu)
@@ -387,34 +397,40 @@ static int ring_buffer_consumer_thread(void *arg)
 	return 0;
 }
 
-static int ring_buffer_producer_thread(void *arg)
+static void rb_producer_hammer_func(struct kthread_work *dummy)
 {
-	while (!break_test()) {
-		ring_buffer_reset(buffer);
+	if (break_test())
+		return;
 
-		if (consumer) {
-			wake_up_process(consumer);
-			wait_for_completion(&read_start);
-		}
+	ring_buffer_reset(buffer);
 
-		ring_buffer_producer();
-		if (break_test())
-			goto out_kill;
+	if (consumer) {
+		wake_up_process(consumer);
+		wait_for_completion(&read_start);
+	}
 
-		trace_printk("Sleeping for 10 secs\n");
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (break_test()) {
-			__set_current_state(TASK_RUNNING);
-			goto out_kill;
-		}
-		schedule_timeout(HZ * SLEEP_TIME);
+	ring_buffer_producer();
+
+	if (break_test())
+		return;
+
+	queue_kthread_work(&rb_producer_worker, &rb_producer_sleep_work);
+}
+
+static void rb_producer_sleep_func(struct kthread_work *dummy)
+{
+	trace_printk("Sleeping for 10 secs\n");
+	set_current_state(TASK_INTERRUPTIBLE);
+	if (break_test()) {
+		set_current_state(TASK_RUNNING);
+		return;
 	}
+	schedule_timeout(HZ * SLEEP_TIME);
 
-out_kill:
-	if (!kthread_should_stop())
-		wait_to_die();
+	if (break_test())
+		return;
 
-	return 0;
+	queue_kthread_work(&rb_producer_worker, &rb_producer_hammer_work);
 }
 
 static int __init ring_buffer_benchmark_init(void)
@@ -434,13 +450,12 @@ static int __init ring_buffer_benchmark_init(void)
 			goto out_fail;
 	}
 
-	producer = kthread_run(ring_buffer_producer_thread,
-			       NULL, "rb_producer");
-	ret = PTR_ERR(producer);
-
-	if (IS_ERR(producer))
+	ret = create_kthread_worker(&rb_producer_worker, "rb_producer");
+	if (ret)
 		goto out_kill;
 
+	queue_kthread_work(&rb_producer_worker, &rb_producer_hammer_work);
+
 	/*
 	 * Run them as low-prio background tasks by default:
 	 */
@@ -458,9 +473,10 @@ static int __init ring_buffer_benchmark_init(void)
 		struct sched_param param = {
 			.sched_priority = producer_fifo
 		};
-		sched_setscheduler(producer, SCHED_FIFO, &param);
+		sched_setscheduler(rb_producer_worker.task,
+				   SCHED_FIFO, &param);
 	} else
-		set_user_nice(producer, producer_nice);
+		set_user_nice(rb_producer_worker.task, producer_nice);
 
 	return 0;
 
@@ -475,7 +491,8 @@ static int __init ring_buffer_benchmark_init(void)
 
 static void __exit ring_buffer_benchmark_exit(void)
 {
-	kthread_stop(producer);
+	test_end = 1;
+	wakeup_and_destroy_kthread_worker(&rb_producer_worker);
 	if (consumer)
 		kthread_stop(consumer);
 	ring_buffer_free(buffer);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
