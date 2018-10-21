Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE586B0273
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:16:56 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id f8-v6so22946064ybn.22
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:16:56 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h63-v6si13991032ywh.193.2018.10.21.09.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:16:55 -0700 (PDT)
Subject: [PATCH 15/28] vfs: plumb remap flags through the vfs dedupe
 functions
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:16:49 -0700
Message-ID: <154013860893.29026.11185987776641893367.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Plumb a remap_flags argument through the vfs_dedupe_file_range_one
functions so that dedupe can take advantage of it.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/overlayfs/file.c |    3 ++-
 fs/read_write.c     |    9 ++++++---
 include/linux/fs.h  |    2 +-
 3 files changed, 9 insertions(+), 5 deletions(-)


diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 0393815c8971..84dd957efa24 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -467,7 +467,8 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
 
 	case OVL_DEDUPE:
 		ret = vfs_dedupe_file_range_one(real_in.file, pos_in,
-						real_out.file, pos_out, len);
+						real_out.file, pos_out, len,
+						flags);
 		break;
 	}
 	revert_creds(old_cred);
diff --git a/fs/read_write.c b/fs/read_write.c
index 0d1ac1b9bc22..ea30666013b0 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -2010,10 +2010,12 @@ EXPORT_SYMBOL(vfs_dedupe_file_range_compare);
 
 loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 				 struct file *dst_file, loff_t dst_pos,
-				 loff_t len)
+				 loff_t len, unsigned int remap_flags)
 {
 	loff_t ret;
 
+	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP));
+
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
 		return ret;
@@ -2044,7 +2046,7 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 	}
 
 	ret = dst_file->f_op->remap_file_range(src_file, src_pos, dst_file,
-			dst_pos, len, REMAP_FILE_DEDUP);
+			dst_pos, len, remap_flags | REMAP_FILE_DEDUP);
 out_drop_write:
 	mnt_drop_write_file(dst_file);
 
@@ -2112,7 +2114,8 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 		}
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
-						    info->dest_offset, len);
+						    info->dest_offset, len,
+						    0);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1c5e55d2a67d..544ab5083b48 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1859,7 +1859,7 @@ extern int vfs_dedupe_file_range(struct file *file,
 				 struct file_dedupe_range *same);
 extern loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 					struct file *dst_file, loff_t dst_pos,
-					loff_t len);
+					loff_t len, unsigned int remap_flags);
 
 
 struct super_operations {
