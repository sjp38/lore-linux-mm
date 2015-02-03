Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id E69BB6B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 08:37:42 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id b13so44493442wgh.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 05:37:42 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id mc8si42933356wjb.27.2015.02.03.05.37.41
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 05:37:41 -0800 (PST)
From: Daniel Sanders <daniel.sanders@imgtec.com>
Subject: [PATCH 1/5] LLVMLinux: Correct size_index table before replacing the bootstrap kmem_cache_node.
Date: Tue, 3 Feb 2015 13:37:15 +0000
Message-ID: <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
In-Reply-To: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
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
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/slab.c        |  1 +
 mm/slab.h        |  1 +
 mm/slab_common.c | 36 +++++++++++++++++++++---------------
 mm/slub.c        |  1 +
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 65b5dcb..6c93f28 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1440,6 +1440,7 @@ void __init kmem_cache_init(void)
 	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 	slab_state = PARTIAL_NODE;
+	correct_kmalloc_cache_index_table();
 
 	slab_early_init = 0;
 
diff --git a/mm/slab.h b/mm/slab.h
index 1cf40054..036c08d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -71,6 +71,7 @@ unsigned long calculate_alignment(unsigned long flags,
 
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
+void correct_kmalloc_cache_index_table(void);
 void create_kmalloc_caches(unsigned long);
 
 /* Find the kmalloc slab corresponding for a certain size */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e03dd6f..d2f7379 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -675,25 +675,20 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
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
+void __init correct_kmalloc_cache_index_table(void)
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
 
@@ -724,6 +719,17 @@ void __init create_kmalloc_caches(unsigned long flags)
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
index fe376fe..2217761 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3604,6 +3604,7 @@ void __init kmem_cache_init(void)
 	kmem_cache_node = bootstrap(&boot_kmem_cache_node);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
+	correct_kmalloc_cache_index_table();
 	create_kmalloc_caches(0);
 
 #ifdef CONFIG_SMP
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
