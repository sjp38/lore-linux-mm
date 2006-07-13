From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:29:30 +1000
Message-Id: <20060713042930.9978.28392.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 17/18] PTI - Swapfile iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Abstracts swapfile iterator from swapfile.c and 
puts it in pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-default.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 swapfile.c   |   77 ++-------------------------------------------------------
 2 files changed, 83 insertions(+), 73 deletions(-)
Index: linux-2.6.17.2/mm/swapfile.c
===================================================================
--- linux-2.6.17.2.orig/mm/swapfile.c	2006-06-30 10:17:23.000000000 +1000
+++ linux-2.6.17.2/mm/swapfile.c	2006-07-08 22:00:07.309931488 +1000
@@ -28,6 +28,7 @@
 #include <linux/mutex.h>
 #include <linux/capability.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -483,7 +484,7 @@
  * just let do_wp_page work it out if a write is requested later - to
  * force COW, vm_page_prot omits write permission from any private vma.
  */
-static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
+void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
 	inc_mm_counter(vma->vm_mm, anon_rss);
@@ -499,72 +500,10 @@
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
-
-static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
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
-
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
 static int unuse_vma(struct vm_area_struct *vma,
 				swp_entry_t entry, struct page *page)
 {
-	pgd_t *pgd;
-	unsigned long addr, end, next;
+	unsigned long addr, end;
 
 	if (page->mapping) {
 		addr = page_address_in_vma(page, vma);
@@ -577,15 +516,7 @@
 		end = vma->vm_end;
 	}
 
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (unuse_pud_range(vma, pgd, addr, next, entry, page))
-			return 1;
-	} while (pgd++, addr = next, addr != end);
-	return 0;
+	return unuse_vma_read_iterator(vma, addr, end, entry, page);
 }
 
 static int unuse_mm(struct mm_struct *mm,
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 21:53:14.552151216 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 22:01:25.216087952 +1000
@@ -1042,3 +1042,82 @@
 
 	return len + old_addr - old_end;	/* how much done */
 }
+
+static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				swp_entry_t entry, struct page *page)
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
+			unuse_pte(vma, pte++, addr, entry, page);
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
+				swp_entry_t entry, struct page *page)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		if (unuse_pte_range(vma, pmd, addr, next, entry, page))
+			return 1;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				swp_entry_t entry, struct page *page)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		if (unuse_pmd_range(vma, pud, addr, next, entry, page))
+			return 1;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int unuse_vma_read_iterator(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end, swp_entry_t entry,
+				struct page *page)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		if (unuse_pud_range(vma, pgd, addr, next, entry, page))
+			return 1;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
