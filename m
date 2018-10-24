Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 958066B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 00:51:11 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id i81-v6so2379527ywe.20
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 21:51:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r189-v6si2259087ywr.371.2018.10.23.21.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 21:51:09 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH RFC v2 1/1] hugetlbfs: use i_mmap_rwsem for pmd sharing and truncate/fault sync
Date: Tue, 23 Oct 2018 21:50:53 -0700
Message-Id: <20181024045053.1467-2-mike.kravetz@oracle.com>
In-Reply-To: <20181024045053.1467-1-mike.kravetz@oracle.com>
References: <20181024045053.1467-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs does not correctly handle page faults racing with truncation.
In addition, shared pmds can cause additional issues.

Without pmd sharing, issues can occur as follows:
  A huegtlbfs file is mmap(MAP_SHARED) with a size of 4 pages.  At
  mmap time, 4 huge pages are reserved for the file/mapping.  So,
  the global reserve count is 4.  In addition, since this is a shared
  mapping an entry for 4 pages is added to the file's reserve map.
  The first 3 of the 4 pages are faulted into the file.  As a result,
  the global reserve count is now 1.

  Task A starts to fault in the last page (routines hugetlb_fault,
  hugetlb_no_page).  It allocates a huge page (alloc_huge_page).
  The reserve map indicates there is a reserved page, so this is
  used and the global reserve count goes to 0.

  Now, task B truncates the file to size 0.  It starts by setting
  inode size to 0(hugetlb_vmtruncate).  It then unmaps all mapping
  of the file (hugetlb_vmdelete_list).  Since task A's page table
  lock is not held at the time, truncation is not blocked.  Truncation
  removes the 3 pages from the file (remove_inode_hugepages).  When
  cleaning up the reserved pages (hugetlb_unreserve_pages), it notices
  the reserve map was for 4 pages.  However, it has only freed 3 pages.
  So it assumes there is still (4 - 3) 1 reserved pages.  It then
  decrements the global reserve count by 1 and it goes negative.

  Task A then continues the page fault process and adds it's newly
  acquired page to the page cache.  Note that the index of this page
  is beyond the size of the truncated file (0).  The page fault process
  then notices the file has been truncated and exits.  However, the
  page is left in the cache associated with the file.

  Now, if the file is immediately deleted the truncate code runs again.
  It will find and free the one page associated with the file.  When
  cleaning up reserves, it notices the reserve map is empty.  Yet, one
  page freed.  So, the global reserve count is decremented by (0 - 1) -1.
  This returns the global count to 0 as it should be.  But, it is
  possible for someone else to mmap this file/range before it is deleted.
  If this happens, a reserve map entry for the allocated page is created
  and the reserved page is forever leaked.

With pmd sharing, the situation is even worse.  Consider the following:
  A task processes a page fault on a shared hugetlbfs file and calls
  huge_pte_alloc to get a ptep.  Suppose the returned ptep points to a
  shared pmd.

  Now, anopther task truncates the hugetlbfs file.  As part of truncation,
  it unmaps everyone who has the file mapped.  If a task has a shared pmd
  in this range, huge_pmd_unshhare will be called.  If this is not the last
  user sharing the pmd, huge_pmd_unshare will clear pud pointing to the
  pmd.  For the task in the middle of the page fault, the ptep returned by
  huge_pte_alloc points to another task's page table or worse.  This leads
  to bad things such as incorrect page map/reference counts or invalid
  memory references.

i_mmap_rwsem is currently used for pmd sharing synchronization.  It is also
held during unmap and whenever a call to huge_pmd_unshare is possible.  It
is only acquired in write mode.  Expand and modify the use of i_mmap_rwsem
as follows:
- i_mmap_rwsem is held in write mode for the duration of truncate
  processing.
- i_mmap_rwsem is held in write mode whenever huge_pmd_share is called.
- i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
  Today that is only via huge_pte_alloc.
- i_mmap_rwsem is held in read mode after huge_pte_alloc, until the caller
  is finished with the returned ptep.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 21 ++++++++++----
 mm/hugetlb.c         | 65 +++++++++++++++++++++++++++++++++-----------
 mm/rmap.c            | 10 +++++++
 mm/userfaultfd.c     | 11 ++++++--
 4 files changed, 84 insertions(+), 23 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..6ee97622a231 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -426,10 +426,16 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			u32 hash;
 
 			index = page->index;
-			hash = hugetlb_fault_mutex_hash(h, current->mm,
+			/*
+			 * No need to take fault mutex for truncation as we
+			 * are synchronized via i_mmap_rwsem.
+			 */
+			if (!truncate_op) {
+				hash = hugetlb_fault_mutex_hash(h, current->mm,
 							&pseudo_vma,
 							mapping, index, 0);
-			mutex_lock(&hugetlb_fault_mutex_table[hash]);
+				mutex_lock(&hugetlb_fault_mutex_table[hash]);
+			}
 
 			/*
 			 * If page is mapped, it was faulted in after being
@@ -470,7 +476,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			}
 
 			unlock_page(page);
-			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			if (!truncate_op)
+				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
 		huge_pagevec_release(&pvec);
 		cond_resched();
@@ -505,8 +512,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	i_mmap_lock_write(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
 		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
-	i_mmap_unlock_write(mapping);
 	remove_inode_hugepages(inode, offset, LLONG_MAX);
+	i_mmap_unlock_write(mapping);
 	return 0;
 }
 
@@ -624,7 +631,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		/* addr is the offset within the file (zero based) */
 		addr = index * hpage_size;
 
-		/* mutex taken here, fault path and hole punch */
+		/*
+		 * fault mutex taken here, protects against fault path
+		 * and hole punch.  inode_lock previously taken protects
+		 * against truncation.
+		 */
 		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
 						index, addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7b5c0ad9a6bd..e9da3eee262f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3252,18 +3252,33 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
+		struct vm_area_struct *dst_vma;
+		struct address_space *mapping;
+
 		src_pte = huge_pte_offset(src, addr, sz);
 		if (!src_pte)
 			continue;
+
+		/*
+		 * i_mmap_rwsem must be held to call huge_pte_alloc.
+		 * Continue to hold until finished with dst_pte, otherwise
+		 * it could go away if part of a shared pmd.
+		 */
+		dst_vma = find_vma(dst, addr);
+		mapping = dst_vma->vm_file->f_mapping;
+		i_mmap_lock_read(mapping);
 		dst_pte = huge_pte_alloc(dst, addr, sz);
 		if (!dst_pte) {
+			i_mmap_unlock_read(mapping);
 			ret = -ENOMEM;
 			break;
 		}
 
 		/* If the pagetables are shared don't copy or take references */
-		if (dst_pte == src_pte)
+		if (dst_pte == src_pte) {
+			i_mmap_unlock_read(mapping);
 			continue;
+		}
 
 		dst_ptl = huge_pte_lock(h, dst, dst_pte);
 		src_ptl = huge_pte_lockptr(h, src, src_pte);
@@ -3306,6 +3321,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		}
 		spin_unlock(src_ptl);
 		spin_unlock(dst_ptl);
+
+		i_mmap_unlock_read(mapping);
 	}
 
 	if (cow)
@@ -3757,14 +3774,18 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
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
@@ -3919,20 +3940,29 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+	 * until finished with ptep.  This serves two purposes:
+	 * 1) It prevents huge_pmd_unshare from being called elsewhere
+	 *    and making the ptep no longer valid.
+	 * 2) It synchronizes us with file truncation.
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
 
@@ -4020,6 +4050,7 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 out_mutex:
 	mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+	i_mmap_unlock_read(mapping);
 	/*
 	 * Generally it's safe to hold refcount during waiting page lock. But
 	 * here we just wait to defer the next page fault to avoid busy loop and
@@ -4624,10 +4655,14 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
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
+ *
+ * pmd allocation is essential for the shared case because pud has to be
+ * populated while holding i_mmap_rwsem section - otherwise racing tasks could
+ * either miss the sharing (see huge_pte_offset) or
+ * select a bad pmd for sharing.
  */
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
@@ -4644,7 +4679,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -4674,7 +4708,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	i_mmap_unlock_write(mapping);
 	return pte;
 }
 
@@ -4685,7 +4718,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
  * indicated by page_count > 1, unmap is achieved by clearing pud and
  * decrementing the ref count. If count == 1, the pte page is not shared.
  *
- * called with page table lock held.
+ * called with page table lock held and i_mmap_rwsem held in write mode.
  *
  * returns: 1 successfully unmapped a shared pte page
  *	    0 the underlying pte page is not shared, or it is the last user
diff --git a/mm/rmap.c b/mm/rmap.c
index 1e79fac3186b..db49e734dda8 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1347,6 +1347,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	bool ret = true;
 	unsigned long start = address, end;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	bool pmd_sharing_possible = false;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1376,8 +1377,15 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * accordingly.
 		 */
 		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
+		if ((end - start) > (PAGE_SIZE << compound_order(page)))
+			pmd_sharing_possible = true;
 	}
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+	/*
+	 * Must hold i_mmap_rwsem in write mode if calling huge_pmd_unshare.
+	 */
+	if (pmd_sharing_possible)
+		i_mmap_lock_write(vma->vm_file->f_mapping);
 
 	while (page_vma_mapped_walk(&pvmw)) {
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
@@ -1657,6 +1665,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		put_page(page);
 	}
 
+	if (pmd_sharing_possible)
+		i_mmap_unlock_write(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
 
 	return ret;
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 5029f241908f..7cf4d8f7494b 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -244,10 +244,14 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
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
@@ -256,6 +260,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		dst_pte = huge_pte_alloc(dst_mm, dst_addr, huge_page_size(h));
 		if (!dst_pte) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			i_mmap_unlock_read(mapping);
 			goto out_unlock;
 		}
 
@@ -263,6 +268,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		dst_pteval = huge_ptep_get(dst_pte);
 		if (!huge_pte_none(dst_pteval)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			i_mmap_unlock_read(mapping);
 			goto out_unlock;
 		}
 
@@ -270,6 +276,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 						dst_addr, src_addr, &page);
 
 		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+		i_mmap_unlock_read(mapping);
 		vm_alloc_shared = vm_shared;
 
 		cond_resched();
-- 
2.17.2
