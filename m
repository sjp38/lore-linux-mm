Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 267018E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:36:55 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id x12so14571219ioj.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:36:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x97sor36138874ita.32.2019.01.11.16.36.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 16:36:54 -0800 (PST)
From: Blake Caldwell <blake.caldwell@colorado.edu>
Subject: [PATCH 2/4] userfaultfd: UFFDIO_REMAP uABI
Date: Sat, 12 Jan 2019 00:36:27 +0000
Message-Id: <7f79b6d232fd6352d7e9df462944ba52ac1d906f.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: blake.caldwell@colorado.edu
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

From: Andrea Arcangeli <aarcange@redhat.com>

This implements the uABI of UFFDIO_REMAP.

Notably one mode bitflag is also forwarded (and in turn known) by the
lowlevel remap_pages method.

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 48f1a7c..a0d6106 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -34,7 +34,8 @@
 #define UFFD_API_RANGE_IOCTLS			\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
-	 (__u64)1 << _UFFDIO_ZEROPAGE)
+	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
+	 (__u64)1 << _UFFDIO_REMAP)
 #define UFFD_API_RANGE_IOCTLS_BASIC		\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY)
@@ -52,6 +53,7 @@
 #define _UFFDIO_WAKE			(0x02)
 #define _UFFDIO_COPY			(0x03)
 #define _UFFDIO_ZEROPAGE		(0x04)
+#define _UFFDIO_REMAP			(0x05)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -68,6 +70,8 @@
 				      struct uffdio_copy)
 #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
 				      struct uffdio_zeropage)
+#define UFFDIO_REMAP		_IOWR(UFFDIO, _UFFDIO_REMAP,	\
+				      struct uffdio_remap)
 
 /* read() structure */
 struct uffd_msg {
@@ -231,4 +235,23 @@ struct uffdio_zeropage {
 	__s64 zeropage;
 };
 
+struct uffdio_remap {
+	__u64 dst;
+	__u64 src;
+	__u64 len;
+	/*
+	 * Especially if used to atomically remove memory from the
+	 * address space the wake on the dst range is not needed.
+	 */
+#define UFFDIO_REMAP_MODE_DONTWAKE		((__u64)1<<0)
+#define UFFDIO_REMAP_MODE_ALLOW_SRC_HOLES	((__u64)1<<1)
+	__u64 mode;
+
+	/*
+	 * "remap" is written by the ioctl and must be at the end: the
+	 * copy_from_user will not read the last 8 bytes.
+	 */
+	__s64 remap;
+};
+
 #endif /* _LINUX_USERFAULTFD_H */
-- 
1.8.3.1
