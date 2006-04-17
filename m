Subject: [PATCH] dup fd error
Message-Id: <E1FVZJQ-0004fB-6z@blr-eng3.blr.corp.google.com>
From: Prasanna Meda <mlp@google.com>
Date: Tue, 18 Apr 2006 00:53:04 +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

set errorp in dup_fd, it will be used in sys_unshare also.

Signed-off-by: Prasanna Meda

--- a/kernel/fork.c	2006-04-17 22:38:09.000000000 +0530
+++ b/kernel/fork.c	2006-04-18 00:38:37.000000000 +0530
@@ -629,6 +629,7 @@ out:
 /*
  * Allocate a new files structure and copy contents from the
  * passed in files structure.
+ * errorp will be valid only when the returned files_struct is NULL.
  */
 static struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 {
@@ -637,6 +638,7 @@ static struct files_struct *dup_fd(struc
 	int open_files, size, i, expand;
 	struct fdtable *old_fdt, *new_fdt;
 
+	*errorp = -ENOMEM;
 	newf = alloc_files();
 	if (!newf)
 		goto out;
@@ -750,7 +752,6 @@ static int copy_files(unsigned long clon
 	 * break this.
 	 */
 	tsk->files = NULL;
-	error = -ENOMEM;
 	newf = dup_fd(oldf, &error);
 	if (!newf)
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
