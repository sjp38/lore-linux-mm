Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB146B008C
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:29 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 72/80] c/r: [pty 2/2] support for pseudo terminals
Date: Wed, 23 Sep 2009 19:51:52 -0400
Message-Id: <1253749920-18673-73-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds support for checkpoint and restart of pseudo terminals
(PTYs). Since PTYs are shared (pointed to by file, and signal), they
are managed via objhash.

PTYs are master/slave pairs; The code arranges for the master to
always be checkpointed first, followed by the slave. This is important
since during restart both ends are created when restoring the master.

In this patch only UNIX98 style PTYs are supported.

Currently only PTYs that are referenced by open files are handled.
Thus PTYs checkpoint starts with a file in tty_file_checkpoint(). It
will first checkpoint the master and slave PTYs via tty_checkpoint(),
and then complete the saving of the file descriptor. This means that
in the image file, the order of objects is: master-tty, slave-tty,
file-desc.

During restart, to restore the master side, we open the /dev/ptmx
device and get a file handle. But at this point we don't know the
designated objref for this file, because the file is due later on in
the image stream. On the other hand, we can't just fput() the file
because it will close the PTY too.

Instead, when we checkpoint the master PTY, we _reserve_ an objref
for the file (which won't be further used in checkpoint). Then at
restart, use it to insert the file to objhash.

TODO:

* Better sanitize input from checkpoint image on restore
* Check the locking when saving/restoring tty_struct state
* Echo position/buffer isn't saved (is it needed ?)
* Handle multiple devpts mounts (namespaces)
* Paths of ptmx and slaves are hard coded (/dev/ptmx, /dev/pts/...)

Changelog[v4]:
  - Fix error path(s) in restore_tty_ldisc()
  - Fix memory leak in restore_tty_ldisc()
Changelog[v3]:
  - [Serge Hallyn] Set tty on error path
Changelog[v2]:
  - Don't save/restore tty->{session,pgrp}
  - Fix leak: drop file reference after ckpt_obj_insert()
  - Move get_file() inside locked clause (fix race)
Changelog[v1]:
  - Adjust include/asm/checkpoint_hdr.h for s390 architecture
  - Add NCC to kernel constants header (ckpt_hdr_const)
  - [Serge Hallyn] fix calculation of canon_datalen

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 arch/s390/include/asm/checkpoint_hdr.h |   11 +
 arch/x86/include/asm/checkpoint_hdr.h  |   11 +
 checkpoint/checkpoint.c                |    3 +
 checkpoint/files.c                     |    6 +
 checkpoint/objhash.c                   |   26 ++
 checkpoint/restart.c                   |    6 +
 drivers/char/pty.c                     |    1 +
 drivers/char/tty_io.c                  |  499 ++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h             |    4 +
 include/linux/checkpoint_hdr.h         |   85 ++++++
 include/linux/tty.h                    |    7 +
 11 files changed, 659 insertions(+), 0 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index 1976355..b6ea8ce 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -83,13 +83,24 @@ struct ckpt_hdr_mm_context {
 };
 
 #define CKPT_ARCH_NSIG  64
+#define CKPT_TTY_NCC  8
+
+/* arch dependent constants */
 #ifdef __KERNEL__
+
 #include <asm/signal.h>
 #if CKPT_ARCH_NSIG != _SIGCONTEXT_NSIG
 #error CKPT_ARCH_NSIG size is wrong (asm/sigcontext.h and asm/checkpoint_hdr.h)
 #endif
+
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
 #endif
 
+#endif /* __KERNEL__ */
+
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 };
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 1228d1b..7a24de5 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -48,14 +48,25 @@ enum {
 	CKPT_HDR_MM_CONTEXT_LDT,
 };
 
+/* arch dependent constants */
 #define CKPT_ARCH_NSIG  64
+#define CKPT_TTY_NCC  8
+
 #ifdef __KERNEL__
+
 #include <asm/signal.h>
 #if CKPT_ARCH_NSIG != _NSIG
 #error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
 #endif
+
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
 #endif
 
+#endif /* __KERNEL__ */
+
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 	/* FIXME: add HAVE_HWFP */
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ae79df7..dbe9e10 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -299,6 +299,9 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->uts_domainname_len = sizeof(uts->domainname);
 	/* rlimit */
 	h->rlimit_nlimits = RLIM_NLIMITS;
+	/* tty */
+	h->n_tty_buf_size = N_TTY_BUF_SIZE;
+	h->tty_termios_ncc = NCC;
 }
 
 /* write the checkpoint header */
diff --git a/checkpoint/files.c b/checkpoint/files.c
index 058bc0e..27e29a0 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -598,6 +598,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_SOCKET,
 		.restore = sock_file_restore,
 	},
+	/* tty */
+	{
+		.file_name = "TTY",
+		.file_type = CKPT_FILE_TTY,
+		.restore = tty_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 0978060..f84388d 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -269,6 +269,22 @@ static int obj_sock_users(void *ptr)
 	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
 }
 
+static int obj_tty_grab(void *ptr)
+{
+	tty_kref_get((struct tty_struct *) ptr);
+	return 0;
+}
+
+static void obj_tty_drop(void *ptr, int lastref)
+{
+	tty_kref_put((struct tty_struct *) ptr);
+}
+
+static int obj_tty_users(void *ptr)
+{
+	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -407,6 +423,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_sock,
 		.restore = restore_sock,
 	},
+	/* struct tty_struct */
+	{
+		.obj_name = "TTY",
+		.obj_type = CKPT_OBJ_TTY,
+		.ref_drop = obj_tty_drop,
+		.ref_grab = obj_tty_grab,
+		.ref_users = obj_tty_users,
+		.checkpoint = checkpoint_tty,
+		.restore = restore_tty,
+	},
 };
 
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 340698a..1016278 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -19,6 +19,7 @@
 #include <linux/freezer.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
+#include <linux/termios.h>
 #include <asm/syscall.h>
 #include <linux/elf.h>
 #include <linux/deferqueue.h>
@@ -402,6 +403,11 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* rlimit */
 	if (h->rlimit_nlimits != RLIM_NLIMITS)
 		return -EINVAL;
+	/* tty */
+	if (h->n_tty_buf_size != N_TTY_BUF_SIZE)
+		return -EINVAL;
+	if (h->tty_termios_ncc != NCC)
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index e2fef99..5fb4ec5 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -15,6 +15,7 @@
 
 #include <linux/errno.h>
 #include <linux/interrupt.h>
+#include <linux/file.h>
 #include <linux/tty.h>
 #include <linux/tty_flip.h>
 #include <linux/fcntl.h>
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 7853ea2..72f4432 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -106,6 +106,7 @@
 
 #include <linux/kmod.h>
 #include <linux/nsproxy.h>
+#include <linux/checkpoint.h>
 
 #undef TTY_DEBUG_HANGUP
 
@@ -151,6 +152,13 @@ static long tty_compat_ioctl(struct file *file, unsigned int cmd,
 #define tty_compat_ioctl NULL
 #endif
 static int tty_fasync(int fd, struct file *filp, int on);
+#ifdef CONFIG_CHECKPOINT
+static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file);
+#else
+#define tty_file_checkpoint NULL
+#define tty_file_collect NULL
+#endif /* CONFIG_CHECKPOINT */
 static void release_tty(struct tty_struct *tty, int idx);
 static void __proc_set_tty(struct task_struct *tsk, struct tty_struct *tty);
 static void proc_set_tty(struct task_struct *tsk, struct tty_struct *tty);
@@ -417,6 +425,8 @@ static const struct file_operations tty_fops = {
 	.open		= tty_open,
 	.release	= tty_release,
 	.fasync		= tty_fasync,
+	.checkpoint	= tty_file_checkpoint,
+	.collect	= tty_file_collect,
 };
 
 static const struct file_operations console_fops = {
@@ -439,6 +449,8 @@ static const struct file_operations hung_up_tty_fops = {
 	.unlocked_ioctl	= hung_up_tty_ioctl,
 	.compat_ioctl	= hung_up_tty_compat_ioctl,
 	.release	= tty_release,
+	.checkpoint	= tty_file_checkpoint,
+	.collect	= tty_file_collect,
 };
 
 static DEFINE_SPINLOCK(redirect_lock);
@@ -2586,6 +2598,493 @@ static long tty_compat_ioctl(struct file *file, unsigned int cmd,
 }
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+static int tty_can_checkpoint(struct ckpt_ctx *ctx, struct tty_struct *tty)
+{
+	/* only support pty driver */
+	if (tty->driver->type != TTY_DRIVER_TYPE_PTY) {
+		ckpt_write_err(ctx, "TSP", "tty: unknown driverv type %d",
+			       tty->driver, tty, tty->driver->type);
+		return 0;
+	}
+	/* only support unix98 style */
+	if (tty->driver->major != UNIX98_PTY_MASTER_MAJOR &&
+	    tty->driver->major != UNIX98_PTY_SLAVE_MAJOR) {
+		ckpt_write_err(ctx, "TP", "tty: legacy pty", tty);
+		return 0;
+	}
+	/* only support n_tty ldisc */
+	if (tty->ldisc->ops->num != N_TTY) {
+		ckpt_write_err(ctx, "TSP", "tty: unknown ldisc type %d",
+			       tty->ldisc->ops, tty, tty->ldisc->ops->num);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_tty *h;
+	struct tty_struct *tty, *real_tty;
+	struct inode *inode;
+	int master_objref, slave_objref;
+	int ret;
+
+	tty = (struct tty_struct *)file->private_data;
+	inode = file->f_path.dentry->d_inode;
+	if (tty_paranoia_check(tty, inode, "tty_file_checkpoint"))
+		return -EIO;
+
+	if (!tty_can_checkpoint(ctx, tty))
+		return -ENOSYS;
+
+	/*
+	 * If we ever support more than PTYs, this would be tty-type
+	 * specific (and probably called via tty_operations).
+	 */
+
+	real_tty = tty_pair_get_tty(tty);
+	ckpt_debug("tty: %p, real_tty: %p\n", tty, real_tty);
+
+	master_objref = checkpoint_obj(ctx, real_tty->link, CKPT_OBJ_TTY);
+	if (master_objref < 0)
+		return master_objref;
+	slave_objref = checkpoint_obj(ctx, real_tty, CKPT_OBJ_TTY);
+	if (slave_objref < 0)
+		return slave_objref;
+	ckpt_debug("master %p %d, slave %p %d\n",
+		   real_tty->link, master_objref, real_tty, slave_objref);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_TTY;
+	h->tty_objref = (tty == real_tty ? slave_objref : master_objref);
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (!ret)
+		ret = ckpt_write_obj(ctx, &h->common.h);
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct tty_struct *tty;
+	struct inode *inode;
+	int ret;
+
+	tty = (struct tty_struct *)file->private_data;
+	inode = file->f_path.dentry->d_inode;
+	if (tty_paranoia_check(tty, inode, "tty_collect"))
+		return -EIO;
+
+	if (!tty_can_checkpoint(ctx, tty))
+		return -ENOSYS;
+
+	ckpt_debug("collecting tty: %p\n", tty);
+	ret = ckpt_obj_collect(ctx, tty, CKPT_OBJ_TTY);
+	if (ret < 0)
+		return ret;
+
+	if (tty->driver->subtype == PTY_TYPE_MASTER) {
+		if (!tty->link) {
+			ckpt_write_err(ctx, "TP", "tty: missing link\n", tty);
+			return -EIO;
+		}
+		ckpt_debug("collecting slave tty: %p\n", tty->link);
+		ret = ckpt_obj_collect(ctx, tty->link, CKPT_OBJ_TTY);
+	}
+
+	return ret;
+}
+
+#define CKPT_LDISC_BAD   (1 << TTY_LDISC_CHANGING)
+#define CKPT_LDISC_GOOD  ((1 << TTY_LDISC_OPEN) | (1 << TTY_LDISC))
+#define CKPT_LDISC_FLAGS (CKPT_LDISC_GOOD | CKPT_LDISC_BAD)
+
+static int checkpoint_tty_ldisc(struct ckpt_ctx *ctx, struct tty_struct *tty)
+{
+	struct ckpt_hdr_ldisc_n_tty *h;
+	int datalen, read_tail;
+	int n, ret;
+
+	/* shouldn't reach here unless ldisc is n_tty */
+	BUG_ON(tty->ldisc->ops->num != N_TTY);
+
+	if ((tty->flags & CKPT_LDISC_FLAGS) != CKPT_LDISC_GOOD) {
+		ckpt_write_err(ctx, "TP", "tty: bad ldisc flags %#lx\n",
+			       tty, tty->flags);
+		return -EBUSY;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TTY_LDISC);
+	if (!h)
+		return -ENOMEM;
+
+	spin_lock_irq(&tty->read_lock);
+	h->column = tty->column;
+	h->datalen = tty->read_cnt;
+	h->canon_column = tty->canon_column;
+	h->canon_datalen = tty->canon_head;
+	if (tty->canon_head > tty->read_tail)
+		h->canon_datalen -= tty->read_tail;
+	else
+		h->canon_datalen += N_TTY_BUF_SIZE - tty->read_tail;
+	h->canon_data = tty->canon_data;
+
+	datalen = tty->read_cnt;
+	read_tail = tty->read_tail;
+	spin_unlock_irq(&tty->read_lock);
+
+	h->minimum_to_wake = tty->minimum_to_wake;
+
+	h->stopped = tty->stopped;
+	h->hw_stopped = tty->hw_stopped;
+	h->flow_stopped = tty->flow_stopped;
+	h->packet = tty->packet;
+	h->ctrl_status = tty->ctrl_status;
+	h->lnext = tty->lnext;
+	h->erasing = tty->erasing;
+	h->raw = tty->raw;
+	h->real_raw = tty->real_raw;
+	h->icanon = tty->icanon;
+	h->closing = tty->closing;
+
+	BUILD_BUG_ON(sizeof(h->read_flags) != sizeof(tty->read_flags));
+	memcpy(h->read_flags, tty->read_flags, sizeof(tty->read_flags));
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("datalen %d\n", datalen);
+	if (datalen) {
+		ret = ckpt_write_buffer(ctx, NULL, datalen);
+		if (ret < 0)
+			return ret;
+		n = min(datalen, N_TTY_BUF_SIZE - read_tail);
+		ret = ckpt_kwrite(ctx, &tty->read_buf[read_tail], n);
+		if (ret < 0)
+			return ret;
+		n = datalen - n;
+		ret = ckpt_kwrite(ctx, tty->read_buf, n);
+	}
+
+	return ret;
+}
+
+#define CKPT_TTY_BAD   ((1 << TTY_CLOSING) | (1 << TTY_FLUSHING))
+#define CKPT_TTY_GOOD  0
+
+static int do_checkpoint_tty(struct ckpt_ctx *ctx, struct tty_struct *tty)
+{
+	struct ckpt_hdr_tty *h;
+	int link_objref;
+	int master = 0;
+	int ret;
+
+	if ((tty->flags & (CKPT_TTY_BAD | CKPT_TTY_GOOD)) != CKPT_TTY_GOOD) {
+		ckpt_write_err(ctx, "TP", "tty: bad flags %#lx\n",
+			       tty, tty->flags);
+		return -EBUSY;
+	}
+
+	/*
+	 * If we ever support more than PTYs, this would be tty-type
+	 * specific (and probably called via tty_operations).
+	 */
+	link_objref = ckpt_obj_lookup(ctx, tty->link, CKPT_OBJ_TTY);
+
+	if (tty->driver->subtype == PTY_TYPE_MASTER)
+		master = 1;
+
+	/* tty is master if-and-only-if link_objref is zero */
+	BUG_ON(master ^ !link_objref);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TTY);
+	if (!h)
+		return -ENOMEM;
+
+	h->driver_type = tty->driver->type;
+	h->driver_subtype = tty->driver->subtype;
+
+	h->link_objref = link_objref;
+
+	/* if master, reserve an objref (see do_restore_tty) */
+	h->file_objref = (master ? ckpt_obj_reserve(ctx) : 0);
+	ckpt_debug("link %d file %d\n", h->link_objref, h->file_objref);
+
+	h->index = tty->index;
+	h->ldisc = tty->ldisc->ops->num;
+	h->flags = tty->flags;
+
+	mutex_lock(&tty->termios_mutex);
+	h->termios.c_line = tty->termios->c_line;
+	h->termios.c_iflag = tty->termios->c_iflag;
+	h->termios.c_oflag = tty->termios->c_oflag;
+	h->termios.c_cflag = tty->termios->c_cflag;
+	h->termios.c_lflag = tty->termios->c_lflag;
+	memcpy(h->termios.c_cc, tty->termios->c_cc, NCC);
+	h->winsize.ws_row = tty->winsize.ws_row;
+	h->winsize.ws_col = tty->winsize.ws_col;
+	h->winsize.ws_ypixel = tty->winsize.ws_ypixel;
+	h->winsize.ws_xpixel = tty->winsize.ws_xpixel;
+	mutex_unlock(&tty->termios_mutex);
+
+	ret  = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* save line discipline data (also writes buffer) */
+	if (!test_bit(TTY_HUPPED, &tty->flags))
+		ret = checkpoint_tty_ldisc(ctx, tty);
+
+	return ret;
+}
+
+int checkpoint_tty(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_tty(ctx, (struct tty_struct *) ptr);
+}
+
+struct file *tty_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_tty *h = (struct ckpt_hdr_file_tty *) ptr;
+	struct tty_struct *tty;
+	struct file *file;
+	char slavepath[16];	/* "/dev/pts/###" */
+	int slavelock;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE ||
+	    ptr->h.len != sizeof(*h) || ptr->f_type != CKPT_FILE_TTY)
+		return ERR_PTR(-EINVAL);
+
+	if (h->tty_objref <= 0)
+		return ERR_PTR(-EINVAL);
+
+	tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
+	ckpt_debug("tty %p objref %d\n", tty, h->tty_objref);
+
+	/* at this point the tty should have been restore already */
+	if (IS_ERR(tty))
+		return (struct file *) tty;
+
+	/*
+	 * If we ever support more than PTYs, this would be tty-type
+	 * specific (and probably called via tty_operations).
+	 */
+
+	/*
+	 * If this tty is master, get the corresponding file from
+	 * tty->tty_file. Otherwise, open the slave device.
+	 */
+	if (tty->driver->subtype == PTY_TYPE_MASTER) {
+		file_list_lock();
+		file = list_first_entry(&tty->tty_files,
+					typeof(*file), f_u.fu_list);
+		get_file(file);
+		file_list_unlock();
+		ckpt_debug("master file %p\n", file);
+	} else {
+		sprintf(slavepath, "/dev/pts/%d", tty->index);
+		slavelock = test_bit(TTY_PTY_LOCK, &tty->link->flags);
+		clear_bit(TTY_PTY_LOCK, &tty->link->flags);
+		file = filp_open(slavepath, O_RDWR | O_NOCTTY, 0);
+		ckpt_debug("slave file %p (idnex %d)\n", file, tty->index);
+		if (IS_ERR(file))
+			return file;
+		if (slavelock)
+			set_bit(TTY_PTY_LOCK, &tty->link->flags);
+	}
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+
+	return file;
+}
+
+static int restore_tty_ldisc(struct ckpt_ctx *ctx,
+			     struct tty_struct *tty,
+			     struct ckpt_hdr_tty *hh)
+{
+	struct ckpt_hdr_ldisc_n_tty *h;
+	int ret = -EINVAL;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TTY_LDISC);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* this is unfair shortcut, because we know ldisc is n_tty */
+	if (hh->ldisc != N_TTY)
+		goto out;
+	if ((hh->flags & CKPT_LDISC_FLAGS) != CKPT_LDISC_GOOD)
+		goto out;
+
+	if (h->datalen > N_TTY_BUF_SIZE)
+		goto out;
+	if (h->canon_datalen > N_TTY_BUF_SIZE)
+		goto out;
+
+	if (h->datalen) {
+		ret = _ckpt_read_buffer(ctx, tty->read_buf, h->datalen);
+		if (ret < 0)
+			goto out;
+	}
+
+	/* TODO: sanitize all these values ? */
+
+	spin_lock_irq(&tty->read_lock);
+	tty->column = h->column;
+	tty->read_cnt = h->datalen;
+	tty->read_head = h->datalen;
+	tty->read_tail = 0;
+	tty->canon_column = h->canon_column;
+	tty->canon_head = h->canon_datalen;
+	tty->canon_data = h->canon_data;
+	spin_unlock_irq(&tty->read_lock);
+
+	tty->minimum_to_wake = h->minimum_to_wake;
+
+	tty->stopped = h->stopped;
+	tty->hw_stopped = h->hw_stopped;
+	tty->flow_stopped = h->flow_stopped;
+	tty->packet = h->packet;
+	tty->ctrl_status = h->ctrl_status;
+	tty->lnext = h->lnext;
+	tty->erasing = h->erasing;
+	tty->raw = h->raw;
+	tty->real_raw = h->real_raw;
+	tty->icanon = h->icanon;
+	tty->closing = h->closing;
+
+	BUILD_BUG_ON(sizeof(h->read_flags) != sizeof(tty->read_flags));
+	memcpy(tty->read_flags, h->read_flags, sizeof(tty->read_flags));
+ out:
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+#define CKPT_PTMX_PATH  "/dev/ptmx"
+
+static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tty *h;
+	struct tty_struct *tty = ERR_PTR(-EINVAL);
+	struct file *file = NULL;
+	int master, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TTY);
+	if (IS_ERR(h))
+		return (struct tty_struct *) h;
+
+	if (h->driver_type != TTY_DRIVER_TYPE_PTY)
+		goto out;
+	if (h->driver_subtype == PTY_TYPE_MASTER)
+		master = 1;
+	else if (h->driver_subtype == PTY_TYPE_SLAVE)
+		master = 0;
+	else
+		goto out;
+	/* @link_object is positive if-and-only-if tty is not master */
+	if (h->link_objref < 0 || (master ^ !h->link_objref))
+		goto out;
+	/* @file_object is positive if-and-only-if tty is master */
+	if (h->file_objref < 0 || (master ^ !!h->file_objref))
+		goto out;
+	if (h->flags & CKPT_TTY_BAD)
+		goto out;
+	/* hung-up tty cannot be master, or have session or pgrp */
+	if (test_bit(TTY_HUPPED, (unsigned long *) &h->flags) && master)
+		goto out;
+
+	ckpt_debug("sanity checks passed, link %d\n", h->link_objref);
+
+	/*
+	 * If we ever support more than PTYs, this would be tty-type
+	 * specific (and probably called via tty_operations).
+	 */
+	if (master) {
+		file = pty_open_by_index("/dev/ptmx", h->index);
+		if (IS_ERR(file)) {
+			ckpt_write_err(ctx, "TE", "open ptmx", PTR_ERR(file));
+			tty = ERR_PTR(PTR_ERR(file));
+			goto out;
+		}
+
+		/*
+		 * Add file to objhash to ensure proper cleanup later
+		 * (it isn't referenced elsewhere). Use h->file_objref
+		 * which was explicitly during checkpoint for this.
+		 */
+		ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
+		fput(file);  /* even on succes (referenced in objash) */
+		if (ret < 0) {
+			tty = ERR_PTR(ret);
+			goto out;
+		}
+
+		tty = file->private_data;
+	} else {
+		tty = ckpt_obj_fetch(ctx, h->link_objref, CKPT_OBJ_TTY);
+		if (IS_ERR(tty))
+			goto out;
+		tty = tty->link;
+	}
+
+	ckpt_debug("tty %p (hup %d)\n",
+		   tty, test_bit(TTY_HUPPED, (unsigned long *) &h->flags));
+
+	/* we now have the desired tty: restore its state as per @h */
+
+	mutex_lock(&tty->termios_mutex);
+	tty->termios->c_line = h->termios.c_line;
+	tty->termios->c_iflag = h->termios.c_iflag;
+	tty->termios->c_oflag = h->termios.c_oflag;
+	tty->termios->c_cflag = h->termios.c_cflag;
+	tty->termios->c_lflag = h->termios.c_lflag;
+	memcpy(tty->termios->c_cc, h->termios.c_cc, NCC);
+	tty->winsize.ws_row = h->winsize.ws_row;
+	tty->winsize.ws_col = h->winsize.ws_col;
+	tty->winsize.ws_ypixel = h->winsize.ws_ypixel;
+	tty->winsize.ws_xpixel = h->winsize.ws_xpixel;
+	mutex_unlock(&tty->termios_mutex);
+
+	if (test_bit(TTY_HUPPED, (unsigned long *) &h->flags))
+		tty_vhangup(tty);
+	else {
+		ret = restore_tty_ldisc(ctx, tty, h);
+		if (ret < 0) {
+			tty = ERR_PTR(ret);
+			goto out;
+		}
+	}
+
+	tty_kref_get(tty);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return tty;
+}
+
+void *restore_tty(struct ckpt_ctx *ctx)
+{
+#ifdef CONFIG_UNIX98_PTYS
+	return (void *) do_restore_tty(ctx);
+#else
+	return ERR_PTR(-ENOSYS);
+#endif
+}
+#endif /* COFNIG_CHECKPOINT */
+
 /*
  * This implements the "Secure Attention Key" ---  the idea is to
  * prevent trojan horses by killing all processes associated with this
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 92a21b2..7c117fc 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -266,6 +266,10 @@ extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
 extern int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task_signal(struct ckpt_ctx *ctx);
 
+/* ttys */
+extern int checkpoint_tty(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_tty(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ac16c59..bf584cb 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -83,6 +83,8 @@ enum {
 	CKPT_HDR_FILE_NAME,
 	CKPT_HDR_FILE,
 	CKPT_HDR_PIPE_BUF,
+	CKPT_HDR_TTY,
+	CKPT_HDR_TTY_LDISC,
 
 	CKPT_HDR_MM = 401,
 	CKPT_HDR_VMA,
@@ -141,6 +143,7 @@ enum obj_type {
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_SOCK,
+	CKPT_OBJ_TTY,
 	CKPT_OBJ_MAX
 };
 
@@ -161,6 +164,9 @@ struct ckpt_const {
 	__u16 uts_domainname_len;
 	/* rlimit */
 	__u16 rlimit_nlimits;
+	/* tty */
+	__u16 n_tty_buf_size;
+	__u16 tty_termios_ncc;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -368,6 +374,7 @@ enum file_type {
 	CKPT_FILE_PIPE,
 	CKPT_FILE_FIFO,
 	CKPT_FILE_SOCKET,
+	CKPT_FILE_TTY,
 	CKPT_FILE_MAX
 };
 
@@ -660,6 +667,84 @@ struct ckpt_hdr_ipc_sem {
 } __attribute__((aligned(8)));
 
 
+/* devices */
+struct ckpt_hdr_file_tty {
+	struct ckpt_hdr_file common;
+	__s32 tty_objref;
+};
+
+struct ckpt_hdr_tty {
+	struct ckpt_hdr h;
+
+	__u16 driver_type;
+	__u16 driver_subtype;
+
+	__s32 link_objref;
+	__s32 file_objref;
+	__u32 _padding;
+
+	__u32 index;
+	__u32 ldisc;
+	__u64 flags;
+
+	/* termios */
+	struct {
+		__u16 c_iflag;
+		__u16 c_oflag;
+		__u16 c_cflag;
+		__u16 c_lflag;
+		__u8 c_line;
+		__u8 c_cc[CKPT_TTY_NCC];
+	} __attribute__((aligned(8))) termios;
+
+	/* winsize */
+	struct {
+		__u16 ws_row;
+		__u16 ws_col;
+		__u16 ws_xpixel;
+		__u16 ws_ypixel;
+	} __attribute__((aligned(8))) winsize;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/tty.h> from userspace, so define: */
+#define CKPT_N_TTY_BUF_SIZE  4096
+#ifdef __KERNEL__
+#include <linux/tty.h>
+#if CKPT_N_TTY_BUF_SIZE != N_TTY_BUF_SIZE
+#error CKPT_N_TTY_BUF_SIZE size is wrong per linux/tty.h
+#endif
+#endif
+
+struct ckpt_hdr_ldisc_n_tty {
+	struct ckpt_hdr h;
+
+	__u32 column;
+	__u32 datalen;
+	__u32 canon_column;
+	__u32 canon_datalen;
+	__u32 canon_data;
+
+	__u16 minimum_to_wake;
+
+	__u8 stopped;
+	__u8 hw_stopped;
+	__u8 flow_stopped;
+	__u8 packet;
+	__u8 ctrl_status;
+	__u8 lnext;
+	__u8 erasing;
+	__u8 raw;
+	__u8 real_raw;
+	__u8 icanon;
+	__u8 closing;
+	__u8 padding[3];
+
+	__u8 read_flags[CKPT_N_TTY_BUF_SIZE / 8];
+
+	/* if @datalen > 0, buffer contents follow (next object) */
+} __attribute__((aligned(8)));
+
+
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
 
diff --git a/include/linux/tty.h b/include/linux/tty.h
index fd40561..295447b 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -471,6 +471,13 @@ extern void tty_ldisc_enable(struct tty_struct *tty);
 /* This one is for ptmx_close() */
 extern int tty_release(struct inode *inode, struct file *filp);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+extern struct file *tty_file_restore(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_file *ptr);
+#endif
+
 /* n_tty.c */
 extern struct tty_ldisc_ops tty_ldisc_N_TTY;
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
