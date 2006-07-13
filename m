From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:29:00 +1000
Message-Id: <20060713042900.9978.30415.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 14/18] PTI - Vmalloc iterators asbstractions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstracts vmalloc build iterator from vmalloc.c to pt_default.c

2) Abstracts vmalloc read iterator from vmalloc.c to pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-default.c |  123 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 vmalloc.c    |  116 ++++++-------------------------------------------------
 2 files changed, 136 insertions(+), 103 deletions(-)
Index: linux-2.6.17.2/mm/vmalloc.c
===================================================================
--- linux-2.6.17.2.orig/mm/vmalloc.c	2006-06-30 10:17:23.000000000 +1000
+++ linux-2.6.17.2/mm/vmalloc.c	2006-07-08 21:01:06.193668264 +1000
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 
 #include <linux/vmalloc.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
@@ -24,135 +25,44 @@
 DEFINE_RWLOCK(vmlist_lock);
 struct vm_struct *vmlist;
 
-static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
+void vunmap_one_pte(pte_t *pte, unsigned long address)
 {
-	pte_t *pte;
-
-	pte = pte_offset_kernel(pmd, addr);
-	do {
-		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
-		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-}
-
-static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
-						unsigned long end)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		vunmap_pte_range(pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
-						unsigned long end)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		vunmap_pmd_range(pud, addr, next);
-	} while (pud++, addr = next, addr != end);
+	pte_t ptent = ptep_get_and_clear(&init_mm, address, pte);
+	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
 }
 
 void unmap_vm_area(struct vm_struct *area)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long addr = (unsigned long) area->addr;
 	unsigned long end = addr + area->size;
 
 	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
 	flush_cache_vunmap(addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		vunmap_pud_range(pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
+	vunmap_read_iterator(addr, end);
 	flush_tlb_kernel_range((unsigned long) area->addr, end);
 }
 
-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page ***pages)
-{
-	pte_t *pte;
-
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
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
-			unsigned long end, pgprot_t prot, struct page ***pages)
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
-			unsigned long end, pgprot_t prot, struct page ***pages)
+int vmap_one_pte(pte_t *pte, unsigned long addr,
+			struct page ***pages, pgprot_t prot)
 {
-	pud_t *pud;
-	unsigned long next;
+	struct page *page = **pages;
 
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
+	WARN_ON(!pte_none(*pte));
+	if (!page)
 		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
+	(*pages)++;
 	return 0;
 }
 
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
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
+	err = vmap_build_iterator(addr, end, prot, pages);
 	flush_cache_vmap((unsigned long) area->addr, end);
 	return err;
 }
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 20:56:52.652212424 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 21:02:46.797374176 +1000
@@ -713,3 +713,126 @@
 	} while (pgd++, addr = next, addr != end);
 	return ret;
 }
+
+static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		vunmap_one_pte(pte, addr);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+}
+
+static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
+						unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		vunmap_pte_range(pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
+						unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		vunmap_pmd_range(pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+}
+
+void vunmap_read_iterator(unsigned long addr, unsigned long end)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+			vunmap_pud_range(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+}
+
+
+static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
+			unsigned long end, pgprot_t prot, struct page ***pages)
+{
+	pte_t *pte;
+	int err;
+
+	pte = pte_alloc_kernel(pmd, addr);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		err = vmap_one_pte(pte, addr, pages, prot);
+		if(err)
+			return err;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	return 0;
+}
+
+static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
+			unsigned long end, pgprot_t prot, struct page ***pages)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(&init_mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (vmap_pte_range(pmd, addr, next, prot, pages))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int vmap_pud_range(pgd_t *pgd, unsigned long addr,
+			unsigned long end, pgprot_t prot, struct page ***pages)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(&init_mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (vmap_pmd_range(pud, addr, next, prot, pages))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int vmap_build_iterator(unsigned long addr,
+			unsigned long end, pgprot_t prot, struct page ***pages)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err;
+
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = vmap_pud_range(pgd, addr, next, prot, pages);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
