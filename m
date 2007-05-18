Message-Id: <200705180737.l4I7b7MM010762@shell0.pdx.osdl.net>
Subject: [patch 4/8] "Convert" hugetlbfs to use vm_ops->fault()
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:08 -0700
Sender: owner-linux-mm@kvack.org
From: Adam Litke <agl@us.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, agl@us.ibm.com, bill.irwin@oracle.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

I discovered that 2.6.21-rc5-mm1 was oopsing my box when running the
libhugetlbfs test suite.  The trouble led me once again to shm stacked
files ;-) The stacked mmap function is labeling the lack of a ->fault()
vm_op a BUG() which is probably a good idea.  It isn't really a problem for
hugetlbfs though, since our faults are handled by an explicit hook in
__handle_mm_fault().  Rather than removing the BUG(), just convert the
hugetlbfs ->nopage() placeholder to a ->fault() one which helps us get one
step closer to removing the nopage vm_op anyway.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nick Piggin <nickpiggin@yahoo.com.au>
Acked-by: Bill Irwin <bill.irwin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/hugetlb.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff -puN mm/hugetlb.c~convert-hugetlbfs-to-use-vm_ops-fault mm/hugetlb.c
--- a/mm/hugetlb.c~convert-hugetlbfs-to-use-vm_ops-fault
+++ a/mm/hugetlb.c
@@ -287,20 +287,19 @@ unsigned long hugetlb_total_pages(void)
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
