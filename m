Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 83F546B0062
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:32:14 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] mm: return boolean from page_has_private()
Date: Wed, 12 Aug 2009 10:32:08 +0200
Message-Id: <1250065929-17392-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Make page_has_private() return a true boolean value and remove the
double negations from the two callsites using it for arithmetic.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/page-flags.h |   13 ++++++++-----
 mm/migrate.c               |    2 +-
 mm/vmscan.c                |    2 +-
 3 files changed, 10 insertions(+), 7 deletions(-)

v2: group private flags in PAGE_FLAGS_PRIVATE [thanks, Christoph]

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 10e6011..840c53b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -402,8 +402,8 @@ static inline void __ClearPageTail(struct page *page)
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
 
-#endif /* !__GENERATING_BOUNDS_H */
-
+#define PAGE_FLAGS_PRIVATE				\
+	(1 << PG_private | 1 << PG_private_2)
 /**
  * page_has_private - Determine if page has private stuff
  * @page: The page to be checked
@@ -411,8 +411,11 @@ static inline void __ClearPageTail(struct page *page)
  * Determine if a page has private stuff, indicating that release routines
  * should be invoked upon it.
  */
-#define page_has_private(page)			\
-	((page)->flags & ((1 << PG_private) |	\
-			  (1 << PG_private_2)))
+static inline int page_has_private(struct page *page)
+{
+	return !!(page->flags & PAGE_FLAGS_PRIVATE);
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
index b0f8fc2..4904986 100644
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
1.6.4.13.ge6580

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
