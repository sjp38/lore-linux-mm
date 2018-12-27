Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3C588E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 14:24:55 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t133so23066163iof.20
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:24:55 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d138si5514159iof.74.2018.12.27.11.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 11:24:54 -0800 (PST)
Subject: Re: bug report: hugetlbfs: use i_mmap_rwsem for more pmd sharing,
 synchronization
References: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <29441ca1-82f1-2e4b-13f6-ad4fe9ed4d0f@oracle.com>
Date: Thu, 27 Dec 2018 11:24:31 -0800
MIME-Version: 1.0
In-Reply-To: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@canonical.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, stable@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/27/18 3:44 AM, Colin Ian King wrote:
> Hi,
> 
> Static analysis with CoverityScan on linux-next detected a potential
> null pointer dereference with the following commit:
> 
> From d8a1051ed4ba55679ef24e838a1942c9c40f0a14 Mon Sep 17 00:00:00 2001
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Sat, 22 Dec 2018 10:55:57 +1100
> Subject: [PATCH] hugetlbfs: use i_mmap_rwsem for more pmd sharing
> 
> The earlier check implies that "mapping" may be a null pointer:
> 
> var_compare_op: Comparing mapping to null implies that mapping might be
> null.
> 
> 1008        if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
> 1009            mapping_cap_writeback_dirty(mapping)) {
> 
> ..however later "mapper" is dereferenced when it may be potentially null:
> 
> 1034                /*
> 1035                 * For hugetlb pages, try_to_unmap could potentially
> call
> 1036                 * huge_pmd_unshare.  Because of this, take semaphore in
> 1037                 * write mode here and set TTU_RMAP_LOCKED to
> indicate we
> 1038                 * have taken the lock at this higer level.
> 1039                 */
>     CID 1476097 (#1 of 1): Dereference after null check (FORWARD_NULL)
> 
> var_deref_model: Passing null pointer mapping to
> i_mmap_lock_write, which dereferences it.
> 
> 1040                i_mmap_lock_write(mapping);
> 1041                unmap_success = try_to_unmap(hpage,
> ttu|TTU_RMAP_LOCKED);
> 1042                i_mmap_unlock_write(mapping);
> 

Thanks for the report.

The 'good news' is that mapping can not be null in the code path above.
The reasons are:
- The page is locked upon entry to the routine
- Earlier in the routine there is the check:
	if (!page_mapped(hpage))
		return true;
  For huge pages (which are processed in the else clause above), page_mapped
  implies page->mapping != null.

However, the routine hwpoison_user_mappings handles all page types.  The
page_mapped check is actually there to check for pages in the swap cache.
It is just coincidence that it also implies mapping != null for huge pages.

It would be better to make an explicit check for mapping != null before
calling i_mmap_lock_write/try_to_unmap.  In this way, unrelated changes to
code above will not potentially lead to the possibility of mapping == null.

I'm not sure what is the best way to handle this.  Below is an updated version
of the patch sent to Andrew.  I can also provide a simple patch to the patch
if that is easier.

From: Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization

While looking at BUGs associated with invalid huge page map counts,
it was discovered and observed that a huge pte pointer could become
'invalid' and point to another task's page table.  Consider the
following:

A task takes a page fault on a shared hugetlbfs file and calls
huge_pte_alloc to get a ptep.  Suppose the returned ptep points to a
shared pmd.

Now, another task truncates the hugetlbfs file.  As part of truncation,
it unmaps everyone who has the file mapped.  If the range being
truncated is covered by a shared pmd, huge_pmd_unshare will be called.
For all but the last user of the shared pmd, huge_pmd_unshare will
clear the pud pointing to the pmd.  If the task in the middle of the
page fault is not the last user, the ptep returned by huge_pte_alloc
now points to another task's page table or worse.  This leads to bad
things such as incorrect page map/reference counts or invalid memory
references.

To fix, expand the use of i_mmap_rwsem as follows:
- i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
  huge_pmd_share is only called via huge_pte_alloc, so callers of
  huge_pte_alloc take i_mmap_rwsem before calling.  In addition, callers
  of huge_pte_alloc continue to hold the semaphore until finished with
  the ptep.
- i_mmap_rwsem is held in write mode whenever huge_pmd_unshare is called.

Cc: <stable@vger.kernel.org>
Fixes: 39dde65c9940 ("shared page table for hugetlb page")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c        | 67 ++++++++++++++++++++++++++++++++++-----------
 mm/memory-failure.c | 16 +++++++++--
 mm/migrate.c        | 13 ++++++++-
 mm/rmap.c           |  4 +++
 mm/userfaultfd.c    | 11 ++++++--
 5 files changed, 90 insertions(+), 21 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 309fb8c969af..2a3162030167 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3239,6 +3239,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct
mm_struct *src,
 	int cow;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
+	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	int ret = 0;
@@ -3247,14 +3248,25 @@ int copy_hugetlb_page_range(struct mm_struct *dst,
struct mm_struct *src,

 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
-	if (cow)
+	if (cow) {
 		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
+	} else {
+		/*
+		 * For shared mappings i_mmap_rwsem must be held to call
+		 * huge_pte_alloc, otherwise the returned ptep could go
+		 * away if part of a shared pmd and another thread calls
+		 * huge_pmd_unshare.
+		 */
+		i_mmap_lock_read(mapping);
+	}

 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
+
 		src_pte = huge_pte_offset(src, addr, sz);
 		if (!src_pte)
 			continue;
+
 		dst_pte = huge_pte_alloc(dst, addr, sz);
 		if (!dst_pte) {
 			ret = -ENOMEM;
@@ -3325,6 +3337,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct
mm_struct *src,

 	if (cow)
 		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+	else
+		i_mmap_unlock_read(mapping);

 	return ret;
 }
@@ -3772,14 +3786,18 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 			};

 			/*
-			 * hugetlb_fault_mutex must be dropped before
-			 * handling userfault.  Reacquire after handling
-			 * fault to make calling code simpler.
+			 * hugetlb_fault_mutex and i_mmap_rwsem must be
+			 * dropped before handling userfault.  Reacquire
+			 * after handling fault to make calling code simpler.
 			 */
 			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
 							idx, haddr);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			i_mmap_unlock_read(mapping);
+
 			ret = handle_userfault(&vmf, VM_UFFD_MISSING);
+
+			i_mmap_lock_read(mapping);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
 			goto out;
 		}
@@ -3927,6 +3945,11 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct
vm_area_struct *vma,

 	ptep = huge_pte_offset(mm, haddr, huge_page_size(h));
 	if (ptep) {
+		/*
+		 * Since we hold no locks, ptep could be stale.  That is
+		 * OK as we are only making decisions based on content and
+		 * not actually modifying content here.
+		 */
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
 			migration_entry_wait_huge(vma, mm, ptep);
@@ -3934,20 +3957,31 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct
vm_area_struct *vma,
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
 				VM_FAULT_SET_HINDEX(hstate_index(h));
-	} else {
-		ptep = huge_pte_alloc(mm, haddr, huge_page_size(h));
-		if (!ptep)
-			return VM_FAULT_OOM;
 	}

+	/*
+	 * Acquire i_mmap_rwsem before calling huge_pte_alloc and hold
+	 * until finished with ptep.  This prevents huge_pmd_unshare from
+	 * being called elsewhere and making the ptep no longer valid.
+	 *
+	 * ptep could have already be assigned via huge_pte_offset.  That
+	 * is OK, as huge_pte_alloc will return the same value unless
+	 * something changed.
+	 */
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, haddr);
+	i_mmap_lock_read(mapping);
+	ptep = huge_pte_alloc(mm, haddr, huge_page_size(h));
+	if (!ptep) {
+		i_mmap_unlock_read(mapping);
+		return VM_FAULT_OOM;
+	}

 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
+	idx = vma_hugecache_offset(h, vma, haddr);
 	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, haddr);
 	mutex_lock(&hugetlb_fault_mutex_table[hash]);

@@ -4035,6 +4069,7 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct
vm_area_struct *vma,
 	}
 out_mutex:
 	mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+	i_mmap_unlock_read(mapping);
 	/*
 	 * Generally it's safe to hold refcount during waiting page lock. But
 	 * here we just wait to defer the next page fault to avoid busy loop and
@@ -4639,10 +4674,12 @@ void adjust_range_if_pmd_sharing_possible(struct
vm_area_struct *vma,
  * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
  * and returns the corresponding pte. While this is not necessary for the
  * !shared pmd case because we can allocate the pmd later as well, it makes the
- * code much cleaner. pmd allocation is essential for the shared case because
- * pud has to be populated inside the same i_mmap_rwsem section - otherwise
- * racing tasks could either miss the sharing (see huge_pte_offset) or select a
- * bad pmd for sharing.
+ * code much cleaner.
+ *
+ * This routine must be called with i_mmap_rwsem held in at least read mode.
+ * For hugetlbfs, this prevents removal of any page table entries associated
+ * with the address space.  This is important as we are setting up sharing
+ * based on existing page table entries (mappings).
  */
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
@@ -4659,7 +4696,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long
addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);

-	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -4689,7 +4725,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long
addr, pud_t *pud)
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	i_mmap_unlock_write(mapping);
 	return pte;
 }

@@ -4700,7 +4735,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long
addr, pud_t *pud)
  * indicated by page_count > 1, unmap is achieved by clearing pud and
  * decrementing the ref count. If count == 1, the pte page is not shared.
  *
- * called with page table lock held.
+ * Called with page table lock held and i_mmap_rwsem held in write mode.
  *
  * returns: 1 successfully unmapped a shared pte page
  *	    0 the underlying pte page is not shared, or it is the last user
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0cd3de3550f0..93558fb981fb 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -966,7 +966,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned
long pfn,
 	enum ttu_flags ttu = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
-	bool unmap_success;
+	bool unmap_success = true;
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
 	bool mlocked = PageMlocked(hpage);
@@ -1028,7 +1028,19 @@ static bool hwpoison_user_mappings(struct page *p,
unsigned long pfn,
 	if (kill)
 		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);

-	unmap_success = try_to_unmap(hpage, ttu);
+	if (!PageHuge(hpage)) {
+		unmap_success = try_to_unmap(hpage, ttu);
+	} else if (mapping) {
+		/*
+		 * For hugetlb pages, try_to_unmap could potentially call
+		 * huge_pmd_unshare.  Because of this, take semaphore in
+		 * write mode here and set TTU_RMAP_LOCKED to indicate we
+		 * have taken the lock at this higer level.
+		 */
+		i_mmap_lock_write(mapping);
+		unmap_success = try_to_unmap(hpage, ttu|TTU_RMAP_LOCKED);
+		i_mmap_unlock_write(mapping);
+	}
 	if (!unmap_success)
 		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
 		       pfn, page_mapcount(hpage));
diff --git a/mm/migrate.c b/mm/migrate.c
index 84381b55b2bd..725edaef238a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1307,8 +1307,19 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		goto put_anon;

 	if (page_mapped(hpage)) {
+		struct address_space *mapping = page_mapping(hpage);
+
+		/*
+		 * try_to_unmap could potentially call huge_pmd_unshare.
+		 * Because of this, take semaphore in write mode here and
+		 * set TTU_RMAP_LOCKED to let lower levels know we have
+		 * taken the lock.
+		 */
+		i_mmap_lock_write(mapping);
 		try_to_unmap(hpage,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
+			TTU_RMAP_LOCKED);
+		i_mmap_unlock_write(mapping);
 		page_was_mapped = 1;
 	}

diff --git a/mm/rmap.c b/mm/rmap.c
index 85b7f9423352..c566bd552535 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -25,6 +25,7 @@
  *     page->flags PG_locked (lock_page)
  *       hugetlbfs_i_mmap_rwsem_key (in huge_pmd_share)
  *         mapping->i_mmap_rwsem
+ *           hugetlb_fault_mutex (hugetlbfs specific page fault mutex)
  *           anon_vma->rwsem
  *             mm->page_table_lock or pte_lock
  *               zone_lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -1374,6 +1375,9 @@ static bool try_to_unmap_one(struct page *page, struct
vm_area_struct *vma,
 		/*
 		 * If sharing is possible, start and end will be adjusted
 		 * accordingly.
+		 *
+		 * If called for a huge page, caller must hold i_mmap_rwsem
+		 * in write mode as it is possible to call huge_pmd_unshare.
 		 */
 		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
 	}
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 458acda96f20..48368589f519 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -267,10 +267,14 @@ static __always_inline ssize_t
__mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		VM_BUG_ON(dst_addr & ~huge_page_mask(h));

 		/*
-		 * Serialize via hugetlb_fault_mutex
+		 * Serialize via i_mmap_rwsem and hugetlb_fault_mutex.
+		 * i_mmap_rwsem ensures the dst_pte remains valid even
+		 * in the case of shared pmds.  fault mutex prevents
+		 * races with other faulting threads.
 		 */
-		idx = linear_page_index(dst_vma, dst_addr);
 		mapping = dst_vma->vm_file->f_mapping;
+		i_mmap_lock_read(mapping);
+		idx = linear_page_index(dst_vma, dst_addr);
 		hash = hugetlb_fault_mutex_hash(h, dst_mm, dst_vma, mapping,
 								idx, dst_addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
@@ -279,6 +283,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct
mm_struct *dst_mm,
 		dst_pte = huge_pte_alloc(dst_mm, dst_addr, huge_page_size(h));
 		if (!dst_pte) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			i_mmap_unlock_read(mapping);
 			goto out_unlock;
 		}

@@ -286,6 +291,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct
mm_struct *dst_mm,
 		dst_pteval = huge_ptep_get(dst_pte);
 		if (!huge_pte_none(dst_pteval)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			i_mmap_unlock_read(mapping);
 			goto out_unlock;
 		}

@@ -293,6 +299,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct
mm_struct *dst_mm,
 						dst_addr, src_addr, &page);

 		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+		i_mmap_unlock_read(mapping);
 		vm_alloc_shared = vm_shared;

 		cond_resched();
-- 
2.17.2
