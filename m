Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5956B007D
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:33:48 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so1175487pab.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:33:48 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id y7si5829481pbt.37.2015.03.04.08.33.30
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 08:33:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 13/24] mm, vmstats: new THP splitting event
Date: Wed,  4 Mar 2015 18:33:01 +0200
Message-Id: <1425486792-93161-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index f420847a3288..3409a5c7dbb8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1646,6 +1646,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma,
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
 
+	count_vm_event(THP_SPLIT_PMD);
+
 	if (is_huge_zero_pmd(*pmd))
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 
@@ -1922,6 +1924,7 @@ static void __split_huge_page(struct page *page,
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
