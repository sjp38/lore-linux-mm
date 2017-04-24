Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0B7A6B02C1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:23:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d132so23850160qkg.23
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:23:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s41si18034193qtg.168.2017.04.24.06.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:23:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 01/20] mm: drop "wait" parameter from write_one_page
Date: Mon, 24 Apr 2017 09:22:40 -0400
Message-Id: <20170424132259.8680-2-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

The callers all set it to 1.

Also, make it clear that this function will not set any sort of AS_*
error, and that the caller must do so if necessary. No existing caller
uses this on normal files, so none of them need it.

Also, add __must_check here since, in general, the callers need to
handle an error here in some fashion.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/exofs/dir.c        |  2 +-
 fs/ext2/dir.c         |  2 +-
 fs/jfs/jfs_metapage.c |  4 ++--
 fs/minix/dir.c        |  2 +-
 fs/sysv/dir.c         |  2 +-
 fs/ufs/dir.c          |  2 +-
 include/linux/mm.h    |  2 +-
 mm/page-writeback.c   | 14 +++++++-------
 8 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 42f9a0a0c4ca..e163ed980c20 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -72,7 +72,7 @@ static int exofs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 	set_page_dirty(page);
 
 	if (IS_DIRSYNC(dir))
-		err = write_one_page(page, 1);
+		err = write_one_page(page);
 	else
 		unlock_page(page);
 
diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index d9650c9508e4..e2709695b177 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -100,7 +100,7 @@ static int ext2_commit_chunk(struct page *page, loff_t pos, unsigned len)
 	}
 
 	if (IS_DIRSYNC(dir)) {
-		err = write_one_page(page, 1);
+		err = write_one_page(page);
 		if (!err)
 			err = sync_inode_metadata(dir, 1);
 	} else {
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index 489aaa1403e5..744fa3c079e6 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -711,7 +711,7 @@ void force_metapage(struct metapage *mp)
 	get_page(page);
 	lock_page(page);
 	set_page_dirty(page);
-	write_one_page(page, 1);
+	write_one_page(page);
 	clear_bit(META_forcewrite, &mp->flag);
 	put_page(page);
 }
@@ -756,7 +756,7 @@ void release_metapage(struct metapage * mp)
 		set_page_dirty(page);
 		if (test_bit(META_sync, &mp->flag)) {
 			clear_bit(META_sync, &mp->flag);
-			write_one_page(page, 1);
+			write_one_page(page);
 			lock_page(page); /* write_one_page unlocks the page */
 		}
 	} else if (mp->lsn)	/* discard_metapage doesn't remove it */
diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index 7edc9b395700..baa9721f1299 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -57,7 +57,7 @@ static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 		mark_inode_dirty(dir);
 	}
 	if (IS_DIRSYNC(dir))
-		err = write_one_page(page, 1);
+		err = write_one_page(page);
 	else
 		unlock_page(page);
 	return err;
diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
index 5bdae85ceef7..f5191cb2c947 100644
--- a/fs/sysv/dir.c
+++ b/fs/sysv/dir.c
@@ -45,7 +45,7 @@ static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 		mark_inode_dirty(dir);
 	}
 	if (IS_DIRSYNC(dir))
-		err = write_one_page(page, 1);
+		err = write_one_page(page);
 	else
 		unlock_page(page);
 	return err;
diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
index de01b8f2aa78..48609f1d9580 100644
--- a/fs/ufs/dir.c
+++ b/fs/ufs/dir.c
@@ -53,7 +53,7 @@ static int ufs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 		mark_inode_dirty(dir);
 	}
 	if (IS_DIRSYNC(dir))
-		err = write_one_page(page, 1);
+		err = write_one_page(page);
 	else
 		unlock_page(page);
 	return err;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00a8fa7e366a..403f78afee20 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2187,7 +2187,7 @@ extern void filemap_map_pages(struct vm_fault *vmf,
 extern int filemap_page_mkwrite(struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
-int write_one_page(struct page *page, int wait);
+int __must_check write_one_page(struct page *page);
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d8ac2a7fb9e7..de0dbf12e2c1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2361,15 +2361,16 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 }
 
 /**
- * write_one_page - write out a single page and optionally wait on I/O
+ * write_one_page - write out a single page and wait on I/O
  * @page: the page to write
- * @wait: if true, wait on writeout
  *
  * The page must be locked by the caller and will be unlocked upon return.
  *
- * write_one_page() returns a negative error code if I/O failed.
+ * write_one_page() returns a negative error code if I/O failed. Note that
+ * the address_space is not marked for error. The caller must do this if
+ * needed.
  */
-int write_one_page(struct page *page, int wait)
+int write_one_page(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 	int ret = 0;
@@ -2380,13 +2381,12 @@ int write_one_page(struct page *page, int wait)
 
 	BUG_ON(!PageLocked(page));
 
-	if (wait)
-		wait_on_page_writeback(page);
+	wait_on_page_writeback(page);
 
 	if (clear_page_dirty_for_io(page)) {
 		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
-		if (ret == 0 && wait) {
+		if (ret == 0) {
 			wait_on_page_writeback(page);
 			if (PageError(page))
 				ret = -EIO;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
