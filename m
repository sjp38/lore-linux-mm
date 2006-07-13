From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:28:50 +1000
Message-Id: <20060713042850.9978.40733.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 13/18] PTI - Msync iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstracts msync iterator from msync.c to pt_default.c

2) Abstract remap_pfn_range from memory.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c     |   76 +++-------------------------------------------
 msync.c      |   96 +++++++++--------------------------------------------------
 pt-default.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 102 insertions(+), 151 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 20:46:15.496234144 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 20:48:44.426434024 +1000
@@ -740,76 +740,17 @@
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
+void remap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr,
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
@@ -842,15 +783,8 @@
 
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
+	err = remap_build_iterator(mm, addr, end, pfn, prot);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
Index: linux-2.6.17.2/mm/msync.c
===================================================================
--- linux-2.6.17.2.orig/mm/msync.c	2006-06-30 10:17:23.000000000 +1000
+++ linux-2.6.17.2/mm/msync.c	2006-07-08 20:51:18.519008392 +1000
@@ -16,89 +16,32 @@
 #include <linux/writeback.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 
-static unsigned long msync_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-	int progress = 0;
-	unsigned long ret = 0;
-
-again:
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-
-		if (progress >= 64) {
-			progress = 0;
-			if (need_resched() || need_lockbreak(ptl))
-				break;
-		}
-		progress++;
-		if (!pte_present(*pte))
-			continue;
-		if (!pte_maybe_dirty(*pte))
-			continue;
-		page = vm_normal_page(vma, addr, *pte);
-		if (!page)
-			continue;
-		if (ptep_clear_flush_dirty(vma, addr, pte) ||
-				page_test_and_clear_dirty(page))
-			ret += set_page_dirty(page);
-		progress += 3;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-	if (addr != end)
-		goto again;
-	return ret;
-}
-
-static inline unsigned long msync_pmd_range(struct vm_area_struct *vma,
-			pud_t *pud, unsigned long addr, unsigned long end)
+int msync_one_pte(pte_t *pte, unsigned long address,
+				struct vm_area_struct *vma, unsigned long *ret)
 {
-	pmd_t *pmd;
-	unsigned long next;
-	unsigned long ret = 0;
+	struct page *page;
 
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		ret += msync_pte_range(vma, pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-	return ret;
-}
-
-static inline unsigned long msync_pud_range(struct vm_area_struct *vma,
-			pgd_t *pgd, unsigned long addr, unsigned long end)
-{
-	pud_t *pud;
-	unsigned long next;
-	unsigned long ret = 0;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		ret += msync_pmd_range(vma, pud, addr, next);
-	} while (pud++, addr = next, addr != end);
-	return ret;
+	if (!pte_present(*pte))
+		return 0;
+	if (!pte_maybe_dirty(*pte))
+		return 0;
+	page = vm_normal_page(vma, address, *pte);
+	if (!page)
+		return 0;
+	if (ptep_clear_flush_dirty(vma, address, pte) ||
+		page_test_and_clear_dirty(page))
+		 *ret += set_page_dirty(page);
+	return 1;
 }
 
 static unsigned long msync_page_range(struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end)
 {
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long ret = 0;
-
 	/* For hugepages we can't go walking the page table normally,
 	 * but that's ok, hugetlbfs is memory based, so we don't need
 	 * to do anything more on an msync().
@@ -107,15 +50,8 @@
 		return 0;
 
 	BUG_ON(addr >= end);
-	pgd = pgd_offset(vma->vm_mm, addr);
 	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		ret += msync_pud_range(vma, pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
-	return ret;
+	return msync_read_iterator(vma, addr, end);
 }
 
 /*
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 20:54:42.425009968 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 20:55:53.911142424 +1000
@@ -632,3 +632,84 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static unsigned long msync_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+	int progress = 0;
+	unsigned long ret = 0;
+
+again:
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		if (progress >= 64) {
+			progress = 0;
+			if (need_resched() || need_lockbreak(ptl))
+				break;
+		}
+		progress++;
+		if(!msync_one_pte(pte, addr, vma, &ret))
+			continue;
+		progress += 3;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	if (addr != end)
+		goto again;
+	return ret;
+}
+
+static inline unsigned long msync_pmd_range(struct vm_area_struct *vma,
+			pud_t *pud, unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long ret = 0;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		ret += msync_pte_range(vma, pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+	return ret;
+}
+
+static inline unsigned long msync_pud_range(struct vm_area_struct *vma,
+			pgd_t *pgd, unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long ret = 0;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		ret += msync_pmd_range(vma, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+	return ret;
+}
+
+unsigned long msync_read_iterator(struct vm_area_struct *vma,
+			unsigned long addr, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	unsigned long next;
+	unsigned long ret=0;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd)) {
+			continue;
+		}
+		ret += msync_pud_range(vma, pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+	return ret;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
