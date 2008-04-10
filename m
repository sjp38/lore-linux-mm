From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/8] alpha: mem_map/max_mapnr -- init is FLATMEM use correct defines
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:40:50 +0100
Message-Id: <1207824050.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The alpha init.c implementation of mem_init is specifically a FLATMEM
implementation, use the correct config option.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/alpha/mm/init.c        |    4 ++--
 include/asm-alpha/mmzone.h  |    2 --
 include/asm-alpha/pgtable.h |    4 ++--
 3 files changed, 4 insertions(+), 6 deletions(-)
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 234e42b..9a4e669 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -277,7 +277,7 @@ srm_paging_stop (void)
 }
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 static void __init
 printk_memory_info(void)
 {
@@ -317,7 +317,7 @@ mem_init(void)
 
 	printk_memory_info();
 }
-#endif /* CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 void
 free_reserved_mem(void *start, void *end)
diff --git a/include/asm-alpha/mmzone.h b/include/asm-alpha/mmzone.h
index 8af56ce..8bfb3b2 100644
--- a/include/asm-alpha/mmzone.h
+++ b/include/asm-alpha/mmzone.h
@@ -72,8 +72,6 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p, int n)
 
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
-#define VALID_PAGE(page)	(((page) - mem_map) < max_mapnr)
-
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> 32))
 #define pgd_page(pgd)		(pfn_to_page(pgd_val(pgd) >> 32))
 #define pte_pfn(pte)		(pte_val(pte) >> 32)
diff --git a/include/asm-alpha/pgtable.h b/include/asm-alpha/pgtable.h
index 99037b0..665ba5c 100644
--- a/include/asm-alpha/pgtable.h
+++ b/include/asm-alpha/pgtable.h
@@ -202,7 +202,7 @@ extern unsigned long __zero_page(void);
  * Conversion functions:  convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  */
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 #define page_to_pa(page)	(((page) - mem_map) << PAGE_SHIFT)
 
 #define pte_pfn(pte)	(pte_val(pte) >> 32)
@@ -235,7 +235,7 @@ pmd_page_vaddr(pmd_t pmd)
 	return ((pmd_val(pmd) & _PFN_MASK) >> (32-PAGE_SHIFT)) + PAGE_OFFSET;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 #define pmd_page(pmd)	(mem_map + ((pmd_val(pmd) & _PFN_MASK) >> 32))
 #define pgd_page(pgd)	(mem_map + ((pgd_val(pgd) & _PFN_MASK) >> 32))
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
