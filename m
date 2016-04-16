Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D75436B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:16 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so109279981pad.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ew7si7092272pad.131.2016.04.15.17.24.12
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 04/29] mm: postpone page table allocation until we have page to map
Date: Sat, 16 Apr 2016 03:23:35 +0300
Message-Id: <1460766240-84565-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The idea (and most of code) is borrowed again: from Hugh's patchset on
huge tmpfs[1].

Instead of allocation pte page table upfront, we postpone this until we
have page to map in hands. This approach opens possibility to map the
page as huge if filesystem supports this.

Comparing to Hugh's patch I've pushed page table allocation a bit
further: into do_set_pte(). This way we can postpone allocation even in
faultaround case without moving do_fault_around() after __do_fault().

do_set_pte() got renamed to alloc_set_pte() as it can allocate page
table if required.

[1] http://lkml.kernel.org/r/alpine.LSU.2.11.1502202015090.14414@eggly.anvils

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  10 +-
 mm/filemap.c       |  16 +--
 mm/memory.c        | 297 +++++++++++++++++++++++++++++++----------------------
 3 files changed, 196 insertions(+), 127 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 696ec39b616b..afe79bb75c47 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -320,6 +320,13 @@ struct fault_env {
 					 * Protects pte page table if 'pte'
 					 * is not NULL, otherwise pmd.
 					 */
+	pgtable_t prealloc_pte;		/* Pre-allocated pte page table.
+					 * vm_ops->map_pages() calls
+					 * alloc_set_pte() from atomic context.
+					 * do_fault_around() pre-allocates
+					 * page table to avoid allocation from
+					 * atomic context.
+					 */
 };
 
 /*
@@ -601,7 +608,8 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
-void do_set_pte(struct fault_env *fe, struct page *page);
+int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
+		struct page *page);
 #endif
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index e32e5d70fc0c..7e982835d4ec 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2147,11 +2147,6 @@ void filemap_map_pages(struct fault_env *fe,
 			start_pgoff) {
 		if (iter.index > end_pgoff)
 			break;
-		fe->pte += iter.index - last_pgoff;
-		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
-		last_pgoff = iter.index;
-		if (!pte_none(*fe->pte))
-			goto next;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -2189,7 +2184,13 @@ repeat:
 
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
-		do_set_pte(fe, page);
+
+		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		if (fe->pte)
+			fe->pte += iter.index - last_pgoff;
+		last_pgoff = iter.index;
+		if (alloc_set_pte(fe, NULL, page))
+			goto unlock;
 		unlock_page(page);
 		goto next;
 unlock:
@@ -2197,6 +2198,9 @@ unlock:
 skip:
 		put_page(page);
 next:
+		/* Huge page is mapped? No need to proceed. */
+		if (pmd_trans_huge(*fe->pmd))
+			break;
 		if (iter.index == end_pgoff)
 			break;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 6c37f84212ee..c31c52507956 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2679,8 +2679,6 @@ static int do_anonymous_page(struct fault_env *fe)
 	struct page *page;
 	pte_t entry;
 
-	pte_unmap(fe->pte);
-
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
@@ -2689,6 +2687,23 @@ static int do_anonymous_page(struct fault_env *fe)
 	if (check_stack_guard_page(vma, fe->address) < 0)
 		return VM_FAULT_SIGSEGV;
 
+	/*
+	 * Use pte_alloc() instead of pte_alloc_map().  We can't run
+	 * pte_offset_map() on pmds where a huge pmd might be created
+	 * from a different thread.
+	 *
+	 * pte_alloc_map() is safe to use under down_write(mmap_sem) or when
+	 * parallel threads are excluded by other means.
+	 *
+	 * Here we only have down_read(mmap_sem).
+	 */
+	if (pte_alloc(vma->vm_mm, fe->pmd, fe->address))
+		return VM_FAULT_OOM;
+
+	/* See the comment in pte_alloc_one_map() */
+	if (unlikely(pmd_trans_unstable(fe->pmd)))
+		return 0;
+
 	/* Use the zero-page for reads */
 	if (!(fe->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
@@ -2804,23 +2819,76 @@ static int __do_fault(struct fault_env *fe, pgoff_t pgoff,
 	return ret;
 }
 
+static int pte_alloc_one_map(struct fault_env *fe)
+{
+	struct vm_area_struct *vma = fe->vma;
+
+	if (!pmd_none(*fe->pmd))
+		goto map_pte;
+	if (fe->prealloc_pte) {
+		fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+		if (unlikely(!pmd_none(*fe->pmd))) {
+			spin_unlock(fe->ptl);
+			goto map_pte;
+		}
+
+		atomic_long_inc(&vma->vm_mm->nr_ptes);
+		pmd_populate(vma->vm_mm, fe->pmd, fe->prealloc_pte);
+		spin_unlock(fe->ptl);
+		fe->prealloc_pte = 0;
+	} else if (unlikely(pte_alloc(vma->vm_mm, fe->pmd, fe->address))) {
+		return VM_FAULT_OOM;
+	}
+map_pte:
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
+	if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))
+		return VM_FAULT_NOPAGE;
+
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+			&fe->ptl);
+	return 0;
+}
+
 /**
- * do_set_pte - setup new PTE entry for given page and add reverse page mapping.
+ * alloc_set_pte - setup new PTE entry for given page and add reverse page
+ * mapping. If needed, the fucntion allocates page table or use pre-allocated.
  *
  * @fe: fault environment
+ * @memcg: memcg to charge page (only for private mappings)
  * @page: page to map
  *
- * Caller must hold page table lock relevant for @fe->pte.
+ * Caller must take care of unlocking fe->ptl, if fe->pte is non-NULL on return.
  *
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
  */
-void do_set_pte(struct fault_env *fe, struct page *page)
+int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
+		struct page *page)
 {
 	struct vm_area_struct *vma = fe->vma;
 	bool write = fe->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
 
+	if (!fe->pte) {
+		int ret = pte_alloc_one_map(fe);
+		if (ret)
+			return ret;
+	}
+
+	/* Re-check under ptl */
+	if (unlikely(!pte_none(*fe->pte)))
+		return VM_FAULT_NOPAGE;
+
 	flush_icache_page(vma, page);
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
@@ -2829,6 +2897,8 @@ void do_set_pte(struct fault_env *fe, struct page *page)
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, fe->address, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page);
@@ -2837,6 +2907,8 @@ void do_set_pte(struct fault_env *fe, struct page *page)
 
 	/* no need to invalidate: a not-present page won't be cached */
 	update_mmu_cache(vma, fe->address, fe->pte);
+
+	return 0;
 }
 
 static unsigned long fault_around_bytes __read_mostly =
@@ -2903,19 +2975,17 @@ late_initcall(fault_around_debugfs);
  * fault_around_pages() value (and therefore to page order).  This way it's
  * easier to guarantee that we don't cross page table boundaries.
  */
-static void do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
+static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 {
-	unsigned long address = fe->address, start_addr, nr_pages, mask;
-	pte_t *pte = fe->pte;
+	unsigned long address = fe->address, nr_pages, mask;
 	pgoff_t end_pgoff;
-	int off;
+	int off, ret = 0;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
 
-	start_addr = max(fe->address & mask, fe->vma->vm_start);
-	off = ((fe->address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
-	fe->pte -= off;
+	fe->address = max(address & mask, fe->vma->vm_start);
+	off = ((address - fe->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
 	start_pgoff -= off;
 
 	/*
@@ -2923,30 +2993,45 @@ static void do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 	 *  or fault_around_pages() from start_pgoff, depending what is nearest.
 	 */
 	end_pgoff = start_pgoff -
-		((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+		((fe->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
 	end_pgoff = min3(end_pgoff, vma_pages(fe->vma) + fe->vma->vm_pgoff - 1,
 			start_pgoff + nr_pages - 1);
 
-	/* Check if it makes any sense to call ->map_pages */
-	fe->address = start_addr;
-	while (!pte_none(*fe->pte)) {
-		if (++start_pgoff > end_pgoff)
-			goto out;
-		fe->address += PAGE_SIZE;
-		if (fe->address >= fe->vma->vm_end)
-			goto out;
-		fe->pte++;
+	if (pmd_none(*fe->pmd)) {
+		fe->prealloc_pte = pte_alloc_one(fe->vma->vm_mm, fe->address);
+		smp_wmb(); /* See comment in __pte_alloc() */
 	}
 
 	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
+
+	/* preallocated pagetable is unused: free it */
+	if (fe->prealloc_pte) {
+		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
+		fe->prealloc_pte = 0;
+	}
+	/* Huge page is mapped? Page fault is solved */
+	if (pmd_trans_huge(*fe->pmd)) {
+		ret = VM_FAULT_NOPAGE;
+		goto out;
+	}
+
+	/* ->map_pages() haven't done anything useful. Cold page cache? */
+	if (!fe->pte)
+		goto out;
+
+	/* check if the page fault is solved */
+	fe->pte -= (fe->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
+	if (!pte_none(*fe->pte))
+		ret = VM_FAULT_NOPAGE;
+	pte_unmap_unlock(fe->pte, fe->ptl);
 out:
-	/* restore fault_env */
-	fe->pte = pte;
 	fe->address = address;
+	fe->pte = NULL;
+	return ret;
 }
 
-static int do_read_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
+static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page;
@@ -2958,33 +3043,25 @@ static int do_read_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 	 * something).
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-				&fe->ptl);
-		do_fault_around(fe, pgoff);
-		if (!pte_same(*fe->pte, orig_pte))
-			goto unlock_out;
-		pte_unmap_unlock(fe->pte, fe->ptl);
+		ret = do_fault_around(fe, pgoff);
+		if (ret)
+			return ret;
 	}
 
 	ret = __do_fault(fe, pgoff, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+	ret |= alloc_set_pte(fe, NULL, fault_page);
+	if (fe->pte)
 		pte_unmap_unlock(fe->pte, fe->ptl);
-		unlock_page(fault_page);
-		put_page(fault_page);
-		return ret;
-	}
-	do_set_pte(fe, fault_page);
 	unlock_page(fault_page);
-unlock_out:
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		put_page(fault_page);
 	return ret;
 }
 
-static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
+static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page, *new_page;
@@ -3012,26 +3089,9 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 		copy_user_highpage(new_page, fault_page, fe->address, vma);
 	__SetPageUptodate(new_page);
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+	ret |= alloc_set_pte(fe, memcg, new_page);
+	if (fe->pte)
 		pte_unmap_unlock(fe->pte, fe->ptl);
-		if (fault_page) {
-			unlock_page(fault_page);
-			put_page(fault_page);
-		} else {
-			/*
-			 * The fault handler has no page to lock, so it holds
-			 * i_mmap_lock for read to protect against truncate.
-			 */
-			i_mmap_unlock_read(vma->vm_file->f_mapping);
-		}
-		goto uncharge_out;
-	}
-	do_set_pte(fe, new_page);
-	mem_cgroup_commit_charge(new_page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
-	pte_unmap_unlock(fe->pte, fe->ptl);
 	if (fault_page) {
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3042,6 +3102,8 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 		 */
 		i_mmap_unlock_read(vma->vm_file->f_mapping);
 	}
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		goto uncharge_out;
 	return ret;
 uncharge_out:
 	mem_cgroup_cancel_charge(new_page, memcg, false);
@@ -3049,7 +3111,7 @@ uncharge_out:
 	return ret;
 }
 
-static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
+static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page;
@@ -3075,16 +3137,15 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 		}
 	}
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+	ret |= alloc_set_pte(fe, NULL, fault_page);
+	if (fe->pte)
 		pte_unmap_unlock(fe->pte, fe->ptl);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+					VM_FAULT_RETRY))) {
 		unlock_page(fault_page);
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(fe, fault_page);
-	pte_unmap_unlock(fe->pte, fe->ptl);
 
 	if (set_page_dirty(fault_page))
 		dirtied = 1;
@@ -3116,20 +3177,19 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_fault(struct fault_env *fe, pte_t orig_pte)
+static int do_fault(struct fault_env *fe)
 {
 	struct vm_area_struct *vma = fe->vma;
 	pgoff_t pgoff = linear_page_index(vma, fe->address);
 
-	pte_unmap(fe->pte);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
 	if (!(fe->flags & FAULT_FLAG_WRITE))
-		return do_read_fault(fe, pgoff,	orig_pte);
+		return do_read_fault(fe, pgoff);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(fe, pgoff, orig_pte);
-	return do_shared_fault(fe, pgoff, orig_pte);
+		return do_cow_fault(fe, pgoff);
+	return do_shared_fault(fe, pgoff);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3269,37 +3329,62 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with pte unmapped and unlocked.
+ * We enter with non-exclusive mmap_sem (to exclude vma changes, but allow
+ * concurrent faults).
  *
- * The mmap_sem may have been released depending on flags and our
- * return value.  See filemap_fault() and __lock_page_or_retry().
+ * The mmap_sem may have been released depending on flags and our return value.
+ * See filemap_fault() and __lock_page_or_retry().
  */
 static int handle_pte_fault(struct fault_env *fe)
 {
 	pte_t entry;
 
-	/*
-	 * some architectures can have larger ptes than wordsize,
-	 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and CONFIG_32BIT=y,
-	 * so READ_ONCE or ACCESS_ONCE cannot guarantee atomic accesses.
-	 * The code below just needs a consistent view for the ifs and
-	 * we later double check anyway with the ptl lock held. So here
-	 * a barrier will do.
-	 */
-	entry = *fe->pte;
-	barrier();
-	if (!pte_present(entry)) {
+	if (unlikely(pmd_none(*fe->pmd))) {
+		/*
+		 * Leave __pte_alloc() until later: because vm_ops->fault may
+		 * want to allocate huge page, and if we expose page table
+		 * for an instant, it will be difficult to retract from
+		 * concurrent faults and from rmap lookups.
+		 */
+	} else {
+		/* See comment in pte_alloc_one_map() */
+		if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))
+			return 0;
+		/*
+		 * A regular pmd is established and it can't morph into a huge
+		 * pmd from under us anymore at this point because we hold the
+		 * mmap_sem read mode and khugepaged takes it in write mode.
+		 * So now it's safe to run pte_offset_map().
+		 */
+		fe->pte = pte_offset_map(fe->pmd, fe->address);
+
+		entry = *fe->pte;
+
+		/*
+		 * some architectures can have larger ptes than wordsize,
+		 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and
+		 * CONFIG_32BIT=y, so READ_ONCE or ACCESS_ONCE cannot guarantee
+		 * atomic accesses.  The code below just needs a consistent
+		 * view for the ifs and we later double check anyway with the
+		 * ptl lock held. So here a barrier will do.
+		 */
+		barrier();
 		if (pte_none(entry)) {
-			if (vma_is_anonymous(fe->vma))
-				return do_anonymous_page(fe);
-			else
-				return do_fault(fe, entry);
+			pte_unmap(fe->pte);
+			fe->pte = NULL;
 		}
-		return do_swap_page(fe, entry);
 	}
 
+	if (!fe->pte) {
+		if (vma_is_anonymous(fe->vma))
+			return do_anonymous_page(fe);
+		else
+			return do_fault(fe);
+	}
+
+	if (!pte_present(entry))
+		return do_swap_page(fe, entry);
+
 	if (pte_protnone(entry))
 		return do_numa_page(fe, entry);
 
@@ -3381,34 +3466,6 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 	}
 
-	/*
-	 * Use pte_alloc() instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pte_alloc(fe.vma->vm_mm, fe.pmd, fe.address)))
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
-	if (unlikely(pmd_trans_unstable(fe.pmd) || pmd_devmap(*fe.pmd)))
-		return 0;
-	/*
-	 * A regular pmd is established and it can't morph into a huge pmd
-	 * from under us anymore at this point because we hold the mmap_sem
-	 * read mode and khugepaged takes it in write mode. So now it's
-	 * safe to run pte_offset_map().
-	 */
-	fe.pte = pte_offset_map(fe.pmd, fe.address);
-
 	return handle_pte_fault(&fe);
 }
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
