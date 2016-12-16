Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A378B6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:25 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 71so92371478ioe.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a15si2935883ita.83.2016.12.16.06.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:24 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/42] userfaultfd: document _IOR/_IOW
Date: Fri, 16 Dec 2016 15:47:40 +0100
Message-Id: <20161216144821.5183-2-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

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
