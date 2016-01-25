Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 64900828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:17 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n5so86673272wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t126si25093692wmb.118.2016.01.25.07.48.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:16 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 15/22] hung_task: Convert hungtaskd into kthread worker API
Date: Mon, 25 Jan 2016 16:45:04 +0100
Message-Id: <1453736711-6703-16-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, linux-watchdog@vger.kernel.org

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

This patch converts hungtaskd() in kthread worker API because
it modifies the priority.

The conversion is pretty straightforward. One iteration of the
main cycle is transferred into a self-queuing delayed kthread work.
We do not longer need to check if it was waken earlier. Instead,
the work timeout is modified when the timeout value is changed.

The user nice value is set from hung_task_init(). Otherwise, we
would need to add an extra init_work.

The patch also handles the error when the kthead worker could not
be crated from some reasons. It was broken before. For example,
wake_up_process would have failed if watchdog_task inclueded an error
code instead of a valid pointer.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: linux-watchdog@vger.kernel.org
---
 kernel/hung_task.c | 41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index e0f90c2b57aa..65026f8b750e 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -41,7 +41,9 @@ int __read_mostly sysctl_hung_task_warnings = 10;
 
 static int __read_mostly did_panic;
 
-static struct task_struct *watchdog_task;
+static struct kthread_worker *watchdog_worker;
+static void watchdog_func(struct kthread_work *dummy);
+static DEFINE_DELAYED_KTHREAD_WORK(watchdog_work, watchdog_func);
 
 /*
  * Should we panic (and reboot, if panic_timeout= is set) when a
@@ -205,7 +207,9 @@ int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
 	if (ret || !write)
 		goto out;
 
-	wake_up_process(watchdog_task);
+	if (watchdog_worker)
+		mod_delayed_kthread_work(watchdog_worker, &watchdog_work,
+			 timeout_jiffies(sysctl_hung_task_timeout_secs));
 
  out:
 	return ret;
@@ -222,30 +226,35 @@ EXPORT_SYMBOL_GPL(reset_hung_task_detector);
 /*
  * kthread which checks for tasks stuck in D state
  */
-static int watchdog(void *dummy)
+static void watchdog_func(struct kthread_work *dummy)
 {
-	set_user_nice(current, 0);
+	unsigned long timeout = sysctl_hung_task_timeout_secs;
 
-	for ( ; ; ) {
-		unsigned long timeout = sysctl_hung_task_timeout_secs;
+	if (atomic_xchg(&reset_hung_task, 0))
+		goto next;
 
-		while (schedule_timeout_interruptible(timeout_jiffies(timeout)))
-			timeout = sysctl_hung_task_timeout_secs;
+	check_hung_uninterruptible_tasks(timeout);
 
-		if (atomic_xchg(&reset_hung_task, 0))
-			continue;
-
-		check_hung_uninterruptible_tasks(timeout);
-	}
-
-	return 0;
+next:
+	queue_delayed_kthread_work(watchdog_worker, &watchdog_work,
+				   timeout_jiffies(timeout));
 }
 
 static int __init hung_task_init(void)
 {
+	struct kthread_worker *worker;
+
 	atomic_notifier_chain_register(&panic_notifier_list, &panic_block);
-	watchdog_task = kthread_run(watchdog, NULL, "khungtaskd");
+	worker = create_kthread_worker(0, "khungtaskd");
+	if (IS_ERR(worker)) {
+		pr_warn("Failed to create khungtaskd\n");
+		goto out;
+	}
+	watchdog_worker = worker;
+	set_user_nice(worker->task, 0);
+	queue_delayed_kthread_work(worker, &watchdog_work, 0);
 
+out:
 	return 0;
 }
 subsys_initcall(hung_task_init);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
