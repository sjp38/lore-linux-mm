Date: Thu, 20 Feb 2003 15:53:19 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.62] Support for remap_page_range in objrmap
Message-ID: <121000000.1045777999@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========967930887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========967930887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Here's the fix we discussed for remap_page_range.  It sets the anon flag
for pages in any vma used for nonlinear.  It also requires that
MAP_NONLINEAR be passed in at mmap time to flag the vma.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========967930887==========
Content-Type: text/plain; charset=iso-8859-1; name="objrmap-2.5.62-4.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="objrmap-2.5.62-4.diff"; size=3953

--- 2.5.62-objsent/./include/linux/mm.h	2003-02-19 12:00:47.000000000 -0600
+++ 2.5.62-objrmap/./include/linux/mm.h	2003-02-20 13:14:08.000000000 -0600
@@ -107,6 +107,7 @@
 #define VM_RESERVED	0x00080000	/* Don't unmap it from swap_out */
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
+#define VM_NONLINEAR	0x00800000	/* Nonlinear area */
=20
 #ifdef CONFIG_STACK_GROWSUP
 #define VM_STACK_FLAGS	(VM_GROWSUP | VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT)
--- 2.5.62-objsent/./include/asm-i386/mman.h	2003-02-17 16:55:56.000000000 =
-0600
+++ 2.5.62-objrmap/./include/asm-i386/mman.h	2003-02-20 13:28:23.000000000 =
-0600
@@ -20,6 +20,7 @@
 #define MAP_NORESERVE	0x4000		/* don't check for reservations */
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
+#define MAP_NONLINEAR	0x20000		/* will be used for remap_file_pages */
=20
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
--- 2.5.62-objsent/./mm/fremap.c	2003-02-17 16:55:50.000000000 -0600
+++ 2.5.62-objrmap/./mm/fremap.c	2003-02-20 15:35:25.000000000 -0600
@@ -78,6 +78,8 @@
 	if (prot & PROT_WRITE)
 		entry =3D pte_mkwrite(pte_mkdirty(entry));
 	set_pte(pte, entry);
+	if (vma->vm_flags & VM_NONLINEAR)
+		SetPageAnon(page);
 	pte_chain =3D page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
 	flush_tlb_page(vma, addr);
@@ -133,7 +135,8 @@
 	 * and that the remapped range is valid and fully within
 	 * the single existing vma:
 	 */
-	if (vma && (vma->vm_flags & VM_SHARED) &&
+	if (vma &&
+	    ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) =3D=3D =
(VM_SHARED|VM_NONLINEAR)) &&
 		vma->vm_ops && vma->vm_ops->populate &&
 			end > start && start >=3D vma->vm_start &&
 				end <=3D vma->vm_end) {
--- 2.5.62-objsent/./mm/mmap.c	2003-02-17 16:56:19.000000000 -0600
+++ 2.5.62-objrmap/./mm/mmap.c	2003-02-20 13:41:20.000000000 -0600
@@ -219,6 +219,7 @@
 	flag_bits =3D
 		_trans(flags, MAP_GROWSDOWN, VM_GROWSDOWN) |
 		_trans(flags, MAP_DENYWRITE, VM_DENYWRITE) |
+		_trans(flags, MAP_NONLINEAR, VM_NONLINEAR) |
 		_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE);
 	return prot_bits | flag_bits;
 #undef _trans
--- 2.5.62-objsent/./mm/rmap.c	2003-02-19 12:05:48.000000000 -0600
+++ 2.5.62-objrmap/./mm/rmap.c	2003-02-20 13:53:57.000000000 -0600
@@ -111,20 +111,20 @@
 		goto out;
 	}
 	pgd =3D pgd_offset(mm, address);
-	if (!pgd_present(*pgd)) {
+	if (!pgd_present(*pgd))
 		goto out_unlock;
-	}
+
 	pmd =3D pmd_offset(pgd, address);
-	if (!pmd_present(*pmd)) {
+	if (!pmd_present(*pmd))
 		goto out_unlock;
-	}
+
 	pte =3D pte_offset_map(pmd, address);
-	if (!pte_present(*pte)) {
+	if (!pte_present(*pte))
 		goto out_unmap;
-	}
-	if (page_to_pfn(page) !=3D pte_pfn(*pte)) {
+
+	if (page_to_pfn(page) !=3D pte_pfn(*pte))
 		goto out_unmap;
-	}
+
 	if (ptep_test_and_clear_young(pte))
 		referenced++;
 out_unmap:
@@ -156,13 +156,11 @@
 	if (down_trylock(&mapping->i_shared_sem))
 		return 1;
 	
-	list_for_each_entry(vma, &mapping->i_mmap, shared) {
+	list_for_each_entry(vma, &mapping->i_mmap, shared)
 		referenced +=3D page_referenced_obj_one(vma, page);
-	}
=20
-	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
+	list_for_each_entry(vma, &mapping->i_mmap_shared, shared)
 		referenced +=3D page_referenced_obj_one(vma, page);
-	}
=20
 	up(&mapping->i_shared_sem);
=20
@@ -444,20 +442,19 @@
 		goto out;
 	}
 	pgd =3D pgd_offset(mm, address);
-	if (!pgd_present(*pgd)) {
+	if (!pgd_present(*pgd))
 		goto out_unlock;
-	}
+
 	pmd =3D pmd_offset(pgd, address);
-	if (!pmd_present(*pmd)) {
+	if (!pmd_present(*pmd))
 		goto out_unlock;
-	}
+
 	pte =3D pte_offset_map(pmd, address);
-	if (!pte_present(*pte)) {
+	if (!pte_present(*pte))
 		goto out_unmap;
-	}
-	if (page_to_pfn(page) !=3D pte_pfn(*pte)) {
+
+	if (page_to_pfn(page) !=3D pte_pfn(*pte))
 		goto out_unmap;
-	}
=20
 	if (vma->vm_flags & VM_LOCKED) {
 		ret =3D  SWAP_FAIL;

--==========967930887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
