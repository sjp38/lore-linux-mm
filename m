Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDEC6B0070
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:09:35 -0400 (EDT)
Received: by igcau2 with SMTP id au2so60898624igc.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:09:35 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id s5si968278icb.10.2015.03.24.16.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 16:09:35 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so86446064igb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:09:35 -0700 (PDT)
Date: Tue, 24 Mar 2015 16:09:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 3/4] mm, mempool: poison elements backed by slab
 allocator
In-Reply-To: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503241609140.21805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

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

This is only effective for configs with CONFIG_DEBUG_SLAB or
CONFIG_SLUB_DEBUG_ON.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: switch dependency to CONFIG_DEBUG_SLAB or CONFIG_SLUB_DEBUG_ON

 mm/mempool.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -17,16 +17,77 @@
 #include <linux/writeback.h>
 #include "slab.h"
 
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB_DEBUG_ON)
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
+#else /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
+static inline void check_slab_element(mempool_t *pool, void *element)
+{
+}
+static inline void poison_slab_element(mempool_t *pool, void *element)
+{
+}
+#endif /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
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
