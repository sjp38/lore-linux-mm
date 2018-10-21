Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A45496B027C
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:17:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h38-v6so25645371ywk.20
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:17:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q5-v6si14736076ywj.32.2018.10.21.09.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:17:14 -0700 (PDT)
Subject: [PATCH 18/28] vfs: clean up generic_remap_file_range_prep return
 value
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:17:09 -0700
Message-ID: <154013862952.29026.12371941728048413604.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Since the remap prep function can update the length of the remap
request, we can change this function to return the usual return status
instead of the odd behavior it has now.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/ocfs2/refcounttree.c |    2 +-
 fs/read_write.c         |    6 +++---
 fs/xfs/xfs_reflink.c    |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 6a42c04ac0ab..46bbd315c39f 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4852,7 +4852,7 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 
 	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
 			&len, remap_flags);
-	if (ret <= 0)
+	if (ret < 0 || len == 0)
 		goto out_unlock;
 
 	/* Lock out changes to the allocation maps and remap. */
diff --git a/fs/read_write.c b/fs/read_write.c
index e4d295d0d236..6b40a43edf18 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1848,8 +1848,8 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
  * sense, and then flush all dirty data.  Caller must ensure that the
  * inodes have been locked against any other modifications.
  *
- * Returns: 0 for "nothing to clone", 1 for "something to clone", or
- * the usual negative error code.
+ * If there's an error, then the usual negative error code is returned.
+ * Otherwise returns 0 with *len set to the request length.
  */
 int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 				  struct file *file_out, loff_t pos_out,
@@ -1945,7 +1945,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 			return ret;
 	}
 
-	return 1;
+	return 0;
 }
 EXPORT_SYMBOL(generic_remap_file_range_prep);
 
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 3dbe5fb7e9c0..9b1ea42c81d1 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1329,7 +1329,7 @@ xfs_reflink_remap_prep(
 
 	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
 			len, remap_flags);
-	if (ret <= 0)
+	if (ret < 0 || *len == 0)
 		goto out_unlock;
 
 	/*
@@ -1409,7 +1409,7 @@ xfs_reflink_remap_range(
 	/* Prepare and then clone file data. */
 	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
 			&len, remap_flags);
-	if (ret <= 0)
+	if (ret < 0 || len == 0)
 		return ret;
 
 	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
