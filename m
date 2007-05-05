Date: Sat, 5 May 2007 09:25:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Add support for dynamic cacheline size determination
Message-ID: <Pine.LNX.4.64.0705050924430.27112@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

SLUB currently assumes that the cacheline size is static. However,
i386 f.e. support dynamic cache line size determination.

Use cache_line_size() instead of L1_CACHE_BYTES in the allocator.

That also explains the purpose of SLAB_HWCACHE_ALIGN. So we will need
to keep that one around to allow dynamic aligning of objects depending
on boot determination of the cache line size.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-05 08:49:07.000000000 -0700
+++ slub/mm/slub.c	2007-05-05 09:19:32.000000000 -0700
@@ -1535,8 +1535,8 @@ static unsigned long calculate_alignment
 	 * then use it.
 	 */
 	if ((flags & SLAB_HWCACHE_ALIGN) &&
-			size > L1_CACHE_BYTES / 2)
-		return max_t(unsigned long, align, L1_CACHE_BYTES);
+			size > cache_line_size() / 2)
+		return max_t(unsigned long, align, cache_line_size());
 
 	if (align < ARCH_SLAB_MINALIGN)
 		return ARCH_SLAB_MINALIGN;
@@ -1721,8 +1721,8 @@ static int calculate_sizes(struct kmem_c
 		size += sizeof(void *);
 	/*
 	 * Determine the alignment based on various parameters that the
-	 * user specified (this is unecessarily complex due to the attempt
-	 * to be compatible with SLAB. Should be cleaned up some day).
+	 * user specified and the dynamic determination of cache line size
+	 * on bootup.
 	 */
 	align = calculate_alignment(flags, align, s->objsize);
 
@@ -2343,7 +2343,7 @@ void __init kmem_cache_init(void)
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" Processors=%d, Nodes=%d\n",
-		KMALLOC_SHIFT_HIGH, L1_CACHE_BYTES,
+		KMALLOC_SHIFT_HIGH, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
