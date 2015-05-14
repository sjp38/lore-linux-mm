Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 92B156B0092
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:43 -0400 (EDT)
Received: by qgg76 with SMTP id 76so14884329qgg.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si4021255qhd.4.2015.05.14.10.31.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:42 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/23] userfaultfd: linux/userfaultfd_k.h
Date: Thu, 14 May 2015 19:31:01 +0200
Message-Id: <1431624680-20153-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Kernel header defining the methods needed by the VM common code to
interact with the userfaultfd.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/userfaultfd_k.h | 79 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)
 create mode 100644 include/linux/userfaultfd_k.h

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
new file mode 100644
index 0000000..e1e4360
--- /dev/null
+++ b/include/linux/userfaultfd_k.h
@@ -0,0 +1,79 @@
+/*
+ *  include/linux/userfaultfd_k.h
+ *
+ *  Copyright (C) 2015  Red Hat, Inc.
+ *
+ */
+
+#ifndef _LINUX_USERFAULTFD_K_H
+#define _LINUX_USERFAULTFD_K_H
+
+#ifdef CONFIG_USERFAULTFD
+
+#include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
+
+#include <linux/fcntl.h>
+
+/*
+ * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
+ * new flags, since they might collide with O_* ones. We want
+ * to re-use O_* flags that couldn't possibly have a meaning
+ * from userfaultfd, in order to leave a free define-space for
+ * shared O_* flags.
+ */
+#define UFFD_CLOEXEC O_CLOEXEC
+#define UFFD_NONBLOCK O_NONBLOCK
+
+#define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
+#define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
+
+extern int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+			    unsigned int flags, unsigned long reason);
+
+/* mm helpers */
+static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
+					struct vm_userfaultfd_ctx vm_ctx)
+{
+	return vma->vm_userfaultfd_ctx.ctx == vm_ctx.ctx;
+}
+
+static inline bool userfaultfd_missing(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_UFFD_MISSING;
+}
+
+static inline bool userfaultfd_armed(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
+}
+
+#else /* CONFIG_USERFAULTFD */
+
+/* mm helpers */
+static inline int handle_userfault(struct vm_area_struct *vma,
+				   unsigned long address,
+				   unsigned int flags,
+				   unsigned long reason)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
+					struct vm_userfaultfd_ctx vm_ctx)
+{
+	return true;
+}
+
+static inline bool userfaultfd_missing(struct vm_area_struct *vma)
+{
+	return false;
+}
+
+static inline bool userfaultfd_armed(struct vm_area_struct *vma)
+{
+	return false;
+}
+
+#endif /* CONFIG_USERFAULTFD */
+
+#endif /* _LINUX_USERFAULTFD_K_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
