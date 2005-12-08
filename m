From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208112945.6309.14050.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 01/07] Remove page_mapcount
Date: Thu,  8 Dec 2005 20:27:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Remove page_mapcount.

This patch removes the page_mapcount() function and replaces it with
page_mapped() if possible. can_share_swap_page() always returns 0 for now.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 fs/proc/task_mmu.c |    2 +-
 include/linux/mm.h |    5 -----
 mm/fremap.c        |    2 --
 mm/page_alloc.c    |   10 ++++------
 mm/rmap.c          |   40 ++++++++--------------------------------
 mm/swapfile.c      |    8 ++------
 6 files changed, 15 insertions(+), 52 deletions(-)

--- from-0002/fs/proc/task_mmu.c
+++ to-work/fs/proc/task_mmu.c	2005-12-08 10:52:13.000000000 +0900
@@ -421,7 +421,7 @@ static struct numa_maps *get_numa_maps(s
  	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
 		page = follow_page(vma, vaddr, 0);
 		if (page) {
-			int count = page_mapcount(page);
+			int count = page_mapped(page);
 
 			if (count)
 				md->mapped++;
--- from-0002/include/linux/mm.h
+++ to-work/include/linux/mm.h	2005-12-08 10:52:13.000000000 +0900
@@ -586,11 +586,6 @@ static inline void reset_page_mapcount(s
 	atomic_set(&(page)->_mapcount, -1);
 }
 
-static inline int page_mapcount(struct page *page)
-{
-	return atomic_read(&(page)->_mapcount) + 1;
-}
-
 /*
  * Return true if this page is mapped into pagetables.
  */
--- from-0002/mm/fremap.c
+++ to-work/mm/fremap.c	2005-12-08 10:52:13.000000000 +0900
@@ -72,8 +72,6 @@ int install_page(struct mm_struct *mm, s
 	if (!page->mapping || page->index >= size)
 		goto unlock;
 	err = -ENOMEM;
-	if (page_mapcount(page) > INT_MAX/2)
-		goto unlock;
 
 	if (pte_none(*pte) || !zap_pte(mm, vma, addr, pte))
 		inc_mm_counter(mm, file_rss);
--- from-0002/mm/page_alloc.c
+++ to-work/mm/page_alloc.c	2005-12-08 10:52:13.000000000 +0900
@@ -126,9 +126,9 @@ static void bad_page(const char *functio
 {
 	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
 		function, current->comm, page);
-	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
+	printk(KERN_EMERG "flags:0x%0*lx mapping:%p count:%d\n",
 		(int)(2*sizeof(unsigned long)), (unsigned long)page->flags,
-		page->mapping, page_mapcount(page), page_count(page));
+		page->mapping, page_count(page));
 	printk(KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n");
@@ -336,8 +336,7 @@ static inline void __free_pages_bulk (st
 
 static inline int free_pages_check(const char *function, struct page *page)
 {
-	if (	page_mapcount(page) ||
-		page->mapping != NULL ||
+	if (	page->mapping != NULL ||
 		page_count(page) != 0 ||
 		(page->flags & (
 			1 << PG_lru	|
@@ -473,8 +472,7 @@ void set_page_refs(struct page *page, in
  */
 static int prep_new_page(struct page *page, int order)
 {
-	if (	page_mapcount(page) ||
-		page->mapping != NULL ||
+	if (	page->mapping != NULL ||
 		page_count(page) != 0 ||
 		(page->flags & (
 			1 << PG_lru	|
--- from-0002/mm/rmap.c
+++ to-work/mm/rmap.c	2005-12-08 11:02:06.000000000 +0900
@@ -289,8 +289,7 @@ pte_t *page_check_address(struct page *p
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
-static int page_referenced_one(struct page *page,
-	struct vm_area_struct *vma, unsigned int *mapcount)
+static int page_referenced_one(struct page *page, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -315,7 +314,6 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
-	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
 	return referenced;
@@ -323,7 +321,6 @@ out:
 
 static int page_referenced_anon(struct page *page)
 {
-	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	int referenced = 0;
@@ -332,12 +329,9 @@ static int page_referenced_anon(struct p
 	if (!anon_vma)
 		return referenced;
 
-	mapcount = page_mapcount(page);
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		referenced += page_referenced_one(page, vma, &mapcount);
-		if (!mapcount)
-			break;
-	}
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		referenced += page_referenced_one(page, vma);
+
 	spin_unlock(&anon_vma->lock);
 	return referenced;
 }
@@ -355,7 +349,6 @@ static int page_referenced_anon(struct p
  */
 static int page_referenced_file(struct page *page)
 {
-	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
@@ -379,21 +372,13 @@ static int page_referenced_file(struct p
 
 	spin_lock(&mapping->i_mmap_lock);
 
-	/*
-	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
-	 * is more likely to be accurate if we note it after spinning.
-	 */
-	mapcount = page_mapcount(page);
-
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
 				  == (VM_LOCKED|VM_MAYSHARE)) {
 			referenced++;
 			break;
 		}
-		referenced += page_referenced_one(page, vma, &mapcount);
-		if (!mapcount)
-			break;
+		referenced += page_referenced_one(page, vma);
 	}
 
 	spin_unlock(&mapping->i_mmap_lock);
@@ -483,7 +468,6 @@ void page_add_file_rmap(struct page *pag
 void page_remove_rmap(struct page *page)
 {
 	if (atomic_add_negative(-1, &page->_mapcount)) {
-		BUG_ON(page_mapcount(page) < 0);
 		/*
 		 * It would be tidy to reset the PageAnon mapping here,
 		 * but that might overwrite a racing page_add_anon_rmap
@@ -594,7 +578,7 @@ out:
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
 static void try_to_unmap_cluster(unsigned long cursor,
-	unsigned int *mapcount, struct vm_area_struct *vma)
+	struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -655,7 +639,6 @@ static void try_to_unmap_cluster(unsigne
 		page_remove_rmap(page);
 		page_cache_release(page);
 		dec_mm_counter(mm, file_rss);
-		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 }
@@ -698,7 +681,6 @@ static int try_to_unmap_file(struct page
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
@@ -731,12 +713,8 @@ static int try_to_unmap_file(struct page
 	 * We don't try to search for this page in the nonlinear vmas,
 	 * and page_referenced wouldn't have found it anyway.  Instead
 	 * just walk the nonlinear vmas trying to age and unmap some.
-	 * The mapcount of the page we came in with is irrelevant,
-	 * but even so use it as a guide to how hard we should try?
 	 */
-	mapcount = page_mapcount(page);
-	if (!mapcount)
-		goto out;
+
 	cond_resched_lock(&mapping->i_mmap_lock);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
@@ -751,11 +729,9 @@ static int try_to_unmap_file(struct page
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
-				try_to_unmap_cluster(cursor, &mapcount, vma);
+				try_to_unmap_cluster(cursor, vma);
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
-				if ((int)mapcount <= 0)
-					goto out;
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
--- from-0002/mm/swapfile.c
+++ to-work/mm/swapfile.c	2005-12-08 10:52:13.000000000 +0900
@@ -308,13 +308,9 @@ static inline int page_swapcount(struct 
  */
 int can_share_swap_page(struct page *page)
 {
-	int count;
-
 	BUG_ON(!PageLocked(page));
-	count = page_mapcount(page);
-	if (count <= 1 && PageSwapCache(page))
-		count += page_swapcount(page);
-	return count == 1;
+
+	return 0;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
