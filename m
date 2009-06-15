Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D68666B0085
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:20 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/11] ext3: Allocate space for mmaped file on page fault
Date: Mon, 15 Jun 2009 19:59:52 +0200
Message-Id: <1245088797-29533-6-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

So far we've allocated space at ->writepage() time. This has the disadvantage
that when we hit ENOSPC or other error, we cannot do much - either throw
away the data or keep the page indefinitely (and loose the data on reboot).
So allocate space already when a page is faulted in.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext3/file.c          |   19 ++++-
 fs/ext3/inode.c         |  220 +++++++++++++++++++++--------------------------
 include/linux/ext3_fs.h |    1 +
 3 files changed, 116 insertions(+), 124 deletions(-)

diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index 5b49704..a7dce9d 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -110,6 +110,23 @@ force_commit:
 	return ret;
 }
 
+static struct vm_operations_struct ext3_file_vm_ops = {
+	.fault		= filemap_fault,
+	.page_mkwrite	= ext3_page_mkwrite,
+};
+
+static int ext3_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (!mapping->a_ops->readpage)
+		return -ENOEXEC;
+	file_accessed(file);
+	vma->vm_ops = &ext3_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	return 0;
+}
+
 const struct file_operations ext3_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
@@ -120,7 +137,7 @@ const struct file_operations ext3_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext3_compat_ioctl,
 #endif
-	.mmap		= generic_file_mmap,
+	.mmap		= ext3_file_mmap,
 	.open		= generic_file_open,
 	.release	= ext3_release_file,
 	.fsync		= ext3_sync_file,
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 2d4b2ca..ec112b4 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -1156,10 +1156,13 @@ static int ext3_write_begin(struct file *file, struct address_space *mapping,
 	from = pos & (PAGE_CACHE_SIZE - 1);
 	to = from + len;
 
+	block_lock_hole_extend(inode, pos);
 retry:
 	page = grab_cache_page_write_begin(mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	*pagep = page;
 
 	handle = ext3_journal_start(inode, needed_blocks);
@@ -1199,6 +1202,8 @@ write_begin_failed:
 	if (ret == -ENOSPC && ext3_should_retry_alloc(inode->i_sb, &retries))
 		goto retry;
 out:
+	if (ret)
+		block_unlock_hole_extend(inode);
 	return ret;
 }
 
@@ -1290,6 +1295,7 @@ static int ext3_ordered_write_end(struct file *file,
 
 	if (pos + len > inode->i_size)
 		vmtruncate(inode, inode->i_size);
+	block_unlock_hole_extend(inode);
 	return ret ? ret : copied;
 }
 
@@ -1316,6 +1322,7 @@ static int ext3_writeback_write_end(struct file *file,
 
 	if (pos + len > inode->i_size)
 		vmtruncate(inode, inode->i_size);
+	block_unlock_hole_extend(inode);
 	return ret ? ret : copied;
 }
 
@@ -1369,6 +1376,7 @@ static int ext3_journalled_write_end(struct file *file,
 
 	if (pos + len > inode->i_size)
 		vmtruncate(inode, inode->i_size);
+	block_unlock_hole_extend(inode);
 	return ret ? ret : copied;
 }
 
@@ -1424,18 +1432,6 @@ static sector_t ext3_bmap(struct address_space *mapping, sector_t block)
 	return generic_block_bmap(mapping,block,ext3_get_block);
 }
 
-static int bget_one(handle_t *handle, struct buffer_head *bh)
-{
-	get_bh(bh);
-	return 0;
-}
-
-static int bput_one(handle_t *handle, struct buffer_head *bh)
-{
-	put_bh(bh);
-	return 0;
-}
-
 static int buffer_unmapped(handle_t *handle, struct buffer_head *bh)
 {
 	return !buffer_mapped(bh);
@@ -1487,125 +1483,25 @@ static int buffer_unmapped(handle_t *handle, struct buffer_head *bh)
  *   We'll probably need that anyway for journalling writepage() output.
  *
  * We don't honour synchronous mounts for writepage().  That would be
- * disastrous.  Any write() or metadata operation will sync the fs for
+ * disastrous. Any write() or metadata operation will sync the fs for
  * us.
  *
- * AKPM2: if all the page's buffers are mapped to disk and !data=journal,
- * we don't need to open a transaction here.
+ * Note, even though we try, we *may* end up allocating blocks here because
+ * page_mkwrite() has not allocated blocks yet but dirty buffers were created
+ * under the whole page, not just the part inside old i_size. We could just
+ * ignore writing such buffers but it would be harder to avoid it then just
+ * do it...
  */
-static int ext3_ordered_writepage(struct page *page,
-				struct writeback_control *wbc)
-{
-	struct inode *inode = page->mapping->host;
-	struct buffer_head *page_bufs;
-	handle_t *handle = NULL;
-	int ret = 0;
-	int err;
-
-	J_ASSERT(PageLocked(page));
-
-	/*
-	 * We give up here if we're reentered, because it might be for a
-	 * different filesystem.
-	 */
-	if (ext3_journal_current_handle())
-		goto out_fail;
-
-	if (!page_has_buffers(page)) {
-		create_empty_buffers(page, inode->i_sb->s_blocksize,
-				(1 << BH_Dirty)|(1 << BH_Uptodate));
-		page_bufs = page_buffers(page);
-	} else {
-		page_bufs = page_buffers(page);
-		if (!walk_page_buffers(NULL, page_bufs, 0, PAGE_CACHE_SIZE,
-				       NULL, buffer_unmapped)) {
-			/* Provide NULL get_block() to catch bugs if buffers
-			 * weren't really mapped */
-			return block_write_full_page(page, NULL, wbc);
-		}
-	}
-	handle = ext3_journal_start(inode, ext3_writepage_trans_blocks(inode));
-
-	if (IS_ERR(handle)) {
-		ret = PTR_ERR(handle);
-		goto out_fail;
-	}
-
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bget_one);
-
-	ret = block_write_full_page(page, ext3_get_block, wbc);
-
-	/*
-	 * The page can become unlocked at any point now, and
-	 * truncate can then come in and change things.  So we
-	 * can't touch *page from now on.  But *page_bufs is
-	 * safe due to elevated refcount.
-	 */
-
-	/*
-	 * And attach them to the current transaction.  But only if
-	 * block_write_full_page() succeeded.  Otherwise they are unmapped,
-	 * and generally junk.
-	 */
-	if (ret == 0) {
-		err = walk_page_buffers(handle, page_bufs, 0, PAGE_CACHE_SIZE,
-					NULL, journal_dirty_data_fn);
-		if (!ret)
-			ret = err;
-	}
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bput_one);
-	err = ext3_journal_stop(handle);
-	if (!ret)
-		ret = err;
-	return ret;
-
-out_fail:
-	redirty_page_for_writepage(wbc, page);
-	unlock_page(page);
-	return ret;
-}
-
-static int ext3_writeback_writepage(struct page *page,
+static int ext3_common_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
-	handle_t *handle = NULL;
 	int ret = 0;
-	int err;
-
-	if (ext3_journal_current_handle())
-		goto out_fail;
-
-	if (page_has_buffers(page)) {
-		if (!walk_page_buffers(NULL, page_buffers(page), 0,
-				      PAGE_CACHE_SIZE, NULL, buffer_unmapped)) {
-			/* Provide NULL get_block() to catch bugs if buffers
-			 * weren't really mapped */
-			return block_write_full_page(page, NULL, wbc);
-		}
-	}
-
-	handle = ext3_journal_start(inode, ext3_writepage_trans_blocks(inode));
-	if (IS_ERR(handle)) {
-		ret = PTR_ERR(handle);
-		goto out_fail;
-	}
 
 	if (test_opt(inode->i_sb, NOBH) && ext3_should_writeback_data(inode))
 		ret = nobh_writepage(page, ext3_get_block, wbc);
 	else
 		ret = block_write_full_page(page, ext3_get_block, wbc);
-
-	err = ext3_journal_stop(handle);
-	if (!ret)
-		ret = err;
-	return ret;
-
-out_fail:
-	redirty_page_for_writepage(wbc, page);
-	unlock_page(page);
 	return ret;
 }
 
@@ -1752,9 +1648,11 @@ static ssize_t ext3_direct_IO(int rw, struct kiocb *iocb,
 	if (orphan) {
 		int err;
 
+		block_lock_hole_extend(inode, offset);
 		/* Credits for sb + inode write */
 		handle = ext3_journal_start(inode, 2);
 		if (IS_ERR(handle)) {
+			block_unlock_hole_extend(inode);
 			/* This is really bad luck. We've written the data
 			 * but cannot extend i_size. Bail out and pretend
 			 * the write failed... */
@@ -1781,11 +1679,84 @@ static ssize_t ext3_direct_IO(int rw, struct kiocb *iocb,
 		err = ext3_journal_stop(handle);
 		if (ret == 0)
 			ret = err;
+		block_unlock_hole_extend(inode);
 	}
 out:
 	return ret;
 }
 
+int ext3_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct page *page = vmf->page;
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = file->f_path.dentry->d_inode;
+	int ret = VM_FAULT_NOPAGE;
+	loff_t size;
+	int len;
+	void *fsdata;
+
+	block_wait_on_hole_extend(inode, page_offset(page));
+	/*
+	 * Get i_alloc_sem to stop truncates messing with the inode. We cannot
+	 * get i_mutex because we are already holding mmap_sem.
+	 */
+	down_read(&inode->i_alloc_sem);
+	size = i_size_read(inode);
+	if ((page->mapping != inode->i_mapping) ||
+	    (page_offset(page) > size)) {
+		/* page got truncated out from underneath us */
+		goto out_unlock;
+	}
+
+	/* page is wholly or partially inside EOF */
+	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
+		len = size & ~PAGE_CACHE_MASK;
+	else
+		len = PAGE_CACHE_SIZE;
+
+	/*
+	 * Check for the common case that everything is already mapped. We
+	 * have to get the page lock so that buffers cannot be released
+	 * under us.
+	 */
+	lock_page(page);
+	if (page_has_buffers(page)) {
+		if (!walk_page_buffers(NULL, page_buffers(page), 0, len, NULL,
+				       buffer_unmapped)) {
+			unlock_page(page);
+			ret = 0;
+			goto out_unlock;
+		}
+	}
+	unlock_page(page);
+
+	/*
+	 * OK, we may need to fill the hole... Do write_begin write_end to do
+	 * block allocation/reservation. We are not holding inode.i_mutex
+	 * here. That allows parallel write_begin, write_end call. lock_page
+	 * prevent this from happening on the same page though.
+	 */
+	ret = mapping->a_ops->write_begin(file, mapping, page_offset(page),
+			len, AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+	if (ret < 0)
+		goto out_unlock;
+	ret = mapping->a_ops->write_end(file, mapping, page_offset(page),
+			len, len, page, fsdata);
+	if (ret < 0)
+		goto out_unlock;
+	ret = 0;
+out_unlock:
+	if (unlikely(ret)) {
+		if (ret == -ENOMEM)
+			ret = VM_FAULT_OOM;
+		else /* -ENOSPC, -EIO, etc */
+			ret = VM_FAULT_SIGBUS;
+	}
+	up_read(&inode->i_alloc_sem);
+	return ret;
+}
+
 /*
  * Pages can be marked dirty completely asynchronously from ext3's journalling
  * activity.  By filemap_sync_pte(), try_to_unmap_one(), etc.  We cannot do
@@ -1808,10 +1779,11 @@ static int ext3_journalled_set_page_dirty(struct page *page)
 static const struct address_space_operations ext3_ordered_aops = {
 	.readpage		= ext3_readpage,
 	.readpages		= ext3_readpages,
-	.writepage		= ext3_ordered_writepage,
+	.writepage		= ext3_common_writepage,
 	.sync_page		= block_sync_page,
 	.write_begin		= ext3_write_begin,
 	.write_end		= ext3_ordered_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext3_bmap,
 	.invalidatepage		= ext3_invalidatepage,
 	.releasepage		= ext3_releasepage,
@@ -1823,10 +1795,11 @@ static const struct address_space_operations ext3_ordered_aops = {
 static const struct address_space_operations ext3_writeback_aops = {
 	.readpage		= ext3_readpage,
 	.readpages		= ext3_readpages,
-	.writepage		= ext3_writeback_writepage,
+	.writepage		= ext3_common_writepage,
 	.sync_page		= block_sync_page,
 	.write_begin		= ext3_write_begin,
 	.write_end		= ext3_writeback_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext3_bmap,
 	.invalidatepage		= ext3_invalidatepage,
 	.releasepage		= ext3_releasepage,
@@ -1842,6 +1815,7 @@ static const struct address_space_operations ext3_journalled_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext3_write_begin,
 	.write_end		= ext3_journalled_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.set_page_dirty		= ext3_journalled_set_page_dirty,
 	.bmap			= ext3_bmap,
 	.invalidatepage		= ext3_invalidatepage,
diff --git a/include/linux/ext3_fs.h b/include/linux/ext3_fs.h
index 7499b36..5051874 100644
--- a/include/linux/ext3_fs.h
+++ b/include/linux/ext3_fs.h
@@ -892,6 +892,7 @@ extern void ext3_get_inode_flags(struct ext3_inode_info *);
 extern void ext3_set_aops(struct inode *inode);
 extern int ext3_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		       u64 start, u64 len);
+extern int ext3_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* ioctl.c */
 extern long ext3_ioctl(struct file *, unsigned int, unsigned long);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
