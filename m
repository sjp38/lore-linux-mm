Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5488A6B00FE
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:02 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4487003pbb.22
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:02 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wh4si7606768pbc.305.2014.03.23.12.09.00
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:01 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 12/22] ext2: Remove ext2_xip_verify_sb()
Date: Sun, 23 Mar 2014 15:08:38 -0400
Message-Id: <5f91cb658e1ee1b593be9fd719e8f204b0069031.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Jan Kara pointed out that calling ext2_xip_verify_sb() in ext2_remount()
doesn't make sense, since changing the XIP option on remount isn't
allowed.  It also doesn't make sense to re-check whether blocksize is
supported since it can't change between mounts.

Replace the call to ext2_xip_verify_sb() in ext2_fill_super() with the
equivalent check and delete the definition.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext2/super.c | 33 ++++++++++++---------------------
 fs/ext2/xip.c   | 12 ------------
 fs/ext2/xip.h   |  2 --
 3 files changed, 12 insertions(+), 35 deletions(-)

diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 20d6697..3a1db39 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -868,9 +868,6 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 		((EXT2_SB(sb)->s_mount_opt & EXT2_MOUNT_POSIX_ACL) ?
 		 MS_POSIXACL : 0);
 
-	ext2_xip_verify_sb(sb); /* see if bdev supports xip, unset
-				    EXT2_MOUNT_XIP if not */
-
 	if (le32_to_cpu(es->s_rev_level) == EXT2_GOOD_OLD_REV &&
 	    (EXT2_HAS_COMPAT_FEATURE(sb, ~0U) ||
 	     EXT2_HAS_RO_COMPAT_FEATURE(sb, ~0U) ||
@@ -900,11 +897,17 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 
 	blocksize = BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-	if (ext2_use_xip(sb) && blocksize != PAGE_SIZE) {
-		if (!silent)
+	if (sbi->s_mount_opt & EXT2_MOUNT_XIP) {
+		if (blocksize != PAGE_SIZE) {
 			ext2_msg(sb, KERN_ERR,
-				"error: unsupported blocksize for xip");
-		goto failed_mount;
+					"error: unsupported blocksize for xip");
+			goto failed_mount;
+		}
+		if (!sb->s_bdev->bd_disk->fops->direct_access) {
+			ext2_msg(sb, KERN_ERR,
+					"error: device does not support xip");
+			goto failed_mount;
+		}
 	}
 
 	/* If the blocksize doesn't match, re-read the thing.. */
@@ -1249,7 +1252,6 @@ static int ext2_remount (struct super_block * sb, int * flags, char * data)
 {
 	struct ext2_sb_info * sbi = EXT2_SB(sb);
 	struct ext2_super_block * es;
-	unsigned long old_mount_opt = sbi->s_mount_opt;
 	struct ext2_mount_options old_opts;
 	unsigned long old_sb_flags;
 	int err;
@@ -1273,22 +1275,11 @@ static int ext2_remount (struct super_block * sb, int * flags, char * data)
 	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
 		((sbi->s_mount_opt & EXT2_MOUNT_POSIX_ACL) ? MS_POSIXACL : 0);
 
-	ext2_xip_verify_sb(sb); /* see if bdev supports xip, unset
-				    EXT2_MOUNT_XIP if not */
-
-	if ((ext2_use_xip(sb)) && (sb->s_blocksize != PAGE_SIZE)) {
-		ext2_msg(sb, KERN_WARNING,
-			"warning: unsupported blocksize for xip");
-		err = -EINVAL;
-		goto restore_opts;
-	}
-
 	es = sbi->s_es;
-	if ((sbi->s_mount_opt ^ old_mount_opt) & EXT2_MOUNT_XIP) {
+	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_XIP) {
 		ext2_msg(sb, KERN_WARNING, "warning: refusing change of "
 			 "xip flag with busy inodes while remounting");
-		sbi->s_mount_opt &= ~EXT2_MOUNT_XIP;
-		sbi->s_mount_opt |= old_mount_opt & EXT2_MOUNT_XIP;
+		sbi->s_mount_opt ^= EXT2_MOUNT_XIP;
 	}
 	if ((*flags & MS_RDONLY) == (sb->s_flags & MS_RDONLY)) {
 		spin_unlock(&sbi->s_lock);
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index 132d4da..66ca113 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -13,15 +13,3 @@
 #include "ext2.h"
 #include "xip.h"
 
-void ext2_xip_verify_sb(struct super_block *sb)
-{
-	struct ext2_sb_info *sbi = EXT2_SB(sb);
-
-	if ((sbi->s_mount_opt & EXT2_MOUNT_XIP) &&
-	    !sb->s_bdev->bd_disk->fops->direct_access) {
-		sbi->s_mount_opt &= (~EXT2_MOUNT_XIP);
-		ext2_msg(sb, KERN_WARNING,
-			     "warning: ignoring xip option - "
-			     "not supported by bdev");
-	}
-}
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index e7b9f0a..87eeb04 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -6,13 +6,11 @@
  */
 
 #ifdef CONFIG_EXT2_FS_XIP
-extern void ext2_xip_verify_sb (struct super_block *);
 static inline int ext2_use_xip (struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
 }
 #else
-#define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #endif
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
