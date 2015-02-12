Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BF4806B0071
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:20:18 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ey11so12349832pad.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:20:18 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dh1si1708434pbc.142.2015.02.12.08.20.12
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:20:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 13/24] mm, vmstats: new THP splitting event
Date: Thu, 12 Feb 2015 18:18:27 +0200
Message-Id: <1423757918-197669-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 2b1cef88b827..3261bfe2156a 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -69,7 +69,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
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
index 46c3cd26f837..b5c1976e2a65 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1644,6 +1644,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma,
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
+	count_vm_event(THP_SPLIT_PMD);
+
 	if (is_huge_zero_pmd(*pmd))
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 
@@ -1917,6 +1919,7 @@ static void __split_huge_page(struct page *page,
  */
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
+	count_vm_event(THP_SPLIT_PAGE_FAILED);
 	return -EBUSY;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1fd0886a389f..e1c87425fe11 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -821,7 +821,9 @@ const char * const vmstat_text[] = {
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
