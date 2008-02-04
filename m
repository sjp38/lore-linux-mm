Message-Id: <20080204144207.547942700@szeredi.hu>
References: <20080204144142.002127391@szeredi.hu>
Date: Mon, 04 Feb 2008 15:41:45 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 3/3] fuse: support writable mmap
Content-Disposition: inline; filename=fuse_mmap_write.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Linus (3 years ago, FUSE inclusion discussions):

  "User-space filesystems are hard to get right. I'd claim that they
   are almost impossible, unless you limit them somehow (shared
   writable mappings are the nastiest part - if you don't have those,
   you can reasonably limit your problems by limiting the number of
   dirty pages you accept through normal "write()" calls)."

Instead of attempting the impossible, I've just waited for the dirty
page accounting infrastructure to materialize (thanks to Peter
Zijlstra and others).  This nicely solved the biggest problem:
limiting the number of pages used for write caching.

Some small details remained, however, which this largish patch
attempts to address.  It provides a page writeback implementation for
fuse, which is completely safe against VM related deadlocks.
Performance may not be very good for certain usage patterns, but
generally it should be acceptable.

It has been tested extensively with fsx-linux and bash-shared-mapping.

This patch depends on
mm-bdi-allow-setting-a-maximum-for-the-bdi-dirty-limit-fix.patch


Fuse page writeback design
--------------------------

fuse_writepage() allocates a new temporary page with
GFP_NOFS|__GFP_HIGHMEM.  It copies the contents of the original page,
and queues a WRITE request to the userspace filesystem using this temp
page.

The writeback is finished instantly from the MM's point of view: the
page is removed from the radix trees, and the PageDirty and
PageWriteback flags are cleared.

For the duration of the actual write, the NR_WRITEBACK_TEMP counter is
incremented.  The per-bdi writeback count is not decremented until the
actual write completes.

On dirtying the page, fuse waits for a previous write to finish before
proceeding.  This makes sure, there can only be one temporary page used
at a time for one cached page.

This approach is wasteful in both memory and CPU bandwidth, so why is
this complication needed?

The basic problem is that there can be no guarantee about the time in
which the userspace filesystem will complete a write.  It may be buggy
or even malicious, and fail to complete WRITE requests.  We don't want
unrelated parts of the system to grind to a halt in such cases.

Also a filesystem may need additional resources (particularly memory)
to complete a WRITE request.  There's a great danger of a deadlock if
that allocation may wait for the writepage to finish.

Currently there are several cases where the kernel can block on page
writeback:

  - allocation order is larger than PAGE_ALLOC_COSTLY_ORDER
  - page migration
  - throttle_vm_writeout (through NR_WRITEBACK)
  - sync(2)

Of course in some cases (fsync, msync) we explicitly want to allow
blocking.  So for these cases new code has to be added to fuse, since
the VM is not tracking writeback pages for us any more.

As an extra safetly measure, the maximum dirty ratio allocated to a
single fuse filesystem is set to 1% by default.  This way one (or
several) buggy or malicious fuse filesystems cannot slow down the rest
of the system by hogging dirty memory.

With appropriate privileges, this limit can be raised through
'/sys/class/bdi/<bdi>/max_ratio'.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/fs/fuse/dev.c
===================================================================
--- linux.orig/fs/fuse/dev.c	2008-02-04 15:24:03.000000000 +0100
+++ linux/fs/fuse/dev.c	2008-02-04 15:24:47.000000000 +0100
@@ -47,6 +47,14 @@ struct fuse_req *fuse_request_alloc(void
 	return req;
 }
 
+struct fuse_req *fuse_request_alloc_nofs(void)
+{
+	struct fuse_req *req = kmem_cache_alloc(fuse_req_cachep, GFP_NOFS);
+	if (req)
+		fuse_request_init(req);
+	return req;
+}
+
 void fuse_request_free(struct fuse_req *req)
 {
 	kmem_cache_free(fuse_req_cachep, req);
@@ -430,6 +438,17 @@ void request_send_background(struct fuse
 }
 
 /*
+ * Called under fc->lock
+ *
+ * fc->connected must have been checked previously
+ */
+void request_send_background_locked(struct fuse_conn *fc, struct fuse_req *req)
+{
+	req->isreply = 1;
+	request_send_nowait_locked(fc, req);
+}
+
+/*
  * Lock the request.  Up to the next unlock_request() there mustn't be
  * anything that could cause a page-fault.  If the request was already
  * aborted bail out.
Index: linux/fs/fuse/dir.c
===================================================================
--- linux.orig/fs/fuse/dir.c	2008-02-04 15:24:03.000000000 +0100
+++ linux/fs/fuse/dir.c	2008-02-04 15:24:47.000000000 +0100
@@ -1107,6 +1107,50 @@ static void iattr_to_fattr(struct iattr 
 }
 
 /*
+ * Prevent concurrent writepages on inode
+ *
+ * This is done by adding a negative bias to the inode write counter
+ * and waiting for all pending writes to finish.
+ */
+void fuse_set_nowrite(struct inode *inode)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	BUG_ON(!mutex_is_locked(&inode->i_mutex));
+
+	spin_lock(&fc->lock);
+	BUG_ON(fi->writectr < 0);
+	fi->writectr += FUSE_NOWRITE;
+	spin_unlock(&fc->lock);
+	wait_event(fi->page_waitq, fi->writectr == FUSE_NOWRITE);
+}
+
+/*
+ * Allow writepages on inode
+ *
+ * Remove the bias from the writecounter and send any queued
+ * writepages.
+ */
+static void __fuse_release_nowrite(struct inode *inode)
+{
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	BUG_ON(fi->writectr != FUSE_NOWRITE);
+	fi->writectr = 0;
+	fuse_flush_writepages(inode);
+}
+
+void fuse_release_nowrite(struct inode *inode)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+
+	spin_lock(&fc->lock);
+	__fuse_release_nowrite(inode);
+	spin_unlock(&fc->lock);
+}
+
+/*
  * Set attributes, and at the same time refresh them.
  *
  * Truncation is slightly complicated, because the 'truncate' request
@@ -1122,6 +1166,8 @@ static int fuse_do_setattr(struct dentry
 	struct fuse_req *req;
 	struct fuse_setattr_in inarg;
 	struct fuse_attr_out outarg;
+	bool is_truncate = false;
+	loff_t oldsize;
 	int err;
 
 	if (!fuse_allow_task(fc, current))
@@ -1145,12 +1191,16 @@ static int fuse_do_setattr(struct dentry
 			send_sig(SIGXFSZ, current, 0);
 			return -EFBIG;
 		}
+		is_truncate = true;
 	}
 
 	req = fuse_get_req(fc);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
+	if (is_truncate)
+		fuse_set_nowrite(inode);
+
 	memset(&inarg, 0, sizeof(inarg));
 	memset(&outarg, 0, sizeof(outarg));
 	iattr_to_fattr(attr, &inarg);
@@ -1181,16 +1231,44 @@ static int fuse_do_setattr(struct dentry
 	if (err) {
 		if (err == -EINTR)
 			fuse_invalidate_attr(inode);
-		return err;
+		goto error;
 	}
 
 	if ((inode->i_mode ^ outarg.attr.mode) & S_IFMT) {
 		make_bad_inode(inode);
-		return -EIO;
+		err = -EIO;
+		goto error;
+	}
+
+	spin_lock(&fc->lock);
+	fuse_change_attributes_common(inode, &outarg.attr,
+				      attr_timeout(&outarg));
+	oldsize = inode->i_size;
+	i_size_write(inode, outarg.attr.size);
+
+	if (is_truncate) {
+		/* NOTE: this may release/reacquire fc->lock */
+		__fuse_release_nowrite(inode);
+	}
+	spin_unlock(&fc->lock);
+
+	/*
+	 * Only call invalidate_inode_pages2() after removing
+	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
+	 */
+	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
+		if (outarg.attr.size < oldsize)
+			fuse_truncate(inode->i_mapping, outarg.attr.size);
+		invalidate_inode_pages2(inode->i_mapping);
 	}
 
-	fuse_change_attributes(inode, &outarg.attr, attr_timeout(&outarg), 0);
 	return 0;
+
+error:
+	if (is_truncate)
+		fuse_release_nowrite(inode);
+
+	return err;
 }
 
 static int fuse_setattr(struct dentry *entry, struct iattr *attr)
Index: linux/fs/fuse/file.c
===================================================================
--- linux.orig/fs/fuse/file.c	2008-02-04 15:24:03.000000000 +0100
+++ linux/fs/fuse/file.c	2008-02-04 15:24:47.000000000 +0100
@@ -210,6 +210,49 @@ u64 fuse_lock_owner_id(struct fuse_conn 
 	return (u64) v0 + ((u64) v1 << 32);
 }
 
+/*
+ * Check if page is under writeback
+ *
+ * This is currently done by walking the list of writepage requests
+ * for the inode, which can be pretty inefficient.
+ */
+static bool fuse_page_is_writeback(struct inode *inode, pgoff_t index)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	struct fuse_req *req;
+	bool found = false;
+
+	spin_lock(&fc->lock);
+	list_for_each_entry(req, &fi->writepages, writepages_entry) {
+		pgoff_t curr_index;
+
+		BUG_ON(req->inode != inode);
+		curr_index = req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		if (curr_index == index) {
+			found = true;
+			break;
+		}
+	}
+	spin_unlock(&fc->lock);
+
+	return found;
+}
+
+/*
+ * Wait for page writeback to be completed.
+ *
+ * Since fuse doesn't rely on the VM writeback tracking, this has to
+ * use some other means.
+ */
+static int fuse_wait_on_page_writeback(struct inode *inode, pgoff_t index)
+{
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	wait_event(fi->page_waitq, !fuse_page_is_writeback(inode, index));
+	return 0;
+}
+
 static int fuse_flush(struct file *file, fl_owner_t id)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
@@ -245,6 +288,21 @@ static int fuse_flush(struct file *file,
 	return err;
 }
 
+/*
+ * Wait for all pending writepages on the inode to finish.
+ *
+ * This is currently done by blocking further writes with FUSE_NOWRITE
+ * and waiting for all sent writes to complete.
+ *
+ * This must be called under i_mutex, otherwise the FUSE_NOWRITE usage
+ * could conflict with truncation.
+ */
+static void fuse_sync_writes(struct inode *inode)
+{
+	fuse_set_nowrite(inode);
+	fuse_release_nowrite(inode);
+}
+
 int fuse_fsync_common(struct file *file, struct dentry *de, int datasync,
 		      int isdir)
 {
@@ -261,6 +319,17 @@ int fuse_fsync_common(struct file *file,
 	if ((!isdir && fc->no_fsync) || (isdir && fc->no_fsyncdir))
 		return 0;
 
+	/*
+	 * Start writeback against all dirty pages of the inode, then
+	 * wait for all outstanding writes, before sending the FSYNC
+	 * request.
+	 */
+	err = write_inode_now(inode, 0);
+	if (err)
+		return err;
+
+	fuse_sync_writes(inode);
+
 	req = fuse_get_req(fc);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
@@ -340,6 +409,13 @@ static int fuse_readpage(struct file *fi
 	if (is_bad_inode(inode))
 		goto out;
 
+	/*
+	 * Page writeback can extend beyond the liftime of the
+	 * page-cache page, so make sure we read a properly synced
+	 * page.
+	 */
+	fuse_wait_on_page_writeback(inode, page->index);
+
 	req = fuse_get_req(fc);
 	err = PTR_ERR(req);
 	if (IS_ERR(req))
@@ -411,6 +487,8 @@ static int fuse_readpages_fill(void *_da
 	struct inode *inode = data->inode;
 	struct fuse_conn *fc = get_fuse_conn(inode);
 
+	fuse_wait_on_page_writeback(inode, page->index);
+
 	if (req->num_pages &&
 	    (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
 	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_read ||
@@ -477,11 +555,10 @@ static ssize_t fuse_file_aio_read(struct
 }
 
 static void fuse_write_fill(struct fuse_req *req, struct file *file,
-			    struct inode *inode, loff_t pos, size_t count,
-			    int writepage)
+			    struct fuse_file *ff, struct inode *inode,
+			    loff_t pos, size_t count, int writepage)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
-	struct fuse_file *ff = file->private_data;
 	struct fuse_write_in *inarg = &req->misc.write.in;
 	struct fuse_write_out *outarg = &req->misc.write.out;
 
@@ -490,7 +567,7 @@ static void fuse_write_fill(struct fuse_
 	inarg->offset = pos;
 	inarg->size = count;
 	inarg->write_flags = writepage ? FUSE_WRITE_CACHE : 0;
-	inarg->flags = file->f_flags;
+	inarg->flags = file ? file->f_flags : 0;
 	req->in.h.opcode = FUSE_WRITE;
 	req->in.h.nodeid = get_node_id(inode);
 	req->in.argpages = 1;
@@ -511,7 +588,7 @@ static size_t fuse_send_write(struct fus
 			      fl_owner_t owner)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
-	fuse_write_fill(req, file, inode, pos, count, 0);
+	fuse_write_fill(req, file, file->private_data, inode, pos, count, 0);
 	if (owner != NULL) {
 		struct fuse_write_in *inarg = &req->misc.write.in;
 		inarg->write_flags |= FUSE_WRITE_LOCKOWNER;
@@ -546,6 +623,12 @@ static int fuse_buffered_write(struct fi
 	if (is_bad_inode(inode))
 		return -EIO;
 
+	/*
+	 * Make sure writepages on the same page are not mixed up with
+	 * plain writes.
+	 */
+	fuse_wait_on_page_writeback(inode, page->index);
+
 	req = fuse_get_req(fc);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
@@ -716,21 +799,239 @@ static ssize_t fuse_direct_write(struct 
 	return res;
 }
 
-static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
+static void fuse_writepage_free(struct fuse_conn *fc, struct fuse_req *req)
 {
-	if ((vma->vm_flags & VM_SHARED)) {
-		if ((vma->vm_flags & VM_WRITE))
-			return -ENODEV;
-		else
-			vma->vm_flags &= ~VM_MAYWRITE;
+	__free_page(req->pages[0]);
+	fuse_file_put(req->ff);
+	fuse_put_request(fc, req);
+}
+
+static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
+{
+	struct inode *inode = req->inode;
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	struct backing_dev_info *bdi = inode->i_mapping->backing_dev_info;
+
+	list_del(&req->writepages_entry);
+	dec_bdi_stat(bdi, BDI_WRITEBACK);
+	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
+	bdi_writeout_inc(bdi);
+	wake_up(&fi->page_waitq);
+}
+
+/* Called under fc->lock, may release and reacquire it */
+static void fuse_send_writepage(struct fuse_conn *fc, struct fuse_req *req)
+{
+	struct fuse_inode *fi = get_fuse_inode(req->inode);
+	loff_t size = i_size_read(req->inode);
+	struct fuse_write_in *inarg = &req->misc.write.in;
+
+	if (!fc->connected)
+		goto out_free;
+
+	if (inarg->offset + PAGE_CACHE_SIZE <= size) {
+		inarg->size = PAGE_CACHE_SIZE;
+	} else if (inarg->offset < size) {
+		inarg->size = size & (PAGE_CACHE_SIZE - 1);
+	} else {
+		/* Got truncated off completely */
+		goto out_free;
+	}
+
+	req->in.args[1].size = inarg->size;
+	fi->writectr++;
+	request_send_background_locked(fc, req);
+	return;
+
+ out_free:
+	fuse_writepage_finish(fc, req);
+	spin_unlock(&fc->lock);
+	fuse_writepage_free(fc, req);
+	spin_lock(&fc->lock);
+}
+
+/*
+ * If fi->writectr is positive (no truncate or fsync going on) send
+ * all queued writepage requests.
+ *
+ * Called with fc->lock
+ */
+void fuse_flush_writepages(struct inode *inode)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	struct fuse_req *req;
+
+	while (fi->writectr >= 0 && !list_empty(&fi->queued_writes)) {
+		req = list_entry(fi->queued_writes.next, struct fuse_req, list);
+		list_del_init(&req->list);
+		fuse_send_writepage(fc, req);
+	}
+}
+
+static void fuse_writepage_end(struct fuse_conn *fc, struct fuse_req *req)
+{
+	struct inode *inode = req->inode;
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	mapping_set_error(inode->i_mapping, req->out.h.error);
+	spin_lock(&fc->lock);
+	fi->writectr--;
+	fuse_writepage_finish(fc, req);
+	spin_unlock(&fc->lock);
+	fuse_writepage_free(fc, req);
+}
+
+static void fuse_clear_page_writeback(struct page *page)
+{
+	int ret;
+	unsigned long flags;
+	struct address_space *mapping = page->mapping;
+
+	write_lock_irqsave(&mapping->tree_lock, flags);
+	ret = TestClearPageWriteback(page);
+	BUG_ON(!ret);
+	radix_tree_tag_clear(&mapping->page_tree, page_index(page),
+			     PAGECACHE_TAG_WRITEBACK);
+	write_unlock_irqrestore(&mapping->tree_lock, flags);
+	dec_zone_page_state(page, NR_WRITEBACK);
+}
+
+static int fuse_writepage_locked(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	struct fuse_req *req;
+	struct fuse_file *ff;
+	struct page *tmp_page;
+
+	set_page_writeback(page);
+
+	req = fuse_request_alloc_nofs();
+	if (!req)
+		goto err;
+
+	tmp_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
+	if (!tmp_page)
+		goto err_free;
+
+	spin_lock(&fc->lock);
+	BUG_ON(list_empty(&fi->write_files));
+	ff = list_entry(fi->write_files.next, struct fuse_file, write_entry);
+	req->ff = fuse_file_get(ff);
+	spin_unlock(&fc->lock);
+
+	fuse_write_fill(req, NULL, ff, inode, page_offset(page), 0, 1);
+
+	copy_highpage(tmp_page, page);
+	req->num_pages = 1;
+	req->pages[0] = tmp_page;
+	req->page_offset = 0;
+	req->end = fuse_writepage_end;
+	req->inode = inode;
+
+	spin_lock(&fc->lock);
+	list_add(&req->writepages_entry, &fi->writepages);
+	list_add_tail(&req->list, &fi->queued_writes);
+	fuse_flush_writepages(inode);
+	spin_unlock(&fc->lock);
+
+	fuse_clear_page_writeback(page);
+	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+
+	return 0;
+
+err_free:
+	fuse_request_free(req);
+err:
+	end_page_writeback(page);
+	return -ENOMEM;
+}
+
+static int fuse_writepage(struct page *page, struct writeback_control *wbc)
+{
+	int err;
+
+	err = fuse_writepage_locked(page);
+	unlock_page(page);
+
+	return err;
+}
+
+static int fuse_launder_page(struct page *page)
+{
+	int err = 0;
+	if (clear_page_dirty_for_io(page)) {
+		struct inode *inode = page->mapping->host;
+		err = fuse_writepage_locked(page);
+		if (!err)
+			fuse_wait_on_page_writeback(inode, page->index);
 	}
-	return generic_file_mmap(file, vma);
+	return err;
 }
 
-static int fuse_set_page_dirty(struct page *page)
+/*
+ * Write back dirty pages now, because there may not be any suitable
+ * open files later
+ */
+static void fuse_vma_close(struct vm_area_struct *vma)
+{
+	filemap_write_and_wait(vma->vm_file->f_mapping);
+}
+
+/*
+ * Wait for writeback against this page to complete before allowing it
+ * to be marked dirty again, and hence written back again, possibly
+ * before the previous writepage completed.
+ *
+ * Block here, instead of in ->writepage(), so that the userspace fs
+ * can only block processes actually operating on the filesystem.
+ *
+ * Otherwise unprivileged userspace fs would be able to block
+ * unrelated:
+ *
+ * - page migration
+ * - sync(2)
+ * - try_to_free_pages() with order > PAGE_ALLOC_COSTLY_ORDER
+ */
+static int fuse_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+{
+	/*
+	 * Don't use page->mapping as it may become NULL from a
+	 * concurrent truncate.
+	 */
+	struct inode *inode = vma->vm_file->f_mapping->host;
+
+	fuse_wait_on_page_writeback(inode, page->index);
+	return 0;
+}
+
+static struct vm_operations_struct fuse_file_vm_ops = {
+	.close		= fuse_vma_close,
+	.fault		= filemap_fault,
+	.page_mkwrite	= fuse_page_mkwrite,
+};
+
+static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
-	printk("fuse_set_page_dirty: should not happen\n");
-	dump_stack();
+	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE)) {
+		struct inode *inode = file->f_dentry->d_inode;
+		struct fuse_conn *fc = get_fuse_conn(inode);
+		struct fuse_inode *fi = get_fuse_inode(inode);
+		struct fuse_file *ff = file->private_data;
+		/*
+		 * file may be written through mmap, so chain it onto the
+		 * inodes's write_file list
+		 */
+		spin_lock(&fc->lock);
+		if (list_empty(&ff->write_entry))
+			list_add(&ff->write_entry, &fi->write_files);
+		spin_unlock(&fc->lock);
+	}
+	file_accessed(file);
+	vma->vm_ops = &fuse_file_vm_ops;
 	return 0;
 }
 
@@ -940,10 +1241,12 @@ static const struct file_operations fuse
 
 static const struct address_space_operations fuse_file_aops  = {
 	.readpage	= fuse_readpage,
+	.writepage	= fuse_writepage,
+	.launder_page	= fuse_launder_page,
 	.write_begin	= fuse_write_begin,
 	.write_end	= fuse_write_end,
 	.readpages	= fuse_readpages,
-	.set_page_dirty	= fuse_set_page_dirty,
+	.set_page_dirty	= __set_page_dirty_nobuffers,
 	.bmap		= fuse_bmap,
 };
 
Index: linux/fs/fuse/fuse_i.h
===================================================================
--- linux.orig/fs/fuse/fuse_i.h	2008-02-04 15:24:03.000000000 +0100
+++ linux/fs/fuse/fuse_i.h	2008-02-04 15:24:47.000000000 +0100
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/backing-dev.h>
 #include <linux/mutex.h>
+#include <linux/rwsem.h>
 
 /** Max number of pages that can be used in a single read request */
 #define FUSE_MAX_PAGES_PER_REQ 32
@@ -25,6 +26,9 @@
 /** Congestion starts at 75% of maximum */
 #define FUSE_CONGESTION_THRESHOLD (FUSE_MAX_BACKGROUND * 75 / 100)
 
+/** Bias for fi->writectr, meaning new writepages must not be sent */
+#define FUSE_NOWRITE INT_MIN
+
 /** It could be as large as PATH_MAX, but would that have any uses? */
 #define FUSE_NAME_MAX 1024
 
@@ -73,6 +77,19 @@ struct fuse_inode {
 
 	/** Files usable in writepage.  Protected by fc->lock */
 	struct list_head write_files;
+
+	/** Writepages pending on truncate or fsync */
+	struct list_head queued_writes;
+
+	/** Number of sent writes, a negative bias (FUSE_NOWRITE)
+	 * means more writes are blocked */
+	int writectr;
+
+	/** Waitq for writepage completion */
+	wait_queue_head_t page_waitq;
+
+	/** List of writepage requestst (pending or sent) */
+	struct list_head writepages;
 };
 
 /** FUSE specific file data */
@@ -242,6 +259,12 @@ struct fuse_req {
 	/** File used in the request (or NULL) */
 	struct fuse_file *ff;
 
+	/** Inode used in the request or NULL */
+	struct inode *inode;
+
+	/** Link on fi->writepages */
+	struct list_head writepages_entry;
+
 	/** Request completion callback */
 	void (*end)(struct fuse_conn *, struct fuse_req *);
 
@@ -504,6 +527,11 @@ void fuse_init_symlink(struct inode *ino
 void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
 			    u64 attr_valid, u64 attr_version);
 
+void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
+				   u64 attr_valid);
+
+void fuse_truncate(struct address_space *mapping, loff_t offset);
+
 /**
  * Initialize the client device
  */
@@ -522,6 +550,8 @@ void fuse_ctl_cleanup(void);
  */
 struct fuse_req *fuse_request_alloc(void);
 
+struct fuse_req *fuse_request_alloc_nofs(void);
+
 /**
  * Free a request
  */
@@ -558,6 +588,8 @@ void request_send_noreply(struct fuse_co
  */
 void request_send_background(struct fuse_conn *fc, struct fuse_req *req);
 
+void request_send_background_locked(struct fuse_conn *fc, struct fuse_req *req);
+
 /* Abort all requests */
 void fuse_abort_conn(struct fuse_conn *fc);
 
@@ -600,3 +632,8 @@ u64 fuse_lock_owner_id(struct fuse_conn 
 
 int fuse_update_attributes(struct inode *inode, struct kstat *stat,
 			   struct file *file, bool *refreshed);
+
+void fuse_flush_writepages(struct inode *inode);
+
+void fuse_set_nowrite(struct inode *inode);
+void fuse_release_nowrite(struct inode *inode);
Index: linux/fs/fuse/inode.c
===================================================================
--- linux.orig/fs/fuse/inode.c	2008-02-04 15:24:03.000000000 +0100
+++ linux/fs/fuse/inode.c	2008-02-04 15:24:47.000000000 +0100
@@ -59,7 +59,11 @@ static struct inode *fuse_alloc_inode(st
 	fi->nodeid = 0;
 	fi->nlookup = 0;
 	fi->attr_version = 0;
+	fi->writectr = 0;
 	INIT_LIST_HEAD(&fi->write_files);
+	INIT_LIST_HEAD(&fi->queued_writes);
+	INIT_LIST_HEAD(&fi->writepages);
+	init_waitqueue_head(&fi->page_waitq);
 	fi->forget_req = fuse_request_alloc();
 	if (!fi->forget_req) {
 		kmem_cache_free(fuse_inode_cachep, inode);
@@ -73,6 +77,7 @@ static void fuse_destroy_inode(struct in
 {
 	struct fuse_inode *fi = get_fuse_inode(inode);
 	BUG_ON(!list_empty(&fi->write_files));
+	BUG_ON(!list_empty(&fi->queued_writes));
 	if (fi->forget_req)
 		fuse_request_free(fi->forget_req);
 	kmem_cache_free(fuse_inode_cachep, inode);
@@ -109,7 +114,7 @@ static int fuse_remount_fs(struct super_
 	return 0;
 }
 
-static void fuse_truncate(struct address_space *mapping, loff_t offset)
+void fuse_truncate(struct address_space *mapping, loff_t offset)
 {
 	/* See vmtruncate() */
 	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
@@ -117,19 +122,12 @@ static void fuse_truncate(struct address
 	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
 }
 
-
-void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
-			    u64 attr_valid, u64 attr_version)
+void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
+				   u64 attr_valid)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_inode *fi = get_fuse_inode(inode);
-	loff_t oldsize;
 
-	spin_lock(&fc->lock);
-	if (attr_version != 0 && fi->attr_version > attr_version) {
-		spin_unlock(&fc->lock);
-		return;
-	}
 	fi->attr_version = ++fc->attr_version;
 	fi->i_time = attr_valid;
 
@@ -159,6 +157,22 @@ void fuse_change_attributes(struct inode
 	fi->orig_i_mode = inode->i_mode;
 	if (!(fc->flags & FUSE_DEFAULT_PERMISSIONS))
 		inode->i_mode &= ~S_ISVTX;
+}
+
+void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
+			    u64 attr_valid, u64 attr_version)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	loff_t oldsize;
+
+	spin_lock(&fc->lock);
+	if (attr_version != 0 && fi->attr_version > attr_version) {
+		spin_unlock(&fc->lock);
+		return;
+	}
+
+	fuse_change_attributes_common(inode, attr, attr_valid);
 
 	oldsize = inode->i_size;
 	i_size_write(inode, attr->size);
@@ -476,6 +490,19 @@ static struct fuse_conn *new_conn(struct
 		err = bdi_register_dev(&fc->bdi, fc->dev);
 		if (err)
 			goto error_bdi_destroy;
+		/*
+		 * For a single fuse filesystem use max 1% of dirty +
+		 * writeback threshold.
+		 *
+		 * This gives about 1M of write buffer for memory maps on a
+		 * machine with 1G and 10% dirty_ratio, which should be more
+		 * than enough.
+		 *
+		 * Privileged users can raise it by writing to
+		 *
+		 *    /sys/class/bdi/<bdi>/max_ratio
+		 */
+		bdi_set_max_ratio(&fc->bdi, 1);
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		fc->attr_version = 1;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
