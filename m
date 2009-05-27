Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2C406B0093
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:21 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 09/43] c/r: dump open file descriptors
Date: Wed, 27 May 2009 13:32:35 -0400
Message-Id: <1243445589-32388-10-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
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
 checkpoint/checkpoint.c          |   25 +++
 checkpoint/files.c               |  311 ++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c             |   40 +++++
 checkpoint/process.c             |   28 ++++
 checkpoint/sys.c                 |    1 +
 include/linux/checkpoint.h       |   14 ++-
 include/linux/checkpoint_hdr.h   |   49 ++++++
 include/linux/checkpoint_types.h |    8 +
 include/linux/fs.h               |    4 +
 10 files changed, 481 insertions(+), 2 deletions(-)

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
index 409c78b..a346b7e 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -15,6 +15,7 @@
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/fs_struct.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/utsname.h>
@@ -244,10 +245,34 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* setup checkpoint-specific parts of ctx */
+static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct fs_struct *fs;
+
+	ctx->root_pid = pid;
+
+	/*
+	 * assume checkpointer is in container's root vfs
+	 * FIXME: this works for now, but will change with real containers
+	 */
+
+	fs = current->fs;
+	read_lock(&fs->lock);
+	ctx->fs_mnt = fs->root;
+	path_get(&ctx->fs_mnt);
+	read_unlock(&fs->lock);
+
+	return 0;
+}
+
 int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	ret = init_checkpoint_ctx(ctx, pid);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/files.c b/checkpoint/files.c
new file mode 100644
index 0000000..d10dfb6
--- /dev/null
+++ b/checkpoint/files.c
@@ -0,0 +1,311 @@
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
+ * dump_fname - write a file name
+ * @ctx: checkpoint context
+ * @path: path name
+ * @root: relative root
+ */
+static int dump_fname(struct ckpt_ctx *ctx,
+		      struct path *path, struct path *root)
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
+	spin_lock(&files->file_lock);
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (/**/; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			spin_unlock(&files->file_lock);
+			rcu_read_unlock();
+			tot *= 2;	/* won't overflow: kmalloc will fail */
+			goto retry;
+		}
+		fds[n++] = i;
+	}
+	rcu_read_unlock();
+	spin_unlock(&files->file_lock);
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
+	ret = dump_fname(ctx, &file->f_path, &ctx->fs_mnt);
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
+	if (!file->f_op->checkpoint)
+		return -EBADF;
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
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 82b4618..ea15958 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,8 @@
 
 #include <linux/kernel.h>
 #include <linux/hash.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -53,6 +55,28 @@ static int obj_no_grab(void *ptr)
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
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -61,6 +85,22 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_no_drop,
 		.ref_grab = obj_no_grab,
 	},
+	/* files_struct object */
+	{
+		.obj_name = "FILE_TABLE",
+		.obj_type = CKPT_OBJ_FILE_TABLE,
+		.ref_drop = obj_file_table_drop,
+		.ref_grab = obj_file_table_grab,
+		.checkpoint = checkpoint_file_table,
+	},
+	/* file object */
+	{
+		.obj_name = "FILE",
+		.obj_type = CKPT_OBJ_FILE,
+		.ref_drop = obj_file_drop,
+		.ref_grab = obj_file_grab,
+		.checkpoint = checkpoint_file,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 6cab717..4c922b6 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -46,6 +46,30 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
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
 /* dump the entire state of a given task */
 int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -55,6 +79,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("shared %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index c8a260d..c2d3d90 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -170,6 +170,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		fput(ctx->file);
 
 	ckpt_obj_hash_free(ctx);
+	path_put(&ctx->fs_mnt);
 
 	kfree(ctx);
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 9f65a81..d170988 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -67,14 +67,26 @@ extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
 
+/* file table */
+extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
+				     struct task_struct *t);
+extern int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr);
+
+/* files */
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
 
-#define CKPT_DDEFAULT	0x7		/* default debug level */
+#define CKPT_DDEFAULT	0x17		/* default debug level */
 
 #ifndef CKPT_DFLAG
 #define CKPT_DFLAG	0x0		/* nothing */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 195e44b..5b4fc52 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -47,11 +47,17 @@ enum {
 	CKPT_HDR_OBJREF,
 
 	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TASK_OBJS,
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
@@ -72,6 +78,8 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_FILE_TABLE,
+	CKPT_OBJ_FILE,
 	CKPT_OBJ_MAX
 };
 
@@ -121,4 +129,45 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* task's shared resources */
+struct ckpt_hdr_task_objs {
+	struct ckpt_hdr h;
+	__s32 files_objref;
+} __attribute__((aligned(8)));
+
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
index 9c14034..067d579 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -14,6 +14,12 @@
 
 
 #ifdef __KERNEL__
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
+#include <linux/list.h>
+#include <linux/path.h>
+#include <linux/fs.h>
 
 #include <linux/sched.h>
 
@@ -31,6 +37,8 @@ struct ckpt_ctx {
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 
+	struct path fs_mnt;     /* container root (FIXME) */
+
 	char err_string[256];	/* checkpoint: error string */
 };
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 60d9229..e64f892 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2310,7 +2310,11 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
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
