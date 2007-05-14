Message-Id: <20070514133212.581041171@chello.nl>
References: <20070514131904.440041502@chello.nl>
Date: Mon, 14 May 2007 15:19:07 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/5] mm: slub allocation fairness
Content-Disposition: inline; filename=mm-slub-ranking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

The slub allocator has some unfairness wrt gfp flags; when the slub cache is
grown the gfp flags are used to allocate more memory, however when there is 
slub cache available (in partial or free slabs) gfp flags are ignored.

Thus it is possible for less critical slub allocations to succeed and gobble
up precious memory when under memory pressure.

This patch solves that by using the newly introduced page allocation rank.

Page allocation rank is a scalar quantity connecting ALLOC_ and gfp flags which
represents how deep we had to reach into our reserves when allocating a page. 
Rank 0 is the deepest we can reach (ALLOC_NO_WATERMARK) and 16 is the most 
shallow allocation possible (ALLOC_WMARK_HIGH).

When the slub space is grown the rank of the page allocation is stored. For
each slub allocation we test the given gfp flags against this rank. Thereby
asking the question: would these flags have allowed the slub to grow.

If not so, we need to test the current situation. This is done by forcing the
growth of the slub space. (Just testing the free page limits will not work due
to direct reclaim) Failing this we need to fail the slub allocation.

Thus if we grew the slub under great duress while PF_MEMALLOC was set and we 
really did access the memalloc reserve the rank would be set to 0. If the next
allocation to that slub would be GFP_NOFS|__GFP_NOMEMALLOC (which ordinarily
maps to rank 4 and always > 0) we'd want to make sure that memory pressure has
decreased enough to allow an allocation with the given gfp flags.

So in this case we try to force grow the slub cache and on failure we fail the
slub allocation. Thus preserving the available slub cache for more pressing
allocations.

[netperf results]


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    1 +
 mm/Kconfig               |    2 +-
 mm/slub.c                |   24 +++++++++++++++++++++---
 3 files changed, 23 insertions(+), 4 deletions(-)

Index: linux-2.6-git/include/linux/slub_def.h
===================================================================
--- linux-2.6-git.orig/include/linux/slub_def.h
+++ linux-2.6-git/include/linux/slub_def.h
@@ -52,6 +52,7 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
 	struct page *cpu_slab[NR_CPUS];
+	int rank;
 };
 
 /*
Index: linux-2.6-git/mm/slub.c
===================================================================
--- linux-2.6-git.orig/mm/slub.c
+++ linux-2.6-git/mm/slub.c
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
 
 /*
  * Lock order:
@@ -961,6 +962,8 @@ static struct page *allocate_slab(struct
 	if (!page)
 		return NULL;
 
+	s->rank = page->index;
+
 	mod_zone_page_state(page_zone(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
@@ -1350,6 +1353,8 @@ static void flush_all(struct kmem_cache 
 #endif
 }
 
+#define FORCE_PAGE	((void *)~0UL)
+
 /*
  * Slow path. The lockless freelist is empty or we need to perform
  * debugging duties.
@@ -1371,8 +1376,12 @@ static void *__slab_alloc(struct kmem_ca
 		gfp_t gfpflags, int node, void *addr, struct page *page)
 {
 	void **object;
-	int cpu = smp_processor_id();
+	int cpu;
+
+	if (page == FORCE_PAGE)
+		goto force_new;
 
+	cpu = smp_processor_id();
 	if (!page)
 		goto new_slab;
 
@@ -1405,6 +1414,7 @@ have_slab:
 		goto load_freelist;
 	}
 
+force_new:
 	page = new_slab(s, gfpflags, node);
 	if (page) {
 		cpu = smp_processor_id();
@@ -1465,15 +1475,22 @@ static void __always_inline *slab_alloc(
 	struct page *page;
 	void **object;
 	unsigned long flags;
+	int rank = slab_alloc_rank(gfpflags);
 
 	local_irq_save(flags);
+	if (slab_insufficient_rank(s, rank)) {
+		page = FORCE_PAGE;
+		goto force_alloc;
+	}
+
 	page = s->cpu_slab[smp_processor_id()];
 	if (unlikely(!page || !page->lockless_freelist ||
-			(node != -1 && page_to_nid(page) != node)))
+			(node != -1 && page_to_nid(page) != node))) {
 
+force_alloc:
 		object = __slab_alloc(s, gfpflags, node, addr, page);
 
-	else {
+	} else {
 		object = page->lockless_freelist;
 		page->lockless_freelist = object[page->offset];
 	}
@@ -1993,6 +2010,7 @@ static int kmem_cache_open(struct kmem_c
 	s->flags = flags;
 	s->align = align;
 	kmem_cache_open_debug_check(s);
+	s->rank = MAX_ALLOC_RANK;
 
 	if (!calculate_sizes(s))
 		goto error;
Index: linux-2.6-git/mm/Kconfig
===================================================================
--- linux-2.6-git.orig/mm/Kconfig
+++ linux-2.6-git/mm/Kconfig
@@ -165,7 +165,7 @@ config ZONE_DMA_FLAG
 
 config SLAB_FAIR
 	def_bool n
-	depends on SLAB
+	depends on SLAB || SLUB
 
 config NR_QUICK
 	int

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
