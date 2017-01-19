Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB2276B026C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:02 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id r82so40511303ywg.3
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:23:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l8si820960ywa.54.2017.01.19.00.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 00:23:02 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0J8E4RA026431
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:01 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282dcxsmmq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:01 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 19 Jan 2017 08:22:56 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] userfaultfd: non-cooperative: rename *EVENT_MADVDONTNEED to *EVENT_REMOVE
Date: Thu, 19 Jan 2017 10:22:32 +0200
In-Reply-To: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1484814154-1557-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The UFFD_EVENT_MADVDONTNEED purpose is to notify uffd monitor about removal
of certain range from address space tracked by userfaultfd.
Hence, UFFD_EVENT_REMOVE seems to better reflect the operation semantics.
Respectively, 'madv_dn' field of uffd_msg is renamed to 'remove' and the
madvise_userfault_dontneed callback is renamed to userfaultfd_remove.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c                         | 14 +++++++-------
 include/linux/userfaultfd_k.h            | 16 ++++++++--------
 include/uapi/linux/userfaultfd.h         |  8 ++++----
 mm/madvise.c                             |  2 +-
 tools/testing/selftests/vm/userfaultfd.c | 16 ++++++++--------
 5 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index a817588..e9b4a50 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -681,16 +681,16 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
-void madvise_userfault_dontneed(struct vm_area_struct *vma,
-				struct vm_area_struct **prev,
-				unsigned long start, unsigned long end)
+void userfaultfd_remove(struct vm_area_struct *vma,
+			struct vm_area_struct **prev,
+			unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue ewq;
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
-	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_MADVDONTNEED))
+	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE))
 		return;
 
 	userfaultfd_ctx_get(ctx);
@@ -700,9 +700,9 @@ void madvise_userfault_dontneed(struct vm_area_struct *vma,
 
 	msg_init(&ewq.msg);
 
-	ewq.msg.event = UFFD_EVENT_MADVDONTNEED;
-	ewq.msg.arg.madv_dn.start = start;
-	ewq.msg.arg.madv_dn.end = end;
+	ewq.msg.event = UFFD_EVENT_REMOVE;
+	ewq.msg.arg.remove.start = start;
+	ewq.msg.arg.remove.end = end;
 
 	userfaultfd_event_wait_completion(ctx, &ewq);
 
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index f431861..2521542 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -61,10 +61,10 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
-extern void madvise_userfault_dontneed(struct vm_area_struct *vma,
-				       struct vm_area_struct **prev,
-				       unsigned long start,
-				       unsigned long end);
+extern void userfaultfd_remove(struct vm_area_struct *vma,
+			       struct vm_area_struct **prev,
+			       unsigned long start,
+			       unsigned long end);
 
 #else /* CONFIG_USERFAULTFD */
 
@@ -112,10 +112,10 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 {
 }
 
-static inline void madvise_userfault_dontneed(struct vm_area_struct *vma,
-					      struct vm_area_struct **prev,
-					      unsigned long start,
-					      unsigned long end)
+static inline void userfaultfd_remove(struct vm_area_struct *vma,
+				      struct vm_area_struct **prev,
+				      unsigned long start,
+				      unsigned long end)
 {
 }
 #endif /* CONFIG_USERFAULTFD */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 9ac4b68..b742c40 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -20,7 +20,7 @@
 #define UFFD_API ((__u64)0xAA)
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
-			   UFFD_FEATURE_EVENT_MADVDONTNEED |	\
+			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
 			   UFFD_FEATURE_MISSING_SHMEM)
 #define UFFD_API_IOCTLS				\
@@ -92,7 +92,7 @@ struct uffd_msg {
 		struct {
 			__u64	start;
 			__u64	end;
-		} madv_dn;
+		} remove;
 
 		struct {
 			/* unused reserved fields */
@@ -109,7 +109,7 @@ struct uffd_msg {
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
 #define UFFD_EVENT_REMAP	0x14
-#define UFFD_EVENT_MADVDONTNEED	0x15
+#define UFFD_EVENT_REMOVE	0x15
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -155,7 +155,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
-#define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
+#define UFFD_FEATURE_EVENT_REMOVE		(1<<3)
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 	__u64 features;
diff --git a/mm/madvise.c b/mm/madvise.c
index b530a49..ab5ef14 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -479,7 +479,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	madvise_userfault_dontneed(vma, prev, start, end);
+	userfaultfd_remove(vma, prev, start, end);
 	zap_page_range(vma, start, end - start);
 	return 0;
 }
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 5a840a6..9eb77df 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -398,12 +398,12 @@ static void *uffd_poll_thread(void *arg)
 			uffd = msg.arg.fork.ufd;
 			pollfd[0].fd = uffd;
 			break;
-		case UFFD_EVENT_MADVDONTNEED:
-			uffd_reg.range.start = msg.arg.madv_dn.start;
-			uffd_reg.range.len = msg.arg.madv_dn.end -
-				msg.arg.madv_dn.start;
+		case UFFD_EVENT_REMOVE:
+			uffd_reg.range.start = msg.arg.remove.start;
+			uffd_reg.range.len = msg.arg.remove.end -
+				msg.arg.remove.start;
 			if (ioctl(uffd, UFFDIO_UNREGISTER, &uffd_reg.range))
-				fprintf(stderr, "madv_dn failure\n"), exit(1);
+				fprintf(stderr, "remove failure\n"), exit(1);
 			break;
 		case UFFD_EVENT_REMAP:
 			area_dst = (char *)(unsigned long)msg.arg.remap.to;
@@ -570,7 +570,7 @@ static int userfaultfd_open(int features)
  * mremap, the entire monitored area is accessed in a single pass for
  * HUGETLB_TEST.
  * The release of the pages currently generates event only for
- * anonymous memory (UFFD_EVENT_MADVDONTNEED), hence it is not checked
+ * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
  * for hugetlb and shmem.
  */
 static int faulting_process(void)
@@ -715,14 +715,14 @@ static int userfaultfd_events_test(void)
 	pid_t pid;
 	char c;
 
-	printf("testing events (fork, remap, madv_dn): ");
+	printf("testing events (fork, remap, remove): ");
 	fflush(stdout);
 
 	if (release_pages(area_dst))
 		return 1;
 
 	features = UFFD_FEATURE_EVENT_FORK | UFFD_FEATURE_EVENT_REMAP |
-		UFFD_FEATURE_EVENT_MADVDONTNEED;
+		UFFD_FEATURE_EVENT_REMOVE;
 	if (userfaultfd_open(features) < 0)
 		return 1;
 	fcntl(uffd, F_SETFL, uffd_flags | O_NONBLOCK);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
