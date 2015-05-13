Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 718766B0070
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:53:49 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so54004991pdb.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:53:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pg3si27488836pdb.124.2015.05.13.07.53.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 07:53:48 -0700 (PDT)
Message-ID: <55536575.8090505@parallels.com>
Date: Wed, 13 May 2015 17:53:41 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] uffd: Add madvise() event for MADV_DONTNEED request
References: <5553651B.1020909@parallels.com>
In-Reply-To: <5553651B.1020909@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

If the page is punched out of the address space the uffd reader
should know this and zeromap the respective area in case of
the #PF event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c                 | 26 ++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 10 ++++++++++
 include/uapi/linux/userfaultfd.h |  9 ++++++++-
 mm/madvise.c                     |  2 ++
 4 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 697e636..6e80a02 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -546,6 +546,32 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx, unsigned long
 	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
+void madvise_userfault_dontneed(struct vm_area_struct *vma,
+		struct vm_area_struct **prev,
+		unsigned long start, unsigned long end)
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
index 0ed5dce..2f72069 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -82,6 +82,10 @@ extern void mremap_userfaultfd_prep(struct vm_area_struct *, struct vm_userfault
 extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx, unsigned long from,
 		unsigned long to, unsigned long len);
 
+extern void madvise_userfault_dontneed(struct vm_area_struct *vma,
+		struct vm_area_struct **prev, unsigned long start,
+		unsigned long end);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -131,6 +135,12 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
 		unsigned long from, unsigned long to, unsigned long len)
 {
 }
+
+static inline void madvise_userfault_dontneed(struct vm_area_struct *vma,
+		struct vm_area_struct **prev, unsigned long start,
+		unsigned long end)
+{
+}
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 59a141c..d0d1ef1 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -14,7 +14,7 @@
  * After implementing the respective features it will become:
  * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP)
  */
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP|UFFD_FEATURE_EVENT_MADVDONTNEED)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -79,6 +79,11 @@ struct uffd_msg {
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
@@ -93,6 +98,7 @@ struct uffd_msg {
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
 #define UFFD_EVENT_REMAP	0x14
+#define UFFD_EVENT_MADVDONTNEED	0x15
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -116,6 +122,7 @@ struct uffdio_api {
 #endif
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
+#define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/madvise.c b/mm/madvise.c
index 10f62b7..3ea20e2 100644
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
@@ -283,6 +284,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	zap_page_range(vma, start, end - start, NULL);
+	madvise_userfault_dontneed(vma, prev, start, end);
 	return 0;
 }
 
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
