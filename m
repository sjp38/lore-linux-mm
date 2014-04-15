Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id E9E8E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:48:42 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so10020929pbb.25
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:48:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id u6si11536625paa.134.2014.04.15.14.48.41
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 14:48:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: close race between split and zap huge pages
Date: Wed, 16 Apr 2014 00:48:35 +0300
Message-Id: <1397598515-25017-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

Sasha Levin has reported two THP BUGs[1][2]. I believe both of them have
the same root cause. Let's look to them one by one.

The first bug[1] is "kernel BUG at mm/huge_memory.c:1829!".
It's BUG_ON(mapcount != page_mapcount(page)) in __split_huge_page().
>From my testing I see that page_mapcount() is higher than mapcount here.

I think it happens due to race between zap_huge_pmd() and
page_check_address_pmd(). page_check_address_pmd() misses PMD
which is under zap:

	CPU0						CPU1
						zap_huge_pmd()
						  pmdp_get_and_clear()
__split_huge_page()
  anon_vma_interval_tree_foreach()
    __split_huge_page_splitting()
      page_check_address_pmd()
        mm_find_pmd()
	  /*
	   * We check if PMD present without taking ptl: no
	   * serialization against zap_huge_pmd(). We miss this PMD,
	   * it's not accounted to 'mapcount' in __split_huge_page().
	   */
	  pmd_present(pmd) == 0

  BUG_ON(mapcount != page_mapcount(page)) // CRASH!!!

						  page_remove_rmap(page)
						    atomic_add_negative(-1, &page->_mapcount)

The second bug[2] is "kernel BUG at mm/huge_memory.c:1371!".
It's VM_BUG_ON_PAGE(!PageHead(page), page) in zap_huge_pmd().

This happens in similar way:

	CPU0						CPU1
						zap_huge_pmd()
						  pmdp_get_and_clear()
						  page_remove_rmap(page)
						    atomic_add_negative(-1, &page->_mapcount)
__split_huge_page()
  anon_vma_interval_tree_foreach()
    __split_huge_page_splitting()
      page_check_address_pmd()
        mm_find_pmd()
	  pmd_present(pmd) == 0	/* The same comment as above */
  /*
   * No crash this time since we already decremented page->_mapcount in
   * zap_huge_pmd().
   */
  BUG_ON(mapcount != page_mapcount(page))

  /*
   * We split the compound page here into small pages without
   * serialization against zap_huge_pmd()
   */
  __split_huge_page_refcount()
						VM_BUG_ON_PAGE(!PageHead(page), page); // CRASH!!!

So my understanding the problem is pmd_present() check in mm_find_pmd()
without taking page table lock.

The bug was introduced by me commit with commit 117b0791ac42. Sorry for
that. :(

Let's open code mm_find_pmd() in page_check_address_pmd() and do the
check under page table lock.

Note that __page_check_address() does the same for PTE entires
if sync != 0.

I've stress tested split and zap code paths for 36+ hours by now and
don't see crashes with the patch applied. Before it took <20 min to
trigger the first bug and few hours for second one (if we ignore
first).

[1] https://lkml.kernel.org/g/<53440991.9090001@oracle.com>
[2] https://lkml.kernel.org/g/<5310C56C.60709@oracle.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: <stable@vger.kernel.org> #3.13+
---
 mm/huge_memory.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5025709bb3b5..d02a83852ee9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1536,16 +1536,23 @@ pmd_t *page_check_address_pmd(struct page *page,
 			      enum page_check_address_pmd_flag flag,
 			      spinlock_t **ptl)
 {
+	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	if (address & ~HPAGE_PMD_MASK)
 		return NULL;
 
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
 		return NULL;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return NULL;
+	pmd = pmd_offset(pud, address);
+
 	*ptl = pmd_lock(mm, pmd);
-	if (pmd_none(*pmd))
+	if (!pmd_present(*pmd))
 		goto unlock;
 	if (pmd_page(*pmd) != page)
 		goto unlock;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
