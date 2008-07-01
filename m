Date: Tue, 1 Jul 2008 14:45:32 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 1/2] - Map UV chipset space - pagetable
Message-ID: <20080701194532.GA28405@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add boot-time function for creating additional 2MB page table entries for
mapping chipset specific cached/uncached ranges.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/mm/init_64.c     |   40 ++++++++++++++++++++++++++++++++++++++++
 include/asm-x86/page_64.h |    4 ++++
 include/asm-x86/pgtable.h |    2 ++
 3 files changed, 46 insertions(+)

Index: linux/arch/x86/mm/init_64.c
===================================================================
--- linux.orig/arch/x86/mm/init_64.c	2008-07-01 14:35:03.000000000 -0500
+++ linux/arch/x86/mm/init_64.c	2008-07-01 14:38:56.000000000 -0500
@@ -198,6 +198,46 @@ set_pte_vaddr(unsigned long vaddr, pte_t
 }
 
 /*
+ * Create large page table mappings for a range of physical addresses.
+ */
+static void __init __init_extra_mapping(unsigned long phys, unsigned long size,
+						pgprot_t prot)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	BUG_ON((phys & ~PMD_MASK) || (size & ~PMD_MASK));
+	for (; size; phys += PMD_SIZE, size -= PMD_SIZE) {
+		pgd = pgd_offset_k((unsigned long)__va(phys));
+		if (pgd_none(*pgd)) {
+			pud = (pud_t *) spp_getpage();
+			set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE |
+						_PAGE_USER));
+		}
+		pud = pud_offset(pgd, (unsigned long)__va(phys));
+		if (pud_none(*pud)) {
+			pmd = (pmd_t *) spp_getpage();
+			set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE |
+						_PAGE_USER));
+		}
+		pmd = pmd_offset(pud, phys);
+		BUG_ON(!pmd_none(*pmd));
+		set_pmd(pmd, __pmd(phys | pgprot_val(prot)));
+	}
+}
+
+void __init init_extra_mapping_wb(unsigned long phys, unsigned long size)
+{
+	__init_extra_mapping(phys, size, PAGE_KERNEL_LARGE);
+}
+
+void __init init_extra_mapping_uc(unsigned long phys, unsigned long size)
+{
+	__init_extra_mapping(phys, size, PAGE_KERNEL_LARGE_NOCACHE);
+}
+
+/*
  * The head.S code sets up the kernel high mapping:
  *
  *   from __START_KERNEL_map to __START_KERNEL_map + size (== _end-_text)
Index: linux/include/asm-x86/pgtable.h
===================================================================
--- linux.orig/include/asm-x86/pgtable.h	2008-07-01 14:35:03.000000000 -0500
+++ linux/include/asm-x86/pgtable.h	2008-07-01 14:35:10.000000000 -0500
@@ -101,6 +101,7 @@ extern pteval_t __PAGE_KERNEL, __PAGE_KE
 #define __PAGE_KERNEL_VSYSCALL		(__PAGE_KERNEL_RX | _PAGE_USER)
 #define __PAGE_KERNEL_VSYSCALL_NOCACHE	(__PAGE_KERNEL_VSYSCALL | _PAGE_PCD | _PAGE_PWT)
 #define __PAGE_KERNEL_LARGE		(__PAGE_KERNEL | _PAGE_PSE)
+#define __PAGE_KERNEL_LARGE_NOCACHE	(__PAGE_KERNEL | _PAGE_CACHE_UC | _PAGE_PSE)
 #define __PAGE_KERNEL_LARGE_EXEC	(__PAGE_KERNEL_EXEC | _PAGE_PSE)
 
 #ifdef CONFIG_X86_32
@@ -118,6 +119,7 @@ extern pteval_t __PAGE_KERNEL, __PAGE_KE
 #define PAGE_KERNEL_UC_MINUS		MAKE_GLOBAL(__PAGE_KERNEL_UC_MINUS)
 #define PAGE_KERNEL_EXEC_NOCACHE	MAKE_GLOBAL(__PAGE_KERNEL_EXEC_NOCACHE)
 #define PAGE_KERNEL_LARGE		MAKE_GLOBAL(__PAGE_KERNEL_LARGE)
+#define PAGE_KERNEL_LARGE_NOCACHE	MAKE_GLOBAL(__PAGE_KERNEL_LARGE_NOCACHE)
 #define PAGE_KERNEL_LARGE_EXEC		MAKE_GLOBAL(__PAGE_KERNEL_LARGE_EXEC)
 #define PAGE_KERNEL_VSYSCALL		MAKE_GLOBAL(__PAGE_KERNEL_VSYSCALL)
 #define PAGE_KERNEL_VSYSCALL_NOCACHE	MAKE_GLOBAL(__PAGE_KERNEL_VSYSCALL_NOCACHE)
Index: linux/include/asm-x86/page_64.h
===================================================================
--- linux.orig/include/asm-x86/page_64.h	2008-07-01 14:35:03.000000000 -0500
+++ linux/include/asm-x86/page_64.h	2008-07-01 14:35:10.000000000 -0500
@@ -84,6 +84,10 @@ extern unsigned long init_memory_mapping
 					 unsigned long end);
 
 extern void initmem_init(unsigned long start_pfn, unsigned long end_pfn);
+
+extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
+extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
+
 #endif	/* !__ASSEMBLY__ */
 
 #ifdef CONFIG_FLATMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
