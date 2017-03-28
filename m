Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC6646B03AA
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:32:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g124so67556289pgc.1
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 22:32:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m8si3006807pga.117.2017.03.27.22.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 22:32:41 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v7 8/9] mm, THP, swap: Support to split THP in swap cache
Date: Tue, 28 Mar 2017 13:32:08 +0800
Message-Id: <20170328053209.25876-9-ying.huang@intel.com>
In-Reply-To: <20170328053209.25876-1-ying.huang@intel.com>
References: <20170328053209.25876-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

From: Huang Ying <ying.huang@intel.com>

This patch enhanced the split_huge_page_to_list() to work properly for
the THP (Transparent Huge Page) in the swap cache during swapping out.

This is used for delaying splitting the THP during swapping out.  Where
for a THP to be swapped out, we will allocate a swap cluster, add the
THP into the swap cache, then split the THP.  The page lock will be held
during this process.  So in the code path other than swapping out, if
the THP need to be split, the PageSwapCache(THP) will be always false.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 08ccf0cebe8f..459c7d5cdeb3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2185,7 +2185,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc()/atomic_add().
 	 */
-	if (PageAnon(head)) {
+	if (PageAnon(head) && !PageSwapCache(head)) {
 		page_ref_inc(page_tail);
 	} else {
 		/* Additional pin to radix tree */
@@ -2196,6 +2196,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	page_tail->flags |= (head->flags &
 			((1L << PG_referenced) |
 			 (1L << PG_swapbacked) |
+			 (1L << PG_swapcache) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
@@ -2258,7 +2259,11 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	ClearPageCompound(head);
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
-		page_ref_inc(head);
+		/* Additional pin to radix tree of swap cache */
+		if (PageSwapCache(head))
+			page_ref_add(head, 2);
+		else
+			page_ref_inc(head);
 	} else {
 		/* Additional pin to radix tree */
 		page_ref_add(head, 2);
@@ -2370,10 +2375,12 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 /* Racy check whether the huge page can be split */
 bool can_split_huge_page(struct page *page, int *pextra_pins)
 {
-	int extra_pins = 0;
+	int extra_pins;
 
 	/* Additional pins from radix tree */
-	if (!PageAnon(page))
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
+	else
 		extra_pins = HPAGE_PMD_NR;
 	if (pextra_pins)
 		*pextra_pins = extra_pins;
@@ -2427,7 +2434,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
