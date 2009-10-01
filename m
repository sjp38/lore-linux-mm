Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE50600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:25:44 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 07/31] mm: allow PF_MEMALLOC from softirq context
Date: Thu,  1 Oct 2009 19:35:56 +0530
Message-Id: <1254405956-15904-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

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
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/linux/sched.h |    7 +++++++
 kernel/softirq.c      |    3 +++
 mm/page_alloc.c       |    7 ++++---
 3 files changed, 14 insertions(+), 3 deletions(-)

Index: mmotm/include/linux/sched.h
===================================================================
--- mmotm.orig/include/linux/sched.h
+++ mmotm/include/linux/sched.h
@@ -1724,6 +1724,13 @@ extern cputime_t task_gtime(struct task_
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
 				const struct cpumask *new_mask);
Index: mmotm/kernel/softirq.c
===================================================================
--- mmotm.orig/kernel/softirq.c
+++ mmotm/kernel/softirq.c
@@ -194,6 +194,8 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long pflags = current->flags;
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -246,6 +248,7 @@ restart:
 
 	account_system_vtime(current);
 	_local_bh_enable();
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ
Index: mmotm/mm/page_alloc.c
===================================================================
--- mmotm.orig/mm/page_alloc.c
+++ mmotm/mm/page_alloc.c
@@ -1708,9 +1708,10 @@ int gfp_to_alloc_flags(gfp_t gfp_mask)
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
