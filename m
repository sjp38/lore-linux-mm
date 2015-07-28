Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 621F06B025D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:23 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so183906543wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id er6si21330162wjd.90.2015.07.28.07.40.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:15 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 10/14] ring_buffer: Fix more races when terminating the producer in the benchmark
Date: Tue, 28 Jul 2015 16:39:27 +0200
Message-Id: <1438094371-8326-11-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The commit b44754d8262d3aab8 ("ring_buffer: Allow to exit the ring
buffer benchmark immediately") added a hack into ring_buffer_producer()
that set @kill_test when kthread_should_stop() returned true. It improved
the situation a lot. It stopped the kthread in most cases because
the producer spent most of the time in the patched while cycle.

But there are still few possible races when kthread_should_stop()
is set outside of the cycle. Then we do not set @kill_test and
some other checks pass.

This patch adds a better fix. It renames @test_kill/TEST_KILL() into
a better descriptive @test_error/TEST_ERROR(). Also it introduces
break_test() function that checks for both @test_error and
kthread_should_stop(). Finally, the new function is used
on many locations when the check for @test_error is not enough.

Also it adds a missing check into ring_buffer_producer_thread()
between setting TASK_INTERRUPTIBLE and calling schedule_timeout().
Otherwise, we might miss a wakeup from kthread_stop().

Finally, it adds the same check also into ring_buffer_consumer()
between setting TASK_INTERRUPTIBLE and calling schedule_timeout().
Well, I added this one just for paranoid reasons. If we are here
the producer should have been destroyed before and it should have
set @reader_finish. But better be safe.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/trace/ring_buffer_benchmark.c | 65 ++++++++++++++++++++----------------
 1 file changed, 37 insertions(+), 28 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index ccb1a0b95f64..10e0ec9b797f 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -60,12 +60,12 @@ MODULE_PARM_DESC(consumer_fifo, "fifo prio for consumer");
 
 static int read_events;
 
-static int kill_test;
+static int test_error;
 
-#define KILL_TEST()				\
+#define TEST_ERROR()				\
 	do {					\
-		if (!kill_test) {		\
-			kill_test = 1;		\
+		if (!test_error) {		\
+			test_error = 1;		\
 			WARN_ON(1);		\
 		}				\
 	} while (0)
@@ -75,6 +75,11 @@ enum event_status {
 	EVENT_DROPPED,
 };
 
+static bool break_test(void)
+{
+	return test_error || kthread_should_stop();
+}
+
 static enum event_status read_event(int cpu)
 {
 	struct ring_buffer_event *event;
@@ -87,7 +92,7 @@ static enum event_status read_event(int cpu)
 
 	entry = ring_buffer_event_data(event);
 	if (*entry != cpu) {
-		KILL_TEST();
+		TEST_ERROR();
 		return EVENT_DROPPED;
 	}
 
@@ -115,10 +120,13 @@ static enum event_status read_page(int cpu)
 		rpage = bpage;
 		/* The commit may have missed event flags set, clear them */
 		commit = local_read(&rpage->commit) & 0xfffff;
-		for (i = 0; i < commit && !kill_test; i += inc) {
+		for (i = 0; i < commit ; i += inc) {
+
+			if (break_test())
+				break;
 
 			if (i >= (PAGE_SIZE - offsetof(struct rb_page, data))) {
-				KILL_TEST();
+				TEST_ERROR();
 				break;
 			}
 
@@ -128,7 +136,7 @@ static enum event_status read_page(int cpu)
 			case RINGBUF_TYPE_PADDING:
 				/* failed writes may be discarded events */
 				if (!event->time_delta)
-					KILL_TEST();
+					TEST_ERROR();
 				inc = event->array[0] + 4;
 				break;
 			case RINGBUF_TYPE_TIME_EXTEND:
@@ -137,12 +145,12 @@ static enum event_status read_page(int cpu)
 			case 0:
 				entry = ring_buffer_event_data(event);
 				if (*entry != cpu) {
-					KILL_TEST();
+					TEST_ERROR();
 					break;
 				}
 				read++;
 				if (!event->array[0]) {
-					KILL_TEST();
+					TEST_ERROR();
 					break;
 				}
 				inc = event->array[0] + 4;
@@ -150,17 +158,17 @@ static enum event_status read_page(int cpu)
 			default:
 				entry = ring_buffer_event_data(event);
 				if (*entry != cpu) {
-					KILL_TEST();
+					TEST_ERROR();
 					break;
 				}
 				read++;
 				inc = ((event->type_len + 1) * 4);
 			}
-			if (kill_test)
+			if (test_error)
 				break;
 
 			if (inc <= 0) {
-				KILL_TEST();
+				TEST_ERROR();
 				break;
 			}
 		}
@@ -178,7 +186,7 @@ static void ring_buffer_consumer(void)
 	read_events ^= 1;
 
 	read = 0;
-	while (!reader_finish && !kill_test) {
+	while (!reader_finish && !break_test()) {
 		int found;
 
 		do {
@@ -193,17 +201,18 @@ static void ring_buffer_consumer(void)
 				else
 					stat = read_page(cpu);
 
-				if (kill_test)
+				if (break_test())
 					break;
 				if (stat == EVENT_FOUND)
 					found = 1;
 			}
-		} while (found && !kill_test);
+		} while (found && !break_test());
 
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (reader_finish)
+		if (reader_finish || break_test()) {
+			__set_current_state(TASK_RUNNING);
 			break;
-
+		}
 		schedule();
 	}
 	reader_finish = 0;
@@ -263,10 +272,7 @@ static void ring_buffer_producer(void)
 		if (cnt % wakeup_interval)
 			cond_resched();
 #endif
-		if (kthread_should_stop())
-			kill_test = 1;
-
-	} while (ktime_before(end_time, timeout) && !kill_test);
+	} while (ktime_before(end_time, timeout) && !break_test());
 	trace_printk("End ring buffer hammer\n");
 
 	if (consumer) {
@@ -282,7 +288,7 @@ static void ring_buffer_producer(void)
 	entries = ring_buffer_entries(buffer);
 	overruns = ring_buffer_overruns(buffer);
 
-	if (kill_test && !kthread_should_stop())
+	if (test_error)
 		trace_printk("ERROR!\n");
 
 	if (!disable_reader) {
@@ -363,15 +369,14 @@ static void wait_to_die(void)
 
 static int ring_buffer_consumer_thread(void *arg)
 {
-	while (!kthread_should_stop() && !kill_test) {
+	while (!break_test()) {
 		complete(&read_start);
 
 		ring_buffer_consumer();
 
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (kthread_should_stop() || kill_test)
+		if (break_test())
 			break;
-
 		schedule();
 	}
 	__set_current_state(TASK_RUNNING);
@@ -384,7 +389,7 @@ static int ring_buffer_consumer_thread(void *arg)
 
 static int ring_buffer_producer_thread(void *arg)
 {
-	while (!kthread_should_stop() && !kill_test) {
+	while (!break_test()) {
 		ring_buffer_reset(buffer);
 
 		if (consumer) {
@@ -393,11 +398,15 @@ static int ring_buffer_producer_thread(void *arg)
 		}
 
 		ring_buffer_producer();
-		if (kill_test)
+		if (break_test())
 			goto out_kill;
 
 		trace_printk("Sleeping for 10 secs\n");
 		set_current_state(TASK_INTERRUPTIBLE);
+		if (break_test()) {
+			__set_current_state(TASK_RUNNING);
+			goto out_kill;
+		}
 		schedule_timeout(HZ * SLEEP_TIME);
 	}
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
