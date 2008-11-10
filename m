Date: Mon, 10 Nov 2008 17:18:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] fsync "livelock" fix with pagecache tags
Message-ID: <20081110161830.GB16924@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel@vger.kernel.org, Mikulas Patocka <mpatocka@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

OK sorry it has taken so long. And actually this patch isn't complete with
testing and comments etc yet (although it runs basic tests here). However
I've now got the existing code up to a point where it's possible, so I'd
like to get my design out there and see what people think about the two
approaches proposed.

The problem. To take an extreme example: if thread A calls fsync on a file with
one dirty page, at index 1 000 000; at the same time, thread B starts dirtying
the file from offset 0 onwards.

Thead B perhaps will be allowed to dirty 1 000 pages before hitting its dirty
threshold, then it will start throttling. Thread A will start writing out B's
pages. They'll proceed more or less in lockstep until thread B finishes
writing.

While these semantics are correct, we'd prefer a timely notification that pages
dirty at the time fsync was called are safely on disk. In the above scenario,
we may have to wait until many times the machine's RAM capacity has been
written to disk before the fsync returns success. Ideally, thread A would
write the single page at index 1 000 000, then return.

What my design does is to snapshot which pages are subject to data-integrity
sync up-front. Subsequent writeout then wait need then only operate on those
pages. In the above example, we'd only write that single page at 1000000.

Mikulas has recently run into this problem and first proposed a design to
basically detect if the fsync has been taking longer than it should be (based
on how many dirty pages a mapping has), and then throttling dirtiers in that
case.

I guess another alternative is to do nothing. It's not strictly a bug. IMO
it is worth improving, however.

Comments?

Thanks,
Nick

--
This patch fixes fsync starvation problems in the presence of concurrent
dirtiers.

This patch introduces a new pagecache tag, PAGECACHE_TAG_FSYNC. Data integrity
syncs then start by looking through the pagecache for pages which are DIRTY
and/or WRITEBACK, and tagging all those as FSYNC (within the requested range).

Subsequent writeout and wait phases need then only look up those pages in
the pagecache which are tagged with PAGECACHE_TAG_FSYNC.

After the sync operation has completed, the FSYNC tags are removed from the
radix tree. This requires a lock on the address space, so multiple fsyncers
to a single file don't use or clear the tags concurrently.

It's a bit annoying to have this lock just for this case, however I think I
found a real bug it helps to fix. Which makes it more attractive as a
solution than it would be for purely an fsync livelock fix: fsync errors do not
get propogated back up to the caller properly in some cases. Consider where we
write a page in the writeout path, then it encounters an IO error and finishes
writeback, in the meantime, another process (eg. via sys_sync, or another
fsync) clears the mapping error bits. Then our fsync will have appeared to
finish successfully, but actually should have returned error.

---
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -583,10 +583,12 @@ struct block_device {
 
 /*
  * Radix-tree tags, for tagging dirty and writeback pages within the pagecache
- * radix trees
+ * radix trees. Also, to snapshot all pages required to be fsync'ed in order
+ * to obey data integrity semantics.
  */
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
+#define PAGECACHE_TAG_FSYNC	2
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
@@ -1809,11 +1811,14 @@ extern int write_inode_now(struct inode 
 extern int filemap_fdatawrite(struct address_space *);
 extern int filemap_flush(struct address_space *);
 extern int filemap_fdatawait(struct address_space *);
+extern int filemap_fdatawait_fsync(struct address_space *);
 extern int filemap_write_and_wait(struct address_space *mapping);
 extern int filemap_write_and_wait_range(struct address_space *mapping,
 				        loff_t lstart, loff_t lend);
 extern int wait_on_page_writeback_range(struct address_space *mapping,
 				pgoff_t start, pgoff_t end);
+extern int wait_on_page_writeback_range_fsync(struct address_space *mapping,
+				pgoff_t start, pgoff_t end);
 extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -55,7 +55,7 @@ static inline int radix_tree_is_indirect
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 2
+#define RADIX_TREE_MAX_TAGS 3
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -147,6 +147,28 @@ void remove_from_page_cache(struct page 
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
+static int sleep_on_fsync(void *word)
+{
+	io_schedule();
+	return 0;
+}
+
+void mapping_fsync_lock(struct address_space *mapping)
+{
+	wait_on_bit_lock(&mapping->flags, AS_FSYNC_LOCK, sleep_on_fsync,
+							TASK_UNINTERRUPTIBLE);
+	WARN_ON(mapping_tagged(mapping, PAGECACHE_TAG_FSYNC));
+}
+
+void mapping_fsync_unlock(struct address_space *mapping)
+{
+	WARN_ON(mapping_tagged(mapping, PAGECACHE_TAG_FSYNC));
+	WARN_ON(!test_bit(AS_FSYNC_LOCK, &mapping->flags));
+	clear_bit_unlock(AS_FSYNC_LOCK, &mapping->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&mapping->flags, AS_FSYNC_LOCK);
+}
+
 static int sync_page(void *word)
 {
 	struct address_space *mapping;
@@ -287,7 +309,7 @@ int wait_on_page_writeback_range(struct 
 
 			/* until radix tree lookup accepts end_index */
 			if (page->index > end)
-				continue;
+				break;
 
 			wait_on_page_writeback(page);
 			if (PageError(page))
@@ -306,6 +328,64 @@ int wait_on_page_writeback_range(struct 
 	return ret;
 }
 
+int wait_on_page_writeback_range_fsync(struct address_space *mapping,
+				pgoff_t start, pgoff_t end)
+{
+	struct pagevec pvec;
+	int nr_pages;
+	int ret = 0;
+	pgoff_t index;
+
+	WARN_ON(!test_bit(AS_FSYNC_LOCK, &mapping->flags));
+
+	if (end < start)
+		goto out;
+
+	pagevec_init(&pvec, 0);
+	index = start;
+	while ((index <= end) &&
+			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+			PAGECACHE_TAG_FSYNC,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
+		unsigned i;
+
+		spin_lock_irq(&mapping->tree_lock);
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			/* until radix tree lookup accepts end_index */
+			if (page->index > end)
+				break;
+
+			radix_tree_tag_clear(&mapping->page_tree, page->index, PAGECACHE_TAG_FSYNC);
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			/* until radix tree lookup accepts end_index */
+			if (page->index > end)
+				break;
+
+			wait_on_page_writeback(page);
+			if (PageError(page))
+				ret = -EIO;
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+
+	/* Check for outstanding write errors */
+	if (test_and_clear_bit(AS_ENOSPC, &mapping->flags))
+		ret = -ENOSPC;
+	if (test_and_clear_bit(AS_EIO, &mapping->flags))
+		ret = -EIO;
+
+out:
+	return ret;
+}
+
 /**
  * sync_page_range - write and wait on all pages in the passed range
  * @inode:	target inode
@@ -325,18 +405,20 @@ int sync_page_range(struct inode *inode,
 {
 	pgoff_t start = pos >> PAGE_CACHE_SHIFT;
 	pgoff_t end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
-	int ret;
+	int ret, ret2;
 
 	if (!mapping_cap_writeback_dirty(mapping) || !count)
 		return 0;
+	mutex_lock(&inode->i_mutex);
+	mapping_fsync_lock(mapping);
 	ret = filemap_fdatawrite_range(mapping, pos, pos + count - 1);
-	if (ret == 0) {
-		mutex_lock(&inode->i_mutex);
+	if (ret == 0)
 		ret = generic_osync_inode(inode, mapping, OSYNC_METADATA);
-		mutex_unlock(&inode->i_mutex);
-	}
+	mutex_unlock(&inode->i_mutex);
+	ret2 = wait_on_page_writeback_range_fsync(mapping, start, end);
 	if (ret == 0)
-		ret = wait_on_page_writeback_range(mapping, start, end);
+		ret = ret2;
+	mapping_fsync_unlock(mapping);
 	return ret;
 }
 EXPORT_SYMBOL(sync_page_range);
@@ -357,15 +439,18 @@ int sync_page_range_nolock(struct inode 
 {
 	pgoff_t start = pos >> PAGE_CACHE_SHIFT;
 	pgoff_t end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
-	int ret;
+	int ret, ret2;
 
 	if (!mapping_cap_writeback_dirty(mapping) || !count)
 		return 0;
+	mapping_fsync_lock(mapping);
 	ret = filemap_fdatawrite_range(mapping, pos, pos + count - 1);
 	if (ret == 0)
 		ret = generic_osync_inode(inode, mapping, OSYNC_METADATA);
+	ret2 = wait_on_page_writeback_range_fsync(mapping, start, end);
 	if (ret == 0)
-		ret = wait_on_page_writeback_range(mapping, start, end);
+		ret = ret2;
+	mapping_fsync_unlock(mapping);
 	return ret;
 }
 EXPORT_SYMBOL(sync_page_range_nolock);
@@ -389,23 +474,30 @@ int filemap_fdatawait(struct address_spa
 }
 EXPORT_SYMBOL(filemap_fdatawait);
 
+int filemap_fdatawait_fsync(struct address_space *mapping)
+{
+	loff_t i_size = i_size_read(mapping->host);
+
+	if (i_size == 0)
+		return 0;
+
+	return wait_on_page_writeback_range_fsync(mapping, 0,
+				(i_size - 1) >> PAGE_CACHE_SHIFT);
+}
+
 int filemap_write_and_wait(struct address_space *mapping)
 {
 	int err = 0;
 
 	if (mapping->nrpages) {
+		int err2;
+
+		mapping_fsync_lock(mapping);
 		err = filemap_fdatawrite(mapping);
-		/*
-		 * Even if the above returned error, the pages may be
-		 * written partially (e.g. -ENOSPC), so we wait for it.
-		 * But the -EIO is special case, it may indicate the worst
-		 * thing (e.g. bug) happened, so we avoid waiting for it.
-		 */
-		if (err != -EIO) {
-			int err2 = filemap_fdatawait(mapping);
-			if (!err)
-				err = err2;
-		}
+		err2 = filemap_fdatawait_fsync(mapping);
+		if (!err)
+			err = err2;
+		mapping_fsync_unlock(mapping);
 	}
 	return err;
 }
@@ -428,16 +520,16 @@ int filemap_write_and_wait_range(struct 
 	int err = 0;
 
 	if (mapping->nrpages) {
-		err = __filemap_fdatawrite_range(mapping, lstart, lend,
-						 WB_SYNC_ALL);
-		/* See comment of filemap_write_and_wait() */
-		if (err != -EIO) {
-			int err2 = wait_on_page_writeback_range(mapping,
+		int err2;
+
+		mapping_fsync_lock(mapping);
+		err = filemap_fdatawrite_range(mapping, lstart, lend);
+		err2 = wait_on_page_writeback_range_fsync(mapping,
 						lstart >> PAGE_CACHE_SHIFT,
 						lend >> PAGE_CACHE_SHIFT);
-			if (!err)
-				err = err2;
-		}
+		if (!err)
+			err = err2;
+		mapping_fsync_unlock(mapping);
 	}
 	return err;
 }
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -872,9 +872,11 @@ int write_cache_pages(struct address_spa
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
 	pgoff_t done_index;
+	unsigned int tag = PAGECACHE_TAG_DIRTY;
 	int cycled;
 	int range_whole = 0;
 	long nr_to_write = wbc->nr_to_write;
+	int sync = wbc->sync_mode != WB_SYNC_NONE;
 
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
 		wbc->encountered_congestion = 1;
@@ -897,13 +899,40 @@ int write_cache_pages(struct address_spa
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
 	}
+
+	if (sync) {
+		WARN_ON(!test_bit(AS_FSYNC_LOCK, &mapping->flags));
+		/*
+		 * If any pages are writeback or dirty, mark them fsync now.
+		 * These are the pages we need to wait in in order to meet our
+		 * data integrity contract.
+		 *
+		 * Writeback pages need to be tagged, so we'll wait for them
+		 * at the end of the writeout phase. However, the lookup below
+		 * could just look up pages which are _DIRTY AND _FSYNC,
+		 * because we don't care about them for the writeout phase.
+		 */
+		spin_lock_irq(&mapping->tree_lock);
+		if (!radix_tree_gang_tag_set_if_tagged(&mapping->page_tree,
+							index, end,
+				(1UL << PAGECACHE_TAG_DIRTY) |
+				(1UL << PAGECACHE_TAG_WRITEBACK),
+				(1UL << PAGECACHE_TAG_FSYNC))) {
+			/* nothing tagged */
+			spin_unlock_irq(&mapping->tree_lock);
+			return 0;
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+		tag = PAGECACHE_TAG_FSYNC;
+	}
+
 retry:
 	done_index = index;
 	while (!done && (index <= end)) {
 		int i;
 
 		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			      PAGECACHE_TAG_DIRTY,
+			      tag,
 			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
 		if (nr_pages == 0)
 			break;
@@ -951,7 +980,7 @@ continue_unlock:
 			}
 
 			if (PageWriteback(page)) {
-				if (wbc->sync_mode != WB_SYNC_NONE)
+				if (sync)
 					wait_on_page_writeback(page);
 				else
 					goto continue_unlock;
@@ -981,7 +1010,7 @@ continue_unlock:
 				}
  			}
 
-			if (wbc->sync_mode == WB_SYNC_NONE) {
+			if (!sync) {
 				wbc->nr_to_write--;
 				if (wbc->nr_to_write <= 0) {
 					done = 1;
Index: linux-2.6/drivers/usb/gadget/file_storage.c
===================================================================
--- linux-2.6.orig/drivers/usb/gadget/file_storage.c
+++ linux-2.6/drivers/usb/gadget/file_storage.c
@@ -1873,13 +1873,15 @@ static int fsync_sub(struct lun *curlun)
 
 	inode = filp->f_path.dentry->d_inode;
 	mutex_lock(&inode->i_mutex);
+	mapping_fsync_lock(mapping);
 	rc = filemap_fdatawrite(inode->i_mapping);
 	err = filp->f_op->fsync(filp, filp->f_path.dentry, 1);
 	if (!rc)
 		rc = err;
-	err = filemap_fdatawait(inode->i_mapping);
+	err = filemap_fdatawait_fsync(inode->i_mapping);
 	if (!rc)
 		rc = err;
+	mapping_fsync_unlock(mapping);
 	mutex_unlock(&inode->i_mutex);
 	VLDBG(curlun, "fdatasync -> %d\n", rc);
 	return rc;
Index: linux-2.6/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.orig/fs/cifs/cifsfs.c
+++ linux-2.6/fs/cifs/cifsfs.c
@@ -991,12 +991,15 @@ static int cifs_oplock_thread(void *dumm
 				else if (CIFS_I(inode)->clientCanCacheRead == 0)
 					break_lease(inode, FMODE_WRITE);
 #endif
+				mapping_fsync_lock(mapping);
 				rc = filemap_fdatawrite(inode->i_mapping);
 				if (CIFS_I(inode)->clientCanCacheRead == 0) {
-					waitrc = filemap_fdatawait(
+					waitrc = filemap_fdatawait_fsync(
 							      inode->i_mapping);
+					mapping_fsync_unlock(mapping);
 					invalidate_remote_inode(inode);
-				}
+				} else
+					mapping_fsync_unlock(mapping);
 				if (rc == 0)
 					rc = waitrc;
 			} else
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -282,6 +282,9 @@ __sync_single_inode(struct inode *inode,
 
 	spin_unlock(&inode_lock);
 
+	if (wait)
+		mapping_fsync_lock(mapping);
+
 	ret = do_writepages(mapping, wbc);
 
 	/* Don't write the inode if only I_DIRTY_PAGES was set */
@@ -292,9 +295,10 @@ __sync_single_inode(struct inode *inode,
 	}
 
 	if (wait) {
-		int err = filemap_fdatawait(mapping);
+		int err = filemap_fdatawait_fsync(mapping);
 		if (ret == 0)
 			ret = err;
+		mapping_fsync_unlock(mapping);
 	}
 
 	spin_lock(&inode_lock);
@@ -772,17 +776,20 @@ int generic_osync_inode(struct inode *in
 	int need_write_inode_now = 0;
 	int err2;
 
-	if (what & OSYNC_DATA)
+	if (what & OSYNC_DATA) {
+		mapping_fsync_lock(mapping);
 		err = filemap_fdatawrite(mapping);
+	}
 	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
 		err2 = sync_mapping_buffers(mapping);
 		if (!err)
 			err = err2;
 	}
 	if (what & OSYNC_DATA) {
-		err2 = filemap_fdatawait(mapping);
+		err2 = filemap_fdatawait_fsync(mapping);
 		if (!err)
 			err = err2;
+		mapping_fsync_unlock(mapping);
 	}
 
 	spin_lock(&inode_lock);
Index: linux-2.6/fs/gfs2/glops.c
===================================================================
--- linux-2.6.orig/fs/gfs2/glops.c
+++ linux-2.6/fs/gfs2/glops.c
@@ -158,15 +158,20 @@ static void inode_go_sync(struct gfs2_gl
 
 	if (test_bit(GLF_DIRTY, &gl->gl_flags)) {
 		gfs2_log_flush(gl->gl_sbd, gl);
+		mapping_fsync_lock(metamapping);
 		filemap_fdatawrite(metamapping);
 		if (ip) {
 			struct address_space *mapping = ip->i_inode.i_mapping;
+
+			mapping_fsync_lock(mapping);
 			filemap_fdatawrite(mapping);
-			error = filemap_fdatawait(mapping);
+			error = filemap_fdatawait_fsync(mapping);
 			mapping_set_error(mapping, error);
+			mapping_fsync_unlock(mapping);
 		}
-		error = filemap_fdatawait(metamapping);
+		error = filemap_fdatawait_fsync(metamapping);
 		mapping_set_error(metamapping, error);
+		mapping_fsync_unlock(metamapping);
 		clear_bit(GLF_DIRTY, &gl->gl_flags);
 		gfs2_ail_empty_gl(gl);
 	}
Index: linux-2.6/fs/gfs2/meta_io.c
===================================================================
--- linux-2.6.orig/fs/gfs2/meta_io.c
+++ linux-2.6/fs/gfs2/meta_io.c
@@ -121,8 +121,10 @@ void gfs2_meta_sync(struct gfs2_glock *g
 	struct address_space *mapping = gl->gl_aspace->i_mapping;
 	int error;
 
+	mapping_fsync_lock(mapping);
 	filemap_fdatawrite(mapping);
-	error = filemap_fdatawait(mapping);
+	error = filemap_fdatawait_fsync(mapping);
+	mapping_fsync_unlock(mapping);
 
 	if (error)
 		gfs2_io_error(gl->gl_sbd);
Index: linux-2.6/fs/gfs2/ops_file.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_file.c
+++ linux-2.6/fs/gfs2/ops_file.c
@@ -244,12 +244,17 @@ static int do_gfs2_set_flags(struct file
 			goto out;
 	}
 	if ((flags ^ new_flags) & GFS2_DIF_JDATA) {
+		struct address_space *mapping = inode->i_mapping;
+		int error2;
+
 		if (flags & GFS2_DIF_JDATA)
 			gfs2_log_flush(sdp, ip->i_gl);
-		error = filemap_fdatawrite(inode->i_mapping);
-		if (error)
-			goto out;
-		error = filemap_fdatawait(inode->i_mapping);
+		mapping_fsync_lock(mapping);
+		error = filemap_fdatawrite(mapping);
+		error2 = filemap_fdatawait_fsync(mapping);
+		mapping_fsync_unlock(mapping);
+		if (!error)
+			error = error2;
 		if (error)
 			goto out;
 	}
Index: linux-2.6/fs/nfs/delegation.c
===================================================================
--- linux-2.6.orig/fs/nfs/delegation.c
+++ linux-2.6/fs/nfs/delegation.c
@@ -216,9 +216,13 @@ out:
 /* Sync all data to disk upon delegation return */
 static void nfs_msync_inode(struct inode *inode)
 {
-	filemap_fdatawrite(inode->i_mapping);
+	struct address_space *mapping = inode->i_mapping;
+
+	mapping_fsync_lock(mapping);
+	filemap_fdatawrite(mapping);
 	nfs_wb_all(inode);
-	filemap_fdatawait(inode->i_mapping);
+	filemap_fdatawait_fsync(mapping);
+	mapping_fsync_unlock(mapping);
 }
 
 /*
Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c
+++ linux-2.6/fs/nfsd/vfs.c
@@ -752,14 +752,18 @@ static inline int nfsd_dosync(struct fil
 			      const struct file_operations *fop)
 {
 	struct inode *inode = dp->d_inode;
+	struct address_space *mapping = inode->i_mapping;
 	int (*fsync) (struct file *, struct dentry *, int);
-	int err;
+	int err, err2;
 
-	err = filemap_fdatawrite(inode->i_mapping);
+	mapping_fsync_lock(mapping);
+	err = filemap_fdatawrite(mapping);
 	if (err == 0 && fop && (fsync = fop->fsync))
 		err = fsync(filp, dp, 0);
+	err2 = filemap_fdatawait_fsync(mapping);
 	if (err == 0)
-		err = filemap_fdatawait(inode->i_mapping);
+		err = err2;
+	mapping_fsync_unlock(mapping);
 
 	return err;
 }
Index: linux-2.6/fs/ocfs2/dlmglue.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/dlmglue.c
+++ linux-2.6/fs/ocfs2/dlmglue.c
@@ -3285,6 +3285,7 @@ static int ocfs2_data_convert_worker(str
 	 */
 	unmap_mapping_range(mapping, 0, 0, 0);
 
+	mapping_fsync_lock(mapping);
 	if (filemap_fdatawrite(mapping)) {
 		mlog(ML_ERROR, "Could not sync inode %llu for downconvert!",
 		     (unsigned long long)OCFS2_I(inode)->ip_blkno);
@@ -3298,8 +3299,9 @@ static int ocfs2_data_convert_worker(str
 		 * for us above. We don't truncate pages if we're
 		 * blocking anything < EXMODE because we want to keep
 		 * them around in that case. */
-		filemap_fdatawait(mapping);
+		filemap_fdatawait_fsync(mapping);
 	}
+	mapping_fsync_unlock(mapping);
 
 out:
 	return UNBLOCK_CONTINUE;
Index: linux-2.6/fs/sync.c
===================================================================
--- linux-2.6.orig/fs/sync.c
+++ linux-2.6/fs/sync.c
@@ -87,20 +87,22 @@ long do_fsync(struct file *file, int dat
 		goto out;
 	}
 
-	ret = filemap_fdatawrite(mapping);
-
 	/*
 	 * We need to protect against concurrent writers, which could cause
 	 * livelocks in fsync_buffers_list().
 	 */
 	mutex_lock(&mapping->host->i_mutex);
+	mapping_fsync_lock(mapping);
+	ret = filemap_fdatawrite(mapping);
+
 	err = file->f_op->fsync(file, file->f_path.dentry, datasync);
 	if (!ret)
 		ret = err;
 	mutex_unlock(&mapping->host->i_mutex);
-	err = filemap_fdatawait(mapping);
+	err = filemap_fdatawait_fsync(mapping);
 	if (!ret)
 		ret = err;
+	mapping_fsync_unlock(mapping);
 out:
 	return ret;
 }
@@ -268,8 +270,7 @@ int do_sync_mapping_range(struct address
 	}
 
 	if (flags & SYNC_FILE_RANGE_WRITE) {
-		ret = __filemap_fdatawrite_range(mapping, offset, endbyte,
-						WB_SYNC_ALL);
+		ret = filemap_fdatawrite_range(mapping, offset, endbyte);
 		if (ret < 0)
 			goto out;
 	}
Index: linux-2.6/fs/xfs/linux-2.6/xfs_fs_subr.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_fs_subr.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_fs_subr.c
@@ -19,6 +19,7 @@
 #include "xfs_vnodeops.h"
 #include "xfs_bmap_btree.h"
 #include "xfs_inode.h"
+#include <linux/writeback.h>
 
 int  fs_noerr(void) { return 0; }
 int  fs_nosys(void) { return ENOSYS; }
@@ -66,16 +67,22 @@ xfs_flush_pages(
 {
 	struct address_space *mapping = VFS_I(ip)->i_mapping;
 	int		ret = 0;
-	int		ret2;
 
 	if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
 		xfs_iflags_clear(ip, XFS_ITRUNCATED);
-		ret = filemap_fdatawrite(mapping);
-		if (flags & XFS_B_ASYNC)
-			return ret;
-		ret2 = filemap_fdatawait(mapping);
-		if (!ret)
-			ret = ret2;
+		if (flags & XFS_B_ASYNC) {
+			ret = __filemap_fdatawrite_range(mapping,
+					0, LLONG_MAX, WB_SYNC_NONE);
+		} else {
+			int ret2;
+
+			mapping_fsync_lock(mapping);
+			ret = filemap_fdatawrite(mapping);
+			ret2 = filemap_fdatawait_fsync(mapping);
+			if (!ret)
+				ret = ret2;
+			mapping_fsync_unlock(mapping);
+		}
 	}
 	return ret;
 }
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -21,6 +21,7 @@
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
 #define AS_MM_ALL_LOCKS	(__GFP_BITS_SHIFT + 2)	/* under mm_take_all_locks() */
+#define AS_FSYNC_LOCK	(__GFP_BITS_SHIFT + 3)	/* under fsync */
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
@@ -33,7 +34,7 @@ static inline void mapping_set_error(str
 }
 
 #ifdef CONFIG_UNEVICTABLE_LRU
-#define AS_UNEVICTABLE	(__GFP_BITS_SHIFT + 2)	/* e.g., ramdisk, SHM_LOCK */
+#define AS_UNEVICTABLE	(__GFP_BITS_SHIFT + 4)	/* e.g., ramdisk, SHM_LOCK */
 
 static inline void mapping_set_unevictable(struct address_space *mapping)
 {
@@ -60,6 +61,9 @@ static inline int mapping_unevictable(st
 }
 #endif
 
+void mapping_fsync_lock(struct address_space *mapping);
+void mapping_fsync_unlock(struct address_space *mapping);
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
