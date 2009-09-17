Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3BA6B0062
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:46 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/7] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Date: Thu, 17 Sep 2009 17:21:44 +0200
Message-Id: <1253200907-31392-5-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

page_mkwrite() is meant to be used by filesystems to allocate blocks under a
page which is becoming writeably mmapped in some process address space. This
allows a filesystem to return a page fault if there is not enough space
available, user exceeds quota or similar problem happens, rather than silently
discarding data later when writepage is called.

On filesystems where blocksize < pagesize the situation is more complicated.
Think for example that blocksize = 1024, pagesize = 4096 and a process does:
  ftruncate(fd, 0);
  pwrite(fd, buf, 1024, 0);
  map = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED, fd, 0);
  map[0] = 'a';  ----> page_mkwrite() for index 0 is called
  ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
  fsync(fd); ----> writepage() for index 0 is called

At the moment page_mkwrite() is called, filesystem can allocate only one block
for the page because i_size == 1024. Otherwise it would create blocks beyond
i_size which is generally undesirable. But later at writepage() time, we would
like to have blocks allocated for the whole page (and in principle we have to
allocate them because user could have filled the page with data after the
second ftruncate()).

This patch introduces a framework which allows filesystems to handle this with
a reasonable effort.  We change block_write_full_page() to check all the
buffers in the page (not only those inside i_size) but write only those which
are delayed or mapped. Since block_create_hole() writeprotects the page, the
filesystem is guaranteed that no block is submitted for IO unless it went
through get_block either from ->write_begin() or ->page_mkwrite().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c                 |  375 ++++++++++++++++++++++++++++++++++++++++++-
 fs/libfs.c                  |   38 +++++
 fs/mpage.c                  |    3 +-
 include/linux/buffer_head.h |   19 ++-
 include/linux/fs.h          |    2 +
 5 files changed, 430 insertions(+), 7 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 0eaa961..abe105a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/bitops.h>
 #include <linux/mpage.h>
+#include <linux/rmap.h>
 #include <linux/bit_spinlock.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
@@ -1688,7 +1689,7 @@ static int __block_prepare_write(struct inode *inode, struct page *page,
 		if (PageUptodate(page)) {
 			if (!buffer_uptodate(bh))
 				set_buffer_uptodate(bh);
-			continue; 
+			continue;
 		}
 		if (!buffer_uptodate(bh) && !buffer_delay(bh) &&
 		    !buffer_unwritten(bh) &&
@@ -1771,7 +1772,15 @@ int block_write_begin(struct file *file, struct address_space *mapping,
 
 	page = *pagep;
 	if (page == NULL) {
+		struct inode *inode = mapping->host;
+
 		ownpage = 1;
+		if (unlikely(pos > inode->i_size)) {
+			status = block_prepare_hole(inode, inode->i_size, pos,
+						    flags, get_block);
+			if (status)
+				goto out;
+		}
 		page = grab_cache_page_write_begin(mapping, index, flags);
 		if (!page) {
 			status = -ENOMEM;
@@ -1852,6 +1861,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	int i_size_changed = 0;
+	loff_t oldsize = inode->i_size;
 
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
@@ -1879,6 +1889,9 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 	if (i_size_changed)
 		mark_inode_dirty(inode);
 
+	if (oldsize < pos)
+		block_finish_hole(inode, oldsize, pos);
+
 	return copied;
 }
 EXPORT_SYMBOL(generic_write_end);
@@ -2168,6 +2181,285 @@ int block_commit_write(struct page *page, unsigned from, unsigned to)
 	return 0;
 }
 
+/**
+ * block_prepare_hole_bh - prepare creation of a hole, return partial bh
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ * @get_block:	filesystem's function for mapping blocks
+ *
+ * Prepare creation of a hole in a file caused either by extending truncate or
+ * by write starting after current i_size. The function finds a buffer head
+ * straddling @from, maps it, loads it from disk if needed and returns a
+ * reference to it. The function also zeroes the page after the returned
+ * buffer head upto @to. When @from is on a block boundary or block straddling
+ * @from is a hole, the function just zeroes the page from @from to @to
+ * and returns NULL.
+ *
+ * This function is usually called from write_begin function of filesystems
+ * which need to do some more complicated stuff before / after writing data
+ * to a block.
+ *
+ * This function must be called with i_mutex locked.
+ */
+struct buffer_head *block_prepare_hole_bh(struct inode *inode, loff_t from,
+					  loff_t to, unsigned flags,
+					  get_block_t *get_block)
+{
+	int bsize = 1 << inode->i_blkbits;
+	struct page *page;
+	pgoff_t index;
+	int start, len, page_off;
+	int err = 0;
+	struct buffer_head *head, *bh;
+
+	WARN_ON(!mutex_is_locked(&inode->i_mutex));
+
+	if (from >= to)
+		goto out;
+	index = from >> PAGE_CACHE_SHIFT;
+	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
+	if (!page) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	start = from & (PAGE_CACHE_SIZE - 1);
+	/* Block boundary? No need to flush anything to disk */
+	if (!(start & (bsize - 1)))
+		goto zero_page;
+
+	if (!page_has_buffers(page))
+		create_empty_buffers(page, bsize, 0);
+
+	/* Find the buffer that contains "offset" */
+	head = bh = page_buffers(page);
+	page_off = bsize;
+	while (start >= page_off) {
+		bh = bh->b_this_page;
+		page_off += bsize;
+	}
+
+	if (!buffer_mapped(bh) && !buffer_delay(bh)) {
+		WARN_ON(bh->b_size != bsize);
+		err = get_block(inode, from >> inode->i_blkbits, bh, 0);
+		if (err)
+			goto unlock;
+		/* Unmapped? It's a hole - nothing to write */
+		if (!buffer_mapped(bh) && !buffer_delay(bh))
+			goto zero_page;
+	}
+
+	if (!buffer_uptodate(bh) && !buffer_unwritten(bh)) {
+		ll_rw_block(READ, 1, &bh);
+		wait_on_buffer(bh);
+		/* Uhhuh. Read error. Complain and punt. */
+		if (!buffer_uptodate(bh)) {
+			err = -EIO;
+			goto unlock;
+		}
+	}
+	/* Zero the page after returned buffer */
+	len = min_t(int, PAGE_CACHE_SIZE - page_off, to - from);
+	zero_user(page, page_off, len);
+	get_bh(bh);
+	unlock_page(page);
+	page_cache_release(page);
+	return bh;
+
+zero_page:
+	len = min_t(int, PAGE_CACHE_SIZE - start, to - from);
+	zero_user(page, start, len);
+unlock:
+	unlock_page(page);
+	page_cache_release(page);
+out:
+	if (err)
+		return ERR_PTR(err);
+	return NULL;
+}
+EXPORT_SYMBOL(block_prepare_hole_bh);
+
+/**
+ * block_prepare_hole - prepare creation of a hole
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ * @get_block:	filesystem's function for mapping blocks
+ *
+ * Prepare creation of a hole in a file caused either by extending truncate or
+ * by write starting after current i_size. We zero-out tail of the page
+ * straddling @from and also mark buffer straddling @from as dirty.
+ *
+ * This function is usually called from write_begin function.
+ *
+ * This function must be called with i_mutex locked.
+ */
+int block_prepare_hole(struct inode *inode, loff_t from, loff_t to,
+		       unsigned flags, get_block_t *get_block)
+{
+	struct buffer_head *bh;
+	int bsize = 1 << inode->i_blkbits;
+	int start, len;
+
+	bh = block_prepare_hole_bh(inode, from, to, flags, get_block);
+	if (!bh)
+		return 0;
+	if (IS_ERR(bh))
+		return PTR_ERR(bh);
+
+	/* Zero the buffer we got */
+	start = from & (PAGE_CACHE_SIZE - 1);
+	len = min_t(int, bsize - (start & (bsize - 1)), to - from);
+	zero_user(bh->b_page, start, len);
+	mark_buffer_dirty(bh);
+	brelse(bh);
+
+	return 0;
+}
+EXPORT_SYMBOL(block_prepare_hole);
+
+/**
+ * nobh_prepare_hole - prepare creation of a hole without buffer heads
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ * @get_block:	filesystem's function for mapping blocks
+ *
+ * Prepare creation of a hole in a file caused either by extending truncate or
+ * by write starting after current i_size. We zero-out tail of the page
+ * straddling @from and also mark buffer straddling @from as dirty.
+ *
+ * This function is called from nobh_write_begin function.
+ *
+ * This function must be called with i_mutex locked.
+ */
+int nobh_prepare_hole(struct inode *inode, loff_t from, loff_t to,
+		      unsigned flags, get_block_t *get_block)
+{
+	int bsize = 1 << inode->i_blkbits;
+	struct page *page;
+	pgoff_t index;
+	int start, len;
+	int err = 0;
+	struct buffer_head map_bh;
+
+	WARN_ON(!mutex_is_locked(&inode->i_mutex));
+
+	if (from >= to)
+		goto out;
+	index = from >> PAGE_CACHE_SHIFT;
+	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
+	if (!page) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	start = from & (PAGE_CACHE_SIZE - 1);
+	len = min_t(int, PAGE_CACHE_SIZE - start, to - from);
+	/* Block boundary? No need to flush anything to disk */
+	if (!(start & (bsize - 1)))
+		goto zero_page;
+
+	if (page_has_buffers(page)) {
+has_buffers:
+		unlock_page(page);
+		page_cache_release(page);
+		return block_prepare_hole(inode, from, to, flags, get_block);
+	}
+
+	map_bh.b_size = bsize;
+	map_bh.b_state = 0;
+	err = get_block(inode, from >> inode->i_blkbits, &map_bh, 0);
+	if (err)
+		goto unlock;
+	/* Unmapped? It's a hole - nothing to write */
+	if (!buffer_mapped(&map_bh))
+		goto zero_page;
+
+	/* Ok, it's mapped. Make sure it's up-to-date */
+	if (!PageUptodate(page)) {
+		err = inode->i_mapping->a_ops->readpage(NULL, page);
+		if (err) {
+			page_cache_release(page);
+			goto out;
+		}
+		lock_page(page);
+		if (!PageUptodate(page)) {
+			err = -EIO;
+			goto unlock;
+		}
+		if (page_has_buffers(page))
+			goto has_buffers;
+	}
+	/*
+	 * We have to send the boundary buffer to disk so mark the page dirty.
+	 * We do it before actually zeroing the page but that does not matter
+	 * since we hold the page lock.
+	 */
+	set_page_dirty(page);
+zero_page:
+	zero_user(page, start, len);
+unlock:
+	unlock_page(page);
+	page_cache_release(page);
+out:
+	return err;
+}
+EXPORT_SYMBOL(nobh_prepare_hole);
+
+#ifdef CONFIG_MMU
+/**
+ * block_finish_hole - finish creation of a hole
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ *
+ * Finish creation of a hole in a file either caused by extending truncate or
+ * by write starting after current i_size. We mark the page straddling @from RO
+ * so that page_mkwrite() is called on the nearest write access to the page.
+ * This way filesystem can be sure that page_mkwrite() is called on the page
+ * before user writes to the page via mmap after the i_size has been changed
+ * (we hold i_mutex here and while we hold it user has no chance finding i_size
+ * is being changed).
+ *
+ * This function must be called after i_size is updated so that page_mkwrite()
+ * happenning immediately after we unlock the page initializes it correctly.
+ */
+void block_finish_hole(struct inode *inode, loff_t from, loff_t to)
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
+EXPORT_SYMBOL(block_finish_hole);
+#endif
+
 /*
  * block_page_mkwrite() is not allowed to change the file size as it gets
  * called from a page fault handler when a page is first dirtied. Hence we must
@@ -2225,6 +2517,56 @@ out:
 	return ret;
 }
 
+/**
+ * noalloc_page_mkwrite - fault in the page without allocating any blocks
+ * @vma:	vma where the fault happened
+ * @vmf:	information about the fault
+ *
+ * This is a page_mkwrite function for filesystems that want to retain the old
+ * behavior and not allocate any blocks on page fault. It just marks all
+ * unmapped buffers in the page as delayed so that block_write_full_page()
+ * writes them.
+ */
+int noalloc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct page *page = vmf->page;
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	int bsize;
+	loff_t size, off;
+	int ret = VM_FAULT_NOPAGE; /* make the VM retry the fault */
+	struct buffer_head *head, *bh;
+
+	lock_page(page);
+	size = i_size_read(inode);
+	bsize = 1 << inode->i_blkbits;
+	if ((page->mapping != inode->i_mapping) ||
+	    (page_offset(page) > size)) {
+		/* page got truncated out from underneath us */
+		unlock_page(page);
+		goto out;
+	}
+
+	ret = VM_FAULT_LOCKED;
+	if (!page_has_buffers(page))
+		create_empty_buffers(page, bsize, 0);
+	head = bh = page_buffers(page);
+	off = ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	do {
+		/*
+		 * Using BH_Delay is a slight hack but in fact it makes
+		 * sence since the filesystem really delays the allocation
+		 * to the moment writeout happens
+		 */
+		if (!buffer_mapped(bh) && off < size)
+			set_buffer_delay(bh);
+		bh = bh->b_this_page;
+		off += bsize;
+	} while (bh != head);
+out:
+	return ret;
+}
+EXPORT_SYMBOL(noalloc_page_mkwrite);
+
 /*
  * nobh_write_begin()'s prereads are special: the buffer_heads are freed
  * immediately, while under the page lock.  So it needs a special end_io
@@ -2286,6 +2628,13 @@ int nobh_write_begin(struct file *file, struct address_space *mapping,
 	from = pos & (PAGE_CACHE_SIZE - 1);
 	to = from + len;
 
+	if (unlikely(pos > inode->i_size)) {
+		ret = nobh_prepare_hole(inode, inode->i_size, pos,
+					flags, get_block);
+		if (ret)
+			return ret;
+	}
+
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -2416,6 +2765,8 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = page->mapping->host;
 	struct buffer_head *head = fsdata;
 	struct buffer_head *bh;
+	loff_t oldsize = inode->i_size;
+
 	BUG_ON(fsdata != NULL && page_has_buffers(page));
 
 	if (unlikely(copied < len) && head)
@@ -2434,6 +2785,9 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	unlock_page(page);
 	page_cache_release(page);
 
+	if (oldsize < pos)
+		block_finish_hole(inode, oldsize, pos);
+
 	while (head) {
 		bh = head;
 		head = head->b_this_page;
@@ -2477,8 +2831,8 @@ int nobh_truncate_page(struct address_space *mapping,
 	blocksize = 1 << inode->i_blkbits;
 	length = offset & (blocksize - 1);
 
-	/* Block boundary? Nothing to do */
-	if (!length)
+	/* Page boundary? Nothing to do */
+	if (!offset)
 		return 0;
 
 	length = blocksize - length;
@@ -2503,6 +2857,10 @@ has_buffers:
 		pos += blocksize;
 	}
 
+	/* Page is no longer fully mapped? */
+	if (pos < PAGE_CACHE_SIZE)
+		ClearPageMappedToDisk(page);
+
 	map_bh.b_size = blocksize;
 	map_bh.b_state = 0;
 	err = get_block(inode, iblock, &map_bh, 0);
@@ -2667,11 +3025,12 @@ int block_write_full_page_endio(struct page *page, get_block_t *get_block,
 	int nr_underway = 0;
 	int write_op = (wbc->sync_mode == WB_SYNC_ALL ?
 			WRITE_SYNC_PLUG : WRITE);
+	int new_writepage = page->mapping->a_ops->new_writepage;
 
 	BUG_ON(!PageLocked(page));
 
 	/* Is the page fully inside i_size? */
-	if (page->index < end_index)
+	if (page->index < end_index || new_writepage)
 		goto write_page;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
@@ -2716,6 +3075,12 @@ write_page:
 	 * handle any aliases from the underlying blockdev's mapping.
 	 */
 	do {
+		if (new_writepage) {
+			if (buffer_dirty(bh) && buffer_delay(bh))
+				goto map_it;
+			else
+				goto next;
+		}
 		if (block > last_block) {
 			/*
 			 * mapped buffers outside i_size will occur, because
@@ -2729,6 +3094,7 @@ write_page:
 			set_buffer_uptodate(bh);
 		} else if ((!buffer_mapped(bh) || buffer_delay(bh)) &&
 			   buffer_dirty(bh)) {
+map_it:
 			WARN_ON(bh->b_size != blocksize);
 			err = get_block(inode, block, bh, 1);
 			if (err)
@@ -2741,6 +3107,7 @@ write_page:
 							bh->b_blocknr);
 			}
 		}
+next:
 		bh = bh->b_this_page;
 		block++;
 	} while (bh != head);
diff --git a/fs/libfs.c b/fs/libfs.c
index 28c45b0..e3741df 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -331,6 +331,38 @@ int simple_rename(struct inode *old_dir, struct dentry *old_dentry,
 }
 
 /**
+ * simple_create_hole - handle creation of a hole on memory-backed filesystem
+ * @inode:	inode where the hole is created
+ * @from:	offset in bytes where the hole starts
+ * @to:		offset in bytes where the hole ends.
+ *
+ * This function does necessary zeroing when a hole is created on a memory
+ * backed filesystem (non-zeros can happen to be beyond EOF because the
+ * page was written via mmap).
+ */
+void simple_create_hole(struct inode *inode, loff_t from, loff_t to)
+{
+	struct page *page;
+	pgoff_t index;
+	int start, len;
+
+	if (from >= to)
+		return;
+	index = from >> PAGE_CACHE_SHIFT;
+	page = find_lock_page(inode->i_mapping, index);
+	/* Page not cached? Nothing to do */
+	if (!page)
+		return;
+	start = from & (PAGE_CACHE_SIZE - 1);
+	len = min_t(int, PAGE_CACHE_SIZE - start, to - from);
+	zero_user(page, start, len);
+	unlock_page(page);
+	page_cache_release(page);
+	return;
+}
+EXPORT_SYMBOL(simple_create_hole);
+
+/**
  * simple_setsize - handle core mm and vfs requirements for file size change
  * @inode: inode
  * @newsize: new file size
@@ -368,6 +400,8 @@ int simple_setsize(struct inode *inode, loff_t newsize)
 	oldsize = inode->i_size;
 	i_size_write(inode, newsize);
 	truncate_pagecache(inode, oldsize, newsize);
+	if (newsize > oldsize)
+		simple_create_hole(inode, oldsize, newsize);
 
 	return error;
 }
@@ -440,6 +474,10 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 	struct page *page;
 	pgoff_t index;
 	unsigned from;
+	struct inode *inode = mapping->host;
+
+	if (pos > inode->i_size)
+		simple_create_hole(inode, inode->i_size, pos);
 
 	index = pos >> PAGE_CACHE_SHIFT;
 	from = pos & (PAGE_CACHE_SIZE - 1);
diff --git a/fs/mpage.c b/fs/mpage.c
index 42381bd..cb0ebee 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -470,6 +470,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	struct buffer_head map_bh;
 	loff_t i_size = i_size_read(inode);
 	int ret = 0;
+	int new_writepage = mapping->a_ops->new_writepage;
 
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
@@ -558,7 +559,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 
 page_is_mapped:
 	end_index = i_size >> PAGE_CACHE_SHIFT;
-	if (page->index >= end_index) {
+	if (page->index >= end_index && !new_writepage) {
 		/*
 		 * The page straddles i_size.  It must be zeroed out on each
 		 * and every writepage invokation because it may be mmapped.
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 16ed028..eb79342 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -151,8 +151,7 @@ void set_bh_page(struct buffer_head *bh,
 int try_to_free_buffers(struct page *);
 struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		int retry);
-void create_empty_buffers(struct page *, unsigned long,
-			unsigned long b_state);
+void create_empty_buffers(struct page *, unsigned long, unsigned long b_state);
 void end_buffer_read_sync(struct buffer_head *bh, int uptodate);
 void end_buffer_write_sync(struct buffer_head *bh, int uptodate);
 void end_buffer_async_write(struct buffer_head *bh, int uptodate);
@@ -221,6 +220,20 @@ int generic_cont_expand_simple(struct inode *inode, loff_t size);
 int block_commit_write(struct page *page, unsigned from, unsigned to);
 int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 				get_block_t get_block);
+int noalloc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
+int block_prepare_hole(struct inode *inode, loff_t from, loff_t to,
+		       unsigned flags, get_block_t *get_block);
+struct buffer_head *block_prepare_hole_bh(struct inode *inode, loff_t from,
+					  loff_t to, unsigned flags,
+					  get_block_t *get_block);
+#ifdef CONFIG_MMU
+void block_finish_hole(struct inode *inode, loff_t from, loff_t to);
+#else
+static inline void block_finish_hole(struct inode *inode, loff_t from, loff_t to)
+{
+}
+#endif
+
 void block_sync_page(struct page *);
 sector_t generic_block_bmap(struct address_space *, sector_t, get_block_t *);
 int block_truncate_page(struct address_space *, loff_t, get_block_t *);
@@ -232,6 +245,8 @@ int nobh_write_end(struct file *, struct address_space *,
 				loff_t, unsigned, unsigned,
 				struct page *, void *);
 int nobh_truncate_page(struct address_space *, loff_t, get_block_t *);
+int nobh_prepare_hole(struct inode *inode, loff_t from, loff_t to,
+		      unsigned flags, get_block_t *get_block);
 int nobh_writepage(struct page *page, get_block_t *get_block,
                         struct writeback_control *wbc);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c9d5f89..e1cc0c2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -595,6 +595,8 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+	int new_writepage;	/* A hack until filesystems are converted to
+				 * use new block_write_full_page */
 };
 
 /*
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
