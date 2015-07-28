Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B93BC6B0260
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:30 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so160501381wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si20790133wiv.76.2015.07.28.07.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:19 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 13/14] kthread_worker: Add set_kthread_worker_user_nice()
Date: Tue, 28 Jul 2015 16:39:30 +0200
Message-Id: <1438094371-8326-14-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

kthread worker API will be used for kthreads that need to modify
the scheduling priority.

This patch adds a function that allows to make it easily, safe way,
and hides implementation details. It might even help to get rid
of an init work.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h              |  2 ++
 kernel/kthread.c                     | 14 ++++++++++++++
 kernel/trace/ring_buffer_benchmark.c |  3 ++-
 mm/huge_memory.c                     | 10 +---------
 4 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index d916b024e986..b75847e1a4c9 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -142,6 +142,8 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 #define create_kthread_worker(worker, flags, namefmt, arg...)		\
 	create_kthread_worker_on_node(worker, flags, -1, namefmt, ##arg)
 
+void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice);
+
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void flush_kthread_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index d02509e17f7e..ab2e235b6144 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -648,6 +648,20 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL(create_kthread_worker_on_node);
 
+/*
+ * set_kthread_worker_user_nice - set scheduling priority for the kthread worker
+ * @worker: target kthread_worker
+ * @nice: niceness value
+ */
+void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice)
+{
+	struct task_struct *task = worker->task;
+
+	WARN_ON(!task);
+	set_user_nice(task, nice);
+}
+EXPORT_SYMBOL(set_kthread_worker_user_nice);
+
 /* insert @work before @pos in @worker */
 static void insert_kthread_work(struct kthread_worker *worker,
 			       struct kthread_work *work,
diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 5036d284885c..73e4c7f11a2c 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -476,7 +476,8 @@ static int __init ring_buffer_benchmark_init(void)
 		sched_setscheduler(rb_producer_worker.task,
 				   SCHED_FIFO, &param);
 	} else
-		set_user_nice(rb_producer_worker.task, producer_nice);
+		set_kthread_worker_user_nice(&rb_producer_worker,
+					     producer_nice);
 
 	return 0;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 51a514161f2b..1d5f990c55ab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -55,12 +55,10 @@ static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
 
-static void khugepaged_init_func(struct kthread_work *dummy);
 static void khugepaged_do_scan_func(struct kthread_work *dummy);
 static void khugepaged_wait_func(struct kthread_work *dummy);
 static void khugepaged_cleanup_func(struct kthread_work *dummy);
 static DEFINE_KTHREAD_WORKER(khugepaged_worker);
-static DEFINE_KTHREAD_WORK(khugepaged_init_work, khugepaged_init_func);
 static DEFINE_KTHREAD_WORK(khugepaged_do_scan_work, khugepaged_do_scan_func);
 static DEFINE_KTHREAD_WORK(khugepaged_wait_work, khugepaged_wait_func);
 static DEFINE_KTHREAD_WORK(khugepaged_cleanup_work, khugepaged_cleanup_func);
@@ -167,8 +165,7 @@ static int start_stop_khugepaged(void)
 			goto out;
 		}
 
-		queue_kthread_work(&khugepaged_worker,
-				   &khugepaged_init_work);
+		set_kthread_worker_user_nice(&khugepaged_worker, MAX_NICE);
 
 		if (list_empty(&khugepaged_scan.mm_head))
 			queue_kthread_work(&khugepaged_worker,
@@ -2803,11 +2800,6 @@ static int khugepaged_wait_event(void)
 		!khugepaged_enabled());
 }
 
-static void khugepaged_init_func(struct kthread_work *dummy)
-{
-	set_user_nice(current, MAX_NICE);
-}
-
 static void khugepaged_do_scan_func(struct kthread_work *dummy)
 {
 	struct page *hpage = NULL;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
