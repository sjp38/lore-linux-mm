Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 76ABB6B0075
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:12 -0500 (EST)
Received: by qgdq107 with SMTP id q107so6293127qgd.6
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f13si6537738qaa.40.2015.03.05.09.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:05 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/21] userfaultfd: linux/userfaultfd_k.h
Date: Thu,  5 Mar 2015 18:17:47 +0100
Message-Id: <1425575884-2574-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

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
