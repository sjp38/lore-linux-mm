Date: Wed, 24 Jul 2002 19:24:19 +0300
From: Dan Aloni <da-x@gmx.net>
Subject: [PATCH 2.5] arch/i386/mm/init.c
Message-ID: <20020724162419.GA6473@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This pulls the dust out of init.c, with cleanups, refactoring, 
comments, etc... 

Currently, it only covers the pieces of code which I understood. It's
amazing how much you can learn just from cleaning another people's code.

In this patch: 
 + change a few printk's to BUG()s.
 + inlining set_pte_phys is not needed.
 + reduce code duplication: refactor one_page_table_init() and 
   one_md_table_init() out of fixrange_init(), and later out of pagetable_init(). 
 + fixrange_init() is be really named page_table_range_init(). It has no code specific to
   fixmaps so it shouldn't be prefixed with it.
 + refactor kernel_physical_mapping_init out of pagetable_init(), because it's 
   a complex task that can be done seperately.
 + 0x1 is really _PAGE_PRESENT in 'set_pgd(pgd, __pgd(__pa(pmd) + 0x1));'.
 + also, set_pmd(pmd, __pmd(_KERNPG_TABLE + __pa(pte))) should be:
   set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE)).  

BTW, it's more a functionality change than a cleanup, but I think it will be healthy 
to set the entries of swapper_pg_dir to the zero page also in non-PAE compilation mode. 
Am I right?

Comments welcomed.

--- init.c.pcs	2002-07-21 07:03:19.000000000 +0300
+++ init.c	2002-07-24 19:18:59.000000000 +0300
@@ -100,8 +100,8 @@
 extern char _text, _etext, _edata, __bss_start, _end;
 extern char __init_begin, __init_end;
 
-static inline void set_pte_phys (unsigned long vaddr,
-			unsigned long phys, pgprot_t flags)
+
+static void set_pte_phys (unsigned long vaddr, unsigned long phys, pgprot_t flags)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -109,12 +109,12 @@
 
 	pgd = swapper_pg_dir + __pgd_offset(vaddr);
 	if (pgd_none(*pgd)) {
-		printk("PAE BUG #00!\n");
+		BUG();
 		return;
 	}
 	pmd = pmd_offset(pgd, vaddr);
 	if (pmd_none(*pmd)) {
-		printk("PAE BUG #01!\n");
+		BUG();
 		return;
 	}
 	pte = pte_offset_kernel(pmd, vaddr);
@@ -133,112 +133,153 @@
 	unsigned long address = __fix_to_virt(idx);
 
 	if (idx >= __end_of_fixed_addresses) {
-		printk("Invalid __set_fixmap\n");
+		BUG();
 		return;
 	}
 	set_pte_phys(address, phys, flags);
 }
 
-static void __init fixrange_init (unsigned long start, unsigned long end, pgd_t *pgd_base)
+/*
+ * Creates a middle page table and put a pointer to it in the
+ * given global directory entry. This only returns the gd entry
+ * in non-PAE compilation mode, since the middle layer is folded.
+ */
+static pmd_t * __init one_md_table_init(pgd_t *pgd_entry)
+{
+	pmd_t *md_table;
+		
+#if CONFIG_X86_PAE
+	md_table = (pmd_t *) alloc_bootmem_low_pages(PAGE_SIZE);
+	set_pgd(pgd_entry, __pgd(__pa(md_table) | _PAGE_PRESENT));
+	if (md_table != pmd_offset(pgd_entry, 0)) 
+		BUG();
+#else
+	md_table = pmd_offset(pgd_entry, 0);
+#endif
+
+	return md_table;
+}
+
+/*
+ * Create a page table and place a pointer to it in a middle page
+ * directory entry.
+ */
+static pte_t * __init one_page_table_init(pmd_t *pmd)
+{
+	pte_t *page_table = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
+	set_pmd(pmd, __pmd(__pa(page_table) | _KERNPG_TABLE));
+	if (page_table != pte_offset_kernel(pmd, 0))
+		BUG();	
+
+	return page_table;
+}
+
+/*
+ * This function initializes a certain range of kernel virtual memory 
+ * with new bootmem page tables, everywhere page tables are missing in
+ * the given range.
+ */
+static void __init page_table_range_init (unsigned long start, unsigned long end, pgd_t *pgd_base)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
-	pte_t *pte;
-	int i, j;
+	int pgd_ofs, pmd_ofs;
 	unsigned long vaddr;
 
 	vaddr = start;
-	i = __pgd_offset(vaddr);
-	j = __pmd_offset(vaddr);
-	pgd = pgd_base + i;
+	pgd_ofs = __pgd_offset(vaddr);
+	pmd_ofs = __pmd_offset(vaddr);
+	pgd = pgd_base + pgd_ofs;
+
+	for ( ; (pgd_ofs < PTRS_PER_PGD) && (vaddr != end); pgd++, pgd_ofs++) {
+		if (pgd_none(*pgd)) 
+			one_md_table_init(pgd);
 
-	for ( ; (i < PTRS_PER_PGD) && (vaddr != end); pgd++, i++) {
-#if CONFIG_X86_PAE
-		if (pgd_none(*pgd)) {
-			pmd = (pmd_t *) alloc_bootmem_low_pages(PAGE_SIZE);
-			set_pgd(pgd, __pgd(__pa(pmd) + 0x1));
-			if (pmd != pmd_offset(pgd, 0))
-				printk("PAE BUG #02!\n");
-		}
 		pmd = pmd_offset(pgd, vaddr);
-#else
-		pmd = (pmd_t *)pgd;
-#endif
-		for (; (j < PTRS_PER_PMD) && (vaddr != end); pmd++, j++) {
-			if (pmd_none(*pmd)) {
-				pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
-				set_pmd(pmd, __pmd(_KERNPG_TABLE + __pa(pte)));
-				if (pte != pte_offset_kernel(pmd, 0))
-					BUG();
-			}
+		for (; (pmd_ofs < PTRS_PER_PMD) && (vaddr != end); pmd++, pmd_ofs++) {
+			if (pmd_none(*pmd)) 
+				one_page_table_init(pmd);
+
 			vaddr += PMD_SIZE;
 		}
-		j = 0;
+		pmd_ofs = 0;
 	}
 }
 
+/*
+ * This maps physical memory to kernel virtual address space, a total of
+ * max_low_pfn pages, by creating page tables starting from address 
+ * PAGE_OFFSET.
+ */
+static void __init kernel_physical_mapping_init(pgd_t *pgd_base)
+{
+	unsigned long pfn;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	int pgd_ofs, pmd_ofs, pte_ofs;
+
+	pgd_ofs = __pgd_offset(PAGE_OFFSET);
+	pgd = pgd_base + pgd_ofs;
+	pfn = 0;
+
+	for (; pgd_ofs < PTRS_PER_PGD && pfn < max_low_pfn; pgd++, pgd_ofs++) {
+		pmd = one_md_table_init(pgd);
+		for (pmd_ofs = 0; pmd_ofs < PTRS_PER_PMD && pfn < max_low_pfn; pmd++, pmd_ofs++) {
+			/* Map with big pages if possible, otherwise create normal page tables. */
+			if (cpu_has_pse) {
+				set_pmd(pmd, pfn_pmd(pfn, PAGE_KERNEL_LARGE));
+				pfn += PTRS_PER_PTE;
+			} else {
+				pte = one_page_table_init(pmd);
+
+				for (pte_ofs = 0; pte_ofs < PTRS_PER_PTE && pfn < max_low_pfn; pte++, pfn++, pte_ofs++)
+					set_pte(pte, pfn_pte(pfn, PAGE_KERNEL));
+			}
+		}
+	}	
+}
+
 unsigned long __PAGE_KERNEL = _PAGE_KERNEL;
 
 static void __init pagetable_init (void)
 {
-	unsigned long vaddr, pfn;
-	pgd_t *pgd, *pgd_base;
-	int i, j, k;
-	pmd_t *pmd;
-	pte_t *pte, *pte_base;
+	unsigned long vaddr;
+	pgd_t *pgd_base = swapper_pg_dir;
+	int i;
 
-	pgd_base = swapper_pg_dir;
 #if CONFIG_X86_PAE
+	/* Init entries of the first-level page table to the zero page */
 	for (i = 0; i < PTRS_PER_PGD; i++)
 		set_pgd(pgd_base + i, __pgd(__pa(empty_zero_page) | _PAGE_PRESENT));
 #endif
+
+	/* Enable PSE if available */
 	if (cpu_has_pse) {
 		set_in_cr4(X86_CR4_PSE);
 	}
+
+	/* Enable PGE if available */
 	if (cpu_has_pge) {
 		set_in_cr4(X86_CR4_PGE);
 		__PAGE_KERNEL |= _PAGE_GLOBAL;
 	}
 
-	i = __pgd_offset(PAGE_OFFSET);
-	pfn = 0;
-	pgd = pgd_base + i;
-
-	for (; i < PTRS_PER_PGD && pfn < max_low_pfn; pgd++, i++) {
-#if CONFIG_X86_PAE
-		pmd = (pmd_t *) alloc_bootmem_low_pages(PAGE_SIZE);
-		set_pgd(pgd, __pgd(__pa(pmd) | _PAGE_PRESENT));
-#else
-		pmd = (pmd_t *) pgd;
-#endif
-		for (j = 0; j < PTRS_PER_PMD && pfn < max_low_pfn; pmd++, j++) {
-			if (cpu_has_pse) {
-				set_pmd(pmd, pfn_pmd(pfn, PAGE_KERNEL_LARGE));
-				pfn += PTRS_PER_PTE;
-			} else {
-				pte_base = pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
-
-				for (k = 0; k < PTRS_PER_PTE && pfn < max_low_pfn; pte++, pfn++, k++)
-					set_pte(pte, pfn_pte(pfn, PAGE_KERNEL));
-
-				set_pmd(pmd, __pmd(__pa(pte_base) | _KERNPG_TABLE));
-			}
-		}
-	}
+	kernel_physical_mapping_init(pgd_base);
 
 	/*
 	 * Fixed mappings, only the page table structure has to be
 	 * created - mappings will be set by set_fixmap():
 	 */
 	vaddr = __fix_to_virt(__end_of_fixed_addresses - 1) & PMD_MASK;
-	fixrange_init(vaddr, 0, pgd_base);
+	page_table_range_init(vaddr, 0, pgd_base);
 
 #if CONFIG_HIGHMEM
 	/*
 	 * Permanent kmaps:
 	 */
 	vaddr = PKMAP_BASE;
-	fixrange_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
+	page_table_range_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
 
 	pgd = swapper_pg_dir + __pgd_offset(vaddr);
 	pmd = pmd_offset(pgd, vaddr);


-- 
Dan Aloni
da-x@gmx.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
