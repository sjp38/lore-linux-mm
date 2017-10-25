Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 159566B0260
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:24:11 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j58so343106qtj.7
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:24:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y36si2733111qta.196.2017.10.25.09.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 09:24:10 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9PGMnFn102937
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:24:09 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dtvgmdhjr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:24:08 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Oct 2017 17:24:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 3/3] userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
Date: Wed, 25 Oct 2017 19:23:37 +0300
In-Reply-To: <1508948617-22505-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1508948617-22505-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1508948617-22505-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

In non-cooperative case, multi-threaded userfaultfd monitor may encounter a
race between UFFDIO_COPY and the processing of UFFD_EVENT_REMOVE.
Unlike the page faults that suspend the faulting thread until the page
fault is resolved, other events resume exectution of the thread that caused
the event immediately after delivering the notification to the userfaultfd
monitor. The monitor may run UFFDIO_COPY in parallel with the event
processing and this may result in memory corruption.
With UFFD_EVENT_REMOVE_SYNC introduced by this patch, it would be possible
to block the non-cooperative thread until the userfaultfd monitor will
explicitly wake it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c                 | 32 +++++++++++++++++++++++++++++++-
 include/uapi/linux/userfaultfd.h | 11 +++++++++++
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 67cec38473b8..06a6475c1bf5 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -658,6 +658,14 @@ static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
 {
 	struct userfaultfd_wake_key key = { 0 };
 
+	/*
+	 * For synchronous events we don't wake up the thread that
+	 * caused the event. The userfault monitor has to explicitly
+	 * wake it with ioctl(UFFDIO_WAKE_SYNC_EVENT)
+	 */
+	if (ewq->msg.event & UFFD_EVENT_FLAG_SYNC)
+		return;
+
 	key.event = ewq->msg.event;
 	 __wake_up_locked_key(&ctx->event_wqh, TASK_NORMAL, &key);
 }
@@ -778,7 +786,8 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	struct userfaultfd_wait_queue ewq;
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
-	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE))
+	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE ||
+		      ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC))
 		return true;
 
 	userfaultfd_ctx_get(ctx);
@@ -787,6 +796,9 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_REMOVE;
+	if (ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC)
+		ewq.msg.event |= UFFD_EVENT_FLAG_SYNC;
+
 	ewq.msg.arg.remove.start = start;
 	ewq.msg.arg.remove.end = end;
 
@@ -1670,6 +1682,21 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	return ret;
 }
 
+static int userfaultfd_wake_sync_event(struct userfaultfd_ctx *ctx,
+				       unsigned long arg)
+{
+	struct userfaultfd_wake_key key = {
+		.event = arg,
+	};
+
+	spin_lock(&ctx->event_wqh.lock);
+	if (waitqueue_active(&ctx->event_wqh))
+		__wake_up_locked_key(&ctx->event_wqh, TASK_NORMAL, &key);
+	spin_unlock(&ctx->event_wqh.lock);
+
+	return 0;
+}
+
 static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			    unsigned long arg)
 {
@@ -1842,6 +1869,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	case UFFDIO_WAKE:
 		ret = userfaultfd_wake(ctx, arg);
 		break;
+	case UFFDIO_WAKE_SYNC_EVENT:
+		ret = userfaultfd_wake_sync_event(ctx, arg);
+		break;
 	case UFFDIO_COPY:
 		ret = userfaultfd_copy(ctx, arg);
 		break;
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index d6d1f65cb3c3..32b96a048baf 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -21,6 +21,7 @@
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
+			   UFFD_FEATURE_EVENT_REMOVE_SYNC |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
 			   UFFD_FEATURE_MISSING_SHMEM |		\
@@ -51,6 +52,7 @@
 #define _UFFDIO_WAKE			(0x02)
 #define _UFFDIO_COPY			(0x03)
 #define _UFFDIO_ZEROPAGE		(0x04)
+#define _UFFDIO_WAKE_SYNC_EVENT		(0x05)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -67,6 +69,7 @@
 				      struct uffdio_copy)
 #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
 				      struct uffdio_zeropage)
+#define UFFDIO_WAKE_SYNC_EVENT	_IOR(UFFDIO, _UFFDIO_WAKE_SYNC_EVENT, __u32)
 
 /* read() structure */
 struct uffd_msg {
@@ -118,6 +121,13 @@ struct uffd_msg {
 #define UFFD_EVENT_REMOVE	0x15
 #define UFFD_EVENT_UNMAP	0x16
 
+/*
+ * Events that are delivered synchronously. The causing thread is
+ * blocked until the event is handled by the userfault monitor
+ */
+#define UFFD_EVENT_FLAG_SYNC	0x80
+#define UFFD_EVENT_REMOVE_SYNC	(UFFD_EVENT_REMOVE | UFFD_EVENT_FLAG_SYNC)
+
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
 #define UFFD_PAGEFAULT_FLAG_WP		(1<<1)	/* If reason is VM_UFFD_WP */
@@ -175,6 +185,7 @@ struct uffdio_api {
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
