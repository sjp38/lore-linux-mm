Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7F93D6B025D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:41 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so110290331wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si30956903wjy.116.2015.09.21.06.05.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:36 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 10/18] ring_buffer: Do no not complete benchmark reader too early
Date: Mon, 21 Sep 2015 15:03:51 +0200
Message-Id: <1442840639-6963-11-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

It seems that complete(&read_done) might be called too early
in some situations.

1st scenario:
-------------

CPU0					CPU1

ring_buffer_producer_thread()
  wake_up_process(consumer);
  wait_for_completion(&read_start);

					ring_buffer_consumer_thread()
					  complete(&read_start);

  ring_buffer_producer()
    # producing data in
    # the do-while cycle

					  ring_buffer_consumer();
					    # reading data
					    # got error
					    # set kill_test = 1;
					    set_current_state(
						TASK_INTERRUPTIBLE);
					    if (reader_finish)  # false
					    schedule();

    # producer still in the middle of
    # do-while cycle
    if (consumer && !(cnt % wakeup_interval))
      wake_up_process(consumer);

					    # spurious wakeup
					    while (!reader_finish &&
						   !kill_test)
					    # leaving because
					    # kill_test == 1
					    reader_finish = 0;
					    complete(&read_done);

1st BANG: We might access uninitialized "read_done" if this is the
	  the first round.

    # producer finally leaving
    # the do-while cycle because kill_test == 1;

    if (consumer) {
      reader_finish = 1;
      wake_up_process(consumer);
      wait_for_completion(&read_done);

2nd BANG: This will never complete because consumer already did
	  the completion.

2nd scenario:
-------------

CPU0					CPU1

ring_buffer_producer_thread()
  wake_up_process(consumer);
  wait_for_completion(&read_start);

					ring_buffer_consumer_thread()
					  complete(&read_start);

  ring_buffer_producer()
    # CPU3 removes the module	  <--- difference from
    # and stops producer          <--- the 1st scenario
    if (kthread_should_stop())
      kill_test = 1;

					  ring_buffer_consumer();
					    while (!reader_finish &&
						   !kill_test)
					    # kill_test == 1 => we never go
					    # into the top level while()
					    reader_finish = 0;
					    complete(&read_done);

    # producer still in the middle of
    # do-while cycle
    if (consumer && !(cnt % wakeup_interval))
      wake_up_process(consumer);

					    # spurious wakeup
					    while (!reader_finish &&
						   !kill_test)
					    # leaving because kill_test == 1
					    reader_finish = 0;
					    complete(&read_done);

BANG: We are in the same "bang" situations as in the 1st scenario.

Root of the problem:
--------------------

ring_buffer_consumer() must complete "read_done" only when "reader_finish"
variable is set. It must not be skipped due to other conditions.

Note that we still must keep the check for "reader_finish" in a loop
because there might be spurious wakeups as described in the
above scenarios.

Solution:
----------

The top level cycle in ring_buffer_consumer() will finish only when
"reader_finish" is set. The data will be read in "while-do" cycle
so that they are not read after an error (kill_test == 1)
or a spurious wake up.

In addition, "reader_finish" is manipulated by the producer thread.
Therefore we add READ_ONCE() to make sure that the fresh value is
read in each cycle. Also we add the corresponding barrier
to synchronize the sleep check.

Next we set the state back to TASK_RUNNING for the situation where we
did not sleep.

Just from paranoid reasons, we initialize both completions statically.
This is safer, in case there are other races that we are unaware of.

As a side effect we could remove the memory barrier from
ring_buffer_producer_thread(). IMHO, this was the reason for
the barrier. ring_buffer_reset() uses spin locks that should
provide the needed memory barrier for using the buffer.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/trace/ring_buffer_benchmark.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index a1503a027ee2..9ea7949366b3 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -24,8 +24,8 @@ struct rb_page {
 static int wakeup_interval = 100;
 
 static int reader_finish;
-static struct completion read_start;
-static struct completion read_done;
+static DECLARE_COMPLETION(read_start);
+static DECLARE_COMPLETION(read_done);
 
 static struct ring_buffer *buffer;
 static struct task_struct *producer;
@@ -178,10 +178,14 @@ static void ring_buffer_consumer(void)
 	read_events ^= 1;
 
 	read = 0;
-	while (!reader_finish && !kill_test) {
-		int found;
+	/*
+	 * Continue running until the producer specifically asks to stop
+	 * and is ready for the completion.
+	 */
+	while (!READ_ONCE(reader_finish)) {
+		int found = 1;
 
-		do {
+		while (found && !kill_test) {
 			int cpu;
 
 			found = 0;
@@ -195,17 +199,23 @@ static void ring_buffer_consumer(void)
 
 				if (kill_test)
 					break;
+
 				if (stat == EVENT_FOUND)
 					found = 1;
+
 			}
-		} while (found && !kill_test);
+		}
 
+		/* Wait till the producer wakes us up when there is more data
+		 * available or when the producer wants us to finish reading.
+		 */
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (reader_finish)
 			break;
 
 		schedule();
 	}
+	__set_current_state(TASK_RUNNING);
 	reader_finish = 0;
 	complete(&read_done);
 }
@@ -389,13 +399,10 @@ static int ring_buffer_consumer_thread(void *arg)
 
 static int ring_buffer_producer_thread(void *arg)
 {
-	init_completion(&read_start);
-
 	while (!kthread_should_stop() && !kill_test) {
 		ring_buffer_reset(buffer);
 
 		if (consumer) {
-			smp_wmb();
 			wake_up_process(consumer);
 			wait_for_completion(&read_start);
 		}
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
