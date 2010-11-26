Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFE78D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:01:13 -0500 (EST)
Message-Id: <20101126145410.315243256@chello.nl>
Date: Fri, 26 Nov 2010 15:38:44 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/21] mm: Revert page_lock_anon_vma() lock annotation
References: <20101126143843.801484792@chello.nl>
Content-Disposition: inline; filename=revert-rmap-annotate_lock_context_change_on_page_unlock_anon_vma.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Namhyung Kim <namhyung@gmail.com>
List-ID: <linux-mm.kvack.org>

Its beyond ugly and gets in the way.

Cc: Namhyung Kim <namhyung@gmail.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -241,20 +241,7 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *__page_lock_anon_vma(struct page *page);
-
-static inline struct anon_vma *page_lock_anon_vma(struct page *page)
-{
-	struct anon_vma *anon_vma;
-
-	__cond_lock(RCU, anon_vma = __page_lock_anon_vma(page));
-
-	/* (void) is needed to make gcc happy */
-	(void) __cond_lock(&anon_vma->root->lock, anon_vma);
-
-	return anon_vma;
-}
-
+struct anon_vma *page_lock_anon_vma(struct page *page);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -314,7 +314,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-struct anon_vma *__page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma, *root_anon_vma;
 	unsigned long anon_mapping;
@@ -348,8 +348,6 @@ struct anon_vma *__page_lock_anon_vma(st
 }
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
-	__releases(&anon_vma->root->lock)
-	__releases(RCU)
 {
 	anon_vma_unlock(anon_vma);
 	rcu_read_unlock();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
