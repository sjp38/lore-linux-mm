Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C13A26B0270
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:27 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b123so21189560itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q124si6190527iof.7.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/42] userfaultfd: non-cooperative: Add fork() event
Date: Fri, 16 Dec 2016 15:47:47 +0100
Message-Id: <20161216144821.5183-9-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Pavel Emelyanov <xemul@parallels.com>

When the mm with uffd-ed vmas fork()-s the respective vmas
notify their uffds with the event which contains a descriptor
with new uffd. This new descriptor can then be used to get
events from the child and populate its mm with data. Note,
that there can be different uffd-s controlling different
vmas within one mm, so first we should collect all those
uffds (and ctx-s) in a list and then notify them all one by
one but only once per fork().

The context is created at fork() time but the descriptor, file
struct and anon inode object is created at event read time. So
some trickery is added to the userfaultfd_ctx_read() to handle
the ctx queues' locking vs file creation.

Another thing worth noticing is that the task that fork()-s
waits for the uffd event to get processed WITHOUT the mmap sem.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 146 ++++++++++++++++++++++++++++++++++++++-
 include/linux/userfaultfd_k.h    |  13 ++++
 include/uapi/linux/userfaultfd.h |  15 ++--
 kernel/fork.c                    |  10 ++-
 4 files changed, 168 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index fd89b1c..09e8d5b 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -64,6 +64,12 @@ struct userfaultfd_ctx {
 	struct mm_struct *mm;
 };
 
+struct userfaultfd_fork_ctx {
+	struct userfaultfd_ctx *orig;
+	struct userfaultfd_ctx *new;
+	struct list_head list;
+};
+
 struct userfaultfd_wait_queue {
 	struct uffd_msg msg;
 	wait_queue_t wq;
@@ -432,9 +438,8 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	return ret;
 }
 
-static int __maybe_unused userfaultfd_event_wait_completion(
-		struct userfaultfd_ctx *ctx,
-		struct userfaultfd_wait_queue *ewq)
+static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
+					     struct userfaultfd_wait_queue *ewq)
 {
 	int ret = 0;
 
@@ -485,6 +490,79 @@ static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
 	__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
 }
 
+int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
+{
+	struct userfaultfd_ctx *ctx = NULL, *octx;
+	struct userfaultfd_fork_ctx *fctx;
+
+	octx = vma->vm_userfaultfd_ctx.ctx;
+	if (!octx || !(octx->features & UFFD_FEATURE_EVENT_FORK)) {
+		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
+		return 0;
+	}
+
+	list_for_each_entry(fctx, fcs, list)
+		if (fctx->orig == octx) {
+			ctx = fctx->new;
+			break;
+		}
+
+	if (!ctx) {
+		fctx = kmalloc(sizeof(*fctx), GFP_KERNEL);
+		if (!fctx)
+			return -ENOMEM;
+
+		ctx = kmem_cache_alloc(userfaultfd_ctx_cachep, GFP_KERNEL);
+		if (!ctx) {
+			kfree(fctx);
+			return -ENOMEM;
+		}
+
+		atomic_set(&ctx->refcount, 1);
+		ctx->flags = octx->flags;
+		ctx->state = UFFD_STATE_RUNNING;
+		ctx->features = octx->features;
+		ctx->released = false;
+		ctx->mm = vma->vm_mm;
+		atomic_inc(&ctx->mm->mm_users);
+
+		userfaultfd_ctx_get(octx);
+		fctx->orig = octx;
+		fctx->new = ctx;
+		list_add_tail(&fctx->list, fcs);
+	}
+
+	vma->vm_userfaultfd_ctx.ctx = ctx;
+	return 0;
+}
+
+static int dup_fctx(struct userfaultfd_fork_ctx *fctx)
+{
+	struct userfaultfd_ctx *ctx = fctx->orig;
+	struct userfaultfd_wait_queue ewq;
+
+	msg_init(&ewq.msg);
+
+	ewq.msg.event = UFFD_EVENT_FORK;
+	ewq.msg.arg.reserved.reserved1 = (__u64)fctx->new;
+
+	return userfaultfd_event_wait_completion(ctx, &ewq);
+}
+
+void dup_userfaultfd_complete(struct list_head *fcs)
+{
+	int ret = 0;
+	struct userfaultfd_fork_ctx *fctx, *n;
+
+	list_for_each_entry_safe(fctx, n, fcs, list) {
+		if (!ret)
+			ret = dup_fctx(fctx);
+		list_del(&fctx->list);
+		kfree(fctx);
+	}
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -620,12 +698,49 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 	}
 }
 
+static const struct file_operations userfaultfd_fops;
+
+static int resolve_userfault_fork(struct userfaultfd_ctx *ctx,
+				  struct userfaultfd_ctx *new,
+				  struct uffd_msg *msg)
+{
+	int fd;
+	struct file *file;
+	unsigned int flags = new->flags & UFFD_SHARED_FCNTL_FLAGS;
+
+	fd = get_unused_fd_flags(flags);
+	if (fd < 0)
+		return fd;
+
+	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, new,
+				  O_RDWR | flags);
+	if (IS_ERR(file)) {
+		put_unused_fd(fd);
+		return PTR_ERR(file);
+	}
+
+	fd_install(fd, file);
+	msg->arg.reserved.reserved1 = 0;
+	msg->arg.fork.ufd = fd;
+
+	return 0;
+}
+
 static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 				    struct uffd_msg *msg)
 {
 	ssize_t ret;
 	DECLARE_WAITQUEUE(wait, current);
 	struct userfaultfd_wait_queue *uwq;
+	/*
+	 * Handling fork event requires sleeping operations, so
+	 * we drop the event_wqh lock, then do these ops, then
+	 * lock it back and wake up the waiter. While the lock is
+	 * dropped the ewq may go away so we keep track of it
+	 * carefully.
+	 */
+	LIST_HEAD(fork_event);
+	struct userfaultfd_ctx *fork_nctx = NULL;
 
 	/* always take the fd_wqh lock before the fault_pending_wqh lock */
 	spin_lock(&ctx->fd_wqh.lock);
@@ -683,6 +798,14 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		if (uwq) {
 			*msg = uwq->msg;
 
+			if (uwq->msg.event == UFFD_EVENT_FORK) {
+				fork_nctx = (struct userfaultfd_ctx *)uwq->msg.arg.reserved.reserved1;
+				list_move(&uwq->wq.task_list, &fork_event);
+				spin_unlock(&ctx->event_wqh.lock);
+				ret = 0;
+				break;
+			}
+
 			userfaultfd_event_complete(ctx, uwq);
 			spin_unlock(&ctx->event_wqh.lock);
 			ret = 0;
@@ -706,6 +829,23 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 	__set_current_state(TASK_RUNNING);
 	spin_unlock(&ctx->fd_wqh.lock);
 
+	if (!ret && msg->event == UFFD_EVENT_FORK) {
+		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
+
+		if (!ret) {
+			spin_lock(&ctx->event_wqh.lock);
+			if (!list_empty(&fork_event)) {
+				uwq = list_first_entry(&fork_event,
+						       typeof(*uwq),
+						       wq.task_list);
+				list_del(&uwq->wq.task_list);
+				__add_wait_queue(&ctx->event_wqh, &uwq->wq);
+				userfaultfd_event_complete(ctx, uwq);
+			}
+			spin_unlock(&ctx->event_wqh.lock);
+		}
+	}
+
 	return ret;
 }
 
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 11b92b0..79002bc 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -52,6 +52,9 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
 }
 
+extern int dup_userfaultfd(struct vm_area_struct *, struct list_head *);
+extern void dup_userfaultfd_complete(struct list_head *);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -76,6 +79,16 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline int dup_userfaultfd(struct vm_area_struct *vma,
+				  struct list_head *l)
+{
+	return 0;
+}
+
+static inline void dup_userfaultfd_complete(struct list_head *l)
+{
+}
+
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 94046b8..c8953c8 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -18,12 +18,7 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-/*
- * After implementing the respective features it will become:
- * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP | \
- *			      UFFD_FEATURE_EVENT_FORK)
- */
-#define UFFD_API_FEATURES (0)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -78,6 +73,10 @@ struct uffd_msg {
 		} pagefault;
 
 		struct {
+			__u32	ufd;
+		} fork;
+
+		struct {
 			/* unused reserved fields */
 			__u64	reserved1;
 			__u64	reserved2;
@@ -90,9 +89,7 @@ struct uffd_msg {
  * Start at 0x12 and not at 0 to be more strict against bugs.
  */
 #define UFFD_EVENT_PAGEFAULT	0x12
-#if 0 /* not available yet */
 #define UFFD_EVENT_FORK		0x13
-#endif
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -111,10 +108,8 @@ struct uffdio_api {
 	 * are to be considered implicitly always enabled in all kernels as
 	 * long as the uffdio_api.api requested matches UFFD_API.
 	 */
-#if 0 /* not available yet */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
-#endif
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/kernel/fork.c b/kernel/fork.c
index 869b8cc..7e5c688 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -55,6 +55,7 @@
 #include <linux/rmap.h>
 #include <linux/ksm.h>
 #include <linux/acct.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/freezer.h>
@@ -559,6 +560,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
+	LIST_HEAD(uf);
 
 	uprobe_start_dup_mmap();
 	if (down_write_killable(&oldmm->mmap_sem)) {
@@ -615,12 +617,13 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (retval)
 			goto fail_nomem_policy;
 		tmp->vm_mm = mm;
+		retval = dup_userfaultfd(tmp, &uf);
+		if (retval)
+			goto fail_nomem_anon_vma_fork;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &=
-			~(VM_LOCKED|VM_LOCKONFAULT|VM_UFFD_MISSING|VM_UFFD_WP);
+		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 		tmp->vm_next = tmp->vm_prev = NULL;
-		tmp->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file_inode(file);
@@ -676,6 +679,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
+	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
 	return retval;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
