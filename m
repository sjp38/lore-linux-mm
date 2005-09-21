Date: Wed, 21 Sep 2005 11:24:23 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/4] hugetlbfs: clean up hugetlbfs_delete_inode
Message-ID: <20050921092423.GB22544@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@ftp.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make hugetlbfs looks the same as generic_detelte_inode, fixing a bunch
of missing updates to it at the same time. Rename it to
hugetlbfs_do_delete_inode and add a real hugetlbfs_delete_inode that
implements ->delete_inode.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2005-09-19 12:46:30.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2005-09-20 23:57:52.000000000 +0200
@@ -224,19 +224,44 @@
 
 static void hugetlbfs_delete_inode(struct inode *inode)
 {
-	hlist_del_init(&inode->i_hash);
+	if (inode->i_data.nrpages)
+		truncate_hugepages(&inode->i_data, 0);
+	clear_inode(inode);
+}
+
+static void hugetlbfs_do_delete_inode(struct inode *inode)
+{
+	struct super_operations *op = inode->i_sb->s_op;
+
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
 	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
 
-	if (inode->i_data.nrpages)
-		truncate_hugepages(&inode->i_data, 0);
-
 	security_inode_delete(inode);
 
-	clear_inode(inode);
+	if (op->delete_inode) {
+		void (*delete)(struct inode *) = op->delete_inode;
+		if (!is_bad_inode(inode))
+			DQUOT_INIT(inode);
+		/* Filesystems implementing their own
+		 * s_op->delete_inode are required to call
+		 * truncate_inode_pages and clear_inode()
+		 * internally
+		 */
+		delete(inode);
+	} else {
+		truncate_inode_pages(&inode->i_data, 0);
+		clear_inode(inode);
+	}
+
+	spin_lock(&inode_lock);
+	hlist_del_init(&inode->i_hash);
+	spin_unlock(&inode_lock);
+	wake_up_inode(inode);
+	if (inode->i_state != I_CLEAR)
+		BUG();
 	destroy_inode(inode);
 }
 
@@ -276,7 +301,7 @@
 static void hugetlbfs_drop_inode(struct inode *inode)
 {
 	if (!inode->i_nlink)
-		hugetlbfs_delete_inode(inode);
+		hugetlbfs_do_delete_inode(inode);
 	else
 		hugetlbfs_forget_inode(inode);
 }
@@ -598,6 +623,7 @@
 	.alloc_inode    = hugetlbfs_alloc_inode,
 	.destroy_inode  = hugetlbfs_destroy_inode,
 	.statfs		= hugetlbfs_statfs,
+	.delete_inode	= hugetlbfs_delete_inode,
 	.drop_inode	= hugetlbfs_drop_inode,
 	.put_super	= hugetlbfs_put_super,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
