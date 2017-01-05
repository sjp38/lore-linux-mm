Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C08DB6B0261
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:04:04 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 189so660039464oif.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:04:04 -0800 (PST)
Received: from da1vs02.rockwellcollins.com (da1vs02.rockwellcollins.com. [205.175.227.29])
        by mx.google.com with ESMTPS id s185si33485262oia.235.2017.01.05.14.04.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 14:04:04 -0800 (PST)
From: David Graziano <david.graziano@rockwellcollins.com>
Subject: [PATCH v4 2/3] shmem: use simple initxattrs callback
Date: Thu,  5 Jan 2017 16:03:42 -0600
Message-Id: <1483653823-22018-3-git-send-email-david.graziano@rockwellcollins.com>
In-Reply-To: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
References: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org, paul@paul-moore.com
Cc: agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, sds@tycho.nsa.gov, linux-kernel@vger.kernel.org, David Graziano <david.graziano@rockwellcollins.com>

Updates shmem to use the newly created simple_xattr_initxattrs()
function to minimize code duplication with other LSM callback
functions.

Signed-off-by: David Graziano <david.graziano@rockwellcollins.com>
---
 mm/shmem.c | 53 ++++++++++++-----------------------------------------
 1 file changed, 12 insertions(+), 41 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 971fc83..ef4bd52 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -33,6 +33,7 @@
 #include <linux/swap.h>
 #include <linux/uio.h>
 #include <linux/khugepaged.h>
+#include <linux/xattr.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -2140,7 +2141,7 @@ static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_short_symlink_operations;
 
 #ifdef CONFIG_TMPFS_XATTR
-static int shmem_initxattrs(struct inode *, const struct xattr *, void *);
+#define shmem_initxattrs simple_xattr_initxattrs
 #else
 #define shmem_initxattrs NULL
 #endif
@@ -2892,6 +2893,7 @@ static int
 shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 {
 	struct inode *inode;
+	struct shmem_inode_info *info;
 	int error = -ENOSPC;
 
 	inode = shmem_get_inode(dir->i_sb, dir, mode, dev, VM_NORESERVE);
@@ -2899,9 +2901,11 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 		error = simple_acl_create(dir, inode);
 		if (error)
 			goto out_iput;
+		info = SHMEM_I(inode);
 		error = security_inode_init_security(inode, dir,
 						     &dentry->d_name,
-						     shmem_initxattrs, NULL);
+						     shmem_initxattrs,
+						     &info->xattrs);
 		if (error && error != -EOPNOTSUPP)
 			goto out_iput;
 
@@ -2921,13 +2925,16 @@ static int
 shmem_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	struct inode *inode;
+	struct shmem_inode_info *info;
 	int error = -ENOSPC;
 
 	inode = shmem_get_inode(dir->i_sb, dir, mode, 0, VM_NORESERVE);
 	if (inode) {
+		info = SHMEM_I(inode);
 		error = security_inode_init_security(inode, dir,
 						     NULL,
-						     shmem_initxattrs, NULL);
+						     shmem_initxattrs,
+						     &info->xattrs);
 		if (error && error != -EOPNOTSUPP)
 			goto out_iput;
 		error = simple_acl_create(dir, inode);
@@ -3119,8 +3126,9 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	if (!inode)
 		return -ENOSPC;
 
+	info = SHMEM_I(inode);
 	error = security_inode_init_security(inode, dir, &dentry->d_name,
-					     shmem_initxattrs, NULL);
+					     shmem_initxattrs, &info->xattrs);
 	if (error) {
 		if (error != -EOPNOTSUPP) {
 			iput(inode);
@@ -3129,7 +3137,6 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		error = 0;
 	}
 
-	info = SHMEM_I(inode);
 	inode->i_size = len-1;
 	if (len <= SHORT_SYMLINK_LEN) {
 		inode->i_link = kmemdup(symname, len, GFP_KERNEL);
@@ -3198,42 +3205,6 @@ static const char *shmem_get_link(struct dentry *dentry,
  * filesystem level, though.
  */
 
-/*
- * Callback for security_inode_init_security() for acquiring xattrs.
- */
-static int shmem_initxattrs(struct inode *inode,
-			    const struct xattr *xattr_array,
-			    void *fs_info)
-{
-	struct shmem_inode_info *info = SHMEM_I(inode);
-	const struct xattr *xattr;
-	struct simple_xattr *new_xattr;
-	size_t len;
-
-	for (xattr = xattr_array; xattr->name != NULL; xattr++) {
-		new_xattr = simple_xattr_alloc(xattr->value, xattr->value_len);
-		if (!new_xattr)
-			return -ENOMEM;
-
-		len = strlen(xattr->name) + 1;
-		new_xattr->name = kmalloc(XATTR_SECURITY_PREFIX_LEN + len,
-					  GFP_KERNEL);
-		if (!new_xattr->name) {
-			kfree(new_xattr);
-			return -ENOMEM;
-		}
-
-		memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
-		       XATTR_SECURITY_PREFIX_LEN);
-		memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
-		       xattr->name, len);
-
-		simple_xattr_list_add(&info->xattrs, new_xattr);
-	}
-
-	return 0;
-}
-
 static int shmem_xattr_handler_get(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
 				   const char *name, void *buffer, size_t size)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
