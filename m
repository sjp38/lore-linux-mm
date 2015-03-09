Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C9F896B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 03:21:58 -0400 (EDT)
Received: by iecrl12 with SMTP id rl12so17794164iec.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:21:58 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id u5si179249icv.40.2015.03.09.00.21.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 00:21:58 -0700 (PDT)
Received: by igal13 with SMTP id l13so18558697iga.0
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:21:58 -0700 (PDT)
Date: Mon, 9 Mar 2015 00:21:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, mempool: poison elements backed by slab allocator
Message-ID: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Mempools keep elements in a reserved pool for contexts in which
allocation may not be possible.  When an element is allocated from the
reserved pool, its memory contents is the same as when it was added to
the reserved pool.

Because of this, elements lack any free poisoning to detect
use-after-free errors.

This patch adds free poisoning for elements backed by the slab allocator.
This is possible because the mempool layer knows the object size of each
element.

When an element is added to the reserved pool, it is poisoned with
POISON_FREE.  When it is removed from the reserved pool, the contents are
checked for POISON_FREE.  If there is a mismatch, a warning is emitted to
the kernel log.

This is only effective for configs with CONFIG_DEBUG_VM.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempool.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -16,16 +16,77 @@
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
 
+#ifdef CONFIG_DEBUG_VM
+static void poison_error(mempool_t *pool, void *element, size_t size,
+			 size_t byte)
+{
+	const int nr = pool->curr_nr;
+	const int start = max_t(int, byte - (BITS_PER_LONG / 8), 0);
+	const int end = min_t(int, byte + (BITS_PER_LONG / 8), size);
+	int i;
+
+	pr_err("BUG: mempool element poison mismatch\n");
+	pr_err("Mempool %p size %ld\n", pool, size);
+	pr_err(" nr=%d @ %p: %s0x", nr, element, start > 0 ? "... " : "");
+	for (i = start; i < end; i++)
+		pr_cont("%x ", *(u8 *)(element + i));
+	pr_cont("%s\n", end < size ? "..." : "");
+	dump_stack();
+}
+
+static void check_slab_element(mempool_t *pool, void *element)
+{
+	if (pool->free == mempool_free_slab || pool->free == mempool_kfree) {
+		size_t size = ksize(element);
+		u8 *obj = element;
+		size_t i;
+
+		for (i = 0; i < size; i++) {
+			u8 exp = (i < size - 1) ? POISON_FREE : POISON_END;
+
+			if (obj[i] != exp) {
+				poison_error(pool, element, size, i);
+				return;
+			}
+		}
+		memset(obj, POISON_INUSE, size);
+	}
+}
+
+static void poison_slab_element(mempool_t *pool, void *element)
+{
+	if (pool->alloc == mempool_alloc_slab ||
+	    pool->alloc == mempool_kmalloc) {
+		size_t size = ksize(element);
+		u8 *obj = element;
+
+		memset(obj, POISON_FREE, size - 1);
+		obj[size - 1] = POISON_END;
+	}
+}
+#else /* CONFIG_DEBUG_VM */
+static inline void check_slab_element(mempool_t *pool, void *element)
+{
+}
+static inline void poison_slab_element(mempool_t *pool, void *element)
+{
+}
+#endif /* CONFIG_DEBUG_VM */
+
 static void add_element(mempool_t *pool, void *element)
 {
 	BUG_ON(pool->curr_nr >= pool->min_nr);
+	poison_slab_element(pool, element);
 	pool->elements[pool->curr_nr++] = element;
 }
 
 static void *remove_element(mempool_t *pool)
 {
-	BUG_ON(pool->curr_nr <= 0);
-	return pool->elements[--pool->curr_nr];
+	void *element = pool->elements[--pool->curr_nr];
+
+	BUG_ON(pool->curr_nr < 0);
+	check_slab_element(pool, element);
+	return element;
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
