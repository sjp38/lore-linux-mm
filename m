Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92E326B038E
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:03:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j30so38960686qta.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:03:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b18si4080010qka.287.2017.03.16.08.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:57 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 06/16] mm/migrate: add new boolean copy flag to migratepage() callback
Date: Thu, 16 Mar 2017 12:05:25 -0400
Message-Id: <1489680335-6594-7-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Allow migration without copy in case destination page already have
source page content. This is usefull for new dma capable migration
where use device dma engine to copy pages.

This feature need carefull audit of filesystem code to make sure
that no one can write to the source page while it is unmapped and
locked. It should be safe for most filesystem but as precaution
return error until support for device migration is added to them.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/staging/lustre/lustre/llite/rw26.c |  8 +++--
 fs/aio.c                                   |  7 +++-
 fs/btrfs/disk-io.c                         | 11 ++++--
 fs/f2fs/data.c                             |  8 ++++-
 fs/f2fs/f2fs.h                             |  2 +-
 fs/hugetlbfs/inode.c                       |  9 +++--
 fs/nfs/internal.h                          |  5 +--
 fs/nfs/write.c                             |  9 +++--
 fs/ubifs/file.c                            |  8 ++++-
 include/linux/balloon_compaction.h         |  3 +-
 include/linux/fs.h                         | 13 ++++---
 include/linux/migrate.h                    |  7 ++--
 mm/balloon_compaction.c                    |  2 +-
 mm/migrate.c                               | 56 +++++++++++++++++++-----------
 mm/zsmalloc.c                              | 12 ++++++-
 15 files changed, 114 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index d89e795..29a59bf 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -43,6 +43,7 @@
 #include <linux/uaccess.h>
 
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
 #include <linux/mpage.h>
@@ -642,9 +643,12 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 #ifdef CONFIG_MIGRATION
 static int ll_migratepage(struct address_space *mapping,
 			  struct page *newpage, struct page *page,
-			  enum migrate_mode mode
-		)
+			  enum migrate_mode mode, bool copy)
 {
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	/* Always fail page migration until we have a proper implementation */
 	return -EIO;
 }
diff --git a/fs/aio.c b/fs/aio.c
index f52d925..fa6bb92 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -37,6 +37,7 @@
 #include <linux/blkdev.h>
 #include <linux/compat.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/ramfs.h>
 #include <linux/percpu-refcount.h>
 #include <linux/mount.h>
@@ -366,13 +367,17 @@ static const struct file_operations aio_ring_fops = {
 
 #if IS_ENABLED(CONFIG_MIGRATION)
 static int aio_migratepage(struct address_space *mapping, struct page *new,
-			struct page *old, enum migrate_mode mode)
+			   struct page *old, enum migrate_mode mode, bool copy)
 {
 	struct kioctx *ctx;
 	unsigned long flags;
 	pgoff_t idx;
 	int rc;
 
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(new))
+		return -EINVAL;
+
 	rc = 0;
 
 	/* mapping->private_lock here protects against the kioctx teardown.  */
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 08b74da..a2b75d6 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -27,6 +27,7 @@
 #include <linux/kthread.h>
 #include <linux/slab.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/ratelimit.h>
 #include <linux/uuid.h>
 #include <linux/semaphore.h>
@@ -1061,9 +1062,13 @@ static int btree_submit_bio_hook(struct inode *inode, struct bio *bio,
 
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
-			struct page *newpage, struct page *page,
-			enum migrate_mode mode)
+			     struct page *newpage, struct page *page,
+			     enum migrate_mode mode, bool copy)
 {
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	/*
 	 * we can't safely write a btree page from here,
 	 * we haven't done the locking hook
@@ -1077,7 +1082,7 @@ static int btree_migratepage(struct address_space *mapping,
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, copy);
 }
 #endif
 
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 1602b4b..14208a5 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -23,6 +23,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/sched/signal.h>
+#include <linux/memremap.h>
 
 #include "f2fs.h"
 #include "node.h"
@@ -2049,7 +2050,8 @@ static sector_t f2fs_bmap(struct address_space *mapping, sector_t block)
 #include <linux/migrate.h>
 
 int f2fs_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
+		struct page *newpage, struct page *page,
+		enum migrate_mode mode, bool copy)
 {
 	int rc, extra_count;
 	struct f2fs_inode_info *fi = F2FS_I(mapping->host);
@@ -2057,6 +2059,10 @@ int f2fs_migrate_page(struct address_space *mapping,
 
 	BUG_ON(PageWriteback(page));
 
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	/* migrating an atomic written page is safe with the inmem_lock hold */
 	if (atomic_written && !mutex_trylock(&fi->inmem_lock))
 		return -EAGAIN;
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index e849f83..ffa5333 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -2299,7 +2299,7 @@ void f2fs_invalidate_page(struct page *page, unsigned int offset,
 int f2fs_release_page(struct page *page, gfp_t wait);
 #ifdef CONFIG_MIGRATION
 int f2fs_migrate_page(struct address_space *mapping, struct page *newpage,
-			struct page *page, enum migrate_mode mode);
+			struct page *page, enum migrate_mode mode, bool copy);
 #endif
 
 /*
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8f96461..13f74d6 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -35,6 +35,7 @@
 #include <linux/security.h>
 #include <linux/magic.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/uio.h>
 
 #include <linux/uaccess.h>
@@ -842,11 +843,15 @@ static int hugetlbfs_set_page_dirty(struct page *page)
 }
 
 static int hugetlbfs_migrate_page(struct address_space *mapping,
-				struct page *newpage, struct page *page,
-				enum migrate_mode mode)
+				  struct page *newpage, struct page *page,
+				  enum migrate_mode mode, bool copy)
 {
 	int rc;
 
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 09ca509..2e23275 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -535,8 +535,9 @@ void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
 #endif
 
 #ifdef CONFIG_MIGRATION
-extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *, enum migrate_mode);
+extern int nfs_migrate_page(struct address_space *mapping,
+			    struct page *newpage, struct page *page,
+			    enum migrate_mode, bool copy);
 #endif
 
 static inline int
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e75b056..1bc4354 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -14,6 +14,7 @@
 #include <linux/writeback.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -2020,8 +2021,12 @@ int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode mode)
+		     struct page *page, enum migrate_mode mode, bool copy)
 {
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
 	 * an in-progress read or write request. Don't try to migrate it.
@@ -2036,7 +2041,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 	if (!nfs_fscache_release_page(page, GFP_KERNEL))
 		return -EBUSY;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, copy);
 }
 #endif
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index d9ae86f..298fbae 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -53,6 +53,7 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 
 static int read_block(struct inode *inode, void *addr, unsigned int block,
 		      struct ubifs_data_node *dn)
@@ -1469,10 +1470,15 @@ static int ubifs_set_page_dirty(struct page *page)
 
 #ifdef CONFIG_MIGRATION
 static int ubifs_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
+			      struct page *newpage, struct page *page,
+			      enum migrate_mode mode, bool copy)
 {
 	int rc;
 
+	/* Can only migrate addressable memory for now */
+	if (!is_addressable_page(newpage))
+		return -EINVAL;
+
 	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 79542b2..27cf3e3 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -85,7 +85,8 @@ extern bool balloon_page_isolate(struct page *page,
 extern void balloon_page_putback(struct page *page);
 extern int balloon_page_migrate(struct address_space *mapping,
 				struct page *newpage,
-				struct page *page, enum migrate_mode mode);
+				struct page *page, enum migrate_mode mode,
+				bool copy);
 
 /*
  * balloon_page_insert - insert a page into the balloon's page list and make
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7251f7b..706a9a9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -346,8 +346,9 @@ struct address_space_operations {
 	 * migrate the contents of a page to the specified target. If
 	 * migrate_mode is MIGRATE_ASYNC, it must not block.
 	 */
-	int (*migratepage) (struct address_space *,
-			struct page *, struct page *, enum migrate_mode);
+	int (*migratepage)(struct address_space *mapping,
+			   struct page *newpage, struct page *page,
+			   enum migrate_mode, bool copy);
 	bool (*isolate_page)(struct page *, isolate_mode_t);
 	void (*putback_page)(struct page *);
 	int (*launder_page) (struct page *);
@@ -3013,9 +3014,11 @@ extern int generic_file_fsync(struct file *, loff_t, loff_t, int);
 extern int generic_check_addressable(unsigned, u64);
 
 #ifdef CONFIG_MIGRATION
-extern int buffer_migrate_page(struct address_space *,
-				struct page *, struct page *,
-				enum migrate_mode);
+extern int buffer_migrate_page(struct address_space *mapping,
+			       struct page *newpage,
+			       struct page *page,
+			       enum migrate_mode,
+			       bool copy);
 #else
 #define buffer_migrate_page NULL
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index fa76b51..0a66ddd 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -33,8 +33,11 @@ extern char *migrate_reason_names[MR_TYPES];
 #ifdef CONFIG_MIGRATION
 
 extern void putback_movable_pages(struct list_head *l);
-extern int migrate_page(struct address_space *,
-			struct page *, struct page *, enum migrate_mode);
+extern int migrate_page(struct address_space *mapping,
+			struct page *newpage,
+			struct page *page,
+			enum migrate_mode,
+			bool copy);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
 extern int isolate_movable_page(struct page *page, isolate_mode_t mode);
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index da91df5..ed5cacb 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -135,7 +135,7 @@ void balloon_page_putback(struct page *page)
 /* move_to_new_page() counterpart for a ballooned page */
 int balloon_page_migrate(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		enum migrate_mode mode)
+		enum migrate_mode mode, bool copy)
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 9a0897a..cb911ce 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -596,18 +596,10 @@ static void copy_huge_page(struct page *dst, struct page *src)
 	}
 }
 
-/*
- * Copy the page to its new location
- */
-void migrate_page_copy(struct page *newpage, struct page *page)
+static void migrate_page_states(struct page *newpage, struct page *page)
 {
 	int cpupid;
 
-	if (PageHuge(page) || PageTransHuge(page))
-		copy_huge_page(newpage, page);
-	else
-		copy_highpage(newpage, page);
-
 	if (PageError(page))
 		SetPageError(newpage);
 	if (PageReferenced(page))
@@ -661,6 +653,19 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 
 	mem_cgroup_migrate(page, newpage);
 }
+
+/*
+ * Copy the page to its new location
+ */
+void migrate_page_copy(struct page *newpage, struct page *page)
+{
+	if (PageHuge(page) || PageTransHuge(page))
+		copy_huge_page(newpage, page);
+	else
+		copy_highpage(newpage, page);
+
+	migrate_page_states(newpage, page);
+}
 EXPORT_SYMBOL(migrate_page_copy);
 
 /************************************************************
@@ -674,8 +679,8 @@ EXPORT_SYMBOL(migrate_page_copy);
  * Pages are locked upon entry and exit.
  */
 int migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page,
-		enum migrate_mode mode)
+		 struct page *newpage, struct page *page,
+		 enum migrate_mode mode, bool copy)
 {
 	int rc;
 
@@ -686,7 +691,11 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	migrate_page_copy(newpage, page);
+	if (copy)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
+
 	return MIGRATEPAGE_SUCCESS;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -698,13 +707,14 @@ EXPORT_SYMBOL(migrate_page);
  * exist.
  */
 int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
+			struct page *newpage, struct page *page,
+			enum migrate_mode mode, bool copy)
 {
 	struct buffer_head *bh, *head;
 	int rc;
 
 	if (!page_has_buffers(page))
-		return migrate_page(mapping, newpage, page, mode);
+		return migrate_page(mapping, newpage, page, mode, copy);
 
 	head = page_buffers(page);
 
@@ -736,12 +746,15 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	migrate_page_copy(newpage, page);
+	if (copy)
+		migrate_page_copy(newpage, page);
+	else
+		migrate_page_states(newpage, page);
 
 	bh = head;
 	do {
 		unlock_buffer(bh);
- 		put_bh(bh);
+		put_bh(bh);
 		bh = bh->b_this_page;
 
 	} while (bh != head);
@@ -796,7 +809,8 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page, enum migrate_mode mode)
+				 struct page *newpage, struct page *page,
+				 enum migrate_mode mode)
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
@@ -813,7 +827,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, true);
 }
 
 /*
@@ -841,7 +855,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	if (likely(is_lru)) {
 		if (!mapping)
-			rc = migrate_page(mapping, newpage, page, mode);
+			rc = migrate_page(mapping, newpage, page, mode, true);
 		else if (mapping->a_ops->migratepage)
 			/*
 			 * Most pages have a mapping and most filesystems
@@ -851,7 +865,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 			 * for page migration.
 			 */
 			rc = mapping->a_ops->migratepage(mapping, newpage,
-							page, mode);
+							page, mode, true);
 		else
 			rc = fallback_migrate_page(mapping, newpage,
 							page, mode);
@@ -868,7 +882,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		}
 
 		rc = mapping->a_ops->migratepage(mapping, newpage,
-						page, mode);
+						page, mode, true);
 		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
 			!PageIsolated(page));
 	}
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b7ee9c3..334ff64 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -52,6 +52,7 @@
 #include <linux/zpool.h>
 #include <linux/mount.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/pagemap.h>
 
 #define ZSPAGE_MAGIC	0x58
@@ -1968,7 +1969,7 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 }
 
 int zs_page_migrate(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode mode)
+		    struct page *page, enum migrate_mode mode, bool copy)
 {
 	struct zs_pool *pool;
 	struct size_class *class;
@@ -1986,6 +1987,15 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
+	/*
+	 * Offloading copy operation for zspage require special considerations
+	 * due to locking so for now we only support regular migration. I do
+	 * not expect we will ever want to support offloading copy. See hmm.h
+	 * for more informations on hmm_vma_migrate() and offload copy.
+	 */
+	if (!copy || !is_addressable_page(newpage))
+		return -EINVAL;
+
 	zspage = get_zspage(page);
 
 	/* Concurrent compactor cannot migrate any subpage in zspage */
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
