Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 63BE96B00A4
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:05:08 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so871496pab.26
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:05:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ia5si31154386pbb.236.2014.06.09.09.05.07
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:05:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 05/10] mm, vmstats: new THP splitting event
Date: Mon,  9 Jun 2014 19:04:16 +0300
Message-Id: <1402329861-7037-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we
now can split PMD without the compound page and that split_huge_page()
can fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h | 4 +++-
 mm/huge_memory.c              | 2 ++
 mm/vmstat.c                   | 4 +++-
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ced92345c963..b44dffa769b9 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -68,7 +68,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_FALLBACK,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
-		THP_SPLIT,
+		THP_SPLIT_PAGE,
+		THP_SPLIT_PAGE_FAILED,
+		THP_SPLIT_PMD,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 752c850f6941..fec89aedcedd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1578,6 +1578,7 @@ unlock:
 
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
+	count_vm_event(THP_SPLIT_PAGE_FAILED);
 	return -EBUSY;
 }
 
@@ -2496,6 +2497,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 		return;
 	}
+	count_vm_event(THP_SPLIT_PMD);
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 		spin_unlock(ptl);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b37bd49bfd55..6a155f0476e8 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -855,7 +855,9 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
-	"thp_split",
+	"thp_split_page",
+	"thp_split_page_failed",
+	"thp_split_pmd",
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
-- 
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
