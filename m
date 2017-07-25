Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEF076B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:06:37 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c14so176980227pgn.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:06:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s10si8020387pge.267.2017.07.25.02.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 02:06:36 -0700 (PDT)
Date: Tue, 25 Jul 2017 12:05:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
> Xen PV guests will never run with 5-level-paging enabled. So I guess you
> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.

There is more code to drop from mmu_pv.c.

But while there, I thought if with boot-time 5-level paging switching we
can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
can be used in these XEN modes with 4-level paging.

Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
modes?

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 7ebb56e99389..6d67d3530698 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,12 +37,12 @@
  *
  */
 
+#define l4_index(x)	(((x) >> P4D_SHIFT) & 511)
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
-#if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
-PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE48)
-PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
-#endif
+L4_PAGE_OFFSET = l4_index(__PAGE_OFFSET_BASE48)
+L4_START_KERNEL = l4_index(__START_KERNEL_map)
+
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
@@ -347,9 +347,9 @@ NEXT_PAGE(early_dynamic_pgts)
 #if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
 NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
+	.org    init_top_pgt + L4_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_top_pgt + PGD_START_KERNEL*8, 0
+	.org    init_top_pgt + L4_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
 
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 1ecd419811a2..027987638e98 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -17,9 +17,6 @@ config XEN_PV
 	bool "Xen PV guest support"
 	default y
 	depends on XEN
-	# XEN_PV is not ready to work with 5-level paging.
-	# Changes to hypervisor are also required.
-	depends on !X86_5LEVEL
 	select XEN_HAVE_PVMMU
 	select XEN_HAVE_VPMU
 	help
@@ -78,6 +75,4 @@ config XEN_DEBUG_FS
 config XEN_PVH
 	bool "Support for running as a PVH guest"
 	depends on XEN && XEN_PVHVM && ACPI
-	# Pre-built page tables are not ready to handle 5-level paging.
-	depends on !X86_5LEVEL
 	def_bool n
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index b0530184c637..3116649302f2 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -469,7 +469,7 @@ __visible pmd_t xen_make_pmd(pmdval_t pmd)
 }
 PV_CALLEE_SAVE_REGS_THUNK(xen_make_pmd);
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#ifdef CONFIG_X86_64
 __visible pudval_t xen_pud_val(pud_t pud)
 {
 	return pte_mfn_to_pfn(pud.pud);
@@ -558,7 +558,7 @@ static void xen_set_p4d(p4d_t *ptr, p4d_t val)
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 }
-#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
+#endif	/* CONFIG_X86_64 */
 
 static int xen_pmd_walk(struct mm_struct *mm, pmd_t *pmd,
 		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
@@ -600,21 +600,17 @@ static int xen_p4d_walk(struct mm_struct *mm, p4d_t *p4d,
 		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
 		bool last, unsigned long limit)
 {
-	int i, nr, flush = 0;
+	int flush = 0;
+	pud_t *pud;
 
-	nr = last ? p4d_index(limit) + 1 : PTRS_PER_P4D;
-	for (i = 0; i < nr; i++) {
-		pud_t *pud;
 
-		if (p4d_none(p4d[i]))
-			continue;
+	if (p4d_none(*p4d))
+		return flush;
 
-		pud = pud_offset(&p4d[i], 0);
-		if (PTRS_PER_PUD > 1)
-			flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
-		flush |= xen_pud_walk(mm, pud, func,
-				last && i == nr - 1, limit);
-	}
+	pud = pud_offset(p4d, 0);
+	if (PTRS_PER_PUD > 1)
+		flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
+	flush |= xen_pud_walk(mm, pud, func, last, limit);
 	return flush;
 }
 
@@ -664,8 +660,6 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 			continue;
 
 		p4d = p4d_offset(&pgd[i], 0);
-		if (PTRS_PER_P4D > 1)
-			flush |= (*func)(mm, virt_to_page(p4d), PT_P4D);
 		flush |= xen_p4d_walk(mm, p4d, func, i == nr - 1, limit);
 	}
 
@@ -1197,22 +1191,14 @@ static void __init xen_cleanmfnmap(unsigned long vaddr)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
-	unsigned int i;
 	bool unpin;
 
 	unpin = (vaddr == 2 * PGDIR_SIZE);
 	vaddr &= PMD_MASK;
 	pgd = pgd_offset_k(vaddr);
 	p4d = p4d_offset(pgd, 0);
-	for (i = 0; i < PTRS_PER_P4D; i++) {
-		if (p4d_none(p4d[i]))
-			continue;
-		xen_cleanmfnmap_p4d(p4d + i, unpin);
-	}
-	if (!p4d_folded) {
-		set_pgd(pgd, __pgd(0));
-		xen_cleanmfnmap_free_pgtbl(p4d, unpin);
-	}
+	if (!p4d_none(*p4d))
+		xen_cleanmfnmap_p4d(p4d, unpin);
 }
 
 static void __init xen_pagetable_p2m_free(void)
@@ -1718,7 +1704,7 @@ static void xen_release_pmd(unsigned long pfn)
 	xen_release_ptpage(pfn, PT_PMD);
 }
 
-#if CONFIG_PGTABLE_LEVELS >= 4
+#ifdef CONFIG_X86_64
 static void xen_alloc_pud(struct mm_struct *mm, unsigned long pfn)
 {
 	xen_alloc_ptpage(mm, pfn, PT_PUD);
@@ -2055,13 +2041,12 @@ static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
  */
 void __init xen_relocate_p2m(void)
 {
-	phys_addr_t size, new_area, pt_phys, pmd_phys, pud_phys, p4d_phys;
+	phys_addr_t size, new_area, pt_phys, pmd_phys, pud_phys;
 	unsigned long p2m_pfn, p2m_pfn_end, n_frames, pfn, pfn_end;
-	int n_pte, n_pt, n_pmd, n_pud, n_p4d, idx_pte, idx_pt, idx_pmd, idx_pud, idx_p4d;
+	int n_pte, n_pt, n_pmd, n_pud, idx_pte, idx_pt, idx_pmd, idx_pud;
 	pte_t *pt;
 	pmd_t *pmd;
 	pud_t *pud;
-	p4d_t *p4d = NULL;
 	pgd_t *pgd;
 	unsigned long *new_p2m;
 	int save_pud;
@@ -2071,11 +2056,7 @@ void __init xen_relocate_p2m(void)
 	n_pt = roundup(size, PMD_SIZE) >> PMD_SHIFT;
 	n_pmd = roundup(size, PUD_SIZE) >> PUD_SHIFT;
 	n_pud = roundup(size, P4D_SIZE) >> P4D_SHIFT;
-	if (PTRS_PER_P4D > 1)
-		n_p4d = roundup(size, PGDIR_SIZE) >> PGDIR_SHIFT;
-	else
-		n_p4d = 0;
-	n_frames = n_pte + n_pt + n_pmd + n_pud + n_p4d;
+	n_frames = n_pte + n_pt + n_pmd + n_pud;
 
 	new_area = xen_find_free_area(PFN_PHYS(n_frames));
 	if (!new_area) {
@@ -2091,76 +2072,56 @@ void __init xen_relocate_p2m(void)
 	 * To avoid any possible virtual address collision, just use
 	 * 2 * PUD_SIZE for the new area.
 	 */
-	p4d_phys = new_area;
-	pud_phys = p4d_phys + PFN_PHYS(n_p4d);
+	pud_phys = new_area;
 	pmd_phys = pud_phys + PFN_PHYS(n_pud);
 	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
 	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
 
 	pgd = __va(read_cr3_pa());
 	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
-	idx_p4d = 0;
 	save_pud = n_pud;
-	do {
-		if (n_p4d > 0) {
-			p4d = early_memremap(p4d_phys, PAGE_SIZE);
-			clear_page(p4d);
-			n_pud = min(save_pud, PTRS_PER_P4D);
-		}
-		for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
-			pud = early_memremap(pud_phys, PAGE_SIZE);
-			clear_page(pud);
-			for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
-				 idx_pmd++) {
-				pmd = early_memremap(pmd_phys, PAGE_SIZE);
-				clear_page(pmd);
-				for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
-					 idx_pt++) {
-					pt = early_memremap(pt_phys, PAGE_SIZE);
-					clear_page(pt);
-					for (idx_pte = 0;
-						 idx_pte < min(n_pte, PTRS_PER_PTE);
-						 idx_pte++) {
-						set_pte(pt + idx_pte,
-								pfn_pte(p2m_pfn, PAGE_KERNEL));
-						p2m_pfn++;
-					}
-					n_pte -= PTRS_PER_PTE;
-					early_memunmap(pt, PAGE_SIZE);
-					make_lowmem_page_readonly(__va(pt_phys));
-					pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE,
-							PFN_DOWN(pt_phys));
-					set_pmd(pmd + idx_pt,
-							__pmd(_PAGE_TABLE | pt_phys));
-					pt_phys += PAGE_SIZE;
+	for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
+		pud = early_memremap(pud_phys, PAGE_SIZE);
+		clear_page(pud);
+		for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
+				idx_pmd++) {
+			pmd = early_memremap(pmd_phys, PAGE_SIZE);
+			clear_page(pmd);
+			for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
+					idx_pt++) {
+				pt = early_memremap(pt_phys, PAGE_SIZE);
+				clear_page(pt);
+				for (idx_pte = 0;
+						idx_pte < min(n_pte, PTRS_PER_PTE);
+						idx_pte++) {
+					set_pte(pt + idx_pte,
+							pfn_pte(p2m_pfn, PAGE_KERNEL));
+					p2m_pfn++;
 				}
-				n_pt -= PTRS_PER_PMD;
-				early_memunmap(pmd, PAGE_SIZE);
-				make_lowmem_page_readonly(__va(pmd_phys));
-				pin_pagetable_pfn(MMUEXT_PIN_L2_TABLE,
-						PFN_DOWN(pmd_phys));
-				set_pud(pud + idx_pmd, __pud(_PAGE_TABLE | pmd_phys));
-				pmd_phys += PAGE_SIZE;
+				n_pte -= PTRS_PER_PTE;
+				early_memunmap(pt, PAGE_SIZE);
+				make_lowmem_page_readonly(__va(pt_phys));
+				pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE,
+						PFN_DOWN(pt_phys));
+				set_pmd(pmd + idx_pt,
+						__pmd(_PAGE_TABLE | pt_phys));
+				pt_phys += PAGE_SIZE;
 			}
-			n_pmd -= PTRS_PER_PUD;
-			early_memunmap(pud, PAGE_SIZE);
-			make_lowmem_page_readonly(__va(pud_phys));
-			pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(pud_phys));
-			if (n_p4d > 0)
-				set_p4d(p4d + idx_pud, __p4d(_PAGE_TABLE | pud_phys));
-			else
-				set_pgd(pgd + 2 + idx_pud, __pgd(_PAGE_TABLE | pud_phys));
-			pud_phys += PAGE_SIZE;
-		}
-		if (n_p4d > 0) {
-			save_pud -= PTRS_PER_P4D;
-			early_memunmap(p4d, PAGE_SIZE);
-			make_lowmem_page_readonly(__va(p4d_phys));
-			pin_pagetable_pfn(MMUEXT_PIN_L4_TABLE, PFN_DOWN(p4d_phys));
-			set_pgd(pgd + 2 + idx_p4d, __pgd(_PAGE_TABLE | p4d_phys));
-			p4d_phys += PAGE_SIZE;
+			n_pt -= PTRS_PER_PMD;
+			early_memunmap(pmd, PAGE_SIZE);
+			make_lowmem_page_readonly(__va(pmd_phys));
+			pin_pagetable_pfn(MMUEXT_PIN_L2_TABLE,
+					PFN_DOWN(pmd_phys));
+			set_pud(pud + idx_pmd, __pud(_PAGE_TABLE | pmd_phys));
+			pmd_phys += PAGE_SIZE;
 		}
-	} while (++idx_p4d < n_p4d);
+		n_pmd -= PTRS_PER_PUD;
+		early_memunmap(pud, PAGE_SIZE);
+		make_lowmem_page_readonly(__va(pud_phys));
+		pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(pud_phys));
+		set_pgd(pgd + 2 + idx_pud, __pgd(_PAGE_TABLE | pud_phys));
+		pud_phys += PAGE_SIZE;
+	}
 
 	/* Now copy the old p2m info to the new area. */
 	memcpy(new_p2m, xen_p2m_addr, size);
@@ -2387,7 +2348,7 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.set_pte = xen_set_pte;
 	pv_mmu_ops.set_pmd = xen_set_pmd;
 	pv_mmu_ops.set_pud = xen_set_pud;
-#if CONFIG_PGTABLE_LEVELS >= 4
+#ifdef CONFIG_X86_64
 	pv_mmu_ops.set_p4d = xen_set_p4d;
 #endif
 
@@ -2397,7 +2358,7 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.alloc_pmd = xen_alloc_pmd;
 	pv_mmu_ops.release_pte = xen_release_pte;
 	pv_mmu_ops.release_pmd = xen_release_pmd;
-#if CONFIG_PGTABLE_LEVELS >= 4
+#ifdef CONFIG_X86_64
 	pv_mmu_ops.alloc_pud = xen_alloc_pud;
 	pv_mmu_ops.release_pud = xen_release_pud;
 #endif
@@ -2463,14 +2424,14 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 	.make_pmd = PV_CALLEE_SAVE(xen_make_pmd),
 	.pmd_val = PV_CALLEE_SAVE(xen_pmd_val),
 
-#if CONFIG_PGTABLE_LEVELS >= 4
+#ifdef CONFIG_X86_64
 	.pud_val = PV_CALLEE_SAVE(xen_pud_val),
 	.make_pud = PV_CALLEE_SAVE(xen_make_pud),
 	.set_p4d = xen_set_p4d_hyper,
 
 	.alloc_pud = xen_alloc_pmd_init,
 	.release_pud = xen_release_pmd_init,
-#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
+#endif	/* CONFIG_X86_64 */
 
 	.activate_mm = xen_activate_mm,
 	.dup_mmap = xen_dup_mmap,
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
