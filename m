Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 577D68D0054
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:59 -0500 (EST)
Message-Id: <20110217162124.457572646@chello.nl>
Date: Thu, 17 Feb 2011 17:19:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/3] mm: Simplify anon_vma refcounts
References: <20110217161948.045410404@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-simplify_anon_vma_refcounts.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

This patch changes the anon_vma refcount to be 0 when the object is
free. It does this by adding 1 ref to being in use in the anon_vma
structure (iow. the anon_vma->head list is not empty).

This allows a simpler release scheme without having to check both the
refcount and the list as well as avoids taking a ref for each entry
on the list.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/rmap.h |   11 +++++--
 mm/rmap.c            |   79 ++++++++++++++++++---------------------------------
 2 files changed, 37 insertions(+), 53 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -73,7 +73,13 @@ static inline void get_anon_vma(struct a
 	atomic_inc(&anon_vma->refcount);
 }
 
-void put_anon_vma(struct anon_vma *);
+void __put_anon_vma(struct anon_vma *anon_vma);
+
+static inline void put_anon_vma(struct anon_vma *anon_vma)
+{
+	if (atomic_dec_and_test(&anon_vma->refcount))
+		__put_anon_vma(anon_vma);
+}
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
@@ -116,7 +122,6 @@ void unlink_anon_vmas(struct vm_area_str
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
-void anon_vma_free(struct anon_vma *);
 
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
@@ -125,6 +130,8 @@ static inline void anon_vma_merge(struct
 	unlink_anon_vmas(next);
 }
 
+struct anon_vma *page_get_anon_vma(struct page *page);
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -67,11 +67,24 @@ static struct kmem_cache *anon_vma_chain
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
-	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	struct anon_vma *anon_vma;
+
+	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	if (anon_vma) {
+		atomic_set(&anon_vma->refcount, 1);
+		/*
+		 * Initialise the anon_vma root to point to itself. If called
+		 * from fork, the root will be reset to the parents anon_vma.
+		 */
+		anon_vma->root = anon_vma;
+	}
+
+	return anon_vma;
 }
 
-void anon_vma_free(struct anon_vma *anon_vma)
+static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
+	VM_BUG_ON(atomic_read(&anon_vma->refcount));
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
@@ -133,11 +146,6 @@ int anon_vma_prepare(struct vm_area_stru
 			if (unlikely(!anon_vma))
 				goto out_enomem_free_avc;
 			allocated = anon_vma;
-			/*
-			 * This VMA had no anon_vma yet.  This anon_vma is
-			 * the root of any anon_vma tree that might form.
-			 */
-			anon_vma->root = anon_vma;
 		}
 
 		anon_vma_lock(anon_vma);
@@ -156,7 +164,7 @@ int anon_vma_prepare(struct vm_area_stru
 		anon_vma_unlock(anon_vma);
 
 		if (unlikely(allocated))
-			anon_vma_free(allocated);
+			put_anon_vma(allocated);
 		if (unlikely(avc))
 			anon_vma_chain_free(avc);
 	}
@@ -241,9 +249,9 @@ int anon_vma_fork(struct vm_area_struct 
 	 */
 	anon_vma->root = pvma->anon_vma->root;
 	/*
-	 * With KSM refcounts, an anon_vma can stay around longer than the
-	 * process it belongs to.  The root anon_vma needs to be pinned
-	 * until this anon_vma is freed, because the lock lives in the root.
+	 * With refcounts, an anon_vma can stay around longer than the
+	 * process it belongs to. The root anon_vma needs to be pinned until
+	 * this anon_vma is freed, because the lock lives in the root.
 	 */
 	get_anon_vma(anon_vma->root);
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
@@ -253,7 +261,7 @@ int anon_vma_fork(struct vm_area_struct 
 	return 0;
 
  out_error_free_anon_vma:
-	anon_vma_free(anon_vma);
+	put_anon_vma(anon_vma);
  out_error:
 	unlink_anon_vmas(vma);
 	return -ENOMEM;
@@ -272,15 +280,11 @@ static void anon_vma_unlink(struct anon_
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !atomic_read(&anon_vma->refcount);
+	empty = list_empty(&anon_vma->head);
 	anon_vma_unlock(anon_vma);
 
-	if (empty) {
-		/* We no longer need the root anon_vma */
-		if (anon_vma->root != anon_vma)
-			put_anon_vma(anon_vma->root);
-		anon_vma_free(anon_vma);
-	}
+	if (empty)
+		put_anon_vma(anon_vma);
 }
 
 void unlink_anon_vmas(struct vm_area_struct *vma)
@@ -1482,38 +1486,11 @@ int try_to_munlock(struct page *page)
 		return try_to_unmap_file(page, TTU_MUNLOCK);
 }
 
-/*
- * Drop an anon_vma refcount, freeing the anon_vma and anon_vma->root
- * if necessary.  Be careful to do all the tests under the lock.  Once
- * we know we are the last user, nobody else can get a reference and we
- * can do the freeing without the lock.
- */
-void put_anon_vma(struct anon_vma *anon_vma)
-{
-	BUG_ON(atomic_read(&anon_vma->refcount) <= 0);
-	if (atomic_dec_and_lock(&anon_vma->refcount, &anon_vma->root->lock)) {
-		struct anon_vma *root = anon_vma->root;
-		int empty = list_empty(&anon_vma->head);
-		int last_root_user = 0;
-		int root_empty = 0;
-
-		/*
-		 * The refcount on a non-root anon_vma got dropped.  Drop
-		 * the refcount on the root and check if we need to free it.
-		 */
-		if (empty && anon_vma != root) {
-			BUG_ON(atomic_read(&root->refcount) <= 0);
-			last_root_user = atomic_dec_and_test(&root->refcount);
-			root_empty = list_empty(&root->head);
-		}
-		anon_vma_unlock(anon_vma);
-
-		if (empty) {
-			anon_vma_free(anon_vma);
-			if (root_empty && last_root_user)
-				anon_vma_free(root);
-		}
-	}
+void __put_anon_vma(struct anon_vma *anon_vma)
+{
+	if (anon_vma->root != anon_vma)
+		put_anon_vma(anon_vma->root);
+	anon_vma_free(anon_vma);
 }
 
 #ifdef CONFIG_MIGRATION


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
