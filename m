Message-Id: <20070427042908.236098804@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:26:59 -0700
From: clameter@sgi.com
Subject: [patch 04/10] SLUB: Conform more to SLABs SLAB_HWCACHE_ALIGN behavior
Content-Disposition: inline; filename=slub_hwalign
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB is using a strict L1_CACHE_BYTES alignment if
SLAB_HWCACHE_ALIGN is specified. SLAB does not align to a cacheline if the
object is smaller than half of a cacheline. Small objects are then aligned
by SLAB to a fraction of a cacheline.

Make SLUB just forget about the alignment requirement if the object size
is less than L1_CACHE_BYTES. It seems that fractional alignments are no
good because they grow the object and reduce the object density in a cache
line needlessly causing additional cache line fetches.

If we are already throwing the user suggestion of a cache line alignment
away then lets do the best we can. Maybe SLAB_HWCACHE_ALIGN also needs
to be tossed given its wishy-washy handling but doing so would require
an audit of all kmem_cache_allocs throughout the kernel source.

In any case one needs to explictly specify an alignment during
kmem_cache_create to either slab allocator in order to ensure that the
objects are cacheline aligned.

[Patch has a nice memory compaction effect on 32 bit platforms]

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 11:41:15.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 11:41:43.000000000 -0700
@@ -1483,9 +1483,19 @@ static int calculate_order(int size)
  * various ways of specifying it.
  */
 static unsigned long calculate_alignment(unsigned long flags,
-		unsigned long align)
+		unsigned long align, unsigned long size)
 {
-	if (flags & SLAB_HWCACHE_ALIGN)
+	/*
+	 * If the user wants hardware cache aligned objects then
+	 * follow that suggestion if the object is sufficiently
+	 * large.
+	 *
+	 * The hardware cache alignment cannot override the
+	 * specified alignment though. If that is greater
+	 * then use it.
+	 */
+	if ((flags & SLAB_HWCACHE_ALIGN) &&
+			size > L1_CACHE_BYTES / 2)
 		return max_t(unsigned long, align, L1_CACHE_BYTES);
 
 	if (align < ARCH_SLAB_MINALIGN)
@@ -1674,7 +1684,7 @@ static int calculate_sizes(struct kmem_c
 	 * user specified (this is unecessarily complex due to the attempt
 	 * to be compatible with SLAB. Should be cleaned up some day).
 	 */
-	align = calculate_alignment(flags, align);
+	align = calculate_alignment(flags, align, s->objsize);
 
 	/*
 	 * SLUB stores one object immediately after another beginning from
@@ -2251,7 +2261,7 @@ static struct kmem_cache *find_mergeable
 		return NULL;
 
 	size = ALIGN(size, sizeof(void *));
-	align = calculate_alignment(flags, align);
+	align = calculate_alignment(flags, align, size);
 	size = ALIGN(size, align);
 
 	list_for_each(h, &slab_caches) {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
