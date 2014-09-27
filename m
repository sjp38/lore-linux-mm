Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 369BF6B0039
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 15:15:37 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gq15so16170819lab.11
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:36 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id o6si12054413lbc.99.2014.09.27.12.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 12:15:35 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id z12so13353244lbi.23
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:35 -0700 (PDT)
Subject: [PATCH v3 1/4] mm/balloon_compaction: redesign ballooned pages
 management
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Sep 2014 23:15:16 +0400
Message-ID: <20140927191515.13738.18027.stgit@zurg>
In-Reply-To: <20140927183403.13738.22121.stgit@zurg>
References: <20140927183403.13738.22121.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Rafael Aquini <aquini@redhat.com>, Stable <stable@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>

From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>

Sasha Levin reported KASAN splash inside isolate_migratepages_range().
Problem is in the function __is_movable_balloon_page() which tests
AS_BALLOON_MAP in page->mapping->flags.  This function has no protection
against anonymous pages.  As result it tried to check address space flags
inside struct anon_vma.

Further investigation shows more problems in current implementation:

* Special branch in __unmap_and_move() never works: balloon_page_movable()
checks page flags and page_count.  In __unmap_and_move() page is locked,
reference counter is elevated, thus balloon_page_movable() always fails.
As a result execution goes to the normal migration path.
virtballoon_migratepage() returns MIGRATEPAGE_BALLOON_SUCCESS instead of
MIGRATEPAGE_SUCCESS, move_to_new_page() thinks this is an error code and
assigns newpage->mapping to NULL. Newly migrated page lose connectivity
with balloon an all ability for further migration.

* lru_lock erroneously required in isolate_migratepages_range() for
isolation ballooned page. This function releases lru_lock periodically,
this makes migration mostly impossible for some pages.

* balloon_page_dequeue have a tight race with balloon_page_isolate:
balloon_page_isolate could be executed in parallel with dequeue between
picking page from list and locking page_lock. Race is rare because they
use trylock_page() for locking.

This patch fixes all of them.

Instead of fake mapping with special flag this patch uses special state
of page->_mapcount: PAGE_BALLOON_MAPCOUNT_VALUE = -256. Buddy allocator
uses PAGE_BUDDY_MAPCOUNT_VALUE = -128 for similar purpose. Storing mark
directly in struct page makes everything safer and easier.

PagePrivate is used to mark pages present in page list (i.e. not isolated,
like PageLRU for normal pages). It replaces special rules for reference
counter and makes balloon migration similar to migration of normal pages.
This flag is protected by page_lock together with link to the balloon device.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Link: http://lkml.kernel.org/p/53E6CEAA.9020105@oracle.com
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Stable <stable@vger.kernel.org>	(v3.8+)
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c    |   15 +++---
 include/linux/balloon_compaction.h |   97 +++++++++---------------------------
 include/linux/migrate.h            |   11 ----
 include/linux/mm.h                 |   19 +++++++
 mm/balloon_compaction.c            |   26 ++++------
 mm/compaction.c                    |    2 -
 mm/migrate.c                       |   16 +-----
 7 files changed, 68 insertions(+), 118 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 25ebe8e..c3eb93fc 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -163,8 +163,8 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
 	/* Find pfns pointing at start of each page, get pages and free them. */
 	for (i = 0; i < num; i += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = balloon_pfn_to_page(pfns[i]);
-		balloon_page_free(page);
 		adjust_managed_page_count(page, 1);
+		put_page(page); /* balloon reference */
 	}
 }
 
@@ -395,6 +395,8 @@ static int virtballoon_migratepage(struct address_space *mapping,
 	if (!mutex_trylock(&vb->balloon_lock))
 		return -EAGAIN;
 
+	get_page(newpage); /* balloon reference */
+
 	/* balloon's page migration 1st step  -- inflate "newpage" */
 	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
 	balloon_page_insert(newpage, mapping, &vb_dev_info->pages);
@@ -404,12 +406,7 @@ static int virtballoon_migratepage(struct address_space *mapping,
 	set_page_pfns(vb->pfns, newpage);
 	tell_host(vb, vb->inflate_vq);
 
-	/*
-	 * balloon's page migration 2nd step -- deflate "page"
-	 *
-	 * It's safe to delete page->lru here because this page is at
-	 * an isolated migration list, and this step is expected to happen here
-	 */
+	/* balloon's page migration 2nd step -- deflate "page" */
 	balloon_page_delete(page);
 	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
 	set_page_pfns(vb->pfns, page);
@@ -417,7 +414,9 @@ static int virtballoon_migratepage(struct address_space *mapping,
 
 	mutex_unlock(&vb->balloon_lock);
 
-	return MIGRATEPAGE_BALLOON_SUCCESS;
+	put_page(page); /* balloon reference */
+
+	return MIGRATEPAGE_SUCCESS;
 }
 
 /* define the balloon_mapping->a_ops callback to allow balloon page migration */
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 089743a..38aa07d 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -27,10 +27,13 @@
  *      counter raised only while it is under our special handling;
  *
  * iii. after the lockless scan step have selected a potential balloon page for
- *      isolation, re-test the page->mapping flags and the page ref counter
+ *      isolation, re-test the PageBalloon mark and the PagePrivate flag
  *      under the proper page lock, to ensure isolating a valid balloon page
  *      (not yet isolated, nor under release procedure)
  *
+ *  iv. isolation or dequeueing procedure must clear PagePrivate flag under
+ *      page lock together with removing page from balloon device page list.
+ *
  * The functions provided by this interface are placed to help on coping with
  * the aforementioned balloon page corner case, as well as to ensure the simple
  * set of exposed rules are satisfied while we are dealing with balloon pages
@@ -71,28 +74,6 @@ static inline void balloon_devinfo_free(struct balloon_dev_info *b_dev_info)
 	kfree(b_dev_info);
 }
 
-/*
- * balloon_page_free - release a balloon page back to the page free lists
- * @page: ballooned page to be set free
- *
- * This function must be used to properly set free an isolated/dequeued balloon
- * page at the end of a sucessful page migration, or at the balloon driver's
- * page release procedure.
- */
-static inline void balloon_page_free(struct page *page)
-{
-	/*
-	 * Balloon pages always get an extra refcount before being isolated
-	 * and before being dequeued to help on sorting out fortuite colisions
-	 * between a thread attempting to isolate and another thread attempting
-	 * to release the very same balloon page.
-	 *
-	 * Before we handle the page back to Buddy, lets drop its extra refcnt.
-	 */
-	put_page(page);
-	__free_page(page);
-}
-
 #ifdef CONFIG_BALLOON_COMPACTION
 extern bool balloon_page_isolate(struct page *page);
 extern void balloon_page_putback(struct page *page);
@@ -108,74 +89,33 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
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
+ * __is_movable_balloon_page - helper to perform @page PageBalloon tests
  */
 static inline bool __is_movable_balloon_page(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
-	return mapping_balloon(mapping);
+	return PageBalloon(page);
 }
 
 /*
- * balloon_page_movable - test page->mapping->flags to identify balloon pages
- *			  that can be moved by compaction/migration.
- *
- * This function is used at core compaction's page isolation scheme, therefore
- * most pages exposed to it are not enlisted as balloon pages and so, to avoid
- * undesired side effects like racing against __free_pages(), we cannot afford
- * holding the page locked while testing page->mapping->flags here.
+ * balloon_page_movable - test PageBalloon to identify balloon pages
+ *			  and PagePrivate to check that the page is not
+ *			  isolated and can be moved by compaction/migration.
  *
  * As we might return false positives in the case of a balloon page being just
- * released under us, the page->mapping->flags need to be re-tested later,
- * under the proper page lock, at the functions that will be coping with the
- * balloon page case.
+ * released under us, this need to be re-tested later, under the page lock.
  */
 static inline bool balloon_page_movable(struct page *page)
 {
-	/*
-	 * Before dereferencing and testing mapping->flags, let's make sure
-	 * this is not a page that uses ->mapping in a different way
-	 */
-	if (page_flags_cleared(page) && !page_mapped(page) &&
-	    page_count(page) == 1)
-		return __is_movable_balloon_page(page);
-
-	return false;
+	return PageBalloon(page) && PagePrivate(page);
 }
 
 /*
  * isolated_balloon_page - identify an isolated balloon page on private
  *			   compaction/migration page lists.
- *
- * After a compaction thread isolates a balloon page for migration, it raises
- * the page refcount to prevent concurrent compaction threads from re-isolating
- * the same page. For that reason putback_movable_pages(), or other routines
- * that need to identify isolated balloon pages on private pagelists, cannot
- * rely on balloon_page_movable() to accomplish the task.
  */
 static inline bool isolated_balloon_page(struct page *page)
 {
-	/* Already isolated balloon pages, by default, have a raised refcount */
-	if (page_flags_cleared(page) && !page_mapped(page) &&
-	    page_count(page) >= 2)
-		return __is_movable_balloon_page(page);
-
-	return false;
+	return PageBalloon(page);
 }
 
 /*
@@ -192,6 +132,8 @@ static inline void balloon_page_insert(struct page *page,
 				       struct address_space *mapping,
 				       struct list_head *head)
 {
+	__SetPageBalloon(page);
+	SetPagePrivate(page);
 	page->mapping = mapping;
 	list_add(&page->lru, head);
 }
@@ -206,8 +148,12 @@ static inline void balloon_page_insert(struct page *page,
  */
 static inline void balloon_page_delete(struct page *page)
 {
+	__ClearPageBalloon(page);
 	page->mapping = NULL;
-	list_del(&page->lru);
+	if (PagePrivate(page)) {
+		ClearPagePrivate(page);
+		list_del(&page->lru);
+	}
 }
 
 /*
@@ -258,6 +204,11 @@ static inline void balloon_page_delete(struct page *page)
 	list_del(&page->lru);
 }
 
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+	return false;
+}
+
 static inline bool balloon_page_movable(struct page *page)
 {
 	return false;
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index b66fd10..01aad3e 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -13,18 +13,9 @@ typedef void free_page_t(struct page *page, unsigned long private);
  * Return values from addresss_space_operations.migratepage():
  * - negative errno on page migration failure;
  * - zero on page migration success;
- *
- * The balloon page migration introduces this special case where a 'distinct'
- * return code is used to flag a successful page migration to unmap_and_move().
- * This approach is necessary because page migration can race against balloon
- * deflation procedure, and for such case we could introduce a nasty page leak
- * if a successfully migrated balloon page gets released concurrently with
- * migration's unmap_and_move() wrap-up steps.
  */
 #define MIGRATEPAGE_SUCCESS		0
-#define MIGRATEPAGE_BALLOON_SUCCESS	1 /* special ret code for balloon page
-					   * sucessful migration case.
-					   */
+
 enum migrate_reason {
 	MR_COMPACTION,
 	MR_MEMORY_FAILURE,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef63711..91001af 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -555,6 +555,25 @@ static inline void __ClearPageBuddy(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
+
+static inline int PageBalloon(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
+}
+
+static inline void __SetPageBalloon(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageBalloon(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageBalloon(page), page);
+	atomic_set(&page->_mapcount, -1);
+}
+
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 6e45a50..52abeeb 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -93,17 +93,12 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 		 * to be released by the balloon driver.
 		 */
 		if (trylock_page(page)) {
+			if (!PagePrivate(page)) {
+				/* raced with isolation */
+				unlock_page(page);
+				continue;
+			}
 			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-			/*
-			 * Raise the page refcount here to prevent any wrong
-			 * attempt to isolate this page, in case of coliding
-			 * with balloon_page_isolate() just after we release
-			 * the page lock.
-			 *
-			 * balloon_page_free() will take care of dropping
-			 * this extra refcount later.
-			 */
-			get_page(page);
 			balloon_page_delete(page);
 			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
@@ -187,7 +182,9 @@ static inline void __isolate_balloon_page(struct page *page)
 {
 	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
 	unsigned long flags;
+
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	ClearPagePrivate(page);
 	list_del(&page->lru);
 	b_dev_info->isolated_pages++;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
@@ -197,7 +194,9 @@ static inline void __putback_balloon_page(struct page *page)
 {
 	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
 	unsigned long flags;
+
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	SetPagePrivate(page);
 	list_add(&page->lru, &b_dev_info->pages);
 	b_dev_info->isolated_pages--;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
@@ -235,12 +234,11 @@ bool balloon_page_isolate(struct page *page)
 		 */
 		if (likely(trylock_page(page))) {
 			/*
-			 * A ballooned page, by default, has just one refcount.
+			 * A ballooned page, by default, has PagePrivate set.
 			 * Prevent concurrent compaction threads from isolating
-			 * an already isolated balloon page by refcount check.
+			 * an already isolated balloon page by clearing it.
 			 */
-			if (__is_movable_balloon_page(page) &&
-			    page_count(page) == 2) {
+			if (balloon_page_movable(page)) {
 				__isolate_balloon_page(page);
 				unlock_page(page);
 				return true;
diff --git a/mm/compaction.c b/mm/compaction.c
index 92075d5..67d938b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -643,7 +643,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!PageLRU(page)) {
 			if (unlikely(balloon_page_movable(page))) {
-				if (locked && balloon_page_isolate(page)) {
+				if (balloon_page_isolate(page)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}
diff --git a/mm/migrate.c b/mm/migrate.c
index c9b5d13..7a31867 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(balloon_page_movable(page))) {
+	if (unlikely(isolated_balloon_page(page))) {
 		/*
 		 * A ballooned page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
@@ -952,17 +952,6 @@ static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
 
 	rc = __unmap_and_move(page, newpage, force, mode);
 
-	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
-		/*
-		 * A ballooned page has been migrated already.
-		 * Now, it's the time to wrap-up counters,
-		 * handle the page back to Buddy and return.
-		 */
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				    page_is_file_cache(page));
-		balloon_page_free(page);
-		return MIGRATEPAGE_SUCCESS;
-	}
 out:
 	if (rc != -EAGAIN) {
 		/*
@@ -985,6 +974,9 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
+	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+		/* drop our reference, page already in the balloon */
+		put_page(newpage);
 	} else
 		putback_lru_page(newpage);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
