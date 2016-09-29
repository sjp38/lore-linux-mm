Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6849280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:34:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 21so137083450pfy.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:34:27 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v1si12804035pav.74.2016.09.28.23.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:34:27 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v4 8/9] mm, THP, swap: Support to split THP in swap cache
Date: Thu, 29 Sep 2016 14:33:53 +0800
Message-Id: <20160929063354.1875-9-ying.huang@intel.com>
In-Reply-To: <20160929063354.1875-1-ying.huang@intel.com>
References: <20160929063354.1875-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

From: Huang Ying <ying.huang@intel.com>

This patch enhanced the split_huge_page_to_list() to work properly for
the THP (Transparent Huge Page) in the swap cache during swapping out.

This is used for delaying splitting the THP during swapping out.  Where
for a THP to be swapped out, we will allocate a swap cluster, add the
THP into the swap cache, then split the THP.  The page lock will be held
during this process.  So in the code path other than swapping out, if
the THP need to be split, the PageSwapCache(THP) will be always false.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/huge_memory.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c856a7c..c58e032 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1834,7 +1834,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc()/atomic_add().
 	 */
-	if (PageAnon(head)) {
+	if (PageAnon(head) && !PageSwapCache(head)) {
 		page_ref_inc(page_tail);
 	} else {
 		/* Additional pin to radix tree */
@@ -1845,6 +1845,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	page_tail->flags |= (head->flags &
 			((1L << PG_referenced) |
 			 (1L << PG_swapbacked) |
+			 (1L << PG_swapcache) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
@@ -1907,7 +1908,11 @@ static void __split_huge_page(struct page *page, struct list_head *list,
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
@@ -2019,10 +2024,12 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 /* Racy check whether the huge page can be split */
 bool can_split_huge_page(struct page *page)
 {
-	int extra_pins = 0;
+	int extra_pins;
 
 	/* Additional pins from radix tree */
-	if (!PageAnon(page))
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
+	else
 		extra_pins = HPAGE_PMD_NR;
 	return total_mapcount(page) == page_count(page) - extra_pins - 1;
 }
@@ -2075,7 +2082,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = 0;
+		extra_pins = PageSwapCache(head) ? HPAGE_PMD_NR : 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
