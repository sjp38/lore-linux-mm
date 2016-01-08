Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 56026828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 19:02:40 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wp13so231881830obc.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 16:02:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k5si9211171obh.95.2016.01.08.16.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 16:02:39 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V2] mm/hugetlbfs Fix bugs in hugetlb_vmtruncate_list
Date: Fri,  8 Jan 2016 15:55:11 -0800
Message-Id: <1452297311-13189-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

Hillf Danton noticed bugs in the hugetlb_vmtruncate_list routine.
The argument end is of type pgoff_t.  It was being converted to a
vaddr offset and passed to unmap_hugepage_range.  However, end
was also being used as an argument to the vma_interval_tree_foreach
controlling loop.  In addition, the conversion of end to vaddr offset
was incorrect.

hugetlb_vmtruncate_list is called as part of a file truncate or fallocate
hole punch operation.

When truncating a hugetlbfs file, this bug could prevent some pages from
being unmapped.  This is possible if there are multiple vmas mapping the
file, and there is a sufficiently sized hole between the mappings.  The
size of the hole between two vmas (A,B) must be such that the starting
virtual address of B is greater than (ending virtual address of A <<
PAGE_SHIFT).  In this case, the pages in B would not be unmapped.  If
pages are not properly unmapped during truncate, the following BUG is hit.
--- kernel BUG at fs/hugetlbfs/inode.c:428!

In the fallocate hole punch case, this bug could prevent pages from being
unmapped as in the truncate case.  However, for hole punch the result is
that unmapped pages will not be removed during the operation.  For hole
punch, it is also possible that more pages than desired will be unmapped.
This unnecessary unmapping will cause page faults to reestablish the mappings
on subsequent page access.

V2:
  Corrected the calculation of v_end
  Added description of user-visible effects

Fixes: 1bfad99ab (" hugetlbfs: hugetlb_vmtruncate_list() needs to take a range")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 0444760..84fa4d4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -463,6 +463,7 @@ hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
 	 */
 	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
 		unsigned long v_offset;
+		unsigned long v_end;
 
 		/*
 		 * Can the expression below overflow on 32-bit arches?
@@ -475,15 +476,17 @@ hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
 		else
 			v_offset = 0;
 
-		if (end) {
-			end = ((end - start) << PAGE_SHIFT) +
-			       vma->vm_start + v_offset;
-			if (end > vma->vm_end)
-				end = vma->vm_end;
-		} else
-			end = vma->vm_end;
+		if (!end)
+			v_end = vma->vm_end;
+		else {
+			v_end = ((end - vma->vm_pgoff) << PAGE_SHIFT)
+							+ vma->vm_start;
+			if (v_end > vma->vm_end)
+				v_end = vma->vm_end;
+		}
 
-		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
+		unmap_hugepage_range(vma, vma->vm_start + v_offset, v_end,
+									NULL);
 	}
 }
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
