From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:36 +1100
Message-Id: <20070113024736.29682.55079.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 22/29] Abstract map vm area
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 22
 * Move default page table iterator map_vm_area from vmalloc.c to pt_default.c
 * Abstract the operation performed by this iterator into vmap-one_pte and
 put it in pt-iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   14 ++++++++
 mm/pt-default.c                 |   67 ++++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c                    |   63 -------------------------------------
 3 files changed, 82 insertions(+), 62 deletions(-)
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:38:30.352438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:38:47.456438000 +1100
@@ -765,3 +765,70 @@
 	} while (pgd++, addr = next, addr != end);
 }
 
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
Index: linux-2.6.20-rc4/mm/vmalloc.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/vmalloc.c	2007-01-11 13:38:30.352438000 +1100
+++ linux-2.6.20-rc4/mm/vmalloc.c	2007-01-11 13:38:47.456438000 +1100
@@ -39,75 +39,14 @@
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
-	return 0;
-}
-
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
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:38:30.348438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:38:47.456438000 +1100
@@ -219,3 +219,17 @@
 	pte_t ptent = ptep_get_and_clear(&init_mm, address, pte);
 	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
 }
+
+static inline int
+vmap_one_pte(pte_t *pte, unsigned long addr,
+			struct page ***pages, pgprot_t prot)
+{
+	struct page *page = **pages;
+
+	WARN_ON(!pte_none(*pte));
+	if (!page)
+		return -ENOMEM;
+	set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
+	(*pages)++;
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
