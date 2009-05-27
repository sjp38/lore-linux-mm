Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B64F46B0089
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:10 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 05/43] c/r: basic infrastructure for checkpoint/restart
Date: Wed, 27 May 2009 13:32:31 -0400
Message-Id: <1243445589-32388-6-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add those interfaces, as well as helpers needed to easily manage the
file format. The code is roughly broken out as follows:

checkpoint/sys.c - user/kernel data transfer, as well as setup of the
  c/r context (a per-checkpoint data structure for housekeeping)

checkpoint/checkpoint.c - output wrappers and basic checkpoint handling

checkpoint/restart.c - input wrappers and basic restart handling

checkpoint/process.c - c/r of task data

For now, we can only checkpoint the 'current' task ("self" checkpoint),
and the 'pid' argument to the syscall is ignored.

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Changelog[v16]:
  - Split ctx->flags to ->uflags (user flags) and ->kflags (kernel flags)
  - Introduce __ckpt_write_err() and ckpt_write_err() to report errors
  - Allow @ptr == NULL to write (or read) header only without payload
  _ Introduce _ckpt_read_obj_type()

Changelog[v15]:
  - Replace header buffer in ckpt_ctx (hbuf,hpos) with kmalloc/kfree()

Changelog[v14]:
  - Cleanup interface to get/put hdr buffers
  - Merge checkpoint and restart code into a single file (per subsystem)
  - Take uts_sem around access to uts->{release,version,machine}
  - Embed ckpt_hdr in all ckpt_hdr_...., cleanup read/write helpers
  - Define sys_checkpoint(0,...) as asking for a self-checkpoint (Serge)
  - Revert use of 'pr_fmt' to avoid tainting whom includes us (Nathan Lynch)
  - Explicitly indicate length of UTS fields in header
  - Discard field 'h->parent' from ckpt_hdr

Changelog[v12]:
  - ckpt_kwrite/ckpt_kread() again use vfs_read(), vfs_write() (safer)
  - Split ckpt_write/ckpt_read() to two parts: _ckpt_write/read() helper
  - Befriend with sparse : explicit conversion to 'void __user *'
  - Redfine 'pr_fmt' instead of using special ckpt_debug()

Changelog[v10]:
  - add ckpt_write_buffer(), ckpt_read_buffer() and ckpt_read_buf_type()
  - force end-of-string in ckpt_read_string() (fix possible DoS)

Changelog[v9]:
  - ckpt_kwrite/ckpt_kread() use file->f_op->write() directly
  - Drop ckpt_uwrite/ckpt_uread() since they aren't used anywhere

Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (although it's not really needed)

Changelog[v5]:
  - Rename headers files s/ckpt/checkpoint/

Changelog[v2]:
  - Added utsname->{release,version,machine} to checkpoint header
  - Pad header structures to 64 bits to ensure compatibility

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 Makefile                         |    2 +-
 checkpoint/Makefile              |    6 +-
 checkpoint/checkpoint.c          |  261 +++++++++++++++++++++++++++++++
 checkpoint/process.c             |   97 ++++++++++++
 checkpoint/restart.c             |  316 ++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c                 |  242 +++++++++++++++++++++++++++++-
 include/linux/checkpoint.h       |   84 ++++++++++
 include/linux/checkpoint_hdr.h   |  100 ++++++++++++
 include/linux/checkpoint_types.h |   43 +++++
 include/linux/magic.h            |    4 +
 lib/Kconfig.debug                |   13 ++
 11 files changed, 1164 insertions(+), 4 deletions(-)

diff --git a/Makefile b/Makefile
index 739fd34..7ad0ca8 100644
--- a/Makefile
+++ b/Makefile
@@ -646,7 +646,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 8a32c6f..99364cc 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,8 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT) += sys.o
+obj-$(CONFIG_CHECKPOINT) += \
+	sys.o \
+	checkpoint.o \
+	restart.o \
+	process.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
new file mode 100644
index 0000000..56b690a
--- /dev/null
+++ b/checkpoint/checkpoint.c
@@ -0,0 +1,261 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/version.h>
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
+static atomic_t ctx_count = ATOMIC_INIT(0);
+
+/**
+ * ckpt_write_obj - write an object
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ */
+int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	return ckpt_kwrite(ctx, h, h->len);
+}
+
+/**
+ * ckpt_write_obj_type - write an object (from a pointer)
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ * @type: desired type
+ *
+ * If @ptr is NULL, then write only the header (payload to follow)
+ */
+int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get(ctx, sizeof(*h));
+	if (!h)
+		return -ENOMEM;
+
+	h->type = type;
+	h->len = len + sizeof(*h);
+
+	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	ret = ckpt_kwrite(ctx, h, sizeof(*h));
+	if (ret < 0)
+		goto out;
+	if (ptr)
+		ret = ckpt_kwrite(ctx, ptr, len);
+ out:
+	_ckpt_hdr_put(ctx, h, sizeof(*h));
+	return ret;
+}
+
+/**
+ * ckpt_write_buffer - write an object of type buffer
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ */
+int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	return ckpt_write_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * ckpt_write_string - write an object of type string
+ * @ctx: checkpoint context
+ * @str: string pointer
+ * @len: string length
+ */
+int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
+{
+	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
+}
+
+static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
+{
+	va_list aq;
+	char *str;
+	int len;
+
+	va_copy(aq, ap);
+
+	/*
+	 * prefix the error string with a '\0' to facilitate easy
+	 * backtrace to the beginning of the error message without
+	 * needing to parse the entire checkpoint image.
+	 */
+	ctx->err_string[0] = '\0';
+	str = &ctx->err_string[1];
+	len = vsnprintf(str, 255, fmt, ap) + 2;
+
+	if (len > 256) {
+		printk(KERN_NOTICE "c/r: error string truncated: ");
+		vprintk(fmt, aq);
+	}
+
+	va_end(aq);
+
+	ckpt_debug("c/r: checkpoint error: %s\n", str);
+}
+
+/**
+ * __ckpt_write_err - save an error string on the ctx->err_string
+ * @ctx: checkpoint context
+ * @fmt: error string format
+ * @...: error string arguments
+ *
+ * Use this during checkpoint to report while holding a spinlock
+ */
+void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	__ckpt_generate_err(ctx, fmt, ap);
+	va_end(ap);
+}
+
+/**
+ * ckpt_write_err - write an object describing an error
+ * @ctx: checkpoint context
+ * @fmt: error string format
+ * @...: error string arguments
+ *
+ * If @fmt is null, the string in the ctx->err_string will be used (and freed)
+ */
+int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+	char *str;
+	int len, ret = 0;
+
+	if (fmt) {
+		va_start(ap, fmt);
+		__ckpt_generate_err(ctx, fmt, ap);
+		va_end(ap);
+	}
+
+	str = ctx->err_string;
+	len = strlen(str + 1) + 2;	/* leading and trailing '\0' */
+
+	if (len == 0)	/* empty error string */
+		return 0;
+
+	ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
+	if (!ret)
+		ret = ckpt_write_string(ctx, str, len);
+	if (ret < 0)
+		printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
+		       ret, str + 1);
+
+	str[1] = '\0';
+	return ret;
+}
+
+/***********************************************************************
+ * Checkpoint
+ */
+
+/* write the checkpoint header */
+static int checkpoint_write_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts;
+	struct timeval ktv;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (!h)
+		return -ENOMEM;
+
+	do_gettimeofday(&ktv);
+	uts = utsname();
+
+	h->magic = CHECKPOINT_MAGIC_HEAD;
+	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	h->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	h->rev = CHECKPOINT_VERSION;
+
+	h->uflags = ctx->uflags;
+	h->time = ktv.tv_sec;
+
+	h->uts_release_len = sizeof(uts->release);
+	h->uts_version_len = sizeof(uts->version);
+	h->uts_machine_len = sizeof(uts->machine);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	down_read(&uts_sem);
+	ret = ckpt_write_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
+ up:
+	up_read(&uts_sem);
+	return ret;
+}
+
+/* write the checkpoint trailer */
+static int checkpoint_write_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (!h)
+		return -ENOMEM;
+
+	h->magic = CHECKPOINT_MAGIC_TAIL;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = checkpoint_write_header(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task(ctx, current);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_write_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	/* on success, return (unique) checkpoint identifier */
+	ctx->crid = atomic_inc_return(&ctx_count);
+	ret = ctx->crid;
+ out:
+	return ret;
+}
diff --git a/checkpoint/process.c b/checkpoint/process.c
new file mode 100644
index 0000000..c2b7564
--- /dev/null
+++ b/checkpoint/process.c
@@ -0,0 +1,97 @@
+/*
+ *  Checkpoint task structure
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/sched.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/***********************************************************************
+ * Checkpoint
+ */
+
+/* dump the task_struct of a given task */
+static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	h->state = t->state;
+	h->exit_state = t->exit_state;
+	h->exit_code = t->exit_code;
+	h->exit_signal = t->exit_signal;
+
+	h->task_comm_len = TASK_COMM_LEN;
+
+	/* FIXME: save remaining relevant task_struct fields */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
+}
+
+/* dump the entire state of a given task */
+int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+
+	ret = checkpoint_task_struct(ctx, t);
+	ckpt_debug("task %d\n", ret);
+
+	return ret;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+/* read the task_struct into the current task */
+static int restore_task_struct(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->task_comm_len > TASK_COMM_LEN)
+		goto out;
+
+	memset(t->comm, 0, TASK_COMM_LEN);
+	ret = _ckpt_read_string(ctx, t->comm, h->task_comm_len);
+
+	/* FIXME: restore remaining relevant task_struct fields */
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* read the entire state of the current task */
+int restore_task(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	ret = restore_task_struct(ctx);
+	ckpt_debug("task %d\n", ret);
+
+	return ret;
+}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
new file mode 100644
index 0000000..a6f73d3
--- /dev/null
+++ b/checkpoint/restart.c
@@ -0,0 +1,316 @@
+/*
+ *  Restart logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/utsname.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/**
+ * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ * @ptr: desired buffer
+ * @len: desired payload length (if 0, flexible)
+ * @max: maximum payload length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			void *ptr, int len, int max)
+{
+	int ret;
+
+	ret = ckpt_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+		    h->type, h->len, len, max);
+	if (h->len < sizeof(*h))
+		return -EINVAL;
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && h->len != len) || (!len && max && h->len > max))
+		return -EINVAL;
+
+	if (ptr)
+		ret = ckpt_kread(ctx, ptr, h->len - sizeof(struct ckpt_hdr));
+	return ret;
+}
+
+/**
+ * _ckpt_read_nbuffer - read an object of type buffer (variable length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ * Returns: actual buffer length (bounded by @len)
+ */
+int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	BUG_ON(!len);
+
+	len += sizeof(struct ckpt_hdr);
+	ret = _ckpt_read_obj(ctx, &h, ptr, 0, len);
+	if (ret < 0)
+		return ret;
+	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h.type, h.len);
+	if (h.type != CKPT_HDR_BUFFER)
+		return -EINVAL;
+	return h.len;
+}
+
+/**
+ * _ckpt_read_obj_type - read an object of some type (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ * @type: buffer type
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	len += sizeof(struct ckpt_hdr);
+	ret = _ckpt_read_obj(ctx, &h, ptr, len, len);
+	if (ret < 0)
+		return ret;
+	if (h.type != type)
+		return -EINVAL;
+	return 0;
+}
+
+/**
+ * _ckpt_read_buffer - read an object of type buffer (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	BUG_ON(!len);
+	return _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * _ckpt_read_string - read an object of type string (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: string length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	int ret;
+
+	BUG_ON(!len);
+
+	ret = _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_STRING);
+	if (ret < 0)
+		return ret;
+	if (ptr)
+		((char *) ptr)[len - 1] = '\0';	/* always play it safe */
+	return 0;
+}
+
+/**
+ * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ * @len: desired payload length (if 0, flexible)
+ * @max: maximum payload length
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
+{
+	struct ckpt_hdr hh;
+	struct ckpt_hdr *h;
+	int ret;
+
+	ret = ckpt_kread(ctx, &hh, sizeof(hh));
+	if (ret < 0)
+		return ERR_PTR(ret);
+	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+		    hh.type, hh.len, len, max);
+	if (hh.len < sizeof(*h))
+		return ERR_PTR(-EINVAL);
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && hh.len != len) || (!len && max && hh.len > max))
+		return ERR_PTR(-EINVAL);
+
+	h = ckpt_hdr_get(ctx, hh.len);
+	if (!h)
+		return ERR_PTR(-ENOMEM);
+
+	*h = hh;	/* yay ! */
+
+	ret = ckpt_kread(ctx, (h + 1), hh.len - sizeof(struct ckpt_hdr));
+	if (ret < 0) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(ret);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_obj_type - allocate and read an object of some type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	BUG_ON(!len);
+
+	h = ckpt_read_obj(ctx, len, len);
+	if (IS_ERR(h))
+		return h;
+
+	if (h->type != type) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_buf_type - allocate and read an object of some type (flxible)
+ * @ctx: checkpoint context
+ * @len: maximum object length
+ * @type: desired object type
+ *
+ * This differs from ckpt_read_obj_type() in that the length of the
+ * incoming object is flexible (up to the maximum specified by @len),
+ * as determined by the ckpt_hdr data.
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	BUG_ON(!len);
+
+	h = ckpt_read_obj(ctx, 0, len);
+	if (IS_ERR(h))
+		return h;
+
+	if (h->type != type) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+/* read the checkpoint header */
+static int restore_read_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts = NULL;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
+	    h->rev != CHECKPOINT_VERSION ||
+	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
+	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
+	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
+		goto out;
+	if (h->uflags)
+		goto out;
+	if (h->uts_release_len != sizeof(uts->release) ||
+	    h->uts_version_len != sizeof(uts->version) ||
+	    h->uts_machine_len != sizeof(uts->machine))
+		goto out;
+
+	ret = -ENOMEM;
+	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
+	if (!uts)
+		goto out;
+
+	ctx->oflags = h->uflags;
+
+	/* FIX: verify compatibility of release, version and machine */
+	ret = _ckpt_read_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
+ out:
+	kfree(uts);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* read the checkpoint trailer */
+static int restore_read_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->magic != CHECKPOINT_MAGIC_TAIL)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int do_restart(struct ckpt_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = restore_read_header(ctx);
+	if (ret < 0)
+		return ret;
+	ret = restore_task(ctx);
+	if (ret < 0)
+		return ret;
+	ret = restore_read_tail(ctx);
+
+	/* on success, adjust the return value if needed [TODO] */
+	return ret;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 881965b..2ad9722 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -8,9 +8,192 @@
  *  distribution for more details.
  */
 
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
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
+ *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
+ */
+
+static inline int _ckpt_kwrite(struct file *file, void *addr, int count)
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
+int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kwrite(ctx->file, addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+static inline int _ckpt_kread(struct file *file, void *addr, int count)
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
+int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kread(ctx->file , addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+/**
+ * ckpt_hdr_get - get a hdr of certain size
+ * @ctx: checkpoint context
+ * @len: desired length
+ *
+ * Returns pointer to header
+ */
+void *ckpt_hdr_get(struct ckpt_ctx *ctx, int len)
+{
+	return kzalloc(len, GFP_KERNEL);
+}
+
+/**
+ * _ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
+ * @ctx: checkpoint context
+ * @ptr: header to free
+ * @len: header length
+ *
+ * (requiring 'ptr' makes it easily interchangable with kmalloc/kfree
+ */
+void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	kfree(ptr);
+}
+
+/**
+ * ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
+ * @ctx: checkpoint context
+ * @ptr: header to free
+ *
+ * It is assumed that @ptr begins with a 'struct ckpt_hdr'.
+ */
+void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr *h = (struct ckpt_hdr *) ptr;
+	_ckpt_hdr_put(ctx, ptr, h->len);
+}
+
+/**
+ * ckpt_hdr_get_type - get a hdr of certain size
+ * @ctx: checkpoint context
+ * @len: number of bytes to reserve
+ *
+ * Returns pointer to reserved space on hbuf
+ */
+void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	h = ckpt_hdr_get(ctx, len);
+	if (!h)
+		return NULL;
+
+	h->type = type;
+	h->len = len;
+	return h;
+}
+
+
+/*
+ * Helpers to manage c/r contexts: allocated for each checkpoint and/or
+ * restart operation, and persists until the operation is completed.
+ */
+
+static void ckpt_ctx_free(struct ckpt_ctx *ctx)
+{
+	if (ctx->file)
+		fput(ctx->file);
+	kfree(ctx);
+}
+
+static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
+				       unsigned long kflags)
+{
+	struct ckpt_ctx *ctx;
+	int err;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return ERR_PTR(-ENOMEM);
+
+	ctx->uflags = uflags;
+	ctx->kflags = kflags;
+
+	err = -EBADF;
+	ctx->file = fget(fd);
+	if (!ctx->file)
+		goto err;
+
+	return ctx;
+ err:
+	ckpt_ctx_free(ctx);
+	return ERR_PTR(err);
+}
 
 /**
  * sys_checkpoint - checkpoint a container
@@ -23,7 +206,26 @@
  */
 SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 {
-	return -ENOSYS;
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	if (pid == 0)
+		pid = task_pid_vnr(current);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_checkpoint(ctx, pid);
+
+	if (!ret)
+		ret = ctx->crid;
+
+	ckpt_ctx_free(ctx);
+	return ret;
 }
 
 /**
@@ -37,5 +239,41 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  */
 SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 {
-	return -ENOSYS;
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_restart(ctx, pid);
+
+	ckpt_ctx_free(ctx);
+	return ret;
+}
+
+
+/* 'ckpt_debug_level' controls the verbosity level of c/r code */
+#ifdef CONFIG_CHECKPOINT_DEBUG
+
+/* FIX: allow to change during runtime */
+unsigned long __read_mostly ckpt_debug_level = CKPT_DDEFAULT;
+
+static __init int ckpt_debug_setup(char *s)
+{
+	long val, ret;
+
+	ret = strict_strtoul(s, 10, &val);
+	if (ret < 0)
+		return ret;
+	ckpt_debug_level = val;
+	return 0;
 }
+
+__setup("ckpt_debug=", ckpt_debug_setup);
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..14da928
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,84 @@
+#ifndef _LINUX_CHECKPOINT_H_
+#define _LINUX_CHECKPOINT_H_
+/*
+ *  Generic checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+
+extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
+extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
+
+extern void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int n);
+extern void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr);
+extern void *ckpt_hdr_get(struct ckpt_ctx *ctx, int n);
+extern void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int n, int type);
+
+extern int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
+extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, int len, int type);
+extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
+extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
+extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
+
+extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, int len, int type);
+extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
+extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
+
+extern int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
+extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
+
+/* task */
+extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task(struct ckpt_ctx *ctx);
+
+
+/* debugging flags */
+#define CKPT_DBASE	0x1		/* anything */
+#define CKPT_DSYS	0x2		/* generic (system) */
+#define CKPT_DRW	0x4		/* image read/write */
+
+#define CKPT_DDEFAULT	0x7		/* default debug level */
+
+#ifndef CKPT_DFLAG
+#define CKPT_DFLAG	0x0		/* nothing */
+#endif
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+extern unsigned long ckpt_debug_level;
+
+/* use this to select a specific debug level */
+#define _ckpt_debug(level, fmt, args...)			\
+	do {						\
+		if (ckpt_debug_level & (level))		\
+			pr_debug("[%d:c/r:%s] " fmt,	\
+				task_pid_vnr(current),	\
+				 __func__, ## args);	\
+	} while (0)
+
+/*
+ * CKPT_DBASE is the base flags, doesn't change
+ * CKPT_DFLAG is to be redfined in each source file
+ */
+#define ckpt_debug(fmt, args...)  \
+	_ckpt_debug(CKPT_DBASE | CKPT_DFLAG, fmt, ## args)
+
+#else
+
+#define _ckpt_debug(level, fmt, args...)	do { } while (0)
+#define ckpt_debug(fmt, args...)		do { } while (0)
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
+
+#endif /* _LINUX_CHECKPOINT_H_ */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
new file mode 100644
index 0000000..c9a1653
--- /dev/null
+++ b/include/linux/checkpoint_hdr.h
@@ -0,0 +1,100 @@
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#define _CHECKPOINT_CKPT_HDR_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
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
+ * __attribute__((aligned (8))) for the entire structure.
+ *
+ * Quoting Arnd Bergmann:
+ *   "This structure has an odd multiple of 32-bit members, which means
+ *   that if you put it into a larger structure that also contains 64-bit
+ *   members, the larger structure may get different alignment on x86-32
+ *   and x86-64, which you might want to avoid. I can't tell if this is
+ *   an actual problem here. ... In this case, I'm pretty sure that
+ *   sizeof(ckpt_hdr_task) on x86-32 is different from x86-64, since it
+ *   will be 32-bit aligned on x86-32."
+ */
+
+/*
+ * header format: 'struct ckpt_hdr' must prefix all other headers. Therfore
+ * when a header is passed around, the information about it (type, size)
+ * is readily available.
+ */
+struct ckpt_hdr {
+	__u32 type;
+	__u32 len;
+} __attribute__((aligned(8)));
+
+/* header types */
+enum {
+	CKPT_HDR_HEADER = 1,
+	CKPT_HDR_BUFFER,
+	CKPT_HDR_STRING,
+
+	CKPT_HDR_TASK = 101,
+
+	CKPT_HDR_TAIL = 9001,
+
+	CKPT_HDR_ERROR = 9999,
+};
+
+/* checkpoint image header */
+struct ckpt_hdr_header {
+	struct ckpt_hdr h;
+	__u64 magic;
+
+	__u16 _padding;
+
+	__u16 major;
+	__u16 minor;
+	__u16 patch;
+	__u16 rev;
+
+	__u16 uts_release_len;
+	__u16 uts_version_len;
+	__u16 uts_machine_len;
+
+	__u64 time;	/* when checkpoint taken */
+	__u64 uflags;	/* uflags from checkpoint */
+
+	/*
+	 * the header is followed by three strings:
+	 *   char release[__NEW_UTS_LEN];
+	 *   char version[__NEW_UTS_LEN];
+	 *   char machine[__NEW_UTS_LEN];
+	 */
+} __attribute__((aligned(8)));
+
+
+/* checkpoint image trailer */
+struct ckpt_hdr_tail {
+	struct ckpt_hdr h;
+	__u64 magic;
+} __attribute__((aligned(8)));
+
+
+/* task data */
+struct ckpt_hdr_task {
+	struct ckpt_hdr h;
+	__u32 state;
+	__u32 exit_state;
+	__u32 exit_code;
+	__u32 exit_signal;
+
+	__u32 task_comm_len;
+} __attribute__((aligned(8)));
+
+#endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
new file mode 100644
index 0000000..2b8d59f
--- /dev/null
+++ b/include/linux/checkpoint_types.h
@@ -0,0 +1,43 @@
+#ifndef _LINUX_CHECKPOINT_TYPES_H_
+#define _LINUX_CHECKPOINT_TYPES_H_
+/*
+ *  Generic checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define CHECKPOINT_VERSION  1
+
+
+#ifdef __KERNEL__
+
+struct ckpt_ctx {
+	int crid;		/* unique checkpoint id */
+
+	pid_t root_pid;		/* container identifier */
+
+	unsigned long kflags;	/* kerenl flags */
+	unsigned long uflags;	/* user flags */
+	unsigned long oflags;	/* restart: uflags from checkpoint */
+
+	struct file *file;	/* input/output file */
+	int total;		/* total read/written */
+
+	char err_string[256];	/* checkpoint: error string */
+};
+
+/* ckpt_ctx: kflags */
+#define CKPT_CTX_CHECKPOINT_BIT		1
+#define CKPT_CTX_RESTART_BIT		2
+
+#define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
+#define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
+
+#endif /* __KERNEL__ */
+
+
+#endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index 5b4e28b..73a9d02 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -50,4 +50,8 @@
 #define INOTIFYFS_SUPER_MAGIC	0x2BAD1DEA
 
 #define STACK_END_MAGIC		0x57AC6E9D
+
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 6cdcf38..ab795a6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -961,6 +961,19 @@ config DMA_API_DEBUG
 	  This option causes a performance degredation.  Use only if you want
 	  to debug device drivers. If unsure, say N.
 
+config CHECKPOINT_DEBUG
+	bool "Checkpoint/restart debugging (EXPERIMENTAL)"
+	depends on CHECKPOINT
+	default y
+	help
+	  This options turns on the debugging output of checkpoint/restart.
+	  The level of verbosity is controlled by 'ckpt_debug_level' and can
+	  be set at boot time with "ckpt_debug=" option.
+
+	  Turning this option off will reduce the size of the c/r code. If
+	  turned on, it is unlikely to incur visible overhead if the debug
+	  level is set to zero.
+
 source "samples/Kconfig"
 
 source "lib/Kconfig.kgdb"
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
