Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF8526B059D
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 76so135402523pgh.11
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y101si1676693plh.243.2017.07.15.19.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:45 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 09/10] percpu: replace area map allocator with bitmap allocator
Date: Sat, 15 Jul 2017 22:23:14 -0400
Message-ID: <20170716022315.19892-10-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The percpu memory allocator is experiencing scalability issues when
allocating and freeing large numbers of counters as in BPF.
Additionally, there is a corner case where iteration is triggered over
all chunks if the contig_hint is the right size, but wrong alignment.

Implementation:
This patch removes the area map allocator in favor of a bitmap allocator
backed by metadata blocks. The primary goal is to provide consistency
in performance and memory footprint with a focus on small allocations
(< 64 bytes). The bitmap removes the heavy memmove from the freeing
critical path and provides a consistent memory footprint. The metadata
blocks provide a bound on the amount of scanning required by maintaining
a set of hints.

The chunks previously were managed by free_size, a value maintained in
bytes. Now, the chunks are managed in terms of bits, which is just a
scaled value of free_size down by PCPU_MIN_ALLOC_SIZE.

There is one caveat with this implementation. In an effort to make
freeing fast, the only time metadata is updated on the free path is if a
whole block becomes free or the freed area spans across metadata blocks.
This causes the chunka??s contig_hint to be potentially smaller than what
it could allocate by up to a block. If the chunka??s contig_hint is
smaller than a block, a check occurs and the hint is kept accurate.
Metadata is always kept accurate on allocation and therefore the
situation where a chunk has a larger contig_hint than available will
never occur.

Evaluation:
I have primarily done testing against a simple workload of allocation of
1 million objects of varying size. Deallocation was done by in order,
alternating, and in reverse. These numbers were collected after rebasing
ontop of a80099a152. I present the worst-case numbers here:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        335      |     4960
             16B    |        485      |     1150
             64B    |        445      |      280
            128B    |        505      |      177
           1024B    |       3385      |      140

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        725      |       70
             16B    |        760      |       70
             64B    |        855      |       80
            128B    |        910      |       90
           1024B    |       3770      |      260

This data demonstrates the inability for the area map allocator to
handle less than ideal situations. In the best case of reverse
deallocation, the area map allocator was able to perform within range
of the bitmap allocator. In the worst case situation, freeing took
nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
dramatically improves the consistency of the free path. The small
allocations performed nearly identical regardless of the freeing
pattern.

While it does add to the allocation latency, the allocation scenario
here is optimal for the area map allocator. The second problem of
additional scanning can result in the area map allocator completing in
52 minutes. The same workload takes only 14 seconds to complete for the
bitmap allocator. This was produced under a more contrived scenario of
allocating 1 milion 4-byte objects with 8-byte alignment.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |   10 +-
 init/main.c            |    1 -
 mm/percpu-internal.h   |   70 ++-
 mm/percpu-stats.c      |   99 ++--
 mm/percpu.c            | 1280 ++++++++++++++++++++++++++++++------------------
 5 files changed, 923 insertions(+), 537 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index a5cedcd..8f62b10 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -26,6 +26,15 @@
 #define PCPU_MIN_ALLOC_SHIFT		2
 
 /*
+ * This determines the size of each metadata block.  There are several subtle
+ * constraints around this variable.  The reserved_region and dynamic_region
+ * of the first chunk must be multiples of PCPU_BITMAP_BLOCK_SIZE.  This is
+ * not a problem if the BLOCK_SIZE encompasses a page, but if exploring blocks
+ * that are backing multiple pages, this needs to be accounted for.
+ */
+#define PCPU_BITMAP_BLOCK_SIZE		(PAGE_SIZE >> PCPU_MIN_ALLOC_SHIFT)
+
+/*
  * Percpu allocator can serve percpu allocations before slab is
  * initialized which allows slab to depend on the percpu allocator.
  * The following two parameters decide how much resource to
@@ -120,7 +129,6 @@ extern bool is_kernel_percpu_address(unsigned long addr);
 #if !defined(CONFIG_SMP) || !defined(CONFIG_HAVE_SETUP_PER_CPU_AREA)
 extern void __init setup_per_cpu_areas(void);
 #endif
-extern void __init percpu_init_late(void);
 
 extern void __percpu *__alloc_percpu_gfp(size_t size, size_t align, gfp_t gfp);
 extern void __percpu *__alloc_percpu(size_t size, size_t align);
diff --git a/init/main.c b/init/main.c
index 052481f..c9a9fff 100644
--- a/init/main.c
+++ b/init/main.c
@@ -500,7 +500,6 @@ static void __init mm_init(void)
 	page_ext_init_flatmem();
 	mem_init();
 	kmem_cache_init();
-	percpu_init_late();
 	pgtable_init();
 	vmalloc_init();
 	ioremap_huge_init();
diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index f0776f6..2dac644 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -4,6 +4,21 @@
 #include <linux/types.h>
 #include <linux/percpu.h>
 
+/*
+ * pcpu_bitmap_md is the metadata block struct.
+ * All units are in terms of bits.
+ */
+struct pcpu_bitmap_md {
+	int			contig_hint;	/* contig hint for block */
+	int			contig_hint_start; /* block relative starting
+						      position of the contig hint */
+	int			left_free;	/* size of free space along
+						   the left side of the block */
+	int			right_free;	/* size of free space along
+						   the right side of the block */
+	int			first_free;	/* block position of first free */
+};
+
 struct pcpu_chunk {
 #ifdef CONFIG_PERCPU_STATS
 	int			nr_alloc;	/* # of allocations */
@@ -11,17 +26,20 @@ struct pcpu_chunk {
 #endif
 
 	struct list_head	list;		/* linked to pcpu_slot lists */
-	int			free_size;	/* free bytes in the chunk */
-	int			contig_hint;	/* max contiguous size hint */
+	int			free_bits;	/* free bits in the chunk */
+	int			contig_hint;	/* max contiguous size hint
+						   in bits */
+	int			contig_hint_start; /* contig_hint starting
+						      bit offset */
 	void			*base_addr;	/* base address of this chunk */
 
-	int			map_used;	/* # of map entries used before the sentry */
-	int			map_alloc;	/* # of map entries allocated */
-	int			*map;		/* allocation map */
-	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
+	unsigned long		*alloc_map;	/* allocation map */
+	unsigned long		*bound_map;	/* boundary map */
+	struct pcpu_bitmap_md	*md_blocks;	/* metadata blocks */
 
 	void			*data;		/* chunk data */
-	int			first_free;	/* no free below this */
+	int			first_free_block; /* block that contains the first
+						     free bit */
 	bool			immutable;	/* no [de]population allowed */
 	bool			has_reserved;	/* indicates if the region this chunk
 						   is responsible for overlaps with
@@ -44,6 +62,44 @@ extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
 extern unsigned long pcpu_reserved_offset;
 
+/*
+ * pcpu_nr_pages_to_blocks - converts nr_pages to # of md_blocks
+ * @chunk: chunk of interest
+ *
+ * This conversion is from the number of physical pages that the chunk
+ * serves to the number of bitmap blocks required.  It converts to bytes
+ * served to bits required and then blocks used.
+ */
+static inline int pcpu_nr_pages_to_blocks(struct pcpu_chunk *chunk)
+{
+	return chunk->nr_pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE /
+	       PCPU_BITMAP_BLOCK_SIZE;
+}
+
+/*
+ * pcpu_pages_to_bits - converts the pages to size of bitmap
+ * @pages: number of physical pages
+ *
+ * This conversion is from physical pages to the number of bits
+ * required in the bitmap.
+ */
+static inline int pcpu_pages_to_bits(int pages)
+{
+	return pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE;
+}
+
+/*
+ * pcpu_nr_pages_to_bits - helper to convert nr_pages to size of bitmap
+ * @chunk: chunk of interest
+ *
+ * This conversion is from the number of physical pages that the chunk
+ * serves to the number of bits in the bitmap.
+ */
+static inline int pcpu_nr_pages_to_bits(struct pcpu_chunk *chunk)
+{
+	return pcpu_pages_to_bits(chunk->nr_pages);
+}
+
 #ifdef CONFIG_PERCPU_STATS
 
 #include <linux/spinlock.h>
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 6fc04b1..8dbef0c 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -29,64 +29,85 @@ static int cmpint(const void *a, const void *b)
 }
 
 /*
- * Iterates over all chunks to find the max # of map entries used.
+ * Iterates over all chunks to find the max nr_alloc entries.
  */
-static int find_max_map_used(void)
+static int find_max_nr_alloc(void)
 {
 	struct pcpu_chunk *chunk;
-	int slot, max_map_used;
+	int slot, max_nr_alloc;
 
-	max_map_used = 0;
+	max_nr_alloc = 0;
 	for (slot = 0; slot < pcpu_nr_slots; slot++)
 		list_for_each_entry(chunk, &pcpu_slot[slot], list)
-			max_map_used = max(max_map_used, chunk->map_used);
+			max_nr_alloc = max(max_nr_alloc, chunk->nr_alloc);
 
-	return max_map_used;
+	return max_nr_alloc;
 }
 
 /*
  * Prints out chunk state. Fragmentation is considered between
  * the beginning of the chunk to the last allocation.
+ *
+ * All statistics are in bytes unless stated otherwise.
  */
 static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 			    int *buffer)
 {
-	int i, s_index, last_alloc, alloc_sign, as_len;
+	int i, last_alloc, as_len, start, end;
 	int *alloc_sizes, *p;
 	/* statistics */
 	int sum_frag = 0, max_frag = 0;
 	int cur_min_alloc = 0, cur_med_alloc = 0, cur_max_alloc = 0;
 
 	alloc_sizes = buffer;
-	s_index = chunk->has_reserved ? 1 : 0;
-
-	/* find last allocation */
-	last_alloc = -1;
-	for (i = chunk->map_used - 1; i >= s_index; i--) {
-		if (chunk->map[i] & 1) {
-			last_alloc = i;
-			break;
-		}
-	}
 
-	/* if the chunk is not empty - ignoring reserve */
-	if (last_alloc >= s_index) {
-		as_len = last_alloc + 1 - s_index;
-
-		/*
-		 * Iterate through chunk map computing size info.
-		 * The first bit is overloaded to be a used flag.
-		 * negative = free space, positive = allocated
-		 */
-		for (i = 0, p = chunk->map + s_index; i < as_len; i++, p++) {
-			alloc_sign = (*p & 1) ? 1 : -1;
-			alloc_sizes[i] = alloc_sign *
-				((p[1] & ~1) - (p[0] & ~1));
+	/*
+	 * find_last_bit returns the start value if nothing found.
+	 * Therefore, we must determine if it is a failure of find_last_bit
+	 * and set the appropriate value.
+	 */
+	last_alloc = find_last_bit(chunk->alloc_map,
+				   pcpu_nr_pages_to_bits(chunk) - 1);
+	last_alloc = test_bit(last_alloc, chunk->alloc_map) ?
+		     last_alloc + 1 : 0;
+
+	start = as_len = 0;
+	if (chunk->has_reserved)
+		start = pcpu_reserved_offset;
+
+	/*
+	 * If a bit is set in the allocation map, the bound_map identifies
+	 * where the allocation ends.  If the allocation is not set, the
+	 * bound_map does not identify free areas as it is only kept accurate
+	 * on allocation, not free.
+	 *
+	 * Positive values are allocations and negative values are free
+	 * fragments.
+	 */
+	while (start < last_alloc) {
+		if (test_bit(start, chunk->alloc_map)) {
+			end = find_next_bit(chunk->bound_map, last_alloc,
+					    start + 1);
+			alloc_sizes[as_len] = 1;
+		} else {
+			end = find_next_bit(chunk->alloc_map, last_alloc,
+					    start + 1);
+			alloc_sizes[as_len] = -1;
 		}
 
-		sort(alloc_sizes, as_len, sizeof(chunk->map[0]), cmpint, NULL);
+		alloc_sizes[as_len++] *= (end - start) * PCPU_MIN_ALLOC_SIZE;
+
+		start = end;
+	}
+
+	/*
+	 * The negative values are free fragments and thus sorting gives the
+	 * free fragments at the beginning in largest first order.
+	 */
+	if (as_len > 0) {
+		sort(alloc_sizes, as_len, sizeof(int), cmpint, NULL);
 
-		/* Iterate through the unallocated fragements. */
+		/* iterate through the unallocated fragments */
 		for (i = 0, p = alloc_sizes; *p < 0 && i < as_len; i++, p++) {
 			sum_frag -= *p;
 			max_frag = max(max_frag, -1 * (*p));
@@ -100,8 +121,9 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
 	P("empty_pop_pages", chunk->nr_empty_pop_pages);
-	P("free_size", chunk->free_size);
-	P("contig_hint", chunk->contig_hint);
+	P("first_free_block", chunk->first_free_block);
+	P("free_size", chunk->free_bits * PCPU_MIN_ALLOC_SIZE);
+	P("contig_hint", chunk->contig_hint * PCPU_MIN_ALLOC_SIZE);
 	P("sum_frag", sum_frag);
 	P("max_frag", max_frag);
 	P("cur_min_alloc", cur_min_alloc);
@@ -113,22 +135,23 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 static int percpu_stats_show(struct seq_file *m, void *v)
 {
 	struct pcpu_chunk *chunk;
-	int slot, max_map_used;
+	int slot, max_nr_alloc;
 	int *buffer;
 
 alloc_buffer:
 	spin_lock_irq(&pcpu_lock);
-	max_map_used = find_max_map_used();
+	max_nr_alloc = find_max_nr_alloc();
 	spin_unlock_irq(&pcpu_lock);
 
-	buffer = vmalloc(max_map_used * sizeof(pcpu_first_chunk->map[0]));
+	/* there can be at most this many free and allocated fragments */
+	buffer = vmalloc((2 * max_nr_alloc + 1) * sizeof(int));
 	if (!buffer)
 		return -ENOMEM;
 
 	spin_lock_irq(&pcpu_lock);
 
 	/* if the buffer allocated earlier is too small */
-	if (max_map_used < find_max_map_used()) {
+	if (max_nr_alloc < find_max_nr_alloc()) {
 		spin_unlock_irq(&pcpu_lock);
 		vfree(buffer);
 		goto alloc_buffer;
diff --git a/mm/percpu.c b/mm/percpu.c
index fb01841..569df63 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -4,6 +4,9 @@
  * Copyright (C) 2009		SUSE Linux Products GmbH
  * Copyright (C) 2009		Tejun Heo <tj@kernel.org>
  *
+ * Copyright (C) 2017		Facebook Inc.
+ * Copyright (C) 2017		Dennis Zhou <dennisszhou@gmail.com>
+ *
  * This file is released under the GPLv2 license.
  *
  * The percpu allocator handles both static and dynamic areas.  Percpu
@@ -34,19 +37,20 @@
  * percpu variables from kernel modules.  Finally, the dynamic section
  * takes care of normal allocations.
  *
- * Allocation state in each chunk is kept using an array of integers
- * on chunk->map.  A positive value in the map represents a free
- * region and negative allocated.  Allocation inside a chunk is done
- * by scanning this map sequentially and serving the first matching
- * entry.  This is mostly copied from the percpu_modalloc() allocator.
- * Chunks can be determined from the address using the index field
- * in the page struct. The index field contains a pointer to the chunk.
- *
- * These chunks are organized into lists according to free_size and
- * tries to allocate from the fullest chunk first. Each chunk maintains
- * a maximum contiguous area size hint which is guaranteed to be equal
- * to or larger than the maximum contiguous area in the chunk. This
- * helps prevent the allocator from iterating over chunks unnecessarily.
+ * The allocator organizes chunks into lists according to free size and
+ * tries to allocate from the fullest chunk first.  Each chunk is managed
+ * by a bitmap with metadata blocks.  The allocation map is updated on
+ * every allocation to reflect the current state while the boundary map
+ * is only updated on allocation.  Each metadata block contains
+ * information to help mitigate the need to iterate over large portions
+ * of the bitmap.  The reverse mapping from page to chunk is stored in
+ * the page's index.  Lastly, units are lazily backed and grow in unison.
+ *
+ * There is a unique conversion that goes on here between bytes and bits.
+ * The chunk tracks the number of pages it is responsible for in nr_pages.
+ * From there, helper functions are used to convert from physical pages
+ * to bitmap bits and bitmap blocks.  All hints are managed in bits
+ * unless explicitly stated.
  *
  * To use this allocator, arch code should do the following:
  *
@@ -86,10 +90,13 @@
 
 #include "percpu-internal.h"
 
-#define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
-#define PCPU_DFL_MAP_ALLOC		16	/* start a map with 16 ents */
-#define PCPU_ATOMIC_MAP_MARGIN_LOW	32
-#define PCPU_ATOMIC_MAP_MARGIN_HIGH	64
+/*
+ * The metadata is managed in terms of bits with each bit mapping to
+ * a fragment of size PCPU_MIN_ALLOC_SIZE.  Thus, the slots are calculated
+ * with respect to the number of bits available.
+ */
+#define PCPU_SLOT_BASE_SHIFT		3
+
 #define PCPU_EMPTY_POP_PAGES_LOW	2
 #define PCPU_EMPTY_POP_PAGES_HIGH	4
 
@@ -156,10 +163,11 @@ unsigned long pcpu_reserved_offset __ro_after_init;
 DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
 static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
 
-struct list_head *pcpu_slot __ro_after_init; /* chunk list slots */
-
-/* chunks which need their map areas extended, protected by pcpu_lock */
-static LIST_HEAD(pcpu_map_extend_chunks);
+/*
+ * Chunk list slots.  These slots order the chunks by the number of
+ * free bits available in the bitmap.
+ */
+struct list_head *pcpu_slot __ro_after_init;
 
 /*
  * The number of empty populated pages, protected by pcpu_lock.  The
@@ -212,25 +220,25 @@ static bool pcpu_addr_in_reserved_chunk(void *addr)
 	       pcpu_reserved_chunk->nr_pages * PAGE_SIZE;
 }
 
-static int __pcpu_size_to_slot(int size)
+static int __pcpu_size_to_slot(int bit_size)
 {
-	int highbit = fls(size);	/* size is in bytes */
+	int highbit = fls(bit_size);	/* size is in bits */
 	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
 }
 
-static int pcpu_size_to_slot(int size)
+static int pcpu_size_to_slot(int bit_size)
 {
-	if (size == pcpu_unit_size)
+	if (bit_size == pcpu_pages_to_bits(pcpu_unit_pages))
 		return pcpu_nr_slots - 1;
-	return __pcpu_size_to_slot(size);
+	return __pcpu_size_to_slot(bit_size);
 }
 
 static int pcpu_chunk_slot(const struct pcpu_chunk *chunk)
 {
-	if (chunk->free_size < sizeof(int) || chunk->contig_hint < sizeof(int))
+	if (chunk->free_bits == 0 || chunk->contig_hint == 0)
 		return 0;
 
-	return pcpu_size_to_slot(chunk->free_size);
+	return pcpu_size_to_slot(chunk->free_bits);
 }
 
 /* set the pointer to a chunk in a page struct */
@@ -277,6 +285,37 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
 }
 
 /*
+ * The following are helper functions to help access bitmaps and convert
+ * between bitmap offsets to actual address offsets.
+ */
+static unsigned long *pcpu_index_alloc_map(struct pcpu_chunk *chunk, int index)
+{
+	return chunk->alloc_map +
+		(index * PCPU_BITMAP_BLOCK_SIZE / BITS_PER_LONG);
+}
+
+static unsigned long pcpu_off_to_block_index(int off)
+{
+	return off / PCPU_BITMAP_BLOCK_SIZE;
+}
+
+static unsigned long pcpu_off_to_block_off(int off)
+{
+	return off & (PCPU_BITMAP_BLOCK_SIZE - 1);
+}
+
+static unsigned long pcpu_block_off_to_off(int index, int off)
+{
+	return index * PCPU_BITMAP_BLOCK_SIZE + off;
+}
+
+static unsigned long pcpu_block_get_first_page(int index)
+{
+	return PFN_DOWN(index * PCPU_BITMAP_BLOCK_SIZE *
+			PCPU_MIN_ALLOC_SIZE);
+}
+
+/*
  * (Un)populated page region iterators.  Iterate over (un)populated
  * page regions between @start and @end in @chunk.  @rs and @re should
  * be integer variables and will be set to start and end page index of
@@ -329,38 +368,6 @@ static void pcpu_mem_free(void *ptr)
 }
 
 /**
- * pcpu_count_occupied_pages - count the number of pages an area occupies
- * @chunk: chunk of interest
- * @i: index of the area in question
- *
- * Count the number of pages chunk's @i'th area occupies.  When the area's
- * start and/or end address isn't aligned to page boundary, the straddled
- * page is included in the count iff the rest of the page is free.
- */
-static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
-{
-	int off = chunk->map[i] & ~1;
-	int end = chunk->map[i + 1] & ~1;
-
-	if (!PAGE_ALIGNED(off) && i > 0) {
-		int prev = chunk->map[i - 1];
-
-		if (!(prev & 1) && prev <= round_down(off, PAGE_SIZE))
-			off = round_down(off, PAGE_SIZE);
-	}
-
-	if (!PAGE_ALIGNED(end) && i + 1 < chunk->map_used) {
-		int next = chunk->map[i + 1];
-		int nend = chunk->map[i + 2] & ~1;
-
-		if (!(next & 1) && nend >= round_up(end, PAGE_SIZE))
-			end = round_up(end, PAGE_SIZE);
-	}
-
-	return max_t(int, PFN_DOWN(end) - PFN_UP(off), 0);
-}
-
-/**
  * pcpu_chunk_relocate - put chunk in the appropriate chunk slot
  * @chunk: chunk of interest
  * @oslot: the previous slot it was on
@@ -386,385 +393,770 @@ static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
 }
 
 /**
- * pcpu_need_to_extend - determine whether chunk area map needs to be extended
+ * pcpu_cnt_pop_pages- counts populated backing pages in range
  * @chunk: chunk of interest
- * @is_atomic: the allocation context
+ * @start: start index
+ * @end: end index
  *
- * Determine whether area map of @chunk needs to be extended.  If
- * @is_atomic, only the amount necessary for a new allocation is
- * considered; however, async extension is scheduled if the left amount is
- * low.  If !@is_atomic, it aims for more empty space.  Combined, this
- * ensures that the map is likely to have enough available space to
- * accomodate atomic allocations which can't extend maps directly.
- *
- * CONTEXT:
- * pcpu_lock.
+ * Calculates the number of populated pages in the region [start, end).
+ * This lets us keep track of how many empty populated pages are available
+ * and decide if we should schedule async work.
  *
  * RETURNS:
- * New target map allocation length if extension is necessary, 0
- * otherwise.
+ * The nr of populated pages.
  */
-static int pcpu_need_to_extend(struct pcpu_chunk *chunk, bool is_atomic)
+static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk,
+				      int start, int end)
 {
-	int margin, new_alloc;
-
-	lockdep_assert_held(&pcpu_lock);
+	return bitmap_weight(chunk->populated, end) -
+	       bitmap_weight(chunk->populated, start);
+}
 
-	if (is_atomic) {
-		margin = 3;
+/**
+ * pcpu_chunk_update_hint - updates metadata about a chunk
+ * @chunk: chunk of interest
+ *
+ * Responsible for iterating over metadata blocks to aggregate the
+ * overall statistics of the chunk.
+ *
+ * Updates:
+ *      chunk->contig_hint
+ *      chunk->contig_hint_start
+ *      nr_empty_pop_pages
+ */
+static void pcpu_chunk_update_hint(struct pcpu_chunk *chunk)
+{
+	bool is_page_empty = true;
+	int i, off, cur_contig, nr_empty_pop_pages, l_pop_off;
+	struct pcpu_bitmap_md *block;
+
+	chunk->contig_hint = cur_contig = 0;
+	off = nr_empty_pop_pages = 0;
+	l_pop_off = pcpu_block_get_first_page(chunk->first_free_block);
+
+	for (i = chunk->first_free_block, block = chunk->md_blocks + i;
+	     i < pcpu_nr_pages_to_blocks(chunk); i++, block++) {
+		/* Manage nr_empty_pop_pages.
+		 *
+		 * This is tricky.  So the the background work function is
+		 * triggered when there are not enough free populated pages.
+		 * This is necessary to make sure atomic allocations can
+		 * succeed.
+		 *
+		 * The first page of each block is kept track of here allowing
+		 * this to scale in both situations where there are > 1 page
+		 * per block and where a block may be a portion of a page.
+		 */
+		int pop_off = pcpu_block_get_first_page(i);
+
+		if (pop_off > l_pop_off) {
+			if (is_page_empty)
+				nr_empty_pop_pages +=
+					pcpu_cnt_pop_pages(chunk, l_pop_off,
+							   pop_off);
+			l_pop_off = pop_off;
+			is_page_empty = true;
+		}
+		if (block->contig_hint != PCPU_BITMAP_BLOCK_SIZE)
+			is_page_empty = false;
 
-		if (chunk->map_alloc <
-		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
-			if (list_empty(&chunk->map_extend_list)) {
-				list_add_tail(&chunk->map_extend_list,
-					      &pcpu_map_extend_chunks);
-				pcpu_schedule_balance_work();
+		/* continue from prev block adding to the cur_contig hint */
+		if (cur_contig) {
+			cur_contig += block->left_free;
+			if (block->left_free == PCPU_BITMAP_BLOCK_SIZE) {
+				continue;
+			} else if (cur_contig > chunk->contig_hint) {
+				chunk->contig_hint = cur_contig;
+				chunk->contig_hint_start = off;
 			}
+			cur_contig = 0;
 		}
-	} else {
-		margin = PCPU_ATOMIC_MAP_MARGIN_HIGH;
+		/* check if the block->contig_hint is larger */
+		if (block->contig_hint > chunk->contig_hint) {
+			chunk->contig_hint = block->contig_hint;
+			chunk->contig_hint_start =
+				pcpu_block_off_to_off(i,
+						      block->contig_hint_start);
+		}
+		/* let the next iteration catch the right_free */
+		cur_contig = block->right_free;
+		off = (i + 1) * PCPU_BITMAP_BLOCK_SIZE - block->right_free;
 	}
 
-	if (chunk->map_alloc >= chunk->map_used + margin)
-		return 0;
-
-	new_alloc = PCPU_DFL_MAP_ALLOC;
-	while (new_alloc < chunk->map_used + margin)
-		new_alloc *= 2;
+	/* catch last iteration if the last block ends with free space */
+	if (cur_contig > chunk->contig_hint) {
+		chunk->contig_hint = cur_contig;
+		chunk->contig_hint_start = off;
+	}
 
-	return new_alloc;
+	/*
+	 * Keep track of nr_empty_pop_pages.
+	 *
+	 * The chunk is maintains the previous number of free pages it held,
+	 * so the delta is used to update the global counter.  The reserved
+	 * chunk is not part of the free page count as they are populated
+	 * at init and are special to serving reserved allocations.
+	 */
+	if (is_page_empty) {
+		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, l_pop_off,
+							 chunk->nr_pages);
+	}
+	if (chunk != pcpu_reserved_chunk)
+		pcpu_nr_empty_pop_pages +=
+			(nr_empty_pop_pages - chunk->nr_empty_pop_pages);
+	chunk->nr_empty_pop_pages = nr_empty_pop_pages;
 }
 
 /**
- * pcpu_extend_area_map - extend area map of a chunk
+ * pcpu_block_update_hint
  * @chunk: chunk of interest
- * @new_alloc: new target allocation length of the area map
+ * @index: block index of the metadata block
  *
- * Extend area map of @chunk to have @new_alloc entries.
+ * Full scan over the entire block to recalculate block-level metadata.
+ */
+static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
+{
+	unsigned long *alloc_map = pcpu_index_alloc_map(chunk, index);
+	struct pcpu_bitmap_md *block = chunk->md_blocks + index;
+	bool is_left_free = false, is_right_free = false;
+	int contig;
+	unsigned long start, end;
+
+	block->contig_hint = 0;
+	start = end = block->first_free;
+	while (start < PCPU_BITMAP_BLOCK_SIZE) {
+		/*
+		 * Scans the allocation map corresponding to this block
+		 * to find free fragments and update metadata accordingly.
+		 */
+		start = find_next_zero_bit(alloc_map, PCPU_BITMAP_BLOCK_SIZE,
+					   start);
+		if (start >= PCPU_BITMAP_BLOCK_SIZE)
+			break;
+		/* returns PCPU_BITMAP_BLOCK_SIZE if no next bit is found */
+		end = find_next_bit(alloc_map, PCPU_BITMAP_BLOCK_SIZE, start);
+		/* update left_free */
+		contig = end - start;
+		if (start == 0) {
+			block->left_free = contig;
+			is_left_free = true;
+		}
+		/* update right_free */
+		if (end == PCPU_BITMAP_BLOCK_SIZE) {
+			block->right_free = contig;
+			is_right_free = true;
+		}
+		/* update block contig_hints */
+		if (block->contig_hint < contig) {
+			block->contig_hint = contig;
+			block->contig_hint_start = start;
+		}
+		start = end;
+	}
+
+	/* clear left/right free hints */
+	if (!is_left_free)
+		block->left_free = 0;
+	if (!is_right_free)
+		block->right_free = 0;
+}
+
+/**
+ * pcpu_block_update_hint_alloc - update hint on allocation path
+ * @chunk: chunk of interest
+ * @bit_off: bitmap offset
+ * @bit_size: size of request in allocation units
  *
- * CONTEXT:
- * Does GFP_KERNEL allocation.  Grabs and releases pcpu_lock.
+ * Updates metadata for the allocation path.  The metadata only has to be
+ * refreshed by a full scan iff we break the largest contig region.
  *
  * RETURNS:
- * 0 on success, -errno on failure.
+ * Bool if we need to update the chunk's metadata. This occurs only if we
+ * break the chunk's contig hint.
  */
-static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
+static bool pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
+					 int bit_size)
 {
-	int *old = NULL, *new = NULL;
-	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
-	unsigned long flags;
-
-	lockdep_assert_held(&pcpu_alloc_mutex);
+	bool update_chunk = false;
+	int i;
+	int s_index, e_index, s_off, e_off;
+	struct pcpu_bitmap_md *s_block, *e_block, *block;
 
-	new = pcpu_mem_zalloc(new_size);
-	if (!new)
-		return -ENOMEM;
+	/* calculate per block offsets */
+	s_index = pcpu_off_to_block_index(bit_off);
+	e_index = pcpu_off_to_block_index(bit_off + bit_size);
+	s_off = pcpu_off_to_block_off(bit_off);
+	e_off = pcpu_off_to_block_off(bit_off + bit_size);
 
-	/* acquire pcpu_lock and switch to new area map */
-	spin_lock_irqsave(&pcpu_lock, flags);
+	/*
+	 * If the offset is the beginning of the next block, set it to the
+	 * end of the previous block as the last bit is the exclusive.
+	 */
+	if (e_off == 0) {
+		e_off = PCPU_BITMAP_BLOCK_SIZE;
+		e_index--;
+	}
 
-	if (new_alloc <= chunk->map_alloc)
-		goto out_unlock;
+	s_block = chunk->md_blocks + s_index;
+	e_block = chunk->md_blocks + e_index;
 
-	old_size = chunk->map_alloc * sizeof(chunk->map[0]);
-	old = chunk->map;
+	/*
+	 * Update s_block.
+	 *
+	 * block->first_free must be updated if the allocation takes its place.
+	 * If the allocation breaks the contig_hint, a scan is required to
+	 * restore this hint.
+	 */
+	if (s_off == s_block->first_free)
+		s_block->first_free = find_next_zero_bit(
+					pcpu_index_alloc_map(chunk, s_index),
+					PCPU_BITMAP_BLOCK_SIZE,
+					s_off + bit_size);
+
+	if (s_off >= s_block->contig_hint_start &&
+	    s_off < s_block->contig_hint_start + s_block->contig_hint) {
+		pcpu_block_refresh_hint(chunk, s_index);
+	} else {
+		/* update left and right contig manually */
+		s_block->left_free = min(s_block->left_free, s_off);
+		if (s_index == e_index)
+			s_block->right_free = min_t(int, s_block->right_free,
+					PCPU_BITMAP_BLOCK_SIZE - e_off);
+		else
+			s_block->right_free = 0;
+	}
 
-	memcpy(new, old, old_size);
+	/*
+	 * Update e_block.
+	 * If they are different, then e_block's first_free is guaranteed to
+	 * be the extend of e_off.  first_free must be updated and a scan
+	 * over e_block is issued.
+	 */
+	if (s_index != e_index) {
+		e_block->first_free = find_next_zero_bit(
+				pcpu_index_alloc_map(chunk, e_index),
+				PCPU_BITMAP_BLOCK_SIZE, e_off);
 
-	chunk->map_alloc = new_alloc;
-	chunk->map = new;
-	new = NULL;
+		pcpu_block_refresh_hint(chunk, e_index);
+	}
 
-out_unlock:
-	spin_unlock_irqrestore(&pcpu_lock, flags);
+	/* update in-between md_blocks */
+	for (i = s_index + 1, block = chunk->md_blocks + i; i < e_index;
+	     i++, block++) {
+		block->contig_hint = 0;
+		block->left_free = 0;
+		block->right_free = 0;
+	}
 
 	/*
-	 * pcpu_mem_free() might end up calling vfree() which uses
-	 * IRQ-unsafe lock and thus can't be called under pcpu_lock.
+	 * The only time a full chunk scan is required is if the global
+	 * contig_hint is broken.  Otherwise, it means a smaller space
+	 * was used and therefore the global contig_hint is still correct.
 	 */
-	pcpu_mem_free(old);
-	pcpu_mem_free(new);
+	if (bit_off >= chunk->contig_hint_start &&
+	    bit_off < chunk->contig_hint_start + chunk->contig_hint)
+		update_chunk = true;
 
-	return 0;
+	return update_chunk;
 }
 
 /**
- * pcpu_fit_in_area - try to fit the requested allocation in a candidate area
- * @chunk: chunk the candidate area belongs to
- * @off: the offset to the start of the candidate area
- * @this_size: the size of the candidate area
- * @size: the size of the target allocation
- * @align: the alignment of the target allocation
- * @pop_only: only allocate from already populated region
- *
- * We're trying to allocate @size bytes aligned at @align.  @chunk's area
- * at @off sized @this_size is a candidate.  This function determines
- * whether the target allocation fits in the candidate area and returns the
- * number of bytes to pad after @off.  If the target area doesn't fit, -1
- * is returned.
- *
- * If @pop_only is %true, this function only considers the already
- * populated part of the candidate area.
+ * pcpu_block_update_hint_free - updates the block hints on the free path
+ * @chunk: chunk of interest
+ * @bit_off: bitmap offset
+ * @bit_size: size of request in allocation units
+ *
+ * Updates the hint along the free path by taking advantage of current metadata
+ * to minimize scanning of the bitmap.  Triggers a global update if an entire
+ * block becomes free or the free spans across blocks.  This tradeoff is to
+ * minimize global scanning to update the chunk->contig_hint.  The
+ * chunk->contig_hint may be off by up to a block, but a chunk->contig_hint
+ * will never be more than the available space.  If the chunk->contig_hint is
+ * in this block, it will be accurate.
+ *
+ * RETURNS:
+ * Bool if we need to update the chunk's metadata.  This occurs if a larger
+ * contig region is created along the edges or we free across blocks.
  */
-static int pcpu_fit_in_area(struct pcpu_chunk *chunk, int off, int this_size,
-			    int size, int align, bool pop_only)
+static bool pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
+					int bit_size)
 {
-	int cand_off = off;
+	bool update_chunk = false;
+	int i;
+	int s_index, e_index, s_off, e_off;
+	int start, end, contig;
+	struct pcpu_bitmap_md *s_block, *e_block, *block;
 
-	while (true) {
-		int head = ALIGN(cand_off, align) - off;
-		int page_start, page_end, rs, re;
+	/* calculate per block offsets */
+	s_index = pcpu_off_to_block_index(bit_off);
+	e_index = pcpu_off_to_block_index(bit_off + bit_size);
+	s_off = pcpu_off_to_block_off(bit_off);
+	e_off = pcpu_off_to_block_off(bit_off + bit_size);
+
+	/*
+	 * If the offset is the beginning of the next block, set it to the
+	 * end of the previous block as the last bit is the exclusive.
+	 */
+	if (e_off == 0) {
+		e_off = PCPU_BITMAP_BLOCK_SIZE;
+		e_index--;
+	}
+
+	s_block = chunk->md_blocks + s_index;
+	e_block = chunk->md_blocks + e_index;
+
+	/*
+	 * Check if the freed area aligns with the block->contig_hint.
+	 * If it does, then the scan to find the beginning/end of the
+	 * larger free area can be avoided.
+	 *
+	 * start and end refer to beginning and end of the free region
+	 * within each their respective blocks.  This is not necessarily
+	 * the entire free region as it may span blocks past the beginning
+	 * or end of the block.
+	 */
+	start = s_off;
+	if (s_off == s_block->contig_hint + s_block->contig_hint_start) {
+		start = s_block->contig_hint_start;
+	} else {
+		int l_bit = find_last_bit(pcpu_index_alloc_map(chunk, s_index),
+					  start);
+		start = (start == l_bit) ? 0 : l_bit + 1;
+	}
+
+	end = e_off;
+	if (e_off == e_block->contig_hint_start)
+		end = e_block->contig_hint_start + e_block->contig_hint;
+	else
+		end = find_next_bit(pcpu_index_alloc_map(chunk, e_index),
+				    PCPU_BITMAP_BLOCK_SIZE, end);
 
-		if (this_size < head + size)
-			return -1;
+	/* freeing in the same block */
+	if (s_index == e_index) {
+		contig = end - start;
 
-		if (!pop_only)
-			return head;
+		if (start == 0)
+			s_block->left_free = contig;
 
+		if (end == PCPU_BITMAP_BLOCK_SIZE)
+			s_block->right_free = contig;
+
+		s_block->first_free = min(s_block->first_free, start);
+		if (contig > s_block->contig_hint) {
+			s_block->contig_hint = contig;
+			s_block->contig_hint_start = start;
+		}
+
+	} else {
 		/*
-		 * If the first unpopulated page is beyond the end of the
-		 * allocation, the whole allocation is populated;
-		 * otherwise, retry from the end of the unpopulated area.
+		 * Freeing across md_blocks.
+		 *
+		 * If the start is at the beginning of the block, just
+		 * reset the block instead.
 		 */
-		page_start = PFN_DOWN(head + off);
-		page_end = PFN_UP(head + off + size);
-
-		rs = page_start;
-		pcpu_next_unpop(chunk, &rs, &re, PFN_UP(off + this_size));
-		if (rs >= page_end)
-			return head;
-		cand_off = re * PAGE_SIZE;
+		if (start == 0) {
+			s_index--;
+		} else {
+			/*
+			 * Knowing that the free is across blocks, this means
+			 * the hint can be updated on the right side and the
+			 * left side does not need to be touched.
+			 */
+			s_block->first_free = min(s_block->first_free, start);
+			contig = PCPU_BITMAP_BLOCK_SIZE - start;
+			s_block->right_free = contig;
+			if (contig > s_block->contig_hint) {
+				s_block->contig_hint = contig;
+				s_block->contig_hint_start = start;
+			}
+		}
+		/*
+		 * If end is the entire e_block, just reset the block
+		 * as well.
+		 */
+		if (end == PCPU_BITMAP_BLOCK_SIZE) {
+			e_index++;
+		} else {
+			/*
+			 * The hint must only be on the left side, so
+			 * update accordingly.
+			 */
+			e_block->first_free = 0;
+			e_block->left_free = end;
+			if (end > e_block->contig_hint) {
+				e_block->contig_hint = end;
+				e_block->contig_hint_start = 0;
+			}
+		}
+
+		/* reset md_blocks in the middle */
+		for (i = s_index + 1, block = chunk->md_blocks + i;
+		     i < e_index; i++, block++) {
+			block->first_free = 0;
+			block->contig_hint_start = 0;
+			block->contig_hint = PCPU_BITMAP_BLOCK_SIZE;
+			block->left_free = PCPU_BITMAP_BLOCK_SIZE;
+			block->right_free = PCPU_BITMAP_BLOCK_SIZE;
+		}
 	}
+
+	/*
+	 * The hint is only checked in the s_block and e_block when
+	 * freeing and particularly only when it is self contained within
+	 * its own block.  A scan is required if the free space spans
+	 * blocks or makes a block whole as the scan will take into
+	 * account free space across blocks.
+	 */
+	if ((start == 0 && end == PCPU_BITMAP_BLOCK_SIZE) ||
+	    s_index != e_index) {
+		update_chunk = true;
+	} else if (s_block->contig_hint > chunk->contig_hint) {
+		/* check if block contig_hint is bigger */
+		chunk->contig_hint = s_block->contig_hint;
+		chunk->contig_hint_start =
+			pcpu_block_off_to_off(s_index,
+					      s_block->contig_hint_start);
+	}
+
+	return update_chunk;
 }
 
 /**
- * pcpu_alloc_area - allocate area from a pcpu_chunk
+ * pcpu_is_populated - determines if the region is populated
  * @chunk: chunk of interest
- * @size: wanted size in bytes
- * @align: wanted align
- * @pop_only: allocate only from the populated area
- * @occ_pages_p: out param for the number of pages the area occupies
+ * @index: block index
+ * @block_off: offset within the bitmap
+ * @bit_size: size of request in allocation units
+ * @next_index: return value for next block index that is populated
  *
- * Try to allocate @size bytes area aligned at @align from @chunk.
- * Note that this function only allocates the offset.  It doesn't
- * populate or map the area.
+ * For atomic allocations, we must check if the backing pages are populated.
  *
- * @chunk->map must have at least two free slots.
+ * RETURNS:
+ * Bool if the backing pages are populated.  next_index is to skip over
+ * unpopulated blocks in pcpu_find_block_fit.
+ */
+static bool pcpu_is_populated(struct pcpu_chunk *chunk, int index,
+			      int block_off, int bit_size, int *next_index)
+{
+	int page_start, page_end, rs, re;
+	int off = pcpu_block_off_to_off(index, block_off);
+	int e_off = off + bit_size * PCPU_MIN_ALLOC_SIZE;
+
+	page_start = PFN_DOWN(off);
+	page_end = PFN_UP(e_off);
+
+	rs = page_start;
+	pcpu_next_unpop(chunk, &rs, &re, PFN_UP(e_off));
+	if (rs >= page_end)
+		return true;
+	*next_index = re * PAGE_SIZE / PCPU_BITMAP_BLOCK_SIZE;
+	return false;
+}
+
+/**
+ * pcpu_find_block_fit - finds the block index to start searching
+ * @chunk: chunk of interest
+ * @bit_size: size of request in allocation units
+ * @align: alignment of area (max PAGE_SIZE)
+ * @pop_only: use populated regions only
  *
- * CONTEXT:
- * pcpu_lock.
+ * Given a chunk and an allocation spec, find the offset to begin searching
+ * for a free region.  This is done by iterating over the bitmap metadata
+ * blocks and then only returning regions that will be guaranteed to fit
+ * alignment by comparing against the block->contig_hint_start or a correctly
+ * aligned offset.  Iteration is used within a block as an allocation may be
+ * able to be served prior to the contig_hint.
+ *
+ * Note: This errs on the side of caution by only selecting blocks guaranteed
+ *	 to have a fit in the chunk's contig_hint.  Poor alignment can cause
+ *	 us to skip over chunk's that have valid vacancies.
  *
  * RETURNS:
- * Allocated offset in @chunk on success, -1 if no matching area is
- * found.
+ * The offset in the bitmap to begin searching.
+ * -1 if no offset is found.
  */
-static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align,
-			   bool pop_only, int *occ_pages_p)
+static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int bit_size,
+			       size_t align, bool pop_only)
 {
-	int oslot = pcpu_chunk_slot(chunk);
-	int max_contig = 0;
-	int i, off;
-	bool seen_free = false;
-	int *p;
-
-	for (i = chunk->first_free, p = chunk->map + i; i < chunk->map_used; i++, p++) {
-		int head, tail;
-		int this_size;
-
-		off = *p;
-		if (off & 1)
-			continue;
+	int i, cur_free;
+	int s_index, block_off, next_index, end_off; /* interior alloc index */
+	struct pcpu_bitmap_md *block;
+	unsigned long *alloc_map;
 
-		this_size = (p[1] & ~1) - off;
+	lockdep_assert_held(&pcpu_lock);
 
-		head = pcpu_fit_in_area(chunk, off, this_size, size, align,
-					pop_only);
-		if (head < 0) {
-			if (!seen_free) {
-				chunk->first_free = i;
-				seen_free = true;
-			}
-			max_contig = max(this_size, max_contig);
+	cur_free = block_off = 0;
+	s_index = chunk->first_free_block;
+	for (i = chunk->first_free_block; i < pcpu_nr_pages_to_blocks(chunk);
+	     i++) {
+		alloc_map = pcpu_index_alloc_map(chunk, i);
+		block = chunk->md_blocks + i;
+
+		/* continue from prev block */
+		cur_free += block->left_free;
+		if (cur_free >= bit_size) {
+			end_off = bit_size;
+			goto check_populated;
+		} else if (block->left_free == PCPU_BITMAP_BLOCK_SIZE) {
 			continue;
 		}
 
 		/*
-		 * If head is small or the previous block is free,
-		 * merge'em.  Note that 'small' is defined as smaller
-		 * than sizeof(int), which is very small but isn't too
-		 * uncommon for percpu allocations.
+		 * Can this block hold this alloc?
+		 *
+		 * Here the block->contig_hint is used to guarantee a fit,
+		 * but the block->first_free is returned as we may be able
+		 * to serve the allocation earlier.  The population check
+		 * must take into account the area beginning at first_free
+		 * through the end of the contig_hint.
 		 */
-		if (head && (head < sizeof(int) || !(p[-1] & 1))) {
-			*p = off += head;
-			if (p[-1] & 1)
-				chunk->free_size -= head;
-			else
-				max_contig = max(*p - p[-1], max_contig);
-			this_size -= head;
-			head = 0;
+		cur_free = 0;
+		s_index = i;
+		block_off = ALIGN(block->contig_hint_start, align);
+		block_off -= block->contig_hint_start;
+		if (block->contig_hint >= block_off + bit_size) {
+			block_off = block->first_free;
+			end_off = block->contig_hint_start - block_off +
+				  bit_size;
+			goto check_populated;
 		}
 
-		/* if tail is small, just keep it around */
-		tail = this_size - head - size;
-		if (tail < sizeof(int)) {
-			tail = 0;
-			size = this_size - head;
+		/* check right */
+		block_off = ALIGN(PCPU_BITMAP_BLOCK_SIZE - block->right_free,
+				  align);
+		/* reset to start looking in the next block */
+		if (block_off >= PCPU_BITMAP_BLOCK_SIZE) {
+			s_index++;
+			cur_free = block_off = 0;
+			continue;
 		}
+		cur_free = PCPU_BITMAP_BLOCK_SIZE - block_off;
+		if (cur_free >= bit_size) {
+			end_off = bit_size;
+check_populated:
+			if (!pop_only ||
+			    pcpu_is_populated(chunk, s_index, block_off,
+					      end_off, &next_index))
+				break;
 
-		/* split if warranted */
-		if (head || tail) {
-			int nr_extra = !!head + !!tail;
-
-			/* insert new subblocks */
-			memmove(p + nr_extra + 1, p + 1,
-				sizeof(chunk->map[0]) * (chunk->map_used - i));
-			chunk->map_used += nr_extra;
-
-			if (head) {
-				if (!seen_free) {
-					chunk->first_free = i;
-					seen_free = true;
-				}
-				*++p = off += head;
-				++i;
-				max_contig = max(head, max_contig);
-			}
-			if (tail) {
-				p[1] = off + size;
-				max_contig = max(tail, max_contig);
-			}
+			i = next_index - 1;
+			s_index = next_index;
+			cur_free = block_off = 0;
 		}
+	}
 
-		if (!seen_free)
-			chunk->first_free = i + 1;
+	/* nothing found */
+	if (i == pcpu_nr_pages_to_blocks(chunk))
+		return -1;
 
-		/* update hint and mark allocated */
-		if (i + 1 == chunk->map_used)
-			chunk->contig_hint = max_contig; /* fully scanned */
-		else
-			chunk->contig_hint = max(chunk->contig_hint,
-						 max_contig);
+	return s_index * PCPU_BITMAP_BLOCK_SIZE + block_off;
+}
 
-		chunk->free_size -= size;
-		*p |= 1;
 
-		*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
-		pcpu_chunk_relocate(chunk, oslot);
-		return off;
-	}
+/**
+ * pcpu_alloc_area - allocates area from a pcpu_chunk
+ * @chunk: chunk of interest
+ * @bit_size: size of request in allocation units
+ * @align: alignment of area (max PAGE_SIZE)
+ * @start: bit_off to start searching
+ *
+ * This function takes in a start bit_offset to begin searching.  It
+ * searches the allocation bitmap to verify that the offset is available
+ * as block->first_free is provided when allocation within a block is
+ * available.
+ *
+ * RETURNS:
+ * Allocated addr offset in @chunk on success,
+ * -1 if no matching area is found
+ */
+static int pcpu_alloc_area(struct pcpu_chunk *chunk, int bit_size,
+			   size_t align, int start)
+{
+	size_t align_mask = (align) ? (align - 1) : 0;
+	int i, bit_off, oslot;
+	struct pcpu_bitmap_md *block;
+
+	lockdep_assert_held(&pcpu_lock);
+
+	oslot = pcpu_chunk_slot(chunk);
+
+	/* search to find fit */
+	bit_off = bitmap_find_next_zero_area(chunk->alloc_map,
+					     pcpu_nr_pages_to_bits(chunk),
+					     start, bit_size, align_mask);
+
+	if (bit_off >= pcpu_nr_pages_to_bits(chunk))
+		return -1;
+
+	/* update alloc map */
+	bitmap_set(chunk->alloc_map, bit_off, bit_size);
+	/* update boundary map */
+	set_bit(bit_off, chunk->bound_map);
+	bitmap_clear(chunk->bound_map, bit_off + 1, bit_size - 1);
+	set_bit(bit_off + bit_size, chunk->bound_map);
+
+	chunk->free_bits -= bit_size;
+
+	if (pcpu_block_update_hint_alloc(chunk, bit_off, bit_size))
+		pcpu_chunk_update_hint(chunk);
+
+	/* update chunk first_free */
+	for (i = chunk->first_free_block, block = chunk->md_blocks + i;
+	     i < pcpu_nr_pages_to_blocks(chunk); i++, block++)
+		if (block->contig_hint != 0)
+			break;
+
+	chunk->first_free_block = i;
 
-	chunk->contig_hint = max_contig;	/* fully scanned */
 	pcpu_chunk_relocate(chunk, oslot);
 
-	/* tell the upper layer that this chunk has no matching area */
-	return -1;
+	return bit_off * PCPU_MIN_ALLOC_SIZE;
 }
 
 /**
- * pcpu_free_area - free area to a pcpu_chunk
+ * pcpu_free_area - frees the corresponding offset
  * @chunk: chunk of interest
- * @freeme: offset of area to free
- * @occ_pages_p: out param for the number of pages the area occupies
+ * @off: addr offset into chunk
  *
- * Free area starting from @freeme to @chunk.  Note that this function
- * only modifies the allocation map.  It doesn't depopulate or unmap
- * the area.
- *
- * CONTEXT:
- * pcpu_lock.
+ * This function determines the size of an allocation to free using
+ * the boundary bitmap and clears the allocation map.  A block metadata
+ * update is triggered and potentially a chunk update occurs.
  */
-static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
-			   int *occ_pages_p)
+static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 {
-	int oslot = pcpu_chunk_slot(chunk);
-	int off = 0;
-	unsigned i, j;
-	int to_free = 0;
-	int *p;
+	int bit_off, bit_size, index, end, oslot;
+	struct pcpu_bitmap_md *block;
 
 	lockdep_assert_held(&pcpu_lock);
 	pcpu_stats_area_dealloc(chunk);
 
-	freeme |= 1;	/* we are searching for <given offset, in use> pair */
-
-	i = 0;
-	j = chunk->map_used;
-	while (i != j) {
-		unsigned k = (i + j) / 2;
-		off = chunk->map[k];
-		if (off < freeme)
-			i = k + 1;
-		else if (off > freeme)
-			j = k;
-		else
-			i = j = k;
-	}
-	BUG_ON(off != freeme);
+	oslot = pcpu_chunk_slot(chunk);
 
-	if (i < chunk->first_free)
-		chunk->first_free = i;
+	bit_off = off / PCPU_MIN_ALLOC_SIZE;
 
-	p = chunk->map + i;
-	*p = off &= ~1;
-	chunk->free_size += (p[1] & ~1) - off;
+	/* find end index */
+	end = find_next_bit(chunk->bound_map, pcpu_nr_pages_to_bits(chunk),
+			    bit_off + 1);
+	bit_size = end - bit_off;
 
-	*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
+	bitmap_clear(chunk->alloc_map, bit_off, bit_size);
 
-	/* merge with next? */
-	if (!(p[1] & 1))
-		to_free++;
-	/* merge with previous? */
-	if (i > 0 && !(p[-1] & 1)) {
-		to_free++;
-		i--;
-		p--;
-	}
-	if (to_free) {
-		chunk->map_used -= to_free;
-		memmove(p + 1, p + 1 + to_free,
-			(chunk->map_used - i) * sizeof(chunk->map[0]));
-	}
+	chunk->free_bits += bit_size;
+
+	/* update first_free */
+	index = pcpu_off_to_block_index(bit_off);
+	block = chunk->md_blocks + index;
+	block->first_free = min_t(int, block->first_free,
+				  bit_off % PCPU_BITMAP_BLOCK_SIZE);
+
+	chunk->first_free_block = min(chunk->first_free_block, index);
+
+	if (pcpu_block_update_hint_free(chunk, bit_off, bit_size))
+		pcpu_chunk_update_hint(chunk);
 
-	chunk->contig_hint = max(chunk->map[i + 1] - chunk->map[i] - 1, chunk->contig_hint);
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
+static void pcpu_init_md_blocks(struct pcpu_chunk *chunk)
+{
+	struct pcpu_bitmap_md *md_block;
+
+	for (md_block = chunk->md_blocks;
+	     md_block != chunk->md_blocks + pcpu_nr_pages_to_blocks(chunk);
+	     md_block++) {
+		md_block->contig_hint = PCPU_BITMAP_BLOCK_SIZE;
+		md_block->left_free = PCPU_BITMAP_BLOCK_SIZE;
+		md_block->right_free = PCPU_BITMAP_BLOCK_SIZE;
+	}
+}
+
+static struct pcpu_chunk * __init pcpu_alloc_first_chunk(int chunk_pages)
+{
+	struct pcpu_chunk *chunk;
+	int map_size_bits;
+
+	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
+				     BITS_TO_LONGS(chunk_pages), 0);
+
+	INIT_LIST_HEAD(&chunk->list);
+	chunk->has_reserved = false;
+	chunk->immutable = true;
+
+	chunk->nr_pages = chunk_pages;
+	map_size_bits = pcpu_nr_pages_to_bits(chunk);
+
+	chunk->alloc_map = memblock_virt_alloc(
+				BITS_TO_LONGS(map_size_bits) *
+				sizeof(chunk->alloc_map[0]), 0);
+	chunk->bound_map = memblock_virt_alloc(
+				BITS_TO_LONGS(map_size_bits + 1) *
+				sizeof(chunk->bound_map[0]), 0);
+	chunk->md_blocks = memblock_virt_alloc(
+				pcpu_nr_pages_to_blocks(chunk) *
+				sizeof(struct pcpu_bitmap_md), 0);
+	pcpu_init_md_blocks(chunk);
+
+	/* fill page populated map - the first chunk is fully populated */
+	bitmap_fill(chunk->populated, chunk_pages);
+	chunk->nr_populated = chunk->nr_empty_pop_pages = chunk_pages;
+
+	return chunk;
+}
+
 static struct pcpu_chunk *pcpu_alloc_chunk(void)
 {
 	struct pcpu_chunk *chunk;
+	int map_size_bits;
 
 	chunk = pcpu_mem_zalloc(pcpu_chunk_struct_size);
 	if (!chunk)
 		return NULL;
 
-	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
-						sizeof(chunk->map[0]));
-	if (!chunk->map) {
-		pcpu_mem_free(chunk);
-		return NULL;
-	}
-
-	chunk->map_alloc = PCPU_DFL_MAP_ALLOC;
-	chunk->map[0] = 0;
-	chunk->map[1] = pcpu_unit_size | 1;
-	chunk->map_used = 1;
-	chunk->has_reserved = false;
-
 	INIT_LIST_HEAD(&chunk->list);
-	INIT_LIST_HEAD(&chunk->map_extend_list);
-	chunk->free_size = pcpu_unit_size;
-	chunk->contig_hint = pcpu_unit_size;
+	chunk->has_reserved = false;
 
 	chunk->nr_pages = pcpu_unit_pages;
+	map_size_bits = pcpu_nr_pages_to_bits(chunk);
+
+	chunk->alloc_map = pcpu_mem_zalloc(BITS_TO_LONGS(map_size_bits) *
+					   sizeof(chunk->alloc_map[0]));
+	if (!chunk->alloc_map)
+		goto alloc_map_fail;
+
+	chunk->bound_map = pcpu_mem_zalloc(BITS_TO_LONGS(map_size_bits + 1) *
+					   sizeof(chunk->bound_map[0]));
+	if (!chunk->alloc_map)
+		goto bound_map_fail;
+
+	chunk->md_blocks = pcpu_mem_zalloc(pcpu_nr_pages_to_blocks(chunk) *
+					   sizeof(chunk->md_blocks[0]));
+	if (!chunk->alloc_map)
+		goto md_blocks_fail;
+
+	pcpu_init_md_blocks(chunk);
+
+	/* init metadata */
+	chunk->contig_hint = chunk->free_bits = map_size_bits;
 
 	return chunk;
+
+md_blocks_fail:
+	pcpu_mem_free(chunk->bound_map);
+bound_map_fail:
+	pcpu_mem_free(chunk->alloc_map);
+alloc_map_fail:
+	pcpu_mem_free(chunk);
+
+	return NULL;
 }
 
 static void pcpu_free_chunk(struct pcpu_chunk *chunk)
 {
 	if (!chunk)
 		return;
-	pcpu_mem_free(chunk->map);
+	pcpu_mem_free(chunk->md_blocks);
+	pcpu_mem_free(chunk->bound_map);
+	pcpu_mem_free(chunk->alloc_map);
 	pcpu_mem_free(chunk);
 }
 
@@ -787,6 +1179,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
 
 	bitmap_set(chunk->populated, page_start, nr);
 	chunk->nr_populated += nr;
+	chunk->nr_empty_pop_pages += nr;
 	pcpu_nr_empty_pop_pages += nr;
 }
 
@@ -809,6 +1202,7 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
 
 	bitmap_clear(chunk->populated, page_start, nr);
 	chunk->nr_populated -= nr;
+	chunk->nr_empty_pop_pages -= nr;
 	pcpu_nr_empty_pop_pages -= nr;
 }
 
@@ -890,19 +1284,23 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	struct pcpu_chunk *chunk;
 	const char *err;
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
-	int occ_pages = 0;
-	int slot, off, new_alloc, cpu, ret;
+	int slot, off, cpu, ret;
 	unsigned long flags;
 	void __percpu *ptr;
+	size_t bit_size, bit_align;
 
 	/*
-	 * We want the lowest bit of offset available for in-use/free
-	 * indicator, so force >= 16bit alignment and make size even.
+	 * There is now a minimum allocation size of PCPU_MIN_ALLOC_SIZE.
+	 * Therefore alignment must be a minimum of that many bytes as well
+	 * as the allocation will have internal fragmentation from
+	 * rounding up by up to PCPU_MIN_ALLOC_SIZE - 1 bytes.
 	 */
-	if (unlikely(align < 2))
-		align = 2;
+	if (unlikely(align < PCPU_MIN_ALLOC_SIZE))
+		align = PCPU_MIN_ALLOC_SIZE;
 
-	size = ALIGN(size, 2);
+	size = ALIGN(size, PCPU_MIN_ALLOC_SIZE);
+	bit_size = size >> PCPU_MIN_ALLOC_SHIFT;
+	bit_align = align >> PCPU_MIN_ALLOC_SHIFT;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
 		     !is_power_of_2(align))) {
@@ -920,23 +1318,14 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	if (reserved && pcpu_reserved_chunk) {
 		chunk = pcpu_reserved_chunk;
 
-		if (size > chunk->contig_hint) {
+		off = pcpu_find_block_fit(chunk, bit_size, bit_align,
+					  is_atomic);
+		if (off < 0) {
 			err = "alloc from reserved chunk failed";
 			goto fail_unlock;
 		}
 
-		while ((new_alloc = pcpu_need_to_extend(chunk, is_atomic))) {
-			spin_unlock_irqrestore(&pcpu_lock, flags);
-			if (is_atomic ||
-			    pcpu_extend_area_map(chunk, new_alloc) < 0) {
-				err = "failed to extend area map of reserved chunk";
-				goto fail;
-			}
-			spin_lock_irqsave(&pcpu_lock, flags);
-		}
-
-		off = pcpu_alloc_area(chunk, size, align, is_atomic,
-				      &occ_pages);
+		off = pcpu_alloc_area(chunk, bit_size, bit_align, off);
 		if (off >= 0)
 			goto area_found;
 
@@ -946,31 +1335,17 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 restart:
 	/* search through normal chunks */
-	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
+	for (slot = pcpu_size_to_slot(bit_size); slot < pcpu_nr_slots; slot++) {
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
-			if (size > chunk->contig_hint)
+			if (bit_size > chunk->contig_hint)
 				continue;
 
-			new_alloc = pcpu_need_to_extend(chunk, is_atomic);
-			if (new_alloc) {
-				if (is_atomic)
-					continue;
-				spin_unlock_irqrestore(&pcpu_lock, flags);
-				if (pcpu_extend_area_map(chunk,
-							 new_alloc) < 0) {
-					err = "failed to extend area map";
-					goto fail;
-				}
-				spin_lock_irqsave(&pcpu_lock, flags);
-				/*
-				 * pcpu_lock has been dropped, need to
-				 * restart cpu_slot list walking.
-				 */
-				goto restart;
-			}
+			off = pcpu_find_block_fit(chunk, bit_size, bit_align,
+						  is_atomic);
+			if (off < 0)
+				continue;
 
-			off = pcpu_alloc_area(chunk, size, align, is_atomic,
-					      &occ_pages);
+			off = pcpu_alloc_area(chunk, bit_size, bit_align, off);
 			if (off >= 0)
 				goto area_found;
 		}
@@ -1021,7 +1396,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
-				pcpu_free_area(chunk, off, &occ_pages);
+				pcpu_free_area(chunk, off);
 				err = "failed to populate";
 				goto fail_unlock;
 			}
@@ -1032,12 +1407,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		mutex_unlock(&pcpu_alloc_mutex);
 	}
 
-	if (chunk != pcpu_reserved_chunk) {
-		spin_lock_irqsave(&pcpu_lock, flags);
-		pcpu_nr_empty_pop_pages -= occ_pages;
-		spin_unlock_irqrestore(&pcpu_lock, flags);
-	}
-
 	if (pcpu_nr_empty_pop_pages < PCPU_EMPTY_POP_PAGES_LOW)
 		pcpu_schedule_balance_work();
 
@@ -1155,7 +1524,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
 		if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
 			continue;
 
-		list_del_init(&chunk->map_extend_list);
 		list_move(&chunk->list, &to_free);
 	}
 
@@ -1173,25 +1541,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
 		pcpu_destroy_chunk(chunk);
 	}
 
-	/* service chunks which requested async area map extension */
-	do {
-		int new_alloc = 0;
-
-		spin_lock_irq(&pcpu_lock);
-
-		chunk = list_first_entry_or_null(&pcpu_map_extend_chunks,
-					struct pcpu_chunk, map_extend_list);
-		if (chunk) {
-			list_del_init(&chunk->map_extend_list);
-			new_alloc = pcpu_need_to_extend(chunk, false);
-		}
-
-		spin_unlock_irq(&pcpu_lock);
-
-		if (new_alloc)
-			pcpu_extend_area_map(chunk, new_alloc);
-	} while (chunk);
-
 	/*
 	 * Ensure there are certain number of free populated pages for
 	 * atomic allocs.  Fill up from the most packed so that atomic
@@ -1213,7 +1562,8 @@ static void pcpu_balance_workfn(struct work_struct *work)
 				  0, PCPU_EMPTY_POP_PAGES_HIGH);
 	}
 
-	for (slot = pcpu_size_to_slot(PAGE_SIZE); slot < pcpu_nr_slots; slot++) {
+	for (slot = pcpu_size_to_slot(PAGE_SIZE / PCPU_MIN_ALLOC_SIZE);
+	     slot < pcpu_nr_slots; slot++) {
 		int nr_unpop = 0, rs, re;
 
 		if (!nr_to_pop)
@@ -1277,7 +1627,7 @@ void free_percpu(void __percpu *ptr)
 	void *addr;
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
-	int off, occ_pages;
+	int off;
 
 	if (!ptr)
 		return;
@@ -1291,13 +1641,10 @@ void free_percpu(void __percpu *ptr)
 	chunk = pcpu_chunk_addr_search(addr);
 	off = addr - chunk->base_addr;
 
-	pcpu_free_area(chunk, off, &occ_pages);
-
-	if (chunk != pcpu_reserved_chunk)
-		pcpu_nr_empty_pop_pages += occ_pages;
+	pcpu_free_area(chunk, off);
 
 	/* if there are more than one fully free chunks, wake up grim reaper */
-	if (chunk->free_size == pcpu_unit_size) {
+	if (chunk->free_bits == pcpu_pages_to_bits(pcpu_unit_pages)) {
 		struct pcpu_chunk *pos;
 
 		list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
@@ -1363,15 +1710,15 @@ bool is_kernel_percpu_address(unsigned long addr)
  * address.  The caller is responsible for ensuring @addr stays valid
  * until this function finishes.
  *
- * percpu allocator has special setup for the first chunk, which currently
+ * Percpu allocator has special setup for the first chunk, which currently
  * supports either embedding in linear address space or vmalloc mapping,
  * and, from the second one, the backing allocator (currently either vm or
  * km) provides translation.
  *
  * The addr can be translated simply without checking if it falls into the
- * first chunk. But the current code reflects better how percpu allocator
+ * first chunk.  But the current code reflects better how percpu allocator
  * actually works, and the verification can discover both bugs in percpu
- * allocator itself and per_cpu_ptr_to_phys() callers. So we keep current
+ * allocator itself and per_cpu_ptr_to_phys() callers.  So we keep current
  * code.
  *
  * RETURNS:
@@ -1417,9 +1764,10 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 		else
 			return page_to_phys(vmalloc_to_page(addr)) +
 			       offset_in_page(addr);
-	} else
+	} else {
 		return page_to_phys(pcpu_addr_to_page(addr)) +
 		       offset_in_page(addr);
+	}
 }
 
 /**
@@ -1555,10 +1903,12 @@ static void pcpu_dump_alloc_info(const char *lvl,
  * static areas on architectures where the addressing model has
  * limited offset range for symbol relocations to guarantee module
  * percpu symbols fall inside the relocatable range.
+ * @ai->static_size + @ai->reserved_size is expected to be page aligned.
  *
  * @ai->dyn_size determines the number of bytes available for dynamic
- * allocation in the first chunk.  The area between @ai->static_size +
- * @ai->reserved_size + @ai->dyn_size and @ai->unit_size is unused.
+ * allocation in the first chunk. Both the start and the end are expected
+ * to be page aligned. The area between @ai->static_size + @ai->reserved_size
+ * + @ai->dyn_size and @ai->unit_size is unused.
  *
  * @ai->unit_size specifies unit size and must be aligned to PAGE_SIZE
  * and equal to or larger than @ai->static_size + @ai->reserved_size +
@@ -1581,11 +1931,11 @@ static void pcpu_dump_alloc_info(const char *lvl,
  * copied static data to each unit.
  *
  * If the first chunk ends up with both reserved and dynamic areas, it
- * is served by two chunks - one to serve the core static and reserved
- * areas and the other for the dynamic area.  They share the same vm
- * and page map but uses different area allocation map to stay away
- * from each other.  The latter chunk is circulated in the chunk slots
- * and available for dynamic allocation like any other chunks.
+ * is served by two chunks - one to serve the reserved area and the other
+ * for the dynamic area.  They share the same vm and page map but use
+ * different area allocation map to stay away from each other.  The latter
+ * chunk is circulated in the chunk slots and available for dynamic allocation
+ * like any other chunks.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
@@ -1593,8 +1943,6 @@ static void pcpu_dump_alloc_info(const char *lvl,
 int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 				  void *base_addr)
 {
-	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
-	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t dyn_size = ai->dyn_size;
 	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
 	struct pcpu_chunk *chunk;
@@ -1606,7 +1954,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	int group, unit, i;
 	int chunk_pages;
 	unsigned long tmp_addr, aligned_addr;
-	unsigned long map_size_bytes;
+	unsigned long map_size_bytes, begin_fill_bits;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -1703,7 +2051,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * Allocate chunk slots.  The additional last slot is for
 	 * empty chunks.
 	 */
-	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
+	pcpu_nr_slots = __pcpu_size_to_slot(
+				pcpu_pages_to_bits(pcpu_unit_pages)) + 2;
 	pcpu_slot = memblock_virt_alloc(
 			pcpu_nr_slots * sizeof(pcpu_slot[0]), 0);
 	for (i = 0; i < pcpu_nr_slots; i++)
@@ -1727,69 +2076,50 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	tmp_addr = (unsigned long)base_addr + ai->static_size;
 	aligned_addr = tmp_addr & PAGE_MASK;
 	pcpu_reserved_offset = tmp_addr - aligned_addr;
+	begin_fill_bits = pcpu_reserved_offset / PCPU_MIN_ALLOC_SIZE;
 
 	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
 			 pcpu_reserved_offset;
+
 	chunk_pages = map_size_bytes >> PAGE_SHIFT;
 
 	/* chunk adjacent to static region allocation */
-	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
-				     BITS_TO_LONGS(chunk_pages), 0);
-	INIT_LIST_HEAD(&chunk->list);
-	INIT_LIST_HEAD(&chunk->map_extend_list);
+	chunk = pcpu_alloc_first_chunk(chunk_pages);
 	chunk->base_addr = (void *)aligned_addr;
-	chunk->map = smap;
-	chunk->map_alloc = ARRAY_SIZE(smap);
 	chunk->immutable = true;
-	bitmap_fill(chunk->populated, chunk_pages);
-	chunk->nr_populated = chunk->nr_empty_pop_pages = chunk_pages;
-
-	chunk->nr_pages = chunk_pages;
 
-	if (ai->reserved_size) {
-		chunk->free_size = ai->reserved_size;
-		pcpu_reserved_chunk = chunk;
-	} else {
-		chunk->free_size = dyn_size;
-		dyn_size = 0;			/* dynamic area covered */
-	}
-	chunk->contig_hint = chunk->free_size;
+	/* set metadata */
+	chunk->contig_hint = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
+	chunk->free_bits = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
 
-	if (pcpu_reserved_offset) {
+	/*
+	 * If the beginning of the reserved region overlaps the end of the
+	 * static region, hide that portion in the metadata.
+	 */
+	if (begin_fill_bits) {
 		chunk->has_reserved = true;
-		chunk->nr_empty_pop_pages--;
-		chunk->map[0] = 1;
-		chunk->map[1] = pcpu_reserved_offset;
-		chunk->map_used = 1;
+		bitmap_fill(chunk->alloc_map, begin_fill_bits);
+		set_bit(0, chunk->bound_map);
+		set_bit(begin_fill_bits, chunk->bound_map);
+
+		if (pcpu_block_update_hint_alloc(chunk, 0, begin_fill_bits))
+			pcpu_chunk_update_hint(chunk);
 	}
-	if (chunk->free_size)
-		chunk->map[++chunk->map_used] = map_size_bytes;
-	chunk->map[chunk->map_used] |= 1;
 
-	/* init dynamic region of first chunk if necessary */
-	if (dyn_size) {
+	/* init dynamic chunk if necessary */
+	if (ai->reserved_size) {
+		pcpu_reserved_chunk = chunk;
+
 		chunk_pages = dyn_size >> PAGE_SHIFT;
 
 		/* chunk allocation */
-		chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
-					     BITS_TO_LONGS(chunk_pages), 0);
-		INIT_LIST_HEAD(&chunk->list);
-		INIT_LIST_HEAD(&chunk->map_extend_list);
+		chunk = pcpu_alloc_first_chunk(chunk_pages);
 		chunk->base_addr = base_addr + ai->static_size +
 				    ai->reserved_size;
-		chunk->map = dmap;
-		chunk->map_alloc = ARRAY_SIZE(dmap);
-		chunk->immutable = true;
-		bitmap_fill(chunk->populated, chunk_pages);
-		chunk->nr_populated = chunk_pages;
-		chunk->nr_empty_pop_pages = chunk_pages;
-
-		chunk->contig_hint = chunk->free_size = dyn_size;
-		chunk->map[0] = 0;
-		chunk->map[1] = chunk->free_size | 1;
-		chunk->map_used = 1;
-
-		chunk->nr_pages = chunk_pages;
+
+		/* set metadata */
+		chunk->contig_hint = pcpu_nr_pages_to_bits(chunk);
+		chunk->free_bits = pcpu_nr_pages_to_bits(chunk);
 	}
 
 	/* link the first chunk in */
@@ -2370,36 +2700,6 @@ void __init setup_per_cpu_areas(void)
 #endif	/* CONFIG_SMP */
 
 /*
- * First and reserved chunks are initialized with temporary allocation
- * map in initdata so that they can be used before slab is online.
- * This function is called after slab is brought up and replaces those
- * with properly allocated maps.
- */
-void __init percpu_init_late(void)
-{
-	struct pcpu_chunk *target_chunks[] =
-		{ pcpu_first_chunk, pcpu_reserved_chunk, NULL };
-	struct pcpu_chunk *chunk;
-	unsigned long flags;
-	int i;
-
-	for (i = 0; (chunk = target_chunks[i]); i++) {
-		int *map;
-		const size_t size = PERCPU_DYNAMIC_EARLY_SLOTS * sizeof(map[0]);
-
-		BUILD_BUG_ON(size > PAGE_SIZE);
-
-		map = pcpu_mem_zalloc(size);
-		BUG_ON(!map);
-
-		spin_lock_irqsave(&pcpu_lock, flags);
-		memcpy(map, chunk->map, size);
-		chunk->map = map;
-		spin_unlock_irqrestore(&pcpu_lock, flags);
-	}
-}
-
-/*
  * Percpu allocator is initialized early during boot when neither slab or
  * workqueue is available.  Plug async management until everything is up
  * and running.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
