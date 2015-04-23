Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AF7286B0080
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:04:59 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so28281367pab.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:04:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yy3si14146907pbb.193.2015.04.23.14.04.56
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:04:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 10/28] mm, vmstats: new THP splitting event
Date: Fri, 24 Apr 2015 00:03:45 +0300
Message-Id: <1429823043-157133-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we
are going to be able split PMD without the compound page and that
split_huge_page() can fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/vm_event_item.h | 4 +++-
 mm/huge_memory.c              | 2 +-
 mm/vmstat.c                   | 4 +++-
 3 files changed, 7 insertions(+), 3 deletions(-)

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
index ccbfacf07160..be6d0e0f5050 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1961,7 +1961,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	BUG_ON(!PageSwapBacked(page));
 	__split_huge_page(page, anon_vma, list);
-	count_vm_event(THP_SPLIT);
+	count_vm_event(THP_SPLIT_PAGE);
 
 	BUG_ON(PageCompound(page));
 out_unlock:
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
