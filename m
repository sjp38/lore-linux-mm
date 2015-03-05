Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9396B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:24:24 -0500 (EST)
Received: by qcvp6 with SMTP id p6so384967qcv.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:24:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j67si6471949qhc.131.2015.03.05.09.19.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:09 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/21] userfaultfd: add new syscall to provide memory externalization
Date: Thu,  5 Mar 2015 18:17:53 +0100
Message-Id: <1425575884-2574-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Once an userfaultfd has been created and certain region of the process
virtual address space have been registered into it, the thread
responsible for doing the memory externalization can manage the page
faults in userland by talking to the kernel using the userfaultfd
protocol.

poll() can be used to know when there are new pending userfaults to be
read (POLLIN).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 977 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 977 insertions(+)
 create mode 100644 fs/userfaultfd.c

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
new file mode 100644
index 0000000..6b31967
--- /dev/null
+++ b/fs/userfaultfd.c
@@ -0,0 +1,977 @@
+/*
+ *  fs/userfaultfd.c
+ *
+ *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
+ *  Copyright (C) 2008-2009 Red Hat, Inc.
+ *  Copyright (C) 2015  Red Hat, Inc.
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
+#include <linux/userfaultfd_k.h>
+#include <linux/mempolicy.h>
+#include <linux/ioctl.h>
+#include <linux/security.h>
+
+enum userfaultfd_state {
+	UFFD_STATE_WAIT_API,
+	UFFD_STATE_RUNNING,
+};
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
+	enum userfaultfd_state state;
+	/* released */
+	bool released;
+	/* mm with one ore more vmas attached to this userfaultfd_ctx */
+	struct mm_struct *mm;
+};
+
+struct userfaultfd_wait_queue {
+	unsigned long address;
+	wait_queue_t wq;
+	bool pending;
+	struct userfaultfd_ctx *ctx;
+};
+
+struct userfaultfd_wake_range {
+	unsigned long start;
+	unsigned long len;
+};
+
+static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
+				     int wake_flags, void *key)
+{
+	struct userfaultfd_wake_range *range = key;
+	int ret;
+	struct userfaultfd_wait_queue *uwq;
+	unsigned long start, len;
+
+	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+	ret = 0;
+	/* don't wake the pending ones to avoid reads to block */
+	if (uwq->pending && !ACCESS_ONCE(uwq->ctx->released))
+		goto out;
+	/* len == 0 means wake all */
+	start = range->start;
+	len = range->len;
+	if (len && (start > uwq->address || start + len <= uwq->address))
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
+static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
+{
+	if (!atomic_inc_not_zero(&ctx->refcount))
+		BUG();
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
+	if (atomic_dec_and_test(&ctx->refcount)) {
+		mmdrop(ctx->mm);
+		kfree(ctx);
+	}
+}
+
+static inline unsigned long userfault_address(unsigned long address,
+					      unsigned int flags,
+					      unsigned long reason)
+{
+	BUILD_BUG_ON(PAGE_SHIFT < UFFD_BITS);
+	address &= PAGE_MASK;
+	if (flags & FAULT_FLAG_WRITE)
+		/*
+		 * Encode "write" fault information in the LSB of the
+		 * address read by userland, without depending on
+		 * FAULT_FLAG_WRITE kernel internal value.
+		 */
+		address |= UFFD_BIT_WRITE;
+	if (reason & VM_UFFD_WP)
+		/*
+		 * Encode "reason" fault information as bit number 1
+		 * in the address read by userland. If bit number 1 is
+		 * clear it means the reason is a VM_FAULT_MISSING
+		 * fault.
+		 */
+		address |= UFFD_BIT_WP;
+	return address;
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
+		     unsigned int flags, unsigned long reason)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct userfaultfd_ctx *ctx;
+	struct userfaultfd_wait_queue uwq;
+
+	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
+	ctx = vma->vm_userfaultfd_ctx.ctx;
+	if (!ctx)
+		return VM_FAULT_SIGBUS;
+
+	BUG_ON(ctx->mm != mm);
+
+	VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
+	VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
+
+	/*
+	 * If it's already released don't get it. This avoids to loop
+	 * in __get_user_pages if userfaultfd_release waits on the
+	 * caller of handle_userfault to release the mmap_sem.
+	 */
+	if (unlikely(ACCESS_ONCE(ctx->released)))
+		return VM_FAULT_SIGBUS;
+
+	/* check that we can return VM_FAULT_RETRY */
+	if (unlikely(!(flags & FAULT_FLAG_ALLOW_RETRY))) {
+		/*
+		 * Validate the invariant that nowait must allow retry
+		 * to be sure not to return SIGBUS erroneously on
+		 * nowait invocations.
+		 */
+		BUG_ON(flags & FAULT_FLAG_RETRY_NOWAIT);
+#ifdef CONFIG_DEBUG_VM
+		if (printk_ratelimit()) {
+			printk(KERN_WARNING
+			       "FAULT_FLAG_ALLOW_RETRY missing %x\n", flags);
+			dump_stack();
+		}
+#endif
+		return VM_FAULT_SIGBUS;
+	}
+
+	/*
+	 * Handle nowait, not much to do other than tell it to retry
+	 * and wait.
+	 */
+	if (flags & FAULT_FLAG_RETRY_NOWAIT)
+		return VM_FAULT_RETRY;
+
+	/* take the reference before dropping the mmap_sem */
+	userfaultfd_ctx_get(ctx);
+
+	/* be gentle and immediately relinquish the mmap_sem */
+	up_read(&mm->mmap_sem);
+
+	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
+	uwq.wq.private = current;
+	uwq.address = userfault_address(address, flags, reason);
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
+		set_current_state(TASK_KILLABLE);
+		if (!uwq.pending || ACCESS_ONCE(ctx->released) ||
+		    fatal_signal_pending(current))
+			break;
+		spin_unlock(&ctx->fault_wqh.lock);
+
+		wake_up_poll(&ctx->fd_wqh, POLLIN);
+		schedule();
+
+		spin_lock(&ctx->fault_wqh.lock);
+	}
+	__remove_wait_queue(&ctx->fault_wqh, &uwq.wq);
+	__set_current_state(TASK_RUNNING);
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	/*
+	 * ctx may go away after this if the userfault pseudo fd is
+	 * already released.
+	 */
+	userfaultfd_ctx_put(ctx);
+
+	return VM_FAULT_RETRY;
+}
+
+static int userfaultfd_release(struct inode *inode, struct file *file)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev;
+	/* len == 0 means wake all */
+	struct userfaultfd_wake_range range = { .len = 0, };
+	unsigned long new_flags;
+
+	ACCESS_ONCE(ctx->released) = true;
+
+	/*
+	 * Flush page faults out of all CPUs. NOTE: all page faults
+	 * must be retried without returning VM_FAULT_SIGBUS if
+	 * userfaultfd_ctx_get() succeeds but vma->vma_userfault_ctx
+	 * changes while handle_userfault released the mmap_sem. So
+	 * it's critical that released is set to true (above), before
+	 * taking the mmap_sem for writing.
+	 */
+	down_write(&mm->mmap_sem);
+	prev = NULL;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		cond_resched();
+		BUG_ON(!!vma->vm_userfaultfd_ctx.ctx ^
+		       !!(vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP)));
+		if (vma->vm_userfaultfd_ctx.ctx != ctx) {
+			prev = vma;
+			continue;
+		}
+		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
+		prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
+				 new_flags, vma->anon_vma,
+				 vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 NULL_VM_UFFD_CTX);
+		if (prev)
+			vma = prev;
+		else
+			prev = vma;
+		vma->vm_flags = new_flags;
+		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+	}
+	up_write(&mm->mmap_sem);
+
+	/*
+	 * After no new page faults can wait on this fault_wqh, flush
+	 * the last page faults that may have been already waiting on
+	 * the fault_wqh.
+	 */
+	spin_lock(&ctx->fault_wqh.lock);
+	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0, &range);
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	wake_up_poll(&ctx->fd_wqh, POLLHUP);
+	userfaultfd_ctx_put(ctx);
+	return 0;
+}
+
+static inline unsigned int find_userfault(struct userfaultfd_ctx *ctx,
+					  struct userfaultfd_wait_queue **uwq)
+{
+	wait_queue_t *wq;
+	struct userfaultfd_wait_queue *_uwq;
+	unsigned int ret = 0;
+
+	spin_lock(&ctx->fault_wqh.lock);
+	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+		_uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+		if (_uwq->pending) {
+			ret = POLLIN;
+			if (uwq)
+				*uwq = _uwq;
+			break;
+		}
+	}
+	spin_unlock(&ctx->fault_wqh.lock);
+
+	return ret;
+}
+
+static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+
+	poll_wait(file, &ctx->fd_wqh, wait);
+
+	switch (ctx->state) {
+	case UFFD_STATE_WAIT_API:
+		return POLLERR;
+	case UFFD_STATE_RUNNING:
+		return find_userfault(ctx, NULL);
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
+	/* always take the fd_wqh lock before the fault_wqh lock */
+	spin_lock(&ctx->fd_wqh.lock);
+	__add_wait_queue(&ctx->fd_wqh, &wait);
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (find_userfault(ctx, &uwq)) {
+			uwq->pending = false;
+			/* careful to always initialize addr if ret == 0 */
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
+	spin_unlock_irq(&ctx->fd_wqh.lock);
+
+	return ret;
+}
+
+static ssize_t userfaultfd_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct userfaultfd_ctx *ctx = file->private_data;
+	ssize_t _ret, ret = 0;
+	/* careful to always initialize addr if ret == 0 */
+	__u64 uninitialized_var(addr);
+	int no_wait = file->f_flags & O_NONBLOCK;
+
+	if (ctx->state == UFFD_STATE_WAIT_API)
+		return -EINVAL;
+	BUG_ON(ctx->state != UFFD_STATE_RUNNING);
+
+	for (;;) {
+		if (count < sizeof(addr))
+			return ret ? ret : -EINVAL;
+		_ret = userfaultfd_ctx_read(ctx, no_wait, &addr);
+		if (_ret < 0)
+			return ret ? ret : _ret;
+		if (put_user(addr, (__u64 __user *) buf))
+			return ret ? ret : -EFAULT;
+		ret += sizeof(addr);
+		buf += sizeof(addr);
+		count -= sizeof(addr);
+		/*
+		 * Allow to read more than one fault at time but only
+		 * block if waiting for the very first one.
+		 */
+		no_wait = O_NONBLOCK;
+	}
+}
+
+static int __wake_userfault(struct userfaultfd_ctx *ctx,
+			    struct userfaultfd_wake_range *range)
+{
+	wait_queue_t *wq;
+	struct userfaultfd_wait_queue *uwq;
+	int ret;
+	unsigned long start, end;
+
+	start = range->start;
+	end = range->start + range->len;
+
+	ret = -ENOENT;
+	spin_lock(&ctx->fault_wqh.lock);
+	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+		uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
+		if (uwq->pending)
+			continue;
+		if (uwq->address >= start && uwq->address < end) {
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
+static __always_inline int wake_userfault(struct userfaultfd_ctx *ctx,
+					  struct userfaultfd_wake_range *range)
+{
+	if (!waitqueue_active(&ctx->fault_wqh))
+		return -ENOENT;
+
+	return __wake_userfault(ctx, range);
+}
+
+static __always_inline int validate_range(struct mm_struct *mm,
+					  __u64 start, __u64 len)
+{
+	__u64 task_size = mm->task_size;
+
+	if (start & ~PAGE_MASK)
+		return -EINVAL;
+	if (len & ~PAGE_MASK)
+		return -EINVAL;
+	if (!len)
+		return -EINVAL;
+	if (start < mmap_min_addr)
+		return -EINVAL;
+	if (start >= task_size)
+		return -EINVAL;
+	if (len > task_size - start)
+		return -EINVAL;
+	return 0;
+}
+
+static int userfaultfd_register(struct userfaultfd_ctx *ctx,
+				unsigned long arg)
+{
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev, *cur;
+	int ret;
+	struct uffdio_register uffdio_register;
+	struct uffdio_register __user *user_uffdio_register;
+	unsigned long vm_flags, new_flags;
+	bool found;
+	unsigned long start, end, vma_end;
+
+	user_uffdio_register = (struct uffdio_register __user *) arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_register, user_uffdio_register,
+			   sizeof(uffdio_register)-sizeof(__u64)))
+		goto out;
+
+	ret = -EINVAL;
+	if (!uffdio_register.mode)
+		goto out;
+	if (uffdio_register.mode & ~(UFFDIO_REGISTER_MODE_MISSING|
+				     UFFDIO_REGISTER_MODE_WP))
+		goto out;
+	vm_flags = 0;
+	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
+		vm_flags |= VM_UFFD_MISSING;
+	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
+		vm_flags |= VM_UFFD_WP;
+		/*
+		 * FIXME: remove the below error constraint by
+		 * implementing the wprotect tracking mode.
+		 */
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = validate_range(mm, uffdio_register.range.start,
+			     uffdio_register.range.len);
+	if (ret)
+		goto out;
+
+	start = uffdio_register.range.start;
+	end = start + uffdio_register.range.len;
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+
+	ret = -ENOMEM;
+	if (!vma)
+		goto out_unlock;
+
+	/* check that there's at least one vma in the range */
+	ret = -EINVAL;
+	if (vma->vm_start >= end)
+		goto out_unlock;
+
+	/*
+	 * Search for not compatible vmas.
+	 *
+	 * FIXME: this shall be relaxed later so that it doesn't fail
+	 * on tmpfs backed vmas (in addition to the current allowance
+	 * on anonymous vmas).
+	 */
+	found = false;
+	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
+		cond_resched();
+
+		BUG_ON(!!cur->vm_userfaultfd_ctx.ctx ^
+		       !!(cur->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP)));
+
+		/* check not compatible vmas */
+		ret = -EINVAL;
+		if (cur->vm_ops)
+			goto out_unlock;
+
+		/*
+		 * Check that this vma isn't already owned by a
+		 * different userfaultfd. We can't allow more than one
+		 * userfaultfd to own a single vma simultaneously or we
+		 * wouldn't know which one to deliver the userfaults to.
+		 */
+		ret = -EBUSY;
+		if (cur->vm_userfaultfd_ctx.ctx &&
+		    cur->vm_userfaultfd_ctx.ctx != ctx)
+			goto out_unlock;
+
+		found = true;
+	}
+	BUG_ON(!found);
+
+	/*
+	 * Now that we scanned all vmas we can already tell userland which
+	 * ioctls methods are guaranteed to succeed on this range.
+	 */
+	ret = -EFAULT;
+	if (put_user(UFFD_API_RANGE_IOCTLS, &user_uffdio_register->ioctls))
+		goto out_unlock;
+
+	if (vma->vm_start < start)
+		prev = vma;
+
+	ret = 0;
+	do {
+		cond_resched();
+
+		BUG_ON(vma->vm_ops);
+		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
+		       vma->vm_userfaultfd_ctx.ctx != ctx);
+
+		/*
+		 * Nothing to do: this vma is already registered into this
+		 * userfaultfd and with the right tracking mode too.
+		 */
+		if (vma->vm_userfaultfd_ctx.ctx == ctx &&
+		    (vma->vm_flags & vm_flags) == vm_flags)
+			goto skip;
+
+		if (vma->vm_start > start)
+			start = vma->vm_start;
+		vma_end = min(end, vma->vm_end);
+
+		new_flags = (vma->vm_flags & ~vm_flags) | vm_flags;
+		prev = vma_merge(mm, prev, start, vma_end, new_flags,
+				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 ((struct vm_userfaultfd_ctx){ ctx }));
+		if (prev) {
+			vma = prev;
+			goto next;
+		}
+		if (vma->vm_start < start) {
+			ret = split_vma(mm, vma, start, 1);
+			if (ret)
+				break;
+		}
+		if (vma->vm_end > end) {
+			ret = split_vma(mm, vma, end, 0);
+			if (ret)
+				break;
+		}
+	next:
+		/*
+		 * In the vma_merge() successful mprotect-like case 8:
+		 * the next vma was merged into the current one and
+		 * the current one has not been updated yet.
+		 */
+		vma->vm_flags = new_flags;
+		vma->vm_userfaultfd_ctx.ctx = ctx;
+
+	skip:
+		prev = vma;
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (vma && vma->vm_start < end);
+out_unlock:
+	up_write(&mm->mmap_sem);
+out:
+	return ret;
+}
+
+static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
+				  unsigned long arg)
+{
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev, *cur;
+	int ret;
+	struct uffdio_range uffdio_unregister;
+	unsigned long new_flags;
+	bool found;
+	unsigned long start, end, vma_end;
+	const void __user *buf = (void __user *)arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
+		goto out;
+
+	ret = validate_range(mm, uffdio_unregister.start,
+			     uffdio_unregister.len);
+	if (ret)
+		goto out;
+
+	start = uffdio_unregister.start;
+	end = start + uffdio_unregister.len;
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+
+	ret = -ENOMEM;
+	if (!vma)
+		goto out_unlock;
+
+	/* check that there's at least one vma in the range */
+	ret = -EINVAL;
+	if (vma->vm_start >= end)
+		goto out_unlock;
+
+	/*
+	 * Search for not compatible vmas.
+	 *
+	 * FIXME: this shall be relaxed later so that it doesn't fail
+	 * on tmpfs backed vmas (in addition to the current allowance
+	 * on anonymous vmas).
+	 */
+	found = false;
+	ret = -EINVAL;
+	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
+		cond_resched();
+
+		BUG_ON(!!cur->vm_userfaultfd_ctx.ctx ^
+		       !!(cur->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP)));
+
+		/*
+		 * Check not compatible vmas, not strictly required
+		 * here as not compatible vmas cannot have an
+		 * userfaultfd_ctx registered on them, but this
+		 * provides for more strict behavior to notice
+		 * unregistration errors.
+		 */
+		if (cur->vm_ops)
+			goto out_unlock;
+
+		found = true;
+	}
+	BUG_ON(!found);
+
+	if (vma->vm_start < start)
+		prev = vma;
+
+	ret = 0;
+	do {
+		cond_resched();
+
+		BUG_ON(vma->vm_ops);
+
+		/*
+		 * Nothing to do: this vma is already registered into this
+		 * userfaultfd and with the right tracking mode too.
+		 */
+		if (!vma->vm_userfaultfd_ctx.ctx)
+			goto skip;
+
+		if (vma->vm_start > start)
+			start = vma->vm_start;
+		vma_end = min(end, vma->vm_end);
+
+		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
+		prev = vma_merge(mm, prev, start, vma_end, new_flags,
+				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 NULL_VM_UFFD_CTX);
+		if (prev) {
+			vma = prev;
+			goto next;
+		}
+		if (vma->vm_start < start) {
+			ret = split_vma(mm, vma, start, 1);
+			if (ret)
+				break;
+		}
+		if (vma->vm_end > end) {
+			ret = split_vma(mm, vma, end, 0);
+			if (ret)
+				break;
+		}
+	next:
+		/*
+		 * In the vma_merge() successful mprotect-like case 8:
+		 * the next vma was merged into the current one and
+		 * the current one has not been updated yet.
+		 */
+		vma->vm_flags = new_flags;
+		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+
+	skip:
+		prev = vma;
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (vma && vma->vm_start < end);
+out_unlock:
+	up_write(&mm->mmap_sem);
+out:
+	return ret;
+}
+
+/*
+ * This is mostly needed to re-wakeup those userfaults that were still
+ * pending when userland wake them up the first time. We don't wake
+ * the pending one to avoid blocking reads to block, or non blocking
+ * read to return -EAGAIN, if used with POLLIN, to avoid userland
+ * doubts on why POLLIN wasn't reliable.
+ */
+static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
+			    unsigned long arg)
+{
+	int ret;
+	struct uffdio_range uffdio_wake;
+	struct userfaultfd_wake_range range;
+	const void __user *buf = (void __user *)arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
+		goto out;
+
+	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
+	if (ret)
+		goto out;
+
+	range.start = uffdio_wake.start;
+	range.len = uffdio_wake.len;
+
+	/*
+	 * len == 0 means wake all and we don't want to wake all here,
+	 * so check it again to be sure.
+	 */
+	VM_BUG_ON(!range.len);
+
+	ret = wake_userfault(ctx, &range);
+
+out:
+	return ret;
+}
+
+/*
+ * userland asks for a certain API version and we return which bits
+ * and ioctl commands are implemented in this kernel for such API
+ * version or -EINVAL if unknown.
+ */
+static int userfaultfd_api(struct userfaultfd_ctx *ctx,
+			   unsigned long arg)
+{
+	struct uffdio_api uffdio_api;
+	void __user *buf = (void __user *)arg;
+	int ret;
+
+	ret = -EINVAL;
+	if (ctx->state != UFFD_STATE_WAIT_API)
+		goto out;
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_api, buf, sizeof(__u64)))
+		goto out;
+	if (uffdio_api.api != UFFD_API) {
+		/* careful not to leak info, we only read the first 8 bytes */
+		memset(&uffdio_api, 0, sizeof(uffdio_api));
+		if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
+			goto out;
+		ret = -EINVAL;
+		goto out;
+	}
+	/* careful not to leak info, we only read the first 8 bytes */
+	uffdio_api.bits = UFFD_API_BITS;
+	uffdio_api.ioctls = UFFD_API_IOCTLS;
+	ret = -EFAULT;
+	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
+		goto out;
+	ctx->state = UFFD_STATE_RUNNING;
+	ret = 0;
+out:
+	return ret;
+}
+
+static long userfaultfd_ioctl(struct file *file, unsigned cmd,
+			      unsigned long arg)
+{
+	int ret = -EINVAL;
+	struct userfaultfd_ctx *ctx = file->private_data;
+
+	switch(cmd) {
+	case UFFDIO_API:
+		ret = userfaultfd_api(ctx, arg);
+		break;
+	case UFFDIO_REGISTER:
+		ret = userfaultfd_register(ctx, arg);
+		break;
+	case UFFDIO_UNREGISTER:
+		ret = userfaultfd_unregister(ctx, arg);
+		break;
+	case UFFDIO_WAKE:
+		ret = userfaultfd_wake(ctx, arg);
+		break;
+	}
+	return ret;
+}
+
+#ifdef CONFIG_PROC_FS
+static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
+{
+	struct userfaultfd_ctx *ctx = f->private_data;
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
+	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
+		   pending, total, UFFD_API, UFFD_API_BITS,
+		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
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
+	.unlocked_ioctl = userfaultfd_ioctl,
+	.compat_ioctl	= userfaultfd_ioctl,
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
+	struct userfaultfd_ctx *ctx;
+
+	BUG_ON(!current->mm);
+
+	/* Check the UFFD_* constants for consistency.  */
+	BUILD_BUG_ON(UFFD_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(UFFD_NONBLOCK != O_NONBLOCK);
+
+	file = ERR_PTR(-EINVAL);
+	if (flags & ~UFFD_SHARED_FCNTL_FLAGS)
+		goto out;
+
+	file = ERR_PTR(-ENOMEM);
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		goto out;
+
+	atomic_set(&ctx->refcount, 1);
+	init_waitqueue_head(&ctx->fault_wqh);
+	init_waitqueue_head(&ctx->fd_wqh);
+	ctx->flags = flags;
+	ctx->state = UFFD_STATE_WAIT_API;
+	ctx->released = false;
+	ctx->mm = current->mm;
+	/* prevent the mm struct to be freed */
+	atomic_inc(&ctx->mm->mm_count);
+
+	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
+				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
+	if (IS_ERR(file))
+		kfree(ctx);
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
