Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6DF86B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:04:06 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f73so558796987ioe.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:04:06 -0800 (PST)
Received: from secvs02.rockwellcollins.com (secvs02.rockwellcollins.com. [205.175.225.241])
        by mx.google.com with ESMTPS id t184si53982680iod.120.2017.01.05.14.04.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 14:04:05 -0800 (PST)
From: David Graziano <david.graziano@rockwellcollins.com>
Subject: [PATCH v4 3/3] mqueue: Implement generic xattr support
Date: Thu,  5 Jan 2017 16:03:43 -0600
Message-Id: <1483653823-22018-4-git-send-email-david.graziano@rockwellcollins.com>
In-Reply-To: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
References: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org, paul@paul-moore.com
Cc: agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, sds@tycho.nsa.gov, linux-kernel@vger.kernel.org, David Graziano <david.graziano@rockwellcollins.com>

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
 ipc/mqueue.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 0b13ace..32271a0 100644
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
@@ -418,7 +421,8 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 {
 	struct inode *inode;
 	struct mq_attr *attr = dentry->d_fsdata;
-	int error;
+	struct mqueue_inode_info *info;
+	int error = 0;
 	struct ipc_namespace *ipc_ns;
 
 	spin_lock(&mq_lock);
@@ -443,6 +447,18 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 		ipc_ns->mq_queues_count--;
 		goto out_unlock;
 	}
+	info = MQUEUE_I(inode);
+	if (info){
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
