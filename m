Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EADB16B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:51:25 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g8so29979167itb.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:51:25 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id v129si1267348oib.7.2016.07.12.04.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 04:51:25 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id w18so18445473oiw.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:51:25 -0700 (PDT)
Date: Tue, 12 Jul 2016 04:51:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: thp: refix false positive BUG in page_move_anon_rmap()
Message-ID: <alpine.LSU.2.11.1607120444540.12528@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

The VM_BUG_ON_PAGE in page_move_anon_rmap() is more trouble than it's
worth: the syzkaller fuzzer hit it again.  It's still wrong for some
THP cases, because linear_page_index() was never intended to apply to
addresses before the start of a vma.

That's easily fixed with a signed long cast inside linear_page_index();
and Dmitry has tested such a patch, to verify the false positive.  But
why extend linear_page_index() just for this case? when the avoidance
in page_move_anon_rmap() has already grown ugly, and there's no reason
for the check at all (nothing else there is using address or index).

Remove address arg from page_move_anon_rmap(), remove VM_BUG_ON_PAGE,
remove CONFIG_DEBUG_VM PageTransHuge adjustment.

And one more thing: should the compound_head(page) be done inside or
outside page_move_anon_rmap()?  It's usually pushed down to the lowest
level nowadays (and mm/memory.c shows no other explicit use of it),
so I think it's better done in page_move_anon_rmap() than by caller.

Fixes: 0798d3c022dc ("mm: thp: avoid false positive VM_BUG_ON_PAGE in page_move_anon_rmap()")
Signed-off-by: Hugh Dickins <hughd@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mika Westerberg <mika.westerberg@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: stable@vger.kernel.org # 4.5+
---
Of course, we could just do a patch that deletes the VM_BUG_ON_PAGE
(and CONFIG_DEBUG_VM PageTransHuge adjustment) for now, and the cleanup
afterwards - but this doesn't affect a widely used interface, or go back
many stable releases, so personally I prefer to do it all in one go.

 include/linux/rmap.h |    2 +-
 mm/hugetlb.c         |    2 +-
 mm/memory.c          |    3 +--
 mm/rmap.c            |    9 +++------
 4 files changed, 6 insertions(+), 10 deletions(-)

--- 4.7-rc7/include/linux/rmap.h	2016-05-15 15:43:13.000000000 -0700
+++ linux/include/linux/rmap.h	2016-07-12 03:18:48.783180753 -0700
@@ -158,7 +158,7 @@ struct anon_vma *page_get_anon_vma(struc
 /*
  * rmap interfaces called when adding or removing pte of page
  */
-void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void page_move_anon_rmap(struct page *, struct vm_area_struct *);
 void page_add_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
--- 4.7-rc7/mm/hugetlb.c	2016-06-26 22:02:27.531373367 -0700
+++ linux/mm/hugetlb.c	2016-07-12 03:18:48.783180753 -0700
@@ -3383,7 +3383,7 @@ retry_avoidcopy:
 	/* If no-one else is actually using this page, avoid the copy
 	 * and just make the page writable */
 	if (page_mapcount(old_page) == 1 && PageAnon(old_page)) {
-		page_move_anon_rmap(old_page, vma, address);
+		page_move_anon_rmap(old_page, vma);
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
--- 4.7-rc7/mm/memory.c	2016-06-26 22:02:27.539373407 -0700
+++ linux/mm/memory.c	2016-07-12 03:18:48.783180753 -0700
@@ -2399,8 +2399,7 @@ static int do_wp_page(struct mm_struct *
 				 * Protected against the rmap code by
 				 * the page lock.
 				 */
-				page_move_anon_rmap(compound_head(old_page),
-						    vma, address);
+				page_move_anon_rmap(old_page, vma);
 			}
 			unlock_page(old_page);
 			return wp_page_reuse(mm, vma, address, page_table, ptl,
--- 4.7-rc7/mm/rmap.c	2016-05-29 15:47:38.711063232 -0700
+++ linux/mm/rmap.c	2016-07-12 03:18:48.783180753 -0700
@@ -1084,23 +1084,20 @@ EXPORT_SYMBOL_GPL(page_mkclean);
  * page_move_anon_rmap - move a page to our anon_vma
  * @page:	the page to move to our anon_vma
  * @vma:	the vma the page belongs to
- * @address:	the user virtual address mapped
  *
  * When a page belongs exclusively to one process after a COW event,
  * that page can be moved into the anon_vma that belongs to just that
  * process, so the rmap code will not search the parent or sibling
  * processes.
  */
-void page_move_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address)
+void page_move_anon_rmap(struct page *page, struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
+	page = compound_head(page);
+
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_VMA(!anon_vma, vma);
-	if (IS_ENABLED(CONFIG_DEBUG_VM) && PageTransHuge(page))
-		address &= HPAGE_PMD_MASK;
-	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
