Message-Id: <20061130101921.360226000@chello.nl>>
References: <20061130101451.495412000@chello.nl>>
Date: Thu, 30 Nov 2006 11:14:53 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/6] mm: allow PF_MEMALLOC from softirq context
Content-Disposition: inline; filename=page-alloc-softirq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
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
--- linux-2.6-git.orig/mm/internal.h	2006-11-29 16:23:02.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2006-11-29 16:34:17.000000000 +0100
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
--- linux-2.6-git.orig/kernel/softirq.c	2006-11-29 16:15:54.000000000 +0100
+++ linux-2.6-git/kernel/softirq.c	2006-11-29 16:32:47.000000000 +0100
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
