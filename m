Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 006A56B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:55:16 -0500 (EST)
Date: Tue, 10 Nov 2009 21:55:13 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911102151500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's contorted mlock/munlock handling in try_to_unmap_anon() and
try_to_unmap_file(), which we'd prefer not to repeat for KSM swapping.
Simplify it by moving it all down into try_to_unmap_one().

One thing is then lost, try_to_munlock()'s distinction between when no
vma holds the page mlocked, and when a vma does mlock it, but we could
not get mmap_sem to set the page flag.  But its only caller takes no
interest in that distinction (and is better testing SWAP_MLOCK anyway),
so let's keep the code simple and return SWAP_AGAIN for both cases.

try_to_unmap_file()'s TTU_MUNLOCK nonlinear handling was particularly
amusing: once unravelled, it turns out to have been choosing between
two different ways of doing the same nothing.  Ah, no, one way was
actually returning SWAP_FAIL when it meant to return SWAP_SUCCESS.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/mlock.c |    2 
 mm/rmap.c  |  107 ++++++++++++---------------------------------------
 2 files changed, 27 insertions(+), 82 deletions(-)

--- mm1/mm/mlock.c	2009-09-28 00:28:41.000000000 +0100
+++ mm2/mm/mlock.c	2009-11-04 10:52:52.000000000 +0000
@@ -117,7 +117,7 @@ static void munlock_vma_page(struct page
 			/*
 			 * did try_to_unlock() succeed or punt?
 			 */
-			if (ret == SWAP_SUCCESS || ret == SWAP_AGAIN)
+			if (ret != SWAP_MLOCK)
 				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 
 			putback_lru_page(page);
--- mm1/mm/rmap.c	2009-11-04 10:52:45.000000000 +0000
+++ mm2/mm/rmap.c	2009-11-04 10:52:52.000000000 +0000
@@ -787,6 +787,8 @@ static int try_to_unmap_one(struct page
 			ret = SWAP_MLOCK;
 			goto out_unmap;
 		}
+		if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
+			goto out_unmap;
 	}
 	if (!(flags & TTU_IGNORE_ACCESS)) {
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
@@ -852,12 +854,22 @@ static int try_to_unmap_one(struct page
 	} else
 		dec_mm_counter(mm, file_rss);
 
-
 	page_remove_rmap(page);
 	page_cache_release(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+
+	if (MLOCK_PAGES && ret == SWAP_MLOCK) {
+		ret = SWAP_AGAIN;
+		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+			if (vma->vm_flags & VM_LOCKED) {
+				mlock_vma_page(page);
+				ret = SWAP_MLOCK;
+			}
+			up_read(&vma->vm_mm->mmap_sem);
+		}
+	}
 out:
 	return ret;
 }
@@ -979,23 +991,6 @@ static int try_to_unmap_cluster(unsigned
 	return ret;
 }
 
-/*
- * common handling for pages mapped in VM_LOCKED vmas
- */
-static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
-{
-	int mlocked = 0;
-
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		if (vma->vm_flags & VM_LOCKED) {
-			mlock_vma_page(page);
-			mlocked++;	/* really mlocked the page */
-		}
-		up_read(&vma->vm_mm->mmap_sem);
-	}
-	return mlocked;
-}
-
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
@@ -1016,42 +1011,19 @@ static int try_to_unmap_anon(struct page
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
-	unsigned int mlocked = 0;
 	int ret = SWAP_AGAIN;
-	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
-
-	if (MLOCK_PAGES && unlikely(unlock))
-		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		if (MLOCK_PAGES && unlikely(unlock)) {
-			if (!((vma->vm_flags & VM_LOCKED) &&
-			      page_mapped_in_vma(page, vma)))
-				continue;  /* must visit all unlocked vmas */
-			ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
-		} else {
-			ret = try_to_unmap_one(page, vma, flags);
-			if (ret == SWAP_FAIL || !page_mapped(page))
-				break;
-		}
-		if (ret == SWAP_MLOCK) {
-			mlocked = try_to_mlock_page(page, vma);
-			if (mlocked)
-				break;	/* stop if actually mlocked page */
-		}
+		ret = try_to_unmap_one(page, vma, flags);
+		if (ret != SWAP_AGAIN || !page_mapped(page))
+			break;
 	}
 
 	page_unlock_anon_vma(anon_vma);
-
-	if (mlocked)
-		ret = SWAP_MLOCK;	/* actually mlocked the page */
-	else if (ret == SWAP_MLOCK)
-		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
-
 	return ret;
 }
 
@@ -1081,45 +1053,23 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
-	unsigned int mlocked = 0;
-	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
-
-	if (MLOCK_PAGES && unlikely(unlock))
-		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		if (MLOCK_PAGES && unlikely(unlock)) {
-			if (!((vma->vm_flags & VM_LOCKED) &&
-						page_mapped_in_vma(page, vma)))
-				continue;	/* must visit all vmas */
-			ret = SWAP_MLOCK;
-		} else {
-			ret = try_to_unmap_one(page, vma, flags);
-			if (ret == SWAP_FAIL || !page_mapped(page))
-				goto out;
-		}
-		if (ret == SWAP_MLOCK) {
-			mlocked = try_to_mlock_page(page, vma);
-			if (mlocked)
-				break;  /* stop if actually mlocked page */
-		}
+		ret = try_to_unmap_one(page, vma, flags);
+		if (ret != SWAP_AGAIN || !page_mapped(page))
+			goto out;
 	}
 
-	if (mlocked)
+	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 
-	if (list_empty(&mapping->i_mmap_nonlinear))
+	/* We don't bother to try to find the munlocked page in nonlinears */
+	if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-		if (MLOCK_PAGES && unlikely(unlock)) {
-			if (!(vma->vm_flags & VM_LOCKED))
-				continue;	/* must visit all vmas */
-			ret = SWAP_MLOCK;	/* leave mlocked == 0 */
-			goto out;		/* no need to look further */
-		}
 		if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
 			(vma->vm_flags & VM_LOCKED))
 			continue;
@@ -1161,10 +1111,9 @@ static int try_to_unmap_file(struct page
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
-				ret = try_to_unmap_cluster(cursor, &mapcount,
-								vma, page);
-				if (ret == SWAP_MLOCK)
-					mlocked = 2;	/* to return below */
+				if (try_to_unmap_cluster(cursor, &mapcount,
+						vma, page) == SWAP_MLOCK)
+					ret = SWAP_MLOCK;
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
 				if ((int)mapcount <= 0)
@@ -1185,10 +1134,6 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
-	if (mlocked)
-		ret = SWAP_MLOCK;	/* actually mlocked the page */
-	else if (ret == SWAP_MLOCK)
-		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
 	return ret;
 }
 
@@ -1231,7 +1176,7 @@ int try_to_unmap(struct page *page, enum
  *
  * Return values are:
  *
- * SWAP_SUCCESS	- no vma's holding page mlocked.
+ * SWAP_AGAIN	- no vma is holding page mlocked, or,
  * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
  * SWAP_MLOCK	- page is now mlocked.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
