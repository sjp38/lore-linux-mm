Date: Thu, 10 Oct 2002 12:27:19 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.41-mm1] new snapshot of shared page tables
Message-ID: <101620000.1034270839@baldur.austin.ibm.com>
In-Reply-To: <3DA4B2E3.4FB3BC52@digeo.com>
References: <228900000.1034197657@baldur.austin.ibm.com>
 <3DA4B2E3.4FB3BC52@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1905909384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1905909384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Wednesday, October 09, 2002 15:51:15 -0700 Andrew Morton
<akpm@digeo.com> wrote:

> Stylistic trivia: When stubbing out a function it's cleaner (and faster)
> to do:
> 
># ifdef CONFIG_FOO
> int my_function(arg1, arg2)
> {
> 	...
> }
># else
> static inline int my_function(arg1, arg2)
> {
> 	return 0;
> }
># endif

I'll go one better and remove the function and the references to it, if
that's cleaner.  It feels cleaner to me.  Here's a patch that does it, on
top of 2.5.41-mm2.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1905909384==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.41-mm2-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.41-mm2-1.diff"; size=3968

--- 2.5.41-mm2/./include/linux/mm.h	2002-10-10 10:17:56.000000000 -0500
+++ 2.5.41-mm2-shpte/./include/linux/mm.h	2002-10-10 10:34:58.000000000 =
-0500
@@ -359,8 +359,11 @@
 extern int shmem_zero_setup(struct vm_area_struct *);
=20
 extern void zap_page_range(struct vm_area_struct *vma, unsigned long =
address, unsigned long size);
-extern int copy_page_range(struct mm_struct *dst, struct mm_struct *src, =
struct vm_area_struct *vma);
+#ifdef CONFIG_SHAREPTE
 extern int share_page_range(struct mm_struct *dst, struct mm_struct *src, =
struct vm_area_struct *vma, pmd_t **prev_pmd);
+#else
+extern int copy_page_range(struct mm_struct *dst, struct mm_struct *src, =
struct vm_area_struct *vma);
+#endif
 extern int remap_page_range(struct vm_area_struct *vma, unsigned long =
from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(struct vm_area_struct *vma, unsigned long =
from, unsigned long size, pgprot_t prot);
=20
--- 2.5.41-mm2/./mm/memory.c	2002-10-10 10:17:57.000000000 -0500
+++ 2.5.41-mm2-shpte/./mm/memory.c	2002-10-10 10:35:34.000000000 -0500
@@ -153,6 +153,7 @@
 	} while (--nr);
 }
=20
+#ifdef CONFIG_SHAREPTE
 /*
  * This function makes the decision whether a pte page needs to be =
unshared
  * or not.  Note that page_count() =3D=3D 1 isn't even tested here.  The =
assumption
@@ -166,7 +167,6 @@
 static inline int pte_needs_unshare(struct mm_struct *mm, struct =
vm_area_struct *vma,
 				    pmd_t *pmd, unsigned long address, int write_access)
 {
-#ifdef CONFIG_SHAREPTE
 	struct page *ptepage;
=20
 	/* It's not even there, nothing to unshare. */
@@ -198,9 +198,6 @@
 	 * Ok, we have to unshare.
 	 */
 	return 1;
-#else
-	return 0;
-#endif
 }
=20
 /*
@@ -223,7 +220,6 @@
=20
 static pte_t *pte_unshare(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
 {
-#ifdef CONFIG_SHAREPTE
 	pte_t	*src_ptb, *dst_ptb;
 	struct page *oldpage, *newpage, *tmppage;
 	struct vm_area_struct *vma;
@@ -359,9 +355,9 @@
 	return dst_ptb + __pte_offset(address);
=20
 out_map:
-#endif
 	return pte_offset_map(pmd, address);
 }
+#endif
=20
 pte_t * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
 {
@@ -417,10 +413,10 @@
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
 #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
=20
+#ifdef CONFIG_SHAREPTE
 int share_page_range(struct mm_struct *dst, struct mm_struct *src,
 	struct vm_area_struct *vma, pmd_t **prev_pmd)
 {
-#ifdef CONFIG_SHAREPTE
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long address =3D vma->vm_start;
 	unsigned long end =3D vma->vm_end;
@@ -505,10 +501,9 @@
 out:
 	return 0;
 nomem:
-#endif
 	return -ENOMEM;
 }
-
+#else
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
@@ -640,6 +635,7 @@
 nomem:
 	return -ENOMEM;
 }
+#endif
=20
 static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
 {
@@ -668,6 +664,7 @@
 	 */
 	ptepage =3D pmd_page(*pmd);
 	pte_page_lock(ptepage);
+#ifdef CONFIG_SHAREPTE
 	if (page_count(ptepage) > 1) {
 		if ((offset =3D=3D 0) && (size =3D=3D PMD_SIZE)) {
 			pmd_clear(pmd);
@@ -679,9 +676,10 @@
 		}
 		ptep =3D pte_unshare(tlb->mm, pmd, address);
 		ptepage =3D pmd_page(*pmd);
-	} else {
+	} else
+#endif
 		ptep =3D pte_offset_map(pmd, address);
-	}
+
 	for (offset=3D0; offset < size; ptep++, offset +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
 		if (pte_none(pte))
@@ -1839,6 +1837,7 @@
 	if (pmd) {
 		pte_t * pte;
=20
+#ifdef CONFIG_SHAREPTE
 		if (pte_needs_unshare(mm, vma, pmd, address, write_access)) {
 			pte_page_lock(pmd_page(*pmd));
 			pte =3D pte_unshare(mm, pmd, address);
@@ -1846,7 +1845,10 @@
 			pte =3D pte_alloc_map(mm, pmd, address);
 			pte_page_lock(pmd_page(*pmd));
 		}
-
+#else
+		pte =3D pte_alloc_map(mm, pmd, address);
+		pte_page_lock(pmd_page(*pmd));
+#endif
 		if (pte) {
 			spin_unlock(&mm->page_table_lock);
 			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);

--==========1905909384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
