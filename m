Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A20C56B00A6
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:38 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 20/80] c/r: basic infrastructure for checkpoint/restart
Date: Wed, 23 Sep 2009 19:51:00 -0400
Message-Id: <1253749920-18673-21-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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


Changelog[v18]:
  - Detect error-headers in input data on restart, and abort.
  - Standard format for checkpoint error strings (and documentation)
  - [Matt Helsley] Rename headerless struct ckpt_hdr_* to struct ckpt_*
  - [Dan Smith] Add an errno validation function
  - Add ckpt_read_payload(): read a variable-length object (no header)
  - Add ckpt_read_string(): same for strings (ensures null-terminated)
  - Add ckpt_read_consume(): consumes next object without processing
Changelog[v17]:
  - Fix compilation for architectures that don't support checkpoint
  - Save/restore t->{set,clear}_child_tid
  - Restart(2) isn't idempotent: must return -EINTR if interrupted
  - ckpt_debug does not depend on DYNAMIC_DEBUG, on by default
  - Export generic checkpoint headers to userespace
  - Fix comment for prototype of sys_restart
  - Have ckpt_debug() print global-pid and __LINE__
  - Only save and test kernel constants once (in header)
Changelog[v16]:
  - Split ctx->flags to ->uflags (user flags) and ->kflags (kernel flags)
  - Introduce __ckpt_write_err() and ckpt_write_err() to report errors
  - Allow @ptr == NULL to write (or read) header only without payload
  - Introduce _ckpt_read_obj_type()
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
 checkpoint/checkpoint.c          |  369 +++++++++++++++++++++++++++++++++
 checkpoint/process.c             |  102 +++++++++
 checkpoint/restart.c             |  422 ++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c                 |  247 ++++++++++++++++++++++-
 include/linux/Kbuild             |    3 +
 include/linux/checkpoint.h       |  109 ++++++++++
 include/linux/checkpoint_hdr.h   |  111 ++++++++++
 include/linux/checkpoint_types.h |   35 +++
 include/linux/magic.h            |    4 +
 lib/Kconfig.debug                |   13 ++
 12 files changed, 1419 insertions(+), 4 deletions(-)
 create mode 100644 checkpoint/checkpoint.c
 create mode 100644 checkpoint/process.c
 create mode 100644 checkpoint/restart.c
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 include/linux/checkpoint_hdr.h
 create mode 100644 include/linux/checkpoint_types.h

diff --git a/Makefile b/Makefile
index fe45658..2e44d0f 100644
--- a/Makefile
+++ b/Makefile
@@ -639,7 +639,7 @@ export mod_strip_cmd
 
 
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
index 0000000..57eb7d8
--- /dev/null
+++ b/checkpoint/checkpoint.c
@@ -0,0 +1,369 @@
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
+/*
+ * __ckpt_generate_fmt - generate standard checkpoint error message
+ * @ctx: checkpoint context
+ * @prefmt: pre-format string
+ * @fmt: message format
+ *
+ * This generates a unified format of checkpoint error messages, to
+ * ease (after the failure) inspection by userspace tools. It converts
+ * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
+ *
+ * PREFMT is constructed from @prefmt by subtituting format snippets
+ * according to the contents of @prefmt.  The format characters in
+ * @prefmt can be E (error), O (objref), P (pointer), S (string) and
+ * V (variable/symbol). For example, E will generate a "err %d" in
+ * PREFMT (see prefmt_array below).
+ *
+ * If @prefmt begins with T, PREFMT will begin with "pid %d tsk %s"
+ * with the pid and the tsk->comm of the currently checkpointed task.
+ * The latter is taken from ctx->tsk, and is it the responsbilility of
+ * the caller to have a valid pointer there (in particular, functions
+ * that iterate on the processes: collect_objects, checkpoint_task,
+ * and tree_count_tasks).
+ *
+ * The caller of ckpt_write_err() and _ckpt_write_err() must provide
+ * the additional variabes, in order, to match the @prefmt (except for
+ * the T key), e.g.:
+ *
+ *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
+ *
+ * Here, T is simply passed, E expects an integer (err), O expects an
+ * integer (objref), and the last argument matches the format string.
+ */
+static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *prefmt, char *fmt)
+{
+	static int warn_notask = 0;
+	static int warn_prefmt = 0;
+	char *format;
+	int i, j, len = 0;
+
+	static struct {
+		char key;
+		char *fmt;
+	} prefmt_array[] = {
+		{ 'E', "err %d" },
+		{ 'O', "obj %d" },
+		{ 'P', "ptr %p" },
+		{ 'V', "sym %pS" },
+		{ 'S', "str %s" },
+		{ 0, "??? %pS" },
+	};
+
+	/*
+	 * 17 for "pid %d" (plus space)
+	 * 21 for "tsk %s" (tsk->comm)
+	 * up to 8 per varfmt entry
+	 */
+	format = kzalloc(37 + 8 * strlen(prefmt) + strlen(fmt), GFP_KERNEL);
+	if (!format)
+		return NULL;
+
+	format[len++] = '[';
+
+	if (prefmt[0] == 'T') {
+		if (ctx->tsk)
+			len = sprintf(format, "pid %d tsk %s ",
+				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+		else if (warn_notask++ < 5)
+			printk(KERN_ERR "c/r: no target task set\n");
+		prefmt++;
+	}
+
+	for (i = 0; i < strlen(prefmt); i++) {
+		for (j = 0; prefmt_array[j].key; j++)
+			if (prefmt_array[j].key == prefmt[i])
+				break;
+		if (!prefmt_array[j].key && warn_prefmt++ < 5)
+			printk(KERN_ERR "c/r: unknown prefmt %c\n", prefmt[i]);
+		len += sprintf(&format[len], "%s ", prefmt_array[j].fmt);
+	}
+
+	if (len > 1)
+		sprintf(&format[len-1], "]: %s", fmt);  /* erase last space */
+	else
+		sprintf(format, "%s", fmt);
+
+	return format;
+}
+
+/* see _ckpt_generate_fmt for information on @prefmt */
+static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *prefmt,
+				char *fmt, va_list ap)
+{
+	va_list aq;
+	char *format;
+	char *str;
+	int len;
+
+	format = __ckpt_generate_fmt(ctx, prefmt, fmt);
+	va_copy(aq, ap);
+
+	/*
+	 * prefix the error string with a '\0' to facilitate easy
+	 * backtrace to the beginning of the error message without
+	 * needing to parse the entire checkpoint image.
+	 */
+	ctx->err_string[0] = '\0';
+	str = &ctx->err_string[1];
+	len = vsnprintf(str, 255, format ? : fmt, ap) + 2;
+
+	if (len > 256) {
+		printk(KERN_NOTICE "c/r: error string truncated: ");
+		vprintk(fmt, aq);
+	}
+
+	va_end(aq);
+	kfree(format);
+
+	ckpt_debug("c/r: checkpoint error: %s\n", str);
+}
+
+/**
+ * __ckpt_write_err - save an error string on the ctx->err_string
+ * @ctx: checkpoint context
+ * @prefmt: error pre-format
+ * @fmt: message format
+ * @...: arguments
+ *
+ * See _ckpt_generate_fmt for information on @prefmt.
+ * Use this during checkpoint to report while holding a spinlock
+ */
+void __ckpt_write_err(struct ckpt_ctx *ctx, char *prefmt, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	__ckpt_generate_err(ctx, prefmt, fmt, ap);
+	va_end(ap);
+}
+
+/**
+ * ckpt_write_err - write an object describing an error
+ * @ctx: checkpoint context
+ * @pre: string pre-format
+ * @fmt: error string format
+ * @...: error string arguments
+ *
+ * See _ckpt_generate_fmt for information on @prefmt.
+ * If @fmt is null, the string in the ctx->err_string will be used (and freed)
+ */
+int ckpt_write_err(struct ckpt_ctx *ctx, char *pre, char *fmt, ...)
+{
+	va_list ap;
+	char *str;
+	int len, ret = 0;
+
+	if (fmt) {
+		va_start(ap, fmt);
+		__ckpt_generate_err(ctx, pre, fmt, ap);
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
+static void fill_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	h->task_comm_len = sizeof(tsk->comm);
+	/* uts */
+	h->uts_release_len = sizeof(uts->release);
+	h->uts_version_len = sizeof(uts->version);
+	h->uts_machine_len = sizeof(uts->machine);
+}
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
+	fill_kernel_const(&h->constants);
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
+long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+{
+	long ret;
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
index 0000000..d221c2a
--- /dev/null
+++ b/checkpoint/process.c
@@ -0,0 +1,102 @@
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
+	h->set_child_tid = (unsigned long) t->set_child_tid;
+	h->clear_child_tid = (unsigned long) t->clear_child_tid;
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
+	ctx->tsk = t;
+
+	ret = checkpoint_task_struct(ctx, t);
+	ckpt_debug("task %d\n", ret);
+
+	ctx->tsk = NULL;
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
+	memset(t->comm, 0, TASK_COMM_LEN);
+	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
+	if (ret < 0)
+		goto out;
+
+	t->set_child_tid = (int __user *) (unsigned long) h->set_child_tid;
+	t->clear_child_tid = (int __user *) (unsigned long) h->clear_child_tid;
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
index 0000000..9f08f4d
--- /dev/null
+++ b/checkpoint/restart.c
@@ -0,0 +1,422 @@
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
+static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	char *ptr;
+	int len, ret;
+
+	len = h->len - sizeof(*h);
+	ptr = kzalloc(len + 1, GFP_KERNEL);
+	if (!ptr) {
+		ckpt_debug("insufficient memory to report image error\n");
+		return -ENOMEM;
+	}
+
+	ret = ckpt_kread(ctx, ptr, len);
+	if (ret >= 0) {
+		ckpt_debug("%s\n", &ptr[1]);
+		ret = -EIO;
+	}
+
+	kfree(ptr);
+	return ret;
+}
+
+/**
+ * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ * @ptr: desired buffer
+ * @len: desired payload length (if 0, flexible)
+ * @max: maximum payload length (if 0, flexible)
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			  void *ptr, int len, int max)
+{
+	int ret;
+
+ again:
+	ret = ckpt_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+		    h->type, h->len, len, max);
+	if (h->len < sizeof(*h))
+		return -EINVAL;
+
+	if (h->type == CKPT_HDR_ERROR) {
+		ret = _ckpt_read_err(ctx, h);
+		if (ret < 0)
+			return ret;
+		goto again;
+	}
+
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
+ * _ckpt_read_obj_type - read an object of some type
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ * @type: buffer type
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: actual _payload_ length
+ */
+int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	if (len)
+		len += sizeof(struct ckpt_hdr);
+	ret = _ckpt_read_obj(ctx, &h, ptr, len, len);
+	if (ret < 0)
+		return ret;
+	if (h.type != type)
+		return -EINVAL;
+	return h.len - sizeof(h);
+}
+
+/**
+ * _ckpt_read_buffer - read an object of type buffer (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: _payload_ length.
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
+ * @len: string length (including '\0')
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	int ret;
+
+	BUG_ON(!len);
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
+ * @max: maximum object length
+ * @type: desired object type
+ *
+ * This differs from ckpt_read_obj_type() in that the length of the
+ * incoming object is flexible (up to the maximum specified by @max;
+ * unlimited if @max is 0), as determined by the ckpt_hdr data.
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type)
+{
+	struct ckpt_hdr *h;
+
+	h = ckpt_read_obj(ctx, 0, max);
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
+ * ckpt_read_payload - allocate and read the payload of an object
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @str: pointer to buffer to be allocated (caller must free)
+ * @type: desired object type
+ *
+ * This can be used to read a variable-length _payload_ from the checkpoint
+ * stream. @max limits the size of the resulting buffer.
+ *
+ * Return: actual _payload_ length
+ */
+int ckpt_read_payload(struct ckpt_ctx *ctx, void **ptr, int max, int type)
+{
+	int len, ret;
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, type);
+	if (len < 0)
+		return len;
+	else if (len > max)
+		return -EINVAL;
+
+	*ptr = kmalloc(len, GFP_KERNEL);
+	if (!*ptr)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, *ptr, len);
+	if (ret < 0) {
+		kfree(*ptr);
+		return ret;
+	}
+
+	return len;
+}
+
+/**
+ * ckpt_read_string - allocate and read a string (variable length)
+ * @ctx: checkpoint context
+ * @max: maximum acceptable length
+ *
+ * Return: allocate string or error pointer
+ */
+char *ckpt_read_string(struct ckpt_ctx *ctx, int max)
+{
+	char *str;
+	int len;
+
+	len = ckpt_read_payload(ctx, (void **)&str, max, CKPT_HDR_STRING);
+	if (len < 0)
+		return ERR_PTR(len);
+	str[len - 1] = '\0';  	/* always play it safe */
+	return str;
+}
+
+/**
+ * ckpt_read_consume - consume the next object of expected type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * This can be used to skip an object in the input stream when the
+ * data is unnecessary for the restart. @len indicates the length of
+ * the object); if @len is zero the length is unconstrained.
+ */
+int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret = 0;
+
+	h = ckpt_read_obj(ctx, len, 0);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->type != type)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+static int check_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	if (h->task_comm_len != sizeof(tsk->comm))
+		return -EINVAL;
+	/* uts */
+	if (h->uts_release_len != sizeof(uts->release))
+		return -EINVAL;
+	if (h->uts_version_len != sizeof(uts->version))
+		return -EINVAL;
+	if (h->uts_machine_len != sizeof(uts->machine))
+		return -EINVAL;
+
+	return 0;
+}
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
+
+	ret = check_kernel_const(&h->constants);
+	if (ret < 0)
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
+long do_restart(struct ckpt_ctx *ctx, pid_t pid)
+{
+	long ret;
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
index 79936cc..7f6f71e 100644
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
+	long ret;
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
@@ -37,5 +239,46 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  */
 SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 {
-	return -ENOSYS;
+	struct ckpt_ctx *ctx = NULL;
+	long ret;
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
+	/* restart(2) isn't idempotent: can't restart syscall */
+	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
+	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
+		ret = -EINTR;
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
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 334a359..3e8bd18 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -44,6 +44,9 @@ header-y += bpqether.h
 header-y += bsg.h
 header-y += can.h
 header-y += cdk.h
+header-y += checkpoint.h
+header-y += checkpoint_hdr.h
+header-y += checkpoint_types.h
 header-y += chio.h
 header-y += coda_psdev.h
 header-y += coff.h
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..be0ba4b
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,109 @@
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
+#define CHECKPOINT_VERSION  2
+
+#ifdef __KERNEL__
+#ifdef CONFIG_CHECKPOINT
+
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/err.h>
+
+/* ckpt_ctx: kflags */
+#define CKPT_CTX_CHECKPOINT_BIT		0
+#define CKPT_CTX_RESTART_BIT		1
+
+#define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
+#define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
+
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
+extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *ptr, char *fmt, ...);
+extern int ckpt_write_err(struct ckpt_ctx *ctx, char *ptr, char *fmt, ...);
+
+extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, int len, int type);
+extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
+extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
+extern int ckpt_read_payload(struct ckpt_ctx *ctx,
+			     void **ptr, int max, int type);
+extern char *ckpt_read_string(struct ckpt_ctx *ctx, int max);
+extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
+
+extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
+
+/* task */
+extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task(struct ckpt_ctx *ctx);
+
+static inline int ckpt_validate_errno(int errno)
+{
+	return (errno >= 0) && (errno < MAX_ERRNO);
+}
+
+/* debugging flags */
+#define CKPT_DBASE	0x1		/* anything */
+#define CKPT_DSYS	0x2		/* generic (system) */
+#define CKPT_DRW	0x4		/* image read/write */
+
+#define CKPT_DDEFAULT	0xffff		/* default debug level */
+
+#ifndef CKPT_DFLAG
+#define CKPT_DFLAG	0xffff		/* everything */
+#endif
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+extern unsigned long ckpt_debug_level;
+
+/* use this to select a specific debug level */
+#define _ckpt_debug(level, fmt, args...)				\
+	do {								\
+		if (ckpt_debug_level & (level))				\
+			printk(KERN_DEBUG "[%d:%d:c/r:%s:%d] " fmt,	\
+				current->pid, task_pid_vnr(current),	\
+				__func__, __LINE__, ## args);		\
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
+#endif /* CONFIG_CHECKPOINT */
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_CHECKPOINT_H_ */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
new file mode 100644
index 0000000..22dadbd
--- /dev/null
+++ b/include/linux/checkpoint_hdr.h
@@ -0,0 +1,111 @@
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
+ * is readily available. Structs that include a struct ckpt_hdr are named
+ * struct ckpt_hdr_* by convention (usualy the struct ckpt_hdr is the first
+ * member).
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
+/* kernel constants */
+struct ckpt_const {
+	/* task */
+	__u16 task_comm_len;
+	/* uts */
+	__u16 uts_release_len;
+	__u16 uts_version_len;
+	__u16 uts_machine_len;
+} __attribute__((aligned(8)));
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
+	struct ckpt_const constants;
+
+	__u64 time;	/* when checkpoint taken */
+	__u64 uflags;	/* uflags from checkpoint */
+
+	/*
+	 * the header is followed by three strings:
+	 *   char release[const.uts_release_len];
+	 *   char version[const.uts_version_len];
+	 *   char machine[const.uts_machine_len];
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
+	__u64 set_child_tid;
+	__u64 clear_child_tid;
+} __attribute__((aligned(8)));
+
+#endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
new file mode 100644
index 0000000..585cb7b
--- /dev/null
+++ b/include/linux/checkpoint_types.h
@@ -0,0 +1,35 @@
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
+#ifdef __KERNEL__
+
+#include <linux/fs.h>
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
+	struct task_struct *tsk;/* checkpoint: current target task */
+	char err_string[256];	/* checkpoint: error string */
+};
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index 1923327..ff17a59 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -53,4 +53,8 @@
 #define INOTIFYFS_SUPER_MAGIC	0x2BAD1DEA
 
 #define STACK_END_MAGIC		0x57AC6E9D
+
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 12327b2..e1ae6e6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1006,6 +1006,19 @@ config DMA_API_DEBUG
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
