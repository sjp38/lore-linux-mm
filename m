Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA3E56B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:56:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g6so6409510pgn.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:56:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v1si2564770plb.505.2017.11.02.08.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 08:56:29 -0700 (PDT)
Date: Thu, 2 Nov 2017 11:56:25 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171102115625.13892e18@gandalf.local.home>
In-Reply-To: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>


Hi Tetsuo,

Can you see if this patch helps your situation?

OK, for the rest of you. Let's have the showdown ;-)

This patch implements what I discussed in Kernel Summit. I added
lockdep annotation (hopefully correctly), and it hasn't had any splats
(since I fixed some bugs in the first iterations). It did catch
problems when I had the owner covering too much. But now that the owner
is only set when actively calling the consoles, lockdep has stayed
quiet.


Here's the design again:

I added a "console_owner" which is set to a task that is actively
writing to the consoles. It is *not* the same an the owner of the
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

OK, let at it :-)

-- Steve

Not-yet-signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
Index: linux-trace.git/kernel/printk/printk.c
===================================================================
--- linux-trace.git.orig/kernel/printk/printk.c
+++ linux-trace.git/kernel/printk/printk.c
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
@@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
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
+			waiter = console_waiter;
+			if (!waiter && owner && owner != current) {
+				console_waiter = true;
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
+				mutex_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+				/* Owner will clear console_waiter on hand off */
+				while (!READ_ONCE(console_waiter))
+					cpu_relax();
+
+				mutex_release(&console_owner_dep_map, 1, _THIS_IP_);
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
@@ -2215,6 +2271,20 @@ skip:
 			goto skip;
 		}
 
+		/*
+		 * While actively printing out messages, if another printk()
+		 * were to occur on another CPU, it may wait for this one to
+		 * finish. This task can not be preempted if there is a
+		 * waiter waiting to take over.
+		 */
+
+		/* The waiter may spin on us after this */
+		mutex_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
+
+		raw_spin_lock(&console_owner_lock);
+		console_owner = current;
+		raw_spin_unlock(&console_owner_lock);
+
 		len += msg_print_text(msg, false, text + len, sizeof(text) - len);
 		if (nr_ext_console_drivers) {
 			ext_len = msg_print_ext_header(ext_text,
@@ -2232,11 +2302,48 @@ skip:
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
+		mutex_release(&console_owner_dep_map, 1, _THIS_IP_);
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
+		console_waiter = false;
+		/* The waiter is now free to continue */
+		mutex_release(&console_owner_dep_map, 1, _THIS_IP_);
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
