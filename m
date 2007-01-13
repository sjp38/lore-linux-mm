From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:08 +1100
Message-Id: <20070113024808.29682.99327.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 28/29] Abstract ioremap iterator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 28
 * Move ioremap iterator from /lib/ioremap.c to pt-default.c
 * Abstract ioremap_one_pte from iterator and put in pt-iterator-ops.h
 * Remove ioremap.c and update /lib/Makefile

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 lib/ioremap.c                                    |   91 -----------------------
 linux-2.6.20-rc4/include/linux/pt-iterator-ops.h |    8 ++
 linux-2.6.20-rc4/lib/Makefile                    |    1 
 linux-2.6.20-rc4/mm/mmap.c                       |    2 
 linux-2.6.20-rc4/mm/pt-default.c                 |   82 ++++++++++++++++++++
 5 files changed, 92 insertions(+), 92 deletions(-)
Index: linux-2.6.20-rc4/lib/Makefile
===================================================================
--- linux-2.6.20-rc4.orig/lib/Makefile	2007-01-11 13:30:52.020438000 +1100
+++ linux-2.6.20-rc4/lib/Makefile	2007-01-11 13:39:06.924438000 +1100
@@ -7,7 +7,6 @@
 	 idr.o div64.o int_sqrt.o bitmap.o extable.o prio_tree.o \
 	 sha1.o irq_regs.o reciprocal_div.o
 
-lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o kref.o kobject_uevent.o klist.o
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:39:05.324438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:39:06.928438000 +1100
@@ -1059,6 +1059,88 @@
 
 #endif
 
+static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
+		unsigned long end, unsigned long phys_addr, pgprot_t prot)
+{
+	pte_t *pte;
+	unsigned long pfn;
+
+	pfn = phys_addr >> PAGE_SHIFT;
+	pte = pte_alloc_kernel(pmd, addr);
+	if (!pte)
+		return -ENOMEM;
+	do {
+			ioremap_one_pte(pte, addr, pfn++, prot);
+#ifdef FFF
+		BUG_ON(!pte_none(*pte));
+		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
+		pfn++;
+#endif
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	return 0;
+}
+
+static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
+		unsigned long end, unsigned long phys_addr, pgprot_t prot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	phys_addr -= addr;
+	pmd = pmd_alloc(&init_mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
+		unsigned long end, unsigned long phys_addr, pgprot_t prot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	phys_addr -= addr;
+	pud = pud_alloc(&init_mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int ioremap_page_range(unsigned long addr,
+		       unsigned long end, unsigned long phys_addr, pgprot_t prot)
+{
+	pgd_t *pgd;
+	unsigned long start;
+	unsigned long next;
+	int err;
+
+	BUG_ON(addr >= end);
+
+	start = addr;
+	phys_addr -= addr;
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = ioremap_pud_range(pgd, addr, next, phys_addr+addr, prot);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+
+	flush_cache_vmap(start, end);
+
+	return err;
+}
+
 static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		unsigned long old_addr, unsigned long old_end,
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
Index: linux-2.6.20-rc4/mm/mmap.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/mmap.c	2007-01-11 13:30:52.020438000 +1100
+++ linux-2.6.20-rc4/mm/mmap.c	2007-01-11 13:39:06.928438000 +1100
@@ -1987,7 +1987,9 @@
 	while (vma)
 		vma = remove_vma(vma);
 
+#ifdef CONFIG_PT_DEFAULT
 	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+#endif
 }
 
 /* Insert vm structure into process list sorted by address
Index: linux-2.6.20-rc4/lib/ioremap.c
===================================================================
--- linux-2.6.20-rc4.orig/lib/ioremap.c	2007-01-11 13:30:52.020438000 +1100
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,91 +0,0 @@
-/*
- * Re-map IO memory to kernel address space so that we can access it.
- * This is needed for high PCI addresses that aren't mapped in the
- * 640k-1MB IO memory area on PC's
- *
- * (C) Copyright 1995 1996 Linus Torvalds
- */
-#include <linux/vmalloc.h>
-#include <linux/mm.h>
-
-#include <asm/cacheflush.h>
-#include <asm/pgtable.h>
-
-static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, unsigned long phys_addr, pgprot_t prot)
-{
-	pte_t *pte;
-	unsigned long pfn;
-
-	pfn = phys_addr >> PAGE_SHIFT;
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
-
-static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, unsigned long phys_addr, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	phys_addr -= addr;
-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, unsigned long phys_addr, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	phys_addr -= addr;
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
-
-int ioremap_page_range(unsigned long addr,
-		       unsigned long end, unsigned long phys_addr, pgprot_t prot)
-{
-	pgd_t *pgd;
-	unsigned long start;
-	unsigned long next;
-	int err;
-
-	BUG_ON(addr >= end);
-
-	start = addr;
-	phys_addr -= addr;
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = ioremap_pud_range(pgd, addr, next, phys_addr+addr, prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
-
-	flush_cache_vmap(start, end);
-
-	return err;
-}
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:39:01.788438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:39:06.932438000 +1100
@@ -327,3 +327,11 @@
 	return 0;
 }
 #endif
+
+static inline void
+ioremap_one_pte(pte_t *pte, unsigned long addr, unsigned long pfn,
+				pgprot_t prot)
+{
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
