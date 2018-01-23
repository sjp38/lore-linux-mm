Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38C4C800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:12:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o28so489941pgn.6
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:12:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 85sor744985pfz.13.2018.01.23.08.12.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 08:12:24 -0800 (PST)
Date: Wed, 24 Jan 2018 01:12:21 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123161221.GD429@tigerII.localdomain>
References: <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
 <20180123154347.GE1771050@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123154347.GE1771050@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Tejun

On (01/23/18 07:43), Tejun Heo wrote:
> Hello, Steven.
> 
> On Tue, Jan 23, 2018 at 10:41:21AM -0500, Steven Rostedt wrote:
> > > I don't want to have heuristics in print_safe, I don't want to have a magic
> > > number controlled by a user-space visible knob, I don't want to have the
> > > first 3 lines of a lockdep splat.
> > 
> > We can have more. But if printk is causing printks, that's a major bug.
> > And work queues are not going to fix it, it will just spread out the
> > pain. Have it be 100 printks, it needs to be fixed if it is happening.
> > And having all printks just generate more printks is not helpful. Even
> > if we slow them down. They will still never end.
> 
> So, at least in the case that we were seeing, it isn't that black and
> white.  printk keeps causing printks but only because printk buffer
> flushing is preventing the printk'ing context from making forward
> progress.  The key problem there is that a flushing context may get
> pinned flushing indefinitely and using a separate context does solve
> the problem.

Would you, as the original bug reporter, be OK if we flush printk_safe (only
printk_safe, not printk_nmi for the time being) via WQ? This should move that
"uncontrolled" flush to a safe context. I don't think we can easily add
kthread offloading to printk at the moment (this will result in a massive gun
fight).

Just in case, below is something like a patch. I think I worked around the
possible wq deadlock scenario. But I haven't tested the patch yet. It's
a bit late here and I guess I need some rest. Will try to look more at
it tomorrow.

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] printk/safe: split flush works

---
 kernel/printk/printk_safe.c | 75 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 63 insertions(+), 12 deletions(-)

diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index 3e3c2004bb23..54bc40ce3c34 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -22,6 +22,7 @@
 #include <linux/cpumask.h>
 #include <linux/irq_work.h>
 #include <linux/printk.h>
+#include <linux/workqueue.h>
 
 #include "internal.h"
 
@@ -49,7 +50,10 @@ static int printk_safe_irq_ready __read_mostly;
 struct printk_safe_seq_buf {
 	atomic_t		len;	/* length of written data */
 	atomic_t		message_lost;
-	struct irq_work		work;	/* IRQ work that flushes the buffer */
+	/* IRQ work that flushes NMI buffer */
+	struct irq_work		irq_flush_work;
+	/* WQ work that flushes SAFE buffer */
+	struct work_struct	wq_flush_work;
 	unsigned char		buffer[SAFE_LOG_BUF_LEN];
 };
 
@@ -61,10 +65,18 @@ static DEFINE_PER_CPU(struct printk_safe_seq_buf, nmi_print_seq);
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
@@ -89,7 +101,7 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	/* The trailing '\0' is not counted into len. */
 	if (len >= sizeof(s->buffer) - 1) {
 		atomic_inc(&s->message_lost);
-		queue_flush_work(s);
+		queue_irq_flush_work(s);
 		return 0;
 	}
 
@@ -112,7 +124,7 @@ static __printf(2, 0) int printk_safe_log_store(struct printk_safe_seq_buf *s,
 	if (atomic_cmpxchg(&s->len, len, len + add) != len)
 		goto again;
 
-	queue_flush_work(s);
+	queue_irq_flush_work(s);
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
@@ -243,6 +253,46 @@ static void __printk_safe_flush(struct irq_work *work)
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
+/*
+ * We can't queue wq work directly from vprintk_safe(), because we can
+ * deadlock. For instance:
+ *
+ * queue_work()
+ *  spin_lock(pool->lock)
+ *   printk()
+ *    call_console_drivers()
+ *     vprintk_safe()
+ *      queue_work()
+ *       spin_lock(pool->lock)
+ *
+ * So we use irq_work, from which we queue wq work. WQ disables local IRQs
+ * while it works with pool, so if we have irq_work on that CPU then we can
+ * expect that pool->lock is not locked.
+ */
+static void irq_to_wq_flush_work_fn(struct irq_work *work)
+{
+	struct printk_safe_seq_buf *s =
+		container_of(work, struct printk_safe_seq_buf, irq_flush_work);
+
+	queue_wq_flush_work(s);
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
@@ -256,9 +306,9 @@ void printk_safe_flush(void)
 
 	for_each_possible_cpu(cpu) {
 #ifdef CONFIG_PRINTK_NMI
-		__printk_safe_flush(&per_cpu(nmi_print_seq, cpu).work);
+		__printk_safe_flush(this_cpu_ptr(&nmi_print_seq));
 #endif
-		__printk_safe_flush(&per_cpu(safe_print_seq, cpu).work);
+		__printk_safe_flush(this_cpu_ptr(&safe_print_seq));
 	}
 }
 
@@ -387,11 +437,12 @@ void __init printk_safe_init(void)
 		struct printk_safe_seq_buf *s;
 
 		s = &per_cpu(safe_print_seq, cpu);
-		init_irq_work(&s->work, __printk_safe_flush);
+		init_irq_work(&s->irq_flush_work, irq_to_wq_flush_work_fn);
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
