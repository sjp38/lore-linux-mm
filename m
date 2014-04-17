Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 279EC6B003B
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 15:47:52 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so697181pde.29
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 12:47:51 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id gr5si12762194pac.32.2014.04.17.12.47.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Apr 2014 12:47:51 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH] ion: only use the CMA heap when CONFIG_CMA is enabled
Date: Thu, 17 Apr 2014 12:47:46 -0700
Message-Id: <1397764066-22527-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

The CMA heap is intended to be used with CMA (as the name
suggests). Don't compile or use it if CONFIG_CMA is not
enabled.

Currently, if CONFIG_CMA=n and someone creates and uses a CMA heap, some
of their allocations might actually succeed (since the CMA heap is just
using generic DMA API routines) but the fact that the memory isn't
coming from CMA is confusing.

Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
---
 drivers/staging/android/ion/Makefile   | 3 ++-
 drivers/staging/android/ion/ion_heap.c | 4 ++++
 drivers/staging/android/ion/ion_priv.h | 3 +++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index b56fd2bf2b..83923eac97 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_ION) +=	ion.o ion_heap.o ion_page_pool.o ion_system_heap.o \
-			ion_carveout_heap.o ion_chunk_heap.o ion_cma_heap.o
+			ion_carveout_heap.o ion_chunk_heap.o
+obj-$(CONFIG_CMA) += ion_cma_heap.o
 obj-$(CONFIG_ION_TEST) += ion_test.o
 ifdef CONFIG_COMPAT
 obj-$(CONFIG_ION) += compat_ion.o
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index bdc6a28ba8..d72940e631 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -332,9 +332,11 @@ struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data)
 	case ION_HEAP_TYPE_CHUNK:
 		heap = ion_chunk_heap_create(heap_data);
 		break;
+#ifdef CONFIG_CMA
 	case ION_HEAP_TYPE_DMA:
 		heap = ion_cma_heap_create(heap_data);
 		break;
+#endif
 	default:
 		pr_err("%s: Invalid heap type %d\n", __func__,
 		       heap_data->type);
@@ -371,9 +373,11 @@ void ion_heap_destroy(struct ion_heap *heap)
 	case ION_HEAP_TYPE_CHUNK:
 		ion_chunk_heap_destroy(heap);
 		break;
+#ifdef CONFIG_CMA
 	case ION_HEAP_TYPE_DMA:
 		ion_cma_heap_destroy(heap);
 		break;
+#endif
 	default:
 		pr_err("%s: Invalid heap type %d\n", __func__,
 		       heap->type);
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index 1eba3f2076..42e541e961 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -323,8 +323,11 @@ void ion_carveout_heap_destroy(struct ion_heap *);
 
 struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *);
 void ion_chunk_heap_destroy(struct ion_heap *);
+
+#ifdef CONFIG_CMA
 struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *);
 void ion_cma_heap_destroy(struct ion_heap *);
+#endif
 
 /**
  * kernel api to allocate/free from carveout -- used when carveout is
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
