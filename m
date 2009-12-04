Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A7C80600794
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:37 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 13/15] ima: rename ima_path_check to ima_file_check
Date: Fri, 04 Dec 2009 15:48:24 -0500
Message-ID: <20091204204824.18286.96552.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

ima_path_check actually deals with files!  call it ima_file_check instead.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/file_table.c                   |    2 +-
 fs/open.c                         |    2 +-
 include/linux/ima.h               |    4 ++--
 security/integrity/ima/ima_main.c |    6 +++---
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index a4ef00e..51da7f9 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -209,7 +209,7 @@ struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
 
 	init_file(file, mnt, dentry, mode, fop);
 
-	ima_path_check(file);
+	ima_file_check(file);
 
 	return file;
 }
diff --git a/fs/open.c b/fs/open.c
index 1ce3103..10bd04e 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -875,7 +875,7 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 		}
 	}
 
-	error = ima_path_check(f);
+	error = ima_file_check(f);
 	if (error) {
 		fput(f);
 		f = ERR_PTR(error);
diff --git a/include/linux/ima.h b/include/linux/ima.h
index 4c68bf9..47ac315 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -20,7 +20,7 @@ struct linux_binprm;
 extern int ima_bprm_check(struct linux_binprm *bprm);
 extern int ima_inode_alloc(struct inode *inode);
 extern void ima_inode_free(struct inode *inode);
-extern int ima_path_check(struct file *file);
+extern int ima_file_check(struct file *file);
 extern void ima_file_free(struct file *file);
 extern int ima_file_mmap(struct file *file, unsigned long prot);
 
@@ -40,7 +40,7 @@ static inline void ima_inode_free(struct inode *inode)
 	return;
 }
 
-static inline int ima_path_check(struct file *file)
+static inline int ima_file_check(struct file *file)
 {
 	return 0;
 }
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index 29d3723..c721ddc 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -14,7 +14,7 @@
  *
  * File: ima_main.c
  *	implements the IMA hooks: ima_bprm_check, ima_file_mmap,
- *	and ima_path_check.
+ *	and ima_file_check.
  */
 #include <linux/module.h>
 #include <linux/file.h>
@@ -175,7 +175,7 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
  * Always return 0 and audit dentry_open failures.
  * (Return code will be based upon measurement appraisal.)
  */
-int ima_path_check(struct file *file)
+int ima_file_check(struct file *file)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct vfsmount *mnt = file->f_path.mnt;
@@ -236,7 +236,7 @@ out:
 	kref_put(&iint->refcount, iint_free);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(ima_path_check);
+EXPORT_SYMBOL_GPL(ima_file_check);
 
 static int process_measurement(struct file *file, const unsigned char *filename,
 			       int mask, int function)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
