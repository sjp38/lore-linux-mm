Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CD4E4900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:33 -0500 (EST)
Received: by pdjg10 with SMTP id g10so12957442pdj.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y3si5626866pdf.59.2015.02.12.08.19.29
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/24] khugepaged: ignore pmd tables with THP mapped with ptes
Date: Thu, 12 Feb 2015 18:18:24 +0200
Message-Id: <1423757918-197669-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Prepare khugepaged to see compound pages mapped with pte. For now we
won't collapse the pmd table with such pte.

khugepaged is subject for future rework wrt new refcounting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 284d1f13247a..9d18e9bafb26 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2735,6 +2735,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -2745,7 +2750,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
