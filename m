Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5826F6B03AB
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 1so141564333pfi.14
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v186si1816774pgv.634.2017.07.24.16.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:51 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 14/23] percpu: replace area map allocator with bitmap allocator
Date: Mon, 24 Jul 2017 19:02:11 -0400
Message-ID: <20170724230220.21774-15-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The percpu memory allocator is experiencing scalability issues when
allocating and freeing large numbers of counters as in BPF.
Additionally, there is a corner case where iteration is triggered over
all chunks if the contig_hint is the right size, but wrong alignment.

This patch replaces the area map allocator with a basic bitmap allocator
implementation. Each subsequent patch will introduce new features and
replace full scanning functions with faster non-scanning options when
possible.

Implementation:
This patchset removes the area map allocator in favor of a bitmap
allocator backed by metadata blocks. The primary goal is to provide
consistency in performance and memory footprint with a focus on small
allocations (< 64 bytes). The bitmap removes the heavy memmove from the
freeing critical path and provides a consistent memory footprint. The
metadata blocks provide a bound on the amount of scanning required by
maintaining a set of hints.

In an effort to make freeing fast, the metadata is updated on the free
path if the new free area makes a page free, a block free, or spans
across blocks. This causes the chunk's contig hint to potentially be
smaller than what it could allocate by up to the smaller of a page or a
block. If the chunk's contig hint is contained within a block, a check
occurs and the hint is kept accurate. Metadata is always kept accurate
on allocation, so there will not be a situation where a chunk has a
later contig hint than available.

Evaluation:
I have primarily done testing against a simple workload of allocation of
1 million objects (2^20) of varying size. Deallocation was done by in
order, alternating, and in reverse. These numbers were collected after
rebasing ontop of a80099a152. I present the worst-case numbers here:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        310      |     4770
             16B    |        557      |     1325
             64B    |        436      |      273
            256B    |        776      |      131
           1024B    |       3280      |      122

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        490      |       70
             16B    |        515      |       75
             64B    |        610      |       80
            256B    |        950      |      100
           1024B    |       3520      |      200

This data demonstrates the inability for the area map allocator to
handle less than ideal situations. In the best case of reverse
deallocation, the area map allocator was able to perform within range
of the bitmap allocator. In the worst case situation, freeing took
nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
dramatically improves the consistency of the free path. The small
allocations performed nearly identical regardless of the freeing
pattern.

While it does add to the allocation latency, the allocation scenario
here is optimal for the area map allocator. The area map allocator runs
into trouble when it is allocating in chunks where the latter half is
full. It is difficult to replicate this, so I present a variant where
the pages are second half filled. Freeing was done sequentially. Below
are the numbers for this scenario:

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |       4118      |     4892
             16B    |       1651      |     1163
             64B    |        598      |      285
            256B    |        771      |      158
           1024B    |       3034      |      160

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        481      |       67
             16B    |        506      |       69
             64B    |        636      |       75
            256B    |        892      |       90
           1024B    |       3262      |      147

The data shows a parabolic curve of performance for the area map
allocator. This is due to the memmove operation being the dominant cost
with the lower object sizes as more objects are packed in a chunk and at
higher object sizes, the traversal of the chunk slots is the dominating
cost. The bitmap allocator suffers this problem as well. The above data
shows the inability to scale for the allocation path with the area map
allocator and that the bitmap allocator demonstrates consistent
performance in general.

The second problem of additional scanning can result in the area map
allocator completing in 52 minutes when trying to allocate 1 million
4-byte objects with 8-byte alignment. The same workload takes
approximately 16 seconds to complete for the bitmap allocator.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |   1 -
 init/main.c            |   1 -
 mm/percpu-internal.h   |  34 ++-
 mm/percpu-km.c         |   2 +-
 mm/percpu-stats.c      |  99 ++++---
 mm/percpu.c            | 721 ++++++++++++++++++-------------------------------
 6 files changed, 354 insertions(+), 504 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 90e0cb0..b7e6c98 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -120,7 +120,6 @@ extern bool is_kernel_percpu_address(unsigned long addr);
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
index c4c8fc4..2e9d9bc 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -11,14 +11,12 @@ struct pcpu_chunk {
 #endif
 
 	struct list_head	list;		/* linked to pcpu_slot lists */
-	int			free_size;	/* free bytes in the chunk */
-	int			contig_hint;	/* max contiguous size hint */
+	int			free_bytes;	/* free bytes in the chunk */
+	int			contig_bits;	/* max contiguous size hint */
 	void			*base_addr;	/* base address of this chunk */
 
-	int			map_used;	/* # of map entries used before the sentry */
-	int			map_alloc;	/* # of map entries allocated */
-	int			*map;		/* allocation map */
-	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
+	unsigned long		*alloc_map;	/* allocation map */
+	unsigned long		*bound_map;	/* boundary map */
 
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
@@ -45,6 +43,30 @@ extern int pcpu_nr_empty_pop_pages;
 extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
 
+/**
+ * pcpu_nr_pages_to_map_bits - converts the pages to size of bitmap
+ * @pages: number of physical pages
+ *
+ * This conversion is from physical pages to the number of bits
+ * required in the bitmap.
+ */
+static inline int pcpu_nr_pages_to_map_bits(int pages)
+{
+	return pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE;
+}
+
+/**
+ * pcpu_chunk_map_bits - helper to convert nr_pages to size of bitmap
+ * @chunk: chunk of interest
+ *
+ * This conversion is from the number of physical pages that the chunk
+ * serves to the number of bits in the bitmap.
+ */
+static inline int pcpu_chunk_map_bits(struct pcpu_chunk *chunk)
+{
+	return pcpu_nr_pages_to_map_bits(chunk->nr_pages);
+}
+
 #ifdef CONFIG_PERCPU_STATS
 
 #include <linux/spinlock.h>
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index eb58aa4..d2a7664 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -69,7 +69,7 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
 
 	spin_lock_irq(&pcpu_lock);
-	pcpu_chunk_populated(chunk, 0, nr_pages);
+	pcpu_chunk_populated(chunk, 0, nr_pages, false);
 	spin_unlock_irq(&pcpu_lock);
 
 	pcpu_stats_chunk_alloc();
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index e146b58..ad03d73 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -29,65 +29,85 @@ static int cmpint(const void *a, const void *b)
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
-	int i, s_index, e_index, last_alloc, alloc_sign, as_len;
+	int i, last_alloc, as_len, start, end;
 	int *alloc_sizes, *p;
 	/* statistics */
 	int sum_frag = 0, max_frag = 0;
 	int cur_min_alloc = 0, cur_med_alloc = 0, cur_max_alloc = 0;
 
 	alloc_sizes = buffer;
-	s_index = (chunk->start_offset) ? 1 : 0;
-	e_index = chunk->map_used - ((chunk->end_offset) ? 1 : 0);
-
-	/* find last allocation */
-	last_alloc = -1;
-	for (i = e_index - 1; i >= s_index; i--) {
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
+				   pcpu_chunk_map_bits(chunk) -
+				   chunk->end_offset / PCPU_MIN_ALLOC_SIZE - 1);
+	last_alloc = test_bit(last_alloc, chunk->alloc_map) ?
+		     last_alloc + 1 : 0;
+
+	as_len = 0;
+	start = chunk->start_offset;
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
@@ -101,8 +121,8 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
 	P("empty_pop_pages", chunk->nr_empty_pop_pages);
-	P("free_size", chunk->free_size);
-	P("contig_hint", chunk->contig_hint);
+	P("free_bytes", chunk->free_bytes);
+	P("contig_bytes", chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
 	P("sum_frag", sum_frag);
 	P("max_frag", max_frag);
 	P("cur_min_alloc", cur_min_alloc);
@@ -114,22 +134,23 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
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
index 84cc255..c31b0c8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -86,10 +86,9 @@
 
 #include "percpu-internal.h"
 
-#define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
-#define PCPU_DFL_MAP_ALLOC		16	/* start a map with 16 ents */
-#define PCPU_ATOMIC_MAP_MARGIN_LOW	32
-#define PCPU_ATOMIC_MAP_MARGIN_HIGH	64
+/* the slots are sorted by free bytes left, 1-31 bytes share the same slot */
+#define PCPU_SLOT_BASE_SHIFT		5
+
 #define PCPU_EMPTY_POP_PAGES_LOW	2
 #define PCPU_EMPTY_POP_PAGES_HIGH	4
 
@@ -218,10 +217,10 @@ static int pcpu_size_to_slot(int size)
 
 static int pcpu_chunk_slot(const struct pcpu_chunk *chunk)
 {
-	if (chunk->free_size < sizeof(int) || chunk->contig_hint < sizeof(int))
+	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE || chunk->contig_bits == 0)
 		return 0;
 
-	return pcpu_size_to_slot(chunk->free_size);
+	return pcpu_size_to_slot(chunk->free_bytes);
 }
 
 /* set the pointer to a chunk in a page struct */
@@ -317,38 +316,6 @@ static void pcpu_mem_free(void *ptr)
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
@@ -374,358 +341,263 @@ static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
 }
 
 /**
- * pcpu_need_to_extend - determine whether chunk area map needs to be extended
+ * pcpu_cnt_pop_pages- counts populated backing pages in range
  * @chunk: chunk of interest
- * @is_atomic: the allocation context
+ * @bit_off: start offset
+ * @bits: size of area to check
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
+ * Calculates the number of populated pages in the region
+ * [page_start, page_end).  This keeps track of how many empty populated
+ * pages are available and decide if async work should be scheduled.
  *
  * RETURNS:
- * New target map allocation length if extension is necessary, 0
- * otherwise.
+ * The nr of populated pages.
  */
-static int pcpu_need_to_extend(struct pcpu_chunk *chunk, bool is_atomic)
+static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk, int bit_off,
+				     int bits)
 {
-	int margin, new_alloc;
-
-	lockdep_assert_held(&pcpu_lock);
+	int page_start = PFN_UP(bit_off * PCPU_MIN_ALLOC_SIZE);
+	int page_end = PFN_DOWN((bit_off + bits) * PCPU_MIN_ALLOC_SIZE);
 
-	if (is_atomic) {
-		margin = 3;
-
-		if (chunk->map_alloc <
-		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
-			if (list_empty(&chunk->map_extend_list)) {
-				list_add_tail(&chunk->map_extend_list,
-					      &pcpu_map_extend_chunks);
-				pcpu_schedule_balance_work();
-			}
-		}
-	} else {
-		margin = PCPU_ATOMIC_MAP_MARGIN_HIGH;
-	}
-
-	if (chunk->map_alloc >= chunk->map_used + margin)
+	if (page_start >= page_end)
 		return 0;
 
-	new_alloc = PCPU_DFL_MAP_ALLOC;
-	while (new_alloc < chunk->map_used + margin)
-		new_alloc *= 2;
-
-	return new_alloc;
+	return bitmap_weight(chunk->populated, page_end) -
+	       bitmap_weight(chunk->populated, page_start);
 }
 
 /**
- * pcpu_extend_area_map - extend area map of a chunk
+ * pcpu_chunk_update - updates the chunk metadata given a free area
  * @chunk: chunk of interest
- * @new_alloc: new target allocation length of the area map
+ * @bit_off: chunk offset
+ * @bits: size of free area
  *
- * Extend area map of @chunk to have @new_alloc entries.
+ * This updates the chunk's contig hint given a free area.
+ */
+static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
+{
+	if (bits > chunk->contig_bits)
+		chunk->contig_bits = bits;
+}
+
+/**
+ * pcpu_chunk_refresh_hint - updates metadata about a chunk
+ * @chunk: chunk of interest
  *
- * CONTEXT:
- * Does GFP_KERNEL allocation.  Grabs and releases pcpu_lock.
+ * Iterates over the chunk to find the largest free area.
  *
- * RETURNS:
- * 0 on success, -errno on failure.
+ * Updates:
+ *      chunk->contig_bits
+ *      nr_empty_pop_pages
  */
-static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
+static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
 {
-	int *old = NULL, *new = NULL;
-	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
-	unsigned long flags;
+	int bits, nr_empty_pop_pages;
+	int rs, re; /* region start, region end */
 
-	lockdep_assert_held(&pcpu_alloc_mutex);
+	/* clear metadata */
+	chunk->contig_bits = 0;
 
-	new = pcpu_mem_zalloc(new_size);
-	if (!new)
-		return -ENOMEM;
+	bits = nr_empty_pop_pages = 0;
+	pcpu_for_each_unpop_region(chunk->alloc_map, rs, re, 0,
+				   pcpu_chunk_map_bits(chunk)) {
+		bits = re - rs;
 
-	/* acquire pcpu_lock and switch to new area map */
-	spin_lock_irqsave(&pcpu_lock, flags);
+		pcpu_chunk_update(chunk, rs, bits);
 
-	if (new_alloc <= chunk->map_alloc)
-		goto out_unlock;
+		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, rs, bits);
+	}
 
-	old_size = chunk->map_alloc * sizeof(chunk->map[0]);
-	old = chunk->map;
+	/*
+	 * Keep track of nr_empty_pop_pages.
+	 *
+	 * The chunk maintains the previous number of free pages it held,
+	 * so the delta is used to update the global counter.  The reserved
+	 * chunk is not part of the free page count as they are populated
+	 * at init and are special to serving reserved allocations.
+	 */
+	if (chunk != pcpu_reserved_chunk)
+		pcpu_nr_empty_pop_pages +=
+			(nr_empty_pop_pages - chunk->nr_empty_pop_pages);
 
-	memcpy(new, old, old_size);
+	chunk->nr_empty_pop_pages = nr_empty_pop_pages;
+}
 
-	chunk->map_alloc = new_alloc;
-	chunk->map = new;
-	new = NULL;
+/**
+ * pcpu_is_populated - determines if the region is populated
+ * @chunk: chunk of interest
+ * @bit_off: chunk offset
+ * @bits: size of area
+ * @next_off: return value for the next offset to start searching
+ *
+ * For atomic allocations, check if the backing pages are populated.
+ *
+ * RETURNS:
+ * Bool if the backing pages are populated.
+ * next_index is to skip over unpopulated blocks in pcpu_find_block_fit.
+ */
+static bool pcpu_is_populated(struct pcpu_chunk *chunk, int bit_off, int bits,
+			      int *next_off)
+{
+	int page_start, page_end, rs, re;
 
-out_unlock:
-	spin_unlock_irqrestore(&pcpu_lock, flags);
+	page_start = PFN_DOWN(bit_off * PCPU_MIN_ALLOC_SIZE);
+	page_end = PFN_UP((bit_off + bits) * PCPU_MIN_ALLOC_SIZE);
 
-	/*
-	 * pcpu_mem_free() might end up calling vfree() which uses
-	 * IRQ-unsafe lock and thus can't be called under pcpu_lock.
-	 */
-	pcpu_mem_free(old);
-	pcpu_mem_free(new);
+	rs = page_start;
+	pcpu_next_unpop(chunk->populated, &rs, &re, page_end);
+	if (rs >= page_end)
+		return true;
 
-	return 0;
+	*next_off = re * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE;
+	return false;
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
+ * pcpu_find_block_fit - finds the block index to start searching
+ * @chunk: chunk of interest
+ * @alloc_bits: size of request in allocation units
+ * @align: alignment of area (max PAGE_SIZE bytes)
+ * @pop_only: use populated regions only
+ *
+ * RETURNS:
+ * The offset in the bitmap to begin searching.
+ * -1 if no offset is found.
  */
-static int pcpu_fit_in_area(struct pcpu_chunk *chunk, int off, int this_size,
-			    int size, int align, bool pop_only)
+static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
+			       size_t align, bool pop_only)
 {
-	int cand_off = off;
+	int bit_off, bits;
+	int re; /* region end */
 
-	while (true) {
-		int head = ALIGN(cand_off, align) - off;
-		int page_start, page_end, rs, re;
+	pcpu_for_each_unpop_region(chunk->alloc_map, bit_off, re, 0,
+				   pcpu_chunk_map_bits(chunk)) {
+		bits = re - bit_off;
 
-		if (this_size < head + size)
-			return -1;
+		/* check alignment */
+		bits -= ALIGN(bit_off, align) - bit_off;
+		bit_off = ALIGN(bit_off, align);
+		if (bits < alloc_bits)
+			continue;
 
-		if (!pop_only)
-			return head;
+		bits = alloc_bits;
+		if (!pop_only || pcpu_is_populated(chunk, bit_off, bits,
+						   &bit_off))
+			break;
 
-		/*
-		 * If the first unpopulated page is beyond the end of the
-		 * allocation, the whole allocation is populated;
-		 * otherwise, retry from the end of the unpopulated area.
-		 */
-		page_start = PFN_DOWN(head + off);
-		page_end = PFN_UP(head + off + size);
-
-		rs = page_start;
-		pcpu_next_unpop(chunk->populated, &rs, &re,
-				PFN_UP(off + this_size));
-		if (rs >= page_end)
-			return head;
-		cand_off = re * PAGE_SIZE;
+		bits = 0;
 	}
+
+	if (bit_off == pcpu_chunk_map_bits(chunk))
+		return -1;
+
+	return bit_off;
 }
 
 /**
- * pcpu_alloc_area - allocate area from a pcpu_chunk
+ * pcpu_alloc_area - allocates an area from a pcpu_chunk
  * @chunk: chunk of interest
- * @size: wanted size in bytes
- * @align: wanted align
- * @pop_only: allocate only from the populated area
- * @occ_pages_p: out param for the number of pages the area occupies
- *
- * Try to allocate @size bytes area aligned at @align from @chunk.
- * Note that this function only allocates the offset.  It doesn't
- * populate or map the area.
+ * @alloc_bits: size of request in allocation units
+ * @align: alignment of area (max PAGE_SIZE)
+ * @start: bit_off to start searching
  *
- * @chunk->map must have at least two free slots.
- *
- * CONTEXT:
- * pcpu_lock.
+ * This function takes in a @start offset to begin searching to fit an
+ * allocation of @alloc_bits with alignment @align.  If it confirms a
+ * valid free area, it then updates the allocation and boundary maps
+ * accordingly.
  *
  * RETURNS:
- * Allocated offset in @chunk on success, -1 if no matching area is
- * found.
+ * Allocated addr offset in @chunk on success.
+ * -1 if no matching area is found.
  */
-static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align,
-			   bool pop_only, int *occ_pages_p)
+static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
+			   size_t align, int start)
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
+	size_t align_mask = (align) ? (align - 1) : 0;
+	int bit_off, end, oslot;
 
-		this_size = (p[1] & ~1) - off;
-
-		head = pcpu_fit_in_area(chunk, off, this_size, size, align,
-					pop_only);
-		if (head < 0) {
-			if (!seen_free) {
-				chunk->first_free = i;
-				seen_free = true;
-			}
-			max_contig = max(this_size, max_contig);
-			continue;
-		}
-
-		/*
-		 * If head is small or the previous block is free,
-		 * merge'em.  Note that 'small' is defined as smaller
-		 * than sizeof(int), which is very small but isn't too
-		 * uncommon for percpu allocations.
-		 */
-		if (head && (head < sizeof(int) || !(p[-1] & 1))) {
-			*p = off += head;
-			if (p[-1] & 1)
-				chunk->free_size -= head;
-			else
-				max_contig = max(*p - p[-1], max_contig);
-			this_size -= head;
-			head = 0;
-		}
+	lockdep_assert_held(&pcpu_lock);
 
-		/* if tail is small, just keep it around */
-		tail = this_size - head - size;
-		if (tail < sizeof(int)) {
-			tail = 0;
-			size = this_size - head;
-		}
+	oslot = pcpu_chunk_slot(chunk);
 
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
-		}
+	/*
+	 * Search to find a fit.
+	 */
+	end = start + alloc_bits;
+	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
+					     alloc_bits, align_mask);
+	if (bit_off >= end)
+		return -1;
 
-		if (!seen_free)
-			chunk->first_free = i + 1;
+	/* update alloc map */
+	bitmap_set(chunk->alloc_map, bit_off, alloc_bits);
 
-		/* update hint and mark allocated */
-		if (i + 1 == chunk->map_used)
-			chunk->contig_hint = max_contig; /* fully scanned */
-		else
-			chunk->contig_hint = max(chunk->contig_hint,
-						 max_contig);
+	/* update boundary map */
+	set_bit(bit_off, chunk->bound_map);
+	bitmap_clear(chunk->bound_map, bit_off + 1, alloc_bits - 1);
+	set_bit(bit_off + alloc_bits, chunk->bound_map);
 
-		chunk->free_size -= size;
-		*p |= 1;
+	chunk->free_bytes -= alloc_bits * PCPU_MIN_ALLOC_SIZE;
 
-		*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
-		pcpu_chunk_relocate(chunk, oslot);
-		return off;
-	}
+	pcpu_chunk_refresh_hint(chunk);
 
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
+ * the boundary bitmap and clears the allocation map.
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
+	int bit_off, bits, end, oslot;
 
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
+	end = find_next_bit(chunk->bound_map, pcpu_chunk_map_bits(chunk),
+			    bit_off + 1);
+	bits = end - bit_off;
+	bitmap_clear(chunk->alloc_map, bit_off, bits);
 
-	*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
+	/* update metadata */
+	chunk->free_bytes += bits * PCPU_MIN_ALLOC_SIZE;
 
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
+	pcpu_chunk_refresh_hint(chunk);
 
-	chunk->contig_hint = max(chunk->map[i + 1] - chunk->map[i] - 1, chunk->contig_hint);
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
+/**
+ * pcpu_alloc_first_chunk - creates chunks that serve the first chunk
+ * @tmp_addr: the start of the region served
+ * @map_size: size of the region served
+ *
+ * This is responsible for creating the chunks that serve the first chunk.  The
+ * base_addr is page aligned down of @tmp_addr while the region end is page
+ * aligned up.  Offsets are kept track of to determine the region served. All
+ * this is done to appease the bitmap allocator in avoiding partial blocks.
+ *
+ * RETURNS:
+ * Chunk serving the region at @tmp_addr of @map_size.
+ */
 static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
-							 int map_size,
-							 int *map,
-							 int init_map_size)
+							 int map_size)
 {
 	struct pcpu_chunk *chunk;
 	unsigned long aligned_addr;
-	int start_offset, region_size;
+	int start_offset, offset_bits, region_size, region_bits;
 
 	/* region calculations */
 	aligned_addr = tmp_addr & PAGE_MASK;
@@ -740,83 +612,98 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 				    0);
 
 	INIT_LIST_HEAD(&chunk->list);
-	INIT_LIST_HEAD(&chunk->map_extend_list);
 
 	chunk->base_addr = (void *)aligned_addr;
 	chunk->start_offset = start_offset;
 	chunk->end_offset = region_size - chunk->start_offset - map_size;
 
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
+	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->map = map;
-	chunk->map_alloc = init_map_size;
+	chunk->alloc_map = memblock_virt_alloc(
+				BITS_TO_LONGS(region_bits) *
+				sizeof(chunk->alloc_map[0]), 0);
+	chunk->bound_map = memblock_virt_alloc(
+				BITS_TO_LONGS(region_bits + 1) *
+				sizeof(chunk->bound_map[0]), 0);
 
 	/* manage populated page bitmap */
 	chunk->immutable = true;
 	bitmap_fill(chunk->populated, chunk->nr_pages);
 	chunk->nr_populated = chunk->nr_pages;
-	chunk->nr_empty_pop_pages = chunk->nr_pages;
+	chunk->nr_empty_pop_pages =
+		pcpu_cnt_pop_pages(chunk, start_offset / PCPU_MIN_ALLOC_SIZE,
+				   map_size / PCPU_MIN_ALLOC_SIZE);
 
-	chunk->contig_hint = chunk->free_size = map_size;
+	chunk->contig_bits = map_size / PCPU_MIN_ALLOC_SIZE;
+	chunk->free_bytes = map_size;
 
 	if (chunk->start_offset) {
 		/* hide the beginning of the bitmap */
-		chunk->nr_empty_pop_pages--;
-
-		chunk->map[0] = 1;
-		chunk->map[1] = chunk->start_offset;
-		chunk->map_used = 1;
+		offset_bits = chunk->start_offset / PCPU_MIN_ALLOC_SIZE;
+		bitmap_set(chunk->alloc_map, 0, offset_bits);
+		set_bit(0, chunk->bound_map);
+		set_bit(offset_bits, chunk->bound_map);
 	}
 
-	/* set chunk's free region */
-	chunk->map[++chunk->map_used] =
-		(chunk->start_offset + chunk->free_size) | 1;
-
 	if (chunk->end_offset) {
 		/* hide the end of the bitmap */
-		chunk->nr_empty_pop_pages--;
-
-		chunk->map[++chunk->map_used] = region_size | 1;
+		offset_bits = chunk->end_offset / PCPU_MIN_ALLOC_SIZE;
+		bitmap_set(chunk->alloc_map,
+			   pcpu_chunk_map_bits(chunk) - offset_bits,
+			   offset_bits);
+		set_bit(start_offset + map_size, chunk->bound_map);
+		set_bit(region_bits, chunk->bound_map);
 	}
 
+	pcpu_chunk_refresh_hint(chunk);
+
 	return chunk;
 }
 
 static struct pcpu_chunk *pcpu_alloc_chunk(void)
 {
 	struct pcpu_chunk *chunk;
+	int region_bits;
 
 	chunk = pcpu_mem_zalloc(pcpu_chunk_struct_size);
 	if (!chunk)
 		return NULL;
 
-	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
-						sizeof(chunk->map[0]));
-	if (!chunk->map) {
-		pcpu_mem_free(chunk);
-		return NULL;
-	}
+	INIT_LIST_HEAD(&chunk->list);
+	chunk->nr_pages = pcpu_unit_pages;
+	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->map_alloc = PCPU_DFL_MAP_ALLOC;
-	chunk->map[0] = 0;
-	chunk->map[1] = pcpu_unit_size | 1;
-	chunk->map_used = 1;
+	chunk->alloc_map = pcpu_mem_zalloc(BITS_TO_LONGS(region_bits) *
+					   sizeof(chunk->alloc_map[0]));
+	if (!chunk->alloc_map)
+		goto alloc_map_fail;
 
-	INIT_LIST_HEAD(&chunk->list);
-	INIT_LIST_HEAD(&chunk->map_extend_list);
-	chunk->free_size = pcpu_unit_size;
-	chunk->contig_hint = pcpu_unit_size;
+	chunk->bound_map = pcpu_mem_zalloc(BITS_TO_LONGS(region_bits + 1) *
+					   sizeof(chunk->bound_map[0]));
+	if (!chunk->bound_map)
+		goto bound_map_fail;
 
-	chunk->nr_pages = pcpu_unit_pages;
+	/* init metadata */
+	chunk->contig_bits = region_bits;
+	chunk->free_bytes = chunk->nr_pages * PAGE_SIZE;
 
 	return chunk;
+
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
+	pcpu_mem_free(chunk->bound_map);
+	pcpu_mem_free(chunk->alloc_map);
 	pcpu_mem_free(chunk);
 }
 
@@ -825,13 +712,17 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
  * @chunk: pcpu_chunk which got populated
  * @page_start: the start page
  * @page_end: the end page
+ * @for_alloc: if this is to populate for allocation
  *
  * Pages in [@page_start,@page_end) have been populated to @chunk.  Update
  * the bookkeeping information accordingly.  Must be called after each
  * successful population.
+ *
+ * If this is @for_alloc, do not increment pcpu_nr_empty_pop_pages because it
+ * is to serve an allocation in that area.
  */
-static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
-				 int page_start, int page_end)
+static void pcpu_chunk_populated(struct pcpu_chunk *chunk, int page_start,
+				 int page_end, bool for_alloc)
 {
 	int nr = page_end - page_start;
 
@@ -839,8 +730,11 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
 
 	bitmap_set(chunk->populated, page_start, nr);
 	chunk->nr_populated += nr;
-	chunk->nr_empty_pop_pages += nr;
-	pcpu_nr_empty_pop_pages += nr;
+
+	if (!for_alloc) {
+		chunk->nr_empty_pop_pages += nr;
+		pcpu_nr_empty_pop_pages += nr;
+	}
 }
 
 /**
@@ -945,19 +839,23 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	struct pcpu_chunk *chunk;
 	const char *err;
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
-	int occ_pages = 0;
-	int slot, off, new_alloc, cpu, ret;
+	int slot, off, cpu, ret;
 	unsigned long flags;
 	void __percpu *ptr;
+	size_t bits, bit_align;
 
 	/*
-	 * We want the lowest bit of offset available for in-use/free
-	 * indicator, so force >= 16bit alignment and make size even.
+	 * There is now a minimum allocation size of PCPU_MIN_ALLOC_SIZE,
+	 * therefore alignment must be a minimum of that many bytes.
+	 * An allocation may have internal fragmentation from rounding up
+	 * of up to PCPU_MIN_ALLOC_SIZE - 1 bytes.
 	 */
 	if (unlikely(align < PCPU_MIN_ALLOC_SIZE))
 		align = PCPU_MIN_ALLOC_SIZE;
 
 	size = ALIGN(size, PCPU_MIN_ALLOC_SIZE);
+	bits = size >> PCPU_MIN_ALLOC_SHIFT;
+	bit_align = align >> PCPU_MIN_ALLOC_SHIFT;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
 		     !is_power_of_2(align))) {
@@ -975,23 +873,13 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	if (reserved && pcpu_reserved_chunk) {
 		chunk = pcpu_reserved_chunk;
 
-		if (size > chunk->contig_hint) {
+		off = pcpu_find_block_fit(chunk, bits, bit_align, is_atomic);
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
+		off = pcpu_alloc_area(chunk, bits, bit_align, off);
 		if (off >= 0)
 			goto area_found;
 
@@ -1003,31 +891,15 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	/* search through normal chunks */
 	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
-			if (size > chunk->contig_hint)
+			off = pcpu_find_block_fit(chunk, bits, bit_align,
+						  is_atomic);
+			if (off < 0)
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
-
-			off = pcpu_alloc_area(chunk, size, align, is_atomic,
-					      &occ_pages);
+			off = pcpu_alloc_area(chunk, bits, bit_align, off);
 			if (off >= 0)
 				goto area_found;
+
 		}
 	}
 
@@ -1077,23 +949,17 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
-				pcpu_free_area(chunk, off, &occ_pages);
+				pcpu_free_area(chunk, off);
 				err = "failed to populate";
 				goto fail_unlock;
 			}
-			pcpu_chunk_populated(chunk, rs, re);
+			pcpu_chunk_populated(chunk, rs, re, true);
 			spin_unlock_irqrestore(&pcpu_lock, flags);
 		}
 
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
 
@@ -1211,7 +1077,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
 		if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
 			continue;
 
-		list_del_init(&chunk->map_extend_list);
 		list_move(&chunk->list, &to_free);
 	}
 
@@ -1230,25 +1095,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
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
@@ -1296,7 +1142,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			if (!ret) {
 				nr_to_pop -= nr;
 				spin_lock_irq(&pcpu_lock);
-				pcpu_chunk_populated(chunk, rs, rs + nr);
+				pcpu_chunk_populated(chunk, rs, rs + nr, false);
 				spin_unlock_irq(&pcpu_lock);
 			} else {
 				nr_to_pop = 0;
@@ -1335,7 +1181,7 @@ void free_percpu(void __percpu *ptr)
 	void *addr;
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
-	int off, occ_pages;
+	int off;
 
 	if (!ptr)
 		return;
@@ -1349,13 +1195,10 @@ void free_percpu(void __percpu *ptr)
 	chunk = pcpu_chunk_addr_search(addr);
 	off = addr - chunk->base_addr;
 
-	pcpu_free_area(chunk, off, &occ_pages);
-
-	if (chunk != pcpu_reserved_chunk)
-		pcpu_nr_empty_pop_pages += occ_pages;
+	pcpu_free_area(chunk, off);
 
 	/* if there are more than one fully free chunks, wake up grim reaper */
-	if (chunk->free_size == pcpu_unit_size) {
+	if (chunk->free_bytes == pcpu_unit_size) {
 		struct pcpu_chunk *pos;
 
 		list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
@@ -1651,8 +1494,6 @@ static void pcpu_dump_alloc_info(const char *lvl,
 int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 				  void *base_addr)
 {
-	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
-	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	size_t static_size, dyn_size;
 	struct pcpu_chunk *chunk;
@@ -1787,8 +1628,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 */
 	tmp_addr = (unsigned long)base_addr + static_size;
 	map_size = ai->reserved_size ?: dyn_size;
-	chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, smap,
-				       ARRAY_SIZE(smap));
+	chunk = pcpu_alloc_first_chunk(tmp_addr, map_size);
 
 	/* init dynamic chunk if necessary */
 	if (ai->reserved_size) {
@@ -1797,8 +1637,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		tmp_addr = (unsigned long)base_addr + static_size +
 			   ai->reserved_size;
 		map_size = dyn_size;
-		chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, dmap,
-					       ARRAY_SIZE(dmap));
+		chunk = pcpu_alloc_first_chunk(tmp_addr, map_size);
 	}
 
 	/* link the first chunk in */
@@ -2375,36 +2214,6 @@ void __init setup_per_cpu_areas(void)
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
