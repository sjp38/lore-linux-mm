Date: Tue, 10 Apr 2007 16:17:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101616020.424@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> calculate_order() is an important function.  The mapping between
> object-size and what-size-slab-will-use is something which regularly comes
> up, as it affects the reliability of the allocations of those objects, and
> their cost, and their page allocator fragmentation effects, etc.  Hence I
> think calculate_order() needs comprehensive commenting.  Rather than none ;)

SLUB: explain sizing of slabs in detail

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 15:55:34.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 16:15:20.000000000 -0700
@@ -1403,6 +1403,27 @@ static int slub_debug;
 
 static char *slub_debug_slabs;
 
+/*
+ * Calculate the order of allocation given an slab object size.
+ *
+ * The order of allocation has significant impact on other elements
+ * of the system. Generally order 0 allocations should be preferred
+ * since they do not cause fragmentation in the page allocator. Larger
+ * objects may have problems with order 0 because there may be too much
+ * space left unused in a slab. We go to a higher order if more than 1/8th
+ * of the slab would be wasted.
+ *
+ * In order to reach satisfactory performance we must insure that
+ * a minimum number of objects is in one slab. Otherwise we may
+ * generate too much activity on the partial lists. This is less a
+ * concern for large slabs though. slub_max_order specified the order
+ * where we begin to stop considering the number of objects in a slab.
+ *
+ * Higher order allocations also allow the placement of more objects
+ * in a slab and thereby reduce object handling overhead. If the user
+ * has requested a higher mininum order then we start with that one
+ * instead of zero.
+ */
 static int calculate_order(int size)
 {
 	int order;
@@ -1430,6 +1451,10 @@ static int calculate_order(int size)
 	return order;
 }
 
+/*
+ * Function to figure out which alignment to use from the
+ * various ways of specifying it.
+ */
 static unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align)
 {
@@ -1543,28 +1568,48 @@ static int init_kmem_cache_nodes(struct 
 }
 #endif
 
+/*
+ * calculate_sizes() determines the order and the distribution of data within
+ * a slab object.
+ */
 static int calculate_sizes(struct kmem_cache *s)
 {
 	unsigned long flags = s->flags;
 	unsigned long size = s->objsize;
 	unsigned long align = s->align;
 
+	/*
+	 * Determine if we can poison the object itself. If the user of
+	 * the slab may touch the object after free or before allocation
+	 * then we should never poison the object itself.
+	 */
 	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
 			!s->ctor && !s->dtor)
 		flags |= __OBJECT_POISON;
 	else
 		flags &= ~__OBJECT_POISON;
 
+	/*
+	 * Round up object size to the next word boundary. We can only
+	 * place the free pointer at word boundaries and this determines
+	 * the possible location of the free pointer.
+	 */
 	size = ALIGN(size, sizeof(void *));
 
 	/*
-	 * If we redzone then check if we have space through above
-	 * alignment. If not then add an additional word, so
-	 * that we have a guard value to check for overwrites.
+	 * If we redzone then check if we there is some space between the
+	 * end of the object and the free pointer. If not then add an
+	 * additional word, so that we can establish a redzone between
+	 * the object and the freepointer to be able to chek for overwrites.
 	 */
 	if ((flags & SLAB_RED_ZONE) && size == s->objsize)
 		size += sizeof(void *);
 
+	/*
+	 * With that we have determined how much of the slab is in actual
+	 * use by the object. This is the potential offset to the free
+	 * pointer.
+	 */
 	s->inuse = size;
 
 	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
@@ -1582,10 +1627,24 @@ static int calculate_sizes(struct kmem_c
 	}
 
 	if (flags & SLAB_STORE_USER)
+		/*
+		 * Need to store information about allocs and frees after
+		 * the object.
+		 */
 		size += 2 * sizeof(struct track);
 
+	/*
+	 * Determine the alignment based on various parameters that the
+	 * user specified (this is unecessarily complex due to the attempt
+	 * to be compatible with SLAB. Should be cleaned up some day).
+	 */
 	align = calculate_alignment(flags, align);
 
+	/*
+	 * SLUB stores one object immediately after another beginning from
+	 * offset 0. In order to align the objects we have to simply size
+	 * each object to conform to the alignment.
+	 */
 	size = ALIGN(size, align);
 	s->size = size;
 
@@ -1593,6 +1652,9 @@ static int calculate_sizes(struct kmem_c
 	if (s->order < 0)
 		return 0;
 
+	/*
+	 * Determine the number of objects per slab
+	 */
 	s->objects = (PAGE_SIZE << s->order) / size;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
