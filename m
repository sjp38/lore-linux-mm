Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18A2844043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:43 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u51so42454109qte.15
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p197si2715399qke.76.2017.06.16.12.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:41 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 11/22] fs: new infrastructure for writeback error handling and reporting
Date: Fri, 16 Jun 2017 15:34:16 -0400
Message-Id: <20170616193427.13955-12-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Most filesystems currently use mapping_set_error and
filemap_check_errors for setting and reporting/clearing writeback errors
at the mapping level. filemap_check_errors is indirectly called from
most of the filemap_fdatawait_* functions and from
filemap_write_and_wait*. These functions are called from all sorts of
contexts to wait on writeback to finish -- e.g. mostly in fsync, but
also in truncate calls, getattr, etc.

The non-fsync callers are problematic. We should be reporting writeback
errors during fsync, but many places spread over the tree clear out
errors before they can be properly reported, or report errors at
nonsensical times.

If I get -EIO on a stat() call, there is no reason for me to assume that
it is because some previous writeback failed. The fact that it also
clears out the error such that a subsequent fsync returns 0 is a bug,
and a nasty one since that's potentially silent data corruption.

This patch adds a small bit of new infrastructure for setting and
reporting errors during address_space writeback. While the above was my
original impetus for adding this, I think it's also the case that
current fsync semantics are just problematic for userland. Most
applications that call fsync do so to ensure that the data they wrote
has hit the backing store.

In the case where there are multiple writers to the file at the same
time, this is really hard to determine. The first one to call fsync will
see any stored error, and the rest get back 0. The processes with open
fds may not be associated with one another in any way. They could even
be in different containers, so ensuring coordination between all fsync
callers is not really an option.

One way to remedy this would be to track what file descriptor was used
to dirty the file, but that's rather cumbersome and would likely be
slow. However, there is a simpler way to improve the semantics here
without incurring too much overhead.

This set adds an errseq_t to struct address_space, and a corresponding
one is added to struct file. Writeback errors are recorded in the
mapping's errseq_t, and the one in struct file is used as the "since"
value.

This changes the semantics of the Linux fsync implementation such that
applications can now use it to determine whether there were any
writeback errors since fsync(fd) was last called (or since the file was
opened in the case of fsync having never been called).

Note that those writeback errors may have occurred when writing data
that was dirtied via an entirely different fd, but that's the case now
with the current mapping_set_error/filemap_check_error infrastructure.
This will at least prevent you from getting a false report of success.

The new behavior is still consistent with the POSIX spec, and is more
reliable for application developers. This patch just adds some basic
infrastructure for doing this, and ensures that the f_wb_err "cursor"
is properly set when a file is opened. Later patches will change the
existing code to use this new infrastructure for reporting errors at
fsync time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 drivers/dax/device.c |  1 +
 fs/block_dev.c       |  1 +
 fs/file_table.c      |  1 +
 fs/open.c            |  3 +++
 include/linux/fs.h   | 53 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c         | 38 +++++++++++++++++++++++++++++++++++++
 6 files changed, 97 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 006e657dfcb9..12943d19bfc4 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -499,6 +499,7 @@ static int dax_open(struct inode *inode, struct file *filp)
 	inode->i_mapping = __dax_inode->i_mapping;
 	inode->i_mapping->host = __dax_inode;
 	filp->f_mapping = inode->i_mapping;
+	filp->f_wb_err = filemap_sample_wb_err(filp->f_mapping);
 	filp->private_data = dev_dax;
 	inode->i_flags = S_DAX;
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index bcd8e16a34e1..dc839f8f0ba5 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1746,6 +1746,7 @@ static int blkdev_open(struct inode * inode, struct file * filp)
 		return -ENOMEM;
 
 	filp->f_mapping = bdev->bd_inode->i_mapping;
+	filp->f_wb_err = filemap_sample_wb_err(filp->f_mapping);
 
 	return blkdev_get(bdev, filp->f_mode, filp);
 }
diff --git a/fs/file_table.c b/fs/file_table.c
index 954d510b765a..72e861a35a7f 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -168,6 +168,7 @@ struct file *alloc_file(const struct path *path, fmode_t mode,
 	file->f_path = *path;
 	file->f_inode = path->dentry->d_inode;
 	file->f_mapping = path->dentry->d_inode->i_mapping;
+	file->f_wb_err = filemap_sample_wb_err(file->f_mapping);
 	if ((mode & FMODE_READ) &&
 	     likely(fop->read || fop->read_iter))
 		mode |= FMODE_CAN_READ;
diff --git a/fs/open.c b/fs/open.c
index cd0c5be8d012..280d4a963791 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -707,6 +707,9 @@ static int do_dentry_open(struct file *f,
 	f->f_inode = inode;
 	f->f_mapping = inode->i_mapping;
 
+	/* Ensure that we skip any errors that predate opening of the file */
+	f->f_wb_err = filemap_sample_wb_err(f->f_mapping);
+
 	if (unlikely(f->f_flags & O_PATH)) {
 		f->f_mode = FMODE_PATH;
 		f->f_op = &empty_fops;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1b1233a1db1e..09d511771b25 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -31,6 +31,7 @@
 #include <linux/workqueue.h>
 #include <linux/delayed_call.h>
 #include <linux/uuid.h>
+#include <linux/errseq.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -393,6 +394,7 @@ struct address_space {
 	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
+	errseq_t		wb_err;
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -847,6 +849,7 @@ struct file {
 	 * Must not be taken from IRQ context.
 	 */
 	spinlock_t		f_lock;
+	errseq_t		f_wb_err;
 	atomic_long_t		f_count;
 	unsigned int 		f_flags;
 	fmode_t			f_mode;
@@ -2521,6 +2524,56 @@ extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
 extern int filemap_check_errors(struct address_space *mapping);
 
+extern int __must_check filemap_report_wb_err(struct file *file);
+
+/**
+ * filemap_set_wb_err - set a writeback error on an address_space
+ * @mapping: mapping in which to set writeback error
+ * @err: error to be set in mapping
+ *
+ * When writeback fails in some way, we must record that error so that
+ * userspace can be informed when fsync and the like are called.  We endeavor
+ * to report errors on any file that was open at the time of the error.  Some
+ * internal callers also need to know when writeback errors have occurred.
+ *
+ * When a writeback error occurs, most filesystems will want to call
+ * filemap_set_wb_err to record the error in the mapping so that it will be
+ * automatically reported whenever fsync is called on the file.
+ *
+ * FIXME: mention FS_* flag here?
+ */
+static inline void filemap_set_wb_err(struct address_space *mapping, int err)
+{
+	errseq_set(&mapping->wb_err, err);
+}
+
+/**
+ * filemap_check_wb_error - has an error occurred since the mark was sampled?
+ * @mapping: mapping to check for writeback errors
+ * @since: previously-sampled errseq_t
+ *
+ * Grab the errseq_t value from the mapping, and see if it has changed "since"
+ * the given value was sampled.
+ *
+ * If it has then report the latest error set, otherwise return 0.
+ */
+static inline int filemap_check_wb_err(struct address_space *mapping, errseq_t since)
+{
+	return errseq_check(&mapping->wb_err, since);
+}
+
+/**
+ * filemap_sample_wb_err - sample the current errseq_t to test for later errors
+ * @mapping: mapping to be sampled
+ *
+ * Writeback errors are always reported relative to a particular sample point
+ * in the past. This function provides those sample points.
+ */
+static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
+{
+	return errseq_sample(&mapping->wb_err);
+}
+
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
 extern int vfs_fsync(struct file *file, int datasync);
diff --git a/mm/filemap.c b/mm/filemap.c
index 21e65c6ef1a0..2803b30cbb5d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -556,6 +556,44 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
 /**
+ * filemap_report_wb_err - report wb error (if any) that was previously set
+ * @file: struct file on which the error is being reported
+ *
+ * When userland calls fsync (or something like nfsd does the equivalent), we
+ * want to report any writeback errors that occurred since the last fsync (or
+ * since the file was opened if there haven't been any).
+ *
+ * Grab the wb_err from the mapping. If it matches what we have in the file,
+ * then just quickly return 0. The file is all caught up.
+ *
+ * If it doesn't match, then take the mapping value, set the "seen" flag in
+ * it and try to swap it into place. If it works, or another task beat us
+ * to it with the new value, then update the f_wb_err and return the error
+ * portion. The error at this point must be reported via proper channels
+ * (a'la fsync, or NFS COMMIT operation, etc.).
+ *
+ * While we handle mapping->wb_err with atomic operations, the f_wb_err
+ * value is protected by the f_lock since we must ensure that it reflects
+ * the latest value swapped in for this file descriptor.
+ */
+int filemap_report_wb_err(struct file *file)
+{
+	int err = 0;
+	struct address_space *mapping = file->f_mapping;
+
+	/* Locklessly handle the common case where nothing has changed */
+	if (errseq_check(&mapping->wb_err, READ_ONCE(file->f_wb_err))) {
+		/* Something changed, must use slow path */
+		spin_lock(&file->f_lock);
+		err = errseq_check_and_advance(&mapping->wb_err,
+						&file->f_wb_err);
+		spin_unlock(&file->f_lock);
+	}
+	return err;
+}
+EXPORT_SYMBOL(filemap_report_wb_err);
+
+/**
  * replace_page_cache_page - replace a pagecache page with a new one
  * @old:	page to be replaced
  * @new:	page to replace with
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
