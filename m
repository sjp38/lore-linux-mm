Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 543DE6B0071
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:28:01 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so5556418pdj.22
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:28:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id sp6si9801987pac.150.2014.08.01.06.27.56
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 06:27:56 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v9 17/22] ext2: Remove ext2_aops_xip
Date: Fri,  1 Aug 2014 09:27:33 -0400
Message-Id: <db1a09c560e0258a50cf1220140c89479a9f5725.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
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
index 154cbcf..034fd42 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -891,11 +891,6 @@ const struct address_space_operations ext2_aops = {
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
@@ -1394,7 +1389,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
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
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
