Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC6356B0256
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 04:34:16 -0400 (EDT)
Received: by pacan13 with SMTP id an13so12217925pac.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 01:34:16 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qq9si26580641pbb.13.2015.07.13.01.34.14
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 01:34:15 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [PATCH 3/4] mm/balloon: apply mobile page migratable into balloon
Date: Mon, 13 Jul 2015 17:35:18 +0900
Message-Id: <1436776519-17337-4-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gioh.kim@lge.com>

From: Gioh Kim <gurugio@hanmail.net>

Apply mobile page migration into balloon driver.
The balloong driver has an anonymous inode that manages
address_space_operation for page migration.
Compaction calls interfaces of mobile page migration
instead of calling balloon migration directly.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c    |  3 ++
 include/linux/balloon_compaction.h | 15 ++++++--
 mm/balloon_compaction.c            | 72 ++++++++++++--------------------------
 mm/compaction.c                    |  8 ++---
 mm/migrate.c                       | 21 ++++++-----
 5 files changed, 54 insertions(+), 65 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 82e80e0..ef5b9b5 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -30,6 +30,7 @@
 #include <linux/balloon_compaction.h>
 #include <linux/oom.h>
 #include <linux/wait.h>
+#include <linux/anon_inodes.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -505,6 +506,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	balloon_devinfo_init(&vb->vb_dev_info);
 #ifdef CONFIG_BALLOON_COMPACTION
 	vb->vb_dev_info.migratepage = virtballoon_migratepage;
+	vb->vb_dev_info.inode = anon_inode_new();
+	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
 
 	err = init_vqs(vb);
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 9b0a15d..a9e0bde 100644
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
@@ -73,12 +75,16 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 	spin_lock_init(&balloon->pages_lock);
 	INIT_LIST_HEAD(&balloon->pages);
 	balloon->migratepage = NULL;
+	balloon->inode = NULL;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
-extern bool balloon_page_isolate(struct page *page);
+extern const struct address_space_operations balloon_aops;
+extern bool balloon_page_isolate(struct page *page,
+				 isolate_mode_t mode);
 extern void balloon_page_putback(struct page *page);
-extern int balloon_page_migrate(struct page *newpage,
+extern int balloon_page_migrate(struct address_space *mapping,
+				struct page *newpage,
 				struct page *page, enum migrate_mode mode);
 
 /*
@@ -124,6 +130,7 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
 	__SetPageBalloon(page);
+	page->mapping = balloon->inode->i_mapping;
 	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)balloon);
 	list_add(&page->lru, &balloon->pages);
@@ -140,6 +147,7 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 static inline void balloon_page_delete(struct page *page)
 {
 	__ClearPageBalloon(page);
+	page->mapping = NULL;
 	set_page_private(page, 0);
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
@@ -191,7 +199,8 @@ static inline bool isolated_balloon_page(struct page *page)
 	return false;
 }
 
-static inline bool balloon_page_isolate(struct page *page)
+static inline bool balloon_page_isolate(struct page *page,
+					isolate_mode_t mode)
 {
 	return false;
 }
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index fcad832..8fbcf9c 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -131,43 +131,16 @@ static inline void __putback_balloon_page(struct page *page)
 }
 
 /* __isolate_lru_page() counterpart for a ballooned page */
-bool balloon_page_isolate(struct page *page)
+bool balloon_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	/*
-	 * Avoid burning cycles with pages that are yet under __free_pages(),
-	 * or just got freed under us.
-	 *
-	 * In case we 'win' a race for a balloon page being freed under us and
-	 * raise its refcount preventing __free_pages() from doing its job
-	 * the put_page() at the end of this block will take care of
-	 * release this page, thus avoiding a nasty leakage.
+	 * A ballooned page, by default, has PagePrivate set.
+	 * Prevent concurrent compaction threads from isolating
+	 * an already isolated balloon page by clearing it.
 	 */
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
+	if (balloon_page_movable(page)) {
+		__isolate_balloon_page(page);
+		return true;
 	}
 	return false;
 }
@@ -175,37 +148,31 @@ bool balloon_page_isolate(struct page *page)
 /* putback_lru_page() counterpart for a ballooned page */
 void balloon_page_putback(struct page *page)
 {
-	/*
-	 * 'lock_page()' stabilizes the page and prevents races against
-	 * concurrent isolation threads attempting to re-isolate it.
-	 */
-	lock_page(page);
+	if (!isolated_balloon_page(page))
+		return;
 
 	if (__is_movable_balloon_page(page)) {
 		__putback_balloon_page(page);
-		/* drop the extra ref count taken for page isolation */
-		put_page(page);
 	} else {
 		WARN_ON(1);
 		dump_page(page, "not movable balloon page");
 	}
-	unlock_page(page);
 }
 
 /* move_to_new_page() counterpart for a ballooned page */
-int balloon_page_migrate(struct page *newpage,
+int balloon_page_migrate(struct address_space *mapping,
+			 struct page *newpage,
 			 struct page *page, enum migrate_mode mode)
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
 	int rc = -EAGAIN;
 
+	if (!isolated_balloon_page(page))
+		return rc;
+
 	/*
-	 * Block others from accessing the 'newpage' when we get around to
-	 * establishing additional references. We should be the only one
-	 * holding a reference to the 'newpage' at this point.
+	 * newpage and page should be already locked.
 	 */
-	BUG_ON(!trylock_page(newpage));
-
 	if (WARN_ON(!__is_movable_balloon_page(page))) {
 		dump_page(page, "not movable balloon page");
 		unlock_page(newpage);
@@ -215,7 +182,14 @@ int balloon_page_migrate(struct page *newpage,
 	if (balloon && balloon->migratepage)
 		rc = balloon->migratepage(balloon, newpage, page, mode);
 
-	unlock_page(newpage);
 	return rc;
 }
+
+/* define the balloon_mapping->a_ops callback to allow balloon page migration */
+const struct address_space_operations balloon_aops = {
+	.migratepage = balloon_page_migrate,
+	.isolatepage = balloon_page_isolate,
+	.putbackpage = balloon_page_putback,
+};
+EXPORT_SYMBOL_GPL(balloon_aops);
 #endif /* CONFIG_BALLOON_COMPACTION */
diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..60e4cbb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -14,7 +14,7 @@
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
-#include <linux/balloon_compaction.h>
+#include <linux/compaction.h>
 #include <linux/page-isolation.h>
 #include <linux/kasan.h>
 #include "internal.h"
@@ -714,12 +714,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU pages and balloon pages
+		 * It's possible to migrate LRU pages and mobile pages
 		 * Skip any other type of page
 		 */
 		if (!PageLRU(page)) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
+			if (unlikely(mobile_page(page))) {
+				if (isolate_mobilepage(page, isolate_mode)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}
diff --git a/mm/migrate.c b/mm/migrate.c
index ee401e4..53f0081d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -35,7 +35,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
-#include <linux/balloon_compaction.h>
+#include <linux/compaction.h>
 #include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
@@ -76,7 +76,7 @@ int migrate_prep_local(void)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
+ * built from lru, mobile, hugetlbfs page. See isolate_migratepages_range()
  * and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
@@ -92,8 +92,8 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
-			balloon_page_putback(page);
+		if (unlikely(mobile_page(page)))
+			putback_mobilepage(page);
 		else
 			putback_lru_page(page);
 	}
@@ -844,15 +844,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(isolated_balloon_page(page))) {
+	if (unlikely(mobile_page(page))) {
 		/*
-		 * A ballooned page does not need any special attention from
+		 * A mobile page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
 		 * Skip any attempt to unmap PTEs or to remap swap cache,
 		 * in order to avoid burning cycles at rmap level, and perform
 		 * the page migration right away (proteced by page lock).
 		 */
-		rc = balloon_page_migrate(newpage, page, mode);
+		lock_page(newpage);
+		rc = page->mapping->a_ops->migratepage(page->mapping,
+						       newpage, page, mode);
+		unlock_page(newpage);
 		goto out_unlock;
 	}
 
@@ -962,8 +965,8 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
-		/* drop our reference, page already in the balloon */
+	} else if (unlikely(mobile_page(newpage))) {
+		/* drop our reference */
 		put_page(newpage);
 	} else
 		putback_lru_page(newpage);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
