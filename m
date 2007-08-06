Message-Id: <20070806103658.603735000@chello.nl>
References: <20070806102922.907530000@chello.nl>
Date: Mon, 06 Aug 2007 12:29:26 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/10] mm: slub: add knowledge of reserve pages
Content-Disposition: inline; filename=reserve-slab.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it.

Care is taken to only touch the SLUB slow path.

Because the reserve threshold is system wide (by virtue of the previous patches)
we can do with a single kmem_cache wide state.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    2 +
 mm/slub.c                |   75 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 70 insertions(+), 7 deletions(-)

Index: linux-2.6-2/include/linux/slub_def.h
===================================================================
--- linux-2.6-2.orig/include/linux/slub_def.h
+++ linux-2.6-2/include/linux/slub_def.h
@@ -50,6 +50,8 @@ struct kmem_cache {
 	struct kobject kobj;	/* For sysfs */
 #endif
 
+	struct page *reserve_slab;
+
 #ifdef CONFIG_NUMA
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
Index: linux-2.6-2/mm/slub.c
===================================================================
--- linux-2.6-2.orig/mm/slub.c
+++ linux-2.6-2/mm/slub.c
@@ -20,11 +20,13 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
 
 /*
  * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   1. reserve_lock
+ *   2. slab_lock(page)
+ *   3. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -258,6 +260,8 @@ static inline int sysfs_slab_alias(struc
 static inline void sysfs_slab_remove(struct kmem_cache *s) {}
 #endif
 
+static DEFINE_SPINLOCK(reserve_lock);
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -1069,7 +1073,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(object, s, 0);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -1087,6 +1091,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1457,6 +1462,7 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	int cpu = smp_processor_id();
+	int reserve = 0;
 
 	if (!page)
 		goto new_slab;
@@ -1486,10 +1492,25 @@ new_slab:
 	if (page) {
 		s->cpu_slab[cpu] = page;
 		goto load_freelist;
-	}
+	} else if (unlikely(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+		goto try_reserve;
 
-	page = new_slab(s, gfpflags, node);
-	if (page) {
+alloc_slab:
+	page = new_slab(s, gfpflags, node, &reserve);
+	if (page && !reserve) {
+		if (unlikely(s->reserve_slab)) {
+			struct page *reserve;
+
+			spin_lock(&reserve_lock);
+			reserve = s->reserve_slab;
+			s->reserve_slab = NULL;
+			spin_unlock(&reserve_lock);
+
+			if (reserve) {
+				slab_lock(reserve);
+				unfreeze_slab(s, reserve);
+			}
+		}
 		cpu = smp_processor_id();
 		if (s->cpu_slab[cpu]) {
 			/*
@@ -1517,6 +1538,18 @@ new_slab:
 		SetSlabFrozen(page);
 		s->cpu_slab[cpu] = page;
 		goto load_freelist;
+	} else if (page) {
+		spin_lock(&reserve_lock);
+		if (s->reserve_slab) {
+			discard_slab(s, page);
+			page = s->reserve_slab;
+			goto got_reserve;
+		}
+		slab_lock(page);
+		SetSlabFrozen(page);
+		s->reserve_slab = page;
+		spin_unlock(&reserve_lock);
+		goto use_reserve;
 	}
 	return NULL;
 debug:
@@ -1528,6 +1561,31 @@ debug:
 	page->freelist = object[page->offset];
 	slab_unlock(page);
 	return object;
+
+try_reserve:
+	spin_lock(&reserve_lock);
+	page = s->reserve_slab;
+	if (!page) {
+		spin_unlock(&reserve_lock);
+		goto alloc_slab;
+	}
+
+got_reserve:
+	slab_lock(page);
+	if (!page->freelist) {
+		s->reserve_slab = NULL;
+		spin_unlock(&reserve_lock);
+		unfreeze_slab(s, page);
+		goto alloc_slab;
+	}
+	spin_unlock(&reserve_lock);
+
+use_reserve:
+	object = page->freelist;
+	page->inuse++;
+	page->freelist = object[page->offset];
+	slab_unlock(page);
+	return object;
 }
 
 /*
@@ -1872,10 +1930,11 @@ static struct kmem_cache_node * __init e
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node, &reserve);
 
 	BUG_ON(!page);
 	n = page->freelist;
@@ -2091,6 +2150,8 @@ static int kmem_cache_open(struct kmem_c
 	s->defrag_ratio = 100;
 #endif
 
+	s->reserve_slab = NULL;
+
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
 error:

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
