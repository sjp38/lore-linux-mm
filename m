Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D9C2E660023
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:31 -0400 (EDT)
Message-Id: <20100804024529.039215901@linux.com>
Date: Tue, 03 Aug 2010 21:45:23 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 09/23] slub: Remove static kmem_cache_cpu array for boot
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=maybe_remove_static
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

The percpu allocator can now handle allocations during early boot.
So drop the static kmem_cache_cpu array.

Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-26 14:26:17.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-26 14:26:20.000000000 -0500
@@ -2063,23 +2063,14 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }
 
-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
-
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 {
-	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
-		/*
-		 * Boot time creation of the kmalloc array. Use static per cpu data
-		 * since the per cpu allocator is not available yet.
-		 */
-		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
-	else
-		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
+	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
+			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));
 
-	if (!s->cpu_slab)
-		return 0;
+	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
 
-	return 1;
+	return s->cpu_slab != NULL;
 }
 
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
