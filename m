Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 473556B03A8
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:32:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v21so91412657pgo.22
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 22:32:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m8si3006807pga.117.2017.03.27.22.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 22:32:40 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v7 7/9] mm, THP: Add can_split_huge_page()
Date: Tue, 28 Mar 2017 13:32:07 +0800
Message-Id: <20170328053209.25876-8-ying.huang@intel.com>
In-Reply-To: <20170328053209.25876-1-ying.huang@intel.com>
References: <20170328053209.25876-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

From: Huang Ying <ying.huang@intel.com>

Separates checking whether we can split the huge page from
split_huge_page_to_list() into a function.  This will help to check that
before splitting the THP (Transparent Huge Page) really.

This will be used for delaying splitting THP during swapping out.  Where
for a THP, we will allocate a swap cluster, add the THP into the swap
cache, then split the THP.  To avoid the unnecessary operations for the
un-splittable THP, we will check that firstly.

There is no functionality change in this patch.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  7 +++++++
 mm/huge_memory.c        | 17 ++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

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
index d14dd961f626..08ccf0cebe8f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2367,6 +2367,19 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 	return ret;
 }
 
+/* Racy check whether the huge page can be split */
+bool can_split_huge_page(struct page *page, int *pextra_pins)
+{
+	int extra_pins = 0;
+
+	/* Additional pins from radix tree */
+	if (!PageAnon(page))
+		extra_pins = HPAGE_PMD_NR;
+	if (pextra_pins)
+		*pextra_pins = extra_pins;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
@@ -2426,8 +2439,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
-		/* Addidional pins from radix tree */
-		extra_pins = HPAGE_PMD_NR;
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
 	}
@@ -2436,7 +2447,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
+	if (!can_split_huge_page(head, &extra_pins)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
