Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6EE6F6B0036
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 02:43:12 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR300EBZJZ5FG30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 07:43:10 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 3/4] mm: add zbud flag to page flags
Date: Tue, 06 Aug 2013 08:42:40 +0200
Message-id: <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Add PageZbud flag to page flags to distinguish pages allocated in zbud.
Currently these pages do not have any flags set.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/page-flags.h |   12 ++++++++++++
 mm/page_alloc.c            |    3 +++
 mm/zbud.c                  |    4 ++++
 3 files changed, 19 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..5b8b61a6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,12 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_ZBUD
+	/* Allocated by zbud. Flag is necessary to find zbud pages to unuse
+	 * during migration/compaction.
+	 */
+	PG_zbud,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -275,6 +281,12 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#ifdef CONFIG_ZBUD
+PAGEFLAG(Zbud, zbud)
+#else
+PAGEFLAG_FALSE(Zbud)
+#endif
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..1a120fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6345,6 +6345,9 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_ZBUD
+	{1UL << PG_zbud,		"zbud"		},
+#endif
 };
 
 static void dump_page_flags(unsigned long flags)
diff --git a/mm/zbud.c b/mm/zbud.c
index a8e986f..a452949 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -230,7 +230,10 @@ static void get_zbud_page(struct zbud_header *zhdr)
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
@@ -341,6 +344,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
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
