Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id D664C6B0072
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:10:03 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so11303220igb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:10:03 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id s2si357283icr.92.2015.03.24.16.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 16:10:03 -0700 (PDT)
Received: by igcau2 with SMTP id au2so86339137igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:10:03 -0700 (PDT)
Date: Tue, 24 Mar 2015 16:10:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
In-Reply-To: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

Elements backed by the slab allocator are poisoned when added to a
mempool's reserved pool.

It is also possible to poison elements backed by the page allocator
because the mempool layer knows the allocation order.

This patch extends mempool element poisoning to include memory backed by
the page allocator.

This is only effective for configs with CONFIG_DEBUG_SLAB or
CONFIG_SLUB_DEBUG_ON.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: modify commit message for new dependencies

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
@@ -35,41 +36,64 @@ static void poison_error(mempool_t *pool, void *element, size_t size,
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
 #else /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
-static inline void check_slab_element(mempool_t *pool, void *element)
+static inline void check_element(mempool_t *pool, void *element)
 {
 }
-static inline void poison_slab_element(mempool_t *pool, void *element)
+static inline void poison_element(mempool_t *pool, void *element)
 {
 }
 #endif /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
@@ -77,7 +101,7 @@ static inline void poison_slab_element(mempool_t *pool, void *element)
 static void add_element(mempool_t *pool, void *element)
 {
 	BUG_ON(pool->curr_nr >= pool->min_nr);
-	poison_slab_element(pool, element);
+	poison_element(pool, element);
 	pool->elements[pool->curr_nr++] = element;
 }
 
@@ -86,7 +110,7 @@ static void *remove_element(mempool_t *pool)
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
