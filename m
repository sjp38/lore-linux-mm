Date: Mon, 5 Apr 2004 16:24:34 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] get_user_pages shortcut for anonymous pages.
Message-ID: <20040405142433.GA5955@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

> I think this will do the wrong thing if the virtual address
> refers to an anon page which is swapped out.
Oh yes, follow_page returns NULL for swapped out pages.

> You'd need to teach follow_page() to return one of three values:
> page-present, page-not-present-but-used-to-be or
> page-not-present-and-never-was.
Hmm, this would get ugly because follow_page calls
follow_huge_addr and follow_huge_pmd for system with highmem. I
really don't want to change follow_page. Instead I added a check
for pgd_none/pgd_bad and pmd_none/pmd_bad for page directory
entries needed for the pages in question. After all the patch is
supposed to prevent the creation of page tables so why not check
the pgd/pmd slots? 

diff -urN linux-2.6/mm/memory.c linux-2.6-bigcore/mm/memory.c
--- linux-2.6/mm/memory.c	Sun Apr  4 05:36:58 2004
+++ linux-2.6-bigcore/mm/memory.c	Mon Apr  5 16:06:10 2004
@@ -688,6 +688,32 @@
 }
 
 
+static inline int
+untouched_anonymous_page(struct mm_struct* mm, struct vm_area_struct *vma,
+			 unsigned long address)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	/* Check if the vma is for an anonymous mapping. */
+	if (vma->vm_ops && vma->vm_ops->nopage)
+		return 0;
+
+	/* Check if page directory entry exists. */
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || pgd_bad(*pgd))
+		return 1;
+
+	/* Check if page middle directory entry exists. */
+	pmd = pmd_offset(pgd, address);
+	if (pmd_none(*pmd) || pmd_bad(*pmd))
+		return 1;
+
+	/* There is a pte slot for 'address' in 'mm'. */
+	return 0;
+}
+
+
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, int len, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
@@ -750,6 +776,18 @@
 			struct page *map;
 			int lookup_write = write;
 			while (!(map = follow_page(mm, start, lookup_write))) {
+				/*
+				 * Shortcut for anonymous pages. We don't want
+				 * to force the creation of pages tables for
+				 * insanly big anonymously mapped areas that
+				 * nobody touched so far. This is important
+				 * for doing a core dump for these mappings.
+				 */
+				if (!lookup_write &&
+				    untouched_anonymous_page(mm,vma,start)) {
+					map = ZERO_PAGE(start);
+					break;
+				}
 				spin_unlock(&mm->page_table_lock);
 				switch (handle_mm_fault(mm,vma,start,write)) {
 				case VM_FAULT_MINOR:


blue skies,
  Martin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
