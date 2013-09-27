Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9716B004D
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:16:53 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2568653pbb.27
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:16:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 07/10] mm, hugetlb: convert hugetlbfs to use split pmd lock
Date: Fri, 27 Sep 2013 16:16:24 +0300
Message-Id: <1380287787-30252-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hugetlb supports multiple page sizes. We use split lock only for PMD
level, but not for PUD.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Alex Thorlton <athorlton@sgi.com>
---
 fs/proc/meminfo.c       |   2 +-
 include/linux/hugetlb.h |  25 +++++++++++
 include/linux/swapops.h |   7 ++--
 mm/hugetlb.c            | 108 +++++++++++++++++++++++++++++-------------------
 mm/mempolicy.c          |   5 ++-
 mm/migrate.c            |   7 ++--
 mm/rmap.c               |   2 +-
 7 files changed, 103 insertions(+), 53 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 59d85d6088..6d061f5359 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -1,8 +1,8 @@
 #include <linux/fs.h>
-#include <linux/hugetlb.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/hugetlb.h>
 #include <linux/mman.h>
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 0393270466..2132532b02 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -392,6 +392,15 @@ static inline int hugepage_migration_support(struct hstate *h)
 	return pmd_huge_support() && (huge_page_shift(h) == PMD_SHIFT);
 }
 
+static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
+               struct mm_struct *mm, pte_t *pte)
+{
+       if (huge_page_size(h) == PMD_SIZE)
+               return pmd_lockptr(mm, (pmd_t *) pte);
+       VM_BUG_ON(huge_page_size(h) == PAGE_SIZE);
+       return &mm->page_table_lock;
+}
+
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page_node(h, nid) NULL
@@ -401,6 +410,7 @@ struct hstate {};
 #define hstate_sizelog(s) NULL
 #define hstate_vma(v) NULL
 #define hstate_inode(i) NULL
+#define page_hstate(page) NULL
 #define huge_page_size(h) PAGE_SIZE
 #define huge_page_mask(h) PAGE_MASK
 #define vma_kernel_pagesize(v) PAGE_SIZE
@@ -421,6 +431,21 @@ static inline pgoff_t basepage_index(struct page *page)
 #define dissolve_free_huge_pages(s, e)	do {} while (0)
 #define pmd_huge_support()	0
 #define hugepage_migration_support(h)	0
+
+static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
+               struct mm_struct *mm, pte_t *pte)
+{
+       return &mm->page_table_lock;
+}
 #endif	/* CONFIG_HUGETLB_PAGE */
 
+static inline spinlock_t *huge_pte_lock(struct hstate *h,
+               struct mm_struct *mm, pte_t *pte)
+{
+       spinlock_t *ptl;
+       ptl = huge_pte_lockptr(h, mm, pte);
+       spin_lock(ptl);
+       return ptl;
+}
+
 #endif /* _LINUX_HUGETLB_H */
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 8d4fa82bfb..c0f75261a7 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -139,7 +139,8 @@ static inline void make_migration_entry_read(swp_entry_t *entry)
 
 extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					unsigned long address);
-extern void migration_entry_wait_huge(struct mm_struct *mm, pte_t *pte);
+extern void migration_entry_wait_huge(struct vm_area_struct *vma,
+		struct mm_struct *mm, pte_t *pte);
 #else
 
 #define make_migration_entry(page, write) swp_entry(0, 0)
@@ -151,8 +152,8 @@ static inline int is_migration_entry(swp_entry_t swp)
 static inline void make_migration_entry_read(swp_entry_t *entryp) { }
 static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 					 unsigned long address) { }
-static inline void migration_entry_wait_huge(struct mm_struct *mm,
-					pte_t *pte) { }
+static inline void migration_entry_wait_huge(struct vm_area_struct *vma,
+		struct mm_struct *mm, pte_t *pte) { }
 static inline int is_write_migration_entry(swp_entry_t entry)
 {
 	return 0;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b49579c7f2..1c13a6f8d8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2361,6 +2361,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
+		spinlock_t *src_ptl, *dst_ptl;
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
@@ -2372,8 +2373,9 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		if (dst_pte == src_pte)
 			continue;
 
-		spin_lock(&dst->page_table_lock);
-		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
+		dst_ptl = huge_pte_lock(h, dst, dst_pte);
+		src_ptl = huge_pte_lockptr(h, src, src_pte);
+		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 		if (!huge_pte_none(huge_ptep_get(src_pte))) {
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
@@ -2383,8 +2385,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			page_dup_rmap(ptepage);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
-		spin_unlock(&src->page_table_lock);
-		spin_unlock(&dst->page_table_lock);
+		spin_unlock(src_ptl);
+		spin_unlock(dst_ptl);
 	}
 	return 0;
 
@@ -2427,6 +2429,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	unsigned long address;
 	pte_t *ptep;
 	pte_t pte;
+	spinlock_t *ptl;
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
@@ -2440,25 +2443,25 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 again:
-	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
 
+		ptl = huge_pte_lock(h, mm, ptep);
 		if (huge_pmd_unshare(mm, &address, ptep))
-			continue;
+			goto unlock;
 
 		pte = huge_ptep_get(ptep);
 		if (huge_pte_none(pte))
-			continue;
+			goto unlock;
 
 		/*
 		 * HWPoisoned hugepage is already unmapped and dropped reference
 		 */
 		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
 			huge_pte_clear(mm, address, ptep);
-			continue;
+			goto unlock;
 		}
 
 		page = pte_page(pte);
@@ -2469,7 +2472,7 @@ again:
 		 */
 		if (ref_page) {
 			if (page != ref_page)
-				continue;
+				goto unlock;
 
 			/*
 			 * Mark the VMA as having unmapped its page so that
@@ -2486,13 +2489,18 @@ again:
 
 		page_remove_rmap(page);
 		force_flush = !__tlb_remove_page(tlb, page);
-		if (force_flush)
+		if (force_flush) {
+			spin_unlock(ptl);
 			break;
+		}
 		/* Bail out after unmapping reference page if supplied */
-		if (ref_page)
+		if (ref_page) {
+			spin_unlock(ptl);
 			break;
+		}
+unlock:
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * mmu_gather ran out of room to batch pages, we break out of
 	 * the PTE lock to avoid doing the potential expensive TLB invalidate
@@ -2598,7 +2606,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pte_t pte,
-			struct page *pagecache_page)
+			struct page *pagecache_page, spinlock_t *ptl)
 {
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
@@ -2632,8 +2640,8 @@ retry_avoidcopy:
 
 	page_cache_get(old_page);
 
-	/* Drop page_table_lock as buddy allocator may be called */
-	spin_unlock(&mm->page_table_lock);
+	/* Drop page table lock as buddy allocator may be called */
+	spin_unlock(ptl);
 	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
@@ -2651,12 +2659,12 @@ retry_avoidcopy:
 			BUG_ON(huge_pte_none(pte));
 			if (unmap_ref_private(mm, vma, old_page, address)) {
 				BUG_ON(huge_pte_none(pte));
-				spin_lock(&mm->page_table_lock);
+				spin_lock(ptl);
 				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 				if (likely(pte_same(huge_ptep_get(ptep), pte)))
 					goto retry_avoidcopy;
 				/*
-				 * race occurs while re-acquiring page_table_lock, and
+				 * race occurs while re-acquiring page table lock, and
 				 * our job is done.
 				 */
 				return 0;
@@ -2665,7 +2673,7 @@ retry_avoidcopy:
 		}
 
 		/* Caller expects lock to be held */
-		spin_lock(&mm->page_table_lock);
+		spin_lock(ptl);
 		if (err == -ENOMEM)
 			return VM_FAULT_OOM;
 		else
@@ -2680,7 +2688,7 @@ retry_avoidcopy:
 		page_cache_release(new_page);
 		page_cache_release(old_page);
 		/* Caller expects lock to be held */
-		spin_lock(&mm->page_table_lock);
+		spin_lock(ptl);
 		return VM_FAULT_OOM;
 	}
 
@@ -2692,10 +2700,10 @@ retry_avoidcopy:
 	mmun_end = mmun_start + huge_page_size(h);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	/*
-	 * Retake the page_table_lock to check for racing updates
+	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
 	 */
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
 		ClearPagePrivate(new_page);
@@ -2709,13 +2717,13 @@ retry_avoidcopy:
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 
 	/* Caller expects lock to be held */
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	return 0;
 }
 
@@ -2763,6 +2771,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping;
 	pte_t new_pte;
+	spinlock_t *ptl;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -2849,7 +2858,8 @@ retry:
 			goto backout_unlocked;
 		}
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(h, mm, ptep);
+	spin_lock(ptl);
 	size = i_size_read(mapping->host) >> huge_page_shift(h);
 	if (idx >= size)
 		goto backout;
@@ -2870,16 +2880,16 @@ retry:
 
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
-		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
+		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
 	}
 
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	unlock_page(page);
 out:
 	return ret;
 
 backout:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 backout_unlocked:
 	unlock_page(page);
 	put_page(page);
@@ -2891,6 +2901,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	pte_t *ptep;
 	pte_t entry;
+	spinlock_t *ptl;
 	int ret;
 	struct page *page = NULL;
 	struct page *pagecache_page = NULL;
@@ -2903,7 +2914,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
-			migration_entry_wait_huge(mm, ptep);
+			migration_entry_wait_huge(vma, mm, ptep);
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
@@ -2959,17 +2970,18 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (page != pagecache_page)
 		lock_page(page);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(h, mm, ptep);
+	spin_lock(ptl);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
-		goto out_page_table_lock;
+		goto out_ptl;
 
 
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!huge_pte_write(entry)) {
 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
-							pagecache_page);
-			goto out_page_table_lock;
+					pagecache_page, ptl);
+			goto out_ptl;
 		}
 		entry = huge_pte_mkdirty(entry);
 	}
@@ -2978,8 +2990,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
 
-out_page_table_lock:
-	spin_unlock(&mm->page_table_lock);
+out_ptl:
+	spin_unlock(ptl);
 
 	if (pagecache_page) {
 		unlock_page(pagecache_page);
@@ -3005,9 +3017,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long remainder = *nr_pages;
 	struct hstate *h = hstate_vma(vma);
 
-	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
+		spinlock_t *ptl = NULL;
 		int absent;
 		struct page *page;
 
@@ -3015,8 +3027,12 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * Some archs (sparc64, sh*) have multiple pte_ts to
 		 * each hugepage.  We have to make sure we get the
 		 * first, for the page indexing below to work.
+		 *
+		 * Note that page table lock is not held when pte is null.
 		 */
 		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
+		if (pte)
+			ptl = huge_pte_lock(h, mm, pte);
 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
 
 		/*
@@ -3028,6 +3044,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if (absent && (flags & FOLL_DUMP) &&
 		    !hugetlbfs_pagecache_present(h, vma, vaddr)) {
+			if (pte)
+				spin_unlock(ptl);
 			remainder = 0;
 			break;
 		}
@@ -3047,10 +3065,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		      !huge_pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
-			spin_unlock(&mm->page_table_lock);
+			if (pte)
+				spin_unlock(ptl);
 			ret = hugetlb_fault(mm, vma, vaddr,
 				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
-			spin_lock(&mm->page_table_lock);
 			if (!(ret & VM_FAULT_ERROR))
 				continue;
 
@@ -3081,8 +3099,8 @@ same_page:
 			 */
 			goto same_page;
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	*nr_pages = remainder;
 	*position = vaddr;
 
@@ -3103,13 +3121,15 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
+		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		ptl = huge_pte_lock(h, mm, ptep);
 		if (huge_pmd_unshare(mm, &address, ptep)) {
 			pages++;
+			spin_unlock(ptl);
 			continue;
 		}
 		if (!huge_pte_none(huge_ptep_get(ptep))) {
@@ -3119,8 +3139,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			set_huge_pte_at(mm, address, ptep, pte);
 			pages++;
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
@@ -3283,6 +3303,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	unsigned long saddr;
 	pte_t *spte = NULL;
 	pte_t *pte;
+	spinlock_t *ptl;
 
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
@@ -3305,13 +3326,14 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!spte)
 		goto out;
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
+	spin_lock(ptl);
 	if (pud_none(*pud))
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
 	else
 		put_page(virt_to_page(spte));
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
 	mutex_unlock(&mapping->i_mmap_mutex);
@@ -3325,7 +3347,7 @@ out:
  * indicated by page_count > 1, unmap is achieved by clearing pud and
  * decrementing the ref count. If count == 1, the pte page is not shared.
  *
- * called with vma->vm_mm->page_table_lock held.
+ * called with page table lock held.
  *
  * returns: 1 successfully unmapped a shared pte page
  *	    0 the underlying pte page is not shared, or it is the last user
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 04729647f3..930a3e64bd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -525,8 +525,9 @@ static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
 #ifdef CONFIG_HUGETLB_PAGE
 	int nid;
 	struct page *page;
+	spinlock_t *ptl;
 
-	spin_lock(&vma->vm_mm->page_table_lock);
+	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
 	page = pte_page(huge_ptep_get((pte_t *)pmd));
 	nid = page_to_nid(page);
 	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
@@ -536,7 +537,7 @@ static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
 	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
 		isolate_huge_page(page, private);
 unlock:
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	spin_unlock(ptl);
 #else
 	BUG();
 #endif
diff --git a/mm/migrate.c b/mm/migrate.c
index 9c8d5f59d3..0ac0668a08 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -130,7 +130,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		ptep = huge_pte_offset(mm, addr);
 		if (!ptep)
 			goto out;
-		ptl = &mm->page_table_lock;
+		ptl = huge_pte_lockptr(hstate_vma(vma), mm, ptep);
 	} else {
 		pmd = mm_find_pmd(mm, addr);
 		if (!pmd)
@@ -247,9 +247,10 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	__migration_entry_wait(mm, ptep, ptl);
 }
 
-void migration_entry_wait_huge(struct mm_struct *mm, pte_t *pte)
+void migration_entry_wait_huge(struct vm_area_struct *vma,
+		struct mm_struct *mm, pte_t *pte)
 {
-	spinlock_t *ptl = &(mm)->page_table_lock;
+	spinlock_t *ptl = huge_pte_lockptr(hstate_vma(vma), mm, pte);
 	__migration_entry_wait(mm, pte, ptl);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index b59d741dcf..55c8b8dc9f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -601,7 +601,7 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 
 	if (unlikely(PageHuge(page))) {
 		pte = huge_pte_offset(mm, address);
-		ptl = &mm->page_table_lock;
+		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
 		goto check;
 	}
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
