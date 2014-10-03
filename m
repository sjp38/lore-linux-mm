Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id CB9AE6B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:04:07 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id c9so1381444qcz.8
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:04:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n69si13631205qge.21.2014.10.03.11.04.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 11:04:03 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 17/17] userfaultfd: implement USERFAULTFD_RANGE_REGISTER|UNREGISTER
Date: Fri,  3 Oct 2014 19:08:07 +0200
Message-Id: <1412356087-16115-18-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This adds two protocol commands to the userfaultfd protocol.

To register memory regions into userfaultfd you can write 16 bytes as:

	 [ start|0x1, end ]

to unregister write:

	 [ start|0x2, end ]

End is "start+len" (not start+len-1). Same as vma->vm_end.

This also enforces the constraint that start and end must both be page
aligned (so the last two bits become available to implement the
USERFAULTFD_RANGE_REGISTER|UNREGISTER commands).

This way there can be multiple userfaultfd for each process and each
one can register into its own virtual memory ranges.

If an userfaultfd tries to register into a virtual memory range
already registered into a different userfaultfd, -EBUSY will be
returned by the write() syscall.

userfaultfd can register into allocated ranges that don't have
MADV_USERFAULT set, but if MADV_USERFAULT is not set, no userfault
will fire on those.

Only if MADV_USERFAULT is set on the virtual memory range, and the
userfaultfd registered into the same range, the userfaultfd protocol
will engage.

If only MADV_USERFAULT is set and there's no userfaultfd registered on
a memory range, only a SIGBUS will be raised and the page fault will
not engage the userfaultfd protocol.

This also makes the handle_userfault() safe against race conditions
with regard to the mmap_sem by requiring FAULT_FLAG_ALLOW_RETRY to be
set the first time a fault is raised by any thread. In turn to work
reliably, the userfaultd depends on the gup_locked|unlocked patchset
to be applied.

If get_user_pages() is run on virtual memory ranges registered into
the userfaultfd, handle_userfault() will return VM_FAULT_SIGBUS and
gup() will return -EFAULT, because get_user_pages() doesn't allow
handle_userfault() to release the mmap_sem and in turn we cannot
safely engage the userfaultfd protocol. So the remaining
get_user_pages() calls must be restricted to memory ranges that we
know are not tracked through the userfaultfd protocol for the
userfaultfd to be reliable.

The only exception of a get_user_pages() that can safely run into an
userfaultfd triggering a -EFAULT is ptrace. ptrace would otherwise
hang so it's actually ok if it will get a -EFAULT instead of
hanging. But it would be ok also to phase out get_user_pages()
completely and have ptrace hang on the userfault (the hang can be
resolved sending SIGKILL to gdb or whatever process that is calling
ptrace). We could also decide to retain the current -EFAULT behavior
of ptrace using get_user_pages_locked with a NULL locked parameter so
the FAULT_FLAG_ALLOW_RETRY flag will not be set. Either ways would be
safe.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c            | 411 +++++++++++++++++++++++++++-----------------
 include/linux/mm.h          |   2 +-
 include/linux/mm_types.h    |  11 ++
 include/linux/userfaultfd.h |  19 +-
 mm/madvise.c                |   3 +-
 mm/mempolicy.c              |   4 +-
 mm/mlock.c                  |   3 +-
 mm/mmap.c                   |  39 +++--
 mm/mprotect.c               |   3 +-
 9 files changed, 320 insertions(+), 175 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 2667d0d..49bbd3b 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -23,6 +23,7 @@
 #include <linux/anon_inodes.h>
 #include <linux/syscalls.h>
 #include <linux/userfaultfd.h>
+#include <linux/mempolicy.h>
 
 struct userfaultfd_ctx {
 	/* pseudo fd refcounting */
@@ -37,6 +38,8 @@ struct userfaultfd_ctx {
 	unsigned int state;
 	/* released */
 	bool released;
+	/* mm with one ore more vmas attached to this userfaultfd_ctx */
+	struct mm_struct *mm;
 };
 
 struct userfaultfd_wait_queue {
@@ -49,6 +52,10 @@ struct userfaultfd_wait_queue {
 #define USERFAULTFD_PROTOCOL ((__u64) 0xaa)
 #define USERFAULTFD_UNKNOWN_PROTOCOL ((__u64) -1ULL)
 
+#define USERFAULTFD_RANGE_REGISTER ((__u64) 0x1)
+#define USERFAULTFD_RANGE_UNREGISTER ((__u64) 0x2)
+#define USERFAULTFD_RANGE_MASK (~((__u64) 0x3))
+
 enum {
 	USERFAULTFD_STATE_ASK_PROTOCOL,
 	USERFAULTFD_STATE_ACK_PROTOCOL,
@@ -56,43 +63,6 @@ enum {
 	USERFAULTFD_STATE_RUNNING,
 };
 
-/**
- * struct mm_slot - userlandfd information per mm that is being scanned
- * @link: link to the mm_slots hash list
- * @mm: the mm that this information is valid for
- * @ctx: userfaultfd context for this mm
- */
-struct mm_slot {
-	struct hlist_node link;
-	struct mm_struct *mm;
-	struct userfaultfd_ctx ctx;
-	struct rcu_head rcu_head;
-};
-
-#define MM_USERLANDFD_HASH_BITS 10
-static DEFINE_HASHTABLE(mm_userlandfd_hash, MM_USERLANDFD_HASH_BITS);
-
-static DEFINE_MUTEX(mm_userlandfd_mutex);
-
-static struct mm_slot *get_mm_slot(struct mm_struct *mm)
-{
-	struct mm_slot *slot;
-
-	hash_for_each_possible_rcu(mm_userlandfd_hash, slot, link,
-				   (unsigned long)mm)
-		if (slot->mm == mm)
-			return slot;
-
-	return NULL;
-}
-
-static void insert_to_mm_userlandfd_hash(struct mm_struct *mm,
-					 struct mm_slot *mm_slot)
-{
-	mm_slot->mm = mm;
-	hash_add_rcu(mm_userlandfd_hash, &mm_slot->link, (unsigned long)mm);
-}
-
 static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 				     int wake_flags, void *key)
 {
@@ -122,30 +92,10 @@ out:
  *
  * Returns: In case of success, returns not zero.
  */
-static int userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
+static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
 {
-	/*
-	 * If it's already released don't get it. This can race
-	 * against userfaultfd_release, if the race triggers it'll be
-	 * handled safely by the handle_userfault main loop
-	 * (userfaultfd_release will take the mmap_sem for writing to
-	 * flush out all in-flight userfaults). This check is only an
-	 * optimization.
-	 */
-	if (unlikely(ACCESS_ONCE(ctx->released)))
-		return 0;
-	return atomic_inc_not_zero(&ctx->refcount);
-}
-
-static void userfaultfd_free(struct userfaultfd_ctx *ctx)
-{
-	struct mm_slot *mm_slot = container_of(ctx, struct mm_slot, ctx);
-
-	mutex_lock(&mm_userlandfd_mutex);
-	hash_del_rcu(&mm_slot->link);
-	mutex_unlock(&mm_userlandfd_mutex);
-
-	kfree_rcu(mm_slot, rcu_head);
+	if (!atomic_inc_not_zero(&ctx->refcount))
+		BUG();
 }
 
 /**
@@ -158,8 +108,10 @@ static void userfaultfd_free(struct userfaultfd_ctx *ctx)
  */
 static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 {
-	if (atomic_dec_and_test(&ctx->refcount))
-		userfaultfd_free(ctx);
+	if (atomic_dec_and_test(&ctx->refcount)) {
+		mmdrop(ctx->mm);
+		kfree(ctx);
+	}
 }
 
 /*
@@ -181,25 +133,55 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 		     unsigned int flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mm_slot *slot;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
-	int ret;
 
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
-	rcu_read_lock();
-	slot = get_mm_slot(mm);
-	if (!slot) {
-		rcu_read_unlock();
+	ctx = vma->vm_userfaultfd_ctx.ctx;
+	if (!ctx)
 		return VM_FAULT_SIGBUS;
-	}
-	ctx = &slot->ctx;
-	if (!userfaultfd_ctx_get(ctx)) {
-		rcu_read_unlock();
+
+	BUG_ON(ctx->mm != mm);
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
 		return VM_FAULT_SIGBUS;
 	}
-	rcu_read_unlock();
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
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
@@ -214,60 +196,15 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 */
 	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
 	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (fatal_signal_pending(current)) {
-			/*
-			 * If we have to fail because the task is
-			 * killed just retry the fault either by
-			 * returning to userland or through
-			 * VM_FAULT_RETRY if we come from a page fault
-			 * and a fatal signal is pending.
-			 */
-			ret = 0;
-			if (flags & FAULT_FLAG_KILLABLE) {
-				/*
-				 * If FAULT_FLAG_KILLABLE is set we
-				 * and there's a fatal signal pending
-				 * can return VM_FAULT_RETRY
-				 * regardless if
-				 * FAULT_FLAG_ALLOW_RETRY is set or
-				 * not as long as we release the
-				 * mmap_sem. The page fault will
-				 * return stright to userland then to
-				 * handle the fatal signal.
-				 */
-				up_read(&mm->mmap_sem);
-				ret = VM_FAULT_RETRY;
-			}
-			break;
-		}
-		if (!uwq.pending || ACCESS_ONCE(ctx->released)) {
-			ret = 0;
-			if (flags & FAULT_FLAG_ALLOW_RETRY) {
-				ret = VM_FAULT_RETRY;
-				if (!(flags & FAULT_FLAG_RETRY_NOWAIT))
-					up_read(&mm->mmap_sem);
-			}
-			break;
-		}
-		if (((FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT) &
-		     flags) ==
-		    (FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT)) {
-			ret = VM_FAULT_RETRY;
-			/*
-			 * The mmap_sem must not be released if
-			 * FAULT_FLAG_RETRY_NOWAIT is set despite we
-			 * return VM_FAULT_RETRY (FOLL_NOWAIT case).
-			 */
+		set_current_state(TASK_KILLABLE);
+		if (!uwq.pending || ACCESS_ONCE(ctx->released) ||
+		    fatal_signal_pending(current))
 			break;
-		}
 		spin_unlock(&ctx->fault_wqh.lock);
-		up_read(&mm->mmap_sem);
 
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
 
-		down_read(&mm->mmap_sem);
 		spin_lock(&ctx->fault_wqh.lock);
 	}
 	__remove_wait_queue(&ctx->fault_wqh, &uwq.wq);
@@ -276,30 +213,53 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 
 	/*
 	 * ctx may go away after this if the userfault pseudo fd is
-	 * released by another CPU.
+	 * already released.
 	 */
 	userfaultfd_ctx_put(ctx);
 
-	return ret;
+	return VM_FAULT_RETRY;
 }
 
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
-	struct mm_slot *mm_slot = container_of(ctx, struct mm_slot, ctx);
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev;
 	__u64 range[2] = { 0ULL, -1ULL };
 
 	ACCESS_ONCE(ctx->released) = true;
 
 	/*
-	 * Flush page faults out of all CPUs to avoid race conditions
-	 * against ctx->released. All page faults must be retried
-	 * without returning VM_FAULT_SIGBUS if the get_mm_slot and
-	 * userfaultfd_ctx_get both succeeds but ctx->released is set.
+	 * Flush page faults out of all CPUs. NOTE: all page faults
+	 * must be retried without returning VM_FAULT_SIGBUS if
+	 * userfaultfd_ctx_get() succeeds but vma->vma_userfault_ctx
+	 * changes while handle_userfault released the mmap_sem. So
+	 * it's critical that released is set to true (above), before
+	 * taking the mmap_sem for writing.
 	 */
-	down_write(&mm_slot->mm->mmap_sem);
-	up_write(&mm_slot->mm->mmap_sem);
+	down_write(&mm->mmap_sem);
+	prev = NULL;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_userfaultfd_ctx.ctx != ctx)
+			continue;
+		prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
+				 vma->vm_flags, vma->anon_vma,
+				 vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 NULL_VM_USERFAULTFD_CTX);
+		if (prev)
+			vma = prev;
+		else
+			prev = vma;
+		vma->vm_userfaultfd_ctx = NULL_VM_USERFAULTFD_CTX;
+	}
+	up_write(&mm->mmap_sem);
 
+	/*
+	 * After no new page faults can wait on this fautl_wqh, flush
+	 * the last page faults that may have been already waiting on
+	 * the fault_wqh.
+	 */
 	spin_lock(&ctx->fault_wqh.lock);
 	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0, range);
 	spin_unlock(&ctx->fault_wqh.lock);
@@ -454,6 +414,140 @@ static int wake_userfault(struct userfaultfd_ctx *ctx, __u64 *range)
 	return ret;
 }
 
+static ssize_t userfaultfd_range_register(struct userfaultfd_ctx *ctx,
+					  unsigned long start,
+					  unsigned long end)
+{
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev;
+	int ret;
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	if (!vma)
+		return -ENOMEM;
+	if (vma->vm_start >= end)
+		return -EINVAL;
+
+	prev = vma->vm_prev;
+	if (vma->vm_start < start)
+		prev = vma;
+
+	ret = 0;
+	/* we got an overlap so start the splitting */
+	do {
+		if (vma->vm_userfaultfd_ctx.ctx == ctx)
+			goto next;
+		if (vma->vm_userfaultfd_ctx.ctx) {
+			ret = -EBUSY;
+			break;
+		}
+		prev = vma_merge(mm, prev, start, end, vma->vm_flags,
+				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 ((struct vm_userfaultfd_ctx){ ctx }));
+		if (prev) {
+			vma = prev;
+			vma->vm_userfaultfd_ctx.ctx = ctx;
+			goto next;
+		}
+		if (vma->vm_start < start) {
+			ret = split_vma(mm, vma, start, 1);
+			if (ret < 0)
+				break;
+		}
+		if (vma->vm_end > end) {
+			ret = split_vma(mm, vma, end, 0);
+			if (ret < 0)
+				break;
+		}
+		vma->vm_userfaultfd_ctx.ctx = ctx;
+	next:
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (vma && vma->vm_start < end);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
+
+static ssize_t userfaultfd_range_unregister(struct userfaultfd_ctx *ctx,
+					    unsigned long start,
+					    unsigned long end)
+{
+	struct mm_struct *mm = ctx->mm;
+	struct vm_area_struct *vma, *prev;
+	int ret;
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	if (!vma)
+		return -ENOMEM;
+	if (vma->vm_start >= end)
+		return -EINVAL;
+
+	prev = vma->vm_prev;
+	if (vma->vm_start < start)
+		prev = vma;
+
+	ret = 0;
+	/* we got an overlap so start the splitting */
+	do {
+		if (!vma->vm_userfaultfd_ctx.ctx)
+			goto next;
+		if (vma->vm_userfaultfd_ctx.ctx != ctx) {
+			ret = -EBUSY;
+			break;
+		}
+		prev = vma_merge(mm, prev, start, end, vma->vm_flags,
+				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				 vma_policy(vma),
+				 NULL_VM_USERFAULTFD_CTX);
+		if (prev) {
+			vma = prev;
+			vma->vm_userfaultfd_ctx = NULL_VM_USERFAULTFD_CTX;
+			goto next;
+		}
+		if (vma->vm_start < start) {
+			ret = split_vma(mm, vma, start, 1);
+			if (ret < 0)
+				break;
+		}
+		if (vma->vm_end > end) {
+			ret = split_vma(mm, vma, end, 0);
+			if (ret < 0)
+				break;
+		}
+		vma->vm_userfaultfd_ctx.ctx = NULL;
+	next:
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (vma && vma->vm_start < end);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
+
+static ssize_t userfaultfd_handle_range(struct userfaultfd_ctx *ctx,
+					__u64 *range)
+{
+	unsigned long start, end;
+
+	start = range[0] & USERFAULTFD_RANGE_MASK;
+	end = range[1];
+	BUG_ON(end <= start);
+	if (end > TASK_SIZE)
+		return -ENOMEM;
+
+	if (range[0] & USERFAULTFD_RANGE_REGISTER) {
+		BUG_ON(range[0] & USERFAULTFD_RANGE_UNREGISTER);
+		return userfaultfd_range_register(ctx, start, end);
+	} else {
+		BUG_ON(!(range[0] & USERFAULTFD_RANGE_UNREGISTER));
+		return userfaultfd_range_unregister(ctx, start, end);
+	}
+}
+
 static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
 				 size_t count, loff_t *ppos)
 {
@@ -483,9 +577,24 @@ static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
 		return -EINVAL;
 	if (copy_from_user(&range, buf, sizeof(range)))
 		return -EFAULT;
-	if (range[0] >= range[1])
+	/* the range mask requires 2 bits */
+	BUILD_BUG_ON(PAGE_SHIFT < 2);
+	if (range[0] & ~PAGE_MASK & USERFAULTFD_RANGE_MASK)
+		return -EINVAL;
+	if ((range[0] & ~USERFAULTFD_RANGE_MASK) == ~USERFAULTFD_RANGE_MASK)
+		return -EINVAL;
+	if (range[1] & ~PAGE_MASK)
+		return -EINVAL;
+	if ((range[0] & PAGE_MASK) >= (range[1] & PAGE_MASK))
 		return -ERANGE;
 
+	/* handle the register/unregister commands */
+	if (range[0] & ~USERFAULTFD_RANGE_MASK) {
+		ssize_t ret = userfaultfd_handle_range(ctx, range);
+		BUG_ON(ret > 0);
+		return ret < 0 ? ret : sizeof(range);
+	}
+
 	/* always take the fd_wqh lock before the fault_wqh lock */
 	if (find_userfault(ctx, NULL, POLLOUT))
 		if (!wake_userfault(ctx, range))
@@ -552,7 +661,9 @@ static const struct file_operations userfaultfd_fops = {
 static struct file *userfaultfd_file_create(int flags)
 {
 	struct file *file;
-	struct mm_slot *mm_slot;
+	struct userfaultfd_ctx *ctx;
+
+	BUG_ON(!current->mm);
 
 	/* Check the UFFD_* constants for consistency.  */
 	BUILD_BUG_ON(UFFD_CLOEXEC != O_CLOEXEC);
@@ -562,33 +673,25 @@ static struct file *userfaultfd_file_create(int flags)
 	if (flags & ~UFFD_SHARED_FCNTL_FLAGS)
 		goto out;
 
-	mm_slot = kmalloc(sizeof(*mm_slot), GFP_KERNEL);
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	file = ERR_PTR(-ENOMEM);
-	if (!mm_slot)
+	if (!ctx)
 		goto out;
 
-	mutex_lock(&mm_userlandfd_mutex);
-	file = ERR_PTR(-EBUSY);
-	if (get_mm_slot(current->mm))
-		goto out_free_unlock;
-
-	atomic_set(&mm_slot->ctx.refcount, 1);
-	init_waitqueue_head(&mm_slot->ctx.fault_wqh);
-	init_waitqueue_head(&mm_slot->ctx.fd_wqh);
-	mm_slot->ctx.flags = flags;
-	mm_slot->ctx.state = USERFAULTFD_STATE_ASK_PROTOCOL;
-	mm_slot->ctx.released = false;
-
-	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops,
-				  &mm_slot->ctx,
+	atomic_set(&ctx->refcount, 1);
+	init_waitqueue_head(&ctx->fault_wqh);
+	init_waitqueue_head(&ctx->fd_wqh);
+	ctx->flags = flags;
+	ctx->state = USERFAULTFD_STATE_ASK_PROTOCOL;
+	ctx->released = false;
+	ctx->mm = current->mm;
+	/* prevent the mm struct to be freed */
+	atomic_inc(&ctx->mm->mm_count);
+
+	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
 	if (IS_ERR(file))
-	out_free_unlock:
-		kfree(mm_slot);
-	else
-		insert_to_mm_userlandfd_hash(current->mm,
-					     mm_slot);
-	mutex_unlock(&mm_userlandfd_mutex);
+		kfree(ctx);
 out:
 	return file;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 71dbe03..cd60938 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1779,7 +1779,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *);
+	struct mempolicy *, struct vm_userfaultfd_ctx);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c876d1..bb78fa8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -238,6 +238,16 @@ struct vm_region {
 						* this region */
 };
 
+#ifdef CONFIG_USERFAULTFD
+#define NULL_VM_USERFAULTFD_CTX ((struct vm_userfaultfd_ctx) { NULL, })
+struct vm_userfaultfd_ctx {
+	struct userfaultfd_ctx *ctx;
+};
+#else /* CONFIG_USERFAULTFD */
+#define NULL_VM_USERFAULTFD_CTX ((struct vm_userfaultfd_ctx) {})
+struct vm_userfaultfd_ctx {};
+#endif /* CONFIG_USERFAULTFD */
+
 /*
  * This struct defines a memory VMM memory area. There is one of these
  * per VM-area/task.  A VM area is any part of the process virtual memory
@@ -308,6 +318,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 };
 
 struct core_thread {
diff --git a/include/linux/userfaultfd.h b/include/linux/userfaultfd.h
index b7caef5..25f49db 100644
--- a/include/linux/userfaultfd.h
+++ b/include/linux/userfaultfd.h
@@ -29,14 +29,27 @@
 int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 		     unsigned int flags);
 
+static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
+					struct vm_userfaultfd_ctx vm_ctx)
+{
+	return vma->vm_userfaultfd_ctx.ctx == vm_ctx.ctx;
+}
+
 #else /* CONFIG_USERFAULTFD */
 
-static int handle_userfault(struct vm_area_struct *vma, unsigned long address,
-			    unsigned int flags)
+static inline int handle_userfault(struct vm_area_struct *vma,
+				   unsigned long address,
+				   unsigned int flags)
 {
 	return VM_FAULT_SIGBUS;
 }
 
-#endif
+static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
+					struct vm_userfaultfd_ctx vm_ctx)
+{
+	return true;
+}
+
+#endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index 24620c0..4bb9a68 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -117,7 +117,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
-				vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma),
+			  vma->vm_userfaultfd_ctx);
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8f5330d..bf54e9c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -769,8 +769,8 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		pgoff = vma->vm_pgoff +
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
-				  vma->anon_vma, vma->vm_file, pgoff,
-				  new_pol);
+				 vma->anon_vma, vma->vm_file, pgoff,
+				 new_pol, vma->vm_userfaultfd_ctx);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
diff --git a/mm/mlock.c b/mm/mlock.c
index ce84cb0..ccb537e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -566,7 +566,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
-			  vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma),
+			  vma->vm_userfaultfd_ctx);
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mmap.c b/mm/mmap.c
index c0a3637..303f45b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -41,6 +41,7 @@
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/printk.h>
+#include <linux/userfaultfd.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -901,7 +902,8 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+				struct file *file, unsigned long vm_flags,
+				struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
 	/*
 	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
@@ -917,6 +919,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
+	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
+		return 0;
 	return 1;
 }
 
@@ -947,9 +951,11 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  */
 static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+		     struct anon_vma *anon_vma, struct file *file,
+		     pgoff_t vm_pgoff,
+		     struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
@@ -966,9 +972,11 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+		    struct anon_vma *anon_vma, struct file *file,
+		    pgoff_t vm_pgoff,
+		    struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = vma_pages(vma);
@@ -1011,7 +1019,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
-			pgoff_t pgoff, struct mempolicy *policy)
+			pgoff_t pgoff, struct mempolicy *policy,
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1038,14 +1047,17 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (prev && prev->vm_end == addr &&
   			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags,
-						anon_vma, file, pgoff)) {
+					    anon_vma, file, pgoff,
+					    vm_userfaultfd_ctx)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
 		if (next && end == next->vm_start &&
 				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen) &&
+						     anon_vma, file,
+						     pgoff+pglen,
+						     vm_userfaultfd_ctx) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1066,7 +1078,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (next && end == next->vm_start &&
  			mpol_equal(policy, vma_policy(next)) &&
 			can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen)) {
+					     anon_vma, file, pgoff+pglen,
+					     vm_userfaultfd_ctx)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
@@ -1548,7 +1561,8 @@ munmap_back:
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
+			NULL, file, pgoff, NULL, NULL_VM_USERFAULTFD_CTX);
 	if (vma)
 		goto out;
 
@@ -2670,7 +2684,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-					NULL, NULL, pgoff, NULL);
+			NULL, NULL, pgoff, NULL, NULL_VM_USERFAULTFD_CTX);
 	if (vma)
 		goto out;
 
@@ -2829,7 +2843,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			    vma->vm_userfaultfd_ctx);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..2ee5aa7 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -294,7 +294,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			   vma->vm_userfaultfd_ctx);
 	if (*pprev) {
 		vma = *pprev;
 		goto success;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
