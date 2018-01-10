Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1A336B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:24:43 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id m1so1458449pls.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:24:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si11730285pfl.33.2018.01.10.05.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 05:24:42 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v5 1/2] printk: Add console owner and waiter logic to load balance console writes
Date: Wed, 10 Jan 2018 14:24:17 +0100
Message-Id: <20180110132418.7080-2-pmladek@suse.com>
In-Reply-To: <20180110132418.7080-1-pmladek@suse.com>
References: <20180110132418.7080-1-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>

From: Steven Rostedt (VMware) <rostedt@goodmis.org>

This patch implements what I discussed in Kernel Summit. I added
lockdep annotation (hopefully correctly), and it hasn't had any splats
(since I fixed some bugs in the first iterations). It did catch
problems when I had the owner covering too much. But now that the owner
is only set when actively calling the consoles, lockdep has stayed
quiet.

Here's the design again:

I added a "console_owner" which is set to a task that is actively
writing to the consoles. It is *not* the same as the owner of the
console_lock. It is only set when doing the calls to the console
functions. It is protected by a console_owner_lock which is a raw spin
lock.

There is a console_waiter. This is set when there is an active console
owner that is not current, and waiter is not set. This too is protected
by console_owner_lock.

In printk() when it tries to write to the consoles, we have:

	if (console_trylock())
		console_unlock();

Now I added an else, which will check if there is an active owner, and
no current waiter. If that is the case, then console_waiter is set, and
the task goes into a spin until it is no longer set.

When the active console owner finishes writing the current message to
the consoles, it grabs the console_owner_lock and sees if there is a
waiter, and clears console_owner.

If there is a waiter, then it breaks out of the loop, clears the waiter
flag (because that will release the waiter from its spin), and exits.
Note, it does *not* release the console semaphore. Because it is a
semaphore, there is no owner. Another task may release it. This means
that the waiter is guaranteed to be the new console owner! Which it
becomes.

Then the waiter calls console_unlock() and continues to write to the
consoles.

If another task comes along and does a printk() it too can become the
new waiter, and we wash rinse and repeat!

By Petr Mladek about possible new deadlocks:

The thing is that we move console_sem only to printk() call
that normally calls console_unlock() as well. It means that
the transferred owner should not bring new type of dependencies.
As Steven said somewhere: "If there is a deadlock, it was
there even before."

We could look at it from this side. The possible deadlock would
look like:

CPU0                            CPU1

console_unlock()

  console_owner = current;

				spin_lockA()
				  printk()
				    spin = true;
				    while (...)

    call_console_drivers()
      spin_lockA()

This would be a deadlock. CPU0 would wait for the lock A.
While CPU1 would own the lockA and would wait for CPU0
to finish calling the console drivers and pass the console_sem
owner.

But if the above is true than the following scenario was
already possible before:

CPU0

spin_lockA()
  printk()
    console_unlock()
      call_console_drivers()
	spin_lockA()

By other words, this deadlock was there even before. Such
deadlocks are prevented by using printk_deferred() in
the sections guarded by the lock A.

Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
[pmladek@suse.com: Commit message about possible deadlocks]
---
 kernel/printk/printk.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 107 insertions(+), 1 deletion(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index b9006617710f..7e6459abba43 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -86,8 +86,15 @@ EXPORT_SYMBOL_GPL(console_drivers);
 static struct lockdep_map console_lock_dep_map = {
 	.name = "console_lock"
 };
+static struct lockdep_map console_owner_dep_map = {
+	.name = "console_owner"
+};
 #endif
 
+static DEFINE_RAW_SPINLOCK(console_owner_lock);
+static struct task_struct *console_owner;
+static bool console_waiter;
+
 enum devkmsg_log_bits {
 	__DEVKMSG_LOG_BIT_ON = 0,
 	__DEVKMSG_LOG_BIT_OFF,
@@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 * semaphore.  The release will print out buffers and wake up
 		 * /dev/kmsg and syslog() users.
 		 */
-		if (console_trylock())
+		if (console_trylock()) {
 			console_unlock();
+		} else {
+			struct task_struct *owner = NULL;
+			bool waiter;
+			bool spin = false;
+
+			printk_safe_enter_irqsave(flags);
+
+			raw_spin_lock(&console_owner_lock);
+			owner = READ_ONCE(console_owner);
+			waiter = READ_ONCE(console_waiter);
+			if (!waiter && owner && owner != current) {
+				WRITE_ONCE(console_waiter, true);
+				spin = true;
+			}
+			raw_spin_unlock(&console_owner_lock);
+
+			/*
+			 * If there is an active printk() writing to the
+			 * consoles, instead of having it write our data too,
+			 * see if we can offload that load from the active
+			 * printer, and do some printing ourselves.
+			 * Go into a spin only if there isn't already a waiter
+			 * spinning, and there is an active printer, and
+			 * that active printer isn't us (recursive printk?).
+			 */
+			if (spin) {
+				/* We spin waiting for the owner to release us */
+				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+				/* Owner will clear console_waiter on hand off */
+				while (READ_ONCE(console_waiter))
+					cpu_relax();
+
+				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+				printk_safe_exit_irqrestore(flags);
+
+				/*
+				 * The owner passed the console lock to us.
+				 * Since we did not spin on console lock, annotate
+				 * this as a trylock. Otherwise lockdep will
+				 * complain.
+				 */
+				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
+				console_unlock();
+				printk_safe_enter_irqsave(flags);
+			}
+			printk_safe_exit_irqrestore(flags);
+
+		}
 	}
 
 	return printed_len;
@@ -2141,6 +2196,7 @@ void console_unlock(void)
 	static u64 seen_seq;
 	unsigned long flags;
 	bool wake_klogd = false;
+	bool waiter = false;
 	bool do_cond_resched, retry;
 
 	if (console_suspended) {
@@ -2229,14 +2285,64 @@ void console_unlock(void)
 		console_seq++;
 		raw_spin_unlock(&logbuf_lock);
 
+		/*
+		 * While actively printing out messages, if another printk()
+		 * were to occur on another CPU, it may wait for this one to
+		 * finish. This task can not be preempted if there is a
+		 * waiter waiting to take over.
+		 */
+		raw_spin_lock(&console_owner_lock);
+		console_owner = current;
+		raw_spin_unlock(&console_owner_lock);
+
+		/* The waiter may spin on us after setting console_owner */
+		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
+
+		raw_spin_lock(&console_owner_lock);
+		waiter = READ_ONCE(console_waiter);
+		console_owner = NULL;
+		raw_spin_unlock(&console_owner_lock);
+
+		/*
+		 * If there is a waiter waiting for us, then pass the
+		 * rest of the work load over to that waiter.
+		 */
+		if (waiter)
+			break;
+
+		/* There was no waiter, and nothing will spin on us here */
+		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+
 		printk_safe_exit_irqrestore(flags);
 
 		if (do_cond_resched)
 			cond_resched();
 	}
+
+	/*
+	 * If there is an active waiter waiting on the console_lock.
+	 * Pass off the printing to the waiter, and the waiter
+	 * will continue printing on its CPU, and when all writing
+	 * has finished, the last printer will wake up klogd.
+	 */
+	if (waiter) {
+		WRITE_ONCE(console_waiter, false);
+		/* The waiter is now free to continue */
+		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
+		/*
+		 * Hand off console_lock to waiter. The waiter will perform
+		 * the up(). After this, the waiter is the console_lock owner.
+		 */
+		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
+		printk_safe_exit_irqrestore(flags);
+		/* Note, if waiter is set, logbuf_lock is not held */
+		return;
+	}
+
 	console_locked = 0;
 
 	/* Release the exclusive_console once it is used */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
