Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 788D06B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:16:36 -0500 (EST)
Received: by pdno5 with SMTP id o5so12065925pdn.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:16:36 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id np10si767447pbc.145.2015.02.20.20.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:16:35 -0800 (PST)
Received: by pdjz10 with SMTP id z10so11996724pdj.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:16:35 -0800 (PST)
Date: Fri, 20 Feb 2015 20:16:32 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 16/24] huge tmpfs: fix problems from premature exposure of
 pagetable
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202015090.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Andrea wrote a very interesting comment on THP in mm/memory.c,
just before the end of __handle_mm_fault():

 * A regular pmd is established and it can't morph into a huge pmd
 * from under us anymore at this point because we hold the mmap_sem
 * read mode and khugepaged takes it in write mode. So now it's
 * safe to run pte_offset_map().

This comment hints at several difficulties, which anon THP solved
for itself with mmap_sem and anon_vma lock, but which huge tmpfs
may need to solve differently.

The reference to pte_offset_map() above: I believe that's a hint
that on a 32-bit machine, the pagetables might need to come from
kernel-mapped memory, but a huge pmd pointing to user memory beyond
that limit could be racily substituted, causing undefined behavior
in the architecture-dependent pte_offset_map().

That itself is not a problem on x86_64, but there's plenty more:
how about those places which use pte_offset_map_lock() - if that
spinlock is in the struct page of a pagetable, which has been
deposited and might be withdrawn and freed at any moment (being
on a list unattached to the allocating pmd in the case of x86),
taking the spinlock might corrupt someone else's struct page.

Because THP has departed from the earlier rules (when pagetable
was only freed under exclusive mmap_sem, or at exit_mmap, after
removing all affected vmas from the rmap list): zap_huge_pmd()
does pte_free() even when serving MADV_DONTNEED under down_read
of mmap_sem.

And what of the "entry = *pte" at the start of handle_pte_fault(),
getting the entry used in pte_same(,orig_pte) tests to validate all
fault handling?  If that entry can itself be junk picked out of some
freed and reused pagetable, it's hard to estimate the consequences.

We need to consider the safety of concurrent faults, and the
safety of rmap lookups, and the safety of miscellaneous operations
such as smaps_pte_range() for reading /proc/<pid>/smaps.

I set out to make safe the places which descend pgd,pud,pmd,pte,
using more careful access techniques like mm_find_pmd(); but with
pte_offset_map() being architecture-defined, it's too big a job to
tighten it up all over.

Instead, approach from the opposite direction: just do not expose
a pagetable in an empty *pmd, until vm_ops->fault has had a chance
to ask for a huge pmd there.  This is a much easier change to make,
and we are lucky that all the driver faults appear to be using
interfaces (like vm_insert_page() and remap_pfn_range()) which
automatically do the pte_alloc() if it was not already done.

But we must not get stuck refaulting: need FAULT_FLAG_MAY_HUGE for
__do_fault() to tell shmem_fault() to try for huge only when *pmd is
empty (could instead add pmd to vmf and let shmem work that out for
itself, but probably better to hide pmd from vm_ops->faults).

Without a pagetable to hold the pte_none() entry found in a newly
allocated pagetable, handle_pte_fault() would like to provide a static
none entry for later orig_pte checks.  But architectures have never had
to provide that definition before; and although almost all use zeroes
for an empty pagetable, a few do not - nios2, s390, um, xtensa.

Never mind, forget about pte_same(,orig_pte), the three __do_fault()
callers can follow do_anonymous_page()'s example, and just use a
pte_none() check instead - supplemented by a pte_file pte_to_pgoff
check until the day VM_NONLINEAR is removed.

do_fault_around() presents one last problem: it wants pagetable to
have been allocated, but was being called by do_read_fault() before
__do_fault().  But I see no disadvantage to moving it after,
allowing huge pmd to be chosent first.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/filemap.c |   10 +-
 mm/memory.c  |  202 +++++++++++++++++++++++++++----------------------
 2 files changed, 118 insertions(+), 94 deletions(-)

--- thpfs.orig/mm/filemap.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/filemap.c	2015-02-20 19:34:42.875920943 -0800
@@ -2000,6 +2000,10 @@ void filemap_map_pages(struct vm_area_st
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
 		if (iter.index > vmf->max_pgoff)
 			break;
+
+		pte = vmf->pte + iter.index - vmf->pgoff;
+		if (!pte_none(*pte))
+			goto next;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -2020,6 +2024,8 @@ repeat:
 			goto repeat;
 		}
 
+		VM_BUG_ON_PAGE(page->index != iter.index, page);
+
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
 				PageHWPoison(page))
@@ -2034,10 +2040,6 @@ repeat:
 		if (page->index >= size >> PAGE_CACHE_SHIFT)
 			goto unlock;
 
-		pte = vmf->pte + page->index - vmf->pgoff;
-		if (!pte_none(*pte))
-			goto unlock;
-
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
--- thpfs.orig/mm/memory.c	2015-02-20 19:34:21.599969589 -0800
+++ thpfs/mm/memory.c	2015-02-20 19:34:42.875920943 -0800
@@ -2617,24 +2617,33 @@ static inline int check_stack_guard_page
 
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * but allow concurrent faults).  We return with mmap_sem still held.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags)
+		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
 	struct mem_cgroup *memcg;
+	pte_t *page_table;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
 
-	pte_unmap(page_table);
-
 	/* Check if we need to add a guard page to the stack */
 	if (check_stack_guard_page(vma, address) < 0)
 		return VM_FAULT_SIGSEGV;
 
+	/*
+	 * Use __pte_alloc instead of pte_alloc_map, because we can't
+	 * run pte_offset_map on the pmd, if an huge pmd could
+	 * materialize from under us from a different thread.
+	 */
+	if (unlikely(pmd_none(*pmd)) &&
+	    unlikely(__pte_alloc(mm, vma, pmd, address)))
+		return VM_FAULT_OOM;
+	/* If an huge pmd materialized from under us just retry later */
+	if (unlikely(pmd_trans_huge(*pmd)))
+		return 0;
+
 	/* Use the zero-page for reads */
 	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
@@ -2697,7 +2706,7 @@ oom:
  * See filemap_fault() and __lock_page_retry().
  */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-		pgoff_t pgoff, unsigned int flags, struct page **page)
+	pmd_t *pmd, pgoff_t pgoff, unsigned int flags, struct page **page)
 {
 	struct vm_fault vmf;
 	int ret;
@@ -2711,20 +2720,41 @@ static int __do_fault(struct vm_area_str
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	if (unlikely(PageHWPoison(vmf.page))) {
-		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf.page);
-		page_cache_release(vmf.page);
-		return VM_FAULT_HWPOISON;
-	}
-
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
 		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
 
+	if (unlikely(PageHWPoison(vmf.page))) {
+		ret = VM_FAULT_HWPOISON;
+		goto err;
+	}
+
+	/*
+	 * Use __pte_alloc instead of pte_alloc_map, because we can't
+	 * run pte_offset_map on the pmd, if an huge pmd could
+	 * materialize from under us from a different thread.
+	 */
+	if (unlikely(pmd_none(*pmd)) &&
+	    unlikely(__pte_alloc(vma->vm_mm, vma, pmd, address))) {
+		ret = VM_FAULT_OOM;
+		goto err;
+	}
+	/*
+	 * If an huge pmd materialized from under us just retry later.
+	 * Allow for racing transition of huge pmd to none to pagetable.
+	 */
+	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
+		ret = VM_FAULT_NOPAGE;
+		goto err;
+	}
+
 	*page = vmf.page;
 	return ret;
+err:
+	unlock_page(vmf.page);
+	page_cache_release(vmf.page);
+	return ret;
 }
 
 /**
@@ -2875,33 +2905,20 @@ static void do_fault_around(struct vm_ar
 
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pgoff_t pgoff, unsigned int flags)
 {
 	struct page *fault_page;
 	spinlock_t *ptl;
 	pte_t *pte;
-	int ret = 0;
-
-	/*
-	 * Let's call ->map_pages() first and use ->fault() as fallback
-	 * if page by the offset is not ready to be mapped (cold cache or
-	 * something).
-	 */
-	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
-	    fault_around_bytes >> PAGE_SHIFT > 1) {
-		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
-		if (!pte_same(*pte, orig_pte))
-			goto unlock_out;
-		pte_unmap_unlock(pte, ptl);
-	}
+	int ret;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte) &&
+	    !(pte_file(*pte) && pte_to_pgoff(*pte) == pgoff))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
@@ -2909,14 +2926,21 @@ static int do_read_fault(struct mm_struc
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
 	unlock_page(fault_page);
-unlock_out:
+
+	/*
+	 * Finally call ->map_pages() to fault around the pte we just set.
+	 */
+	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
+	    fault_around_bytes >> PAGE_SHIFT > 1)
+		do_fault_around(vma, address, pte, pgoff, flags);
+
 	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
 static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pgoff_t pgoff, unsigned int flags)
 {
 	struct page *fault_page, *new_page;
 	struct mem_cgroup *memcg;
@@ -2936,7 +2960,7 @@ static int do_cow_fault(struct mm_struct
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -2944,7 +2968,8 @@ static int do_cow_fault(struct mm_struct
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte) &&
+	    !(pte_file(*pte) && pte_to_pgoff(*pte) == pgoff))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
@@ -2965,7 +2990,7 @@ uncharge_out:
 
 static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pgoff_t pgoff, unsigned int flags)
 {
 	struct page *fault_page;
 	struct address_space *mapping;
@@ -2974,7 +2999,7 @@ static int do_shared_fault(struct mm_str
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -2993,7 +3018,8 @@ static int do_shared_fault(struct mm_str
 	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte) &&
+	    !(pte_file(*pte) && pte_to_pgoff(*pte) == pgoff))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
@@ -3034,20 +3060,16 @@ static int do_shared_fault(struct mm_str
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	pte_unmap(page_table);
 	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
+		return do_read_fault(mm, vma, address, pmd, pgoff, flags);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+		return do_cow_fault(mm, vma, address, pmd, pgoff, flags);
+	return do_shared_fault(mm, vma, address, pmd, pgoff, flags);
 }
 
 /*
@@ -3082,12 +3104,10 @@ static int do_nonlinear_fault(struct mm_
 
 	pgoff = pte_to_pgoff(orig_pte);
 	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
+		return do_read_fault(mm, vma, address, pmd, pgoff, flags);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+		return do_cow_fault(mm, vma, address, pmd, pgoff, flags);
+	return do_shared_fault(mm, vma, address, pmd, pgoff, flags);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3189,40 +3209,62 @@ out:
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with pte unmapped and unlocked.
- *
+ * We enter with non-exclusive mmap_sem
+ * (to exclude vma changes, but allow concurrent faults).
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int handle_pte_fault(struct mm_struct *mm,
 		     struct vm_area_struct *vma, unsigned long address,
-		     pte_t *pte, pmd_t *pmd, unsigned int flags)
+		     pmd_t *pmd, unsigned int flags)
 {
+	pte_t *pte;
 	pte_t entry;
 	spinlock_t *ptl;
 
+	/* If an huge pmd materialized from under us just retry later */
+	if (unlikely(pmd_trans_huge(*pmd)))
+		return 0;
+
+	if (unlikely(pmd_none(*pmd))) {
+		/*
+		 * Leave __pte_alloc() until later: because huge tmpfs may
+		 * want to map_team_by_pmd(), and if we expose page table
+		 * for an instant, it will be difficult to retract from
+		 * concurrent faults and from rmap lookups.
+		 */
+		pte = NULL;
+	} else {
+		/*
+		 * A regular pmd is established and it can't morph into a huge
+		 * pmd from under us anymore at this point because we hold the
+		 * mmap_sem read mode and khugepaged takes it in write mode.
+		 * So now it's safe to run pte_offset_map().
+		 */
+		pte = pte_offset_map(pmd, address);
+		entry = *pte;
+		barrier();
+		if (pte_none(entry)) {
+			pte_unmap(pte);
+			pte = NULL;
+		}
+	}
+
 	/*
 	 * some architectures can have larger ptes than wordsize,
 	 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and CONFIG_32BIT=y,
 	 * so READ_ONCE or ACCESS_ONCE cannot guarantee atomic accesses.
-	 * The code below just needs a consistent view for the ifs and
+	 * The code above just needs a consistent view for the ifs and
 	 * we later double check anyway with the ptl lock held. So here
 	 * a barrier will do.
 	 */
-	entry = *pte;
-	barrier();
+
+	if (!pte) {
+		if (vma->vm_ops && vma->vm_ops->fault)
+			return do_linear_fault(mm, vma, address, pmd, flags);
+		return do_anonymous_page(mm, vma, address, pmd, flags);
+	}
 	if (!pte_present(entry)) {
-		if (pte_none(entry)) {
-			if (vma->vm_ops) {
-				if (likely(vma->vm_ops->fault))
-					return do_linear_fault(mm, vma, address,
-						pte, pmd, flags, entry);
-			}
-			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, flags);
-		}
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
 					pte, pmd, flags, entry);
@@ -3273,7 +3315,6 @@ static int __handle_mm_fault(struct mm_s
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
@@ -3325,26 +3366,7 @@ static int __handle_mm_fault(struct mm_s
 		}
 	}
 
-	/*
-	 * Use __pte_alloc instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
-		return VM_FAULT_OOM;
-	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		return 0;
-	/*
-	 * A regular pmd is established and it can't morph into a huge pmd
-	 * from under us anymore at this point because we hold the mmap_sem
-	 * read mode and khugepaged takes it in write mode. So now it's
-	 * safe to run pte_offset_map().
-	 */
-	pte = pte_offset_map(pmd, address);
-
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return handle_pte_fault(mm, vma, address, pmd, flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
