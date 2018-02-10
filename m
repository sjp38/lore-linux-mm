Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 749C36B027E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 19:38:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a2so4867189pgn.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 16:38:29 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o190si535621pga.553.2018.02.09.16.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 16:38:28 -0800 (PST)
Subject: [PATCH v2 1/2] mm,
 hugetlbfs: introduce ->pagesize() to vm_operations_struct
From: Dave Jiang <dave.jiang@intel.com>
Date: Fri, 09 Feb 2018 17:38:27 -0700
Message-ID: <151822310695.52376.2707461327280470402.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <151822289999.52376.4998780583577188804.stgit@djiang5-desk3.ch.intel.com>
References: <151822289999.52376.4998780583577188804.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, dan.j.williams@intel.com

From: Dan Williams <dan.j.williams@intel.com>

When device-dax is operating in huge-page mode we want it to behave like
hugetlbfs and report the MMU page mapping size that is being enforced by
the vma. Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce
->split() to vm_operations_struct" it would be messy to teach
vma_mmu_pagesize() about device-dax page mapping sizes in the same
(hstate) way that hugetlbfs communicates this attribute.  Instead, these
patches introduce a new ->pagesize() vm operation.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Reported-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 arch/powerpc/mm/hugetlbpage.c |    5 +----
 include/linux/mm.h            |    1 +
 mm/hugetlb.c                  |   23 ++++++++++++-----------
 3 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a9b9083c5e49..c6a2e577e842 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -568,10 +568,7 @@ unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
 	if (!radix_enabled())
 		return 1UL << mmu_psize_to_shift(psize);
 #endif
-	if (!is_vm_hugetlb_page(vma))
-		return PAGE_SIZE;
-
-	return huge_page_size(hstate_vma(vma));
+	return vma_kernel_pagesize(vma);
 }
 
 static inline bool is_power_of_4(unsigned long x)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..37b9aef91ec7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -383,6 +383,7 @@ struct vm_operations_struct {
 	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
+	unsigned long (*pagesize)(struct vm_area_struct * area);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9a334f5fb730..8fa069b5cb4d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -637,14 +637,9 @@ EXPORT_SYMBOL_GPL(linear_hugepage_index);
  */
 unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 {
-	struct hstate *hstate;
-
-	if (!is_vm_hugetlb_page(vma))
-		return PAGE_SIZE;
-
-	hstate = hstate_vma(vma);
-
-	return 1UL << huge_page_shift(hstate);
+	if (vma->vm_ops && vma->vm_ops->pagesize)
+		return vma->vm_ops->pagesize(vma);
+	return PAGE_SIZE;
 }
 EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 
@@ -654,12 +649,10 @@ EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
  * architectures where it differs, an architecture-specific version of this
  * function is required.
  */
-#ifndef vma_mmu_pagesize
-unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
+__weak unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
 {
 	return vma_kernel_pagesize(vma);
 }
-#endif
 
 /*
  * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
@@ -3132,6 +3125,13 @@ static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
 	return 0;
 }
 
+static unsigned long hugetlb_vm_op_pagesize(struct vm_area_struct *vma)
+{
+	struct hstate *hstate = hstate_vma(vma);
+
+	return 1UL << huge_page_shift(hstate);
+}
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
@@ -3149,6 +3149,7 @@ const struct vm_operations_struct hugetlb_vm_ops = {
 	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
 	.split = hugetlb_vm_op_split,
+	.pagesize = hugetlb_vm_op_pagesize,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
