Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 764F16B059C
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t8so135463811pgs.5
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w21si9900737pge.368.2017.07.15.19.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:46 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 10/10] percpu: add optimizations on allocation path for the bitmap allocator
Date: Sat, 15 Jul 2017 22:23:15 -0400
Message-ID: <20170716022315.19892-11-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch adds two optimizations to the allocation path. The first is
to not consider a chunk if the requested allocation cannot fit in the
chunk's contig_hint. The benefit is that this avoids unncessary scanning
over a chunk as the assumption is memory pressure is high and creating a
new chunk has minimal consequences. This may fail when the contig_hint
has poor alignment, but again we fall back on the high memory pressure
argument.

The second is just a fail-fast mechanism. When allocating, a offset is
identified within a block and then scanning is used to see if it will
fit. An offset should never be returned unless it is known to fit, so
here we just bind the scanning to the size of a block.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 569df63..7496571 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -885,6 +885,12 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int bit_size,
 
 	lockdep_assert_held(&pcpu_lock);
 
+	/* check chunk->contig_hint to see if alloc can fit - see note above */
+	block_off = ALIGN(chunk->contig_hint_start, align) -
+		    chunk->contig_hint_start;
+	if (block_off + bit_size > chunk->contig_hint)
+		return -1;
+
 	cur_free = block_off = 0;
 	s_index = chunk->first_free_block;
 	for (i = chunk->first_free_block; i < pcpu_nr_pages_to_blocks(chunk);
@@ -973,19 +979,23 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int bit_size,
 			   size_t align, int start)
 {
 	size_t align_mask = (align) ? (align - 1) : 0;
-	int i, bit_off, oslot;
+	int i, bit_off, end, oslot;
 	struct pcpu_bitmap_md *block;
 
 	lockdep_assert_held(&pcpu_lock);
 
 	oslot = pcpu_chunk_slot(chunk);
 
-	/* search to find fit */
-	bit_off = bitmap_find_next_zero_area(chunk->alloc_map,
-					     pcpu_nr_pages_to_bits(chunk),
-					     start, bit_size, align_mask);
+	/*
+	 * Search to find fit.  The search for the start is limited to
+	 * be within a block_size, but should in reality never be hit
+	 * as the contig_hint should be a valid placement.
+	 */
+	end = start + bit_size + PCPU_BITMAP_BLOCK_SIZE;
+	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
+					     bit_size, align_mask);
 
-	if (bit_off >= pcpu_nr_pages_to_bits(chunk))
+	if (bit_off >= end)
 		return -1;
 
 	/* update alloc map */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
