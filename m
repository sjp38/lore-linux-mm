Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 63849828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:19 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so69425146wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk5si29191533wjb.9.2016.01.25.07.48.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:18 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 16/22] kmemleak: Convert kmemleak kthread into kthread worker API
Date: Mon, 25 Jan 2016 16:45:05 +0100
Message-Id: <1453736711-6703-17-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Catalin Marinas <catalin.marinas@arm.com>

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

This patch converts the kmemleak kthread into the kthread worker
API because it modifies the scheduling priority.

The result is a simple self-queuing work that just calls kmemleak_scan().

The info messages and set_user_nice() are moved to the functions that
start and stop the worker. These are also renamed to mention worker
instead of thread.

We do not longer need to handle a spurious wakeup and count the remaining
timeout. It is handled by the worker. The delayed work is queued after
the full timeout passes.

Finally, the initial delay is done only when the kthread is started
during the boot. For this we added a parameter to the start function.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 87 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 43 insertions(+), 44 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 25c0ad36fe38..16f1a7bb1697 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -216,7 +216,8 @@ static int kmemleak_error;
 static unsigned long min_addr = ULONG_MAX;
 static unsigned long max_addr;
 
-static struct task_struct *scan_thread;
+static struct kthread_worker *kmemleak_scan_worker;
+static struct delayed_kthread_work kmemleak_scan_work;
 /* used to avoid reporting of recently allocated objects */
 static unsigned long jiffies_min_age;
 static unsigned long jiffies_last_scan;
@@ -1470,54 +1471,48 @@ static void kmemleak_scan(void)
 }
 
 /*
- * Thread function performing automatic memory scanning. Unreferenced objects
- * at the end of a memory scan are reported but only the first time.
+ * Kthread worker function performing automatic memory scanning.
+ * Unreferenced objects at the end of a memory scan are reported
+ * but only the first time.
  */
-static int kmemleak_scan_thread(void *arg)
+static void kmemleak_scan_func(struct kthread_work *dummy)
 {
-	static int first_run = 1;
-
-	pr_info("Automatic memory scanning thread started\n");
-	set_user_nice(current, 10);
-
-	/*
-	 * Wait before the first scan to allow the system to fully initialize.
-	 */
-	if (first_run) {
-		first_run = 0;
-		ssleep(SECS_FIRST_SCAN);
-	}
-
-	while (!kthread_should_stop()) {
-		signed long timeout = jiffies_scan_wait;
-
-		mutex_lock(&scan_mutex);
-		kmemleak_scan();
-		mutex_unlock(&scan_mutex);
-
-		/* wait before the next scan */
-		while (timeout && !kthread_should_stop())
-			timeout = schedule_timeout_interruptible(timeout);
-	}
-
-	pr_info("Automatic memory scanning thread ended\n");
+	mutex_lock(&scan_mutex);
+	kmemleak_scan();
+	mutex_unlock(&scan_mutex);
 
-	return 0;
+	queue_delayed_kthread_work(kmemleak_scan_worker, &kmemleak_scan_work,
+				   jiffies_scan_wait);
 }
 
 /*
  * Start the automatic memory scanning thread. This function must be called
  * with the scan_mutex held.
  */
-static void start_scan_thread(void)
+static void start_scan_thread(bool boot)
 {
-	if (scan_thread)
+	unsigned long timeout = 0;
+
+	if (kmemleak_scan_worker)
 		return;
-	scan_thread = kthread_run(kmemleak_scan_thread, NULL, "kmemleak");
-	if (IS_ERR(scan_thread)) {
-		pr_warning("Failed to create the scan thread\n");
-		scan_thread = NULL;
+
+	init_delayed_kthread_work(&kmemleak_scan_work, kmemleak_scan_func);
+	kmemleak_scan_worker = create_kthread_worker(0, "kmemleak");
+	if (IS_ERR(kmemleak_scan_worker)) {
+		pr_warn("Failed to create the memory scan worker\n");
+		kmemleak_scan_worker = NULL;
 	}
+	pr_info("Automatic memory scanning thread started\n");
+	set_user_nice(kmemleak_scan_worker->task, 10);
+
+	/*
+	 * Wait before the first scan to allow the system to fully initialize.
+	 */
+	if (boot)
+		timeout = msecs_to_jiffies(SECS_FIRST_SCAN * MSEC_PER_SEC);
+
+	queue_delayed_kthread_work(kmemleak_scan_worker, &kmemleak_scan_work,
+				   timeout);
 }
 
 /*
@@ -1526,10 +1521,14 @@ static void start_scan_thread(void)
  */
 static void stop_scan_thread(void)
 {
-	if (scan_thread) {
-		kthread_stop(scan_thread);
-		scan_thread = NULL;
-	}
+	if (!kmemleak_scan_worker)
+		return;
+
+	cancel_delayed_kthread_work_sync(&kmemleak_scan_work);
+	destroy_kthread_worker(kmemleak_scan_worker);
+	kmemleak_scan_worker = NULL;
+
+	pr_info("Automatic memory scanning thread ended\n");
 }
 
 /*
@@ -1726,7 +1725,7 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	else if (strncmp(buf, "stack=off", 9) == 0)
 		kmemleak_stack_scan = 0;
 	else if (strncmp(buf, "scan=on", 7) == 0)
-		start_scan_thread();
+		start_scan_thread(false);
 	else if (strncmp(buf, "scan=off", 8) == 0)
 		stop_scan_thread();
 	else if (strncmp(buf, "scan=", 5) == 0) {
@@ -1738,7 +1737,7 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		stop_scan_thread();
 		if (secs) {
 			jiffies_scan_wait = msecs_to_jiffies(secs * 1000);
-			start_scan_thread();
+			start_scan_thread(false);
 		}
 	} else if (strncmp(buf, "scan", 4) == 0)
 		kmemleak_scan();
@@ -1962,7 +1961,7 @@ static int __init kmemleak_late_init(void)
 	if (!dentry)
 		pr_warning("Failed to create the debugfs kmemleak file\n");
 	mutex_lock(&scan_mutex);
-	start_scan_thread();
+	start_scan_thread(true);
 	mutex_unlock(&scan_mutex);
 
 	pr_info("Kernel memory leak detector initialized\n");
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
