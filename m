Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB6C6B0271
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 05:57:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so98781644pgx.6
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 02:57:21 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z2si21818290par.2.2016.11.15.02.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 02:57:20 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
Date: Tue, 15 Nov 2016 21:57:02 +1100
Message-Id: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org

POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
to shift poison values so that they don't alias userspace.

We should add it to ZERO_SIZE_PTR so that attackers can't use
ZERO_SIZE_PTR as a way to get a pointer to userspace.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 include/linux/slab.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 084b12bad198..17ddd7aea2dd 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -12,6 +12,7 @@
 #define	_LINUX_SLAB_H
 
 #include <linux/gfp.h>
+#include <linux/poison.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
@@ -109,7 +110,7 @@
  * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
  * Both make kfree a no-op.
  */
-#define ZERO_SIZE_PTR ((void *)16)
+#define ZERO_SIZE_PTR ((void *)(16 + POISON_POINTER_DELTA))
 
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
