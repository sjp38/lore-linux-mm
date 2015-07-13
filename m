Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 57B036B0255
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 00:21:55 -0400 (EDT)
Received: by padck2 with SMTP id ck2so35589715pad.0
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 21:21:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h4si26277246pdi.136.2015.07.12.21.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jul 2015 21:21:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 04/10] hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete
Date: Sun, 12 Jul 2015 21:21:02 -0700
Message-Id: <1436761268-6397-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
References: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

fallocate hole punch will want to unmap a specific range of pages.
Modify the existing hugetlb_vmtruncate_list() routine to take a
start/end range.  If end is 0, this indicates all pages after start
should be unmapped.  This is the same as the existing truncate
functionality.  Modify existing callers to add 0 as end of range.

Since the routine will be used in hole punch as well as truncate
operations, it is more appropriately renamed to hugetlb_vmdelete_list().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 0cf74df..ed40f56 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -349,11 +349,15 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 }
 
 static inline void
-hugetlb_vmtruncate_list(struct rb_root *root, pgoff_t pgoff)
+hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
 {
 	struct vm_area_struct *vma;
 
-	vma_interval_tree_foreach(vma, root, pgoff, ULONG_MAX) {
+	/*
+	 * end == 0 indicates that the entire range after
+	 * start should be unmapped.
+	 */
+	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
 		unsigned long v_offset;
 
 		/*
@@ -362,13 +366,20 @@ hugetlb_vmtruncate_list(struct rb_root *root, pgoff_t pgoff)
 		 * which overlap the truncated area starting at pgoff,
 		 * and no vma on a 32-bit arch can span beyond the 4GB.
 		 */
-		if (vma->vm_pgoff < pgoff)
-			v_offset = (pgoff - vma->vm_pgoff) << PAGE_SHIFT;
+		if (vma->vm_pgoff < start)
+			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
 		else
 			v_offset = 0;
 
-		unmap_hugepage_range(vma, vma->vm_start + v_offset,
-				     vma->vm_end, NULL);
+		if (end) {
+			end = ((end - start) << PAGE_SHIFT) +
+			       vma->vm_start + v_offset;
+			if (end > vma->vm_end)
+				end = vma->vm_end;
+		} else
+			end = vma->vm_end;
+
+		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
 	}
 }
 
@@ -384,7 +395,7 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	i_size_write(inode, offset);
 	i_mmap_lock_write(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
-		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
+		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
 	i_mmap_unlock_write(mapping);
 	truncate_hugepages(inode, offset);
 	return 0;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
