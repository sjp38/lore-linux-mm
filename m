Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4B48C6B025E
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:43 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so145403125wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8si17015784wiz.62.2015.09.21.06.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:42 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 12/18] ring_buffer: Convert benchmark kthreads into kthread worker API
Date: Mon, 21 Sep 2015 15:03:53 +0200
Message-Id: <1442840639-6963-13-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
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
 kernel/trace/ring_buffer_benchmark.c | 133 ++++++++++++++++-------------------
 1 file changed, 59 insertions(+), 74 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 9e00fd178226..3f27ff6debd3 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -26,10 +26,17 @@ static int wakeup_interval = 100;
 static int reader_finish;
 static DECLARE_COMPLETION(read_start);
 static DECLARE_COMPLETION(read_done);
-
 static struct ring_buffer *buffer;
-static struct task_struct *producer;
-static struct task_struct *consumer;
+
+static void rb_producer_hammer_func(struct kthread_work *dummy);
+static struct kthread_worker *rb_producer_worker;
+static DEFINE_DELAYED_KTHREAD_WORK(rb_producer_hammer_work,
+				   rb_producer_hammer_func);
+
+static void rb_consumer_func(struct kthread_work *dummy);
+static struct kthread_worker *rb_consumer_worker;
+static DEFINE_KTHREAD_WORK(rb_consumer_work, rb_consumer_func);
+
 static unsigned long read;
 
 static unsigned int disable_reader;
@@ -61,6 +68,7 @@ MODULE_PARM_DESC(consumer_fifo, "fifo prio for consumer");
 static int read_events;
 
 static int test_error;
+static int test_end;
 
 #define TEST_ERROR()				\
 	do {					\
@@ -77,7 +85,7 @@ enum event_status {
 
 static bool break_test(void)
 {
-	return test_error || kthread_should_stop();
+	return test_error || test_end;
 }
 
 static enum event_status read_event(int cpu)
@@ -262,8 +270,8 @@ static void ring_buffer_producer(void)
 		end_time = ktime_get();
 
 		cnt++;
-		if (consumer && !(cnt % wakeup_interval))
-			wake_up_process(consumer);
+		if (rb_consumer_worker && !(cnt % wakeup_interval))
+			wake_up_process(rb_consumer_worker->task);
 
 #ifndef CONFIG_PREEMPT
 		/*
@@ -281,7 +289,7 @@ static void ring_buffer_producer(void)
 	} while (ktime_before(end_time, timeout) && !break_test());
 	trace_printk("End ring buffer hammer\n");
 
-	if (consumer) {
+	if (rb_consumer_worker) {
 		/* Init both completions here to avoid races */
 		init_completion(&read_start);
 		init_completion(&read_done);
@@ -290,7 +298,7 @@ static void ring_buffer_producer(void)
 		reader_finish = 1;
 		/* finish var visible before waking up the consumer */
 		smp_wmb();
-		wake_up_process(consumer);
+		wake_up_process(rb_consumer_worker->task);
 		wait_for_completion(&read_done);
 	}
 
@@ -368,68 +376,39 @@ static void ring_buffer_producer(void)
 	}
 }
 
-static void wait_to_die(void)
-{
-	set_current_state(TASK_INTERRUPTIBLE);
-	while (!kthread_should_stop()) {
-		schedule();
-		set_current_state(TASK_INTERRUPTIBLE);
-	}
-	__set_current_state(TASK_RUNNING);
-}
-
-static int ring_buffer_consumer_thread(void *arg)
+static void rb_consumer_func(struct kthread_work *dummy)
 {
-	while (!break_test()) {
-		complete(&read_start);
-
-		ring_buffer_consumer();
+	complete(&read_start);
 
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (break_test())
-			break;
-		schedule();
-	}
-	__set_current_state(TASK_RUNNING);
-
-	if (!kthread_should_stop())
-		wait_to_die();
-
-	return 0;
+	ring_buffer_consumer();
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
-
-		ring_buffer_producer();
-		if (break_test())
-			goto out_kill;
+	ring_buffer_reset(buffer);
 
-		trace_printk("Sleeping for 10 secs\n");
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (break_test())
-			goto out_kill;
-		schedule_timeout(HZ * SLEEP_TIME);
+	if (rb_consumer_worker) {
+		queue_kthread_work(rb_consumer_worker, &rb_consumer_work);
+		wait_for_completion(&read_start);
 	}
 
-out_kill:
-	__set_current_state(TASK_RUNNING);
-	if (!kthread_should_stop())
-		wait_to_die();
+	ring_buffer_producer();
 
-	return 0;
+	if (break_test())
+		return;
+
+	trace_printk("Sleeping for 10 secs\n");
+	queue_delayed_kthread_work(rb_producer_worker,
+				   &rb_producer_hammer_work,
+				   HZ * SLEEP_TIME);
 }
 
 static int __init ring_buffer_benchmark_init(void)
 {
-	int ret;
+	int ret = 0;
 
 	/* make a one meg buffer in overwite mode */
 	buffer = ring_buffer_alloc(1000000, RB_FL_OVERWRITE);
@@ -437,19 +416,21 @@ static int __init ring_buffer_benchmark_init(void)
 		return -ENOMEM;
 
 	if (!disable_reader) {
-		consumer = kthread_create(ring_buffer_consumer_thread,
-					  NULL, "rb_consumer");
-		ret = PTR_ERR(consumer);
-		if (IS_ERR(consumer))
+		rb_consumer_worker = create_kthread_worker("rb_consumer");
+		if (IS_ERR(rb_consumer_worker)) {
+			ret = PTR_ERR(rb_consumer_worker);
 			goto out_fail;
+		}
 	}
 
-	producer = kthread_run(ring_buffer_producer_thread,
-			       NULL, "rb_producer");
-	ret = PTR_ERR(producer);
-
-	if (IS_ERR(producer))
+	rb_producer_worker = create_kthread_worker("rb_producer");
+	if (IS_ERR(rb_producer_worker)) {
+		ret = PTR_ERR(rb_producer_worker);
 		goto out_kill;
+	}
+
+	queue_delayed_kthread_work(rb_producer_worker,
+				   &rb_producer_hammer_work, 0);
 
 	/*
 	 * Run them as low-prio background tasks by default:
@@ -459,24 +440,26 @@ static int __init ring_buffer_benchmark_init(void)
 			struct sched_param param = {
 				.sched_priority = consumer_fifo
 			};
-			sched_setscheduler(consumer, SCHED_FIFO, &param);
+			sched_setscheduler(rb_consumer_worker->task,
+					   SCHED_FIFO, &param);
 		} else
-			set_user_nice(consumer, consumer_nice);
+			set_user_nice(rb_consumer_worker->task, consumer_nice);
 	}
 
 	if (producer_fifo >= 0) {
 		struct sched_param param = {
 			.sched_priority = producer_fifo
 		};
-		sched_setscheduler(producer, SCHED_FIFO, &param);
+		sched_setscheduler(rb_producer_worker->task,
+				   SCHED_FIFO, &param);
 	} else
-		set_user_nice(producer, producer_nice);
+		set_user_nice(rb_producer_worker->task, producer_nice);
 
 	return 0;
 
  out_kill:
-	if (consumer)
-		kthread_stop(consumer);
+	if (rb_consumer_worker)
+		destroy_kthread_worker(rb_consumer_worker);
 
  out_fail:
 	ring_buffer_free(buffer);
@@ -485,9 +468,11 @@ static int __init ring_buffer_benchmark_init(void)
 
 static void __exit ring_buffer_benchmark_exit(void)
 {
-	kthread_stop(producer);
-	if (consumer)
-		kthread_stop(consumer);
+	test_end = 1;
+	cancel_delayed_kthread_work_sync(&rb_producer_hammer_work);
+	destroy_kthread_worker(rb_producer_worker);
+	if (rb_consumer_worker)
+		destroy_kthread_worker(rb_consumer_worker);
 	ring_buffer_free(buffer);
 }
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
