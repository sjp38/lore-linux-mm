Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4786B0266
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:33 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 18so61518618ybc.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n4si6083386pan.58.2016.09.01.08.18.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 08/10] mm, THP: Add can_split_huge_page()
Date: Thu,  1 Sep 2016 08:17:01 -0700
Message-Id: <1472743023-4116-9-git-send-email-ying.huang@intel.com>
In-Reply-To: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

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
index 2db2112..7082fe3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1959,6 +1959,17 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
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
@@ -2029,7 +2040,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
