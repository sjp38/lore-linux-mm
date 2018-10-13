Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 488BE6B0269
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:06:17 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c33-v6so13943025qta.20
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:06:17 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a76-v6si2271378qkh.119.2018.10.12.17.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:06:16 -0700 (PDT)
Subject: [PATCH 04/25] vfs: strengthen checking of file range inputs to
 generic_remap_checks
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Fri, 12 Oct 2018 17:06:10 -0700
Message-ID: <153938917040.8361.8262720501664468642.stgit@magnolia>
In-Reply-To: <153938912912.8361.13446310416406388958.stgit@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
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
 mm/filemap.c |   91 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 59 insertions(+), 32 deletions(-)


diff --git a/mm/filemap.c b/mm/filemap.c
index 47e6bfd45a91..08ad210fee49 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2915,6 +2915,49 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
+static int generic_access_check_limits(struct file *file, loff_t pos,
+				       loff_t *count)
+{
+	struct inode *inode = file->f_mapping->host;
+
+	/* Don't exceed the LFS limits. */
+	if (unlikely(pos + *count > MAX_NON_LFS &&
+				!(file->f_flags & O_LARGEFILE))) {
+		if (pos >= MAX_NON_LFS)
+			return -EFBIG;
+		*count = min(*count, (loff_t)MAX_NON_LFS - pos);
+	}
+
+	/*
+	 * Don't operate on ranges the page cache doesn't support.
+	 *
+	 * If we have written data it becomes a short write.  If we have
+	 * exceeded without writing data we send a signal and return EFBIG.
+	 * Linus frestrict idea will clean these up nicely..
+	 */
+	if (unlikely(pos >= inode->i_sb->s_maxbytes))
+		return -EFBIG;
+
+	*count = min(*count, inode->i_sb->s_maxbytes - pos);
+	return 0;
+}
+
+static int generic_write_check_limits(struct file *file, loff_t pos,
+				      loff_t *count)
+{
+	unsigned long limit = rlimit(RLIMIT_FSIZE);
+
+	if (limit != RLIM_INFINITY) {
+		if (pos >= limit) {
+			send_sig(SIGXFSZ, current, 0);
+			return -EFBIG;
+		}
+		*count = min(*count, (loff_t)limit - pos);
+	}
+
+	return generic_access_check_limits(file, pos, count);
+}
+
 /*
  * Performs necessary checks before doing a write
  *
@@ -2926,8 +2969,8 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	unsigned long limit = rlimit(RLIMIT_FSIZE);
-	loff_t pos;
+	loff_t count;
+	int ret;
 
 	if (!iov_iter_count(from))
 		return 0;
@@ -2936,40 +2979,15 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
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
+	count = iov_iter_count(from);
+	ret = generic_write_check_limits(file, iocb->ki_pos, &count);
+	if (ret)
+		return ret;
 
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
-
-	iov_iter_truncate(from, inode->i_sb->s_maxbytes - pos);
+	iov_iter_truncate(from, count);
 	return iov_iter_count(from);
 }
 EXPORT_SYMBOL(generic_write_checks);
@@ -2991,6 +3009,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	uint64_t bcount;
 	loff_t size_in, size_out;
 	loff_t bs = inode_out->i_sb->s_blocksize;
+	int ret;
 
 	/* The start of both ranges must be aligned to an fs block. */
 	if (!IS_ALIGNED(pos_in, bs) || !IS_ALIGNED(pos_out, bs))
@@ -3014,6 +3033,14 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
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
