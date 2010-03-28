Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 71CA36B01AC
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 17:21:18 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [10.3.21.14])
	by smtp-out.google.com with ESMTP id o2SLL9j3005575
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 14:21:11 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq14.eem.corp.google.com with ESMTP id o2SLL5iY025912
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 23:21:08 +0200
Received: by pvg7 with SMTP id 7so4004788pvg.21
        for <linux-mm@kvack.org>; Sun, 28 Mar 2010 14:21:05 -0700 (PDT)
Date: Sun, 28 Mar 2010 14:21:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <20100328162821.GA16765@redhat.com>
Message-ID: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: anfei <anfei.zhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Mar 2010, Oleg Nesterov wrote:

> I see. But still I can't understand. To me, the problem is not that
> B can't exit, the problem is that A doesn't know it should exit. All
> threads should exit and free ->mm. Even if B could exit, this is not
> enough. And, to some extent, it doesn't matter if it holds mmap_sem
> or not.
> 
> Don't get me wrong. Even if I don't understand oom_kill.c the patch
> looks obviously good to me, even from "common sense" pov. I am just
> curious.
> 
> So, my understanding is: we are going to kill the whole thread group
> but TIF_MEMDIE is per-thread. Mark the whole thread group as TIF_MEMDIE
> so that any thread can notice this flag and (say, __alloc_pages_slowpath)
> fail asap.
> 
> Is my understanding correct?
> 

[Adding Mel Gorman <mel@csn.ul.ie> to the cc]

The problem with this approach is that we could easily deplete all memory 
reserves if the oom killed task has an extremely large number of threads, 
there has always been only a single thread with TIF_MEMDIE set per cpuset 
or memcg; for systems that don't run with cpusets or memory controller,
this has been limited to one thread with TIF_MEMDIE for the entire system.

There's risk involved with suddenly allowing 1000 threads to have 
TIF_MEMDIE set and the chances of fully depleting all allowed zones is 
much higher if they allocate memory prior to exit, for example.

An alternative is to fail allocations if they are failable and the 
allocating task has a pending SIGKILL.  It's better to preempt the oom 
killer since current is going to be exiting anyway and this avoids a 
needless kill.

That's possible if it's guaranteed that __GFP_NOFAIL allocations with a 
pending SIGKILL are granted ALLOC_NO_WATERMARKS to prevent them from 
endlessly looping while making no progress.

Comments?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1610,13 +1610,21 @@ try_next_zone:
 }
 
 static inline int
-should_alloc_retry(gfp_t gfp_mask, unsigned int order,
+should_alloc_retry(struct task_struct *p, gfp_t gfp_mask, unsigned int order,
 				unsigned long pages_reclaimed)
 {
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		return 0;
 
+	/* Loop if specifically requested */
+	if (gfp_mask & __GFP_NOFAIL)
+		return 1;
+
+	/* Task is killed, fail the allocation if possible */
+	if (fatal_signal_pending(p))
+		return 0;
+
 	/*
 	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
 	 * means __GFP_NOFAIL, but that may not be true in other
@@ -1635,13 +1643,6 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
 		return 1;
 
-	/*
-	 * Don't let big-order allocations loop unless the caller
-	 * explicitly requests that.
-	 */
-	if (gfp_mask & __GFP_NOFAIL)
-		return 1;
-
 	return 0;
 }
 
@@ -1798,6 +1799,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
 		if (!in_interrupt() &&
 		    ((p->flags & PF_MEMALLOC) ||
+		     (fatal_signal_pending(p) && (gfp_mask & __GFP_NOFAIL)) ||
 		     unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
@@ -1812,6 +1814,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	int migratetype)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	const gfp_t nofail = gfp_mask & __GFP_NOFAIL;
 	struct page *page = NULL;
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
@@ -1876,7 +1879,7 @@ rebalance:
 		goto nopage;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	if (test_thread_flag(TIF_MEMDIE) && !nofail)
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
@@ -1888,6 +1891,10 @@ rebalance:
 	if (page)
 		goto got_pg;
 
+	/* Task is killed, fail the allocation if possible */
+	if (fatal_signal_pending(p) && !nofail)
+		goto nopage;
+
 	/*
 	 * If we failed to make any progress reclaiming, then we are
 	 * running out of options and have to consider going OOM
@@ -1909,8 +1916,7 @@ rebalance:
 			 * made, there are no other options and retrying is
 			 * unlikely to help.
 			 */
-			if (order > PAGE_ALLOC_COSTLY_ORDER &&
-						!(gfp_mask & __GFP_NOFAIL))
+			if (order > PAGE_ALLOC_COSTLY_ORDER && !nofail)
 				goto nopage;
 
 			goto restart;
@@ -1919,7 +1925,7 @@ rebalance:
 
 	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
-	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
+	if (should_alloc_retry(p, gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 		goto rebalance;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
