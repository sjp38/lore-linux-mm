Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D64E16B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:10:40 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so12172904pdj.14
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:10:40 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id iz2si12612760pbc.230.2014.08.20.08.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 20 Aug 2014 08:05:21 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAM00DOL218UP60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Aug 2014 16:07:56 +0100 (BST)
Subject: [PATCH 6/7] mm/balloon_compaction: use common page ballooning
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 20 Aug 2014 19:05:04 +0400
Message-id: <20140820150503.4194.38388.stgit@buzz>
In-reply-to: <20140820150435.4194.28003.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

This patch replaces checking AS_BALLOON_MAP in page->mapping->flags
with PageBalloon which is stored directly in the struct page.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
---
 include/linux/balloon_compaction.h |   85 ++----------------------------------
 mm/Kconfig                         |    2 -
 mm/balloon_compaction.c            |    7 +--
 mm/compaction.c                    |    9 ++--
 mm/migrate.c                       |    4 +-
 mm/vmscan.c                        |    2 -
 6 files changed, 15 insertions(+), 94 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 53d482e..f5fda8b 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -108,77 +108,6 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
 }
 
 /*
- * page_flags_cleared - helper to perform balloon @page ->flags tests.
- *
- * As balloon pages are obtained from buddy and we do not play with page->flags
- * at driver level (exception made when we get the page lock for compaction),
- * we can safely identify a ballooned page by checking if the
- * PAGE_FLAGS_CHECK_AT_PREP page->flags are all cleared.  This approach also
- * helps us skip ballooned pages that are locked for compaction or release, thus
- * mitigating their racy check at balloon_page_movable()
- */
-static inline bool page_flags_cleared(struct page *page)
-{
-	return !(page->flags & PAGE_FLAGS_CHECK_AT_PREP);
-}
-
-/*
- * __is_movable_balloon_page - helper to perform @page mapping->flags tests
- */
-static inline bool __is_movable_balloon_page(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-	return !PageAnon(page) && mapping_balloon(mapping);
-}
-
-/*
- * balloon_page_movable - test page->mapping->flags to identify balloon pages
- *			  that can be moved by compaction/migration.
- *
- * This function is used at core compaction's page isolation scheme, therefore
- * most pages exposed to it are not enlisted as balloon pages and so, to avoid
- * undesired side effects like racing against __free_pages(), we cannot afford
- * holding the page locked while testing page->mapping->flags here.
- *
- * As we might return false positives in the case of a balloon page being just
- * released under us, the page->mapping->flags need to be re-tested later,
- * under the proper page lock, at the functions that will be coping with the
- * balloon page case.
- */
-static inline bool balloon_page_movable(struct page *page)
-{
-	/*
-	 * Before dereferencing and testing mapping->flags, let's make sure
-	 * this is not a page that uses ->mapping in a different way
-	 */
-	if (page_flags_cleared(page) && !page_mapped(page) &&
-	    page_count(page) == 1)
-		return __is_movable_balloon_page(page);
-
-	return false;
-}
-
-/*
- * isolated_balloon_page - identify an isolated balloon page on private
- *			   compaction/migration page lists.
- *
- * After a compaction thread isolates a balloon page for migration, it raises
- * the page refcount to prevent concurrent compaction threads from re-isolating
- * the same page. For that reason putback_movable_pages(), or other routines
- * that need to identify isolated balloon pages on private pagelists, cannot
- * rely on balloon_page_movable() to accomplish the task.
- */
-static inline bool isolated_balloon_page(struct page *page)
-{
-	/* Already isolated balloon pages, by default, have a raised refcount */
-	if (page_flags_cleared(page) && !page_mapped(page) &&
-	    page_count(page) >= 2)
-		return __is_movable_balloon_page(page);
-
-	return false;
-}
-
-/*
  * balloon_page_insert - insert a page into the balloon's page list and make
  *		         the page->mapping assignment accordingly.
  * @page    : page to be assigned as a 'balloon page'
@@ -192,6 +121,7 @@ static inline void balloon_page_insert(struct page *page,
 				       struct address_space *mapping,
 				       struct list_head *head)
 {
+	__SetPageBalloon(page);
 	page->mapping = mapping;
 	list_add(&page->lru, head);
 }
@@ -206,6 +136,7 @@ static inline void balloon_page_insert(struct page *page,
  */
 static inline void balloon_page_delete(struct page *page)
 {
+	__ClearPageBalloon(page);
 	page->mapping = NULL;
 	list_del(&page->lru);
 }
@@ -250,24 +181,16 @@ static inline void balloon_page_insert(struct page *page,
 				       struct address_space *mapping,
 				       struct list_head *head)
 {
+	__SetPageBalloon(page);
 	list_add(&page->lru, head);
 }
 
 static inline void balloon_page_delete(struct page *page)
 {
+	__ClearPageBalloon(page);
 	list_del(&page->lru);
 }
 
-static inline bool balloon_page_movable(struct page *page)
-{
-	return false;
-}
-
-static inline bool isolated_balloon_page(struct page *page)
-{
-	return false;
-}
-
 static inline bool balloon_page_isolate(struct page *page)
 {
 	return false;
diff --git a/mm/Kconfig b/mm/Kconfig
index 72e0db0..e09cf0a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -237,7 +237,7 @@ config MEMORY_BALLOON
 config BALLOON_COMPACTION
 	bool "Allow for balloon memory compaction/migration"
 	def_bool y
-	depends on COMPACTION && VIRTIO_BALLOON
+	depends on COMPACTION && MEMORY_BALLOON
 	help
 	  Memory fragmentation introduced by ballooning might reduce
 	  significantly the number of 2MB contiguous memory blocks that can be
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 533c567..22c8e03 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -253,8 +253,7 @@ bool balloon_page_isolate(struct page *page)
 			 * Prevent concurrent compaction threads from isolating
 			 * an already isolated balloon page by refcount check.
 			 */
-			if (__is_movable_balloon_page(page) &&
-			    page_count(page) == 2) {
+			if (PageBalloon(page) && page_count(page) == 2) {
 				__isolate_balloon_page(page);
 				unlock_page(page);
 				return true;
@@ -275,7 +274,7 @@ void balloon_page_putback(struct page *page)
 	 */
 	lock_page(page);
 
-	if (__is_movable_balloon_page(page)) {
+	if (PageBalloon(page)) {
 		__putback_balloon_page(page);
 		/* drop the extra ref count taken for page isolation */
 		put_page(page);
@@ -300,7 +299,7 @@ int balloon_page_migrate(struct page *newpage,
 	 */
 	BUG_ON(!trylock_page(newpage));
 
-	if (WARN_ON(!__is_movable_balloon_page(page))) {
+	if (WARN_ON(!PageBalloon(page))) {
 		dump_page(page, "not movable balloon page");
 		unlock_page(newpage);
 		return rc;
diff --git a/mm/compaction.c b/mm/compaction.c
index 0653f5f..e9aeed2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -596,11 +596,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 * Skip any other type of page
 		 */
 		if (!PageLRU(page)) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
-					/* Successfully isolated */
-					goto isolate_success;
-				}
+			if (unlikely(PageBalloon(page)) &&
+					balloon_page_isolate(page)) {
+				/* Successfully isolated */
+				goto isolate_success;
 			}
 			continue;
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 161d044..c35e6f2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -92,7 +92,7 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
+		if (unlikely(PageBalloon(page)))
 			balloon_page_putback(page);
 		else
 			putback_lru_page(page);
@@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(__is_movable_balloon_page(page))) {
+	if (unlikely(PageBalloon(page))) {
 		/*
 		 * A ballooned page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2836b53..f90f93e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1160,7 +1160,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
+		    !PageBalloon(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
