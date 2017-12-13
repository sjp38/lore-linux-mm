Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 372376B025F
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 08:07:06 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x1so1079131plb.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:07:06 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id w15si1329892plp.561.2017.12.13.05.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Dec 2017 05:07:04 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm, hugetlbfs: introduce ->pagesize() to vm_operations_struct
In-Reply-To: <20171210113715.GE20234@dhcp22.suse.cz>
References: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com> <151270385525.21215.16828596212056611775.stgit@dwillia2-desk3.amr.corp.intel.com> <20171210113715.GE20234@dhcp22.suse.cz>
Date: Thu, 14 Dec 2017 00:07:01 +1100
Message-ID: <87o9n2aia2.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 07-12-17 19:30:55, Dan Williams wrote:
>> When device-dax is operating in huge-page mode we want it to behave like
>> hugetlbfs and report the MMU page mapping size that is being enforced by
>> the vma. Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce
>> ->split() to vm_operations_struct" it would be messy to teach
>> vma_mmu_pagesize() about device-dax page mapping sizes in the same
>> (hstate) way that hugetlbfs communicates this attribute.  Instead, these
>> patches introduce a new ->pagesize() vm operation.
>> 
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Reported-by: Jane Chu <jane.chu@oracle.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> My build battery choked on the following
> In file included from drivers/infiniband/core/umem_odp.c:41:0:
> ./include/linux/hugetlb.h: In function 'vma_kernel_pagesize':
> ./include/linux/hugetlb.h:262:32: error: dereferencing pointer to incomplete type
>   if (vma->vm_ops && vma->vm_ops->pagesize)
>                                 ^
> ./include/linux/hugetlb.h:263:21: error: dereferencing pointer to incomplete type
>    return vma->vm_ops->pagesize(vma);
>
> I thought that adding #include <linux/mm.h> into linux/hugetlb.h would
> be sufficient but then it failed for powerpc defconfig which overrides
> vma_kernel_pagesize
> In file included from ./include/linux/hugetlb.h:452:0,
>                  from arch/powerpc/mm/hugetlbpage.c:14:
> ./arch/powerpc/include/asm/hugetlb.h:131:26: error: redefinition of 'vma_mmu_pagesize'
>  #define vma_mmu_pagesize vma_mmu_pagesize
>                           ^
> arch/powerpc/mm/hugetlbpage.c:563:15: note: in expansion of macro 'vma_mmu_pagesize'
>  unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
>                ^
> In file included from arch/powerpc/mm/hugetlbpage.c:14:0:
> ./include/linux/hugetlb.h:275:29: note: previous definition of 'vma_mmu_pagesize' was here
>  static inline unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
>
> So it looks this needs something more laborous.

This builds for me.

cheers


diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 14c9d44f355b..3cc6ca1bdaf2 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -123,6 +123,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
  * to override the version in mm/hugetlb.c
  */
 #define vma_mmu_pagesize vma_mmu_pagesize
+unsigned long vma_mmu_pagesize(struct vm_area_struct *vma);
 
 /*
  * If the arch doesn't supply something else, assume that hugepage
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
index 6e3696c7b35a..fe7b74325856 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -394,10 +394,6 @@ static inline unsigned long huge_page_size(struct hstate *h)
 	return (unsigned long)PAGE_SIZE << h->order;
 }
 
-extern unsigned long vma_kernel_pagesize(struct vm_area_struct *vma);
-
-extern unsigned long vma_mmu_pagesize(struct vm_area_struct *vma);
-
 static inline unsigned long huge_page_mask(struct hstate *h)
 {
 	return h->mask;
@@ -430,6 +426,30 @@ static inline unsigned int blocks_per_huge_page(struct hstate *h)
 
 #include <asm/hugetlb.h>
 
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
 #ifndef arch_make_huge_pte
 static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 				       struct page *page, int writable)
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
index 7661156552d3..1933499f896d 100644
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
index 4137fb67cd79..7c1c45bb3d08 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -629,36 +629,6 @@ pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 }
 EXPORT_SYMBOL_GPL(linear_hugepage_index);
 
-/*
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
 /*
  * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
  * bits of the reservation map pointer, which are always clear due to
@@ -3142,6 +3112,13 @@ static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
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
@@ -3159,6 +3136,7 @@ const struct vm_operations_struct hugetlb_vm_ops = {
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
