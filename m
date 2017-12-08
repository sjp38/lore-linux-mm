Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC5996B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 22:39:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so7537407pfh.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 19:39:11 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r82si5266114pfi.277.2017.12.07.19.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 19:39:10 -0800 (PST)
Subject: [PATCH 1/2] mm,
 hugetlbfs: introduce ->pagesize() to vm_operations_struct
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 07 Dec 2017 19:30:55 -0800
Message-ID: <151270385525.21215.16828596212056611775.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

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
---
 arch/powerpc/mm/hugetlbpage.c |    5 +----
 include/linux/hugetlb.h       |   30 ++++++++++++++++++++++++------
 include/linux/mm.h            |    1 +
 mm/hugetlb.c                  |   38 ++++++++------------------------------
 4 files changed, 34 insertions(+), 40 deletions(-)

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
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 82a25880714a..716ccf14ff7b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -254,6 +254,30 @@ enum {
 	HUGETLB_ANONHUGE_INODE  = 2,
 };
 
+/*
+ * Return the size of the pages allocated when backing a VMA. In the majority
+ * cases this will be same size as used by the page table entries.
+ */
+static inline unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
+{
+	if (vma->vm_ops && vma->vm_ops->pagesize)
+		return vma->vm_ops->pagesize(vma);
+	return PAGE_SIZE;
+}
+
+/*
+ * Return the page size being used by the MMU to back a VMA. In the majority
+ * of cases, the page size used by the kernel matches the MMU size. On
+ * architectures where it differs, an architecture-specific version of this
+ * function is required.
+ */
+#ifndef vma_mmu_pagesize
+static inline unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
+{
+	return vma_kernel_pagesize(vma);
+}
+#endif
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_sb_info {
 	long	max_inodes;   /* inodes allowed */
@@ -395,10 +419,6 @@ static inline unsigned long huge_page_size(struct hstate *h)
 	return (unsigned long)PAGE_SIZE << h->order;
 }
 
-extern unsigned long vma_kernel_pagesize(struct vm_area_struct *vma);
-
-extern unsigned long vma_mmu_pagesize(struct vm_area_struct *vma);
-
 static inline unsigned long huge_page_mask(struct hstate *h)
 {
 	return h->mask;
@@ -533,8 +553,6 @@ struct hstate {};
 #define page_hstate(page) NULL
 #define huge_page_size(h) PAGE_SIZE
 #define huge_page_mask(h) PAGE_MASK
-#define vma_kernel_pagesize(v) PAGE_SIZE
-#define vma_mmu_pagesize(v) PAGE_SIZE
 #define huge_page_order(h) 0
 #define huge_page_shift(h) PAGE_SHIFT
 static inline bool hstate_is_gigantic(struct hstate *h)
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
index 9a334f5fb730..f45ded1f978a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -632,36 +632,6 @@ pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 EXPORT_SYMBOL_GPL(linear_hugepage_index);
 
 /*
- * Return the size of the pages allocated when backing a VMA. In the majority
- * cases this will be same size as used by the page table entries.
- */
-unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
-{
-	struct hstate *hstate;
-
-	if (!is_vm_hugetlb_page(vma))
-		return PAGE_SIZE;
-
-	hstate = hstate_vma(vma);
-
-	return 1UL << huge_page_shift(hstate);
-}
-EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
-
-/*
- * Return the page size being used by the MMU to back a VMA. In the majority
- * of cases, the page size used by the kernel matches the MMU size. On
- * architectures where it differs, an architecture-specific version of this
- * function is required.
- */
-#ifndef vma_mmu_pagesize
-unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
-{
-	return vma_kernel_pagesize(vma);
-}
-#endif
-
-/*
  * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
  * bits of the reservation map pointer, which are always clear due to
  * alignment.
@@ -3132,6 +3102,13 @@ static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
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
@@ -3149,6 +3126,7 @@ const struct vm_operations_struct hugetlb_vm_ops = {
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
