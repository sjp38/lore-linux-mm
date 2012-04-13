Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 122646B007E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:06:04 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2F00CXV8HYD4@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 13 Apr 2012 15:05:58 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2F00MYU8HZ90@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 13 Apr 2012 15:06:00 +0100 (BST)
Date: Fri, 13 Apr 2012 16:05:50 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 4/4] ARM: remove consistent dma region and use common vmalloc
 range for dma allocations
In-reply-to: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1334325950-7881-5-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

This patch changes dma-mapping subsystem to use generic vmalloc areas
for all consistent dma allocations. This increases the total size limit
of the consistent allocations and removes platform hacks and a lot of
duplicated code.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/include/asm/dma-mapping.h |    2 +-
 arch/arm/mm/dma-mapping.c          |  220 +++++++-----------------------------
 2 files changed, 40 insertions(+), 182 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index cb3b7c9..92b0afb 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -210,7 +210,7 @@ int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
  * DMA region above it's default value of 2MB. It must be called before the
  * memory allocator is initialised, i.e. before any core_initcall.
  */
-extern void __init init_consistent_dma_size(unsigned long size);
+static inline void init_consistent_dma_size(unsigned long size) { }
 
 
 #ifdef CONFIG_DMABOUNCE
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index db23ae4..74ff839 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -19,6 +19,8 @@
 #include <linux/dma-mapping.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/io.h>
 
 #include <asm/memory.h>
 #include <asm/highmem.h>
@@ -119,204 +121,59 @@ static void __dma_free_buffer(struct page *page, size_t size)
 }
 
 #ifdef CONFIG_MMU
-
-#define CONSISTENT_OFFSET(x)	(((unsigned long)(x) - consistent_base) >> PAGE_SHIFT)
-#define CONSISTENT_PTE_INDEX(x) (((unsigned long)(x) - consistent_base) >> PMD_SHIFT)
-
-/*
- * These are the page tables (2MB each) covering uncached, DMA consistent allocations
- */
-static pte_t **consistent_pte;
-
-#define DEFAULT_CONSISTENT_DMA_SIZE SZ_2M
-
-unsigned long consistent_base = CONSISTENT_END - DEFAULT_CONSISTENT_DMA_SIZE;
-
-void __init init_consistent_dma_size(unsigned long size)
-{
-	unsigned long base = CONSISTENT_END - ALIGN(size, SZ_2M);
-
-	BUG_ON(consistent_pte); /* Check we're called before DMA region init */
-	BUG_ON(base < VMALLOC_END);
-
-	/* Grow region to accommodate specified size  */
-	if (base < consistent_base)
-		consistent_base = base;
-}
-
-#include "vmregion.h"
-
-static struct arm_vmregion_head consistent_head = {
-	.vm_lock	= __SPIN_LOCK_UNLOCKED(&consistent_head.vm_lock),
-	.vm_list	= LIST_HEAD_INIT(consistent_head.vm_list),
-	.vm_end		= CONSISTENT_END,
-};
-
 #ifdef CONFIG_HUGETLB_PAGE
 #error ARM Coherent DMA allocator does not (yet) support huge TLB
 #endif
 
-/*
- * Initialise the consistent memory allocation.
- */
-static int __init consistent_init(void)
-{
-	int ret = 0;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	int i = 0;
-	unsigned long base = consistent_base;
-	unsigned long num_ptes = (CONSISTENT_END - base) >> PMD_SHIFT;
-
-	consistent_pte = kmalloc(num_ptes * sizeof(pte_t), GFP_KERNEL);
-	if (!consistent_pte) {
-		pr_err("%s: no memory\n", __func__);
-		return -ENOMEM;
-	}
-
-	pr_debug("DMA memory: 0x%08lx - 0x%08lx:\n", base, CONSISTENT_END);
-	consistent_head.vm_start = base;
-
-	do {
-		pgd = pgd_offset(&init_mm, base);
-
-		pud = pud_alloc(&init_mm, pgd, base);
-		if (!pud) {
-			printk(KERN_ERR "%s: no pud tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		pmd = pmd_alloc(&init_mm, pud, base);
-		if (!pmd) {
-			printk(KERN_ERR "%s: no pmd tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-		WARN_ON(!pmd_none(*pmd));
-
-		pte = pte_alloc_kernel(pmd, base);
-		if (!pte) {
-			printk(KERN_ERR "%s: no pte tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		consistent_pte[i++] = pte;
-		base += PMD_SIZE;
-	} while (base < CONSISTENT_END);
-
-	return ret;
-}
-
-core_initcall(consistent_init);
-
 static void *
 __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
 	const void *caller)
 {
-	struct arm_vmregion *c;
-	size_t align;
-	int bit;
-
-	if (!consistent_pte) {
-		printk(KERN_ERR "%s: not initialised\n", __func__);
-		dump_stack();
-		return NULL;
-	}
-
-	/*
-	 * Align the virtual region allocation - maximum alignment is
-	 * a section size, minimum is a page size.  This helps reduce
-	 * fragmentation of the DMA space, and also prevents allocations
-	 * smaller than a section from crossing a section boundary.
-	 */
-	bit = fls(size - 1);
-	if (bit > SECTION_SHIFT)
-		bit = SECTION_SHIFT;
-	align = 1 << bit;
-
-	/*
-	 * Allocate a virtual address in the consistent mapping region.
-	 */
-	c = arm_vmregion_alloc(&consistent_head, align, size,
-			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM), caller);
-	if (c) {
-		pte_t *pte;
-		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
-		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-
-		pte = consistent_pte[idx] + off;
-		c->vm_pages = page;
-
-		do {
-			BUG_ON(!pte_none(*pte));
-
-			set_pte_ext(pte, mk_pte(page, prot), 0);
-			page++;
-			pte++;
-			off++;
-			if (off >= PTRS_PER_PTE) {
-				off = 0;
-				pte = consistent_pte[++idx];
-			}
-		} while (size -= PAGE_SIZE);
-
-		dsb();
+	struct vm_struct *area;
+	unsigned long addr;
 
-		return (void *)c->vm_start;
-	}
-	return NULL;
+	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
+	if (!area)
+		return NULL;
+	addr = (unsigned long)area->addr;
+	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
+
+	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
+		vunmap((void *)addr);
+		return NULL;
+	}
+	return (void *)addr;
 }
 
 static void __dma_free_remap(void *cpu_addr, size_t size)
 {
-	struct arm_vmregion *c;
-	unsigned long addr;
-	pte_t *ptep;
-	int idx;
-	u32 off;
+	struct vm_struct *area;
+
+	read_lock(&vmlist_lock);
 
-	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
-	if (!c) {
+	area = find_vm_area(cpu_addr);
+	if (!area) {
 		printk(KERN_ERR "%s: trying to free invalid coherent area: %p\n",
 		       __func__, cpu_addr);
 		dump_stack();
+		read_unlock(&vmlist_lock);
 		return;
 	}
 
-	if ((c->vm_end - c->vm_start) != size) {
+	/*
+	 * get_vm_area_caller always use additional guard page, so skip it here
+	 */
+	if (area->size - PAGE_SIZE != size) {
 		printk(KERN_ERR "%s: freeing wrong coherent size (%ld != %d)\n",
-		       __func__, c->vm_end - c->vm_start, size);
+		       __func__, area->size, size);
 		dump_stack();
-		size = c->vm_end - c->vm_start;
+		size = area->size;
 	}
 
-	idx = CONSISTENT_PTE_INDEX(c->vm_start);
-	off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-	ptep = consistent_pte[idx] + off;
-	addr = c->vm_start;
-	do {
-		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
-
-		ptep++;
-		addr += PAGE_SIZE;
-		off++;
-		if (off >= PTRS_PER_PTE) {
-			off = 0;
-			ptep = consistent_pte[++idx];
-		}
-
-		if (pte_none(pte) || !pte_present(pte))
-			printk(KERN_CRIT "%s: bad page in kernel page table\n",
-			       __func__);
-	} while (size -= PAGE_SIZE);
+	unmap_kernel_range((unsigned long)cpu_addr, size);
+	read_unlock(&vmlist_lock);
 
-	flush_tlb_kernel_range(c->vm_start, c->vm_end);
-
-	arm_vmregion_free(&consistent_head, c);
+	vunmap(cpu_addr);
 }
 
 #else	/* !CONFIG_MMU */
@@ -398,25 +255,29 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 {
 	int ret = -ENXIO;
 #ifdef CONFIG_MMU
+	struct vm_struct *area;
 	unsigned long user_size, kern_size;
-	struct arm_vmregion *c;
 
+	read_lock(&vmlist_lock);
+	area = find_vm_area(cpu_addr);
 	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 
-	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
-	if (c) {
+	if (area) {
 		unsigned long off = vma->vm_pgoff;
+		unsigned long phys = __phys_to_pfn(area->phys_addr);
 
-		kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
+		/* skip vmalloc guard page */
+		kern_size = (area->size >> PAGE_SHIFT) - 1;
 
 		if (off < kern_size &&
 		    user_size <= (kern_size - off)) {
 			ret = remap_pfn_range(vma, vma->vm_start,
-					      page_to_pfn(c->vm_pages) + off,
+					      phys + off,
 					      user_size << PAGE_SHIFT,
 					      vma->vm_page_prot);
 		}
 	}
+	read_unlock(&vmlist_lock);
 #endif	/* CONFIG_MMU */
 
 	return ret;
@@ -726,9 +587,6 @@ EXPORT_SYMBOL(dma_set_mask);
 
 static int __init dma_debug_do_init(void)
 {
-#ifdef CONFIG_MMU
-	arm_vmregion_create_proc("dma-mappings", &consistent_head);
-#endif
 	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
 	return 0;
 }
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
