Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 653016B0269
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:36:12 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id q62-v6so243550lfg.4
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:36:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor918522lfk.58.2018.10.23.14.36.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:36:10 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 09/17] prmem: hardened usercopy
Date: Wed, 24 Oct 2018 00:34:56 +0300
Message-Id: <20181023213504.28905-10-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Chris von Recklinghausen <crecklin@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Prevent leaks of protected memory to userspace.
The protection from overwrited from userspace is already available, once
the memory is write protected.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Kees Cook <keescook@chromium.org>
CC: Chris von Recklinghausen <crecklin@redhat.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/prmem.h | 24 ++++++++++++++++++++++++
 mm/usercopy.c         |  5 +++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
index cf713fc1c8bb..919d853ddc15 100644
--- a/include/linux/prmem.h
+++ b/include/linux/prmem.h
@@ -273,6 +273,30 @@ struct pmalloc_pool {
 	uint8_t mode;
 };
 
+void __noreturn usercopy_abort(const char *name, const char *detail,
+			       bool to_user, unsigned long offset,
+			       unsigned long len);
+
+/**
+ * check_pmalloc_object() - helper for hardened usercopy
+ * @ptr: the beginning of the memory to check
+ * @n: the size of the memory to check
+ * @to_user: copy to userspace or from userspace
+ *
+ * If the check is ok, it will fall-through, otherwise it will abort.
+ * The function is inlined, to minimize the performance impact of the
+ * extra check that can end up on a hot path.
+ * Non-exhaustive micro benchmarking with QEMU x86_64 shows a reduction of
+ * the time spent in this fragment by 60%, when inlined.
+ */
+static inline
+void check_pmalloc_object(const void *ptr, unsigned long n, bool to_user)
+{
+	if (unlikely(__is_wr_after_init(ptr, n) || __is_wr_pool(ptr, n)))
+		usercopy_abort("pmalloc", "accessing pmalloc obj", to_user,
+			       (const unsigned long)ptr, n);
+}
+
 /*
  * The write rare functionality is fully implemented as __always_inline,
  * to prevent having an internal function call that is capable of modifying
diff --git a/mm/usercopy.c b/mm/usercopy.c
index 852eb4e53f06..a080dd37b684 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -22,8 +22,10 @@
 #include <linux/thread_info.h>
 #include <linux/atomic.h>
 #include <linux/jump_label.h>
+#include <linux/prmem.h>
 #include <asm/sections.h>
 
+
 /*
  * Checks if a given pointer and length is contained by the current
  * stack frame (if possible).
@@ -284,6 +286,9 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 
 	/* Check for object in kernel to avoid text exposure. */
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
+
+	/* Check if object is from a pmalloc chunk. */
+	check_pmalloc_object(ptr, n, to_user);
 }
 EXPORT_SYMBOL(__check_object_size);
 
-- 
2.17.1
