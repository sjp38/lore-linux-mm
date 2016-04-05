Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1526B0294
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:24:27 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n1so18472495pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:24:27 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id g1si3801317pfd.0.2016.04.05.14.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:24:26 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id e128so18466305pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:24:26 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:24:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 09/31] huge tmpfs: avoid premature exposure of new
 pagetable
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051423160.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In early development, a huge tmpfs fault simply replaced the pmd which
pointed to the empty pagetable just allocated in __handle_mm_fault():
but that is unsafe.

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
pte_offset_map() being architecture-defined, found it too big a job
to tighten up all over.

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
callers can follow do_anonymous_page(), and just use a pte_none() check.

do_fault_around() presents one last problem: it wants pagetable to
have been allocated, but was being called by do_read_fault() before
__do_fault().  I see no disadvantage to moving it after, allowing huge
pmd to be chosen first; but Kirill reports additional radix-tree lookup
in hot pagecache case when he implemented faultaround: needs further
investigation.

Note: after months of use, we recently hit an OOM deadlock: this patch
moves the new pagetable allocation inside where page lock is held on a
pagecache page, and exit's munlock_vma_pages_all() takes page lock on
all mlocked pages.  Both parties are behaving badly: we hope to change
munlock to use trylock_page() instead, but should certainly switch here
to preallocating the pagetable outside the page lock.  But I've not yet
written and tested that change.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/filemap.c |   10 +-
 mm/memory.c  |  215 ++++++++++++++++++++++++++-----------------------
 2 files changed, 123 insertions(+), 102 deletions(-)

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2147,6 +2147,10 @@ void filemap_map_pages(struct vm_area_st
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
@@ -2168,6 +2172,8 @@ repeat:
 			goto repeat;
 		}
 
+		VM_BUG_ON_PAGE(page->index != iter.index, page);
+
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
 				PageHWPoison(page))
@@ -2182,10 +2188,6 @@ repeat:
 		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
-		pte = vmf->pte + page->index - vmf->pgoff;
-		if (!pte_none(*pte))
-			goto unlock;
-
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2678,20 +2678,17 @@ static inline int check_stack_guard_page
 
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
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
@@ -2700,6 +2697,27 @@ static int do_anonymous_page(struct mm_s
 	if (check_stack_guard_page(vma, address) < 0)
 		return VM_FAULT_SIGSEGV;
 
+	/*
+	 * Use pte_alloc instead of pte_alloc_map, because we can't
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
+
 	/* Use the zero-page for reads */
 	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
@@ -2778,8 +2796,8 @@ oom:
  * See filemap_fault() and __lock_page_retry().
  */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-			pgoff_t pgoff, unsigned int flags,
-			struct page *cow_page, struct page **page)
+		      pmd_t *pmd, pgoff_t pgoff, unsigned int flags,
+		      struct page *cow_page, struct page **page)
 {
 	struct vm_fault vmf;
 	int ret;
@@ -2797,21 +2815,40 @@ static int __do_fault(struct vm_area_str
 	if (!vmf.page)
 		goto out;
 
-	if (unlikely(PageHWPoison(vmf.page))) {
-		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf.page);
-		put_page(vmf.page);
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
+	 * Use pte_alloc instead of pte_alloc_map, because we can't
+	 * run pte_offset_map on the pmd, if an huge pmd could
+	 * materialize from under us from a different thread.
+	 */
+	if (unlikely(pte_alloc(vma->vm_mm, pmd, address))) {
+		ret = VM_FAULT_OOM;
+		goto err;
+	}
+	/*
+	 * If a huge pmd materialized under us just retry later.  Allow for
+	 * a racing transition of huge pmd to none to huge pmd or pagetable.
+	 */
+	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd))) {
+		ret = VM_FAULT_NOPAGE;
+		goto err;
+	}
  out:
 	*page = vmf.page;
 	return ret;
+err:
+	unlock_page(vmf.page);
+	put_page(vmf.page);
+	return ret;
 }
 
 /**
@@ -2961,32 +2998,19 @@ static void do_fault_around(struct vm_ar
 
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
-	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
-		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
-		if (!pte_same(*pte, orig_pte))
-			goto unlock_out;
-		pte_unmap_unlock(pte, ptl);
-	}
+	int ret;
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -2994,14 +3018,20 @@ static int do_read_fault(struct mm_struc
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
 	unlock_page(fault_page);
-unlock_out:
+
+	/*
+	 * Finally call ->map_pages() to fault around the pte we just set.
+	 */
+	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1)
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
@@ -3021,7 +3051,7 @@ static int do_cow_fault(struct mm_struct
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, new_page, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
@@ -3030,7 +3060,7 @@ static int do_cow_fault(struct mm_struct
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte))) {
 		pte_unmap_unlock(pte, ptl);
 		if (fault_page) {
 			unlock_page(fault_page);
@@ -3067,7 +3097,7 @@ uncharge_out:
 
 static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pgoff_t pgoff, unsigned int flags)
 {
 	struct page *fault_page;
 	struct address_space *mapping;
@@ -3076,7 +3106,7 @@ static int do_shared_fault(struct mm_str
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(vma, address, pmd, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3095,7 +3125,7 @@ static int do_shared_fault(struct mm_str
 	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
+	if (unlikely(!pte_none(*pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3135,22 +3165,18 @@ static int do_shared_fault(struct mm_str
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
 	pgoff_t pgoff = linear_page_index(vma, address);
 
-	pte_unmap(page_table);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
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
@@ -3290,20 +3316,49 @@ static int wp_huge_pmd(struct mm_struct
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
-static int handle_pte_fault(struct mm_struct *mm,
-		     struct vm_area_struct *vma, unsigned long address,
-		     pte_t *pte, pmd_t *pmd, unsigned int flags)
+static int handle_pte_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
+	pmd_t pmdval;
+	pte_t *pte;
 	pte_t entry;
 	spinlock_t *ptl;
 
+	/* If a huge pmd materialized under us just retry later */
+	pmdval = *pmd;
+	barrier();
+	if (unlikely(pmd_trans_huge(pmdval) || pmd_devmap(pmdval)))
+		return 0;
+
+	if (unlikely(pmd_none(pmdval))) {
+		/*
+		 * Leave pte_alloc() until later: because huge tmpfs may
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
@@ -3312,21 +3367,14 @@ static int handle_pte_fault(struct mm_st
 	 * we later double check anyway with the ptl lock held. So here
 	 * a barrier will do.
 	 */
-	entry = *pte;
-	barrier();
-	if (!pte_present(entry)) {
-		if (pte_none(entry)) {
-			if (vma_is_anonymous(vma))
-				return do_anonymous_page(mm, vma, address,
-							 pte, pmd, flags);
-			else
-				return do_fault(mm, vma, address, pte, pmd,
-						flags, entry);
-		}
-		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
-	}
 
+	if (!pte) {
+		if (!vma_is_anonymous(vma))
+			return do_fault(mm, vma, address, pmd, flags);
+		return do_anonymous_page(mm, vma, address, pmd, flags);
+	}
+	if (!pte_present(entry))
+		return do_swap_page(mm, vma, address, pte, pmd, flags, entry);
 	if (pte_protnone(entry))
 		return do_numa_page(mm, vma, address, entry, pte, pmd);
 
@@ -3370,7 +3418,6 @@ static int __handle_mm_fault(struct mm_s
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 					    flags & FAULT_FLAG_INSTRUCTION,
@@ -3416,35 +3463,7 @@ static int __handle_mm_fault(struct mm_s
 		}
 	}
 
-	/*
-	 * Use pte_alloc() instead of pte_alloc_map, because we can't
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
