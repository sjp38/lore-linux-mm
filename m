Message-Id: <20081002131608.260230952@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:14 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/32] mm: allow PF_MEMALLOC from softirq context
Content-Disposition: inline; filename=mm-PF_MEMALLOC-softirq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

This is needed to allow network softirq packet processing to make use of
PF_MEMALLOC.

Currently softirq context cannot use PF_MEMALLOC due to it not being associated
with a task, and therefore not having task flags to fiddle with - thus the gfp
to alloc flag mapping ignores the task flags when in interrupts (hard or soft)
context.

Allowing softirqs to make use of PF_MEMALLOC therefore requires some trickery.
We basically borrow the task flags from whatever process happens to be
preempted by the softirq.

So we modify the gfp to alloc flags mapping to not exclude task flags in
softirq context, and modify the softirq code to save, clear and restore the
PF_MEMALLOC flag.

The save and clear, ensures the preempted task's PF_MEMALLOC flag doesn't
leak into the softirq. The restore ensures a softirq's PF_MEMALLOC flag cannot
leak back into the preempted process.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/sched.h |    7 +++++++
 kernel/softirq.c      |    3 +++
 mm/page_alloc.c       |    7 ++++---
 3 files changed, 14 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1449,9 +1449,10 @@ int gfp_to_alloc_flags(gfp_t gfp_mask)
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_interrupt() &&
-		    ((p->flags & PF_MEMALLOC) ||
-		     unlikely(test_thread_flag(TIF_MEMDIE))))
+		if (!in_irq() && (p->flags & PF_MEMALLOC))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_interrupt() &&
+				unlikely(test_thread_flag(TIF_MEMDIE)))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 
Index: linux-2.6/kernel/softirq.c
===================================================================
--- linux-2.6.orig/kernel/softirq.c
+++ linux-2.6/kernel/softirq.c
@@ -213,6 +213,8 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long pflags = current->flags;
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -251,6 +253,7 @@ restart:
 
 	account_system_vtime(current);
 	_local_bh_enable();
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1533,6 +1533,13 @@ static inline void put_task_struct(struc
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
+static inline void tsk_restore_flags(struct task_struct *p,
+				     unsigned long pflags, unsigned long mask)
+{
+	p->flags &= ~mask;
+	p->flags |= pflags & mask;
+}
+
 #ifdef CONFIG_SMP
 extern int set_cpus_allowed_ptr(struct task_struct *p,
 				const cpumask_t *new_mask);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
