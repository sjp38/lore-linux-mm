Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A5B446B009B
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:25 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so918623pac.16
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:25 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gv6si3137685pac.208.2014.11.05.06.50.13
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 11/19] mm, vmstats: new THP splitting event
Date: Wed,  5 Nov 2014 16:49:46 +0200
Message-Id: <1415198994-15252-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we
now can split PMD without the compound page and that split_huge_page()
can fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h | 4 +++-
 mm/huge_memory.c              | 3 +++
 mm/vmstat.c                   | 4 +++-
 3 files changed, 9 insertions(+), 2 deletions(-)

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
index e51059eea5bc..c63911b10143 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1620,6 +1620,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma,
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
+	count_vm_event(THP_SPLIT_PMD);
+
 	if (is_huge_zero_pmd(*pmd))
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 
@@ -1893,6 +1895,7 @@ static void __split_huge_page(struct page *page,
  */
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
+	count_vm_event(THP_SPLIT_PAGE_FAILED);
 	return -EBUSY;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c4d42e27ca9e..7cedd10c636d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -872,7 +872,9 @@ const char * const vmstat_text[] = {
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
