From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:26 +1100
Message-Id: <20070113024726.29682.71586.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 20/29] Abstract change protection iterator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 20
 * Move default change_protection iterator implementation from mprotect.c to
 pt-default.c
 * Abstract an operator function, change_prot_pte and place this function
 into pt-iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   44 ++++++++++++++++++
 mm/mprotect.c                   |   94 +---------------------------------------
 mm/pt-default.c                 |   66 ++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+), 91 deletions(-)
Index: linux-2.6.20-rc4/mm/mprotect.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/mprotect.c	2007-01-11 13:30:52.468438000 +1100
+++ linux-2.6.20-rc4/mm/mprotect.c	2007-01-11 13:37:59.472438000 +1100
@@ -21,110 +21,22 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/pt.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
-{
-	pte_t *pte, oldpte;
-	spinlock_t *ptl;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	arch_enter_lazy_mmu_mode();
-	do {
-		oldpte = *pte;
-		if (pte_present(oldpte)) {
-			pte_t ptent;
-
-			/* Avoid an SMP race with hardware updated dirty/clean
-			 * bits by wiping the pte and then setting the new pte
-			 * into place.
-			 */
-			ptent = ptep_get_and_clear(mm, addr, pte);
-			ptent = pte_modify(ptent, newprot);
-			/*
-			 * Avoid taking write faults for pages we know to be
-			 * dirty.
-			 */
-			if (dirty_accountable && pte_dirty(ptent))
-				ptent = pte_mkwrite(ptent);
-			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
-#ifdef CONFIG_MIGRATION
-		} else if (!pte_file(oldpte)) {
-			swp_entry_t entry = pte_to_swp_entry(oldpte);
-
-			if (is_write_migration_entry(entry)) {
-				/*
-				 * A protection check is difficult so
-				 * just be safe and disable write
-				 */
-				make_migration_entry_read(&entry);
-				set_pte_at(mm, addr, pte,
-					swp_entry_to_pte(entry));
-			}
-#endif
-		}
-
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-}
-
-static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		change_pmd_range(mm, pud, addr, next, newprot, dirty_accountable);
-	} while (pud++, addr = next, addr != end);
-}
-
 static void change_protection(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
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
-		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
-	} while (pgd++, addr = next, addr != end);
+	change_protection_read_iterator(vma, addr, end, newprot, dirty_accountable);
 	flush_tlb_range(vma, start, end);
 }
 
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:37:53.612438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:37:59.476438000 +1100
@@ -1,3 +1,5 @@
+#include <linux/rmap.h>
+#include <asm/tlb.h>
 
 static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
 {
@@ -166,3 +168,45 @@
 	BUG_ON(!pte_none(*pte));
 	set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
 }
+
+static inline void
+change_prot_pte(struct mm_struct *mm, pte_t *pte,
+	unsigned long addr, pgprot_t newprot, int dirty_accountable)
+
+{
+	pte_t oldpte;
+	oldpte = *pte;
+
+	if (pte_present(oldpte)) {
+		pte_t ptent;
+
+		/* Avoid an SMP race with hardware updated dirty/clean
+		 * bits by wiping the pte and then setting the new pte
+		 * into place.
+		 */
+		ptent = ptep_get_and_clear(mm, addr, pte);
+		ptent = pte_modify(ptent, newprot);
+		/*
+		 * Avoid taking write faults for pages we know to be
+		 * dirty.
+		 */
+		if (dirty_accountable && pte_dirty(ptent))
+			ptent = pte_mkwrite(ptent);
+		set_pte_at(mm, addr, pte, ptent);
+		lazy_mmu_prot_update(ptent);
+#ifdef CONFIG_MIGRATION
+	} else if (!pte_file(oldpte)) {
+		swp_entry_t entry = pte_to_swp_entry(oldpte);
+
+		if (is_write_migration_entry(entry)) {
+			/*
+			 * A protection check is difficult so
+			 * just be safe and disable write
+			 */
+			make_migration_entry_read(&entry);
+			set_pte_at(mm, addr, pte,
+				swp_entry_to_pte(entry));
+		}
+#endif
+	}
+}
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:37:53.600438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:37:59.476438000 +1100
@@ -644,3 +644,69 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	do {
+		change_prot_pte(mm, pte, addr, newprot, dirty_accountable);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+}
+
+static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		change_pmd_range(mm, pud, addr, next, newprot, dirty_accountable);
+	} while (pud++, addr = next, addr != end);
+}
+
+void change_protection_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable)
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
+		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
+	} while (pgd++, addr = next, addr != end);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
