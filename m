Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2DAfK6O029470
	for <linux-mm@kvack.org>; Sun, 13 Mar 2005 02:41:21 -0800 (PST)
From: pmeda@akamai.com
Date: Sun, 13 Mar 2005 02:50:01 -0800
Message-Id: <200503131050.CAA07251@allur.sanmateo.akamai.com>
Subject: [PATCH] pivot_root: better documentation to code
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pivot_root works with five nami data structures, I would like add
the minimal documentation to the code to make things clear.

Signed-Off-by: Prasanna Meda <pmeda@akamai.com>


--- Linux/fs/namespace.c	Sun Mar 13 09:37:18 2005
+++ linux/fs/namespace.c	Sun Mar 13 10:26:09 2005
@@ -1255,10 +1255,19 @@
 }
 
 /*
- * Moves the current root to put_root, and sets root/cwd of all processes
- * which had them on the old root to new_root.
+ * pivot_root Semantics:
+ * Moves the root file system of the current process to the directory put_old,
+ * makes new_root as the new root file system of the current process, and sets
+ * root/cwd of all processes which had them on the current root to new_root.
  *
- * Note:
+ * Restrictions:
+ * The new_root and put_old must be directories, and  must not be on the
+ * same file  system as the current process root. The put_old  must  be
+ * underneath new_root,  i.e. adding a non-zero number of /.. to the string
+ * pointed to by put_old must yield the same directory as new_root. No other
+ * file system may be mounted on put_old. After all, new_root is a mountpoint.
+ *
+ * Notes:
  *  - we don't move root/cwd if they are not at the root (reason: if something
  *    cared enough to change them, it's probably wrong to force them elsewhere)
  *  - it's okay to pick a root that isn't the root of a file system, e.g.
@@ -1313,10 +1322,10 @@
 		goto out2;
 	error = -EBUSY;
 	if (new_nd.mnt == user_nd.mnt || old_nd.mnt == user_nd.mnt)
-		goto out2; /* loop */
+		goto out2; /* loop, on the same file system  */
 	error = -EINVAL;
 	if (user_nd.mnt->mnt_root != user_nd.dentry)
-		goto out2;
+		goto out2; /* not a mountpoint */
 	if (new_nd.mnt->mnt_root != new_nd.dentry)
 		goto out2; /* not a mountpoint */
 	tmp = old_nd.mnt; /* make sure we can reach put_old from new_root */
@@ -1324,7 +1333,7 @@
 	if (tmp != new_nd.mnt) {
 		for (;;) {
 			if (tmp->mnt_parent == tmp)
-				goto out3;
+				goto out3; /* already mounted on put_old */
 			if (tmp->mnt_parent == new_nd.mnt)
 				break;
 			tmp = tmp->mnt_parent;
@@ -1335,8 +1344,8 @@
 		goto out3;
 	detach_mnt(new_nd.mnt, &parent_nd);
 	detach_mnt(user_nd.mnt, &root_parent);
-	attach_mnt(user_nd.mnt, &old_nd);
-	attach_mnt(new_nd.mnt, &root_parent);
+	attach_mnt(user_nd.mnt, &old_nd);     /* mount old root on put_old */
+	attach_mnt(new_nd.mnt, &root_parent); /* mount new_root on / */
 	spin_unlock(&vfsmount_lock);
 	chroot_fs_refs(&user_nd, &new_nd);
 	security_sb_post_pivotroot(&user_nd, &new_nd);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
