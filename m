Message-ID: <491C61B1.10005@goop.org>
Date: Thu, 13 Nov 2008 09:19:45 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

remap_pte_range() just wants to apply a function over a range of ptes
corresponding to a virtual address range.  That's exactly what
apply_to_page_range() does, so use it.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 mm/memory.c |   92 ++++++++++++-----------------------------------------------
 1 file changed, 20 insertions(+), 72 deletions(-)

===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1472,69 +1472,20 @@
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
-/*
- * maps a range of physical memory into the requested pages. the old
- * mappings are removed. any references to nonexistent pages results
- * in null mappings (currently treated as "copy-on-access")
- */
-static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+struct remap_data {
+	struct mm_struct *mm;
+	unsigned long pfn;
+	pgprot_t prot;
+};
+
+static int remap_area_pte_fn(pte_t *ptep, pgtable_t token,
+			     unsigned long addr, void *data)
 {
-	pte_t *pte;
-	spinlock_t *ptl;
+	struct remap_data *rmd = data;
+	pte_t pte = pte_mkspecial(pfn_pte(rmd->pfn++, rmd->prot));
 
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -ENOMEM;
-	arch_enter_lazy_mmu_mode();
-	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
-}
+	set_pte_at(rmd->mm, addr, ptep, pte);
 
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
 	return 0;
 }
 
@@ -1551,10 +1502,9 @@
 int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		    unsigned long pfn, unsigned long size, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
+	struct remap_data rmd;
 	int err;
 
 	/*
@@ -1584,16 +1534,14 @@
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
 	BUG_ON(addr >= end);
-	pfn -= addr >> PAGE_SHIFT;
-	pgd = pgd_offset(mm, addr);
-	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+
+	rmd.mm = mm;
+	rmd.pfn = pfn;
+	rmd.prot = prot;
+
+	err = apply_to_page_range(mm, addr, end - addr,
+				  remap_area_pte_fn, &rmd);
+
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
