From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 10/12] Restore open file descriprtors
Date: Thu, 30 Oct 2008 09:51:13 -0400
Message-Id: <1225374675-22850-11-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restore open file descriptors: for each FD read 'struct cr_hdr_fd_ent'
and lookup objref in the hash table; if not found (first occurence), read
in 'struct cr_hdr_fd_data', create a new FD and register in the hash.
Otherwise attach the file pointer from the hash as an FD.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Changelog[v6]:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 checkpoint/Makefile        |    2 +-
 checkpoint/restart.c       |    4 +
 checkpoint/rstr_file.c     |  246 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    1 +
 4 files changed, 252 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/rstr_file.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 7496695..88bbc10 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o ckpt_file.o
+		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index f4d87ba..9ff9f66 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -219,6 +219,10 @@ static int cr_read_task(struct cr_ctx *ctx)
 	cr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_files(ctx);
+	cr_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_read_thread(ctx);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
new file mode 100644
index 0000000..08bb049
--- /dev/null
+++ b/checkpoint/rstr_file.c
@@ -0,0 +1,246 @@
+/*
+ *  Checkpoint file descriptors
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_file.h"
+
+static int cr_close_all_fds(struct files_struct *files)
+{
+	int *fdtable;
+	int nfds;
+
+	nfds = cr_scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+	while (nfds--)
+		sys_close(fdtable[nfds]);
+	kfree(fdtable);
+	return 0;
+}
+
+/**
+ * cr_attach_file - attach a lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int cr_attach_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+	}
+	return fd;
+}
+
+/**
+ * cr_attach_get_file - attach (and get) lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int cr_attach_get_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+		get_file(file);
+	}
+	return fd;
+}
+
+#define CR_SETFL_MASK (O_APPEND|O_NONBLOCK|O_NDELAY|FASYNC|O_DIRECT|O_NOATIME)
+
+/* cr_read_fd_data - restore the state of a given file pointer */
+static int
+cr_read_fd_data(struct cr_ctx *ctx, struct files_struct *files, int parent)
+{
+	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file;
+	int rparent, ret;
+	int fd = 0;	/* pacify gcc warning */
+
+	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_DATA);
+	cr_debug("rparent %d parent %d flags %#x mode %#x how %d\n",
+		 rparent, parent, hh->f_flags, hh->f_mode, hh->fd_type);
+	if (rparent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+
+	if (rparent != parent)
+		goto out;
+
+	/* FIX: more sanity checks on f_flags, f_mode etc */
+
+	switch (hh->fd_type) {
+	case CR_FD_FILE:
+	case CR_FD_DIR:
+	case CR_FD_LINK:
+		file = cr_read_open_fname(ctx, hh->f_flags, hh->f_mode);
+		break;
+	default:
+		goto out;
+	}
+
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	/* FIX: need to restore uid, gid, owner etc */
+
+	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
+	if (fd < 0) {
+		filp_close(file, NULL);
+		ret = fd;
+		goto out;
+	}
+
+	/* register new <objref, file> tuple in hash table */
+	ret = cr_obj_add_ref(ctx, (void *) file, parent, CR_OBJ_FILE, 0);
+	if (ret < 0)
+		goto out;
+	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
+	if (ret < 0)
+		goto out;
+	ret = vfs_llseek(file, hh->f_pos, SEEK_SET);
+	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
+		ret = 0;
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret < 0 ? ret : fd;
+}
+
+/**
+ * cr_read_fd_ent - restore the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @parent: parent objref
+ *
+ * Restores the state of a file descriptor; looks up the objref (in the
+ * header) in the hash table, and if found picks the matching file and
+ * use it; otherwise calls cr_read_fd_data to restore the file too.
+ */
+static int
+cr_read_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int parent)
+{
+	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file;
+	int newfd, rparent, ret;
+
+	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_ENT);
+	cr_debug("rparent %d parent %d ref %d fd %d c.o.e %d\n",
+		 rparent, parent, hh->objref, hh->fd, hh->close_on_exec);
+	if (rparent < 0) {
+		ret = rparent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+
+	if (rparent != parent)
+		goto out;
+	if (hh->objref <= 0)
+		goto out;
+
+	file = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_FILE);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	if (file) {
+		/* reuse file descriptor found in the hash table */
+		newfd = cr_attach_get_file(file);
+	} else {
+		/* create new file pointer (and register in hash table) */
+		newfd = cr_read_fd_data(ctx, files, hh->objref);
+	}
+
+	if (newfd < 0) {
+		ret = newfd;
+		goto out;
+	}
+
+	cr_debug("newfd got %d wanted %d\n", newfd, hh->fd);
+
+	/* if newfd isn't desired fd then reposition it */
+	if (newfd != hh->fd) {
+		ret = sys_dup2(newfd, hh->fd);
+		if (ret < 0)
+			goto out;
+		sys_close(newfd);
+	}
+
+	if (hh->close_on_exec)
+		set_close_on_exec(hh->fd, 1);
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_files(struct cr_ctx *ctx)
+{
+	struct cr_hdr_files *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct files_struct *files = current->files;
+	int i, parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FILES);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+#if 0	/* activate when containers are used */
+	if (parent != task_pid_vnr(current))
+		goto out;
+#endif
+	cr_debug("objref %d nfds %d\n", hh->objref, hh->nfds);
+	if (hh->objref < 0 || hh->nfds < 0)
+		goto out;
+
+	if (hh->nfds > sysctl_nr_open) {
+		ret = -EMFILE;
+		goto out;
+	}
+
+	/* point of no return -- close all file descriptors */
+	ret = cr_close_all_fds(files);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < hh->nfds; i++) {
+		ret = cr_read_fd_ent(ctx, files, hh->objref);
+		if (ret < 0)
+			break;
+	}
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 0856b3b..6c1e87f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -85,6 +85,7 @@ extern int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);
 
 extern int do_restart(struct cr_ctx *ctx);
 extern int cr_read_mm(struct cr_ctx *ctx);
+extern int cr_read_files(struct cr_ctx *ctx);
 
 #define cr_debug(fmt, args...)  \
 	pr_debug("[CR:%s] " fmt, __func__, ## args)
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
