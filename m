Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id E1070828E1
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:29:57 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id ig19so4219604igb.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:29:57 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h14si1339539igt.51.2016.03.10.23.29.48
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:49 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 04/19] mm/balloon: use general movable page feature into balloon
Date: Fri, 11 Mar 2016 16:30:08 +0900
Message-Id: <1457681423-26664-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

Now, VM has a feature to migrate non-lru movable pages so
balloon doesn't need custom migration hooks in migrate.c
and compact.c. Instead, this patch implements page->mapping
->{isolate|migrate|putback} functions.

With that, we could remove hooks for ballooning in general
migration functions and make balloon compaction simple.

Cc: virtualization@lists.linux-foundation.org
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Gioh Kim <gurugio@hanmail.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/virtio/virtio_balloon.c    |   4 ++
 include/linux/balloon_compaction.h |  47 ++++-------------
 include/linux/page-flags.h         |  53 +++++++++++--------
 mm/balloon_compaction.c            | 101 ++++++++-----------------------------
 mm/compaction.c                    |   7 ---
 mm/migrate.c                       |  22 ++------
 mm/vmscan.c                        |   2 +-
 7 files changed, 73 insertions(+), 163 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0c3691f46575..30a1ea31bef4 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -30,6 +30,7 @@
 #include <linux/balloon_compaction.h>
 #include <linux/oom.h>
 #include <linux/wait.h>
+#include <linux/anon_inodes.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -476,6 +477,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 
 	mutex_unlock(&vb->balloon_lock);
 
+	ClearPageIsolated(page);
 	put_page(page); /* balloon reference */
 
 	return MIGRATEPAGE_SUCCESS;
@@ -509,6 +511,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	balloon_devinfo_init(&vb->vb_dev_info);
 #ifdef CONFIG_BALLOON_COMPACTION
 	vb->vb_dev_info.migratepage = virtballoon_migratepage;
+	vb->vb_dev_info.inode = anon_inode_new();
+	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
 
 	err = init_vqs(vb);
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 9b0a15d06a4f..43a858545844 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -48,6 +48,7 @@
 #include <linux/migrate.h>
 #include <linux/gfp.h>
 #include <linux/err.h>
+#include <linux/fs.h>
 
 /*
  * Balloon device information descriptor.
@@ -62,6 +63,7 @@ struct balloon_dev_info {
 	struct list_head pages;		/* Pages enqueued & handled to Host */
 	int (*migratepage)(struct balloon_dev_info *, struct page *newpage,
 			struct page *page, enum migrate_mode mode);
+	struct inode *inode;
 };
 
 extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
@@ -73,45 +75,19 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 	spin_lock_init(&balloon->pages_lock);
 	INIT_LIST_HEAD(&balloon->pages);
 	balloon->migratepage = NULL;
+	balloon->inode = NULL;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
-extern bool balloon_page_isolate(struct page *page);
+extern const struct address_space_operations balloon_aops;
+extern bool balloon_page_isolate(struct page *page,
+				isolate_mode_t mode);
 extern void balloon_page_putback(struct page *page);
-extern int balloon_page_migrate(struct page *newpage,
+extern int balloon_page_migrate(struct address_space *mapping,
+				struct page *newpage,
 				struct page *page, enum migrate_mode mode);
 
 /*
- * __is_movable_balloon_page - helper to perform @page PageBalloon tests
- */
-static inline bool __is_movable_balloon_page(struct page *page)
-{
-	return PageBalloon(page);
-}
-
-/*
- * balloon_page_movable - test PageBalloon to identify balloon pages
- *			  and PagePrivate to check that the page is not
- *			  isolated and can be moved by compaction/migration.
- *
- * As we might return false positives in the case of a balloon page being just
- * released under us, this need to be re-tested later, under the page lock.
- */
-static inline bool balloon_page_movable(struct page *page)
-{
-	return PageBalloon(page) && PagePrivate(page);
-}
-
-/*
- * isolated_balloon_page - identify an isolated balloon page on private
- *			   compaction/migration page lists.
- */
-static inline bool isolated_balloon_page(struct page *page)
-{
-	return PageBalloon(page);
-}
-
-/*
  * balloon_page_insert - insert a page into the balloon's page list and make
  *			 the page->private assignment accordingly.
  * @balloon : pointer to balloon device
@@ -123,8 +99,8 @@ static inline bool isolated_balloon_page(struct page *page)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
+	page->mapping = balloon->inode->i_mapping;
 	__SetPageBalloon(page);
-	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)balloon);
 	list_add(&page->lru, &balloon->pages);
 }
@@ -140,11 +116,10 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 static inline void balloon_page_delete(struct page *page)
 {
 	__ClearPageBalloon(page);
+	page->mapping = NULL;
 	set_page_private(page, 0);
-	if (PagePrivate(page)) {
-		ClearPagePrivate(page);
+	if (!PageIsolated(page))
 		list_del(&page->lru);
-	}
 }
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index cdf07c3f3a6f..94d46d947490 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -597,50 +597,59 @@ static inline void __ClearPageBuddy(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
-#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
+#define PAGE_MOVABLE_MAPCOUNT_VALUE (-256)
+#define PAGE_BALLOON_MAPCOUNT_VALUE PAGE_MOVABLE_MAPCOUNT_VALUE
 
-static inline int PageBalloon(struct page *page)
+static inline int PageMovable(struct page *page)
 {
-	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
+	return (test_bit(PG_movable, &(page)->flags) &&
+		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE);
 }
 
-static inline void __SetPageBalloon(struct page *page)
+static inline void __SetPageMovable(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+	WARN_ON(!page->mapping);
+
+	__set_bit(PG_movable, &page->flags);
+	atomic_set(&page->_mapcount, PAGE_MOVABLE_MAPCOUNT_VALUE);
 }
 
-static inline void __ClearPageBalloon(struct page *page)
+static inline void __ClearPageMovable(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageBalloon(page), page);
 	atomic_set(&page->_mapcount, -1);
+	__clear_bit(PG_movable, &(page)->flags);
 }
 
-#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
+PAGEFLAG(Isolated, isolated, PF_ANY);
 
-static inline int PageMovable(struct page *page)
+static inline int PageBalloon(struct page *page)
 {
-	return ((test_bit(PG_movable, &(page)->flags) &&
-		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
-		|| PageBalloon(page));
+	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE
+		&& PagePrivate2(page);
 }
 
-static inline void __SetPageMovable(struct page *page)
+static inline void __SetPageBalloon(struct page *page)
 {
-	WARN_ON(!page->mapping);
-
-	__set_bit(PG_movable, &page->flags);
-	atomic_set(&page->_mapcount, PAGE_MOVABLE_MAPCOUNT_VALUE);
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+#ifdef CONFIG_BALLOON_COMPACTION
+	__SetPageMovable(page);
+#else
+	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+#endif
+	SetPagePrivate2(page);
 }
 
-static inline void __ClearPageMovable(struct page *page)
+static inline void __ClearPageBalloon(struct page *page)
 {
+	VM_BUG_ON_PAGE(!PageBalloon(page), page);
+#ifdef CONFIG_BALLOON_COMPACTION
+	__ClearPageMovable(page);
+#else
 	atomic_set(&page->_mapcount, -1);
-	__clear_bit(PG_movable, &(page)->flags);
+#endif
+	ClearPagePrivate2(page);
 }
 
-PAGEFLAG(Isolated, isolated, PF_ANY);
-
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 300117f1a08f..2c091bf5e22b 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -70,7 +70,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 		 */
 		if (trylock_page(page)) {
 #ifdef CONFIG_BALLOON_COMPACTION
-			if (!PagePrivate(page)) {
+			if (PageIsolated(page)) {
 				/* raced with isolation */
 				unlock_page(page);
 				continue;
@@ -106,110 +106,53 @@ EXPORT_SYMBOL_GPL(balloon_page_dequeue);
 
 #ifdef CONFIG_BALLOON_COMPACTION
 
-static inline void __isolate_balloon_page(struct page *page)
+/* __isolate_lru_page() counterpart for a ballooned page */
+bool balloon_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
 	unsigned long flags;
 
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	ClearPagePrivate(page);
 	list_del(&page->lru);
 	b_dev_info->isolated_pages++;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	SetPageIsolated(page);
+
+	return true;
 }
 
-static inline void __putback_balloon_page(struct page *page)
+/* putback_lru_page() counterpart for a ballooned page */
+void balloon_page_putback(struct page *page)
 {
 	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
 	unsigned long flags;
 
+	ClearPageIsolated(page);
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	SetPagePrivate(page);
 	list_add(&page->lru, &b_dev_info->pages);
 	b_dev_info->isolated_pages--;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 }
 
-/* __isolate_lru_page() counterpart for a ballooned page */
-bool balloon_page_isolate(struct page *page)
-{
-	/*
-	 * Avoid burning cycles with pages that are yet under __free_pages(),
-	 * or just got freed under us.
-	 *
-	 * In case we 'win' a race for a balloon page being freed under us and
-	 * raise its refcount preventing __free_pages() from doing its job
-	 * the put_page() at the end of this block will take care of
-	 * release this page, thus avoiding a nasty leakage.
-	 */
-	if (likely(get_page_unless_zero(page))) {
-		/*
-		 * As balloon pages are not isolated from LRU lists, concurrent
-		 * compaction threads can race against page migration functions
-		 * as well as race against the balloon driver releasing a page.
-		 *
-		 * In order to avoid having an already isolated balloon page
-		 * being (wrongly) re-isolated while it is under migration,
-		 * or to avoid attempting to isolate pages being released by
-		 * the balloon driver, lets be sure we have the page lock
-		 * before proceeding with the balloon page isolation steps.
-		 */
-		if (likely(trylock_page(page))) {
-			/*
-			 * A ballooned page, by default, has PagePrivate set.
-			 * Prevent concurrent compaction threads from isolating
-			 * an already isolated balloon page by clearing it.
-			 */
-			if (balloon_page_movable(page)) {
-				__isolate_balloon_page(page);
-				unlock_page(page);
-				return true;
-			}
-			unlock_page(page);
-		}
-		put_page(page);
-	}
-	return false;
-}
-
-/* putback_lru_page() counterpart for a ballooned page */
-void balloon_page_putback(struct page *page)
-{
-	/*
-	 * 'lock_page()' stabilizes the page and prevents races against
-	 * concurrent isolation threads attempting to re-isolate it.
-	 */
-	lock_page(page);
-
-	if (__is_movable_balloon_page(page)) {
-		__putback_balloon_page(page);
-		/* drop the extra ref count taken for page isolation */
-		put_page(page);
-	} else {
-		WARN_ON(1);
-		dump_page(page, "not movable balloon page");
-	}
-	unlock_page(page);
-}
-
 /* move_to_new_page() counterpart for a ballooned page */
-int balloon_page_migrate(struct page *newpage,
-			 struct page *page, enum migrate_mode mode)
+int balloon_page_migrate(struct address_space *mapping,
+		struct page *newpage, struct page *page,
+		enum migrate_mode mode)
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
-	int rc = -EAGAIN;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
-	if (WARN_ON(!__is_movable_balloon_page(page))) {
-		dump_page(page, "not movable balloon page");
-		return rc;
-	}
-
-	if (balloon && balloon->migratepage)
-		rc = balloon->migratepage(balloon, newpage, page, mode);
-
-	return rc;
+	return balloon->migratepage(balloon, newpage, page, mode);
 }
+
+const struct address_space_operations balloon_aops = {
+	.migratepage = balloon_page_migrate,
+	.isolate_page = balloon_page_isolate,
+	.putback_page = balloon_page_putback,
+};
+EXPORT_SYMBOL_GPL(balloon_aops);
 #endif /* CONFIG_BALLOON_COMPACTION */
diff --git a/mm/compaction.c b/mm/compaction.c
index 99f791bf2ba6..e322307ac8de 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -741,13 +741,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		is_lru = PageLRU(page);
 		if (!is_lru) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
-					/* Successfully isolated */
-					goto isolate_success;
-				}
-			}
-
 			if (unlikely(PageMovable(page)) &&
 					!PageIsolated(page)) {
 				if (locked) {
diff --git a/mm/migrate.c b/mm/migrate.c
index b7b2a60f57c4..98b5e7f07548 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -146,8 +146,8 @@ void putback_movable_page(struct page *page)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
- * and isolate_huge_page().
+ * built from lru, movable, hugetlbfs page.
+ * See isolate_migratepages_range() and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
 {
@@ -162,9 +162,7 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
-			balloon_page_putback(page);
-		else if (unlikely(PageIsolated(page)))
+		if (unlikely(PageIsolated(page)))
 			putback_movable_page(page);
 		else
 			putback_lru_page(page);
@@ -953,18 +951,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	if (unlikely(!trylock_page(newpage)))
 		goto out_unlock;
 
-	if (unlikely(isolated_balloon_page(page))) {
-		/*
-		 * A ballooned page does not need any special attention from
-		 * physical to virtual reverse mapping procedures.
-		 * Skip any attempt to unmap PTEs or to remap swap cache,
-		 * in order to avoid burning cycles at rmap level, and perform
-		 * the page migration right away (proteced by page lock).
-		 */
-		rc = balloon_page_migrate(newpage, page, mode);
-		goto out_unlock_both;
-	}
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -1009,7 +995,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 out:
 	/* If migration is scucessful, move newpage to right list */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__is_movable_balloon_page(newpage)))
+		if (unlikely(PageMovable(newpage)))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71b1c29948db..ca49b4f53c81 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1262,7 +1262,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
+		    !PageIsolated(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
