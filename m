Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C7AB082F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:25:28 -0400 (EDT)
Received: by pasz6 with SMTP id z6so4810288pas.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:25:28 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id d10si69784897pbu.167.2015.10.28.04.25.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 04:25:27 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 3/3] ARC: mm: HIGHMEM: switch to using phys_addr_t for physical addresses
Date: Wed, 28 Oct 2015 16:53:13 +0530
Message-ID: <1446031393-2312-4-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
References: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Mel
 Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-snps-arc@lists.infraded.org, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

This allows PAE40 support in next patch when we switch to > 32-bits of
physical addresses

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/cacheflush.h |  8 ++++----
 arch/arc/mm/cache.c               | 26 +++++++++++++-------------
 arch/arc/mm/tlb.c                 | 10 +++++-----
 3 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/arch/arc/include/asm/cacheflush.h b/arch/arc/include/asm/cacheflush.h
index 0992d3dbcc65..fbe3587c4f36 100644
--- a/arch/arc/include/asm/cacheflush.h
+++ b/arch/arc/include/asm/cacheflush.h
@@ -31,10 +31,10 @@
 
 void flush_cache_all(void);
 
-void flush_icache_range(unsigned long start, unsigned long end);
-void __sync_icache_dcache(unsigned long paddr, unsigned long vaddr, int len);
-void __inv_icache_page(unsigned long paddr, unsigned long vaddr);
-void __flush_dcache_page(unsigned long paddr, unsigned long vaddr);
+void flush_icache_range(unsigned long kstart, unsigned long kend);
+void __sync_icache_dcache(phys_addr_t paddr, unsigned long vaddr, int len);
+void __inv_icache_page(phys_addr_t paddr, unsigned long vaddr);
+void __flush_dcache_page(phys_addr_t paddr, unsigned long vaddr);
 
 #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
 
diff --git a/arch/arc/mm/cache.c b/arch/arc/mm/cache.c
index 08a7cc0ac100..6941db059ad8 100644
--- a/arch/arc/mm/cache.c
+++ b/arch/arc/mm/cache.c
@@ -26,7 +26,7 @@ int ioc_exists;
 volatile int slc_enable = 1, ioc_enable = 1;
 unsigned long perip_space = ARC_UNCACHED_ADDR_SPACE;
 
-void (*_cache_line_loop_ic_fn)(unsigned long paddr, unsigned long vaddr,
+void (*_cache_line_loop_ic_fn)(phys_addr_t paddr, unsigned long vaddr,
 			       unsigned long sz, const int cacheop);
 
 void (*__dma_cache_wback_inv)(unsigned long start, unsigned long sz);
@@ -223,7 +223,7 @@ slc_chk:
  */
 
 static inline
-void __cache_line_loop_v2(unsigned long paddr, unsigned long vaddr,
+void __cache_line_loop_v2(phys_addr_t paddr, unsigned long vaddr,
 			  unsigned long sz, const int op)
 {
 	unsigned int aux_cmd;
@@ -261,7 +261,7 @@ void __cache_line_loop_v2(unsigned long paddr, unsigned long vaddr,
 }
 
 static inline
-void __cache_line_loop_v3(unsigned long paddr, unsigned long vaddr,
+void __cache_line_loop_v3(phys_addr_t paddr, unsigned long vaddr,
 			  unsigned long sz, const int op)
 {
 	unsigned int aux_cmd, aux_tag;
@@ -315,7 +315,7 @@ void __cache_line_loop_v3(unsigned long paddr, unsigned long vaddr,
  * specified in PTAG (similar to MMU v3)
  */
 static inline
-void __cache_line_loop_v4(unsigned long paddr, unsigned long vaddr,
+void __cache_line_loop_v4(phys_addr_t paddr, unsigned long vaddr,
 			  unsigned long sz, const int cacheop)
 {
 	unsigned int aux_cmd;
@@ -419,7 +419,7 @@ static inline void __dc_entire_op(const int op)
 /*
  * D-Cache Line ops: Per Line INV (discard or wback+discard) or FLUSH (wback)
  */
-static inline void __dc_line_op(unsigned long paddr, unsigned long vaddr,
+static inline void __dc_line_op(phys_addr_t paddr, unsigned long vaddr,
 				unsigned long sz, const int op)
 {
 	unsigned long flags;
@@ -452,7 +452,7 @@ static inline void __ic_entire_inv(void)
 }
 
 static inline void
-__ic_line_inv_vaddr_local(unsigned long paddr, unsigned long vaddr,
+__ic_line_inv_vaddr_local(phys_addr_t paddr, unsigned long vaddr,
 			  unsigned long sz)
 {
 	unsigned long flags;
@@ -469,7 +469,7 @@ __ic_line_inv_vaddr_local(unsigned long paddr, unsigned long vaddr,
 #else
 
 struct ic_inv_args {
-	unsigned long paddr, vaddr;
+	phys_addr_t paddr, vaddr;
 	int sz;
 };
 
@@ -480,7 +480,7 @@ static void __ic_line_inv_vaddr_helper(void *info)
         __ic_line_inv_vaddr_local(ic_inv->paddr, ic_inv->vaddr, ic_inv->sz);
 }
 
-static void __ic_line_inv_vaddr(unsigned long paddr, unsigned long vaddr,
+static void __ic_line_inv_vaddr(phys_addr_t paddr, unsigned long vaddr,
 				unsigned long sz)
 {
 	struct ic_inv_args ic_inv = {
@@ -501,7 +501,7 @@ static void __ic_line_inv_vaddr(unsigned long paddr, unsigned long vaddr,
 
 #endif /* CONFIG_ARC_HAS_ICACHE */
 
-noinline void slc_op(unsigned long paddr, unsigned long sz, const int op)
+noinline void slc_op(phys_addr_t paddr, unsigned long sz, const int op)
 {
 #ifdef CONFIG_ISA_ARCV2
 	/*
@@ -591,7 +591,7 @@ void flush_dcache_page(struct page *page)
 	} else if (page_mapped(page)) {
 
 		/* kernel reading from page with U-mapping */
-		unsigned long paddr = (unsigned long)page_address(page);
+		phys_addr_t paddr = (unsigned long)page_address(page);
 		unsigned long vaddr = page->index << PAGE_CACHE_SHIFT;
 
 		if (addr_not_cache_congruent(paddr, vaddr))
@@ -739,14 +739,14 @@ EXPORT_SYMBOL(flush_icache_range);
  *    builtin kernel page will not have any virtual mappings.
  *    kprobe on loadable module will be kernel vaddr.
  */
-void __sync_icache_dcache(unsigned long paddr, unsigned long vaddr, int len)
+void __sync_icache_dcache(phys_addr_t paddr, unsigned long vaddr, int len)
 {
 	__dc_line_op(paddr, vaddr, len, OP_FLUSH_N_INV);
 	__ic_line_inv_vaddr(paddr, vaddr, len);
 }
 
 /* wrapper to compile time eliminate alignment checks in flush loop */
-void __inv_icache_page(unsigned long paddr, unsigned long vaddr)
+void __inv_icache_page(phys_addr_t paddr, unsigned long vaddr)
 {
 	__ic_line_inv_vaddr(paddr, vaddr, PAGE_SIZE);
 }
@@ -755,7 +755,7 @@ void __inv_icache_page(unsigned long paddr, unsigned long vaddr)
  * wrapper to clearout kernel or userspace mappings of a page
  * For kernel mappings @vaddr == @paddr
  */
-void __flush_dcache_page(unsigned long paddr, unsigned long vaddr)
+void __flush_dcache_page(phys_addr_t paddr, unsigned long vaddr)
 {
 	__dc_line_op(paddr, vaddr & PAGE_MASK, PAGE_SIZE, OP_FLUSH_N_INV);
 }
diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index 5dcae21dd8dc..b5f28dc0f924 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -499,7 +499,7 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 /*
  * Routine to create a TLB entry
  */
-void create_tlb(struct vm_area_struct *vma, unsigned long address, pte_t *ptep)
+void create_tlb(struct vm_area_struct *vma, unsigned long vaddr, pte_t *ptep)
 {
 	unsigned long flags;
 	unsigned int asid_or_sasid, rwx;
@@ -535,9 +535,9 @@ void create_tlb(struct vm_area_struct *vma, unsigned long address, pte_t *ptep)
 
 	local_irq_save(flags);
 
-	tlb_paranoid_check(asid_mm(vma->vm_mm, smp_processor_id()), address);
+	tlb_paranoid_check(asid_mm(vma->vm_mm, smp_processor_id()), vaddr);
 
-	address &= PAGE_MASK;
+	vaddr &= PAGE_MASK;
 
 	/* update this PTE credentials */
 	pte_val(*ptep) |= (_PAGE_PRESENT | _PAGE_ACCESSED);
@@ -547,7 +547,7 @@ void create_tlb(struct vm_area_struct *vma, unsigned long address, pte_t *ptep)
 	/* ASID for this task */
 	asid_or_sasid = read_aux_reg(ARC_REG_PID) & 0xff;
 
-	pd0 = address | asid_or_sasid | (pte_val(*ptep) & PTE_BITS_IN_PD0);
+	pd0 = vaddr | asid_or_sasid | (pte_val(*ptep) & PTE_BITS_IN_PD0);
 
 	/*
 	 * ARC MMU provides fully orthogonal access bits for K/U mode,
@@ -583,7 +583,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long vaddr_unaligned,
 		      pte_t *ptep)
 {
 	unsigned long vaddr = vaddr_unaligned & PAGE_MASK;
-	unsigned long paddr = pte_val(*ptep) & PAGE_MASK;
+	phys_addr_t paddr = pte_val(*ptep) & PAGE_MASK;
 	struct page *page = pfn_to_page(pte_pfn(*ptep));
 
 	create_tlb(vma, vaddr, ptep);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
