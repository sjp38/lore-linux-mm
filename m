Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 147A39003CA
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:21:30 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so30094771pab.2
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:21:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rx6si36275326pab.219.2015.07.20.07.21.21
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 06/36] mm: handle PTE-mapped tail pages in gerneric fast gup implementaiton
Date: Mon, 20 Jul 2015 17:20:39 +0300
Message-Id: <1437402069-105900-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 55c87b16289b..6b9f578cff2e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1089,7 +1089,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 * for an example see gup_get_pte in arch/x86/mm/gup.c
 		 */
 		pte_t pte = READ_ONCE(*ptep);
-		struct page *page;
+		struct page *head, *page;
 
 		/*
 		 * Similar to the PMD case below, NUMA hinting must take slow
@@ -1101,15 +1101,17 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
