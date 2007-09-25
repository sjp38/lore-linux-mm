Message-Id: <20070925233006.103775720@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:46 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/14] Move vmalloc_to_page() to mm/vmalloc.
Content-Disposition: inline; filename=vcompound_move_vmalloc_to_page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We already have page table manipulation for vmalloc in vmalloc.c. Move the
vmalloc_to_page() function there as well.

Move the definitions for vmalloc related functions in mm.h to a newly created
section. A better place would be vmalloc.h but mm.h is basic and may depend
on these functions. An alternative would be to include vmalloc.h in mm.h (like done
for vmstat.h).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    5 +++--
 mm/memory.c        |   40 ----------------------------------------
 mm/vmalloc.c       |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 42 deletions(-)

Index: linux-2.6.23-rc8-mm1/mm/memory.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/memory.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/memory.c	2007-09-25 15:14:56.000000000 -0700
@@ -2651,46 +2651,6 @@ int make_pages_present(unsigned long add
 	return ret == len ? 0 : -1;
 }
 
-/* 
- * Map a vmalloc()-space virtual address to the physical page.
- */
-struct page * vmalloc_to_page(void * vmalloc_addr)
-{
-	unsigned long addr = (unsigned long) vmalloc_addr;
-	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
-  
-	if (!pgd_none(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (!pud_none(*pud)) {
-			pmd = pmd_offset(pud, addr);
-			if (!pmd_none(*pmd)) {
-				ptep = pte_offset_map(pmd, addr);
-				pte = *ptep;
-				if (pte_present(pte))
-					page = pte_page(pte);
-				pte_unmap(ptep);
-			}
-		}
-	}
-	return page;
-}
-
-EXPORT_SYMBOL(vmalloc_to_page);
-
-/*
- * Map a vmalloc()-space virtual address to the physical page frame number.
- */
-unsigned long vmalloc_to_pfn(void * vmalloc_addr)
-{
-	return page_to_pfn(vmalloc_to_page(vmalloc_addr));
-}
-
-EXPORT_SYMBOL(vmalloc_to_pfn);
-
 #if !defined(__HAVE_ARCH_GATE_AREA)
 
 #if defined(AT_SYSINFO_EHDR)
Index: linux-2.6.23-rc8-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/vmalloc.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/vmalloc.c	2007-09-25 15:14:56.000000000 -0700
@@ -166,6 +166,44 @@ int map_vm_area(struct vm_struct *area, 
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
 
+/*
+ * Map a vmalloc()-space virtual address to the physical page.
+ */
+struct page *vmalloc_to_page(void *vmalloc_addr)
+{
+	unsigned long addr = (unsigned long) vmalloc_addr;
+	struct page *page = NULL;
+	pgd_t *pgd = pgd_offset_k(addr);
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+
+	if (!pgd_none(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (!pud_none(*pud)) {
+			pmd = pmd_offset(pud, addr);
+			if (!pmd_none(*pmd)) {
+				ptep = pte_offset_map(pmd, addr);
+				pte = *ptep;
+				if (pte_present(pte))
+					page = pte_page(pte);
+				pte_unmap(ptep);
+			}
+		}
+	}
+	return page;
+}
+EXPORT_SYMBOL(vmalloc_to_page);
+
+/*
+ * Map a vmalloc()-space virtual address to the physical page frame number.
+ */
+unsigned long vmalloc_to_pfn(void *vmalloc_addr)
+{
+	return page_to_pfn(vmalloc_to_page(vmalloc_addr));
+}
+EXPORT_SYMBOL(vmalloc_to_pfn);
+
 static struct vm_struct *__get_vm_area_node(unsigned long size, unsigned long flags,
 					    unsigned long start, unsigned long end,
 					    int node, gfp_t gfp_mask)
Index: linux-2.6.23-rc8-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/mm.h	2007-09-25 15:08:14.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/mm.h	2007-09-25 15:16:32.000000000 -0700
@@ -231,6 +231,10 @@ static inline int get_page_unless_zero(s
 	return atomic_inc_not_zero(&page->_count);
 }
 
+/* Support for virtually mapped pages */
+struct page *vmalloc_to_page(void *addr);
+unsigned long vmalloc_to_pfn(void *addr);
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
@@ -1086,8 +1090,6 @@ static inline unsigned long vma_pages(st
 
 pgprot_t vm_get_page_prot(unsigned long vm_flags);
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
-struct page *vmalloc_to_page(void *addr);
-unsigned long vmalloc_to_pfn(void *addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
