Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47FC06B000C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j14-v6so13160790pfn.11
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t128-v6si14810365pgc.582.2018.05.23.07.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:10 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/34] fs: factor out a __generic_write_end helper
Date: Wed, 23 May 2018 16:43:25 +0200
Message-Id: <20180523144357.18985-3-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Bits of the buffer.c based write_end implementations that don't know
about buffer_heads and can be reused by other implementations.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/buffer.c   | 67 +++++++++++++++++++++++++++------------------------
 fs/internal.h |  2 ++
 2 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 249b83fafe48..bd964b2ad99a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2076,6 +2076,40 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 }
 EXPORT_SYMBOL(block_write_begin);
 
+int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
+		struct page *page)
+{
+	loff_t old_size = inode->i_size;
+	bool i_size_changed = false;
+
+	/*
+	 * No need to use i_size_read() here, the i_size cannot change under us
+	 * because we hold i_rwsem.
+	 *
+	 * But it's important to update i_size while still holding page lock:
+	 * page writeout could otherwise come in and zero beyond i_size.
+	 */
+	if (pos + copied > inode->i_size) {
+		i_size_write(inode, pos + copied);
+		i_size_changed = true;
+	}
+
+	unlock_page(page);
+	put_page(page);
+
+	if (old_size < pos)
+		pagecache_isize_extended(inode, old_size, pos);
+	/*
+	 * Don't mark the inode dirty under page lock. First, it unnecessarily
+	 * makes the holding time of page lock longer. Second, it forces lock
+	 * ordering of page lock and transaction start for journaling
+	 * filesystems.
+	 */
+	if (i_size_changed)
+		mark_inode_dirty(inode);
+	return copied;
+}
+
 int block_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
@@ -2116,39 +2150,8 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	struct inode *inode = mapping->host;
-	loff_t old_size = inode->i_size;
-	int i_size_changed = 0;
-
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
-
-	/*
-	 * No need to use i_size_read() here, the i_size
-	 * cannot change under us because we hold i_mutex.
-	 *
-	 * But it's important to update i_size while still holding page lock:
-	 * page writeout could otherwise come in and zero beyond i_size.
-	 */
-	if (pos+copied > inode->i_size) {
-		i_size_write(inode, pos+copied);
-		i_size_changed = 1;
-	}
-
-	unlock_page(page);
-	put_page(page);
-
-	if (old_size < pos)
-		pagecache_isize_extended(inode, old_size, pos);
-	/*
-	 * Don't mark the inode dirty under page lock. First, it unnecessarily
-	 * makes the holding time of page lock longer. Second, it forces lock
-	 * ordering of page lock and transaction start for journaling
-	 * filesystems.
-	 */
-	if (i_size_changed)
-		mark_inode_dirty(inode);
-
-	return copied;
+	return __generic_write_end(mapping->host, pos, copied, page);
 }
 EXPORT_SYMBOL(generic_write_end);
 
diff --git a/fs/internal.h b/fs/internal.h
index e08972db0303..b955232d3d49 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -43,6 +43,8 @@ static inline int __sync_blockdev(struct block_device *bdev, int wait)
 extern void guard_bio_eod(int rw, struct bio *bio);
 extern int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 		get_block_t *get_block, struct iomap *iomap);
+int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
+		struct page *page);
 
 /*
  * char_dev.c
-- 
2.17.0
