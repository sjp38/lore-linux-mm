Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 79FF76B003C
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 11:57:59 -0400 (EDT)
Received: by mail-ey0-f169.google.com with SMTP id 4so6779982eye.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 08:57:57 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 5/6] slub: Only IPI CPUs that have per cpu obj to flush
Date: Sun, 23 Oct 2011 17:56:52 +0200
Message-Id: <1319385413-29665-6-git-send-email-gilad@benyossef.com>
In-Reply-To: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

flush_all() is called for each kmem_cahce_destroy(). So every cache
being destroyed dynamically ended up sending an IPI to each CPU in the
system, regardless if the cache has ever been used there.

For example, if you close the Infinband ipath driver char device file,
the close file ops calls kmem_cache_destroy(). So running some
infiniband config tool on one a single CPU dedicated to system tasks
might interrupt the rest of the 127 CPUs I dedicated to some CPU
intensive task.

I suspect there is a good chance that every line in the output of "git
grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario.

This patch attempts to rectify this issue by sending an IPI to flush
the per cpu objects back to the free lists only to CPUs that seems to
have such objects.

The check which CPU to IPI is racy but we don't care since
asking a CPU without per cpu objects to flush does no
damage and as far as I can tell the flush_all by itself is
racy against allocs on remote CPUs anyway, so if you meant
the flush_all to be determinstic, you had to arrange for
locking regardless.

Also note that it is fine for concurrent uses of the cpumask var
on different cpus since they end up tracking the same thing. The
only downside to a race is asking a CPU with not per cpu cache
to flush, which before this patch happens all the time any way.

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
 include/linux/slub_def.h |    3 +++
 mm/slub.c                |   37 +++++++++++++++++++++++++++++++++++--
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index f58d641..b130f61 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -102,6 +102,9 @@ struct kmem_cache {
 	 */
 	int remote_node_defrag_ratio;
 #endif
+
+	/* Which CPUs hold local slabs for this cache. */
+	cpumask_var_t cpus_with_slabs;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/mm/slub.c b/mm/slub.c
index 7c54fe8..f8cbf2d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1948,7 +1948,18 @@ static void flush_cpu_slab(void *d)
 
 static void flush_all(struct kmem_cache *s)
 {
-	on_each_cpu(flush_cpu_slab, s, 1);
+	struct kmem_cache_cpu *c;
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		c = per_cpu_ptr(s->cpu_slab, cpu);
+		if (c && c->page)
+			cpumask_set_cpu(cpu, s->cpus_with_slabs);
+		else
+			cpumask_clear_cpu(cpu, s->cpus_with_slabs);
+	}
+
+	on_each_cpu_mask(s->cpus_with_slabs, flush_cpu_slab, s, 1);
 }
 
 /*
@@ -3028,6 +3039,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 		sysfs_slab_remove(s);
+		free_cpumask_var(s->cpus_with_slabs);
 	}
 	up_write(&slub_lock);
 }
@@ -3528,6 +3540,7 @@ void __init kmem_cache_init(void)
 	int order;
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;
+	int ret;
 
 	kmem_size = offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *);
@@ -3635,15 +3648,24 @@ void __init kmem_cache_init(void)
 
 	slab_state = UP;
 
-	/* Provide the correct kmalloc names now that the caches are up */
+	/*
+	 * Provide the correct kmalloc names and the cpus_with_slabs cpumasks
+	 * for CONFIG_CPUMASK_OFFSTACK=y case now that the caches are up.
+	 */
 	if (KMALLOC_MIN_SIZE <= 32) {
 		kmalloc_caches[1]->name = kstrdup(kmalloc_caches[1]->name, GFP_NOWAIT);
 		BUG_ON(!kmalloc_caches[1]->name);
+		ret = alloc_cpumask_var(&kmalloc_caches[1]->cpus_with_slabs,
+			GFP_NOWAIT);
+		BUG_ON(!ret);
 	}
 
 	if (KMALLOC_MIN_SIZE <= 64) {
 		kmalloc_caches[2]->name = kstrdup(kmalloc_caches[2]->name, GFP_NOWAIT);
 		BUG_ON(!kmalloc_caches[2]->name);
+		ret = alloc_cpumask_var(&kmalloc_caches[2]->cpus_with_slabs,
+				GFP_NOWAIT);
+		BUG_ON(!ret);
 	}
 
 	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
@@ -3651,6 +3673,9 @@ void __init kmem_cache_init(void)
 
 		BUG_ON(!s);
 		kmalloc_caches[i]->name = s;
+		ret = alloc_cpumask_var(&kmalloc_caches[i]->cpus_with_slabs,
+				GFP_NOWAIT);
+		BUG_ON(!ret);
 	}
 
 #ifdef CONFIG_SMP
@@ -3668,6 +3693,10 @@ void __init kmem_cache_init(void)
 			BUG_ON(!name);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
 				s->objsize, SLAB_CACHE_DMA);
+			ret = alloc_cpumask_var(
+				&kmalloc_dma_caches[i]->cpus_with_slabs,
+				GFP_NOWAIT);
+			BUG_ON(!ret);
 		}
 	}
 #endif
@@ -3778,15 +3807,19 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
+
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
+			alloc_cpumask_var(&s->cpus_with_slabs, GFP_KERNEL);
 			list_add(&s->list, &slab_caches);
 			if (sysfs_slab_add(s)) {
 				list_del(&s->list);
+				free_cpumask_var(s->cpus_with_slabs);
 				kfree(n);
 				kfree(s);
 				goto err;
 			}
+
 			up_write(&slub_lock);
 			return s;
 		}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
