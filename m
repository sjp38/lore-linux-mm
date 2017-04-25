Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59CCB6B02F3
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 08:57:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i25so27411859pfa.23
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 05:57:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a90si22400448plc.67.2017.04.25.05.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 05:57:14 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v10 2/3] mm, THP, swap: Check whether THP can be split firstly
Date: Tue, 25 Apr 2017 20:56:57 +0800
Message-Id: <20170425125658.28684-3-ying.huang@intel.com>
In-Reply-To: <20170425125658.28684-1-ying.huang@intel.com>
References: <20170425125658.28684-1-ying.huang@intel.com>
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
 mm/swap_state.c         |  4 ++++
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
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 16ff89d058f4..006d91d8fc53 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -192,6 +192,10 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
+	/* cannot split, skip it */
+	if (PageTransHuge(page) && !can_split_huge_page(page, NULL))
+		return 0;
+
 retry:
 	entry = get_swap_page(page);
 	if (!entry.val)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
