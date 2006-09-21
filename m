From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] shared page table for hugetlb page - v2
Date: Wed, 20 Sep 2006 17:57:33 -0700
Message-ID: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Following up with the work on shared page table, here is a re-post of
shared page table for hugetlb memory.  Dave's latest patch restricts
the page table sharing at pmd level in order to simplify some of the
complexity for normal page, but that simplification cuts out all the
performance benefit for hugetlb on x86-64 and ia32.

The following patch attempt to kick that optimization back in for hugetlb
memory and allow pt sharing at second level.  It is nicely self-contained
within hugetlb subsystem.  With no impact to generic VM at all, I think
this patch is ready for mainline consideration.

Imprecise RSS accounting is an irritating ill effect with pt sharing.
After consulted with several VM experts, I have tried various methods to
solve that problem: (1) iterate through all mm_structs that share the PT
and increment count; (2) keep RSS count in page table structure and then
sum them up at reporting time. None of the above methods yield any
satisfactory implementation.

Since process RSS accounting is pure information only, I propose we don't
count them at all for hugetlb page. rlimit has such field, though there is
absolutely no enforcement on limiting that resource. One other method is
to account all RSS at hugetlb mmap time regardless they are faulted or not.
I opt for the simplicity of no accounting at all.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


 arch/i386/mm/hugetlbpage.c |   79 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/hugetlb.c               |   14 ++++++-
 2 files changed, 89 insertions(+), 4 deletions(-)

--- ./mm/hugetlb.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./mm/hugetlb.c	2006-09-20 15:36:28.000000000 -0700
@@ -344,7 +344,6 @@
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			add_mm_counter(dst, file_rss, HPAGE_SIZE / PAGE_SIZE);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(&src->page_table_lock);
@@ -356,6 +355,12 @@
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
@@ -379,13 +384,15 @@
 		if (!ptep)
 			continue;
 
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (pte_none(pte))
 			continue;
 
 		page = pte_page(pte);
 		put_page(page);
-		add_mm_counter(mm, file_rss, (int) -(HPAGE_SIZE / PAGE_SIZE));
 	}
 
 	spin_unlock(&mm->page_table_lock);
@@ -488,7 +495,6 @@
 	if (!pte_none(*ptep))
 		goto backout;
 
-	add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
@@ -631,6 +637,8 @@
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		if (huge_pte_put(vma, &address, ptep))
+			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
--- ./arch/i386/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/i386/mm/hugetlbpage.c	2006-09-20 09:38:54.000000000 -0700
@@ -17,16 +17,93 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
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
+
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 {
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
