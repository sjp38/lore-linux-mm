Message-Id: <20070504103156.057213163@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:26:54 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/40] mm: allow PF_MEMALLOC from softirq context
Content-Disposition: inline; filename=mm-PF_MEMALLOC-softirq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Allow PF_MEMALLOC to be set in softirq context. When running softirqs from
a borrowed context save current->flags, ksoftirqd will have its own 
task_struct.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/sched.h |    4 ++++
 kernel/softirq.c      |    3 +++
 mm/internal.h         |    7 ++++---
 3 files changed, 11 insertions(+), 3 deletions(-)

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2007-02-22 14:44:37.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2007-02-22 15:16:58.000000000 +0100
@@ -75,9 +75,10 @@ static int inline gfp_to_alloc_flags(gfp
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
 
Index: linux-2.6-git/kernel/softirq.c
===================================================================
--- linux-2.6-git.orig/kernel/softirq.c	2007-02-22 14:44:35.000000000 +0100
+++ linux-2.6-git/kernel/softirq.c	2007-02-22 15:29:38.000000000 +0100
@@ -210,6 +210,8 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long pflags = current->flags;
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -248,6 +250,7 @@ restart:
 
 	account_system_vtime(current);
 	_local_bh_enable();
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ
Index: linux-2.6-git/include/linux/sched.h
===================================================================
--- linux-2.6-git.orig/include/linux/sched.h	2007-02-22 15:17:39.000000000 +0100
+++ linux-2.6-git/include/linux/sched.h	2007-02-22 15:29:05.000000000 +0100
@@ -1185,6 +1185,10 @@ static inline void put_task_struct(struc
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
+#define tsk_restore_flags(p, pflags, mask) \
+	do {	(p)->flags &= ~(mask); \
+		(p)->flags |= ((pflags) & (mask)); } while (0)
+
 #ifdef CONFIG_SMP
 extern int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask);
 #else

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
