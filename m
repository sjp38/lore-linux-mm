Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0366F6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:00:46 -0500 (EST)
Date: Tue, 10 Nov 2009 22:00:43 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 4/6] mm: pass address down to rmap ones
In-Reply-To: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911102159270.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KSM swapping will know where page_referenced_one() and try_to_unmap_one()
should look.  It could hack page->index to get them to do what it wants,
but it seems cleaner now to pass the address down to them.

Make the same change to page_mkclean_one(), since it follows the same
pattern; but there's no real need in its case.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/rmap.c |   53 ++++++++++++++++++++++++++--------------------------
 1 file changed, 27 insertions(+), 26 deletions(-)

--- mm3/mm/rmap.c	2009-11-04 10:52:58.000000000 +0000
+++ mm4/mm/rmap.c	2009-11-04 10:53:05.000000000 +0000
@@ -336,21 +336,15 @@ int page_mapped_in_vma(struct page *page
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
-static int page_referenced_one(struct page *page,
-			       struct vm_area_struct *vma,
-			       unsigned int *mapcount,
+static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
+			       unsigned long address, unsigned int *mapcount,
 			       unsigned long *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
 	int referenced = 0;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
@@ -408,6 +402,9 @@ static int page_referenced_anon(struct p
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		unsigned long address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
 		/*
 		 * If we are reclaiming on behalf of a cgroup, skip
 		 * counting on behalf of references from different
@@ -415,7 +412,7 @@ static int page_referenced_anon(struct p
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma,
+		referenced += page_referenced_one(page, vma, address,
 						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
@@ -473,6 +470,9 @@ static int page_referenced_file(struct p
 	mapcount = page_mapcount(page);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
 		/*
 		 * If we are reclaiming on behalf of a cgroup, skip
 		 * counting on behalf of references from different
@@ -480,7 +480,7 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma,
+		referenced += page_referenced_one(page, vma, address,
 						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
@@ -534,18 +534,14 @@ int page_referenced(struct page *page,
 	return referenced;
 }
 
-static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
+static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
+			    unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
 	int ret = 0;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
 	pte = page_check_address(page, mm, address, &ptl, 1);
 	if (!pte)
 		goto out;
@@ -577,8 +573,12 @@ static int page_mkclean_file(struct addr
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		if (vma->vm_flags & VM_SHARED)
-			ret += page_mkclean_one(page, vma);
+		if (vma->vm_flags & VM_SHARED) {
+			unsigned long address = vma_address(page, vma);
+			if (address == -EFAULT)
+				continue;
+			ret += page_mkclean_one(page, vma, address);
+		}
 	}
 	spin_unlock(&mapping->i_mmap_lock);
 	return ret;
@@ -760,19 +760,14 @@ void page_remove_rmap(struct page *page)
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-				enum ttu_flags flags)
+			    unsigned long address, enum ttu_flags flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
@@ -1017,7 +1012,10 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, flags);
+		unsigned long address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		ret = try_to_unmap_one(page, vma, address, flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			break;
 	}
@@ -1055,7 +1053,10 @@ static int try_to_unmap_file(struct page
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, flags);
+		unsigned long address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		ret = try_to_unmap_one(page, vma, address, flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			goto out;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
