Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5493D6B0284
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:20:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 17-v6so15981948pgs.18
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:20:19 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l4-v6si12652639pgf.344.2018.10.15.20.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:20:18 -0700 (PDT)
Subject: [PATCH 19/26] vfs: clean up generic_remap_file_range_prep return
 value
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:20:14 -0700
Message-ID: <153966001458.3607.5940191707393894977.stgit@magnolia>
In-Reply-To: <153965939489.1256.7400115244528045860.stgit@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Since the remap prep function can update the length of the remap
request, we can change this function to return the usual return status
instead of the odd behavior it has now.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
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
index 450e038e8617..37a7d3fe35d8 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1872,8 +1872,8 @@ static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
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
@@ -1954,7 +1954,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
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
