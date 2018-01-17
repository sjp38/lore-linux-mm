Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 134CD6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:12:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q8so9020322pfh.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:12:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r11si4880762plo.624.2018.01.17.09.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 09:12:55 -0800 (PST)
Date: Wed, 17 Jan 2018 12:12:51 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117121251.7283a56e@gandalf.local.home>
In-Reply-To: <20180117151509.GT3460072@devbig577.frc2.facebook.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 17 Jan 2018 07:15:09 -0800
Tejun Heo <tj@kernel.org> wrote:

> It's great that Steven's patches solve a good number of problems.  It
> is also true that there's a class of problems that it doesn't solve,
> which other approaches do.  The productive thing to do here is trying
> to solve the unsolved one too, especially given that it doesn't seem
> too difficuilt to do so on top of what's proposed.

OK, let's talk about the other problems, as this is no longer related
to my patch.

=46rom your previous email:

> 1. Console is IPMI emulated serial console.  Super slow.  Also
>    netconsole is in use.
> 2. System runs out of memory, OOM triggers.
> 3. OOM handler is printing out OOM debug info.
> 4. While trying to emit the messages for netconsole, the network stack
>    / driver tries to allocate memory and then fail, which in turn
>    triggers allocation failure or other warning messages.  printk was
>    already flushing, so the messages are queued on the ring.
> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>    shrinking.  Because OOM handler is trapped in printk flushing, it
>    never manages to free memory and no one else can enter OOM path
>    either, so the system is trapped in this state.

=46rom what I gathered, you said an OOM would trigger, and then the
network console would not be able to allocate memory and it would
trigger a printk too, and cause an infinite amount of printks.

This could very well be a great place to force offloading. If a printk
is called from within a printk, at the same context (normal, softirq,
irq or NMI), then we should trigger the offloading.

My ftrace ring buffer has a context level recursion check, we could use
that, and even tie it into my previous patch:

With something like this (not compiled tested or anything, and
kick_offload_thread() would need to be implemented).

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 9cb943c90d98..b80b23a0ca13 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2261,6 +2261,63 @@ static int have_callable_console(void)
=20
 	return 0;
 }
+/*
+ * Used for which context the printk is in.
+ *  NMI     =3D 0
+ *  IRQ     =3D 1
+ *  SOFTIRQ =3D 2
+ *  NORMAL  =3D 3
+ *
+ * Stack ordered, where the lower number can preempt
+ * the higher number: mask &=3D mask - 1, will only clear
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
+	unsigned long pc =3D preempt_count();
+	int val =3D this_cpu_read(recursion_bits);
+
+	if (!(pc & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
+		bit =3D CTX_NORMAL;
+	else
+		bit =3D pc & NMI_MASK ? CTX_NMI :
+			pc & HARDIRQ_MASK ? CTX_IRQ : CTX_SOFTIRQ;
+
+	if (unlikely(val & (1 << bit)))
+		return true;
+
+	val |=3D (1 << bit);
+	this_cpu_write(recursion_bits, val);
+	return false;
+}
+
+static void recursion_check_finish(bool offload)
+{
+	int val =3D this_cpu_read(recursion_bits);
+
+	if (offload)
+		return;
+
+	val &=3D val - 1;
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
=20
 /*
  * Can we actually use the console at this time on this cpu?
@@ -2333,6 +2390,7 @@ void console_unlock(void)
=20
 	for (;;) {
 		struct printk_log *msg;
+		bool offload;
 		size_t ext_len =3D 0;
 		size_t len;
=20
@@ -2393,15 +2451,20 @@ void console_unlock(void)
 		 * waiter waiting to take over.
 		 */
 		console_lock_spinning_enable();
+		offload =3D recursion_check_start();
=20
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
=20
+		recursion_check_finish(offload);
+
 		if (console_lock_spinning_disable_and_check()) {
 			printk_safe_exit_irqrestore(flags);
 			return;
 		}
+		if (offload)
+			kick_offload_thread();
=20
 		printk_safe_exit_irqrestore(flags);
=20

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
