Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C90216B0267
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 16:52:43 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id f73so22561878ioe.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 13:52:43 -0800 (PST)
Received: from ch3vs01.rockwellcollins.com (ch3vs01.rockwellcollins.com. [205.175.226.27])
        by mx.google.com with ESMTPS id e124si10513766ite.4.2016.12.08.13.52.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 13:52:43 -0800 (PST)
From: David Graziano <david.graziano@rockwellcollins.com>
Subject: [PATCH RFC v3 3/3] mqueue: Implement generic xattr support
Date: Thu,  8 Dec 2016 15:52:28 -0600
Message-Id: <1481233948-53350-4-git-send-email-david.graziano@rockwellcollins.com>
In-Reply-To: <1481233948-53350-1-git-send-email-david.graziano@rockwellcollins.com>
References: <1481233948-53350-1-git-send-email-david.graziano@rockwellcollins.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org
Cc: paul@paul-moore.com, agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, David Graziano <david.graziano@rockwellcollins.com>

Adds support for generic extended attributes within the POSIX message
queues filesystem and setting them by consulting the LSM. This is
needed so that the security.selinux extended attribute can be set via
a SELinux named type transition on file inodes created within the
filesystem. It allows a selinux policy to be created  for a set of
custom applications that use POSIX message queues for their IPC and
uniquely labeling them based on the application that creates the mqueue
eliminating the need for relabeling after the mqueue file is created.
The implementation is based on tmpfs/shmem and uses the newly created
simple_xattr_initxattrs() LSM callback function.

Signed-off-by: David Graziano <david.graziano@rockwellcollins.com>
---
 ipc/mqueue.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 0b13ace..ae11be3 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -35,6 +35,7 @@
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
 #include <linux/slab.h>
+#include <linux/xattr.h>
 
 #include <net/sock.h>
 #include "util.h"
@@ -70,6 +71,7 @@ struct mqueue_inode_info {
 	struct rb_root msg_tree;
 	struct posix_msg_tree_node *node_cache;
 	struct mq_attr attr;
+	struct simple_xattrs xattrs;	/* list of xattrs */
 
 	struct sigevent notify;
 	struct pid *notify_owner;
@@ -254,6 +256,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 			info->attr.mq_maxmsg = attr->mq_maxmsg;
 			info->attr.mq_msgsize = attr->mq_msgsize;
 		}
+		simple_xattrs_init(&info->xattrs);
 		/*
 		 * We used to allocate a static array of pointers and account
 		 * the size of that array as well as one msg_msg struct per
@@ -418,6 +421,7 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 {
 	struct inode *inode;
 	struct mq_attr *attr = dentry->d_fsdata;
+	struct mqueue_inode_info *info;
 	int error;
 	struct ipc_namespace *ipc_ns;
 
@@ -443,6 +447,18 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 		ipc_ns->mq_queues_count--;
 		goto out_unlock;
 	}
+	info = MQUEUE_I(inode);
+	if (info) {
+		error = security_inode_init_security(inode, dir,
+						     &dentry->d_name,
+						     simple_xattr_initxattrs,
+						     &info->xattrs);
+	}
+	if (error && error != -EOPNOTSUPP) {
+		spin_lock(&mq_lock);
+		ipc_ns->mq_queues_count--;
+		goto out_unlock;
+	}
 
 	put_ipc_ns(ipc_ns);
 	dir->i_size += DIRENT_SIZE;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
