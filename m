Received: From wagner (for linux-mm@kvack.org) With LocalMail ;
	Sat, 21 May 2005 12:43:32 +1000
From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 21 May 2005 12:43:31 +1000
Subject: [PATCH 1/15] PTI: clean page table interface
Message-ID: <20050521024331.GA6984@cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are a set of 15 patches against 2.6.12-rc4 to provide a clean
page table interface so that alternate page tables can be fitted
to Linux in the future.  This patch set is produced on behalf of
the Gelato research group at the University of New South Wales.

LMbench results are included at the end of this patch set.  The
results are very good although the mmap latency figures were
slightly higher than expected.

I look forward to any feedback that will assist me in putting
together a page table interface that will benefit the whole linux
community. 

Paul C Davies (for Gelato@UNSW)

Patch 1 of 15.

			GENERAL INFORMATION

The current page table implementation is tightly interwoven with
the rest of the  virtual memory code.  This makes it difficult to
implement new page tables, or to change the existing implementation.

This patch series attempts to abstract out the page table, so that
architectures can replace it with one that is more friendly if they
wish.  It's probable that architectures such as i386 and ARM, where
the hardware walks the current page table directly, will not want to
change it; but IA64 amongst others may wish to try page tables more
suited to huge sparse virtual memory layouts, or page tables that can
be hardware walked.

A new Kconfig option allows selecting the format; at present it's a
choice of one entry, but that will change in the future.

LMBench and similar microbenchmarks show no significant performance 
degradation after the full patch set is applied, on i386, Pentium-4 
or IA64 McKinley.  The patch set passes all vm tests for The LTP test 
suite ltp-20050505. 

There are 15 patches.  The general story is:
	* Introduce the architecture independent interface minus
	  iterators.
	* Move relevant code behind interface.
	* Go through each function in the general interface and call
	  it.
	* Introduce iterators.
	* Go through and call all iterators.
Up to this point all architectures will run through this by default.
	* Now introduce the ia64 mlpt specific interface.
	* Move architecture specific mlpt code behind interface and
	  call the new interface.

The first patch introduces the architecture independent interface
minus the iterators.  Kconfig options for architectures other than 
i386 and IA64 will be added in a later patch series.

 arch/i386/Kconfig         |    2 
 arch/ia64/Kconfig         |    2 
 include/mm/mlpt-generic.h |  190 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig                |   16 +++
 4 files changed, 210 insertions(+)

Index: linux-2.6.12-rc4/include/mm/mlpt-generic.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/mm/mlpt-generic.h	2005-05-19 17:04:00.000000000 +1000
@@ -0,0 +1,190 @@
+#ifndef _MM_MLPT_GENERIC_H
+#define _MM_MLPT_GENERIC_H 1
+
+#include <linux/highmem.h>
+#include <asm/tlb.h>
+
+/**
+ * init_page_table - initialise a user process page table 
+ *
+ * Returns the address of the page table
+ *
+ * Creates a new page table.  This consists of a zeroed out pgd.
+ */
+
+static inline pgd_t *init_page_table(void)
+{
+	return pgd_alloc(NULL);
+}
+
+/**
+ * free_page_table - frees a user process page table 
+ * @pgd: the pointer to the page table
+ *
+ * Returns void
+ *
+ * Frees the page table.  It assumes that the rest of the page table has been 
+ * torn down prior to this.
+ */
+
+static inline void free_page_table(pgd_t *pgd)
+{
+	pgd_free(pgd);
+}
+
+/**
+ * lookup_page_table - looks up any page table 
+ * @mm: the address space that owns the page table
+ * @address: The virtual address we are trying to find the pte for 
+ *
+ * Returns a pointer to a pte.
+ *
+ * Look up the kernel or user page table.
+ */
+
+static inline pte_t *lookup_page_table(struct mm_struct *mm, unsigned long address)
+{ 
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	if (mm) { /* Look up user page table */
+		pgd = pgd_offset(mm, address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	} else { /* Look up kernel page table */
+		pgd = pgd_offset_k(address);
+		if (pgd_none_or_clear_bad(pgd)) //look at clear bad here.
+			return NULL;
+	}
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
+	pte = pte_offset_map(pmd, address);
+
+	return pte;
+}
+
+/**
+ * build_page_table - builds a user process page table.
+ * @mm: the address space that owns the page table.
+ * @address: The virtual address for which we are adding a mapping.
+ *
+ * Returns a pointer to a pte.
+ *
+ * Builds the pud/pmd/pte directories for a page table if requried.
+ * This function readies the page table for insertion.
+ */
+
+static inline pte_t *build_page_table(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset(mm, address);
+
+	if (!pgd) {
+		return NULL;
+	}
+
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud) {
+		return NULL;
+	}
+
+	pmd = pmd_alloc(mm, pud, address);
+	if (!pmd) {
+		return NULL;
+	}
+
+	pte = pte_alloc_map(mm, pmd, address);
+
+	return pte;
+}
+
+/**
+ * lookup_nested_pte - looks up a nested pte.
+ * @mm: the address space that owns the page table.
+ * @address: The virtual address for which we are adding a mapping.
+ *
+ * Returns a pointer to the pte to be unmapped.
+ *
+ * This function looks up a user page table for a nested pte. 
+ */
+
+static inline pte_t *lookup_nested_pte(struct mm_struct *mm, unsigned long address)
+{ 
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte = NULL;
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_none_or_clear_bad(pgd))
+		goto end;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none_or_clear_bad(pud))
+		goto end;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none_or_clear_bad(pmd))
+		goto end;
+
+	pte = pte_offset_map_nested(pmd, address);
+	if (pte_none(*pte)) {
+		pte_unmap_nested(pte);
+		pte = NULL;
+	}
+end:
+	return pte;
+}
+
+/**
+ * lookup_page_table_gate - looks up a page table.
+ * @mm: the address space that owns the page table.
+ * @start: The virtual address we are looking up
+ *
+ * Returns a pointer to the pte to be unmapped.
+ *
+ * This function looks up a page table.  The gate varies with the 
+ * architecture.  
+ */
+
+static inline pte_t *lookup_page_table_gate(struct mm_struct *mm, unsigned long start)
+{
+	unsigned long pg = start & PAGE_MASK;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	if (pg > TASK_SIZE)
+		pgd = pgd_offset_k(pg);
+	else
+		pgd = pgd_offset_gate(mm, pg);
+	BUG_ON(pgd_none(*pgd));
+	pud = pud_offset(pgd, pg);
+	BUG_ON(pud_none(*pud));
+	pmd = pmd_offset(pud, pg);
+	BUG_ON(pmd_none(*pmd));
+	pte = pte_offset_map(pmd, pg);
+
+	return pte;
+}
+
+void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+		   unsigned long floor, unsigned long ceiling);
+
+#endif
Index: linux-2.6.12-rc4/mm/Kconfig
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/mm/Kconfig	2005-05-19 17:04:00.000000000 +1000
@@ -0,0 +1,16 @@
+choice
+	prompt "Page Table Format"
+	default MLPT
+
+config MLPT
+       bool "MLPT"
+       help
+         Linux will offer a choice of page table formats for different
+	 purposes.  The Multi-Level-Page Table is the standard (old)
+	 page table, which can be walked directly by many
+	 architectures.
+	 Typically each architecture will have, as well as Linux's
+	 page tables, its own hardware-walked tables that act as a
+	 software-loaded cache of the kernel tables.
+	 
+endchoice
Index: linux-2.6.12-rc4/arch/i386/Kconfig
===================================================================
--- linux-2.6.12-rc4.orig/arch/i386/Kconfig	2005-05-19 17:02:57.000000000 +1000
+++ linux-2.6.12-rc4/arch/i386/Kconfig	2005-05-19 17:04:00.000000000 +1000
@@ -703,6 +703,8 @@
 	  with major 203 and minors 0 to 31 for /dev/cpu/0/cpuid to
 	  /dev/cpu/31/cpuid.
 
+source "mm/Kconfig"
+
 source "drivers/firmware/Kconfig"
 
 choice
Index: linux-2.6.12-rc4/arch/ia64/Kconfig
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/Kconfig	2005-05-19 17:02:57.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/Kconfig	2005-05-19 17:04:00.000000000 +1000
@@ -342,6 +342,8 @@
 	depends on IOSAPIC && EXPERIMENTAL
 	default y
 
+source "mm/Kconfig"
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
