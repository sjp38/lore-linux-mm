Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB20B6B02FA
	for <linux-mm@kvack.org>; Mon, 15 May 2017 07:25:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so96168245pgn.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 04:25:41 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y64si10640992plh.78.2017.05.15.04.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 04:25:40 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v11 4/5] mm, THP, swap: Check whether THP can be split firstly
Date: Mon, 15 May 2017 19:25:21 +0800
Message-Id: <20170515112522.32457-5-ying.huang@intel.com>
In-Reply-To: <20170515112522.32457-1-ying.huang@intel.com>
References: <20170515112522.32457-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Huang Ying <ying.huang@intel.com>

To swap out THP (Transparent Huage Page), before splitting the THP,
the swap cluster will be allocated and the THP will be added into the
swap cache.  But it is possible that the THP cannot be split, so that
we must delete the THP from the swap cache and free the swap cluster.
To avoid that, in this patch, whether the THP can be split is checked
firstly.  The check can only be done racy, but it is good enough for
most cases.

With the patch, the swap out throughput improves 3.6% (from about
4.16GB/s to about 4.31GB/s) in the vm-scalability swap-w-seq test case
with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case creates 8 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for can_split_huge_page()]
---
 include/linux/huge_mm.h |  7 +++++++
 mm/huge_memory.c        | 20 ++++++++++++++++----
 mm/vmscan.c             |  4 ++++
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..d3b3e8fcc717 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -113,6 +113,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
+bool can_split_huge_page(struct page *page, int *pextra_pins);
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
@@ -231,6 +232,12 @@ static inline void prep_transhuge_page(struct page *page) {}
 
 #define thp_get_unmapped_area	NULL
 
+static inline bool
+can_split_huge_page(struct page *page, int *pextra_pins)
+{
+	BUILD_BUG();
+	return false;
+}
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b7c06476590e..3a14c77fcce7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2384,6 +2384,21 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 	return ret;
 }
 
+/* Racy check whether the huge page can be split */
+bool can_split_huge_page(struct page *page, int *pextra_pins)
+{
+	int extra_pins;
+
+	/* Additional pins from radix tree */
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
+	else
+		extra_pins = HPAGE_PMD_NR;
+	if (pextra_pins)
+		*pextra_pins = extra_pins;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
@@ -2431,7 +2446,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
@@ -2443,8 +2457,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
-		/* Addidional pins from radix tree */
-		extra_pins = HPAGE_PMD_NR;
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
 	}
@@ -2453,7 +2465,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
+	if (!can_split_huge_page(head, &extra_pins)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d58a37f79219..a5355022dc2f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1125,6 +1125,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		    !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
+			/* cannot split THP, skip it */
+			if (PageTransHuge(page) &&
+			    !can_split_huge_page(page, NULL))
+				goto activate_locked;
 			if (!add_to_swap(page)) {
 				if (!PageTransHuge(page))
 					goto activate_locked;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
