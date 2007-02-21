Message-Id: <20070221144841.823705000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:07 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/29] mm: allow PF_MEMALLOC from softirq context
Content-Disposition: inline; filename=mm-PF_MEMALLOC-softirq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Allow PF_MEMALLOC to be set in softirq context. When running softirqs from
a borrowed context save current->flags, ksoftirqd will have its own 
task_struct.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/softirq.c |    3 +++
 mm/internal.h    |   14 ++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2006-12-14 10:02:52.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2006-12-14 10:10:09.000000000 +0100
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
 
@@ -117,9 +118,10 @@ static inline int gfp_to_rank(gfp_t gfp_
 	 */
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_interrupt() &&
-		    ((current->flags & PF_MEMALLOC) ||
-		     unlikely(test_thread_flag(TIF_MEMDIE))))
+		if (!in_irq() && (current->flags & PF_MEMALLOC))
+			return 0;
+		else if (!in_interrupt() &&
+				unlikely(test_thread_flag(TIF_MEMDIE)))
 			return 0;
 	}
 
Index: linux-2.6-git/kernel/softirq.c
===================================================================
--- linux-2.6-git.orig/kernel/softirq.c	2006-12-14 10:02:18.000000000 +0100
+++ linux-2.6-git/kernel/softirq.c	2006-12-14 10:02:52.000000000 +0100
@@ -209,6 +209,8 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long pflags = current->flags;
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -247,6 +249,7 @@ restart:
 
 	account_system_vtime(current);
 	_local_bh_enable();
+	current->flags = pflags;
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
