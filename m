Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D9BD96B00F9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:23 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so7891016pde.28
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id sh5si3796545pbc.80.2014.02.25.06.19.22
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:22 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 13/22] ext2: Remove ext2_use_xip
Date: Tue, 25 Feb 2014 09:18:29 -0500
Message-Id: <1393337918-28265-14-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

Replace ext2_use_xip() with test_opt(XIP) which expands to the same code

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext2/ext2.h  | 4 ++++
 fs/ext2/inode.c | 2 +-
 fs/ext2/namei.c | 4 ++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index d9a17d0..5ecf570 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -380,7 +380,11 @@ struct ext2_inode {
 #define EXT2_MOUNT_NO_UID32		0x000200  /* Disable 32-bit UIDs */
 #define EXT2_MOUNT_XATTR_USER		0x004000  /* Extended user attributes */
 #define EXT2_MOUNT_POSIX_ACL		0x008000  /* POSIX Access Control Lists */
+#ifdef CONFIG_FS_XIP
 #define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
+#else
+#define EXT2_MOUNT_XIP			0
+#endif
 #define EXT2_MOUNT_USRQUOTA		0x020000  /* user quota */
 #define EXT2_MOUNT_GRPQUOTA		0x040000  /* group quota */
 #define EXT2_MOUNT_RESERVATION		0x080000  /* Preallocation */
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index a9346a9..2e587e2 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1393,7 +1393,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext2_file_inode_operations;
-		if (ext2_use_xip(inode->i_sb)) {
+		if (test_opt(inode->i_sb, XIP)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index c268d0a..846c356 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -105,7 +105,7 @@ static int ext2_create (struct inode * dir, struct dentry * dentry, umode_t mode
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (ext2_use_xip(inode->i_sb)) {
+	if (test_opt(inode->i_sb, XIP)) {
 		inode->i_mapping->a_ops = &ext2_aops_xip;
 		inode->i_fop = &ext2_xip_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
@@ -126,7 +126,7 @@ static int ext2_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (ext2_use_xip(inode->i_sb)) {
+	if (test_opt(inode->i_sb, XIP)) {
 		inode->i_mapping->a_ops = &ext2_aops_xip;
 		inode->i_fop = &ext2_xip_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
