Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8B62E6B0082
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:00 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/34] mm: compaction: Determine if dirty pages can be migrated without blocking within ->migratepage
Date: Mon, 23 Jul 2012 14:38:30 +0100
Message-Id: <1343050727-3045-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit b969c4ab9f182a6e1b2a0848be349f99714947b0 upstream.

Stable note: Not tracked in Bugzilla. A fix aimed at preserving page
	aging information by reducing LRU list churning had the side-effect
	of reducing THP allocation success rates. This was part of a series
	to restore the success rates while preserving the reclaim fix.

Asynchronous compaction is used when allocating transparent hugepages
to avoid blocking for long periods of time. Due to reports of
stalling, there was a debate on disabling synchronous compaction
but this severely impacted allocation success rates. Part of the
reason was because when deciding whether to migrate dirty pages,
the following check is made;

	if (PageDirty(page) && !sync &&
		mapping->a_ops->migratepage != migrate_page)
			rc = -EBUSY;

This skips over all pages using buffer_migrate_page() even though
it is possible to migrate some of these pages without blocking. This
patch updates the ->migratepage callback with a "sync" parameter. It
is the resposibility of the callback to gracefully fail migration of
the page if it would block.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andy Isaacson <adi@hexapodia.org>
Cc: Nai Xia <nai.xia@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/disk-io.c      |    4 +-
 fs/nfs/internal.h       |    2 +-
 fs/nfs/write.c          |    4 +-
 include/linux/fs.h      |    9 ++--
 include/linux/migrate.h |    2 +-
 mm/migrate.c            |  129 +++++++++++++++++++++++++++++++++--------------
 6 files changed, 104 insertions(+), 46 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 1ac8db5d..522cb2a 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -801,7 +801,7 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
-			struct page *newpage, struct page *page)
+			struct page *newpage, struct page *page, bool sync)
 {
 	/*
 	 * we can't safely write a btree page from here,
@@ -816,7 +816,7 @@ static int btree_migratepage(struct address_space *mapping,
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
-	return migrate_page(mapping, newpage, page);
+	return migrate_page(mapping, newpage, page, sync);
 }
 #endif
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2a55347..a74442a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -315,7 +315,7 @@ void nfs_commit_release_pages(struct nfs_write_data *data);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *);
+		struct page *, struct page *, bool);
 #else
 #define nfs_migrate_page NULL
 #endif
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f2f80c0..22a48fd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1662,7 +1662,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page)
+		struct page *page, bool sync)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
@@ -1677,7 +1677,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 
 	nfs_fscache_release_page(page, GFP_KERNEL);
 
-	return migrate_page(mapping, newpage, page);
+	return migrate_page(mapping, newpage, page, sync);
 }
 #endif
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 96b1035..09ddec9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -607,9 +607,12 @@ struct address_space_operations {
 			loff_t offset, unsigned long nr_segs);
 	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
 						void **, unsigned long *);
-	/* migrate the contents of a page to the specified target */
+	/*
+	 * migrate the contents of a page to the specified target. If sync
+	 * is false, it must not block.
+	 */
 	int (*migratepage) (struct address_space *,
-			struct page *, struct page *);
+			struct page *, struct page *, bool);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
@@ -2478,7 +2481,7 @@ extern int generic_check_addressable(unsigned, u64);
 
 #ifdef CONFIG_MIGRATION
 extern int buffer_migrate_page(struct address_space *,
-				struct page *, struct page *);
+				struct page *, struct page *, bool);
 #else
 #define buffer_migrate_page NULL
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e39aeec..14e6d2a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -11,7 +11,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
-			struct page *, struct page *);
+			struct page *, struct page *, bool);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
diff --git a/mm/migrate.c b/mm/migrate.c
index e58ab66..fb8d1ae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -220,6 +220,55 @@ out:
 	pte_unmap_unlock(ptep, ptl);
 }
 
+#ifdef CONFIG_BLOCK
+/* Returns true if all buffers are successfully locked */
+static bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
+{
+	struct buffer_head *bh = head;
+
+	/* Simple case, sync compaction */
+	if (sync) {
+		do {
+			get_bh(bh);
+			lock_buffer(bh);
+			bh = bh->b_this_page;
+
+		} while (bh != head);
+
+		return true;
+	}
+
+	/* async case, we cannot block on lock_buffer so use trylock_buffer */
+	do {
+		get_bh(bh);
+		if (!trylock_buffer(bh)) {
+			/*
+			 * We failed to lock the buffer and cannot stall in
+			 * async migration. Release the taken locks
+			 */
+			struct buffer_head *failed_bh = bh;
+			put_bh(failed_bh);
+			bh = head;
+			while (bh != failed_bh) {
+				unlock_buffer(bh);
+				put_bh(bh);
+				bh = bh->b_this_page;
+			}
+			return false;
+		}
+
+		bh = bh->b_this_page;
+	} while (bh != head);
+	return true;
+}
+#else
+static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
+								bool sync)
+{
+	return true;
+}
+#endif /* CONFIG_BLOCK */
+
 /*
  * Replace the page in the mapping.
  *
@@ -229,7 +278,8 @@ out:
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page,
+		struct buffer_head *head, bool sync)
 {
 	int expected_count;
 	void **pslot;
@@ -259,6 +309,19 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	}
 
 	/*
+	 * In the async migration case of moving a page with buffers, lock the
+	 * buffers using trylock before the mapping is moved. If the mapping
+	 * was moved, we later failed to lock the buffers and could not move
+	 * the mapping back due to an elevated page count, we would have to
+	 * block waiting on other references to be dropped.
+	 */
+	if (!sync && head && !buffer_migrate_lock_buffers(head, sync)) {
+		page_unfreeze_refs(page, expected_count);
+		spin_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
+	/*
 	 * Now we know that no one else is looking at the page.
 	 */
 	get_page(newpage);	/* add cache reference */
@@ -415,13 +478,13 @@ EXPORT_SYMBOL(fail_migrate_page);
  * Pages are locked upon entry and exit.
  */
 int migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page, bool sync)
 {
 	int rc;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, sync);
 
 	if (rc)
 		return rc;
@@ -438,28 +501,28 @@ EXPORT_SYMBOL(migrate_page);
  * exist.
  */
 int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page, bool sync)
 {
 	struct buffer_head *bh, *head;
 	int rc;
 
 	if (!page_has_buffers(page))
-		return migrate_page(mapping, newpage, page);
+		return migrate_page(mapping, newpage, page, sync);
 
 	head = page_buffers(page);
 
-	rc = migrate_page_move_mapping(mapping, newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page, head, sync);
 
 	if (rc)
 		return rc;
 
-	bh = head;
-	do {
-		get_bh(bh);
-		lock_buffer(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
+	/*
+	 * In the async case, migrate_page_move_mapping locked the buffers
+	 * with an IRQ-safe spinlock held. In the sync case, the buffers
+	 * need to be locked no
+	 */
+	if (sync)
+		BUG_ON(!buffer_migrate_lock_buffers(head, sync));
 
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
@@ -536,10 +599,13 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page)
+	struct page *newpage, struct page *page, bool sync)
 {
-	if (PageDirty(page))
+	if (PageDirty(page)) {
+		if (!sync)
+			return -EBUSY;
 		return writeout(mapping, page);
+	}
 
 	/*
 	 * Buffers may be managed in a filesystem specific way.
@@ -549,7 +615,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page);
+	return migrate_page(mapping, newpage, page, sync);
 }
 
 /*
@@ -585,29 +651,18 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	mapping = page_mapping(page);
 	if (!mapping)
-		rc = migrate_page(mapping, newpage, page);
-	else {
+		rc = migrate_page(mapping, newpage, page, sync);
+	else if (mapping->a_ops->migratepage)
 		/*
-		 * Do not writeback pages if !sync and migratepage is
-		 * not pointing to migrate_page() which is nonblocking
-		 * (swapcache/tmpfs uses migratepage = migrate_page).
+		 * Most pages have a mapping and most filesystems provide a
+		 * migratepage callback. Anonymous pages are part of swap
+		 * space which also has its own migratepage callback. This
+		 * is the most common path for page migration.
 		 */
-		if (PageDirty(page) && !sync &&
-		    mapping->a_ops->migratepage != migrate_page)
-			rc = -EBUSY;
-		else if (mapping->a_ops->migratepage)
-			/*
-			 * Most pages have a mapping and most filesystems
-			 * should provide a migration function. Anonymous
-			 * pages are part of swap space which also has its
-			 * own migration function. This is the most common
-			 * path for page migration.
-			 */
-			rc = mapping->a_ops->migratepage(mapping,
-							newpage, page);
-		else
-			rc = fallback_migrate_page(mapping, newpage, page);
-	}
+		rc = mapping->a_ops->migratepage(mapping,
+						newpage, page, sync);
+	else
+		rc = fallback_migrate_page(mapping, newpage, page, sync);
 
 	if (rc) {
 		newpage->mapping = NULL;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
