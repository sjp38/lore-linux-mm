Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 9D8D26B0070
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:15:06 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 13/18] ext4: use ext4_zero_partial_blocks in punch_hole
Date: Tue,  9 Apr 2013 11:14:22 +0200
Message-Id: <1365498867-27782-14-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>

We're doing to get rid of ext4_discard_partial_page_buffers() since it is
duplicating some code and also partially duplicating work of
truncate_pagecache_range(), moreover the old implementation was much
clearer.

Now when the truncate_inode_pages_range() can handle truncating non page
aligned regions we can use this to invalidate and zero out block aligned
region of the punched out range and then use ext4_block_truncate_page()
to zero the unaligned blocks on the start and end of the range. This
will greatly simplify the punch hole code. Moreover after this commit we
can get rid of the ext4_discard_partial_page_buffers() completely.

We also introduce function ext4_prepare_punch_hole() to do come common
operations before we attempt to do the actual punch hole on
indirect or extent file which saves us some code duplication.

This has been tested on ppc64 with 1k block size with fsx and xfstests
without any problems.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/ext4.h  |    2 +
 fs/ext4/inode.c |  110 ++++++++++++++++++++-----------------------------------
 2 files changed, 42 insertions(+), 70 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 3aa5943..2428244 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2109,6 +2109,8 @@ extern int ext4_block_truncate_page(handle_t *handle,
 		struct address_space *mapping, loff_t from);
 extern int ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length);
+extern int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
+			     loff_t lstart, loff_t lend);
 extern int ext4_discard_partial_page_buffers(handle_t *handle,
 		struct address_space *mapping, loff_t from,
 		loff_t length, int flags);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d58e13c..6003fd1 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3675,6 +3675,37 @@ unlock:
 	return err;
 }
 
+int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
+			     loff_t lstart, loff_t lend)
+{
+	struct super_block *sb = inode->i_sb;
+	struct address_space *mapping = inode->i_mapping;
+	unsigned partial = lstart & (sb->s_blocksize - 1);
+	ext4_fsblk_t start = lstart >> sb->s_blocksize_bits;
+	ext4_fsblk_t end = lend >> sb->s_blocksize_bits;
+	int err = 0;
+
+	/* Handle partial zero within the single block */
+	if (start == end) {
+		err = ext4_block_zero_page_range(handle, mapping,
+						 lstart, lend - lstart + 1);
+		return err;
+	}
+	/* Handle partial zero out on the start of the range */
+	if (partial) {
+		err = ext4_block_zero_page_range(handle, mapping,
+						 lstart, sb->s_blocksize);
+		if (err)
+			return err;
+	}
+	/* Handle partial zero out on the end of the range */
+	partial = lend & (sb->s_blocksize - 1);
+	if (partial != sb->s_blocksize - 1)
+		err = ext4_block_zero_page_range(handle, mapping,
+						 lend - partial, partial + 1);
+	return err;
+}
+
 int ext4_can_truncate(struct inode *inode)
 {
 	if (S_ISREG(inode->i_mode))
@@ -3703,7 +3734,6 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
 	struct super_block *sb = inode->i_sb;
 	ext4_lblk_t first_block, stop_block;
 	struct address_space *mapping = inode->i_mapping;
-	loff_t first_page, last_page, page_len;
 	loff_t first_page_offset, last_page_offset;
 	handle_t *handle;
 	unsigned int credits;
@@ -3755,17 +3785,13 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
 		   offset;
 	}
 
-	first_page = (offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	last_page = (offset + length) >> PAGE_CACHE_SHIFT;
-
-	first_page_offset = first_page << PAGE_CACHE_SHIFT;
-	last_page_offset = last_page << PAGE_CACHE_SHIFT;
+	first_page_offset = round_up(offset, sb->s_blocksize);
+	last_page_offset = round_down((offset + length), sb->s_blocksize) - 1;
 
-	/* Now release the pages */
-	if (last_page_offset > first_page_offset) {
+	/* Now release the pages and zero block aligned part of pages*/
+	if (last_page_offset > first_page_offset)
 		truncate_pagecache_range(inode, first_page_offset,
-					 last_page_offset - 1);
-	}
+					 last_page_offset);
 
 	/* Wait all existing dio workers, newcomers will block on i_mutex */
 	ext4_inode_block_unlocked_dio(inode);
@@ -3785,66 +3811,10 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
 		goto out_dio;
 	}
 
-	/*
-	 * Now we need to zero out the non-page-aligned data in the
-	 * pages at the start and tail of the hole, and unmap the
-	 * buffer heads for the block aligned regions of the page that
-	 * were completely zeroed.
-	 */
-	if (first_page > last_page) {
-		/*
-		 * If the file space being truncated is contained
-		 * within a page just zero out and unmap the middle of
-		 * that page
-		 */
-		ret = ext4_discard_partial_page_buffers(handle,
-			mapping, offset, length, 0);
-
-		if (ret)
-			goto out_stop;
-	} else {
-		/*
-		 * zero out and unmap the partial page that contains
-		 * the start of the hole
-		 */
-		page_len = first_page_offset - offset;
-		if (page_len > 0) {
-			ret = ext4_discard_partial_page_buffers(handle, mapping,
-						offset, page_len, 0);
-			if (ret)
-				goto out_stop;
-		}
-
-		/*
-		 * zero out and unmap the partial page that contains
-		 * the end of the hole
-		 */
-		page_len = offset + length - last_page_offset;
-		if (page_len > 0) {
-			ret = ext4_discard_partial_page_buffers(handle, mapping,
-					last_page_offset, page_len, 0);
-			if (ret)
-				goto out_stop;
-		}
-	}
-
-	/*
-	 * If i_size is contained in the last page, we need to
-	 * unmap and zero the partial page after i_size
-	 */
-	if (inode->i_size >> PAGE_CACHE_SHIFT == last_page &&
-	   inode->i_size % PAGE_CACHE_SIZE != 0) {
-		page_len = PAGE_CACHE_SIZE -
-			(inode->i_size & (PAGE_CACHE_SIZE - 1));
-
-		if (page_len > 0) {
-			ret = ext4_discard_partial_page_buffers(handle,
-					mapping, inode->i_size, page_len, 0);
-
-			if (ret)
-				goto out_stop;
-		}
-	}
+	ret = ext4_zero_partial_blocks(handle, inode, offset,
+				       offset + length - 1);
+	if (ret)
+		goto out_stop;
 
 	first_block = (offset + sb->s_blocksize - 1) >>
 		EXT4_BLOCK_SIZE_BITS(sb);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
