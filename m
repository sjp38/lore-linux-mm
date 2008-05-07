Date: Wed, 7 May 2008 16:36:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] more ZERO_PAGE handling in follow_page()
Message-Id: <20080507163643.d4da0ed0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, tonyb@cybernetics.com, mika.penttila@kolumbus.fi
List-ID: <linux-mm.kvack.org>

Rewrote the description of patch. (no changes in the logic.)

Thank you for all help.
-Kame
==
follow_page() is called from get_user_pages(), which returns specified user page.
follow_page() can return 1) a page or 2) NULL or 3)ZERO_PAGE.
If NULL, handle_mm_fault() is called.

Now, follow_page() to unused pte returns NULL if page table exists. As a result
get_user_pages() calls handle_mm_fault() and allocate new memory.
This behavior increases memory consumption at coredump, which does
read-once-but-never-written page fault.
By returning ZERO_PAGE() against READ/ANON request, we can avoid it.

(Because exec's arguments copy needs to call handle_mm_fault at WRITE/ANON
 request, we just handle READ/ANON case here.)

Change log:
  - Rewrote patch description and Added comments.
  - fixed to check pte_present()/pte_none() in proper way.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Tested-by: Tony Battersby <tonyb@cybernetics.com>
Acked-by: Nick Piggin <npiggin@suse.de>

---
 mm/memory.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: linux-2.6.25/mm/memory.c
===================================================================
--- linux-2.6.25.orig/mm/memory.c
+++ linux-2.6.25/mm/memory.c
@@ -926,15 +926,15 @@ struct page *follow_page(struct vm_area_
 	page = NULL;
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto no_page_table;
+		goto null_or_zeropage;
 
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto no_page_table;
+		goto null_or_zeropage;
 	
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		goto no_page_table;
+		goto null_or_zeropage;
 
 	if (pmd_huge(*pmd)) {
 		BUG_ON(flags & FOLL_GET);
@@ -947,8 +947,14 @@ struct page *follow_page(struct vm_area_
 		goto out;
 
 	pte = *ptep;
-	if (!pte_present(pte))
+	if (!pte_present(pte)) {
+		/* Read fault to empty pte can return ZERO_PAGE */
+		if (!(flags & FOLL_WRITE) && pte_none(pte)) {
+			pte_unmap_unlock(ptep, ptl);
+			goto null_or_zeropage;
+		}
 		goto unlock;
+	}
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
 	page = vm_normal_page(vma, address, pte);
@@ -968,7 +974,7 @@ unlock:
 out:
 	return page;
 
-no_page_table:
+null_or_zeropage:
 	/*
 	 * When core dumping an enormous anonymous area that nobody
 	 * has touched so far, we don't want to allocate page tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
