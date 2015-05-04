Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 87CB26B0080
	for <linux-mm@kvack.org>; Mon,  4 May 2015 02:19:41 -0400 (EDT)
Received: by wgin8 with SMTP id n8so139629278wgi.0
        for <linux-mm@kvack.org>; Sun, 03 May 2015 23:19:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gb5si21213480wjb.21.2015.05.03.23.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 May 2015 23:19:14 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 13/15] xen: move p2m list if conflicting with e820 map
Date: Mon,  4 May 2015 08:19:04 +0200
Message-Id: <1430720346-21063-14-git-send-email-jgross@suse.com>
In-Reply-To: <1430720346-21063-1-git-send-email-jgross@suse.com>
References: <1430720346-21063-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

Check whether the hypervisor supplied p2m list is placed at a location
which is conflicting with the target E820 map. If this is the case
relocate it to a new area unused up to now and compliant to the E820
map.

As the p2m list might by huge (up to several GB) and is required to be
mapped virtually, set up a temporary mapping for the copied list.

For pvh domains just delete the p2m related information from start
info instead of reserving the p2m memory, as we don't need it at all.

For 32 bit kernels adjust the memblock_reserve() parameters in order
to cover the page tables only. This requires to memblock_reserve() the
start_info page on it's own.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/mmu.c     | 232 ++++++++++++++++++++++++++++++++++++++++++++++---
 arch/x86/xen/setup.c   |  51 +++++------
 arch/x86/xen/xen-ops.h |   3 +
 3 files changed, 247 insertions(+), 39 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 1982617..9694d79 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1094,6 +1094,16 @@ static void xen_exit_mmap(struct mm_struct *mm)
 
 static void xen_post_allocator_init(void);
 
+static void __init pin_pagetable_pfn(unsigned cmd, unsigned long pfn)
+{
+	struct mmuext_op op;
+
+	op.cmd = cmd;
+	op.arg1.mfn = pfn_to_mfn(pfn);
+	if (HYPERVISOR_mmuext_op(&op, 1, NULL, DOMID_SELF))
+		BUG();
+}
+
 #ifdef CONFIG_X86_64
 static void __init xen_cleanhighmap(unsigned long vaddr,
 				    unsigned long vaddr_end)
@@ -1129,10 +1139,12 @@ static void __init xen_free_ro_pages(unsigned long paddr, unsigned long size)
 	memblock_free(paddr, size);
 }
 
-static void __init xen_cleanmfnmap_free_pgtbl(void *pgtbl)
+static void __init xen_cleanmfnmap_free_pgtbl(void *pgtbl, bool unpin)
 {
 	unsigned long pa = __pa(pgtbl) & PHYSICAL_PAGE_MASK;
 
+	if (unpin)
+		pin_pagetable_pfn(MMUEXT_UNPIN_TABLE, PFN_DOWN(pa));
 	ClearPagePinned(virt_to_page(__va(pa)));
 	xen_free_ro_pages(pa, PAGE_SIZE);
 }
@@ -1151,7 +1163,9 @@ static void __init xen_cleanmfnmap(unsigned long vaddr)
 	pmd_t *pmd;
 	pte_t *pte;
 	unsigned int i;
+	bool unpin;
 
+	unpin = (vaddr == 2 * PGDIR_SIZE);
 	set_pgd(pgd, __pgd(0));
 	do {
 		pud = pud_page + pud_index(va);
@@ -1168,22 +1182,24 @@ static void __init xen_cleanmfnmap(unsigned long vaddr)
 				xen_free_ro_pages(pa, PMD_SIZE);
 			} else if (!pmd_none(*pmd)) {
 				pte = pte_offset_kernel(pmd, va);
+				set_pmd(pmd, __pmd(0));
 				for (i = 0; i < PTRS_PER_PTE; ++i) {
 					if (pte_none(pte[i]))
 						break;
 					pa = pte_pfn(pte[i]) << PAGE_SHIFT;
 					xen_free_ro_pages(pa, PAGE_SIZE);
 				}
-				xen_cleanmfnmap_free_pgtbl(pte);
+				xen_cleanmfnmap_free_pgtbl(pte, unpin);
 			}
 			va += PMD_SIZE;
 			if (pmd_index(va))
 				continue;
-			xen_cleanmfnmap_free_pgtbl(pmd);
+			set_pud(pud, __pud(0));
+			xen_cleanmfnmap_free_pgtbl(pmd, unpin);
 		}
 
 	} while (pud_index(va) || pmd_index(va));
-	xen_cleanmfnmap_free_pgtbl(pud_page);
+	xen_cleanmfnmap_free_pgtbl(pud_page, unpin);
 }
 
 static void __init xen_pagetable_p2m_free(void)
@@ -1219,6 +1235,12 @@ static void __init xen_pagetable_p2m_free(void)
 	} else {
 		xen_cleanmfnmap(addr);
 	}
+}
+
+static void __init xen_pagetable_cleanhighmap(void)
+{
+	unsigned long size;
+	unsigned long addr;
 
 	/* At this stage, cleanup_highmap has already cleaned __ka space
 	 * from _brk_limit way up to the max_pfn_mapped (which is the end of
@@ -1251,6 +1273,8 @@ static void __init xen_pagetable_p2m_setup(void)
 
 #ifdef CONFIG_X86_64
 	xen_pagetable_p2m_free();
+
+	xen_pagetable_cleanhighmap();
 #endif
 	/* And revector! Bye bye old array */
 	xen_start_info->mfn_list = (unsigned long)xen_p2m_addr;
@@ -1586,15 +1610,6 @@ static void __init xen_set_pte_init(pte_t *ptep, pte_t pte)
 	native_set_pte(ptep, pte);
 }
 
-static void __init pin_pagetable_pfn(unsigned cmd, unsigned long pfn)
-{
-	struct mmuext_op op;
-	op.cmd = cmd;
-	op.arg1.mfn = pfn_to_mfn(pfn);
-	if (HYPERVISOR_mmuext_op(&op, 1, NULL, DOMID_SELF))
-		BUG();
-}
-
 /* Early in boot, while setting up the initial pagetable, assume
    everything is pinned. */
 static void __init xen_alloc_pte_init(struct mm_struct *mm, unsigned long pfn)
@@ -2007,6 +2022,185 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	/* Revector the xen_start_info */
 	xen_start_info = (struct start_info *)__va(__pa(xen_start_info));
 }
+
+/*
+ * Read a value from a physical address.
+ */
+static unsigned long __init xen_read_phys_ulong(phys_addr_t addr)
+{
+	unsigned long *vaddr;
+	unsigned long val;
+
+	vaddr = early_memremap_ro(addr, sizeof(val));
+	val = *vaddr;
+	early_memunmap(vaddr, sizeof(val));
+	return val;
+}
+
+/*
+ * Translate a virtual address to a physical one without relying on mapped
+ * page tables.
+ */
+static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
+{
+	phys_addr_t pa;
+	pgd_t pgd;
+	pud_t pud;
+	pmd_t pmd;
+	pte_t pte;
+
+	pa = read_cr3();
+	pgd = native_make_pgd(xen_read_phys_ulong(pa + pgd_index(vaddr) *
+						       sizeof(pgd)));
+	if (!pgd_present(pgd))
+		return 0;
+
+	pa = pgd_val(pgd) & PTE_PFN_MASK;
+	pud = native_make_pud(xen_read_phys_ulong(pa + pud_index(vaddr) *
+						       sizeof(pud)));
+	if (!pud_present(pud))
+		return 0;
+	pa = pud_pfn(pud) << PAGE_SHIFT;
+	if (pud_large(pud))
+		return pa + (vaddr & ~PUD_MASK);
+
+	pmd = native_make_pmd(xen_read_phys_ulong(pa + pmd_index(vaddr) *
+						       sizeof(pmd)));
+	if (!pmd_present(pmd))
+		return 0;
+	pa = pmd_pfn(pmd) << PAGE_SHIFT;
+	if (pmd_large(pmd))
+		return pa + (vaddr & ~PMD_MASK);
+
+	pte = native_make_pte(xen_read_phys_ulong(pa + pte_index(vaddr) *
+						       sizeof(pte)));
+	if (!pte_present(pte))
+		return 0;
+	pa = pte_pfn(pte) << PAGE_SHIFT;
+
+	return pa | (vaddr & ~PAGE_MASK);
+}
+
+/*
+ * Find a new area for the hypervisor supplied p2m list and relocate the p2m to
+ * this area.
+ */
+void __init xen_relocate_p2m(void)
+{
+	phys_addr_t size, new_area, pt_phys, pmd_phys, pud_phys;
+	unsigned long p2m_pfn, p2m_pfn_end, n_frames, pfn, pfn_end;
+	int n_pte, n_pt, n_pmd, n_pud, idx_pte, idx_pt, idx_pmd, idx_pud;
+	pte_t *pt;
+	pmd_t *pmd;
+	pud_t *pud;
+	pgd_t *pgd;
+	unsigned long *new_p2m;
+
+	size = PAGE_ALIGN(xen_start_info->nr_pages * sizeof(unsigned long));
+	n_pte = roundup(size, PAGE_SIZE) >> PAGE_SHIFT;
+	n_pt = roundup(size, PMD_SIZE) >> PMD_SHIFT;
+	n_pmd = roundup(size, PUD_SIZE) >> PUD_SHIFT;
+	n_pud = roundup(size, PGDIR_SIZE) >> PGDIR_SHIFT;
+	n_frames = n_pte + n_pt + n_pmd + n_pud;
+
+	new_area = xen_find_free_area(PFN_PHYS(n_frames));
+	if (!new_area) {
+		xen_raw_console_write("Can't find new memory area for p2m needed due to E820 map conflict\n");
+		BUG();
+	}
+
+	/*
+	 * Setup the page tables for addressing the new p2m list.
+	 * We have asked the hypervisor to map the p2m list at the user address
+	 * PUD_SIZE. It may have done so, or it may have used a kernel space
+	 * address depending on the Xen version.
+	 * To avoid any possible virtual address collision, just use
+	 * 2 * PUD_SIZE for the new area.
+	 */
+	pud_phys = new_area;
+	pmd_phys = pud_phys + PFN_PHYS(n_pud);
+	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
+	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
+
+	pgd = __va(read_cr3());
+	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
+	for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
+		pud = early_memremap(pud_phys, PAGE_SIZE);
+		clear_page(pud);
+		for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
+		     idx_pmd++) {
+			pmd = early_memremap(pmd_phys, PAGE_SIZE);
+			clear_page(pmd);
+			for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
+			     idx_pt++) {
+				pt = early_memremap(pt_phys, PAGE_SIZE);
+				clear_page(pt);
+				for (idx_pte = 0;
+				     idx_pte < min(n_pte, PTRS_PER_PTE);
+				     idx_pte++) {
+					set_pte(pt + idx_pte,
+						pfn_pte(p2m_pfn, PAGE_KERNEL));
+					p2m_pfn++;
+				}
+				n_pte -= PTRS_PER_PTE;
+				early_memunmap(pt, PAGE_SIZE);
+				make_lowmem_page_readonly(__va(pt_phys));
+				pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE,
+						  PFN_DOWN(pt_phys));
+				set_pmd(pmd + idx_pt,
+					__pmd(_PAGE_TABLE | pt_phys));
+				pt_phys += PAGE_SIZE;
+			}
+			n_pt -= PTRS_PER_PMD;
+			early_memunmap(pmd, PAGE_SIZE);
+			make_lowmem_page_readonly(__va(pmd_phys));
+			pin_pagetable_pfn(MMUEXT_PIN_L2_TABLE,
+					  PFN_DOWN(pmd_phys));
+			set_pud(pud + idx_pmd, __pud(_PAGE_TABLE | pmd_phys));
+			pmd_phys += PAGE_SIZE;
+		}
+		n_pmd -= PTRS_PER_PUD;
+		early_memunmap(pud, PAGE_SIZE);
+		make_lowmem_page_readonly(__va(pud_phys));
+		pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(pud_phys));
+		set_pgd(pgd + 2 + idx_pud, __pgd(_PAGE_TABLE | pud_phys));
+		pud_phys += PAGE_SIZE;
+	}
+
+	/* Now copy the old p2m info to the new area. */
+	memcpy(new_p2m, xen_p2m_addr, size);
+	xen_p2m_addr = new_p2m;
+
+	/* Release the old p2m list and set new list info. */
+	p2m_pfn = PFN_DOWN(xen_early_virt_to_phys(xen_start_info->mfn_list));
+	BUG_ON(!p2m_pfn);
+	p2m_pfn_end = p2m_pfn + PFN_DOWN(size);
+
+	if (xen_start_info->mfn_list < __START_KERNEL_map) {
+		pfn = xen_start_info->first_p2m_pfn;
+		pfn_end = xen_start_info->first_p2m_pfn +
+			  xen_start_info->nr_p2m_frames;
+		set_pgd(pgd + 1, __pgd(0));
+	} else {
+		pfn = p2m_pfn;
+		pfn_end = p2m_pfn_end;
+	}
+
+	memblock_free(PFN_PHYS(pfn), PAGE_SIZE * (pfn_end - pfn));
+	while (pfn < pfn_end) {
+		if (pfn == p2m_pfn) {
+			pfn = p2m_pfn_end;
+			continue;
+		}
+		make_lowmem_page_readwrite(__va(PFN_PHYS(pfn)));
+		pfn++;
+	}
+
+	xen_start_info->mfn_list = (unsigned long)xen_p2m_addr;
+	xen_start_info->first_p2m_pfn =  PFN_DOWN(new_area);
+	xen_start_info->nr_p2m_frames = n_frames;
+}
+
 #else	/* !CONFIG_X86_64 */
 static RESERVE_BRK_ARRAY(pmd_t, initial_kernel_pmd, PTRS_PER_PMD);
 static RESERVE_BRK_ARRAY(pmd_t, swapper_kernel_pmd, PTRS_PER_PMD);
@@ -2077,10 +2271,20 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 			  PFN_DOWN(__pa(initial_page_table)));
 	xen_write_cr3(__pa(initial_page_table));
 
-	xen_pt_base = __pa(xen_start_info->pt_base);
+	/*
+	 * The hypervisor supplied page tables are located just after the
+	 * start info page. For 32 bit domains xen_start_info->pt_base is the
+	 * pgd address which might be not the first page table in the page
+	 * table pool.
+	 * So to be sure to reserve all page tables use the knowledge that the
+	 * page tables are located just after the start info page (this is a
+	 * guaranteed interface).
+	 */
+	xen_pt_base = __pa(xen_start_info) + PAGE_SIZE;
 	xen_pt_size = xen_start_info->nr_pt_frames * PAGE_SIZE;
 
 	memblock_reserve(xen_pt_base, xen_pt_size);
+	memblock_reserve(__pa(xen_start_info), PAGE_SIZE);
 }
 #endif	/* CONFIG_X86_64 */
 
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 0d7f881..b096d02 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -663,37 +663,35 @@ static void __init xen_phys_memcpy(phys_addr_t dest, phys_addr_t src,
 
 /*
  * Reserve Xen mfn_list.
- * See comment above "struct start_info" in <xen/interface/xen.h>
- * We tried to make the the memblock_reserve more selective so
- * that it would be clear what region is reserved. Sadly we ran
- * in the problem wherein on a 64-bit hypervisor with a 32-bit
- * initial domain, the pt_base has the cr3 value which is not
- * neccessarily where the pagetable starts! As Jan put it: "
- * Actually, the adjustment turns out to be correct: The page
- * tables for a 32-on-64 dom0 get allocated in the order "first L1",
- * "first L2", "first L3", so the offset to the page table base is
- * indeed 2. When reading xen/include/public/xen.h's comment
- * very strictly, this is not a violation (since there nothing is said
- * that the first thing in the page table space is pointed to by
- * pt_base; I admit that this seems to be implied though, namely
- * do I think that it is implied that the page table space is the
- * range [pt_base, pt_base + nt_pt_frames), whereas that
- * range here indeed is [pt_base - 2, pt_base - 2 + nt_pt_frames),
- * which - without a priori knowledge - the kernel would have
- * difficulty to figure out)." - so lets just fall back to the
- * easy way and reserve the whole region.
  */
 static void __init xen_reserve_xen_mfnlist(void)
 {
+	phys_addr_t start, size;
+
 	if (xen_start_info->mfn_list >= __START_KERNEL_map) {
-		memblock_reserve(__pa(xen_start_info->mfn_list),
-				 xen_start_info->pt_base -
-				 xen_start_info->mfn_list);
+		start = __pa(xen_start_info->mfn_list);
+		size = PFN_ALIGN(xen_start_info->nr_pages *
+				 sizeof(unsigned long));
+	} else {
+		start = PFN_PHYS(xen_start_info->first_p2m_pfn);
+		size = PFN_PHYS(xen_start_info->nr_p2m_frames);
+	}
+
+	if (!xen_is_e820_reserved(start, size)) {
+		memblock_reserve(start, size);
 		return;
 	}
 
-	memblock_reserve(PFN_PHYS(xen_start_info->first_p2m_pfn),
-			 PFN_PHYS(xen_start_info->nr_p2m_frames));
+#ifdef CONFIG_X86_32
+	/*
+	 * Relocating the p2m on 32 bit system to an arbitrary virtual address
+	 * is not supported, so just give up.
+	 */
+	xen_raw_console_write("Xen hypervisor allocated p2m list conflicts with E820 map\n");
+	BUG();
+#else
+	xen_relocate_p2m();
+#endif
 }
 
 /**
@@ -895,7 +893,10 @@ char * __init xen_auto_xlated_memory_setup(void)
 		e820_add_region(xen_e820_map[i].addr, xen_e820_map[i].size,
 				xen_e820_map[i].type);
 
-	xen_reserve_xen_mfnlist();
+	/* Remove p2m info, it is not needed. */
+	xen_start_info->mfn_list = 0;
+	xen_start_info->first_p2m_pfn = 0;
+	xen_start_info->nr_p2m_frames = 0;
 
 	return "Xen";
 }
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index 553abd8..a489c79 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -39,6 +39,9 @@ void __init xen_pt_check_e820(void);
 
 void xen_mm_pin_all(void);
 void xen_mm_unpin_all(void);
+#ifdef CONFIG_X86_64
+void __init xen_relocate_p2m(void);
+#endif
 
 bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size);
 unsigned long __ref xen_chk_extra_mem(unsigned long pfn);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
