Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D0FEA6B01D0
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:28:32 -0400 (EDT)
Message-Id: <20100625212102.841706448@quilx.com>
Date: Fri, 25 Jun 2010 16:20:29 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 03/16] [PATCH 2/2] percpu: allow limited allocation before slab is online
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=percpu_early_2
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

This patch updates percpu allocator such that it can serve limited
amount of allocation before slab comes online.  This is primarily to
allow slab to depend on working percpu allocator.

Two parameters, PERCPU_DYNAMIC_EARLY_SIZE and SLOTS, determine how
much memory space and allocation map slots are reserved.  If this
reserved area is exhausted, WARN_ON_ONCE() will trigger and allocation
will fail till slab comes online.

The following changes are made to implement early alloc.

* pcpu_mem_alloc() now checks slab_is_available()

* Chunks are allocated using pcpu_mem_alloc()

* Init paths make sure ai->dyn_size is at least as large as
  PERCPU_DYNAMIC_EARLY_SIZE.

* Initial alloc maps are allocated in __initdata and copied to
  kmalloc'd areas once slab is online.

Signed-off-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/percpu.h |   13 ++++++++++++
 init/main.c            |    1
 include/linux/percpu.h |   13 ++++++++++++
 init/main.c            |    1 
 mm/percpu.c            |   52 +++++++++++++++++++++++++++++++++++++------------
 3 files changed, 54 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/percpu.c
===================================================================
--- linux-2.6.orig/mm/percpu.c	2010-06-23 14:43:39.000000000 -0500
+++ linux-2.6/mm/percpu.c	2010-06-23 14:43:54.000000000 -0500
@@ -282,6 +282,9 @@ static void __maybe_unused pcpu_next_pop
  */
 static void *pcpu_mem_alloc(size_t size)
 {
+	if (WARN_ON_ONCE(!slab_is_available()))
+		return NULL;
+
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
 	else {
@@ -392,13 +395,6 @@ static int pcpu_extend_area_map(struct p
 	old_size = chunk->map_alloc * sizeof(chunk->map[0]);
 	memcpy(new, chunk->map, old_size);
 
-	/*
-	 * map_alloc < PCPU_DFL_MAP_ALLOC indicates that the chunk is
-	 * one of the first chunks and still using static map.
-	 */
-	if (chunk->map_alloc >= PCPU_DFL_MAP_ALLOC)
-		old = chunk->map;
-
 	chunk->map_alloc = new_alloc;
 	chunk->map = new;
 	new = NULL;
@@ -604,7 +600,7 @@ static struct pcpu_chunk *pcpu_alloc_chu
 {
 	struct pcpu_chunk *chunk;
 
-	chunk = kzalloc(pcpu_chunk_struct_size, GFP_KERNEL);
+	chunk = pcpu_mem_alloc(pcpu_chunk_struct_size);
 	if (!chunk)
 		return NULL;
 
@@ -1084,7 +1080,9 @@ struct pcpu_alloc_info * __init pcpu_bui
 	memset(group_map, 0, sizeof(group_map));
 	memset(group_cnt, 0, sizeof(group_map));
 
-	size_sum = PFN_ALIGN(static_size + reserved_size + dyn_size);
+	/* calculate size_sum and ensure dyn_size is enough for early alloc */
+	size_sum = PFN_ALIGN(static_size + reserved_size +
+			    max_t(size_t, dyn_size, PERCPU_DYNAMIC_EARLY_SIZE));
 	dyn_size = size_sum - static_size - reserved_size;
 
 	/*
@@ -1314,7 +1312,8 @@ int __init pcpu_setup_first_chunk(const 
 				  void *base_addr)
 {
 	static char cpus_buf[4096] __initdata;
-	static int smap[2], dmap[2];
+	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
+	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t dyn_size = ai->dyn_size;
 	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
 	struct pcpu_chunk *schunk, *dchunk = NULL;
@@ -1337,14 +1336,13 @@ int __init pcpu_setup_first_chunk(const 
 } while (0)
 
 	/* sanity checks */
-	BUILD_BUG_ON(ARRAY_SIZE(smap) >= PCPU_DFL_MAP_ALLOC ||
-		     ARRAY_SIZE(dmap) >= PCPU_DFL_MAP_ALLOC);
 	PCPU_SETUP_BUG_ON(ai->nr_groups <= 0);
 	PCPU_SETUP_BUG_ON(!ai->static_size);
 	PCPU_SETUP_BUG_ON(!base_addr);
 	PCPU_SETUP_BUG_ON(ai->unit_size < size_sum);
 	PCPU_SETUP_BUG_ON(ai->unit_size & ~PAGE_MASK);
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
+	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
@@ -1782,3 +1780,33 @@ void __init setup_per_cpu_areas(void)
 		__per_cpu_offset[cpu] = delta + pcpu_unit_offsets[cpu];
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
+
+/*
+ * First and reserved chunks are initialized with temporary allocation
+ * map in initdata so that they can be used before slab is online.
+ * This function is called after slab is brought up and replaces those
+ * with properly allocated maps.
+ */
+void __init percpu_init_late(void)
+{
+	struct pcpu_chunk *target_chunks[] =
+		{ pcpu_first_chunk, pcpu_reserved_chunk, NULL };
+	struct pcpu_chunk *chunk;
+	unsigned long flags;
+	int i;
+
+	for (i = 0; (chunk = target_chunks[i]); i++) {
+		int *map;
+		const size_t size = PERCPU_DYNAMIC_EARLY_SLOTS * sizeof(map[0]);
+
+		BUILD_BUG_ON(size > PAGE_SIZE);
+
+		map = pcpu_mem_alloc(size);
+		BUG_ON(!map);
+
+		spin_lock_irqsave(&pcpu_lock, flags);
+		memcpy(map, chunk->map, size);
+		chunk->map = map;
+		spin_unlock_irqrestore(&pcpu_lock, flags);
+	}
+}
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c	2010-06-22 09:45:34.000000000 -0500
+++ linux-2.6/init/main.c	2010-06-23 14:43:54.000000000 -0500
@@ -522,6 +522,7 @@ static void __init mm_init(void)
 	page_cgroup_init_flatmem();
 	mem_init();
 	kmem_cache_init();
+	percpu_init_late();
 	pgtable_cache_init();
 	vmalloc_init();
 }
Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2010-06-23 14:43:39.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2010-06-23 14:43:54.000000000 -0500
@@ -45,6 +45,16 @@
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(64 << 10)
 
 /*
+ * Percpu allocator can serve percpu allocations before slab is
+ * initialized which allows slab to depend on the percpu allocator.
+ * The following two parameters decide how much resource to
+ * preallocate for this.  Keep PERCPU_DYNAMIC_RESERVE equal to or
+ * larger than PERCPU_DYNAMIC_EARLY_SIZE.
+ */
+#define PERCPU_DYNAMIC_EARLY_SLOTS	128
+#define PERCPU_DYNAMIC_EARLY_SIZE	(12 << 10)
+
+/*
  * PERCPU_DYNAMIC_RESERVE indicates the amount of free area to piggy
  * back on the first chunk for dynamic percpu allocation if arch is
  * manually allocating and mapping it for faster access (as a part of
@@ -140,6 +150,7 @@ extern bool is_kernel_percpu_address(uns
 #ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 extern void __init setup_per_cpu_areas(void);
 #endif
+extern void __init percpu_init_late(void);
 
 #else /* CONFIG_SMP */
 
@@ -153,6 +164,8 @@ static inline bool is_kernel_percpu_addr
 
 static inline void __init setup_per_cpu_areas(void) { }
 
+static inline void __init percpu_init_late(void) { }
+
 static inline void *pcpu_lpage_remapped(void *kaddr)
 {
 	return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
