Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6946B0273
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:29 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o141so21452203itc.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u78si6146369ioi.236.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 26/42] userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_HUGETLBFS
Date: Fri, 16 Dec 2016 15:48:05 +0100
Message-Id: <20161216144821.5183-27-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Userland developers asked to be notified immediately by the UFFDIO_API
ioctl if hugetlbfs missing mode is supported by userfaultfd in the
running kernel. This avoids the need to run UFFDIO_REGISTER on a
hugetlbfs virtual memory range to find out.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index a3828a9..7293321 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -18,9 +18,10 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |	    \
-			   UFFD_FEATURE_EVENT_REMAP |	    \
-			   UFFD_FEATURE_EVENT_MADVDONTNEED)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
+			   UFFD_FEATURE_EVENT_REMAP |		\
+			   UFFD_FEATURE_EVENT_MADVDONTNEED |	\
+			   UFFD_FEATURE_MISSING_HUGETLBFS)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -125,11 +126,32 @@ struct uffdio_api {
 	 * Note: UFFD_EVENT_PAGEFAULT and UFFD_PAGEFAULT_FLAG_WRITE
 	 * are to be considered implicitly always enabled in all kernels as
 	 * long as the uffdio_api.api requested matches UFFD_API.
+	 *
+	 * UFFD_FEATURE_MISSING_HUGETLBFS means an UFFDIO_REGISTER
+	 * with UFFDIO_REGISTER_MODE_MISSING mode will succeed on
+	 * hugetlbfs virtual memory ranges. Adding or not adding
+	 * UFFD_FEATURE_MISSING_HUGETLBFS to uffdio_api.features has
+	 * no real functional effect after UFFDIO_API returns, but
+	 * it's only useful for an initial feature set probe at
+	 * UFFDIO_API time. There are two ways to use it:
+	 *
+	 * 1) by adding UFFD_FEATURE_MISSING_HUGETLBFS to the
+	 *    uffdio_api.features before calling UFFDIO_API, an error
+	 *    will be returned by UFFDIO_API on a kernel without
+	 *    hugetlbfs missing support
+	 *
+	 * 2) the UFFD_FEATURE_MISSING_HUGETLBFS can not be added in
+	 *    uffdio_api.features and instead it will be set by the
+	 *    kernel in the uffdio_api.features if the kernel supports
+	 *    it, so userland can later check if the feature flag is
+	 *    present in uffdio_api.features after UFFDIO_API
+	 *    succeeded.
 	 */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
 #define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
+#define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 	__u64 features;
 
 	__u64 ioctls;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
