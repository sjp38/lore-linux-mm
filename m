Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6E07E6B00F0
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 00:23:02 -0500 (EST)
Received: by gyd10 with SMTP id 10so5186885gyd.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 21:23:00 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 6/7] Good bye remove_from_page_cache
Date: Tue, 11 Jan 2011 14:22:10 +0900
Message-Id: <a8f11de2e49f4e1b59ef35fcc14c4f157fb467ce.1294723009.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1294723009.git.minchan.kim@gmail.com>
References: <cover.1294723009.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1294723009.git.minchan.kim@gmail.com>
References: <cover.1294723009.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Now delete_from_page_cache replaces remove_from_page_cache.
So we remove remove_from_page_cache so fs or something out of
mainline will notice it when compile time and can fix it.

Cc: Christoph Hellwig <hch@infradead.org>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/pagemap.h |    1 -
 mm/filemap.c            |   27 +++++++++++----------------
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7a1cb49..7bf6587 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -455,7 +455,6 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
-extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
 extern void delete_from_page_cache(struct page *page);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index cf9bbf2..a5542fa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -148,7 +148,17 @@ void __remove_from_page_cache(struct page *page)
 	}
 }
 
-void remove_from_page_cache(struct page *page)
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
+
 {
 	struct address_space *mapping = page->mapping;
 	void (*freepage)(struct page *);
@@ -163,21 +173,6 @@ void remove_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-}
-EXPORT_SYMBOL(remove_from_page_cache);
-
-/**
- * delete_from_page_cache - delete page from page cache
- * @page: the page which the kernel is trying to remove from page cache
- *
- * This must be called only on pages that have
- * been verified to be in the page cache and locked.
- * It will never put the page into the free list,
- * the caller has a reference on the page.
- */
-void delete_from_page_cache(struct page *page)
-{
-	remove_from_page_cache(page);
 	page_cache_release(page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
