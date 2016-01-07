Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6679C828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 17:44:25 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id wp13so204443563obc.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:44:25 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t2si1575439obd.39.2016.01.07.14.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 14:44:24 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlbfs Fix bugs in hugetlb_vmtruncate_list
Date: Thu,  7 Jan 2016 14:35:37 -0800
Message-Id: <1452206137-12441-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org, "[4.3]"@kvack.org

Hillf Danton noticed bugs in the hugetlb_vmtruncate_list routine.
The argument end is of type pgoff_t.  It was being converted to a
vaddr offset and passed to unmap_hugepage_range.  However, end
was also being used as an argument to the vma_interval_tree_foreach
controlling loop.  In addition, the conversion of end to vaddr offset
was incorrect.

Fixes: 1bfad99ab (" hugetlbfs: hugetlb_vmtruncate_list() needs to take a range")
Cc: stable@vger.kernel.org [4.3]
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 0444760..89abdc9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -461,8 +461,12 @@ hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
 	 * end == 0 indicates that the entire range after
 	 * start should be unmapped.
 	 */
-	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
+	if (!end)
+		end = ULONG_MAX;
+
+	vma_interval_tree_foreach(vma, root, start, end) {
 		unsigned long v_offset;
+		unsigned long v_end;
 
 		/*
 		 * Can the expression below overflow on 32-bit arches?
@@ -475,15 +479,12 @@ hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
 		else
 			v_offset = 0;
 
-		if (end) {
-			end = ((end - start) << PAGE_SHIFT) +
-			       vma->vm_start + v_offset;
-			if (end > vma->vm_end)
-				end = vma->vm_end;
-		} else
-			end = vma->vm_end;
+		v_end = (end - vma->vm_pgoff) << PAGE_SHIFT;
+		if (v_end > vma->vm_end)
+			v_end = vma->vm_end;
 
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
