Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 542306B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 13:20:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id q8so2391410pfh.12
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:20:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a24si8487180pgw.394.2018.01.19.10.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 10:20:56 -0800 (PST)
Date: Fri, 19 Jan 2018 13:20:52 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180119132052.02b89626@gandalf.local.home>
In-Reply-To: <20180117134201.0a9cbbbf@gandalf.local.home>
References: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180111203057.5b1a8f8f@gandalf.local.home>
	<20180111215547.2f66a23a@gandalf.local.home>
	<20180116194456.GS3460072@devbig577.frc2.facebook.com>
	<20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
	<20180117151509.GT3460072@devbig577.frc2.facebook.com>
	<20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Tejun,

I was thinking about this a bit more, and instead of offloading a
recursive printk, perhaps its best to simply throttle it. Because the
problem may not go away if a printk thread takes over, because the bug
is really the printk infrastructure filling the printk buffer keeping
printk from ever stopping.

This patch detects that printk is causing itself to print more and
throttles it after 3 messages have printed due to recursion. Could you
see if this helps your test cases?

I built this on top of linux-next (yesterday's branch).

It compiles and boots, but I didn't do any other tests on it.

Thanks!

-- Steve

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 9cb943c90d98..2c7f18876224 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1826,6 +1826,75 @@ static size_t log_output(int facility, int level, enum log_flags lflags, const c
 	/* Store it in the record log */
 	return log_store(facility, level, lflags, 0, dict, dictlen, text, text_len);
 }
+/*
+ * Used for which context the printk is in.
+ *  NMI     = 0
+ *  IRQ     = 1
+ *  SOFTIRQ = 2
+ *  NORMAL  = 3
+ *
+ * Stack ordered, where the lower number can preempt
+ * the higher number: mask &= mask - 1, will only clear
+ * the lowerest set bit.
+ */
+enum {
+	CTX_NMI,
+	CTX_IRQ,
+	CTX_SOFTIRQ,
+	CTX_NORMAL,
+};
+
+static DEFINE_PER_CPU(int, recursion_bits);
+static DEFINE_PER_CPU(int, recursion_count);
+static atomic_t recursion_overflow;
+static const int recursion_max = 3;
+
+static int __recursion_check_test(int val)
+{
+	unsigned long pc = preempt_count();
+	int bit;
+
+	if (!(pc & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
+		bit = CTX_NORMAL;
+	else
+		bit = pc & NMI_MASK ? CTX_NMI :
+			pc & HARDIRQ_MASK ? CTX_IRQ : CTX_SOFTIRQ;
+
+	return val & (1 << bit);
+}
+
+static bool recursion_check_test(void)
+{
+	int val = this_cpu_read(recursion_bits);
+
+	return __recursion_check_test(val);
+}
+
+static bool recursion_check_start(void)
+{
+	int val = this_cpu_read(recursion_bits);
+	int set;
+
+	set = __recursion_check_test(val);
+
+	if (unlikely(set))
+		return true;
+
+	val |= set;
+	this_cpu_write(recursion_bits, val);
+	return false;
+}
+
+static void recursion_check_finish(bool recursion)
+{
+	int val = this_cpu_read(recursion_bits);
+
+	if (recursion)
+		return;
+
+	val &= val - 1;
+	this_cpu_write(recursion_bits, val);
+}
 
 asmlinkage int vprintk_emit(int facility, int level,
 			    const char *dict, size_t dictlen,
@@ -1849,6 +1918,17 @@ asmlinkage int vprintk_emit(int facility, int level,
 
 	/* This stops the holder of console_sem just where we want him */
 	logbuf_lock_irqsave(flags);
+
+	if (recursion_check_test()) {
+		/* A printk happened within a printk at the same context */
+		if (this_cpu_inc_return(recursion_count) > recursion_max) {
+			atomic_inc(&recursion_overflow);
+			logbuf_unlock_irqrestore(flags);
+			printed_len = 0;
+			goto out;
+		}
+	}
+
 	/*
 	 * The printf needs to come first; we need the syslog
 	 * prefix which might be passed-in as a parameter.
@@ -1895,12 +1975,14 @@ asmlinkage int vprintk_emit(int facility, int level,
 
 	/* If called from the scheduler, we can not call up(). */
 	if (!in_sched) {
+		bool recursion;
 		/*
 		 * Disable preemption to avoid being preempted while holding
 		 * console_sem which would prevent anyone from printing to
 		 * console
 		 */
 		preempt_disable();
+		recursion = recursion_check_start();
 		/*
 		 * Try to acquire and then immediately release the console
 		 * semaphore.  The release will print out buffers and wake up
@@ -1908,9 +1990,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (console_trylock_spinning())
 			console_unlock();
+
+		recursion_check_finish(recursion);
+		this_cpu_write(recursion_count, 0);
 		preempt_enable();
 	}
-
+out:
 	return printed_len;
 }
 EXPORT_SYMBOL(vprintk_emit);
@@ -2343,9 +2428,14 @@ void console_unlock(void)
 			seen_seq = log_next_seq;
 		}
 
-		if (console_seq < log_first_seq) {
+		if (console_seq < log_first_seq || atomic_read(&recursion_overflow)) {
+			size_t missed;
+
+			missed = atomic_xchg(&recursion_overflow, 0);
+			missed += log_first_seq - console_seq;
+
 			len = sprintf(text, "** %u printk messages dropped **\n",
-				      (unsigned)(log_first_seq - console_seq));
+				      (unsigned)missed);
 
 			/* messages are gone, move to first one */
 			console_seq = log_first_seq;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
