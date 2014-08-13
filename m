Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 633016B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 11:28:39 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so15095313pab.15
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:28:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pg3si1745301pdb.181.2014.08.13.08.28.38
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 08:28:38 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH] mm: Actually clear pmd_numa before invalidating
Date: Wed, 13 Aug 2014 11:28:27 -0400
Message-Id: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Commit 67f87463d3 cleared the NUMA bit in a copy of the PMD entry, but
then wrote back the original

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: <stable@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/pgtable-generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index a8b9199..dfb79e0 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -195,7 +195,7 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 	pmd_t entry = *pmdp;
 	if (pmd_numa(entry))
 		entry = pmd_mknonnuma(entry);
-	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(*pmdp));
+	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
