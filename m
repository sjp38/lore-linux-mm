Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9A31E6B01AC
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 12:59:08 -0400 (EDT)
Message-ID: <4C1BA5BA.7000403@kernel.org>
Date: Fri, 18 Jun 2010 18:58:34 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] percpu: allow limited allocation before slab is online
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home> <4C19E19D.2020802@kernel.org> <alpine.DEB.2.00.1006170842410.22997@router.home>
In-Reply-To: <alpine.DEB.2.00.1006170842410.22997@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
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
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/percpu.h |   13 ++++++++++++
 init/main.c            |    1
 mm/percpu.c            |   52 +++++++++++++++++++++++++++++++++++++------------
 3 files changed, 54 insertions(+), 12 deletions(-)

Index: work/mm/percpu.c
===================================================================
--- work.orig/mm/percpu.c
+++ work/mm/percpu.c
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

@@ -1109,7 +1105,9 @@ struct pcpu_alloc_info * __init pcpu_bui
 	memset(group_map, 0, sizeof(group_map));
 	memset(group_cnt, 0, sizeof(group_cnt));

-	size_sum = PFN_ALIGN(static_size + reserved_size + dyn_size);
+	/* calculate size_sum and ensure dyn_size is enough for early alloc */
+	size_sum = PFN_ALIGN(static_size + reserved_size +
+			    max_t(size_t, dyn_size, PERCPU_DYNAMIC_EARLY_SIZE));
 	dyn_size = size_sum - static_size - reserved_size;

 	/*
@@ -1338,7 +1336,8 @@ int __init pcpu_setup_first_chunk(const
 				  void *base_addr)
 {
 	static char cpus_buf[4096] __initdata;
-	static int smap[2], dmap[2];
+	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
+	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t dyn_size = ai->dyn_size;
 	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
 	struct pcpu_chunk *schunk, *dchunk = NULL;
@@ -1361,14 +1360,13 @@ int __init pcpu_setup_first_chunk(const
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
@@ -1806,3 +1804,33 @@ void __init setup_per_cpu_areas(void)
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
Index: work/init/main.c
===================================================================
--- work.orig/init/main.c
+++ work/init/main.c
@@ -522,6 +522,7 @@ static void __init mm_init(void)
 	page_cgroup_init_flatmem();
 	mem_init();
 	kmem_cache_init();
+	percpu_init_late();
 	pgtable_cache_init();
 	vmalloc_init();
 }
Index: work/include/linux/percpu.h
===================================================================
--- work.orig/include/linux/percpu.h
+++ work/include/linux/percpu.h
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
