Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CECB6B027F
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:45:44 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id c67-v6so17928612ywh.13
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:45:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x125-v6si3386613yba.408.2018.10.17.15.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:45:43 -0700 (PDT)
Subject: [PATCH 12/29] vfs: remap helper should update destination inode
 metadata
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:45:38 -0700
Message-ID: <153981633799.5568.10992236383232225210.stgit@magnolia>
In-Reply-To: <153981625504.5568.2708520119290577378.stgit@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Extend generic_remap_file_range_prep to handle inode metadata updates
when remapping into a file.  If the operation can possibly alter the
file contents, we must update the ctime and mtime and remove security
privileges, just like we do for regular file writes.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c      |   19 +++++++++++++++++++
 fs/xfs/xfs_reflink.c |   23 -----------------------
 2 files changed, 19 insertions(+), 23 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index ebcbfc4f2907..b61bd3fc7154 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1820,6 +1820,25 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
+	/* If can't alter the file contents, we're done. */
+	if (!(remap_flags & REMAP_FILE_DEDUP)) {
+		/* Update the timestamps, since we can alter file contents. */
+		if (!(file_out->f_mode & FMODE_NOCMTIME)) {
+			ret = file_update_time(file_out);
+			if (ret)
+				return ret;
+		}
+
+		/*
+		 * Clear the security bits if the process is not being run by
+		 * root.  This keeps people from modifying setuid and setgid
+		 * binaries.
+		 */
+		ret = file_remove_privs(file_out);
+		if (ret)
+			return ret;
+	}
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
