Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 86B426B003B
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:30:09 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8709082pdi.5
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:30:09 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00EXPQT6AJ20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:30:05 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 3/6] mm: use mapcount for identifying zbud pages
Date: Tue, 08 Oct 2013 15:29:37 +0200
Message-id: <1381238980-2491-4-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Currently zbud pages do not have any flags set so it is not possible to
identify them during migration or compaction.

Implement PageZbud() by comparing page->_mapcount to -127 to distinguish
pages allocated by zbud. Just like PageBuddy() is implemented.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 include/linux/mm.h |   23 +++++++++++++++++++++++
 mm/zbud.c          |    4 ++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..4307429 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -447,6 +447,7 @@ static inline void init_page_count(struct page *page)
  * efficiently by most CPU architectures.
  */
 #define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
+#define PAGE_ZBUD_MAPCOUNT_VALUE (-127)
 
 static inline int PageBuddy(struct page *page)
 {
@@ -465,6 +466,28 @@ static inline void __ClearPageBuddy(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+#ifdef CONFIG_ZBUD
+static inline int PageZbud(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_ZBUD_MAPCOUNT_VALUE;
+}
+
+static inline void SetPageZbud(struct page *page)
+{
+	VM_BUG_ON(atomic_read(&page->_mapcount) != -1);
+	atomic_set(&page->_mapcount, PAGE_ZBUD_MAPCOUNT_VALUE);
+}
+
+static inline void ClearPageZbud(struct page *page)
+{
+	VM_BUG_ON(!PageZbud(page));
+	atomic_set(&page->_mapcount, -1);
+}
+#else
+PAGEFLAG_FALSE(Zbud)
+#endif
+
+
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
diff --git a/mm/zbud.c b/mm/zbud.c
index e19f36a..6db0557 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -197,7 +197,10 @@ static void get_zbud_page(struct zbud_header *zhdr)
 static int put_zbud_page(struct zbud_header *zhdr)
 {
 	struct page *page = virt_to_page(zhdr);
+	VM_BUG_ON(!PageZbud(page));
+
 	if (put_page_testzero(page)) {
+		ClearPageZbud(page);
 		free_hot_cold_page(page, 0);
 		return 1;
 	}
@@ -307,6 +310,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	 * don't increase the page count.
 	 */
 	zhdr = init_zbud_page(page);
+	SetPageZbud(page);
 	bud = FIRST;
 
 found:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
