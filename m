Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 659436B0284
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g193so23145580qke.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h63si1903828qkd.292.2016.11.02.12.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/33] userfaultfd: document _IOR/_IOW
Date: Wed,  2 Nov 2016 20:33:33 +0100
Message-Id: <1478115245-32090-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

This adds proper documentation (inline) to avoid the risk of further
misunderstandings about the semantics of _IOW/_IOR and it also reminds
whoever will bump the UFFDIO_API in the future, to change the two
ioctl to _IOW.

This was found while implementing strace support for those ioctl,
otherwise we could have never found it by just reviewing kernel code
and testing it.

_IOC_READ or _IOC_WRITE alters nothing but the ioctl number itself, so
it's only worth fixing if the UFFDIO_API is bumped someday.

Reported-by: "Dmitry V. Levin" <ldv@altlinux.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/asm-generic/ioctl.h | 10 +++++++++-
 include/uapi/linux/userfaultfd.h |  6 ++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/uapi/asm-generic/ioctl.h b/include/uapi/asm-generic/ioctl.h
index 7e7c11b..749b32f 100644
--- a/include/uapi/asm-generic/ioctl.h
+++ b/include/uapi/asm-generic/ioctl.h
@@ -48,6 +48,9 @@
 /*
  * Direction bits, which any architecture can choose to override
  * before including this file.
+ *
+ * NOTE: _IOC_WRITE means userland is writing and kernel is
+ * reading. _IOC_READ means userland is reading and kernel is writing.
  */
 
 #ifndef _IOC_NONE
@@ -72,7 +75,12 @@
 #define _IOC_TYPECHECK(t) (sizeof(t))
 #endif
 
-/* used to create numbers */
+/*
+ * Used to create numbers.
+ *
+ * NOTE: _IOW means userland is writing and kernel is reading. _IOR
+ * means userland is reading and kernel is writing.
+ */
 #define _IO(type,nr)		_IOC(_IOC_NONE,(type),(nr),0)
 #define _IOR(type,nr,size)	_IOC(_IOC_READ,(type),(nr),(_IOC_TYPECHECK(size)))
 #define _IOW(type,nr,size)	_IOC(_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(size)))
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 9057d7a..94046b8 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -11,6 +11,12 @@
 
 #include <linux/types.h>
 
+/*
+ * If the UFFDIO_API is upgraded someday, the UFFDIO_UNREGISTER and
+ * UFFDIO_WAKE ioctls should be defined as _IOW and not as _IOR.  In
+ * userfaultfd.h we assumed the kernel was reading (instead _IOC_READ
+ * means the userland is reading).
+ */
 #define UFFD_API ((__u64)0xAA)
 /*
  * After implementing the respective features it will become:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
