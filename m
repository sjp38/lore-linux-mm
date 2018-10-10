Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8759B6B0269
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:11:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f5-v6so2630943plf.11
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:11:11 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z1-v6si22516285plo.59.2018.10.09.17.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:11:10 -0700 (PDT)
Subject: [PATCH 04/25] xfs: update ctime and remove suid before cloning files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:11:06 -0700
Message-ID: <153913026644.32295.612141018276176517.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Before cloning into a file, update the ctime and remove sensitive
attributes like suid, just like we'd do for a regular file write.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_reflink.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index cbb359e68a72..d4feaeba8542 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1264,6 +1264,7 @@ xfs_reflink_zero_posteof(
  * Prepare two files for range cloning.  Upon a successful return both inodes
  * will have the iolock and mmaplock held, the page cache of the out file
  * will be truncated, and any leases on the out file will have been broken.
+ * This function borrows heavily from xfs_file_aio_write_checks.
  * Returns negative for error, 0 for nothing to do, and 1 for success.
  */
 STATIC int
@@ -1328,6 +1329,30 @@ xfs_reflink_remap_prep(
 	/* Zap any page cache for the destination file's range. */
 	truncate_inode_pages_range(&inode_out->i_data, pos_out,
 				   PAGE_ALIGN(pos_out + *len) - 1);
+
+	/* If we're altering the file contents... */
+	if (!is_dedupe) {
+		/*
+		 * ...update the timestamps (which will grab the ilock again
+		 * from xfs_fs_dirty_inode, so we have to call it before we
+		 * take the ilock).
+		 */
+		if (!(file_out->f_mode & FMODE_NOCMTIME)) {
+			ret = file_update_time(file_out);
+			if (ret)
+				goto out_unlock;
+		}
+
+		/*
+		 * ...clear the security bits if the process is not being run
+		 * by root.  This keeps people from modifying setuid and setgid
+		 * binaries.
+		 */
+		ret = file_remove_privs(file_out);
+		if (ret)
+			goto out_unlock;
+	}
+
 	return 1;
 out_unlock:
 	xfs_reflink_remap_unlock(file_in, file_out);
