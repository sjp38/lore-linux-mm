Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id E48816B006C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 06:22:41 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR900DB4E4XUP80@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Aug 2013 11:22:34 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH v2 3/4] mm: use mapcount for identifying zbud pages
Date: Fri, 09 Aug 2013 12:22:19 +0200
Message-id: <1376043740-10576-4-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com>
References: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Currently zbud pages do not have any flags set so it is not possible to
identify them during migration or compaction.

Implement PageZbud() by comparing page->_mapcount to -127 to distinguish
pages allocated by zbud. Just like PageBuddy() is implemented.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/mm.h |   23 +++++++++++++++++++++++
 mm/zbud.c          |    4 ++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..b9ae6f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -440,6 +440,7 @@ static inline void init_page_count(struct page *page)
  * efficiently by most CPU architectures.
  */
 #define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
+#define PAGE_ZBUD_MAPCOUNT_VALUE (-127)
 
 static inline int PageBuddy(struct page *page)
 {
@@ -458,6 +459,28 @@ static inline void __ClearPageBuddy(struct page *page)
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
index 52f6ba1..24c9ba0 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -199,7 +199,10 @@ static void get_zbud_page(struct zbud_header *zhdr)
 static int put_zbud_page(struct zbud_pool *pool, struct zbud_header *zhdr)
 {
 	struct page *page = virt_to_page(zhdr);
+	BUG_ON(!PageZbud(page));
+
 	if (put_page_testzero(page)) {
+		ClearPageZbud(page);
 		free_hot_cold_page(page, 0);
 		pool->pages_nr--;
 		return 1;
@@ -310,6 +313,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
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
