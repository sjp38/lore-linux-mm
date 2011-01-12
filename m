Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 020556B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 10:19:48 -0500 (EST)
Received: by pxi12 with SMTP id 12so102865pxi.14
        for <linux-mm@kvack.org>; Wed, 12 Jan 2011 07:19:46 -0800 (PST)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH] Rename struct task variables from p to tsk
Date: Wed, 12 Jan 2011 08:19:31 -0700
Message-Id: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

p is not a meaningful identifier, this patch replaces all instances
in page_alloc.c of p when used as a struct task with the more useful
tsk.

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 mm/page_alloc.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ff7e158..acfbb20 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1852,23 +1852,23 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
-	struct task_struct *p = current;
+	struct task_struct *tsk = current;
 	bool drained = false;
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
-	p->flags |= PF_MEMALLOC;
+	tsk->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
+	tsk->reclaim_state = &reclaim_state;
 
 	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
 
-	p->reclaim_state = NULL;
+	tsk->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-	p->flags &= ~PF_MEMALLOC;
+	tsk->flags &= ~PF_MEMALLOC;
 
 	cond_resched();
 
@@ -1932,7 +1932,7 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
 static inline int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
-	struct task_struct *p = current;
+	struct task_struct *tsk = current;
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 
@@ -1954,12 +1954,12 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
-	} else if (unlikely(rt_task(p)) && !in_interrupt())
+	} else if (unlikely(rt_task(tsk)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
 		if (!in_interrupt() &&
-		    ((p->flags & PF_MEMALLOC) ||
+		    ((tsk->flags & PF_MEMALLOC) ||
 		     unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
@@ -1978,7 +1978,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
-	struct task_struct *p = current;
+	struct task_struct *tsk = current;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2034,7 +2034,7 @@ rebalance:
 		goto nopage;
 
 	/* Avoid recursion of direct reclaim */
-	if (p->flags & PF_MEMALLOC)
+	if (tsk->flags & PF_MEMALLOC)
 		goto nopage;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
@@ -2108,7 +2108,7 @@ nopage:
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
 		printk(KERN_WARNING "%s: page allocation failure."
 			" order:%d, mode:0x%x\n",
-			p->comm, order, gfp_mask);
+			tsk->comm, order, gfp_mask);
 		dump_stack();
 		show_mem();
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
