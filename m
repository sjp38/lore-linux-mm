Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4EC6B026A
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:06:10 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so16690356pga.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:06:10 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id s5si31951267pfj.271.2016.12.08.21.06.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 21:06:09 -0800 (PST)
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OHW009BVJI8QV50@mailout4.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Dec 2016 14:06:08 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] staging: android: ion: return -ENOMEM in ion_cma_heap
 allocation failure
Date: Fri, 09 Dec 2016 14:05:30 +0900
Message-id: <1481259930-4620-2-git-send-email-jaewon31.kim@samsung.com>
In-reply-to: <1481259930-4620-1-git-send-email-jaewon31.kim@samsung.com>
References: <1481259930-4620-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: labbott@redhat.com, sumit.semwal@linaro.org, tixy@linaro.org, prime.zeng@huawei.com, tranmanphong@gmail.com, fabio.estevam@freescale.com, ccross@android.com, rebecca@android.com, benjamin.gaignard@linaro.org, arve@android.com, riandrews@android.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

Initial Commit 349c9e138551 ("gpu: ion: add CMA heap") returns -1 in allocation
failure. The returned value is passed up to userspace through ioctl. So user can
misunderstand error reason as -EPERM(1) rather than -ENOMEM(12).

This patch simply changed this to return -ENOMEM.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/staging/android/ion/ion_cma_heap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index 6c7de74..22b9582 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -24,8 +24,6 @@
 #include "ion.h"
 #include "ion_priv.h"
 
-#define ION_CMA_ALLOCATE_FAILED -1
-
 struct ion_cma_heap {
 	struct ion_heap heap;
 	struct device *dev;
@@ -59,7 +57,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
 
 	info = kzalloc(sizeof(struct ion_cma_buffer_info), GFP_KERNEL);
 	if (!info)
-		return ION_CMA_ALLOCATE_FAILED;
+		return -ENOMEM;
 
 	info->cpu_addr = dma_alloc_coherent(dev, len, &(info->handle),
 						GFP_HIGHUSER | __GFP_ZERO);
@@ -88,7 +86,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
 	dma_free_coherent(dev, len, info->cpu_addr, info->handle);
 err:
 	kfree(info);
-	return ION_CMA_ALLOCATE_FAILED;
+	return -ENOMEM;
 }
 
 static void ion_cma_free(struct ion_buffer *buffer)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
