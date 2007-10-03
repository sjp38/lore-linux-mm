Date: Tue, 2 Oct 2007 17:37:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: kswapd min order, slub max order [was Re: -mm merge plans for
 2.6.24]
In-Reply-To: <Pine.LNX.4.64.0710021120220.30615@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0710021732520.32678@schroedinger.engr.sgi.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
 <1191350333.2708.6.camel@localhost> <Pine.LNX.4.64.0710021120220.30615@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007, Christoph Lameter wrote:

> The maximum order of allocation used by SLUB may have to depend on the 
> number of page structs in the system since small systems (128M was the 
> case that Peter found) can easier get into trouble. SLAB has similar 
> measures to avoid order 1 allocations for small systems below 32M.

A patch like this? This is based on the number of page structs on the 
system. Maybe it needs to be based on the number of MAX_ORDER blocks
for antifrag?


SLUB: Determine slub_max_order depending on the number of pages available

Determine the maximum order to be used for slabs and the mininum
desired number of objects in a slab from the amount of pages that
a system has available (like SLAB does for the order 1/0 distinction).

For systems with less than 128M only use order 0 allocations (SLAB does 
that for <32M only). The order 0 config is useful for small systems to 
minimize the memory used. Memory easily fragments since we have less than 
32k pages to play with. Order 0 insures that higher order allocations are 
minimized (Larger orders must still be used for objects that do not fit 
into order 0 pages).

Then step up to order 1 for systems < 256000 pages (1G)

Order 2 limit to systems < 1000000 page structs (4G)

Order 3 for systems larger than that.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-02 09:26:16.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-02 16:40:22.000000000 -0700
@@ -153,25 +153,6 @@ static inline void ClearSlabDebug(struct
 /* Enable to test recovery from slab corruption on boot */
 #undef SLUB_RESILIENCY_TEST
 
-#if PAGE_SHIFT <= 12
-
-/*
- * Small page size. Make sure that we do not fragment memory
- */
-#define DEFAULT_MAX_ORDER 1
-#define DEFAULT_MIN_OBJECTS 4
-
-#else
-
-/*
- * Large page machines are customarily able to handle larger
- * page orders.
- */
-#define DEFAULT_MAX_ORDER 2
-#define DEFAULT_MIN_OBJECTS 8
-
-#endif
-
 /*
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
@@ -1718,8 +1699,9 @@ static struct page *get_object_page(cons
  * take the list_lock.
  */
 static int slub_min_order;
-static int slub_max_order = DEFAULT_MAX_ORDER;
-static int slub_min_objects = DEFAULT_MIN_OBJECTS;
+static int slub_max_order;
+static int slub_min_objects = 4;
+static int manual;
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
@@ -2237,7 +2219,7 @@ static struct kmem_cache *kmalloc_caches
 static int __init setup_slub_min_order(char *str)
 {
 	get_option (&str, &slub_min_order);
-
+	manual = 1;
 	return 1;
 }
 
@@ -2246,7 +2228,7 @@ __setup("slub_min_order=", setup_slub_mi
 static int __init setup_slub_max_order(char *str)
 {
 	get_option (&str, &slub_max_order);
-
+	manual = 1;
 	return 1;
 }
 
@@ -2255,7 +2237,7 @@ __setup("slub_max_order=", setup_slub_ma
 static int __init setup_slub_min_objects(char *str)
 {
 	get_option (&str, &slub_min_objects);
-
+	manual = 1;
 	return 1;
 }
 
@@ -2566,6 +2548,16 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+/*
+ * Table to autotune the maximum slab order based on the number of pages
+ * that the system has available.
+ */
+static unsigned long __initdata phys_pages_for_order[PAGE_ALLOC_COSTLY_ORDER] = {
+	32768,		/* >128M if using 4K pages, >512M (16k), >2G (64k) */
+	256000,		/* >1G if using 4k pages, >4G (16k), >16G (64k) */
+	1000000		/* >4G if using 4k pages, >16G (16k), >64G (64k) */
+};
+
 /********************************************************************
  *			Basic setup of slabs
  *******************************************************************/
@@ -2575,6 +2567,15 @@ void __init kmem_cache_init(void)
 	int i;
 	int caches = 0;
 
+	if (!manual) {
+		/* No manual parameters. Autotune for system */
+		for (i = 0; i < PAGE_ALLOC_COSTLY_ORDER; i++)
+			if (num_physpages > phys_pages_for_order[i]) {
+				slub_max_order++;
+				slub_min_objects <<= 1;
+			}
+	}
+
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
