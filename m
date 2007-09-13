Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DHx8Uw017487
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DHx8cp690962
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:08 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DHx7EN026478
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:08 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/5] hugetlb: Account for hugepages as locked_vm
Date: Thu, 13 Sep 2007 10:59:05 -0700
Message-Id: <20070913175905.27074.92434.stgit@kernel>
In-Reply-To: <20070913175855.27074.27030.stgit@kernel>
References: <20070913175855.27074.27030.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Hugepages allocated to a process are pinned into memory and are not
reclaimable.  Currently they do not contribute towards the process' locked
memory.  This patch includes those pages in the process' 'locked_vm' pages.

NOTE: The locked_vm counter is only updated at fault and unmap time.  Huge
pages are different from regular mlocked memory which is faulted in all at
once.  Therefore, it does not make sense to charge at mmap time for huge
page mappings.  This difference results in a deviation from normal mlock
accounting which cannot be trivially reconciled given the inherent
differences with huge pages.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index de4cf45..1dfeafa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -428,6 +428,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			continue;
 
 		page = pte_page(pte);
+		mm->locked_vm -= HPAGE_SIZE >> PAGE_SHIFT;
 		if (pte_dirty(pte))
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
@@ -561,6 +562,16 @@ retry:
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
 
+	/*
+ 	 * Account for huge pages as locked memory.
+ 	 * The locked limits are not enforced at mmap time because hugetlbfs
+ 	 * behaves differently than normal locked memory:  1) The pages are
+ 	 * not pinned immediately, and 2) The pages come from a pre-configured
+ 	 * pool of memory to which the administrator has separately arranged
+ 	 * access.
+ 	 */
+	mm->locked_vm += HPAGE_SIZE >> PAGE_SHIFT;
+
 	if (write_access && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
