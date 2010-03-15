Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 44BC96B01CB
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:16:46 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 22so1024714fge.8
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 06:16:43 -0700 (PDT)
Subject: [PATCH] mm: remove return value of putback_lru_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 15 Mar 2010 22:16:34 +0900
Message-ID: <1268658994.1889.8.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Now putback_lru_page never can fail.
So it doesn't matter count of "the number of pages put back".

In addition, users of this functions don't use return value.

Let's remove unnecessary code.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/migrate.h |    4 ++--
 mm/migrate.c            |    7 +------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7f085c9..7a07b17 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -9,7 +9,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 #ifdef CONFIG_MIGRATION
 #define PAGE_MIGRATION 1
 
-extern int putback_lru_pages(struct list_head *l);
+extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
@@ -25,7 +25,7 @@ extern int migrate_vmas(struct mm_struct *mm,
 #else
 #define PAGE_MIGRATION 0
 
-static inline int putback_lru_pages(struct list_head *l) { return 0; }
+static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, int offlining) { return -ENOSYS; }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 88000b8..6903abf 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -57,23 +57,18 @@ int migrate_prep(void)
 /*
  * Add isolated pages on the list back to the LRU under page lock
  * to avoid leaking evictable pages back onto unevictable list.
- *
- * returns the number of pages put back.
  */
-int putback_lru_pages(struct list_head *l)
+void putback_lru_pages(struct list_head *l)
 {
 	struct page *page;
 	struct page *page2;
-	int count = 0;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		putback_lru_page(page);
-		count++;
 	}
-	return count;
 }
 
 /*
-- 
1.6.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
