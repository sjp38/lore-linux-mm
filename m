Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA1A86B0038
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:05:58 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so182128813wgs.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:05:58 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id k8si16518067wia.75.2015.04.20.08.05.56
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 08:05:57 -0700 (PDT)
From: Daniel Sanders <daniel.sanders@imgtec.com>
Subject: [PATCH v5] slab: Correct size_index table before replacing the bootstrap kmem_cache_node.
Date: Mon, 20 Apr 2015 16:05:35 +0100
Message-ID: <1429542335-8379-1-git-send-email-daniel.sanders@imgtec.com>
In-Reply-To: <1424791511-11407-2-git-send-email-daniel.sanders@imgtec.com>
References: <1424791511-11407-2-git-send-email-daniel.sanders@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Daniel Sanders <daniel.sanders@imgtec.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch moves the initialization of the size_index table slightly
earlier so that the first few kmem_cache_node's can be safely allocated
when KMALLOC_MIN_SIZE is large.

There are currently two ways to generate indices into kmalloc_caches
(via kmalloc_index() and via the size_index table in slab_common.c)
and on some arches (possibly only MIPS) they potentially disagree with
each other until create_kmalloc_caches() has been called. It seems
that the intention is that the size_index table is a fast equivalent
to kmalloc_index() and that create_kmalloc_caches() patches the table
to return the correct value for the cases where kmalloc_index()'s
if-statements apply.

The failing sequence was:
* kmalloc_caches contains NULL elements
* kmem_cache_init initialises the element that 'struct
  kmem_cache_node' will be allocated to. For 32-bit Mips, this is a
  56-byte struct and kmalloc_index returns KMALLOC_SHIFT_LOW (7).
* init_list is called which calls kmalloc_node to allocate a 'struct
  kmem_cache_node'.
* kmalloc_slab selects the kmem_caches element using
  size_index[size_index_elem(size)]. For MIPS, size is 56, and the
  expression returns 6.
* This element of kmalloc_caches is NULL and allocation fails.
* If it had not already failed, it would have called
  create_kmalloc_caches() at this point which would have changed
  size_index[size_index_elem(size)] to 7.

Signed-off-by: Daniel Sanders <daniel.sanders@imgtec.com>
Acked-by: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
v2 renamed correct_kmalloc_cache_index_table() to
setup_kmalloc_cache_index_table() as requested.

v3 has no changes but adds this background information:
I don't believe the bug to be LLVM specific but GCC doesn't normally encounter
the problem. I haven't been able to identify exactly what GCC is doing better
(probably inlining) but it seems that GCC is managing to optimize to the point
that it eliminates the problematic allocations. This theory is supported by the
fact that GCC can be made to fail in the same way by changing inline, __inline,
__inline__, and __always_inline in include/linux/compiler-gcc.h such that they
don't actually inline things.

v4 refreshes the patch.

v5 refreshes the patch and drops the '1/4' from the subject since the other
patches in the series have been merged.

 mm/slab.c        |  1 +
 mm/slab.h        |  1 +
 mm/slab_common.c | 36 +++++++++++++++++++++---------------
 mm/slub.c        |  1 +
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd..200e224 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1454,6 +1454,7 @@ void __init kmem_cache_init(void)
 	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 	slab_state = PARTIAL_NODE;
+	setup_kmalloc_cache_index_table();
 
 	slab_early_init = 0;
 
diff --git a/mm/slab.h b/mm/slab.h
index 4c3ac12..8da63e4 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -71,6 +71,7 @@ unsigned long calculate_alignment(unsigned long flags,
 
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
+void setup_kmalloc_cache_index_table(void);
 void create_kmalloc_caches(unsigned long);
 
 /* Find the kmalloc slab corresponding for a certain size */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb34..c7c6c33 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -784,25 +784,20 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 }
 
 /*
- * Create the kmalloc array. Some of the regular kmalloc arrays
- * may already have been created because they were needed to
- * enable allocations for slab creation.
+ * Patch up the size_index table if we have strange large alignment
+ * requirements for the kmalloc array. This is only the case for
+ * MIPS it seems. The standard arches will not generate any code here.
+ *
+ * Largest permitted alignment is 256 bytes due to the way we
+ * handle the index determination for the smaller caches.
+ *
+ * Make sure that nothing crazy happens if someone starts tinkering
+ * around with ARCH_KMALLOC_MINALIGN
  */
-void __init create_kmalloc_caches(unsigned long flags)
+void __init setup_kmalloc_cache_index_table(void)
 {
 	int i;
 
-	/*
-	 * Patch up the size_index table if we have strange large alignment
-	 * requirements for the kmalloc array. This is only the case for
-	 * MIPS it seems. The standard arches will not generate any code here.
-	 *
-	 * Largest permitted alignment is 256 bytes due to the way we
-	 * handle the index determination for the smaller caches.
-	 *
-	 * Make sure that nothing crazy happens if someone starts tinkering
-	 * around with ARCH_KMALLOC_MINALIGN
-	 */
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
@@ -833,6 +828,17 @@ void __init create_kmalloc_caches(unsigned long flags)
 		for (i = 128 + 8; i <= 192; i += 8)
 			size_index[size_index_elem(i)] = 8;
 	}
+}
+
+/*
+ * Create the kmalloc array. Some of the regular kmalloc arrays
+ * may already have been created because they were needed to
+ * enable allocations for slab creation.
+ */
+void __init create_kmalloc_caches(unsigned long flags)
+{
+	int i;
+
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i]) {
 			kmalloc_caches[i] = create_kmalloc_cache(NULL,
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..816df00 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3700,6 +3700,7 @@ void __init kmem_cache_init(void)
 	kmem_cache_node = bootstrap(&boot_kmem_cache_node);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
+	setup_kmalloc_cache_index_table();
 	create_kmalloc_caches(0);
 
 #ifdef CONFIG_SMP
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
