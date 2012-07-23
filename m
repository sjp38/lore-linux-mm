Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8204C6B0093
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:03 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 22/34] mm: compaction: Introduce sync-light migration for use by compaction
Date: Mon, 23 Jul 2012 14:38:35 +0100
Message-Id: <1343050727-3045-23-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 upstream.

Stable note: Not tracked in Buzilla. This was part of a series that
	reduced interactivity stalls experienced when THP was enabled.
	These stalls were particularly noticable when copying data
	to a USB stick but the experiences for users varied a lot.

This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
mode that avoids writing back pages to backing storage. Async
compaction maps to MIGRATE_ASYNC while sync compaction maps to
MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
hotplug, MIGRATE_SYNC is used.

This avoids sync compaction stalling for an excessive length of time,
particularly when copying files to a USB stick where there might be
a large number of dirty pages backed by a filesystem that does not
support ->writepages.

[aarcange@redhat.com: This patch is heavily based on Andrea's work]
[akpm@linux-foundation.org: fix fs/nfs/write.c build]
[akpm@linux-foundation.org: fix fs/btrfs/disk-io.c build]
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
 fs/btrfs/disk-io.c      |    3 +-
 fs/hugetlbfs/inode.c    |    3 +-
 fs/nfs/internal.h       |    2 +-
 fs/nfs/write.c          |    2 +-
 include/linux/fs.h      |    6 ++--
 include/linux/migrate.h |   23 +++++++++++---
 mm/compaction.c         |    2 +-
 mm/memory-failure.c     |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/mempolicy.c          |    2 +-
 mm/migrate.c            |   78 ++++++++++++++++++++++++++---------------------
 11 files changed, 75 insertions(+), 50 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 522cb2a..c57d202 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -801,7 +801,8 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
-			struct page *newpage, struct page *page, bool sync)
+			struct page *newpage, struct page *page,
+			enum migrate_mode sync)
 {
 	/*
 	 * we can't safely write a btree page from here,
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8b0c875..6327a06 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -568,7 +568,8 @@ static int hugetlbfs_set_page_dirty(struct page *page)
 }
 
 static int hugetlbfs_migrate_page(struct address_space *mapping,
-				struct page *newpage, struct page *page)
+				struct page *newpage, struct page *page,
+				enum migrate_mode mode)
 {
 	int rc;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a74442a..4f10d81 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -315,7 +315,7 @@ void nfs_commit_release_pages(struct nfs_write_data *data);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *, bool);
+		struct page *, struct page *, enum migrate_mode);
 #else
 #define nfs_migrate_page NULL
 #endif
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 22a48fd..a5fcc65 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1662,7 +1662,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page, bool sync)
+		struct page *page, enum migrate_mode sync)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 09ddec9..212ea7b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -523,6 +523,7 @@ enum positive_aop_returns {
 struct page;
 struct address_space;
 struct writeback_control;
+enum migrate_mode;
 
 struct iov_iter {
 	const struct iovec *iov;
@@ -612,7 +613,7 @@ struct address_space_operations {
 	 * is false, it must not block.
 	 */
 	int (*migratepage) (struct address_space *,
-			struct page *, struct page *, bool);
+			struct page *, struct page *, enum migrate_mode);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
@@ -2481,7 +2482,8 @@ extern int generic_check_addressable(unsigned, u64);
 
 #ifdef CONFIG_MIGRATION
 extern int buffer_migrate_page(struct address_space *,
-				struct page *, struct page *, bool);
+				struct page *, struct page *,
+				enum migrate_mode);
 #else
 #define buffer_migrate_page NULL
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 14e6d2a..775787c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -6,18 +6,31 @@
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
+/*
+ * MIGRATE_ASYNC means never block
+ * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
+ *	on most operations but not ->writepage as the potential stall time
+ *	is too significant
+ * MIGRATE_SYNC will block when migrating pages
+ */
+enum migrate_mode {
+	MIGRATE_ASYNC,
+	MIGRATE_SYNC_LIGHT,
+	MIGRATE_SYNC,
+};
+
 #ifdef CONFIG_MIGRATION
 #define PAGE_MIGRATION 1
 
 extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
-			struct page *, struct page *, bool);
+			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			bool sync);
+			enum migrate_mode sync);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			bool sync);
+			enum migrate_mode sync);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -36,10 +49,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		bool sync) { return -ENOSYS; }
+		enum migrate_mode sync) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		bool sync) { return -ENOSYS; }
+		enum migrate_mode sync) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 76bdd65..0d43bb9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -577,7 +577,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
-				cc->sync);
+				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 740c4f5..6496748 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1464,7 +1464,7 @@ int soft_offline_page(struct page *page, int flags)
 					    page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-								0, true);
+							0, MIGRATE_SYNC);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c46887b..ae5a3f2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -747,7 +747,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		}
 		/* this function returns # of failed pages */
 		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
-								true, true);
+							true, MIGRATE_SYNC);
 		if (ret)
 			putback_lru_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3dac2d1..dd5f874 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -926,7 +926,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest,
-								false, true);
+							false, MIGRATE_SYNC);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index fb8d1ae..132063e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -222,12 +222,13 @@ out:
 
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
-static bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
+static bool buffer_migrate_lock_buffers(struct buffer_head *head,
+							enum migrate_mode mode)
 {
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (sync) {
+	if (mode != MIGRATE_ASYNC) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -263,7 +264,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
 }
 #else
 static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
-								bool sync)
+							enum migrate_mode mode)
 {
 	return true;
 }
@@ -279,7 +280,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		struct buffer_head *head, bool sync)
+		struct buffer_head *head, enum migrate_mode mode)
 {
 	int expected_count;
 	void **pslot;
@@ -315,7 +316,8 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if (!sync && head && !buffer_migrate_lock_buffers(head, sync)) {
+	if (mode == MIGRATE_ASYNC && head &&
+			!buffer_migrate_lock_buffers(head, mode)) {
 		page_unfreeze_refs(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
@@ -478,13 +480,14 @@ EXPORT_SYMBOL(fail_migrate_page);
  * Pages are locked upon entry and exit.
  */
 int migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, bool sync)
+		struct page *newpage, struct page *page,
+		enum migrate_mode mode)
 {
 	int rc;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, sync);
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode);
 
 	if (rc)
 		return rc;
@@ -501,17 +504,17 @@ EXPORT_SYMBOL(migrate_page);
  * exist.
  */
 int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, bool sync)
+		struct page *newpage, struct page *page, enum migrate_mode mode)
 {
 	struct buffer_head *bh, *head;
 	int rc;
 
 	if (!page_has_buffers(page))
-		return migrate_page(mapping, newpage, page, sync);
+		return migrate_page(mapping, newpage, page, mode);
 
 	head = page_buffers(page);
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, head, sync);
+	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode);
 
 	if (rc)
 		return rc;
@@ -521,8 +524,8 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked no
 	 */
-	if (sync)
-		BUG_ON(!buffer_migrate_lock_buffers(head, sync));
+	if (mode != MIGRATE_ASYNC)
+		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
@@ -599,10 +602,11 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page, bool sync)
+	struct page *newpage, struct page *page, enum migrate_mode mode)
 {
 	if (PageDirty(page)) {
-		if (!sync)
+		/* Only writeback pages in full synchronous migration */
+		if (mode != MIGRATE_SYNC)
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -615,7 +619,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page, sync);
+	return migrate_page(mapping, newpage, page, mode);
 }
 
 /*
@@ -630,7 +634,7 @@ static int fallback_migrate_page(struct address_space *mapping,
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-					int remap_swapcache, bool sync)
+				int remap_swapcache, enum migrate_mode mode)
 {
 	struct address_space *mapping;
 	int rc;
@@ -651,7 +655,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	mapping = page_mapping(page);
 	if (!mapping)
-		rc = migrate_page(mapping, newpage, page, sync);
+		rc = migrate_page(mapping, newpage, page, mode);
 	else if (mapping->a_ops->migratepage)
 		/*
 		 * Most pages have a mapping and most filesystems provide a
@@ -660,9 +664,9 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		 * is the most common path for page migration.
 		 */
 		rc = mapping->a_ops->migratepage(mapping,
-						newpage, page, sync);
+						newpage, page, mode);
 	else
-		rc = fallback_migrate_page(mapping, newpage, page, sync);
+		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
 	if (rc) {
 		newpage->mapping = NULL;
@@ -677,7 +681,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, bool offlining, bool sync)
+			int force, bool offlining, enum migrate_mode mode)
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
@@ -686,7 +690,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	struct anon_vma *anon_vma = NULL;
 
 	if (!trylock_page(page)) {
-		if (!force || !sync)
+		if (!force || mode == MIGRATE_ASYNC)
 			goto out;
 
 		/*
@@ -732,10 +736,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 	if (PageWriteback(page)) {
 		/*
-		 * For !sync, there is no point retrying as the retry loop
-		 * is expected to be too short for PageWriteback to be cleared
+		 * Only in the case of a full syncronous migration is it
+		 * necessary to wait for PageWriteback. In the async case,
+		 * the retry loop is too short and in the sync-light case,
+		 * the overhead of stalling is too much
 		 */
-		if (!sync) {
+		if (mode != MIGRATE_SYNC) {
 			rc = -EBUSY;
 			goto uncharge;
 		}
@@ -806,7 +812,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
+		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -829,7 +835,8 @@ out:
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, bool offlining, bool sync)
+			struct page *page, int force, bool offlining,
+			enum migrate_mode mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -847,7 +854,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, offlining, sync);
+	rc = __unmap_and_move(page, newpage, force, offlining, mode);
 out:
 	if (rc != -EAGAIN) {
  		/*
@@ -897,7 +904,8 @@ out:
  */
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
-				int force, bool offlining, bool sync)
+				int force, bool offlining,
+				enum migrate_mode mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -910,7 +918,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force || !sync)
+		if (!force || mode != MIGRATE_SYNC)
 			goto out;
 		lock_page(hpage);
 	}
@@ -921,7 +929,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, 1, sync);
+		rc = move_to_new_page(new_hpage, hpage, 1, mode);
 
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
@@ -964,7 +972,7 @@ out:
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		bool sync)
+		enum migrate_mode mode)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -985,7 +993,7 @@ int migrate_pages(struct list_head *from,
 
 			rc = unmap_and_move(get_new_page, private,
 						page, pass > 2, offlining,
-						sync);
+						mode);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1015,7 +1023,7 @@ out:
 
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		bool sync)
+		enum migrate_mode mode)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -1032,7 +1040,7 @@ int migrate_huge_pages(struct list_head *from,
 
 			rc = unmap_and_move_huge_page(get_new_page,
 					private, page, pass > 2, offlining,
-					sync);
+					mode);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1161,7 +1169,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0, true);
+				(unsigned long)pm, 0, MIGRATE_SYNC);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
