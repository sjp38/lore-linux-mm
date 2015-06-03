Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 88F48900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:06:37 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so11156145pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:06:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hq3si1800802pac.164.2015.06.03.10.06.34
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:06:34 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 08/36] khugepaged: ignore pmd tables with THP mapped with ptes
Date: Wed,  3 Jun 2015 20:05:39 +0300
Message-Id: <1433351167-125878-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Prepare khugepaged to see compound pages mapped with pte. For now we
won't collapse the pmd table with such pte.

khugepaged is subject for future rework wrt new refcounting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4ad975506c1b..a5423bee0109 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2680,6 +2680,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
+
+		/* TODO: teach khugepaged to collapse THP mapped with pte */
+		if (PageCompound(page))
+			goto out_unmap;
+
 		/*
 		 * Record which node the original page is from and save this
 		 * information to khugepaged_node_load[].
@@ -2690,7 +2695,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		if (khugepaged_scan_abort(node))
 			goto out_unmap;
 		khugepaged_node_load[node]++;
-		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
 		/*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
