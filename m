Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AED88E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 18:55:20 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t192so22985271ywe.4
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 15:55:20 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h128si12347172ywa.35.2019.01.03.15.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 15:55:18 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/2] hugetlbfs: Revert "Use i_mmap_rwsem to fix page fault/truncate race"
Date: Thu,  3 Jan 2019 15:54:51 -0800
Message-Id: <20190103235452.29335-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

This reverts commit c86aa7bbfd5568ba8a82d3635d8f7b8a8e06fe54

The reverted commit caused ABBA deadlocks when file migration raced
with file eviction for specific hugetlbfs files.  This was discovered
with a modified version of the LTP move_pages12 test.

The purpose of the reverted patch was to close a long existing race
between hugetlbfs file truncation and page faults.  After more analysis
of the patch and impacted code, it was determined that i_mmap_rwsem can
not be used for all required synchronization.  Therefore, revert this
patch while working an another approach to the underlying issue.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 61 ++++++++++++++++++++++++--------------------
 mm/hugetlb.c         | 21 +++++++--------
 2 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 63a516096af3..3daf471bbd92 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -410,16 +410,17 @@ hugetlb_vmdelete_list(struct rb_root_cached *root, pgoff_t start, pgoff_t end)
  * truncation is indicated by end of range being LLONG_MAX
  *	In this case, we first scan the range and release found pages.
  *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
- *	maps and global counts.
+ *	maps and global counts.  Page faults can not race with truncation
+ *	in this routine.  hugetlb_no_page() prevents page faults in the
+ *	truncated range.  It checks i_size before allocation, and again after
+ *	with the page table lock for the page held.  The same lock must be
+ *	acquired to unmap a page.
  * hole punch is indicated if end is not LLONG_MAX
  *	In the hole punch case we scan the range and release found pages.
  *	Only when releasing a page is the associated region/reserv map
  *	deleted.  The region/reserv map for ranges without associated
- *	pages are not modified.
- *
- * Callers of this routine must hold the i_mmap_rwsem in write mode to prevent
- * races with page faults.
- *
+ *	pages are not modified.  Page faults can race with hole punch.
+ *	This is indicated if we find a mapped page.
  * Note: If the passed end of range value is beyond the end of file, but
  * not LLONG_MAX this routine still performs a hole punch operation.
  */
@@ -449,14 +450,32 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
+			u32 hash;
 
 			index = page->index;
+			hash = hugetlb_fault_mutex_hash(h, current->mm,
+							&pseudo_vma,
+							mapping, index, 0);
+			mutex_lock(&hugetlb_fault_mutex_table[hash]);
+
 			/*
-			 * A mapped page is impossible as callers should unmap
-			 * all references before calling.  And, i_mmap_rwsem
-			 * prevents the creation of additional mappings.
+			 * If page is mapped, it was faulted in after being
+			 * unmapped in caller.  Unmap (again) now after taking
+			 * the fault mutex.  The mutex will prevent faults
+			 * until we finish removing the page.
+			 *
+			 * This race can only happen in the hole punch case.
+			 * Getting here in a truncate operation is a bug.
 			 */
-			VM_BUG_ON(page_mapped(page));
+			if (unlikely(page_mapped(page))) {
+				BUG_ON(truncate_op);
+
+				i_mmap_lock_write(mapping);
+				hugetlb_vmdelete_list(&mapping->i_mmap,
+					index * pages_per_huge_page(h),
+					(index + 1) * pages_per_huge_page(h));
+				i_mmap_unlock_write(mapping);
+			}
 
 			lock_page(page);
 			/*
@@ -478,6 +497,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			}
 
 			unlock_page(page);
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
 		huge_pagevec_release(&pvec);
 		cond_resched();
@@ -489,20 +509,9 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
-	struct address_space *mapping = inode->i_mapping;
 	struct resv_map *resv_map;
 
-	/*
-	 * The vfs layer guarantees that there are no other users of this
-	 * inode.  Therefore, it would be safe to call remove_inode_hugepages
-	 * without holding i_mmap_rwsem.  We acquire and hold here to be
-	 * consistent with other callers.  Since there will be no contention
-	 * on the semaphore, overhead is negligible.
-	 */
-	i_mmap_lock_write(mapping);
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
-	i_mmap_unlock_write(mapping);
-
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */
 	if (resv_map)
@@ -523,8 +532,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	i_mmap_lock_write(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
 		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
-	remove_inode_hugepages(inode, offset, LLONG_MAX);
 	i_mmap_unlock_write(mapping);
+	remove_inode_hugepages(inode, offset, LLONG_MAX);
 	return 0;
 }
 
@@ -558,8 +567,8 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 			hugetlb_vmdelete_list(&mapping->i_mmap,
 						hole_start >> PAGE_SHIFT,
 						hole_end  >> PAGE_SHIFT);
-		remove_inode_hugepages(inode, hole_start, hole_end);
 		i_mmap_unlock_write(mapping);
+		remove_inode_hugepages(inode, hole_start, hole_end);
 		inode_unlock(inode);
 	}
 
@@ -642,11 +651,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		/* addr is the offset within the file (zero based) */
 		addr = index * hpage_size;
 
-		/*
-		 * fault mutex taken here, protects against fault path
-		 * and hole punch.  inode_lock previously taken protects
-		 * against truncation.
-		 */
+		/* mutex taken here, fault path and hole punch */
 		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
 						index, addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 611b68c43c00..5671ac9d13bb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3756,16 +3756,16 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	/*
-	 * We can not race with truncation due to holding i_mmap_rwsem.
-	 * Check once here for faults beyond end of file.
+	 * Use page lock to guard against racing truncation
+	 * before we get page_table_lock.
 	 */
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
-	if (idx >= size)
-		goto out;
-
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
+		size = i_size_read(mapping->host) >> huge_page_shift(h);
+		if (idx >= size)
+			goto out;
+
 		/*
 		 * Check for page in userfault range
 		 */
@@ -3855,6 +3855,9 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	ptl = huge_pte_lock(h, mm, ptep);
+	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	if (idx >= size)
+		goto backout;
 
 	ret = 0;
 	if (!huge_pte_none(huge_ptep_get(ptep)))
@@ -3957,10 +3960,8 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/*
 	 * Acquire i_mmap_rwsem before calling huge_pte_alloc and hold
-	 * until finished with ptep.  This serves two purposes:
-	 * 1) It prevents huge_pmd_unshare from being called elsewhere
-	 *    and making the ptep no longer valid.
-	 * 2) It synchronizes us with file truncation.
+	 * until finished with ptep.  This prevents huge_pmd_unshare from
+	 * being called elsewhere and making the ptep no longer valid.
 	 *
 	 * ptep could have already be assigned via huge_pte_offset.  That
 	 * is OK, as huge_pte_alloc will return the same value unless
-- 
2.17.2
