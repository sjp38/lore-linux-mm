Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9F366B6ADA
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:09:12 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so4734921edb.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:09:12 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e10-v6si3138979eji.18.2018.12.03.12.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 12:09:11 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] hugetlbfs: remove unnecessary code after i_mmap_rwsem synchronization
Date: Mon,  3 Dec 2018 12:08:50 -0800
Message-Id: <20181203200850.6460-4-mike.kravetz@oracle.com>
In-Reply-To: <20181203200850.6460-1-mike.kravetz@oracle.com>
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

After expanding i_mmap_rwsem use for better shared pmd and page fault/
truncation synchronization, remove code that is no longer necessary.

Cc: <stable@vger.kernel.org>
Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 46 +++++++++++++++-----------------------------
 mm/hugetlb.c         | 21 ++++++++++----------
 2 files changed, 25 insertions(+), 42 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 3244147fc42b..a9c00c6ef80d 100644
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
@@ -624,7 +604,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
index 362601b69c56..89e1a253a40b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3760,16 +3760,16 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
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
@@ -3859,9 +3859,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	ptl = huge_pte_lock(h, mm, ptep);
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
-	if (idx >= size)
-		goto backout;
 
 	ret = 0;
 	if (!huge_pte_none(huge_ptep_get(ptep)))
@@ -3964,8 +3961,10 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
