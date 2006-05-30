Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:33:22 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:33:21 +1000 (EST)
Subject: [Patch 12/17] PTI: Abstract msync build iterator
Message-ID: <Pine.LNX.4.61.0605301731510.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Abstract the msync iterator to default-pt-read-iterators.h

  include/linux/default-pt-read-iterators.h |  162 
++++++++++++++++++++++++++++++
  mm/msync.c                                |   99 +++---------------
  2 files changed, 180 insertions(+), 81 deletions(-)
Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-read-iterators.h	2006-05-28 
20:24:53.251150720 +1000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
20:25:15.227809760 +1000
@@ -162,4 +162,166 @@
  	} while (pgd++, addr = next, addr != end);
  }

+/*
+ * msync_read_iterator: Called in msync.c
+ */
+
+typedef int (*msync_callback_t)(pte_t *pte, unsigned long address,
+				struct vm_area_struct *vma, unsigned long 
*ret);
+
+static inline unsigned long msync_pte_range(struct vm_area_struct *vma,
+				pmd_t *pmd, unsigned long addr,
+				unsigned long end, msync_callback_t func)
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
+		if(!func(pte, addr, vma, &ret))
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
+			pud_t *pud, unsigned long addr,
+			unsigned long end, msync_callback_t func)
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
+		ret += msync_pte_range(vma, pmd, addr, next, func);
+	} while (pmd++, addr = next, addr != end);
+	return ret;
+}
+
+static inline unsigned long msync_pud_range(struct vm_area_struct *vma,
+			pgd_t *pgd, unsigned long addr,
+			unsigned long end, msync_callback_t func)
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
+		ret += msync_pmd_range(vma, pud, addr, next, func);
+	} while (pud++, addr = next, addr != end);
+	return ret;
+}
+
+static inline unsigned long msync_read_iterator(struct vm_area_struct 
*vma,
+				unsigned long addr, unsigned long end, 
msync_callback_t func)
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
+		ret += msync_pud_range(vma, pgd, addr, next, func);
+	} while (pgd++, addr = next, addr != end);
+	return ret;
+}
+
+/*
+ * change_protection_read_iterator: Called in mprotect.c
+ */
+
+typedef void (*change_prot_callback_t) (struct mm_struct *mm, pte_t *pte,
+	unsigned long address, pgprot_t newprot);
+
+static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		change_prot_callback_t func)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	do {
+		func(mm, pte, addr, newprot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+}
+
+static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		change_prot_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		change_pte_range(mm, pmd, addr, next, newprot, func);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		change_prot_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		change_pmd_range(mm, pud, addr, next, newprot, func);
+	} while (pud++, addr = next, addr != end);
+}
+
+static inline void change_protection_read_iterator(struct vm_area_struct 
*vma,
+	unsigned long addr, unsigned long end, pgprot_t newprot,
+	change_prot_callback_t func)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd)) {
+			continue;
+		}
+		change_pud_range(mm, pgd, addr, next, newprot, func);
+	} while (pgd++, addr = next, addr != end);
+}
+
  #endif
Index: linux-rc5/mm/msync.c
===================================================================
--- linux-rc5.orig/mm/msync.c	2006-05-28 20:24:53.252150568 +1000
+++ linux-rc5/mm/msync.c	2006-05-28 20:25:15.228809608 +1000
@@ -16,89 +16,33 @@
  #include <linux/writeback.h>
  #include <linux/file.h>
  #include <linux/syscalls.h>
+#include <linux/rmap.h>
+#include <linux/default-pt.h>

  #include <asm/pgtable.h>
  #include <asm/tlbflush.h>

-static unsigned long msync_pte_range(struct vm_area_struct *vma, pmd_t 
*pmd,
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
-{
-	pmd_t *pmd;
-	unsigned long next;
-	unsigned long ret = 0;
-
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
+static int msync_pte(pte_t *pte, unsigned long address,
+				struct vm_area_struct *vma, unsigned long 
*ret)
  {
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
+	struct page *page;
+
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
@@ -107,15 +51,8 @@
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
+	return msync_read_iterator(vma, addr, end, msync_pte);
  }

  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
