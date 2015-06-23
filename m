Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDB76B0075
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:21 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so7778857pdb.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id o7si34822173pap.19.2015.06.23.06.47.13
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 10/36] mm, vmstats: new THP splitting event
Date: Tue, 23 Jun 2015 16:46:20 +0300
Message-Id: <1435067206-92901-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
THP_SPLIT_PAGE_FAILED and THP_SPLIT_PMD. It reflects the fact that we
are going to be able split PMD without the compound page and that
split_huge_page() can fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
index 2374dbb57c44..cdc3a358eb17 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1986,7 +1986,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
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
