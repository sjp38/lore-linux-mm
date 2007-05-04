Message-Id: <20070504103204.628880236@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:30 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 39/40] mm: a process flags to avoid blocking allocations
Content-Disposition: inline; filename=pf_mem_nowait.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

PF_MEM_NOWAIT - will make allocations fail before blocking. This is usefull
to convert process behaviour to non-blocking.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Christie <michaelc@cs.wisc.edu>
---
 include/linux/sched.h |    1 +
 kernel/softirq.c      |    4 ++--
 mm/internal.h         |   11 ++++++++++-
 mm/page_alloc.c       |    4 ++--
 4 files changed, 15 insertions(+), 5 deletions(-)

Index: linux-2.6-git/include/linux/sched.h
===================================================================
--- linux-2.6-git.orig/include/linux/sched.h	2007-03-26 12:03:07.000000000 +0200
+++ linux-2.6-git/include/linux/sched.h	2007-03-26 12:03:09.000000000 +0200
@@ -1158,6 +1158,7 @@ static inline void put_task_struct(struc
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
+#define PF_MEM_NOWAIT	0x40000000	/* Make allocations fail instead of block */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2007-03-26 12:03:07.000000000 +0200
+++ linux-2.6-git/mm/page_alloc.c	2007-03-26 12:03:09.000000000 +0200
@@ -1234,11 +1234,11 @@ struct page * fastcall
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	struct task_struct *p = current;
+	const bool wait = gfp_wait(gfp_mask);
 	struct zone **z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
-	struct task_struct *p = current;
 	int do_retry;
 	int alloc_flags;
 	int did_some_progress;
Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2007-03-26 12:03:07.000000000 +0200
+++ linux-2.6-git/mm/internal.h	2007-03-26 12:03:09.000000000 +0200
@@ -46,6 +46,15 @@ extern void fastcall __init __free_pages
 #define ALLOC_NO_WATERMARKS	0x20 /* don't check watermarks at all */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 
+static bool inline gfp_wait(gfp_t gfp_mask)
+{
+	bool wait = gfp_mask & __GFP_WAIT;
+	if (wait && !in_irq() && (current->flags & PF_MEM_NOWAIT))
+		wait = false;
+
+	return wait;
+}
+
 /*
  * get the deepest reaching allocation flags for the given gfp_mask
  */
@@ -53,7 +62,7 @@ static int inline gfp_to_alloc_flags(gfp
 {
 	struct task_struct *p = current;
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	const bool wait = gfp_wait(gfp_mask);
 
 	/*
 	 * The caller may dip into page reserves a bit more if the caller
Index: linux-2.6-git/kernel/softirq.c
===================================================================
--- linux-2.6-git.orig/kernel/softirq.c	2007-03-26 12:03:07.000000000 +0200
+++ linux-2.6-git/kernel/softirq.c	2007-03-26 12:12:58.000000000 +0200
@@ -211,7 +211,7 @@ asmlinkage void __do_softirq(void)
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
 	unsigned long pflags = current->flags;
-	current->flags &= ~PF_MEMALLOC;
+	current->flags &= ~(PF_MEMALLOC|PF_MEM_NOWAIT);
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -250,7 +250,7 @@ restart:
 
 	account_system_vtime(current);
 	_local_bh_enable();
-	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	tsk_restore_flags(current, pflags, (PF_MEMALLOC|PF_MEM_NOWAIT));
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
