Date: Fri, 22 Nov 2002 10:40:25 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.48-mm1] Break COW page tables on mmap
Message-ID: <26960000.1037983225@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========873890887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========873890887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


I found a fairly large hole in my unsharing logic.  Pte page COW behavior
breaks down when new objects are mapped.  This patch makes sure there
aren't any COW pte pages in the range of a new mapping at mmap time.

This should fix the KDE problem.  It fixed it on the test machine I've been
using.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========873890887==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.48-mm1-2.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.48-mm1-2.diff"; size=2233

--- 2.5.48-mm1-shsent/./mm/memory.c	2002-11-21 11:26:32.000000000 -0600
+++ 2.5.48-mm1-shpte/./mm/memory.c	2002-11-22 10:27:39.000000000 -0600
@@ -1080,6 +1080,65 @@
 	tlb_finish_mmu(tlb, 0, TASK_SIZE);
 }
=20
+#ifdef CONFIG_SHAREPTE
+void
+clear_share_range(struct mm_struct *mm, unsigned long address, unsigned =
long len)
+{
+	pgd_t		*pgd;
+	pmd_t		*pmd;
+	struct page	*ptepage;
+	unsigned long	end =3D address + len;
+
+	spin_lock(&mm->page_table_lock);
+
+	pgd =3D pgd_offset(mm, address);
+	if (pgd_none(*pgd) || pgd_bad(*pgd))
+		goto skip_start;
+
+	pmd =3D pmd_offset(pgd, address);
+	if (pmd_none(*pmd) || pmd_bad(*pmd))
+		goto skip_start;
+
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
+	if (page_count(ptepage) > 1) {
+		pte_t *pte;
+
+		pte =3D pte_unshare(mm, pmd, address);
+		pte_unmap(pte);
+		ptepage =3D pmd_page(*pmd);
+	}
+	pte_page_unlock(ptepage);
+
+skip_start:
+	/* This range is contained in one pte page.  We're done. */
+	if ((address >> PMD_SHIFT) =3D=3D (end >> PMD_SHIFT))
+		goto out;
+	
+	pgd =3D pgd_offset(mm, end);
+	if (pgd_none(*pgd) || pgd_bad(*pgd))
+		goto out;
+
+	pmd =3D pmd_offset(pgd, end);
+	if (pmd_none(*pmd) || pmd_bad(*pmd))
+		goto out;
+
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
+	if (page_count(ptepage) > 1) {
+		pte_t *pte;
+
+		pte =3D pte_unshare(mm, pmd, end);
+		pte_unmap(pte);
+		ptepage =3D pmd_page(*pmd);
+	}
+	pte_page_unlock(ptepage);
+
+out:
+	spin_unlock(&mm->page_table_lock);
+}
+#endif
+
 /*
  * Do a quick page-table lookup for a single page.
  * mm->page_table_lock must be held.
--- 2.5.48-mm1-shsent/./mm/mmap.c	2002-11-19 09:17:36.000000000 -0600
+++ 2.5.48-mm1-shpte/./mm/mmap.c	2002-11-22 10:26:11.000000000 -0600
@@ -57,6 +57,8 @@
 pgprot_t protection_pmd[8] =3D {
 	__PMD000, __PMD001, __PMD010, __PMD011, __PMD100, __PMD101, __PMD110, =
__PMD111
 };
+extern void clear_share_range(struct mm_struct *mm, unsigned long address,
+			      unsigned long len);
 #endif
=20
 int sysctl_overcommit_memory =3D 0;	/* default is heuristic overcommit */
@@ -524,6 +526,9 @@
 			return -ENOMEM;
 		goto munmap_back;
 	}
+#ifdef CONFIG_SHAREPTE
+	clear_share_range(mm, addr, len);
+#endif
=20
 	/* Check against address space limit. */
 	if ((mm->total_vm << PAGE_SHIFT) + len

--==========873890887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
