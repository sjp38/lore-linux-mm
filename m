Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4B6BE6B005C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:37 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 23/23] ramfs: enable transparent huge page cache
Date: Sun,  4 Aug 2013 05:17:25 +0300
Message-Id: <1375582645-29274-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

ramfs is the most simple fs from page cache point of view. Let's start
transparent huge page cache enabling here.

ramfs pages are not movable[1] and switching to transhuge pages doesn't
affect that. We need to fix this eventually.

[1] http://lkml.org/lkml/2013/4/2/720

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ramfs/file-mmu.c | 3 ++-
 fs/ramfs/inode.c    | 6 +++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 4884ac5..3236e41 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -32,7 +32,7 @@
 
 const struct address_space_operations ramfs_aops = {
 	.readpage	= simple_readpage,
-	.write_begin	= simple_write_begin,
+	.write_begin	= simple_thp_write_begin,
 	.write_end	= simple_write_end,
 	.set_page_dirty = __set_page_dirty_no_writeback,
 };
@@ -47,6 +47,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
 	.llseek		= generic_file_llseek,
+	.release	= simple_thp_release,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index 39d1465..5dafdfc 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -61,7 +61,11 @@ struct inode *ramfs_get_inode(struct super_block *sb,
 		inode_init_owner(inode, dir, mode);
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
-		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
+		/*
+		 * TODO: make ramfs pages movable
+		 */
+		mapping_set_gfp_mask(inode->i_mapping,
+				GFP_TRANSHUGE & ~__GFP_MOVABLE);
 		mapping_set_unevictable(inode->i_mapping);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
