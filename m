Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB706B021A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:47 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 39/96] c/r: restore open file descriptors
Date: Wed, 17 Mar 2010 12:08:27 -0400
Message-Id: <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

For each fd read 'struct ckpt_hdr_file_desc' and lookup objref in the
hash table; If not found in the hash table, (first occurence), read in
'struct ckpt_hdr_file', create a new file and register in the hash.
Otherwise attach the file pointer from the hash as an FD.


Changelog[v19-rc1]:
  - Fix lockdep complaint in restore_obj_files()
Changelog[v19-rc1]:
  - Restore thread/cpu state early
  - Ensure null-termination of file names read from image
  - Fix compile warning in restore_open_fname()
Changelog[v18]:
  - Invoke set_close_on_exec() unconditionally on restart
Changelog[v17]:
  - Validate f_mode after restore against saved f_mode
  - Fail if f_flags have O_CREAT|O_EXCL|O_NOCTTY|O_TRUN
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
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/files.c         |  318 ++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c       |    2 +
 checkpoint/process.c       |   20 +++
 include/linux/checkpoint.h |    7 +
 4 files changed, 347 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 7a57b24..b404c8f 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -16,6 +16,8 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -442,3 +444,319 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	return ret;
 }
+
+/**************************************************************************
+ * Restart
+ */
+
+/**
+ * restore_open_fname - read a file name and open a file
+ * @ctx: checkpoint context
+ * @flags: file flags
+ */
+struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
+{
+	struct file *file;
+	char *fname;
+	int len;
+
+	/* prevent bad input from doing bad things */
+	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
+		return ERR_PTR(-EINVAL);
+
+	len = ckpt_read_payload(ctx, (void **) &fname,
+				PATH_MAX, CKPT_HDR_FILE_NAME);
+	if (len < 0)
+		return ERR_PTR(len);
+	fname[len - 1] = '\0';	/* always play if safe */
+	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
+
+	file = filp_open(fname, flags, 0);
+	kfree(fname);
+
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
+	fmode_t new_mode = file->f_mode;
+	fmode_t saved_mode = (__force fmode_t) h->f_mode;
+	int ret;
+
+	/* FIX: need to restore uid, gid, owner etc */
+
+	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
+	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Normally f_mode is set by open, and modified only via
+	 * fcntl(), so its value now should match that at checkpoint.
+	 * However, a file may be downgraded from (read-)write to
+	 * read-only, e.g:
+	 *  - mark_files_ro() unsets FMODE_WRITE
+	 *  - nfs4_file_downgrade() too, and also sert FMODE_READ
+	 * Validate the new f_mode against saved f_mode, allowing:
+	 *  - new with FMODE_WRITE, saved without FMODE_WRITE
+	 *  - new without FMODE_READ, saved with FMODE_READ
+	 */
+	if ((new_mode & FMODE_WRITE) && !(saved_mode & FMODE_WRITE)) {
+		new_mode &= ~FMODE_WRITE;
+		if (!(new_mode & FMODE_READ) && (saved_mode & FMODE_READ))
+			new_mode |= FMODE_READ;
+	}
+	/* finally, at this point new mode should match saved mode */
+	if (new_mode ^ saved_mode)
+		return -EINVAL;
+
+	if (file->f_mode & FMODE_LSEEK)
+		ret = vfs_llseek(file, h->f_pos, SEEK_SET);
+
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
+	file = restore_open_fname(ctx, ptr->f_flags);
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
+	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
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
+			goto out;
+	}
+
+	ret = deferqueue_run(ctx->files_deferq);
+	ckpt_debug("files_deferq ran %d entries\n", ret);
+	if (ret > 0)
+		ret = 0;
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
+		struct files_struct *prev;
+
+		task_lock(current);
+		prev = current->files;
+		current->files = files;
+		atomic_inc(&files->count);
+		task_unlock(current);
+
+		put_files_struct(prev);
+	}
+
+	return 0;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index f25d130..cacc4c7 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -112,6 +112,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_grab = obj_file_table_grab,
 		.ref_users = obj_file_table_users,
 		.checkpoint = checkpoint_file_table,
+		.restore = restore_file_table,
 	},
 	/* file object */
 	{
@@ -121,6 +122,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_grab = obj_file_grab,
 		.ref_users = obj_file_users,
 		.checkpoint = checkpoint_file,
+		.restore = restore_file,
 	},
 };
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index adc34a2..23e0296 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -348,6 +348,22 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
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
 int restore_restart_block(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_restart_block *h;
@@ -477,6 +493,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_objs(ctx);
+	ckpt_debug("objs %d\n", ret);
  out:
 	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d74a890..749f30c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -163,16 +163,23 @@ extern int restore_restart_block(struct ckpt_ctx *ctx);
 extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
 				     struct task_struct *t);
+extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
 extern int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_file_table(struct ckpt_ctx *ctx);
 
 /* files */
 extern int checkpoint_fname(struct ckpt_ctx *ctx,
 			    struct path *path, struct path *root);
+extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags);
+
 extern int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file);
 extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_file(struct ckpt_ctx *ctx);
 
 extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 				  struct ckpt_hdr_file *h);
+extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			       struct ckpt_hdr_file *h);
 
 static inline int ckpt_validate_errno(int errno)
 {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
