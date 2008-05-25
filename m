Message-Id: <20080525143453.701909000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:32 +1000
From: npiggin@suse.de
Subject: [patch 15/23] x86: support GB hugepages on 64-bit
Content-Disposition: inline; filename=x86-support-GB-hugetlb-pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

---
 arch/x86/mm/hugetlbpage.c |   33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -133,9 +133,14 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
-		if (pud_none(*pud))
-			huge_pmd_share(mm, addr, pud);
-		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+		if (sz == PUD_SIZE) {
+			pte = (pte_t *)pud;
+		} else {
+			BUG_ON(sz != PMD_SIZE);
+			if (pud_none(*pud))
+				huge_pmd_share(mm, addr, pud);
+			pte = (pte_t *) pmd_alloc(mm, pud, addr);
+		}
 	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
@@ -151,8 +156,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_present(*pgd)) {
 		pud = pud_offset(pgd, addr);
-		if (pud_present(*pud))
+		if (pud_present(*pud)) {
+			if (pud_large(*pud))
+				return (pte_t *)pud;
 			pmd = pmd_offset(pud, addr);
+		}
 	}
 	return (pte_t *) pmd;
 }
@@ -215,7 +223,7 @@ int pmd_huge(pmd_t pmd)
 
 int pud_huge(pud_t pud)
 {
-	return 0;
+	return !!(pud_val(pud) & _PAGE_PSE);
 }
 
 struct page *
@@ -251,6 +259,7 @@ static unsigned long hugetlb_get_unmappe
 		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long start_addr;
@@ -263,7 +272,7 @@ static unsigned long hugetlb_get_unmappe
 	}
 
 full_search:
-	addr = ALIGN(start_addr, HPAGE_SIZE);
+	addr = ALIGN(start_addr, huge_page_size(h));
 
 	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
@@ -285,7 +294,7 @@ full_search:
 		}
 		if (addr + mm->cached_hole_size < vma->vm_start)
 		        mm->cached_hole_size = vma->vm_start - addr;
-		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
+		addr = ALIGN(vma->vm_end, huge_page_size(h));
 	}
 }
 
@@ -293,6 +302,7 @@ static unsigned long hugetlb_get_unmappe
 		unsigned long addr0, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev_vma;
 	unsigned long base = mm->mmap_base, addr = addr0;
@@ -313,7 +323,7 @@ try_again:
 		goto fail;
 
 	/* either no address requested or cant fit in requested address hole */
-	addr = (mm->free_area_cache - len) & HPAGE_MASK;
+	addr = (mm->free_area_cache - len) & huge_page_mask(h);
 	do {
 		/*
 		 * Lookup failure means no vma is above this address,
@@ -344,7 +354,7 @@ try_again:
 		        largest_hole = vma->vm_start - addr;
 
 		/* try just below the current vma->vm_start */
-		addr = (vma->vm_start - len) & HPAGE_MASK;
+		addr = (vma->vm_start - len) & huge_page_mask(h);
 	} while (len <= vma->vm_start);
 
 fail:
@@ -382,10 +392,11 @@ unsigned long
 hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 
-	if (len & ~HPAGE_MASK)
+	if (len & ~huge_page_mask(h))
 		return -EINVAL;
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -397,7 +408,7 @@ hugetlb_get_unmapped_area(struct file *f
 	}
 
 	if (addr) {
-		addr = ALIGN(addr, HPAGE_SIZE);
+		addr = ALIGN(addr, huge_page_size(h));
 		vma = find_vma(mm, addr);
 		if (TASK_SIZE - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
