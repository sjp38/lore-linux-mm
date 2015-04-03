Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BD1696B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 10:48:04 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so123732652pdb.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 07:48:04 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id uz3si12241957pbc.116.2015.04.03.07.48.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 03 Apr 2015 07:48:03 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM800M2ZJYQIO50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Apr 2015 15:52:02 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] mm, mempool: kasan: poison mempool elements
Date: Fri, 03 Apr 2015 17:47:47 +0300
Message-id: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, David Rientjes <rientjes@google.com>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, Dmitry Chernenkov <drcheren@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

Mempools keep allocated objects in reserved for situations
when ordinary allocation may not be possible to satisfy.
These objects shouldn't be accessed before they leave
the pool.
This patch poison elements when get into the pool
and unpoison when they leave it. This will let KASan
to detect use-after-free of mempool's elements.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/kasan.h |  2 ++
 mm/kasan/kasan.c      | 13 +++++++++++++
 mm/mempool.c          | 23 +++++++++++++++++++++++
 3 files changed, 38 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5bb0744..5486d77 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -44,6 +44,7 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size);
 void kasan_kfree_large(const void *ptr);
+void kasan_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size);
 void kasan_krealloc(const void *object, size_t new_size);
 
@@ -71,6 +72,7 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size) {}
 static inline void kasan_kfree_large(const void *ptr) {}
+static inline void kasan_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size) {}
 static inline void kasan_krealloc(const void *object, size_t new_size) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 936d816..6c513a6 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -389,6 +389,19 @@ void kasan_krealloc(const void *object, size_t size)
 		kasan_kmalloc(page->slab_cache, object, size);
 }
 
+void kasan_kfree(void *ptr)
+{
+	struct page *page;
+
+	page = virt_to_head_page(ptr);
+
+	if (unlikely(!PageSlab(page)))
+		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
+				KASAN_FREE_PAGE);
+	else
+		kasan_slab_free(page->slab_cache, ptr);
+}
+
 void kasan_kfree_large(const void *ptr)
 {
 	struct page *page = virt_to_page(ptr);
diff --git a/mm/mempool.c b/mm/mempool.c
index acd597f..f884e24 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -11,6 +11,7 @@
 
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/kasan.h>
 #include <linux/kmemleak.h>
 #include <linux/export.h>
 #include <linux/mempool.h>
@@ -100,10 +101,31 @@ static inline void poison_element(mempool_t *pool, void *element)
 }
 #endif /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
 
+static void kasan_poison_element(mempool_t *pool, void *element)
+{
+	if (pool->alloc == mempool_alloc_slab)
+		kasan_slab_free(pool->pool_data, element);
+	if (pool->alloc == mempool_kmalloc)
+		kasan_kfree(element);
+	if (pool->alloc == mempool_alloc_pages)
+		kasan_free_pages(element, (unsigned long)pool->pool_data);
+}
+
+static void kasan_unpoison_element(mempool_t *pool, void *element)
+{
+	if (pool->alloc == mempool_alloc_slab)
+		kasan_slab_alloc(pool->pool_data, element);
+	if (pool->alloc == mempool_kmalloc)
+		kasan_krealloc(element, (size_t)pool->pool_data);
+	if (pool->alloc == mempool_alloc_pages)
+		kasan_alloc_pages(element, (unsigned long)pool->pool_data);
+}
+
 static void add_element(mempool_t *pool, void *element)
 {
 	BUG_ON(pool->curr_nr >= pool->min_nr);
 	poison_element(pool, element);
+	kasan_poison_element(pool, element);
 	pool->elements[pool->curr_nr++] = element;
 }
 
@@ -113,6 +135,7 @@ static void *remove_element(mempool_t *pool)
 
 	BUG_ON(pool->curr_nr < 0);
 	check_element(pool, element);
+	kasan_unpoison_element(pool, element);
 	return element;
 }
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
