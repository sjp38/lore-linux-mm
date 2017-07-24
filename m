Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20CCA6B03C1
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so24992991wrz.10
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:57 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i8si12662888wrb.191.2017.07.24.16.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:55 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 15/23] percpu: introduce bitmap metadata blocks
Date: Mon, 24 Jul 2017 19:02:12 -0400
Message-ID: <20170724230220.21774-16-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch introduces the bitmap metadata blocks and adds the skeleton
of the code that will be used to maintain these blocks.  Each chunk's
bitmap is made up of full metadata blocks. These blocks maintain basic
metadata to help prevent scanning unnecssarily to update hints. Full
scanning methods are used for the skeleton and will be replaced in the
coming patches. A number of helper functions are added as well to do
conversion of pages to blocks and manage offsets. Comments will be
updated as the final version of each function is added.

There exists a relationship between PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE,
the region size, and unit_size. Every chunk's region (including offsets)
is page aligned at the beginning to preserve alignment. The end is
aligned to LCM(PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE) to ensure that the end
can fit with the populated page map which is by page and every metadata
block is fully accounted for. The unit_size is already page aligned, but
must also be aligned with PCPU_BITMAP_BLOCK_SIZE to ensure full metadata
blocks.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |  12 +++
 mm/percpu-internal.h   |  29 +++++++
 mm/percpu.c            | 228 ++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 257 insertions(+), 12 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index b7e6c98..31795e6 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -26,6 +26,18 @@
 #define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
 
 /*
+ * This determines the size of each metadata block.  There are several subtle
+ * constraints around this constant.  The reserved region must be a multiple of
+ * PCPU_BITMAP_BLOCK_SIZE.  Additionally, PCPU_BITMAP_BLOCK_SIZE must be a
+ * multiple of PAGE_SIZE or PAGE_SIZE must be a multiple of
+ * PCPU_BITMAP_BLOCK_SIZE to align with the populated page map. The unit_size
+ * also has to be a multiple of PCPU_BITMAP_BLOCK_SIZE to ensure full blocks.
+ */
+#define PCPU_BITMAP_BLOCK_SIZE		PAGE_SIZE
+#define PCPU_BITMAP_BLOCK_BITS		(PCPU_BITMAP_BLOCK_SIZE >>	\
+					 PCPU_MIN_ALLOC_SHIFT)
+
+/*
  * Percpu allocator can serve percpu allocations before slab is
  * initialized which allows slab to depend on the percpu allocator.
  * The following two parameters decide how much resource to
diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 2e9d9bc..252ae9e 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -4,6 +4,22 @@
 #include <linux/types.h>
 #include <linux/percpu.h>
 
+/*
+ * pcpu_block_md is the metadata block struct.
+ * Each chunk's bitmap is split into a number of full blocks.
+ * All units are in terms of bits.
+ */
+struct pcpu_block_md {
+	int                     contig_hint;    /* contig hint for block */
+	int                     contig_hint_start; /* block relative starting
+						      position of the contig hint */
+	int                     left_free;      /* size of free space along
+						   the left side of the block */
+	int                     right_free;     /* size of free space along
+						   the right side of the block */
+	int                     first_free;     /* block position of first free */
+};
+
 struct pcpu_chunk {
 #ifdef CONFIG_PERCPU_STATS
 	int			nr_alloc;	/* # of allocations */
@@ -17,6 +33,7 @@ struct pcpu_chunk {
 
 	unsigned long		*alloc_map;	/* allocation map */
 	unsigned long		*bound_map;	/* boundary map */
+	struct pcpu_block_md	*md_blocks;	/* metadata blocks */
 
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
@@ -44,6 +61,18 @@ extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
 
 /**
+ * pcpu_chunk_nr_blocks - converts nr_pages to # of md_blocks
+ * @chunk: chunk of interest
+ *
+ * This conversion is from the number of physical pages that the chunk
+ * serves to the number of bitmap blocks used.
+ */
+static inline int pcpu_chunk_nr_blocks(struct pcpu_chunk *chunk)
+{
+	return chunk->nr_pages * PAGE_SIZE / PCPU_BITMAP_BLOCK_SIZE;
+}
+
+/**
  * pcpu_nr_pages_to_map_bits - converts the pages to size of bitmap
  * @pages: number of physical pages
  *
diff --git a/mm/percpu.c b/mm/percpu.c
index c31b0c8..6bddc02 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -63,6 +63,7 @@
 #include <linux/bitmap.h>
 #include <linux/bootmem.h>
 #include <linux/err.h>
+#include <linux/lcm.h>
 #include <linux/list.h>
 #include <linux/log2.h>
 #include <linux/mm.h>
@@ -279,6 +280,26 @@ static void pcpu_next_pop(unsigned long *bitmap, int *rs, int *re, int end)
 	     (rs) < (re);						     \
 	     (rs) = (re) + 1, pcpu_next_pop((bitmap), &(rs), &(re), (end)))
 
+/*
+ * The following are helper functions to help access bitmaps and convert
+ * between bitmap offsets to address offsets.
+ */
+static unsigned long *pcpu_index_alloc_map(struct pcpu_chunk *chunk, int index)
+{
+	return chunk->alloc_map +
+	       (index * PCPU_BITMAP_BLOCK_BITS / BITS_PER_LONG);
+}
+
+static unsigned long pcpu_off_to_block_index(int off)
+{
+	return off / PCPU_BITMAP_BLOCK_BITS;
+}
+
+static unsigned long pcpu_off_to_block_off(int off)
+{
+	return off & (PCPU_BITMAP_BLOCK_BITS - 1);
+}
+
 /**
  * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
@@ -424,6 +445,154 @@ static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
 }
 
 /**
+ * pcpu_block_update - updates a block given a free area
+ * @block: block of interest
+ * @start: start offset in block
+ * @end: end offset in block
+ *
+ * Updates a block given a known free area.  The region [start, end) is
+ * expected to be the entirety of the free area within a block.
+ */
+static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
+{
+	int contig = end - start;
+
+	block->first_free = min(block->first_free, start);
+	if (start == 0)
+		block->left_free = contig;
+
+	if (end == PCPU_BITMAP_BLOCK_BITS)
+		block->right_free = contig;
+
+	if (contig > block->contig_hint) {
+		block->contig_hint_start = start;
+		block->contig_hint = contig;
+	}
+}
+
+/**
+ * pcpu_block_refresh_hint
+ * @chunk: chunk of interest
+ * @index: index of the metadata block
+ *
+ * Scans over the block beginning at first_free and updates the block
+ * metadata accordingly.
+ */
+static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
+{
+	struct pcpu_block_md *block = chunk->md_blocks + index;
+	unsigned long *alloc_map = pcpu_index_alloc_map(chunk, index);
+	int rs, re;	/* region start, region end */
+
+	/* clear hints */
+	block->contig_hint = 0;
+	block->left_free = block->right_free = 0;
+
+	/* iterate over free areas and update the contig hints */
+	pcpu_for_each_unpop_region(alloc_map, rs, re, block->first_free,
+				   PCPU_BITMAP_BLOCK_BITS) {
+		pcpu_block_update(block, rs, re);
+	}
+}
+
+/**
+ * pcpu_block_update_hint_alloc - update hint on allocation path
+ * @chunk: chunk of interest
+ * @bit_off: chunk offset
+ * @bits: size of request
+ */
+static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
+					 int bits)
+{
+	struct pcpu_block_md *s_block, *e_block, *block;
+	int s_index, e_index;	/* block indexes of the freed allocation */
+	int s_off, e_off;	/* block offsets of the freed allocation */
+
+	/*
+	 * Calculate per block offsets.
+	 * The calculation uses an inclusive range, but the resulting offsets
+	 * are [start, end).  e_index always points to the last block in the
+	 * range.
+	 */
+	s_index = pcpu_off_to_block_index(bit_off);
+	e_index = pcpu_off_to_block_index(bit_off + bits - 1);
+	s_off = pcpu_off_to_block_off(bit_off);
+	e_off = pcpu_off_to_block_off(bit_off + bits - 1) + 1;
+
+	s_block = chunk->md_blocks + s_index;
+	e_block = chunk->md_blocks + e_index;
+
+	/*
+	 * Update s_block.
+	 */
+	pcpu_block_refresh_hint(chunk, s_index);
+
+	/*
+	 * Update e_block.
+	 */
+	if (s_index != e_index) {
+		pcpu_block_refresh_hint(chunk, e_index);
+
+		/* update in-between md_blocks */
+		for (block = s_block + 1; block < e_block; block++) {
+			block->contig_hint = 0;
+			block->left_free = 0;
+			block->right_free = 0;
+		}
+	}
+
+	pcpu_chunk_refresh_hint(chunk);
+}
+
+/**
+ * pcpu_block_update_hint_free - updates the block hints on the free path
+ * @chunk: chunk of interest
+ * @bit_off: chunk offset
+ * @bits: size of request
+ */
+static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
+					int bits)
+{
+	struct pcpu_block_md *s_block, *e_block, *block;
+	int s_index, e_index;	/* block indexes of the freed allocation */
+	int s_off, e_off;	/* block offsets of the freed allocation */
+
+	/*
+	 * Calculate per block offsets.
+	 * The calculation uses an inclusive range, but the resulting offsets
+	 * are [start, end).  e_index always points to the last block in the
+	 * range.
+	 */
+	s_index = pcpu_off_to_block_index(bit_off);
+	e_index = pcpu_off_to_block_index(bit_off + bits - 1);
+	s_off = pcpu_off_to_block_off(bit_off);
+	e_off = pcpu_off_to_block_off(bit_off + bits - 1) + 1;
+
+	s_block = chunk->md_blocks + s_index;
+	e_block = chunk->md_blocks + e_index;
+
+	/* update s_block */
+	pcpu_block_refresh_hint(chunk, s_index);
+
+	/* freeing in the same block */
+	if (s_index != e_index) {
+		/* update e_block */
+		pcpu_block_refresh_hint(chunk, e_index);
+
+		/* reset md_blocks in the middle */
+		for (block = s_block + 1; block < e_block; block++) {
+			block->first_free = 0;
+			block->contig_hint_start = 0;
+			block->contig_hint = PCPU_BITMAP_BLOCK_BITS;
+			block->left_free = PCPU_BITMAP_BLOCK_BITS;
+			block->right_free = PCPU_BITMAP_BLOCK_BITS;
+		}
+	}
+
+	pcpu_chunk_refresh_hint(chunk);
+}
+
+/**
  * pcpu_is_populated - determines if the region is populated
  * @chunk: chunk of interest
  * @bit_off: chunk offset
@@ -539,7 +708,7 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 
 	chunk->free_bytes -= alloc_bits * PCPU_MIN_ALLOC_SIZE;
 
-	pcpu_chunk_refresh_hint(chunk);
+	pcpu_block_update_hint_alloc(chunk, bit_off, alloc_bits);
 
 	pcpu_chunk_relocate(chunk, oslot);
 
@@ -574,11 +743,24 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 	/* update metadata */
 	chunk->free_bytes += bits * PCPU_MIN_ALLOC_SIZE;
 
-	pcpu_chunk_refresh_hint(chunk);
+	pcpu_block_update_hint_free(chunk, bit_off, bits);
 
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
+static void pcpu_init_md_blocks(struct pcpu_chunk *chunk)
+{
+	struct pcpu_block_md *md_block;
+
+	for (md_block = chunk->md_blocks;
+	     md_block != chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
+	     md_block++) {
+		md_block->contig_hint = PCPU_BITMAP_BLOCK_BITS;
+		md_block->left_free = PCPU_BITMAP_BLOCK_BITS;
+		md_block->right_free = PCPU_BITMAP_BLOCK_BITS;
+	}
+}
+
 /**
  * pcpu_alloc_first_chunk - creates chunks that serve the first chunk
  * @tmp_addr: the start of the region served
@@ -596,7 +778,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 							 int map_size)
 {
 	struct pcpu_chunk *chunk;
-	unsigned long aligned_addr;
+	unsigned long aligned_addr, lcm_align;
 	int start_offset, offset_bits, region_size, region_bits;
 
 	/* region calculations */
@@ -604,7 +786,13 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 
 	start_offset = tmp_addr - aligned_addr;
 
-	region_size = PFN_ALIGN(start_offset + map_size);
+	/*
+	 * Align the end of the region with the LCM of PAGE_SIZE and
+	 * PCPU_BITMAP_BLOCK_SIZE.  One of these constants is a multiple of
+	 * the other.
+	 */
+	lcm_align = lcm(PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE);
+	region_size = ALIGN(start_offset + map_size, lcm_align);
 
 	/* allocate chunk */
 	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
@@ -620,12 +808,13 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
 	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->alloc_map = memblock_virt_alloc(
-				BITS_TO_LONGS(region_bits) *
-				sizeof(chunk->alloc_map[0]), 0);
-	chunk->bound_map = memblock_virt_alloc(
-				BITS_TO_LONGS(region_bits + 1) *
-				sizeof(chunk->bound_map[0]), 0);
+	chunk->alloc_map = memblock_virt_alloc(BITS_TO_LONGS(region_bits) *
+					       sizeof(chunk->alloc_map[0]), 0);
+	chunk->bound_map = memblock_virt_alloc(BITS_TO_LONGS(region_bits + 1) *
+					       sizeof(chunk->bound_map[0]), 0);
+	chunk->md_blocks = memblock_virt_alloc(pcpu_chunk_nr_blocks(chunk) *
+					       sizeof(chunk->md_blocks[0]), 0);
+	pcpu_init_md_blocks(chunk);
 
 	/* manage populated page bitmap */
 	chunk->immutable = true;
@@ -644,6 +833,8 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 		bitmap_set(chunk->alloc_map, 0, offset_bits);
 		set_bit(0, chunk->bound_map);
 		set_bit(offset_bits, chunk->bound_map);
+
+		pcpu_block_update_hint_alloc(chunk, 0, offset_bits);
 	}
 
 	if (chunk->end_offset) {
@@ -654,9 +845,10 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 			   offset_bits);
 		set_bit(start_offset + map_size, chunk->bound_map);
 		set_bit(region_bits, chunk->bound_map);
-	}
 
-	pcpu_chunk_refresh_hint(chunk);
+		pcpu_block_update_hint_alloc(chunk, pcpu_chunk_map_bits(chunk)
+					     - offset_bits, offset_bits);
+	}
 
 	return chunk;
 }
@@ -684,12 +876,21 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	if (!chunk->bound_map)
 		goto bound_map_fail;
 
+	chunk->md_blocks = pcpu_mem_zalloc(pcpu_chunk_nr_blocks(chunk) *
+					   sizeof(chunk->md_blocks[0]));
+	if (!chunk->md_blocks)
+		goto md_blocks_fail;
+
+	pcpu_init_md_blocks(chunk);
+
 	/* init metadata */
 	chunk->contig_bits = region_bits;
 	chunk->free_bytes = chunk->nr_pages * PAGE_SIZE;
 
 	return chunk;
 
+md_blocks_fail:
+	pcpu_mem_free(chunk->bound_map);
 bound_map_fail:
 	pcpu_mem_free(chunk->alloc_map);
 alloc_map_fail:
@@ -1527,9 +1728,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(ai->unit_size < size_sum);
 	PCPU_SETUP_BUG_ON(offset_in_page(ai->unit_size));
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
+	PCPU_SETUP_BUG_ON(!IS_ALIGNED(ai->unit_size, PCPU_BITMAP_BLOCK_SIZE));
 	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
 	PCPU_SETUP_BUG_ON(!ai->dyn_size);
 	PCPU_SETUP_BUG_ON(!IS_ALIGNED(ai->reserved_size, PCPU_MIN_ALLOC_SIZE));
+	PCPU_SETUP_BUG_ON(!(IS_ALIGNED(PCPU_BITMAP_BLOCK_SIZE, PAGE_SIZE) ||
+			    IS_ALIGNED(PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE)));
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
