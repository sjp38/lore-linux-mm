Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8836B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:15:16 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 07/19] c/r: basic infrastructure for checkpoint/restart
Date: Tue, 14 Dec 2010 08:14:55 -0800
Message-Id: <1292343307-7870-7-git-send-email-danms@us.ibm.com>
In-Reply-To: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
References: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: danms@us.ibm.com
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

Add those interfaces, as well as helpers needed to easily manage the
file format. The code is roughly broken out as follows:

kernel/checkpoint/sys.c - user/kernel data transfer, as well as setup
  of the c/r context (a per-checkpoint data structure for housekeeping)

kernel/checkpoint/checkpoint.c - output wrappers and checkpoint handling

kernel/checkpoint/restart.c - input wrappers and restart handling

kernel/checkpoint/process.c - c/r of task data

For now, we can only checkpoint the 'current' task ("self" checkpoint),
and the 'pid' argument to the syscall is ignored.

Patches to add the per-architecture support as well as the actual
work to do the memory checkpoint follow in subsequent patches.

Changelog[v21]:
  - Complain if checkpoint_hdr.h included without CONFIG_CHECKPOINT
  - Do not include checkpoint_hdr.h explicitly
  - Consolidate ckpt_read/write with kernel_read/write
  - Reorganize code:move checkpoint/* to kernel/checkpoint/*
  - [Christoffer Dall] Fix trivial bug in ckpt_msg macro
Changelog[v20]:
  - Export key symbols to enable c/r from kernel modules
Changelog[v19]:
  - [Serge Hallyn] Use ckpt_err() to for bad header values
Changelog[v19-rc3]:
  - sys_{checkpoint,restart} to use ptregs prototype
Changelog[v19-rc1]:
  - Set ctx->errno in do_ckpt_msg() if needed
  - Document prototype of ckpt_write_err in header
  - Update prototype of ckpt_read_obj()
  - Fix up headers so we can munge them for use by userspace
  - [Matt Helsley] Check for empty string for _ckpt_write_err()
  - [Matt Helsley] Add cpp definitions for enums
  - [Serge Hallyn] Add global section container to image format
  - [Matt Helsley] Fix total byte read/write count for large images
  - ckpt_read_buf_type() to accept max payload (excludes ckpt_hdr)
  - [Serge Hallyn] Define new api for error and debug logging
  - Use logfd in sys_{checkpoint,restart}
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

Cc: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/Kbuild             |    3 +
 include/linux/checkpoint.h       |  202 +++++++++++++++++
 include/linux/checkpoint_hdr.h   |  135 +++++++++++
 include/linux/checkpoint_types.h |   44 ++++
 include/linux/magic.h            |    3 +
 include/linux/syscalls.h         |    4 -
 kernel/checkpoint/Makefile       |    6 +-
 kernel/checkpoint/checkpoint.c   |  213 ++++++++++++++++++
 kernel/checkpoint/process.c      |  101 +++++++++
 kernel/checkpoint/restart.c      |  460 +++++++++++++++++++++++++++++++++++++
 kernel/checkpoint/sys.c          |  461 +++++++++++++++++++++++++++++++++++++-
 lib/Kconfig.debug                |   13 +
 12 files changed, 1632 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 include/linux/checkpoint_hdr.h
 create mode 100644 include/linux/checkpoint_types.h
 create mode 100644 kernel/checkpoint/checkpoint.c
 create mode 100644 kernel/checkpoint/process.c
 create mode 100644 kernel/checkpoint/restart.c

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 97319a8..1fe511b 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -81,6 +81,9 @@ header-y += cciss_ioctl.h
 header-y += cdk.h
 header-y += cdrom.h
 header-y += cgroupstats.h
+header-y += checkpoint.h
+header-y += checkpoint_hdr.h
+header-y += checkpoint_types.h
 header-y += chio.h
 header-y += cm4000_cs.h
 header-y += cn_proc.h
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..4bb5b8d
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,202 @@
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
+#define CHECKPOINT_VERSION  3
+
+/* misc user visible */
+#define CHECKPOINT_FD_NONE	-1
+
+#ifdef __KERNEL__
+#ifdef CONFIG_CHECKPOINT
+
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/err.h>
+
+/* sycall helpers */
+extern long do_sys_checkpoint(pid_t pid, int fd,
+			      unsigned long flags, int logfd);
+extern long do_sys_restart(pid_t pid, int fd,
+			   unsigned long flags, int logfd);
+
+/* ckpt_ctx: kflags */
+#define CKPT_CTX_CHECKPOINT_BIT		0
+#define CKPT_CTX_RESTART_BIT		1
+#define CKPT_CTX_ERROR_BIT		3
+
+#define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
+#define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
+#define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
+
+
+extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, size_t count);
+extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, size_t count);
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
+
+extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, int len, int type);
+extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
+extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type);
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
+/*
+ * This is deprecated
+ */
+/* use this to select a specific debug level */
+#define _ckpt_debug(level, fmt, args...)				\
+	do {								\
+		if (ckpt_debug_level & (level))				\
+			printk(KERN_DEBUG "[%d:%d:c/r:%s:%d] " fmt,	\
+				current->pid,				\
+				current->nsproxy ?			\
+				task_pid_vnr(current) : -1,		\
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
+/*
+ * This is deprecated
+ */
+#define _ckpt_debug(level, fmt, args...)	do { } while (0)
+#define ckpt_debug(fmt, args...)		do { } while (0)
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
+
+/*
+ * prototypes for the new logging api
+ */
+
+extern void ckpt_msg_lock(struct ckpt_ctx *ctx);
+extern void ckpt_msg_unlock(struct ckpt_ctx *ctx);
+
+extern void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...);
+extern void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...);
+
+/*
+ * Append formatted msg to ctx->msg[ctx->msg_len].
+ * Must be called after expanding format.
+ * May be called under spinlock.
+ * Must be called under ckpt_msg_lock().
+ */
+extern void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...);
+
+/*
+ * Write ctx->msg to all relevant places.
+ * Must not be called under spinlock.
+ * Must be called under ckpt_msg_lock().
+ */
+extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
+
+/*
+ * Append an enhanced formatted message to ctx->msg.
+ * This will not write the message out to the applicable files, so
+ * the caller will have to use _ckpt_msg_complete() to finish up.
+ * @ctx must be a valid checkpoint context.
+ * @fmt is the extended format
+ *
+ * Must be called with ckpt_msg_lock held.
+ */
+#define _ckpt_msg(ctx, fmt, args...) do {	\
+	_do_ckpt_msg(ctx, 0, fmt, ##args);	\
+} while (0)
+
+/*
+ * Append an enhanced formatted message to ctx->msg.
+ * This will take the ckpt_msg_lock and also write the message out
+ * to the applicable files by calling _ckpt_msg_complete().
+ * @ctx must be a valid checkpoint context.
+ * @fmt is the extended format
+ *
+ * Must not be called under spinlock.
+ */
+#define ckpt_msg(ctx, fmt, args...) do {	\
+	do_ckpt_msg(ctx, 0, fmt, ##args);	\
+} while (0)
+
+/*
+ * Report an error.
+ * This will take the ckpt_msg_lock and also write the message out
+ * to the applicable files by calling _ckpt_msg_complete().
+ * @ctx must be a valid checkpoint context.
+ * @err is the error value
+ * @fmt is the extended format
+ *
+ * Must not be called under spinlock.
+ */
+
+#define ckpt_err(ctx, err, fmt, args...) do {				\
+	do_ckpt_msg(ctx, err, "[E @ %s:%d]" fmt, __func__, __LINE__, ##args); \
+} while (0)
+
+/*
+ * Same as ckpt_err() but
+ *	must be called with ctx->msg_mutex held
+ *	can be called under spinlock
+ *	must be followed by a call to _ckpt_msg_complete()
+ */
+#define _ckpt_err(ctx, err, fmt, args...) do {				\
+	_do_ckpt_msg(ctx, err, "[E @ %s:%d]" fmt, __func__, __LINE__, ##args); \
+} while (0)
+
+#endif /* CONFIG_CHECKPOINT */
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_CHECKPOINT_H_ */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
new file mode 100644
index 0000000..7ccebc7
--- /dev/null
+++ b/include/linux/checkpoint_hdr.h
@@ -0,0 +1,135 @@
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#define _CHECKPOINT_CKPT_HDR_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef __KERNEL__
+#include <sys/types.h>
+#include <linux/types.h>
+#endif
+
+#ifdef __KERNEL__
+#include <linux/types.h>
+
+#ifndef CONFIG_CHECKPOINT
+#error linux/checkpoint_hdr.h included directly (without CONFIG_CHECKPOINT)
+#endif
+
+#endif
+
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
+#define CKPT_HDR_HEADER CKPT_HDR_HEADER
+	CKPT_HDR_CONTAINER,
+#define CKPT_HDR_CONTAINER CKPT_HDR_CONTAINER
+	CKPT_HDR_BUFFER,
+#define CKPT_HDR_BUFFER CKPT_HDR_BUFFER
+	CKPT_HDR_STRING,
+#define CKPT_HDR_STRING CKPT_HDR_STRING
+
+	CKPT_HDR_TASK = 101,
+#define CKPT_HDR_TASK CKPT_HDR_TASK
+
+	CKPT_HDR_TAIL = 9001,
+#define CKPT_HDR_TAIL CKPT_HDR_TAIL
+
+	CKPT_HDR_ERROR = 9999,
+#define CKPT_HDR_ERROR CKPT_HDR_ERROR
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
+/* checkpoint image trailer */
+struct ckpt_hdr_tail {
+	struct ckpt_hdr h;
+	__u64 magic;
+} __attribute__((aligned(8)));
+
+/* container configuration section header */
+struct ckpt_hdr_container {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));;
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
index 0000000..13d6dd5
--- /dev/null
+++ b/include/linux/checkpoint_types.h
@@ -0,0 +1,44 @@
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
+	struct file *logfile;	/* status/debug log file */
+	loff_t total;		/* total read/written */
+
+	struct task_struct *tsk;/* checkpoint: current target task */
+	char err_string[256];	/* checkpoint: error string */
+
+	int errno;		/* errno that caused failure */
+
+#define CKPT_MSG_LEN 1024
+	char fmt[CKPT_MSG_LEN];
+	char msg[CKPT_MSG_LEN];
+	int msglen;
+	struct mutex msg_mutex;
+};
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index ff690d0..30cd986 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -59,4 +59,7 @@
 #define SOCKFS_MAGIC		0x534F434B
 #define V9FS_MAGIC		0x01021997
 
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 20be1a6..cacc27a 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -820,10 +820,6 @@ asmlinkage long sys_fanotify_init(unsigned int flags, unsigned int event_f_flags
 asmlinkage long sys_fanotify_mark(int fanotify_fd, unsigned int flags,
 				  u64 mask, int fd,
 				  const char  __user *pathname);
-asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
-			       int logfd);
-asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags,
-			    int logfd);
 
 int kernel_execve(const char *filename, const char *const argv[], const char *const envp[]);
 
diff --git a/kernel/checkpoint/Makefile b/kernel/checkpoint/Makefile
index 8a32c6f..99364cc 100644
--- a/kernel/checkpoint/Makefile
+++ b/kernel/checkpoint/Makefile
@@ -2,4 +2,8 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT) += sys.o
+obj-$(CONFIG_CHECKPOINT) += \
+	sys.o \
+	checkpoint.o \
+	restart.o \
+	process.o
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
new file mode 100644
index 0000000..75b43e6
--- /dev/null
+++ b/kernel/checkpoint/checkpoint.c
@@ -0,0 +1,213 @@
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
+#include <linux/module.h>
+#include <linux/time.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/utsname.h>
+#include <linux/magic.h>
+#include <linux/checkpoint.h>
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
+EXPORT_SYMBOL(ckpt_write_obj);
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
+EXPORT_SYMBOL(ckpt_write_obj_type);
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
+EXPORT_SYMBOL(ckpt_write_buffer);
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
+EXPORT_SYMBOL(ckpt_write_string);
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
+/* write the container configuration section */
+static int checkpoint_container(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_container *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
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
+	ret = checkpoint_container(ctx);
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
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
new file mode 100644
index 0000000..abd9025
--- /dev/null
+++ b/kernel/checkpoint/process.c
@@ -0,0 +1,101 @@
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
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
new file mode 100644
index 0000000..cd9945c
--- /dev/null
+++ b/kernel/checkpoint/restart.c
@@ -0,0 +1,460 @@
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
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <linux/utsname.h>
+#include <linux/checkpoint.h>
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
+ * @len: desired object length (if 0, flexible)
+ * @max: maximum object length (if 0, flexible)
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
+EXPORT_SYMBOL(_ckpt_read_obj_type);
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
+EXPORT_SYMBOL(_ckpt_read_buffer);
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
+EXPORT_SYMBOL(_ckpt_read_string);
+
+/**
+ * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ * @len: desired total length (if 0, flexible)
+ * @max: maximum total length
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
+EXPORT_SYMBOL(ckpt_read_obj_type);
+
+/**
+ * ckpt_read_buf_type - allocate and read an object of some type (flxible)
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @type: desired object type
+ *
+ * This differs from ckpt_read_obj_type() in that the length of the
+ * incoming object is flexible (up to the maximum specified by @max;
+ * unlimited if @max is 0), as determined by the ckpt_hdr data.
+ *
+ * NOTE: for symmetry with checkpoint, @max is the maximum _payload_
+ * size, excluding the header.
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type)
+{
+	struct ckpt_hdr *h;
+
+	if (max)
+		max += sizeof(struct ckpt_hdr);
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
+EXPORT_SYMBOL(ckpt_read_buf_type);
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
+EXPORT_SYMBOL(ckpt_read_payload);
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
+	str[len - 1] = '\0';	/* always play it safe */
+	return str;
+}
+EXPORT_SYMBOL(ckpt_read_string);
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
+EXPORT_SYMBOL(ckpt_read_consume);
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
+	    h->patch != ((LINUX_VERSION_CODE) & 0xff)) {
+		ckpt_err(ctx, ret, "incompatible kernel version");
+		goto out;
+	}
+	if (h->uflags) {
+		ckpt_err(ctx, ret, "incompatible restart user flags");
+		goto out;
+	}
+
+	ret = check_kernel_const(&h->constants);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "incompatible kernel constants");
+		goto out;
+	}
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
+/* read the container configuration section */
+static int restore_container(struct ckpt_ctx *ctx)
+{
+	int ret = 0;
+	struct ckpt_hdr_container *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_hdr_put(ctx, h);
+
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
+	ret = restore_container(ctx);
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
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index a81750a..af8c1bf 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -8,12 +8,398 @@
  *  distribution for more details.
  */
 
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
 #include <linux/sched.h>
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
+#include <linux/slab.h>
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
+ *   _ckpt_kwrite() - write a kernel-space buffer to a file
+ *   _ckpt_kread() - read from a file to a kernel-space buffer
+ *
+ *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
+ *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
+ *
+ * They latter two succeed only if the entire read or write succeeds,
+ * and return 0, or negative error otherwise.
+ */
+
+static ssize_t _ckpt_kwrite(struct file *file, void *addr, size_t count)
+{
+	loff_t pos;
+	int ret;
+
+	pos = file_pos_read(file);
+	ret = kernel_write(file, pos, addr, count);
+	if (ret < 0)
+		return ret;
+	file_pos_write(file, pos + ret);
+	return ret;
+}
+
+/* returns 0 on success */
+int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, size_t count)
+{
+	int ret;
+
+	ret = _ckpt_kwrite(ctx->file, addr, count);
+	if (ret < 0)
+		return ret;
+
+	ctx->total += count;
+	return 0;
+}
+
+static ssize_t _ckpt_kread(struct file *file, void *addr, size_t count)
+{
+	loff_t pos;
+	int ret;
+
+	pos = file_pos_read(file);
+	ret = kernel_read(file, pos, addr, count);
+	if (ret < 0)
+		return ret;
+	file_pos_write(file, pos + ret);
+	return ret;
+}
+
+/* returns 0 on success */
+int ckpt_kread(struct ckpt_ctx *ctx, void *addr, size_t count)
+{
+	int ret;
+
+	ret = _ckpt_kread(ctx->file, addr, count);
+	if (ret < 0)
+		return ret;
+	if (ret != count)
+		return -EPIPE;
+
+	ctx->total += count;
+	return 0;
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
+EXPORT_SYMBOL(ckpt_hdr_get);
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
+EXPORT_SYMBOL(_ckpt_hdr_put);
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
+EXPORT_SYMBOL(ckpt_hdr_put);
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
+EXPORT_SYMBOL(ckpt_hdr_get_type);
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
+	if (ctx->logfile)
+		fput(ctx->logfile);
+	kfree(ctx);
+}
+
+static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
+				       unsigned long kflags, int logfd)
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
+	mutex_init(&ctx->msg_mutex);
+
+	err = -EBADF;
+	ctx->file = fget(fd);
+	if (!ctx->file)
+		goto err;
+	if (logfd == CHECKPOINT_FD_NONE)
+		goto nolog;
+	ctx->logfile = fget(logfd);
+	if (!ctx->logfile)
+		goto err;
+ nolog:
+	return ctx;
+ err:
+	ckpt_ctx_free(ctx);
+	return ERR_PTR(err);
+}
+
+static void ckpt_set_error(struct ckpt_ctx *ctx, int err)
+{
+	ctx->errno = err;
+}
+
+/* helpers to handler log/dbg/err messages */
+void ckpt_msg_lock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_lock(&ctx->msg_mutex);
+	ctx->msg[0] = '\0';
+	ctx->msglen = 1;
+}
+
+void ckpt_msg_unlock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_unlock(&ctx->msg_mutex);
+}
+
+static inline int is_special_flag(char *s)
+{
+	if (*s == '%' && s[1] == '(' && s[2] != '\0' && s[3] == ')')
+		return 1;
+	return 0;
+}
+
+/*
+ * _ckpt_generate_fmt - handle the special flags in the enhanced format
+ * strings used by checkpoint/restart error messages.
+ * @ctx: checkpoint context
+ * @fmt: message format
+ *
+ * The special flags are surrounded by %() to help them visually stand
+ * out.  For instance, %(O) means an objref.  The following special
+ * flags are recognized:
+ *	O: objref
+ *	P: pointer
+ *	T: task
+ *	S: string
+ *	V: variable
+ *
+ * %(O) will be expanded to "[obj %d]".  Likewise P, S, and V, will
+ * also expand to format flags requiring an argument to the subsequent
+ * sprintf or printk.  T will be expanded to a string with no flags,
+ * requiring no further arguments.
+ *
+ * These do not accept any extra flags (i.e. min field width, precision,
+ * etc).
+ *
+ * The caller of ckpt_err() and _ckpt_err() must provide
+ * the additional variabes, in order, to match the @fmt (except for
+ * the T key), e.g.:
+ *
+ *	ckpt_err(ctx, err, "%(T)FILE flags %d %(O)\n", flags, objref);
+ *
+ * May be called under spinlock.
+ * Must be called with ctx->msg_mutex held.  The expanded format
+ * will be placed in ctx->fmt.
+ */
+static void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
+{
+	char *s = ctx->fmt;
+	int len = 0;
+
+	for (; *fmt && len < CKPT_MSG_LEN; fmt++) {
+		if (!is_special_flag(fmt)) {
+			s[len++] = *fmt;
+			continue;
+		}
+		switch (fmt[2]) {
+		case 'O':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[obj %%d]");
+			break;
+		case 'P':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[ptr %%p]");
+			break;
+		case 'V':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[sym %%pS]");
+			break;
+		case 'S':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[str %%s]");
+			break;
+		case 'T':
+			if (ctx->tsk)
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid %d tsk %s]",
+					task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+			else
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid -1 tsk NULL]");
+			break;
+		default:
+			printk(KERN_ERR "c/r: bad format specifier %c\n",
+					fmt[2]);
+			BUG();
+		}
+		fmt += 3;
+	}
+	if (len == CKPT_MSG_LEN)
+		s[CKPT_MSG_LEN-1] = '\0';
+	else
+		s[len] = '\0';
+}
+
+static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
+				va_list ap)
+{
+	int len = ctx->msglen;
+
+	if (err) {
+		len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[err %d]",
+				 err);
+		if (len > CKPT_MSG_LEN)
+			goto full;
+	}
+
+	len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[pos %lld]",
+			ctx->total);
+	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
+	if (len > CKPT_MSG_LEN) {
+full:
+		len = CKPT_MSG_LEN;
+		ctx->msg[CKPT_MSG_LEN-1] = '\0';
+	}
+	ctx->msglen = len;
+}
+
+void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	_ckpt_msg_appendv(ctx, 0, fmt, ap);
+	va_end(ap);
+}
+
+void _ckpt_msg_complete(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	/* Don't write an empty or uninitialized msg */
+	if (ctx->msglen <= 1)
+		return;
+
+	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ctx->errno) {
+		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
+		if (!ret)
+			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
+		if (ret < 0)
+			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
+			       ret, ctx->msg+1);
+	}
+
+	if (ctx->logfile) {
+		struct file *logfile = ctx->logfile;
+		loff_t pos = file_pos_read(logfile);
+		ret = kernel_write(logfile, pos, ctx->msg+1, ctx->msglen-1);
+		if (ret > 0)
+			file_pos_write(logfile, pos + ret);
+	}
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	printk(KERN_DEBUG "%s", ctx->msg+1);
+#endif
+
+	ctx->msglen = 0;
+}
+
+#define __do_ckpt_msg(ctx, err, fmt) do {		\
+	va_list ap;					\
+	_ckpt_generate_fmt(ctx, fmt);			\
+	va_start(ap, fmt);				\
+	_ckpt_msg_appendv(ctx, err, ctx->fmt, ap);	\
+	va_end(ap);					\
+} while (0)
+
+void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
+{
+	__do_ckpt_msg(ctx, err, fmt);
+}
+
+void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
+{
+	if (!ctx)
+		return;
+
+	ckpt_msg_lock(ctx);
+	__do_ckpt_msg(ctx, err, fmt);
+	_ckpt_msg_complete(ctx);
+	ckpt_msg_unlock(ctx);
+
+	if (err)
+		ckpt_set_error(ctx, err);
+}
+EXPORT_SYMBOL(do_ckpt_msg);
+
+/* checkpoint/restart syscalls */
 
 /**
- * sys_checkpoint - checkpoint a container
+ * do_sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
  * @fd: file to which dump the checkpoint image
  * @flags: checkpoint operation flags
@@ -22,14 +408,32 @@
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd,
-		unsigned long, flags, int, logfd)
+long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
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
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
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
- * sys_restart - restart a container
+ * do_sys_restart - restart a container
  * @pid: pid of task root (in coordinator's namespace), or 0
  * @fd: file from which read the checkpoint image
  * @flags: restart operation flags
@@ -38,8 +442,49 @@ SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd,
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE4(restart, pid_t, pid, int, fd,
-		unsigned long, flags, int, logfd)
+long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
+{
+	struct ckpt_ctx *ctx = NULL;
+	long ret;
+
+	/* no flags for now */
+	if (flags)
+		return -EINVAL;
+
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
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
+EXPORT_SYMBOL(ckpt_debug_level);
+
+static __init int ckpt_debug_setup(char *s)
 {
-	return -ENOSYS;
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
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 28b42b9..df9a344 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1230,6 +1230,19 @@ config ASYNC_RAID6_TEST
 
 	  If unsure, say N.
 
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
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
