Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3B74828F0
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:38:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so30850198pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:38:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id x69si43400947pfi.273.2016.08.09.09.38.13
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:38:13 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC 09/11] mm, THP: Add can_split_huge_page()
Date: Tue,  9 Aug 2016 09:37:51 -0700
Message-Id: <1470760673-12420-10-git-send-email-ying.huang@intel.com>
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

From: Huang Ying <ying.huang@intel.com>

Separates checking whether we can split the huge page from
split_huge_page_to_list() into a function.  This will help to check that
before splitting the THP (Transparent Huge Page) really.

This will be used for delaying splitting THP during swapping out.  Where
for a THP, we will allocate a swap cluster, add the THP into swap cache,
then split the THP.  To avoid unnecessary operations for un-splittable
THP, we will check that firstly.

There is no functionality change in this patch.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/huge_mm.h |  6 ++++++
 mm/huge_memory.c        | 13 ++++++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6f14de4..95ccbb4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -90,6 +90,7 @@ extern unsigned long transparent_hugepage_flags;
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
+bool can_split_huge_page(struct page *page);
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
@@ -169,6 +170,11 @@ void put_huge_zero_page(void);
 static inline void prep_transhuge_page(struct page *page) {}
 
 #define transparent_hugepage_flags 0UL
+static inline bool
+can_split_huge_page(struct page *page)
+{
+	return false;
+}
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2373f0a..af65413 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1954,6 +1954,17 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 	return ret;
 }
 
+/* Racy check whether the huge page can be split */
+bool can_split_huge_page(struct page *page)
+{
+	int extra_pins = 0;
+
+	/* Additional pins from radix tree */
+	if (!PageAnon(page))
+		extra_pins = HPAGE_PMD_NR;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
@@ -2024,7 +2035,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
+	if (!can_split_huge_page(head)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
