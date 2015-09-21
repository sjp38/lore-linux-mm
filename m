Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 505DF6B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:01 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so113872321wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si16965876wic.116.2015.09.21.06.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:00 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 01/18] kthread: Allow to call __kthread_create_on_node() with va_list args
Date: Mon, 21 Sep 2015 15:03:42 +0200
Message-Id: <1442840639-6963-2-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

kthread_create_on_node() implements a bunch of logic to create
the kthread. It is already called by kthread_create_on_cpu().

We are going to add a new API that will allow to standardize kthreads
and define safe points for termination, freezing, parking, and even
signal handling. It will want to call kthread_create_on_node()
with va_list args.

This patch does only a refactoring and does not modify the existing
behavior.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/kthread.c | 72 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 42 insertions(+), 30 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 9ff173dca1ae..1d29e675fe44 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -244,33 +244,10 @@ static void create_kthread(struct kthread_create_info *create)
 	}
 }
 
-/**
- * kthread_create_on_node - create a kthread.
- * @threadfn: the function to run until signal_pending(current).
- * @data: data ptr for @threadfn.
- * @node: task and thread structures for the thread are allocated on this node
- * @namefmt: printf-style name for the thread.
- *
- * Description: This helper function creates and names a kernel
- * thread.  The thread will be stopped: use wake_up_process() to start
- * it.  See also kthread_run().  The new thread has SCHED_NORMAL policy and
- * is affine to all CPUs.
- *
- * If thread is going to be bound on a particular cpu, give its node
- * in @node, to get NUMA affinity for kthread stack, or else give NUMA_NO_NODE.
- * When woken, the thread will run @threadfn() with @data as its
- * argument. @threadfn() can either call do_exit() directly if it is a
- * standalone thread for which no one will call kthread_stop(), or
- * return when 'kthread_should_stop()' is true (which means
- * kthread_stop() has been called).  The return value should be zero
- * or a negative error number; it will be passed to kthread_stop().
- *
- * Returns a task_struct or ERR_PTR(-ENOMEM) or ERR_PTR(-EINTR).
- */
-struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
-					   void *data, int node,
-					   const char namefmt[],
-					   ...)
+static struct task_struct *__kthread_create_on_node(int (*threadfn)(void *data),
+						    void *data, int node,
+						    const char namefmt[],
+						    va_list args)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct task_struct *task;
@@ -311,11 +288,8 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	task = create->result;
 	if (!IS_ERR(task)) {
 		static const struct sched_param param = { .sched_priority = 0 };
-		va_list args;
 
-		va_start(args, namefmt);
 		vsnprintf(task->comm, sizeof(task->comm), namefmt, args);
-		va_end(args);
 		/*
 		 * root may have changed our (kthreadd's) priority or CPU mask.
 		 * The kernel thread should not inherit these properties.
@@ -326,6 +300,44 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	kfree(create);
 	return task;
 }
+
+/**
+ * kthread_create_on_node - create a kthread.
+ * @threadfn: the function to run until signal_pending(current).
+ * @data: data ptr for @threadfn.
+ * @node: task and thread structures for the thread are allocated on this node
+ * @namefmt: printf-style name for the thread.
+ *
+ * Description: This helper function creates and names a kernel
+ * thread.  The thread will be stopped: use wake_up_process() to start
+ * it.  See also kthread_run().  The new thread has SCHED_NORMAL policy and
+ * is affine to all CPUs.
+ *
+ * If thread is going to be bound on a particular cpu, give its node
+ * in @node, to get NUMA affinity for kthread stack, or else give NUMA_NO_NODE.
+ * When woken, the thread will run @threadfn() with @data as its
+ * argument. @threadfn() can either call do_exit() directly if it is a
+ * standalone thread for which no one will call kthread_stop(), or
+ * return when 'kthread_should_stop()' is true (which means
+ * kthread_stop() has been called).  The return value should be zero
+ * or a negative error number; it will be passed to kthread_stop().
+ *
+ * Returns a task_struct or ERR_PTR(-ENOMEM) or ERR_PTR(-EINTR).
+ */
+struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
+					   void *data, int node,
+					   const char namefmt[],
+					   ...)
+{
+	struct task_struct *task;
+	va_list args;
+
+	va_start(args, namefmt);
+	task = __kthread_create_on_node(threadfn, data, node, namefmt, args);
+	va_end(args);
+
+	return task;
+}
 EXPORT_SYMBOL(kthread_create_on_node);
 
 static void __kthread_bind_mask(struct task_struct *p, const struct cpumask *mask, long state)
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
