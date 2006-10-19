From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch 1/2] shared page table for hugetlb page - v4
Date: Thu, 19 Oct 2006 12:09:02 -0700
Message-ID: <000001c6f3b2$0c70b8c0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Re-diff against git tree as of this morning since some of the changes
were committed for a different reason. No other change from last version.
I was hoping Hugh finds time to review version v4 posted about two weeks
ago.  Though I don't want to wait for too long to rebase. So here we go:


[patch 1/2] shared page table for hugetlb page - v4


Following up with the work on shared page table done by Dave McCracken.
This set of patch target shared page table for hugetlb memory only.

The shared page table is particular useful in the situation of large
number of independent processes sharing large shared memory segments.
In the normal page case, the amount of memory saved from process' page
table is quite significant. For hugetlb, the saving on page table memory
is not the primary objective (as hugetlb itself already cuts down page
table overhead significantly), instead, the purpose of using shared page
table on hugetlb is to allow faster TLB refill and smaller cache pollution
upon TLB miss.

With PT sharing, pte entries are shared among hundreds of processes, the
cache consumption used by all the page table is smaller and in return,
application gets much higher cache hit ratio.  One other effect is that
cache hit ratio with hardware page walker hitting on pte in cache will
be higher and this helps to reduce tlb miss latency.  These two effects
contribute to higher application performance.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./mm/hugetlb.c.orig	2006-10-11 14:58:53.000000000 -0700
+++ ./mm/hugetlb.c	2006-10-19 10:01:43.000000000 -0700
@@ -381,6 +381,9 @@ void __unmap_hugepage_range(struct vm_ar
 		if (!ptep)
 			continue;
 
+		if (huge_pmd_unshare(mm, &address, ptep))
+			continue;
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (pte_none(pte))
 			continue;
@@ -650,11 +653,14 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
+	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
+		if (huge_pmd_unshare(mm, &address, ptep))
+			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
@@ -663,6 +669,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
+	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
 }
--- ./include/linux/hugetlb.h.orig	2006-10-11 14:58:53.000000000 -0700
+++ ./include/linux/hugetlb.h	2006-10-19 10:01:43.000000000 -0700
@@ -35,6 +35,7 @@ extern int sysctl_hugetlb_shm_group;
 
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
--- ./arch/i386/mm/hugetlbpage.c.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/i386/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -17,6 +17,113 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
+static unsigned long page_table_shareable(struct vm_area_struct *svma,
+				struct vm_area_struct *vma,
+				unsigned long addr, pgoff_t idx)
+{
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
+	    sbase < svma->vm_start || svma->vm_end < s_end)
+		return 0;
+
+	return saddr;
+}
+
+static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
+{
+	unsigned long base = addr & PUD_MASK;
+	unsigned long end = base + PUD_SIZE;
+
+	/*
+	 * check on proper vm_flags and page table alignment
+	 */
+	if (vma->vm_flags & VM_MAYSHARE &&
+	    vma->vm_start <= base && end <= vma->vm_end)
+		return 1;
+	return 0;
+}
+
+/*
+ * search for a shareable pmd page for hugetlb.
+ */
+static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			vma->vm_pgoff;
+	struct prio_tree_iter iter;
+	struct vm_area_struct *svma;
+	unsigned long saddr;
+	pte_t *spte = NULL;
+
+	if (!vma_shareable(vma, addr))
+		return;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+		if (svma == vma)
+			continue;
+
+		saddr = page_table_shareable(svma, vma, addr, idx);
+		if (saddr) {
+			spte = huge_pte_offset(svma->vm_mm, saddr);
+			if (spte) {
+				get_page(virt_to_page(spte));
+				break;
+			}
+		}
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
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
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
@@ -25,8 +132,11 @@ pte_t *huge_pte_alloc(struct mm_struct *
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	if (pud)
+	if (pud) {
+		if (pud_none(*pud))
+			huge_pmd_share(mm, addr, pud);
 		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
 	return pte;
--- ./arch/ia64/mm/hugetlbpage.c.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -64,6 +64,11 @@ huge_pte_offset (struct mm_struct *mm, u
 	return pte;
 }
 
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 #define mk_pte_huge(entry) { pte_val(entry) |= _PAGE_P; }
 
 /*
--- ./arch/powerpc/mm/hugetlbpage.c.orig	2006-10-10 19:51:11.000000000 -0700
+++ ./arch/powerpc/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -146,6 +146,11 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	return hugepte_offset(hpdp, addr);
 }
 
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp)
 {
 	pte_t *hugepte = hugepd_page(*hpdp);
--- ./arch/sparc64/mm/hugetlbpage.c.orig	2006-10-10 19:51:11.000000000 -0700
+++ ./arch/sparc64/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -235,6 +235,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t entry)
 {
--- ./arch/sh/mm/hugetlbpage.c.orig	2006-10-10 19:51:11.000000000 -0700
+++ ./arch/sh/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -63,6 +63,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+
 struct page *follow_huge_addr(struct mm_struct *mm,
 			      unsigned long address, int write)
 {
--- ./arch/sh64/mm/hugetlbpage.c.orig	2006-10-10 19:51:11.000000000 -0700
+++ ./arch/sh64/mm/hugetlbpage.c	2006-10-19 10:01:43.000000000 -0700
@@ -53,6 +53,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	return pte;
 }
 
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
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
