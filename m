Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D09366B02BE
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:27 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id q186so21230139itb.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si6170060ioi.183.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 37/42] userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_SHMEM
Date: Fri, 16 Dec 2016 15:48:16 +0100
Message-Id: <20161216144821.5183-38-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Userland developers asked to be notified immediately by the UFFDIO_API
ioctl if shmem missing mode is supported by userfaultfd in the running
kernel. This avoids the need to run UFFDIO_REGISTER on a shmem virtual
memory range to find out.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 10631a4..9ac4b68 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -21,7 +21,8 @@
 #define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_MADVDONTNEED |	\
-			   UFFD_FEATURE_MISSING_HUGETLBFS)
+			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
+			   UFFD_FEATURE_MISSING_SHMEM)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -146,12 +147,17 @@ struct uffdio_api {
 	 *    it, so userland can later check if the feature flag is
 	 *    present in uffdio_api.features after UFFDIO_API
 	 *    succeeded.
+	 *
+	 * UFFD_FEATURE_MISSING_SHMEM works the same as
+	 * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
+	 * (i.e. tmpfs and other shmem based APIs).
 	 */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
 #define UFFD_FEATURE_EVENT_REMAP		(1<<2)
 #define UFFD_FEATURE_EVENT_MADVDONTNEED		(1<<3)
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
+#define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 	__u64 features;
 
 	__u64 ioctls;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
