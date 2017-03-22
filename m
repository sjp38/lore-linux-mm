Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 187EC6B0337
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 14:29:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r89so45048575pfi.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 11:29:25 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id s19si1941414pfg.28.2017.03.22.11.29.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 11:29:24 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ON8003SWBCWBC10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Mar 2017 18:29:20 +0000 (GMT)
From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: [PATCH v2] userfaultfd: provide pid in userfault msg
Date: Wed, 22 Mar 2017 21:29:06 +0300
Message-id: <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
In-reply-to: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com>
References: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170322182918eucas1p204ef2f7aadb0ac41d11f15ef434c74c4@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr . David Alan Gilbert" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com, a.perevalov@samsung.com

It could be useful for calculating downtime during
postcopy live migration per vCPU. Side observer or application itself
will be informed about proper task's sleep during userfaultfd
processing.

Process's thread id is being provided when user requeste it
by setting UFFD_FEATURE_THREAD_ID bit into uffdio_api.features.

Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
---
 fs/userfaultfd.c                 | 8 ++++++--
 include/uapi/linux/userfaultfd.h | 8 +++++++-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 24fd7e0..14c30d4 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -180,7 +180,8 @@ static inline void msg_init(struct uffd_msg *msg)
 
 static inline struct uffd_msg userfault_msg(unsigned long address,
 					    unsigned int flags,
-					    unsigned long reason)
+					    unsigned long reason,
+					    unsigned int features)
 {
 	struct uffd_msg msg;
 	msg_init(&msg);
@@ -204,6 +205,8 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 		 * write protect fault.
 		 */
 		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WP;
+	if (features & UFFD_FEATURE_THREAD_ID)
+		msg.arg.pagefault.ptid = task_pid_vnr(current);
 	return msg;
 }
 
@@ -408,7 +411,8 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
-	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason);
+	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason,
+			ctx->features);
 	uwq.ctx = ctx;
 	uwq.waken = false;
 
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 819e235..84e4a1e 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -24,7 +24,8 @@
 			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
-			   UFFD_FEATURE_MISSING_SHMEM)
+			   UFFD_FEATURE_MISSING_SHMEM |		\
+			   UFFD_FEATURE_THREAD_ID)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -83,6 +84,7 @@ struct uffd_msg {
 		struct {
 			__u64	flags;
 			__u64	address;
+			pid_t   ptid;
 		} pagefault;
 
 		struct {
@@ -158,6 +160,9 @@ struct uffdio_api {
 	 * UFFD_FEATURE_MISSING_SHMEM works the same as
 	 * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
 	 * (i.e. tmpfs and other shmem based APIs).
+	 *
+	 * UFFD_FEATURE_THREAD_ID pid of the page faulted task_struct will
+	 * be returned, if feature is not requested 0 will be returned.
 	 */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
@@ -166,6 +171,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
+#define UFFD_FEATURE_THREAD_ID			(1<<7)
 	__u64 features;
 
 	__u64 ioctls;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
