Subject: [RFC] fuse writable mmap design
Message-Id: <E1IshIR-0000fE-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 15 Nov 2007 17:10:27 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Writable shared memory mappings for fuse are something I've been
trying to implement forever.

Now hopefully I've got it all worked out, it survives indefinitely
with bash-shared-mapping and fsx-linux.  And I'd like to solicit
comments about the approach.

I'm not asking for comments on the patch itself.  It needs to be
cleaned and split up.  It's only included for reference.

Thanks,
Miklos



Fuse page writeback design
--------------------------

fuse_writepage() allocates a new temporary page with
GFP_NOFS|__GFP_HIGHMEM.  It copies the contents of the original page,
and queues a WRITE request to the userspace filesystem using this temp
page.

>From the VM's point of view, the writeback is finished instantly: the
page is removed from the radix trees, and the PageDirty and
PageWriteback flags are cleared.

The per-bdi writeback count is not decremented until the writeback
truly completes.  And there's a new 'nr_writeback_temp' counter, that
is used to track the global count of these writebacks instead of the
per-zone NR_WRITEBACK (it could be a new per-zone counter in vm_stat,
but for simplicity, current code just uses a single atomic counter).

If the writeout was due to memory pressure, in effect this migrates
data from a full zone to a less full zone.

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
---

Index: linux-2.6.24-rc2/fs/fuse/dev.c
===================================================================
--- linux-2.6.24-rc2.orig/fs/fuse/dev.c	2007-11-14 20:23:50.000000000 +0100
+++ linux-2.6.24-rc2/fs/fuse/dev.c	2007-11-14 20:23:50.000000000 +0100
@@ -47,6 +47,14 @@ struct fuse_req *fuse_request_alloc(void
 	return req;
 }
 
+struct fuse_req *fuse_request_alloc_nofs(void)
+{
+	struct fuse_req *req = kmem_cache_alloc(fuse_req_cachep, GFP_NOFS);
+ 	if (req)
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
Index: linux-2.6.24-rc2/fs/fuse/dir.c
===================================================================
--- linux-2.6.24-rc2.orig/fs/fuse/dir.c	2007-11-14 20:23:50.000000000 +0100
+++ linux-2.6.24-rc2/fs/fuse/dir.c	2007-11-14 20:23:50.000000000 +0100
@@ -1109,9 +1109,12 @@ static int fuse_do_setattr(struct dentry
 {
 	struct inode *inode = entry->d_inode;
 	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
 	struct fuse_req *req;
 	struct fuse_setattr_in inarg;
 	struct fuse_attr_out outarg;
+	bool is_truncate = false;
+	loff_t oldsize;
 	int err;
 
 	if (!fuse_allow_task(fc, current))
@@ -1135,12 +1138,21 @@ static int fuse_do_setattr(struct dentry
 			send_sig(SIGXFSZ, current, 0);
 			return -EFBIG;
 		}
+		is_truncate = true;
 	}
 
 	req = fuse_get_req(fc);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
+	if (is_truncate) {
+		spin_lock(&fc->lock);
+		BUG_ON(fi->writectr < 0);
+		fi->writectr += FUSE_NOWRITE;
+		spin_unlock(&fc->lock);
+		wait_event(fi->page_waitq, fi->writectr == FUSE_NOWRITE);
+	}
+
 	memset(&inarg, 0, sizeof(inarg));
 	memset(&outarg, 0, sizeof(outarg));
 	iattr_to_fattr(attr, &inarg);
@@ -1179,7 +1191,29 @@ static int fuse_do_setattr(struct dentry
 		return -EIO;
 	}
 
-	fuse_change_attributes(inode, &outarg.attr, attr_timeout(&outarg), 0);
+	spin_lock(&fc->lock);
+	fuse_change_attributes_common(inode, &outarg.attr,
+				      attr_timeout(&outarg));
+	oldsize = inode->i_size;
+	i_size_write(inode, outarg.attr.size);
+
+	if (is_truncate) {
+		BUG_ON(fi->writectr != FUSE_NOWRITE);
+		fi->writectr = 0;
+		fuse_flush_writepages(inode);
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
+	}
+
 	return 0;
 }
 
Index: linux-2.6.24-rc2/fs/fuse/file.c
===================================================================
--- linux-2.6.24-rc2.orig/fs/fuse/file.c	2007-11-14 20:23:50.000000000 +0100
+++ linux-2.6.24-rc2/fs/fuse/file.c	2007-11-14 22:12:55.000000000 +0100
@@ -210,6 +210,51 @@ u64 fuse_lock_owner_id(struct fuse_conn 
 	return (u64) v0 + ((u64) v1 << 32);
 }
 
+/*
+ * Check if page is under writeback
+ *
+ * This is currently done by walking the list of writepage requests
+ * for the inode, which can be pretty inefficient.
+ */
+static bool fuse_page_is_writeback(struct page *page)
+{
+	struct inode *inode = page->mapping->host;
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
+		if (curr_index == page->index) {
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
+static int fuse_wait_on_page_writeback(struct page *page)
+{
+	struct inode *inode = page->mapping->host;
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	wait_event(fi->page_waitq, !fuse_page_is_writeback(page));
+	return 0;
+}
+
 static int fuse_flush(struct file *file, fl_owner_t id)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
@@ -245,6 +290,32 @@ static int fuse_flush(struct file *file,
 	return err;
 }
 
+/*
+ * Wait for all pending writepages on the inode to finish.
+ *
+ * This is currently done by blocking further writes with FUSE_NOWRITE
+ * and waiting for all sent writes to complete.
+ *
+ * This must be called under i_mutex, otherwise the FUSE_NOWRITE usage
+ * could conflict with truncatation.
+ */
+static void fuse_sync_writes(struct inode *inode)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	spin_lock(&fc->lock);
+	BUG_ON(fi->writectr < 0);
+	fi->writectr += FUSE_NOWRITE;
+	spin_unlock(&fc->lock);
+
+	wait_event(fi->page_waitq, fi->writectr == FUSE_NOWRITE);
+
+	spin_lock(&fc->lock);
+	fi->writectr = 0;
+	spin_unlock(&fc->lock);
+}
+
 int fuse_fsync_common(struct file *file, struct dentry *de, int datasync,
 		      int isdir)
 {
@@ -261,6 +332,17 @@ int fuse_fsync_common(struct file *file,
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
@@ -340,6 +422,13 @@ static int fuse_readpage(struct file *fi
 	if (is_bad_inode(inode))
 		goto out;
 
+	/*
+	 * Page writeback can extend beyond the liftime of the
+	 * page-cache page, so make sure we read a properly synced
+	 * page.
+	 */
+	fuse_wait_on_page_writeback(page);
+
 	req = fuse_get_req(fc);
 	err = PTR_ERR(req);
 	if (IS_ERR(req))
@@ -411,6 +500,8 @@ static int fuse_readpages_fill(void *_da
 	struct inode *inode = data->inode;
 	struct fuse_conn *fc = get_fuse_conn(inode);
 
+	fuse_wait_on_page_writeback(page);
+
 	if (req->num_pages &&
 	    (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
 	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_read ||
@@ -477,11 +568,10 @@ static ssize_t fuse_file_aio_read(struct
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
 
@@ -490,7 +580,7 @@ static void fuse_write_fill(struct fuse_
 	inarg->offset = pos;
 	inarg->size = count;
 	inarg->write_flags = writepage ? FUSE_WRITE_CACHE : 0;
-	inarg->flags = file->f_flags;
+	inarg->flags = file ? file->f_flags : 0;
 	req->in.h.opcode = FUSE_WRITE;
 	req->in.h.nodeid = get_node_id(inode);
 	req->in.argpages = 1;
@@ -511,7 +601,7 @@ static size_t fuse_send_write(struct fus
 			      fl_owner_t owner)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
-	fuse_write_fill(req, file, inode, pos, count, 0);
+	fuse_write_fill(req, file, file->private_data, inode, pos, count, 0);
 	if (owner != NULL) {
 		struct fuse_write_in *inarg = &req->misc.write.in;
 		inarg->write_flags |= FUSE_WRITE_LOCKOWNER;
@@ -546,6 +636,12 @@ static int fuse_buffered_write(struct fi
 	if (is_bad_inode(inode))
 		return -EIO;
 
+	/*
+	 * Make sure writepages on the same page are not mixed up with
+	 * plain writes.
+	 */
+	fuse_wait_on_page_writeback(page);
+
 	req = fuse_get_req(fc);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
@@ -716,21 +812,243 @@ static ssize_t fuse_direct_write(struct 
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
+	fc->numwrite--;
+	dec_bdi_stat(bdi, BDI_WRITEBACK);
+	atomic_long_dec(&nr_writeback_temp);
+	bdi_writeout_inc(bdi);
+	wake_up(&fi->page_waitq);
+	wake_up(&fc->writeback_waitq);
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
 	}
-	return generic_file_mmap(file, vma);
 }
 
-static int fuse_set_page_dirty(struct page *page)
+static void fuse_writepage_end(struct fuse_conn *fc, struct fuse_req *req)
 {
-	printk("fuse_set_page_dirty: should not happen\n");
-	dump_stack();
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
+	fc->numwrite++;
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
+	atomic_long_inc(&nr_writeback_temp);
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
+		err = fuse_writepage_locked(page);
+		if (!err)
+			fuse_wait_on_page_writeback(page);
+	}
+	return err;
+}
+
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
+ *
+ * Also make sure, that we don't allow new dirtyings if there are too
+ * many writepages pending for this filesystem.
+ */
+static int fuse_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+{
+	struct fuse_conn *fc = get_fuse_conn(page->mapping->host);
+
+	fuse_wait_on_page_writeback(page);
+	wait_event(fc->writeback_waitq,
+		   fc->numwrite < FUSE_WRITEBACK_THRESHOLD);
+
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
+{
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
 
@@ -940,10 +1258,12 @@ static const struct file_operations fuse
 
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
 
Index: linux-2.6.24-rc2/fs/fuse/fuse_i.h
===================================================================
--- linux-2.6.24-rc2.orig/fs/fuse/fuse_i.h	2007-11-14 20:23:50.000000000 +0100
+++ linux-2.6.24-rc2/fs/fuse/fuse_i.h	2007-11-14 20:23:50.000000000 +0100
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/backing-dev.h>
 #include <linux/mutex.h>
+#include <linux/rwsem.h>
 
 /** Max number of pages that can be used in a single read request */
 #define FUSE_MAX_PAGES_PER_REQ 32
@@ -25,6 +26,13 @@
 /** Congestion starts at 75% of maximum */
 #define FUSE_CONGESTION_THRESHOLD (FUSE_MAX_BACKGROUND * 75 / 100)
 
+/** Block page page dirtying if the number of writepages for this
+    filesystem is above this threshold */
+#define FUSE_WRITEBACK_THRESHOLD 32
+
+/** Bias for fi->writectr, meaning new writepages must not be sent */
+#define FUSE_NOWRITE INT_MIN
+
 /** It could be as large as PATH_MAX, but would that have any uses? */
 #define FUSE_NAME_MAX 1024
 
@@ -73,6 +81,19 @@ struct fuse_inode {
 
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
@@ -242,6 +263,12 @@ struct fuse_req {
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
 
@@ -410,6 +437,12 @@ struct fuse_conn {
 
 	/** Version counter for attribute changes */
 	u64 attr_version;
+
+	/** Total number of pending writepage requests for this fs */
+	int numwrite;
+
+	/** Waitq for writepage completion */
+	wait_queue_head_t writeback_waitq;
 };
 
 static inline struct fuse_conn *get_fuse_conn_super(struct super_block *sb)
@@ -504,6 +537,11 @@ void fuse_init_symlink(struct inode *ino
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
@@ -522,6 +560,8 @@ void fuse_ctl_cleanup(void);
  */
 struct fuse_req *fuse_request_alloc(void);
 
+struct fuse_req *fuse_request_alloc_nofs(void);
+
 /**
  * Free a request
  */
@@ -558,6 +598,8 @@ void request_send_noreply(struct fuse_co
  */
 void request_send_background(struct fuse_conn *fc, struct fuse_req *req);
 
+void request_send_background_locked(struct fuse_conn *fc, struct fuse_req *req);
+
 /* Abort all requests */
 void fuse_abort_conn(struct fuse_conn *fc);
 
@@ -600,3 +642,5 @@ u64 fuse_lock_owner_id(struct fuse_conn 
 
 int fuse_update_attributes(struct inode *inode, struct kstat *stat,
 			   struct file *file, bool *refreshed);
+
+void fuse_flush_writepages(struct inode *inode);
Index: linux-2.6.24-rc2/fs/fuse/inode.c
===================================================================
--- linux-2.6.24-rc2.orig/fs/fuse/inode.c	2007-11-14 20:23:50.000000000 +0100
+++ linux-2.6.24-rc2/fs/fuse/inode.c	2007-11-14 20:23:50.000000000 +0100
@@ -57,7 +57,11 @@ static struct inode *fuse_alloc_inode(st
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
@@ -71,6 +75,7 @@ static void fuse_destroy_inode(struct in
 {
 	struct fuse_inode *fi = get_fuse_inode(inode);
 	BUG_ON(!list_empty(&fi->write_files));
+	BUG_ON(!list_empty(&fi->queued_writes));
 	if (fi->forget_req)
 		fuse_request_free(fi->forget_req);
 	kmem_cache_free(fuse_inode_cachep, inode);
@@ -112,7 +117,7 @@ static int fuse_remount_fs(struct super_
 	return 0;
 }
 
-static void fuse_truncate(struct address_space *mapping, loff_t offset)
+void fuse_truncate(struct address_space *mapping, loff_t offset)
 {
 	/* See vmtruncate() */
 	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
@@ -120,19 +125,12 @@ static void fuse_truncate(struct address
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
 
@@ -162,6 +160,22 @@ void fuse_change_attributes(struct inode
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
@@ -461,6 +475,7 @@ static struct fuse_conn *new_conn(void)
 		init_waitqueue_head(&fc->waitq);
 		init_waitqueue_head(&fc->blocked_waitq);
 		init_waitqueue_head(&fc->reserved_req_waitq);
+		init_waitqueue_head(&fc->writeback_waitq);
 		INIT_LIST_HEAD(&fc->pending);
 		INIT_LIST_HEAD(&fc->processing);
 		INIT_LIST_HEAD(&fc->io);
Index: linux-2.6.24-rc2/include/linux/backing-dev.h
===================================================================
--- linux-2.6.24-rc2.orig/include/linux/backing-dev.h	2007-11-14 20:22:50.000000000 +0100
+++ linux-2.6.24-rc2/include/linux/backing-dev.h	2007-11-14 20:23:50.000000000 +0100
@@ -128,6 +128,8 @@ static inline unsigned long bdi_stat_err
 #endif
 }
 
+extern void bdi_writeout_inc(struct backing_dev_info *bdi);
+
 /*
  * Flags in backing_dev_info::capability
  * - The first two flags control whether dirty pages will contribute to the
Index: linux-2.6.24-rc2/mm/page-writeback.c
===================================================================
--- linux-2.6.24-rc2.orig/mm/page-writeback.c	2007-11-14 20:22:50.000000000 +0100
+++ linux-2.6.24-rc2/mm/page-writeback.c	2007-11-14 22:13:15.000000000 +0100
@@ -98,6 +98,11 @@ EXPORT_SYMBOL(laptop_mode);
 
 /* End of sysctl-exported parameters */
 
+/*
+ * Number of pages being written back using temp buffers (used by FUSE)
+ */
+atomic_long_t nr_writeback_temp;
+EXPORT_SYMBOL(nr_writeback_temp);
 
 static void background_writeout(unsigned long _min_pages);
 
@@ -161,6 +166,16 @@ static inline void __bdi_writeout_inc(st
 	__prop_inc_percpu(&vm_completions, &bdi->completions);
 }
 
+void bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__bdi_writeout_inc(bdi);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(bdi_writeout_inc);
+
 static inline void task_dirty_inc(struct task_struct *tsk)
 {
 	prop_inc_single(&vm_dirties, &tsk->dirties);
@@ -194,7 +209,8 @@ clip_bdi_dirty_limit(struct backing_dev_
 	avail_dirty = dirty -
 		(global_page_state(NR_FILE_DIRTY) +
 		 global_page_state(NR_WRITEBACK) +
-		 global_page_state(NR_UNSTABLE_NFS));
+		 global_page_state(NR_UNSTABLE_NFS) +
+		 atomic_long_read(&nr_writeback_temp));
 
 	if (avail_dirty < 0)
 		avail_dirty = 0;
Index: linux-2.6.24-rc2/include/linux/vmstat.h
===================================================================
--- linux-2.6.24-rc2.orig/include/linux/vmstat.h	2007-11-14 20:22:50.000000000 +0100
+++ linux-2.6.24-rc2/include/linux/vmstat.h	2007-11-14 22:13:24.000000000 +0100
@@ -116,6 +116,8 @@ static inline void vm_events_fold_cpu(in
 		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
 		zone_idx(zone), delta)
 
+extern atomic_long_t nr_writeback_temp;
+
 /*
  * Zone based page accounting with per cpu differentials.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
