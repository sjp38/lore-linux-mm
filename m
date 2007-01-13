From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:42 +1100
Message-Id: <20070113024742.29682.76296.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 23/29] Abstract unuse_vma
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 23
 * Move default page table iterator unuse_vma from swapfile.c to pt_default.c
 * Move unuse_pte into pt-iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   21 ++++++++
 mm/pt-default.c                 |   79 ++++++++++++++++++++++++++++++++
 mm/swapfile.c                   |   97 +---------------------------------------
 3 files changed, 104 insertions(+), 93 deletions(-)
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:38:47.456438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:38:51.872438000 +1100
@@ -832,3 +832,82 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
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
Index: linux-2.6.20-rc4/mm/swapfile.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/swapfile.c	2007-01-11 13:30:52.300438000 +1100
+++ linux-2.6.20-rc4/mm/swapfile.c	2007-01-11 13:38:51.876438000 +1100
@@ -27,6 +27,7 @@
 #include <linux/mutex.h>
 #include <linux/capability.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -501,93 +502,10 @@
 }
 #endif
 
-/*
- * No need to decide whether this PTE shares the swap entry with others,
- * just let do_wp_page work it out if a write is requested later - to
- * force COW, vm_page_prot omits write permission from any private vma.
- */
-static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
-		unsigned long addr, swp_entry_t entry, struct page *page)
-{
-	inc_mm_counter(vma->vm_mm, anon_rss);
-	get_page(page);
-	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_anon_rmap(page, vma, addr);
-	swap_free(entry);
-	/*
-	 * Move the page to the active list so it is not
-	 * immediately swapped out again after swapon.
-	 */
-	activate_page(page);
-}
-
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
@@ -600,15 +518,8 @@
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
+	return unuse_vma_read_iterator(vma, addr, end,
+		entry, page);
 }
 
 static int unuse_mm(struct mm_struct *mm,
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:38:47.456438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:38:51.876438000 +1100
@@ -233,3 +233,24 @@
 	(*pages)++;
 	return 0;
 }
+
+/*
+ * No need to decide whether this PTE shares the swap entry with others,
+ * just let do_wp_page work it out if a write is requested later - to
+ * force COW, vm_page_prot omits write permission from any private vma.
+ */
+static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
+		unsigned long addr, swp_entry_t entry, struct page *page)
+{
+	inc_mm_counter(vma->vm_mm, anon_rss);
+	get_page(page);
+	set_pte_at(vma->vm_mm, addr, pte,
+		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	page_add_anon_rmap(page, vma, addr);
+	swap_free(entry);
+	/*
+	 * Move the page to the active list so it is not
+	 * immediately swapped out again after swapon.
+	 */
+	activate_page(page);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
