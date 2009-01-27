Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCE16B0083
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 12:08:52 -0500 (EST)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v13][PATCH 04/14] General infrastructure for checkpoint restart
Date: Tue, 27 Jan 2009 12:08:02 -0500
Message-Id: <1233076092-8660-5-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add those interfaces, as well as helpers needed to easily manage the
file format. The code is roughly broken out as follows:

checkpoint/sys.c - user/kernel data transfer, as well as setup of the
  CR context (a per-checkpoint data structure for housekeeping)
checkpoint/checkpoint.c - output wrappers and basic checkpoint handling
checkpoint/restart.c - input wrappers and basic restart handling

For now, we can only checkpoint the 'current' task ("self" checkpoint),
and the 'pid' argument to to the syscall is ignored.

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Changelog[v12]:
  - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
  - Split cr_write/cr_read() to two parts: _cr_write/read() helper
  - Befriend with sparse : explicit conversion to 'void __user *'
  - Redfine 'pr_fmt' instead of using special cr_debug()

Changelog[v10]:
  - add cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()
  - force end-of-string in cr_read_string() (fix possible DoS)

Changelog[v9]:
  - cr_kwrite/cr_kread() use file->f_op->write() directly
  - Drop cr_uwrite/cr_uread() since they aren't used anywhere

Changelog[v6]:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (although it's not really needed)

Changelog[v5]:
  - Rename headers files s/ckpt/checkpoint/

Changelog[v2]:
  - Added utsname->{release,version,machine} to checkpoint header
  - Pad header structures to 64 bits to ensure compatibility

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Makefile                       |    2 +-
 checkpoint/Makefile            |    2 +-
 checkpoint/checkpoint.c        |  188 +++++++++++++++++++++++++++++++
 checkpoint/restart.c           |  239 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c               |  216 +++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |   61 ++++++++++
 include/linux/checkpoint_hdr.h |   85 ++++++++++++++
 include/linux/magic.h          |    3 +
 8 files changed, 790 insertions(+), 6 deletions(-)
 create mode 100644 checkpoint/checkpoint.c
 create mode 100644 checkpoint/restart.c
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 include/linux/checkpoint_hdr.h

diff --git a/Makefile b/Makefile
index 71e98e9..c1744a1 100644
--- a/Makefile
+++ b/Makefile
@@ -619,7 +619,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 07d018b..d2df68c 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,4 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
new file mode 100644
index 0000000..35bf99b
--- /dev/null
+++ b/checkpoint/checkpoint.c
@@ -0,0 +1,188 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/time.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/utsname.h>
+#include <linux/magic.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* unique checkpoint identifier (FIXME: should be per-container ?) */
+static atomic_t cr_ctx_count = ATOMIC_INIT(0);
+
+/**
+ * cr_write_obj - write a record described by a cr_hdr
+ * @ctx: checkpoint context
+ * @h: record descriptor
+ * @buf: record buffer
+ */
+int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf)
+{
+	int ret;
+
+	ret = cr_kwrite(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	return cr_kwrite(ctx, buf, h->len);
+}
+
+/**
+ * cr_write_buffer - write a buffer
+ * @ctx: checkpoint context
+ * @str: buffer pointer
+ * @len: buffer size
+ */
+int cr_write_buffer(struct cr_ctx *ctx, void *buf, int len)
+{
+	struct cr_hdr h;
+
+	h.type = CR_HDR_BUFFER;
+	h.len = len;
+	h.parent = 0;
+
+	return cr_write_obj(ctx, &h, buf);
+}
+
+/**
+ * cr_write_string - write a string
+ * @ctx: checkpoint context
+ * @str: string pointer
+ * @len: string length
+ */
+int cr_write_string(struct cr_ctx *ctx, char *str, int len)
+{
+	struct cr_hdr h;
+
+	h.type = CR_HDR_STRING;
+	h.len = len;
+	h.parent = 0;
+
+	return cr_write_obj(ctx, &h, str);
+}
+
+/* write the checkpoint header */
+static int cr_write_head(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct new_utsname *uts;
+	struct timeval ktv;
+	int ret;
+
+	h.type = CR_HDR_HEAD;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	do_gettimeofday(&ktv);
+
+	hh->magic = CHECKPOINT_MAGIC_HEAD;
+	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	hh->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	hh->rev = CR_VERSION;
+
+	hh->flags = ctx->flags;
+	hh->time = ktv.tv_sec;
+
+	uts = utsname();
+	memcpy(hh->release, uts->release, __NEW_UTS_LEN);
+	memcpy(hh->version, uts->version, __NEW_UTS_LEN);
+	memcpy(hh->machine, uts->machine, __NEW_UTS_LEN);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* write the checkpoint trailer */
+static int cr_write_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_tail *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_TAIL;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->magic = CHECKPOINT_MAGIC_TAIL;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* dump the task_struct of a given task */
+static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_TASK;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->state = t->state;
+	hh->exit_state = t->exit_state;
+	hh->exit_code = t->exit_code;
+	hh->exit_signal = t->exit_signal;
+
+	hh->task_comm_len = TASK_COMM_LEN;
+
+	/* FIXME: save remaining relevant task_struct fields */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	return cr_write_string(ctx, t->comm, TASK_COMM_LEN);
+}
+
+/* dump the entire state of a given task */
+static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+
+	ret = cr_write_task_struct(ctx, t);
+	pr_debug("ret %d\n", ret);
+
+	return ret;
+}
+
+int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = cr_write_head(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_task(ctx, current);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	ctx->crid = atomic_inc_return(&cr_ctx_count);
+
+	/* on success, return (unique) checkpoint identifier */
+	ret = ctx->crid;
+ out:
+	return ret;
+}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
new file mode 100644
index 0000000..4741f4a
--- /dev/null
+++ b/checkpoint/restart.c
@@ -0,0 +1,239 @@
+/*
+ *  Restart logic and helpers
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/**
+ * cr_read_obj - read a whole record (cr_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: record descriptor
+ * @buf: record buffer
+ * @len: available buffer size
+ */
+int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int len)
+{
+	int ret;
+
+	ret = cr_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+
+	pr_debug("type %d len %d parent %d\n", h->type, h->len, h->parent);
+
+	if (h->len < 0 || h->len > len)
+		return -EINVAL;
+
+	return cr_kread(ctx, buf, h->len);
+}
+
+/**
+ * cr_read_obj_type - read a whole record of expected type and size
+ * @ctx: checkpoint context
+ * @buf: record buffer
+ * @n: expected record size
+ * @type: expected record type
+ *
+ * Returns objref of the parent object
+ */
+int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int len, int type)
+{
+	struct cr_hdr h;
+	int ret;
+
+	ret = cr_read_obj(ctx, &h, buf, len);
+	if (ret < 0)
+		return ret;
+
+	if (h.len != len || h.type != type)
+		return -EINVAL;
+
+	return h.parent;
+}
+
+/**
+ * cr_read_buf_type - read a whole record of expected type (unknown size)
+ * @ctx: checkpoint context
+ * @buf: record buffer
+ * @n: availabe buffer size (output: actual record size)
+ * @type: expected record type
+ *
+ * Returns objref of the parent object
+ */
+int cr_read_buf_type(struct cr_ctx *ctx, void *buf, int *len, int type)
+{
+	struct cr_hdr h;
+	int ret;
+
+	ret = cr_read_obj(ctx, &h, buf, *len);
+	if (ret < 0)
+		return ret;
+
+	if (h.type != type)
+		return -EINVAL;
+
+	*len = h.len;
+	return h.parent;
+}
+
+/**
+ * cr_read_buffer - read a buffer
+ * @ctx: checkpoint context
+ * @buf: buffer
+ * @len: buffer size (output actual record size)
+ */
+int cr_read_buffer(struct cr_ctx *ctx, void *buf, int *len)
+{
+	return cr_read_buf_type(ctx, buf, len, CR_HDR_BUFFER);
+}
+
+/**
+ * cr_read_string - read a string
+ * @ctx: checkpoint context
+ * @str: string buffer
+ * @len: string length
+ */
+int cr_read_string(struct cr_ctx *ctx, char *str, int len)
+{
+	int ret;
+
+	ret = cr_read_buf_type(ctx, str, &len, CR_HDR_STRING);
+	if (ret < 0)
+		return ret;
+
+	if (len > 0)
+		str[len - 1] = '\0';	/* always play it safe */
+
+	return ret;
+}
+
+/* read the checkpoint header */
+static int cr_read_head(struct cr_ctx *ctx)
+{
+	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret = -EINVAL;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	} else if (parent != 0)
+		goto out;
+
+	if (hh->magic != CHECKPOINT_MAGIC_HEAD || hh->rev != CR_VERSION ||
+	    hh->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
+	    hh->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
+	    hh->patch != ((LINUX_VERSION_CODE) & 0xff))
+		goto out;
+
+	if (hh->flags & ~CR_CTX_CKPT)
+		goto out;
+
+	ctx->oflags = hh->flags;
+
+	/* FIX: verify compatibility of release, version and machine */
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* read the checkpoint trailer */
+static int cr_read_tail(struct cr_ctx *ctx)
+{
+	struct cr_hdr_tail *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret = -EINVAL;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TAIL);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	} else if (parent != 0)
+		goto out;
+
+	if (hh->magic != CHECKPOINT_MAGIC_TAIL)
+		goto out;
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* read the task_struct into the current task */
+static int cr_read_task_struct(struct cr_ctx *ctx)
+{
+	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	char *buf;
+	int parent, ret = -EINVAL;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TASK);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	} else if (parent != 0)
+		goto out;
+
+	/* upper limit for task_comm_len to prevent DoS */
+	if (hh->task_comm_len < 0 || hh->task_comm_len > PAGE_SIZE)
+		goto out;
+
+	buf = kmalloc(hh->task_comm_len, GFP_KERNEL);
+	if (!buf)
+		goto out;
+	ret = cr_read_string(ctx, buf, hh->task_comm_len);
+	if (!ret) {
+		/* if t->comm is too long, silently truncate */
+		memset(t->comm, 0, TASK_COMM_LEN);
+		memcpy(t->comm, buf, min(hh->task_comm_len, TASK_COMM_LEN));
+	}
+	kfree(buf);
+
+	/* FIXME: restore remaining relevant task_struct fields */
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* read the entire state of the current task */
+static int cr_read_task(struct cr_ctx *ctx)
+{
+	int ret;
+
+	ret = cr_read_task_struct(ctx);
+	pr_debug("ret %d\n", ret);
+
+	return ret;
+}
+
+int do_restart(struct cr_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = cr_read_head(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_task(ctx);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	/* on success, adjust the return value if needed [TODO] */
+ out:
+	return ret;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 375129c..76e2553 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -10,6 +10,180 @@
 
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/uaccess.h>
+#include <linux/capability.h>
+#include <linux/checkpoint.h>
+
+/*
+ * Helpers to write(read) from(to) kernel space to(from) the checkpoint
+ * image file descriptor (similar to how a core-dump is performed).
+ *
+ *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   cr_kread() - read from the checkpoint image to a kernel-space buffer
+ */
+
+static inline int _cr_kwrite(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nwrite;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		loff_t pos = file_pos_read(file);
+		nwrite = vfs_write(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nwrite < 0) {
+			if (nwrite == -EAGAIN)
+				nwrite = 0;
+			else
+				return nwrite;
+		}
+		uaddr += nwrite;
+	}
+	return 0;
+}
+
+int cr_kwrite(struct cr_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _cr_kwrite(ctx->file, addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+static inline int _cr_kread(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nread;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		loff_t pos = file_pos_read(file);
+		nread = vfs_read(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nread <= 0) {
+			if (nread == -EAGAIN) {
+				nread = 0;
+				continue;
+			} else if (nread == 0)
+				nread = -EPIPE;		/* unexecpted EOF */
+			return nread;
+		}
+		uaddr += nread;
+	}
+	return 0;
+}
+
+int cr_kread(struct cr_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _cr_kread(ctx->file , addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+/*
+ * During checkpoint and restart the code writes outs/reads in data
+ * to/from the checkpoint image from/to a temporary buffer (ctx->hbuf).
+ * Because operations can be nested, use cr_hbuf_get() to reserve space
+ * in the buffer, then cr_hbuf_put() when you no longer need that space.
+ */
+
+/*
+ * ctx->hbuf is used to hold headers and data of known (or bound),
+ * static sizes. In some cases, multiple headers may be allocated in
+ * a nested manner. The size should accommodate all headers, nested
+ * or not, on all archs.
+ */
+#define CR_HBUF_TOTAL  (8 * 4096)
+
+/**
+ * cr_hbuf_get - reserve space on the hbuf
+ * @ctx: checkpoint context
+ * @n: number of bytes to reserve
+ *
+ * Returns pointer to reserved space
+ */
+void *cr_hbuf_get(struct cr_ctx *ctx, int n)
+{
+	void *ptr;
+
+	/*
+	 * Since requests depend on logic and static header sizes (not on
+	 * user data), space should always suffice, unless someone either
+	 * made a structure bigger or call path deeper than expected.
+	 */
+	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
+	ptr = ctx->hbuf + ctx->hpos;
+	ctx->hpos += n;
+	return ptr;
+}
+
+/**
+ * cr_hbuf_put - unreserve space on the hbuf
+ * @ctx: checkpoint context
+ * @n: number of bytes to reserve
+ */
+void cr_hbuf_put(struct cr_ctx *ctx, int n)
+{
+	BUG_ON(ctx->hpos < n);
+	ctx->hpos -= n;
+}
+
+/*
+ * helpers to manage C/R contexts: allocated for each checkpoint and/or
+ * restart operation, and persists until the operation is completed.
+ */
+
+static void cr_ctx_free(struct cr_ctx *ctx)
+{
+	if (ctx->file)
+		fput(ctx->file);
+	kfree(ctx->hbuf);
+	kfree(ctx);
+}
+
+static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
+{
+	struct cr_ctx *ctx;
+	int err;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return ERR_PTR(-ENOMEM);
+
+	ctx->flags = flags;
+
+	err = -EBADF;
+	ctx->file = fget(fd);
+	if (!ctx->file)
+		goto err;
+
+	err = -ENOMEM;
+	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
+	if (!ctx->hbuf)
+		goto err;
+
+	return ctx;
+
+ err:
+	cr_ctx_free(ctx);
+	return ERR_PTR(err);
+}
 
 /**
  * sys_checkpoint - checkpoint a container
@@ -22,9 +196,26 @@
  */
 asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 {
-	pr_debug("sys_checkpoint not implemented yet\n");
-	return -ENOSYS;
+	struct cr_ctx *ctx;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(fd, flags | CR_CTX_CKPT);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_checkpoint(ctx, pid);
+
+	if (!ret)
+		ret = ctx->crid;
+
+	cr_ctx_free(ctx);
+	return ret;
 }
+
 /**
  * sys_restart - restart a container
  * @crid: checkpoint image identifier
@@ -36,6 +227,23 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
  */
 asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 {
-	pr_debug("sys_restart not implemented yet\n");
-	return -ENOSYS;
+	struct cr_ctx *ctx;
+	pid_t pid;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = cr_ctx_alloc(fd, flags | CR_CTX_RSTR);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	/* FIXME: for now, we use 'crid' as a pid */
+	pid = (pid_t) crid;
+
+	ret = do_restart(ctx, pid);
+
+	cr_ctx_free(ctx);
+	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..65a2cbf
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,61 @@
+#ifndef _CHECKPOINT_CKPT_H_
+#define _CHECKPOINT_CKPT_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define CR_VERSION  1
+
+struct cr_ctx {
+	int crid;		/* unique checkpoint id */
+
+	pid_t root_pid;		/* container identifier */
+
+	unsigned long flags;
+	unsigned long oflags;	/* restart: old flags */
+
+	struct file *file;
+	int total;		/* total read/written */
+
+	void *hbuf;		/* temporary buffer for headers */
+	int hpos;		/* position in headers buffer */
+};
+
+/* cr_ctx: flags */
+#define CR_CTX_CKPT	0x1
+#define CR_CTX_RSTR	0x2
+
+extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
+extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
+
+extern void *cr_hbuf_get(struct cr_ctx *ctx, int n);
+extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
+
+struct cr_hdr;
+
+extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
+extern int cr_write_buffer(struct cr_ctx *ctx, void *buf, int len);
+extern int cr_write_string(struct cr_ctx *ctx, char *str, int len);
+
+extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
+extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int len, int type);
+extern int cr_read_buf_type(struct cr_ctx *ctx, void *buf, int *len, int type);
+extern int cr_read_buffer(struct cr_ctx *ctx, void *buf, int *len);
+extern int cr_read_string(struct cr_ctx *ctx, char *str, int len);
+
+extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
+extern int do_restart(struct cr_ctx *ctx, pid_t pid);
+
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
+
+#endif /* _CHECKPOINT_CKPT_H_ */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
new file mode 100644
index 0000000..fcc0125
--- /dev/null
+++ b/include/linux/checkpoint_hdr.h
@@ -0,0 +1,85 @@
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#define _CHECKPOINT_CKPT_HDR_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+#include <linux/utsname.h>
+
+/*
+ * To maintain compatibility between 32-bit and 64-bit architecture flavors,
+ * keep data 64-bit aligned: use padding for structure members, and use
+ * __attribute__ ((aligned (8))) for the entire structure.
+ *
+ * Quoting Arnd Bergmann:
+ *   "This structure has an odd multiple of 32-bit members, which means
+ *   that if you put it into a larger structure that also contains 64-bit
+ *   members, the larger structure may get different alignment on x86-32
+ *   and x86-64, which you might want to avoid. I can't tell if this is
+ *   an actual problem here. ... In this case, I'm pretty sure that
+ *   sizeof(cr_hdr_task) on x86-32 is different from x86-64, since it
+ *   will be 32-bit aligned on x86-32."
+ */
+
+/* records: generic header */
+
+struct cr_hdr {
+	__s16 type;
+	__s16 len;
+	__u32 parent;
+};
+
+/* header types */
+enum {
+	CR_HDR_HEAD = 1,
+	CR_HDR_BUFFER,
+	CR_HDR_STRING,
+
+	CR_HDR_TASK = 101,
+	CR_HDR_THREAD,
+	CR_HDR_CPU,
+
+	CR_HDR_MM = 201,
+	CR_HDR_VMA,
+	CR_HDR_MM_CONTEXT,
+
+	CR_HDR_TAIL = 5001
+};
+
+struct cr_hdr_head {
+	__u64 magic;
+
+	__u16 major;
+	__u16 minor;
+	__u16 patch;
+	__u16 rev;
+
+	__u64 time;	/* when checkpoint taken */
+	__u64 flags;	/* checkpoint options */
+
+	char release[__NEW_UTS_LEN];
+	char version[__NEW_UTS_LEN];
+	char machine[__NEW_UTS_LEN];
+} __attribute__((aligned(8)));
+
+struct cr_hdr_tail {
+	__u64 magic;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_task {
+	__u32 state;
+	__u32 exit_state;
+	__u32 exit_code;
+	__u32 exit_signal;
+
+	__s32 task_comm_len;
+} __attribute__((aligned(8)));
+
+#endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index f7f3fdd..5939bbe 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -46,4 +46,7 @@
 #define FUTEXFS_SUPER_MAGIC	0xBAD1DEA
 #define INOTIFYFS_SUPER_MAGIC	0x2BAD1DEA
 
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
