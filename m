Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9GIIgaA001353
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:18:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9GIEXlP056956
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9GIETVL028115
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:32 -0400
Subject: [PATCH 8/9] Dump open file descriptors
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 16 Oct 2008 11:14:26 -0700
References: <20081016181414.934C4FCC@kernel>
In-Reply-To: <20081016181414.934C4FCC@kernel>
Message-Id: <20081016181426.1BFD15C8@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

Dump the files_struct of a task with 'struct cr_hdr_files', followed by
all open file descriptors. Since FDs can be shared, they are assigned an
objref and registered in the object hash.

For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its objref
and its close-on-exec property. If the FD is to be saved (first time)
then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
Then will come the next FD and so on.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/checkpoint/Makefile            |    2 
 linux-2.6.git-dave/checkpoint/checkpoint.c        |    4 
 linux-2.6.git-dave/checkpoint/checkpoint_file.h   |   17 +
 linux-2.6.git-dave/checkpoint/ckpt_file.c         |  231 ++++++++++++++++++++++
 linux-2.6.git-dave/include/linux/checkpoint.h     |    7 
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h |   32 ++-
 6 files changed, 288 insertions(+), 5 deletions(-)

diff -puN checkpoint/checkpoint.c~v6_PATCH_8_9_Dump_open_file_descriptors checkpoint/checkpoint.c
--- linux-2.6.git/checkpoint/checkpoint.c~v6_PATCH_8_9_Dump_open_file_descriptors	2008-10-16 10:53:38.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint.c	2008-10-16 10:53:38.000000000 -0700
@@ -203,6 +203,10 @@ static int cr_write_task(struct cr_ctx *
 	cr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_files(ctx, t);
+	cr_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_thread(ctx, t);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff -puN /dev/null checkpoint/checkpoint_file.h
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint_file.h	2008-10-16 10:53:38.000000000 -0700
@@ -0,0 +1,17 @@
+#ifndef _CHECKPOINT_CKPT_FILE_H_
+#define _CHECKPOINT_CKPT_FILE_H_
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
+#include <linux/fdtable.h>
+
+int cr_scan_fds(struct files_struct *files, int **fdtable);
+
+#endif /* _CHECKPOINT_CKPT_FILE_H_ */
diff -puN /dev/null checkpoint/ckpt_file.c
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2008-10-16 10:53:38.000000000 -0700
@@ -0,0 +1,231 @@
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
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_file.h"
+
+#define CR_DEFAULT_FDTABLE  256		/* an initial guess */
+
+/**
+ * cr_scan_fds - scan file table and construct array of open fds
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
+int cr_scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds;
+	int i, n = 0;
+	int tot = CR_DEFAULT_FDTABLE;
+
+	fds = kmalloc(tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	/*
+	 * We assume that the target task is frozen (or that we checkpoint
+	 * ourselves), so we can safely proceed after krealloc() from where
+	 * we left off; in the worst cases restart will fail.
+	 */
+
+	spin_lock(&files->file_lock);
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (i = 0; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			/*
+			 * fcheck_files() is safe with drop/re-acquire
+			 * of the lock, because it tests:  fd < max_fds
+			 */
+			spin_unlock(&files->file_lock);
+			rcu_read_unlock();
+			tot *= 2;	/* won't overflow: kmalloc will fail */
+			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+			if (!fds) {
+				kfree(fds);
+				return -ENOMEM;
+			}
+			rcu_read_lock();
+			spin_lock(&files->file_lock);
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
+/* cr_write_fd_data - dump the state of a given file pointer */
+static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct dentry *dent = file->f_dentry;
+	struct inode *inode = dent->d_inode;
+	enum fd_type fd_type;
+	int ret;
+
+	h.type = CR_HDR_FD_DATA;
+	h.len = sizeof(*hh);
+	h.parent = parent;
+
+	hh->f_flags = file->f_flags;
+	hh->f_mode = file->f_mode;
+	hh->f_pos = file->f_pos;
+	hh->f_version = file->f_version;
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+
+	switch (inode->i_mode & S_IFMT) {
+	case S_IFREG:
+		fd_type = CR_FD_FILE;
+		break;
+	case S_IFDIR:
+		fd_type = CR_FD_DIR;
+		break;
+	case S_IFLNK:
+		fd_type = CR_FD_LINK;
+		break;
+	default:
+		cr_hbuf_put(ctx, sizeof(*hh));
+		return -EBADF;
+	}
+
+	/* FIX: check if the file/dir/link is unlinked */
+	hh->fd_type = fd_type;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	return cr_write_fname(ctx, &file->f_path, ctx->vfsroot);
+}
+
+/**
+ * cr_write_fd_ent - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls cr_write_fd_data to dump the file pointer too.
+ */
+static int
+cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int coe, objref, new, ret;
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
+	if (!file) {
+		ret = -EBADF;
+		goto out;
+	}
+
+	new = cr_obj_add_ptr(ctx, file, &objref, CR_OBJ_FILE, 0);
+	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
+
+	if (new < 0) {
+		ret = new;
+		goto out;
+	}
+
+	h.type = CR_HDR_FD_ENT;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->objref = objref;
+	hh->fd = fd;
+	hh->close_on_exec = coe;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	/* new==1 if-and-only-if file was newly added to hash */
+	if (new)
+		ret = cr_write_fd_data(ctx, file, objref);
+
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	fput(file);
+	return ret;
+}
+
+int cr_write_files(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_files *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct files_struct *files;
+	int *fdtable;
+	int nfds, n, ret;
+
+	h.type = CR_HDR_FILES;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
+
+	files = get_files_struct(t);
+
+	nfds = cr_scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		put_files_struct(files);
+		return nfds;
+	}
+
+	hh->objref = 0;	/* will be meaningful with multiple processes */
+	hh->nfds = nfds;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto clean;
+
+	cr_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = cr_write_fd_ent(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+
+ clean:
+	kfree(fdtable);
+	put_files_struct(files);
+	return ret;
+}
diff -puN checkpoint/Makefile~v6_PATCH_8_9_Dump_open_file_descriptors checkpoint/Makefile
--- linux-2.6.git/checkpoint/Makefile~v6_PATCH_8_9_Dump_open_file_descriptors	2008-10-16 10:53:38.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Makefile	2008-10-16 10:53:38.000000000 -0700
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o
+		ckpt_mem.o rstr_mem.o ckpt_file.o
diff -puN include/linux/checkpoint.h~v6_PATCH_8_9_Dump_open_file_descriptors include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~v6_PATCH_8_9_Dump_open_file_descriptors	2008-10-16 10:53:38.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2008-10-16 10:53:38.000000000 -0700
@@ -13,7 +13,7 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 
-#define CR_VERSION  1
+#define CR_VERSION  2
 
 struct cr_ctx {
 	pid_t pid;		/* container identifier */
@@ -79,11 +79,12 @@ extern int cr_read_fname(struct cr_ctx *
 extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 				       int flags, int mode);
 
+extern int do_checkpoint(struct cr_ctx *ctx);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
-extern int cr_read_mm(struct cr_ctx *ctx);
+extern int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);
 
-extern int do_checkpoint(struct cr_ctx *ctx);
 extern int do_restart(struct cr_ctx *ctx);
+extern int cr_read_mm(struct cr_ctx *ctx);
 
 /* there are from fs/read_write.c, not exported otherwise in a header */
 extern loff_t file_pos_read(struct file *file);
diff -puN include/linux/checkpoint_hdr.h~v6_PATCH_8_9_Dump_open_file_descriptors include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~v6_PATCH_8_9_Dump_open_file_descriptors	2008-10-16 10:53:38.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2008-10-16 10:53:38.000000000 -0700
@@ -17,7 +17,7 @@
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
- * __attribute__ ((aligned (8))) for the entire structure.
+ * __attribute__((aligned(8))) for the entire structure.
  */
 
 /* records: generic header */
@@ -43,6 +43,10 @@ enum {
 	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
+	CR_HDR_FILES = 301,
+	CR_HDR_FD_ENT,
+	CR_HDR_FD_DATA,
+
 	CR_HDR_TAIL = 5001
 };
 
@@ -105,4 +109,30 @@ struct cr_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+struct cr_hdr_files {
+	__u32 objref;		/* identifier for shared objects */
+	__u32 nfds;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_fd_ent {
+	__u32 objref;		/* identifier for shared objects */
+	__s32 fd;
+	__u32 close_on_exec;
+} __attribute__((aligned(8)));
+
+/* fd types */
+enum  fd_type {
+	CR_FD_FILE = 1,
+	CR_FD_DIR,
+	CR_FD_LINK
+};
+
+struct cr_hdr_fd_data {
+	__u16 fd_type;
+	__u16 f_mode;
+	__u32 f_flags;
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
