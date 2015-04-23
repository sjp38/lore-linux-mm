Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C7F196B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:01:21 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so28203534pab.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:01:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hj2si14167542pbc.103.2015.04.23.14.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 14:01:20 -0700 (PDT)
Date: Thu, 23 Apr 2015 14:01:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm/slab_common: Support the slub_debug boot option
 on specific object size
Message-Id: <20150423140119.ef9480fd9561e23d0383dc06@linux-foundation.org>
In-Reply-To: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
References: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@rasmusvillemoes.dk, Daniel Sanders <daniel.sanders@imgtec.com>

On Thu, 23 Apr 2015 21:26:00 +0800 Gavin Guo <gavin.guo@canonical.com> wrote:

> The slub_debug=PU,kmalloc-xx cannot work because in the
> create_kmalloc_caches() the s->name is created after the
> create_kmalloc_cache() is called. The name is NULL in the
> create_kmalloc_cache() so the kmem_cache_flags() would not set the
> slub_debug flags to the s->flags. The fix here set up a kmalloc_names
> string array for the initialization purpose and delete the dynamic
> name creation of kmalloc_caches.

I suppose we should worry about the bug fix before the cleanups, so I'm
merging this.

I did this on top:

--- a/mm/slab_common.c
+++ a/mm/slab_common.c
@@ -784,14 +784,14 @@ struct kmem_cache *kmalloc_slab(size_t s
 }
 
 /*
- * The kmalloc_names is to make slub_debug=,kmalloc-xx option work in the boot
- * time. The kmalloc_index() support to 2^26=64MB. So, the final entry of the
- * table is kmalloc-67108864.
+ * kmalloc_info[] is to make slub_debug=,kmalloc-xx option work at boot time.
+ * kmalloc_index() supports up to 2^26=64MB, so the final entry of the table is
+ * kmalloc-67108864.
  */
 static struct {
 	const char *name;
 	unsigned long size;
-} const kmalloc_names[] __initconst = {
+} const kmalloc_info[] __initconst = {
 	{NULL,                      0},		{"kmalloc-96",             96},
 	{"kmalloc-192",           192},		{"kmalloc-8",               8},
 	{"kmalloc-16",             16},		{"kmalloc-32",             32},
@@ -861,8 +861,8 @@ void __init create_kmalloc_caches(unsign
 	for (i = KMALLOC_LOOP_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i]) {
 			kmalloc_caches[i] = create_kmalloc_cache(
-						kmalloc_names[i].name,
-						kmalloc_names[i].size,
+						kmalloc_info[i].name,
+						kmalloc_info[i].size,
 						flags);
 		}
 
_


This patch conflicts significantly with Daniel's "slab: correct
size_index table before replacing the bootstrap kmem_cache_node".  I've
reworked Daniel's patch as below.  Please review?

Regarding merge timing: coudl the slab developers please let me know
whether they believe that "slab: correct size_index table before
replacing the bootstrap kmem_cache_node" and/or "mm/slab_common:
support the slub_debug boot option on specific object size" should be
merged into 4.1?  -stable?

Thanks.


From: Daniel Sanders <daniel.sanders@imgtec.com>
Subject: slab: correct size_index table before replacing the bootstrap kmem_cache_node

This patch moves the initialization of the size_index table slightly
earlier so that the first few kmem_cache_node's can be safely allocated
when KMALLOC_MIN_SIZE is large.

There are currently two ways to generate indices into kmalloc_caches (via
kmalloc_index() and via the size_index table in slab_common.c) and on some
arches (possibly only MIPS) they potentially disagree with each other
until create_kmalloc_caches() has been called.  It seems that the
intention is that the size_index table is a fast equivalent to
kmalloc_index() and that create_kmalloc_caches() patches the table to
return the correct value for the cases where kmalloc_index()'s
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

I don't believe the bug to be LLVM specific but GCC doesn't normally
encounter the problem.  I haven't been able to identify exactly what GCC
is doing better (probably inlining) but it seems that GCC is managing to
optimize to the point that it eliminates the problematic allocations. 
This theory is supported by the fact that GCC can be made to fail in the
same way by changing inline, __inline, __inline__, and __always_inline in
include/linux/compiler-gcc.h such that they don't actually inline things.

Signed-off-by: Daniel Sanders <daniel.sanders@imgtec.com>
Acked-by: Pekka Enberg <penberg@kernel.org>
Acked-by: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slab.c        |    1 +
 mm/slab.h        |    1 +
 mm/slab_common.c |   36 +++++++++++++++++++++---------------
 mm/slub.c        |    1 +
 4 files changed, 24 insertions(+), 15 deletions(-)

diff -puN mm/slab.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node mm/slab.c
--- a/mm/slab.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node
+++ a/mm/slab.c
@@ -1454,6 +1454,7 @@ void __init kmem_cache_init(void)
 	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 	slab_state = PARTIAL_NODE;
+	setup_kmalloc_cache_index_table();
 
 	slab_early_init = 0;
 
diff -puN mm/slab.h~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node mm/slab.h
--- a/mm/slab.h~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node
+++ a/mm/slab.h
@@ -71,6 +71,7 @@ unsigned long calculate_alignment(unsign
 
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
+void setup_kmalloc_cache_index_table(void);
 void create_kmalloc_caches(unsigned long);
 
 /* Find the kmalloc slab corresponding for a certain size */
diff -puN mm/slab_common.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node mm/slab_common.c
--- a/mm/slab_common.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node
+++ a/mm/slab_common.c
@@ -809,25 +809,20 @@ static struct {
 };
 
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
 
@@ -858,6 +853,17 @@ void __init create_kmalloc_caches(unsign
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
 	for (i = KMALLOC_LOOP_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i]) {
 			kmalloc_caches[i] = create_kmalloc_cache(
diff -puN mm/slub.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node mm/slub.c
--- a/mm/slub.c~slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node
+++ a/mm/slub.c
@@ -3700,6 +3700,7 @@ void __init kmem_cache_init(void)
 	kmem_cache_node = bootstrap(&boot_kmem_cache_node);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
+	setup_kmalloc_cache_index_table();
 	create_kmalloc_caches(0);
 
 #ifdef CONFIG_SMP
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
