Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 23E966B007E
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 04:46:17 -0500 (EST)
Received: by pbbrp12 with SMTP id rp12so4351193pbb.25
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 01:46:16 -0800 (PST)
MIME-Version: 1.0
From: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
Subject: [PATCH] tmpfs: security xattr setting on inode creation
Date: Thu, 23 Feb 2012 11:46:05 +0200
Message-Id: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jarkko Sakkinen <jarkko.sakkinen@intel.com>

Adds to generic xattr support introduced in Linux 3.0 by
implementing initxattrs callback. This enables consulting
of security attributes from LSM and EVM when inode is
created.

Signed-off-by: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
---
 mm/shmem.c |   82 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 66 insertions(+), 16 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7a45ad0..cd367b1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1478,6 +1478,64 @@ static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 }
 
 /*
+ * Allocate new xattr.
+ */
+static int shmem_xattr_alloc(size_t size, struct shmem_xattr **new_xattr)
+{
+	/* wrap around? */
+	size_t len = sizeof(**new_xattr) + size;
+	if (len <= sizeof(**new_xattr))
+		return -ENOMEM;
+
+	*new_xattr = kmalloc(len, GFP_KERNEL);
+	if (*new_xattr == NULL)
+		return -ENOMEM;
+
+	(*new_xattr)->size = size;
+	return 0;
+}
+
+/*
+ * Callback for security_inode_init_security() for acquiring xattrs.
+ */
+static int shmem_initxattrs(struct inode *inode,
+			    const struct xattr *xattr_array,
+			    void *fs_info)
+{
+	const struct xattr *xattr;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_xattr *new_xattr = NULL;
+	size_t len;
+	int err = 0;
+
+	for (xattr = xattr_array; xattr->name != NULL; xattr++) {
+		err = shmem_xattr_alloc(xattr->value_len, &new_xattr);
+		if (err < 0)
+			return err;
+
+		len = strlen(xattr->name) + 1;
+		new_xattr->name = kmalloc(XATTR_SECURITY_PREFIX_LEN + len,
+					  GFP_KERNEL);
+		if (new_xattr->name == NULL) {
+			kfree(new_xattr);
+			return -ENOMEM;
+		}
+
+		memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
+		       XATTR_SECURITY_PREFIX_LEN);
+		memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
+		       xattr->name, len);
+		memcpy(new_xattr->value, xattr->value, xattr->value_len);
+
+		spin_lock(&info->lock);
+		list_add(&new_xattr->list, &info->xattr_list);
+		spin_unlock(&info->lock);
+	}
+
+	return 0;
+}
+
+/*
  * File creation. Allocate an inode, and we're done..
  */
 static int
@@ -1490,7 +1548,7 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 	if (inode) {
 		error = security_inode_init_security(inode, dir,
 						     &dentry->d_name,
-						     NULL, NULL);
+						     &shmem_initxattrs, NULL);
 		if (error) {
 			if (error != -EOPNOTSUPP) {
 				iput(inode);
@@ -1630,7 +1688,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		return -ENOSPC;
 
 	error = security_inode_init_security(inode, dir, &dentry->d_name,
-					     NULL, NULL);
+					     &shmem_initxattrs, NULL);
 	if (error) {
 		if (error != -EOPNOTSUPP) {
 			iput(inode);
@@ -1731,26 +1789,19 @@ static int shmem_xattr_get(struct dentry *dentry, const char *name,
 	return ret;
 }
 
-static int shmem_xattr_set(struct dentry *dentry, const char *name,
+static int shmem_xattr_set(struct inode *inode, const char *name,
 			   const void *value, size_t size, int flags)
 {
-	struct inode *inode = dentry->d_inode;
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_xattr *xattr;
 	struct shmem_xattr *new_xattr = NULL;
-	size_t len;
 	int err = 0;
 
 	/* value == NULL means remove */
 	if (value) {
-		/* wrap around? */
-		len = sizeof(*new_xattr) + size;
-		if (len <= sizeof(*new_xattr))
-			return -ENOMEM;
-
-		new_xattr = kmalloc(len, GFP_KERNEL);
-		if (!new_xattr)
-			return -ENOMEM;
+		err = shmem_xattr_alloc(size, &new_xattr);
+		if (err < 0)
+			return err;
 
 		new_xattr->name = kstrdup(name, GFP_KERNEL);
 		if (!new_xattr->name) {
@@ -1758,7 +1809,6 @@ static int shmem_xattr_set(struct dentry *dentry, const char *name,
 			return -ENOMEM;
 		}
 
-		new_xattr->size = size;
 		memcpy(new_xattr->value, value, size);
 	}
 
@@ -1858,7 +1908,7 @@ static int shmem_setxattr(struct dentry *dentry, const char *name,
 	if (size == 0)
 		value = "";  /* empty EA, do not remove */
 
-	return shmem_xattr_set(dentry, name, value, size, flags);
+	return shmem_xattr_set(dentry->d_inode, name, value, size, flags);
 
 }
 
@@ -1878,7 +1928,7 @@ static int shmem_removexattr(struct dentry *dentry, const char *name)
 	if (err)
 		return err;
 
-	return shmem_xattr_set(dentry, name, NULL, 0, XATTR_REPLACE);
+	return shmem_xattr_set(dentry->d_inode, name, NULL, 0, XATTR_REPLACE);
 }
 
 static bool xattr_is_trusted(const char *name)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
