Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 287D78D0007
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:01:21 -0500 (EST)
Message-Id: <20101126145410.491545145@chello.nl>
Date: Fri, 26 Nov 2010 15:38:47 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/21] mm: Rename drop_anon_vma to put_anon_vma
References: <20101126143843.801484792@chello.nl>
Content-Disposition: inline; filename=put_anon_vma.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

The normal code pattern used in the kernel is: get/put.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/rmap.h |    4 ++--
 mm/ksm.c             |   10 +++++-----
 mm/migrate.c         |    2 +-
 mm/rmap.c            |    4 ++--
 4 files changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -87,7 +87,7 @@ static inline void get_anon_vma(struct a
 	atomic_inc(&anon_vma->external_refcount);
 }
 
-void drop_anon_vma(struct anon_vma *);
+void put_anon_vma(struct anon_vma *);
 #else
 static inline void anonvma_external_refcount_init(struct anon_vma *anon_vma)
 {
@@ -102,7 +102,7 @@ static inline void get_anon_vma(struct a
 {
 }
 
-static inline void drop_anon_vma(struct anon_vma *anon_vma)
+static inline void put_anon_vma(struct anon_vma *anon_vma)
 {
 }
 #endif /* CONFIG_KSM */
Index: linux-2.6/mm/ksm.c
===================================================================
--- linux-2.6.orig/mm/ksm.c
+++ linux-2.6/mm/ksm.c
@@ -307,11 +307,11 @@ static void hold_anon_vma(struct rmap_it
 	get_anon_vma(anon_vma);
 }
 
-static void ksm_drop_anon_vma(struct rmap_item *rmap_item)
+static void ksm_put_anon_vma(struct rmap_item *rmap_item)
 {
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
-	drop_anon_vma(anon_vma);
+	put_anon_vma(anon_vma);
 }
 
 /*
@@ -396,7 +396,7 @@ static void break_cow(struct rmap_item *
 	 * It is not an accident that whenever we want to break COW
 	 * to undo, we also need to drop a reference to the anon_vma.
 	 */
-	ksm_drop_anon_vma(rmap_item);
+	ksm_put_anon_vma(rmap_item);
 
 	down_read(&mm->mmap_sem);
 	if (ksm_test_exit(mm))
@@ -451,7 +451,7 @@ static void remove_node_from_stable_tree
 			ksm_pages_sharing--;
 		else
 			ksm_pages_shared--;
-		ksm_drop_anon_vma(rmap_item);
+		ksm_put_anon_vma(rmap_item);
 		rmap_item->address &= PAGE_MASK;
 		cond_resched();
 	}
@@ -539,7 +539,7 @@ static void remove_rmap_item_from_tree(s
 		else
 			ksm_pages_shared--;
 
-		ksm_drop_anon_vma(rmap_item);
+		ksm_put_anon_vma(rmap_item);
 		rmap_item->address &= PAGE_MASK;
 
 	} else if (rmap_item->address & UNSTABLE_FLAG) {
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -683,7 +683,7 @@ rcu_unlock:
 
 	/* Drop an anon_vma reference if we took one */
 	if (anon_vma)
-		drop_anon_vma(anon_vma);
+		put_anon_vma(anon_vma);
 
 	if (rcu_locked)
 		rcu_read_unlock();
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -274,7 +274,7 @@ static void anon_vma_unlink(struct anon_
 	if (empty) {
 		/* We no longer need the root anon_vma */
 		if (anon_vma->root != anon_vma)
-			drop_anon_vma(anon_vma->root);
+			put_anon_vma(anon_vma->root);
 		anon_vma_free(anon_vma);
 	}
 }
@@ -1448,7 +1448,7 @@ int try_to_munlock(struct page *page)
  * we know we are the last user, nobody else can get a reference and we
  * can do the freeing without the lock.
  */
-void drop_anon_vma(struct anon_vma *anon_vma)
+void put_anon_vma(struct anon_vma *anon_vma)
 {
 	BUG_ON(atomic_read(&anon_vma->external_refcount) <= 0);
 	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->root->lock)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
