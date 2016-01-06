Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id CD8E1828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 17:44:24 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id l9so274847056oia.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 14:44:24 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xu2si32761671oec.67.2016.01.06.14.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 14:44:24 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole punch
Date: Wed,  6 Jan 2016 14:37:04 -0800
Message-Id: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Page faults can race with fallocate hole punch.  If a page fault happens
between the unmap and remove operations, the page is not removed and
remains within the hole.  This is not the desired behavior.  The race
is difficult to detect in user level code as even in the non-race
case, a page within the hole could be faulted back in before fallocate
returns.  If userfaultfd is expanded to support hugetlbfs in the future,
this race will be easier to observe.

If this race is detected and a page is mapped, the remove operation
(remove_inode_hugepages) will unmap the page before removing.  The unmap
within remove_inode_hugepages occurs with the hugetlb_fault_mutex held
so that no other faults will be processed until the page is removed.

The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
remove_inode_hugepages to satisfy the new reference.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 139 +++++++++++++++++++++++++++------------------------
 1 file changed, 73 insertions(+), 66 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 0444760..0871d70 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -324,11 +324,46 @@ static void remove_huge_page(struct page *page)
 	delete_from_page_cache(page);
 }
 
+static inline void
+hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
+{
+	struct vm_area_struct *vma;
+
+	/*
+	 * end == 0 indicates that the entire range after
+	 * start should be unmapped.
+	 */
+	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
+		unsigned long v_offset;
+
+		/*
+		 * Can the expression below overflow on 32-bit arches?
+		 * No, because the interval tree returns us only those vmas
+		 * which overlap the truncated area starting at pgoff,
+		 * and no vma on a 32-bit arch can span beyond the 4GB.
+		 */
+		if (vma->vm_pgoff < start)
+			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
+		else
+			v_offset = 0;
+
+		if (end) {
+			end = ((end - start) << PAGE_SHIFT) +
+			       vma->vm_start + v_offset;
+			if (end > vma->vm_end)
+				end = vma->vm_end;
+		} else
+			end = vma->vm_end;
+
+		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
+	}
+}
+
 
 /*
  * remove_inode_hugepages handles two distinct cases: truncation and hole
  * punch.  There are subtle differences in operation for each case.
-
+ *
  * truncation is indicated by end of range being LLONG_MAX
  *	In this case, we first scan the range and release found pages.
  *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
@@ -379,6 +414,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
+			bool rsv_on_error;
 			u32 hash;
 
 			/*
@@ -395,37 +431,43 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 							mapping, next, 0);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
-			lock_page(page);
-			if (likely(!page_mapped(page))) {
-				bool rsv_on_error = !PagePrivate(page);
-				/*
-				 * We must free the huge page and remove
-				 * from page cache (remove_huge_page) BEFORE
-				 * removing the region/reserve map
-				 * (hugetlb_unreserve_pages).  In rare out
-				 * of memory conditions, removal of the
-				 * region/reserve map could fail.  Before
-				 * free'ing the page, note PagePrivate which
-				 * is used in case of error.
-				 */
-				remove_huge_page(page);
-				freed++;
-				if (!truncate_op) {
-					if (unlikely(hugetlb_unreserve_pages(
-							inode, next,
-							next + 1, 1)))
-						hugetlb_fix_reserve_counts(
-							inode, rsv_on_error);
-				}
-			} else {
-				/*
-				 * If page is mapped, it was faulted in after
-				 * being unmapped.  It indicates a race between
-				 * hole punch and page fault.  Do nothing in
-				 * this case.  Getting here in a truncate
-				 * operation is a bug.
-				 */
+			/*
+			 * If page is mapped, it was faulted in after being
+			 * unmapped in caller.  Unmap (again) now after taking
+			 * the fault mutex.  The mutex will prevent faults
+			 * until we finish removing the page.
+			 *
+			 * This race can only happen in the hole punch case.
+			 * Getting here in a truncate operation is a bug.
+			 */
+			if (unlikely(page_mapped(page))) {
 				BUG_ON(truncate_op);
+
+				i_mmap_lock_write(mapping);
+				hugetlb_vmdelete_list(&mapping->i_mmap,
+					next * pages_per_huge_page(h),
+					(next + 1) * pages_per_huge_page(h));
+				i_mmap_unlock_write(mapping);
+			}
+
+			lock_page(page);
+			/*
+			 * We must free the huge page and remove from page
+			 * cache (remove_huge_page) BEFORE removing the
+			 * region/reserve map (hugetlb_unreserve_pages).  In
+			 * rare out of memory conditions, removal of the
+			 * region/reserve map could fail.  Before free'ing
+			 * the page, note PagePrivate which is used in case
+			 * of error.
+			 */
+			rsv_on_error = !PagePrivate(page);
+			remove_huge_page(page);
+			freed++;
+			if (!truncate_op) {
+				if (unlikely(hugetlb_unreserve_pages(inode,
+							next, next + 1, 1)))
+					hugetlb_fix_reserve_counts(inode,
+								rsv_on_error);
 			}
 
 			unlock_page(page);
@@ -452,41 +494,6 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
-static inline void
-hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
-{
-	struct vm_area_struct *vma;
-
-	/*
-	 * end == 0 indicates that the entire range after
-	 * start should be unmapped.
-	 */
-	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
-		unsigned long v_offset;
-
-		/*
-		 * Can the expression below overflow on 32-bit arches?
-		 * No, because the interval tree returns us only those vmas
-		 * which overlap the truncated area starting at pgoff,
-		 * and no vma on a 32-bit arch can span beyond the 4GB.
-		 */
-		if (vma->vm_pgoff < start)
-			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
-		else
-			v_offset = 0;
-
-		if (end) {
-			end = ((end - start) << PAGE_SHIFT) +
-			       vma->vm_start + v_offset;
-			if (end > vma->vm_end)
-				end = vma->vm_end;
-		} else
-			end = vma->vm_end;
-
-		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
-	}
-}
-
 static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 {
 	pgoff_t pgoff;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
