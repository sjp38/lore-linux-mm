Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D91E6B0089
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:19 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 10/43] c/r: restore open file descriptors
Date: Wed, 27 May 2009 13:32:36 -0400
Message-Id: <1243445589-32388-11-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

For each fd read 'struct ckpt_hdr_file_desc' and lookup objref in the
hash table; If not found in the hash table, (first occurence), read in
'struct ckpt_hdr_file', create a new file and register in the hash.
Otherwise attach the file pointer from the hash as an FD.

Changelog[v16]:
  - Reorder patch (move earlier in series)
  - Handle shared files_struct objects

Changelog[v14]:
  - Introduce a per file-type restore() callback
  - Revert change to pr_debug(), back to ckpt_debug()
  - Rename:  restore_files() => restore_fd_table()
  - Rename:  ckpt_read_fd_data() => restore_file()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'hh->parent'

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/files.c         |  285 ++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c       |    2 +
 checkpoint/process.c       |   20 +++
 checkpoint/restart.c       |    9 ++
 include/linux/checkpoint.h |    5 +
 5 files changed, 321 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index d10dfb6..d7583d3 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -16,6 +16,8 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -309,3 +311,286 @@ int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	return objref;
 }
+
+/**************************************************************************
+ * Restart
+ */
+
+/**
+ * read_open_fname - read a file name and open a file
+ * @ctx: checkpoint context
+ * @flags: file flags
+ * @mode: file mode
+ */
+static struct file *read_open_fname(struct ckpt_ctx *ctx, int flags, int mode)
+{
+	struct ckpt_hdr *h;
+	struct file *file;
+	char *fname;
+
+	h = ckpt_read_buf_type(ctx, PATH_MAX, CKPT_HDR_FILE_NAME);
+	if (IS_ERR(h))
+		return (struct file *) h;
+	fname = (char *) (h + 1);
+	ckpt_debug("fname '%s' flags %#x mode %#x\n", fname, flags, mode);
+
+	file = filp_open(fname, flags, mode);
+	ckpt_hdr_put(ctx, h);
+	return file;
+}
+
+static int close_all_fds(struct files_struct *files)
+{
+	int *fdtable;
+	int nfds;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+	while (nfds--)
+		sys_close(fdtable[nfds]);
+	kfree(fdtable);
+	return 0;
+}
+
+/**
+ * attach_file - attach a lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int attach_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		get_file(file);
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+	}
+	return fd;
+}
+
+#define CKPT_SETFL_MASK  \
+	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
+
+int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			struct ckpt_hdr_file *h)
+{
+	int ret;
+
+	/* FIX: need to restore uid, gid, owner etc */
+
+	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
+	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
+	if (ret < 0)
+		goto out;
+
+	ret = vfs_llseek(file, h->f_pos, SEEK_SET);
+	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
+		ret = 0;
+ out:
+	return ret;
+}
+
+static struct file *generic_file_restore(struct ckpt_ctx *ctx,
+					 struct ckpt_hdr_file *ptr)
+{
+	struct file *file;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
+		return ERR_PTR(-EINVAL);
+
+	file = read_open_fname(ctx, ptr->f_flags, ptr->f_mode);
+	if (IS_ERR(file))
+		return file;
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+	return file;
+}
+
+struct restore_file_ops {
+	char *file_name;
+	enum file_type file_type;
+	struct file * (*restore) (struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_file *ptr);
+};
+
+static struct restore_file_ops restore_file_ops[] = {
+	/* ignored file */
+	{
+		.file_name = "IGNORE",
+		.file_type = CKPT_FILE_IGNORE,
+		.restore = NULL,
+	},
+	/* regular file/directory */
+	{
+		.file_name = "GENERIC",
+		.file_type = CKPT_FILE_GENERIC,
+		.restore = generic_file_restore,
+	},
+};
+
+static struct file *do_restore_file(struct ckpt_ctx *ctx)
+{
+	struct restore_file_ops *ops;
+	struct ckpt_hdr_file *h;
+	struct file *file = ERR_PTR(-EINVAL);
+
+	/*
+	 * All 'struct ckpt_hdr_file_...' begin with ckpt_hdr_file,
+	 * but the actual object depends on the file type. The length
+	 * should never be more than page.
+	 */
+	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_FILE);
+	if (IS_ERR(h))
+		return (struct file *) h;
+	ckpt_debug("flags %#x mode %#x type %d\n",
+		 h->f_flags, h->f_mode, h->f_type);
+
+	if (h->f_type >= CKPT_FILE_MAX)
+		goto out;
+
+	ops = &restore_file_ops[h->f_type];
+	BUG_ON(ops->file_type != h->f_type);
+
+	if (ops->restore)
+		file = ops->restore(ctx, h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return file;
+}
+
+/* restore callback for file pointer */
+void *restore_file(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_file(ctx);
+}
+
+/**
+ * ckpt_read_file_desc - restore the state of a given file descriptor
+ * @ctx: checkpoint context
+ *
+ * Restores the state of a file descriptor; looks up the objref (in the
+ * header) in the hash table, and if found picks the matching file and
+ * use it; otherwise calls restore_file to restore the file too.
+ */
+static int restore_file_desc(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_file_desc *h;
+	struct file *file;
+	int newfd, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_debug("ref %d fd %d c.o.e %d\n",
+		 h->fd_objref, h->fd_descriptor, h->fd_close_on_exec);
+
+	ret = -EINVAL;
+	if (h->fd_objref <= 0 || h->fd_descriptor < 0)
+		goto out;
+
+	file = ckpt_obj_fetch(ctx, h->fd_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	newfd = attach_file(file);
+	if (newfd < 0) {
+		ret = newfd;
+		goto out;
+	}
+
+	ckpt_debug("newfd got %d wanted %d\n", newfd, h->fd_descriptor);
+
+	/* reposition if newfd isn't desired fd */
+	if (newfd != h->fd_descriptor) {
+		ret = sys_dup2(newfd, h->fd_descriptor);
+		if (ret < 0)
+			goto out;
+		sys_close(newfd);
+	}
+
+	if (h->fd_close_on_exec)
+		set_close_on_exec(h->fd_descriptor, 1);
+
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* restore callback for file table */
+static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_file_table *h;
+	struct files_struct *files;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
+	if (IS_ERR(h))
+		return (struct files_struct *) h;
+
+	ckpt_debug("nfds %d\n", h->fdt_nfds);
+
+	ret = -EMFILE;
+	if (h->fdt_nfds < 0 || h->fdt_nfds > sysctl_nr_open)
+		goto out;
+
+	/*
+	 * We assume that restarting tasks, as created in user-space,
+	 * have distinct files_struct objects each. If not, we need to
+	 * call dup_fd() to make sure we don't overwrite an already
+	 * restored one.
+	 */
+
+	/* point of no return -- close all file descriptors */
+	ret = close_all_fds(current->files);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < h->fdt_nfds; i++) {
+		ret = restore_file_desc(ctx);
+		if (ret < 0)
+			break;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (!ret) {
+		files = current->files;
+		atomic_inc(&files->count);
+	} else {
+		files = ERR_PTR(ret);
+	}
+	return files;
+}
+
+void *restore_file_table(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_file_table(ctx);
+}
+
+int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
+{
+	struct files_struct *files;
+
+	files = ckpt_obj_fetch(ctx, files_objref, CKPT_OBJ_FILE_TABLE);
+	if (IS_ERR(files))
+		return PTR_ERR(files);
+
+	if (files != current->files) {
+		task_lock(current);
+		put_files_struct(current->files);
+		current->files = files;
+		task_unlock(current);
+		atomic_inc(&files->count);
+	}
+
+	return 0;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ea15958..f5c9f7c 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -92,6 +92,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_file_table_drop,
 		.ref_grab = obj_file_table_grab,
 		.checkpoint = checkpoint_file_table,
+		.restore = restore_file_table,
 	},
 	/* file object */
 	{
@@ -100,6 +101,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_file_drop,
 		.ref_grab = obj_file_grab,
 		.checkpoint = checkpoint_file,
+		.restore = restore_file,
 	},
 };
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 4c922b6..5fd1573 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -121,6 +121,22 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_objs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_objs *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = restore_obj_file_table(ctx, h->files_objref);
+	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
@@ -130,6 +146,10 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = restore_task_objs(ctx);
+	ckpt_debug("shared %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = restore_thread(ctx);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index ce52e30..d3d6c5e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -351,10 +351,19 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
 int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	ret = init_restart_ctx(ctx);
+	if (ret < 0)
+		return ret;
 	ret = restore_read_header(ctx);
 	if (ret < 0)
 		return ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d170988..bb14a66 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -70,13 +70,18 @@ extern int restore_cpu(struct ckpt_ctx *ctx);
 /* file table */
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
 				     struct task_struct *t);
+extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
 extern int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_file_table(struct ckpt_ctx *ctx);
 
 /* files */
 extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_file(struct ckpt_ctx *ctx);
 
 extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 				  struct ckpt_hdr_file *h);
+extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			       struct ckpt_hdr_file *h);
 
 
 /* debugging flags */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
