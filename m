Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D91846B01EA
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:29:10 -0400 (EDT)
Date: Wed, 26 May 2010 11:25:53 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
 inline function
Message-ID: <20100526112553.65724b12@annuminas.surriel.com>
In-Reply-To: <20100526112403.635be0ed@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com>
	<20100513140919.0a037845.akpm@linux-foundation.org>
	<4BFC9CCF.6000809@redhat.com>
	<20100526112403.635be0ed@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Subject: change direct call of spin_lock(anon_vma->lock) to inline function

Subsitute a direct call of spin_lock(anon_vma->lock) with
an inline function doing exactly the same.

This makes it easier to do the substitution to the root
anon_vma lock in a following patch.

We will deal with the handful of special locks (nested,
dec_and_lock, etc) separately.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h |   10 ++++++++++
 mm/ksm.c             |   18 +++++++++---------
 mm/migrate.c         |    2 +-
 mm/mmap.c            |    2 +-
 mm/rmap.c            |   22 +++++++++++-----------
 5 files changed, 32 insertions(+), 22 deletions(-)

Index: linux-2.6.34/include/linux/rmap.h
===================================================================
--- linux-2.6.34.orig/include/linux/rmap.h
+++ linux-2.6.34/include/linux/rmap.h
@@ -113,6 +113,16 @@ static inline void vma_unlock_anon_vma(s
 		spin_unlock(&anon_vma->lock);
 }
 
+static inline void anon_vma_lock(struct anon_vma *anon_vma)
+{
+	spin_lock(&anon_vma->lock);
+}
+
+static inline void anon_vma_unlock(struct anon_vma *anon_vma)
+{
+	spin_unlock(&anon_vma->lock);
+}
+
 /*
  * anon_vma helper functions.
  */
Index: linux-2.6.34/mm/ksm.c
===================================================================
--- linux-2.6.34.orig/mm/ksm.c
+++ linux-2.6.34/mm/ksm.c
@@ -327,7 +327,7 @@ static void drop_anon_vma(struct rmap_it
 
 	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 		if (empty)
 			anon_vma_free(anon_vma);
 	}
@@ -1566,7 +1566,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		spin_lock(&anon_vma->lock);
+		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
@@ -1589,7 +1589,7 @@ again:
 			if (!search_new_forks || !mapcount)
 				break;
 		}
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 		if (!mapcount)
 			goto out;
 	}
@@ -1619,7 +1619,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		spin_lock(&anon_vma->lock);
+		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
@@ -1637,11 +1637,11 @@ again:
 			ret = try_to_unmap_one(page, vma,
 					rmap_item->address, flags);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
-				spin_unlock(&anon_vma->lock);
+				anon_vma_unlock(anon_vma);
 				goto out;
 			}
 		}
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 	}
 	if (!search_new_forks++)
 		goto again;
@@ -1671,7 +1671,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		spin_lock(&anon_vma->lock);
+		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
@@ -1688,11 +1688,11 @@ again:
 
 			ret = rmap_one(page, vma, rmap_item->address, arg);
 			if (ret != SWAP_AGAIN) {
-				spin_unlock(&anon_vma->lock);
+				anon_vma_unlock(anon_vma);
 				goto out;
 			}
 		}
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 	}
 	if (!search_new_forks++)
 		goto again;
Index: linux-2.6.34/mm/mmap.c
===================================================================
--- linux-2.6.34.orig/mm/mmap.c
+++ linux-2.6.34/mm/mmap.c
@@ -2589,7 +2589,7 @@ static void vm_unlock_anon_vma(struct an
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->head.next))
 			BUG();
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 	}
 }
 
Index: linux-2.6.34/mm/rmap.c
===================================================================
--- linux-2.6.34.orig/mm/rmap.c
+++ linux-2.6.34/mm/rmap.c
@@ -134,7 +134,7 @@ int anon_vma_prepare(struct vm_area_stru
 			allocated = anon_vma;
 		}
 
-		spin_lock(&anon_vma->lock);
+		anon_vma_lock(anon_vma);
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
@@ -147,7 +147,7 @@ int anon_vma_prepare(struct vm_area_stru
 			avc = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
@@ -170,9 +170,9 @@ static void anon_vma_chain_link(struct v
 	avc->anon_vma = anon_vma;
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
-	spin_lock(&anon_vma->lock);
+	anon_vma_lock(anon_vma);
 	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
-	spin_unlock(&anon_vma->lock);
+	anon_vma_unlock(anon_vma);
 }
 
 /*
@@ -246,12 +246,12 @@ static void anon_vma_unlink(struct anon_
 	if (!anon_vma)
 		return;
 
-	spin_lock(&anon_vma->lock);
+	anon_vma_lock(anon_vma);
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
-	spin_unlock(&anon_vma->lock);
+	anon_vma_unlock(anon_vma);
 
 	if (empty)
 		anon_vma_free(anon_vma);
@@ -303,10 +303,10 @@ again:
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	anon_vma_lock(anon_vma);
 
 	if (page_rmapping(page) != anon_vma) {
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 		goto again;
 	}
 
@@ -318,7 +318,7 @@ out:
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
+	anon_vma_unlock(anon_vma);
 	rcu_read_unlock();
 }
 
@@ -1396,7 +1396,7 @@ static int rmap_walk_anon(struct page *p
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
-	spin_lock(&anon_vma->lock);
+	anon_vma_lock(anon_vma);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
@@ -1406,7 +1406,7 @@ static int rmap_walk_anon(struct page *p
 		if (ret != SWAP_AGAIN)
 			break;
 	}
-	spin_unlock(&anon_vma->lock);
+	anon_vma_unlock(anon_vma);
 	return ret;
 }
 
Index: linux-2.6.34/mm/migrate.c
===================================================================
--- linux-2.6.34.orig/mm/migrate.c
+++ linux-2.6.34/mm/migrate.c
@@ -684,7 +684,7 @@ rcu_unlock:
 	/* Drop an anon_vma reference if we took one */
 	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		anon_vma_unlock(anon_vma);
 		if (empty)
 			anon_vma_free(anon_vma);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
