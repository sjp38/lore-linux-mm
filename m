From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:28:40 +1000
Message-Id: <20060713042840.9978.62852.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 12/18] PTI - Zeromap iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstracts zeromap_page_range iterator from memory.c to pt_default.c

2) Add remap_pfn_range to pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c     |   71 +++-------------------------
 pt-default.c |  146 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 155 insertions(+), 62 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 20:38:57.812521328 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 20:46:15.496234144 +1000
@@ -649,80 +649,27 @@
 
 EXPORT_SYMBOL(get_user_pages);
 
-static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
+void zeromap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr, pgprot_t prot)
 {
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		struct page *page = ZERO_PAGE(addr);
-		pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
-		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, zero_pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
-}
-
-static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (zeromap_pte_range(mm, pmd, addr, next, prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (zeromap_pmd_range(mm, pud, addr, next, prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
+	struct page *page = ZERO_PAGE(addr);
+	pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
+	page_cache_get(page);
+	page_add_file_rmap(page);
+	inc_mm_counter(mm, file_rss);
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(mm, addr, pte, zero_pte);
 }
 
 int zeromap_page_range(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long size, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long end = addr + size;
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
 	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = zeromap_pud_range(mm, pgd, addr, next, prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = zeromap_build_iterator(mm, addr, end, prot);
 	return err;
 }
 
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 20:38:57.812521328 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 20:44:58.658664376 +1000
@@ -486,3 +486,149 @@
 
 	return addr;
 }
+
+static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		zeromap_one_pte(mm, pte, addr, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (zeromap_pte_range(mm, pmd, addr, next, prot))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (zeromap_pmd_range(mm, pud, addr, next, prot))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int zeromap_build_iterator(struct mm_struct *mm,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if(zeromap_pud_range(mm, pgd, addr, next, prot))
+		  	return -ENOMEM;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+/*
+ * maps a range of physical memory into the requested pages. the old
+ * mappings are removed. any references to nonexistent pages results
+ * in null mappings (currently treated as "copy-on-access")
+ */
+static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		remap_one_pte(mm, pte, addr, pfn++, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pfn -= addr >> PAGE_SHIFT;
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (remap_pte_range(mm, pmd, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pfn -= addr >> PAGE_SHIFT;
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (remap_pmd_range(mm, pud, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = remap_pud_range(mm, pgd, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot);
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
