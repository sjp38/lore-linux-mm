Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 74AA06B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:26:53 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so126256743pac.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:26:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bk2si6242254pbc.26.2015.04.27.04.26.52
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 04:26:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
Date: Mon, 27 Apr 2015 14:26:46 +0300
Message-Id: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PageTrans* helpers are always-false if THP is disabled compile-time.
It means the fucntion will fail to detect hugetlb pages in this case.

Let's use PageCompound() instead. With small tweak to how we calculate
next low_pfn it will make function ready to see tail pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/compaction.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08da99a2..6ef2fdf1d6b6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -732,18 +732,18 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * splitting and collapsing (collapsing has already happened
 		 * if PageLRU is set) but the lock is not necessarily taken
 		 * here and it is wasteful to take it just to check transhuge.
-		 * Check TransHuge without lock and skip the whole pageblock if
-		 * it's either a transhuge or hugetlbfs page, as calling
+		 * Check PageCompound without lock and skip the whole pageblock
+		 * if it's either a transhuge or hugetlbfs page, as calling
 		 * compound_order() without preventing THP from splitting the
 		 * page underneath us may return surprising results.
 		 */
-		if (PageTransHuge(page)) {
-			if (!locked)
-				low_pfn = ALIGN(low_pfn + 1,
-						pageblock_nr_pages) - 1;
+		if (PageCompound(page)) {
+			int nr;
+			if (locked)
+				nr = 1 << compound_order(page);
 			else
-				low_pfn += (1 << compound_order(page)) - 1;
-
+				nr = pageblock_nr_pages;
+			low_pfn = ALIGN(low_pfn + 1, nr) - 1;
 			continue;
 		}
 
@@ -763,11 +763,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (!locked)
 				break;
 
-			/* Recheck PageLRU and PageTransHuge under lock */
+			/* Recheck PageLRU and PageCompound under lock */
 			if (!PageLRU(page))
 				continue;
-			if (PageTransHuge(page)) {
-				low_pfn += (1 << compound_order(page)) - 1;
+			if (PageCompound(page)) {
+				int nr = 1 << compound_order(page);
+				low_pfn = ALIGN(low_pfn + 1, nr) - 1;
 				continue;
 			}
 		}
@@ -778,7 +779,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (__isolate_lru_page(page, isolate_mode) != 0)
 			continue;
 
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		VM_BUG_ON_PAGE(PageCompound(page), page);
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
