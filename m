Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C7D408D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 04:04:31 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] shmem: using goto to replace several return
Date: Tue, 8 Mar 2011 17:15:00 +0800
Message-ID: <1299575700-6901-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
References: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, hughd@google.com, npiggin@kernel.dk, Bob Liu <lliubbo@gmail.com>

Code clean, use goto to replace several return.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/shmem.c |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7c9cdc6..99f5915 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1847,17 +1847,13 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 						     &dentry->d_name, NULL,
 						     NULL, NULL);
 		if (error) {
-			if (error != -EOPNOTSUPP) {
-				iput(inode);
-				return error;
-			}
+			if (error != -EOPNOTSUPP)
+				goto failed_iput;
 		}
 #ifdef CONFIG_TMPFS_POSIX_ACL
 		error = generic_acl_init(inode, dir);
-		if (error) {
-			iput(inode);
-			return error;
-		}
+		if (error)
+			goto failed_iput;
 #else
 		error = 0;
 #endif
@@ -1866,6 +1862,9 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 		d_instantiate(dentry, inode);
 		dget(dentry); /* Extra count - pin the dentry in core */
 	}
+
+failed_iput:
+	iput(inode);
 	return error;
 }
 
@@ -1987,10 +1986,8 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	error = security_inode_init_security(inode, dir, &dentry->d_name, NULL,
 					     NULL, NULL);
 	if (error) {
-		if (error != -EOPNOTSUPP) {
-			iput(inode);
-			return error;
-		}
+		if (error != -EOPNOTSUPP)
+			goto failed_iput;
 		error = 0;
 	}
 
@@ -2002,10 +1999,8 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		inode->i_op = &shmem_symlink_inline_operations;
 	} else {
 		error = shmem_getpage(inode, 0, &page, SGP_WRITE, NULL);
-		if (error) {
-			iput(inode);
-			return error;
-		}
+		if (error)
+			goto failed_iput;
 		inode->i_mapping->a_ops = &shmem_aops;
 		inode->i_op = &shmem_symlink_inode_operations;
 		kaddr = kmap_atomic(page, KM_USER0);
@@ -2019,7 +2014,10 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
 	d_instantiate(dentry, inode);
 	dget(dentry);
-	return 0;
+
+failed_iput:
+	iput(inode);
+	return error;
 }
 
 static void *shmem_follow_link_inline(struct dentry *dentry, struct nameidata *nd)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
