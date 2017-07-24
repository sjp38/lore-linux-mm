Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A866A6B0496
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:03:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r123so12158565wmb.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:03:04 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h191si6366521wma.181.2017.07.24.16.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:03:03 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 22/23] percpu: update pcpu_find_block_fit to use an iterator
Date: Mon, 24 Jul 2017 19:02:19 -0400
Message-ID: <20170724230220.21774-23-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The simple, and expensive, way to find a free area is to iterate over
the entire bitmap until an area is found that fits the allocation size
and alignment. This patch makes use of an iterate that find an area to
check by using the block level contig hints. It will only return an area
that can fit the size and alignment request. If the request can fit
inside a block, it returns the first_free bit to start checking from to
see if it can be fulfilled prior to the contig hint. The pcpu_alloc_area
check has a bound of a block size added in case it is wrong.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 112 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 92 insertions(+), 20 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 9e4192c..ffa9da7 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -355,10 +355,72 @@ static void pcpu_next_md_free_region(struct pcpu_chunk *chunk, int *bit_off,
 	}
 }
 
+/**
+ * pcpu_next_fit_region - finds fit areas for a given allocation request
+ * @chunk: chunk of interest
+ * @alloc_bits: size of allocation
+ * @align: alignment of area (max PAGE_SIZE)
+ * @bit_off: chunk offset
+ * @bits: size of free area
+ *
+ * Finds the next free region that is viable for use with a given size and
+ * alignment.  This only returns if there is a valid area to be used for this
+ * allocation.  block->first_free is returned if the allocation request fits
+ * within the block to see if the request can be fulfilled prior to the contig
+ * hint.
+ */
+static void pcpu_next_fit_region(struct pcpu_chunk *chunk, int alloc_bits,
+				 int align, int *bit_off, int *bits)
+{
+	int i = pcpu_off_to_block_index(*bit_off);
+	int block_off = pcpu_off_to_block_off(*bit_off);
+	struct pcpu_block_md *block;
+
+	*bits = 0;
+	for (block = chunk->md_blocks + i; i < pcpu_chunk_nr_blocks(chunk);
+	     block++, i++) {
+		/* handles contig area across blocks */
+		if (*bits) {
+			*bits += block->left_free;
+			if (*bits >= alloc_bits)
+				return;
+			if (block->left_free == PCPU_BITMAP_BLOCK_BITS)
+				continue;
+		}
+
+		/* check block->contig_hint */
+		*bits = ALIGN(block->contig_hint_start, align) -
+			block->contig_hint_start;
+		/*
+		 * This uses the block offset to determine if this has been
+		 * checked in the prior iteration.
+		 */
+		if (block->contig_hint &&
+		    block->contig_hint_start >= block_off &&
+		    block->contig_hint >= *bits + alloc_bits) {
+			*bits += alloc_bits + block->contig_hint_start -
+				 block->first_free;
+			*bit_off = pcpu_block_off_to_off(i, block->first_free);
+			return;
+		}
+
+		*bit_off = ALIGN(PCPU_BITMAP_BLOCK_BITS - block->right_free,
+				 align);
+		*bits = PCPU_BITMAP_BLOCK_BITS - *bit_off;
+		*bit_off = pcpu_block_off_to_off(i, *bit_off);
+		if (*bits >= alloc_bits)
+			return;
+	}
+
+	/* no valid offsets were found - fail condition */
+	*bit_off = pcpu_chunk_map_bits(chunk);
+}
+
 /*
  * Metadata free area iterators.  These perform aggregation of free areas
  * based on the metadata blocks and return the offset @bit_off and size in
- * bits of the free area @bits.
+ * bits of the free area @bits.  pcpu_for_each_fit_region only returns when
+ * a fit is found for the allocation request.
  */
 #define pcpu_for_each_md_free_region(chunk, bit_off, bits)		\
 	for (pcpu_next_md_free_region((chunk), &(bit_off), &(bits));	\
@@ -366,6 +428,14 @@ static void pcpu_next_md_free_region(struct pcpu_chunk *chunk, int *bit_off,
 	     (bit_off) += (bits) + 1,					\
 	     pcpu_next_md_free_region((chunk), &(bit_off), &(bits)))
 
+#define pcpu_for_each_fit_region(chunk, alloc_bits, align, bit_off, bits)     \
+	for (pcpu_next_fit_region((chunk), (alloc_bits), (align), &(bit_off), \
+				  &(bits));				      \
+	     (bit_off) < pcpu_chunk_map_bits((chunk));			      \
+	     (bit_off) += (bits),					      \
+	     pcpu_next_fit_region((chunk), (alloc_bits), (align), &(bit_off), \
+				  &(bits)))
+
 /**
  * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
@@ -818,6 +888,14 @@ static bool pcpu_is_populated(struct pcpu_chunk *chunk, int bit_off, int bits,
  * @align: alignment of area (max PAGE_SIZE bytes)
  * @pop_only: use populated regions only
  *
+ * Given a chunk and an allocation spec, find the offset to begin searching
+ * for a free region.  This iterates over the bitmap metadata blocks to
+ * find an offset that will be guaranteed to fit the requirements.  It is
+ * not quite first fit as if the allocation does not fit in the contig hint
+ * of a block or chunk, it is skipped.  This errs on the side of caution
+ * to prevent excess iteration.  Poor alignment can cause the allocator to
+ * skip over blocks and chunks that have valid free areas.
+ *
  * RETURNS:
  * The offset in the bitmap to begin searching.
  * -1 if no offset is found.
@@ -825,8 +903,7 @@ static bool pcpu_is_populated(struct pcpu_chunk *chunk, int bit_off, int bits,
 static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 			       size_t align, bool pop_only)
 {
-	int bit_off, bits;
-	int re; /* region end */
+	int bit_off, bits, next_off;
 
 	/*
 	 * Check to see if the allocation can fit in the chunk's contig hint.
@@ -839,22 +916,14 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	if (bit_off + alloc_bits > chunk->contig_bits)
 		return -1;
 
-	pcpu_for_each_unpop_region(chunk->alloc_map, bit_off, re,
-				   chunk->first_bit,
-				   pcpu_chunk_map_bits(chunk)) {
-		bits = re - bit_off;
-
-		/* check alignment */
-		bits -= ALIGN(bit_off, align) - bit_off;
-		bit_off = ALIGN(bit_off, align);
-		if (bits < alloc_bits)
-			continue;
-
-		bits = alloc_bits;
+	bit_off = chunk->first_bit;
+	bits = 0;
+	pcpu_for_each_fit_region(chunk, alloc_bits, align, bit_off, bits) {
 		if (!pop_only || pcpu_is_populated(chunk, bit_off, bits,
-						   &bit_off))
+						   &next_off))
 			break;
 
+		bit_off = next_off;
 		bits = 0;
 	}
 
@@ -872,9 +941,12 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
  * @start: bit_off to start searching
  *
  * This function takes in a @start offset to begin searching to fit an
- * allocation of @alloc_bits with alignment @align.  If it confirms a
- * valid free area, it then updates the allocation and boundary maps
- * accordingly.
+ * allocation of @alloc_bits with alignment @align.  It needs to scan
+ * the allocation map because if it fits within the block's contig hint,
+ * @start will be block->first_free. This is an attempt to fill the
+ * allocation prior to breaking the contig hint.  The allocation and
+ * boundary maps are updated accordingly if it confirms a valid
+ * free area.
  *
  * RETURNS:
  * Allocated addr offset in @chunk on success.
@@ -893,7 +965,7 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 	/*
 	 * Search to find a fit.
 	 */
-	end = start + alloc_bits;
+	end = start + alloc_bits + PCPU_BITMAP_BLOCK_BITS;
 	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
 					     alloc_bits, align_mask);
 	if (bit_off >= end)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
