Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:39:55 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:39:54 +1000 (EST)
Subject: [Patch 16/17] PTI: Abstract vmap build iterator
Message-ID: <Pine.LNX.4.61.0605301738300.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  include/linux/default-pt-build-iterators.h |  163 
+++++++++++++++++++++++++++++
  include/linux/default-pt.h                 |    1
  mm/vmalloc.c                               |   64 +----------
  3 files changed, 172 insertions(+), 56 deletions(-)
Index: linux-rc5/include/linux/default-pt-build-iterators.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/include/linux/default-pt-build-iterators.h	2006-05-28 
20:33:02.758988368 +1000
@@ -0,0 +1,163 @@
+#ifndef _LINUX_DEFAULT_PT_BUILD_ITERATORS_H
+#define _LINUX_DEFAULT_PT_BUILD_ITERATORS_H 1
+
+/******************************************************************************/
+/*                              BUILD ITERATORS 
*/
+/******************************************************************************/
+
+/*
+ * vmap build iterator. Called in vmalloc.c
+ */
+
+typedef int (*vmap_callback_t)(pte_t *, unsigned long, struct page ***,
+			pgprot_t);
+
+static inline int vmap_pte_range(pmd_t *pmd, unsigned long addr,
+			unsigned long end, pgprot_t prot,
+			struct page ***pages, vmap_callback_t func)
+{
+	pte_t *pte;
+	int err;
+
+	pte = pte_alloc_kernel(pmd, addr);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		err = func(pte, addr, pages, prot);
+		if(err)
+			return err;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	return 0;
+}
+
+static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
+			unsigned long end, pgprot_t prot,
+			struct page ***pages, vmap_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(&init_mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (vmap_pte_range(pmd, addr, next, prot, pages, func))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int vmap_pud_range(pgd_t *pgd, unsigned long addr,
+			unsigned long end, pgprot_t prot,
+			struct page ***pages, vmap_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(&init_mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (vmap_pmd_range(pud, addr, next, prot, pages, func))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int vmap_build_iterator(unsigned long addr,
+			unsigned long end, pgprot_t prot,
+			struct page ***pages, vmap_callback_t func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err;
+
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = vmap_pud_range(pgd, addr, next, prot, pages, func);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+/*
+ * zeromap build iterator. Called in memory.c
+ */
+
+typedef void (*zeromap_callback_t)(struct mm_struct *mm, pte_t *pte,
+		unsigned long addr, pgprot_t prot);
+
+static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long addr, unsigned long end,
+			pgprot_t prot, zeromap_callback_t func)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		func(mm, pte, addr, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
+			unsigned long addr, unsigned long end,
+			pgprot_t prot, zeromap_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (zeromap_pte_range(mm, pmd, addr, next, prot, func))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end,
+			pgprot_t prot, zeromap_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (zeromap_pmd_range(mm, pud, addr, next, prot, func))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int zeromap_build_iterator(struct mm_struct *mm,
+			unsigned long addr, unsigned long end,
+			pgprot_t prot, zeromap_callback_t func)
+{
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if(zeromap_pud_range(mm, pgd, addr, next, prot, func))
+		  	return -ENOMEM;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+#endif
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
20:31:35.004254976 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
20:33:02.759988216 +1000
@@ -177,6 +177,7 @@
  #include <linux/pt-common.h>
  #include <linux/default-pt-dual-iterators.h>
  #include <linux/default-pt-read-iterators.h>
+#include <linux/default-pt-build-iterators.h>

  #endif

Index: linux-rc5/mm/vmalloc.c
===================================================================
--- linux-rc5.orig/mm/vmalloc.c	2006-05-28 20:31:35.005255824 +1000
+++ linux-rc5/mm/vmalloc.c	2006-05-28 20:33:02.760988064 +1000
@@ -43,75 +43,27 @@
  	flush_tlb_kernel_range((unsigned long) area->addr, end);
  }

-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
+static int vmap_pte(pte_t *pte, unsigned long addr,
+			struct page ***pages, pgprot_t prot)
  {
-	pte_t *pte;
+	struct page *page = **pages;

-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
+	WARN_ON(!pte_none(*pte));
+	if (!page)
  		return -ENOMEM;
-	do {
-		struct page *page = **pages;
-		WARN_ON(!pte_none(*pte));
-		if (!page)
-			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*pages)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
-
-static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
+	(*pages)++;
  	return 0;
  }

  int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page 
***pages)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long addr = (unsigned long) area->addr;
  	unsigned long end = addr + area->size - PAGE_SIZE;
  	int err;

  	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = vmap_build_iterator(addr, end, prot, pages, vmap_pte);
  	flush_cache_vmap((unsigned long) area->addr, end);
  	return err;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
