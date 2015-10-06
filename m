Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 622B282F68
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:25:01 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so212490844pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:25:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cz3si49635432pbb.218.2015.10.06.08.24.50
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 06/37] mm: handle PTE-mapped tail pages in gerneric fast gup implementaiton
Date: Tue,  6 Oct 2015 18:23:33 +0300
Message-Id: <1444145044-72349-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we are going to see THP tail pages mapped with PTE.
Generic fast GUP rely on page_cache_get_speculative() to obtain
reference on page. page_cache_get_speculative() always fails on tail
pages, because ->_count on tail pages is always zero.

Let's handle tail pages in gup_pte_range().

New split_huge_page() will rely on migration entries to freeze page's
counts. Recheck PTE value after page_cache_get_speculative() on head
page should be enough to serialize against split.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/gup.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 745a50f2d57d..6880085d3790 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1097,7 +1097,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 * for an example see gup_get_pte in arch/x86/mm/gup.c
 		 */
 		pte_t pte = READ_ONCE(*ptep);
-		struct page *page;
+		struct page *head, *page;
 
 		/*
 		 * Similar to the PMD case below, NUMA hinting must take slow
@@ -1109,15 +1109,17 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
+		head = compound_head(page);
 
-		if (!page_cache_get_speculative(page))
+		if (!page_cache_get_speculative(head))
 			goto pte_unmap;
 
 		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-			put_page(page);
+			put_page(head);
 			goto pte_unmap;
 		}
 
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
 		(*nr)++;
 
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
