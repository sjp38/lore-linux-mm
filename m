Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 374576B03AE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so122241823pff.13
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:36:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k196si13126099pga.50.2017.05.16.03.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:36:23 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GASxu2102282
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:22 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afwsj68yw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:22 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:36:19 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 5/5] userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
Date: Tue, 16 May 2017 13:36:02 +0300
In-Reply-To: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1494930962-3318-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
 fs/userfaultfd.c                 | 29 ++++++++++++++++++++++++++++-
 include/uapi/linux/userfaultfd.h | 11 +++++++++++
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 8868229..1167d0e 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -609,6 +609,14 @@ static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
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
 	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &key);
 }
@@ -729,7 +737,8 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	struct userfaultfd_wait_queue ewq;
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
-	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE))
+	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE ||
+		      ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC))
 		return true;
 
 	userfaultfd_ctx_get(ctx);
@@ -738,6 +747,9 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_REMOVE;
+	if (ctx->features & UFFD_FEATURE_EVENT_REMOVE_SYNC)
+		ewq.msg.event |= UFFD_EVENT_FLAG_SYNC;
+
 	ewq.msg.arg.remove.start = start;
 	ewq.msg.arg.remove.end = end;
 
@@ -1564,6 +1576,18 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	return ret;
 }
 
+static int userfaultfd_wake_sync_event(struct userfaultfd_ctx *ctx,
+				       unsigned long arg)
+{
+	struct userfaultfd_wake_key key = {
+		.event = arg,
+	};
+
+	wake_userfault(ctx, &key);
+
+	return 0;
+}
+
 static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			    unsigned long arg)
 {
@@ -1734,6 +1758,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
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
index 3b05953..b1b15e4 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -21,6 +21,7 @@
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
+			   UFFD_FEATURE_EVENT_REMOVE_SYNC |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
 			   UFFD_FEATURE_MISSING_SHMEM)
@@ -49,6 +50,7 @@
 #define _UFFDIO_WAKE			(0x02)
 #define _UFFDIO_COPY			(0x03)
 #define _UFFDIO_ZEROPAGE		(0x04)
+#define _UFFDIO_WAKE_SYNC_EVENT		(0x05)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -65,6 +67,7 @@
 				      struct uffdio_copy)
 #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
 				      struct uffdio_zeropage)
+#define UFFDIO_WAKE_SYNC_EVENT	_IOR(UFFDIO, _UFFDIO_WAKE_SYNC_EVENT, __u32)
 
 /* read() structure */
 struct uffd_msg {
@@ -113,6 +116,13 @@ struct uffd_msg {
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
@@ -161,6 +171,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
+#define UFFD_FEATURE_EVENT_REMOVE_SYNC		(1<<7)
 	__u64 features;
 
 	__u64 ioctls;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
