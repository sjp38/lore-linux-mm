Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2SKPGwN031833
	for <linux-mm@kvack.org>; Wed, 28 Mar 2007 16:25:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2SKREJu037652
	for <linux-mm@kvack.org>; Wed, 28 Mar 2007 14:27:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2SKRE5a025912
	for <linux-mm@kvack.org>; Wed, 28 Mar 2007 14:27:14 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] "Convert" hugetlbfs to use vm_ops->fault()
Date: Wed, 28 Mar 2007 13:27:13 -0700
Message-Id: <20070328202713.4864.71864.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew, I discovered that 2.6.21-rc5-mm1 was oopsing my box when running
the libhugetlbfs test suite.  The trouble led me once again to shm stacked
files ;-)  The stacked mmap function is labeling the lack of a ->fault()
vm_op a BUG() which is probably a good idea.  It isn't really a problem for
hugetlbfs though, since our faults are handled by an explicit hook in
__handle_mm_fault().  Rather than removing the BUG(), just convert the
hugetlbfs ->nopage() placeholder to a ->fault() one which helps us get one
step closer to removing the nopage vm_op anyway.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a07ffd4..89acb00 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -291,20 +291,19 @@ unsigned long hugetlb_total_pages(void)
 }
 
 /*
- * We cannot handle pagefaults against hugetlb pages at all.  They cause
- * handle_mm_fault() to try to instantiate regular-sized pages in the
- * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
- * this far.
+ * Hugetlb faults are serviced in __handle_mm_fault by explicitly calling
+ * hugetlb_fault.  Therefore the vm_ops->fault() op for hugetlb pages
+ * should never be called.
  */
-static struct page *hugetlb_nopage(struct vm_area_struct *vma,
-				unsigned long address, int *unused)
+static struct page *hugetlb_vm_op_fault(struct vm_area_struct *vma,
+					struct fault_data *fdata)
 {
 	BUG();
 	return NULL;
 }
 
 struct vm_operations_struct hugetlb_vm_ops = {
-	.nopage = hugetlb_nopage,
+	.fault = hugetlb_vm_op_fault,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
