Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A40382963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:37:41 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so11477332pab.11
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:37:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yb4si12138493pab.103.2014.05.06.07.37.39
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:37:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/8] mm, rmap: kill rmap_walk_control->file_nonlinear()
Date: Tue,  6 May 2014 17:37:28 +0300
Message-Id: <1399387052-31660-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody creates nonlinear VMAs. No need to support them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |   2 -
 mm/migrate.c         |  32 --------
 mm/rmap.c            | 216 ---------------------------------------------------
 3 files changed, 250 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 9be55c7617da..812774417407 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -237,7 +237,6 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
  * arg: passed to rmap_one() and invalid_vma()
  * rmap_one: executed on each vma where page is mapped
  * done: for checking traversing termination condition
- * file_nonlinear: for handling file nonlinear mapping
  * anon_lock: for getting anon_lock by optimized way rather than default
  * invalid_vma: for skipping uninterested vma
  */
@@ -246,7 +245,6 @@ struct rmap_walk_control {
 	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
 					unsigned long addr, void *arg);
 	int (*done)(struct page *page);
-	int (*file_nonlinear)(struct page *, struct address_space *, void *arg);
 	struct anon_vma *(*anon_lock)(struct page *page);
 	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
diff --git a/mm/migrate.c b/mm/migrate.c
index bed48809e5d0..b494fdb9a636 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -178,37 +178,6 @@ out:
 }
 
 /*
- * Congratulations to trinity for discovering this bug.
- * mm/fremap.c's remap_file_pages() accepts any range within a single vma to
- * convert that vma to VM_NONLINEAR; and generic_file_remap_pages() will then
- * replace the specified range by file ptes throughout (maybe populated after).
- * If page migration finds a page within that range, while it's still located
- * by vma_interval_tree rather than lost to i_mmap_nonlinear list, no problem:
- * zap_pte() clears the temporary migration entry before mmap_sem is dropped.
- * But if the migrating page is in a part of the vma outside the range to be
- * remapped, then it will not be cleared, and remove_migration_ptes() needs to
- * deal with it.  Fortunately, this part of the vma is of course still linear,
- * so we just need to use linear location on the nonlinear list.
- */
-static int remove_linear_migration_ptes_from_nonlinear(struct page *page,
-		struct address_space *mapping, void *arg)
-{
-	struct vm_area_struct *vma;
-	/* hugetlbfs does not support remap_pages, so no huge pgoff worries */
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	unsigned long addr;
-
-	list_for_each_entry(vma,
-		&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
-		if (addr >= vma->vm_start && addr < vma->vm_end)
-			remove_migration_pte(page, vma, addr, arg);
-	}
-	return SWAP_AGAIN;
-}
-
-/*
  * Get rid of all migration entries and replace them by
  * references to the indicated page.
  */
@@ -217,7 +186,6 @@ static void remove_migration_ptes(struct page *old, struct page *new)
 	struct rmap_walk_control rwc = {
 		.rmap_one = remove_migration_pte,
 		.arg = old,
-		.file_nonlinear = remove_linear_migration_ptes_from_nonlinear,
 	};
 
 	rmap_walk(new, &rwc);
diff --git a/mm/rmap.c b/mm/rmap.c
index d8e1a7e7fbe8..e031d4ad0a4b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1252,207 +1252,6 @@ out_mlock:
 	return ret;
 }
 
-/*
- * objrmap doesn't work for nonlinear VMAs because the assumption that
- * offset-into-file correlates with offset-into-virtual-addresses does not hold.
- * Consequently, given a particular page and its ->index, we cannot locate the
- * ptes which are mapping that page without an exhaustive linear search.
- *
- * So what this code does is a mini "virtual scan" of each nonlinear VMA which
- * maps the file to which the target page belongs.  The ->vm_private_data field
- * holds the current cursor into that scan.  Successive searches will circulate
- * around the vma's virtual address space.
- *
- * So as more replacement pressure is applied to the pages in a nonlinear VMA,
- * more scanning pressure is placed against them as well.   Eventually pages
- * will become fully unmapped and are eligible for eviction.
- *
- * For very sparsely populated VMAs this is a little inefficient - chances are
- * there there won't be many ptes located within the scan cluster.  In this case
- * maybe we could scan further - to the end of the pte page, perhaps.
- *
- * Mlocked pages:  check VM_LOCKED under mmap_sem held for read, if we can
- * acquire it without blocking.  If vma locked, mlock the pages in the cluster,
- * rather than unmapping them.  If we encounter the "check_page" that vmscan is
- * trying to unmap, return SWAP_MLOCK, else default SWAP_AGAIN.
- */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
-#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
-
-static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
-		struct vm_area_struct *vma, struct page *check_page)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t pteval;
-	spinlock_t *ptl;
-	struct page *page;
-	unsigned long address;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
-	unsigned long end;
-	int ret = SWAP_AGAIN;
-	int locked_vma = 0;
-
-	address = (vma->vm_start + cursor) & CLUSTER_MASK;
-	end = address + CLUSTER_SIZE;
-	if (address < vma->vm_start)
-		address = vma->vm_start;
-	if (end > vma->vm_end)
-		end = vma->vm_end;
-
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
-		return ret;
-
-	mmun_start = address;
-	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
-	/*
-	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
-	 * keep the sem while scanning the cluster for mlocking pages.
-	 */
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		locked_vma = (vma->vm_flags & VM_LOCKED);
-		if (!locked_vma)
-			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
-	}
-
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
-
-	for (; address < end; pte++, address += PAGE_SIZE) {
-		if (!pte_present(*pte))
-			continue;
-		page = vm_normal_page(vma, address, *pte);
-		BUG_ON(!page || PageAnon(page));
-
-		if (locked_vma) {
-			if (page == check_page) {
-				/* we know we have check_page locked */
-				mlock_vma_page(page);
-				ret = SWAP_MLOCK;
-			} else if (trylock_page(page)) {
-				/*
-				 * If we can lock the page, perform mlock.
-				 * Otherwise leave the page alone, it will be
-				 * eventually encountered again later.
-				 */
-				mlock_vma_page(page);
-				unlock_page(page);
-			}
-			continue;	/* don't unmap */
-		}
-
-		if (ptep_clear_flush_young_notify(vma, address, pte))
-			continue;
-
-		/* Nuke the page table entry. */
-		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush(vma, address, pte);
-
-		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address)) {
-			pte_t ptfile = pgoff_to_pte(page->index);
-			if (pte_soft_dirty(pteval))
-				pte_file_mksoft_dirty(ptfile);
-			set_pte_at(mm, address, pte, ptfile);
-		}
-
-		/* Move the dirty bit to the physical page now the pte is gone. */
-		if (pte_dirty(pteval))
-			set_page_dirty(page);
-
-		page_remove_rmap(page);
-		page_cache_release(page);
-		dec_mm_counter(mm, MM_FILEPAGES);
-		(*mapcount)--;
-	}
-	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	if (locked_vma)
-		up_read(&vma->vm_mm->mmap_sem);
-	return ret;
-}
-
-static int try_to_unmap_nonlinear(struct page *page,
-		struct address_space *mapping, void *arg)
-{
-	struct vm_area_struct *vma;
-	int ret = SWAP_AGAIN;
-	unsigned long cursor;
-	unsigned long max_nl_cursor = 0;
-	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
-
-	list_for_each_entry(vma,
-		&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-		cursor = (unsigned long) vma->vm_private_data;
-		if (cursor > max_nl_cursor)
-			max_nl_cursor = cursor;
-		cursor = vma->vm_end - vma->vm_start;
-		if (cursor > max_nl_size)
-			max_nl_size = cursor;
-	}
-
-	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
-		return SWAP_FAIL;
-	}
-
-	/*
-	 * We don't try to search for this page in the nonlinear vmas,
-	 * and page_referenced wouldn't have found it anyway.  Instead
-	 * just walk the nonlinear vmas trying to age and unmap some.
-	 * The mapcount of the page we came in with is irrelevant,
-	 * but even so use it as a guide to how hard we should try?
-	 */
-	mapcount = page_mapcount(page);
-	if (!mapcount)
-		return ret;
-
-	cond_resched();
-
-	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
-	if (max_nl_cursor == 0)
-		max_nl_cursor = CLUSTER_SIZE;
-
-	do {
-		list_for_each_entry(vma,
-			&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-			cursor = (unsigned long) vma->vm_private_data;
-			while (cursor < max_nl_cursor &&
-				cursor < vma->vm_end - vma->vm_start) {
-				if (try_to_unmap_cluster(cursor, &mapcount,
-						vma, page) == SWAP_MLOCK)
-					ret = SWAP_MLOCK;
-				cursor += CLUSTER_SIZE;
-				vma->vm_private_data = (void *) cursor;
-				if ((int)mapcount <= 0)
-					return ret;
-			}
-			vma->vm_private_data = (void *) max_nl_cursor;
-		}
-		cond_resched();
-		max_nl_cursor += CLUSTER_SIZE;
-	} while (max_nl_cursor <= max_nl_size);
-
-	/*
-	 * Don't loop forever (perhaps all the remaining pages are
-	 * in locked vmas).  Reset cursor on all unreserved nonlinear
-	 * vmas, now forgetting on which ones it had fallen behind.
-	 */
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
-		vma->vm_private_data = NULL;
-
-	return ret;
-}
-
 bool is_vma_temporary_stack(struct vm_area_struct *vma)
 {
 	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
@@ -1498,7 +1297,6 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)flags,
 		.done = page_not_mapped,
-		.file_nonlinear = try_to_unmap_nonlinear,
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
@@ -1544,12 +1342,6 @@ int try_to_munlock(struct page *page)
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)TTU_MUNLOCK,
 		.done = page_not_mapped,
-		/*
-		 * We don't bother to try to find the munlocked page in
-		 * nonlinears. It's costly. Instead, later, page reclaim logic
-		 * may call try_to_unmap() and recover PG_mlocked lazily.
-		 */
-		.file_nonlinear = NULL,
 		.anon_lock = page_lock_anon_vma_read,
 
 	};
@@ -1678,14 +1470,6 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 			goto done;
 	}
 
-	if (!rwc->file_nonlinear)
-		goto done;
-
-	if (list_empty(&mapping->i_mmap_nonlinear))
-		goto done;
-
-	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
-
 done:
 	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
