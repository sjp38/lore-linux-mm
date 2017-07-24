Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2A946B0493
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:03:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c14so165083678pgn.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:03:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y2si7533629pgr.803.2017.07.24.16.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:59 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 21/23] percpu: use metadata blocks to update the chunk contig hint
Date: Mon, 24 Jul 2017 19:02:18 -0400
Message-ID: <20170724230220.21774-22-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The largest free region will either be a block level contig hint or an
aggregate over the left_free and right_free areas of blocks. This is a
much smaller set of free areas that need to be checked than a full
traverse.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 80 +++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 70 insertions(+), 10 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 426548a..9e4192c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -306,6 +306,67 @@ static unsigned long pcpu_block_off_to_off(int index, int off)
 }
 
 /**
+ * pcpu_next_md_free_region - finds the next hint free area
+ * @chunk: chunk of interest
+ * @bit_off: chunk offset
+ * @bits: size of free area
+ *
+ * Helper function for pcpu_for_each_md_free_region.  It checks
+ * block->contig_hint and performs aggregation across blocks to find the
+ * next hint.  It modifies bit_off and bits in-place to be consumed in the
+ * loop.
+ */
+static void pcpu_next_md_free_region(struct pcpu_chunk *chunk, int *bit_off,
+				     int *bits)
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
+			if (block->left_free == PCPU_BITMAP_BLOCK_BITS)
+				continue;
+			return;
+		}
+
+		/*
+		 * This checks three things.  First is there a contig_hint to
+		 * check.  Second, have we checked this hint before by
+		 * comparing the block_off.  Third, is this the same as the
+		 * right contig hint.  In the last case, it spills over into
+		 * the next block and should be handled by the contig area
+		 * across blocks code.
+		 */
+		*bits = block->contig_hint;
+		if (*bits && block->contig_hint_start >= block_off &&
+		    *bits + block->contig_hint_start < PCPU_BITMAP_BLOCK_BITS) {
+			*bit_off = pcpu_block_off_to_off(i,
+					block->contig_hint_start);
+			return;
+		}
+
+		*bits = block->right_free;
+		*bit_off = (i + 1) * PCPU_BITMAP_BLOCK_BITS - block->right_free;
+	}
+}
+
+/*
+ * Metadata free area iterators.  These perform aggregation of free areas
+ * based on the metadata blocks and return the offset @bit_off and size in
+ * bits of the free area @bits.
+ */
+#define pcpu_for_each_md_free_region(chunk, bit_off, bits)		\
+	for (pcpu_next_md_free_region((chunk), &(bit_off), &(bits));	\
+	     (bit_off) < pcpu_chunk_map_bits((chunk));			\
+	     (bit_off) += (bits) + 1,					\
+	     pcpu_next_md_free_region((chunk), &(bit_off), &(bits)))
+
+/**
  * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
  *
@@ -418,29 +479,28 @@ static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
  * pcpu_chunk_refresh_hint - updates metadata about a chunk
  * @chunk: chunk of interest
  *
- * Iterates over the chunk to find the largest free area.
+ * Iterates over the metadata blocks to find the largest contig area.
+ * It also counts the populated pages and uses the delta to update the
+ * global count.
  *
  * Updates:
  *      chunk->contig_bits
  *      chunk->contig_bits_start
- *      nr_empty_pop_pages
+ *      nr_empty_pop_pages (chunk and global)
  */
 static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
 {
-	int bits, nr_empty_pop_pages;
-	int rs, re; /* region start, region end */
+	int bit_off, bits, nr_empty_pop_pages;
 
 	/* clear metadata */
 	chunk->contig_bits = 0;
 
+	bit_off = chunk->first_bit;
 	bits = nr_empty_pop_pages = 0;
-	pcpu_for_each_unpop_region(chunk->alloc_map, rs, re, chunk->first_bit,
-				   pcpu_chunk_map_bits(chunk)) {
-		bits = re - rs;
-
-		pcpu_chunk_update(chunk, rs, bits);
+	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
+		pcpu_chunk_update(chunk, bit_off, bits);
 
-		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, rs, bits);
+		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, bit_off, bits);
 	}
 
 	/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
