Message-Id: <20080719084303.857060828@jp.fujitsu.com>
References: <20080719084213.588795788@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 17:42:15 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [-mm][splitlru][PATCH 2/3] split LRU: munlock rework
Content-Disposition: inline; filename=munlock-rework.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

current munlock processing use to pagewalk.
its cause two problems.
  - build error on nommu machine
  - runtime error on HIGHPTE machine.

This patch fixes it.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Li Zefan <lizf@cn.fujitsu.com>
CC: Hugh Dickins <hugh@veritas.com>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
CC: Rik van Riel <riel@redhat.com>

---
 mm/mlock.c |  152 ++++++++++++++-----------------------------------------------
 1 file changed, 35 insertions(+), 117 deletions(-)

Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -147,18 +147,33 @@ static void munlock_vma_page(struct page
  * vma->vm_mm->mmap_sem must be held for write.
  */
 static int __mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+				   unsigned long start, unsigned long end,
+				   int mlock)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
 	struct page *pages[16]; /* 16 gives a reasonable batch */
-	int write = !!(vma->vm_flags & VM_WRITE);
 	int nr_pages = (end - start) / PAGE_SIZE;
 	int ret;
+	int gup_flags = 0;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(end   & ~PAGE_MASK);
+	VM_BUG_ON(start < vma->vm_start);
+	VM_BUG_ON(end   > vma->vm_end);
+	VM_BUG_ON((!rwsem_is_locked(&mm->mmap_sem)) &&
+		  (atomic_read(&mm->mm_users) != 0));
+
+	/*
+	 * mlock:   don't page populate if page has PROT_NONE permission.
+	 * munlock: the pages always do munlock althrough
+	 *          its has PROT_NONE permission.
+	 */
+	if (!mlock)
+		gup_flags |= GUP_FLAGS_IGNORE_VMA_PERMISSIONS;
 
-	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
-	VM_BUG_ON(start < vma->vm_start || end > vma->vm_end);
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	if (vma->vm_flags & VM_WRITE)
+		gup_flags |= GUP_FLAGS_WRITE;
 
 	lru_add_drain_all();	/* push cached pages to LRU */
 
@@ -171,9 +186,9 @@ static int __mlock_vma_pages_range(struc
 		 * get_user_pages makes pages present if we are
 		 * setting mlock.
 		 */
-		ret = get_user_pages(current, mm, addr,
+		ret = __get_user_pages(current, mm, addr,
 				min_t(int, nr_pages, ARRAY_SIZE(pages)),
-				write, 0, pages, NULL);
+				gup_flags, pages, NULL);
 		/*
 		 * This can happen for, e.g., VM_NONLINEAR regions before
 		 * a page has been allocated and mapped at a given offset,
@@ -202,8 +217,12 @@ static int __mlock_vma_pages_range(struc
 			 * us.  Check after acquiring page lock.
 			 */
 			lock_page(page);
-			if (page->mapping)
-				mlock_vma_page(page);
+			if (page->mapping) {
+				if (mlock)
+					mlock_vma_page(page);
+				else
+					munlock_vma_page(page);
+			}
 			unlock_page(page);
 			put_page(page);		/* ref from get_user_pages() */
 
@@ -221,120 +240,19 @@ static int __mlock_vma_pages_range(struc
 	return 0;	/* count entire vma as locked_vm */
 }
 
-/*
- * private structure for munlock page table walk
- */
-struct munlock_page_walk {
-	struct vm_area_struct *vma;
-	pmd_t                 *pmd; /* for migration_entry_wait() */
-};
-
-/*
- * munlock normal pages for present ptes
- */
-static int __munlock_pte_handler(pte_t *ptep, unsigned long addr,
-				   unsigned long end, struct mm_walk *walk)
-{
-	struct munlock_page_walk *mpw = walk->private;
-	swp_entry_t entry;
-	struct page *page;
-	pte_t pte;
-
-retry:
-	pte = *ptep;
-	/*
-	 * If it's a swap pte, we might be racing with page migration.
-	 */
-	if (unlikely(!pte_present(pte))) {
-		if (!is_swap_pte(pte))
-			goto out;
-		entry = pte_to_swp_entry(pte);
-		if (is_migration_entry(entry)) {
-			migration_entry_wait(mpw->vma->vm_mm, mpw->pmd, addr);
-			goto retry;
-		}
-		goto out;
-	}
-
-	page = vm_normal_page(mpw->vma, addr, pte);
-	if (!page)
-		goto out;
-
-	lock_page(page);
-	if (!page->mapping) {
-		unlock_page(page);
-		goto retry;
-	}
-	munlock_vma_page(page);
-	unlock_page(page);
-
-out:
-	return 0;
-}
-
-/*
- * Save pmd for pte handler for waiting on migration entries
- */
-static int __munlock_pmd_handler(pmd_t *pmd, unsigned long addr,
-				 unsigned long end, struct mm_walk *walk)
-{
-	struct munlock_page_walk *mpw = walk->private;
-
-	mpw->pmd = pmd;
-	return 0;
-}
-
-
-/*
- * munlock a range of pages in the vma using standard page table walk.
- *
- * vma->vm_mm->mmap_sem must be held for write.
- */
-static void __munlock_vma_pages_range(struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	struct munlock_page_walk mpw = {
-		.vma = vma,
-	};
-	struct mm_walk munlock_page_walk = {
-		.pmd_entry = __munlock_pmd_handler,
-		.pte_entry = __munlock_pte_handler,
-		.private = &mpw,
-		.mm = mm,
-	};
-
-	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
-	VM_BUG_ON((!rwsem_is_locked(&mm->mmap_sem)) &&
-		  (atomic_read(&mm->mm_users) != 0));
-	VM_BUG_ON(start < vma->vm_start);
-	VM_BUG_ON(end > vma->vm_end);
-
-	lru_add_drain_all();	/* push cached pages to LRU */
-	walk_page_range(start, end, &munlock_page_walk);
-	lru_add_drain_all();	/* to update stats */
-}
-
 #else /* CONFIG_UNEVICTABLE_LRU */
 
 /*
  * Just make pages present if VM_LOCKED.  No-op if unlocking.
  */
 static int __mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+				   unsigned long start, unsigned long end,
+				   int mlock)
 {
-	if (vma->vm_flags & VM_LOCKED)
+	if (mlock && (vma->vm_flags & VM_LOCKED))
 		make_pages_present(start, end);
 	return 0;
 }
-
-/*
- * munlock a range of pages in the vma -- no-op.
- */
-static void __munlock_vma_pages_range(struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
-{
-}
 #endif /* CONFIG_UNEVICTABLE_LRU */
 
 /*
@@ -357,7 +275,7 @@ int mlock_vma_pages_range(struct vm_area
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 		downgrade_write(&mm->mmap_sem);
-		nr_pages = __mlock_vma_pages_range(vma, start, end);
+		nr_pages = __mlock_vma_pages_range(vma, start, end, 1);
 
 		up_read(&mm->mmap_sem);
 		/* vma can change or disappear */
@@ -392,7 +310,7 @@ void munlock_vma_pages_range(struct vm_a
 			   unsigned long start, unsigned long end)
 {
 	vma->vm_flags &= ~VM_LOCKED;
-	__munlock_vma_pages_range(vma, start, end);
+	__mlock_vma_pages_range(vma, start, end, 0);
 }
 
 /*
@@ -469,7 +387,7 @@ success:
 		 */
 		downgrade_write(&mm->mmap_sem);
 
-		ret = __mlock_vma_pages_range(vma, start, end);
+		ret = __mlock_vma_pages_range(vma, start, end, 1);
 		if (ret > 0) {
 			mm->locked_vm -= ret;
 			ret = 0;
@@ -495,7 +413,7 @@ success:
 		 * while.  Should we downgrade the semaphore for both lock
 		 * AND unlock ?
 		 */
-		__munlock_vma_pages_range(vma, start, end);
+		__mlock_vma_pages_range(vma, start, end, 0);
 	}
 
 out:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
