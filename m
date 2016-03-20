Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B81F76B0263
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:50 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id l68so91599682wml.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:42:50 -0700 (PDT)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id l67si9265538wmg.76.2016.03.20.05.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 05:42:46 -0700 (PDT)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rapoport@il.ibm.com>;
	Sun, 20 Mar 2016 12:42:45 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7CDD91B0804B
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:43:13 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2KCgg565701968
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:42 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2KCggbj017352
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:42 -0400
From: Mike Rapoport <rapoport@il.ibm.com>
Subject: [PATCH 5/5] uffd: Add madvise() event for MADV_DONTNEED request
Date: Sun, 20 Mar 2016 14:42:21 +0200
Message-Id: <1458477741-6942-6-git-send-email-rapoport@il.ibm.com>
In-Reply-To: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>, Mike Rapoport <rapoport@il.ibm.com>

From: Pavel Emelyanov <xemul@parallels.com>

If the page is punched out of the address space the uffd reader
should know this and zeromap the respective area in case of
the #PF event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rapoport@il.ibm.com>
---
 fs/userfaultfd.c                 | 26 ++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 12 ++++++++++++
 include/uapi/linux/userfaultfd.h |  9 ++++++++-
 mm/madvise.c                     |  2 ++
 4 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index a7771bd..e65ca84 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -599,6 +599,32 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx,
 	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
+void madvise_userfault_dontneed(struct vm_area_struct *vma,
+				struct vm_area_struct **prev,
+				unsigned long start, unsigned long end)
+{
+	struct userfaultfd_ctx *ctx;
+	struct userfaultfd_wait_queue ewq;
+
+	ctx = vma->vm_userfaultfd_ctx.ctx;
+	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_MADVDONTNEED))
+		return;
+
+	userfaultfd_ctx_get(ctx);
+	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
+	up_read(&vma->vm_mm->mmap_sem);
+
+	msg_init(&ewq.msg);
+
+	ewq.msg.event = UFFD_EVENT_MADVDONTNEED;
+	ewq.msg.arg.madv_dn.start = start;
+	ewq.msg.arg.madv_dn.end = end;
+
+	userfaultfd_event_wait_completion(ctx, &ewq);
+
+	down_read(&vma->vm_mm->mmap_sem);
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 42ea277..7e22a3d 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -62,6 +62,11 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
+extern void madvise_userfault_dontneed(struct vm_area_struct *vma,
+				       struct vm_area_struct **prev,
+				       unsigned long start,
+				       unsigned long end);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -109,6 +114,13 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
 					       unsigned long len)
 {
 }
+
+static inline void madvise_userfault_dontneed(struct vm_area_struct *vma,
+					      struct vm_area_struct **prev,
+					      unsigned long start,
+					      unsigned long end)
+{
+}
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 46bbb6f..cbcb3a5 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -16,7 +16,7 @@
  * After implementing the respective features it will become:
  * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP)
  */
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP|UFFD_FEATURE_EVENT_MADVDONTNEED)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -81,6 +81,11 @@ struct uffd_msg {
 		} remap;
 
 		struct {
+			__u64	start;
+			__u64	end;
+		} madv_dn;
+
+		struct {
 			/* unused reserved fields */
 			__u64	reserved1;
 			__u64	reserved2;
@@ -95,6 +100,7 @@ struct uffd_msg {
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
 #define UFFD_EVENT_REMAP	0x14
+#define UFFD_EVENT_MADVDONTNEED	0x15
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -118,6 +124,7 @@ struct uffdio_api {
 #endif
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
+#define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/madvise.c b/mm/madvise.c
index a011473..7b66d6b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -10,6 +10,7 @@
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/hugetlb.h>
 #include <linux/falloc.h>
 #include <linux/sched.h>
@@ -476,6 +477,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	zap_page_range(vma, start, end - start, NULL);
+	madvise_userfault_dontneed(vma, prev, start, end);
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
