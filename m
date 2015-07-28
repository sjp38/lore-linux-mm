Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 078B66B025C
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:21 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so160494135wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d3si20842431wiy.0.2015.07.28.07.40.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:13 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 09/14] ring_buffer: Initialize completions statically in the benchmark
Date: Tue, 28 Jul 2015 16:39:26 +0200
Message-Id: <1438094371-8326-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

It looks strange to initialize the completions repeatedly.

This patch uses static initialization. It simplifies the code
and even helps to get rid of two memory barriers.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/trace/ring_buffer_benchmark.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index a1503a027ee2..ccb1a0b95f64 100644
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
@@ -270,11 +270,6 @@ static void ring_buffer_producer(void)
 	trace_printk("End ring buffer hammer\n");
 
 	if (consumer) {
-		/* Init both completions here to avoid races */
-		init_completion(&read_start);
-		init_completion(&read_done);
-		/* the completions must be visible before the finish var */
-		smp_wmb();
 		reader_finish = 1;
 		/* finish var visible before waking up the consumer */
 		smp_wmb();
@@ -389,13 +384,10 @@ static int ring_buffer_consumer_thread(void *arg)
 
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
