Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC2B36B0279
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 23:19:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id f59-v6so17185626plb.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:19:34 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l91-v6si12934147plb.315.2018.10.15.20.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 20:19:33 -0700 (PDT)
Subject: [PATCH 13/26] vfs: create generic_remap_file_range_touch to update
 inode metadata
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Mon, 15 Oct 2018 20:19:26 -0700
Message-ID: <153965996673.3607.133184523000924340.stgit@magnolia>
In-Reply-To: <153965939489.1256.7400115244528045860.stgit@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Create a new VFS helper to handle inode metadata updates when remapping
into a file.  If the operation can possibly alter the file contents, we
must update the ctime and mtime and remove security privileges, just
like we do for regular file writes.  Wire up ocfs2 to ensure consistent
behavior.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c      |   28 ++++++++++++++++++++++++++++
 fs/xfs/xfs_reflink.c |   23 -----------------------
 2 files changed, 28 insertions(+), 23 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index ebcbfc4f2907..3f6392f1d5d4 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1737,6 +1737,30 @@ static int generic_remap_check_len(struct inode *inode_in,
 	return 0;
 }
 
+/* Update inode timestamps and remove security privileges when remapping. */
+static int generic_remap_file_range_target(struct file *file,
+					   unsigned int remap_flags)
+{
+	int ret;
+
+	/* If can't alter the file contents, we're done. */
+	if (remap_flags & REMAP_FILE_DEDUP)
+		return 0;
+
+	/* Update the timestamps, since we can alter file contents. */
+	if (!(file->f_mode & FMODE_NOCMTIME)) {
+		ret = file_update_time(file);
+		if (ret)
+			return ret;
+	}
+
+	/*
+	 * Clear the security bits if the process is not being run by root.
+	 * This keeps people from modifying setuid and setgid binaries.
+	 */
+	return file_remove_privs(file);
+}
+
 /*
  * Check that the two inodes are eligible for cloning, the ranges make
  * sense, and then flush all dirty data.  Caller must ensure that the
@@ -1820,6 +1844,10 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
+	ret = generic_remap_file_range_target(file_out, remap_flags);
+	if (ret)
+		return ret;
+
 	return 1;
 }
 EXPORT_SYMBOL(generic_remap_file_range_prep);
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index 29aab196ce7e..2d7dd8b28d7c 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1372,29 +1372,6 @@ xfs_reflink_remap_prep(
 	truncate_inode_pages_range(&inode_out->i_data, pos_out,
 				   PAGE_ALIGN(pos_out + *len) - 1);
 
-	/* If we're altering the file contents... */
-	if (!(remap_flags & REMAP_FILE_DEDUP)) {
-		/*
-		 * ...update the timestamps (which will grab the ilock again
-		 * from xfs_fs_dirty_inode, so we have to call it before we
-		 * take the ilock).
-		 */
-		if (!(file_out->f_mode & FMODE_NOCMTIME)) {
-			ret = file_update_time(file_out);
-			if (ret)
-				goto out_unlock;
-		}
-
-		/*
-		 * ...clear the security bits if the process is not being run
-		 * by root.  This keeps people from modifying setuid and setgid
-		 * binaries.
-		 */
-		ret = file_remove_privs(file_out);
-		if (ret)
-			goto out_unlock;
-	}
-
 	return 1;
 out_unlock:
 	xfs_reflink_remap_unlock(file_in, file_out);
