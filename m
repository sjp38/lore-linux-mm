Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2D976B037E
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:20 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k1so40439797qtb.20
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z14si18021491qtb.78.2017.04.24.06.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:19 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 13/20] fs: new infrastructure for writeback error handling and reporting
Date: Mon, 24 Apr 2017 09:22:52 -0400
Message-Id: <20170424132259.8680-14-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

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
infrastructure for doing this. Later patches will change the existing
code to use this new infrastructure.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/vfs.txt | 10 +++++++++-
 fs/open.c                         |  3 +++
 include/linux/fs.h                | 24 ++++++++++++++++++++++++
 mm/filemap.c                      | 38 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 94dd27ef4a76..ed06fb39822b 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -576,6 +576,11 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
 written at any point after PG_Dirty is clear.  Once it is known to be
 safe, PG_Writeback is cleared.
 
+If there is an error during writeback, then the address_space should be
+marked with an error (typically using filemap_set_wb_error), in order to
+ensure that the error can later be reported to the application when an
+fsync is issued.
+
 Writeback makes use of a writeback_control structure...
 
 struct address_space_operations
@@ -888,7 +893,10 @@ otherwise noted.
 
   release: called when the last reference to an open file is closed
 
-  fsync: called by the fsync(2) system call
+  fsync: called by the fsync(2) system call. Filesystems that use the
+	pagecache should call filemap_report_wb_error before returning
+	to ensure that any errors that occurred during writeback are
+	reported and the file's error sequence advanced.
 
   fasync: called by the fcntl(2) system call when asynchronous
 	(non-blocking) mode is enabled for a file
diff --git a/fs/open.c b/fs/open.c
index 949cef29c3bb..88bfed8d3c88 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -709,6 +709,9 @@ static int do_dentry_open(struct file *f,
 	f->f_inode = inode;
 	f->f_mapping = inode->i_mapping;
 
+	/* Ensure that we skip any errors that predate opening of the file */
+	f->f_wb_err = filemap_sample_wb_error(f->f_mapping);
+
 	if (unlikely(f->f_flags & O_PATH)) {
 		f->f_mode = FMODE_PATH;
 		f->f_op = &empty_fops;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7251f7bb45e8..69a89f667c7f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -31,6 +31,7 @@
 #include <linux/workqueue.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/delayed_call.h>
+#include <linux/errseq.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -394,6 +395,7 @@ struct address_space {
 	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
+	errseq_t		wb_err;
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -846,6 +848,7 @@ struct file {
 	 * Must not be taken from IRQ context.
 	 */
 	spinlock_t		f_lock;
+	errseq_t		f_wb_err;
 	atomic_long_t		f_count;
 	unsigned int 		f_flags;
 	fmode_t			f_mode;
@@ -2521,6 +2524,27 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
 extern int filemap_check_errors(struct address_space *mapping);
+extern int __must_check filemap_report_wb_error(struct file *file);
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
+static inline int filemap_check_wb_error(struct address_space *mapping, errseq_t since)
+{
+	return errseq_check(&mapping->wb_err, since);
+}
+
+static inline errseq_t filemap_sample_wb_error(struct address_space *mapping)
+{
+	return errseq_sample(&mapping->wb_err);
+}
 
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
diff --git a/mm/filemap.c b/mm/filemap.c
index 1694623a6289..ee1a798acfc1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -546,6 +546,44 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
 /**
+ * filemap_report_wb_error - report wb error (if any) that was previously set
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
+int filemap_report_wb_error(struct file *file)
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
+EXPORT_SYMBOL(filemap_report_wb_error);
+
+/**
  * replace_page_cache_page - replace a pagecache page with a new one
  * @old:	page to be replaced
  * @new:	page to replace with
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
