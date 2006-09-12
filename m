Message-Id: <20060912144905.106019000@chello.nl>
References: <20060912143049.278065000@chello.nl>
Subject: [PATCH 19/20] mm: a process flags to avoid blocking allocations
Content-Disposition: inline; filename=pf_mem_nowait.patch
Date: Tue, 12 Sep 2006 17:25:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

PF_MEM_NOWAIT - will make allocations fail before blocking. This is usefull
to convert process behaviour to non-blocking.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Mike Christie <michaelc@cs.wisc.edu>
---
 include/linux/sched.h |    1 +
 mm/page_alloc.c       |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1056,6 +1056,7 @@ static inline void put_task_struct(struc
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
+#define PF_MEM_NOWAIT	0x40000000	/* Make allocations fail instead of block */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -912,11 +912,11 @@ struct page * fastcall
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	struct task_struct *p = current;
+	const int wait = (gfp_mask & __GFP_WAIT) && !(p->flags & PF_MEM_NOWAIT);
 	struct zone **z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
-	struct task_struct *p = current;
 	int do_retry;
 	int alloc_flags;
 	int did_some_progress;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
