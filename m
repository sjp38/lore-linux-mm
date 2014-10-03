Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id F01BC6B0074
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:48 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so935262vcb.34
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id so5si4710571vcb.97.2014.10.03.10.08.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/17] userfaultfd: add new syscall to provide memory externalization
Date: Fri,  3 Oct 2014 19:08:04 +0200
Message-Id: <1412356087-16115-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Once an userfaultfd is created MADV_USERFAULT regions talks through
the userfaultfd protocol with the thread responsible for doing the
memory externalization of the process.

The protocol starts by userland writing the requested/preferred
USERFAULT_PROTOCOL version into the userfault fd (64bit write), if
kernel knows it, it will ack it by allowing userland to read 64bit
from the userfault fd that will contain the same 64bit
USERFAULT_PROTOCOL version that userland asked. Otherwise userfault
will read __u64 value -1ULL (aka USERFAULTFD_UNKNOWN_PROTOCOL) and it
will have to try again by writing an older protocol version if
suitable for its usage too, and read it back again until it stops
reading -1ULL. After that the userfaultfd protocol starts.

The protocol consists in the userfault fd reads 64bit in size
providing userland the fault addresses. After a userfault address has
been read and the fault is resolved by userland, the application must
write back 128bits in the form of [ start, end ] range (64bit each)
that will tell the kernel such a range has been mapped. Multiple read
userfaults can be resolved in a single range write. poll() can be used
to know when there are new userfaults to read (POLLIN) and when there
are threads waiting a wakeup through a range write (POLLOUT).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/syscalls/syscall_32.tbl |   1 +
 arch/x86/syscalls/syscall_64.tbl |   1 +
 fs/Makefile                      |   1 +
 fs/userfaultfd.c                 | 643 +++++++++++++++++++++++++++++++++++++++
 include/linux/syscalls.h         |   1 +
 include/linux/userfaultfd.h      |  42 +++
 init/Kconfig                     |  11 +
 kernel/sys_ni.c                  |   1 +
 mm/huge_memory.c                 |  24 +-
 mm/memory.c                      |   5 +-
 10 files changed, 720 insertions(+), 10 deletions(-)
 create mode 100644 fs/userfaultfd.c
 create mode 100644 include/linux/userfaultfd.h

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index 2d0594c..782038c 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -364,3 +364,4 @@
 355	i386	getrandom		sys_getrandom
 356	i386	memfd_create		sys_memfd_create
 357	i386	remap_anon_pages	sys_remap_anon_pages
+358	i386	userfaultfd		sys_userfaultfd
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 41e8f3e..3d5601f 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -328,6 +328,7 @@
 319	common	memfd_create		sys_memfd_create
 320	common	kexec_file_load		sys_kexec_file_load
 321	common	remap_anon_pages	sys_remap_anon_pages
+322	common	userfaultfd		sys_userfaultfd
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/Makefile b/fs/Makefile
index 90c8852..00dfe77 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_ANON_INODES)	+= anon_inodes.o
 obj-$(CONFIG_SIGNALFD)		+= signalfd.o
 obj-$(CONFIG_TIMERFD)		+= timerfd.o
 obj-$(CONFIG_EVENTFD)		+= eventfd.o
+obj-$(CONFIG_USERFAULTFD)	+= userfaultfd.o
 obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
new file mode 100644
index 0000000..62b827e
--- /dev/null
+++ b/fs/userfaultfd.c
@@ -0,0 +1,643 @@
+/*
+ *  fs/userfaultfd.c
+ *
+ *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
+ *  Copyright (C) 2008-2009 Red Hat, Inc.
+ *  Copyright (C) 2014  Red Hat, Inc.
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ *
+ *  Some part derived from fs/eventfd.c (anon inode setup) and
+ *  mm/ksm.c (mm hashing).
+ */
+
+#include <linux/hashtable.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/poll.h>
+#include <linux/slab.h>
+#include <linux/seq_file.h>
+#include <linux/file.h>
+#include <linux/bug.h>
+#include <linux/anon_inodes.h>
+#include <linux/syscalls.h>
+#include <linux/userfaultfd.h>
+
+struct userfaultfd_ctx {
+	/* pseudo fd refcounting */
+	atomic_t refcount;
+	/* waitqueue head for the userfaultfd page faults */
+	wait_queue_head_t fault_wqh;
+	/* waitqueue head for the pseudo fd to wakeup poll/read */
+	wait_queue_head_t fd_wqh;
+	/* userfaultfd syscall flags */
+	unsigned int flags;
+	/* state machine */
+	unsigned int state;
+	/* released */
+	bool released;
+};
+
+struct userfaultfd_wait_queue {
+	unsigned long address;
+	wait_queue_t wq;
+	bool pending;
+	struct userfaultfd_ctx *ctx;
+};
+
+#define USERFAULTFD_PROTOCOL ((__u64) 0xaa)
+#define USERFAULTFD_UNKNOWN_PROTOCOL ((__u64) -1ULL)
+
+enum {
+	USERFAULTFD_STATE_ASK_PROTOCOL,
+	USERFAULTFD_STATE_ACK_PROTOCOL,
+	USERFAULTFD_STATE_ACK_UNKNOWN_PROTOCOL,
+	USERFAULTFD_STATE_RUNNING,
+};
+
+/**
+ * struct mm_slot - userlandfd information per mm that is being scanned
+ * @link: link to the mm_slots hash list
+ * @mm: the mm that this information is valid for
+ * @ctx: userfaultfd context for this mm
+ */
+struct mm_slot {
+	struct hlist_node link;
+	struct mm_struct *mm;
+	struct userfaultfd_ctx ctx;
+	struct rcu_head rcu_head;
+};
+
+#define MM_USERLANDFD_HASH_BITS 10
+static DEFINE_HASHTABLE(mm_userlandfd_hash, MM_USERLANDFD_HASH_BITS);
+
+static DEFINE_MUTEX(mm_userlandfd_mutex);
+
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
+{
+	struct mm_slot *slot;
+
+	hash_for_each_possible_rcu(mm_userlandfd_hash, slot, link,
+				   (unsigned long)mm)
+		if (slot->mm == mm)
+			return slot;
+
+	return NULL;
+}
+
+static void insert_to_mm_userlandfd_hash(struct mm_struct *mm,
+					 struct mm_slot *mm_slot)
+{
+	mm_slot->mm = mm;
+	hash_add_rcu(mm_userlandfd_hash, &mm_slot->link, (unsigned long)mm);
+}
+
+static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
+				     int wake_flags, void *key)
+{
+	unsigned long *range = key;
+	int ret;
+	struct userfaultfd_wait_queue *uwq;
+
+	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+	ret = 0;
+	/* don't wake the pending ones to avoid reads to block */
+	if (uwq->pending && !ACCESS_ONCE(uwq->ctx->released))
+		goto out;
+	if (range[0] > uwq->address || range[1] <= uwq->address)
+		goto out;
+	ret = wake_up_state(wq->private, mode);
+	if (ret)
+		/* wake only once, autoremove behavior */
+		list_del_init(&wq->task_list);
+out:
+	return ret;
+}
+
+/**
+ * userfaultfd_ctx_get - Acquires a reference to the internal userfaultfd
+ * context.
+ * @ctx: [in] Pointer to the userfaultfd context.
+ *
+ * Returns: In case of success, returns not zero.
+ */
+static int userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
+{
+	/*
+	 * If it's already released don't get it. This can race
+	 * against userfaultfd_release, if the race triggers it'll be
+	 * handled safely by the handle_userfault main loop
+	 * (userfaultfd_release will take the mmap_sem for writing to
+	 * flush out all in-flight userfaults). This check is only an
+	 * optimization.
+	 */
+	if (unlikely(ACCESS_ONCE(ctx->released)))
+		return 0;
+	return atomic_inc_not_zero(&ctx->refcount);
+}
+
+static void userfaultfd_free(struct userfaultfd_ctx *ctx)
+{
+	struct mm_slot *mm_slot = container_of(ctx, struct mm_slot, ctx);
+
+	mutex_lock(&mm_userlandfd_mutex);
+	hash_del_rcu(&mm_slot->link);
+	mutex_unlock(&mm_userlandfd_mutex);
+
+	kfree_rcu(mm_slot, rcu_head);
+}
+
+/**
+ * userfaultfd_ctx_put - Releases a reference to the internal userfaultfd
+ * context.
+ * @ctx: [in] Pointer to userfaultfd context.
+ *
+ * The userfaultfd context reference must have been previously acquired either
+ * with userfaultfd_ctx_get() or userfaultfd_ctx_fdget().
+ */
+static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->refcount))
+		userfaultfd_free(ctx);
+}
+
+/*
+ * The locking rules involved in returning VM_FAULT_RETRY depending on
+ * FAULT_FLAG_ALLOW_RETRY, FAULT_FLAG_RETRY_NOWAIT and
+ * FAULT_FLAG_KILLABLE are not straightforward. The "Caution"
+ * recommendation in __lock_page_or_retry is not an understatement.
+ *
+ * If FAULT_FLAG_ALLOW_RETRY is set, the mmap_sem must be released
+ * before returning VM_FAULT_RETRY only if FAULT_FLAG_RETRY_NOWAIT is
+ * not set.
+ *
+ * If FAULT_FLAG_ALLOW_RETRY is set but FAULT_FLAG_KILLABLE is not
+ * set, VM_FAULT_RETRY can still be returned if and only if there are
+ * fatal_signal_pending()s, and the mmap_sem must be released before
+ * returning it.
+ */
+int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+		     unsigned int flags)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mm_slot *slot;
+	struct userfaultfd_ctx *ctx;
+	struct userfaultfd_wait_queue uwq;
+	int ret;
+
+	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
+	rcu_read_lock();
+	slot = get_mm_slot(mm);
+	if (!slot) {
+		rcu_read_unlock();
+		return VM_FAULT_SIGBUS;
+	}
+	ctx = &slot->ctx;
+	if (!userfaultfd_ctx_get(ctx)) {
+		rcu_read_unlock();
+		return VM_FAULT_SIGBUS;
+	}
+	rcu_read_unlock();
+
+	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
+	uwq.wq.private = current;
+	uwq.address = address;
+	uwq.pending = true;
+	uwq.ctx = ctx;
+
+	spin_lock(&ctx->fault_wqh.lock);
+	/*
+	 * After the __add_wait_queue the uwq is visible to userland
+	 * through poll/read().
+	 */
+	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (fatal_signal_pending(current)) {
+			/*
+			 * If we have to fail because the task is
+			 * killed just retry the fault either by
+			 * returning to userland or through
+			 * VM_FAULT_RETRY if we come from a page fault
+			 * and a fatal signal is pending.
+			 */
+			ret = 0;
+			if (flags & FAULT_FLAG_KILLABLE) {
+				/*
+				 * If FAULT_FLAG_KILLABLE is set we
+				 * and there's a fatal signal pending
+				 * can return VM_FAULT_RETRY
+				 * regardless if
+				 * FAULT_FLAG_ALLOW_RETRY is set or
+				 * not as long as we release the
+				 * mmap_sem. The page fault will
+				 * return stright to userland then to
+				 * handle the fatal signal.
+				 */
+				up_read(&mm->mmap_sem);
+				ret = VM_FAULT_RETRY;
+			}
+			break;
+		}
+		if (!uwq.pending || ACCESS_ONCE(ctx->released)) {
+			ret = 0;
+			if (flags & FAULT_FLAG_ALLOW_RETRY) {
+				ret = VM_FAULT_RETRY;
+				if (!(flags & FAULT_FLAG_RETRY_NOWAIT))
+					up_read(&mm->mmap_sem);
+			}
+			break;
+		}
+		if (((FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT) &
+		     flags) ==
+		    (FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT)) {
+			ret = VM_FAULT_RETRY;
+			/*
+			 * The mmap_sem must not be released if
+			 * FAULT_FLAG_RETRY_NOWAIT is set despite we
+			 * return VM_FAULT_RETRY (FOLL_NOWAIT case).
+			 */
+			break;
+		}
+		spin_unlock(&ctx->fault_wqh.lock);
+		up_read(&mm->mmap_sem);
+
+		wake_up_poll(&ctx->fd_wqh, POLLIN);
+		schedule();
+
+		down_read(&mm->mmap_sem);
+		spin_lock(&ctx->fault_wqh.lock);
+	}
+	__remove_wait_queue(&ctx->fault_wqh, &uwq.wq);
+	__set_current_state(TASK_RUNNING);
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	/*
+	 * ctx may go away after this if the userfault pseudo fd is
+	 * released by another CPU.
+	 */
+	userfaultfd_ctx_put(ctx);
+
+	return ret;
+}
+
+static int userfaultfd_release(struct inode *inode, struct file *file)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+	struct mm_slot *mm_slot = container_of(ctx, struct mm_slot, ctx);
+	__u64 range[2] = { 0ULL, -1ULL };
+
+	ACCESS_ONCE(ctx->released) = true;
+
+	/*
+	 * Flush page faults out of all CPUs to avoid race conditions
+	 * against ctx->released. All page faults must be retried
+	 * without returning VM_FAULT_SIGBUS if the get_mm_slot and
+	 * userfaultfd_ctx_get both succeeds but ctx->released is set.
+	 */
+	down_write(&mm_slot->mm->mmap_sem);
+	up_write(&mm_slot->mm->mmap_sem);
+
+	spin_lock(&ctx->fault_wqh.lock);
+	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0, range);
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	wake_up_poll(&ctx->fd_wqh, POLLHUP);
+	userfaultfd_ctx_put(ctx);
+	return 0;
+}
+
+static inline unsigned long find_userfault(struct userfaultfd_ctx *ctx,
+					   struct userfaultfd_wait_queue **uwq,
+					   unsigned int events_filter)
+{
+	wait_queue_t *wq;
+	struct userfaultfd_wait_queue *_uwq;
+	unsigned int events = 0;
+
+	BUG_ON(!events_filter);
+
+	spin_lock(&ctx->fault_wqh.lock);
+	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+		_uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+		if (_uwq->pending) {
+			if (!(events & POLLIN) && (events_filter & POLLIN)) {
+				events |= POLLIN;
+				if (uwq)
+					*uwq = _uwq;
+			}
+		} else if (events_filter & POLLOUT)
+			events |= POLLOUT;
+		if (events == events_filter)
+			break;
+	}
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	return events;
+}
+
+static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+
+	poll_wait(file, &ctx->fd_wqh, wait);
+
+	switch (ctx->state) {
+	case USERFAULTFD_STATE_ASK_PROTOCOL:
+		return POLLOUT;
+	case USERFAULTFD_STATE_ACK_PROTOCOL:
+		return POLLIN;
+	case USERFAULTFD_STATE_ACK_UNKNOWN_PROTOCOL:
+		return POLLIN;
+	case USERFAULTFD_STATE_RUNNING:
+		return find_userfault(ctx, NULL, POLLIN|POLLOUT);
+	default:
+		BUG();
+	}
+}
+
+static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
+				    __u64 *addr)
+{
+	ssize_t ret;
+	DECLARE_WAITQUEUE(wait, current);
+	struct userfaultfd_wait_queue *uwq = NULL;
+
+	if (ctx->state == USERFAULTFD_STATE_ASK_PROTOCOL) {
+		return -EINVAL;
+	} else if (ctx->state == USERFAULTFD_STATE_ACK_PROTOCOL) {
+		*addr = USERFAULTFD_PROTOCOL;
+		ctx->state = USERFAULTFD_STATE_RUNNING;
+		return 0;
+	} else if (ctx->state == USERFAULTFD_STATE_ACK_UNKNOWN_PROTOCOL) {
+		*addr = USERFAULTFD_UNKNOWN_PROTOCOL;
+		ctx->state = USERFAULTFD_STATE_ASK_PROTOCOL;
+		return 0;
+	}
+	BUG_ON(ctx->state != USERFAULTFD_STATE_RUNNING);
+
+	spin_lock(&ctx->fd_wqh.lock);
+	__add_wait_queue(&ctx->fd_wqh, &wait);
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		/* always take the fd_wqh lock before the fault_wqh lock */
+		if (find_userfault(ctx, &uwq, POLLIN)) {
+			uwq->pending = false;
+			*addr = uwq->address;
+			ret = 0;
+			break;
+		}
+		if (signal_pending(current)) {
+			ret = -ERESTARTSYS;
+			break;
+		}
+		if (no_wait) {
+			ret = -EAGAIN;
+			break;
+		}
+		spin_unlock(&ctx->fd_wqh.lock);
+		schedule();
+		spin_lock_irq(&ctx->fd_wqh.lock);
+	}
+	__remove_wait_queue(&ctx->fd_wqh, &wait);
+	__set_current_state(TASK_RUNNING);
+	if (ret == 0) {
+		if (waitqueue_active(&ctx->fd_wqh))
+			wake_up_locked_poll(&ctx->fd_wqh, POLLOUT);
+	}
+	spin_unlock_irq(&ctx->fd_wqh.lock);
+
+	return ret;
+}
+
+static ssize_t userfaultfd_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+	ssize_t ret;
+	/* careful to always initialize addr if ret == 0 */
+	__u64 uninitialized_var(addr);
+
+	if (count < sizeof(addr))
+		return -EINVAL;
+	ret = userfaultfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &addr);
+	if (ret < 0)
+		return ret;
+
+	return put_user(addr, (__u64 __user *) buf) ? -EFAULT : sizeof(addr);
+}
+
+static int wake_userfault(struct userfaultfd_ctx *ctx, __u64 *range)
+{
+	wait_queue_t *wq;
+	struct userfaultfd_wait_queue *uwq;
+	int ret = -ENOENT;
+
+	spin_lock(&ctx->fault_wqh.lock);
+	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+		uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+		if (uwq->pending)
+			continue;
+		if (uwq->address >= range[0] &&
+		    uwq->address < range[1]) {
+			ret = 0;
+			/* wake all in the range and autoremove */
+			__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0,
+					     range);
+			break;
+		}
+	}
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	return ret;
+}
+
+static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+	ssize_t res;
+	__u64 range[2];
+	DECLARE_WAITQUEUE(wait, current);
+
+	if (ctx->state == USERFAULTFD_STATE_ASK_PROTOCOL) {
+		__u64 protocol;
+		if (count < sizeof(__u64))
+			return -EINVAL;
+		if (copy_from_user(&protocol, buf, sizeof(protocol)))
+			return -EFAULT;
+		if (protocol != USERFAULTFD_PROTOCOL) {
+			/* we'll offer the supported protocol in the ack */
+			printk_once(KERN_INFO
+				    "userfaultfd protocol not available\n");
+			ctx->state = USERFAULTFD_STATE_ACK_UNKNOWN_PROTOCOL;
+		} else
+			ctx->state = USERFAULTFD_STATE_ACK_PROTOCOL;
+		return sizeof(protocol);
+	} else if (ctx->state == USERFAULTFD_STATE_ACK_PROTOCOL)
+		return -EINVAL;
+
+	BUG_ON(ctx->state != USERFAULTFD_STATE_RUNNING);
+
+	if (count < sizeof(range))
+		return -EINVAL;
+	if (copy_from_user(&range, buf, sizeof(range)))
+		return -EFAULT;
+	if (range[0] >= range[1])
+		return -ERANGE;
+
+	spin_lock(&ctx->fd_wqh.lock);
+	__add_wait_queue(&ctx->fd_wqh, &wait);
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		/* always take the fd_wqh lock before the fault_wqh lock */
+		if (find_userfault(ctx, NULL, POLLOUT)) {
+			if (!wake_userfault(ctx, range)) {
+				res = sizeof(range);
+				break;
+			}
+		}
+		if (signal_pending(current)) {
+			res = -ERESTARTSYS;
+			break;
+		}
+		if (file->f_flags & O_NONBLOCK) {
+			res = -EAGAIN;
+			break;
+		}
+		spin_unlock(&ctx->fd_wqh.lock);
+		schedule();
+		spin_lock(&ctx->fd_wqh.lock);
+	}
+	__remove_wait_queue(&ctx->fd_wqh, &wait);
+	__set_current_state(TASK_RUNNING);
+	spin_unlock(&ctx->fd_wqh.lock);
+
+	return res;
+}
+
+#ifdef CONFIG_PROC_FS
+static int userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
+{
+	struct userfaultfd_ctx *ctx = f->private_data;
+	int ret;
+	wait_queue_t *wq;
+	struct userfaultfd_wait_queue *uwq;
+	unsigned long pending = 0, total = 0;
+
+	spin_lock(&ctx->fault_wqh.lock);
+	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+		uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+		if (uwq->pending)
+			pending++;
+		total++;
+	}
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	/*
+	 * If more protocols will be added, there will be all shown
+	 * separated by a space. Like this:
+	 *	protocols: 0xaa 0xbb
+	 */
+	ret = seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nprotocols:\t%Lx\n",
+			 pending, total, USERFAULTFD_PROTOCOL);
+
+	return ret;
+}
+#endif
+
+static const struct file_operations userfaultfd_fops = {
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo	= userfaultfd_show_fdinfo,
+#endif
+	.release	= userfaultfd_release,
+	.poll		= userfaultfd_poll,
+	.read		= userfaultfd_read,
+	.write		= userfaultfd_write,
+	.llseek		= noop_llseek,
+};
+
+/**
+ * userfaultfd_file_create - Creates an userfaultfd file pointer.
+ * @flags: Flags for the userfaultfd file.
+ *
+ * This function creates an userfaultfd file pointer, w/out installing
+ * it into the fd table. This is useful when the userfaultfd file is
+ * used during the initialization of data structures that require
+ * extra setup after the userfaultfd creation. So the userfaultfd
+ * creation is split into the file pointer creation phase, and the
+ * file descriptor installation phase.  In this way races with
+ * userspace closing the newly installed file descriptor can be
+ * avoided.  Returns an userfaultfd file pointer, or a proper error
+ * pointer.
+ */
+static struct file *userfaultfd_file_create(int flags)
+{
+	struct file *file;
+	struct mm_slot *mm_slot;
+
+	/* Check the UFFD_* constants for consistency.  */
+	BUILD_BUG_ON(UFFD_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(UFFD_NONBLOCK != O_NONBLOCK);
+
+	file = ERR_PTR(-EINVAL);
+	if (flags & ~UFFD_SHARED_FCNTL_FLAGS)
+		goto out;
+
+	mm_slot = kmalloc(sizeof(*mm_slot), GFP_KERNEL);
+	file = ERR_PTR(-ENOMEM);
+	if (!mm_slot)
+		goto out;
+
+	mutex_lock(&mm_userlandfd_mutex);
+	file = ERR_PTR(-EBUSY);
+	if (get_mm_slot(current->mm))
+		goto out_free_unlock;
+
+	atomic_set(&mm_slot->ctx.refcount, 1);
+	init_waitqueue_head(&mm_slot->ctx.fault_wqh);
+	init_waitqueue_head(&mm_slot->ctx.fd_wqh);
+	mm_slot->ctx.flags = flags;
+	mm_slot->ctx.state = USERFAULTFD_STATE_ASK_PROTOCOL;
+	mm_slot->ctx.released = false;
+
+	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops,
+				  &mm_slot->ctx,
+				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
+	if (IS_ERR(file))
+	out_free_unlock:
+		kfree(mm_slot);
+	else
+		insert_to_mm_userlandfd_hash(current->mm,
+					     mm_slot);
+	mutex_unlock(&mm_userlandfd_mutex);
+out:
+	return file;
+}
+
+SYSCALL_DEFINE1(userfaultfd, int, flags)
+{
+	int fd, error;
+	struct file *file;
+
+	error = get_unused_fd_flags(flags & UFFD_SHARED_FCNTL_FLAGS);
+	if (error < 0)
+		return error;
+	fd = error;
+
+	file = userfaultfd_file_create(flags);
+	if (IS_ERR(file)) {
+		error = PTR_ERR(file);
+		goto err_put_unused_fd;
+	}
+	fd_install(fd, file);
+
+	return fd;
+
+err_put_unused_fd:
+	put_unused_fd(fd);
+
+	return error;
+}
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3d4bb05..c5cd88d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -811,6 +811,7 @@ asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_memfd_create(const char __user *uname_ptr, unsigned int flags);
+asmlinkage long sys_userfaultfd(int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
 asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
diff --git a/include/linux/userfaultfd.h b/include/linux/userfaultfd.h
new file mode 100644
index 0000000..b7caef5
--- /dev/null
+++ b/include/linux/userfaultfd.h
@@ -0,0 +1,42 @@
+/*
+ *  include/linux/userfaultfd.h
+ *
+ *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
+ *  Copyright (C) 2014  Red Hat, Inc.
+ *
+ */
+
+#ifndef _LINUX_USERFAULTFD_H
+#define _LINUX_USERFAULTFD_H
+
+#include <linux/fcntl.h>
+
+/*
+ * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
+ * new flags, since they might collide with O_* ones. We want
+ * to re-use O_* flags that couldn't possibly have a meaning
+ * from userfaultfd, in order to leave a free define-space for
+ * shared O_* flags.
+ */
+#define UFFD_CLOEXEC O_CLOEXEC
+#define UFFD_NONBLOCK O_NONBLOCK
+
+#define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
+#define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
+
+#ifdef CONFIG_USERFAULTFD
+
+int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+		     unsigned int flags);
+
+#else /* CONFIG_USERFAULTFD */
+
+static int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+			    unsigned int flags)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+#endif
+
+#endif /* _LINUX_USERFAULTFD_H */
diff --git a/init/Kconfig b/init/Kconfig
index e84c642..d57127e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1518,6 +1518,17 @@ config EVENTFD
 
 	  If unsure, say Y.
 
+config USERFAULTFD
+	bool "Enable userfaultfd() system call"
+	select ANON_INODES
+	default y
+	depends on MMU
+	help
+	  Enable the userfaultfd() system call that allows to trap and
+	  handle page faults in userland.
+
+	  If unsure, say Y.
+
 config SHMEM
 	bool "Use full shmem filesystem" if EXPERT
 	default y
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2bc7bef..fe6ab0c 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -200,6 +200,7 @@ cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
 cond_syscall(sys_memfd_create);
+cond_syscall(sys_userfaultfd);
 
 /* performance counters: */
 cond_syscall(sys_perf_event_open);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9c66428..10e6408 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/userfaultfd.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -713,7 +714,7 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
-					struct page *page)
+					struct page *page, unsigned int flags)
 {
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
@@ -753,11 +754,15 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 		/* Deliver the page fault to userland */
 		if (vma->vm_flags & VM_USERFAULT) {
+			int ret;
+
 			spin_unlock(ptl);
 			mem_cgroup_cancel_charge(page, memcg);
 			put_page(page);
 			pte_free(mm, pgtable);
-			return VM_FAULT_SIGBUS;
+			ret = handle_userfault(vma, haddr, flags);
+			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			return ret;
 		}
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
@@ -837,16 +842,19 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		ret = 0;
 		set = false;
 		if (pmd_none(*pmd)) {
-			if (vma->vm_flags & VM_USERFAULT)
-				ret = VM_FAULT_SIGBUS;
-			else {
+			if (vma->vm_flags & VM_USERFAULT) {
+				spin_unlock(ptl);
+				ret = handle_userfault(vma, haddr, flags);
+				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			} else {
 				set_huge_zero_page(pgtable, mm, vma,
 						   haddr, pmd,
 						   zero_page);
+				spin_unlock(ptl);
 				set = true;
 			}
-		}
-		spin_unlock(ptl);
+		} else
+			spin_unlock(ptl);
 		if (!set) {
 			pte_free(mm, pgtable);
 			put_huge_zero_page();
@@ -859,7 +867,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
+	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
diff --git a/mm/memory.c b/mm/memory.c
index 16e4c8a..e80772b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/userfaultfd.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2648,7 +2649,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (vma->vm_flags & VM_USERFAULT) {
 			pte_unmap_unlock(page_table, ptl);
-			return VM_FAULT_SIGBUS;
+			return handle_userfault(vma, address, flags);
 		}
 		goto setpte;
 	}
@@ -2682,7 +2683,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(page_table, ptl);
 		mem_cgroup_cancel_charge(page, memcg);
 		page_cache_release(page);
-		return VM_FAULT_SIGBUS;
+		return handle_userfault(vma, address, flags);
 	}
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
