Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:34:51 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:34:51 +1000 (EST)
Subject: [Patch 13/17] PTI: Abstract swap read iterator
Message-ID: <Pine.LNX.4.61.0605301733260.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Abstract the swap iterator from swapfile.c to default-pt-read-iterators.h

  include/linux/default-pt-read-iterators.h |   87 
++++++++++++++++++++++++++++++
  include/linux/default-pt.h                |    3 +
  include/linux/swapops.h                   |    5 +
  mm/mprotect.c                             |   75 
+++++--------------------
  mm/swapfile.c                             |   85 
-----------------------------
  5 files changed, 112 insertions(+), 143 deletions(-)
Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-read-iterators.h	2006-05-28 
20:27:01.010728312 +1000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
20:27:53.705717456 +1000
@@ -324,4 +324,91 @@
  	} while (pgd++, addr = next, addr != end);
  }

+/*
+ * unuse_vma_read_iterator: Called in swapfile.c FIXME
+ */
+
+typedef void (*unuse_pte_callback_t)(struct vm_area_struct *vma, pte_t 
*pte,
+				unsigned long addr, swp_entry_t entry, 
struct page *page);
+
+static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end, 
swp_entry_t entry,
+				struct page *page, unuse_pte_callback_t 
func)
+{
+	pte_t swp_pte = swp_entry_to_pte(entry);
+	pte_t *pte;
+	spinlock_t *ptl;
+	int found = 0;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		/*
+		 * swapoff spends a _lot_ of time in this loop!
+		 * Test inline before going to call unuse_pte.
+		 */
+		if (unlikely(pte_same(*pte, swp_pte))) {
+			func(vma, pte++, addr, entry, page);
+			found = 1;
+			break;
+		}
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return found;
+}
+
+static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+				unsigned long addr, unsigned long end, 
swp_entry_t entry,
+				struct page *page, unuse_pte_callback_t 
func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		if (unuse_pte_range(vma, pmd, addr, next, entry, page, 
func))
+			return 1;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end, 
swp_entry_t entry,
+				struct page *page, unuse_pte_callback_t 
func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		if (unuse_pmd_range(vma, pud, addr, next, entry, page, 
func))
+			return 1;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int unuse_vma_read_iterator(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end, 
swp_entry_t entry,
+				struct page *page, unuse_pte_callback_t 
func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		if (unuse_pud_range(vma, pgd, addr, next, entry, page, 
func))
+			return 1;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+
  #endif
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
20:26:48.811582864 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
20:27:53.706717304 +1000
@@ -1,6 +1,9 @@
  #ifndef _LINUX_DEFAULT_PT_H
  #define _LINUX_DEFAULT_PT_H

+#include <linux/swap.h>
+#include <linux/swapops.h>
+
  #include <asm/tlb.h>
  #include <asm/pgalloc.h>
  #include <asm/pgtable.h>
Index: linux-rc5/include/linux/swapops.h
===================================================================
--- linux-rc5.orig/include/linux/swapops.h	2006-05-28 
20:26:48.811582864 +1000
+++ linux-rc5/include/linux/swapops.h	2006-05-28 20:27:53.706717304 
+1000
@@ -1,3 +1,6 @@
+#ifndef _LINUX_SWAPOPS_H
+#define _LINUX_SWAPOPS_H 1
+
  /*
   * swapcache pages are stored in the swapper_space radix tree.  We want 
to
   * get good packing density in that tree, so the index should be dense in
@@ -67,3 +70,5 @@
  	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
  	return __swp_entry_to_pte(arch_entry);
  }
+
+#endif
Index: linux-rc5/mm/mprotect.c
===================================================================
--- linux-rc5.orig/mm/mprotect.c	2006-05-28 20:26:48.811582864 
+1000
+++ linux-rc5/mm/mprotect.c	2006-05-28 20:27:53.704717608 +1000
@@ -19,82 +19,41 @@
  #include <linux/mempolicy.h>
  #include <linux/personality.h>
  #include <linux/syscalls.h>
+#include <linux/rmap.h>
+#include <linux/default-pt.h>

  #include <asm/uaccess.h>
  #include <asm/pgtable.h>
  #include <asm/cacheflush.h>
  #include <asm/tlbflush.h>

-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	do {
-		if (pte_present(*pte)) {
-			pte_t ptent;
-
-			/* Avoid an SMP race with hardware updated 
dirty/clean
-			 * bits by wiping the pte and then setting the new 
pte
-			 * into place.
-			 */
-			ptent = pte_modify(ptep_get_and_clear(mm, addr, 
pte), newprot);
-			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-}
-
-static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		change_pte_range(mm, pmd, addr, next, newprot);
-	} while (pmd++, addr = next, addr != end);
-}
+void change_prot_pte(struct mm_struct *mm, pte_t *pte,
+	unsigned long address, pgprot_t newprot)

-static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
  {
-	pud_t *pud;
-	unsigned long next;
+	if (pte_present(*pte)) {
+		pte_t ptent;

-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		change_pmd_range(mm, pud, addr, next, newprot);
-	} while (pud++, addr = next, addr != end);
+		/* Avoid an SMP race with hardware updated dirty/clean
+		 * bits by wiping the pte and then setting the new pte
+		 * into place.
+		 */
+		ptent = pte_modify(ptep_get_and_clear(mm, address, pte), 
newprot);
+		set_pte_at(mm, addr, pte, ptent);
+		lazy_mmu_prot_update(ptent);
+	}
  }

  static void change_protection(struct vm_area_struct *vma,
  		unsigned long addr, unsigned long end, pgprot_t newprot)
  {
-	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long start = addr;

  	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
+
  	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		change_pud_range(mm, pgd, addr, next, newprot);
-	} while (pgd++, addr = next, addr != end);
+	change_protection_read_iterator(vma, addr, end,
+		newprot, change_prot_pte);
  	flush_tlb_range(vma, start, end);
  }

Index: linux-rc5/mm/swapfile.c
===================================================================
--- linux-rc5.orig/mm/swapfile.c	2006-05-28 20:26:48.811582864 
+1000
+++ linux-rc5/mm/swapfile.c	2006-05-28 20:27:53.707717152 +1000
@@ -499,94 +499,9 @@
  	activate_page(page);
  }

-static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
-{
-	pte_t swp_pte = swp_entry_to_pte(entry);
-	pte_t *pte;
-	spinlock_t *ptl;
-	int found = 0;
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		/*
-		 * swapoff spends a _lot_ of time in this loop!
-		 * Test inline before going to call unuse_pte.
-		 */
-		if (unlikely(pte_same(*pte, swp_pte))) {
-			unuse_pte(vma, pte++, addr, entry, page);
-			found = 1;
-			break;
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	return found;
-}

-static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
-{
-	pmd_t *pmd;
-	unsigned long next;

-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		if (unuse_pte_range(vma, pmd, addr, next, entry, page))
-			return 1;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
-{
-	pud_t *pud;
-	unsigned long next;

-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		if (unuse_pmd_range(vma, pud, addr, next, entry, page))
-			return 1;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
-
-static int unuse_vma(struct vm_area_struct *vma,
-				swp_entry_t entry, struct page *page)
-{
-	pgd_t *pgd;
-	unsigned long addr, end, next;
-
-	if (page->mapping) {
-		addr = page_address_in_vma(page, vma);
-		if (addr == -EFAULT)
-			return 0;
-		else
-			end = addr + PAGE_SIZE;
-	} else {
-		addr = vma->vm_start;
-		end = vma->vm_end;
-	}
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (unuse_pud_range(vma, pgd, addr, next, entry, page))
-			return 1;
-	} while (pgd++, addr = next, addr != end);
-	return 0;
-}

  static int unuse_mm(struct mm_struct *mm,
  				swp_entry_t entry, struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
