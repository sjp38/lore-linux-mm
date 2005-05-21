From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 15:09:56 +1000 (EST)
Subject: [PATCH 13/15] PTI: Add files and IA64 part of interface
In-Reply-To: <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211506080.8979@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 13 of 15.

This patch adds the new files required by the IA64 architecture
to achieve a trully independent page table interface.  Architectures
other that IA64 also require an architecture dependent interface
component to achieve a trully indepenent page table interface.

 	*The architecture dependent interface is to go in
 	 include/asm-ia64/mlpt.h  This will be hooked into the general
 	 page table interface.
 	*mlpt specific code in include/asm-ia64/pgtable.h is to be
 	 abstracted to include/asm-ia64/pgtable-mlpt.h.
 	*mlpt specific code for the ia64 architecture is to be shifted
 	 behind the interface into mlpt-ia64.c.

  arch/ia64/mm/Makefile               |    2
  arch/ia64/mm/fixed-mlpt/Makefile    |    5 +
  arch/ia64/mm/fixed-mlpt/mlpt-ia64.c |    1
  include/asm-ia64/mlpt.h             |  108 
++++++++++++++++++++++++++++++++++++
  include/asm-ia64/pgtable-mlpt.h     |    5 +
  include/asm-ia64/pgtable.h          |    7 ++
  6 files changed, 128 insertions(+)

Index: linux-2.6.12-rc4/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-ia64/pgtable.h	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-ia64/pgtable.h	2005-05-19 
18:32:00.000000000 +1000
@@ -20,6 +20,10 @@
  #include <asm/system.h>
  #include <asm/types.h>

+#ifdef CONFIG_MLPT
+#include <asm/pgtable-mlpt.h>
+#endif
+
  #define IA64_MAX_PHYS_BITS	50	/* max. number of physical address 
bits (architected) */

  /*
@@ -561,7 +565,10 @@
  #define __HAVE_ARCH_PGD_OFFSET_GATE
  #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE

+#ifdef CONFIG_MLPT
  #include <asm-generic/pgtable-nopud.h>
+#endif
+
  #include <asm-generic/pgtable.h>

  #endif /* _ASM_IA64_PGTABLE_H */
Index: linux-2.6.12-rc4/include/asm-ia64/pgtable-mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/asm-ia64/pgtable-mlpt.h	2005-05-19 
18:32:00.000000000 +1000
@@ -0,0 +1,5 @@
+#ifndef ASM_IA64_PGTABLE_MLPT_H
+#define ASM_IA64_PGTABLE_MLPT_H 1
+
+#endif
+
Index: linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/mlpt-ia64.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/mlpt-ia64.c	2005-05-19 
18:32:00.000000000 +1000
@@ -0,0 +1 @@
+
Index: linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/Makefile	2005-05-19 
18:32:00.000000000 +1000
@@ -0,0 +1,5 @@
+#
+# Makefile
+#
+
+obj-y := mlpt-ia64.o
Index: linux-2.6.12-rc4/arch/ia64/mm/Makefile
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/Makefile	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/Makefile	2005-05-19 
18:32:00.000000000 +1000
@@ -4,6 +4,8 @@

  obj-y := init.o fault.o tlb.o extable.o

+obj-y += fixed-mlpt/
+
  obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
  obj-$(CONFIG_NUMA)	   += numa.o
  obj-$(CONFIG_DISCONTIGMEM) += discontig.o
Index: linux-2.6.12-rc4/include/asm-ia64/mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/asm-ia64/mlpt.h	2005-05-19 
18:32:00.000000000 +1000
@@ -0,0 +1,108 @@
+#ifndef MLPT_IA64_H
+#define MLPT_IA64_H 1
+
+#include <linux/bootmem.h>
+
+static inline pte_t *lookup_kernel_page_table(unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset_k(address);
+	if (pgd_none_or_clear_bad(pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none_or_clear_bad(pud)) {
+		return NULL;
+	}
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none_or_clear_bad(pmd)) {
+		return NULL;
+	}
+
+	pte = pte_offset_kernel(pmd, address);
+
+	return pte;
+}
+
+
+/**
+ * build_kernel_page_table - frees a user process page table.
+ * @mm: the address space that owns the page table.
+ * @address: The virtual address for which we are adding a mapping.
+ *
+ * Returns a pointer to a pte.
+ *
+ * Builds the pud/pmd.pte directorires for a page table if requried.
+ * This function readies the page table for insertion.
+ */
+
+static inline pte_t *build_kernel_page_table(unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset_k(address);
+
+	if (!pgd) {
+		return NULL;
+	}
+
+	pud = pud_alloc(&init_mm, pgd, address);
+	if (!pud) {
+		return NULL;
+	}
+
+	pmd = pmd_alloc(&init_mm, pud, address);
+	if (!pmd) {
+		return NULL;
+	}
+
+	pte = pte_alloc_map(&init_mm, pmd, address);
+
+	return pte;
+}
+
+
+/**
+ * build_memory_map - builds the kernel page table for the memory map
+ * @address: The virtual address for which we are adding a mapping.
+ *
+ * Returns a pointer to the pte to be mapped.
+ *
+ * This function builds the kernel page table
+ */
+
+static inline pte_t *build_memory_map(unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
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
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
