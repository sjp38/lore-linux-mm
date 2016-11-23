Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0FA6B026F
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:23:36 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id 19so2232926vko.0
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:23:36 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m30si4234484pli.231.2016.11.23.01.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 01:23:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix false-positive WARN_ON() in truncate/invalidate for hugetlb
Date: Wed, 23 Nov 2016 12:23:26 +0300
Message-Id: <20161123092326.169822-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Doug Nelson <doug.nelson@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "[4.8+]" <stable@vger.kernel.org>

Hugetlb pages have ->index in size of the huge pages (PMD_SIZE or
PUD_SIZE), not in PAGE_SIZE as other types of pages. This means we
cannot user page_to_pgoff() to check whether we've got the right page
for the radix-tree index.

Let's introduce page_to_index() which would return radix-tree index for
given page.

We will be able to get rid of this once hugetlb will be switched to
multi-order entries.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-and-tested-by: Doug Nelson <doug.nelson@intel.com>
Fixes: fc127da085c2 ("truncate: handle file thp")
Cc: <stable@vger.kernel.org> [4.8+]
---
 include/linux/pagemap.h | 23 +++++++++++++++++------
 mm/truncate.c           |  8 ++++----
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index dd15d39e1985..7e68545d58d8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -374,16 +374,13 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
 }
 
 /*
- * Get the offset in PAGE_SIZE.
- * (TODO: hugepage should have ->index in PAGE_SIZE)
+ * Index of the page with in radix-tree
+ * (TODO: remove once hugetlb pages will have ->index in PAGE_SIZE)
  */
-static inline pgoff_t page_to_pgoff(struct page *page)
+static inline pgoff_t page_to_index(struct page *page)
 {
 	pgoff_t pgoff;
 
-	if (unlikely(PageHeadHuge(page)))
-		return page->index << compound_order(page);
-
 	if (likely(!PageTransTail(page)))
 		return page->index;
 
@@ -397,6 +394,20 @@ static inline pgoff_t page_to_pgoff(struct page *page)
 }
 
 /*
+ * Get the offset in PAGE_SIZE.
+ * (TODO: hugepage should have ->index in PAGE_SIZE)
+ */
+static inline pgoff_t page_to_pgoff(struct page *page)
+{
+	pgoff_t pgoff;
+
+	if (unlikely(PageHeadHuge(page)))
+		return page->index << compound_order(page);
+
+	return page_to_index(page);
+}
+
+/*
  * Return byte-offset into filesystem object for page.
  */
 static inline loff_t page_offset(struct page *page)
diff --git a/mm/truncate.c b/mm/truncate.c
index a01cce450a26..8d8c62d89e6d 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -283,7 +283,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page_to_pgoff(page) != index);
+			WARN_ON(page_to_index(page) != index);
 			if (PageWriteback(page)) {
 				unlock_page(page);
 				continue;
@@ -371,7 +371,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			}
 
 			lock_page(page);
-			WARN_ON(page_to_pgoff(page) != index);
+			WARN_ON(page_to_index(page) != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
@@ -492,7 +492,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (!trylock_page(page))
 				continue;
 
-			WARN_ON(page_to_pgoff(page) != index);
+			WARN_ON(page_to_index(page) != index);
 
 			/* Middle of THP: skip */
 			if (PageTransTail(page)) {
@@ -612,7 +612,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			}
 
 			lock_page(page);
-			WARN_ON(page_to_pgoff(page) != index);
+			WARN_ON(page_to_index(page) != index);
 			if (page->mapping != mapping) {
 				unlock_page(page);
 				continue;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
