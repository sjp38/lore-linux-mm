Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8A506B0285
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:14:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o18-v6so2529686pgv.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:14:11 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d11-v6si20296135pgg.91.2018.10.09.17.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:14:10 -0700 (PDT)
Subject: [PATCH 10/25] vfs: rename clone_verify_area to remap_verify_area
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:11:52 -0700
Message-ID: <153913031261.32295.9177776550062804985.stgit@magnolia>
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

Since we use clone_verify_area for both clone and dedupe range checks,
rename the function to make it clear that it's for both.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/read_write.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index 4ea81ea7d78d..b4acfb45d916 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1686,7 +1686,7 @@ SYSCALL_DEFINE6(copy_file_range, int, fd_in, loff_t __user *, off_in,
 	return ret;
 }
 
-static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
+static int remap_verify_area(struct file *file, loff_t pos, u64 len, bool write)
 {
 	struct inode *inode = file_inode(file);
 
@@ -1818,11 +1818,11 @@ int do_clone_file_range(struct file *file_in, loff_t pos_in,
 	if (!file_in->f_op->remap_file_range)
 		return -EOPNOTSUPP;
 
-	ret = clone_verify_area(file_in, pos_in, len, false);
+	ret = remap_verify_area(file_in, pos_in, len, false);
 	if (ret)
 		return ret;
 
-	ret = clone_verify_area(file_out, pos_out, len, true);
+	ret = remap_verify_area(file_out, pos_out, len, true);
 	if (ret)
 		return ret;
 
@@ -1955,7 +1955,7 @@ int vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 	if (ret)
 		return ret;
 
-	ret = clone_verify_area(dst_file, dst_pos, len, true);
+	ret = remap_verify_area(dst_file, dst_pos, len, true);
 	if (ret < 0)
 		goto out_drop_write;
 
@@ -2017,7 +2017,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 	if (!S_ISREG(src->i_mode))
 		goto out;
 
-	ret = clone_verify_area(file, off, len, false);
+	ret = remap_verify_area(file, off, len, false);
 	if (ret < 0)
 		goto out;
 	ret = 0;
