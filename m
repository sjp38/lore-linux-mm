Date: Tue, 5 Aug 2008 00:39:36 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [RFC/PATCH] SLUB: dynamic per-cache MIN_PARTIAL
Message-ID: <Pine.LNX.4.64.0808050037400.26319@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Pekka Enberg <penberg@cs.helsinki.fi>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: matthew@wil.cx, akpm@linux-foundation.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This patch changes the static MIN_PARTIAL to a dynamic per-cache ->min_partial
value that is calculated from object size. The bigger the object size, the more
pages we keep on the partial list.

I tested SLAB, SLUB, and SLUB with this patch on Jens Axboe's 'netio' example
script of the fio benchmarking tool. The script stresses the networking
subsystem which should also give a fairly good beating of kmalloc() et al.

To run the test yourself, first clone the fio repository:

  git clone git://git.kernel.dk/fio.git

and then run the following command n times on your machine:

  time ./fio examples/netio

The results on my 2-way 64-bit x86 machine are as follows:

  [ the minimum, maximum, and average are captured from 50 individual runs ]

                 real time (seconds)
                 min      max      avg      sd
  SLAB           22.76    23.38    22.98    0.17
  SLUB           22.80    25.78    23.46    0.72
  SLUB (dynamic) 22.74    23.54    23.00    0.20    

                 sys time (seconds)
                 min      max      avg      sd
  SLAB           6.90     8.28     7.70     0.28
  SLUB           7.42     16.95    8.89     2.28
  SLUB (dynamic) 7.17     8.64     7.73     0.29    

                 user time (seconds)
                 min      max      avg      sd
  SLAB           36.89    38.11    37.50    0.29
  SLUB           30.85    37.99    37.06    1.67
  SLUB (dynamic) 36.75    38.07    37.59    0.32    

As you can see from the above numbers, this patch brings SLUB to the same level
as SLAB for this particular workload fixing a ~2% regression. I'd expect this
change to help similar workloads that allocate a lot of objects that are close
to the size of a page.

Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   26 +++++++++++++++++++-------
 2 files changed, 20 insertions(+), 7 deletions(-)

Index: slab-2.6/include/linux/slub_def.h
===================================================================
--- slab-2.6.orig/include/linux/slub_def.h	2008-08-05 00:35:42.000000000 +0300
+++ slab-2.6/include/linux/slub_def.h	2008-08-05 00:36:21.000000000 +0300
@@ -46,6 +46,7 @@
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
 	unsigned long nr_partial;
+	unsigned long min_partial;
 	struct list_head partial;
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
Index: slab-2.6/mm/slub.c
===================================================================
--- slab-2.6.orig/mm/slub.c	2008-08-05 00:35:42.000000000 +0300
+++ slab-2.6/mm/slub.c	2008-08-05 00:36:27.000000000 +0300
@@ -1329,7 +1329,7 @@
 		n = get_node(s, zone_to_nid(zone));
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
-				n->nr_partial > MIN_PARTIAL) {
+				n->nr_partial > n->min_partial) {
 			page = get_partial_node(n);
 			if (page)
 				return page;
@@ -1381,7 +1381,7 @@
 		slab_unlock(page);
 	} else {
 		stat(c, DEACTIVATE_EMPTY);
-		if (n->nr_partial < MIN_PARTIAL) {
+		if (n->nr_partial < n->min_partial) {
 			/*
 			 * Adding an empty slab to the partial slabs in order
 			 * to avoid page allocator overhead. This slab needs
@@ -1913,9 +1913,21 @@
 #endif
 }
 
-static void init_kmem_cache_node(struct kmem_cache_node *n)
+static void
+init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 {
 	n->nr_partial = 0;
+
+	/*
+	 * The larger the object size is, the more pages we want on the partial
+	 * list to avoid pounding the page allocator excessively.
+	 */
+	n->min_partial = ilog2(s->size);
+	if (n->min_partial < MIN_PARTIAL)
+		n->min_partial = MIN_PARTIAL;
+	else if (n->min_partial > MAX_PARTIAL)
+		n->min_partial = MAX_PARTIAL;
+
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
 #ifdef CONFIG_SLUB_DEBUG
@@ -2087,7 +2099,7 @@
 	init_object(kmalloc_caches, n, 1);
 	init_tracking(kmalloc_caches, n);
 #endif
-	init_kmem_cache_node(n);
+	init_kmem_cache_node(n, kmalloc_caches);
 	inc_slabs_node(kmalloc_caches, node, page->objects);
 
 	/*
@@ -2144,7 +2156,7 @@
 
 		}
 		s->node[node] = n;
-		init_kmem_cache_node(n);
+		init_kmem_cache_node(n, s);
 	}
 	return 1;
 }
@@ -2155,7 +2167,7 @@
 
 static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 {
-	init_kmem_cache_node(&s->local_node);
+	init_kmem_cache_node(&s->local_node, s);
 	return 1;
 }
 #endif
@@ -2889,7 +2901,7 @@
 			ret = -ENOMEM;
 			goto out;
 		}
-		init_kmem_cache_node(n);
+		init_kmem_cache_node(n, s);
 		s->node[nid] = n;
 	}
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
