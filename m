Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA6Lwwr3028609
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 14:58:58 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA6LxT5O075824
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 14:59:29 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA6LxTgH024890
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 14:59:29 -0700
Subject: hugetlb: Make unmap_ref_private multi-size-aware
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Thu, 06 Nov 2008 15:59:19 -0600
Message-Id: <1226008759.9727.102.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Jon Tollefson <kniht@linux.vnet.ibm.com>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Oops.  Part of the hugetlb private reservation code was not fully converted to
use hstates.  When a huge page must be unmapped from VMAs due to a failed COW,
HPAGE_SIZE is used in the call to unmap_hugepage_range() regardless of the page
size being used.  This works if the VMA is using the default huge page size.
Otherwise we might unmap too much, too little, or trigger a BUG_ON.  Rare but
serious -- fix it.
    
Signed-off-by: Adam Litke <agl@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 421aee9..070150b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1751,6 +1751,7 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 				struct page *page, unsigned long address)
 {
+	struct hstate *h = hstate_vma(vma);
 	struct vm_area_struct *iter_vma;
 	struct address_space *mapping;
 	struct prio_tree_iter iter;
@@ -1760,7 +1761,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * vm_pgoff is in PAGE_SIZE units, hence the different calculation
 	 * from page cache lookup which is in HPAGE_SIZE units.
 	 */
-	address = address & huge_page_mask(hstate_vma(vma));
+	address = address & huge_page_mask(h);
 	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT)
 		+ (vma->vm_pgoff >> PAGE_SHIFT);
 	mapping = (struct address_space *)page_private(page);
@@ -1779,7 +1780,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if (!is_vma_resv_set(iter_vma, HPAGE_RESV_OWNER))
 			unmap_hugepage_range(iter_vma,
-				address, address + HPAGE_SIZE,
+				address, address + huge_page_size(h),
 				page);
 	}
 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
