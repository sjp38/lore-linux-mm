Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9F46082F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:23:51 -0400 (EDT)
Received: by iody8 with SMTP id y8so6590849iod.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:23:51 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id m13si20712716igt.101.2015.10.28.04.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 04:23:50 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 1/3] ARC: mm: preps ahead of HIGHMEM support
Date: Wed, 28 Oct 2015 16:53:11 +0530
Message-ID: <1446031393-2312-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
References: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Mel
 Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-snps-arc@lists.infraded.org, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Before we plug in highmem support, some of code needs to be ready for it
 - copy_user_highpage() needs to be using the kmap_atomic API
 - max_low_pfn can't be assumed to be same as max_pfn
 - mk_pte() can't assume page_address()
 - do_page_fault() can't assume VMALLOC_END is end of kernel vaddr space

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h |  9 +--------
 arch/arc/mm/cache.c            | 16 +++++++++++-----
 arch/arc/mm/fault.c            | 13 ++++++++++---
 arch/arc/mm/init.c             |  2 +-
 4 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index f7c7273cd537..bd771351a1d1 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -270,13 +270,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 		(unsigned long)(((pte_val(x) - CONFIG_LINUX_LINK_BASE) >> \
 				PAGE_SHIFT)))
 
-#define mk_pte(page, pgprot)						\
-({									\
-	pte_t pte;							\
-	pte_val(pte) = __pa(page_address(page)) + pgprot_val(pgprot);	\
-	pte;								\
-})
-
+#define mk_pte(page, prot)	pfn_pte(page_to_pfn(page), prot)
 #define pte_pfn(pte)		(pte_val(pte) >> PAGE_SHIFT)
 #define pfn_pte(pfn, prot)	(__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot)))
 #define __pte_index(addr)	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
@@ -360,7 +354,6 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 #define pgd_offset_fast(mm, addr)	pgd_offset(mm, addr)
 #endif
 
-extern void paging_init(void);
 extern pgd_t swapper_pg_dir[] __aligned(PAGE_SIZE);
 void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 		      pte_t *ptep);
diff --git a/arch/arc/mm/cache.c b/arch/arc/mm/cache.c
index 27d255d3dc5d..08a7cc0ac100 100644
--- a/arch/arc/mm/cache.c
+++ b/arch/arc/mm/cache.c
@@ -813,8 +813,8 @@ void flush_anon_page(struct vm_area_struct *vma, struct page *page,
 void copy_user_highpage(struct page *to, struct page *from,
 	unsigned long u_vaddr, struct vm_area_struct *vma)
 {
-	unsigned long kfrom = (unsigned long)page_address(from);
-	unsigned long kto = (unsigned long)page_address(to);
+	void *kfrom = kmap_atomic(from);
+	void *kto = kmap_atomic(to);
 	int clean_src_k_mappings = 0;
 
 	/*
@@ -824,13 +824,16 @@ void copy_user_highpage(struct page *to, struct page *from,
 	 *
 	 * Note that while @u_vaddr refers to DST page's userspace vaddr, it is
 	 * equally valid for SRC page as well
+	 *
+	 * For !VIPT cache, all of this gets compiled out as
+	 * addr_not_cache_congruent() is 0
 	 */
 	if (page_mapped(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
-		__flush_dcache_page(kfrom, u_vaddr);
+		__flush_dcache_page((unsigned long)kfrom, u_vaddr);
 		clean_src_k_mappings = 1;
 	}
 
-	copy_page((void *)kto, (void *)kfrom);
+	copy_page(kto, kfrom);
 
 	/*
 	 * Mark DST page K-mapping as dirty for a later finalization by
@@ -847,11 +850,14 @@ void copy_user_highpage(struct page *to, struct page *from,
 	 * sync the kernel mapping back to physical page
 	 */
 	if (clean_src_k_mappings) {
-		__flush_dcache_page(kfrom, kfrom);
+		__flush_dcache_page((unsigned long)kfrom, (unsigned long)kfrom);
 		set_bit(PG_dc_clean, &from->flags);
 	} else {
 		clear_bit(PG_dc_clean, &from->flags);
 	}
+
+	kunmap_atomic(kto);
+	kunmap_atomic(kfrom);
 }
 
 void clear_user_page(void *to, unsigned long u_vaddr, struct page *page)
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index d948e4e9d89c..af63f4a13e60 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -18,7 +18,14 @@
 #include <asm/pgalloc.h>
 #include <asm/mmu.h>
 
-static int handle_vmalloc_fault(unsigned long address)
+/*
+ * kernel virtual address is required to implement vmalloc/pkmap/fixmap
+ * Refer to asm/processor.h for System Memory Map
+ *
+ * It simply copies the PMD entry (pointer to 2nd level page table or hugepage)
+ * from swapper pgdir to task pgdir. The 2nd level table/page is thus shared
+ */
+noinline static int handle_kernel_vaddr_fault(unsigned long address)
 {
 	/*
 	 * Synchronize this task's top level page-table
@@ -72,8 +79,8 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 * only copy the information from the master page table,
 	 * nothing more.
 	 */
-	if (address >= VMALLOC_START && address <= VMALLOC_END) {
-		ret = handle_vmalloc_fault(address);
+	if (address >= VMALLOC_START) {
+		ret = handle_kernel_vaddr_fault(address);
 		if (unlikely(ret))
 			goto bad_area_nosemaphore;
 		else
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 5121b9b16ba8..5256765d5db0 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -97,7 +97,7 @@ void __init setup_arch_memory(void)
 	/* Last usable page of low mem (no HIGHMEM yet for ARC port) */
 	max_low_pfn = max_pfn = PFN_DOWN(end_mem);
 
-	max_mapnr = max_low_pfn - min_low_pfn;
+	max_mapnr = max_pfn - min_low_pfn;
 
 	/*------------- reserve kernel image -----------------------*/
 	memblock_reserve(CONFIG_LINUX_LINK_BASE,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
