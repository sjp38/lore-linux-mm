Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 029696B026D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:11:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 8-v6so3237783pfr.0
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:11:25 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f9-v6si25660578plm.126.2018.10.09.17.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:11:24 -0700 (PDT)
Subject: [PATCH 06/25] vfs: strengthen checking of file range inputs to
 generic_remap_checks
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:11:20 -0700
Message-ID: <153913028015.32295.15993665528948323051.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

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
---
 mm/filemap.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)


diff --git a/mm/filemap.c b/mm/filemap.c
index 14041a8468ba..59056bd9c58a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2974,6 +2974,27 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 }
 EXPORT_SYMBOL(generic_write_checks);
 
+static int
+generic_remap_check_limits(struct file *file, loff_t pos, uint64_t *count)
+{
+	struct inode *inode = file->f_mapping->host;
+
+	/* Don't exceed the LFS limits. */
+	if (unlikely(pos + *count > MAX_NON_LFS &&
+				!(file->f_flags & O_LARGEFILE))) {
+		if (pos >= MAX_NON_LFS)
+			return -EFBIG;
+		*count = min(*count, MAX_NON_LFS - (uint64_t)pos);
+	}
+
+	/* Don't operate on ranges the page cache doesn't support. */
+	if (unlikely(pos >= inode->i_sb->s_maxbytes))
+		return -EFBIG;
+
+	*count = min(*count, inode->i_sb->s_maxbytes - (uint64_t)pos);
+	return 0;
+}
+
 /*
  * Performs necessary checks before doing a clone.
  *
@@ -2992,6 +3013,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	uint64_t bcount;
 	loff_t size_in, size_out;
 	loff_t bs = inode_out->i_sb->s_blocksize;
+	int ret;
 
 	/* The start of both ranges must be aligned to an fs block. */
 	if (!IS_ALIGNED(pos_in, bs) || !IS_ALIGNED(pos_out, bs))
@@ -3015,6 +3037,23 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 		return -EINVAL;
 	count = min(count, size_in - (uint64_t)pos_in);
 
+	/* Don't exceed RLMIT_FSIZE in the file we're writing into. */
+	if (limit != RLIM_INFINITY) {
+		if (pos_out >= limit) {
+			send_sig(SIGXFSZ, current, 0);
+			return -EFBIG;
+		}
+		count = min(count, limit - (uint64_t)pos_out);
+	}
+
+	ret = generic_remap_check_limits(file_in, pos_in, &count);
+	if (ret)
+		return ret;
+
+	ret = generic_remap_check_limits(file_out, pos_out, &count);
+	if (ret)
+		return ret;
+
 	/*
 	 * If the user wanted us to link to the infile's EOF, round up to the
 	 * next block boundary for this check.
