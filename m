Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2A3F6B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 14:56:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5-v6so1098760pgv.6
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 11:56:17 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 12-v6si22162038pgq.337.2018.10.18.11.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 11:56:16 -0700 (PDT)
Date: Thu, 18 Oct 2018 11:56:07 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH v2 04/29] vfs: strengthen checking of file range inputs to
 generic_remap_checks
Message-ID: <20181018185607.GV28243@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
 <153981628292.5568.2466587869276881561.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153981628292.5568.2466587869276881561.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

File range remapping, if allowed to run past the destination file's EOF,
is an optimization on a regular file write.  Regular file writes that
extend the file length are subject to various constraints which are not
checked by range cloning.

This is a correctness problem because we're never allowed to touch
ranges that the page cache can't support (s_maxbytes); we're not
supposed to deal with large offsets (MAX_NON_LFS) if O_LARGEFILE isn't
set; and we must obey resource limits (RLIMIT_FSIZE).

Therefore, add these checks to the new generic_remap_checks function so
that we curtail unexpected behavior.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
v2: restructurings as recommended by Al Viro
---
 mm/filemap.c |   84 ++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 52 insertions(+), 32 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 47e6bfd45a91..aab149fc1faa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2915,6 +2915,42 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
+/*
+ * Don't operate on ranges the page cache doesn't support, and don't exceed the
+ * LFS limits.  If pos is under the limit it becomes a short access.  If it
+ * exceeds the limit we return -EFBIG.
+ */
+static int generic_access_check_limits(struct file *file, loff_t pos,
+				       loff_t *count)
+{
+	struct inode *inode = file->f_mapping->host;
+	loff_t max_size = inode->i_sb->s_maxbytes;
+
+	if (!(file->f_flags & O_LARGEFILE))
+		max_size = MAX_NON_LFS;
+
+	if (unlikely(pos >= max_size))
+		return -EFBIG;
+	*count = min(*count, max_size - pos);
+	return 0;
+}
+
+static int generic_write_check_limits(struct file *file, loff_t pos,
+				      loff_t *count)
+{
+	loff_t limit = rlimit(RLIMIT_FSIZE);
+
+	if (limit != RLIM_INFINITY) {
+		if (pos >= limit) {
+			send_sig(SIGXFSZ, current, 0);
+			return -EFBIG;
+		}
+		*count = min(*count, limit - pos);
+	}
+
+	return generic_access_check_limits(file, pos, count);
+}
+
 /*
  * Performs necessary checks before doing a write
  *
@@ -2926,8 +2962,8 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	unsigned long limit = rlimit(RLIMIT_FSIZE);
-	loff_t pos;
+	loff_t count;
+	int ret;
 
 	if (!iov_iter_count(from))
 		return 0;
@@ -2936,40 +2972,15 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	if (iocb->ki_flags & IOCB_APPEND)
 		iocb->ki_pos = i_size_read(inode);
 
-	pos = iocb->ki_pos;
-
 	if ((iocb->ki_flags & IOCB_NOWAIT) && !(iocb->ki_flags & IOCB_DIRECT))
 		return -EINVAL;
 
-	if (limit != RLIM_INFINITY) {
-		if (iocb->ki_pos >= limit) {
-			send_sig(SIGXFSZ, current, 0);
-			return -EFBIG;
-		}
-		iov_iter_truncate(from, limit - (unsigned long)pos);
-	}
-
-	/*
-	 * LFS rule
-	 */
-	if (unlikely(pos + iov_iter_count(from) > MAX_NON_LFS &&
-				!(file->f_flags & O_LARGEFILE))) {
-		if (pos >= MAX_NON_LFS)
-			return -EFBIG;
-		iov_iter_truncate(from, MAX_NON_LFS - (unsigned long)pos);
-	}
-
-	/*
-	 * Are we about to exceed the fs block limit ?
-	 *
-	 * If we have written data it becomes a short write.  If we have
-	 * exceeded without writing data we send a signal and return EFBIG.
-	 * Linus frestrict idea will clean these up nicely..
-	 */
-	if (unlikely(pos >= inode->i_sb->s_maxbytes))
-		return -EFBIG;
+	count = iov_iter_count(from);
+	ret = generic_write_check_limits(file, iocb->ki_pos, &count);
+	if (ret)
+		return ret;
 
-	iov_iter_truncate(from, inode->i_sb->s_maxbytes - pos);
+	iov_iter_truncate(from, count);
 	return iov_iter_count(from);
 }
 EXPORT_SYMBOL(generic_write_checks);
@@ -2991,6 +3002,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	uint64_t bcount;
 	loff_t size_in, size_out;
 	loff_t bs = inode_out->i_sb->s_blocksize;
+	int ret;
 
 	/* The start of both ranges must be aligned to an fs block. */
 	if (!IS_ALIGNED(pos_in, bs) || !IS_ALIGNED(pos_out, bs))
@@ -3014,6 +3026,14 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 		return -EINVAL;
 	count = min(count, size_in - (uint64_t)pos_in);
 
+	ret = generic_access_check_limits(file_in, pos_in, &count);
+	if (ret)
+		return ret;
+
+	ret = generic_write_check_limits(file_out, pos_out, &count);
+	if (ret)
+		return ret;
+
 	/*
 	 * If the user wanted us to link to the infile's EOF, round up to the
 	 * next block boundary for this check.
