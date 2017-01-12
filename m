Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3E2C6B026D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:29:43 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id a29so16467289qtb.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:29:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p39si6319156qtp.30.2017.01.12.07.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:29:42 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v16 11/15] mm/hmm/migrate: add new boolean copy flag to migratepage() callback
Date: Thu, 12 Jan 2017 11:30:38 -0500
Message-Id: <1484238642-10674-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Allow migration without copy in case destination page already have
source page content. This is usefull for HMM migration to device
where we copy page before doing the final migration step.

This feature need carefull audit of filesystem code to make sure
that no one can write to the source page while it is unmapped and
locked. It should be safe for most filesystem but as precaution
return error until support for device migration is added to them.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/staging/lustre/lustre/llite/rw26.c |  8 +++--
 fs/aio.c                                   |  7 +++-
 fs/btrfs/disk-io.c                         | 11 ++++--
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
 13 files changed, 106 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 26f3a37..5a225ca 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -43,6 +43,7 @@
 #include <linux/uaccess.h>
 
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
 #include <linux/mpage.h>
@@ -635,9 +636,12 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
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
index 428484f..30cf06c 100644
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
index 3a57f99..6ccd3c9 100644
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
@@ -1046,9 +1047,13 @@ static int btree_submit_bio_hook(struct inode *inode, struct bio *bio,
 
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
@@ -1062,7 +1067,7 @@ static int btree_migratepage(struct address_space *mapping,
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, copy);
 }
 #endif
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4fb7b10..b52dd44 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -35,6 +35,7 @@
 #include <linux/security.h>
 #include <linux/magic.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/uio.h>
 
 #include <asm/uaccess.h>
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
index 80bcc0b..12d9d8d 100644
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
index 5321183..d7130a5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -14,6 +14,7 @@
 #include <linux/writeback.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -2023,8 +2024,12 @@ int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 
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
@@ -2039,7 +2044,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 	if (!nfs_fscache_release_page(page, GFP_KERNEL))
 		return -EBUSY;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, copy);
 }
 #endif
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index b4fbeef..f625cac 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -53,6 +53,7 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 
 static int read_block(struct inode *inode, void *addr, unsigned int block,
 		      struct ubifs_data_node *dn)
@@ -1455,10 +1456,15 @@ static int ubifs_set_page_dirty(struct page *page)
 
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
index 2f63d44..431f0d3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -398,8 +398,9 @@ struct address_space_operations {
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
@@ -3010,9 +3011,11 @@ extern int generic_file_fsync(struct file *, loff_t, loff_t, int);
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
index ae8d475..37b77ba 100644
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
 extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
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
index 5de87d5..36e2ed9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -622,18 +622,10 @@ static void copy_huge_page(struct page *dst, struct page *src)
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
@@ -687,6 +679,19 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 
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
@@ -700,8 +705,8 @@ EXPORT_SYMBOL(migrate_page_copy);
  * Pages are locked upon entry and exit.
  */
 int migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page,
-		enum migrate_mode mode)
+		 struct page *newpage, struct page *page,
+		 enum migrate_mode mode, bool copy)
 {
 	int rc;
 
@@ -712,7 +717,11 @@ int migrate_page(struct address_space *mapping,
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
@@ -724,13 +733,14 @@ EXPORT_SYMBOL(migrate_page);
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
 
@@ -762,12 +772,15 @@ int buffer_migrate_page(struct address_space *mapping,
 
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
@@ -822,7 +835,8 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page, enum migrate_mode mode)
+				 struct page *newpage, struct page *page,
+				 enum migrate_mode mode)
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
@@ -839,7 +853,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page, mode);
+	return migrate_page(mapping, newpage, page, mode, true);
 }
 
 /*
@@ -867,7 +881,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	if (likely(is_lru)) {
 		if (!mapping)
-			rc = migrate_page(mapping, newpage, page, mode);
+			rc = migrate_page(mapping, newpage, page, mode, true);
 		else if (mapping->a_ops->migratepage)
 			/*
 			 * Most pages have a mapping and most filesystems
@@ -877,7 +891,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 			 * for page migration.
 			 */
 			rc = mapping->a_ops->migratepage(mapping, newpage,
-							page, mode);
+							page, mode, true);
 		else
 			rc = fallback_migrate_page(mapping, newpage,
 							page, mode);
@@ -894,7 +908,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		}
 
 		rc = mapping->a_ops->migratepage(mapping, newpage,
-						page, mode);
+						page, mode, true);
 		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
 			!PageIsolated(page));
 	}
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b0bc023..bf73222 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -52,6 +52,7 @@
 #include <linux/zpool.h>
 #include <linux/mount.h>
 #include <linux/migrate.h>
+#include <linux/memremap.h>
 #include <linux/pagemap.h>
 
 #define ZSPAGE_MAGIC	0x58
@@ -2015,7 +2016,7 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 }
 
 int zs_page_migrate(struct address_space *mapping, struct page *newpage,
-		struct page *page, enum migrate_mode mode)
+		    struct page *page, enum migrate_mode mode, bool copy)
 {
 	struct zs_pool *pool;
 	struct size_class *class;
@@ -2033,6 +2034,15 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
