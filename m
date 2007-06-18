Message-Id: <20070618095913.634860091@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:39 -0700
From: clameter@sgi.com
Subject: [patch 01/26] SLUB Debug: Fix initial object debug state of NUMA bootstrap objects
Content-Disposition: inline; filename=fix_numa_boostrap_debug
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

The function we are calling to initialize object debug state during early
NUMA bootstrap sets up an inactive object giving it the wrong redzone
signature. The bootstrap nodes are active objects and should have active redzone
signatures.

Currently slab validation complains and reverts the object to active state.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 23:51:43.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-18 00:40:04.000000000 -0700
@@ -1925,7 +1925,8 @@ static struct kmem_cache_node * __init e
 	page->freelist = get_freepointer(kmalloc_caches, n);
 	page->inuse++;
 	kmalloc_caches->node[node] = n;
-	setup_object_debug(kmalloc_caches, page, n);
+	init_object(kmalloc_caches, n, 1);
+	init_tracking(kmalloc_caches, n);
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
 	add_partial(n, page);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
