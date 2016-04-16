Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1996B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:38:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so258391142pfb.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:38:19 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id uz7si6294788pab.179.2016.04.16.16.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 16:38:18 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id fs9so47822232pac.2
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:38:18 -0700 (PDT)
Date: Sat, 16 Apr 2016 16:38:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm 4/5] huge tmpfs: avoid premature exposure of new
 pagetable revert
In-Reply-To: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604161633130.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch reverts all of my 09/31, your
huge-tmpfs-avoid-premature-exposure-of-new-pagetable.patch
and also the mm/memory.c changes from the patch after it,
huge-tmpfs-map-shmem-by-huge-page-pmd-or-by-page-team-ptes.patch

I've diffed this against the top of the tree, but it may be better to
throw this and huge-tmpfs-avoid-premature-exposure-of-new-pagetable.patch
away, and just delete the mm/memory.c part of the patch after it.

This is in preparation for 5/5, which replaces what was done here.
Why?  Numerous reasons.  Kirill was concerned that my movement of
map_pages from before to after fault would show performance regression.
Robot reported vm-scalability.throughput -5.5% regression, bisected to
the avoid premature exposure patch.  Andrew was concerned about bloat
in mm/memory.o.  Google had seen (on an earlier kernel) an OOM deadlock
from pagetable allocations being done while holding pagecache pagelock.

I thought I could deal with those later on, but the clincher came from
Xiong Zhou's report that it had broken binary execution from DAX mount.
Silly little oversight, but not as easily fixed as first appears, because
DAX now uses the i_mmap_rwsem to guard an extent from truncation: which
would be open to deadlock if pagetable allocation goes down to reclaim
(both are using only the read lock, but in danger of an rwr sandwich).

I've considered various alternative approaches, and what can be done
to get both DAX and huge tmpfs working again quickly.  Eventually
arrived at the obvious: shmem should use the new pmd_fault().

Reported-by: kernel test robot <xiaolong.ye@intel.com>
Reported-by: Xiong Zhou <jencce.kernel@gmail.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/filemap.c |   10 --
 mm/memory.c  |  225 +++++++++++++++++++++----------------------------
 2 files changed, 101 insertions(+), 134 deletions(-)

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2151,10 +2151,6 @@ void filemap_map_pages(struct vm_area_st
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
 		if (iter.index > vmf->max_pgoff)
 			break;
-
-		pte = vmf->pte + iter.index - vmf->pgoff;
-		if (!pte_none(*pte))
-			goto next;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -2176,8 +2172,6 @@ repeat:
 			goto repeat;
 		}
 
-		VM_BUG_ON_PAGE(page->index != iter.index, page);
-
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
 				PageHWPoison(page))
@@ -2192,6 +2186,10 @@ repeat:
 		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
+		pte = vmf->pte + page->index - vmf->pgoff;
+		if (!pte_none(*pte))
+			goto unlock;
+
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -45,7 +45,6 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
-#include <linux/pageteam.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/export.h>
@@ -2718,17 +2717,20 @@ static inline int check_stack_guard_page
 
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults).  We return with mmap_sem still held.
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned int flags)
 {
 	struct mem_cgroup *memcg;
-	pte_t *page_table;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
 
+	pte_unmap(page_table);
+
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
@@ -2737,27 +2739,6 @@ static int do_anonymous_page(struct mm_s
 	if (check_stack_guard_page(vma, address) < 0)
 		return VM_FAULT_SIGSEGV;
 
-	/*
-	 * Use pte_alloc instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pte_alloc(mm, pmd, address)))
-		return VM_FAULT_OOM;
-	/*
-	 * If a huge pmd materialized under us just retry later.  Use
-	 * pmd_trans_unstable() instead of pmd_trans_huge() to ensure the pmd
-	 * didn't become pmd_trans_huge under us and then back to pmd_none, as
-	 * a result of MADV_DONTNEED running immediately after a huge pmd fault
-	 * in a different thread of this mm, in turn leading to a misleading
-	 * pmd_trans_huge() retval.  All we have to ensure is that it is a
-	 * regular pmd that we can walk with pte_offset_map() and we can do that
-	 * through an atomic read in C, which is what pmd_trans_unstable()
-	 * provides.
-	 */
-	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd)))
-		return 0;
-
 	/* Use the zero-page for reads */
 	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
@@ -2836,8 +2817,8 @@ oom:
  * See filemap_fault() and __lock_page_retry().
  */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-		      pmd_t *pmd, pgoff_t pgoff, unsigned int flags,
-		      struct page *cow_page, struct page **page)
+			pgoff_t pgoff, unsigned int flags,
+			struct page *cow_page, struct page **page)
 {
 	struct vm_fault vmf;
 	int ret;
@@ -2849,20 +2830,17 @@ static int __do_fault(struct vm_area_str
 	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.cow_page = cow_page;
 
-	/*
-	 * Give huge pmd a chance before allocating pte or trying fault around.
-	 */
-	if (unlikely(pmd_none(*pmd)))
-		vmf.flags |= FAULT_FLAG_MAY_HUGE;
-
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (!vmf.page)
 		goto out;
-	if (unlikely(ret & VM_FAULT_HUGE)) {
-		ret |= map_team_by_pmd(vma, address, pmd, vmf.page);
-		return ret;
+
+	if (unlikely(PageHWPoison(vmf.page))) {
+		if (ret & VM_FAULT_LOCKED)
+			unlock_page(vmf.page);
+		put_page(vmf.page);
+		return VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
@@ -2870,35 +2848,9 @@ static int __do_fault(struct vm_area_str
 	else
 		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
 
-	if (unlikely(PageHWPoison(vmf.page))) {
-		ret = VM_FAULT_HWPOISON;
-		goto err;
-	}
-
-	/*
-	 * Use pte_alloc instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pte_alloc(vma->vm_mm, pmd, address))) {
-		ret = VM_FAULT_OOM;
-		goto err;
-	}
-	/*
-	 * If a huge pmd materialized under us just retry later.  Allow for
-	 * a racing transition of huge pmd to none to huge pmd or pagetable.
-	 */
-	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd))) {
-		ret = VM_FAULT_NOPAGE;
-		goto err;
-	}
  out:
 	*page = vmf.page;
 	return ret;
-err:
-	unlock_page(vmf.page);
-	put_page(vmf.page);
-	return ret;
 }
 
 /**
@@ -3048,19 +3000,32 @@ static void do_fault_around(struct vm_ar
 
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags)
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page;
 	spinlock_t *ptl;
 	pte_t *pte;
-	int ret;
+	int ret = 0;
 
-	ret = __do_fault(vma, address, pmd, pgoff, flags, NULL, &fault_page);
+	/*
+	 * Let's call ->map_pages() first and use ->fault() as fallback
+	 * if page by the offset is not ready to be mapped (cold cache or
+	 * something).
+	 */
+	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
+		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+		do_fault_around(vma, address, pte, pgoff, flags);
+		if (!pte_same(*pte, orig_pte))
+			goto unlock_out;
+		pte_unmap_unlock(pte, ptl);
+	}
+
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_none(*pte))) {
+	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3068,20 +3033,14 @@ static int do_read_fault(struct mm_struc
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
 	unlock_page(fault_page);
-
-	/*
-	 * Finally call ->map_pages() to fault around the pte we just set.
-	 */
-	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1)
-		do_fault_around(vma, address, pte, pgoff, flags);
-
+unlock_out:
 	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
 static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags)
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page, *new_page;
 	struct mem_cgroup *memcg;
@@ -3101,7 +3060,7 @@ static int do_cow_fault(struct mm_struct
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pmd, pgoff, flags, new_page, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -3110,7 +3069,7 @@ static int do_cow_fault(struct mm_struct
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_none(*pte))) {
+	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		if (fault_page) {
 			unlock_page(fault_page);
@@ -3147,7 +3106,7 @@ uncharge_out:
 
 static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags)
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page;
 	struct address_space *mapping;
@@ -3156,7 +3115,7 @@ static int do_shared_fault(struct mm_str
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pmd, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3175,7 +3134,7 @@ static int do_shared_fault(struct mm_str
 	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_none(*pte))) {
+	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3215,18 +3174,22 @@ static int do_shared_fault(struct mm_str
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff = linear_page_index(vma, address);
 
+	pte_unmap(page_table);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
 	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags);
+		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
+				orig_pte);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags);
+		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
+				orig_pte);
+	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3354,7 +3317,6 @@ static int wp_huge_pmd(struct mm_struct
 		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
 	if (vma->vm_ops->pmd_fault)
 		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
-	remap_team_by_ptes(vma, address, pmd);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3367,49 +3329,20 @@ static int wp_huge_pmd(struct mm_struct
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * We enter with non-exclusive mmap_sem
- * (to exclude vma changes, but allow concurrent faults).
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with pte unmapped and unlocked.
+ *
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+static int handle_pte_fault(struct mm_struct *mm,
+		     struct vm_area_struct *vma, unsigned long address,
+		     pte_t *pte, pmd_t *pmd, unsigned int flags)
 {
-	pmd_t pmdval;
-	pte_t *pte;
 	pte_t entry;
 	spinlock_t *ptl;
 
-	/* If a huge pmd materialized under us just retry later */
-	pmdval = *pmd;
-	barrier();
-	if (unlikely(pmd_trans_huge(pmdval) || pmd_devmap(pmdval)))
-		return 0;
-
-	if (unlikely(pmd_none(pmdval))) {
-		/*
-		 * Leave pte_alloc() until later: because huge tmpfs may
-		 * want to map_team_by_pmd(), and if we expose page table
-		 * for an instant, it will be difficult to retract from
-		 * concurrent faults and from rmap lookups.
-		 */
-		pte = NULL;
-	} else {
-		/*
-		 * A regular pmd is established and it can't morph into a huge
-		 * pmd from under us anymore at this point because we hold the
-		 * mmap_sem read mode and khugepaged takes it in write mode.
-		 * So now it's safe to run pte_offset_map().
-		 */
-		pte = pte_offset_map(pmd, address);
-		entry = *pte;
-		barrier();
-		if (pte_none(entry)) {
-			pte_unmap(pte);
-			pte = NULL;
-		}
-	}
-
 	/*
 	 * some architectures can have larger ptes than wordsize,
 	 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and CONFIG_32BIT=y,
@@ -3418,14 +3351,21 @@ static int handle_pte_fault(struct mm_st
 	 * we later double check anyway with the ptl lock held. So here
 	 * a barrier will do.
 	 */
-
-	if (!pte) {
-		if (!vma_is_anonymous(vma))
-			return do_fault(mm, vma, address, pmd, flags);
-		return do_anonymous_page(mm, vma, address, pmd, flags);
+	entry = *pte;
+	barrier();
+	if (!pte_present(entry)) {
+		if (pte_none(entry)) {
+			if (vma_is_anonymous(vma))
+				return do_anonymous_page(mm, vma, address,
+							 pte, pmd, flags);
+			else
+				return do_fault(mm, vma, address, pte, pmd,
+						flags, entry);
+		}
+		return do_swap_page(mm, vma, address,
+					pte, pmd, flags, entry);
 	}
-	if (!pte_present(entry))
-		return do_swap_page(mm, vma, address, pte, pmd, flags, entry);
+
 	if (pte_protnone(entry))
 		return do_numa_page(mm, vma, address, entry, pte, pmd);
 
@@ -3469,6 +3409,7 @@ static int __handle_mm_fault(struct mm_s
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
+	pte_t *pte;
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 					    flags & FAULT_FLAG_INSTRUCTION,
@@ -3514,7 +3455,35 @@ static int __handle_mm_fault(struct mm_s
 		}
 	}
 
-	return handle_pte_fault(mm, vma, address, pmd, flags);
+	/*
+	 * Use pte_alloc() instead of pte_alloc_map, because we can't
+	 * run pte_offset_map on the pmd, if an huge pmd could
+	 * materialize from under us from a different thread.
+	 */
+	if (unlikely(pte_alloc(mm, pmd, address)))
+		return VM_FAULT_OOM;
+	/*
+	 * If a huge pmd materialized under us just retry later.  Use
+	 * pmd_trans_unstable() instead of pmd_trans_huge() to ensure the pmd
+	 * didn't become pmd_trans_huge under us and then back to pmd_none, as
+	 * a result of MADV_DONTNEED running immediately after a huge pmd fault
+	 * in a different thread of this mm, in turn leading to a misleading
+	 * pmd_trans_huge() retval.  All we have to ensure is that it is a
+	 * regular pmd that we can walk with pte_offset_map() and we can do that
+	 * through an atomic read in C, which is what pmd_trans_unstable()
+	 * provides.
+	 */
+	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd)))
+		return 0;
+	/*
+	 * A regular pmd is established and it can't morph into a huge pmd
+	 * from under us anymore at this point because we hold the mmap_sem
+	 * read mode and khugepaged takes it in write mode. So now it's
+	 * safe to run pte_offset_map().
+	 */
+	pte = pte_offset_map(pmd, address);
+
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
