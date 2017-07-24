Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A53A6B0494
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:03:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so4540736wmg.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:03:02 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b20si13780640wrd.228.2017.07.24.16.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:03:01 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 20/23] percpu: update free path to take advantage of contig hints
Date: Mon, 24 Jul 2017 19:02:17 -0400
Message-ID: <20170724230220.21774-21-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The bitmap allocator must keep metadata consistent. The easiest way is
to scan after every allocation for each affected block and the entire
chunk. This is rather expensive.

The free path can take advantage of current contig hints to prevent
scanning within the start and end block.  If a scan is needed, it can
be done by scanning backwards from the start and forwards from the end
to identify the entire free area this can be combined with. The blocks
can then be updated by some basic checks rather than complete block
scans.

A chunk scan happens when the freed area makes a page free, a block
free, or spans across blocks. This is necessary as the contig hint at
this point could span across blocks. The check uses the minimum of page
size and the block size to allow for variable sized blocks. There is a
tradeoff here with not updating after every free. It is possible a
contig hint in one block can be merged with the contig hint in the next
block. This means the contig hint can be off by up to a page. However,
if the chunk's contig hint is contained in one block, the contig hint
will be accurate.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |  3 +++
 mm/percpu.c            | 68 +++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 68 insertions(+), 3 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 31795e6..6a5fb93 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -25,6 +25,9 @@
 #define PCPU_MIN_ALLOC_SHIFT		2
 #define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
 
+/* number of bits per page, used to trigger a scan if blocks are > PAGE_SIZE */
+#define PCPU_BITS_PER_PAGE		(PAGE_SIZE >> PCPU_MIN_ALLOC_SHIFT)
+
 /*
  * This determines the size of each metadata block.  There are several subtle
  * constraints around this constant.  The reserved region must be a multiple of
diff --git a/mm/percpu.c b/mm/percpu.c
index 2bf2cfc..426548a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -300,6 +300,11 @@ static unsigned long pcpu_off_to_block_off(int off)
 	return off & (PCPU_BITMAP_BLOCK_BITS - 1);
 }
 
+static unsigned long pcpu_block_off_to_off(int index, int off)
+{
+	return index * PCPU_BITMAP_BLOCK_BITS + off;
+}
+
 /**
  * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
@@ -616,6 +621,17 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
  * @chunk: chunk of interest
  * @bit_off: chunk offset
  * @bits: size of request
+ *
+ * Updates metadata for the allocation path.  This avoids a blind block
+ * refresh by making use of the block contig hints.  If this fails, it scans
+ * forward and backward to determine the extent of the free area.  This is
+ * capped at the boundary of blocks.
+ *
+ * A chunk update is triggered if a page becomes free, a block becomes free,
+ * or the free spans across blocks.  This tradeoff is to minimize iterating
+ * over the block metadata to update chunk->contig_bits.  chunk->contig_bits
+ * may be off by up to a page, but it will never be more than the available
+ * space.  If the contig hint is contained in one block, it will be accurate.
  */
 static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 					int bits)
@@ -623,6 +639,7 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 	struct pcpu_block_md *s_block, *e_block, *block;
 	int s_index, e_index;	/* block indexes of the freed allocation */
 	int s_off, e_off;	/* block offsets of the freed allocation */
+	int start, end;		/* start and end of the whole free area */
 
 	/*
 	 * Calculate per block offsets.
@@ -638,13 +655,46 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 	s_block = chunk->md_blocks + s_index;
 	e_block = chunk->md_blocks + e_index;
 
+	/*
+	 * Check if the freed area aligns with the block->contig_hint.
+	 * If it does, then the scan to find the beginning/end of the
+	 * larger free area can be avoided.
+	 *
+	 * start and end refer to beginning and end of the free area
+	 * within each their respective blocks.  This is not necessarily
+	 * the entire free area as it may span blocks past the beginning
+	 * or end of the block.
+	 */
+	start = s_off;
+	if (s_off == s_block->contig_hint + s_block->contig_hint_start) {
+		start = s_block->contig_hint_start;
+	} else {
+		/*
+		 * Scan backwards to find the extent of the free area.
+		 * find_last_bit returns the starting bit, so if the start bit
+		 * is returned, that means there was no last bit and the
+		 * remainder of the chunk is free.
+		 */
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
+				    PCPU_BITMAP_BLOCK_BITS, end);
+
 	/* update s_block */
-	pcpu_block_refresh_hint(chunk, s_index);
+	e_off = (s_index == e_index) ? end : PCPU_BITMAP_BLOCK_BITS;
+	pcpu_block_update(s_block, start, e_off);
 
 	/* freeing in the same block */
 	if (s_index != e_index) {
 		/* update e_block */
-		pcpu_block_refresh_hint(chunk, e_index);
+		pcpu_block_update(e_block, 0, end);
 
 		/* reset md_blocks in the middle */
 		for (block = s_block + 1; block < e_block; block++) {
@@ -656,7 +706,19 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 		}
 	}
 
-	pcpu_chunk_refresh_hint(chunk);
+	/*
+	 * Refresh chunk metadata when the free makes a page free, a block
+	 * free, or spans across blocks.  The contig hint may be off by up to
+	 * a page, but if the hint is contained in a block, it will be accurate
+	 * with the else condition below.
+	 */
+	if ((ALIGN_DOWN(end, min(PCPU_BITS_PER_PAGE, PCPU_BITMAP_BLOCK_BITS)) >
+	     ALIGN(start, min(PCPU_BITS_PER_PAGE, PCPU_BITMAP_BLOCK_BITS))) ||
+	    s_index != e_index)
+		pcpu_chunk_refresh_hint(chunk);
+	else
+		pcpu_chunk_update(chunk, pcpu_block_off_to_off(s_index, start),
+				  s_block->contig_hint);
 }
 
 /**
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
