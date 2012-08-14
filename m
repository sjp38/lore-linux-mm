Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 772036B005D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 04:55:14 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/2] cma: support MIGRATE_DISCARD
Date: Tue, 14 Aug 2012 17:57:07 +0900
Message-Id: <1344934627-8473-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1344934627-8473-1-git-send-email-minchan@kernel.org>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patch introudes MIGRATE_DISCARD mode in migration.
It drop clean cache pages instead of migration so that
migration latency could be reduced. Of course, it could
evict code pages but latency of big contiguous memory
is more important than some background application's slow down
in mobile embedded enviroment.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/migrate_mode.h |   11 +++++++---
 mm/migrate.c                 |   50 +++++++++++++++++++++++++++++++++---------
 mm/page_alloc.c              |    2 +-
 3 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89..04ca19c 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,16 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRTATE_DISCARD will discard clean cache page instead of migration
+ *
+ * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
+ * together as OR flag.
  */
 enum migrate_mode {
-	MIGRATE_ASYNC,
-	MIGRATE_SYNC_LIGHT,
-	MIGRATE_SYNC,
+	MIGRATE_ASYNC = 1 << 0,
+	MIGRATE_SYNC_LIGHT = 1 << 1,
+	MIGRATE_SYNC = 1 << 2,
+	MIGRATE_DISCARD = 1 << 3,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..8119a59 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -225,7 +225,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
+	if (!(mode & MIGRATE_ASYNC)) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -313,7 +313,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if (mode == MIGRATE_ASYNC && head &&
+	if (mode & MIGRATE_ASYNC && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_unfreeze_refs(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -521,7 +521,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked now
 	 */
-	if (mode != MIGRATE_ASYNC)
+	if (!(mode & MIGRATE_ASYNC))
 		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
@@ -603,7 +603,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		if (!(mode & MIGRATE_SYNC))
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -685,9 +685,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	int remap_swapcache = 1;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
+	enum ttu_flags ttu_flags;
+	bool discard_mode = false;
+	bool file = false;
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
+		if (!force || mode & MIGRATE_ASYNC)
 			goto out;
 
 		/*
@@ -733,7 +736,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		if (!(mode & MIGRATE_SYNC)) {
 			rc = -EBUSY;
 			goto uncharge;
 		}
@@ -799,12 +802,39 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto skip_unmap;
 	}
 
+	file = page_is_file_cache(page);
+	ttu_flags = TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS;
+
+	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
+		ttu_flags |= TTU_MIGRATION;
+	else
+		discard_mode = true;
+
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, ttu_flags);
 
 skip_unmap:
-	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
+	if (!page_mapped(page)) {
+		if (!discard_mode)
+			rc = move_to_new_page(newpage, page, remap_swapcache, mode);
+		else {
+			struct address_space *mapping;
+			mapping = page_mapping(page);
+
+			if (page_has_private(page)) {
+				if (!try_to_release_page(page, GFP_KERNEL)) {
+					rc = -EAGAIN;
+					goto uncharge;
+				}
+			}
+
+			if (remove_mapping(mapping, page))
+				rc = 0;
+			else
+				rc = -EAGAIN;
+			goto uncharge;
+		}
+	}
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -907,7 +937,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force || !(mode & MIGRATE_SYNC))
 			goto out;
 		lock_page(hpage);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8540eb..58ea96d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5662,7 +5662,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 
 		ret = migrate_pages(&cc.migratepages,
 				    __alloc_contig_migrate_alloc,
-				    0, false, MIGRATE_SYNC);
+				    0, false, MIGRATE_SYNC|MIGRATE_DISCARD);
 	}
 
 	putback_lru_pages(&cc.migratepages);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
