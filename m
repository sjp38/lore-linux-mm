Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2N35T6O028653
	for <linux-mm@kvack.org>; Tue, 22 Mar 2005 19:05:29 -0800 (PST)
From: pmeda@akamai.com
Date: Tue, 22 Mar 2005 19:15:02 -0800
Message-Id: <200503230315.TAA10165@allur.sanmateo.akamai.com>
Subject: [PATCH] namei: add audit_inode to all branches in path_lookup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Main change is in path_lookup: added a goto to do audit_inode
instead of return statement, when emul_lookup_dentry for root
is successful.  The existing code does audit_inode only when
lookup is done in normal root or cwd.

Other changes: Some lookup routines are returning zero on success,
and some are returning zero on failure. I documented the related
function signatures in this code path, so that one can glance over
abstract functions without understanding the entire code.

Signed-off-by: Prasanna Meda <pmeda@akamai.com>


--- linux/fs/namei.c	Tue Mar 22 01:29:37 2005
+++ Linux/fs/namei.c	Tue Mar 22 01:48:24 2005
@@ -675,11 +675,11 @@
 
 /*
  * Name resolution.
+ * This is the basic name resolution function, turning a pathname into
+ * the final dentry. We expect 'base' to be positive and a directory.
  *
- * This is the basic name resolution function, turning a pathname
- * into the final dentry.
- *
- * We expect 'base' to be positive and a directory.
+ * Returns 0 and nd will have valid dentry and mnt on success.
+ * Returns error and drops reference to input namei data on failure.
  */
 int fastcall link_path_walk(const char * name, struct nameidata *nd)
 {
@@ -887,8 +887,10 @@
 	return link_path_walk(name, nd);
 }
 
-/* SMP-safe */
-/* returns 1 if everything is done */
+/* 
+ * SMP-safe: Returns 1 and nd will have valid dentry and mnt, if
+ * everything is done. Returns 0 and drops input nd, if lookup failed;
+ */
 static int __emul_lookup_dentry(const char *name, struct nameidata *nd)
 {
 	if (path_walk(name, nd))
@@ -952,9 +954,10 @@
 	}
 }
 
+/* Returns 0 and nd will be valid on success; Retuns error, otherwise. */
 int fastcall path_lookup(const char *name, unsigned int flags, struct nameidata *nd)
 {
-	int retval;
+	int retval = 0;
 
 	nd->last_type = LAST_ROOT; /* if there are only slashes... */
 	nd->flags = flags;
@@ -967,7 +970,7 @@
 			nd->dentry = dget(current->fs->altroot);
 			read_unlock(&current->fs->lock);
 			if (__emul_lookup_dentry(name,nd))
-				return 0;
+				goto out; /* found in altroot */
 			read_lock(&current->fs->lock);
 		}
 		nd->mnt = mntget(current->fs->rootmnt);
@@ -979,6 +982,7 @@
 	read_unlock(&current->fs->lock);
 	current->total_link_count = 0;
 	retval = link_path_walk(name, nd);
+out:
 	if (unlikely(current->audit_context
 		     && nd && nd->dentry && nd->dentry->d_inode))
 		audit_inode(name,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
