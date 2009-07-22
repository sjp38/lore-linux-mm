Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 21DE26B00C0
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:24 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 33/60] c/r: dump open file descriptors
Date: Wed, 22 Jul 2009 05:59:55 -0400
Message-Id: <1248256822-23416-34-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Dump the file table with 'struct ckpt_hdr_file_table, followed by all
open file descriptors. Because the 'struct file' corresponding to an
fd can be shared, they are assigned an objref and registered in the
object hash. A reference to the 'file *' is kept for as long as it
lives in the hash (the hash is only cleaned up at the end of the
checkpoint).

Also provide generic_checkpoint_file() and generic_restore_file()
which is good for normal files and directories. It does not support
yet unlinked files or directories.

Changelog[v17]:
  - Only collect sub-objects of files_struct once
  - Better file error debugging
  - Use (new) d_unlinked()
Changelog[v16]:
  - Fix compile warning in checkpoint_bad()
Changelog[v16]:
  - Reorder patch (move earlier in series)
  - Handle shared files_struct objects
Changelog[v14]:
  - File objects are dumped/restored prior to the first reference
  - Introduce a per file-type restore() callback
  - Use struct file_operations->checkpoint()
  - Put code for generic file descriptors in a separate function
  - Use one CKPT_FILE_GENERIC for both regular files and dirs
  - Revert change to pr_debug(), back to ckpt_debug()
  - Use only unsigned fields in checkpoint headers
  - Rename:  ckpt_write_files() => checkpoint_fd_table()
  - Rename:  ckpt_write_fd_data() => checkpoint_file()
  - Discard field 'h->parent'
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v11]:
  - Discard handling of opened symlinks (there is no such thing)
  - ckpt_scan_fds() retries from scratch if hits size limits
Changelog[v9]:
  - Fix a couple of leaks in ckpt_write_files()
  - Drop useless kfree from ckpt_scan_fds()
Changelog[v8]:
  - initialize 'coe' to workaround gcc false warning
Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/Makefile              |    3 +-
 checkpoint/checkpoint.c          |   11 +
 checkpoint/files.c               |  382 ++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c             |   53 ++++++
 checkpoint/process.c             |   34 ++++-
 checkpoint/sys.c                 |    1 +
 include/linux/checkpoint.h       |   15 ++
 include/linux/checkpoint_hdr.h   |   49 +++++
 include/linux/checkpoint_types.h |    6 +
 include/linux/fs.h               |    4 +
 10 files changed, 556 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/files.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 5aa6a75..1d0c058 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -7,4 +7,5 @@ obj-$(CONFIG_CHECKPOINT) += \
 	objhash.o \
 	checkpoint.o \
 	restart.o \
-	process.o
+	process.o \
+	files.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index e126626..59b86d8 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -18,6 +18,7 @@
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/fs_struct.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/utsname.h>
@@ -573,6 +574,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task;
 	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
 
 	/*
 	 * No need for explicit cleanup here, because if an error
@@ -612,6 +614,15 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init)
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 
+	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
+	task_lock(ctx->root_task);
+	fs = ctx->root_task->fs;
+	read_lock(&fs->lock);
+	ctx->fs_mnt = fs->root;
+	path_get(&ctx->fs_mnt);
+	read_unlock(&fs->lock);
+	task_unlock(ctx->root_task);
+
 	return 0;
 }
 
diff --git a/checkpoint/files.c b/checkpoint/files.c
new file mode 100644
index 0000000..5ff9925
--- /dev/null
+++ b/checkpoint/files.c
@@ -0,0 +1,382 @@
+/*
+ *  Checkpoint file descriptors
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DFILE
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * fill_fname - return pathname of a given file
+ * @path: path name
+ * @root: relative root
+ * @buf: buffer for pathname
+ * @len: buffer length (in) and pathname length (out)
+ */
+static char *fill_fname(struct path *path, struct path *root,
+			char *buf, int *len)
+{
+	struct path tmp = *root;
+	char *fname;
+
+	BUG_ON(!buf);
+	spin_lock(&dcache_lock);
+	fname = __d_path(path, &tmp, buf, *len);
+	spin_unlock(&dcache_lock);
+	if (IS_ERR(fname))
+		return fname;
+	*len = (buf + (*len) - fname);
+	/*
+	 * FIX: if __d_path() changed these, it must have stepped out of
+	 * init's namespace. Since currently we require a unified namespace
+	 * within the container: simply fail.
+	 */
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
+		fname = ERR_PTR(-EBADF);
+
+	return fname;
+}
+
+/**
+ * checkpoint_fname - write a file name
+ * @ctx: checkpoint context
+ * @path: path name
+ * @root: relative root
+ */
+int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
+{
+	char *buf, *fname;
+	int ret, flen;
+
+	/*
+	 * FIXME: we can optimize and save memory (and storage) if we
+	 * share strings (through objhash) and reference them instead
+	 */
+
+	flen = PATH_MAX;
+	buf = kmalloc(flen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	fname = fill_fname(path, root, buf, &flen);
+	if (!IS_ERR(fname))
+		ret = ckpt_write_obj_type(ctx, fname, flen,
+					  CKPT_HDR_FILE_NAME);
+	else
+		ret = PTR_ERR(fname);
+
+	kfree(buf);
+	return ret;
+}
+
+#define CKPT_DEFAULT_FDTABLE  256		/* an initial guess */
+
+/**
+ * scan_fds - scan file table and construct array of open fds
+ * @files: files_struct pointer
+ * @fdtable: (output) array of open fds
+ *
+ * Returns the number of open fds found, and also the file table
+ * array via *fdtable. The caller should free the array.
+ *
+ * The caller must validate the file descriptors collected in the
+ * array before using them, e.g. by using fcheck_files(), in case
+ * the task's fdtable changes in the meantime.
+ */
+static int scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds = NULL;
+	int i = 0, n = 0;
+	int tot = CKPT_DEFAULT_FDTABLE;
+
+	/*
+	 * We assume that all tasks possibly sharing the file table are
+	 * frozen (or we are a single process and we checkpoint ourselves).
+	 * Therefore, we can safely proceed after krealloc() from where we
+	 * left off. Otherwise the file table may be modified by another
+	 * task after we scan it. The behavior is this case is undefined,
+	 * and either checkpoint or restart will likely fail.
+	 */
+ retry:
+	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (/**/; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			rcu_read_unlock();
+			tot *= 2;	/* won't overflow: kmalloc will fail */
+			goto retry;
+		}
+		fds[n++] = i;
+	}
+	rcu_read_unlock();
+
+	*fdtable = fds;
+	return n;
+}
+
+int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+			   struct ckpt_hdr_file *h)
+{
+	h->f_flags = file->f_flags;
+	h->f_mode = file->f_mode;
+	h->f_pos = file->f_pos;
+	h->f_version = file->f_version;
+
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+
+	return 0;
+}
+
+int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_generic *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	/*
+	 * FIXME: when we'll add support for unlinked files/dirs, we'll
+	 * need to distinguish between unlinked filed and unlinked dirs.
+	 */
+	h->common.f_type = CKPT_FILE_GENERIC;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, &h->common.h);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_fname(ctx, &file->f_path, &ctx->fs_mnt);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+EXPORT_SYMBOL(generic_file_checkpoint);
+
+/* checkpoint callback for file pointer */
+int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct file *file = (struct file *) ptr;
+
+	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
+		return -EBADF;
+	}
+	if (d_unlinked(file->f_dentry)) {
+		ckpt_debug("unlinked files are unsupported\n");
+		return -EBADF;
+	}
+	return file->f_op->checkpoint(ctx, file);
+}
+
+/**
+ * ckpt_write_file_desc - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls ckpt_write_file to dump the file pointer too.
+ */
+static int checkpoint_file_desc(struct ckpt_ctx *ctx,
+				struct files_struct *files, int fd)
+{
+	struct ckpt_hdr_file_desc *h;
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int objref, ret;
+	int coe = 0;	/* avoid gcc warning */
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
+	if (!h)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	file = fcheck_files(files, fd);
+	if (file) {
+		coe = FD_ISSET(fd, fdt->close_on_exec);
+		get_file(file);
+	}
+	rcu_read_unlock();
+
+	/* sanity check (although this shouldn't happen) */
+	ret = -EBADF;
+	if (!file)
+		goto out;
+
+	/*
+	 * if seen first time, this will add 'file' to the objhash, keep
+	 * a reference to it, dump its state while at it.
+	 */
+	objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
+	ckpt_debug("fd %d objref %d file %p coe %d)\n", fd, objref, file, coe);
+	if (objref < 0) {
+		ret = objref;
+		goto out;
+	}
+
+	h->fd_objref = objref;
+	h->fd_descriptor = fd;
+	h->fd_close_on_exec = coe;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+out:
+	ckpt_hdr_put(ctx, h);
+	if (file)
+		fput(file);
+	return ret;
+}
+
+static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
+				    struct files_struct *files)
+{
+	struct ckpt_hdr_file_table *h;
+	int *fdtable = NULL;
+	int nfds, n, ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
+	if (!h)
+		return -ENOMEM;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		ret = nfds;
+		goto out;
+	}
+
+	h->fdt_nfds = nfds;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ckpt_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+ out:
+	kfree(fdtable);
+	return ret;
+}
+
+/* checkpoint callback for file table */
+int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_file_table(ctx, (struct files_struct *) ptr);
+}
+
+/* checkpoint wrapper for file table */
+int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct files_struct *files;
+	int objref;
+
+	files = get_files_struct(t);
+	if (!files)
+		return -EBUSY;
+	objref = checkpoint_obj(ctx, files, CKPT_OBJ_FILE_TABLE);
+	put_files_struct(files);
+
+	return objref;
+}
+
+/***********************************************************************
+ * Collect
+ */
+
+static int collect_file_desc(struct ckpt_ctx *ctx,
+			     struct files_struct *files, int fd)
+{
+	struct fdtable *fdt;
+	struct file *file;
+	int ret;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	file = fcheck_files(files, fd);
+	if (file)
+		get_file(file);
+	rcu_read_unlock();
+
+	if (!file)
+		return -EAGAIN;
+
+	ret = ckpt_obj_collect(ctx, file, CKPT_OBJ_FILE);
+	fput(file);
+
+	return ret;
+}
+
+static int collect_file_table(struct ckpt_ctx *ctx, struct files_struct *files)
+{
+	int *fdtable;
+	int exists;
+	int nfds, n;
+	int ret;
+
+	/* if already exists, don't proceed inside the struct */
+	exists = ckpt_obj_lookup(ctx, files, CKPT_OBJ_FILE_TABLE);
+
+	ret = ckpt_obj_collect(ctx, files, CKPT_OBJ_FILE_TABLE);
+	if (ret < 0 || exists)
+		return ret;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+
+	for (n = 0; n < nfds; n++) {
+		ret = collect_file_desc(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+
+	kfree(fdtable);
+	return ret;
+}
+
+int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct files_struct *files;
+	int ret;
+
+	files = get_files_struct(t);
+	if (!files)
+		return -EBUSY;
+	ret = collect_file_table(ctx, files);
+	put_files_struct(files);
+
+	return ret;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 3f23910..d77e8c4 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,8 @@
 
 #include <linux/kernel.h>
 #include <linux/hash.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -52,6 +54,7 @@ struct ckpt_obj_hash {
 int checkpoint_bad(struct ckpt_ctx *ctx, void *ptr)
 {
 	BUG();
+	return 0;
 }
 
 void *restore_bad(struct ckpt_ctx *ctx)
@@ -71,6 +74,38 @@ static int obj_no_grab(void *ptr)
 	return 0;
 }
 
+static int obj_file_table_grab(void *ptr)
+{
+	atomic_inc(&((struct files_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_file_table_drop(void *ptr)
+{
+	put_files_struct((struct files_struct *) ptr);
+}
+
+static int obj_file_table_users(void *ptr)
+{
+	return atomic_read(&((struct files_struct *) ptr)->count);
+}
+
+static int obj_file_grab(void *ptr)
+{
+	get_file((struct file *) ptr);
+	return 0;
+}
+
+static void obj_file_drop(void *ptr)
+{
+	fput((struct file *) ptr);
+}
+
+static int obj_file_users(void *ptr)
+{
+	return atomic_long_read(&((struct file *) ptr)->f_count);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -79,6 +114,24 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_no_drop,
 		.ref_grab = obj_no_grab,
 	},
+	/* files_struct object */
+	{
+		.obj_name = "FILE_TABLE",
+		.obj_type = CKPT_OBJ_FILE_TABLE,
+		.ref_drop = obj_file_table_drop,
+		.ref_grab = obj_file_table_grab,
+		.ref_users = obj_file_table_users,
+		.checkpoint = checkpoint_file_table,
+	},
+	/* file object */
+	{
+		.obj_name = "FILE",
+		.obj_type = CKPT_OBJ_FILE,
+		.ref_drop = obj_file_drop,
+		.ref_grab = obj_file_grab,
+		.ref_users = obj_file_users,
+		.checkpoint = checkpoint_file,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 4da4e4a..61caa01 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -103,6 +103,30 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_objs *h;
+	int files_objref;
+	int ret;
+
+	files_objref = checkpoint_obj_file_table(ctx, t);
+	ckpt_debug("files: objref %d\n", files_objref);
+	if (files_objref < 0) {
+		ckpt_write_err(ctx, "task %d (%s), files_struct: %d",
+			       task_pid_vnr(t), t->comm, files_objref);
+		return files_objref;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (!h)
+		return -ENOMEM;
+	h->files_objref = files_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 /* dump the task_struct of a given task */
 int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -227,6 +251,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (t->exit_state)
 		return 0;
 
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
@@ -243,7 +271,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
-	return 0;
+	int ret;
+
+	ret = ckpt_collect_file_table(ctx, t);
+
+	return ret;
 }
 
 /***********************************************************************
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d16d48f..bc5620f 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -195,6 +195,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		fput(ctx->file);
 
 	ckpt_obj_hash_free(ctx);
+	path_put(&ctx->fs_mnt);
 
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index efd05cc..67845dc 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -124,12 +124,27 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* file table */
+extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
+				     struct task_struct *t);
+extern int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr);
+
+/* files */
+extern int checkpoint_fname(struct ckpt_ctx *ctx,
+			    struct path *path, struct path *root);
+extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
+
+extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+				  struct ckpt_hdr_file *h);
+
 
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
 #define CKPT_DOBJ	0x8		/* shared objects */
+#define CKPT_DFILE	0x10		/* files and filesystem */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 7c46638..3f8483e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -52,12 +52,18 @@ enum {
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
+	CKPT_HDR_TASK_OBJS,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
 
 	/* 201-299: reserved for arch-dependent */
 
+	CKPT_HDR_FILE_TABLE = 301,
+	CKPT_HDR_FILE_DESC,
+	CKPT_HDR_FILE_NAME,
+	CKPT_HDR_FILE,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -78,6 +84,8 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_FILE_TABLE,
+	CKPT_OBJ_FILE,
 	CKPT_OBJ_MAX
 };
 
@@ -155,6 +163,12 @@ struct ckpt_hdr_task {
 	__u64 robust_futex_list; /* a __user ptr */
 } __attribute__((aligned(8)));
 
+/* task's shared resources */
+struct ckpt_hdr_task_objs {
+	struct ckpt_hdr h;
+	__s32 files_objref;
+} __attribute__((aligned(8)));
+
 /* restart blocks */
 struct ckpt_hdr_restart_block {
 	struct ckpt_hdr h;
@@ -176,4 +190,39 @@ enum restart_block_type {
 	CKPT_RESTART_BLOCK_FUTEX
 };
 
+/* file system */
+struct ckpt_hdr_file_table {
+	struct ckpt_hdr h;
+	__s32 fdt_nfds;
+} __attribute__((aligned(8)));
+
+/* file descriptors */
+struct ckpt_hdr_file_desc {
+	struct ckpt_hdr h;
+	__s32 fd_objref;
+	__s32 fd_descriptor;
+	__u32 fd_close_on_exec;
+} __attribute__((aligned(8)));
+
+enum file_type {
+	CKPT_FILE_IGNORE = 0,
+	CKPT_FILE_GENERIC,
+	CKPT_FILE_MAX
+};
+
+/* file objects */
+struct ckpt_hdr_file {
+	struct ckpt_hdr h;
+	__u32 f_type;
+	__u32 f_mode;
+	__u32 f_flags;
+	__u32 _padding;
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_generic {
+	struct ckpt_hdr_file common;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index bd78d19..c446510 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -12,6 +12,10 @@
 
 #ifdef __KERNEL__
 
+#include <linux/list.h>
+#include <linux/path.h>
+#include <linux/fs.h>
+
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/fs.h>
@@ -40,6 +44,8 @@ struct ckpt_ctx {
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 
+	struct path fs_mnt;     /* container root (FIXME) */
+
 	char err_string[256];	/* checkpoint: error string */
 
 	/* [multi-process checkpoint] */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 05d4745..2174957 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2313,7 +2313,11 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#ifdef CONFIG_CHECKPOINT
+extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+#else
 #define generic_file_checkpoint NULL
+#endif
 
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
