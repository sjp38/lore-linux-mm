Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2986B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 09:13:06 -0500 (EST)
Received: by qkct129 with SMTP id t129so6728581qkc.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 06:13:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f200si22367415qhc.127.2015.11.03.06.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 06:13:05 -0800 (PST)
From: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH] tmpfs: listxattr should include POSIX ACL xattrs
Date: Tue,  3 Nov 2015 15:13:01 +0100
Message-Id: <1446559981-26025-1-git-send-email-agruenba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>

When a file on tmpfs has an ACL or a Default ACL, listxattr should include the
corresponding xattr names.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/kernfs/inode.c     |  2 +-
 fs/xattr.c            | 53 +++++++++++++++++++++++++++++++++++----------------
 include/linux/xattr.h |  2 +-
 mm/shmem.c            |  2 +-
 4 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
index 756dd56..3c415bf 100644
--- a/fs/kernfs/inode.c
+++ b/fs/kernfs/inode.c
@@ -230,7 +230,7 @@ ssize_t kernfs_iop_listxattr(struct dentry *dentry, char *buf, size_t size)
 	if (!attrs)
 		return -ENOMEM;
 
-	return simple_xattr_list(&attrs->xattrs, buf, size);
+	return simple_xattr_list(d_inode(dentry), &attrs->xattrs, buf, size);
 }
 
 static inline void set_default_inode_attr(struct inode *inode, umode_t mode)
diff --git a/fs/xattr.c b/fs/xattr.c
index 072fee1..7035d7d 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -926,38 +926,59 @@ static bool xattr_is_trusted(const char *name)
 	return !strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN);
 }
 
+static int xattr_list_one(char **buffer, ssize_t *remaining_size,
+			  const char *name)
+{
+	size_t len = strlen(name) + 1;
+	if (*buffer) {
+		if (*remaining_size < len)
+			return -ERANGE;
+		memcpy(*buffer, name, len);
+		*buffer += len;
+	}
+	*remaining_size -= len;
+	return 0;
+}
+
 /*
  * xattr LIST operation for in-memory/pseudo filesystems
  */
-ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer,
-			  size_t size)
+ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs,
+			  char *buffer, size_t size)
 {
 	bool trusted = capable(CAP_SYS_ADMIN);
 	struct simple_xattr *xattr;
-	size_t used = 0;
+	ssize_t remaining_size = size;
+	int err;
+
+#ifdef CONFIG_FS_POSIX_ACL
+	if (inode->i_acl) {
+		err = xattr_list_one(&buffer, &remaining_size,
+				     XATTR_NAME_POSIX_ACL_ACCESS);
+		if (err)
+			return err;
+	}
+	if (inode->i_default_acl) {
+		err = xattr_list_one(&buffer, &remaining_size,
+				     XATTR_NAME_POSIX_ACL_DEFAULT);
+		if (err)
+			return err;
+	}
+#endif
 
 	spin_lock(&xattrs->lock);
 	list_for_each_entry(xattr, &xattrs->head, list) {
-		size_t len;
-
 		/* skip "trusted." attributes for unprivileged callers */
 		if (!trusted && xattr_is_trusted(xattr->name))
 			continue;
 
-		len = strlen(xattr->name) + 1;
-		used += len;
-		if (buffer) {
-			if (size < used) {
-				used = -ERANGE;
-				break;
-			}
-			memcpy(buffer, xattr->name, len);
-			buffer += len;
-		}
+		err = xattr_list_one(&buffer, &remaining_size, xattr->name);
+		if (err)
+			return err;
 	}
 	spin_unlock(&xattrs->lock);
 
-	return used;
+	return size - remaining_size;
 }
 
 /*
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 91b0a68..b57aed5 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -92,7 +92,7 @@ int simple_xattr_get(struct simple_xattrs *xattrs, const char *name,
 int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
 		     const void *value, size_t size, int flags);
 int simple_xattr_remove(struct simple_xattrs *xattrs, const char *name);
-ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer,
+ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs, char *buffer,
 			  size_t size);
 void simple_xattr_list_add(struct simple_xattrs *xattrs,
 			   struct simple_xattr *new_xattr);
diff --git a/mm/shmem.c b/mm/shmem.c
index 48ce829..3d95547 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2645,7 +2645,7 @@ static int shmem_removexattr(struct dentry *dentry, const char *name)
 static ssize_t shmem_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
 	struct shmem_inode_info *info = SHMEM_I(d_inode(dentry));
-	return simple_xattr_list(&info->xattrs, buffer, size);
+	return simple_xattr_list(d_inode(dentry), &info->xattrs, buffer, size);
 }
 #endif /* CONFIG_TMPFS_XATTR */
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
