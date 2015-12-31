Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C80B46B002B
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 05:16:52 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 65so109714885pff.3
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 02:16:52 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ro6si285914pab.190.2015.12.31.02.16.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Dec 2015 02:16:52 -0800 (PST)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] arm64: fix add kasan bug
Date: Thu, 31 Dec 2015 18:09:09 +0800
Message-ID: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: qiuxishi@huawei.com, zhongjiang@huawei.com, long.wanglong@huawei.com

From: zhong jiang <zhongjiang@huawei.com>

In general, each process have 16kb stack space to use, but
stack need extra space to store red_zone when kasan enable.
the patch fix above question.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/arm64/include/asm/thread_info.h | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index 90c7ff2..45b5a7e 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -23,13 +23,24 @@
 
 #include <linux/compiler.h>
 
+#ifdef CONFIG_KASAN
+#define KASAN_STACK_ORDER 1
+#else
+#define KASAN_STACK_ORDER 0
+#endif
+
 #ifdef CONFIG_ARM64_4K_PAGES
-#define THREAD_SIZE_ORDER	2
+#define THREAD_SIZE_ORDER	(2 + KASAN_STACK_ORDER)
 #elif defined(CONFIG_ARM64_16K_PAGES)
-#define THREAD_SIZE_ORDER	0
+#define THREAD_SIZE_ORDER	(0 + KASAN_STACK_ORDER)
 #endif
 
+#ifdef CONFIG_KASAN
+#define THREAD_SIZE		32768
+#else
 #define THREAD_SIZE		16384
+#endif
+
 #define THREAD_START_SP		(THREAD_SIZE - 16)
 
 #ifndef __ASSEMBLY__
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
