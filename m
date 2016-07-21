Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 70F2E82963
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 06:40:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so49610792lfw.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:40:22 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id d65si3611776lfg.399.2016.07.21.03.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 03:40:21 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id f65so17329341wmi.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:40:20 -0700 (PDT)
From: Miklos Szeredi <mszeredi@redhat.com>
Subject: [PATCH] mm: export filemap_check_errors() to modules
Date: Thu, 21 Jul 2016 12:40:18 +0200
Message-Id: <1469097618-3238-1-git-send-email-mszeredi@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Jaegeuk Kim <jaegeuk@kernel.org>

And use it instead of opencoding in btrfs, f2fs and in fuse (coming up).

Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
Cc: Chris Mason <clm@fb.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
---
 fs/btrfs/ctree.h    |  1 -
 fs/btrfs/inode.c    | 15 ---------------
 fs/btrfs/tree-log.c |  4 ++--
 fs/f2fs/node.c      |  7 ++-----
 include/linux/fs.h  |  1 +
 mm/filemap.c        |  3 ++-
 6 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 4274a7bfdaed..425834193259 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -3129,7 +3129,6 @@ int btrfs_prealloc_file_range_trans(struct inode *inode,
 				    struct btrfs_trans_handle *trans, int mode,
 				    u64 start, u64 num_bytes, u64 min_size,
 				    loff_t actual_len, u64 *alloc_hint);
-int btrfs_inode_check_errors(struct inode *inode);
 extern const struct dentry_operations btrfs_dentry_operations;
 #ifdef CONFIG_BTRFS_FS_RUN_SANITY_TESTS
 void btrfs_test_inode_set_ops(struct inode *inode);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 4421954720b8..b22841625333 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -10489,21 +10489,6 @@ out_inode:
 
 }
 
-/* Inspired by filemap_check_errors() */
-int btrfs_inode_check_errors(struct inode *inode)
-{
-	int ret = 0;
-
-	if (test_bit(AS_ENOSPC, &inode->i_mapping->flags) &&
-	    test_and_clear_bit(AS_ENOSPC, &inode->i_mapping->flags))
-		ret = -ENOSPC;
-	if (test_bit(AS_EIO, &inode->i_mapping->flags) &&
-	    test_and_clear_bit(AS_EIO, &inode->i_mapping->flags))
-		ret = -EIO;
-
-	return ret;
-}
-
 static const struct inode_operations btrfs_dir_inode_operations = {
 	.getattr	= btrfs_getattr,
 	.lookup		= btrfs_lookup,
diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
index c05f69a8ec42..3c29b9357392 100644
--- a/fs/btrfs/tree-log.c
+++ b/fs/btrfs/tree-log.c
@@ -3944,7 +3944,7 @@ static int wait_ordered_extents(struct btrfs_trans_handle *trans,
 			 * i_mapping flags, so that the next fsync won't get
 			 * an outdated io error too.
 			 */
-			btrfs_inode_check_errors(inode);
+			filemap_check_errors(inode->i_mapping);
 			*ordered_io_error = true;
 			break;
 		}
@@ -4181,7 +4181,7 @@ static int btrfs_log_changed_extents(struct btrfs_trans_handle *trans,
 	 * without writing to the log tree and the fsync must report the
 	 * file data write error and not commit the current transaction.
 	 */
-	ret = btrfs_inode_check_errors(inode);
+	ret = filemap_check_errors(inode->i_mapping);
 	if (ret)
 		ctx->io_err = ret;
 process:
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 1f21aae80c40..fde0e47fb119 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1521,7 +1521,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 {
 	pgoff_t index = 0, end = ULONG_MAX;
 	struct pagevec pvec;
-	int ret2 = 0, ret = 0;
+	int ret2, ret = 0;
 
 	pagevec_init(&pvec, 0);
 
@@ -1550,10 +1550,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 		cond_resched();
 	}
 
-	if (unlikely(test_and_clear_bit(AS_ENOSPC, &NODE_MAPPING(sbi)->flags)))
-		ret2 = -ENOSPC;
-	if (unlikely(test_and_clear_bit(AS_EIO, &NODE_MAPPING(sbi)->flags)))
-		ret2 = -EIO;
+	ret2 = filemap_check_errors(NODE_MAPPING(sbi));
 	if (!ret)
 		ret = ret2;
 	return ret;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd288148a6b1..6f2536a3a916 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2507,6 +2507,7 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
+extern int filemap_check_errors(struct address_space *mapping);
 
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
diff --git a/mm/filemap.c b/mm/filemap.c
index 20f3b1f33f0e..6d92935dcf71 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -254,7 +254,7 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
-static int filemap_check_errors(struct address_space *mapping)
+int filemap_check_errors(struct address_space *mapping)
 {
 	int ret = 0;
 	/* Check for outstanding write errors */
@@ -266,6 +266,7 @@ static int filemap_check_errors(struct address_space *mapping)
 		ret = -EIO;
 	return ret;
 }
+EXPORT_SYMBOL(filemap_check_errors);
 
 /**
  * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
