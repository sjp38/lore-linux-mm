Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EC6106B006E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:04:29 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so28661135pdb.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:04:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fo9si14228791pdb.98.2015.04.23.14.04.28
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:04:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 08/28] khugepaged: ignore pmd tables with THP mapped with ptes
Date: Fri, 24 Apr 2015 00:03:43 +0300
Message-Id: <1429823043-157133-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Prepare khugepaged to see compound pages mapped with pte. For now we
won't collapse the pmd table with such pte.

khugepaged is subject for future rework wrt new refcounting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/huge_memory.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fa3d4f78b716..ffc30e4462c1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2653,6 +2653,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -2663,7 +2668,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
