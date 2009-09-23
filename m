Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBA36B00AC
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:41 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 34/80] c/r: dump open file descriptors
Date: Wed, 23 Sep 2009 19:51:14 -0400
Message-Id: <1253749920-18673-35-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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

Changelog[v18]:
  - Add a few more ckpt_write_err()s
  - [Dan Smith] Export fill_fname() as ckpt_fill_fname()
  - Introduce ckpt_collect_file() that also uses file->collect method
  - In collect_file_stabl() use retval from ckpt_obj_collect() to
    test for first-time-object
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
 checkpoint/files.c               |  417 ++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c             |   52 +++++
 checkpoint/process.c             |   33 +++-
 checkpoint/sys.c                 |    8 +
 include/linux/checkpoint.h       |   19 ++
 include/linux/checkpoint_hdr.h   |   49 +++++
 include/linux/checkpoint_types.h |    5 +
 include/linux/fs.h               |    4 +
 10 files changed, 599 insertions(+), 2 deletions(-)
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
index c21646d..4cc2a2f 100644
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
@@ -673,6 +674,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task;
 	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
 
 	/*
 	 * No need for explicit cleanup here, because if an error
@@ -714,6 +716,15 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
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
index 0000000..a554cbc
--- /dev/null
+++ b/checkpoint/files.c
@@ -0,0 +1,417 @@
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
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * ckpt_fill_fname - return pathname of a given file
+ * @path: path name
+ * @root: relative root
+ * @buf: buffer for pathname
+ * @len: buffer length (in) and pathname length (out)
+ */
+char *ckpt_fill_fname(struct path *path, struct path *root, char *buf, int *len)
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
+	fname = ckpt_fill_fname(path, root, buf, &flen);
+	if (!IS_ERR(fname)) {
+		ret = ckpt_write_obj_type(ctx, fname, flen,
+					  CKPT_HDR_FILE_NAME);
+	} else {
+		ret = PTR_ERR(fname);
+		ckpt_write_err(ctx, "TEP", "obtain filename (file)", ret);
+	}
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
+	int ret;
+
+	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_write_err(ctx, "TEPS", "f_op lacks checkpoint",
+			       -EBADF, file, file->f_op);
+		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
+		return -EBADF;
+	}
+	if (d_unlinked(file->f_dentry)) {
+		ckpt_write_err(ctx, "TEP", "unlinked file", -EBADF, file);
+		ckpt_debug("unlinked files are unsupported\n");
+		return -EBADF;
+	}
+
+	ret = file->f_op->checkpoint(ctx, file);
+	if (ret < 0)
+		ckpt_write_err(ctx, "TEP", "file checkpoint failed", ret, file);
+	return ret;
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
+	if (!file) {
+		pr_warning("c/r: file descriptor gone?");
+		ckpt_write_err(ctx, "TEP", "file gone? (%d)", ret, file, fd);
+		goto out;
+	}
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
+			goto out;
+	}
+
+	ret = deferqueue_run(ctx->files_deferq);
+	ckpt_debug("files_deferq ran %d entries\n", ret);
+	if (ret > 0)
+		ret = 0;
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
+int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file)
+{
+	int ret;
+
+	ret = ckpt_obj_collect(ctx, file, CKPT_OBJ_FILE);
+	if (ret <= 0)
+		return ret;
+	/* if first time for this file (ret > 0), invoke ->collect() */
+	if (file->f_op->collect)
+		ret = file->f_op->collect(ctx, file);
+	if (ret < 0)
+		ckpt_write_err(ctx, "TEP", "file collect", ret, file);
+	return ret;
+}
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
+	if (!file) {
+		ckpt_write_err(ctx, "TE", "file removed", -EBUSY, file);
+		return -EBUSY;
+	}
+
+	ret = ckpt_collect_file(ctx, file);
+	fput(file);
+
+	return ret;
+}
+
+static int collect_file_table(struct ckpt_ctx *ctx, struct files_struct *files)
+{
+	int *fdtable;
+	int nfds, n;
+	int ret;
+
+	/* if already exists (ret == 0), nothing to do */
+	ret = ckpt_obj_collect(ctx, files, CKPT_OBJ_FILE_TABLE);
+	if (ret <= 0)
+		return ret;
+
+	/* if first time for this file table (ret > 0), proceed inside */
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
+	if (!files) {
+		ckpt_write_err(ctx, "TE", "files_struct missing", -EBUSY);
+		return -EBUSY;
+	}
+	ret = collect_file_table(ctx, files);
+	put_files_struct(files);
+
+	return ret;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index dd1f3e5..cefbab6 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,8 @@
 
 #include <linux/kernel.h>
 #include <linux/hash.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -62,6 +64,38 @@ static int obj_no_grab(void *ptr)
 	return 0;
 }
 
+static int obj_file_table_grab(void *ptr)
+{
+	atomic_inc(&((struct files_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_file_table_drop(void *ptr, int lastref)
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
+static void obj_file_drop(void *ptr, int lastref)
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
@@ -70,6 +104,24 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
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
index 5e690d3..042dc45 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -104,6 +104,29 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
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
+		ckpt_write_err(ctx, "TE", "files_struct", files_objref);
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
@@ -231,6 +254,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (t->exit_state)
 		return 0;
 
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
@@ -248,7 +275,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
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
index d16d48f..1373ff9 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -191,10 +191,14 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	if (ctx->files_deferq)
+		deferqueue_destroy(ctx->files_deferq);
+
 	if (ctx->file)
 		fput(ctx->file);
 
 	ckpt_obj_hash_free(ctx);
+	path_put(&ctx->fs_mnt);
 
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
@@ -237,6 +241,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
 
+	ctx->files_deferq = deferqueue_create();
+	if (!ctx->files_deferq)
+		goto err;
+
 	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index b698b19..6fa5035 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -70,6 +70,9 @@ extern int ckpt_read_payload(struct ckpt_ctx *ctx,
 extern char *ckpt_read_string(struct ckpt_ctx *ctx, int max);
 extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
+extern char *ckpt_fill_fname(struct path *path, struct path *root,
+			     char *buf, int *len);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -137,6 +140,21 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
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
+extern int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file);
+extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
+
+extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+				  struct ckpt_hdr_file *h);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
@@ -147,6 +165,7 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
 #define CKPT_DOBJ	0x8		/* shared objects */
+#define CKPT_DFILE	0x10		/* files and filesystem */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 7a4015b..1124375 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -54,12 +54,18 @@ enum {
 
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
@@ -80,6 +86,8 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_FILE_TABLE,
+	CKPT_OBJ_FILE,
 	CKPT_OBJ_MAX
 };
 
@@ -157,6 +165,12 @@ struct ckpt_hdr_task {
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
@@ -178,4 +192,39 @@ enum restart_block_type {
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
index f11fd07..795742f 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -14,6 +14,8 @@
 
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
+#include <linux/list.h>
+#include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
 #include <linux/wait.h>
@@ -39,6 +41,9 @@ struct ckpt_ctx {
 	atomic_t refcount;
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+	struct deferqueue_head *files_deferq;	/* deferred file-table work */
+
+	struct path fs_mnt;     /* container root (FIXME) */
 
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 02638a7..5ec844f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2316,7 +2316,11 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
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
