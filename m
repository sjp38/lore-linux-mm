Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0046E828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so54975447wmw.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iq7si45740590wjb.143.2016.04.14.08.15.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:39 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 13/20] hung_task: Convert hungtaskd into kthread worker API
Date: Thu, 14 Apr 2016 17:14:32 +0200
Message-Id: <1460646879-617-14-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
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

This patch moves one iteration of the main cycle into a self-queuing
delayed kthread work. It does not longer check if it was called
earlier. Instead, the work is scheduled only when needed. This
requires storing the time of the last check into a global
variable.

Also the check is not longer schedule with MAX_SCHEDULE_TIMEOUT
when it is disabled. Instead the work is canceled and it is
not queued at all.

There is a small race window when sysctl_hung_task_timeout_secs
might be modified between queuing and processing the work.
Therefore the lapsed time has to be computed explicitly.

The user nice and initial hung_task_last_checked values are
set from hung_task_init(). Otherwise, we would need to add
an extra init_work.

The patch also handles the error when the kthread worker could not
be crated from some reasons. It was broken before. For example,
wake_up_process would have failed if watchdog_task included an error
code instead of a valid pointer.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: linux-watchdog@vger.kernel.org
---
 kernel/hung_task.c | 83 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 50 insertions(+), 33 deletions(-)

diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index d234022805dc..9070c822abd8 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -36,12 +36,15 @@ int __read_mostly sysctl_hung_task_check_count = PID_MAX_LIMIT;
  * Zero means infinite timeout - no checking done:
  */
 unsigned long __read_mostly sysctl_hung_task_timeout_secs = CONFIG_DEFAULT_HUNG_TASK_TIMEOUT;
+unsigned long hung_task_last_checked;
 
 int __read_mostly sysctl_hung_task_warnings = 10;
 
 static int __read_mostly did_panic;
 
-static struct task_struct *watchdog_task;
+static struct kthread_worker *watchdog_worker;
+static void watchdog_check_func(struct kthread_work *dummy);
+static DEFINE_DELAYED_KTHREAD_WORK(watchdog_check_work, watchdog_check_func);
 
 /*
  * Should we panic (and reboot, if panic_timeout= is set) when a
@@ -72,7 +75,7 @@ static struct notifier_block panic_block = {
 	.notifier_call = hung_task_panic,
 };
 
-static void check_hung_task(struct task_struct *t, unsigned long timeout)
+static void check_hung_task(struct task_struct *t, unsigned long lapsed)
 {
 	unsigned long switch_count = t->nvcsw + t->nivcsw;
 
@@ -109,7 +112,7 @@ static void check_hung_task(struct task_struct *t, unsigned long timeout)
 	 * complain:
 	 */
 	pr_err("INFO: task %s:%d blocked for more than %ld seconds.\n",
-		t->comm, t->pid, timeout);
+		t->comm, t->pid, lapsed);
 	pr_err("      %s %s %.*s\n",
 		print_tainted(), init_utsname()->release,
 		(int)strcspn(init_utsname()->version, " "),
@@ -155,7 +158,7 @@ static bool rcu_lock_break(struct task_struct *g, struct task_struct *t)
  * a really long time (120 seconds). If that happens, print out
  * a warning.
  */
-static void check_hung_uninterruptible_tasks(unsigned long timeout)
+static void check_hung_uninterruptible_tasks(unsigned long lapsed)
 {
 	int max_count = sysctl_hung_task_check_count;
 	int batch_count = HUNG_TASK_BATCHING;
@@ -179,20 +182,12 @@ static void check_hung_uninterruptible_tasks(unsigned long timeout)
 		}
 		/* use "==" to skip the TASK_KILLABLE tasks waiting on NFS */
 		if (t->state == TASK_UNINTERRUPTIBLE)
-			check_hung_task(t, timeout);
+			check_hung_task(t, lapsed);
 	}
  unlock:
 	rcu_read_unlock();
 }
 
-static long hung_timeout_jiffies(unsigned long last_checked,
-				 unsigned long timeout)
-{
-	/* timeout of 0 will disable the watchdog */
-	return timeout ? last_checked - jiffies + timeout * HZ :
-		MAX_SCHEDULE_TIMEOUT;
-}
-
 /*
  * Process updating of timeout sysctl
  */
@@ -201,13 +196,26 @@ int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
 				  size_t *lenp, loff_t *ppos)
 {
 	int ret;
+	long remaining;
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 
-	if (ret || !write)
+	if (ret || !write || !watchdog_worker)
+		goto out;
+
+	/* Disable watchdog when there is a zero timeout */
+	if (!sysctl_hung_task_timeout_secs) {
+		cancel_delayed_kthread_work_sync(&watchdog_check_work);
 		goto out;
+	}
 
-	wake_up_process(watchdog_task);
+	/* Reschedule the check according to the updated timeout */
+	remaining = sysctl_hung_task_timeout_secs * HZ -
+		    (jiffies - hung_task_last_checked);
+	if (remaining < 0)
+		remaining = 0;
+	mod_delayed_kthread_work(watchdog_worker, &watchdog_check_work,
+				 remaining);
 
  out:
 	return ret;
@@ -221,36 +229,45 @@ void reset_hung_task_detector(void)
 }
 EXPORT_SYMBOL_GPL(reset_hung_task_detector);
 
+static void schedule_next_watchdog_check(void)
+{
+	unsigned long timeout = READ_ONCE(sysctl_hung_task_timeout_secs);
+
+	hung_task_last_checked = jiffies;
+	if (timeout)
+		queue_delayed_kthread_work(watchdog_worker,
+					   &watchdog_check_work,
+					   timeout * HZ);
+}
+
 /*
  * kthread which checks for tasks stuck in D state
  */
-static int watchdog(void *dummy)
+static void watchdog_check_func(struct kthread_work *dummy)
 {
-	unsigned long hung_last_checked = jiffies;
+	unsigned long lapsed = (jiffies - hung_task_last_checked) / HZ;
 
-	set_user_nice(current, 0);
+	if (!atomic_xchg(&reset_hung_task, 0))
+		check_hung_uninterruptible_tasks(lapsed);
 
-	for ( ; ; ) {
-		unsigned long timeout = sysctl_hung_task_timeout_secs;
-		long t = hung_timeout_jiffies(hung_last_checked, timeout);
-
-		if (t <= 0) {
-			if (!atomic_xchg(&reset_hung_task, 0))
-				check_hung_uninterruptible_tasks(timeout);
-			hung_last_checked = jiffies;
-			continue;
-		}
-		schedule_timeout_interruptible(t);
-	}
-
-	return 0;
+	schedule_next_watchdog_check();
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
+	schedule_next_watchdog_check();
 
+ out:
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
