Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A80A46B02AE
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:11 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y205so16169364qkb.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v7si1904469qkc.319.2016.11.02.12.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/33] userfaultfd: non-cooperative: Add madvise() event for MADV_DONTNEED request
Date: Wed,  2 Nov 2016 20:33:44 +0100
Message-Id: <1478115245-32090-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Pavel Emelyanov <xemul@parallels.com>

If the page is punched out of the address space the uffd reader
should know this and zeromap the respective area in case of
the #PF event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 26 ++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 12 ++++++++++++
 include/uapi/linux/userfaultfd.h | 10 +++++++++-
 mm/madvise.c                     |  2 ++
 4 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 2fcbd6b..9357dcf 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -598,6 +598,32 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx,
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
index bfab4ef..efb06d7 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -61,6 +61,11 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
+extern void madvise_userfault_dontneed(struct vm_area_struct *vma,
+				       struct vm_area_struct **prev,
+				       unsigned long start,
+				       unsigned long end);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -106,6 +111,13 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
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
index 79a85e5..2bbf323 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -19,7 +19,8 @@
  */
 #define UFFD_API ((__u64)0xAA)
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |	    \
-			   UFFD_FEATURE_EVENT_REMAP)
+			   UFFD_FEATURE_EVENT_REMAP |	    \
+			   UFFD_FEATURE_EVENT_MADVDONTNEED)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -84,6 +85,11 @@ struct uffd_msg {
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
@@ -98,6 +104,7 @@ struct uffd_msg {
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
 #define UFFD_EVENT_REMAP	0x14
+#define UFFD_EVENT_MADVDONTNEED	0x15
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -119,6 +126,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
+#define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/madvise.c b/mm/madvise.c
index 93fb63e..7168bc6 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
