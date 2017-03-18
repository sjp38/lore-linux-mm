Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 561756B039B
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v127so85964156qkb.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:54 -0700 (PDT)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com. [209.85.220.181])
        by mx.google.com with ESMTPS id c67si7685619qkf.186.2017.03.17.17.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:53 -0700 (PDT)
Received: by mail-qk0-f181.google.com with SMTP id p64so77334076qke.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:52 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 16/21] staging: android: ion: Get rid of ion_phys_addr_t
Date: Fri, 17 Mar 2017 17:54:48 -0700
Message-Id: <1489798493-16600-17-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Once upon a time, phys_addr_t was not everywhere in the kernel. These
days it is used enough places that having a separate Ion type doesn't
make sense. Remove the extra type and just use phys_addr_t directly.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.h               | 12 ++----------
 drivers/staging/android/ion/ion_carveout_heap.c | 10 +++++-----
 drivers/staging/android/ion/ion_chunk_heap.c    |  6 +++---
 drivers/staging/android/ion/ion_heap.c          |  4 ++--
 4 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/android/ion/ion.h b/drivers/staging/android/ion/ion.h
index 3b4bff5..e8a6ffe 100644
--- a/drivers/staging/android/ion/ion.h
+++ b/drivers/staging/android/ion/ion.h
@@ -28,14 +28,6 @@ struct ion_mapper;
 struct ion_client;
 struct ion_buffer;
 
-/*
- * This should be removed some day when phys_addr_t's are fully
- * plumbed in the kernel, and all instances of ion_phys_addr_t should
- * be converted to phys_addr_t.  For the time being many kernel interfaces
- * do not accept phys_addr_t's that would have to
- */
-#define ion_phys_addr_t unsigned long
-
 /**
  * struct ion_platform_heap - defines a heap in the given platform
  * @type:	type of the heap from ion_heap_type enum
@@ -53,9 +45,9 @@ struct ion_platform_heap {
 	enum ion_heap_type type;
 	unsigned int id;
 	const char *name;
-	ion_phys_addr_t base;
+	phys_addr_t base;
 	size_t size;
-	ion_phys_addr_t align;
+	phys_addr_t align;
 	void *priv;
 };
 
diff --git a/drivers/staging/android/ion/ion_carveout_heap.c b/drivers/staging/android/ion/ion_carveout_heap.c
index e0e360f..1419a89 100644
--- a/drivers/staging/android/ion/ion_carveout_heap.c
+++ b/drivers/staging/android/ion/ion_carveout_heap.c
@@ -30,10 +30,10 @@
 struct ion_carveout_heap {
 	struct ion_heap heap;
 	struct gen_pool *pool;
-	ion_phys_addr_t base;
+	phys_addr_t base;
 };
 
-static ion_phys_addr_t ion_carveout_allocate(struct ion_heap *heap,
+static phys_addr_t ion_carveout_allocate(struct ion_heap *heap,
 					     unsigned long size)
 {
 	struct ion_carveout_heap *carveout_heap =
@@ -46,7 +46,7 @@ static ion_phys_addr_t ion_carveout_allocate(struct ion_heap *heap,
 	return offset;
 }
 
-static void ion_carveout_free(struct ion_heap *heap, ion_phys_addr_t addr,
+static void ion_carveout_free(struct ion_heap *heap, phys_addr_t addr,
 			      unsigned long size)
 {
 	struct ion_carveout_heap *carveout_heap =
@@ -63,7 +63,7 @@ static int ion_carveout_heap_allocate(struct ion_heap *heap,
 				      unsigned long flags)
 {
 	struct sg_table *table;
-	ion_phys_addr_t paddr;
+	phys_addr_t paddr;
 	int ret;
 
 	table = kmalloc(sizeof(*table), GFP_KERNEL);
@@ -96,7 +96,7 @@ static void ion_carveout_heap_free(struct ion_buffer *buffer)
 	struct ion_heap *heap = buffer->heap;
 	struct sg_table *table = buffer->sg_table;
 	struct page *page = sg_page(table->sgl);
-	ion_phys_addr_t paddr = PFN_PHYS(page_to_pfn(page));
+	phys_addr_t paddr = PFN_PHYS(page_to_pfn(page));
 
 	ion_heap_buffer_zero(buffer);
 
diff --git a/drivers/staging/android/ion/ion_chunk_heap.c b/drivers/staging/android/ion/ion_chunk_heap.c
index 46e13f6..606f25f 100644
--- a/drivers/staging/android/ion/ion_chunk_heap.c
+++ b/drivers/staging/android/ion/ion_chunk_heap.c
@@ -27,7 +27,7 @@
 struct ion_chunk_heap {
 	struct ion_heap heap;
 	struct gen_pool *pool;
-	ion_phys_addr_t base;
+	phys_addr_t base;
 	unsigned long chunk_size;
 	unsigned long size;
 	unsigned long allocated;
@@ -151,8 +151,8 @@ struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data)
 	chunk_heap->heap.ops = &chunk_heap_ops;
 	chunk_heap->heap.type = ION_HEAP_TYPE_CHUNK;
 	chunk_heap->heap.flags = ION_HEAP_FLAG_DEFER_FREE;
-	pr_debug("%s: base %lu size %zu \n", __func__,
-		 chunk_heap->base, heap_data->size);
+	pr_debug("%s: base %pa size %zu \n", __func__,
+		 &chunk_heap->base, heap_data->size);
 
 	return &chunk_heap->heap;
 
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index c69d0bd..03b554f 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -343,9 +343,9 @@ struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data)
 	}
 
 	if (IS_ERR_OR_NULL(heap)) {
-		pr_err("%s: error creating heap %s type %d base %lu size %zu\n",
+		pr_err("%s: error creating heap %s type %d base %pa size %zu\n",
 		       __func__, heap_data->name, heap_data->type,
-		       heap_data->base, heap_data->size);
+		       &heap_data->base, heap_data->size);
 		return ERR_PTR(-EINVAL);
 	}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
