Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB7E6B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:48:34 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so166091pdi.6
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:48:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 1si23375pdf.153.2014.07.22.12.48.32
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 12:48:33 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v8 06/22] Introduce IS_DAX(inode)
Date: Tue, 22 Jul 2014 15:47:54 -0400
Message-Id: <b49a506b72183bf36bb70b01f2241371885988fa.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Use an inode flag to tag inodes which should avoid using the page cache.
Convert ext2 to use it instead of mapping_is_xip().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/inode.c    | 9 ++++++---
 fs/ext2/xip.h      | 2 --
 include/linux/fs.h | 6 ++++++
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 36d35c3..0cb0448 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -731,7 +731,7 @@ static int ext2_get_blocks(struct inode *inode,
 		goto cleanup;
 	}
 
-	if (ext2_use_xip(inode->i_sb)) {
+	if (IS_DAX(inode)) {
 		/*
 		 * we need to clear the block
 		 */
@@ -1201,7 +1201,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
 
 	inode_dio_wait(inode);
 
-	if (mapping_is_xip(inode->i_mapping))
+	if (IS_DAX(inode))
 		error = xip_truncate_page(inode->i_mapping, newsize);
 	else if (test_opt(inode->i_sb, NOBH))
 		error = nobh_truncate_page(inode->i_mapping,
@@ -1273,7 +1273,8 @@ void ext2_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = EXT2_I(inode)->i_flags;
 
-	inode->i_flags &= ~(S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC);
+	inode->i_flags &= ~(S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME |
+				S_DIRSYNC | S_DAX);
 	if (flags & EXT2_SYNC_FL)
 		inode->i_flags |= S_SYNC;
 	if (flags & EXT2_APPEND_FL)
@@ -1284,6 +1285,8 @@ void ext2_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT2_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
+	if (test_opt(inode->i_sb, XIP))
+		inode->i_flags |= S_DAX;
 }
 
 /* Propagate flags from i_flags to EXT2_I(inode)->i_flags */
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index 18b34d2..29be737 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -16,9 +16,7 @@ static inline int ext2_use_xip (struct super_block *sb)
 }
 int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
 				void **, unsigned long *);
-#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_mem)
 #else
-#define mapping_is_xip(map)			0
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e11d60c..a94e5d7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1579,6 +1579,7 @@ struct super_operations {
 #define S_IMA		1024	/* Inode has an associated IMA struct */
 #define S_AUTOMOUNT	2048	/* Automount/referral quasi-directory */
 #define S_NOSEC		4096	/* no suid or xattr security attributes */
+#define S_DAX		8192	/* Direct Access, avoiding the page cache */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -1616,6 +1617,11 @@ struct super_operations {
 #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
+#ifdef CONFIG_FS_XIP
+#define IS_DAX(inode)		((inode)->i_flags & S_DAX)
+#else
+#define IS_DAX(inode)		0
+#endif
 
 /*
  * Inode state bits.  Protected by inode->i_lock
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
