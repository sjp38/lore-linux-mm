Date: Sat, 9 Feb 2008 13:45:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB tbench regression due to page allocator deficiency
Message-ID: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

I have been chasing the tbench regression (1-4%) for two weeks now and 
even after I added statistics I could only verify that behavior was just 
optimal.

None of the tricks that I threw at the problem changed anything until I 
realized that the tbench load depends heavily on 4k allocations that SLUB 
hands off to the page allocator (SLAB handles 4k itself). I extended the 
kmalloc array to 4k and I got:

christoph@stapp:~$ slabinfo -AD
Name                   Objects    Alloc     Free   %Fast
:0004096                   180 665259550 665259415  99  99
skbuff_fclone_cache         46 665196592 665196592  99  99
:0000192                  2575 31232665 31230129  99  99
:0001024                   854 31204838 31204006  99  99
vm_area_struct            1093   108941   107954  91  17
dentry                    7738    26248    18544  92  43
:0000064                  2179    19208    17287  97  73

So the kmalloc-4096 is heavily used. If I give the 4k objects a reasonable 
allocation size in slub (PAGE_ALLOC_COSTLY_ORDER) then the fastpath of 
SLUB becomes effective for 4k allocs and then SLUB is faster than SLAB 
here.

Performance on tbench (Dual Quad 8p 8G):

SLAB		2223.32 MB/sec
SLUB unmodified	2144.36 MB/sec
SLUB+patch	2245.56 MB/sec (stats still active so this isnt optimal yet)

4k allocations cannot optimally be handled by SLUB if we are restricted to 
order 0 allocs because the fastpath only handles fractions of one 
allocation unit and if the allocation unit is 4k then we only have one 
object per slab.

Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
allocations in such a way that is competitive with the slab allocators? 
The cycle count for an allocation needs to be <100 not just below 1000 as 
it is now.

---
 include/linux/slub_def.h |    6 +++---
 mm/slub.c                |   25 +++++++++++++++++--------
 2 files changed, 20 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-09 13:04:48.464203968 -0800
+++ linux-2.6/include/linux/slub_def.h	2008-02-09 13:08:37.413120259 -0800
@@ -110,7 +110,7 @@ struct kmem_cache {
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[PAGE_SHIFT];
+extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1];
 
 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -191,7 +191,7 @@ void *__kmalloc(size_t size, gfp_t flags
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > PAGE_SIZE / 2)
+		if (size > PAGE_SIZE)
 			return (void *)__get_free_pages(flags | __GFP_COMP,
 							get_order(size));
 
@@ -214,7 +214,7 @@ void *kmem_cache_alloc_node(struct kmem_
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
-		size <= PAGE_SIZE / 2 && !(flags & SLUB_DMA)) {
+		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
 
 		if (!s)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-09 13:04:48.472203975 -0800
+++ linux-2.6/mm/slub.c	2008-02-09 13:14:43.786633258 -0800
@@ -1919,6 +1919,15 @@ static inline int calculate_order(int si
 	int fraction;
 
 	/*
+	 * Cover up bad performance of page allocator fastpath vs
+	 * slab allocator fastpaths. Take the largest order reasonable
+	 * in order to be able to avoid partial list overhead.
+	 *
+	 * This yields 8 4k objects per 32k slab allocation.
+	 */
+	if (size == PAGE_SIZE)
+		return PAGE_ALLOC_COSTLY_ORDER;
+	/*
 	 * Attempt to find best configuration for a slab. This
 	 * works by first attempting to generate a layout with
 	 * the best configuration and backing off gradually.
@@ -2484,11 +2493,11 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache kmalloc_caches[PAGE_SHIFT] __cacheline_aligned;
+struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT];
+static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT + 1];
 #endif
 
 static int __init setup_slub_min_order(char *str)
@@ -2670,7 +2679,7 @@ void *__kmalloc(size_t size, gfp_t flags
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE / 2))
+	if (unlikely(size > PAGE_SIZE))
 		return (void *)__get_free_pages(flags | __GFP_COMP,
 							get_order(size));
 
@@ -2688,7 +2697,7 @@ void *__kmalloc_node(size_t size, gfp_t 
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE / 2))
+	if (unlikely(size > PAGE_SIZE))
 		return (void *)__get_free_pages(flags | __GFP_COMP,
 							get_order(size));
 
@@ -3001,7 +3010,7 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
-	for (i = KMALLOC_SHIFT_LOW; i < PAGE_SHIFT; i++) {
+	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
 			"kmalloc", 1 << i, GFP_KERNEL);
 		caches++;
@@ -3028,7 +3037,7 @@ void __init kmem_cache_init(void)
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
-	for (i = KMALLOC_SHIFT_LOW; i < PAGE_SHIFT; i++)
+	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
 		kmalloc_caches[i]. name =
 			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
 
@@ -3218,7 +3227,7 @@ void *__kmalloc_track_caller(size_t size
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE / 2))
+	if (unlikely(size > PAGE_SIZE))
 		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
 							get_order(size));
 	s = get_slab(size, gfpflags);
@@ -3234,7 +3243,7 @@ void *__kmalloc_node_track_caller(size_t
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE / 2))
+	if (unlikely(size > PAGE_SIZE))
 		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
 							get_order(size));
 	s = get_slab(size, gfpflags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
