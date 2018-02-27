Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED3146B000A
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:15 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id s82so11733342qke.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 00:20:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x128si9841925qkc.315.2018.02.27.00.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 00:20:14 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1R8JOkC064819
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:13 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gd2k8tnvh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:09 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Feb 2018 08:20:06 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/3] userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
Date: Tue, 27 Feb 2018 10:19:52 +0200
In-Reply-To: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1519719592-22668-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

In non-cooperative case, userfaultfd monitor may encounter a race between
UFFDIO_COPY or UFFDIO_UNREGISTER and the processing of UFFD_EVENT_REMOVE.

Unlike the page faults that suspend the faulting thread until the page
fault is resolved, other events resume execution of the thread that caused
the event immediately after delivering the notification to the userfaultfd
monitor. The monitor may run UFFDIO_COPY in parallel with the event
processing and this may result in memory corruption.

Another race condition is caused if the faulting thread consequently calls
a system call causing UFFD_EVENT_REMOVE and munmap(). In this case, uffd
monitor will try to unregister the removed range as the response for
UFFD_EVENT_REMOVE, but the VMA linked to the uffd context might already be
gone because of munmap().

With UFFD_EVENT_REMOVE_SYNC introduced by this patch, it would be possible
to block the non-cooperative thread until the userfaultfd monitor will
explicitly wake it and thus allow uffd monitor proper processing of
UFFD_EVENT_REMOVE.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c                 | 65 ++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/userfaultfd.h | 14 +++++++++
 2 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d9f74b389706..af813b3a3397 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -50,6 +50,8 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fd_wqh;
 	/* waitqueue head for events */
 	wait_queue_head_t event_wqh;
+	/* waitqueue head for sync events */
+	wait_queue_head_t event_sync_wqh;
 	/* a refile sequence protected by fault_pending_wqh lock */
 	struct seqcount refile_seq;
 	/* pseudo fd refcounting */
@@ -116,6 +118,17 @@ static bool userfaultfd_should_wake(struct userfaultfd_wait_queue *uwq,
 			return false;
 	}
 
+	if (key->event == UFFD_EVENT_REMOVE_SYNC) {
+		unsigned long start, end;
+
+		start = key->arg.range.start;
+		end = start + key->arg.range.len;
+
+		if (start != uwq->msg.arg.remove.start ||
+		    end != uwq->msg.arg.remove.end)
+			return false;
+	}
+
 	return true;
 }
 
@@ -191,6 +204,8 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->event_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->event_wqh));
+		VM_BUG_ON(spin_is_locked(&ctx->event_sync_wqh.lock));
+		VM_BUG_ON(waitqueue_active(&ctx->event_sync_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
 		mmdrop(ctx->mm);
@@ -676,7 +691,19 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
 				       struct userfaultfd_wait_queue *ewq)
 {
-	struct userfaultfd_wake_key key = { 0 };
+	struct userfaultfd_wake_key key;
+
+	/*
+	 * For synchronous events we don't wake up the thread that
+	 * caused the event, but rather refile it onto
+	 * event_sync_wqh. The userfault monitor has to explicitly
+	 * wake it with ioctl(UFFDIO_WAKE_SYNC_EVENT)
+	 */
+	if (ewq->msg.event & UFFD_EVENT_FLAG_SYNC) {
+		list_del(&ewq->wq.entry);
+		__add_wait_queue(&ctx->event_sync_wqh, &ewq->wq);
+		return;
+	}
 
 	key.event = ewq->msg.event;
 	 __wake_up_locked_key(&ctx->event_wqh, TASK_NORMAL, &key);
@@ -798,7 +825,8 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	struct userfaultfd_wait_queue ewq;
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
-	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE))
+	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE ||
+		      ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC))
 		return true;
 
 	userfaultfd_ctx_get(ctx);
@@ -807,6 +835,9 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_REMOVE;
+	if (ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC)
+		ewq.msg.event |= UFFD_EVENT_FLAG_SYNC;
+
 	ewq.msg.arg.remove.start = start;
 	ewq.msg.arg.remove.end = end;
 
@@ -935,6 +966,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 
 	/* Flush pending events that may still wait on event_wqh */
 	__wake_up(&ctx->event_wqh, TASK_NORMAL, 0, &key);
+	__wake_up(&ctx->event_sync_wqh, TASK_NORMAL, 0, &key);
 
 	wake_up_poll(&ctx->fd_wqh, EPOLLHUP);
 	userfaultfd_ctx_put(ctx);
@@ -1677,6 +1709,31 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	return ret;
 }
 
+static int userfaultfd_wake_sync_event(struct userfaultfd_ctx *ctx,
+				       unsigned long arg)
+{
+	struct uffd_msg uffd_msg;
+	struct userfaultfd_wake_key key;
+	const void __user *buf = (void __user *)arg;
+
+	if (copy_from_user(&uffd_msg, buf, sizeof(uffd_msg)))
+		return -EFAULT;
+
+	if (uffd_msg.event != UFFD_EVENT_REMOVE_SYNC)
+		return -EINVAL;
+
+	key.event = uffd_msg.event;
+	key.arg.range.start = uffd_msg.arg.remove.start;
+	key.arg.range.len = uffd_msg.arg.remove.end - uffd_msg.arg.remove.start;
+
+	spin_lock(&ctx->event_wqh.lock);
+	if (waitqueue_active(&ctx->event_sync_wqh))
+		__wake_up_locked_key(&ctx->event_sync_wqh, TASK_NORMAL, &key);
+	spin_unlock(&ctx->event_wqh.lock);
+
+	return 0;
+}
+
 static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			    unsigned long arg)
 {
@@ -1849,6 +1906,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	case UFFDIO_WAKE:
 		ret = userfaultfd_wake(ctx, arg);
 		break;
+	case UFFDIO_WAKE_SYNC_EVENT:
+		ret = userfaultfd_wake_sync_event(ctx, arg);
+		break;
 	case UFFDIO_COPY:
 		ret = userfaultfd_copy(ctx, arg);
 		break;
@@ -1909,6 +1969,7 @@ static void init_once_userfaultfd_ctx(void *mem)
 	init_waitqueue_head(&ctx->fault_pending_wqh);
 	init_waitqueue_head(&ctx->fault_wqh);
 	init_waitqueue_head(&ctx->event_wqh);
+	init_waitqueue_head(&ctx->event_sync_wqh);
 	init_waitqueue_head(&ctx->fd_wqh);
 	seqcount_init(&ctx->refile_seq);
 }
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 48f1a7c2f1f0..81e3e2e2eded 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -22,6 +22,7 @@
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
+			   UFFD_FEATURE_EVENT_REMOVE_SYNC |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
 			   UFFD_FEATURE_MISSING_SHMEM |		\
@@ -52,6 +53,7 @@
 #define _UFFDIO_WAKE			(0x02)
 #define _UFFDIO_COPY			(0x03)
 #define _UFFDIO_ZEROPAGE		(0x04)
+#define _UFFDIO_WAKE_SYNC_EVENT		(0x05)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -68,6 +70,8 @@
 				      struct uffdio_copy)
 #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
 				      struct uffdio_zeropage)
+#define UFFDIO_WAKE_SYNC_EVENT	_IOR(UFFDIO, _UFFDIO_WAKE_SYNC_EVENT, \
+				     struct uffd_msg)
 
 /* read() structure */
 struct uffd_msg {
@@ -119,6 +123,15 @@ struct uffd_msg {
 #define UFFD_EVENT_REMOVE	0x15
 #define UFFD_EVENT_UNMAP	0x16
 
+/*
+ * Events that are delivered synchronously. The causing thread is
+ * blocked until the event is handled by the userfault monitor. The
+ * monitor is responsible to explictly wake up the thread after
+ * processing the event.
+ */
+#define UFFD_EVENT_FLAG_SYNC	0x80
+#define UFFD_EVENT_REMOVE_SYNC	(UFFD_EVENT_REMOVE | UFFD_EVENT_FLAG_SYNC)
+
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
 #define UFFD_PAGEFAULT_FLAG_WP		(1<<1)	/* If reason is VM_UFFD_WP */
@@ -176,6 +189,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
 #define UFFD_FEATURE_SIGBUS			(1<<7)
 #define UFFD_FEATURE_THREAD_ID			(1<<8)
+#define UFFD_FEATURE_EVENT_REMOVE_SYNC		(1<<9)
 	__u64 features;
 
 	__u64 ioctls;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
