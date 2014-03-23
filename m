Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id ED4086B0110
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:24 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so4520535pbc.4
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id se7si7625602pbb.139.2014.03.23.12.09.22
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:22 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 16/22] ext2: Remove ext2_aops_xip
Date: Sun, 23 Mar 2014 15:08:42 -0400
Message-Id: <0b6512aa46a504459f41d3c609fc20c93d4a911a.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

We shouldn't need a special address_space_operations any more

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext2/ext2.h  | 1 -
 fs/ext2/inode.c | 7 +------
 fs/ext2/namei.c | 4 ++--
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index b30c3bd..b8b1c11 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -793,7 +793,6 @@ extern const struct file_operations ext2_xip_file_operations;
 
 /* inode.c */
 extern const struct address_space_operations ext2_aops;
-extern const struct address_space_operations ext2_aops_xip;
 extern const struct address_space_operations ext2_nobh_aops;
 
 /* namei.c */
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 67124f0..7ca76da 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -890,11 +890,6 @@ const struct address_space_operations ext2_aops = {
 	.error_remove_page	= generic_error_remove_page,
 };
 
-const struct address_space_operations ext2_aops_xip = {
-	.bmap			= ext2_bmap,
-	.direct_IO		= ext2_direct_IO,
-};
-
 const struct address_space_operations ext2_nobh_aops = {
 	.readpage		= ext2_readpage,
 	.readpages		= ext2_readpages,
@@ -1393,7 +1388,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext2_file_inode_operations;
 		if (test_opt(inode->i_sb, XIP)) {
-			inode->i_mapping->a_ops = &ext2_aops_xip;
+			inode->i_mapping->a_ops = &ext2_aops;
 			inode->i_fop = &ext2_xip_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 7ca803f..0db888c 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -105,7 +105,7 @@ static int ext2_create (struct inode * dir, struct dentry * dentry, umode_t mode
 
 	inode->i_op = &ext2_file_inode_operations;
 	if (test_opt(inode->i_sb, XIP)) {
-		inode->i_mapping->a_ops = &ext2_aops_xip;
+		inode->i_mapping->a_ops = &ext2_aops;
 		inode->i_fop = &ext2_xip_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
@@ -126,7 +126,7 @@ static int ext2_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 
 	inode->i_op = &ext2_file_inode_operations;
 	if (test_opt(inode->i_sb, XIP)) {
-		inode->i_mapping->a_ops = &ext2_aops_xip;
+		inode->i_mapping->a_ops = &ext2_aops;
 		inode->i_fop = &ext2_xip_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
