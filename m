Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B45416B0007
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 08:30:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s1-v6so11240149pfm.22
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:30:18 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id p24-v6si16336360plo.52.2018.08.14.05.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 05:30:17 -0700 (PDT)
From: Xiaofeng Yuan <yuanxiaofeng1@huawei.com>
Subject: [PATCH RFC] usercopy: optimize stack check flow when the page-spanning test is disabled
Date: Tue, 14 Aug 2018 20:20:28 +0800
Message-ID: <1534249228-57122-1-git-send-email-yuanxiaofeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xiaofeng Yuan <yuanxiaofeng1@huawei.com>

The check_heap_object() checks the spanning multiple pages and slab.
When the page-spanning test is disabled, the check_heap_object() is
redundant for spanning multiple pages. However, the kernel stacks are
multiple pages under certain conditions: CONFIG_ARCH_THREAD_STACK_ALLOCATOR
is not defined and (THREAD_SIZE >= PAGE_SIZE). At this point, We can skip
the check_heap_object() for kernel stacks to improve performance.
Similarly, the virtually-mapped stack can skip check_heap_object() also,
beacause virt_addr_valid() will return.

I launched more than 100 apps on smartphone, and recorded total check time
and numbers of kernel stacks. The average time of checking kernel stacks
reduced by 48%.


Signed-off-by: Xiaofeng Yuan <yuanxiaofeng1@huawei.com>
---
 mm/usercopy.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index e9e9325..af350f6 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -255,6 +255,29 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 	/* Check for invalid addresses. */
 	check_bogus_address((const unsigned long)ptr, n, to_user);
 
+#if !defined(CONFIG_HARDENED_USERCOPY_PAGESPAN) && \
+    !defined(CONFIG_ARCH_THREAD_STACK_ALLOCATOR) && \
+    (THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK))
+	/* Check for bad stack object. */
+	switch (check_stack_object(ptr, n)) {
+	case NOT_STACK:
+		/* Object is not touching the current process stack. */
+		break;
+	case GOOD_FRAME:
+	case GOOD_STACK:
+		/*
+		 * Object is either in the correct frame (when it
+		 * is possible to check) or just generally on the
+		 * process stack (when frame checking not available).
+		 */
+		return;
+	default:
+		usercopy_abort("process stack", NULL, to_user, 0, n);
+	}
+
+	/* Check for bad heap object. */
+	check_heap_object(ptr, n, to_user);
+#else
 	/* Check for bad heap object. */
 	check_heap_object(ptr, n, to_user);
 
@@ -274,6 +297,7 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 	default:
 		usercopy_abort("process stack", NULL, to_user, 0, n);
 	}
+#endif
 
 	/* Check for object in kernel to avoid text exposure. */
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
-- 
1.9.1
