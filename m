Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 834CE6B0098
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:50 -0400 (EDT)
Received: by wibt6 with SMTP id t6so23970392wib.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ua7si2595822wib.37.2015.05.14.10.31.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:43 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/23] userfaultfd: Rename uffd_api.bits into .features
Date: Thu, 14 May 2015 19:31:08 +0200
Message-Id: <1431624680-20153-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

From: Pavel Emelyanov <xemul@parallels.com>

This is (seem to be) the minimal thing that is required to unblock
standard uffd usage from the non-cooperative one. Now more bits can
be added to the features field indicating e.g. UFFD_FEATURE_FORK and
others needed for the latter use-case.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 |  4 ++--
 include/uapi/linux/userfaultfd.h | 10 ++++++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1c9be61..9085365 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -856,7 +856,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 	/* careful not to leak info, we only read the first 8 bytes */
-	uffdio_api.bits = UFFD_API_BITS;
+	uffdio_api.features = UFFD_API_FEATURES;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 	ret = -EFAULT;
 	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
@@ -913,7 +913,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	 *	protocols: aa:... bb:...
 	 */
 	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
-		   pending, total, UFFD_API, UFFD_API_BITS,
+		   pending, total, UFFD_API, UFFD_API_FEATURES,
 		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
 }
 #endif
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 9a8cd56..5e1c2f7 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -11,7 +11,7 @@
 
 #define UFFD_API ((__u64)0xAA)
 /* FIXME: add "|UFFD_BIT_WP" to UFFD_API_BITS after implementing it */
-#define UFFD_API_BITS (UFFD_BIT_WRITE)
+#define UFFD_API_FEATURES (UFFD_FEATURE_WRITE_BIT)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -51,12 +51,18 @@
 #define UFFD_BIT_WP	(1<<1)	/* handle_userfault() reason VM_UFFD_WP */
 #define UFFD_BITS	2	/* two above bits used for UFFD_BIT_* mask */
 
+/*
+ * Features reported in uffdio_api.features field
+ */
+#define UFFD_FEATURE_WRITE_BIT	(1<<0) /* Corresponds to UFFD_BIT_WRITE */
+#define UFFD_FEATURE_WP_BIT	(1<<1) /* Corresponds to UFFD_BIT_WP */
+
 struct uffdio_api {
 	/* userland asks for an API number */
 	__u64 api;
 
 	/* kernel answers below with the available features for the API */
-	__u64 bits;
+	__u64 features;
 	__u64 ioctls;
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
