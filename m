Date: Mon, 8 Oct 2007 15:52:34 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: [rfc] more granular page table lock for hugepages
Message-ID: <20071008225234.GC27824@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Appended patch is a quick prototype which extends the concept of separate
spinlock per page table page to hugepages. More granular spinlock will
be used to guard the page table entries in the pmd page, instead of using the
mm's single page_table_lock.

For the threaded OLTP workload, this patch showed a 2.4% througput
improvement on a 128GB x86_64 system.

Appended patch is for i386/x86_64 and need more work to make it generic
for all architectures.

Note: To make use of this optimization, pmd page table page need to be
allocated using regular page allocation routines and not through slab cache
(As the spinlock in struct page overlaps with the slab meta-data).
For example, powerpc allocates pmd through the slab cache. Perhaps
we need to change the pmd allocation in powerpc or use the
global page_table_lock for now.

Before we clean it up and make it generic enough to cover all the
architectures supporting hugepages, wanted to run this by the experts
in linux-mm.

Comments?

thanks,
suresh
---
diff --git a/arch/i386/mm/hugetlbpage.c b/arch/i386/mm/hugetlbpage.c
index efdf95a..1d2d3be 100644
--- a/arch/i386/mm/hugetlbpage.c
+++ b/arch/i386/mm/hugetlbpage.c
@@ -117,7 +117,9 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 	if (page_count(virt_to_page(ptep)) == 1)
 		return 0;
 
+	spin_lock(&mm->page_table_lock);
 	pud_clear(pud);
+	spin_unlock(&mm->page_table_lock);
 	put_page(virt_to_page(ptep));
 	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
 	return 1;
@@ -134,7 +136,37 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 	if (pud) {
 		if (pud_none(*pud))
 			huge_pmd_share(mm, addr, pud);
-		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+		if (pud_none(*pud)) {
+			pte = (pte_t *) pmd_alloc(mm, pud, addr);
+			pte_lock_init(virt_to_page(pte));
+		} else
+			pte = (pte_t *) pmd_offset(pud, addr);
+	}
+	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
+
+	return pte;
+}
+
+pte_t *huge_pte_alloc_lock(struct mm_struct *mm, unsigned long addr, spinlock_t **ptlp)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pte_t *pte = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	if (pud) {
+		spinlock_t *ptl;
+		if (pud_none(*pud))
+			huge_pmd_share(mm, addr, pud);
+		if (pud_none(*pud)) {
+			pte = (pte_t *) pmd_alloc(mm, pud, addr);
+			pte_lock_init(virt_to_page(pte));
+		} else
+			pte = (pte_t *) pmd_offset(pud, addr);
+		ptl = pte_lockptr(mm, (pmd_t *)pud);
+		*ptlp = ptl;
+		spin_lock(ptl);
 	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
@@ -156,6 +188,25 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return (pte_t *) pmd;
 }
 
+pte_t *huge_pte_offset_lock(struct mm_struct *mm, unsigned long addr, spinlock_t **ptlp)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (pud_present(*pud)) {
+			spinlock_t *ptl = pte_lockptr(mm, (pmd_t *)pud);
+			*ptlp = ptl;
+			pmd = pmd_offset(pud, addr);
+			spin_lock(ptl);
+		}
+	}
+	return (pte_t *) pmd;
+}
+
 #if 0	/* This is just for testing */
 struct page *
 follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
diff --git a/include/asm-x86_64/pgtable.h b/include/asm-x86_64/pgtable.h
index 0a71e0b..c6271f3 100644
--- a/include/asm-x86_64/pgtable.h
+++ b/include/asm-x86_64/pgtable.h
@@ -345,7 +345,7 @@ static inline int pmd_large(pmd_t pte) {
 
 /* PMD  - Level 2 access */
 #define pmd_page_vaddr(pmd) ((unsigned long) __va(pmd_val(pmd) & PTE_MASK))
-#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#define pmd_page(pmd)		(pfn_to_page(pmd_pfn(pmd)))
 
 #define pmd_index(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 #define pmd_offset(dir, address) ((pmd_t *) pud_page_vaddr(*(dir)) + \
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2c13715..3abcc3f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -35,7 +35,9 @@ extern int sysctl_hugetlb_shm_group;
 /* arch callbacks */
 
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
+pte_t *huge_pte_alloc_lock(struct mm_struct *mm, unsigned long addr, spinlock_t **ptlp);
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
+pte_t *huge_pte_offset_lock(struct mm_struct *mm, unsigned long addr, spinlock_t **ptlp);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a45d1f0..b1d27e7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -344,14 +344,16 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
+		spinlock_t *sptl;
+		spinlock_t *dptl;
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
-		dst_pte = huge_pte_alloc(dst, addr);
+		dst_pte = huge_pte_alloc_lock(dst, addr, &dptl);
 		if (!dst_pte)
 			goto nomem;
-		spin_lock(&dst->page_table_lock);
-		spin_lock(&src->page_table_lock);
+		if (src_pte != dst_pte)
+			huge_pte_offset_lock(src, addr, &sptl);
 		if (!pte_none(*src_pte)) {
 			if (cow)
 				ptep_set_wrprotect(src, addr, src_pte);
@@ -360,8 +362,9 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			get_page(ptepage);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
-		spin_unlock(&src->page_table_lock);
-		spin_unlock(&dst->page_table_lock);
+		if (src_pte != dst_pte)
+			spin_unlock(sptl);
+		spin_unlock(dptl);
 	}
 	return 0;
 
@@ -378,6 +381,8 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 	pte_t pte;
 	struct page *page;
 	struct page *tmp;
+	spinlock_t *ptl;
+
 	/*
 	 * A page gathering list, protected by per file i_mmap_lock. The
 	 * lock is used to avoid list corruption from multiple unmapping
@@ -389,7 +394,6 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
-	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
@@ -398,7 +402,11 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 		if (huge_pmd_unshare(mm, &address, ptep))
 			continue;
 
+		ptep = huge_pte_offset_lock(mm, address, &ptl);
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
+
+		spin_unlock(ptl);
+
 		if (pte_none(pte))
 			continue;
 
@@ -407,7 +415,6 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
 	}
-	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
@@ -438,6 +445,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *old_page, *new_page;
 	int avoidcopy;
+	spinlock_t *ptl;
 
 	old_page = pte_page(pte);
 
@@ -457,11 +465,9 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	}
 
-	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
-	spin_lock(&mm->page_table_lock);
 
-	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
+	ptep = huge_pte_offset_lock(mm, address & HPAGE_MASK, &ptl);
 	if (likely(pte_same(*ptep, pte))) {
 		/* Break COW */
 		set_huge_pte_at(mm, address, ptep,
@@ -471,6 +477,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	page_cache_release(new_page);
 	page_cache_release(old_page);
+	spin_unlock(ptl);
 	return VM_FAULT_MINOR;
 }
 
@@ -483,6 +490,7 @@ int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping;
 	pte_t new_pte;
+	spinlock_t *ptl;
 
 	mapping = vma->vm_file->f_mapping;
 	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
@@ -523,31 +531,32 @@ retry:
 			lock_page(page);
 	}
 
-	spin_lock(&mm->page_table_lock);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
 
 	ret = VM_FAULT_MINOR;
-	if (!pte_none(*ptep))
+	huge_pte_offset_lock(mm, address, &ptl);
+	if (!pte_none(*ptep)) {
+		spin_unlock(ptl);
 		goto backout;
+	}
 
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
 
+	spin_unlock(ptl);
 	if (write_access && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte);
 	}
 
-	spin_unlock(&mm->page_table_lock);
 	unlock_page(page);
 out:
 	return ret;
 
 backout:
-	spin_unlock(&mm->page_table_lock);
 	hugetlb_put_quota(mapping);
 	unlock_page(page);
 	put_page(page);
@@ -561,6 +570,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t entry;
 	int ret;
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
+	spinlock_t *ptl;
 
 	ptep = huge_pte_alloc(mm, address);
 	if (!ptep)
@@ -572,8 +582,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * the same page in the page cache.
 	 */
 	mutex_lock(&hugetlb_instantiation_mutex);
+	ptep = huge_pte_offset_lock(mm, address, &ptl);
 	entry = *ptep;
 	if (pte_none(entry)) {
+		spin_unlock(ptl);
 		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
 		mutex_unlock(&hugetlb_instantiation_mutex);
 		return ret;
@@ -581,12 +593,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	ret = VM_FAULT_MINOR;
 
-	spin_lock(&mm->page_table_lock);
 	/* Check for a racing update before calling hugetlb_cow */
-	if (likely(pte_same(entry, *ptep)))
-		if (write_access && !pte_write(entry))
+	if (likely(pte_same(entry, *ptep))) {
+		if (write_access && !pte_write(entry)) {
+			spin_unlock(ptl);
 			ret = hugetlb_cow(mm, vma, address, ptep, entry);
-	spin_unlock(&mm->page_table_lock);
+		} else
+			spin_unlock(ptl);
+	} else
+		spin_unlock(ptl);
+
 	mutex_unlock(&hugetlb_instantiation_mutex);
 
 	return ret;
@@ -599,8 +615,8 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
 	int remainder = *length;
+	spinlock_t *ptl;
 
-	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
 		struct page *page;
@@ -610,14 +626,14 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * each hugepage.  We have to make * sure we get the
 		 * first, for the page indexing below to work.
 		 */
-		pte = huge_pte_offset(mm, vaddr & HPAGE_MASK);
+		pte = huge_pte_offset_lock(mm, vaddr & HPAGE_MASK, &ptl);
 
 		if (!pte || pte_none(*pte)) {
 			int ret;
 
-			spin_unlock(&mm->page_table_lock);
+			if (pte)
+				spin_unlock(ptl);
 			ret = hugetlb_fault(mm, vma, vaddr, 0);
-			spin_lock(&mm->page_table_lock);
 			if (ret == VM_FAULT_MINOR)
 				continue;
 
@@ -650,8 +666,8 @@ same_page:
 			 */
 			goto same_page;
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	*length = remainder;
 	*position = vaddr;
 
@@ -670,21 +686,23 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
-	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
+		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
 		if (huge_pmd_unshare(mm, &address, ptep))
 			continue;
+
+		ptep = huge_pte_offset_lock(mm, address, &ptl);
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
 			lazy_mmu_prot_update(pte);
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
diff --git a/mm/memory.c b/mm/memory.c
index f64cbf9..1bde136 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2645,6 +2645,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	if (!new)
 		return -ENOMEM;
 
+	pte_lock_init(virt_to_page(new));
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
