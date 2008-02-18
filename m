From: David Howells <dhowells@redhat.com>
Subject: Slab initialisation problems on MN10300
Date: Mon, 18 Feb 2008 16:07:43 +0000
Message-ID: <16085.1203350863@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com, penberg@cs.helsinki.fi, mpm@selenic.com
Cc: dhowells@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm running into a BUG_ON() when trying to boot an MN10300 arch kernel.  The
kernel is UP, non-NUMA and is using SLAB.  With gdb attached to the kernel, I
see the following backtrace:

	(gdb) bt
	#0  0x90258041 in setup_cpu_cache (cachep=0x93c00130) at mm/slab.c:2103
	#1  0x900977d7 in kmem_cache_create (name=0x9026de9d "size-64", size=64, align=16, flags=270336, 
	    ctor=0) at mm/slab.c:2384
	#2  0x9029e959 in kmem_cache_init () at mm/slab.c:1548
	#3  0x902987aa in start_kernel () at init/main.c:618
	#4  0x9000122f in __no_parameters () at arch/mn10300/kernel/head.S:209
	#5  0x9000122f in __no_parameters () at arch/mn10300/kernel/head.S:209

The offending line is this:

		} else {
			int node;
			for_each_online_node(node) {
				cachep->nodelists[node] =
				    kmalloc_node(sizeof(struct kmem_list3),
						GFP_KERNEL, node);
  >>>>>>			BUG_ON(!cachep->nodelists[node]);
				kmem_list3_init(cachep->nodelists[node]);
			}
		}

This is line 2103 of mm/slab.c in setup_cpu_cache().

Using gdb, I can see that node is 0 and cachep->nodelists[0] is NULL before
the kmalloc_node().

Looking in malloc_sizes[], I see:

	(gdb) p malloc_sizes[0]
	$18 = {cs_size = 0x20, cs_cachep = 0x93c000e0}
	(gdb) p malloc_sizes[1]
	$19 = {cs_size = 0x40, cs_cachep = 0x0}
	(gdb) p malloc_sizes[2]
	$20 = {cs_size = 0x60, cs_cachep = 0x0}
	(gdb) p malloc_sizes[3]
	$21 = {cs_size = 0x80, cs_cachep = 0x0}

and sizeof(struct kmem_list3) is 52, which is going to get rounded up to 64 by
kmalloc_node().  This means that it's going to attempt to allocate out of the
64-byte kmalloc slab, which is what the kernel is currently setting up, so the
allocation fails.

I have to wonder if this comment in setup_cpu_cache() is actually correct:

		/*
		 * Note: the first kmem_cache_create must create the cache
		 * that's used by kmalloc(24), otherwise the creation of
		 * further caches will BUG().
		 */

Perhaps it's no longer 24, but something bigger.  The first pass through
setup_cpu_cache() is done for the 32-byte kmalloc slab, with g_cpucache_up set
to NONE.  The second pass is done for the 64-byte kmalloc slab with
g_cpucache_up set to PARTIAL_L3.  It is the second pass that fails.

The first pass is special cased.  malloc_sizes[0]->cs_cachep is set after the
first pass.

The second pass calls kmalloc() on sizeof(struct arraycache_init), which is 20
and succeeds.  It then calls kmalloc_node() on sizeof(struct kmem_list3),
which is 52 and fails.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
