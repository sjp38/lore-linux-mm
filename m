Date: Fri, 11 Oct 2002 14:31:36 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.41-mm3] Proactively share page tables for shared memory
Message-ID: <24970000.1034364696@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1829269384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========1829269384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This is the other part to shared page tables.  It will actively attempt to
find and share a pte page for newly mapped shared memory.

This patch is intended to be applied to 2.5.41-mm3 plus the bugfix patch I
submitted this morning.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1829269384==========
Content-Type: text/plain; charset=iso-8859-1; name="shmmap-2.5.41-mm3-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shmmap-2.5.41-mm3-1.diff";
 size=2640

--- 2.5.41-mm3-shpte/./mm/memory.c	2002-10-11 10:59:14.000000000 -0500
+++ 2.5.41-mm3-shmmap/./mm/memory.c	2002-10-11 13:36:34.000000000 -0500
@@ -365,6 +365,77 @@
 out_map:
 	return pte_offset_map(pmd, address);
 }
+
+static pte_t *pte_try_to_share(struct mm_struct *mm, struct vm_area_struct =
*vma,
+			       pmd_t *pmd, unsigned long address)
+{
+	struct address_space *as;
+	struct vm_area_struct *lvma;
+	struct page *ptepage;
+	unsigned long base;
+
+	/*
+	 * It already has a pte page.  No point in checking further.
+	 * We can go ahead and return it now, since we know it's there.
+	 */
+	if (pmd_present(*pmd)) {
+		ptepage =3D pmd_page(*pmd);
+		pte_page_lock(ptepage);
+		return pte_page_map(ptepage, address);
+	}
+
+	/* It's not even shared memory. We definitely can't share the page. */
+	if (!(vma->vm_flags & VM_SHARED))
+		return NULL;
+
+	/* We can only share if the entire pte page fits inside the vma */
+	base =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	if ((base < vma->vm_start) || (vma->vm_end < (base + PMD_SIZE)))
+		return NULL;
+
+	as =3D vma->vm_file->f_dentry->d_inode->i_mapping;
+
+	list_for_each_entry(lvma, &as->i_mmap_shared, shared) {
+		pgd_t *lpgd;
+		pmd_t *lpmd;
+		pmd_t pmdval;
+
+		/* Skip the one we're working on */
+		if (lvma =3D=3D vma)
+			continue;
+
+		/* It has to be mapping to the same address */
+		if ((lvma->vm_start !=3D vma->vm_start) ||
+		    (lvma->vm_end !=3D vma->vm_end) ||
+		    (lvma->vm_pgoff !=3D vma->vm_pgoff))
+			continue;
+
+		lpgd =3D pgd_offset(vma->vm_mm, address);
+		lpmd =3D pmd_offset(lpgd, address);
+
+		/* This page table doesn't have a pte page either, so skip it. */
+		if (!pmd_present(*lpmd))
+			continue;
+
+		/* Ok, we can share it. */
+
+		ptepage =3D pmd_page(*lpmd);
+		pte_page_lock(ptepage);
+		get_page(ptepage);
+		/*
+		 * If this vma is only mapping it read-only, set the
+		 * pmd entry read-only to protect it from writes.
+		 * Otherwise set it writeable.
+		 */
+		if (vma->vm_flags & VM_MAYWRITE)
+			pmdval =3D pmd_mkwrite(*lpmd);
+		else
+			pmdval =3D pmd_wrprotect(*lpmd);
+		set_pmd(pmd, pmdval);
+		return pte_page_map(ptepage, address);
+	}
+	return NULL;
+}
 #endif
=20
 pte_t * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
@@ -1966,8 +2037,11 @@
 			pte_page_lock(pmd_page(*pmd));
 			pte =3D pte_unshare(mm, pmd, address);
 		} else {
-			pte =3D pte_alloc_map(mm, pmd, address);
-			pte_page_lock(pmd_page(*pmd));
+			pte =3D pte_try_to_share(mm, vma, pmd, address);
+			if (!pte) {
+				pte =3D pte_alloc_map(mm, pmd, address);
+				pte_page_lock(pmd_page(*pmd));
+			}
 		}
 #else
 		pte =3D pte_alloc_map(mm, pmd, address);

--==========1829269384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
