Date: Wed, 21 Sep 2005 11:26:44 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/4] cleanup hugelbfs_forget_inode
Message-ID: <20050921092644.GD22544@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@ftp.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Reformat hugelbfs_forget_inode and add the missing but harmless
write_inode_now call.  It looks the same as generic_forget_inode now
except for the call to truncate_hugepages instead of
truncate_inode_pages.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2005-09-21 00:01:50.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2005-09-21 11:09:23.000000000 +0200
@@ -231,25 +231,28 @@
 
 static void hugetlbfs_forget_inode(struct inode *inode)
 {
-	struct super_block *super_block = inode->i_sb;
+	struct super_block *sb = inode->i_sb;
 
-	if (hlist_unhashed(&inode->i_hash))
-		goto out_truncate;
-
-	if (!(inode->i_state & (I_DIRTY|I_LOCK))) {
-		list_del(&inode->i_list);
-		list_add(&inode->i_list, &inode_unused);
-	}
-	inodes_stat.nr_unused++;
-	if (!super_block || (super_block->s_flags & MS_ACTIVE)) {
+	if (!hlist_unhashed(&inode->i_hash)) {
+		if (!(inode->i_state & (I_DIRTY|I_LOCK)))
+			list_move(&inode->i_list, &inode_unused);
+		inodes_stat.nr_unused++;
+		if (!sb || (sb->s_flags & MS_ACTIVE)) {
+			spin_unlock(&inode_lock);
+			return;
+		}
+		inode->i_state |= I_WILL_FREE;
 		spin_unlock(&inode_lock);
-		return;
+		/*
+		 * write_inode_now is a noop as we set BDI_CAP_NO_WRITEBACK
+		 * in our backing_dev_info.
+		 */
+		write_inode_now(inode, 1);
+		spin_lock(&inode_lock);
+		inode->i_state &= ~I_WILL_FREE;
+		inodes_stat.nr_unused--;
+		hlist_del_init(&inode->i_hash);
 	}
-
-	/* write_inode_now() ? */
-	inodes_stat.nr_unused--;
-	hlist_del_init(&inode->i_hash);
-out_truncate:
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
@@ -257,7 +260,6 @@
 	spin_unlock(&inode_lock);
 	if (inode->i_data.nrpages)
 		truncate_hugepages(&inode->i_data, 0);
-
 	clear_inode(inode);
 	destroy_inode(inode);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
