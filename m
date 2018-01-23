Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68229800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:40:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i1so10184003pgv.22
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 22:40:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15-v6sor846850pli.49.2018.01.22.22.40.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 22:40:28 -0800 (PST)
Date: Tue, 23 Jan 2018 15:40:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123064023.GA492@jagdpanzerIV>
References: <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180121141521.GA429@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On (01/21/18 23:15), Sergey Senozhatsky wrote:
[..]
> we have printk recursion from console drivers. it's redirected to
> printk_safe and we queue an IRQ work to flush the buffer
> 
>  printk
>   console_unlock
>    call_console_drivers
>     net_console
>      printk
>       printk_save -> irq_work queue
> 
> now console_unlock() enables local IRQs, we have the printk_safe
> flush. but printk_safe flush does not call into the console_unlock(),
> it uses printk_deferred() version of printk
> 
> IRQ work
> 
>  prink_safe_flush
>   printk_deferred -> irq_work queue
> 
> 
> so we schedule another IRQ work (deferred printk work), which eventually
> tries to lock console_sem
> 
> IRQ work
>  wake_up_klogd_work_func()
>   if (console_trylock())
>    console_unlock()

Why do we even use irq_work for printk_safe?

Okay... So, how about this. For printk_safe we use system_wq for flushing.
IOW, we flush from a task running exactly on the same CPU which hit printk
recursion, not from IRQ. From vprintk_safe() recursion, we queue work on
*that* CPU. Which gives us the following thing: if CPU stuck in
console_unlock() loop with preemption disabled, then system_wq does not
schedule on that CPU and we, thus, don't flush printk_safe buffer from that
CPU. But if CPU can reschedule, then we are kinda OK to flush printk_safe
buffer, printing extra messages from that CPU will not lock it up, because
it's in preemptible context.

Thoughts?


Something like this:

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] printk/safe: use slowpath flush for printk_safe

---
 kernel/printk/printk_safe.c | 53 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 48 insertions(+), 5 deletions(-)

diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index 3e3c2004bb23..c641853a5fa9 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -22,6 +22,8 @@
 #include <linux/cpumask.h>
 #include <linux/irq_work.h>
 #include <linux/printk.h>
+#include <linux/console.h>
+#include <linux/workqueue.h>
 
 #include "internal.h"
 
@@ -50,6 +52,7 @@ struct printk_safe_seq_buf {
 	atomic_t		len;	/* length of written data */
 	atomic_t		message_lost;
 	struct irq_work		work;	/* IRQ work that flushes the buffer */
+	struct work_struct	slowpath_flush_work;
 	unsigned char		buffer[SAFE_LOG_BUF_LEN];
 };
 
@@ -61,12 +64,20 @@ static DEFINE_PER_CPU(struct printk_safe_seq_buf, nmi_print_seq);
 #endif
 
 /* Get flushed in a more safe context. */
-static void queue_flush_work(struct printk_safe_seq_buf *s)
+static void queue_irq_flush_work(struct printk_safe_seq_buf *s)
 {
 	if (printk_safe_irq_ready)
 		irq_work_queue(&s->work);
 }
 
+static void queue_slowpath_flush_work(struct printk_safe_seq_buf *s)
+{
+	if (printk_safe_irq_ready)
+		queue_work_on(smp_processor_id(),
+				system_wq,
+				&s->slowpath_flush_work);
+}
+
 /*
  * Add a message to per-CPU context-dependent buffer. NMI and printk-safe
  * have dedicated buffers, because otherwise printk-safe preempted by
@@ -89,7 +100,7 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	/* The trailing '\0' is not counted into len. */
 	if (len >= sizeof(s->buffer) - 1) {
 		atomic_inc(&s->message_lost);
-		queue_flush_work(s);
+		queue_irq_flush_work(s);
 		return 0;
 	}
 
@@ -112,7 +123,6 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	if (atomic_cmpxchg(&s->len, len, len + add) != len)
 		goto again;
 
-	queue_flush_work(s);
 	return add;
 }
 
@@ -243,6 +253,35 @@ static void __printk_safe_flush(struct irq_work *work)
 	raw_spin_unlock_irqrestore(&read_lock, flags);
 }
 
+/* NMI buffers are always flushed */
+static void flush_nmi_buffer(struct irq_work *work)
+{
+	__printk_safe_flush(work);
+}
+
+/* printk_safe buffers flushing, on the contrary, can be postponed */
+static void flush_printk_safe_buffer(struct irq_work *work)
+{
+	struct printk_safe_seq_buf *s =
+		container_of(work, struct printk_safe_seq_buf, work);
+
+	if (is_console_locked()) {
+		queue_slowpath_flush_work(s);
+		return;
+	}
+
+	__printk_safe_flush(work);
+}
+
+static void slowpath_flush_work_fn(struct work_struct *work)
+{
+	struct printk_safe_seq_buf *s =
+		container_of(work, struct printk_safe_seq_buf,
+				slowpath_flush_work);
+
+	__printk_safe_flush(&s->work);
+}
+
 /**
  * printk_safe_flush - flush all per-cpu nmi buffers.
  *
@@ -300,6 +339,7 @@ static __printf(1, 0) int vprintk_nmi(const char *fmt, va_list args)
 {
 	struct printk_safe_seq_buf *s = this_cpu_ptr(&nmi_print_seq);
 
+	queue_irq_flush_work(s);
 	return printk_safe_log_store(s, fmt, args);
 }
 
@@ -343,6 +383,7 @@ static __printf(1, 0) int vprintk_safe(const char *fmt, va_list args)
 {
 	struct printk_safe_seq_buf *s = this_cpu_ptr(&safe_print_seq);
 
+	queue_slowpath_flush_work(s);
 	return printk_safe_log_store(s, fmt, args);
 }
 
@@ -387,11 +428,13 @@ void __init printk_safe_init(void)
 		struct printk_safe_seq_buf *s;
 
 		s = &per_cpu(safe_print_seq, cpu);
-		init_irq_work(&s->work, __printk_safe_flush);
+		init_irq_work(&s->work, flush_printk_safe_buffer);
+		INIT_WORK(&s->slowpath_flush_work, slowpath_flush_work_fn);
 
 #ifdef CONFIG_PRINTK_NMI
 		s = &per_cpu(nmi_print_seq, cpu);
-		init_irq_work(&s->work, __printk_safe_flush);
+		init_irq_work(&s->work, flush_nmi_buffer);
+		/* we don't use slowpath flush for NMI */
 #endif
 	}
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
