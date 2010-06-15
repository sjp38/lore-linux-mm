Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B6186B025C
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:15:16 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:11:50 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [RFC] slub: Simplify boot kmem_cache_cpu allocations
In-Reply-To: <alpine.DEB.2.00.1006151406120.10865@router.home>
Message-ID: <alpine.DEB.2.00.1006151409240.10865@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Maybe this one can also be applied after the other patch?

Tejun: Is it somehow possible to reliably use the alloc_percpu() on all
platforms during early boot before the slab allocator is up?



Subject: slub: Simplify boot kmem_cache_cpu allocations

There is no need anymore for a large amount of kmem_cache_cpu
structures during bootup since the DMA slabs are allocated late
during boot. Also the tight 1-1 association with the indexing
of the kmalloc array is not necessary.

Simply take SLUB_PAGE_SHIFT entries from static memory.

Many arches could avoid static kmem_cache_cpu allocations
entirely since they have the ability to do alloc_percpu() early
in boot. But at least i386 needs this for now since an alloc_percpu()
triggers a call to kmalloc.

Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-06-03 13:48:41.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-06-03 14:24:30.000000000 -0500
@@ -2068,23 +2068,25 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }

-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
+/*
+ * Some arches need some assist during bootup since the percpu allocator is
+ * not available early during boot.
+ */
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
+static struct kmem_cache_cpu *boot_kmem_cache_cpu = &kmalloc_percpu[0];

 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 {
-	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
+	if (boot_kmem_cache_cpu - kmalloc_percpu < SLUB_PAGE_SHIFT)
 		/*
 		 * Boot time creation of the kmalloc array. Use static per cpu data
-		 * since the per cpu allocator is not available yet.
+		 * since the per cpu allocator may not be available yet.
 		 */
-		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
+		s->cpu_slab = boot_kmem_cache_cpu++;
 	else
-		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
+		s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);

-	if (!s->cpu_slab)
-		return 0;
-
-	return 1;
+	return s->cpu_slab != NULL;
 }

 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
