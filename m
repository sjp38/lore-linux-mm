Date: Fri, 11 Oct 2002 12:10:38 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.41-mm3] Fix unmap for shared page tables
Message-ID: <65780000.1034356238@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1870079384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========1870079384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


I realized I got the unmap code wrong for shared page tables.  Here's a
patch that fixes the problem plus optimizes the exit case.  It should also
fix Paul Larson's BUG().

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1870079384==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.41-mm3-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.41-mm3-1.diff"; size=9432

--- 2.5.41-mm3/./mm/mmap.c	2002-10-11 10:54:43.000000000 -0500
+++ 2.5.41-mm3-shpte/./mm/mmap.c	2002-10-11 11:34:24.000000000 -0500
@@ -24,7 +24,10 @@
 #include <asm/tlb.h>
=20
 extern void unmap_page_range(mmu_gather_t *,struct vm_area_struct *vma, =
unsigned long address, unsigned long size);
-extern void unmap_all_pages(mmu_gather_t *tlb, struct mm_struct *mm, =
unsigned long address, unsigned long end);
+#ifdef CONFIG_SHAREPTE
+extern void unmap_shared_range(struct mm_struct *mm, unsigned long =
address, unsigned long end);
+#endif
+extern void unmap_all_pages(struct mm_struct *mm);
 extern void clear_page_tables(mmu_gather_t *tlb, unsigned long first, int =
nr);
=20
 /*
@@ -984,6 +987,10 @@
 {
 	mmu_gather_t *tlb;
=20
+#ifdef CONFIG_SHAREPTE
+	/* Make sure all the pte pages in the range are unshared if necessary */
+	unmap_shared_range(mm, start, end);
+#endif
 	tlb =3D tlb_gather_mmu(mm, 0);
=20
 	do {
@@ -1267,9 +1274,7 @@
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct * mm)
 {
-	mmu_gather_t *tlb;
 	struct vm_area_struct * mpnt;
-	int unmap_vma =3D mm->total_vm < UNMAP_THRESHOLD;
=20
 	profile_exit_mmap(mm);
 =20
@@ -1277,39 +1282,14 @@
 =20
 	spin_lock(&mm->page_table_lock);
=20
-	tlb =3D tlb_gather_mmu(mm, 1);
-
 	flush_cache_mm(mm);
-	mpnt =3D mm->mmap;
-	while (mpnt) {
-		unsigned long start =3D mpnt->vm_start;
-		unsigned long end =3D mpnt->vm_end;
=20
-		/*
-		 * If the VMA has been charged for, account for its
-		 * removal
-		 */
-		if (mpnt->vm_flags & VM_ACCOUNT)
-			vm_unacct_memory((end - start) >> PAGE_SHIFT);
-
-		mm->map_count--;
-		if (is_vm_hugetlb_page(mpnt))
-			mpnt->vm_ops->close(mpnt);
-		else if (unmap_vma)
-			unmap_page_range(tlb, mpnt, start, end);
-		mpnt =3D mpnt->vm_next;
-	}
+	unmap_all_pages(mm);
=20
 	/* This is just debugging */
 	if (mm->map_count)
 		BUG();
=20
-	if (!unmap_vma)
-		unmap_all_pages(tlb, mm, 0, TASK_SIZE);
-
-	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
-	tlb_finish_mmu(tlb, 0, TASK_SIZE);
-
 	mpnt =3D mm->mmap;
 	mm->mmap =3D mm->mmap_cache =3D NULL;
 	mm->mm_rb =3D RB_ROOT;
@@ -1325,6 +1305,14 @@
 	 */
 	while (mpnt) {
 		struct vm_area_struct * next =3D mpnt->vm_next;
+
+		/*
+		 * If the VMA has been charged for, account for its
+		 * removal
+		 */
+		if (mpnt->vm_flags & VM_ACCOUNT)
+			vm_unacct_memory((mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT);
+
 		remove_shared_vm_struct(mpnt);
 		if (mpnt->vm_ops) {
 			if (mpnt->vm_ops->close)
--- 2.5.41-mm3/./mm/memory.c	2002-10-11 10:54:43.000000000 -0500
+++ 2.5.41-mm3-shpte/./mm/memory.c	2002-10-11 10:59:14.000000000 -0500
@@ -267,26 +267,34 @@
 	base =3D addr =3D oldpage->index;
 	page_end =3D base + PMD_SIZE;
 	vma =3D find_vma(mm, base);
-	if (!vma || (page_end <=3D vma->vm_start))
-		BUG(); 		/* No valid pages in this pte page */
=20
 	src_unshare =3D page_count(oldpage) =3D=3D 2;
 	dst_ptb =3D pte_page_map(newpage, base);
 	src_ptb =3D pte_page_map_nested(oldpage, base);
=20
-	if (vma->vm_start > addr)
-		addr =3D vma->vm_start;
+	if (page_end <=3D vma->vm_start)
+		vma =3D NULL;
=20
-	if (vma->vm_end < page_end)
-		end =3D vma->vm_end;
-	else
-		end =3D page_end;
+	if (vma) {
+		if (vma->vm_start > addr)
+			addr =3D vma->vm_start;
+
+		if (vma->vm_end < page_end)
+			end =3D vma->vm_end;
+		else
+			end =3D page_end;
+	} else {
+		addr =3D end =3D page_end;
+	}
=20
 	do {
-		unsigned int cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D =
VM_MAYWRITE;
+		unsigned int cow =3D 0;
 		pte_t *src_pte =3D src_ptb + __pte_offset(addr);
 		pte_t *dst_pte =3D dst_ptb + __pte_offset(addr);
=20
+		if (vma)
+			cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D VM_MAYWRITE;
+
 		do {
 			pte_t pte =3D *src_pte;
 			struct page *page;
@@ -637,9 +645,71 @@
 }
 #endif
=20
-static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
+#ifdef CONFIG_SHAREPTE
+static inline void unmap_shared_pmd(struct mm_struct *mm, pgd_t *pgd,
+				    unsigned long address, unsigned long end)
 {
 	struct page *ptepage;
+	pmd_t * pmd;
+
+	if (pgd_none(*pgd))
+		return;
+	if (pgd_bad(*pgd)) {
+		pgd_ERROR(*pgd);
+		pgd_clear(pgd);
+		return;
+	}
+	pmd =3D pmd_offset(pgd, address);
+	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
+		end =3D ((address + PGDIR_SIZE) & PGDIR_MASK);
+	do {
+		if (pmd_none(*pmd))
+			goto skip_pmd;
+		if (pmd_bad(*pmd)) {
+			pmd_ERROR(*pmd);
+			pmd_clear(pmd);
+			goto skip_pmd;
+		}
+
+		ptepage =3D pmd_page(*pmd);
+		pte_page_lock(ptepage);
+
+		if (page_count(ptepage) > 1) {
+			if ((address <=3D ptepage->index) &&
+			    (end >=3D (ptepage->index + PMD_SIZE))) {
+				pmd_clear(pmd);
+				pgtable_remove_rmap_locked(ptepage, mm);
+				mm->rss -=3D ptepage->private;
+				put_page(ptepage);
+			} else {
+				pte_unshare(mm, pmd, address);
+				ptepage =3D pmd_page(*pmd);
+			}
+		}
+		pte_page_unlock(ptepage);
+skip_pmd:
+		address =3D (address + PMD_SIZE) & PMD_MASK;=20
+		pmd++;
+	} while (address < end);
+}
+
+void unmap_shared_range(struct mm_struct *mm, unsigned long address, =
unsigned long end)
+{
+	pgd_t * pgd;
+
+	if (address >=3D end)
+		BUG();
+	pgd =3D pgd_offset(mm, address);
+	do {
+		unmap_shared_pmd(mm, pgd, address, end - address);
+		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+		pgd++;
+	} while (address && (address < end));
+}
+#endif
+
+static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
+{
 	unsigned long offset;
 	pte_t *ptep;
=20
@@ -656,29 +726,7 @@
 		size =3D PMD_SIZE - offset;
 	size &=3D PAGE_MASK;
=20
-	/*
-	 * Check to see if the pte page is shared.  If it is and we're unmapping
-	 * the entire page, just decrement the reference count and we're done.
-	 * If we're only unmapping part of the page we'll have to unshare it the
-	 * slow way.
-	 */
-	ptepage =3D pmd_page(*pmd);
-	pte_page_lock(ptepage);
-#ifdef CONFIG_SHAREPTE
-	if (page_count(ptepage) > 1) {
-		if ((offset =3D=3D 0) && (size =3D=3D PMD_SIZE)) {
-			pmd_clear(pmd);
-			pgtable_remove_rmap_locked(ptepage, tlb->mm);
-			tlb->mm->rss -=3D ptepage->private;
-			put_page(ptepage);
-			pte_page_unlock(ptepage);
-			return;
-		}
-		ptep =3D pte_unshare(tlb->mm, pmd, address);
-		ptepage =3D pmd_page(*pmd);
-	} else
-#endif
-		ptep =3D pte_offset_map(pmd, address);
+	ptep =3D pte_offset_map(pmd, address);
=20
 	for (offset=3D0; offset < size; ptep++, offset +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
@@ -707,12 +755,12 @@
 			pte_clear(ptep);
 		}
 	}
-	pte_page_unlock(ptepage);
 	pte_unmap(ptep-1);
 }
=20
 static void zap_pmd_range(mmu_gather_t *tlb, pgd_t * dir, unsigned long =
address, unsigned long size)
 {
+	struct page *ptepage;
 	pmd_t * pmd;
 	unsigned long end;
=20
@@ -728,7 +776,14 @@
 	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
 		end =3D ((address + PGDIR_SIZE) & PGDIR_MASK);
 	do {
+		ptepage =3D pmd_page(*pmd);
+		pte_page_lock(ptepage);
+#ifdef CONFIG_SHAREPTE
+		if (page_count(ptepage) > 1)
+			BUG();
+#endif
 		zap_pte_range(tlb, pmd, address, end - address);
+		pte_page_unlock(ptepage);
 		address =3D (address + PMD_SIZE) & PMD_MASK;=20
 		pmd++;
 	} while (address < end);
@@ -779,6 +834,9 @@
=20
 	spin_lock(&mm->page_table_lock);
=20
+#ifdef CONFIG_SHAREPTE
+	unmap_shared_range(mm, address, address + size);
+#endif
   	/*
  	 * This was once a long-held spinlock.  Now we break the
  	 * work up into ZAP_BLOCK_SIZE units and relinquish the
@@ -803,19 +861,85 @@
 	spin_unlock(&mm->page_table_lock);
 }
=20
-void unmap_all_pages(mmu_gather_t *tlb, struct mm_struct *mm, unsigned =
long address, unsigned long end)
+void unmap_all_pages(struct mm_struct *mm)
 {
-	pgd_t * dir;
+	struct vm_area_struct *vma;
+	struct page *ptepage;
+	mmu_gather_t *tlb;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	unsigned long address;
+	unsigned long end;
=20
-	if (address >=3D end)
-		BUG();
-	dir =3D pgd_offset(mm, address);
+	tlb =3D tlb_gather_mmu(mm, 1);
+
+	vma =3D mm->mmap;
+	if (!vma)
+		goto out;
+
+	mm->map_count--;
+	if (is_vm_hugetlb_page(vma)) {
+		vma->vm_ops->close(vma);
+		goto next_vma;
+	}
+
+	address =3D vma->vm_start;
+	end =3D ((address + PGDIR_SIZE) & PGDIR_MASK);
+
+	pgd =3D pgd_offset(mm, address);
+	pmd =3D pmd_offset(pgd, address);
 	do {
-		zap_pmd_range(tlb, dir, address, end - address);
-		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+		do {
+			if (pmd_none(*pmd))
+				goto skip_pmd;
+			if (pmd_bad(*pmd)) {
+				pmd_ERROR(*pmd);
+				pmd_clear(pmd);
+				goto skip_pmd;
+			}
+		
+			ptepage =3D pmd_page(*pmd);
+			pte_page_lock(ptepage);
+			if (page_count(ptepage) > 1) {
+				pmd_clear(pmd);
+				pgtable_remove_rmap_locked(ptepage, mm);
+				mm->rss -=3D ptepage->private;
+				put_page(ptepage);
+			} else {
+				zap_pte_range(tlb, pmd, address, end - address);
+			}
+			pte_page_unlock(ptepage);
+skip_pmd:
+			pmd++;
+			address =3D (address + PMD_SIZE) & PMD_MASK;
+			if (address >=3D vma->vm_end) {
+next_vma:
+				vma =3D vma->vm_next;
+				if (!vma)
+					goto out;
+
+				mm->map_count--;
+				if (is_vm_hugetlb_page(vma)) {
+					vma->vm_ops->close(vma);
+					goto next_vma;
+				}
+
+				address =3D vma->vm_start;
+				end =3D ((address + PGDIR_SIZE) & PGDIR_MASK);
+				pgd =3D pgd_offset(mm, address);
+				pmd =3D pmd_offset(pgd, address);
+			}
+		} while (address < end);
+		pgd++;
+		pmd =3D pmd_offset(pgd, address);
+		end =3D ((address + PGDIR_SIZE) & PGDIR_MASK);
+	} while (vma);
+
+out:
+	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
+	tlb_finish_mmu(tlb, 0, TASK_SIZE);
 }
+
 /*
  * Do a quick page-table lookup for a single page.
  * mm->page_table_lock must be held.

--==========1870079384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
