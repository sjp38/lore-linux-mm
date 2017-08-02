Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6A376B05F6
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g13so23737188qta.0
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g62si24108986qke.408.2017.08.02.09.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:06 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/6] userfaultfd: provide pid in userfault msg
Date: Wed,  2 Aug 2017 18:51:44 +0200
Message-Id: <20170802165145.22628-6-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

From: Alexey Perevalov <a.perevalov@samsung.com>

It could be useful for calculating downtime during
postcopy live migration per vCPU. Side observer or application itself
will be informed about proper task's sleep during userfaultfd
processing.

Process's thread id is being provided when user requeste it
by setting UFFD_FEATURE_THREAD_ID bit into uffdio_api.features.

Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 |  8 ++++++--
 include/uapi/linux/userfaultfd.h | 10 +++++++---
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 03510becb321..ae044650dffa 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -181,7 +181,8 @@ static inline void msg_init(struct uffd_msg *msg)
 
 static inline struct uffd_msg userfault_msg(unsigned long address,
 					    unsigned int flags,
-					    unsigned long reason)
+					    unsigned long reason,
+					    unsigned int features)
 {
 	struct uffd_msg msg;
 	msg_init(&msg);
@@ -205,6 +206,8 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 		 * write protect fault.
 		 */
 		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WP;
+	if (features & UFFD_FEATURE_THREAD_ID)
+		msg.arg.pagefault.ptid = task_pid_vnr(current);
 	return msg;
 }
 
@@ -425,7 +428,8 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
-	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason);
+	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason,
+			ctx->features);
 	uwq.ctx = ctx;
 	uwq.waken = false;
 
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index d39d5db56771..2b24c28d99a7 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -24,7 +24,8 @@
 			   UFFD_FEATURE_EVENT_UNMAP |		\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
 			   UFFD_FEATURE_MISSING_SHMEM |		\
-			   UFFD_FEATURE_SIGBUS)
+			   UFFD_FEATURE_SIGBUS |		\
+			   UFFD_FEATURE_THREAD_ID)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -79,6 +80,7 @@ struct uffd_msg {
 		struct {
 			__u64	flags;
 			__u64	address;
+			__u32   ptid;
 		} pagefault;
 
 		struct {
@@ -158,8 +160,9 @@ struct uffdio_api {
 	 * UFFD_FEATURE_SIGBUS feature means no page-fault
 	 * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
 	 * a SIGBUS signal will be sent to the faulting process.
-	 * The application process can enable this behavior by adding
-	 * it to uffdio_api.features.
+	 *
+	 * UFFD_FEATURE_THREAD_ID pid of the page faulted task_struct will
+	 * be returned, if feature is not requested 0 will be returned.
 	 */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
@@ -169,6 +172,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
 #define UFFD_FEATURE_SIGBUS			(1<<7)
+#define UFFD_FEATURE_THREAD_ID			(1<<8)
 	__u64 features;
 
 	__u64 ioctls;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
