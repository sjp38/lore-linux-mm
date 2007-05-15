Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1179170912.2942.37.camel@lappy>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
	 <1179164453.2942.26.camel@lappy>
	 <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
	 <1179170912.2942.37.camel@lappy>
Content-Type: text/plain
Date: Tue, 15 May 2007 19:27:16 +0200
Message-Id: <1179250036.7173.7.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 21:28 +0200, Peter Zijlstra wrote:

> One allocator is all I need; it would just be grand if all could be
> supported.
> 
> So what you suggest is not placing the 'emergency' slab into the regular
> place so that normal allocations will not be able to find it. Then if an
> emergency allocation cannot be satified by the regular path, we fall
> back to the slow path and find the emergency slab.


How about something like this; it seems to sustain a little stress.


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slub_def.h |    3 +
 mm/slub.c                |   73 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 68 insertions(+), 8 deletions(-)

Index: linux-2.6-git/include/linux/slub_def.h
===================================================================
--- linux-2.6-git.orig/include/linux/slub_def.h
+++ linux-2.6-git/include/linux/slub_def.h
@@ -47,6 +47,9 @@ struct kmem_cache {
 	struct list_head list;	/* List of slab caches */
 	struct kobject kobj;	/* For sysfs */
 
+	spinlock_t reserve_lock;
+	struct page *reserve_slab;
+
 #ifdef CONFIG_NUMA
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
Index: linux-2.6-git/mm/slub.c
===================================================================
--- linux-2.6-git.orig/mm/slub.c
+++ linux-2.6-git/mm/slub.c
@@ -20,11 +20,13 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
 
 /*
  * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   1. slab->reserve_lock
+ *   2. slab_lock(page)
+ *   3. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -981,7 +983,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(object, s, SLAB_CTOR_CONSTRUCTOR);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *rank)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -999,6 +1001,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
+	*rank = page->rank;
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1286,7 +1289,7 @@ static void putback_slab(struct kmem_cac
 /*
  * Remove the cpu slab
  */
-static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
+static void __deactivate_slab(struct kmem_cache *s, struct page *page)
 {
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
@@ -1305,8 +1308,13 @@ static void deactivate_slab(struct kmem_
 		page->freelist = object;
 		page->inuse--;
 	}
-	s->cpu_slab[cpu] = NULL;
 	ClearPageActive(page);
+}
+
+static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
+{
+	__deactivate_slab(s, page);
+	s->cpu_slab[cpu] = NULL;
 
 	putback_slab(s, page);
 }
@@ -1372,6 +1380,7 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	int cpu = smp_processor_id();
+	int rank = 0;
 
 	if (!page)
 		goto new_slab;
@@ -1403,10 +1412,42 @@ have_slab:
 		s->cpu_slab[cpu] = page;
 		SetPageActive(page);
 		goto load_freelist;
+	} else if (gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS) {
+		spin_lock(&s->reserve_lock);
+		page = s->reserve_slab;
+		if (page) {
+			if (page->freelist) {
+				slab_lock(page);
+				spin_unlock(&s->reserve_lock);
+				goto load_freelist;
+			} else
+				s->reserve_slab = NULL;
+		}
+		spin_unlock(&s->reserve_lock);
+
+		if (page) {
+			slab_lock(page);
+			__deactivate_slab(s, page);
+			putback_slab(s, page);
+		}
 	}
 
-	page = new_slab(s, gfpflags, node);
-	if (page) {
+	page = new_slab(s, gfpflags, node, &rank);
+	if (page && rank) {
+		if (unlikely(s->reserve_slab)) {
+			struct page *reserve;
+
+			spin_lock(&s->reserve_lock);
+			reserve = s->reserve_slab;
+			s->reserve_slab = NULL;
+			spin_unlock(&s->reserve_lock);
+
+			if (reserve) {
+				slab_lock(reserve);
+				__deactivate_slab(s, reserve);
+				putback_slab(s, reserve);
+			}
+		}
 		cpu = smp_processor_id();
 		if (s->cpu_slab[cpu]) {
 			/*
@@ -1432,6 +1473,18 @@ have_slab:
 		}
 		slab_lock(page);
 		goto have_slab;
+	} else if (page) {
+		spin_lock(&s->reserve_lock);
+		if (s->reserve_slab) {
+			discard_slab(s, page);
+			page = s->reserve_slab;
+		}
+		slab_lock(page);
+		SetPageActive(page);
+		s->reserve_slab = page;
+		spin_unlock(&s->reserve_lock);
+
+		goto load_freelist;
 	}
 	return NULL;
 debug:
@@ -1788,10 +1841,11 @@ static struct kmem_cache_node * __init e
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	int rank;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node, &rank);
 	/* new_slab() disables interupts */
 	local_irq_enable();
 
@@ -2002,6 +2056,9 @@ static int kmem_cache_open(struct kmem_c
 	s->defrag_ratio = 100;
 #endif
 
+	spin_lock_init(&s->reserve_lock);
+	s->reserve_slab = NULL;
+
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
 error:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
