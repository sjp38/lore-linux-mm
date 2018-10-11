Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB2F46B027C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:13:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n81-v6so6709655pfi.20
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:13:42 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a94-v6si28662526pla.123.2018.10.10.21.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:13:41 -0700 (PDT)
Subject: [PATCH 10/25] vfs: create generic_remap_file_range_touch to update
 inode metadata
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:13:35 -0700
Message-ID: <153923121518.5546.15603284343898988670.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
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
 fs/ocfs2/refcounttree.c |    8 ++++++++
 fs/read_write.c         |   24 ++++++++++++++++++++++++
 fs/xfs/xfs_reflink.c    |   29 +++++++----------------------
 include/linux/fs.h      |    1 +
 4 files changed, 40 insertions(+), 22 deletions(-)


diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 36c56dfbe485..ee1ed11379b3 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4855,6 +4855,14 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 	if (ret <= 0)
 		goto out_unlock;
 
+	/*
+	 * Update inode timestamps and remove security privileges before we
+	 * take the ilock.
+	 */
+	ret = generic_remap_file_range_touch(file_out, is_dedupe);
+	if (ret)
+		goto out_unlock;
+
 	/* Lock out changes to the allocation maps and remap. */
 	down_write(&OCFS2_I(inode_in)->ip_alloc_sem);
 	if (!same_inode)
diff --git a/fs/read_write.c b/fs/read_write.c
index 60cdfb576d81..b233fe019fae 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1811,6 +1811,30 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 }
 EXPORT_SYMBOL(generic_remap_file_range_prep);
 
+/* Update inode timestamps and remove security privileges when remapping. */
+int generic_remap_file_range_touch(struct file *file, bool is_dedupe)
+{
+	int ret;
+
+	/* If can't alter the file contents, we're done. */
+	if (is_dedupe)
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
+EXPORT_SYMBOL(generic_remap_file_range_touch);
+
 int do_clone_file_range(struct file *file_in, loff_t pos_in,
 			struct file *file_out, loff_t pos_out, u64 len)
 {
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index a7757a128a78..99f2ea4fcaba 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1371,28 +1371,13 @@ xfs_reflink_remap_prep(
 	truncate_inode_pages_range(&inode_out->i_data, pos_out,
 				   PAGE_ALIGN(pos_out + *len) - 1);
 
-	/* If we're altering the file contents... */
-	if (!is_dedupe) {
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
+	/*
+	 * Update inode timestamps and remove security privileges before we
+	 * take the ilock.
+	 */
+	ret = generic_remap_file_range_touch(file_out, is_dedupe);
+	if (ret)
+		goto out_unlock;
 
 	return 1;
 out_unlock:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 686905be04c0..91fd3c77763b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1847,6 +1847,7 @@ extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
 extern int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 					 struct file *file_out, loff_t pos_out,
 					 u64 *count, bool is_dedupe);
+extern int generic_remap_file_range_touch(struct file *file, bool is_dedupe);
 extern int do_clone_file_range(struct file *file_in, loff_t pos_in,
 			       struct file *file_out, loff_t pos_out, u64 len);
 extern int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
