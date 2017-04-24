Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 290F16B0388
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:23 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o36so40489839qtb.2
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 125si18027739qki.263.2017.04.24.06.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:21 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 14/20] fs: retrofit old error reporting API onto new infrastructure
Date: Mon, 24 Apr 2017 09:22:53 -0400
Message-Id: <20170424132259.8680-15-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

Now that we have a better way to store and report errors that occur
during writeback, we need to convert the existing codebase to use it. We
could just adapt all of the filesystem code and related infrastructure
to the new API, but that's a lot of churn.

When it comes to setting errors in the mapping, filemap_set_wb_error is
a drop-in replacement for mapping_set_error. Turn that function into a
simple wrapper around the new one.

Because we want to ensure that writeback errors are always reported at
fsync time, inject filemap_report_wb_error calls much closer to the
syscall boundary, in call_fsync.

For fsync calls (and things like the nfsd equivalent), we either return
the error that the fsync operation returns, or the one returned by
filemap_report_wb_error. In both cases, we advance the file->f_wb_err to
the latest value. This allows us to provide new fsync semantics that
will return errors that may have occurred previously and been viewed
via other file descriptors.

The final piece of the puzzle is what to do about filemap_check_errors
calls that are being called directly or via filemap_* functions. Here,
we must take a little "creative license".

Since we now handle advancing the file->f_wb_err value at the generic
filesystem layer, we no longer need those callers to clear errors out
of the mapping or advance an errseq_t.

A lot of the existing codebase relies on being getting an error back
from those functions when there is a writeback problem, so we do still
want to have them report writeback errors somehow.

When reporting writeback errors, we will always report errors that have
occurred since a particular point in time. With the old writeback error
reporting, the time we used was "since it was last tested/cleared" which
is entirely arbitrary and potentially racy. Now, we can at least report
the latest error that has occurred since an arbitrary point in time
(represented as a sampled errseq_t value).

In the case where we don't have a struct file to work with, this patch
just has the wrappers sample the current mapping->wb_err value, and use
that as an arbitrary point from which to check for errors.

That's probably not "correct" in all cases, particularly in the case of
something like filemap_fdatawait, but I'm not sure it's any worse than
what we already have, and this gives us a basis from which to work.

A lot of those callers will likely want to change to a model where they
sample the errseq_t much earlier (perhaps when starting a transaction),
store it in an appropriate place and then use that value later when
checking to see if an error occurred.

That will almost certainly take some involvement from other subsystem
maintainers. I'm quite open to adding new API functions to help enable
this if that would be helpful, but I don't really want to do that until
I better understand what's needed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/vfs.txt |  9 ++++-----
 fs/btrfs/file.c                   | 10 ++--------
 fs/btrfs/tree-log.c               |  9 ++-------
 fs/f2fs/file.c                    |  3 +++
 fs/f2fs/node.c                    |  6 +-----
 fs/fuse/file.c                    |  7 +++++--
 fs/libfs.c                        |  6 ++++--
 include/linux/fs.h                | 17 ++++++++++-------
 include/linux/pagemap.h           |  8 ++------
 mm/filemap.c                      | 33 +++++++++++----------------------
 10 files changed, 44 insertions(+), 64 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index ed06fb39822b..f201a77873f7 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -577,7 +577,7 @@ written at any point after PG_Dirty is clear.  Once it is known to be
 safe, PG_Writeback is cleared.
 
 If there is an error during writeback, then the address_space should be
-marked with an error (typically using filemap_set_wb_error), in order to
+marked with an error (typically using mapping_set_error), in order to
 ensure that the error can later be reported to the application when an
 fsync is issued.
 
@@ -893,10 +893,9 @@ otherwise noted.
 
   release: called when the last reference to an open file is closed
 
-  fsync: called by the fsync(2) system call. Filesystems that use the
-	pagecache should call filemap_report_wb_error before returning
-	to ensure that any errors that occurred during writeback are
-	reported and the file's error sequence advanced.
+  fsync: called by the fsync(2) system call. Errors that were previously
+	 recorded using mapping_set_error will automatically be returned to
+	 the application and the file's error sequence advanced.
 
   fasync: called by the fcntl(2) system call when asynchronous
 	(non-blocking) mode is enabled for a file
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 520cb7230b2d..e15faf240b51 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1962,6 +1962,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	int ret = 0;
 	bool full_sync = 0;
 	u64 len;
+	errseq_t wb_since = READ_ONCE(file->f_wb_err);
 
 	/*
 	 * The range length can be represented by u64, we have to do the typecasts
@@ -2079,14 +2080,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		 */
 		clear_bit(BTRFS_INODE_NEEDS_FULL_SYNC,
 			  &BTRFS_I(inode)->runtime_flags);
-		/*
-		 * An ordered extent might have started before and completed
-		 * already with io errors, in which case the inode was not
-		 * updated and we end up here. So check the inode's mapping
-		 * flags for any errors that might have happened while doing
-		 * writeback of file data.
-		 */
-		ret = filemap_check_errors(inode->i_mapping);
+		ret = filemap_check_wb_error(inode->i_mapping, wb_since);
 		inode_unlock(inode);
 		goto out;
 	}
diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
index a59674c3e69e..d0a123dbb199 100644
--- a/fs/btrfs/tree-log.c
+++ b/fs/btrfs/tree-log.c
@@ -3972,12 +3972,6 @@ static int wait_ordered_extents(struct btrfs_trans_handle *trans,
 			    test_bit(BTRFS_ORDERED_IOERR, &ordered->flags)));
 
 		if (test_bit(BTRFS_ORDERED_IOERR, &ordered->flags)) {
-			/*
-			 * Clear the AS_EIO/AS_ENOSPC flags from the inode's
-			 * i_mapping flags, so that the next fsync won't get
-			 * an outdated io error too.
-			 */
-			filemap_check_errors(inode->i_mapping);
 			*ordered_io_error = true;
 			break;
 		}
@@ -4171,6 +4165,7 @@ static int btrfs_log_changed_extents(struct btrfs_trans_handle *trans,
 	u64 test_gen;
 	int ret = 0;
 	int num = 0;
+	errseq_t since = filemap_sample_wb_error(inode->vfs_inode.i_mapping);
 
 	INIT_LIST_HEAD(&extents);
 
@@ -4214,7 +4209,7 @@ static int btrfs_log_changed_extents(struct btrfs_trans_handle *trans,
 	 * without writing to the log tree and the fsync must report the
 	 * file data write error and not commit the current transaction.
 	 */
-	ret = filemap_check_errors(inode->vfs_inode.i_mapping);
+	ret = filemap_check_wb_error(inode->vfs_inode.i_mapping, since);
 	if (ret)
 		ctx->io_err = ret;
 process:
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 5f7317875a67..7ce13281925f 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -187,6 +187,7 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
 		.nr_to_write = LONG_MAX,
 		.for_reclaim = 0,
 	};
+	errseq_t since = READ_ONCE(file->f_wb_err);
 
 	if (unlikely(f2fs_readonly(inode->i_sb)))
 		return 0;
@@ -265,6 +266,8 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
 	}
 
 	ret = wait_on_node_pages_writeback(sbi, ino);
+	if (ret == 0)
+		ret = filemap_check_wb_error(NODE_MAPPING(sbi), since);
 	if (ret)
 		goto out;
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 481aa8dc79f4..b3ef9504fd8b 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1630,7 +1630,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 {
 	pgoff_t index = 0, end = ULONG_MAX;
 	struct pagevec pvec;
-	int ret2, ret = 0;
+	int ret = 0;
 
 	pagevec_init(&pvec, 0);
 
@@ -1658,10 +1658,6 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 		pagevec_release(&pvec);
 		cond_resched();
 	}
-
-	ret2 = filemap_check_errors(NODE_MAPPING(sbi));
-	if (!ret)
-		ret = ret2;
 	return ret;
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 07d0efcb050c..e1ced9cfb090 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -398,6 +398,7 @@ static int fuse_flush(struct file *file, fl_owner_t id)
 	struct fuse_req *req;
 	struct fuse_flush_in inarg;
 	int err;
+	errseq_t since = READ_ONCE(file->f_wb_err);
 
 	if (is_bad_inode(inode))
 		return -EIO;
@@ -413,7 +414,7 @@ static int fuse_flush(struct file *file, fl_owner_t id)
 	fuse_sync_writes(inode);
 	inode_unlock(inode);
 
-	err = filemap_check_errors(file->f_mapping);
+	err = filemap_check_wb_error(file->f_mapping, since);
 	if (err)
 		return err;
 
@@ -446,6 +447,7 @@ int fuse_fsync_common(struct file *file, loff_t start, loff_t end,
 	FUSE_ARGS(args);
 	struct fuse_fsync_in inarg;
 	int err;
+	errseq_t since;
 
 	if (is_bad_inode(inode))
 		return -EIO;
@@ -461,6 +463,7 @@ int fuse_fsync_common(struct file *file, loff_t start, loff_t end,
 	if (err)
 		goto out;
 
+	since = READ_ONCE(file->f_wb_err);
 	fuse_sync_writes(inode);
 
 	/*
@@ -468,7 +471,7 @@ int fuse_fsync_common(struct file *file, loff_t start, loff_t end,
 	 * filemap_write_and_wait_range() does not catch errors.
 	 * We have to do this directly after fuse_sync_writes()
 	 */
-	err = filemap_check_errors(file->f_mapping);
+	err = filemap_check_wb_error(file->f_mapping, since);
 	if (err)
 		goto out;
 
diff --git a/fs/libfs.c b/fs/libfs.c
index 12a48ee442d3..23319d74fa42 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -991,8 +991,10 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 
 out:
 	inode_unlock(inode);
-	err = filemap_check_errors(inode->i_mapping);
-	return ret ? : err;
+	if (!ret)
+		ret = filemap_check_wb_error(inode->i_mapping,
+						READ_ONCE(file->f_wb_err));
+	return ret;
 }
 EXPORT_SYMBOL(__generic_file_fsync);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 69a89f667c7f..ca185f026258 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1741,12 +1741,6 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
 	return file->f_op->mmap(file, vma);
 }
 
-static inline int call_fsync(struct file *file, loff_t start, loff_t end,
-			     int datasync)
-{
-	return file->f_op->fsync(file, start, end, datasync);
-}
-
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			      unsigned long nr_segs, unsigned long fast_segs,
 			      struct iovec *fast_pointer,
@@ -2523,7 +2517,6 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
-extern int filemap_check_errors(struct address_space *mapping);
 extern int __must_check filemap_report_wb_error(struct file *file);
 
 /**
@@ -2546,6 +2539,16 @@ static inline errseq_t filemap_sample_wb_error(struct address_space *mapping)
 	return errseq_sample(&mapping->wb_err);
 }
 
+static inline int call_fsync(struct file *file, loff_t start, loff_t end,
+			     int datasync)
+{
+	int ret, ret2;
+
+	ret = file->f_op->fsync(file, start, end, datasync);
+	ret2 = filemap_report_wb_error(file);
+	return ret ? : ret2;
+}
+
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
 extern int vfs_fsync(struct file *file, int datasync);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 84943e8057ef..32512ffc15fa 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -14,6 +14,7 @@
 #include <linux/bitops.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
 #include <linux/hugetlb_inline.h>
+#include <linux/errseq.h>
 
 /*
  * Bits in mapping->flags.
@@ -30,12 +31,7 @@ enum mapping_flags {
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
-	if (unlikely(error)) {
-		if (error == -ENOSPC)
-			set_bit(AS_ENOSPC, &mapping->flags);
-		else
-			set_bit(AS_EIO, &mapping->flags);
-	}
+	return errseq_set(&mapping->wb_err, error);
 }
 
 static inline void mapping_set_unevictable(struct address_space *mapping)
diff --git a/mm/filemap.c b/mm/filemap.c
index ee1a798acfc1..d94a76d4e023 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
+#include <linux/errseq.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -295,20 +296,6 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
-int filemap_check_errors(struct address_space *mapping)
-{
-	int ret = 0;
-	/* Check for outstanding write errors */
-	if (test_bit(AS_ENOSPC, &mapping->flags) &&
-	    test_and_clear_bit(AS_ENOSPC, &mapping->flags))
-		ret = -ENOSPC;
-	if (test_bit(AS_EIO, &mapping->flags) &&
-	    test_and_clear_bit(AS_EIO, &mapping->flags))
-		ret = -EIO;
-	return ret;
-}
-EXPORT_SYMBOL(filemap_check_errors);
-
 /**
  * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
  * @mapping:	address space structure to write
@@ -431,9 +418,10 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 			    loff_t end_byte)
 {
 	int ret, ret2;
+	errseq_t since = filemap_sample_wb_error(mapping);
 
 	ret = __filemap_fdatawait_range(mapping, start_byte, end_byte);
-	ret2 = filemap_check_errors(mapping);
+	ret2 = filemap_check_wb_error(mapping, since);
 	if (!ret)
 		ret = ret2;
 
@@ -489,6 +477,7 @@ EXPORT_SYMBOL(filemap_fdatawait);
 int filemap_write_and_wait(struct address_space *mapping)
 {
 	int err = 0;
+	errseq_t since = filemap_sample_wb_error(mapping);
 
 	if ((!dax_mapping(mapping) && mapping->nrpages) ||
 	    (dax_mapping(mapping) && mapping->nrexceptional)) {
@@ -500,12 +489,12 @@ int filemap_write_and_wait(struct address_space *mapping)
 		 * thing (e.g. bug) happened, so we avoid waiting for it.
 		 */
 		if (err != -EIO) {
-			int err2 = filemap_fdatawait(mapping);
+			filemap_fdatawait_keep_errors(mapping);
 			if (!err)
-				err = err2;
+				err = filemap_check_wb_error(mapping, since);
 		}
 	} else {
-		err = filemap_check_errors(mapping);
+		err = filemap_check_wb_error(mapping, since);
 	}
 	return err;
 }
@@ -526,6 +515,7 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 				 loff_t lstart, loff_t lend)
 {
 	int err = 0;
+	errseq_t since = filemap_sample_wb_error(mapping);
 
 	if ((!dax_mapping(mapping) && mapping->nrpages) ||
 	    (dax_mapping(mapping) && mapping->nrexceptional)) {
@@ -533,13 +523,12 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
 		if (err != -EIO) {
-			int err2 = filemap_fdatawait_range(mapping,
-						lstart, lend);
+			__filemap_fdatawait_range(mapping, lstart, lend);
 			if (!err)
-				err = err2;
+				err = filemap_check_wb_error(mapping, since);
 		}
 	} else {
-		err = filemap_check_errors(mapping);
+		err = filemap_check_wb_error(mapping, since);
 	}
 	return err;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
