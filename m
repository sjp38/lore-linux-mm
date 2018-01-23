Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD57D800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:05:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e12so10267598pgu.11
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 23:05:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7sor2946338pgq.373.2018.01.22.23.05.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 23:05:06 -0800 (PST)
Date: Tue, 23 Jan 2018 16:05:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123070501.GA489@jagdpanzerIV>
References: <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123064023.GA492@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/23/18 15:40), Sergey Senozhatsky wrote:
[..]
> Why do we even use irq_work for printk_safe?
> 
> Okay... So, how about this. For printk_safe we use system_wq for flushing.
> IOW, we flush from a task running exactly on the same CPU which hit printk
> recursion, not from IRQ. From vprintk_safe() recursion, we queue work on
> *that* CPU. Which gives us the following thing: if CPU stuck in
> console_unlock() loop with preemption disabled, then system_wq does not
> schedule on that CPU and we, thus, don't flush printk_safe buffer from that
> CPU. But if CPU can reschedule, then we are kinda OK to flush printk_safe
> buffer, printing extra messages from that CPU will not lock it up, because
> it's in preemptible context.
> 
> Thoughts?

A slightly reworked version:
a) Do not check console_locked
b) Do not have irq_work fast path for printk_safe buffer
 c) Which lets to union WQ/IRQ work structs - we use only IRQ work for
    NMI buffers, and only WQ work for SAFE buffers
 d) And also to refactor the code

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] printk/safe: use system_wq to flush printk_safe buffers

---
 kernel/printk/printk_safe.c | 52 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 40 insertions(+), 12 deletions(-)

diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index 3e3c2004bb23..6c8c82cedccb 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -22,6 +22,7 @@
 #include <linux/cpumask.h>
 #include <linux/irq_work.h>
 #include <linux/printk.h>
+#include <linux/workqueue.h>
 
 #include "internal.h"
 
@@ -49,7 +50,12 @@ static int printk_safe_irq_ready __read_mostly;
 struct printk_safe_seq_buf {
 	atomic_t		len;	/* length of written data */
 	atomic_t		message_lost;
-	struct irq_work		work;	/* IRQ work that flushes the buffer */
+	union {
+		/* IRQ work that flushes NMI buffer */
+		struct irq_work		irq_flush_work;
+		/* WQ work that flushes SAFE buffer */
+		struct work_struct	wq_flush_work;
+	};
 	unsigned char		buffer[SAFE_LOG_BUF_LEN];
 };
 
@@ -61,10 +67,18 @@ static DEFINE_PER_CPU(struct printk_safe_seq_buf, nmi_print_seq);
 #endif
 
 /* Get flushed in a more safe context. */
-static void queue_flush_work(struct printk_safe_seq_buf *s)
+static void queue_irq_flush_work(struct printk_safe_seq_buf *s)
 {
 	if (printk_safe_irq_ready)
-		irq_work_queue(&s->work);
+		irq_work_queue(&s->irq_flush_work);
+}
+
+static void queue_wq_flush_work(struct printk_safe_seq_buf *s)
+{
+	if (printk_safe_irq_ready)
+		queue_work_on(smp_processor_id(),
+				system_wq,
+				&s->wq_flush_work);
 }
 
 /*
@@ -89,7 +103,6 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	/* The trailing '\0' is not counted into len. */
 	if (len >= sizeof(s->buffer) - 1) {
 		atomic_inc(&s->message_lost);
-		queue_flush_work(s);
 		return 0;
 	}
 
@@ -112,7 +125,6 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	if (atomic_cmpxchg(&s->len, len, len + add) != len)
 		goto again;
 
-	queue_flush_work(s);
 	return add;
 }
 
@@ -186,12 +198,10 @@ static void report_message_lost(struct printk_safe_seq_buf *s)
  * Flush data from the associated per-CPU buffer. The function
  * can be called either via IRQ work or independently.
  */
-static void __printk_safe_flush(struct irq_work *work)
+static void __printk_safe_flush(struct printk_safe_seq_buf *s)
 {
 	static raw_spinlock_t read_lock =
 		__RAW_SPIN_LOCK_INITIALIZER(read_lock);
-	struct printk_safe_seq_buf *s =
-		container_of(work, struct printk_safe_seq_buf, work);
 	unsigned long flags;
 	size_t len;
 	int i;
@@ -243,6 +253,22 @@ static void __printk_safe_flush(struct irq_work *work)
 	raw_spin_unlock_irqrestore(&read_lock, flags);
 }
 
+static void irq_flush_work_fn(struct irq_work *work)
+{
+	struct printk_safe_seq_buf *s =
+		container_of(work, struct printk_safe_seq_buf, irq_flush_work);
+
+	__printk_safe_flush(s);
+}
+
+static void wq_flush_work_fn(struct work_struct *work)
+{
+	struct printk_safe_seq_buf *s =
+		container_of(work, struct printk_safe_seq_buf, wq_flush_work);
+
+	__printk_safe_flush(s);
+}
+
 /**
  * printk_safe_flush - flush all per-cpu nmi buffers.
  *
@@ -256,9 +282,9 @@ void printk_safe_flush(void)
 
 	for_each_possible_cpu(cpu) {
 #ifdef CONFIG_PRINTK_NMI
-		__printk_safe_flush(&per_cpu(nmi_print_seq, cpu).work);
+		__printk_safe_flush(this_cpu_ptr(&nmi_print_seq));
 #endif
-		__printk_safe_flush(&per_cpu(safe_print_seq, cpu).work);
+		__printk_safe_flush(this_cpu_ptr(&safe_print_seq));
 	}
 }
 
@@ -300,6 +326,7 @@ static __printf(1, 0) int vprintk_nmi(const char *fmt, va_list args)
 {
 	struct printk_safe_seq_buf *s = this_cpu_ptr(&nmi_print_seq);
 
+	queue_irq_flush_work(s);
 	return printk_safe_log_store(s, fmt, args);
 }
 
@@ -343,6 +370,7 @@ static __printf(1, 0) int vprintk_safe(const char *fmt, va_list args)
 {
 	struct printk_safe_seq_buf *s = this_cpu_ptr(&safe_print_seq);
 
+	queue_wq_flush_work(s);
 	return printk_safe_log_store(s, fmt, args);
 }
 
@@ -387,11 +415,11 @@ void __init printk_safe_init(void)
 		struct printk_safe_seq_buf *s;
 
 		s = &per_cpu(safe_print_seq, cpu);
-		init_irq_work(&s->work, __printk_safe_flush);
+		INIT_WORK(&s->wq_flush_work, wq_flush_work_fn);
 
 #ifdef CONFIG_PRINTK_NMI
 		s = &per_cpu(nmi_print_seq, cpu);
-		init_irq_work(&s->work, __printk_safe_flush);
+		init_irq_work(&s->irq_flush_work, irq_flush_work_fn);
 #endif
 	}
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
