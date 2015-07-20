Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 021F89003CA
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:21:23 -0400 (EDT)
Received: by iecri3 with SMTP id ri3so23494932iec.2
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:21:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f4si6168436igc.19.2015.07.20.07.21.21
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 01/36] mm, proc: adjust PSS calculation
Date: Mon, 20 Jul 2015 17:20:34 +0300
Message-Id: <1437402069-105900-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 181ca3d56c72..37a3cf92f7c6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -450,9 +450,10 @@ struct mem_size_stats {
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
@@ -461,23 +462,37 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	/* Accumulate the size in pages that have been accessed. */
 	if (young || PageReferenced(page))
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
 
@@ -512,7 +527,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 
 	if (!page)
 		return;
-	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
+
+	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -528,8 +544,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
