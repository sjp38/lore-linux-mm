Date: Fri, 6 Jul 2007 13:36:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Fix CONFIG_SLUB_DEBUG use for CONFIG_NUMA
Message-ID: <Pine.LNX.4.64.0707061333320.24784@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We currently cannot disable CONFIG_SLUB_DEBUG for CONFIG_NUMA. Now that 
embedded systems start to use NUMA we may need this.

Put an #ifdef around places where NUMA only code uses fields only valid
for CONFIG_SLUB_DEBUG.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-06 13:28:57.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-06 13:29:01.000000000 -0700
@@ -1868,7 +1868,9 @@ static void init_kmem_cache_node(struct 
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+#ifdef CONFIG_SLUB_DEBUG
 	INIT_LIST_HEAD(&n->full);
+#endif
 }
 
 #ifdef CONFIG_NUMA
@@ -1898,8 +1900,10 @@ static struct kmem_cache_node * __init e
 	page->freelist = get_freepointer(kmalloc_caches, n);
 	page->inuse++;
 	kmalloc_caches->node[node] = n;
+#ifdef CONFIG_SLUB_DEBUG
 	init_object(kmalloc_caches, n, 1);
 	init_tracking(kmalloc_caches, n);
+#endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
 	add_partial(n, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
