From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] huge page MAP_NORESERVE review cleanups
References: <exportbomb.1212166524@pinky>
Date: Fri, 30 May 2008 17:58:39 +0100
Message-Id: <1212166719.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Use the new encapsulated huge page offset helper.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1dce03a..901e580 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -733,8 +733,7 @@ static int vma_needs_reservation(struct vm_area_struct *vma, unsigned long addr)
 	struct inode *inode = mapping->host;
 
 	if (vma->vm_flags & VM_SHARED) {
-		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
-				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		pgoff_t idx = vma_pagecache_offset(vma, addr);
 		return region_chg(&inode->i_mapping->private_list,
 							idx, idx + 1);
 
@@ -752,8 +751,7 @@ static void vma_commit_reservation(struct vm_area_struct *vma,
 	struct inode *inode = mapping->host;
 
 	if (vma->vm_flags & VM_SHARED) {
-		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
-				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		pgoff_t idx = vma_pagecache_offset(vma, addr);
 		region_add(&inode->i_mapping->private_list, idx, idx + 1);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
