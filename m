Message-Id: <200405222211.i4MMBMr14068@mail.osdl.org>
Subject: [patch 39/57] rmap 21 try_to_unmap_one mapcount
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:10:50 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Why should try_to_unmap_anon and try_to_unmap_file take a copy of
page->mapcount and pass it down for try_to_unmap_one to decrement?  why not
just check page->mapcount itself?  asks akpm.  Perhaps there used to be a good
reason, but not any more: remove the mapcount arg.


---

 25-akpm/mm/rmap.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff -puN mm/rmap.c~rmap-21-try_to_unmap_one-mapcount mm/rmap.c
--- 25/mm/rmap.c~rmap-21-try_to_unmap_one-mapcount	2004-05-22 14:56:27.736874880 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:37.543019960 -0700
@@ -462,9 +462,8 @@ int fastcall mremap_move_anon_rmap(struc
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  */
-static int try_to_unmap_one(struct page *page,
-	struct mm_struct *mm, unsigned long address,
-	unsigned int *mapcount, struct vm_area_struct *vma)
+static int try_to_unmap_one(struct page *page, struct mm_struct *mm,
+		unsigned long address, struct vm_area_struct *vma)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -494,8 +493,6 @@ static int try_to_unmap_one(struct page 
 	if (page_to_pfn(page) != pte_pfn(*pte))
 		goto out_unmap;
 
-	(*mapcount)--;
-
 	if (!vma) {
 		vma = find_vma(mm, address);
 		/* unmap_vmas drops page_table_lock with vma unlinked */
@@ -654,7 +651,6 @@ out_unlock:
 
 static inline int try_to_unmap_anon(struct page *page)
 {
-	unsigned int mapcount = page->mapcount;
 	struct anonmm *anonmm = (struct anonmm *) page->mapping;
 	struct anonmm *anonhd = anonmm->head;
 	struct list_head *seek_head;
@@ -665,9 +661,8 @@ static inline int try_to_unmap_anon(stru
 	 * First try the indicated mm, it's the most likely.
 	 */
 	if (anonmm->mm && anonmm->mm->rss) {
-		ret = try_to_unmap_one(page,
-			anonmm->mm, page->index, &mapcount, NULL);
-		if (ret == SWAP_FAIL || !mapcount)
+		ret = try_to_unmap_one(page, anonmm->mm, page->index, NULL);
+		if (ret == SWAP_FAIL || !page->mapcount)
 			goto out;
 	}
 
@@ -681,9 +676,8 @@ static inline int try_to_unmap_anon(stru
 	list_for_each_entry(anonmm, seek_head, list) {
 		if (!anonmm->mm || !anonmm->mm->rss)
 			continue;
-		ret = try_to_unmap_one(page,
-			anonmm->mm, page->index, &mapcount, NULL);
-		if (ret == SWAP_FAIL || !mapcount)
+		ret = try_to_unmap_one(page, anonmm->mm, page->index, NULL);
+		if (ret == SWAP_FAIL || !page->mapcount)
 			goto out;
 	}
 out:
@@ -705,7 +699,6 @@ out:
  */
 static inline int try_to_unmap_file(struct page *page)
 {
-	unsigned int mapcount = page->mapcount;
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma = NULL;
@@ -715,6 +708,7 @@ static inline int try_to_unmap_file(stru
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
+	unsigned int mapcount;
 
 	if (!spin_trylock(&mapping->i_mmap_lock))
 		return ret;
@@ -723,9 +717,8 @@ static inline int try_to_unmap_file(stru
 					&iter, pgoff, pgoff)) != NULL) {
 		if (vma->vm_mm->rss) {
 			address = vma_address(vma, pgoff);
-			ret = try_to_unmap_one(page,
-				vma->vm_mm, address, &mapcount, vma);
-			if (ret == SWAP_FAIL || !mapcount)
+			ret = try_to_unmap_one(page, vma->vm_mm, address, vma);
+			if (ret == SWAP_FAIL || !page->mapcount)
 				goto out;
 		}
 	}
@@ -755,6 +748,7 @@ static inline int try_to_unmap_file(stru
 	 * The mapcount of the page we came in with is irrelevant,
 	 * but even so use it as a guide to how hard we should try?
 	 */
+	mapcount = page->mapcount;
 	page_map_unlock(page);
 	cond_resched_lock(&mapping->i_mmap_lock);
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
