Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DFGkEZ028553
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:16:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFGjrF244982
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFGji6029764
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:45 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/5] [hugetlb] Account for hugepages as locked_vm
Date: Fri, 13 Jul 2007 08:16:43 -0700
Message-Id: <20070713151642.17750.89814.stgit@kernel>
In-Reply-To: <20070713151621.17750.58171.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hugepages allocated for a process are pinned and may not be reclaimed. This
patch accounts for hugepages under locked_vm.

TODO:
	Explore replacing this patch with a hugetlb pool high watermark
instead.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 61a52b0..d1ca501 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -402,6 +402,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			continue;
 
 		page = pte_page(pte);
+		mm->locked_vm -= BASE_PAGES_PER_HPAGE;
 		if (pte_dirty(pte))
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
@@ -535,6 +536,14 @@ retry:
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
 
+	/*
+ 	 * Account for huge pages as locked. Note that lock limits are not
+ 	 * enforced here because it is not expected that limits are enforced
+ 	 * at fault time. It also would not be right to enforce the limits
+ 	 * at mmap() time because the pages are not pinned at that point
+ 	 */
+	mm->locked_vm += BASE_PAGES_PER_HPAGE;
+
 	if (write_access && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
