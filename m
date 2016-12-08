Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 518156B0260
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 16:52:32 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id b194so22004979ioa.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 13:52:32 -0800 (PST)
Received: from ch3vs02.rockwellcollins.com (ch3vs02.rockwellcollins.com. [205.175.226.29])
        by mx.google.com with ESMTPS id q7si10462828itb.45.2016.12.08.13.52.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 13:52:31 -0800 (PST)
From: David Graziano <david.graziano@rockwellcollins.com>
Subject: [PATCH RFC v3 1/3] xattr: add simple initxattrs function
Date: Thu,  8 Dec 2016 15:52:26 -0600
Message-Id: <1481233948-53350-2-git-send-email-david.graziano@rockwellcollins.com>
In-Reply-To: <1481233948-53350-1-git-send-email-david.graziano@rockwellcollins.com>
References: <1481233948-53350-1-git-send-email-david.graziano@rockwellcollins.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org
Cc: paul@paul-moore.com, agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, David Graziano <david.graziano@rockwellcollins.com>

Adds new simple_xattr_initxattrs() initialization function for
initializing the extended attributes via LSM callback. Based
on callback function used by tmpfs/shmem. This is allows for
consolidation and avoiding code duplication when other filesystem
need to implement a simple initxattrs LSM callback function.

Signed-off-by: David Graziano <david.graziano@rockwellcollins.com>
---
 fs/xattr.c            | 39 +++++++++++++++++++++++++++++++++++++++
 include/linux/xattr.h |  3 +++
 2 files changed, 42 insertions(+)

diff --git a/fs/xattr.c b/fs/xattr.c
index c243905..69dd142 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -994,3 +994,42 @@ void simple_xattr_list_add(struct simple_xattrs *xattrs,
 	list_add(&new_xattr->list, &xattrs->head);
 	spin_unlock(&xattrs->lock);
 }
+
+/*
+ * Callback for security_inode_init_security() for acquiring xattrs.
+ */
+int simple_xattr_initxattrs(struct inode *inode,
+			    const struct xattr *xattr_array,
+			    void *fs_info)
+{
+	struct simple_xattrs *xattrs;
+	const struct xattr *xattr;
+	struct simple_xattr *new_xattr;
+	size_t len;
+
+	if (!fs_info)
+		return -ENOMEM;
+	xattrs = (struct simple_xattrs *) fs_info;
+
+	for (xattr = xattr_array; xattr->name != NULL; xattr++) {
+		new_xattr = simple_xattr_alloc(xattr->value, xattr->value_len);
+		if (!new_xattr)
+			return -ENOMEM;
+		len = strlen(xattr->name) + 1;
+		new_xattr->name = kmalloc(XATTR_SECURITY_PREFIX_LEN + len,
+					  GFP_KERNEL);
+		if (!new_xattr->name) {
+			kfree(new_xattr);
+			return -ENOMEM;
+		}
+
+		memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
+		       XATTR_SECURITY_PREFIX_LEN);
+		memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
+		       xattr->name, len);
+
+		simple_xattr_list_add(xattrs, new_xattr);
+	}
+
+	return 0;
+}
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 94079ba..a787d1a 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -108,5 +108,8 @@ ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs, cha
 			  size_t size);
 void simple_xattr_list_add(struct simple_xattrs *xattrs,
 			   struct simple_xattr *new_xattr);
+int simple_xattr_initxattrs(struct inode *inode,
+			    const struct xattr *xattr_array,
+			    void *fs_info);
 
 #endif	/* _LINUX_XATTR_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
