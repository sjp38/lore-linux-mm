Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C09DF6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:35:49 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so51954137pdb.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:35:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id os6si37950415pdb.81.2015.03.18.12.35.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 12:35:48 -0700 (PDT)
Message-ID: <5509D38C.7030009@parallels.com>
Date: Wed, 18 Mar 2015 22:35:40 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] uffd: Introduce fork() notification
References: <5509D342.7000403@parallels.com>
In-Reply-To: <5509D342.7000403@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>
Cc: Sanidhya Kashyap <sanidhya.gatech@gmail.com>

As described in previous e-mail, we need to get informed when
the task, whose mm is monitored with uffd, calls fork().

The fork notification is the new uffd with the same regions
and flags as those on parent. When read()-ing from uffd the
monitor task would receive the new uffd's descriptor number
and will be able to start reading events from the new task.

The fork() of mm with uffd attached doesn't finish until the 
monitor "acks" the message by reading the new uffd descriptor.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c                 | 175 ++++++++++++++++++++++++++++++++++++++-
 include/linux/userfaultfd_k.h    |  12 +++
 include/uapi/linux/userfaultfd.h |   4 +-
 kernel/fork.c                    |   9 +-
 4 files changed, 194 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index bd629b4..265f031 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -12,6 +12,7 @@
  *  mm/ksm.c (mm hashing).
  */
 
+#include <linux/list.h>
 #include <linux/hashtable.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
@@ -37,6 +38,8 @@ struct userfaultfd_ctx {
 	atomic_t refcount;
 	/* waitqueue head for the userfaultfd page faults */
 	wait_queue_head_t fault_wqh;
+	/* waitqueue head for fork-s */
+	wait_queue_head_t fork_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
 	/* userfaultfd syscall flags */
@@ -51,10 +54,21 @@ struct userfaultfd_ctx {
 	struct mm_struct *mm;
 };
 
+struct userfaultfd_fork_ctx {
+	struct userfaultfd_ctx *orig;
+	struct userfaultfd_ctx *new;
+	struct list_head list;
+};
+
 #define UFFD_FEATURE_LONGMSG	0x1
+#define UFFD_FEATURE_FORK	0x2
 
 struct userfaultfd_wait_queue {
-	unsigned long address;
+	union {
+		unsigned long address;
+		struct userfaultfd_ctx *nctx;
+		int fd;
+	};
 	wait_queue_t wq;
 	bool pending;
 	struct userfaultfd_ctx *ctx;
@@ -75,6 +89,7 @@ static struct userfaultfd_ctx *userfaultfd_ctx_alloc(void)
 	if (ctx) {
 		atomic_set(&ctx->refcount, 1);
 		init_waitqueue_head(&ctx->fault_wqh);
+		init_waitqueue_head(&ctx->fork_wqh);
 		init_waitqueue_head(&ctx->fd_wqh);
 		ctx->released = false;
 	}
@@ -270,6 +285,111 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	return VM_FAULT_RETRY;
 }
 
+int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
+{
+	struct userfaultfd_ctx *ctx = NULL, *octx;
+	struct userfaultfd_fork_ctx *fctx;
+
+	octx = vma->vm_userfaultfd_ctx.ctx;
+	if (!octx || !(octx->features & UFFD_FEATURE_FORK)) {
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
+		ctx = userfaultfd_ctx_alloc();
+		if (!ctx) {
+			kfree(fctx);
+			return -ENOMEM;
+		}
+
+		ctx->flags = octx->flags;
+		ctx->state = UFFD_STATE_RUNNING;
+		ctx->features = UFFD_FEATURE_FORK | UFFD_FEATURE_LONGMSG;
+		ctx->mm = vma->vm_mm;
+		atomic_inc(&ctx->mm->mm_count);
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
+	int ret = 0;
+	struct userfaultfd_ctx *ctx = fctx->orig;
+	struct userfaultfd_wait_queue uwq;
+
+	init_waitqueue_entry(&uwq.wq, current);
+	uwq.pending = true;
+	uwq.ctx = ctx;
+	uwq.nctx = fctx->new;
+
+	spin_lock(&ctx->fork_wqh.lock);
+	/*
+	 * After the __add_wait_queue the uwq is visible to userland
+	 * through poll/read().
+	 */
+	__add_wait_queue(&ctx->fork_wqh, &uwq.wq);
+	for (;;) {
+		set_current_state(TASK_KILLABLE);
+		if (!uwq.pending)
+			break;
+		if (ACCESS_ONCE(ctx->released) ||
+				fatal_signal_pending(current)) {
+			ret = -1;
+			break;
+		}
+
+		spin_unlock(&ctx->fork_wqh.lock);
+
+		wake_up_poll(&ctx->fd_wqh, POLLIN);
+		schedule();
+
+		spin_lock(&ctx->fork_wqh.lock);
+	}
+	__remove_wait_queue(&ctx->fork_wqh, &uwq.wq);
+	__set_current_state(TASK_RUNNING);
+	spin_unlock(&ctx->fork_wqh.lock);
+
+	/*
+	 * ctx may go away after this if the userfault pseudo fd is
+	 * already released.
+	 */
+	userfaultfd_ctx_put(ctx);
+
+	return ret;
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
@@ -356,6 +476,12 @@ static inline unsigned int find_userfault(struct userfaultfd_ctx *ctx,
 	return do_find_userfault(&ctx->fault_wqh, uwq);
 }
 
+static inline unsigned int find_userfault_fork(struct userfaultfd_ctx *ctx,
+		struct userfaultfd_wait_queue **uwq)
+{
+	return do_find_userfault(&ctx->fork_wqh, uwq);
+}
+
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -366,12 +492,40 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 	case UFFD_STATE_WAIT_API:
 		return POLLERR;
 	case UFFD_STATE_RUNNING:
-		return find_userfault(ctx, NULL);
+		return find_userfault(ctx, NULL) || find_userfault_fork(ctx, NULL);
 	default:
 		BUG();
 	}
 }
 
+static ssize_t resolve_userfault_fork(struct userfaultfd_ctx *ctx,
+		struct userfaultfd_wait_queue **uwq)
+{
+	struct userfaultfd_ctx *new;
+	int fd;
+	struct file *file;
+
+	if (!find_userfault_fork(ctx, uwq))
+		return 0;
+
+	new = (*uwq)->nctx;
+	fd = get_unused_fd_flags(new->flags & UFFD_SHARED_FCNTL_FLAGS);
+	if (fd < 0)
+		return fd;
+
+	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, new,
+				  O_RDWR | (new->flags & UFFD_SHARED_FCNTL_FLAGS));
+	if (IS_ERR(file)) {
+		put_unused_fd(fd);
+		return PTR_ERR(file);
+	}
+
+	fd_install(fd, file);
+	(*uwq)->fd = fd;
+
+	return 1;
+}
+
 static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 				    __u64 *mtype, __u64 *addr)
 {
@@ -392,6 +546,21 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			ret = 0;
 			break;
 		}
+
+		ret = resolve_userfault_fork(ctx, &uwq);
+		if (ret < 0)
+			break;
+		if (ret > 0) {
+			*mtype = UFFD_FORK;
+			*addr = uwq->fd;
+
+			uwq->pending = false;
+			wake_up(&ctx->fork_wqh);
+
+			ret = 0;
+			break;
+		}
+
 		if (signal_pending(current)) {
 			ret = -ERESTARTSYS;
 			break;
@@ -1015,7 +1184,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 
 	if (uffdio_api.api == UFFD_API_V2) {
-		ctx->features |= UFFD_FEATURE_LONGMSG;
+		ctx->features |= UFFD_FEATURE_FORK | UFFD_FEATURE_LONGMSG;
 		uffdio_api.bits |= UFFD_API_V2_BITS;
 	}
 
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 81f0d11..44827f7 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -75,6 +75,9 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
 }
 
+extern int dup_userfaultfd(struct vm_area_struct *, struct list_head *);
+extern void dup_userfaultfd_complete(struct list_head *);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -107,6 +110,15 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline int dup_userfaultfd(struct vm_area_struct *, struct list_head *)
+{
+	return 0;
+}
+
+static inline void dup_userfaultfd_complete(struct list_head *)
+{
+}
+
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 4e169b8..f6cfea3 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -155,9 +155,11 @@ struct uffd_v2_msg {
 };
 
 #define UFFD_PAGEFAULT	0x1
+#define UFFD_FORK	0x2
 
 #define UFFD_PAGEFAULT_BIT	(1 << (UFFD_PAGEFAULT - 1))
-#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT)
+#define UFFD_FORK_BIT		(1 << (UFFD_FORK - 1))
+#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT | UFFD_FORK_BIT)
 
 /*
  * Lower PAGE_SHIFT bits are used to report those supported
diff --git a/kernel/fork.c b/kernel/fork.c
index cfab6e9..532882d 100644
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
@@ -370,6 +371,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
+	LIST_HEAD(uf);
 
 	uprobe_start_dup_mmap();
 	down_write(&oldmm->mmap_sem);
@@ -421,11 +423,13 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		if (retval)
 			goto fail_nomem_policy;
 		tmp->vm_mm = mm;
+		retval = dup_userfaultfd(tmp, &uf);
+		if (retval)
+			goto fail_nomem_anon_vma_fork;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~(VM_LOCKED|VM_UFFD_MISSING|VM_UFFD_WP);
+		tmp->vm_flags &= ~(VM_LOCKED);
 		tmp->vm_next = tmp->vm_prev = NULL;
-		tmp->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file_inode(file);
@@ -481,6 +485,7 @@ out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
+	dup_userfaultfd_complete(&uf);
 	uprobe_end_dup_mmap();
 	return retval;
 fail_nomem_anon_vma_fork:
-- 
1.8.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
