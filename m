From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:31 +1100
Message-Id: <20070113024731.29682.91008.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 21/29] Abstract unmap vm area
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 21
 * Move default page table iterator, vunmap_read_iterator, from vmalloc.c
 to pt_default.c
 * Abstract the operation performed by this iterator into vunmap-one_pte and
 put it in pt-iterator-ops.h
 * Place inclusion guards in swapops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |    9 ++++++
 include/linux/swapops.h         |    4 ++
 mm/pt-default.c                 |   55 ++++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c                    |   52 +------------------------------------
 4 files changed, 70 insertions(+), 50 deletions(-)
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:37:59.476438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:38:30.348438000 +1100
@@ -1,4 +1,6 @@
 #include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 #include <asm/tlb.h>
 
 static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
@@ -210,3 +212,10 @@
 #endif
 	}
 }
+
+static inline void
+vunmap_one_pte(pte_t *pte, unsigned long address)
+{
+	pte_t ptent = ptep_get_and_clear(&init_mm, address, pte);
+	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
+}
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:37:59.476438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:38:30.352438000 +1100
@@ -710,3 +710,58 @@
 		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
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
Index: linux-2.6.20-rc4/mm/vmalloc.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/vmalloc.c	2007-01-11 13:30:52.416438000 +1100
+++ linux-2.6.20-rc4/mm/vmalloc.c	2007-01-11 13:38:30.352438000 +1100
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 
 #include <linux/vmalloc.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
@@ -27,63 +28,14 @@
 static void *__vmalloc_node(unsigned long size, gfp_t gfp_mask, pgprot_t prot,
 			    int node);
 
-static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
-{
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
-}
-
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
 
Index: linux-2.6.20-rc4/include/linux/swapops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/swapops.h	2007-01-11 13:37:20.448438000 +1100
+++ linux-2.6.20-rc4/include/linux/swapops.h	2007-01-11 13:38:30.352438000 +1100
@@ -1,3 +1,6 @@
+#ifndef _LINUX_SWAPOPS_H
+#define _LINUX_SWAPOPS_H
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -122,3 +125,4 @@
 
 #endif
 
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
