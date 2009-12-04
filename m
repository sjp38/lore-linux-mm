Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3CD39600794
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:32 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 12/15] ima-path-check rework
Date: Fri, 04 Dec 2009 15:48:16 -0500
Message-ID: <20091204204816.18286.15738.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>


---

 fs/cachefiles/rdwr.c                |    2 
 fs/ecryptfs/main.c                  |    3 -
 fs/file_table.c                     |    4 +
 fs/hugetlbfs/inode.c                |    2 
 fs/namei.c                          |   33 ++------
 fs/nfsd/vfs.c                       |   14 ---
 fs/notify/fanotify/fanotify_user.c  |   13 +--
 fs/open.c                           |   12 ++-
 include/asm-generic/fcntl.h         |    5 +
 include/linux/fs.h                  |    3 +
 include/linux/ima.h                 |   16 ----
 ipc/mqueue.c                        |    2 
 ipc/shm.c                           |    2 
 mm/shmem.c                          |    3 -
 security/integrity/ima/ima_main.c   |  141 ++++++++++-------------------------
 security/integrity/ima/ima_policy.c |   10 +-
 16 files changed, 79 insertions(+), 186 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index a6c8c6f..1d83325 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -11,7 +11,6 @@
 
 #include <linux/mount.h>
 #include <linux/file.h>
-#include <linux/ima.h>
 #include "internal.h"
 
 /*
@@ -923,7 +922,6 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 	if (IS_ERR(file)) {
 		ret = PTR_ERR(file);
 	} else {
-		ima_counts_get(file);
 		ret = -EIO;
 		if (file->f_op->write) {
 			pos = (loff_t) page->index << PAGE_SHIFT;
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index c6ac85d..42b2961 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -35,7 +35,6 @@
 #include <linux/key.h>
 #include <linux/parser.h>
 #include <linux/fs_stack.h>
-#include <linux/ima.h>
 #include "ecryptfs_kernel.h"
 
 /**
@@ -140,8 +139,6 @@ int ecryptfs_init_persistent_file(struct dentry *ecryptfs_dentry)
 			opened_lower_file = 1;
 	}
 	mutex_unlock(&inode_info->lower_file_mutex);
-	if (opened_lower_file)
-		ima_counts_get(inode_info->lower_file);
 	return rc;
 }
 
diff --git a/fs/file_table.c b/fs/file_table.c
index 629a167..a4ef00e 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -10,6 +10,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/init.h>
+#include <linux/ima.h>
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/security.h>
@@ -207,6 +208,9 @@ struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
 		return NULL;
 
 	init_file(file, mnt, dentry, mode, fop);
+
+	ima_path_check(file);
+
 	return file;
 }
 EXPORT_SYMBOL(alloc_file);
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index f1d80e5..4780d41 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -30,7 +30,6 @@
 #include <linux/dnotify.h>
 #include <linux/statfs.h>
 #include <linux/security.h>
-#include <linux/ima.h>
 #include <linux/magic.h>
 #include <linux/xattr.h>
 
@@ -1021,7 +1020,6 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
 			&hugetlbfs_file_operations);
 	if (!file)
 		goto out_dentry; /* inode is already attached */
-	ima_counts_get(file);
 
 	return file;
 
diff --git a/fs/namei.c b/fs/namei.c
index d7ecd2f..e9ea4f4 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -24,7 +24,6 @@
 #include <linux/fsnotify.h>
 #include <linux/personality.h>
 #include <linux/security.h>
-#include <linux/ima.h>
 #include <linux/syscalls.h>
 #include <linux/mount.h>
 #include <linux/audit.h>
@@ -1513,29 +1512,22 @@ int may_open(struct path *path, int acc_mode, int flag)
 	if (error)
 		return error;
 
-	error = ima_path_check(path, acc_mode ?
-			       acc_mode & (MAY_READ | MAY_WRITE | MAY_EXEC) :
-			       ACC_MODE(flag) & (MAY_READ | MAY_WRITE),
-			       IMA_COUNT_UPDATE);
-
-	if (error)
-		return error;
 	/*
 	 * An append-only file must be opened in append mode for writing.
 	 */
 	if (IS_APPEND(inode)) {
 		error = -EPERM;
 		if  ((flag & FMODE_WRITE) && !(flag & O_APPEND))
-			goto err_out;
+			return error;
 		if (flag & O_TRUNC)
-			goto err_out;
+			return error;
 	}
 
 	/* O_NOATIME can only be set by the owner or superuser */
 	if (flag & O_NOATIME)
 		if (!is_owner_or_cap(inode)) {
 			error = -EPERM;
-			goto err_out;
+			return error;
 		}
 
 	/*
@@ -1543,12 +1535,12 @@ int may_open(struct path *path, int acc_mode, int flag)
 	 */
 	error = break_lease(inode, flag);
 	if (error)
-		goto err_out;
+		return error;
 
 	if (flag & O_TRUNC) {
 		error = get_write_access(inode);
 		if (error)
-			goto err_out;
+			return error;
 
 		/*
 		 * Refuse to truncate files with mandatory locks held on them.
@@ -1566,17 +1558,12 @@ int may_open(struct path *path, int acc_mode, int flag)
 		}
 		put_write_access(inode);
 		if (error)
-			goto err_out;
+			return error;
 	} else
 		if (flag & FMODE_WRITE)
 			vfs_dq_init(inode);
 
 	return 0;
-err_out:
-	ima_counts_put(path, acc_mode ?
-		       acc_mode & (MAY_READ | MAY_WRITE | MAY_EXEC) :
-		       ACC_MODE(flag) & (MAY_READ | MAY_WRITE));
-	return error;
 }
 
 /*
@@ -1760,10 +1747,6 @@ do_last:
 			goto exit;
 		}
 		filp = nameidata_to_filp(&nd, open_flag);
-		if (IS_ERR(filp))
-			ima_counts_put(&nd.path,
-				       acc_mode & (MAY_READ | MAY_WRITE |
-						   MAY_EXEC));
 		mnt_drop_write(nd.path.mnt);
 		if (nd.root.mnt)
 			path_put(&nd.root);
@@ -1820,9 +1803,7 @@ ok:
 		goto exit;
 	}
 	filp = nameidata_to_filp(&nd, open_flag);
-	if (IS_ERR(filp))
-		ima_counts_put(&nd.path,
-			       acc_mode & (MAY_READ | MAY_WRITE | MAY_EXEC));
+
 	/*
 	 * It is now safe to drop the mnt write
 	 * because the filp has had a write taken
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cf8ac12..54a80bb 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -55,7 +55,6 @@
 #include <linux/security.h>
 #endif /* CONFIG_NFSD_V4 */
 #include <linux/jhash.h>
-#include <linux/ima.h>
 #include "nfsd.h"
 #include "vfs.h"
 
@@ -773,8 +772,6 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 			    flags, current_cred());
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
-	else
-		ima_counts_get(*filp);
 out_nfserr:
 	err = nfserrno(host_err);
 out:
@@ -2072,7 +2069,6 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 					struct dentry *dentry, int acc)
 {
 	struct inode	*inode = dentry->d_inode;
-	struct path	path;
 	int		err;
 
 	if (acc == NFSD_MAY_NOP)
@@ -2145,17 +2141,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	if (err == -EACCES && S_ISREG(inode->i_mode) &&
 	    acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE))
 		err = inode_permission(inode, MAY_EXEC);
-	if (err)
-		goto nfsd_out;
 
-	/* Do integrity (permission) checking now, but defer incrementing
-	 * IMA counts to the actual file open.
-	 */
-	path.mnt = exp->ex_path.mnt;
-	path.dentry = dentry;
-	err = ima_path_check(&path, acc & (MAY_READ | MAY_WRITE | MAY_EXEC),
-			     IMA_COUNT_LEAVE);
-nfsd_out:
 	return err? nfserrno(err) : 0;
 }
 
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index c5f59d8..d5a73d8 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -3,7 +3,6 @@
 #include <linux/fs.h>
 #include <linux/anon_inodes.h>
 #include <linux/fsnotify_backend.h>
-#include <linux/ima.h>
 #include <linux/init.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
@@ -48,7 +47,7 @@ static int create_and_fill_fd(struct fsnotify_group *group,
 			      struct fanotify_event_metadata *metadata,
 			      struct fsnotify_event *event)
 {
-	int client_fd, err;
+	int client_fd;
 	struct dentry *dentry;
 	struct vfsmount *mnt;
 	struct file *new_file;
@@ -75,13 +74,9 @@ static int create_and_fill_fd(struct fsnotify_group *group,
 	/* it's possible this event was an overflow event.  in that case dentry and mnt
 	 * are NULL;  That's fine, just don't call dentry open */
 	if (dentry && mnt) {
-		err = ima_path_check(&event->path, MAY_READ, IMA_COUNT_UPDATE);
-		if (err)
-			new_file = ERR_PTR(err);
-		else
-			new_file = dentry_open(dentry, mnt,
-					       O_RDONLY | O_LARGEFILE | FMODE_NONOTIFY,
-					       current_cred());
+		new_file = dentry_open(dentry, mnt,
+				       O_RDONLY | O_LARGEFILE | FMODE_NONOTIFY,
+				       current_cred());
 	} else
 		new_file = ERR_PTR(-EOVERFLOW);
 	if (IS_ERR(new_file)) {
diff --git a/fs/open.c b/fs/open.c
index ebb74d4..1ce3103 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -30,6 +30,7 @@
 #include <linux/audit.h>
 #include <linux/falloc.h>
 #include <linux/fs_struct.h>
+#include <linux/ima.h>
 
 #include "internal.h"
 
@@ -827,8 +828,9 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	struct inode *inode;
 	int error;
 
-	f->f_flags = (flags & ~(FMODE_EXEC | FMODE_NONOTIFY));
-	f->f_mode = (__force fmode_t)((flags+1) & O_ACCMODE) | (flags & FMODE_NONOTIFY) |
+	f->f_flags = (flags & ~(FMODE_EXEC | FMODE_NONOTIFY | FMODE_NOIMA));
+	f->f_mode = (__force fmode_t)((flags+1) & O_ACCMODE) |
+				(flags & (FMODE_NONOTIFY | FMODE_NOIMA)) |
 				FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
 
 	inode = dentry->d_inode;
@@ -873,6 +875,12 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 		}
 	}
 
+	error = ima_path_check(f);
+	if (error) {
+		fput(f);
+		f = ERR_PTR(error);
+	}
+
 	return f;
 
 cleanup_all:
diff --git a/include/asm-generic/fcntl.h b/include/asm-generic/fcntl.h
index 7c0094f..67645ae 100644
--- a/include/asm-generic/fcntl.h
+++ b/include/asm-generic/fcntl.h
@@ -4,8 +4,9 @@
 #include <linux/types.h>
 
 /*
- * FMODE_EXEC is 0x20
- * FMODE_NONOTIFY is 0x800000
+ * FMODE_EXEC is	0x0000020
+ * FMODE_NONOTIFY is	0x0800000
+ * FMODE_NOIMA is	0x1000000
  * These cannot be used by userspace O_* until internal and external open
  * flags are split.
  * -Eric Paris
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 112d71a..f435d5b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -91,6 +91,9 @@ struct inodes_stat_t {
 /* File was opened by fanotify and shouldn't generate fanotify events */
 #define FMODE_NONOTIFY		((__force fmode_t)8388608)
 
+/* File is being opened for IMA and should not do IMA measurements */
+#define FMODE_NOIMA		((__force fmode_t)16777216)
+
 /*
  * The below are the various read and write types that we support. Some of
  * them include behavioral modifiers that send information down to the
diff --git a/include/linux/ima.h b/include/linux/ima.h
index 0e3f2a4..4c68bf9 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -20,11 +20,9 @@ struct linux_binprm;
 extern int ima_bprm_check(struct linux_binprm *bprm);
 extern int ima_inode_alloc(struct inode *inode);
 extern void ima_inode_free(struct inode *inode);
-extern int ima_path_check(struct path *path, int mask, int update_counts);
+extern int ima_path_check(struct file *file);
 extern void ima_file_free(struct file *file);
 extern int ima_file_mmap(struct file *file, unsigned long prot);
-extern void ima_counts_get(struct file *file);
-extern void ima_counts_put(struct path *path, int mask);
 
 #else
 static inline int ima_bprm_check(struct linux_binprm *bprm)
@@ -42,7 +40,7 @@ static inline void ima_inode_free(struct inode *inode)
 	return;
 }
 
-static inline int ima_path_check(struct path *path, int mask, int update_counts)
+static inline int ima_path_check(struct file *file)
 {
 	return 0;
 }
@@ -56,15 +54,5 @@ static inline int ima_file_mmap(struct file *file, unsigned long prot)
 {
 	return 0;
 }
-
-static inline void ima_counts_get(struct file *file)
-{
-	return;
-}
-
-static inline void ima_counts_put(struct path *path, int mask)
-{
-	return;
-}
 #endif /* CONFIG_IMA_H */
 #endif /* _LINUX_IMA_H */
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index f5d4bd2..6c97934 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -32,7 +32,6 @@
 #include <linux/nsproxy.h>
 #include <linux/pid.h>
 #include <linux/ipc_namespace.h>
-#include <linux/ima.h>
 
 #include <net/sock.h>
 #include "util.h"
@@ -734,7 +733,6 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 		error = PTR_ERR(filp);
 		goto out_putfd;
 	}
-	ima_counts_get(filp);
 
 	fd_install(fd, filp);
 	goto out_upsem;
diff --git a/ipc/shm.c b/ipc/shm.c
index 757f596..8bc7f0e 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -39,7 +39,6 @@
 #include <linux/nsproxy.h>
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
-#include <linux/ima.h>
 
 #include <asm/uaccess.h>
 
@@ -891,7 +890,6 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 	file = alloc_file(path.mnt, path.dentry, f_mode, &shm_file_operations);
 	if (!file)
 		goto out_free;
-	ima_counts_get(file);
 
 	file->private_data = sfd;
 	file->f_mapping = shp->shm_file->f_mapping;
diff --git a/mm/shmem.c b/mm/shmem.c
index b212184..7bd8fd6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -29,7 +29,6 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/swap.h>
-#include <linux/ima.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -2655,8 +2654,6 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 	if (!file)
 		goto put_dentry;
 
-	ima_counts_get(file);
-
 #ifndef CONFIG_MMU
 	error = ramfs_nommu_expand_for_mapping(inode, size);
 	if (error) {
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index e041233..29d3723 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -36,10 +36,12 @@ static int __init hash_setup(char *str)
 __setup("ima_hash=", hash_setup);
 
 /*
- * Update the counts given an fmode_t
+ * Update the counts given a file
  */
-static void ima_inc_counts(struct ima_iint_cache *iint, fmode_t mode)
+static void ima_inc_counts(struct ima_iint_cache *iint, struct file *file)
 {
+	fmode_t mode = file->f_mode;
+
 	BUG_ON(!mutex_is_locked(&iint->mutex));
 
 	iint->opencount++;
@@ -50,19 +52,13 @@ static void ima_inc_counts(struct ima_iint_cache *iint, fmode_t mode)
 }
 
 /*
- * Update the counts given open flags instead of fmode
- */
-static void ima_inc_counts_flags(struct ima_iint_cache *iint, int flags)
-{
-	ima_inc_counts(iint, (__force fmode_t)((flags+1) & O_ACCMODE));
-}
-
-/*
  * Decrement ima counts
  */
-static void ima_dec_counts(struct ima_iint_cache *iint, struct inode *inode,
-			   fmode_t mode)
+static void ima_dec_counts(struct ima_iint_cache *iint, struct file *file)
 {
+	struct inode *inode = file->f_path.dentry->d_inode;
+	fmode_t mode = file->f_mode;
+
 	BUG_ON(!mutex_is_locked(&iint->mutex));
 
 	iint->opencount--;
@@ -92,12 +88,6 @@ static void ima_dec_counts(struct ima_iint_cache *iint, struct inode *inode,
 	}
 }
 
-static void ima_dec_counts_flags(struct ima_iint_cache *iint,
-				 struct inode *inode, int flags)
-{
-	ima_dec_counts(iint, inode, (__force fmode_t)((flags+1) & O_ACCMODE));
-}
-
 /**
  * ima_file_free - called on __fput()
  * @file: pointer to file structure being freed
@@ -110,6 +100,8 @@ void ima_file_free(struct file *file)
 	struct inode *inode = file->f_dentry->d_inode;
 	struct ima_iint_cache *iint;
 
+	if (file->f_mode & FMODE_NOIMA)
+		return;
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return;
 	iint = ima_iint_find_get(inode);
@@ -117,7 +109,7 @@ void ima_file_free(struct file *file)
 		return;
 
 	mutex_lock(&iint->mutex);
-	ima_dec_counts(iint, inode, file->f_mode);
+	ima_dec_counts(iint, file);
 	mutex_unlock(&iint->mutex);
 	kref_put(&iint->refcount, iint_free);
 }
@@ -157,7 +149,7 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
 {
 	int rc = 0;
 
-	ima_inc_counts(iint, file->f_mode);
+	ima_inc_counts(iint, file);
 
 	rc = ima_collect_measurement(iint, file);
 	if (!rc)
@@ -166,7 +158,7 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
 }
 
 /**
- * ima_path_check - based on policy, collect/store measurement.
+ * ima_file_check - based on policy, collect/store measurement.
  * @path: contains a pointer to the path to be measured
  * @mask: contains MAY_READ, MAY_WRITE or MAY_EXECUTE
  *
@@ -183,13 +175,18 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
  * Always return 0 and audit dentry_open failures.
  * (Return code will be based upon measurement appraisal.)
  */
-int ima_path_check(struct path *path, int mask, int update_counts)
+int ima_path_check(struct file *file)
 {
-	struct inode *inode = path->dentry->d_inode;
+	struct dentry *dentry = file->f_path.dentry;
+	struct vfsmount *mnt = file->f_path.mnt;
+	struct inode *inode = dentry->d_inode;
+	fmode_t mode = file->f_mode;
 	struct ima_iint_cache *iint;
-	struct file *file = NULL;
+	struct file *internal_file = NULL;
 	int rc;
 
+	if (mode & FMODE_NOIMA)
+		return 0;
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return 0;
 	iint = ima_iint_find_get(inode);
@@ -197,45 +194,45 @@ int ima_path_check(struct path *path, int mask, int update_counts)
 		return 0;
 
 	mutex_lock(&iint->mutex);
-	if (update_counts)
-		ima_inc_counts_flags(iint, mask);
+
+	ima_inc_counts(iint, file);
 
 	rc = ima_must_measure(iint, inode, MAY_READ, PATH_CHECK);
 	if (rc < 0)
 		goto out;
 
-	if ((mask & MAY_WRITE) || (mask == 0))
+	/* if this file is writable, check if it is already open read */
+	if (mode & FMODE_WRITE) {
 		ima_read_write_check(TOMTOU, iint, inode,
-				     path->dentry->d_name.name);
-
-	if ((mask & (MAY_WRITE | MAY_READ | MAY_EXEC)) != MAY_READ)
+				     dentry->d_name.name);
 		goto out;
+	}
 
-	ima_read_write_check(OPEN_WRITERS, iint, inode,
-			     path->dentry->d_name.name);
-	if (!(iint->flags & IMA_MEASURED)) {
-		struct dentry *dentry = dget(path->dentry);
-		struct vfsmount *mnt = mntget(path->mnt);
+	/* if this is for read, does something else have this open for write? */
+	ima_read_write_check(OPEN_WRITERS, iint, inode, dentry->d_name.name);
 
-		file = dentry_open(dentry, mnt, O_RDONLY | O_LARGEFILE,
-				   current_cred());
-		if (IS_ERR(file)) {
-			int audit_info = 0;
+	if (!(iint->flags & IMA_MEASURED)) {
+		dentry = dget(dentry);
+		mnt = mntget(mnt);
 
+		internal_file = dentry_open(dentry, mnt,
+					    O_RDONLY | O_LARGEFILE | FMODE_NOIMA,
+					    current_cred());
+		if (IS_ERR(internal_file)) {
 			integrity_audit_msg(AUDIT_INTEGRITY_PCR, inode,
 					    dentry->d_name.name,
 					    "add_measurement",
 					    "dentry_open failed",
-					    1, audit_info);
-			file = NULL;
+					    1, 0);
+			internal_file = NULL;
 			goto out;
 		}
 		rc = get_path_measurement(iint, file, dentry->d_name.name);
 	}
 out:
 	mutex_unlock(&iint->mutex);
-	if (file)
-		fput(file);
+	if (internal_file)
+		fput(internal_file);
 	kref_put(&iint->refcount, iint_free);
 	return 0;
 }
@@ -248,6 +245,8 @@ static int process_measurement(struct file *file, const unsigned char *filename,
 	struct ima_iint_cache *iint;
 	int rc;
 
+	if (file->f_mode & FMODE_NOIMA)
+		return 0;
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return 0;
 	iint = ima_iint_find_get(inode);
@@ -268,62 +267,6 @@ out:
 	return rc;
 }
 
-/*
- * ima_counts_put - decrement file counts
- *
- * File counts are incremented in ima_path_check. On file open
- * error, such as ETXTBSY, decrement the counts to prevent
- * unnecessary imbalance messages.
- */
-void ima_counts_put(struct path *path, int mask)
-{
-	struct inode *inode = path->dentry->d_inode;
-	struct ima_iint_cache *iint;
-
-	/* The inode may already have been freed, freeing the iint
-	 * with it. Verify the inode is not NULL before dereferencing
-	 * it.
-	 */
-	if (!ima_initialized || !inode || !S_ISREG(inode->i_mode))
-		return;
-	iint = ima_iint_find_get(inode);
-	if (!iint)
-		return;
-
-	mutex_lock(&iint->mutex);
-	ima_dec_counts_flags(iint, inode, mask);
-	mutex_unlock(&iint->mutex);
-
-	kref_put(&iint->refcount, iint_free);
-}
-
-/*
- * ima_counts_get - increment file counts
- *
- * - for IPC shm and shmat file.
- * - for nfsd exported files.
- *
- * Increment the counts for these files to prevent unnecessary
- * imbalance messages.
- */
-void ima_counts_get(struct file *file)
-{
-	struct inode *inode = file->f_dentry->d_inode;
-	struct ima_iint_cache *iint;
-
-	if (!ima_initialized || !S_ISREG(inode->i_mode))
-		return;
-	iint = ima_iint_find_get(inode);
-	if (!iint)
-		return;
-	mutex_lock(&iint->mutex);
-	ima_inc_counts(iint, file->f_mode);
-	mutex_unlock(&iint->mutex);
-
-	kref_put(&iint->refcount, iint_free);
-}
-EXPORT_SYMBOL_GPL(ima_counts_get);
-
 /**
  * ima_file_mmap - based on policy, collect/store measurement.
  * @file: pointer to the file to be measured (May be NULL)
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index e127839..8c699b4 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -205,7 +205,6 @@ void ima_update_policy(void)
 	const char *op = "policy_update";
 	const char *cause = "already exists";
 	int result = 1;
-	int audit_info = 0;
 
 	if (ima_measure == &measure_default_rules) {
 		ima_measure = &measure_policy_rules;
@@ -213,7 +212,7 @@ void ima_update_policy(void)
 		result = 0;
 	}
 	integrity_audit_msg(AUDIT_INTEGRITY_STATUS, NULL,
-			    NULL, op, cause, result, audit_info);
+			    NULL, op, cause, result, 0);
 }
 
 enum {
@@ -387,20 +386,19 @@ int ima_parse_add_rule(char *rule)
 	const char *op = "update_policy";
 	struct ima_measure_rule_entry *entry;
 	int result = 0;
-	int audit_info = 0;
 
 	/* Prevent installed policy from changing */
 	if (ima_measure != &measure_default_rules) {
 		integrity_audit_msg(AUDIT_INTEGRITY_STATUS, NULL,
 				    NULL, op, "already exists",
-				    -EACCES, audit_info);
+				    -EACCES, 0);
 		return -EACCES;
 	}
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry) {
 		integrity_audit_msg(AUDIT_INTEGRITY_STATUS, NULL,
-				    NULL, op, "-ENOMEM", -ENOMEM, audit_info);
+				    NULL, op, "-ENOMEM", -ENOMEM, 0);
 		return -ENOMEM;
 	}
 
@@ -415,7 +413,7 @@ int ima_parse_add_rule(char *rule)
 		kfree(entry);
 		integrity_audit_msg(AUDIT_INTEGRITY_STATUS, NULL,
 				    NULL, op, "invalid policy", result,
-				    audit_info);
+				    0);
 	}
 	return result;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
