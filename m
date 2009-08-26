Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B36846B00BE
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:54:21 -0400 (EDT)
Date: Wed, 26 Aug 2009 10:53:47 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] mm: introduce page_lru_base_type fix
Message-ID: <Pine.LNX.4.64.0908261050080.18633@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My usual tmpfs swapping loads on recent mmotms have oddly
aroused the OOM killer after an hour or two.  Bisection led to
mm-return-boolean-from-page_is_file_cache.patch, but really it's
the prior mm-introduce-page_lru_base_type.patch that's at fault.

It converted page_lru() to use page_lru_base_type(), but forgot
to convert del_page_from_lru() - which then decremented the wrong
stats once page_is_file_cache() was changed to a boolean.

Fix that, move page_lru_base_type() before del_page_from_lru(),
and mark it "inline" like the other mm_inline.h functions.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/mm_inline.h |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

--- mmotm/include/linux/mm_inline.h	2009-08-21 12:12:42.000000000 +0100
+++ linux/include/linux/mm_inline.h	2009-08-26 00:39:38.000000000 +0100
@@ -35,42 +35,42 @@ del_page_from_lru_list(struct zone *zone
 	mem_cgroup_del_lru_list(page, l);
 }
 
+/**
+ * page_lru_base_type - which LRU list type should a page be on?
+ * @page: the page to test
+ *
+ * Used for LRU list index arithmetic.
+ *
+ * Returns the base LRU type - file or anon - @page should be on.
+ */
+static inline enum lru_list page_lru_base_type(struct page *page)
+{
+	if (page_is_file_cache(page))
+		return LRU_INACTIVE_FILE;
+	return LRU_INACTIVE_ANON;
+}
+
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
-	enum lru_list l = LRU_BASE;
+	enum lru_list l;
 
 	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
 	} else {
+		l = page_lru_base_type(page);
 		if (PageActive(page)) {
 			__ClearPageActive(page);
 			l += LRU_ACTIVE;
 		}
-		l += page_is_file_cache(page);
 	}
 	__dec_zone_state(zone, NR_LRU_BASE + l);
 	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
- * page_lru_base_type - which LRU list type should a page be on?
- * @page: the page to test
- *
- * Used for LRU list index arithmetic.
- *
- * Returns the base LRU type - file or anon - @page should be on.
- */
-static enum lru_list page_lru_base_type(struct page *page)
-{
-	if (page_is_file_cache(page))
-		return LRU_INACTIVE_FILE;
-	return LRU_INACTIVE_ANON;
-}
-
-/**
  * page_lru - which LRU list should a page be on?
  * @page: the page to test
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
