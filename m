Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 02AFB6B005A
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 04:57:37 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] mm: return boolean from page_has_private()
Date: Tue, 21 Jul 2009 10:56:34 +0200
Message-Id: <1248166594-8859-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make page_has_private() return a true boolean value and remove the
double negations from the two callsites using it for arithmetic.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page-flags.h |   11 ++++++-----
 mm/migrate.c               |    2 +-
 mm/vmscan.c                |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e2e5ce5..17119bd 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -396,8 +396,6 @@ static inline void __ClearPageTail(struct page *page)
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
 
-#endif /* !__GENERATING_BOUNDS_H */
-
 /**
  * page_has_private - Determine if page has private stuff
  * @page: The page to be checked
@@ -405,8 +403,11 @@ static inline void __ClearPageTail(struct page *page)
  * Determine if a page has private stuff, indicating that release routines
  * should be invoked upon it.
  */
-#define page_has_private(page)			\
-	((page)->flags & ((1 << PG_private) |	\
-			  (1 << PG_private_2)))
+static inline int page_has_private(struct page *page)
+{
+	return !!(page->flags & ((1 << PG_private) | (1 << PG_private_2)));
+}
+
+#endif /* !__GENERATING_BOUNDS_H */
 
 #endif	/* PAGE_FLAGS_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index e97e513..16052e8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -272,7 +272,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	expected_count = 2 + !!page_has_private(page);
+	expected_count = 2 + page_has_private(page);
 	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6b368d3..67e2824 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -286,7 +286,7 @@ static inline int page_mapping_inuse(struct page *page)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
-	return page_count(page) - !!page_has_private(page) == 2;
+	return page_count(page) - page_has_private(page) == 2;
 }
 
 static int may_write_to_queue(struct backing_dev_info *bdi)
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
