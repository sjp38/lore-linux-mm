Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58DC06B03E8
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 01:35:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 79so26003288pgf.2
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 22:35:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d76si681437pfe.306.2017.04.05.22.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 22:35:51 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v8 2/3] mm, THP, swap: Check whether THP can be split firstly
Date: Thu,  6 Apr 2017 13:35:14 +0800
Message-Id: <20170406053515.4842-3-ying.huang@intel.com>
In-Reply-To: <20170406053515.4842-1-ying.huang@intel.com>
References: <20170406053515.4842-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Huang Ying <ying.huang@intel.com>

In the original THP swapping out implementation, before splitting the
THP (Transparent Huage Page), the swap cluster will be allocated and
the THP will be added into the swap cache.  But it is possible that
the THP cannot be split, and we must delete the THP from the swap
cache and free the swap cluster.  To avoid that, in this patch,
whether the THP can be split is checked firstly.  The check can only
be done racy, but it is good enough for most cases.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for can_split_huge_page()]
---
 include/linux/huge_mm.h |  7 +++++++
 mm/huge_memory.c        | 20 ++++++++++++++++----
 mm/swap_state.c         |  7 ++++++-
 3 files changed, 29 insertions(+), 5 deletions(-)

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
index 4a5c1ca21894..459c7d5cdeb3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2372,6 +2372,21 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
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
@@ -2419,7 +2434,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
@@ -2431,8 +2445,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
-		/* Addidional pins from radix tree */
-		extra_pins = HPAGE_PMD_NR;
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
 	}
@@ -2441,7 +2453,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
+	if (!can_split_huge_page(head, &extra_pins)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7659557351cf..612fb2418df6 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -201,7 +201,12 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
 #ifdef CONFIG_THP_SWAP_CLUSTER
-	huge = PageTransHuge(page);
+	if (unlikely(PageTransHuge(page))) {
+		/* cannot split, skip it */
+		if (!can_split_huge_page(page, NULL))
+			return 0;
+		huge = true;
+	}
 #endif
 
 retry:
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
