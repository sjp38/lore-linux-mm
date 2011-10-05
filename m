Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F916900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:10:29 -0400 (EDT)
Subject: Re: [PATCH] mm, arch: Complete pagefault_disable abstraction
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 05 Oct 2011 15:10:24 +0200
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317820224.6766.21.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>


For reference, here's the -rt patch that goes on top:

---
Subject: rt: Preemptable pagefault_disable()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed Oct 05 14:20:57 CEST 2011

Implement a preemptable pagefault_disable() by keeping a per-task
pagefault_disabled counter.

This allows disabling of the pagefault handler (and thus avoiding the
recursive fault/mmap_sem issues) without disabling preemption.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/sched.h   |    9 ++++++++-
 include/linux/uaccess.h |    5 +++++
 kernel/fork.c           |    3 +++
 mm/memory.c             |   24 ++++++++++++++++++++++++
 4 files changed, 40 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/uaccess.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/uaccess.h
+++ linux-2.6/include/linux/uaccess.h
@@ -4,6 +4,7 @@
 #include <linux/preempt.h>
 #include <asm/uaccess.h>
=20
+#ifndef CONFIG_PREEMPT_RT_FULL
 /*
  * These routines enable/disable the pagefault handler in that
  * it will not take any locks and go straight to the fixup table.
@@ -37,6 +38,10 @@ static inline void pagefault_enable(void
 	barrier();
 	preempt_check_resched();
 }
+#else
+extern void pagefault_disable(void);
+extern void pagefault_enable(void);
+#endif
=20
 #ifndef ARCH_HAS_NOCACHE_UACCESS
=20
Index: linux-2.6/kernel/fork.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -1200,6 +1200,9 @@ static struct task_struct *copy_process(
 	p->hardirq_context =3D 0;
 	p->softirq_context =3D 0;
 #endif
+#ifdef CONFIG_PREEMPT_RT_FULL
+	p->pagefault_disabled =3D 0;
+#endif
 #ifdef CONFIG_LOCKDEP
 	p->lockdep_depth =3D 0; /* no locks held yet */
 	p->curr_chain_key =3D 0;
Index: linux-2.6/mm/memory.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -3436,6 +3436,30 @@ int handle_pte_fault(struct mm_struct *m
 	return 0;
 }
=20
+#ifdef CONFIG_PREEMPT_RT_FULL
+void pagefault_disable(void)
+{
+	current->pagefault_disabled++;
+	/*
+	 * make sure to have issued the store before a pagefault
+	 * can hit.
+	 */
+	barrier();
+}
+EXPORT_SYMBOL_GPL(pagefault_disable);
+
+void pagefault_enable(void)
+{
+	/*
+	 * make sure to issue those last loads/stores before enabling
+	 * the pagefault handler again.
+	 */
+	barrier();
+	current->pagefault_disabled--;
+}
+EXPORT_SYMBOL_GPL(pagefault_enable);
+#endif
+
 /*
  * By the time we get here, we already hold the mm semaphore
  */
Index: linux-2.6/include/linux/sched.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1434,6 +1434,9 @@ struct task_struct {
 	/* mutex deadlock detection */
 	struct mutex_waiter *blocked_on;
 #endif
+#ifdef CONFIG_PREEMPT_RT_FULL
+	int pagefault_disabled;
+#endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int irq_events;
 	unsigned long hardirq_enable_ip;
@@ -1578,7 +1581,11 @@ struct task_struct {
=20
 static inline bool pagefault_disabled(void)
 {
-	return in_atomic();
+	return in_atomic()
+#ifdef CONFIG_PREEMPT_RT_FULL
+		|| current->pagefault_disabled
+#endif
+		;
 }
=20
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
