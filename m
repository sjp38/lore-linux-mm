Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E69F6B0394
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 16:45:29 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 9so116895695qkk.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:29 -0800 (PST)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id l61si7900683qtd.243.2017.03.02.13.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 13:45:28 -0800 (PST)
Received: by mail-qk0-f173.google.com with SMTP id n127so147117007qkf.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:28 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCH 11/12] staging: android: ion: Make Ion heaps selectable
Date: Thu,  2 Mar 2017 13:44:43 -0800
Message-Id: <1488491084-17252-12-git-send-email-labbott@redhat.com>
In-Reply-To: <1488491084-17252-1-git-send-email-labbott@redhat.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org


Currently, all heaps are compiled in all the time. In switching to
a better platform model, let's allow these to be compiled out for good
measure.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/Kconfig    | 32 ++++++++++++++++++++
 drivers/staging/android/ion/Makefile   |  8 +++--
 drivers/staging/android/ion/ion_priv.h | 53 ++++++++++++++++++++++++++++++++--
 3 files changed, 87 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
index 0c91b2b..2e97990 100644
--- a/drivers/staging/android/ion/Kconfig
+++ b/drivers/staging/android/ion/Kconfig
@@ -17,3 +17,35 @@ config ION_TEST
 	  Choose this option to create a device that can be used to test the
 	  kernel and device side ION functions.
 
+config ION_SYSTEM_HEAP
+	bool "Ion system heap"
+	depends on ION
+	help
+	  Choose this option to enable the Ion system heap. The system heap
+	  is backed by pages from the buddy allocator. If in doubt, say Y.
+
+config ION_CARVEOUT_HEAP
+	bool "Ion carveout heap support"
+	depends on ION
+	help
+	  Choose this option to enable carveout heaps with Ion. Carveout heaps
+	  are backed by memory reserved from the system. Allocation times are
+	  typically faster at the cost of memory not being used. Unless you
+	  know your system has these regions, you should say N here.
+
+config ION_CHUNK_HEAP
+	bool "Ion chunk heap support"
+	depends on ION
+	help
+          Choose this option to enable chunk heaps with Ion. This heap is
+	  similar in function the carveout heap but memory is broken down
+	  into smaller chunk sizes, typically corresponding to a TLB size.
+	  Unless you know your system has these regions, you should say N here.
+
+config ION_CMA_HEAP
+	bool "Ion CMA heap support"
+	depends on ION && CMA
+	help
+	  Choose this option to enable CMA heaps with Ion. This heap is backed
+	  by the Contiguous Memory Allocator (CMA). If your system has these
+	  regions, you should say Y here.
diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index 9457090..eef022b 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -1,6 +1,8 @@
-obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
-			ion_page_pool.o ion_system_heap.o \
-			ion_carveout_heap.o ion_chunk_heap.o ion_cma_heap.o
+obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o
+obj-$(CONFIG_ION_SYSTEM_HEAP) += ion_system_heap.o ion_page_pool.o
+obj-$(CONFIG_ION_CARVEOUT_HEAP) += ion_carveout_heap.o
+obj-$(CONFIG_ION_CHUNK_HEAP) += ion_chunk_heap.o
+obj-$(CONFIG_ION_CMA_HEAP) += ion_cma_heap.o
 obj-$(CONFIG_ION_TEST) += ion_test.o
 ifdef CONFIG_COMPAT
 obj-$(CONFIG_ION) += compat_ion.o
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index b09bc7c..6eafe0d 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -369,21 +369,68 @@ size_t ion_heap_freelist_size(struct ion_heap *heap);
  * heaps as appropriate.
  */
 
+
 struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data);
 void ion_heap_destroy(struct ion_heap *heap);
+
+#ifdef CONFIG_ION_SYSTEM_HEAP
 struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused);
 void ion_system_heap_destroy(struct ion_heap *heap);
-
 struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *heap);
 void ion_system_contig_heap_destroy(struct ion_heap *heap);
-
+#else
+static inline struct ion_heap * ion_system_heap_create(
+	struct ion_platform_heap *unused)
+{
+	return ERR_PTR(-ENODEV);
+}
+static inline void ion_system_heap_destroy(struct ion_heap *heap) { }
+
+static inline struct ion_heap *ion_system_contig_heap_create(
+	struct ion_platform_heap *heap)
+{
+	return ERR_PTR(-ENODEV);
+}
+
+static inline void ion_system_contig_heap_destroy(struct ion_heap *heap) { }
+#endif
+
+#ifdef CONFIG_ION_CARVEOUT_HEAP
 struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data);
 void ion_carveout_heap_destroy(struct ion_heap *heap);
-
+#else
+static inline struct ion_heap *ion_carveout_heap_create(
+	struct ion_platform_heap *heap_data)
+{
+	return ERR_PTR(-ENODEV);
+}
+static inline void ion_carveout_heap_destroy(struct ion_heap *heap) { }
+#endif
+
+#ifdef CONFIG_ION_CHUNK_HEAP
 struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data);
 void ion_chunk_heap_destroy(struct ion_heap *heap);
+#else
+static inline struct ion_heap *ion_chunk_heap_create(
+	struct ion_platform_heap *heap_data)
+{
+	return ERR_PTR(-ENODEV);
+}
+static inline void ion_chunk_heap_destroy(struct ion_heap *heap) { }
+
+#endif
+
+#ifdef CONFIG_ION_CMA_HEAP
 struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data);
 void ion_cma_heap_destroy(struct ion_heap *heap);
+#else
+static inline struct ion_heap *ion_cma_heap_create(
+	struct ion_platform_heap *data)
+{
+	return ERR_PTR(-ENODEV);
+}
+static inline void ion_cma_heap_destroy(struct ion_heap *heap) { }
+#endif
 
 /**
  * functions for creating and destroying a heap pool -- allows you
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
