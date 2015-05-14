Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id A1DE36B0089
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:33 -0400 (EDT)
Received: by qgg76 with SMTP id 76so14881889qgg.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m22si23712478qhb.128.2015.05.14.10.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:28 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 20/23] userfaultfd: UFFDIO_COPY|UFFDIO_ZEROPAGE uAPI
Date: Thu, 14 May 2015 19:31:17 +0200
Message-Id: <1431624680-20153-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This implements the uABI of UFFDIO_COPY and UFFDIO_ZEROPAGE.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 42 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 8e42bc3..c8a543f 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -21,7 +21,9 @@
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
 	 (__u64)1 << _UFFDIO_API)
 #define UFFD_API_RANGE_IOCTLS			\
-	((__u64)1 << _UFFDIO_WAKE)
+	((__u64)1 << _UFFDIO_WAKE |		\
+	 (__u64)1 << _UFFDIO_COPY |		\
+	 (__u64)1 << _UFFDIO_ZEROPAGE)
 
 /*
  * Valid ioctl command number range with this API is from 0x00 to
@@ -34,6 +36,8 @@
 #define _UFFDIO_REGISTER		(0x00)
 #define _UFFDIO_UNREGISTER		(0x01)
 #define _UFFDIO_WAKE			(0x02)
+#define _UFFDIO_COPY			(0x03)
+#define _UFFDIO_ZEROPAGE		(0x04)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -46,6 +50,10 @@
 				     struct uffdio_range)
 #define UFFDIO_WAKE		_IOR(UFFDIO, _UFFDIO_WAKE,	\
 				     struct uffdio_range)
+#define UFFDIO_COPY		_IOWR(UFFDIO, _UFFDIO_COPY,	\
+				      struct uffdio_copy)
+#define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
+				      struct uffdio_zeropage)
 
 /* read() structure */
 struct uffd_msg {
@@ -118,4 +126,36 @@ struct uffdio_register {
 	__u64 ioctls;
 };
 
+struct uffdio_copy {
+	__u64 dst;
+	__u64 src;
+	__u64 len;
+	/*
+	 * There will be a wrprotection flag later that allows to map
+	 * pages wrprotected on the fly. And such a flag will be
+	 * available if the wrprotection ioctl are implemented for the
+	 * range according to the uffdio_register.ioctls.
+	 */
+#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
+	__u64 mode;
+
+	/*
+	 * "copy" is written by the ioctl and must be at the end: the
+	 * copy_from_user will not read the last 8 bytes.
+	 */
+	__s64 copy;
+};
+
+struct uffdio_zeropage {
+	struct uffdio_range range;
+#define UFFDIO_ZEROPAGE_MODE_DONTWAKE		((__u64)1<<0)
+	__u64 mode;
+
+	/*
+	 * "zeropage" is written by the ioctl and must be at the end:
+	 * the copy_from_user will not read the last 8 bytes.
+	 */
+	__s64 zeropage;
+};
+
 #endif /* _LINUX_USERFAULTFD_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
