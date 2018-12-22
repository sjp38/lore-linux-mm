Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id F22888E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 17:30:45 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so9533712ita.1
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 14:30:45 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b21si7593350itc.73.2018.12.22.14.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Dec 2018 14:30:44 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 2/2] hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
Date: Sat, 22 Dec 2018 14:30:13 -0800
Message-Id: <20181222223013.22193-3-mike.kravetz@oracle.com>
In-Reply-To: <20181222223013.22193-1-mike.kravetz@oracle.com>
References: <20181222223013.22193-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

hugetlbfs page faults can race with truncate and hole punch operations.
Current code in the page fault path attempts to handle this by 'backing
out' operations if we encounter the race.  One obvious omission in the
current code is removing a page newly added to the page cache.  This is
pretty straight forward to address, but there is a more subtle and
difficult issue of backing out hugetlb reservations.  To handle this
correctly, the 'reservation state' before page allocation needs to be
noted so that it can be properly backed out.  There are four distinct
possibilities for reservation state: shared/reserved, shared/no-resv,
private/reserved and private/no-resv.  Backing out a reservation may
require memory allocation which could fail so that needs to be taken
into account as well.

Instead of writing the required complicated code for this rare
occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
mode for the duration of page fault processing.  Hold i_mmap_rwsem
longer in truncation and hold punch code to cover the call to
remove_inode_hugepages.

With this modification, code in remove_inode_hugepages checking for
races becomes 'dead' as it can not longer happen.  Remove the dead code
and expand comments to explain reasoning.  Similarly, checks for races
with truncation in the page fault path can be simplified and removed.

Cc: <stable@vger.kernel.org>
Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 61 ++++++++++++++++++++------------------------
 mm/hugetlb.c         | 21 ++++++++-------
 2 files changed, 38 insertions(+), 44 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..a2fcea5f8225 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -383,17 +383,16 @@ hugetlb_vmdelete_list(struct rb_root_cached *root, pgoff_t start, pgoff_t end)
  * truncation is indicated by end of range being LLONG_MAX
  *	In this case, we first scan the range and release found pages.
  *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
- *	maps and global counts.  Page faults can not race with truncation
- *	in this routine.  hugetlb_no_page() prevents page faults in the
- *	truncated range.  It checks i_size before allocation, and again after
- *	with the page table lock for the page held.  The same lock must be
- *	acquired to unmap a page.
+ *	maps and global counts.
  * hole punch is indicated if end is not LLONG_MAX
  *	In the hole punch case we scan the range and release found pages.
  *	Only when releasing a page is the associated region/reserv map
  *	deleted.  The region/reserv map for ranges without associated
- *	pages are not modified.  Page faults can race with hole punch.
- *	This is indicated if we find a mapped page.
+ *	pages are not modified.
+ *
+ * Callers of this routine must hold the i_mmap_rwsem in write mode to prevent
+ * races with page faults.
+ *
  * Note: If the passed end of range value is beyond the end of file, but
  * not LLONG_MAX this routine still performs a hole punch operation.
  */
@@ -423,32 +422,14 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
-			u32 hash;
 
 			index = page->index;
-			hash = hugetlb_fault_mutex_hash(h, current->mm,
-							&pseudo_vma,
-							mapping, index, 0);
-			mutex_lock(&hugetlb_fault_mutex_table[hash]);
-
 			/*
-			 * If page is mapped, it was faulted in after being
-			 * unmapped in caller.  Unmap (again) now after taking
-			 * the fault mutex.  The mutex will prevent faults
-			 * until we finish removing the page.
-			 *
-			 * This race can only happen in the hole punch case.
-			 * Getting here in a truncate operation is a bug.
+			 * A mapped page is impossible as callers should unmap
+			 * all references before calling.  And, i_mmap_rwsem
+			 * prevents the creation of additional mappings.
 			 */
-			if (unlikely(page_mapped(page))) {
-				BUG_ON(truncate_op);
-
-				i_mmap_lock_write(mapping);
-				hugetlb_vmdelete_list(&mapping->i_mmap,
-					index * pages_per_huge_page(h),
-					(index + 1) * pages_per_huge_page(h));
-				i_mmap_unlock_write(mapping);
-			}
+			VM_BUG_ON(page_mapped(page));
 
 			lock_page(page);
 			/*
@@ -470,7 +451,6 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			}
 
 			unlock_page(page);
-			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
 		huge_pagevec_release(&pvec);
 		cond_resched();
@@ -482,9 +462,20 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
+	struct address_space *mapping = inode->i_mapping;
 	struct resv_map *resv_map;
 
+	/*
+	 * The vfs layer guarantees that there are no other users of this
+	 * inode.  Therefore, it would be safe to call remove_inode_hugepages
+	 * without holding i_mmap_rwsem.  We acquire and hold here to be
+	 * consistent with other callers.  Since there will be no contention
+	 * on the semaphore, overhead is negligible.
+	 */
+	i_mmap_lock_write(mapping);
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
+	i_mmap_unlock_write(mapping);
+
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */
 	if (resv_map)
@@ -505,8 +496,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	i_mmap_lock_write(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
 		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
-	i_mmap_unlock_write(mapping);
 	remove_inode_hugepages(inode, offset, LLONG_MAX);
+	i_mmap_unlock_write(mapping);
 	return 0;
 }
 
@@ -540,8 +531,8 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 			hugetlb_vmdelete_list(&mapping->i_mmap,
 						hole_start >> PAGE_SHIFT,
 						hole_end  >> PAGE_SHIFT);
-		i_mmap_unlock_write(mapping);
 		remove_inode_hugepages(inode, hole_start, hole_end);
+		i_mmap_unlock_write(mapping);
 		inode_unlock(inode);
 	}
 
@@ -624,7 +615,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
index 2a3162030167..cfd9790b01e3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3757,16 +3757,16 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	/*
-	 * Use page lock to guard against racing truncation
-	 * before we get page_table_lock.
+	 * We can not race with truncation due to holding i_mmap_rwsem.
+	 * Check once here for faults beyond end of file.
 	 */
+	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	if (idx >= size)
+		goto out;
+
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
-		size = i_size_read(mapping->host) >> huge_page_shift(h);
-		if (idx >= size)
-			goto out;
-
 		/*
 		 * Check for page in userfault range
 		 */
@@ -3856,9 +3856,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	ptl = huge_pte_lock(h, mm, ptep);
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
-	if (idx >= size)
-		goto backout;
 
 	ret = 0;
 	if (!huge_pte_none(huge_ptep_get(ptep)))
@@ -3961,8 +3958,10 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/*
 	 * Acquire i_mmap_rwsem before calling huge_pte_alloc and hold
-	 * until finished with ptep.  This prevents huge_pmd_unshare from
-	 * being called elsewhere and making the ptep no longer valid.
+	 * until finished with ptep.  This serves two purposes:
+	 * 1) It prevents huge_pmd_unshare from being called elsewhere
+	 *    and making the ptep no longer valid.
+	 * 2) It synchronizes us with file truncation.
 	 *
 	 * ptep could have already be assigned via huge_pte_offset.  That
 	 * is OK, as huge_pte_alloc will return the same value unless
-- 
2.17.2
