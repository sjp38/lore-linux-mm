Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF026B03B5
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u7so121962683pgo.6
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:56 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y11si7721975plg.62.2017.07.24.16.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:55 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 17/23] percpu: skip chunks if the alloc does not fit in the contig hint
Date: Mon, 24 Jul 2017 19:02:14 -0400
Message-ID: <20170724230220.21774-18-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch adds chunk->contig_bits_start to keep track of the contig
hint's offset and the check to skip the chunk if it does not fit. If
the chunk's contig hint starting offset cannot satisfy an allocation,
the allocator assumes there is enough memory pressure in this chunk to
either use a different chunk or create a new one. This accepts a less
tight packing for a smoother latency curve.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |  2 ++
 mm/percpu.c          | 18 ++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index e60e049..7065faf 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -29,6 +29,8 @@ struct pcpu_chunk {
 	struct list_head	list;		/* linked to pcpu_slot lists */
 	int			free_bytes;	/* free bytes in the chunk */
 	int			contig_bits;	/* max contiguous size hint */
+	int			contig_bits_start; /* contig_bits starting
+						      offset */
 	void			*base_addr;	/* base address of this chunk */
 
 	unsigned long		*alloc_map;	/* allocation map */
diff --git a/mm/percpu.c b/mm/percpu.c
index ad70c67..3732373 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -393,12 +393,14 @@ static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk, int bit_off,
  * @bit_off: chunk offset
  * @bits: size of free area
  *
- * This updates the chunk's contig hint given a free area.
+ * This updates the chunk's contig hint and starting offset given a free area.
  */
 static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
 {
-	if (bits > chunk->contig_bits)
+	if (bits > chunk->contig_bits) {
+		chunk->contig_bits_start = bit_off;
 		chunk->contig_bits = bits;
+	}
 }
 
 /**
@@ -409,6 +411,7 @@ static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
  *
  * Updates:
  *      chunk->contig_bits
+ *      chunk->contig_bits_start
  *      nr_empty_pop_pages
  */
 static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
@@ -639,6 +642,17 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	int bit_off, bits;
 	int re; /* region end */
 
+	/*
+	 * Check to see if the allocation can fit in the chunk's contig hint.
+	 * This is an optimization to prevent scanning by assuming if it
+	 * cannot fit in the global hint, there is memory pressure and creating
+	 * a new chunk would happen soon.
+	 */
+	bit_off = ALIGN(chunk->contig_bits_start, align) -
+		  chunk->contig_bits_start;
+	if (bit_off + alloc_bits > chunk->contig_bits)
+		return -1;
+
 	pcpu_for_each_unpop_region(chunk->alloc_map, bit_off, re,
 				   chunk->first_bit,
 				   pcpu_chunk_map_bits(chunk)) {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
