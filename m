Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6546B0260
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so54055635wmv.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:45:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 74si3784194wme.29.2017.01.27.10.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 10:45:08 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0RIceng022873
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:07 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28896pntnt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:06 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jan 2017 18:45:04 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 3/5] userfaultfd: non-cooperative: add event for exit() notification
Date: Fri, 27 Jan 2017 20:44:31 +0200
In-Reply-To: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1485542673-24387-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Allow userfaultfd monitor track termination of the processes that have
memory backed by the uffd.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 fs/userfaultfd.c                 | 24 ++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    |  7 +++++++
 include/uapi/linux/userfaultfd.h |  5 ++++-
 kernel/exit.c                    |  2 ++
 4 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 651d6d8..839ffd5 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -774,6 +774,30 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
 	}
 }
 
+void userfaultfd_exit(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma = mm->mmap;
+
+	while (vma) {
+		struct userfaultfd_ctx *ctx = vma->vm_userfaultfd_ctx.ctx;
+
+		if (ctx && (ctx->features & UFFD_FEATURE_EVENT_EXIT)) {
+			struct userfaultfd_wait_queue ewq;
+
+			userfaultfd_ctx_get(ctx);
+
+			msg_init(&ewq.msg);
+			ewq.msg.event = UFFD_EVENT_EXIT;
+
+			userfaultfd_event_wait_completion(ctx, &ewq);
+
+			ctx->features &= ~UFFD_FEATURE_EVENT_EXIT;
+		}
+
+		vma = vma->vm_next;
+	}
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index a40be5d..0468548 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -72,6 +72,8 @@ extern int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 extern void userfaultfd_unmap_complete(struct mm_struct *mm,
 				       struct list_head *uf);
 
+extern void userfaultfd_exit(struct mm_struct *mm);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -136,6 +138,11 @@ static inline void userfaultfd_unmap_complete(struct mm_struct *mm,
 					      struct list_head *uf)
 {
 }
+
+static inline void userfaultfd_exit(struct mm_struct *mm)
+{
+}
+
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 3b05953..c055947 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -18,7 +18,8 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_EXIT |		\
+			   UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
@@ -112,6 +113,7 @@ struct uffd_msg {
 #define UFFD_EVENT_REMAP	0x14
 #define UFFD_EVENT_REMOVE	0x15
 #define UFFD_EVENT_UNMAP	0x16
+#define UFFD_EVENT_EXIT		0x17
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -161,6 +163,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
+#define UFFD_FEATURE_EVENT_EXIT			(1<<7)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/kernel/exit.c b/kernel/exit.c
index 16c6077..c11bf9d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -55,6 +55,7 @@
 #include <linux/kcov.h>
 #include <linux/random.h>
 #include <linux/rcuwait.h>
+#include <linux/userfaultfd_k.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -547,6 +548,7 @@ static void exit_mm(void)
 	enter_lazy_tlb(mm, current);
 	task_unlock(current);
 	mm_update_next_owner(mm);
+	userfaultfd_exit(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
