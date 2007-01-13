From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:20 +1100
Message-Id: <20070113024820.29682.89721.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 1/5] Introduce IA64 page table interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH IA64 01
 * Create /include/asm-ia64/pt.h and define IA64 page table interface.
   * This file is for including various implementations of page table.
   At the moment, just the default page table.
 * Create /include/asm-ia64/pt-default.h and place abstracted page table
 dependendent functions (for IA64) in there.
 * Call create_kernel_page_table in arch-ia64/kernel/setup.c (which does
 nothing for the current page table implementation, but may do for others).
 * Make implementation independent call to lookup the kernel page table in
 /arch/ia64/mm/fault.c
 * Call implementation independent build and lookup functions in
 /arch/ia64/mm/init.c.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/kernel/setup.c      |    2 
 arch/ia64/mm/fault.c          |   19 +------
 arch/ia64/mm/init.c           |   59 ++--------------------
 include/asm-ia64/pt-default.h |  112 ++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/pt.h         |   16 ++++++
 5 files changed, 140 insertions(+), 68 deletions(-)
Index: linux-2.6.20-rc1/include/asm-ia64/pt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pt.h	2006-12-23 20:55:49.287909000 +1100
@@ -0,0 +1,16 @@
+#ifndef _ASM_IA64_PT_H
+#define _ASM_IA64_PT_H 1
+
+#ifdef CONFIG_PT_DEFAULT
+#include <asm/pt-default.h>
+#endif
+
+void create_kernel_page_table(void);
+
+pte_t *build_page_table_k(unsigned long address);
+
+pte_t *build_page_table_k_bootmem(unsigned long address, int _node);
+
+pte_t *lookup_page_table_k(unsigned long address);
+
+#endif
Index: linux-2.6.20-rc1/include/asm-ia64/pt-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pt-default.h	2006-12-23 20:55:19.759909000 +1100
@@ -0,0 +1,112 @@
+#ifndef _ASM_IA64_PT_DEFAULT_H
+#define _ASM_IA64_PT_DEFAULT_H 1
+
+#include <linux/bootmem.h>
+#include <asm/pgalloc.h>
+
+
+/* Create kernel page table */
+static inline void create_kernel_page_table(void) {}
+
+/* Lookup the kernel page table */
+static inline pte_t *lookup_page_table_k(unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+
+	pgd = pgd_offset_k(address);
+	if (pgd_none(*pgd) || pgd_bad(*pgd))
+		return 0;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || pud_bad(*pud))
+		return 0;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || pmd_bad(*pmd))
+		return 0;
+
+	ptep = pte_offset_kernel(pmd, address);
+
+	return ptep;
+}
+
+static inline pte_t *lookup_page_table_k2(unsigned long *end_address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_k(*end_address);
+	if (pgd_none(*pgd)) {
+		*end_address += PGDIR_SIZE;
+		return NULL;
+	}
+
+	pud = pud_offset(pgd, *end_address);
+	if (pud_none(*pud)) {
+		*end_address += PUD_SIZE;
+		return NULL;
+	}
+
+	pmd = pmd_offset(pud, *end_address);
+	if (pmd_none(*pmd)) {
+		*end_address += PMD_SIZE;
+		return NULL;
+	}
+
+	return pte_offset_kernel(pmd, *end_address);
+}
+
+/* Build the kernel page table */
+static inline pte_t *build_page_table_k(unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_k(address);		/* note: this is NOT pgd_offset()! */
+
+	pud = pud_alloc(&init_mm, pgd, address);
+	if (!pud)
+		return NULL;
+	pmd = pmd_alloc(&init_mm, pud, address);
+	if (!pmd)
+		return NULL;
+
+	return  pte_alloc_kernel(pmd, address);
+}
+
+/* Builds the kernel page table from bootmem (before kernel memory allocation
+ * comes on line) */
+static inline pte_t *build_page_table_k_bootmem(unsigned long address, int _node)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	int node= _node;
+
+	pgd = pgd_offset_k(address);
+	if (pgd_none(*pgd))
+		pgd_populate(&init_mm, pgd,
+			     alloc_bootmem_pages_node(
+				     NODE_DATA(node), PAGE_SIZE));
+	pud = pud_offset(pgd, address);
+
+	if (pud_none(*pud))
+		pud_populate(&init_mm, pud,
+			     alloc_bootmem_pages_node(
+				     NODE_DATA(node), PAGE_SIZE));
+	pmd = pmd_offset(pud, address);
+
+	if (pmd_none(*pmd))
+		pmd_populate_kernel(&init_mm, pmd,
+				    alloc_bootmem_pages_node(
+					    NODE_DATA(node), PAGE_SIZE));
+	return pte_offset_kernel(pmd, address);
+}
+
+
+#endif /* !_PT_DEFAULT_H */
Index: linux-2.6.20-rc1/arch/ia64/kernel/setup.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/kernel/setup.c	2006-12-23 20:55:06.603909000 +1100
+++ linux-2.6.20-rc1/arch/ia64/kernel/setup.c	2006-12-23 20:55:19.763909000 +1100
@@ -61,6 +61,7 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 #include <asm/system.h>
+#include <asm/pt.h>
 
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
@@ -545,6 +546,7 @@
 		ia64_mca_init();
 
 	platform_setup(cmdline_p);
+	create_kernel_page_table();
 	paging_init();
 }
 
Index: linux-2.6.20-rc1/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/mm/fault.c	2006-12-23 20:55:06.603909000 +1100
+++ linux-2.6.20-rc1/arch/ia64/mm/fault.c	2006-12-23 20:55:19.763909000 +1100
@@ -16,6 +16,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/kdebug.h>
+#include <asm/pt.h>
 
 extern void die (char *, struct pt_regs *, long);
 
@@ -57,27 +58,13 @@
  * Return TRUE if ADDRESS points at a page in the kernel's mapped segment
  * (inside region 5, on ia64) and that page is present.
  */
+
 static int
 mapped_kernel_page_is_present (unsigned long address)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *ptep, pte;
 
-	pgd = pgd_offset_k(address);
-	if (pgd_none(*pgd) || pgd_bad(*pgd))
-		return 0;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || pud_bad(*pud))
-		return 0;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return 0;
-
-	ptep = pte_offset_kernel(pmd, address);
+	ptep = lookup_page_table_k(address);
 	if (!ptep)
 		return 0;
 
Index: linux-2.6.20-rc1/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/mm/init.c	2006-12-23 20:55:06.603909000 +1100
+++ linux-2.6.20-rc1/arch/ia64/mm/init.c	2006-12-23 20:55:19.763909000 +1100
@@ -35,6 +35,7 @@
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
 #include <asm/mca.h>
+#include <asm/pt.h>
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
@@ -269,25 +270,14 @@
 static struct page * __init
 put_kernel_page (struct page *page, unsigned long address, pgprot_t pgprot)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
 
 	if (!PageReserved(page))
 		printk(KERN_ERR "put_kernel_page: page at 0x%p not in reserved memory\n",
 		       page_address(page));
 
-	pgd = pgd_offset_k(address);		/* note: this is NOT pgd_offset()! */
-
 	{
-		pud = pud_alloc(&init_mm, pgd, address);
-		if (!pud)
-			goto out;
-		pmd = pmd_alloc(&init_mm, pud, address);
-		if (!pmd)
-			goto out;
-		pte = pte_alloc_kernel(pmd, address);
+		pte = build_page_table_k(address);
 		if (!pte)
 			goto out;
 		if (!pte_none(*pte))
@@ -428,30 +418,9 @@
 		pgdat->node_start_pfn + pgdat->node_spanned_pages];
 
 	do {
-		pgd_t *pgd;
-		pud_t *pud;
-		pmd_t *pmd;
 		pte_t *pte;
 
-		pgd = pgd_offset_k(end_address);
-		if (pgd_none(*pgd)) {
-			end_address += PGDIR_SIZE;
-			continue;
-		}
-
-		pud = pud_offset(pgd, end_address);
-		if (pud_none(*pud)) {
-			end_address += PUD_SIZE;
-			continue;
-		}
-
-		pmd = pmd_offset(pud, end_address);
-		if (pmd_none(*pmd)) {
-			end_address += PMD_SIZE;
-			continue;
-		}
-
-		pte = pte_offset_kernel(pmd, end_address);
+		pte = lookup_page_table_k2(&end_address);
 retry_pte:
 		if (pte_none(*pte)) {
 			end_address += PAGE_SIZE;
@@ -477,9 +446,6 @@
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
 	int node;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
 
 	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
@@ -489,23 +455,12 @@
 	end_page = PAGE_ALIGN((unsigned long) map_end);
 	node = paddr_to_nid(__pa(start));
 
+	printk("MEMMAP\n");
 	for (address = start_page; address < end_page; address += PAGE_SIZE) {
-		pgd = pgd_offset_k(address);
-		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pud = pud_offset(pgd, address);
-
-		if (pud_none(*pud))
-			pud_populate(&init_mm, pud, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pmd = pmd_offset(pud, address);
-
-		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pte = pte_offset_kernel(pmd, address);
-
+		pte = build_page_table_k_bootmem(address, node);
 		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
-					     PAGE_KERNEL));
+			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node),
+				PAGE_SIZE)) >> PAGE_SHIFT, PAGE_KERNEL));
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
