Date: Wed, 22 Mar 2006 13:44:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Add gfp flag __GFP_POLICY to control policies and cpusets redirection
 of allocations
Message-ID: <Pine.LNX.4.64.0603221342170.24959@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: pj@sgi.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Note to Andrew: This patch replaces
	cpuset-alloc_pages_node-overrides-cpuset-constraints.patch
	cpuset-alloc_pages_node-overrides-cpuset-constraints-speedup.patch

Various subsystems manage their own locality (slab, block layer, device drivers)
and are rather sensitive to cpusets or memory policies interfering with their
operation. Also various kernel components rely on the ability to temporarily
allocate a page for a kernel thread. That page should be local to the process.

This patch introduces a flag __GFP_POLICY that can be specified to enable
cpusets and memory policy redirection to different nodes for alloc_pages()
and alloc_pages_node().

__GFP_POLICY is set by default for user space page allocations (GFP_USER and
GFP_HIGHUSER) but not for GFP_KERNEL which is used by device drivers and
other local uses of pages in the kernel.

The slab allocator does its own application of memory policies and cpuset
constraints based on SLAB_MEM_SPREAD flags. The patch just insures that the
page allocator does not apply additional policies after the slab allocator
has determined where memory should be allocated. This can happen f.e. if
a cpuset is active and then some kernel component tries to allocate
a new slab or grow the size of the slab.

vmalloc() and vmalloc_node() are exempted from policies since these are
typically used by device drivers for large memory allocations that should
be controlled by the device driver itself.

GFP_KERNEL does not have __GFP_POLICY set. Meaning that page allocations
with GFP_KERNEL are no longer subject to cpusets and policy constraints.
I have looked through the kernel for page allocation with GFP_KERNEL and 
the instance I have seen should not use policies.
(Note that slab allocations with GFP_KERNEL still perform as before).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16/include/linux/gfp.h
===================================================================
--- linux-2.6.16.orig/include/linux/gfp.h	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/include/linux/gfp.h	2006-03-22 13:25:02.000000000 -0800
@@ -47,6 +47,9 @@ struct vm_area_struct;
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_POLICY	((__force gfp_t)0x40000u) /* Allocation needs to obey memory policies
+						     and cpuset constraints */
+
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -55,16 +58,17 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_POLICY)
 
 /* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
+			 __GFP_POLICY)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
-			 __GFP_HIGHMEM)
+			 __GFP_HIGHMEM | __GFP_POLICY)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: linux-2.6.16/mm/slab.c
===================================================================
--- linux-2.6.16.orig/mm/slab.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/mm/slab.c	2006-03-22 13:25:02.000000000 -0800
@@ -1392,6 +1392,8 @@ static void *kmem_getpages(struct kmem_c
 	int i;
 
 	flags |= cachep->gfpflags;
+	flags &= ~__GFP_POLICY;
+
 	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page)
 		return NULL;
Index: linux-2.6.16/mm/vmalloc.c
===================================================================
--- linux-2.6.16.orig/mm/vmalloc.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/mm/vmalloc.c	2006-03-22 13:25:02.000000000 -0800
@@ -411,6 +411,9 @@ void *__vmalloc_area_node(struct vm_stru
 	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
+	/* Do not obey policy or cpuset constraints */
+	gfp_mask &= ~__GFP_POLICY;
+
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE)
Index: linux-2.6.16/kernel/cpuset.c
===================================================================
--- linux-2.6.16.orig/kernel/cpuset.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/kernel/cpuset.c	2006-03-22 13:25:02.000000000 -0800
@@ -2159,7 +2159,7 @@ int __cpuset_zone_allowed(struct zone *z
 	const struct cpuset *cs;	/* current cpuset ancestors */
 	int allowed = 1;		/* is allocation in zone z allowed? */
 
-	if (in_interrupt())
+	if (in_interrupt() || !(gfp_mask & __GFP_POLICY))
 		return 1;
 	node = z->zone_pgdat->node_id;
 	if (node_isset(node, current->mems_allowed))
Index: linux-2.6.16/mm/mempolicy.c
===================================================================
--- linux-2.6.16.orig/mm/mempolicy.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/mm/mempolicy.c	2006-03-22 13:25:02.000000000 -0800
@@ -1292,7 +1292,7 @@ struct page *alloc_pages_current(gfp_t g
 
 	if ((gfp & __GFP_WAIT) && !in_interrupt())
 		cpuset_update_task_memory_state();
-	if (!pol || in_interrupt())
+	if (!pol || in_interrupt() || !(gfp & __GFP_POLICY))
 		pol = &default_policy;
 	if (pol->policy == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
