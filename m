Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9326B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 08:45:08 -0500 (EST)
Received: by qgec40 with SMTP id c40so32631870qge.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:45:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d204si3477951qkb.109.2015.12.02.05.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 05:45:07 -0800 (PST)
From: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v2 06/11] tmpfs: Use xattr handler infrastructure
Date: Wed,  2 Dec 2015 14:44:38 +0100
Message-Id: <1449063883-22097-7-git-send-email-agruenba@redhat.com>
In-Reply-To: <1449063883-22097-1-git-send-email-agruenba@redhat.com>
References: <1449063883-22097-1-git-send-email-agruenba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Use the VFS xattr handler infrastructure and get rid of similar code in
the filesystem.  For implementing shmem_xattr_handler_set, we need a
version of simple_xattr_set which removes the attribute when value is
NULL.  Use this to implement kernfs_iop_removexattr as well.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: James Morris <james.l.morris@oracle.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 fs/kernfs/inode.c     |   2 +-
 fs/xattr.c            |  48 ++++++------------
 include/linux/xattr.h |   4 +-
 mm/shmem.c            | 131 ++++++++++++++++----------------------------------
 4 files changed, 60 insertions(+), 125 deletions(-)

diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
index 756dd56..f97e1f7 100644
--- a/fs/kernfs/inode.c
+++ b/fs/kernfs/inode.c
@@ -205,7 +205,7 @@ int kernfs_iop_removexattr(struct dentry *dentry, const char *name)
 	if (!attrs)
 		return -ENOMEM;
 
-	return simple_xattr_remove(&attrs->xattrs, name);
+	return simple_xattr_set(&attrs->xattrs, name, NULL, 0, XATTR_REPLACE);
 }
 
 ssize_t kernfs_iop_getxattr(struct dentry *dentry, const char *name, void *buf,
diff --git a/fs/xattr.c b/fs/xattr.c
index 418ad69..4ef8b37 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -851,8 +851,22 @@ int simple_xattr_get(struct simple_xattrs *xattrs, const char *name,
 	return ret;
 }
 
-static int __simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
-			      const void *value, size_t size, int flags)
+/**
+ * simple_xattr_set - xattr SET operation for in-memory/pseudo filesystems
+ * @xattrs: target simple_xattr list
+ * @name: name of the extended attribute
+ * @value: value of the xattr. If %NULL, will remove the attribute.
+ * @size: size of the new xattr
+ * @flags: %XATTR_{CREATE|REPLACE}
+ *
+ * %XATTR_CREATE is set, the xattr shouldn't exist already; otherwise fails
+ * with -EEXIST.  If %XATTR_REPLACE is set, the xattr should exist;
+ * otherwise, fails with -ENODATA.
+ *
+ * Returns 0 on success, -errno on failure.
+ */
+int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
+		     const void *value, size_t size, int flags)
 {
 	struct simple_xattr *xattr;
 	struct simple_xattr *new_xattr = NULL;
@@ -902,36 +916,6 @@ out:
 
 }
 
-/**
- * simple_xattr_set - xattr SET operation for in-memory/pseudo filesystems
- * @xattrs: target simple_xattr list
- * @name: name of the new extended attribute
- * @value: value of the new xattr. If %NULL, will remove the attribute
- * @size: size of the new xattr
- * @flags: %XATTR_{CREATE|REPLACE}
- *
- * %XATTR_CREATE is set, the xattr shouldn't exist already; otherwise fails
- * with -EEXIST.  If %XATTR_REPLACE is set, the xattr should exist;
- * otherwise, fails with -ENODATA.
- *
- * Returns 0 on success, -errno on failure.
- */
-int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
-		     const void *value, size_t size, int flags)
-{
-	if (size == 0)
-		value = ""; /* empty EA, do not remove */
-	return __simple_xattr_set(xattrs, name, value, size, flags);
-}
-
-/*
- * xattr REMOVE operation for in-memory/pseudo filesystems
- */
-int simple_xattr_remove(struct simple_xattrs *xattrs, const char *name)
-{
-	return __simple_xattr_set(xattrs, name, NULL, 0, XATTR_REPLACE);
-}
-
 static bool xattr_is_trusted(const char *name)
 {
 	return !strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN);
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 2d2d911..704c016 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -104,9 +104,7 @@ int simple_xattr_get(struct simple_xattrs *xattrs, const char *name,
 		     void *buffer, size_t size);
 int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
 		     const void *value, size_t size, int flags);
-int simple_xattr_remove(struct simple_xattrs *xattrs, const char *name);
-ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer,
-			  size_t size);
+ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer, size_t size);
 void simple_xattr_list_add(struct simple_xattrs *xattrs,
 			   struct simple_xattr *new_xattr);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 9187eee..fdfe6c8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2561,94 +2561,47 @@ static int shmem_initxattrs(struct inode *inode,
 	return 0;
 }
 
-static const struct xattr_handler *shmem_xattr_handlers[] = {
-#ifdef CONFIG_TMPFS_POSIX_ACL
-	&posix_acl_access_xattr_handler,
-	&posix_acl_default_xattr_handler,
-#endif
-	NULL
-};
-
-static int shmem_xattr_validate(const char *name)
-{
-	struct { const char *prefix; size_t len; } arr[] = {
-		{ XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN },
-		{ XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN }
-	};
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(arr); i++) {
-		size_t preflen = arr[i].len;
-		if (strncmp(name, arr[i].prefix, preflen) == 0) {
-			if (!name[preflen])
-				return -EINVAL;
-			return 0;
-		}
-	}
-	return -EOPNOTSUPP;
-}
-
-static ssize_t shmem_getxattr(struct dentry *dentry, const char *name,
-			      void *buffer, size_t size)
+static int shmem_xattr_handler_get(const struct xattr_handler *handler,
+				   struct dentry *dentry, const char *name,
+				   void *buffer, size_t size)
 {
 	struct shmem_inode_info *info = SHMEM_I(d_inode(dentry));
-	int err;
-
-	/*
-	 * If this is a request for a synthetic attribute in the system.*
-	 * namespace use the generic infrastructure to resolve a handler
-	 * for it via sb->s_xattr.
-	 */
-	if (!strncmp(name, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
-		return generic_getxattr(dentry, name, buffer, size);
-
-	err = shmem_xattr_validate(name);
-	if (err)
-		return err;
 
+	name = xattr_full_name(handler, name);
 	return simple_xattr_get(&info->xattrs, name, buffer, size);
 }
 
-static int shmem_setxattr(struct dentry *dentry, const char *name,
-			  const void *value, size_t size, int flags)
+static int shmem_xattr_handler_set(const struct xattr_handler *handler,
+				   struct dentry *dentry, const char *name,
+				   const void *value, size_t size, int flags)
 {
 	struct shmem_inode_info *info = SHMEM_I(d_inode(dentry));
-	int err;
-
-	/*
-	 * If this is a request for a synthetic attribute in the system.*
-	 * namespace use the generic infrastructure to resolve a handler
-	 * for it via sb->s_xattr.
-	 */
-	if (!strncmp(name, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
-		return generic_setxattr(dentry, name, value, size, flags);
-
-	err = shmem_xattr_validate(name);
-	if (err)
-		return err;
 
+	name = xattr_full_name(handler, name);
 	return simple_xattr_set(&info->xattrs, name, value, size, flags);
 }
 
-static int shmem_removexattr(struct dentry *dentry, const char *name)
-{
-	struct shmem_inode_info *info = SHMEM_I(d_inode(dentry));
-	int err;
-
-	/*
-	 * If this is a request for a synthetic attribute in the system.*
-	 * namespace use the generic infrastructure to resolve a handler
-	 * for it via sb->s_xattr.
-	 */
-	if (!strncmp(name, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
-		return generic_removexattr(dentry, name);
+static const struct xattr_handler shmem_security_xattr_handler = {
+	.prefix = XATTR_SECURITY_PREFIX,
+	.get = shmem_xattr_handler_get,
+	.set = shmem_xattr_handler_set,
+};
 
-	err = shmem_xattr_validate(name);
-	if (err)
-		return err;
+static const struct xattr_handler shmem_trusted_xattr_handler = {
+	.prefix = XATTR_TRUSTED_PREFIX,
+	.get = shmem_xattr_handler_get,
+	.set = shmem_xattr_handler_set,
+};
 
-	return simple_xattr_remove(&info->xattrs, name);
-}
+static const struct xattr_handler *shmem_xattr_handlers[] = {
+#ifdef CONFIG_TMPFS_POSIX_ACL
+	&posix_acl_access_xattr_handler,
+	&posix_acl_default_xattr_handler,
+#endif
+	&shmem_security_xattr_handler,
+	&shmem_trusted_xattr_handler,
+	NULL
+};
 
 static ssize_t shmem_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
@@ -2661,10 +2614,10 @@ static const struct inode_operations shmem_short_symlink_operations = {
 	.readlink	= generic_readlink,
 	.follow_link	= simple_follow_link,
 #ifdef CONFIG_TMPFS_XATTR
-	.setxattr	= shmem_setxattr,
-	.getxattr	= shmem_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= shmem_listxattr,
-	.removexattr	= shmem_removexattr,
+	.removexattr	= generic_removexattr,
 #endif
 };
 
@@ -2673,10 +2626,10 @@ static const struct inode_operations shmem_symlink_inode_operations = {
 	.follow_link	= shmem_follow_link,
 	.put_link	= shmem_put_link,
 #ifdef CONFIG_TMPFS_XATTR
-	.setxattr	= shmem_setxattr,
-	.getxattr	= shmem_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= shmem_listxattr,
-	.removexattr	= shmem_removexattr,
+	.removexattr	= generic_removexattr,
 #endif
 };
 
@@ -3148,10 +3101,10 @@ static const struct inode_operations shmem_inode_operations = {
 	.getattr	= shmem_getattr,
 	.setattr	= shmem_setattr,
 #ifdef CONFIG_TMPFS_XATTR
-	.setxattr	= shmem_setxattr,
-	.getxattr	= shmem_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= shmem_listxattr,
-	.removexattr	= shmem_removexattr,
+	.removexattr	= generic_removexattr,
 	.set_acl	= simple_set_acl,
 #endif
 };
@@ -3170,10 +3123,10 @@ static const struct inode_operations shmem_dir_inode_operations = {
 	.tmpfile	= shmem_tmpfile,
 #endif
 #ifdef CONFIG_TMPFS_XATTR
-	.setxattr	= shmem_setxattr,
-	.getxattr	= shmem_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= shmem_listxattr,
-	.removexattr	= shmem_removexattr,
+	.removexattr	= generic_removexattr,
 #endif
 #ifdef CONFIG_TMPFS_POSIX_ACL
 	.setattr	= shmem_setattr,
@@ -3183,10 +3136,10 @@ static const struct inode_operations shmem_dir_inode_operations = {
 
 static const struct inode_operations shmem_special_inode_operations = {
 #ifdef CONFIG_TMPFS_XATTR
-	.setxattr	= shmem_setxattr,
-	.getxattr	= shmem_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= shmem_listxattr,
-	.removexattr	= shmem_removexattr,
+	.removexattr	= generic_removexattr,
 #endif
 #ifdef CONFIG_TMPFS_POSIX_ACL
 	.setattr	= shmem_setattr,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
