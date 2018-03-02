Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55C9D6B0007
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 22:58:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 73so3748304pfz.22
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 19:58:09 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a2si3401776pgd.452.2018.03.01.19.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 19:58:08 -0800 (PST)
Subject: [PATCH v3 1/3] mm,
 powerpc: use vma_kernel_pagesize() in vma_mmu_pagesize()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:49:01 -0800
Message-ID: <151996254179.27922.2213728278535578744.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

The current powerpc definition of vma_mmu_pagesize() open codes looking
up the page size via hstate. It is identical to the generic
vma_kernel_pagesize() implementation.

Now, vma_kernel_pagesize() is growing support for determining the
page size of Device-DAX vmas in addition to the existing Hugetlbfs page
size determination.

Ideally, if the powerpc vma_mmu_pagesize() used vma_kernel_pagesize() it
would automatically benefit from any new vma-type support that is added
to vma_kernel_pagesize(). However, the powerpc vma_mmu_pagesize() is
prevented from calling vma_kernel_pagesize() due to a circular header
dependency that requires vma_mmu_pagesize() to be defined before
including <linux/hugetlb.h>.

Break this circular dependency by defining the default
vma_mmu_pagesize() as a __weak symbol to be overridden by the powerpc
version.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/include/asm/hugetlb.h |    6 ------
 arch/powerpc/mm/hugetlbpage.c      |    5 +----
 mm/hugetlb.c                       |    8 +++-----
 3 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 1a4847f67ea8..6f6751d3eba9 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -118,12 +118,6 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long ceiling);
 
 /*
- * The version of vma_mmu_pagesize() in arch/powerpc/mm/hugetlbpage.c needs
- * to override the version in mm/hugetlb.c
- */
-#define vma_mmu_pagesize vma_mmu_pagesize
-
-/*
  * If the arch doesn't supply something else, assume that hugepage
  * size aligned regions are ok without further preparation.
  */
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 876da2bc1796..3a08d211d2ee 100644
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
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c204e3d132b..f9c4ea42b04a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -650,15 +650,13 @@ EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 /*
  * Return the page size being used by the MMU to back a VMA. In the majority
  * of cases, the page size used by the kernel matches the MMU size. On
- * architectures where it differs, an architecture-specific version of this
- * function is required.
+ * architectures where it differs, an architecture-specific 'strong'
+ * version of this symbol is required.
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
