Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:41:23 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:41:22 +1000 (EST)
Subject: [Patch 17/17] PTI: Abstract zeromap build iterator
Message-ID: <Pine.LNX.4.61.0605301739560.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Abstract the zeromap build iterator to default-pt-build-iterators.h file.

  include/linux/default-pt-build-iterators.h |   85 ++++++++++++++++
  mm/memory.c                                |  148 
++---------------------------
  2 files changed, 100 insertions(+), 133 deletions(-)
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 21:27:01.799766192 +1000
+++ linux-rc5/mm/memory.c	2006-05-29 13:23:46.314675120 +1000
@@ -49,7 +49,6 @@
  #include <linux/module.h>
  #include <linux/init.h>

-#include <asm/pgalloc.h>
  #include <asm/uaccess.h>
  #include <asm/tlb.h>
  #include <asm/tlbflush.h>
@@ -652,95 +651,30 @@

  EXPORT_SYMBOL(get_user_pages);

-static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
+void zeromap_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr, 
pgprot_t prot)
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
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
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
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
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
  			unsigned long addr, unsigned long size, pgprot_t 
prot)
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
+	err = zeromap_build_iterator(mm, addr, end, prot, zeromap_pte);
  	return err;
  }

-pte_t * fastcall get_locked_pte(struct mm_struct *mm, unsigned long addr, 
spinlock_t **ptl)
-{
-	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
-	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd)
-			return pte_alloc_map_lock(mm, pmd, addr, ptl);
-	}
-	return NULL;
-}
-
  /*
   * This is the old fallback for page remapping.
   *
@@ -808,76 +742,17 @@
  }
  EXPORT_SYMBOL(vm_insert_page);

-/*
- * maps a range of physical memory into the requested pages. the old
- * mappings are removed. any references to nonexistent pages results
- * in null mappings (currently treated as "copy-on-access")
- */
-static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+void remap_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr,
+			   unsigned long pfn, pgprot_t prot)
  {
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
-}
-
-static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pfn -= addr >> PAGE_SHIFT;
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (remap_pte_range(mm, pmd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (remap_pmd_range(mm, pud, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
  }

  /*  Note: this is only safe if the mm semaphore is held when called. */
  int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
  		    unsigned long pfn, unsigned long size, pgprot_t prot)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long end = addr + PAGE_ALIGN(size);
  	struct mm_struct *mm = vma->vm_mm;
  	int err;
@@ -910,15 +785,9 @@

  	BUG_ON(addr >= end);
  	pfn -= addr >> PAGE_SHIFT;
-	pgd = pgd_offset(mm, addr);
  	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = remap_build_iterator(mm, addr, end, pfn, prot, remap_pte);
+
  	return err;
  }
  EXPORT_SYMBOL(remap_pfn_range);
Index: linux-rc5/include/linux/default-pt-build-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-build-iterators.h	2006-05-28 
21:27:01.900750840 +1000
+++ linux-rc5/include/linux/default-pt-build-iterators.h	2006-05-29 
13:24:45.016751048 +1000
@@ -160,4 +160,89 @@
  	return 0;
  }

+typedef void (*remap_pfn_callback_t)(struct mm_struct *, pte_t *, 
unsigned long,
+			   unsigned long, pgprot_t);
+
+/*
+ * maps a range of physical memory into the requested pages. the old
+ * mappings are removed. any references to nonexistent pages results
+ * in null mappings (currently treated as "copy-on-access")
+ */
+static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot, remap_pfn_callback_t func)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		func(mm, pte, addr, pfn++, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot, remap_pfn_callback_t func)
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
+				pfn + (addr >> PAGE_SHIFT), prot, func))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot, remap_pfn_callback_t func)
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
+				pfn + (addr >> PAGE_SHIFT), prot, func))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot, remap_pfn_callback_t func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err;
+
+	pgd = pgd_offset(mm, addr);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		err = remap_pud_range(mm, pgd, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot, func);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
