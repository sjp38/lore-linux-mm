From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] shared page table for hugetlb page - v2
Date: Fri, 22 Sep 2006 15:53:14 -0700
Message-ID: <000401c6de99$e374c100$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060922142117.eebc5e94.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Friday, September 22, 2006 2:21 PM
> The locking in here makes me a bit queasy.  What causes *spte to still be
> shareable after we've dropped i_mmap_lock?
> 
> (A patch which adds appropriate comments would be the preferred answer,
> please...)
> 

OK, patch attached below.


> > +int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
> 
> I think this function could do with a comment describing its
> responsibilities.
> 

OK, comments added in the patch below.


> > +{
> > +	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
> > +	pud_t *pud = pud_offset(pgd, *addr);
> > +
> > +	if (page_count(virt_to_page(ptep)) <= 1)
> > +		return 0;
> 
> And this test.  It's testing the refcount of the pte page, yes?  Why?  What
> does it mean when that refcount is zero?  Bug?  And when it's one?  We're
> the last user, so the above test is an optimisation, yes?

Yes, testing whether the pte page is shared or not.  This function falls out
if the pte page is not shared or we are the last user.  The caller of this
function then iterate through each pte and unmap the corresponding user pages.
I've added comments in the patch as well.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/i386/mm/hugetlbpage.c.orig	2006-09-22 12:48:54.000000000 -0700
+++ ./arch/i386/mm/hugetlbpage.c	2006-09-22 13:48:12.000000000 -0700
@@ -57,6 +57,11 @@ void pmd_share(struct vm_area_struct *vm
 
 		spin_lock(&svma->vm_mm->page_table_lock);
 		spte = huge_pte_offset(svma->vm_mm, addr);
+		/*
+		 * if a valid hugetlb pte is found, take a reference count
+		 * on the pte page.  We can then safely populate it into
+		 * pud at a later point.
+		 */
 		if (spte)
 			get_page(virt_to_page(spte));
 		spin_unlock(&svma->vm_mm->page_table_lock);
@@ -76,6 +81,16 @@ void pmd_share(struct vm_area_struct *vm
 	spin_unlock(&vma->vm_mm->page_table_lock);
 }
 
+/*
+ * unmap huge page backed by shared pte.
+ *
+ * Hugetlb pte page is ref counted at the time of mapping.  If pte is shared
+ * indicated by page_count > 1, unmap is achieved by clearing pud and
+ * decrementing the ref count. If count == 1, the pte page is not shared.
+ *
+ * returns: 1 successfully unmapped a shared pte page
+ *	    0 the underlying pte page is not shared, or it is the last user
+ */
 int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
 {
 	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
