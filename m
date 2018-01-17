Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C32B6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:42:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so14799778pfi.2
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:42:07 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a18si4854283pfg.271.2018.01.17.10.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 10:42:05 -0800 (PST)
Date: Wed, 17 Jan 2018 13:42:01 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117134201.0a9cbbbf@gandalf.local.home>
In-Reply-To: <20180117121251.7283a56e@gandalf.local.home>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 17 Jan 2018 12:12:51 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> @@ -2393,15 +2451,20 @@ void console_unlock(void)
>  		 * waiter waiting to take over.
>  		 */
>  		console_lock_spinning_enable();
> +		offload = recursion_check_start();
>  
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
>  
> +		recursion_check_finish(offload);
> +
>  		if (console_lock_spinning_disable_and_check()) {
>  			printk_safe_exit_irqrestore(flags);
>  			return;
>  		}
> +		if (offload)
> +			kick_offload_thread();
>  

Ah, major flaw in this code. The recursion check needs to be in
printk() itself around the trylock.

-- Steve

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 9cb943c90d98..31df145cc4d7 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1826,6 +1826,63 @@ static size_t log_output(int facility, int level, enum log_flags lflags, const c
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
+
+static bool recursion_check_start(void)
+{
+	unsigned long pc = preempt_count();
+	int val = this_cpu_read(recursion_bits);
+
+	if (!(pc & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
+		bit = CTX_NORMAL;
+	else
+		bit = pc & NMI_MASK ? CTX_NMI :
+			pc & HARDIRQ_MASK ? CTX_IRQ : CTX_SOFTIRQ;
+
+	if (unlikely(val & (1 << bit)))
+		return true;
+
+	val |= (1 << bit);
+	this_cpu_write(recursion_bits, val);
+	return false;
+}
+
+static void recursion_check_finish(bool offload)
+{
+	int val = this_cpu_read(recursion_bits);
+
+	if (offload)
+		return;
+
+	val &= val - 1;
+	this_cpu_write(recursion_bits, val);
+}
+
+static void kick_offload_thread(void)
+{
+	/*
+	 * Consoles are triggering printks, offload the printks
+	 * to another CPU to hopefully avoid a lockup.
+	 */
+}
 
 asmlinkage int vprintk_emit(int facility, int level,
 			    const char *dict, size_t dictlen,
@@ -1895,12 +1952,14 @@ asmlinkage int vprintk_emit(int facility, int level,
 
 	/* If called from the scheduler, we can not call up(). */
 	if (!in_sched) {
+		bool offload;
 		/*
 		 * Disable preemption to avoid being preempted while holding
 		 * console_sem which would prevent anyone from printing to
 		 * console
 		 */
 		preempt_disable();
+		offload = recursion_check_start();
 		/*
 		 * Try to acquire and then immediately release the console
 		 * semaphore.  The release will print out buffers and wake up
@@ -1908,7 +1967,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (console_trylock_spinning())
 			console_unlock();
+
+		recursion_check_finish(offload);
 		preempt_enable();
+
+		if (offload)
+			kick_offload_thread();
 	}
 
 	return printed_len;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
