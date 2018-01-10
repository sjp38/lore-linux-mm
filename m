Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD6C6B0260
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:24:47 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f8so11397198pgs.9
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:24:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si1006348pgs.499.2018.01.10.05.24.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 05:24:45 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Date: Wed, 10 Jan 2018 14:24:18 +0100
Message-Id: <20180110132418.7080-3-pmladek@suse.com>
In-Reply-To: <20180110132418.7080-1-pmladek@suse.com>
References: <20180110132418.7080-1-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The commit ("printk: Add console owner and waiter logic to load balance
console writes") made vprintk_emit() and console_unlock() even more
complicated.

This patch extracts the new code into 3 helper functions. They should
help to keep it rather self-contained. It will be easier to use and
maintain.

This patch just shuffles the existing code. It does not change
the functionality.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/printk/printk.c | 242 +++++++++++++++++++++++++++++--------------------
 1 file changed, 145 insertions(+), 97 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 7e6459abba43..6217c280e6c1 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -86,15 +86,8 @@ EXPORT_SYMBOL_GPL(console_drivers);
 static struct lockdep_map console_lock_dep_map = {
 	.name = "console_lock"
 };
-static struct lockdep_map console_owner_dep_map = {
-	.name = "console_owner"
-};
 #endif
 
-static DEFINE_RAW_SPINLOCK(console_owner_lock);
-static struct task_struct *console_owner;
-static bool console_waiter;
-
 enum devkmsg_log_bits {
 	__DEVKMSG_LOG_BIT_ON = 0,
 	__DEVKMSG_LOG_BIT_OFF,
@@ -1551,6 +1544,143 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
 }
 
 /*
+ * Special console_lock variants that help to reduce the risk of soft-lockups.
+ * They allow to pass console_lock to another printk() call using a busy wait.
+ */
+
+#ifdef CONFIG_LOCKDEP
+static struct lockdep_map console_owner_dep_map = {
+	.name = "console_owner"
+};
+#endif
+
+static DEFINE_RAW_SPINLOCK(console_owner_lock);
+static struct task_struct *console_owner;
+static bool console_waiter;
+
+/**
+ * console_lock_spinning_enable - mark beginning of code where another
+ *	thread might safely busy wait
+ *
+ * This might be called in sections where the current console_lock owner
+ * cannot sleep. It is a signal that another thread might start busy
+ * waiting for console_lock.
+ */
+static void console_lock_spinning_enable(void)
+{
+	raw_spin_lock(&console_owner_lock);
+	console_owner = current;
+	raw_spin_unlock(&console_owner_lock);
+
+	/* The waiter may spin on us after setting console_owner */
+	spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+}
+
+/**
+ * console_lock_spinning_disable_and_check - mark end of code where another
+ *	thread was able to busy wait and check if there is a waiter
+ *
+ * This is called at the end of section when spinning was enabled by
+ * console_lock_spinning_enable(). It has two functions. First, it
+ * is a signal that it is not longer safe to start busy waiting
+ * for the lock. Second, it checks if there is a busy waiter and
+ * passes the lock rights to her.
+ *
+ * Important: Callers lose the lock if there was the busy waiter.
+ *	They must not longer touch items synchornized by console_lock
+ *	in this case.
+ *
+ * Return: 1 if the lock rights were passed, 0 othrewise.
+ */
+static int console_lock_spinning_disable_and_check(void)
+{
+	int waiter;
+
+	raw_spin_lock(&console_owner_lock);
+	waiter = READ_ONCE(console_waiter);
+	console_owner = NULL;
+	raw_spin_unlock(&console_owner_lock);
+
+	if (!waiter) {
+		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+		return 0;
+	}
+
+	/* The waiter is now free to continue */
+	WRITE_ONCE(console_waiter, false);
+
+	spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+
+	/*
+	 * Hand off console_lock to waiter. The waiter will perform
+	 * the up(). After this, the waiter is the console_lock owner.
+	 */
+	mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
+	return 1;
+}
+
+/**
+ * console_trylock_spinning - try to get console_lock by busy waiting
+ *
+ * This allows to busy wait for the console_lock when the current
+ * owner is running in a special marked sections. It means that
+ * the current owner is running and cannot reschedule until it
+ * is ready to loose the lock.
+ *
+ * Return: 1 if we got the lock, 0 othrewise
+ */
+static int console_trylock_spinning(void)
+{
+	struct task_struct *owner = NULL;
+	bool waiter;
+	bool spin = false;
+	unsigned long flags;
+
+	printk_safe_enter_irqsave(flags);
+
+	raw_spin_lock(&console_owner_lock);
+	owner = READ_ONCE(console_owner);
+	waiter = READ_ONCE(console_waiter);
+	if (!waiter && owner && owner != current) {
+		WRITE_ONCE(console_waiter, true);
+		spin = true;
+	}
+	raw_spin_unlock(&console_owner_lock);
+
+	/*
+	 * If there is an active printk() writing to the
+	 * consoles, instead of having it write our data too,
+	 * see if we can offload that load from the active
+	 * printer, and do some printing ourselves.
+	 * Go into a spin only if there isn't already a waiter
+	 * spinning, and there is an active printer, and
+	 * that active printer isn't us (recursive printk?).
+	 */
+	if (!spin) {
+		printk_safe_exit_irqrestore(flags);
+		return 0;
+	}
+
+	/* We spin waiting for the owner to release us */
+	spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+	/* Owner will clear console_waiter on hand off */
+	while (READ_ONCE(console_waiter))
+		cpu_relax();
+	spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+
+	printk_safe_exit_irqrestore(flags);
+	/*
+	 * The owner passed the console lock to us.
+	 * Since we did not spin on console lock, annotate
+	 * this as a trylock. Otherwise lockdep will
+	 * complain.
+	 */
+	mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
+
+	return 1;
+}
+
+/*
  * Call the console drivers, asking them to write out
  * log_buf[start] to log_buf[end - 1].
  * The console_lock must be held.
@@ -1760,56 +1890,8 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 * semaphore.  The release will print out buffers and wake up
 		 * /dev/kmsg and syslog() users.
 		 */
-		if (console_trylock()) {
+		if (console_trylock() || console_trylock_spinning())
 			console_unlock();
-		} else {
-			struct task_struct *owner = NULL;
-			bool waiter;
-			bool spin = false;
-
-			printk_safe_enter_irqsave(flags);
-
-			raw_spin_lock(&console_owner_lock);
-			owner = READ_ONCE(console_owner);
-			waiter = READ_ONCE(console_waiter);
-			if (!waiter && owner && owner != current) {
-				WRITE_ONCE(console_waiter, true);
-				spin = true;
-			}
-			raw_spin_unlock(&console_owner_lock);
-
-			/*
-			 * If there is an active printk() writing to the
-			 * consoles, instead of having it write our data too,
-			 * see if we can offload that load from the active
-			 * printer, and do some printing ourselves.
-			 * Go into a spin only if there isn't already a waiter
-			 * spinning, and there is an active printer, and
-			 * that active printer isn't us (recursive printk?).
-			 */
-			if (spin) {
-				/* We spin waiting for the owner to release us */
-				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
-				/* Owner will clear console_waiter on hand off */
-				while (READ_ONCE(console_waiter))
-					cpu_relax();
-
-				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
-				printk_safe_exit_irqrestore(flags);
-
-				/*
-				 * The owner passed the console lock to us.
-				 * Since we did not spin on console lock, annotate
-				 * this as a trylock. Otherwise lockdep will
-				 * complain.
-				 */
-				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
-				console_unlock();
-				printk_safe_enter_irqsave(flags);
-			}
-			printk_safe_exit_irqrestore(flags);
-
-		}
 	}
 
 	return printed_len;
@@ -1910,6 +1992,8 @@ static ssize_t msg_print_ext_header(char *buf, size_t size,
 static ssize_t msg_print_ext_body(char *buf, size_t size,
 				  char *dict, size_t dict_len,
 				  char *text, size_t text_len) { return 0; }
+static void console_lock_spinning_enable(void) { }
+static int console_lock_spinning_disable_and_check(void) { return 0; }
 static void call_console_drivers(const char *ext_text, size_t ext_len,
 				 const char *text, size_t len) {}
 static size_t msg_print_text(const struct printk_log *msg,
@@ -2196,7 +2280,6 @@ void console_unlock(void)
 	static u64 seen_seq;
 	unsigned long flags;
 	bool wake_klogd = false;
-	bool waiter = false;
 	bool do_cond_resched, retry;
 
 	if (console_suspended) {
@@ -2291,31 +2374,16 @@ void console_unlock(void)
 		 * finish. This task can not be preempted if there is a
 		 * waiter waiting to take over.
 		 */
-		raw_spin_lock(&console_owner_lock);
-		console_owner = current;
-		raw_spin_unlock(&console_owner_lock);
-
-		/* The waiter may spin on us after setting console_owner */
-		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+		console_lock_spinning_enable();
 
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
 
-		raw_spin_lock(&console_owner_lock);
-		waiter = READ_ONCE(console_waiter);
-		console_owner = NULL;
-		raw_spin_unlock(&console_owner_lock);
-
-		/*
-		 * If there is a waiter waiting for us, then pass the
-		 * rest of the work load over to that waiter.
-		 */
-		if (waiter)
-			break;
-
-		/* There was no waiter, and nothing will spin on us here */
-		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+		if (console_lock_spinning_disable_and_check()) {
+			printk_safe_exit_irqrestore(flags);
+			return;
+		}
 
 		printk_safe_exit_irqrestore(flags);
 
@@ -2323,26 +2391,6 @@ void console_unlock(void)
 			cond_resched();
 	}
 
-	/*
-	 * If there is an active waiter waiting on the console_lock.
-	 * Pass off the printing to the waiter, and the waiter
-	 * will continue printing on its CPU, and when all writing
-	 * has finished, the last printer will wake up klogd.
-	 */
-	if (waiter) {
-		WRITE_ONCE(console_waiter, false);
-		/* The waiter is now free to continue */
-		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
-		/*
-		 * Hand off console_lock to waiter. The waiter will perform
-		 * the up(). After this, the waiter is the console_lock owner.
-		 */
-		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
-		printk_safe_exit_irqrestore(flags);
-		/* Note, if waiter is set, logbuf_lock is not held */
-		return;
-	}
-
 	console_locked = 0;
 
 	/* Release the exclusive_console once it is used */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
