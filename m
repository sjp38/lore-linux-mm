Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC016B006C
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 03:22:26 -0400 (EDT)
Received: by igal13 with SMTP id l13so18560877iga.0
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:22:26 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id a40si3270531ioj.29.2015.03.09.00.22.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 00:22:25 -0700 (PDT)
Received: by igbhl2 with SMTP id hl2so18515752igb.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:22:25 -0700 (PDT)
Date: Mon, 9 Mar 2015 00:22:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, mempool: poison elements backed by page allocator
In-Reply-To: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503090022090.19148@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Elements backed by the slab allocator are poisoned when added to a
mempool's reserved pool.

It is also possible to poison elements backed by the page allocator
because the mempool layer knows the allocation order.

This patch extends mempool element poisoning to include memory backed by
the page allocator.

This is only effective for configs with CONFIG_DEBUG_VM.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempool.c | 74 ++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 49 insertions(+), 25 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -6,6 +6,7 @@
  *  extreme VM load.
  *
  *  started by Ingo Molnar, Copyright (C) 2001
+ *  debugging by David Rientjes, Copyright (C) 2015
  */
 
 #include <linux/mm.h>
@@ -34,41 +35,64 @@ static void poison_error(mempool_t *pool, void *element, size_t size,
 	dump_stack();
 }
 
-static void check_slab_element(mempool_t *pool, void *element)
+static void __check_element(mempool_t *pool, void *element, size_t size)
 {
-	if (pool->free == mempool_free_slab || pool->free == mempool_kfree) {
-		size_t size = ksize(element);
-		u8 *obj = element;
-		size_t i;
-
-		for (i = 0; i < size; i++) {
-			u8 exp = (i < size - 1) ? POISON_FREE : POISON_END;
-
-			if (obj[i] != exp) {
-				poison_error(pool, element, size, i);
-				return;
-			}
+	u8 *obj = element;
+	size_t i;
+
+	for (i = 0; i < size; i++) {
+		u8 exp = (i < size - 1) ? POISON_FREE : POISON_END;
+
+		if (obj[i] != exp) {
+			poison_error(pool, element, size, i);
+			return;
 		}
-		memset(obj, POISON_INUSE, size);
+	}
+	memset(obj, POISON_INUSE, size);
+}
+
+static void check_element(mempool_t *pool, void *element)
+{
+	/* Mempools backed by slab allocator */
+	if (pool->free == mempool_free_slab || pool->free == mempool_kfree)
+		__check_element(pool, element, ksize(element));
+
+	/* Mempools backed by page allocator */
+	if (pool->free == mempool_free_pages) {
+		int order = (int)(long)pool->pool_data;
+		void *addr = page_address(element);
+
+		__check_element(pool, addr, 1UL << (PAGE_SHIFT + order));
 	}
 }
 
-static void poison_slab_element(mempool_t *pool, void *element)
+static void __poison_element(void *element, size_t size)
 {
-	if (pool->alloc == mempool_alloc_slab ||
-	    pool->alloc == mempool_kmalloc) {
-		size_t size = ksize(element);
-		u8 *obj = element;
+	u8 *obj = element;
+
+	memset(obj, POISON_FREE, size - 1);
+	obj[size - 1] = POISON_END;
+}
+
+static void poison_element(mempool_t *pool, void *element)
+{
+	/* Mempools backed by slab allocator */
+	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
+		__poison_element(element, ksize(element));
+
+	/* Mempools backed by page allocator */
+	if (pool->alloc == mempool_alloc_pages) {
+		int order = (int)(long)pool->pool_data;
+		void *addr = page_address(element);
 
-		memset(obj, POISON_FREE, size - 1);
-		obj[size - 1] = POISON_END;
+		__poison_element(addr, 1UL << (PAGE_SHIFT + order));
 	}
 }
 #else /* CONFIG_DEBUG_VM */
-static inline void check_slab_element(mempool_t *pool, void *element)
+static inline void check_element(mempool_t *pool, void *element)
 {
 }
-static inline void poison_slab_element(mempool_t *pool, void *element)
+static inline void poison_element(mempool_t *pool, void *element)
 {
 }
 #endif /* CONFIG_DEBUG_VM */
@@ -76,7 +100,7 @@ static inline void poison_slab_element(mempool_t *pool, void *element)
 static void add_element(mempool_t *pool, void *element)
 {
 	BUG_ON(pool->curr_nr >= pool->min_nr);
-	poison_slab_element(pool, element);
+	poison_element(pool, element);
 	pool->elements[pool->curr_nr++] = element;
 }
 
@@ -85,7 +109,7 @@ static void *remove_element(mempool_t *pool)
 	void *element = pool->elements[--pool->curr_nr];
 
 	BUG_ON(pool->curr_nr < 0);
-	check_slab_element(pool, element);
+	check_element(pool, element);
 	return element;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
