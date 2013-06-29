Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8541A6B003B
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:47:03 -0400 (EDT)
Subject: [PATCH 14/16] fuse: Fix O_DIRECT operations vs cached writeback
 misorder - v2
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:46:49 +0400
Message-ID: <20130629174633.20175.16915.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

The problem is:

1. write cached data to a file
2. read directly from the same file (via another fd)

The 2nd operation may read stale data, i.e. the one that was in a file
before the 1st op. Problem is in how fuse manages writeback.

When direct op occurs the core kernel code calls filemap_write_and_wait
to flush all the cached ops in flight. But fuse acks the writeback right
after the ->writepages callback exits w/o waiting for the real write to
happen. Thus the subsequent direct op proceeds while the real writeback
is still in flight. This is a problem for backends that reorder operation.

Fix this by making the fuse direct IO callback explicitly wait on the
in-flight writeback to finish.

Changed in v2:
 - do not wait on writeback if fuse_direct_io() call came from
   CUSE (because it doesn't use fuse inodes)

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/cuse.c   |    5 +++--
 fs/fuse/file.c   |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 fs/fuse/fuse_i.h |   13 ++++++++++++-
 3 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/fs/fuse/cuse.c b/fs/fuse/cuse.c
index aef34b1..b57b5ee 100644
--- a/fs/fuse/cuse.c
+++ b/fs/fuse/cuse.c
@@ -95,7 +95,7 @@ static ssize_t cuse_read(struct file *file, char __user *buf, size_t count,
 	struct iovec iov = { .iov_base = buf, .iov_len = count };
 	struct fuse_io_priv io = { .async = 0, .file = file };
 
-	return fuse_direct_io(&io, &iov, 1, count, &pos, 0);
+	return fuse_direct_io(&io, &iov, 1, count, &pos, FUSE_DIO_CUSE);
 }
 
 static ssize_t cuse_write(struct file *file, const char __user *buf,
@@ -109,7 +109,8 @@ static ssize_t cuse_write(struct file *file, const char __user *buf,
 	 * No locking or generic_write_checks(), the server is
 	 * responsible for locking and sanity checks.
 	 */
-	return fuse_direct_io(&io, &iov, 1, count, &pos, 1);
+	return fuse_direct_io(&io, &iov, 1, count, &pos,
+			      FUSE_DIO_WRITE | FUSE_DIO_CUSE);
 }
 
 static int cuse_open(struct inode *inode, struct file *file)
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 86ef60f..ea45cf3 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -342,6 +342,31 @@ u64 fuse_lock_owner_id(struct fuse_conn *fc, fl_owner_t id)
 	return (u64) v0 + ((u64) v1 << 32);
 }
 
+static bool fuse_range_is_writeback(struct inode *inode, pgoff_t idx_from,
+				    pgoff_t idx_to)
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
+		if (!(idx_from >= curr_index + req->num_pages ||
+		      idx_to < curr_index)) {
+			found = true;
+			break;
+		}
+	}
+	spin_unlock(&fc->lock);
+
+	return found;
+}
+
 /*
  * Check if page is under writeback
  *
@@ -386,6 +411,19 @@ static int fuse_wait_on_page_writeback(struct inode *inode, pgoff_t index)
 	return 0;
 }
 
+static void fuse_wait_on_writeback(struct inode *inode, pgoff_t start,
+				   size_t bytes)
+{
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	pgoff_t idx_from, idx_to;
+
+	idx_from = start >> PAGE_CACHE_SHIFT;
+	idx_to = (start + bytes - 1) >> PAGE_CACHE_SHIFT;
+
+	wait_event(fi->page_waitq,
+		   !fuse_range_is_writeback(inode, idx_from, idx_to));
+}
+
 static int fuse_flush(struct file *file, fl_owner_t id)
 {
 	struct inode *inode = file_inode(file);
@@ -1360,8 +1398,10 @@ static inline int fuse_iter_npages(const struct iov_iter *ii_p)
 
 ssize_t fuse_direct_io(struct fuse_io_priv *io, const struct iovec *iov,
 		       unsigned long nr_segs, size_t count, loff_t *ppos,
-		       int write)
+		       int flags)
 {
+	int write = flags & FUSE_DIO_WRITE;
+	int cuse = flags & FUSE_DIO_CUSE;
 	struct file *file = io->file;
 	struct fuse_file *ff = file->private_data;
 	struct fuse_conn *fc = ff->fc;
@@ -1390,6 +1430,10 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, const struct iovec *iov,
 			break;
 		}
 
+		if (!cuse)
+			fuse_wait_on_writeback(file->f_mapping->host, pos,
+					       nbytes);
+
 		if (write)
 			nres = fuse_send_write(req, io, pos, nbytes, owner);
 		else
@@ -1468,7 +1512,8 @@ static ssize_t __fuse_direct_write(struct fuse_io_priv *io,
 
 	res = generic_write_checks(file, ppos, &count, 0);
 	if (!res)
-		res = fuse_direct_io(io, iov, nr_segs, count, ppos, 1);
+		res = fuse_direct_io(io, iov, nr_segs, count, ppos,
+				     FUSE_DIO_WRITE);
 
 	fuse_invalidate_attr(inode);
 
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 82abb82..f969b22 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -859,9 +859,20 @@ int fuse_reverse_inval_entry(struct super_block *sb, u64 parent_nodeid,
 
 int fuse_do_open(struct fuse_conn *fc, u64 nodeid, struct file *file,
 		 bool isdir);
+
+/**
+ * fuse_direct_io() flags
+ */
+
+/** If set, it is WRITE; otherwise - READ */
+#define FUSE_DIO_WRITE (1 << 0)
+
+/** CUSE pass fuse_direct_io() a file which f_mapping->host is not from FUSE */
+#define FUSE_DIO_CUSE  (1 << 1)
+
 ssize_t fuse_direct_io(struct fuse_io_priv *io, const struct iovec *iov,
 		       unsigned long nr_segs, size_t count, loff_t *ppos,
-		       int write);
+		       int flags);
 long fuse_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg,
 		   unsigned int flags);
 long fuse_ioctl_common(struct file *file, unsigned int cmd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
