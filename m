Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2A7EB6B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:09:45 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: change enum migrate_mode with bitwise type
Date: Wed,  5 Sep 2012 17:11:12 +0900
Message-Id: <1346832673-12512-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

This patch changes migrate_mode type to bitwise type because
next patch will add MIGRATE_DISCARD and it could be ORed with other
attributes so it would be better to change it with bitwise type.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Suggested-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/btrfs/disk-io.c           |    2 +-
 fs/hugetlbfs/inode.c         |    2 +-
 fs/nfs/internal.h            |    2 +-
 fs/nfs/write.c               |    2 +-
 include/linux/fs.h           |    4 ++--
 include/linux/migrate.h      |   10 +++++-----
 include/linux/migrate_mode.h |   15 +++++++++------
 mm/migrate.c                 |   38 +++++++++++++++++++-------------------
 8 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 62e0caf..70fbbe1 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -901,7 +901,7 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
 			struct page *newpage, struct page *page,
-			enum migrate_mode mode)
+			migrate_mode_t mode)
 {
 	/*
 	 * we can't safely write a btree page from here,
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 7f11118..2b254f9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -604,7 +604,7 @@ static int hugetlbfs_set_page_dirty(struct page *page)
 
 static int hugetlbfs_migrate_page(struct address_space *mapping,
 				struct page *newpage, struct page *page,
-				enum migrate_mode mode)
+				migrate_mode_t mode)
 {
 	int rc;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..d554438 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -452,7 +452,7 @@ void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *, enum migrate_mode);
+		struct page *, struct page *, migrate_mode_t);
 #else
 #define nfs_migrate_page NULL
 #endif
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3b5537..093889b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1783,7 +1783,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode mode)
+		struct page *page, migrate_mode_t mode)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0b25c5d..a7fbdc6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -637,7 +637,7 @@ struct address_space_operations {
 	 * is false, it must not block.
 	 */
 	int (*migratepage) (struct address_space *,
-			struct page *, struct page *, enum migrate_mode);
+			struct page *, struct page *, migrate_mode_t);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
@@ -2734,7 +2734,7 @@ extern int generic_check_addressable(unsigned, u64);
 #ifdef CONFIG_MIGRATION
 extern int buffer_migrate_page(struct address_space *,
 				struct page *, struct page *,
-				enum migrate_mode);
+				migrate_mode_t);
 #else
 #define buffer_migrate_page NULL
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ce7e667..f7a50f5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -11,13 +11,13 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
-			struct page *, struct page *, enum migrate_mode);
+			struct page *, struct page *, migrate_mode_t);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode mode);
+			migrate_mode_t mode);
 extern int migrate_huge_page(struct page *, new_page_t x,
 			unsigned long private, bool offlining,
-			enum migrate_mode mode);
+			migrate_mode_t mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -35,10 +35,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode mode) { return -ENOSYS; }
+		migrate_mode_t mode) { return -ENOSYS; }
 static inline int migrate_huge_page(struct page *page, new_page_t x,
 		unsigned long private, bool offlining,
-		enum migrate_mode mode) { return -ENOSYS; }
+		migrate_mode_t mode) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89..8848cad 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -1,16 +1,19 @@
 #ifndef MIGRATE_MODE_H_INCLUDED
 #define MIGRATE_MODE_H_INCLUDED
+
+/* MIGRATE_ASYNC means never block */
+#define MIGRATE_ASYNC		((__force migrate_mode_t)0x1)
 /*
- * MIGRATE_ASYNC means never block
  * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
+ */
+#define MIGRATE_SYNC_LIGHT	((__force migrate_mode_t)0x2)
+/*
  * MIGRATE_SYNC will block when migrating pages
  */
-enum migrate_mode {
-	MIGRATE_ASYNC,
-	MIGRATE_SYNC_LIGHT,
-	MIGRATE_SYNC,
-};
+#define MIGRATE_SYNC		((__force migrate_mode_t)0x4)
+
+typedef unsigned __bitwise__ migrate_mode_t;
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..28d464b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -220,12 +220,12 @@ out:
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
 static bool buffer_migrate_lock_buffers(struct buffer_head *head,
-							enum migrate_mode mode)
+							migrate_mode_t mode)
 {
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
+	if (!(mode & MIGRATE_ASYNC)) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -261,7 +261,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 }
 #else
 static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
-							enum migrate_mode mode)
+							migrate_mode_t mode)
 {
 	return true;
 }
@@ -277,7 +277,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		struct buffer_head *head, enum migrate_mode mode)
+		struct buffer_head *head, migrate_mode_t mode)
 {
 	int expected_count;
 	void **pslot;
@@ -313,7 +313,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if (mode == MIGRATE_ASYNC && head &&
+	if ((mode & MIGRATE_ASYNC) && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_unfreeze_refs(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -478,7 +478,7 @@ EXPORT_SYMBOL(fail_migrate_page);
  */
 int migrate_page(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		enum migrate_mode mode)
+		migrate_mode_t mode)
 {
 	int rc;
 
@@ -501,7 +501,7 @@ EXPORT_SYMBOL(migrate_page);
  * exist.
  */
 int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
+		struct page *newpage, struct page *page, migrate_mode_t mode)
 {
 	struct buffer_head *bh, *head;
 	int rc;
@@ -521,7 +521,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked now
 	 */
-	if (mode != MIGRATE_ASYNC)
+	if (!(mode & MIGRATE_ASYNC))
 		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
@@ -599,11 +599,11 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page, enum migrate_mode mode)
+	struct page *newpage, struct page *page, migrate_mode_t mode)
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		if (!(mode & MIGRATE_SYNC))
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -631,7 +631,7 @@ static int fallback_migrate_page(struct address_space *mapping,
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-				int remap_swapcache, enum migrate_mode mode)
+				int remap_swapcache, migrate_mode_t mode)
 {
 	struct address_space *mapping;
 	int rc;
@@ -679,7 +679,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-			int force, bool offlining, enum migrate_mode mode)
+			int force, bool offlining, migrate_mode_t mode)
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
@@ -687,7 +687,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	struct anon_vma *anon_vma = NULL;
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
+		if (!force || (mode & MIGRATE_ASYNC))
 			goto out;
 
 		/*
@@ -733,7 +733,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		if (!(mode & MIGRATE_SYNC)) {
 			rc = -EBUSY;
 			goto uncharge;
 		}
@@ -827,7 +827,7 @@ out:
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			struct page *page, int force, bool offlining,
-			enum migrate_mode mode)
+			migrate_mode_t mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -894,7 +894,7 @@ out:
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
 				int force, bool offlining,
-				enum migrate_mode mode)
+				migrate_mode_t mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -907,7 +907,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force || !(mode & MIGRATE_SYNC))
 			goto out;
 		lock_page(hpage);
 	}
@@ -958,7 +958,7 @@ out:
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		enum migrate_mode mode)
+		migrate_mode_t mode)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -1009,7 +1009,7 @@ out:
 
 int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
 		      unsigned long private, bool offlining,
-		      enum migrate_mode mode)
+		      migrate_mode_t mode)
 {
 	int pass, rc;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
