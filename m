From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch 1/2] htlb shared page table
Date: Fri, 29 Sep 2006 17:34:31 -0700
Message-ID: <000101c6e428$31d44ee0$ff0da8c0@amr.corp.intel.com>
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
shared page table for hugetlb memory.  Dave's latest patch restricts the
page table sharing at pmd level in order to simplify some of the complexity
for normal page, but that simplification cuts out all the performance
benefit for hugetlb on x86-64 and ia32.

The following patch attempt to kick that optimization back in for hugetlb
memory and allow pt sharing at second level.  It is nicely self-contained
within hugetlb subsystem.  With no impact to generic VM at all.

Imprecise RSS accounting is an irritating ill effect with pt sharing. 
After consulted with several VM experts, I have tried various methods to
solve that problem: (1) iterate through all mm_structs that share the PT
and increment count; (2) keep RSS count in page table structure and then
sum them up at reporting time.  None of the above methods yield any
satisfactory implementation.

Since process RSS accounting is pure information only, I propose we don't
count them at all for hugetlb page.  rlimit has such field, though there is
absolutely no enforcement on limiting that resource.  One other method is
to account all RSS at hugetlb mmap time regardless they are faulted or not.
I opt for the simplicity of no accounting at all.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./mm/hugetlb.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./mm/hugetlb.c	2006-09-29 14:55:13.000000000 -0700
@@ -379,6 +379,9 @@ void unmap_hugepage_range(struct vm_area
 		if (!ptep)
 			continue;
 
+		if (huge_pte_unshare(mm, &address, ptep))
+			continue;
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (pte_none(pte))
 			continue;
@@ -631,6 +634,8 @@ void hugetlb_change_protection(struct vm
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		if (huge_pte_unshare(mm, &address, ptep))
+			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
--- ./include/linux/hugetlb.h.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./include/linux/hugetlb.h	2006-09-29 14:51:20.000000000 -0700
@@ -34,6 +34,7 @@ extern int sysctl_hugetlb_shm_group;
 
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
+int huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
--- ./arch/i386/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/i386/mm/hugetlbpage.c	2006-09-29 14:55:13.000000000 -0700
@@ -17,6 +17,104 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
+static unsigned long page_table_shareable(struct vm_area_struct *svma,
+			 struct vm_area_struct *vma,
+			 unsigned long addr, unsigned long idx)
+{
+	unsigned long base = addr & PUD_MASK;
+	unsigned long end = base + PUD_SIZE;
+
+	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
+				svma->vm_start;
+	unsigned long sbase = saddr & PUD_MASK;
+	unsigned long s_end = sbase + PUD_SIZE;
+
+	/*
+	 * match the virtual addresses, permission and the alignment of the
+	 * page table page.
+	 */
+	if (pmd_index(addr) != pmd_index(saddr) ||
+	    vma->vm_flags != svma->vm_flags ||
+	    base < vma->vm_start || vma->vm_end < end ||
+	    sbase < svma->vm_start || svma->vm_end < s_end)
+		return 0;
+
+	return saddr;
+}
+
+/*
+ * search for a shareable pmd page for hugetlb.
+ */
+static void huge_pte_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	unsigned long idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			    vma->vm_pgoff;
+	struct prio_tree_iter iter;
+	struct vm_area_struct *svma;
+	unsigned long saddr;
+	pte_t *spte = NULL;
+
+	if (!vma->vm_flags & VM_MAYSHARE)
+		return;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+		if (svma == vma || !down_read_trylock(&svma->vm_mm->mmap_sem))
+			continue;
+
+		saddr = page_table_shareable(svma, vma, addr, idx);
+		if (saddr) {
+			spte = huge_pte_offset(svma->vm_mm, saddr);
+			if (spte)
+				get_page(virt_to_page(spte));
+		}
+		up_read(&svma->vm_mm->mmap_sem);
+		if (spte)
+			break;
+	}
+
+	if (!spte)
+		goto out;
+
+	spin_lock(&mm->page_table_lock);
+	if (pud_none(*pud))
+		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
+	else
+		put_page(virt_to_page(spte));
+	spin_unlock(&mm->page_table_lock);
+out:
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
+/*
+ * unmap huge page backed by shared pte.
+ *
+ * Hugetlb pte page is ref counted at the time of mapping.  If pte is shared
+ * indicated by page_count > 1, unmap is achieved by clearing pud and
+ * decrementing the ref count. If count == 1, the pte page is not shared.
+ * 
+ * called with vma->vm_mm->page_table_lock held.
+ *
+ * returns: 1 successfully unmapped a shared pte page
+ *	    0 the underlying pte page is not shared, or it is the last user
+ */
+int huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	pgd_t *pgd = pgd_offset(mm, *addr);
+	pud_t *pud = pud_offset(pgd, *addr);
+
+	BUG_ON(page_count(virt_to_page(ptep)) == 0);
+	if (page_count(virt_to_page(ptep)) == 1)
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
 	pgd_t *pgd;
@@ -25,8 +123,11 @@ pte_t *huge_pte_alloc(struct mm_struct *
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	if (pud)
+	if (pud) {
+		if (pud_none(*pud))
+			huge_pte_share(mm, addr, pud);
 		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
 	return pte;
--- ./arch/ia64/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/ia64/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
@@ -64,6 +64,12 @@ huge_pte_offset (struct mm_struct *mm, u
 	return pte;
 }
 
+int
+huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 #define mk_pte_huge(entry) { pte_val(entry) |= _PAGE_P; }
 
 /*
--- ./arch/powerpc/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/powerpc/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
@@ -146,6 +146,12 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	return hugepte_offset(hpdp, addr);
 }
 
+int
+huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp)
 {
 	pte_t *hugepte = hugepd_page(*hpdp);
--- ./arch/sparc64/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/sparc64/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
@@ -235,6 +235,12 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int
+huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t entry)
 {
--- ./arch/sh/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/sh/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
@@ -53,6 +53,12 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int
+huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t entry)
 {
--- ./arch/sh64/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
+++ ./arch/sh64/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
@@ -53,6 +53,12 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int
+huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t entry)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
