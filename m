Date: Tue, 19 Jun 2007 16:17:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 26/26] SLUB: Place kmem_cache_cpu structures in a NUMA
 aware way.
In-Reply-To: <20070618095919.579023320@sgi.com>
Message-ID: <Pine.LNX.4.64.0706191615490.15951@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095919.579023320@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Some fixups to this patch:


Fix issues with per cpu kmem_cache_cpu arrays.

1. During cpu bootstrap we also need to bootstrap the per cpu array
   for the cpu in SLUB.
   kmem_cache_init is called while only a single cpu is marked online.

2. The size determination of the kmem_cache array is wrong for UP.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-19 15:38:22.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-19 16:13:17.000000000 -0700
@@ -2016,21 +2016,28 @@ static int alloc_kmem_cache_cpus(struct 
 	return 1;
 }
 
+/*
+ * Initialize the per cpu array.
+ */
+static void init_alloc_cpu_cpu(int cpu)
+{
+	int i;
+
+	for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
+		free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i], cpu);
+}
+
 static void __init init_alloc_cpu(void)
 {
 	int cpu;
-	int i;
 
-	for_each_online_cpu(cpu) {
-		for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
-			free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i],
-								cpu);
-	}
+	for_each_online_cpu(cpu)
+		init_alloc_cpu_cpu(cpu);
 }
 
 #else
 static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
-static inline void init_alloc_cpu(struct kmem_cache *s) {}
+static inline void init_alloc_cpu(void) {}
 
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
@@ -3094,10 +3101,12 @@ void __init kmem_cache_init(void)
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
-#endif
-
 	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
 				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
+#else
+	kmem_size = sizeof(struct kmem_cache);
+#endif
+
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d,"
 		" MinObjects=%d, CPUs=%d, Nodes=%d\n",
@@ -3244,6 +3253,7 @@ static int __cpuinit slab_cpuup_callback
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
+		init_alloc_cpu_cpu(cpu);
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list)
 			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(cpu,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
