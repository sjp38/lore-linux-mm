From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] shared page table for hugetlb page
Date: Wed, 7 Jun 2006 13:51:00 -0700
Message-ID: <000101c68a74$16aeed40$d534030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Taken Hugh's earlier suggestion on making shared page table only for
hugetlb page, I've redone the work and it showed that it is remarkable
small and compact. The whole thing can be done with less than 100 lines.
I think it is definitely worthwhile for the hugetlb page and am pushing
along with the following patch for mainline consideration. The patch is
for em64t. Though, other arch can be filled in easily. x86-64 in general
would benefit the most because hugetlb page on that arch is still
relatively small in demanding environment (64 GB would requires 32,768
of 2MB hugetlb page).

I still need to work on: (1) rss accounting and (2) locking with priority
radix tree. I've confused myself with tree_lock and i_mmap_lock.

For those hugetlb enthusiast out there, please review this as well.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


 arch/i386/mm/hugetlbpage.c |   88 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/hugetlb.c               |   11 +++++
 2 files changed, 98 insertions(+), 1 deletion(-)

diff -Nurp linux-2.6.16/arch/i386/mm/hugetlbpage.c linux-2.6.16.ken/arch/i386/mm/hugetlbpage.c
--- linux-2.6.16/arch/i386/mm/hugetlbpage.c	2006-06-07 08:07:52.000000000 -0700
+++ linux-2.6.16.ken/arch/i386/mm/hugetlbpage.c	2006-06-07 10:44:31.000000000 -0700
@@ -18,16 +18,102 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
+#ifdef CONFIG_X86_64
+int page_table_shareable(struct vm_area_struct *svma,
+			 struct vm_area_struct *vma,
+			 unsigned long addr, unsigned long size)
+{
+	unsigned long base = addr & ~(size - 1);
+	unsigned long end = base + size;
+
+	if (base < vma->vm_start || vma->vm_end < end)
+		return 0;
+
+	if (svma->vm_flags != vma->vm_flags ||
+	    svma->vm_start != vma->vm_start ||
+	    svma->vm_end   != vma->vm_end)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * search for a shareable pmd page for hugetlb.
+ */
+void pmd_share(struct vm_area_struct *vma, pud_t *pud, unsigned long addr)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct prio_tree_iter iter;
+	struct vm_area_struct *svma;
+	pte_t *spte = NULL;
+
+	if (!vma->vm_flags & VM_SHARED)
+		return;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap,
+			      vma->vm_pgoff, vma->vm_pgoff) {
+		if (svma == vma ||
+		    !page_table_shareable(svma, vma, addr, PUD_SIZE))
+			continue;
+
+		spin_lock(&svma->vm_mm->page_table_lock);
+		spte = huge_pte_offset(svma->vm_mm, addr);
+		if (spte)
+			get_page(virt_to_page(spte));
+		spin_unlock(&svma->vm_mm->page_table_lock);
+		if (spte)
+			break;
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+
+	if (!spte)
+		return;
+
+	spin_lock(&vma->vm_mm->page_table_lock);
+	if (pud_none(*pud))
+		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
+	else
+		put_page(virt_to_page(spte));
+	spin_unlock(&vma->vm_mm->page_table_lock);
+}
+
+int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
+{
+	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
+	pud_t *pud = pud_offset(pgd, *addr);
+
+	if (page_count(virt_to_page(ptep)) <= 1)
+		return 0;
+
+	pud_clear(pud);
+	put_page(virt_to_page(ptep));
+	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
+	return 1;
+}
+#else
+void pmd_share(struct vm_area_struct *vma, pud_t *pud, unsigned long addr)
+{
+}
+#endif
+
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 {
+	/*
+	 * to be fixed: pass me the darn vma pointer.
+	 */
+	struct vm_area_struct *vma = find_vma(mm, addr);
 	pgd_t *pgd;
 	pud_t *pud;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	if (pud)
+	if (pud) {
+		if (pud_none(*pud))
+			pmd_share(vma, pud, addr);
 		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
 	return pte;
diff -Nurp linux-2.6.16/mm/hugetlb.c linux-2.6.16.ken/mm/hugetlb.c
--- linux-2.6.16/mm/hugetlb.c	2006-06-07 08:07:54.000000000 -0700
+++ linux-2.6.16.ken/mm/hugetlb.c	2006-06-07 10:22:16.000000000 -0700
@@ -467,6 +467,12 @@ nomem:
 	return -ENOMEM;
 }
 
+__attribute__((weak))
+int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end)
 {
@@ -490,6 +496,9 @@ void unmap_hugepage_range(struct vm_area
 		if (!ptep)
 			continue;
 
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (pte_none(pte))
 			continue;
@@ -742,6 +751,8 @@ void hugetlb_change_protection(struct vm
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
