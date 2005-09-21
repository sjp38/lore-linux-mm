Date: Wed, 21 Sep 2005 11:21:56 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/4] hugetlbfs: move free_inodes accounting
Message-ID: <20050921092156.GA22544@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@ftp.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move hugetlbfs accounting into ->alloc_inode / ->destroy_inode.  This
keeps the code simpler, fixes a loeak where a failing inode allocation
wouldn't decrement the counter and moves hugetlbfs_delete_inode and
hugetlbfs_forget_inode closer to their generic counterparts.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2005-09-18 13:47:32.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2005-09-19 12:41:37.000000000 +0200
@@ -224,8 +224,6 @@
 
 static void hugetlbfs_delete_inode(struct inode *inode)
 {
-	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(inode->i_sb);
-
 	hlist_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
@@ -238,12 +236,6 @@
 
 	security_inode_delete(inode);
 
-	if (sbinfo->free_inodes >= 0) {
-		spin_lock(&sbinfo->stat_lock);
-		sbinfo->free_inodes++;
-		spin_unlock(&sbinfo->stat_lock);
-	}
-
 	clear_inode(inode);
 	destroy_inode(inode);
 }
@@ -251,7 +243,6 @@
 static void hugetlbfs_forget_inode(struct inode *inode)
 {
 	struct super_block *super_block = inode->i_sb;
-	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(super_block);
 
 	if (hlist_unhashed(&inode->i_hash))
 		goto out_truncate;
@@ -278,12 +269,6 @@
 	if (inode->i_data.nrpages)
 		truncate_hugepages(&inode->i_data, 0);
 
-	if (sbinfo->free_inodes >= 0) {
-		spin_lock(&sbinfo->stat_lock);
-		sbinfo->free_inodes++;
-		spin_unlock(&sbinfo->stat_lock);
-	}
-
 	clear_inode(inode);
 	destroy_inode(inode);
 }
@@ -379,17 +364,6 @@
 					gid_t gid, int mode, dev_t dev)
 {
 	struct inode *inode;
-	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(sb);
-
-	if (sbinfo->free_inodes >= 0) {
-		spin_lock(&sbinfo->stat_lock);
-		if (!sbinfo->free_inodes) {
-			spin_unlock(&sbinfo->stat_lock);
-			return NULL;
-		}
-		sbinfo->free_inodes--;
-		spin_unlock(&sbinfo->stat_lock);
-	}
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -531,29 +505,51 @@
 	}
 }
 
+static inline int hugetlbfs_inc_free_inodes(struct hugetlbfs_sb_info *sbinfo)
+{
+	if (sbinfo->free_inodes >= 0) {
+		spin_lock(&sbinfo->stat_lock);
+		if (unlikely(!sbinfo->free_inodes)) {
+			spin_unlock(&sbinfo->stat_lock);
+			return 0;
+		}
+		sbinfo->free_inodes--;
+		spin_unlock(&sbinfo->stat_lock);
+	}
+
+	return 1;
+}
+
+static void hugetlbfs_dec_free_inodes(struct hugetlbfs_sb_info *sbinfo)
+{
+	if (sbinfo->free_inodes >= 0) {
+		spin_lock(&sbinfo->stat_lock);
+		sbinfo->free_inodes++;
+		spin_unlock(&sbinfo->stat_lock);
+	}
+}
+
+
 static kmem_cache_t *hugetlbfs_inode_cachep;
 
 static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 {
+	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(sb);
 	struct hugetlbfs_inode_info *p;
 
+	if (unlikely(!hugetlbfs_inc_free_inodes(sbinfo)))
+		return NULL;
 	p = kmem_cache_alloc(hugetlbfs_inode_cachep, SLAB_KERNEL);
-	if (!p)
+	if (unlikely(!p)) {
+		hugetlbfs_dec_free_inodes(sbinfo);
 		return NULL;
+	}
 	return &p->vfs_inode;
 }
 
-static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
-{
-	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
-
-	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
-	    SLAB_CTOR_CONSTRUCTOR)
-		inode_init_once(&ei->vfs_inode);
-}
-
 static void hugetlbfs_destroy_inode(struct inode *inode)
 {
+	hugetlbfs_dec_free_inodes(HUGETLBFS_SB(inode->i_sb));
 	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
 	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
 }
@@ -565,6 +561,16 @@
 	.set_page_dirty	= hugetlbfs_set_page_dirty,
 };
 
+
+static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+{
+	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
+
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
+	    SLAB_CTOR_CONSTRUCTOR)
+		inode_init_once(&ei->vfs_inode);
+}
+
 struct file_operations hugetlbfs_file_operations = {
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= simple_sync_file,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
