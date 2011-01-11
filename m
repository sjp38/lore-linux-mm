Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 686E66B00EA
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 00:22:38 -0500 (EST)
Received: by yxl31 with SMTP id 31so8787810yxl.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 21:22:36 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 1/7] Introduce delete_from_page_cache
Date: Tue, 11 Jan 2011 14:22:05 +0900
Message-Id: <34bbf652c570ce9a53ffad78d5fe9a5f3cdfa9a7.1294723009.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1294723009.git.minchan.kim@gmail.com>
References: <cover.1294723009.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1294723009.git.minchan.kim@gmail.com>
References: <cover.1294723009.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

This function works as just wrapper remove_from_page_cache.
The difference is that it decreases page references in itself.
So caller have to make sure it has a page reference before calling.

This patch is ready for removing remove_from_page_cache.

Cc: Christoph Hellwig <hch@infradead.org>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/pagemap.h |    1 +
 mm/filemap.c            |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9c66e99..7a1cb49 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+extern void delete_from_page_cache(struct page *page);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
diff --git a/mm/filemap.c b/mm/filemap.c
index 095c393..cf9bbf2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -166,6 +166,22 @@ void remove_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(remove_from_page_cache);
 
+/**
+ * delete_from_page_cache - delete page from page cache
+ * @page: the page which the kernel is trying to remove from page cache
+ *
+ * This must be called only on pages that have
+ * been verified to be in the page cache and locked.
+ * It will never put the page into the free list,
+ * the caller has a reference on the page.
+ */
+void delete_from_page_cache(struct page *page)
+{
+	remove_from_page_cache(page);
+	page_cache_release(page);
+}
+EXPORT_SYMBOL(delete_from_page_cache);
+
 static int sync_page(void *word)
 {
 	struct address_space *mapping;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
