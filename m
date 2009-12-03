Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2C27D6B007D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:59:40 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 5/6] vfs: make init-file static
Date: Thu, 03 Dec 2009 14:59:25 -0500
Message-ID: <20091203195925.8925.21416.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

init-file is no longer used by anything except alloc_file.  Make it static and
remove from headers.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/file_table.c      |   73 ++++++++++++++++++++++----------------------------
 include/linux/file.h |    3 --
 2 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 4bef4c0..0f9d2f2 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -150,53 +150,16 @@ fail:
 EXPORT_SYMBOL(get_empty_filp);
 
 /**
- * alloc_file - allocate and initialize a 'struct file'
- * @mnt: the vfsmount on which the file will reside
- * @dentry: the dentry representing the new file
- * @mode: the mode with which the new file will be opened
- * @fop: the 'struct file_operations' for the new file
- *
- * Use this instead of get_empty_filp() to get a new
- * 'struct file'.  Do so because of the same initialization
- * pitfalls reasons listed for init_file().  This is a
- * preferred interface to using init_file().
- *
- * If all the callers of init_file() are eliminated, its
- * code should be moved into this function.
- */
-struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
-		fmode_t mode, const struct file_operations *fop)
-{
-	struct file *file;
-
-	file = get_empty_filp();
-	if (!file)
-		return NULL;
-
-	init_file(file, mnt, dentry, mode, fop);
-	return file;
-}
-EXPORT_SYMBOL(alloc_file);
-
-/**
  * init_file - initialize a 'struct file'
  * @file: the already allocated 'struct file' to initialized
  * @mnt: the vfsmount on which the file resides
  * @dentry: the dentry representing this file
  * @mode: the mode the file is opened with
  * @fop: the 'struct file_operations' for this file
- *
- * Use this instead of setting the members directly.  Doing so
- * avoids making mistakes like forgetting the mntget() or
- * forgetting to take a write on the mnt.
- *
- * Note: This is a crappy interface.  It is here to make
- * merging with the existing users of get_empty_filp()
- * who have complex failure logic easier.  All users
- * of this should be moving to alloc_file().
  */
-int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
-	   fmode_t mode, const struct file_operations *fop)
+static int init_file(struct file *file, struct vfsmount *mnt,
+		     struct dentry *dentry, fmode_t mode,
+		     const struct file_operations *fop)
 {
 	int error = 0;
 	file->f_path.dentry = dentry;
@@ -218,7 +181,35 @@ int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
 	}
 	return error;
 }
-EXPORT_SYMBOL(init_file);
+
+/**
+ * alloc_file - allocate and initialize a 'struct file'
+ * @mnt: the vfsmount on which the file will reside
+ * @dentry: the dentry representing the new file
+ * @mode: the mode with which the new file will be opened
+ * @fop: the 'struct file_operations' for the new file
+ *
+ * Use this instead of get_empty_filp() to get a new
+ * 'struct file'.  Do so because of the same initialization
+ * pitfalls reasons listed for init_file().  This is a
+ * preferred interface to using init_file().
+ *
+ * If all the callers of init_file() are eliminated, its
+ * code should be moved into this function.
+ */
+struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
+		fmode_t mode, const struct file_operations *fop)
+{
+	struct file *file;
+
+	file = get_empty_filp();
+	if (!file)
+		return NULL;
+
+	init_file(file, mnt, dentry, mode, fop);
+	return file;
+}
+EXPORT_SYMBOL(alloc_file);
 
 void fput(struct file *file)
 {
diff --git a/include/linux/file.h b/include/linux/file.h
index 335a0a5..6a8d361 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -18,9 +18,6 @@ extern void drop_file_write_access(struct file *file);
 struct file_operations;
 struct vfsmount;
 struct dentry;
-extern int init_file(struct file *, struct vfsmount *mnt,
-		struct dentry *dentry, fmode_t mode,
-		const struct file_operations *fop);
 extern struct file *alloc_file(struct vfsmount *, struct dentry *dentry,
 		fmode_t mode, const struct file_operations *fop);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
