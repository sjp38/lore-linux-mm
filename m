Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 401606B0253
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:44:18 -0500 (EST)
Received: by iouu10 with SMTP id u10so192002035iou.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 13:44:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gz5si1789539igb.38.2015.11.30.13.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 13:44:17 -0800 (PST)
From: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH 07/10] tmpfs: listxattr should include POSIX ACL xattrs
Date: Mon, 30 Nov 2015 22:43:40 +0100
Message-Id: <1448919823-27103-8-git-send-email-agruenba@redhat.com>
In-Reply-To: <1448919823-27103-1-git-send-email-agruenba@redhat.com>
References: <1448919823-27103-1-git-send-email-agruenba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

When a file on tmpfs has an ACL or a Default ACL, listxattr should include the
corresponding xattr name.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 fs/kernfs/inode.c     |  2 +-
 fs/xattr.c            | 53 +++++++++++++++++++++++++++++++++++----------------
 include/linux/xattr.h |  3 ++-
 mm/shmem.c            |  2 +-
 4 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
index f97e1f7..16405ae 100644
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
index 1a1ddd7..b3c573c 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -921,38 +921,59 @@ static bool xattr_is_trusted(const char *name)
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
index 46826c7..4c60010 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -99,7 +99,8 @@ int simple_xattr_get(struct simple_xattrs *xattrs, const char *name,
 		     void *buffer, size_t size);
 int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
 		     const void *value, size_t size, int flags);
-ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer, size_t size);
+ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs, char *buffer,
+			  size_t size);
 void simple_xattr_list_add(struct simple_xattrs *xattrs,
 			   struct simple_xattr *new_xattr);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index fdfe6c8..297390f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2606,7 +2606,7 @@ static const struct xattr_handler *shmem_xattr_handlers[] = {
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
