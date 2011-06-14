Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 96EE26B00E8
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:57:57 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p5EAvhEq017262
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:57:43 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz29.hot.corp.google.com with ESMTP id p5EAvfX5016182
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:57:42 -0700
Received: by pvc21 with SMTP id 21so3732952pvc.39
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:57:41 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:57:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 11/12] tmpfs: use kmemdup for short symlinks
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106140356240.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

But we've not yet removed the old swp_entry_t i_direct[16] from
shmem_inode_info.  That's because it was still being shared with the
inline symlink.  Remove it now (saving 64 or 128 bytes from shmem inode
size), and use kmemdup() for short symlinks, say, those up to 128 bytes.

I wonder why mpol_free_shared_policy() is done in shmem_destroy_inode()
rather than shmem_evict_inode(), where we usually do such freeing?  I
guess it doesn't matter, and I'm not into NUMA mpol testing right now.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/shmem_fs.h |   11 +++--------
 mm/shmem.c               |   31 ++++++++++++++++++-------------
 2 files changed, 21 insertions(+), 21 deletions(-)

--- linux.orig/include/linux/shmem_fs.h	2011-06-14 00:45:20.625161293 -0700
+++ linux/include/linux/shmem_fs.h	2011-06-14 00:54:49.667983016 -0700
@@ -8,20 +8,15 @@
 
 /* inode in-kernel data */
 
-#define SHMEM_NR_DIRECT 16
-
-#define SHMEM_SYMLINK_INLINE_LEN (SHMEM_NR_DIRECT * sizeof(swp_entry_t))
-
 struct shmem_inode_info {
 	spinlock_t		lock;
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
-	unsigned long		swapped;	/* subtotal assigned to swap */
-	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	union {
-		swp_entry_t	i_direct[SHMEM_NR_DIRECT]; /* first blocks */
-		char		inline_symlink[SHMEM_SYMLINK_INLINE_LEN];
+		unsigned long	swapped;	/* subtotal assigned to swap */
+		char		*symlink;	/* unswappable short symlink */
 	};
+	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct list_head	xattr_list;	/* list of shmem_xattr */
 	struct inode		vfs_inode;
--- linux.orig/mm/shmem.c	2011-06-14 00:54:36.499917716 -0700
+++ linux/mm/shmem.c	2011-06-14 00:54:49.667983016 -0700
@@ -73,6 +73,9 @@ static struct vfsmount *shm_mnt;
 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
 
+/* Symlink up to this size is kmalloc'ed instead of using a swappable page */
+#define SHORT_SYMLINK_LEN 128
+
 struct shmem_xattr {
 	struct list_head list;	/* anchored by shmem_inode_info->xattr_list */
 	char *name;		/* xattr name */
@@ -585,7 +588,8 @@ static void shmem_evict_inode(struct ino
 			list_del_init(&info->swaplist);
 			mutex_unlock(&shmem_swaplist_mutex);
 		}
-	}
+	} else
+		kfree(info->symlink);
 
 	list_for_each_entry_safe(xattr, nxattr, &info->xattr_list, list) {
 		kfree(xattr->name);
@@ -1173,7 +1177,7 @@ static struct inode *shmem_get_inode(str
 
 #ifdef CONFIG_TMPFS
 static const struct inode_operations shmem_symlink_inode_operations;
-static const struct inode_operations shmem_symlink_inline_operations;
+static const struct inode_operations shmem_short_symlink_operations;
 
 static int
 shmem_write_begin(struct file *file, struct address_space *mapping,
@@ -1638,10 +1642,13 @@ static int shmem_symlink(struct inode *d
 
 	info = SHMEM_I(inode);
 	inode->i_size = len-1;
-	if (len <= SHMEM_SYMLINK_INLINE_LEN) {
-		/* do it inline */
-		memcpy(info->inline_symlink, symname, len);
-		inode->i_op = &shmem_symlink_inline_operations;
+	if (len <= SHORT_SYMLINK_LEN) {
+		info->symlink = kmemdup(symname, len, GFP_KERNEL);
+		if (!info->symlink) {
+			iput(inode);
+			return -ENOMEM;
+		}
+		inode->i_op = &shmem_short_symlink_operations;
 	} else {
 		error = shmem_getpage(inode, 0, &page, SGP_WRITE, NULL);
 		if (error) {
@@ -1664,9 +1671,9 @@ static int shmem_symlink(struct inode *d
 	return 0;
 }
 
-static void *shmem_follow_link_inline(struct dentry *dentry, struct nameidata *nd)
+static void *shmem_follow_short_symlink(struct dentry *dentry, struct nameidata *nd)
 {
-	nd_set_link(nd, SHMEM_I(dentry->d_inode)->inline_symlink);
+	nd_set_link(nd, SHMEM_I(dentry->d_inode)->symlink);
 	return NULL;
 }
 
@@ -1914,9 +1921,9 @@ static ssize_t shmem_listxattr(struct de
 }
 #endif /* CONFIG_TMPFS_XATTR */
 
-static const struct inode_operations shmem_symlink_inline_operations = {
+static const struct inode_operations shmem_short_symlink_operations = {
 	.readlink	= generic_readlink,
-	.follow_link	= shmem_follow_link_inline,
+	.follow_link	= shmem_follow_short_symlink,
 #ifdef CONFIG_TMPFS_XATTR
 	.setxattr	= shmem_setxattr,
 	.getxattr	= shmem_getxattr,
@@ -2259,10 +2266,8 @@ static void shmem_destroy_callback(struc
 
 static void shmem_destroy_inode(struct inode *inode)
 {
-	if ((inode->i_mode & S_IFMT) == S_IFREG) {
-		/* only struct inode is valid if it's an inline symlink */
+	if ((inode->i_mode & S_IFMT) == S_IFREG)
 		mpol_free_shared_policy(&SHMEM_I(inode)->policy);
-	}
 	call_rcu(&inode->i_rcu, shmem_destroy_callback);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
