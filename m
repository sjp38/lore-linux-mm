Date: Wed, 02 Apr 2003 11:13:02 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <8910000.1049303582@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1813199384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========1813199384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


I came up with a scheme for accessing the page tables in page_convert_anon
that should work without requiring locks.  Hugh has looked at it and agrees
it addresses the problems he found.  Anyway, here's the patch.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1813199384==========
Content-Type: text/plain; charset=us-ascii; name="objlock-2.5.66-mm2-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="objlock-2.5.66-mm2-1.diff";
 size=1116

--- 2.5.66-mm2/./mm/rmap.c	2003-04-01 11:23:35.000000000 -0600
+++ 2.5.66-mm2-fix/./mm/rmap.c	2003-04-01 11:30:21.000000000 -0600
@@ -95,7 +95,9 @@ find_pte(struct vm_area_struct *vma, str
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
+	pgd_t pgdval;
 	pmd_t *pmd;
+	pmd_t pmdval;
 	pte_t *pte;
 	unsigned long loffset;
 	unsigned long address;
@@ -106,17 +108,27 @@ find_pte(struct vm_area_struct *vma, str
 		goto out;
 
 	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
+	pgdval = *pgd;
+	if (!pgd_present(pgdval))
 		goto out;
 
-	pmd = pmd_offset(pgd, address);
-	if (!pmd_present(*pmd))
+	pmd = pmd_offset(&pgdval, address);
+	pmdval = *pmd;
+	if (!pmd_present(pmdval))
 		goto out;
 
-	pte = pte_offset_map(pmd, address);
+	/* Double check to make sure the pmd page hasn't been freed */
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pte = pte_offset_map(&pmdval, address);
 	if (!pte_present(*pte))
 		goto out_unmap;
 
+	/* Double check to make sure the pte page hasn't been freed */
+	if (!pmd_present(*pmd))
+		goto out_unmap;
+
 	if (page_to_pfn(page) != pte_pfn(*pte))
 		goto out_unmap;
 

--==========1813199384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
