Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8776B003A
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:21 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so6724058pbc.12
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qt8si13716721pbb.161.2014.02.10.12.41.19
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/8] mm: introduce do_shared_fault() and drop do_fault()
Date: Mon, 10 Feb 2014 22:41:04 +0200
Message-Id: <1392064866-11840-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch introduces do_shared_fault(). The function does what
do_fault() does for write faults to shared mappings

Unlike do_fault(), do_shared_fault() is relatively clean and
straight-forward.

Old do_fault() is not needed anymore. Let it die.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 224 ++++++++++++++++--------------------------------------------
 1 file changed, 60 insertions(+), 164 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9ad0754d11ba..288a351c6dd0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2748,7 +2748,7 @@ reuse:
 		 * bit after it clear all dirty ptes, but before a racing
 		 * do_wp_page installs a dirty pte.
 		 *
-		 * do_fault is protected similarly.
+		 * do_shared_fault is protected similarly.
 		 */
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
@@ -3410,188 +3410,84 @@ uncharge_out:
 	return ret;
 }
 
-/*
- * do_fault() tries to create a new page mapping. It aggressively
- * tries to share with existing pages, but makes a separate copy if
- * the FAULT_FLAG_WRITE is set in the flags parameter in order to avoid
- * the next page fault.
- *
- * As this is called only for pages that do not currently exist, we
- * do not need to flush old virtual caches or the TLB.
- *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte neither mapped nor locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
- */
-static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
-	pte_t *page_table;
+	struct page *fault_page;
 	spinlock_t *ptl;
-	struct page *page, *fault_page;
-	struct page *cow_page;
-	pte_t entry;
-	int anon = 0;
-	struct page *dirty_page = NULL;
-	int ret;
-	int page_mkwrite = 0;
-
-	/*
-	 * If we do COW later, allocate page befor taking lock_page()
-	 * on the file cache page. This will reduce lock holding time.
-	 */
-	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
-
-		if (unlikely(anon_vma_prepare(vma)))
-			return VM_FAULT_OOM;
-
-		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
-		if (!cow_page)
-			return VM_FAULT_OOM;
-
-		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
-			page_cache_release(cow_page);
-			return VM_FAULT_OOM;
-		}
-	} else
-		cow_page = NULL;
+	pte_t entry, *pte;
+	int dirtied = 0;
+	struct vm_fault vmf;
+	int ret, tmp;
 
 	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-		goto uncharge_out;
+		return ret;
 
 	/*
-	 * Should we do an early C-O-W break?
+	 * Check if the backing address space wants to know that the page is
+	 * about to become writable
 	 */
-	page = fault_page;
-	if (flags & FAULT_FLAG_WRITE) {
-		if (!(vma->vm_flags & VM_SHARED)) {
-			page = cow_page;
-			anon = 1;
-			copy_user_highpage(page, fault_page, address, vma);
-			__SetPageUptodate(page);
-		} else {
-			/*
-			 * If the page will be shareable, see if the backing
-			 * address space wants to know that the page is about
-			 * to become writable
-			 */
-			if (vma->vm_ops->page_mkwrite) {
-				struct vm_fault vmf;
-				int tmp;
-
-				vmf.virtual_address =
-					(void __user *)(address & PAGE_MASK);
-				vmf.pgoff = pgoff;
-				vmf.flags = flags;
-				vmf.page = fault_page;
-
-				unlock_page(page);
-				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-				if (unlikely(tmp &
-					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-					ret = tmp;
-					goto unwritable_page;
-				}
-				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
-					lock_page(page);
-					if (!page->mapping) {
-						ret = 0; /* retry the fault */
-						unlock_page(page);
-						goto unwritable_page;
-					}
-				} else
-					VM_BUG_ON_PAGE(!PageLocked(page), page);
-				page_mkwrite = 1;
-			}
-		}
+	if (!vma->vm_ops->page_mkwrite)
+		goto set_pte;
 
-	}
+	unlock_page(fault_page);
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = pgoff;
+	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf.page = fault_page;
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+	if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+		page_cache_release(fault_page);
+		return tmp;
+	}
 
-	/*
-	 * This silly early PAGE_DIRTY setting removes a race
-	 * due to the bad i386 page protection. But it's valid
-	 * for other architectures too.
-	 *
-	 * Note that if FAULT_FLAG_WRITE is set, we either now have
-	 * an exclusive copy of the page, or this is a shared mapping,
-	 * so we can make it writable and dirty to avoid having to
-	 * handle that later.
-	 */
-	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
-		flush_icache_page(vma, page);
-		entry = mk_pte(page, vma->vm_page_prot);
-		if (flags & FAULT_FLAG_WRITE)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		else if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
-			pte_mksoft_dirty(entry);
-		if (anon) {
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
-			page_add_new_anon_rmap(page, vma, address);
-		} else {
-			inc_mm_counter_fast(mm, MM_FILEPAGES);
-			page_add_file_rmap(page);
-			if (flags & FAULT_FLAG_WRITE) {
-				dirty_page = page;
-				get_page(dirty_page);
-			}
+	if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+		lock_page(fault_page);
+		if (!fault_page->mapping) {
+			unlock_page(fault_page);
+			page_cache_release(fault_page);
+			return 0; /* retry */
 		}
-		set_pte_at(mm, address, page_table, entry);
-
-		/* no need to invalidate: a not-present page won't be cached */
-		update_mmu_cache(vma, address, page_table);
-	} else {
-		if (cow_page)
-			mem_cgroup_uncharge_page(cow_page);
-		if (anon)
-			page_cache_release(page);
-		else
-			anon = 1; /* no anon but release faulted_page */
+	} else
+		VM_BUG_ON_PAGE(!PageLocked(fault_page), fault_page);
+set_pte:
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (unlikely(!pte_same(*pte, orig_pte))) {
+		pte_unmap_unlock(pte, ptl);
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		return ret;
 	}
 
-	pte_unmap_unlock(page_table, ptl);
-
-	if (dirty_page) {
-		struct address_space *mapping = page->mapping;
-		int dirtied = 0;
+	flush_icache_page(vma, fault_page);
+	entry = mk_pte(fault_page, vma->vm_page_prot);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	page_add_file_rmap(fault_page);
+	set_pte_at(mm, address, pte, entry);
 
-		if (set_page_dirty(dirty_page))
-			dirtied = 1;
-		unlock_page(dirty_page);
-		put_page(dirty_page);
-		if ((dirtied || page_mkwrite) && mapping) {
-			/*
-			 * Some device drivers do not set page.mapping but still
-			 * dirty their pages
-			 */
-			balance_dirty_pages_ratelimited(mapping);
-		}
+	/* no need to invalidate: a not-present page won't be cached */
+	update_mmu_cache(vma, address, pte);
+	pte_unmap_unlock(pte, ptl);
 
-		/* file_update_time outside page_lock */
-		if (vma->vm_file && !page_mkwrite)
-			file_update_time(vma->vm_file);
-	} else {
-		unlock_page(fault_page);
-		if (anon)
-			page_cache_release(fault_page);
+	if (set_page_dirty(fault_page))
+		dirtied = 1;
+	unlock_page(fault_page);
+	if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {
+		/*
+		 * Some device drivers do not set page.mapping but still
+		 * dirty their pages
+		 */
+		balance_dirty_pages_ratelimited(fault_page->mapping);
 	}
 
-	return ret;
+	/* file_update_time outside page_lock */
+	if (vma->vm_file && !vma->vm_ops->page_mkwrite)
+		file_update_time(vma->vm_file);
 
-unwritable_page:
-	page_cache_release(page);
-	return ret;
-uncharge_out:
-	/* fs's fault handler get error */
-	if (cow_page) {
-		mem_cgroup_uncharge_page(cow_page);
-		page_cache_release(cow_page);
-	}
 	return ret;
 }
 
@@ -3609,7 +3505,7 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!(vma->vm_flags & VM_SHARED))
 		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
-	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 /*
@@ -3647,7 +3543,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!(vma->vm_flags & VM_SHARED))
 		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
-	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
