Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E98AF6B0033
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 11:50:01 -0400 (EDT)
Received: by mail-bw0-f41.google.com with SMTP id zu5so9120434bkb.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 08:50:00 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if offstack
Date: Sun, 23 Oct 2011 17:48:42 +0200
Message-Id: <1319384922-29632-7-git-send-email-gilad@benyossef.com>
In-Reply-To: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

We need a cpumask to track cpus with per cpu cache pages
to know which cpu to whack during flush_all. For
CONFIG_CPUMASK_OFFSTACK=n we allocate the mask on stack.
For CONFIG_CPUMASK_OFFSTACK=y we don't want to call kmalloc
on the flush_all path, so we preallocate per kmem_cache
on cache creation and use it in flush_all.

The result is that for the common CONFIG_CPUMASK_OFFSTACK=n
case there is no memory overhead for the mask var.

Since systems where CONFIG_CPUMASK_OFFSTACK=y are the systems
which are most likely to benefit from less IPIs by tracking
which cpu pas actually has a per cpu cache, we end up paying
the overhead only in cases we enjoy the upside.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/slub_def.h |    8 ++++++-
 mm/slub.c                |   52 +++++++++++++++++++++++++++++++++------------
 2 files changed, 45 insertions(+), 15 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index b130f61..c07f7aa 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -103,8 +103,14 @@ struct kmem_cache {
 	int remote_node_defrag_ratio;
 #endif
 
-	/* Which CPUs hold local slabs for this cache. */
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	/*
+	 * Which CPUs hold local slabs for this cache.
+	 * Only updated on calling flush_all().
+	 * Defined on stack for CONFIG_CPUMASK_OFFSTACK=n.
+	 */
 	cpumask_var_t cpus_with_slabs;
+#endif
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/mm/slub.c b/mm/slub.c
index f8cbf2d..765be95 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1946,20 +1946,48 @@ static void flush_cpu_slab(void *d)
 	__flush_cpu_slab(s, smp_processor_id());
 }
 
+/*
+ * We need a cpumask struct to track which cpus have
+ * per cpu caches. For CONFIG_CPUMASK_OFFSTACK=n we
+ * allocate on stack. For CONFIG_CPUMASK_OFFSTACK=y
+ * we don't want to allocate in the flush_all code path
+ * so we allocate a struct for each cache structure
+ * on kmem cache creation and use it here.
+ */
 static void flush_all(struct kmem_cache *s)
 {
 	struct kmem_cache_cpu *c;
 	int cpu;
+	cpumask_var_t cpus;
 
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	cpus = s->cpus_with_slabs;
+#endif
 	for_each_online_cpu(cpu) {
 		c = per_cpu_ptr(s->cpu_slab, cpu);
 		if (c && c->page)
-			cpumask_set_cpu(cpu, s->cpus_with_slabs);
+			cpumask_set_cpu(cpu, cpus);
 		else
-			cpumask_clear_cpu(cpu, s->cpus_with_slabs);
+			cpumask_clear_cpu(cpu, cpus);
 	}
 
-	on_each_cpu_mask(s->cpus_with_slabs, flush_cpu_slab, s, 1);
+	on_each_cpu_mask(cpus, flush_cpu_slab, s, 1);
+}
+
+static inline int alloc_cpus_mask(struct kmem_cache *s, int flags)
+{
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	return alloc_cpumask_var(&s->cpus_with_slabs, flags);
+#else
+	return 1;
+#endif
+}
+
+static inline void free_cpus_mask(struct kmem_cache *s)
+{
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	free_cpumask_var(s->cpus_with_slabs);
+#endif
 }
 
 /*
@@ -3039,7 +3067,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 		sysfs_slab_remove(s);
-		free_cpumask_var(s->cpus_with_slabs);
+		free_cpus_mask(s);
 	}
 	up_write(&slub_lock);
 }
@@ -3655,16 +3683,14 @@ void __init kmem_cache_init(void)
 	if (KMALLOC_MIN_SIZE <= 32) {
 		kmalloc_caches[1]->name = kstrdup(kmalloc_caches[1]->name, GFP_NOWAIT);
 		BUG_ON(!kmalloc_caches[1]->name);
-		ret = alloc_cpumask_var(&kmalloc_caches[1]->cpus_with_slabs,
-			GFP_NOWAIT);
+		ret = alloc_cpus_mask(kmalloc_caches[1], GFP_NOWAIT);
 		BUG_ON(!ret);
 	}
 
 	if (KMALLOC_MIN_SIZE <= 64) {
 		kmalloc_caches[2]->name = kstrdup(kmalloc_caches[2]->name, GFP_NOWAIT);
 		BUG_ON(!kmalloc_caches[2]->name);
-		ret = alloc_cpumask_var(&kmalloc_caches[2]->cpus_with_slabs,
-				GFP_NOWAIT);
+		ret = alloc_cpus_mask(kmalloc_caches[2], GFP_NOWAIT);
 		BUG_ON(!ret);
 	}
 
@@ -3673,8 +3699,7 @@ void __init kmem_cache_init(void)
 
 		BUG_ON(!s);
 		kmalloc_caches[i]->name = s;
-		ret = alloc_cpumask_var(&kmalloc_caches[i]->cpus_with_slabs,
-				GFP_NOWAIT);
+		ret = alloc_cpus_mask(kmalloc_caches[i], GFP_NOWAIT);
 		BUG_ON(!ret);
 	}
 
@@ -3693,8 +3718,7 @@ void __init kmem_cache_init(void)
 			BUG_ON(!name);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
 				s->objsize, SLAB_CACHE_DMA);
-			ret = alloc_cpumask_var(
-				&kmalloc_dma_caches[i]->cpus_with_slabs,
+			ret = alloc_cpus_mask(kmalloc_dma_caches[i],
 				GFP_NOWAIT);
 			BUG_ON(!ret);
 		}
@@ -3810,11 +3834,11 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
-			alloc_cpumask_var(&s->cpus_with_slabs, GFP_KERNEL);
+			alloc_cpus_mask(s, GFP_KERNEL);
 			list_add(&s->list, &slab_caches);
 			if (sysfs_slab_add(s)) {
 				list_del(&s->list);
-				free_cpumask_var(s->cpus_with_slabs);
+				free_cpus_mask(s);
 				kfree(n);
 				kfree(s);
 				goto err;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
