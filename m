Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 79EAB6B0088
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:53 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/13] NFS: Remove requirement for inode->i_mutex from nfs_invalidate_mapping
Date: Wed, 10 Feb 2010 12:03:32 -0500
Message-Id: <1265821413-21618-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-10-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-11-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c           |    2 +-
 fs/nfs/inode.c         |   41 +----------------------------------------
 fs/nfs/symlink.c       |    2 +-
 include/linux/nfs_fs.h |    1 -
 4 files changed, 3 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3c7f03b..a1f6b44 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -560,7 +560,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->entry = &my_entry;
 
 	nfs_block_sillyrename(dentry);
-	res = nfs_revalidate_mapping_nolock(inode, filp->f_mapping);
+	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0)
 		goto out;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 38e79e4..f50ad09 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -754,7 +754,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	return __nfs_revalidate_inode(server, inode);
 }
 
-static int nfs_invalidate_mapping_nolock(struct inode *inode, struct address_space *mapping)
+static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	
@@ -775,49 +775,10 @@ static int nfs_invalidate_mapping_nolock(struct inode *inode, struct address_spa
 	return 0;
 }
 
-static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
-{
-	int ret = 0;
-
-	mutex_lock(&inode->i_mutex);
-	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA) {
-		ret = nfs_sync_mapping(mapping);
-		if (ret == 0)
-			ret = nfs_invalidate_mapping_nolock(inode, mapping);
-	}
-	mutex_unlock(&inode->i_mutex);
-	return ret;
-}
-
-/**
- * nfs_revalidate_mapping_nolock - Revalidate the pagecache
- * @inode - pointer to host inode
- * @mapping - pointer to mapping
- */
-int nfs_revalidate_mapping_nolock(struct inode *inode, struct address_space *mapping)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	int ret = 0;
-
-	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-			|| nfs_attribute_timeout(inode) || NFS_STALE(inode)) {
-		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-		if (ret < 0)
-			goto out;
-	}
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
-		ret = nfs_invalidate_mapping_nolock(inode, mapping);
-out:
-	return ret;
-}
-
 /**
  * nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
- *
- * This version of the function will take the inode->i_mutex and attempt to
- * flush out all dirty data if it needs to invalidate the page cache.
  */
 int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 412738d..2ea9e5c 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -50,7 +50,7 @@ static void *nfs_follow_link(struct dentry *dentry, struct nameidata *nd)
 	struct page *page;
 	void *err;
 
-	err = ERR_PTR(nfs_revalidate_mapping_nolock(inode, inode->i_mapping));
+	err = ERR_PTR(nfs_revalidate_mapping(inode, inode->i_mapping));
 	if (err)
 		goto read_failed;
 	page = read_cache_page(&inode->i_data, 0,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b1e0877..5af42eb 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -346,7 +346,6 @@ extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
-extern int nfs_revalidate_mapping_nolock(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
