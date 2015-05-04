Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B08C26B0072
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:23:26 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so142434314wgy.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:23:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si21508351wjs.183.2015.05.04.01.23.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:23:19 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 04/15] xen: eliminate scalability issues from initial mapping setup
Date: Mon,  4 May 2015 10:23:04 +0200
Message-Id: <1430727795-25133-5-git-send-email-jgross@suse.com>
In-Reply-To: <1430727795-25133-1-git-send-email-jgross@suse.com>
References: <1430727795-25133-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Direct Xen to place the initial P->M table outside of the initial
mapping, as otherwise the 1G (implementation) / 2G (theoretical)
restriction on the size of the initial mapping limits the amount
of memory a domain can be handed initially.

As the initial P->M table is copied rather early during boot to
domain private memory and it's initial virtual mapping is dropped,
the easiest way to avoid virtual address conflicts with other
addresses in the kernel is to use a user address area for the
virtual address of the initial P->M table. This allows us to just
throw away the page tables of the initial mapping after the copy
without having to care about address invalidation.

It should be noted that this patch won't enable a pv-domain to USE
more than 512 GB of RAM. It just enables it to be started with a
P->M table covering more memory. This is especially important for
being able to boot a Dom0 on a system with more than 512 GB memory.

Signed-off-by: Juergen Gross <jgross@suse.com>
Based-on-patch-by: Jan Beulich <jbeulich@suse.com>
---
 arch/x86/xen/mmu.c      | 126 ++++++++++++++++++++++++++++++++++++++++++++----
 arch/x86/xen/setup.c    |  67 ++++++++++++++-----------
 arch/x86/xen/xen-head.S |   2 +
 3 files changed, 156 insertions(+), 39 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index dd151b2..c04e14e 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1114,6 +1114,77 @@ static void __init xen_cleanhighmap(unsigned long vaddr,
 	xen_mc_flush();
 }
 
+/*
+ * Make a page range writeable and free it.
+ */
+static void __init xen_free_ro_pages(unsigned long paddr, unsigned long size)
+{
+	void *vaddr = __va(paddr);
+	void *vaddr_end = vaddr + size;
+
+	for (; vaddr < vaddr_end; vaddr += PAGE_SIZE)
+		make_lowmem_page_readwrite(vaddr);
+
+	memblock_free(paddr, size);
+}
+
+static void __init xen_cleanmfnmap_free_pgtbl(void *pgtbl)
+{
+	unsigned long pa = __pa(pgtbl) & PHYSICAL_PAGE_MASK;
+
+	ClearPagePinned(virt_to_page(__va(pa)));
+	xen_free_ro_pages(pa, PAGE_SIZE);
+}
+
+/*
+ * Since it is well isolated we can (and since it is perhaps large we should)
+ * also free the page tables mapping the initial P->M table.
+ */
+static void __init xen_cleanmfnmap(unsigned long vaddr)
+{
+	unsigned long va = vaddr & PMD_MASK;
+	unsigned long pa;
+	pgd_t *pgd = pgd_offset_k(va);
+	pud_t *pud_page = pud_offset(pgd, 0);
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	unsigned int i;
+
+	set_pgd(pgd, __pgd(0));
+	do {
+		pud = pud_page + pud_index(va);
+		if (pud_none(*pud)) {
+			va += PUD_SIZE;
+		} else if (pud_large(*pud)) {
+			pa = pud_val(*pud) & PHYSICAL_PAGE_MASK;
+			xen_free_ro_pages(pa, PUD_SIZE);
+			va += PUD_SIZE;
+		} else {
+			pmd = pmd_offset(pud, va);
+			if (pmd_large(*pmd)) {
+				pa = pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
+				xen_free_ro_pages(pa, PMD_SIZE);
+			} else if (!pmd_none(*pmd)) {
+				pte = pte_offset_kernel(pmd, va);
+				for (i = 0; i < PTRS_PER_PTE; ++i) {
+					if (pte_none(pte[i]))
+						break;
+					pa = pte_pfn(pte[i]) << PAGE_SHIFT;
+					xen_free_ro_pages(pa, PAGE_SIZE);
+				}
+				xen_cleanmfnmap_free_pgtbl(pte);
+			}
+			va += PMD_SIZE;
+			if (pmd_index(va))
+				continue;
+			xen_cleanmfnmap_free_pgtbl(pmd);
+		}
+
+	} while (pud_index(va) || pmd_index(va));
+	xen_cleanmfnmap_free_pgtbl(pud_page);
+}
+
 static void __init xen_pagetable_p2m_free(void)
 {
 	unsigned long size;
@@ -1128,18 +1199,25 @@ static void __init xen_pagetable_p2m_free(void)
 	/* using __ka address and sticking INVALID_P2M_ENTRY! */
 	memset((void *)xen_start_info->mfn_list, 0xff, size);
 
-	/* We should be in __ka space. */
-	BUG_ON(xen_start_info->mfn_list < __START_KERNEL_map);
 	addr = xen_start_info->mfn_list;
-	/* We roundup to the PMD, which means that if anybody at this stage is
-	 * using the __ka address of xen_start_info or xen_start_info->shared_info
-	 * they are in going to crash. Fortunatly we have already revectored
-	 * in xen_setup_kernel_pagetable and in xen_setup_shared_info. */
+	/*
+	 * We could be in __ka space.
+	 * We roundup to the PMD, which means that if anybody at this stage is
+	 * using the __ka address of xen_start_info or
+	 * xen_start_info->shared_info they are in going to crash. Fortunatly
+	 * we have already revectored in xen_setup_kernel_pagetable and in
+	 * xen_setup_shared_info.
+	 */
 	size = roundup(size, PMD_SIZE);
-	xen_cleanhighmap(addr, addr + size);
 
-	size = PAGE_ALIGN(xen_start_info->nr_pages * sizeof(unsigned long));
-	memblock_free(__pa(xen_start_info->mfn_list), size);
+	if (addr >= __START_KERNEL_map) {
+		xen_cleanhighmap(addr, addr + size);
+		size = PAGE_ALIGN(xen_start_info->nr_pages *
+				  sizeof(unsigned long));
+		memblock_free(__pa(addr), size);
+	} else {
+		xen_cleanmfnmap(addr);
+	}
 
 	/* At this stage, cleanup_highmap has already cleaned __ka space
 	 * from _brk_limit way up to the max_pfn_mapped (which is the end of
@@ -1461,6 +1539,24 @@ static pte_t __init mask_rw_pte(pte_t *ptep, pte_t pte)
 #else /* CONFIG_X86_64 */
 static pte_t __init mask_rw_pte(pte_t *ptep, pte_t pte)
 {
+	unsigned long pfn;
+
+	if (xen_feature(XENFEAT_writable_page_tables) ||
+	    xen_feature(XENFEAT_auto_translated_physmap) ||
+	    xen_start_info->mfn_list >= __START_KERNEL_map)
+		return pte;
+
+	/*
+	 * Pages belonging to the initial p2m list mapped outside the default
+	 * address range must be mapped read-only. This region contains the
+	 * page tables for mapping the p2m list, too, and page tables MUST be
+	 * mapped read-only.
+	 */
+	pfn = pte_pfn(pte);
+	if (pfn >= xen_start_info->first_p2m_pfn &&
+	    pfn < xen_start_info->first_p2m_pfn + xen_start_info->nr_p2m_frames)
+		pte = __pte_ma(pte_val_ma(pte) & ~_PAGE_RW);
+
 	return pte;
 }
 #endif /* CONFIG_X86_64 */
@@ -1815,7 +1911,10 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	 * mappings. Considering that on Xen after the kernel mappings we
 	 * have the mappings of some pages that don't exist in pfn space, we
 	 * set max_pfn_mapped to the last real pfn mapped. */
-	max_pfn_mapped = PFN_DOWN(__pa(xen_start_info->mfn_list));
+	if (xen_start_info->mfn_list < __START_KERNEL_map)
+		max_pfn_mapped = xen_start_info->first_p2m_pfn;
+	else
+		max_pfn_mapped = PFN_DOWN(__pa(xen_start_info->mfn_list));
 
 	pt_base = PFN_DOWN(__pa(xen_start_info->pt_base));
 	pt_end = pt_base + xen_start_info->nr_pt_frames;
@@ -1855,6 +1954,11 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	/* Graft it onto L4[511][510] */
 	copy_page(level2_kernel_pgt, l2);
 
+	/* Copy the initial P->M table mappings if necessary. */
+	i = pgd_index(xen_start_info->mfn_list);
+	if (i && i < pgd_index(__START_KERNEL_map))
+		init_level4_pgt[i] = ((pgd_t *)xen_start_info->pt_base)[i];
+
 	if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 		/* Make pagetable pieces RO */
 		set_page_prot(init_level4_pgt, PAGE_KERNEL_RO);
@@ -1895,6 +1999,8 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 
 	/* Our (by three pages) smaller Xen pagetable that we are using */
 	memblock_reserve(PFN_PHYS(pt_base), (pt_end - pt_base) * PAGE_SIZE);
+	/* protect xen_start_info */
+	memblock_reserve(__pa(xen_start_info), PAGE_SIZE);
 	/* Revector the xen_start_info */
 	xen_start_info = (struct start_info *)__va(__pa(xen_start_info));
 }
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 55f388e..adad417 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -560,6 +560,41 @@ static void __init xen_ignore_unusable(struct e820entry *list, size_t map_size)
 	}
 }
 
+/*
+ * Reserve Xen mfn_list.
+ * See comment above "struct start_info" in <xen/interface/xen.h>
+ * We tried to make the the memblock_reserve more selective so
+ * that it would be clear what region is reserved. Sadly we ran
+ * in the problem wherein on a 64-bit hypervisor with a 32-bit
+ * initial domain, the pt_base has the cr3 value which is not
+ * neccessarily where the pagetable starts! As Jan put it: "
+ * Actually, the adjustment turns out to be correct: The page
+ * tables for a 32-on-64 dom0 get allocated in the order "first L1",
+ * "first L2", "first L3", so the offset to the page table base is
+ * indeed 2. When reading xen/include/public/xen.h's comment
+ * very strictly, this is not a violation (since there nothing is said
+ * that the first thing in the page table space is pointed to by
+ * pt_base; I admit that this seems to be implied though, namely
+ * do I think that it is implied that the page table space is the
+ * range [pt_base, pt_base + nt_pt_frames), whereas that
+ * range here indeed is [pt_base - 2, pt_base - 2 + nt_pt_frames),
+ * which - without a priori knowledge - the kernel would have
+ * difficulty to figure out)." - so lets just fall back to the
+ * easy way and reserve the whole region.
+ */
+static void __init xen_reserve_xen_mfnlist(void)
+{
+	if (xen_start_info->mfn_list >= __START_KERNEL_map) {
+		memblock_reserve(__pa(xen_start_info->mfn_list),
+				 xen_start_info->pt_base -
+				 xen_start_info->mfn_list);
+		return;
+	}
+
+	memblock_reserve(PFN_PHYS(xen_start_info->first_p2m_pfn),
+			 PFN_PHYS(xen_start_info->nr_p2m_frames));
+}
+
 /**
  * machine_specific_memory_setup - Hook for machine specific memory setup.
  **/
@@ -684,35 +719,10 @@ char * __init xen_memory_setup(void)
 	e820_add_region(ISA_START_ADDRESS, ISA_END_ADDRESS - ISA_START_ADDRESS,
 			E820_RESERVED);
 
-	/*
-	 * Reserve Xen bits:
-	 *  - mfn_list
-	 *  - xen_start_info
-	 * See comment above "struct start_info" in <xen/interface/xen.h>
-	 * We tried to make the the memblock_reserve more selective so
-	 * that it would be clear what region is reserved. Sadly we ran
-	 * in the problem wherein on a 64-bit hypervisor with a 32-bit
-	 * initial domain, the pt_base has the cr3 value which is not
-	 * neccessarily where the pagetable starts! As Jan put it: "
-	 * Actually, the adjustment turns out to be correct: The page
-	 * tables for a 32-on-64 dom0 get allocated in the order "first L1",
-	 * "first L2", "first L3", so the offset to the page table base is
-	 * indeed 2. When reading xen/include/public/xen.h's comment
-	 * very strictly, this is not a violation (since there nothing is said
-	 * that the first thing in the page table space is pointed to by
-	 * pt_base; I admit that this seems to be implied though, namely
-	 * do I think that it is implied that the page table space is the
-	 * range [pt_base, pt_base + nt_pt_frames), whereas that
-	 * range here indeed is [pt_base - 2, pt_base - 2 + nt_pt_frames),
-	 * which - without a priori knowledge - the kernel would have
-	 * difficulty to figure out)." - so lets just fall back to the
-	 * easy way and reserve the whole region.
-	 */
-	memblock_reserve(__pa(xen_start_info->mfn_list),
-			 xen_start_info->pt_base - xen_start_info->mfn_list);
-
 	sanitize_e820_map(e820.map, ARRAY_SIZE(e820.map), &e820.nr_map);
 
+	xen_reserve_xen_mfnlist();
+
 	return "Xen";
 }
 
@@ -739,8 +749,7 @@ char * __init xen_auto_xlated_memory_setup(void)
 	for (i = 0; i < memmap.nr_entries; i++)
 		e820_add_region(map[i].addr, map[i].size, map[i].type);
 
-	memblock_reserve(__pa(xen_start_info->mfn_list),
-			 xen_start_info->pt_base - xen_start_info->mfn_list);
+	xen_reserve_xen_mfnlist();
 
 	return "Xen";
 }
diff --git a/arch/x86/xen/xen-head.S b/arch/x86/xen/xen-head.S
index 8afdfcc..b65f59a 100644
--- a/arch/x86/xen/xen-head.S
+++ b/arch/x86/xen/xen-head.S
@@ -104,6 +104,8 @@ ENTRY(hypercall_page)
 	ELFNOTE(Xen, XEN_ELFNOTE_VIRT_BASE,      _ASM_PTR __PAGE_OFFSET)
 #else
 	ELFNOTE(Xen, XEN_ELFNOTE_VIRT_BASE,      _ASM_PTR __START_KERNEL_map)
+	/* Map the p2m table to a 512GB-aligned user address. */
+	ELFNOTE(Xen, XEN_ELFNOTE_INIT_P2M,       .quad PGDIR_SIZE)
 #endif
 	ELFNOTE(Xen, XEN_ELFNOTE_ENTRY,          _ASM_PTR startup_xen)
 	ELFNOTE(Xen, XEN_ELFNOTE_HYPERCALL_PAGE, _ASM_PTR hypercall_page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
