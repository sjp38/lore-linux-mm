From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/1] allocate structures for reservation tracking in hugetlbfs outside of spinlocks v2
Date: Mon, 11 Aug 2008 18:58:20 +0100
Message-Id: <1218477500-11772-1-git-send-email-apw@shadowen.org>
In-Reply-To: <20080807143824.8e0803da.akpm@linux-foundation.org>
References: <20080807143824.8e0803da.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

[Andrew this should replace the previous version which did not check
the returns from the region prepare for errors.  This has been tested by
us and Gerald and it looks good.

Bah, while reviewing the locking based on your previous email I spotted
that we need to check the return from the vma_needs_reservation call for
allocation errors.  Here is an updated patch to correct this.  This passes
testing here.]

In the normal case, hugetlbfs reserves hugepages at map time so that the
pages exist for future faults.  A struct file_region is used to track
when reservations have been consumed and where.  These file_regions
are allocated as necessary with kmalloc() which can sleep with the
mm->page_table_lock held.  This is wrong and triggers may-sleep warning
when PREEMPT is enabled.

Updates to the underlying file_region are done in two phases.  The first
phase prepares the region for the change, allocating any necessary memory,
without actually making the change.  The second phase actually commits
the change.  This patch makes use of this by checking the reservations
before the page_table_lock is taken; triggering any necessary allocations.
This may then be safely repeated within the locks without any allocations
being required.

Credit to Mel Gorman for diagnosing this failure and initial versions of
the patch.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/hugetlb.c |   55 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 28a2980..393ea8b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1937,6 +1937,18 @@ retry:
 			lock_page(page);
 	}
 
+	/*
+	 * If we are going to COW a private mapping later, we examine the
+	 * pending reservations for this page now. This will ensure that
+	 * any allocations necessary to record that reservation occur outside
+	 * the spinlock.
+	 */
+	if (write_access && !(vma->vm_flags & VM_SHARED))
+		if (vma_needs_reservation(h, vma, address) < 0) {
+			ret = VM_FAULT_OOM;
+			goto backout_unlocked;
+		}
+
 	spin_lock(&mm->page_table_lock);
 	size = i_size_read(mapping->host) >> huge_page_shift(h);
 	if (idx >= size)
@@ -1962,6 +1974,7 @@ out:
 
 backout:
 	spin_unlock(&mm->page_table_lock);
+backout_unlocked:
 	unlock_page(page);
 	put_page(page);
 	goto out;
@@ -1973,6 +1986,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t *ptep;
 	pte_t entry;
 	int ret;
+	struct page *pagecache_page = NULL;
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
 
@@ -1989,25 +2003,44 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
 		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
-		mutex_unlock(&hugetlb_instantiation_mutex);
-		return ret;
+		goto out_unlock;
 	}
 
 	ret = 0;
 
+	/*
+	 * If we are going to COW the mapping later, we examine the pending
+	 * reservations for this page now. This will ensure that any
+	 * allocations necessary to record that reservation occur outside the
+	 * spinlock. For private mappings, we also lookup the pagecache
+	 * page now as it is used to determine if a reservation has been
+	 * consumed.
+	 */
+	if (write_access && !pte_write(entry)) {
+		if (vma_needs_reservation(h, vma, address) < 0) {
+			ret = VM_FAULT_OOM;
+			goto out_unlock;
+		}
+
+		if (!(vma->vm_flags & VM_SHARED))
+			pagecache_page = hugetlbfs_pagecache_page(h,
+								vma, address);
+	}
+
 	spin_lock(&mm->page_table_lock);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (likely(pte_same(entry, huge_ptep_get(ptep))))
-		if (write_access && !pte_write(entry)) {
-			struct page *page;
-			page = hugetlbfs_pagecache_page(h, vma, address);
-			ret = hugetlb_cow(mm, vma, address, ptep, entry, page);
-			if (page) {
-				unlock_page(page);
-				put_page(page);
-			}
-		}
+		if (write_access && !pte_write(entry))
+			ret = hugetlb_cow(mm, vma, address, ptep, entry,
+							pagecache_page);
 	spin_unlock(&mm->page_table_lock);
+
+	if (pagecache_page) {
+		unlock_page(pagecache_page);
+		put_page(pagecache_page);
+	}
+
+out_unlock:
 	mutex_unlock(&hugetlb_instantiation_mutex);
 
 	return ret;
-- 
1.6.0.rc1.258.g80295

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
