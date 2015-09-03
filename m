Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3F46B0255
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:13:38 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so49509222pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:13:37 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ym6si22038018pac.59.2015.09.03.08.13.36
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:13:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 01/36] mm, proc: adjust PSS calculation
Date: Thu,  3 Sep 2015 18:12:47 +0300
Message-Id: <1441293202-137314-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting all subpages of the compound page are not necessary
have the same mapcount. We need to take into account mapcount of every
sub-page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c | 47 +++++++++++++++++++++++++++++++----------------
 1 file changed, 31 insertions(+), 16 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 66954f5d753c..6b73be84271c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -453,9 +453,10 @@ struct mem_size_stats {
 };
 
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
-		unsigned long size, bool young, bool dirty)
+		bool compound, bool young, bool dirty)
 {
-	int mapcount;
+	int i, nr = compound ? HPAGE_PMD_NR : 1;
+	unsigned long size = nr * PAGE_SIZE;
 
 	if (PageAnon(page))
 		mss->anonymous += size;
@@ -464,23 +465,37 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	/* Accumulate the size in pages that have been accessed. */
 	if (young || page_is_young(page) || PageReferenced(page))
 		mss->referenced += size;
-	mapcount = page_mapcount(page);
-	if (mapcount >= 2) {
-		u64 pss_delta;
 
-		if (dirty || PageDirty(page))
-			mss->shared_dirty += size;
-		else
-			mss->shared_clean += size;
-		pss_delta = (u64)size << PSS_SHIFT;
-		do_div(pss_delta, mapcount);
-		mss->pss += pss_delta;
-	} else {
+	/*
+	 * page_count(page) == 1 guarantees the page is mapped exactly once.
+	 * If any subpage of the compound page mapped with PTE it would elevate
+	 * page_count().
+	 */
+	if (page_count(page) == 1) {
 		if (dirty || PageDirty(page))
 			mss->private_dirty += size;
 		else
 			mss->private_clean += size;
 		mss->pss += (u64)size << PSS_SHIFT;
+		return;
+	}
+
+	for (i = 0; i < nr; i++, page++) {
+		int mapcount = page_mapcount(page);
+
+		if (mapcount >= 2) {
+			if (dirty || PageDirty(page))
+				mss->shared_dirty += PAGE_SIZE;
+			else
+				mss->shared_clean += PAGE_SIZE;
+			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
+		} else {
+			if (dirty || PageDirty(page))
+				mss->private_dirty += PAGE_SIZE;
+			else
+				mss->private_clean += PAGE_SIZE;
+			mss->pss += PAGE_SIZE << PSS_SHIFT;
+		}
 	}
 }
 
@@ -515,7 +530,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 
 	if (!page)
 		return;
-	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
+
+	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -531,8 +547,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	if (IS_ERR_OR_NULL(page))
 		return;
 	mss->anonymous_thp += HPAGE_PMD_SIZE;
-	smaps_account(mss, page, HPAGE_PMD_SIZE,
-			pmd_young(*pmd), pmd_dirty(*pmd));
+	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
 static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
