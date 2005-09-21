Date: Wed, 21 Sep 2005 11:25:15 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/4] kill hugelbfs_do_delete_inode
Message-ID: <20050921092515.GC22544@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@ftp.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlbfs_do_delete_inode is the same as generic_delete_inode now, so
remove it in favour of the latter.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2005-09-19 12:53:32.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2005-09-19 12:54:28.000000000 +0200
@@ -229,42 +229,6 @@
 	clear_inode(inode);
 }
 
-static void hugetlbfs_do_delete_inode(struct inode *inode)
-{
-	struct super_operations *op = inode->i_sb->s_op;
-
-	list_del_init(&inode->i_list);
-	list_del_init(&inode->i_sb_list);
-	inode->i_state |= I_FREEING;
-	inodes_stat.nr_inodes--;
-	spin_unlock(&inode_lock);
-
-	security_inode_delete(inode);
-
-	if (op->delete_inode) {
-		void (*delete)(struct inode *) = op->delete_inode;
-		if (!is_bad_inode(inode))
-			DQUOT_INIT(inode);
-		/* Filesystems implementing their own
-		 * s_op->delete_inode are required to call
-		 * truncate_inode_pages and clear_inode()
-		 * internally
-		 */
-		delete(inode);
-	} else {
-		truncate_inode_pages(&inode->i_data, 0);
-		clear_inode(inode);
-	}
-
-	spin_lock(&inode_lock);
-	hlist_del_init(&inode->i_hash);
-	spin_unlock(&inode_lock);
-	wake_up_inode(inode);
-	if (inode->i_state != I_CLEAR)
-		BUG();
-	destroy_inode(inode);
-}
-
 static void hugetlbfs_forget_inode(struct inode *inode)
 {
 	struct super_block *super_block = inode->i_sb;
@@ -301,7 +265,7 @@
 static void hugetlbfs_drop_inode(struct inode *inode)
 {
 	if (!inode->i_nlink)
-		hugetlbfs_do_delete_inode(inode);
+		generic_delete_inode(inode);
 	else
 		hugetlbfs_forget_inode(inode);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
