Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id A16E76B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:03:36 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id ty20so8814929lab.37
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 08:03:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si19040366lbx.64.2014.09.23.08.03.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 08:03:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/2] vfs: Fix data corruption when blocksize < pagesize for mmaped data
Date: Tue, 23 Sep 2014 17:03:22 +0200
Message-Id: <1411484603-17756-2-git-send-email-jack@suse.cz>
In-Reply-To: <1411484603-17756-1-git-send-email-jack@suse.cz>
References: <1411484603-17756-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>

->page_mkwrite() is used by filesystems to allocate blocks under a page
which is becoming writeably mmapped in some process' address space. This
allows a filesystem to return a page fault if there is not enough space
available, user exceeds quota or similar problem happens, rather than
silently discarding data later when writepage is called.

However VFS fails to call ->page_mkwrite() in all the cases where
filesystems need it when blocksize < pagesize. For example when
blocksize = 1024, pagesize = 4096 the following is problematic:
  ftruncate(fd, 0);
  pwrite(fd, buf, 1024, 0);
  map = mmap(NULL, 1024, PROT_WRITE, MAP_SHARED, fd, 0);
  map[0] = 'a';       ----> page_mkwrite() for index 0 is called
  ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
  mremap(map, 1024, 10000, 0);
  map[4095] = 'a';    ----> no page_mkwrite() called

At the moment ->page_mkwrite() is called, filesystem can allocate only
one block for the page because i_size == 1024. Otherwise it would create
blocks beyond i_size which is generally undesirable. But later at
->writepage() time, we also need to store data at offset 4095 but we
don't have block allocated for it.

This patch introduces a helper function filesystems can use to have
->page_mkwrite() called at all the necessary moments.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c                 | 57 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/buffer_head.h |  7 ++++++
 2 files changed, 64 insertions(+)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8f05111bbb8b..2e3a1190dd0a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/rmap.h>
 #include <trace/events/block.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
@@ -2010,6 +2011,59 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 	return 0;
 }
 
+#ifdef CONFIG_MMU
+/**
+ * block_create_hole - handle creation of a hole in a file
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ *
+ * Handle creation of a hole in a file either caused by extending truncate or
+ * by write starting after current i_size. We mark the page straddling @from RO
+ * so that page_mkwrite() is called on the nearest write access to the page.
+ * This way filesystem can be sure that page_mkwrite() is called on the page
+ * before user writes to the page via mmap after the i_size has been changed.
+ *
+ * This function must be called after i_size is updated so that page_mkwrite()
+ * happenning immediately after we unlock the page initializes it correctly.
+ * Also the function must be called while we still hold i_mutex - this not only
+ * makes sure i_size is stable but also that userspace cannot observe new
+ * i_size value before we are prepared to store mmap writes at new inode size.
+ */
+void block_create_hole(struct inode *inode, loff_t from, loff_t to)
+{
+	int bsize = 1 << inode->i_blkbits;
+	loff_t rounded_from;
+	struct page *page;
+	pgoff_t index;
+
+	WARN_ON(!mutex_is_locked(&inode->i_mutex));
+	WARN_ON(to > inode->i_size);
+
+	if (from >= to || bsize == PAGE_CACHE_SIZE)
+		return;
+	/* Currently last page will not have any hole block created? */
+	rounded_from = ALIGN(from, bsize);
+	if (to <= rounded_from || !(rounded_from & (PAGE_CACHE_SIZE - 1)))
+		return;
+
+	index = from >> PAGE_CACHE_SHIFT;
+	page = find_lock_page(inode->i_mapping, index);
+	/* Page not cached? Nothing to do */
+	if (!page)
+		return;
+	/*
+	 * See clear_page_dirty_for_io() for details why set_page_dirty()
+	 * is needed.
+	 */
+	if (page_mkclean(page))
+		set_page_dirty(page);
+	unlock_page(page);
+	page_cache_release(page);
+}
+EXPORT_SYMBOL(block_create_hole);
+#endif
+
 /*
  * block_write_begin takes care of the basic task of block allocation and
  * bringing partial write blocks uptodate first.
@@ -2080,6 +2134,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	struct inode *inode = mapping->host;
+	loff_t old_size = inode->i_size;
 	int i_size_changed = 0;
 
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
@@ -2099,6 +2154,8 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 	unlock_page(page);
 	page_cache_release(page);
 
+	if (old_size < pos)
+		block_create_hole(inode, old_size, pos);
 	/*
 	 * Don't mark the inode dirty under page lock. First, it unnecessarily
 	 * makes the holding time of page lock longer. Second, it forces lock
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 324329ceea1e..b4f79eeca7c5 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -244,6 +244,13 @@ static inline int block_page_mkwrite_return(int err)
 	/* -ENOSPC, -EDQUOT, -EIO ... */
 	return VM_FAULT_SIGBUS;
 }
+#ifdef CONFIG_MMU
+void block_create_hole(struct inode *inode, loff_t from, loff_t to);
+#else
+static inline void block_create_hole(struct inode *inode, loff_t from, loff_t to)
+{
+}
+#endif
 sector_t generic_block_bmap(struct address_space *, sector_t, get_block_t *);
 int block_truncate_page(struct address_space *, loff_t, get_block_t *);
 int nobh_write_begin(struct address_space *, loff_t, unsigned, unsigned,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
